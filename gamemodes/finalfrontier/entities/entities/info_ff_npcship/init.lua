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

ENT.Type = "point"
ENT.Base = "base_point"

local MAXIMUM_SPEED = 0.2

ENT._roomdict = nil
ENT._roomlist = nil
ENT._doors = nil
ENT._bounds = nil

ENT._defaultGrids = nil

ENT._systems = nil

ENT._players = nil

ENT._nwdata = nil
ENT._object = nil

ENT._mainLightName = nil
ENT._warnLightName = nil
ENT._warnLightBrushName = nil

ENT._mainLights = nil
ENT._warnLights = nil
ENT._warnLightBrushes = nil

ENT._hazardEnd = 0

ENT._targetShip = nil
ENT._targetLastPos = nil
ENT._targetLastSeen = nil

ENT._attackHoverRange = 0.5
ENT._speedScore = math.Rand(0.2, 1)
ENT._sensorRange = 2
ENT._movementMode = 0
ENT._wanderTiming = nil
ENT._nextWander = nil

ENT._isAggressive = false


function ENT:KeyValue(key, value)
    self._nwdata = self._nwdata or {}

    if key == "health" then
        self:_SetBaseHealth(tonumber(value), true)
    elseif key == "name" then
        self:_SetFullName(tostring(value), true)
    elseif key == "color" then
        self:_SetUIColor(tostring(value), true)
    elseif key == "mainlight" then
        self._mainLightName = tostring(value)
    elseif key == "warnlight" then
        self._warnLightName = tostring(value)
    elseif key == "warnlightbrush" then
        self._warnLightBrushName = tostring(value)
    end
end

function ENT:Think()
    if self._movementMode == 0 then
        if self._nextWander < CurTime() then
            self:GetObject():SetRotation(math.random(-360, 360))
            self._nextWander = CurTime() + math.Rand(self._wanderTiming[1], self._wanderTiming[2])
        end
        if self._isAggressive then
            self._targetShip = self:SearchForEnemy()
            if IsValid(self._targetShip) and self:IsObjectInRange(self._targetShip) then
                self._movementMode = 1
            end
        else
            self:AccelerateForwards()
        end
    elseif self._movementMode == 1 then --Follow enemy
        if not IsValid(self._targetShip) then self._movementMode = 2 MsgN("Ship no longer valid!") return end
        if self:IsObjectInRange(self._targetShip) then
            self._targetLastSeen = CurTime()
            local ox, oy = self._targetShip:GetCoordinates()
            self._targetLastPos = {ox, oy}
            self:PointAt(self._targetShip:GetCoordinates())
            self:ChaseEnemy()
        end
        if self._targetLastSeen < CurTime()-10 then
            self._movementMode = 2
        end
    else
        self._movementMode = 0
    end
end

function ENT:SearchForEnemy()
    local tbl = ents.FindByClass("info_ff_object")
    for i=1, #tbl do
        local obj = tbl[i]
        if self:IsObjectInRange(tbl[i]) then
            if obj:GetObjectType() ~= objtype.SHIP then continue end
            if obj == self:GetObject() then continue end
            return obj
        end
    end
    return nil
end

function ENT:DistanceToObject(obj)
    return self:DistanceTo(obj:GetCoordinates())
end

function ENT:DistanceTo(ox, oy)
    local sx, sy = self:GetCoordinates()
    return universe:GetDistance(ox, oy, sx, sy)
end

function ENT:PointAtObject(obj)
    self:PointAt(obj:GetCoordinates())
end

function ENT:PointAt(tx, ty)
    local sx, sy = self:GetCoordinates()
    self._nwdata.dx, self._nwdata.dy = tx, ty
    local dx, dy = universe:GetDifference(sx, sy, tx, ty)
    self:GetObject():SetTargetRotation(math.atan2(dy, dx) / math.pi * 180.0)
end



function ENT:Initialize()
    self._roomdict = {}
    self._roomlist = {}
    self._doors = {}
    self._bounds = Bounds()
    self._targetShip = nil
    self._targetLastPos = nil
    self._targetLastSeen = 0

    self._speedScore = math.Rand(0.05, 0.5)

    self._attackHoverRange = 0.5
    self._sensorRange = 2

    self._movementMode = 0
    self._wanderTiming = {20, 100}
    self._nextWander = 0

    self._systems = {}
    self._players = {}

    self._nwdata = NetworkTable(self:GetName(), self._nwdata)

    self._nwdata.roomnames = {}
    self._nwdata.doornames = {}

    self._nwdata.name = self:GetName()

    self._nwdata.hazardmode = true
    
    self._nwdata.tx = 0
    self._nwdata.ty = 0


    if not self:GetBaseHealth() then
        self:_SetBaseHealth(1)
    end

    self._defaultGrid = GenerateModuleGrid()
end

function ENT:SetAggressive(var)
    self._isAggressive = var
end

function ENT:GetDefaultGrid()
    return self._defaultGrid
end

function ENT:GetObject()
    return self._nwdata.object
end

function ENT:IsObjectInRange(obj)
    if not IsValid(obj) or not obj.GetCoordinates then return false end

    local ox, oy = obj:GetCoordinates()
    local sx, sy = self:GetCoordinates()

    return universe:GetDistance(ox, oy, sx, sy) <= self:GetRange()
end

function ENT:GetAccelerationMagnitude()
    local score = self._speedScore
    return 1 + score * 3
end

function ENT:GetAcceleration(amul, vmul)
    if amul == nil then amul = 1 end
    if vmul == nil then vmul = 1 end

    local score = self:GetAccelerationMagnitude()
    local speedmul = 0.01

    local ax = math.cos(math.rad(self:GetRotation())) * score * speedmul * amul
    local ay = math.sin(math.rad(self:GetRotation())) * score * speedmul * amul

    local cx, cy = self:GetVel()
    local vx = cx + ax * vmul
    local vy = cy + ay * vmul
    vx = math.Clamp(vx, -MAXIMUM_SPEED, MAXIMUM_SPEED)
    vy = math.Clamp(vy, -MAXIMUM_SPEED, MAXIMUM_SPEED)

    return vx, vy
end

function ENT:AccelerateForwards()
    local vx, vy = self:GetAcceleration(1,1)

    self._nwdata.object:SetVel(vx, vy)
end

function ENT:ChaseEnemy()
    local ox, oy = self._targetShip:GetCoordinates()
    local sx, sy = self:GetCoordinates()
    local len = universe:GetDistance(ox, oy, sx, sy)

    local cx, cy = self:GetVel()

    local disttogoal = len - self._attackHoverRange

    local vx, vy = self:GetAcceleration(disttogoal, len)

    if len < self._attackHoverRange then
        vx = vx/1.5
        vy = vy/1.5
        if math.abs(vx) < 0.01 then vx = 0 end
        if math.abs(vy) < 0.01 then vy = 0 end
    end

    self._nwdata.object:SetVel(vx, vy)
end

function ENT:GetCoordinates()
    return self._nwdata.object:GetCoordinates()
end

function ENT:GetRotation()
    return self._nwdata.object:GetRotation()
end

function ENT:GetRotationRadians()
    return self._nwdata.object:GetRotationRadians()
end

function ENT:GetVel()
    return self._nwdata.object:GetVel()
end

function ENT:GetRange()
    return self._sensorRange
end

function ENT:InitPostEntity()
    self._nwdata.object = ents.Create("info_ff_object")
    self._nwdata.object:SetCoordinates(5 + math.random() * 0.2 - 0.1, 9 + math.random() * 0.2 - 0.1)
    self._nwdata.object:SetObjectType(objtype.SHIP)
    self._nwdata.object:SetObjectName(self:GetName())
    self._nwdata.object:Spawn()
    self._nwdata.object:SetRotation(math.random() * 360)
    self._nwdata:Update()

    npcships.Add(self)

end

function ENT:Reset()
    self._nwdata.object:SetCoordinates(5 + math.random() * 0.2 - 0.1, 9 + math.random() * 0.2 - 0.1)
    self._nwdata.object:SetRotation(math.random() * 360)

	self:SetCloak(false)
	self._cloakEnd = 0
end
local chargeFireSingle = true

function ENT:CreateDamageInfo(target, damage)
        if not IsValid(target) then return nil end

        local dmg = DamageInfo()
        dmg:SetDamageType(DMG_BLAST)
        dmg:SetDamage(damage)

        if target:IsPlayer() then
            dmg:ScaleDamage(1)
        elseif target:GetClass() == "prop_ff_module" then
            local t = target:GetModuleType()
            if t == moduletype.LIFE_SUPPORT then
                dmg:ScaleDamage(1)
            elseif t == moduletype.SHIELDS then
                dmg:ScaleDamage(1)
            elseif t == moduletype.SYSTEM_POWER then
                dmg:ScaleDamage(1)
            end
        end

    return dmg
end

local shieldedSounds = {
	"weapons/physcannon/energy_disintegrate4.wav",
	"weapons/physcannon/energy_disintegrate5.wav"
}

function ENT:DoRoomDamage(damage, room, ratio, mult)
	local damage = damage || 10
	local shields = room:GetUnitShields()
	local ratio = ratio || 0
	local mult = mult || 1

	util.ScreenShake(room:GetPos(), math.sqrt(damage * 0.5), math.random() * 4 + 3, 1.5, 768)

	room:SetLastDamage(CurTime())

	room:SetUnitShields(shields - math.min(shields, damage * mult) * (1 - ratio))
	damage = damage - (shields / mult) * (1 - ratio)

	if damage > 0 then
		for _, ent in pairs(room:GetEntities()) do
			local dmg = self:CreateDamageInfo(ent, damage)
			if dmg then
				dmg:SetAttacker(room)
				dmg:SetInflictor(room)
				ent:TakeDamageInfo(dmg)
			end
		end

		for _, pos in pairs(room:GetTransporterTargets()) do
			timer.Simple(math.random() * 0.5, function()
				local ed = EffectData()
				ed:SetOrigin(pos)
				ed:SetScale(1)
				util.Effect("Explosion", ed)
			end)
		end
	else
		sound.Play(table.Random(shieldedSounds), room:GetPos(), 100, 70)

		local effects = room:GetDamageEffects()
		local count = math.max(1, #effects * math.random() * 0.5)
		for i = 1, count do
			effects[i]:PlayEffect()
		end
	end
end

function ENT:GetBounds()
    return self._bounds
end

function _mt:GetOrigin()
    return self._nwdata.x, self._nwdata.y
end

function ENT:_SetBaseHealth(health, dontUpdate)
    self._nwdata.basehealth = health
    if not dontUpdate then self._nwdata:Update() end
end

function ENT:GetBaseHealth()
    return self._nwdata.basehealth
end

function ENT:_SetFullName(value, dontUpdate)
    self._nwdata.fullname = value
    if not dontUpdate then self._nwdata:Update() end
end

function ENT:GetFullName()
    return self._nwdata.fullname or "Unnamed"
end

function ENT:GetSystem(name)
    if not self._systems[name] then
        for _, room in pairs(self._roomlist) do
            if room:GetSystemName() == name then
                self._systems[name] = room:GetSystem()
                return room:GetSystem()
            end
        end
    end

    return self._systems[name]
end

function ENT:IsPointInside(x, y)
    return self:GetBounds():IsPointInside(x, y)
end
