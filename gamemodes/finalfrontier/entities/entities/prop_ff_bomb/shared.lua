
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
        self.timetick = CurTime()
    end
    function ENT:Use(ply)
        
        local TraceLine = util.TraceLine({start = ply:GetShootPos(), endpos = ply:GetAimVector() * 128 + ply:GetShootPos(), filter = ply})	
        local HitPosition = self:WorldToLocal(TraceLine.HitPos)
    
        if not IsValid(ply) or not ply:IsPlayer() then return end

        if not self:IsPlayerHolding() and not inrange(-7.5, 7.6, -6.3, -3.3, HitPosition.x, HitPosition.y ) then
            self:SetAngles(Angle(0, self:GetAngles().y, 0))
            ply:PickupObject(self)
        end
        
        if inrange(-7.5, 7.6, -6.3, -3.3, HitPosition.x, HitPosition.y ) and not self:GetArmed() then
            self:EmitSound( "buttons/button6.wav", 75, 100, 1, CHAN_AUTO )
            self:SetArmed(true)
            self.timetick = CurTime() + 1
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
            if self.timetick < CurTime() then
                self:SetTimer(self:GetTimer()-1)
                self:EmitSound( "buttons/button17.wav", 75, 100, 1, CHAN_AUTO )
            self.timetick = CurTime() + 1
            end
        end
        
        if self:GetTimer() <= 0 then
            self:VisualEffect()
            local ship = ships.FindCurrentShip(self)
            
            for _, room in ipairs(ship._roomlist) do
                local bounds = room:GetBounds()
                local min = Vector(bounds.l, bounds.t, -65536)
                local max = Vector(bounds.r, bounds.b, 65536)
                
                for _, ent in pairs(ents.FindInBox(min, max)) do
                    local pos = ent:GetPos()
                    if ent == self then
                        
                            local damage = 150
							
							util.ScreenShake(room:GetPos(), math.sqrt(damage * 0.5), math.random() * 4 + 3, 1.5, 768)
							
                            if damage > 0 then
                            for _, ent in pairs(room:GetEntities()) do
                                local dmg = self:CreateDamageInfo(room, damage)
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
            end end end
            
            self:Remove()
        end
    end
    
    function ENT:VisualEffect()
        local effectData = EffectData();	
        effectData:SetStart(self:GetPos());
        effectData:SetOrigin(self:GetPos());
        effectData:SetScale(8);	
        util.Effect("Explosion", effectData, true, true);
        dmginfo = self:CreateDamageInfo(self, 150)
        util.BlastDamageInfo( dmginfo, self:GetPos(), 1000 )
    end;
end

function ENT:CreateDamageInfo(target, damage)
        if not IsValid(target) then return nil end
        
        local dmg = DamageInfo()
        dmg:SetDamageType(DMG_BLAST)
        dmg:SetDamage(damage)

        if target:IsPlayer() then
            dmg:ScaleDamage(self:GetPersonnelMultiplier())
        elseif target:GetClass() == "prop_ff_module" then
            local t = target:GetModuleType()
            if t == moduletype.LIFE_SUPPORT then
                dmg:ScaleDamage(self:GetLifeSupportModuleMultiplier())
            elseif t == moduletype.SHIELDS then
                dmg:ScaleDamage(self:GetShieldModuleMultiplier())
            elseif t == moduletype.SYSTEM_POWER then
                dmg:ScaleDamage(self:GetPowerModuleMultiplier())
            end
        end

    return dmg
end

function ships.FindCurrentShip(ent)
    local pos = ent:GetPos()
    for _, ship in pairs(ships._dict) do
        if ship:IsPointInside(pos.x, pos.y) then return ship end
    end
    return nil
end

function ENT:IsPointInside(x, y)
    return self:GetBounds():IsPointInside(x, y)
        and IsPointInsidePolyGroup(self:GetPolygons(), x, y)
end

if CLIENT then
    function ENT:GetPlayerTarget(ply)
        ply = ply or LocalPlayer()

        local ang = self:GetAngles()
        ang:RotateAroundAxis(ang:Up(), -90)

        local p0 = self:GetPos() + ang:Up() * 11
        local n = ang:Up()
        local l0 = ply:GetShootPos()
        local l = ply:GetAimVector()
        
        local d = (p0 - l0):Dot(n) / l:Dot(n)

        local hitpos = (l0 + l * d) - p0
        local xvec = ang:Forward()
        local yvec = ang:Right()
        
        local x = math.floor(hitpos:DotProduct(xvec) / 5) + 3
        local y = math.floor(hitpos:DotProduct(yvec) / 5) + 3

        if x < 1 or x > 4 or y < 1 or y > 4 then return nil end

        return x, y
    end

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
            surface.SetDrawColor(color_black)
            surface.DrawRect(-160, -135, 322, 243)
            if inrange(-7.5, 7.6, -6.3, -3.3, HitPosition.x, HitPosition.y ) then
                surface.SetDrawColor(COLORS.DarkRed)
            else
                surface.SetDrawColor(COLORS.Red)
            end
            surface.DrawRect(-150, -125, 302, 60)
            draw.SimpleText("Arm", "CTextSmall", 0, -96, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, COLORS.DarkGrey);
            draw.SimpleText("Explosive Photon Device", "CTextTiny", 0, -40, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, COLORS.DarkGrey);
            draw.SimpleText("___________________________", "CTextTiny", 0, -27, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, COLORS.DarkGrey);
            draw.SimpleText("This device emits a large", "CTextTiny", 0, 5, COLORS.LightRed, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, COLORS.DarkGrey);
            draw.SimpleText("amount of charged photons", "CTextTiny", 0, 25, COLORS.LightRed, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, COLORS.DarkGrey);
            draw.SimpleText("that cause extreme damage", "CTextTiny", 0, 45, COLORS.LightRed, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, COLORS.DarkGrey);
            draw.SimpleText("to anyone inside it's LOS", "CTextTiny", 0, 65, COLORS.LightRed, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, COLORS.DarkGrey);
        cam.End3D2D()
        
        cam.Start3D2D(self:GetPos() + ang2:Up() * 6.5, ang2, 0.05)
            surface.SetDrawColor(color_black)
            
            surface.DrawRect(-122, -44, 90, 84)
            local txtcolor = color_white
            if self:GetArmed() then
                txtcolor = _ColorDarkRed
            end
            
            draw.SimpleText( self:GetTimer(), "CTextLarge", -77, -33, txtcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
        cam.End3D2D()
    end
end