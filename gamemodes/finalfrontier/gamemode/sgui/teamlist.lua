-----------------------------------WHOA THERE PARTNER!----------------------------------
-- This is an addon created by me, Lawlypops. Do not re-upload! (Unless I have given  --
-- EXPRESSED permission in the description!) You can use it to learn for yourself, or --
--            you can get in contact with me if you wish to learn GMOD LUA            --
----------------------------------------------------------------------------------------
--Begin the magic!

if SERVER then AddCSLuaFile() end

local roomNames = {
	"Piloting",
	"Scanner",
	"Weapons",
	"Reactor",
	"Door Control",
	"Life Support",
	"Left Hall",
	"Right Hall",
	"Medical",
	"Teleporter",
	"Shields",
	"Engineering"
}

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
				local roomText = roomNames[ply:GetRoomIndex()] or "Unkown"
				draw.SimpleText( ply:Nick(), "LHUD_Font", 9, 25+YOffset, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				draw.SimpleText( roomText, "LHUD_Font_Small", 14, 55+YOffset, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				surface.SetDrawColor( COLORS.DarkRed )
				surface.DrawRect( 150, 15+YOffset, 115, 20 )
				surface.DrawPoly(HPBGTri)
				surface.SetDrawColor( COLORS.OffRed )
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
					draw.SimpleText( "Respawn in: " .. ply:GetNWInt("NWDeathTime"), "LHUD_Font_Small", 310, 25+YOffset, COLORS.OffRed, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				end
				PlayerCount = PlayerCount+1
			end
		end
	end

	hook.Add("HUDPaint", "ff_drawplayers", ItemPlayerList)
end