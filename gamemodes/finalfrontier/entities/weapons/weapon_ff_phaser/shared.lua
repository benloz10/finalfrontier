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

if CLIENT then
	SWEP.HoldType      = "pistol"
	SWEP.PrintName     = "Phaser"
	SWEP.ViewModelFOV  = 56
	SWEP.ViewModelFlip = false
	SWEP.Slot          = 0
	SWEP.SlotPos       = 1
	SWEP.DrawAmmo      = false
	SWEP.DrawCrosshair = true
	SWEP.UseHands      = true
end

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.Primary.Sound     = Sound("Weapon_AR2.Single")
SWEP.Primary.Recoil    = 32
SWEP.Primary.MinDamage = 2
SWEP.Primary.MaxDamage = 20
SWEP.Primary.NumShots  = 1  
SWEP.Primary.Delay     = 0.125
SWEP.Primary.Ammo      = "none"  
SWEP.Primary.Force     = 2

SWEP.Primary.ChargeDecay  = 0.85
SWEP.Primary.RechargeRate = 0.25
SWEP.Primary.ClipSize     = 1
SWEP.Primary.DefaultClip  = 1
SWEP.Primary.Automatic    = false

SWEP._lastShot = 0
SWEP._lastCharge = 0

function SWEP:GetCharge()
	return math.Clamp(self._lastCharge + (CurTime() - self._lastShot) * self.Primary.RechargeRate, 0, 1)
end

function SWEP:ShouldDropOnDie()
    return false
end

function SWEP:Deploy()
	self._lastShot = CurTime()
	self._lastCharge = 0

	self.BaseClass.Deploy(self)
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:ShootEffects()

	if not SERVER and CurTime() - self._lastShot < self.Primary.Delay / 2 then return end

	local charge = self:GetCharge()

	self._lastShot = CurTime()
	self._lastCharge = charge * charge * self.Primary.ChargeDecay

	local nextShot = self._lastShot + self.Primary.Delay

	self.Weapon:SetNextPrimaryFire(nextShot)
	self.Weapon:SetNextSecondaryFire(nextShot)

	local ang = self.Owner:GetAimVector():Angle()
	local rot = math.random() * math.pi * 2
	local far = 65536
	local rad = math.random() * (1.1 - charge) / 16

	local dx = math.cos(rot) * rad
	local dy = math.sin(rot) * rad

	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = self.Owner:GetShootPos()
		+ self.Owner:GetAimVector() * far
		+ ang:Up() * (dx * far)
		+ ang:Right() * (dy * far)

	trace.filter = self.Owner

	local tr = util.TraceLine(trace)

	if SERVER then
		local dmg = DamageInfo()
		dmg:SetDamage(self.Primary.MinDamage + (self.Primary.MaxDamage - self.Primary.MinDamage) * charge)
		dmg:SetAttacker(self:GetOwner())
		dmg:SetInflictor(self)

		if dmg.SetDamageType then
			dmg:SetDamagePosition(tr.HitPos)
			dmg:SetDamageType(DMG_PLASMA)
		end

		tr.Entity:DispatchTraceAttack(dmg, tr.HitPos, tr.HitPos - tr.HitNormal * 20)
	end

	local effect = EffectData()
	effect:SetEntity(self.Owner)

	if CLIENT and self.Owner == LocalPlayer() then
		local vm = self.Owner:GetViewModel()
		effect:SetStart(vm:GetAttachment(vm:LookupAttachment("muzzle")).Pos)
	else
		effect:SetStart(self.Weapon:GetAttachment(self.Weapon:LookupAttachment("muzzle")).Pos)
	end

	effect:SetOrigin(tr.HitPos)
	effect:SetScale(charge)

	util.Effect("phaser_tracer", effect)

	effect = EffectData()
	effect:SetOrigin(tr.HitPos + tr.HitNormal)
	effect:SetNormal(tr.HitNormal)

	util.Effect("AR2Impact", effect)

	self.Weapon:EmitSound("weapons/ar2/fire1.wav", 100, 100 + charge * 60)

	self.Owner:ViewPunch(Angle(dx * self.Primary.Recoil, dy * self.Primary.Recoil, 0))
end

function SWEP:SecondaryAttack()
end

if CLIENT then
	SWEP._ColorWhite = Color(255, 255, 255)
	function SWEP:DoDrawCrosshair(x, y)
		local charge = self:GetCharge()
		local inner = CreateHollowCircle(x, y, 16, 17, (1 - charge) * math.pi * 0.5, charge * math.pi)
		local outer = CreateHollowCircle(x, y, 15, 18, (1 - charge) * math.pi * 0.5, charge * math.pi)
        local clr = team.GetColor(self.Owner:Team())

        draw.NoTexture()

		surface.SetDrawColor(Color(clr.r, clr.g, clr.b, 32))
		surface.DrawRect(x - 1, y - 3, 3, 6)
        
        for _, v in ipairs(outer) do
			surface.DrawPoly(v)
		end

		self._ColorWhite.a = 32 + Pulse(0.25) * charge * 64
		surface.SetDrawColor(self._ColorWhite)
		surface.DrawRect(x, y - 2, 1, 4)

        for _, v in ipairs(inner) do
			surface.DrawPoly(v)
		end

		return true
	end
end