-- Copyright (c) 2014 James King [metapyziks@gmail.com]
-- 
-- This file is part of Final Frontier.
-- 
-- Final Frontier is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as
-- published by the Free Software Foundation, either version 3 of
-- the License, or (at your option) any later version.
-- 
-- Final Frontier is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public License
-- along with Final Frontier. If not, see <http://www.gnu.org/licenses/>.

if not npcships then
    npcships = {}

    npcships._dict = {}
    npcships._nwdata = NetworkTable("npcships")
end

function npcships.Add(ship)
    local name = ship:GetName()
    if not name or npcships._dict[name] then return end
    
    npcships._dict[name] = ship
    table.insert(npcships._nwdata, name)
    npcships._nwdata:Update()

    local x, y = ship:GetCoordinates()
    local sector = universe:GetSector(x, y)
    MsgN("NPC Ship added in sector " .. sector:GetSectorName()
        .. " : [" .. x .. ", " .. y .. "] (" .. name .. ")")
end

function npcships.GetAll()
    return npcships._dict
end

function npcships.GetByName(name)
    return npcships._dict[name]
end

function npcships.InitPostEntity()
    local classOrder = {
        "info_ff_npcship"
    }

    for _1, class in ipairs(classOrder) do
        for _2, ent in ipairs(ents.FindByClass(class)) do
            ent:InitPostEntity()
        end
    end
end

concommand.Add("ff_addnpc", function()
    local newship = ents.Create("info_ff_npcship")
    newship:SetPos(Vector(0,0,0))
    newship:SetName("NPC_SHIP " .. newship:EntIndex())
    newship:Spawn()
    newship:InitPostEntity()
end)
