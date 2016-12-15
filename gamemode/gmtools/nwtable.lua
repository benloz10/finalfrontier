-- Copyright (c) 2014 James King [metapyziks@gmail.com]
-- 
-- This file is part of GMTools.
-- 
-- GMTools is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as
-- published by the Free Software Foundation, either version 3 of
-- the License, or (at your option) any later version.
-- 
-- GMTools is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public License
-- along with GMTools. If not, see <http://www.gnu.org/licenses/>.

if SERVER then AddCSLuaFile("nwtable.lua") end

local POLL_PERIOD = 0

if not NWTInfo then
    NWTInfo = {}
    NWTInfo.__index = NWTInfo

    NWTInfo._entity = nil
    NWTInfo._ident = nil
    NWTInfo._timestampIdent = nil

    NWTInfo._keyNums = nil

    NWTInfo._value = nil

    NWTInfo._nwtents = {}
    NWTInfo._globals = {}
end

local _nwtents = NWTInfo._nwtents
local _globals = NWTInfo._globals

function NWTInfo:GetServerTimestamp()
    return -1
end

if SERVER then
    util.AddNetworkString("NWTableUpdate")

    NWTInfo._live = nil
    NWTInfo._info = nil
    NWTInfo._nextKeyNum = 1

    function NWTInfo:SetServerTimestamp(time)
        return
    end

    function NWTInfo:GetLastUpdateTime()
        return self._info._lastupdate
    end

    function NWTInfo:GetValue()
        return self._live
    end

    function NWTInfo:Update()
        local t = CurTime()
        if self:UpdateTable(self._value, self._info, self._live, t) then
            self:SetServerTimestamp(t)
        end
    end

    local _typewrite = {
        [TYPE_NIL] = function(v) end,
        [TYPE_STRING] = function(v) net.WriteString(v) end,
        [TYPE_NUMBER] = function(v) net.WriteFloat(v) end,
        [TYPE_BOOL] = function(v) net.WriteBit(v) end,
        [TYPE_ENTITY] = function(v) net.WriteEntity(v) end
    }

    function NWTInfo:UpdateTable(old, info, new, time)
        local changed = false
        for k, v in pairs(new) do
            local kid, vid = TypeID(k), TypeID(v)
            if _typewrite[kid] and (_typewrite[vid] or vid == TYPE_TABLE) then
                if not self._keyNums[k] then
                    self._keyNums[k] = {num = self._nextKeyNum, time = time}
                    self._nextKeyNum = self._nextKeyNum + 1
                end
                if vid == TYPE_TABLE then
                    if not old[k] then
                        old[k] = {}
                        info[k] = {}
                        changed = true
                    end
                    if self:UpdateTable(old[k], info[k], v, time) then
                        changed = true
                    end
                elseif (vid == TYPE_NIL and TypeID(old) ~= TYPE_NIL)
                    or (_typewrite[vid] and old[k] ~= v) then
                    old[k] = v
                    info[k] = time
                    changed = true
                end
            end
        end

        for k, v in pairs(old) do
            if not new[k] and old[k] then
                old[k] = nil
                info[k] = time
                changed = true
            end
        end

        if changed then info._lastupdate = time end
        return changed
    end

    net.Receive("NWTableUpdate", function(len, ply)
        local count = net.ReadUInt(16)

        if count == 0 then return end

        net.Start("NWTableUpdate")
        net.WriteUInt(count, 16)
        net.WriteFloat(CurTime())

        for i = 1, count do
            local ent = net.ReadEntity()
            local ident = net.ReadString()
            local time = net.ReadFloat()

            if not IsValid(ent) and _globals[ident] then
                _globals[ident]:SendUpdate(ply, time)
            elseif ent._nwts and ent._nwts[ident] then
                ent._nwts[ident]:SendUpdate(ply, time)
            end
        end
        net.Send(ply)
    end)

    function NWTInfo:SendUpdate(ply, since)
        since = since or 0

        if since >= self._info._lastupdate then
            return
        end

        net.WriteEntity(self._entity)
        net.WriteString(self._ident)

        local keyBits = 8
        if table.Count(self._keyNums) > 255 then
            keyBits = 16
            if table.Count(self._keyNums) > 65535 then
                keyBits = 32
            end
        end
        net.WriteInt(keyBits, 8)
        for k, v in pairs(self._keyNums) do
            if v.time > since then
                local kid = TypeID(k)
                net.WriteUInt(v.num, keyBits)
                net.WriteInt(kid, 8)
                _typewrite[kid](k)
            end
        end
        net.WriteUInt(0, keyBits)

        self:SendTable(self._value, self._info, since, keyBits)
    end

    function NWTInfo:SendTable(table, info, since, keyBits)
        local count = 0
        for k, i in pairs(info) do
            if k ~= "_lastupdate" then
                local v = table[k]
                local tid = TypeID(v)
                if (tid == TYPE_TABLE and i._lastupdate and i._lastupdate > since)
                    or (tid ~= TYPE_TABLE and i > since) then
                    count = count + 1
                end
            end
        end

        net.WriteInt(count, 8)
        for k, i in pairs(info) do
            if k ~= "_lastupdate" then
                local v = table[k]
                local tid = TypeID(v)
                if tid == TYPE_TABLE then
                    if i._lastupdate and i._lastupdate > since then
                        net.WriteUInt(self._keyNums[k].num, keyBits)
                        net.WriteInt(tid, 8)
                        self:SendTable(v, i, since, keyBits)
                    end
                elseif i > since then
                    net.WriteUInt(self._keyNums[k].num, keyBits)
                    net.WriteInt(tid, 8)
                    _typewrite[tid](v)
                end
            end
        end
    end
elseif CLIENT then
    NWTInfo._lastupdate = -1
    NWTInfo._pendingupdate = false

    function NWTInfo:GetValue()
        return self._value
    end

    function NWTInfo:NeedsUpdate()
        return self._lastupdate < self:GetServerTimestamp()
    end

    function NWTInfo:GetLastUpdateTime()
        return self._lastupdate
    end

    function NWTInfo:CheckForUpdates()
        if not self._pendingupdate and self:NeedsUpdate() then
            self._pendingupdate = true
            return true
        end
    end

    function NWTInfo:Forget()
        if self._entity then
            if not self._entity._nwts then return end

            self._entity._nwts[self._ident] = nil

            if table.Count(self._entity._nwts) == 0 then
                self._entity._nwts = nil
                table.RemoveByValue(_nwtents, self._entity)
            end
        else
            if not _globals[self._ident] then return end

            _globals[self._ident] = nil
        end
    end

    local _typeread = {
        [TYPE_NIL] = function() return nil end,
        [TYPE_STRING] = function() return net.ReadString() end,
        [TYPE_NUMBER] = function() return net.ReadFloat() end,
        [TYPE_BOOL] = function() return net.ReadBit() == 1 end,
        [TYPE_ENTITY] = function() return net.ReadEntity() end
    }

    function NWTInfo:ReceiveUpdate(time)
        if time < self._lastupdate then return end
        self._lastupdate = time
        local keyBits = net.ReadInt(8)
        while true do
            local num = net.ReadUInt(keyBits)
            if num == 0 then break end
            local kid = net.ReadInt(8)
            self._keyNums[num] = _typeread[kid]()
        end
        self:ReceiveTable(self._value, keyBits)
    end

    function NWTInfo:ReceiveTable(table, keyBits)
        local count = net.ReadInt(8)
        for i = 1, count do
            local key = self._keyNums[net.ReadUInt(keyBits)]
            local tid = net.ReadInt(8)

            if tid == TYPE_TABLE then
                if not table[key] then table[key] = {} end
                self:ReceiveTable(table[key], keyBits)
            else
                table[key] = _typeread[tid]()
            end
        end
    end

    if not timer.Exists("NWTableUpdate") then
        timer.Create("NWTableUpdate", POLL_PERIOD, 0, function()
            local toUpdate = {}

            for _, tbl in pairs(_globals) do
                if tbl and tbl:CheckForUpdates() then
                    table.insert(toUpdate, tbl)
                end
            end

            local i = #_nwtents
            while i > 0 do
                local ent = _nwtents[i]

                if not IsValid(ent) or not ent._nwts then
                    table.remove(_nwtents, i)
                else
                    for _, tbl in pairs(ent._nwts) do
                        if tbl and tbl:CheckForUpdates() then
                            table.insert(toUpdate, tbl)
                        end
                    end
                end

                i = i - 1
            end

            if #toUpdate == 0 then return end

            net.Start("NWTableUpdate")
            net.WriteUInt(#toUpdate, 16)
            for _, tbl in ipairs(toUpdate) do
                net.WriteEntity(tbl._entity)
                net.WriteString(tbl._ident)
                net.WriteFloat(tbl._lastupdate)
            end
            net.SendToServer()
        end)

        net.Receive("NWTableUpdate", function(len, ply)
            local count = net.ReadUInt(16)
            local time = net.ReadFloat()

            for i = 1, count do
                local ent = net.ReadEntity()
                local ident = net.ReadString()

                if not IsValid(ent) then
                    local tab = _globals[ident]
                    if tab then
                        tab:ReceiveUpdate(time)
                        tab._pendingupdate = false
                    end
                elseif ent._nwts then
                    local tab = ent._nwts[ident]
                    if tab then
                        tab:ReceiveUpdate(time)
                        tab._pendingupdate = false
                    end
                end
            end
        end)
    end
end

function NWTInfo:GetTimestampIdent()
    return self._timestampIdent
end

function NWTInfo:New(ent, ident, orig)
    if self == NWTInfo then
        return setmetatable({}, self):New(ent, ident, orig)
    end

    self._entity = ent
    self._ident = ident

    if ent then
        self._timestampIdent = ident .. "Timestamp"
    else
        self._timestampIdent = "_" .. ident
    end

    self._keyNums = {}


    if SERVER then
        self._value = {}
        self._info = { _lastupdate = CurTime() }
        self._live = orig or {}

        self._live.GetLastUpdateTime = function(val)
            return self:GetLastUpdateTime()
        end

        self._live.Update = function(val)
            self:Update()
        end
    elseif CLIENT then
        self._value = orig or {}

        self._value.NeedsUpdate = function(val)
            return self:NeedsUpdate()
        end

        self._value.IsCurrent = function(val)
            return not self:NeedsUpdate()
        end

        self._value.GetLastUpdateTime = function(val)
            return self:GetLastUpdateTime()
        end

        self._value.Forget = function(val)
            self:Forget()
        end
    end

    return self
end

_mt = FindMetaTable("Entity")

function _mt:NetworkTable(index, ident, orig)
    if not self._nwts then self._nwts = {} end

    if self._nwts[ident] then return self._nwts[ident]:GetValue() end
   
    local nwt = NWTInfo:New(self, ident, orig)
    self._nwts[ident] = nwt

    if not table.HasValue(_nwtents, self) then
        table.insert(_nwtents, self)
    end

    self:NetworkVar("Float", index, nwt:GetTimestampIdent())

    if SERVER then
        local setter = self["Set" .. nwt:GetTimestampIdent()]
        nwt.SetServerTimestamp = function(nwt, val)
            setter(self, val)
        end

        nwt:Update()
        nwt:SetServerTimestamp(CurTime())
    end

    local getter = self["Get" .. nwt:GetTimestampIdent()]
    nwt.GetServerTimestamp = function(nwt)
        return getter(self)
    end
    
    return nwt:GetValue()
end

function NetworkTable(ident, orig)
    if _globals[ident] then return _globals[ident]:GetValue() end

    local nwt = NWTInfo:New(nil, ident, orig)
    _globals[ident] = nwt

    local timestamp = nwt:GetTimestampIdent()

    if SERVER then
        nwt.SetServerTimestamp = function(nwt, val)
            SetGlobalFloat(timestamp, val)
        end

        nwt:Update()
        nwt:SetServerTimestamp(CurTime())
    end

    nwt.GetServerTimestamp = function(nwt)
        return GetGlobalFloat(timestamp, -1)
    end

    return nwt:GetValue()
end
