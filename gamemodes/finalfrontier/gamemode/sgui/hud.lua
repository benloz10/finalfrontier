-----------------------------------WHOA THERE PARTNER!----------------------------------
-- This is an addon created by me, Lawlypops. Do not re-upload! (Unless I have given  --
-- EXPRESSED permission in the description!) You can use it to learn for yourself, or --
--            you can get in contact with me if you wish to learn GMOD LUA            --
----------------------------------------------------------------------------------------
--Begin the magic!
if SERVER then AddCSLuaFile() end



if CLIENT then
	surface.CreateFont( 'FF_Death_Font', {
		font = "arial black",
		size = 80,
		weight = 1000,
		blursize = 0,
		scanlines = 0,
		antialias = true
	} )
	
	surface.CreateFont( 'LHUD_Font_Large', {
		font = "impact",
		size = 50,
		weight = 1000,
		blursize = 0,
		scanlines = 0,
		antialias = true
	} )

	surface.CreateFont( 'LHUD_Font', {
		font = "impact",
		size = 30,
		weight = 1000,
		blursize = 0,
		scanlines = 0,
		antialias = true
	} )

	surface.CreateFont( 'LHUD_Font_Small', {
		font = "Engraves MT",
		size = 20,
		weight = 1000,
		blursize = 0,
		scanlines = 0,
		antialias = true
	} )

	surface.CreateFont( 'LHUD_Font_Tiny', {
		font = "Engraves MT",
		size = 13,
		weight = 1000,
		blursize = 0,
		scanlines = 0,
		antialias = true
	} )
end

local FFHUD_Enabled = CreateClientConVar( "ffhud_active", 1, true, false, "Enable/Disable the HUD" )


function disablehud(name) -- Tell the default HUD to STFU
    if FFHUD_Enabled:GetBool() then
        for k, v in pairs({"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo", })do
            if name == v then return false end
        end
    end
end
hook.Add("HUDShouldDraw", "ff_disabledefaulthud", disablehud )

function ShouldDraw()
    ply = LocalPlayer()
    if ply:GetActiveWeapon():IsValid() then
        if ply:Health() > 0
		and ply:GetActiveWeapon():GetClass() != "gmod_camera"
		and FFHUD_Enabled:GetBool()
		and GetConVar("cl_drawhud"):GetBool()
		and not ply:InVehicle() then
            return true
        else
            return false
        end
    end
end

function drawCircle( x, y, radius, seg, val, maxval )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( (( i / seg ) * -math.Clamp((val/maxval)*360, 0, 360))+180 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end
	
	surface.DrawPoly( cir )
end

function drawRadialBar(x, y, rad, val, maxval, xoffset, yoffset, width, bgcolor, barcolor, barbgcolor)
	draw.NoTexture()
	surface.SetDrawColor(bgcolor)
	drawCircle( x-xoffset, y+yoffset, rad+10, 40, 1, 1 )
	surface.SetDrawColor(barbgcolor)
	drawCircle( x-xoffset, y+yoffset, rad, 40, 1, 1 )
	surface.SetDrawColor(barcolor)
	drawCircle( x-xoffset, y+yoffset, rad, 40, val, maxval )
	surface.SetDrawColor(bgcolor)
	drawCircle( x-xoffset, y+yoffset, rad-width, 40, 1, 1 )
end

local oldHealth = 100
local oldOxy = 100
local CanPress = true

local BGColor = Color(55,55,60)

function GM:HUDPaint()
    local ply = LocalPlayer()
    local hp = ply:Health()
	local maxhp = ply:GetMaxHealth()
    local oxygen = ply:GetPlyOxygen()
	local maxoxy = ply:GetPlyMaxOxygen()
    
    local xoffset = 100
    local yoffset = 20
	
	local hpwidth = 20
	local hprad = 80
	
	local oxywidth = 15
	local oxyrad = 60
	
	
    if oldHealth != hp then
        oldHealth = math.Clamp(math.Approach( oldHealth, hp, math.max( 0.02, math.abs( (hp - oldHealth)/20 ) ) ), 0, maxhp)
    end
    
    if oldOxy != oxygen then
        oldOxy = math.Clamp(math.Approach( oldOxy, oxygen, math.max( 0.02, math.abs( (oxygen - oldOxy)/20 ) ) ), 0, maxhp)
    end
    
    if ShouldDraw() then
		--Health
			drawRadialBar(200, ScrH()-200, hprad, oldHealth, maxhp, xoffset, yoffset, hpwidth, BGColor, COLORS.Red, COLORS.DarkRed)
			draw.SimpleText( "HP", "LHUD_Font_Large", 200-xoffset,ScrH()-220+yoffset, COLORS.LightGrey, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( math.Round(oldHealth), "LHUD_Font_Large", 200-xoffset,ScrH()-180+yoffset, COLORS.LightGrey, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		--Oxygen
			drawRadialBar(350, ScrH()-100, oxyrad, oldOxy, maxoxy, xoffset, yoffset, oxywidth, BGColor, COLORS.Blue, COLORS.DarkBlue)
			draw.SimpleText( "OXY", "LHUD_Font", 350-xoffset,ScrH()-115+yoffset, COLORS.LightGrey, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( math.Round(oldOxy), "LHUD_Font", 350-xoffset,ScrH()-85+yoffset, COLORS.LightGrey, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        
    end
	--Death screen
	if ply:Health() <= 0 or not ply:Alive() then
		surface.SetDrawColor(0,0,0,240)
		surface.DrawRect(0,0,ScrW(),ScrH())
		draw.SimpleText( "YOU ARE DEAD", "FF_Death_Font", ScrW()/2, 100, COLORS.Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( "You will respawn in:", "FF_Death_Font", ScrW()/2, 160, COLORS.Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( ply:GetNWInt("NWDeathTime"), "FF_Death_Font", ScrW()/2, 220, COLORS.Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
end



local teamcol=Color( 0, 0, 0 )

local DEVTABLE = {
	["STEAM_0:1:30656417"] = true,  //Lawlypops
	["STEAM_0:1:67321501"] = true //Nitro
}

function IsDev(ply)
	return DEVTABLE[ply:SteamID()] or false
end

function GM:PostDrawOpaqueRenderables()
	local ply=LocalPlayer()
	local tr=ply:GetEyeTraceNoCursor().Entity
	if tr:IsValid() and tr:IsPlayer() then
	teamcol=team.GetColor(tr:Team())
		cam.Start3D2D(tr:GetPos() + Vector(0,0,80), ply:EyeAngles():Right():Angle() + Angle(0,0,90), 0.1)
				draw.SimpleText( tr:Nick(), "CTextMedium", 0, 0, teamcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		cam.End3D2D()
		
		if IsDev(tr) then
			cam.Start3D2D(tr:GetPos() + Vector(0,0,75), ply:EyeAngles():Right():Angle() + Angle(0,0,90), 0.1)
			draw.SimpleText( "-DEV-", "CTextMedium", 0, 0, COLORS.Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			cam.End3D2D()
		end
	end
end