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

SYS.FullName = "Piloting"
SYS.SGUIName = "piloting"

SYS.Powered = true

SYS._jumpCharge = 0
SYS._jumpIsCharging = false
SYS._isSelectingJump = false

local DURATION_MULTIPLIER = 4
local MAXIMUM_SPEED = 0.2

function SYS:GetTargetCoordinates()
    local sx, sy = self:GetShip():GetCoordinates()
    local ax, ay = self:GetTargetAcceleration()

    local dt = self:GetAccelerationTime()

    return sx + ax * dt, sy + ay * dt
end

function SYS:GetTargetAcceleration()
    if self:IsFullStopping() then
        local vx, vy = self:GetShip():GetVel()
        local vl = math.sqrt(vx * vx + vy * vy)

        if vl == 0 then
            return 0, 0
        else
            return -vx / vl, -vy / vl
        end
    elseif self:GetAccelerationTime() <= 0 then
        return 0, 0
    end

    return self._nwdata.dx, self._nwdata.dy
end

function SYS:GetAccelerationTime()
    if self:IsFullStopping() then
        local vx, vy = self:GetShip():GetVel()
        return math.sqrt(vx * vx + vy * vy)
    end

    return math.max(0, (self._nwdata.duration - CurTime() + self._nwdata.inittime) / DURATION_MULTIPLIER)
end

function SYS:IsAccelerating()
    local ax, ay = self:GetTargetAcceleration()

    return ax * ax + ay * ay > 0
end

function SYS:IsFullStopping()
    return self._nwdata.fullstop
end

function SYS:GetJumpCharge()
	return self._nwdata._jumpcharge
end

function SYS:SetJumpCharge(charge)
	self._nwdata._jumpcharge = charge
	self._nwdata:Update()
end

function SYS:GetIsJumping()
	return self._jumpIsCharging
end

function SYS:SetIsJumping(status)
	self._jumpIsCharging = status
end

function SYS:GetIsSelectingJump()
	return self._isSelectingJump
end

function SYS:SetIsSelectingJump(status)
	self._isSelectingJump = status
end

if SERVER then
    resource.AddFile("materials/systems/piloting.png")

    local ACCELERATION_PER_POWER = 1.0 / 800.0

    SYS._prevVel = Vector(0, 0, 0)

    local function shipPhysicsSimulate(ent, phys, delta)
        local self = ent._piloting

        if self:GetAccelerationTime() <= 0 then
            if self._nwdata.duration > 0 then
                self:SetTargetHeading(0, 0)
            end
            
            return Vector(0, 0, 0), Vector(0, 0, 0), SIM_GLOBAL_ACCELERATION
        end

        local ax, ay = self:GetTargetAcceleration()
        local a = self:GetAccelerationMagnitude()

        local vx, vy = self:GetShip():GetVel()
        local ox, oy = vx, vy

        vx = vx + ax * a
        vy = vy + ay * a

        local speed2 = vx * vx + vy * vy

        if speed2 > MAXIMUM_SPEED * MAXIMUM_SPEED then
            local speed = math.sqrt(speed2)
            vx = vx / speed * MAXIMUM_SPEED
            vy = vy / speed * MAXIMUM_SPEED
        end

        local acc = universe:GetWorldPos(vx, vy) - universe:GetWorldPos(ox, oy)

        return Vector(0, 0, 0), acc, SIM_GLOBAL_ACCELERATION
    end

    function SYS:GetMaximumPower()
        local score = self:GetRoom():GetModuleScore(moduletype.SYSTEM_POWER)
        return 4 + score * 4
    end

    function SYS:CalculatePowerNeeded()
        local dx, dy = self:GetTargetAcceleration()

        if dx * dx + dy * dy > 0 then
            return self:GetMaximumPower()
        elseif self:GetIsJumping() then
			return self:CalculateJumpPower()
		else
            return 0
        end
    end
	
	function SYS:CalculateJumpPower()
		return self:GetMaximumPower() * 1.2
	end

    function SYS:Initialize()
        self:SetTargetHeading(0, 0)

        self:GetShip():GetObject()._piloting = self
        self:GetShip():GetObject().PhysicsSimulate = shipPhysicsSimulate
		
		self._nwdata._jumpcharge = 0
		self._nwdata:Update()
		
		sound.Add( {
			name = "ff_jump_charge1",
			channel = CHAN_STATIC,
			volume = 1.0,
			level = 120,
			pitch = 80,
			sound = "ambient/levels/labs/teleport_mechanism_windup2.wav"
		} )
		sound.Add( {
			name = "ff_jump_drive",
			channel = CHAN_STATIC,
			volume = 1.0,
			level = 120,
			sound = "ambient/levels/citadel/portal_open1_adpcm.wav"
		} )
		sound.Add( {
			name = "ff_jump_thunder",
			channel = CHAN_STATIC,
			volume = 1.0,
			level = 120,
			sound = "ambient/levels/labs/teleport_postblast_thunder1.wav"
		} )
    end

    function SYS:FullStop()
        self._nwdata.fullstop = true
        self._nwdata.duration = 0
        self._nwdata.inittime = 0
        self._nwdata.dx = 0
        self._nwdata.dy = 0
        self._nwdata:Update()
    end

    function SYS:SetTargetHeading(dx, dy)
        local len = math.sqrt(dx * dx + dy * dy)

        self._nwdata.fullstop = false
        self._nwdata.duration = len * DURATION_MULTIPLIER
        self._nwdata.inittime = CurTime()

        if self._nwdata.duration > 0 then
            self._nwdata.dx = dx / len
            self._nwdata.dy = dy / len

            self:GetShip():GetObject():SetTargetRotation(math.atan2(dy, dx) / math.pi * 180.0)
        else
            self._nwdata.dx = 0
            self._nwdata.dy = 0
        end

        self._nwdata:Update()
    end

    function SYS:GetAccelerationMagnitude()
        if self:GetPowerNeeded() <= 0 then return 0 end
        local score = self:GetRoom():GetModuleScore(moduletype.SYSTEM_POWER)
        return self:GetPower() * ACCELERATION_PER_POWER * (1 + score * 3)
    end
	
	function SYS:CanCloak()
		local ship = self:GetShip()
		local reactor = ship:GetSystem("reactor")
		if  reactor:GetSystemLimitRatio(ship:GetSystem("shields")) == 0 and
			reactor:GetSystemLimitRatio(ship:GetSystem("piloting")) == 0 and
			reactor:GetSystemLimitRatio(ship:GetSystem("weapons")) == 0 and
			
			self:GetRoom():GetShip():GetVel() == 0 then
			return true
		else
			return false
		end
	end

	function SYS:CanJump()
		local reactor = self:GetShip():GetSystem("reactor")
		local piloting = self:GetShip():GetSystem("piloting")
		print(self:CalculateJumpPower().."/"..reactor:GetTotalPower() - reactor:GetTotalSupplied().." | "..reactor:GetSystemLimit(piloting))
		
		if self:CalculateJumpPower() <= reactor:GetTotalPower() - reactor:GetTotalSupplied() and
			reactor:GetSystemLimit(piloting) >= reactor:GetTotalPower() - reactor:GetTotalSupplied() then
			return true
		else
			return false
		end
	end
	
	function SYS:CheckJumpInterrupt()
		local reactor = self:GetShip():GetSystem("reactor")
		if self:GetPower() < self:CalculateJumpPower() then
			return true
		else
			return false
		end
	end
	
	function SYS:TryCloak()
		if self:CanCloak() then
			self:GetShip():SetCloak()
		else
			self:GetShip():ErrorSound()
		end
	end
	
	
	function SYS:BeginJump(tx, ty)
		self._jumpIsCharging = true
		self:FullStop()
		self:GetShip():SetJumpTarget(tx,ty)
		
		local sx, sy = self:GetShip():GetCoordinates()
		local dx, dy = universe:GetDifference(sx, sy, tx, ty)
		
		self:GetShip():GetObject():SetTargetRotation(math.atan2(dx, dy) / math.pi * 180.0)
		self:GetShip():GetSystem("engineering"):GetRoom():EmitSound("ff_jump_charge1")
		self:GetShip():GetSystem("piloting"):GetRoom():EmitSound("ff_jump_charge1")
	end
	
	function SYS:TryJump(x, y)
		if self:CanJump() then
			self:BeginJump(x, y)
		else
			self:GetShip():ErrorSound()
		end
	end
	
elseif CLIENT then
    SYS.Icon = Material("systems/piloting.png", "smooth")

    function SYS:Initialize()
        self._nwdata.fullstop = true
        self._nwdata.duration = 0
        self._nwdata.inittime = 0
        self._nwdata.dx = 0
        self._nwdata.dy = 0
    end
end
