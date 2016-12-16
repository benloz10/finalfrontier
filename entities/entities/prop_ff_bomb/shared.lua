#NoSimplerr#

-- Created by Lawlypops
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

if SERVER then AddCSLuaFile("shared.lua") end

ENT.Type = "anim"
ENT.Base = "base_anim"

if SERVER then
    concommand.Add("ff_spawn_bomb", function(ply, cmd, args)
        if not IsValid(ply) or not cvars.Bool("sv_cheats") then return end

        local trace = ply:GetEyeTraceNoCursor()

        local mdl = ents.Create("prop_ff_bomb")
        mdl:SetPos(trace.HitPos + trace.HitNormal * 8)
        mdl:Spawn()
    end, nil, "Spawn a transporter bomb", FCVAR_CHEAT)
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Armed")
    
    self:NetworkVar("Int", 0, "Timer")
    
    self:NetworkVar("String", 0, "ShipName")
end

function inrange(y, y2, x, x2, locx, locy)
	if locy >= y and locy <= y2 and locx >= x and locx <= x2 then
        return true
    else
        return false
    end
end

if SERVER then

    function ENT:Initialize()
        self:SetArmed(false)
        self:SetTimer(10)

        self:SetUseType(SIMPLE_USE)

        self:SetModel("models/props_lab/reciever01b.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
    end
    local timetick = CurTime()
    function ENT:Use(ply)
        
        local TraceLine = util.TraceLine({start = ply:GetShootPos(), endpos = ply:GetAimVector() * 128 + ply:GetShootPos(), filter = ply})	
        local HitPosition = self:WorldToLocal(TraceLine.HitPos)
    
        if not IsValid(ply) or not ply:IsPlayer() then return end

        if not self:IsPlayerHolding() and not inrange(-7.5, 7.6, -6.3, -3.3, HitPosition.x, HitPosition.y ) then
            self:SetAngles(Angle(0, self:GetAngles().y, 0))
            ply:PickupObject(self)
        end
        
        if inrange(-7.5, 7.6, -6.3, -3.3, HitPosition.x, HitPosition.y ) then
            self:EmitSound( "buttons/button6.wav", 75, 100, 1, CHAN_AUTO )
            self:SetArmed(true)
            timetick = CurTime() + 1
        end
    end
    /*
    function ENT:GetRoom()
        local ship = ships.GetByName(self:GetShipName())
        return ship:GetRoomByIndex(self:GetRoomIndex())
    end
    */
    function ENT:Think()
        if self:GetArmed() then
            if timetick < CurTime() then
                self:SetTimer(self:GetTimer()-1)
                self:EmitSound( "buttons/button17.wav", 75, 100, 1, CHAN_AUTO )
            timetick = CurTime() + 1
            end
        end
        
        if self:GetTimer() <= 0 then
            self:VisualEffect();
            self:Remove()
        end
    end
    
    function ENT:VisualEffect()
        local effectData = EffectData();	
        effectData:SetStart(self:GetPos());
        effectData:SetOrigin(self:GetPos());
        effectData:SetScale(8);	
        util.Effect("Explosion", effectData, true, true);
        util.BlastDamage( self, self, self:GetPos(), 1000, 80 )
    end;
    /*
    function ENT:Damage(room)
        local shields = room:GetUnitShields()
        local damage = 15
        local ratio = { 0, 0 }
        local mult = { 4, 4 }

        util.ScreenShake(room:GetPos(), math.sqrt(damage * 0.5), math.random() * 4 + 3, 1.5, 768)

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
    */
end

if CLIENT then
    

    function ENT:Draw()
    self.BaseClass.Draw(self)
    
    ply = LocalPlayer()
    
        local TraceLine = util.TraceLine({start = ply:GetShootPos(), endpos = ply:GetAimVector() * 128 + ply:GetShootPos(), filter = ply})	
        local HitPosition = self:WorldToLocal(TraceLine.HitPos)
        
        local ang = self:GetAngles()
        local ang2 = self:GetAngles()
        ang:RotateAroundAxis(ang:Up(), 90)
        ang2:RotateAroundAxis(ang2:Right(), -90)
        ang2:RotateAroundAxis(ang2:Up(), 90)

        draw.NoTexture()
        
        cam.Start3D2D(self:GetPos() + ang:Up() * 3.4, ang, 0.05)
            surface.SetDrawColor(Color(0, 0, 0, 255))
            surface.DrawRect(-160, -135, 322, 243)
            if inrange(-7.5, 7.6, -6.3, -3.3, HitPosition.x, HitPosition.y ) then
                surface.SetDrawColor(Color(150, 0, 0, 255))
            else
                surface.SetDrawColor(Color(255, 0, 0, 255))
            end
            surface.DrawRect(-150, -125, 302, 60)
            draw.SimpleText("Arm", "CTextSmall", 0, -96, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
            draw.SimpleText(math.Round(HitPosition.y, 2) .. "," .. math.Round(HitPosition.x, 2), "CTextTiny", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
        cam.End3D2D()
        
        cam.Start3D2D(self:GetPos() + ang2:Up() * 6.5, ang2, 0.05)
            surface.SetDrawColor(Color(0, 0, 0, 255))
            
            surface.DrawRect(-122, -44, 90, 84)
            if not self:GetArmed() then
                txtcolor=Color( 255, 255, 255 )
            else
                txtcolor=Color( 150, 0, 0 )
            end
            
            draw.SimpleText( self:GetTimer(), "CTextLarge", -77, -33, txtcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
        cam.End3D2D()
    end
end