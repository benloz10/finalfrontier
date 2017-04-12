-----------------------------------WHOA THERE PARTNER!----------------------------------
-- This is an addon created by me, Lawlypops. Do not re-upload! (Unless I have given  --
-- EXPRESSED permission in the description!) You can use it to learn for yourself, or --
--            you can get in contact with me if you wish to learn GMOD LUA            --
----------------------------------------------------------------------------------------

--Begin the magic!
if SERVER then AddCSLuaFile() end

if CLIENT then
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

local LHUD_Enabled = CreateClientConVar( "lhud_active", 1, true, false, "Enable/Disable the HUD" )

local connecttime = CurTime()

function GM:InitPostEntity()
connecttime = CurTime()
end

function hidehud(name) -- Tell the default HUD to STFU
    if LHUD_Enabled:GetBool() then
        for k, v in pairs({"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo", })do
            if name == v then return false end
        end
    end
end
hook.Add("HUDShouldDraw", "LHUD_HideDefault", hidehud )

function TranslateNPCClass( class )
    if class == "npc_breen" then
        return "Dr. Breen"
    elseif class == "npc_strider" then
        return "Strider"
    elseif class == "npc_vortigaunt" then
        return "Vortigaunt"
    elseif class == "npc_citizen" then
        return "Citizen"
    elseif class == "npc_gman" then
        return bit.tohex(math.random(1000000000000, 9999999999999))
    elseif class == "npc_eli" then
        return "Eli Vance"
    elseif class == "npc_mossman" then
        return "Dr. Judith Mossman"
    elseif class == "npc_kleiner" then
        return "Dr. Isaac Kleiner"
    elseif class == "npc_magnusson" then
        return "Dr. Arne Magnusson"
    elseif class == "npc_dog" then
        return "'Dog' | Class: Robotic"
    elseif class == "npc_barney" then
        return "Barney Calhoun"
    elseif class == "npc_alyx" then
        return "Alyx Vance"
    elseif class == "npc_combine_camera" then
        return "Camera"
    elseif class == "npc_turret_ceiling" then
        return "Ceiling Turret"
    elseif class == "npc_cscanner" then
        return "City Scanner"
    elseif class == "npc_combinedropship" then
        return "Dropship"
    elseif class == "npc_combinegunship" then
        return "Gunship"
    elseif class == "npc_combine_s" then
        return "Combine Soldier"
    elseif class == "npc_metropolice" then
        return "Metro Police"
    elseif class == "npc_hunter" then
        return "Hunter"
    elseif class == "npc_helicopter" then
        return "Hunter Chopper"
    elseif class == "npc_manhack" then
        return "Manhack"
    elseif class == "npc_rollermine" then
        return "Rollermine"
    elseif class == "npc_clawscanner" then
        return "Shield Scanner"
    elseif class == "npc_stalker" then
        return "Stalker"
    elseif class == "npc_turret_floor" then
        return "Turret"
    elseif class == "npc_crow" then
        return "Crow"
    elseif class == "npc_monk" then
        return "Father Grigori"
    elseif class == "npc_seagull" then
        return "Seagull"
    elseif class == "npc_pigeon" then
        return "Pigeon"
    elseif class == "npc_antlion" then
        return "Antlion | Class: Soldier"
    elseif class == "npc_antlionguard" then
        return "Antlion | Class: Guardian"
    elseif class == "npc_antlion_worker" then
        return "Antlion | Class: Worker"
    elseif class == "npc_barnacle" then
        return "Barnacle"
    elseif class == "npc_headcrab_fast" then
        return "Headcrab | Class: Fast"
    elseif class == "npc_headcrab" then
        return "Headcrab | Class: Slow"
    elseif class == "npc_headcrab_black" then
        return "Headcrab | Class: Poisonous"
    elseif class == "npc_fastzombie" then
        return "Zombie | Class: Fast"
    elseif class == "npc_zombie" then
        return "Zombie | Class: Slow"
    elseif class == "npc_poisonzombie" then
        return "Zombie | Class: Poisonous"
    elseif class == "npc_fastzombie_torso" then
        return "Zombie | Class: Fast"
    elseif class == "npc_zombie_torso" then
        return "Zombie | Class: Slow"
    else
        return class
    end
end

function TranslateAmmoToString( ammoType )
	if( ammoType == 1 ) then
		return 'DEW Charges'
	elseif( ammoType == 2 ) then
		return 'High Energy Pellet'
	elseif( ammoType == 3 ) then
		return '9mm-M82'
	elseif( ammoType == 4 ) then
		return '4.6x30mm'
	elseif( ammoType == 5 ) then
		return '.357'
	elseif( ammoType == 6 ) then
		return 'Crossbow Bolts'
	elseif( ammoType == 7 ) then
		return 'Buckshot'
	elseif( ammoType == 8 ) then
		return 'RPG Round'
	elseif( ammoType == 9 ) then
		return 'Rifle Grenades'
	elseif( ammoType == 10 ) then
		return 'Grenades'
	elseif( ammoType == 11 ) then
		return 'SLAM Charges'
	elseif( ammoType == 12 ) then
		return '9mm'
	elseif( ammoType == 13 ) then
		return 'Sniper Rounds'
	elseif( ammoType == 14 ) then
		return 'Penetrated Sniper Rounds'
	elseif( ammoType == 15 ) then
		return 'Thumper'
	elseif( ammoType == 16 ) then
		return 'Gravity'
	elseif( ammoType == 17 ) then
		return 'Battery'
	elseif( ammoType == 18 ) then
		return 'Gauss Energy'
	elseif( ammoType == 19 ) then
		return 'Dark Energy'
	elseif( ammoType == 20 ) then
		return 'Helicopter Energy Rounds'
	elseif( ammoType == 21 ) then
		return 'Strider Energy Rounds'
	elseif( ammoType == 22 ) then
		return 'Helicopter Energy Rounds'
	elseif( ammoType == 23 ) then
		return '9mm'
	elseif( ammoType == 24 ) then
		return 'MP5 Grenades'
	elseif( ammoType == 25 ) then
		return 'Hornet Ammo'
	elseif( ammoType == 26 ) then
		return 'Strider Pulse Shots'
	elseif( ammoType == 27 ) then
		return 'Heavy Combine Energy Rounds'
	else
		return 'Unknown ammo'
	end
end

function ShouldDraw()
    ply = LocalPlayer()
    if ply:GetActiveWeapon():IsValid() then
        if ply:Health() > 0 and ply:GetActiveWeapon():GetClass() != "gmod_camera" and LHUD_Enabled:GetBool() and GetConVar("cl_drawhud"):GetBool() and not ply:InVehicle() then
            return true
        else
            return false
        end
    end
end


local oldHealth = 100
local oldOxy = 100

displaytime = CurTime() - 1

function GM:HUDPaint()
    local ply = LocalPlayer()
    local hp = ply:Health()
    local oxygen = ply:GetPlyOxygen()
    local contime = math.floor(CurTime()-connecttime)
    local sec = contime % 60
    local min = math.floor(contime / 60 % 60)
    local hr =  math.floor(contime / 3600 )
    
    local OxySideOffset = 0
    local xoffset = 0
    local yoffset = 0
    
    OxySideOffset = (math.Clamp((oldOxy/10)*70, 0, 70)*1.5)-100
    
    
    if oldHealth != hp then
        oldHealth = math.Clamp(math.Approach( oldHealth, hp, math.max( 0.02, math.abs( (hp - oldHealth)/20 ) ) ), 0, 100)
    end
    
    if oldOxy != oxygen then
        oldOxy = math.Clamp(math.Approach( oldOxy, oxygen, math.max( 0.02, math.abs( (oxygen - oldOxy)/20 ) ) ), 0, 100)
    end
    
    if ShouldDraw() then
        --Info
        surface.SetDrawColor( 0, 0, 0 )
        surface.DrawRect( 20+xoffset, ScrH() - 120+yoffset, 100, 100 )
        surface.SetDrawColor( 200, 0, 0, 255 )
        surface.DrawRect( 25+xoffset, ScrH() - 115+yoffset, 90, 90 )
        draw.SimpleText( ply:Nick(), "LHUD_Font", 350+xoffset+OxySideOffset, ScrH() - 100+yoffset, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
        draw.SimpleText( "Ping", "LHUD_Font_Small", 70+xoffset, ScrH() - 110+yoffset, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
        draw.SimpleText( ply:Ping() .. " ms", "LHUD_Font_Small", 70+xoffset, ScrH() - 95+yoffset, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
        draw.SimpleText( "Playtime", "LHUD_Font_Small", 70+xoffset, ScrH() - 70+yoffset, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
        draw.SimpleText( hr .. ":" .. min .. ":" .. sec, "LHUD_Font_Small", 70+xoffset, ScrH() - 55+yoffset, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
        -----------------------
        
        --HP
        surface.SetDrawColor( 0, 0, 0, 200 )
        //surface.DrawRect( 135+xoffset, ScrH()-120+yoffset, 80, 100 )
        surface.SetDrawColor( 255, 0, 0 )
        surface.DrawRect( 140+xoffset, ScrH()-50+yoffset,  math.Clamp((oldHealth/10)*70, 0, 70), 10 )
        surface.DrawRect( 140+xoffset, ScrH()-65+yoffset,  math.Clamp(((oldHealth-10)/10)*70, 0, 70), 10 )
        surface.DrawRect( 140+xoffset, ScrH()-80+yoffset,  math.Clamp(((oldHealth-20)/10)*70, 0, 70), 10 )
        surface.DrawRect( 140+xoffset, ScrH()-95+yoffset,  math.Clamp(((oldHealth-30)/10)*70, 0, 70), 10 )
        surface.DrawRect( 140+xoffset, ScrH()-110+yoffset, math.Clamp(((oldHealth-40)/10)*70, 0, 70), 10 )
        surface.DrawRect( 140+xoffset, ScrH()-125+yoffset, math.Clamp(((oldHealth-50)/10)*70, 0, 70), 10 )
        surface.DrawRect( 140+xoffset, ScrH()-140+yoffset, math.Clamp(((oldHealth-60)/10)*70, 0, 70), 10 )
        surface.DrawRect( 140+xoffset, ScrH()-155+yoffset, math.Clamp(((oldHealth-70)/10)*70, 0, 70), 10 )
        surface.DrawRect( 140+xoffset, ScrH()-170+yoffset, math.Clamp(((oldHealth-80)/10)*70, 0, 70), 10 )
        surface.DrawRect( 140+xoffset, ScrH()-185+yoffset, math.Clamp(((oldHealth-90)/10)*70, 0, 70), 10 )
        
        --Oxygen
        surface.DrawRect( 240+xoffset, ScrH()-50+yoffset,  math.Clamp((oldOxy/10)*70, 0, 70), 10 )
        surface.DrawRect( 240+xoffset, ScrH()-65+yoffset,  math.Clamp(((oldOxy-10)/10)*70, 0, 70), 10 )
        surface.DrawRect( 240+xoffset, ScrH()-80+yoffset,  math.Clamp(((oldOxy-20)/10)*70, 0, 70), 10 )
        surface.DrawRect( 240+xoffset, ScrH()-95+yoffset,  math.Clamp(((oldOxy-30)/10)*70, 0, 70), 10 )
        surface.DrawRect( 240+xoffset, ScrH()-110+yoffset, math.Clamp(((oldOxy-40)/10)*70, 0, 70), 10 )
        surface.DrawRect( 240+xoffset, ScrH()-125+yoffset, math.Clamp(((oldOxy-50)/10)*70, 0, 70), 10 )
        surface.DrawRect( 240+xoffset, ScrH()-140+yoffset, math.Clamp(((oldOxy-60)/10)*70, 0, 70), 10 )
        surface.DrawRect( 240+xoffset, ScrH()-155+yoffset, math.Clamp(((oldOxy-70)/10)*70, 0, 70), 10 )
        surface.DrawRect( 240+xoffset, ScrH()-170+yoffset, math.Clamp(((oldOxy-80)/10)*70, 0, 70), 10 )
        surface.DrawRect( 240+xoffset, ScrH()-185+yoffset, math.Clamp(((oldOxy-90)/10)*70, 0, 70), 10 )
        
        draw.SimpleText( "HEALTH", "LHUD_Font_Small", 142+xoffset, ScrH() - 37+yoffset, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
        if hp <= 1000000 then
            draw.SimpleText( math.Round(oldHealth), "LHUD_Font_Small", 175+xoffset, ScrH() - ((oldHealth/100)*150)-60+yoffset, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
        else
            draw.SimpleText( "Heckerman", "LHUD_Font_Small", 175+xoffset, ScrH() - ((oldHealth/100)*150)-60+yoffset, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
        end
        
        if oxygen == 0 and oldOxy < 10 then
        else
            draw.SimpleText( "OXYGEN", "LHUD_Font_Small", 240+xoffset, ScrH() - 37+yoffset, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
            if hp <= 1000000 then
                draw.SimpleText( math.Round(oldOxy), "LHUD_Font_Small", 275+xoffset, ScrH() - ((oldOxy/100)*150)-60+yoffset, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
            else
                draw.SimpleText( "Heckerman", "LHUD_Font_Small", 275+xoffset, ScrH() - ((oldOxy/100)*150)-60+yoffset, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
            end
        end
        -----------------------
        
        --Ammo
        local wep=ply:GetActiveWeapon()
        local clip1=wep:Clip1()
        local maxclip1=wep:GetMaxClip1()
        local ammo=ply:GetAmmoCount(wep:GetPrimaryAmmoType())
        
        local barspacing=2
        
        
        surface.SetDrawColor( 0, 0, 0, 200 )
        if wep:GetPrimaryAmmoType() > 0 and wep:GetPrimaryAmmoType() < 28 then
            surface.DrawRect( 350+xoffset+OxySideOffset, ScrH()-50+yoffset, 300, 30 )
        end
        draw.SimpleText( TranslateAmmoToString(wep:GetPrimaryAmmoType()), "LHUD_Font_Small", 350+xoffset+OxySideOffset, ScrH() - 73+yoffset, Color(255, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
        surface.SetDrawColor( 255, 255, 200 )
        for i = 0, clip1 - 1 do
            surface.DrawRect( (355 + i * 292/maxclip1)+xoffset+OxySideOffset, ScrH()-45+yoffset, 292/maxclip1 - barspacing, 20 )
        end
        -----------------------
        
        --Other Display
        tr = ply:GetEyeTrace()
        
        if tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
            displaytime = CurTime() + 2
            ent = tr.Entity
        end
        
        if displaytime > CurTime() and ent:IsValid() then
            surface.SetDrawColor( 0, 0, 0, 200 )
            surface.DrawRect( 10, 10, 300, 80 )
            if ent:IsPlayer() then
                draw.SimpleText( ent:Nick(), "LHUD_Font_Small", 40, 18, team.GetColor(ent:Team()), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
            else
                local npc = TranslateNPCClass(ent:GetClass())
                draw.SimpleText( npc, "LHUD_Font_Small", 40, 18, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
            end
            
            draw.SimpleText( "HP: " .. ent:Health() .. "/100", "LHUD_Font_Small", 20, 40, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
            surface.SetDrawColor( 50, 0, 0 )
            surface.DrawRect( 15, 62, 290, 22 )
            
            surface.SetDrawColor( 200, 0, 0 )
            surface.DrawRect( 15, 62, math.Clamp(ent:Health()/100, 0, 1) * 290, 22 )
            surface.SetDrawColor( 200, 200, 0 )
            surface.DrawRect( 15, 62, math.Clamp((ent:Health()-100)/100, 0, 1) * 290, 22 )
            surface.SetDrawColor( 200, 200, 200 )
            surface.DrawRect( 15, 62, math.Clamp((ent:Health()-200)/100, 0, 1) * 290, 22 )
            surface.SetDrawColor( 0, 0, 200 )
            surface.DrawRect( 15, 62, math.Clamp((ent:Health()-300)/9700, 0, 1) * 290, 22 )
            
            if ent:IsPlayer() then
                if ent:IsAdmin() or ent:IsSuperAdmin() then
                    surface.DrawTexturedRect( 15, 21, 16, 16 )
                end
            end
        end
    end
end

local teamcol=Color( 0, 0, 0 )

function GM:PostDrawOpaqueRenderables()
	local ply=LocalPlayer()
	local tr=ply:GetEyeTraceNoCursor().Entity
	if tr:IsValid() and tr:IsPlayer() then
	teamcol=team.GetColor(tr:Team())

		cam.Start3D2D(tr:GetPos() + Vector(0,0,80), ply:EyeAngles():Right():Angle() + Angle(0,0,90), 0.1)
				draw.SimpleText( tr:Nick(), "CTextMedium", 0, 0, teamcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		cam.End3D2D()
		if tr:SteamID() == "STEAM_0:1:30656417" or ply:SteamID() == "STEAM_0:0:16012000" then
		cam.Start3D2D(tr:GetPos() + Vector(0,0,75), ply:EyeAngles():Right():Angle() + Angle(0,0,90), 0.1)
			if tr:SteamID() == "STEAM_0:1:30656417" then
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
	if ply:SteamID() == "STEAM_0:1:30656417" then
		if ply:Alive() then
		chat.AddText(Color(255, 0, 0, 255), "-DEV- ", nickteamcolor, nickteam, Color(50, 50, 50, 255), "| ", nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), txt)
		else
		chat.AddText(Color(255, 0, 0, 255), "-DEV- *REKT* ", nickteamcolor, nickteam, Color(50, 50, 50, 255), "| ", nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), txt)
		end
		return true
	elseif ply:SteamID() == "STEAM_0:0:16012000" then
		if ply:Alive() then
		chat.AddText(Color(255, 0, 0, 255), "~CREATOR~ ", nickteamcolor, nickteam, Color(50, 50, 50, 255), "| ", nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), txt)
		else
		chat.AddText(Color(255, 0, 0, 255), "~CREATOR~ *REKT* ", nickteamcolor, nickteam, Color(50, 50, 50, 255), "| ", nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), txt)
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