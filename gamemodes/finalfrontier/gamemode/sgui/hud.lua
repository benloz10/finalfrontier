-----------------------------------WHOA THERE PARTNER!----------------------------------
-- This is an addon created by me, Lawlypops. Do not re-upload! (Unless I have given  --
-- EXPRESSED permission in the description!) You can use it to learn for yourself, or --
--            you can get in contact with me if you wish to learn GMOD LUA            --
----------------------------------------------------------------------------------------
--Begin the magic!
if SERVER then AddCSLuaFile() end

if CLIENT then
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

function drawCircle( x, y, radius, seg, hp )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( (( i / seg ) * -math.Clamp((hp/100)*360, 0, 360))+180 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end
	
	surface.DrawPoly( cir )
end

function drawRadialBar(x,y,rad,hp,xoffset,yoffset,width, bgcolor, barcolor, barbgcolor)
	draw.NoTexture()
	surface.SetDrawColor(bgcolor)
	drawCircle( x-xoffset, y+yoffset, rad+10, 40, 100 )
	surface.SetDrawColor(barbgcolor)
	drawCircle( x-xoffset, y+yoffset, rad, 40, 100 )
	surface.SetDrawColor(barcolor)
	drawCircle( x-xoffset, y+yoffset, rad, 40, hp )
	surface.SetDrawColor(bgcolor)
	drawCircle( x-xoffset, y+yoffset, rad-width, 40, 100 )
end

local oldHealth = 100
local oldOxy = 100
local CanPress = true

function GM:HUDPaint()
    local ply = LocalPlayer()
    local hp = ply:Health()
    local oxygen = ply:GetPlyOxygen()
    
    local xoffset = 100
    local yoffset = 20
	
	local hpwidth = 20
	local hprad = 80
	
	local oxywidth = 15
	local oxyrad = 60
	
	
    if oldHealth != hp then
        oldHealth = math.Clamp(math.Approach( oldHealth, hp, math.max( 0.02, math.abs( (hp - oldHealth)/20 ) ) ), 0, 100)
    end
    
    if oldOxy != oxygen then
        oldOxy = math.Clamp(math.Approach( oldOxy, oxygen, math.max( 0.02, math.abs( (oxygen - oldOxy)/20 ) ) ), 0, 100)
    end
    
    if ShouldDraw() then
        --Info
		--Health
			drawRadialBar(200, ScrH()-200, hprad, oldHealth, xoffset, yoffset, hpwidth, Color(55,55,60), Color(255,0,0), Color(150,0,0))
			draw.SimpleText( "HP", "LHUD_Font_Large", 200-xoffset,ScrH()-220+yoffset, Color(200,200,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( math.Round(oldHealth), "LHUD_Font_Large", 200-xoffset,ScrH()-180+yoffset, Color(200,200,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		--Oxygen
			drawRadialBar(350, ScrH()-100, oxyrad, oldOxy, xoffset, yoffset, oxywidth, Color(55,55,60), Color(0,100,255), Color(0,50,150))
			draw.SimpleText( "OXY", "LHUD_Font", 350-xoffset,ScrH()-115+yoffset, Color(200,200,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( math.Round(oldOxy), "LHUD_Font", 350-xoffset,ScrH()-85+yoffset, Color(200,200,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        -----------------------
        
        --Ammo
        -----------------------
        
    end
end



local teamcol=Color( 0, 0, 0 )

function IsCreator(ply)
	if ply:SteamID() == "STEAM_0:1:30656417" then //Lawlypops
		return true
	else
		return false
	end
end

function IsDev(ply)
	if ply:SteamID() == "STEAM_0:1:67321501" then //Nitro
		return true
	else
		return false
	end
end

function GM:PostDrawOpaqueRenderables()
	local ply=LocalPlayer()
	local tr=ply:GetEyeTraceNoCursor().Entity
	if tr:IsValid() and tr:IsPlayer() then
	teamcol=team.GetColor(tr:Team())
		cam.Start3D2D(tr:GetPos() + Vector(0,0,80), ply:EyeAngles():Right():Angle() + Angle(0,0,90), 0.1)
				draw.SimpleText( tr:Nick(), "CTextMedium", 0, 0, teamcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		cam.End3D2D()
		
		if IsDev(tr) or IsCreator(tr) then
			cam.Start3D2D(tr:GetPos() + Vector(0,0,75), ply:EyeAngles():Right():Angle() + Angle(0,0,90), 0.1)
				if IsDev(tr) then
					draw.SimpleText( "-DEV-", "CTextMedium", 0, 0, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				else
					draw.SimpleText( "~CREATOR~", "CTextMedium", 0, 0, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				end
			cam.End3D2D()
		end
	end
end

function GM:OnPlayerChat( ply, txt, Team, PlayerIsDead )
    local nickteamcolor = team.GetColor(ply:Team())
    local nickteam = team.GetName(ply:Team())
	if IsDev(ply) then
		if ply:Alive() then
		chat.AddText(Color(255, 50, 0, 255), "-DEV- ", nickteamcolor, nickteam, Color(50, 50, 50, 255), "| ", nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), txt)
		else
		chat.AddText(Color(255, 50, 0, 255), "-DEV- *REKT* ", nickteamcolor, nickteam, Color(50, 50, 50, 255), "| ", nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), txt)
		end
		return true
	elseif IsCreator(ply) then
		if ply:Alive() then
		chat.AddText(Color(200, 0, 0, 255), "~CREATOR~ ", nickteamcolor, nickteam, Color(50, 50, 50, 255), "| ", nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), txt)
		else
		chat.AddText(Color(200, 0, 0, 255), "~CREATOR~ *REKT* ", nickteamcolor, nickteam, Color(50, 50, 50, 255), "| ", nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), txt)
		end
		return true
	
	elseif ply:IsAdmin() or ply:IsSuperAdmin() then
		if ply:Alive() then
		chat.AddText(Color(180, 0, 0, 255), "-ADMIN- ", nickteamcolor, nickteam, Color(50, 50, 50, 255), "| ", nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), txt)
		else
		chat.AddText(Color(180, 0, 0, 255), "-ADMIN- *REKT* ", nickteamcolor, nickteam, Color(50, 50, 50, 255), "| ", nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), txt)
		end
		return true
	else
	if Team then
				if ply:Alive() then
				chat.AddText(Color(255, 0, 0, 255), "(TEAM) ", nickteamcolor, nickteam, Color(50, 50, 50, 255), "| ", nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), txt)
				else
				chat.AddText(Color(255, 0, 0, 255), "*DEAD* (TEAM) ", nickteamcolor, nickteam, Color(50, 50, 50, 255), "| ", nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), txt)
				end
				return true
	end
	if ply:IsPlayer() then
	if ply:Alive() then
				chat.AddText(Color(255, 0, 0, 255), "", nickteamcolor, nickteam, Color(50, 50, 50, 255), "| ", nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), txt)
				return true
	elseif !ply:Alive() then
				chat.AddText(Color(255, 0, 0, 255), "*DEAD* ", nickteamcolor, nickteam, Color(50, 50, 50, 255), "| ", nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), txt)
				return true
	end
	end
	end
end
