-----------------------------------WHOA THERE PARTNER!----------------------------------
-- This is an addon created by me, Lawlypops. Do not re-upload! (Unless I have given  --
-- EXPRESSED permission in the description!) You can use it to learn for yourself, or --
--            you can get in contact with me if you wish to learn GMOD LUA            --
----------------------------------------------------------------------------------------
--Begin the magic!

if SERVER then AddCSLuaFile() end

local roomConvert = {}

roomConvert[1] = "Piloting"
roomConvert[2] = "Scanner"
roomConvert[3] = "Weapons"
roomConvert[4] = "Reactor"
roomConvert[5] = "Door Control"
roomConvert[6] = "Life Support"
roomConvert[7] = "Left Hall"
roomConvert[8] = "Right Hall"
roomConvert[9] = "Medical"
roomConvert[10] = "Teleporter"
roomConvert[11] = "Shields"
roomConvert[12] = "Engineering"

if CLIENT then
	function ItemPlayerList()
		local PlayerCount = 0
		for _, ply in pairs(player.GetAll()) do
			if IsValid(ply) and ply:Team() == LocalPlayer():Team() and ply != LocalPlayer() then
				local YOffset = PlayerCount*70
				local HPBGTri = {
					{ x = 265, y = 35+YOffset },
					{ x = 265, y = 15+YOffset },
					{ x = 295, y = 35+YOffset }
				}
				
				surface.SetDrawColor( team.GetColor(ply:Team()) )
				surface.DrawRect( 7, 7+YOffset, 296, 36 )
				draw.SimpleText( ply:Nick(), "LHUD_Font", 9, 25+YOffset, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				draw.SimpleText( roomConvert[ply:GetRoomIndex()], "LHUD_Font_Small", 14, 55+YOffset, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				surface.SetDrawColor( 100, 0, 0 )
				surface.DrawRect( 150, 15+YOffset, 115, 20 )
				surface.DrawPoly(HPBGTri)
				surface.SetDrawColor( 200, 0, 0 )
				surface.DrawRect( 150, 15+YOffset, math.Clamp((ply:Health()/80), 0, 1) * 115, 20 )
				
				
				
				if ply:Health() > 80 then
					local HPTri = {
						{ x = 265, y = 35+YOffset },
						{ x = 265, y = 15+YOffset },
					}
						table.insert( HPTri, { x = 265 + math.Clamp(((ply:Health()-80)/20), 0, 1) * 30, y = 15+YOffset + math.Clamp(((ply:Health()-80)/20), 0, 1) * 20 } )
						table.insert( HPTri, { x = 265 + math.Clamp(((ply:Health()-80)/20), 0, 1) * 30, y = 35+YOffset } )
					surface.DrawPoly( HPTri )
				end
				if ply:Health() <= 0 then
					draw.SimpleText( "Respawn in: " .. ply:GetNWInt("NWDeathTime"), "LHUD_Font_Small", 310, 25+YOffset, Color(200,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				end
				PlayerCount = PlayerCount+1
			end
		end
	end


	function paintList()
		//surface.SetDrawColor( 0, 0, 0, 200 )
		//surface.DrawRect( 5, 5, 300, 500 )
		ItemPlayerList()
	end
end

hook.Add("HUDPaint", "ff_drawplayers", paintList)