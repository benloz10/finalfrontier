-- Copyright (c) 2014 Michael Ortmann [micha.ortmann@yahoo.de]
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

SWEP.PrintName = "Admin Repair Tool"
SWEP.Slot      = 1
SWEP.HoldType = "pistol"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_toolgun.mdl"
SWEP.WorldModel = "models/weapons/w_toolgun.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.UseHands = true
SWEP.Damage = 158

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "Pistol"

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"

SWEP.AllowDelete = false
SWEP.AllowDrop = false

SWEP.COOLDOWN = 2
SWEP.MAX_DISTANCE = 128
SWEP.THINK_STEP = 0.1
SWEP.nextThinkStamp = CurTime()+SWEP.THINK_STEP

function SWEP:PrimaryAttack() return false end --This stops the repair tool from making the 'Out of Ammo' sound

function SWEP:SetupDataTables()
	self:NetworkVar( "Int", 0, "RepairModeA" )
	self:NetworkVar( "Int", 1, "GreenBoxesA" )
	self:NetworkVar( "Int", 2, "BlueBoxesA" )
    self:NetworkVar( "Bool", 0, "UsingWelderA" )
end

function SWEP:Initialize()
    self:SetRepairModeA(-1)
    self:SetGreenBoxesA(999)
    self:SetBlueBoxesA(999)
    self:SetUsingWelderA(false)
end

function SWEP:ShouldDropOnDie()
    return false
end

function SWEP:SecondaryAttack()
    if SERVER then
        if self:GetRepairModeA() == 0 then
            self:SetRepairModeA(1)
        elseif self:GetRepairModeA() == 1 then
            self:SetRepairModeA(2)
        elseif self:GetRepairModeA() == 2 then
            self:SetRepairModeA(-1)
        else
            self:SetRepairModeA(0)
        end
    end
end

function SWEP:Think()
    if (CurTime()<self.nextThinkStamp) then return end
    if (self:GetUsingWelderA()) then
        local trace = self.Owner:GetEyeTraceNoCursor()

        local effectData = EffectData()
        effectData:SetOrigin( trace.HitPos )
        effectData:SetNormal( trace.HitNormal )
        util.Effect( "stunstickimpact", effectData, true, true )
    end
    self.nextThinkStamp = CurTime()+self.THINK_STEP
end


if SERVER then
    util.AddNetworkString( "usingWelderA" )
    util.AddNetworkString( "manipulateModuleA" )
    util.AddNetworkString( "DoTheShootDammit" )
    util.AddNetworkString("zoom")

    net.Receive( "usingWelderA", function( len, ply )
        local self = ply:GetWeapon( "weapon_ff_repair_tool_admin" )
        if (!self) then return end

        self:SetUsingWelderA(net.ReadBit()==1)
        if (self:GetUsingWelderA()) then
            ply.weldingSound = CreateSound(ply, "ambient/machines/electric_machine.wav")
            ply.weldingSound:PlayEx(0.5, 120)
        else
            ply.weldingSound:Stop()
        end
    end )

    net.Receive( "manipulateModuleA", function( len, ply )
        local self = ply:GetWeapon( "weapon_ff_repair_tool_admin" )
        if (!self) then return end

        local ent = net.ReadEntity()
        local gridx = net.ReadInt(4)
        local gridy = net.ReadInt(4)

        if (self:GetRepairModeA() == -1) then
            if (ent._grid[gridx][gridy] == 0) then
                self:SetGreenBoxesA(self:GetGreenBoxesA() + 1 )
            elseif (ent._grid[gridx][gridy] == 1) then
                self:SetBlueBoxesA(self:GetBlueBoxesA() + 1 )
            end
        else
            if (self:GetRepairModeA() == 0) then
                self:SetGreenBoxesA(self:GetGreenBoxesA() - 1 )
            elseif (self:GetRepairModeA() == 1) then
                self:SetBlueBoxesA(self:GetBlueBoxesA() - 1 )
            end
        end

        ent:SetTile(gridx, gridy, self:GetRepairModeA())
    end )

    net.Receive("DoTheShootDammit", function(angery, pl)
        pl:GetWeapon("weapon_ff_repair_tool_admin"):ShootBullet(1742,1,0,"Pistol",5,1)
    end)

    net.Receive("zoom", function(zoom, pl)
        if(net.ReadBit() == 1) then
            pl:SetRunSpeed(800)
        else
            pl:SetRunSpeed(250)
        end
    end)
end


if CLIENT then
    SWEP.timestampCompleted = 0
    SWEP.manEntity, SWEP.manX, SWEP.manY = nil

    function SWEP:Think()
        if CurTime() < self.nextThinkStamp
        or LocalPlayer() ~= self.Owner 
        or LocalPlayer():GetActiveWeapon() ~= self then return end
        
        local trace = self.Owner:GetEyeTraceNoCursor()

        if(!vgui.CursorVisible() and input.IsMouseDown( MOUSE_LEFT ) and self:GetRepairModeA() <= 1 and self.Owner:GetShootPos():Distance(trace.HitPos)<self.MAX_DISTANCE and trace) then
            if(trace.Entity:GetClass() != "prop_ff_module") then return end

            local possible, gridx, gridy, ent = self:actionTrace()

            if (!self:GetUsingWelderA()) then
                net.Start( "usingWelderA" )
                net.WriteBit( true )
                net.SendToServer()
            end

            if(!self:actionTrace()) then
                self.timestampCompleted = 0
                self.manEntity, self.manX, self.manY = nil
            else

                if(self.manEntity == ent && self.manX == gridx && self.manY == gridy) then
                    if(CurTime()>self.timestampCompleted) then
                        net.Start( "manipulateModuleA" )
                        net.WriteEntity( self.manEntity )
                        net.WriteInt( self.manX, 4)
                        net.WriteInt( self.manY, 4)
                        net.SendToServer()
                        self.manEntity, self.manX, self.manY = nil
                    end
                else
                    self.manEntity = ent 
                    self.manX = gridx 
                    self.manY = gridy
                    self.timestampCompleted = CurTime()
                end
            end

        elseif(self:GetUsingWelderA()) then
            net.Start( "usingWelderA" )
            net.WriteBit( false )
            net.SendToServer()
            self.manEntity, self.manX, self.manY = nil
        end

        if(!vgui.CursorVisible() and input.IsMouseDown(MOUSE_LEFT) and self:GetRepairModeA() == 2) then
                net.Start("DoTheShootDammit")
                net.SendToServer()
        end

        if(!vgui.CursorVisible() and self.Owner:KeyDown(IN_RELOAD) and !timer.Exists("wait")) then
            if(ZoomToggle == 0) then
                net.Start("zoom")
                net.WriteBit(true)
                net.SendToServer()
                ZoomToggle = 1
                timer.Create("wait",0.5,1,function() end)
            elseif(ZoomToggle == 1) then
                net.Start("zoom")
                net.WriteBit(false)
                net.SendToServer()
                ZoomToggle = 0
                timer.Create("wait",0.5,1,function() end)
            end
        end

        function self:Holster( wep )
            if not IsFirstTimePredicted() then return end
            net.Start("zoom")
            net.WriteBit(false)
            net.SendToServer()
            ZoomToggle = 0
        end

        self.nextThinkStamp = CurTime()+self.THINK_STEP
    end

    local matScreen     = Material( "models/weapons/v_toolgun/screen" )

    -- GetRenderTarget returns the texture if it exists, or creates it if it doesn't
    local rtTexture     = GetRenderTarget( "GModToolgunScreen", 256, 256 )

    surface.CreateFont( "RepairToolDesc", {
        font    = "Helvetica",
        size    = 40,
        weight    = 900
    } )
    surface.CreateFont( "RepairToolNumber", {
        font    = "Helvetica",
        size    = 150,
        weight    = 900
    } )
    --[[---------------------------------------------------------
        We use this opportunity to draw to the toolmode
            screen's rendertarget texture.
    -----------------------------------------------------------]]
    function SWEP:RenderScreen()

        local TEX_SIZE = 256
        local oldW = ScrW()
        local oldH = ScrH()

        -- Set the material of the screen to our render target
        matScreen:SetTexture( "$basetexture", rtTexture )

        local oldRT = render.GetRenderTarget()

        -- Set up our view for drawing to the texture
        render.SetRenderTarget( rtTexture )
        render.SetViewPort( 0, 0, TEX_SIZE, TEX_SIZE )
        cam.Start2D()
            local backgroundColor
            local text = "REPAIR"
            local textNumber = false
            if self:GetRepairModeA() == 0 then
                backgroundColor = COLORS.Green
                textNumber = self:GetGreenBoxesA()
            elseif self:GetRepairModeA() == 1 then
                backgroundColor = COLORS.Blue
                textNumber = self:GetBlueBoxesA()
            elseif self:GetRepairModeA() == 2 then
                backgroundColor = COLORS.Pink
                text = "'REPAIR' ;)"
            else
                backgroundColor = COLORS.Red

                text = "REMOVE"
            end
            surface.SetDrawColor( backgroundColor )
            surface.DrawRect( 0, 0, TEX_SIZE, TEX_SIZE )

            self:drawShadowedText(text, TEX_SIZE / 2, 32, "RepairToolDesc")
            if textNumber != false then
                self:drawShadowedText(textNumber, TEX_SIZE / 2, TEX_SIZE / 2, "RepairToolNumber")
            end

            local totbars = 10
            local barspacing = 2
            local width = TEX_SIZE - 8
            local barsize = (width - 8 + barspacing) / totbars
            local bars = 10
            if (self:GetUsingWelderA()) then
                bars = math.Clamp(((CurTime()-self.timestampCompleted)) * totbars,0,totbars)
            end

            surface.SetDrawColor(COLORS.MediumGrey)

            local possible = self:actionTrace()
            for i = 0, bars - 1 do
                    if (possible) then surface.SetDrawColor(LerpColour(color_white, COLORS.Yellow, Pulse(0.5, -i / totbars / 4))) end

                surface.DrawRect(8 + i * barsize,
                    TEX_SIZE - 40, barsize - barspacing, 32)
            end

        cam.End2D()
        render.SetRenderTarget( oldRT )
        render.SetViewPort( 0, 0, oldW, oldH )

    end

    function SWEP:drawShadowedText(text, x, y, font)
        draw.SimpleText( text, font, x + 3, y + 3, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        draw.SimpleText( text, font, x , y , color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    function SWEP:actionTrace()
        local trace = self.Owner:GetEyeTraceNoCursor()
        if (trace.Entity:GetClass()=="prop_ff_module") then
            local gridx, gridy = trace.Entity:GetPlayerTargetedTile(LocalPlayer())
            if (!gridx || !gridy) then return false end

            local grid = trace.Entity:GetGrid()

            if (self:GetRepairModeA() == -1 && grid[gridx][gridy] >= 0) then
                return true, gridx, gridy, trace.Entity
            elseif ( self:GetRepairModeA() >= 0 && grid[gridx][gridy] < 0 ) then
                if ((self:GetRepairModeA() == 0 && self:GetGreenBoxesA() > 0) || (self:GetRepairModeA() == 1 && self:GetBlueBoxesA() > 0)) then
                    return true, gridx, gridy, trace.Entity
                end
            end
        end
    end
end