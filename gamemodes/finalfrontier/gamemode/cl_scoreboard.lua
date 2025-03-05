-- Copyright (c) 2014 Spartan322 [Spartan322@live.com]
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

surface.CreateFont( "ScoreboardDefault",
{
    font   = "Helvetica",
    size   = 22,
    weight = 800
})

surface.CreateFont( "FF_Scoreboard",
{
    font   = "Helvetica",
    size   = 25,
    weight = 800
})

function DrawListItem(w, ply, xoffset, playersincolumn)
	local xpos = (ScrW()/2)-xoffset
	local ypos = 210+(40*playersincolumn)
	
	local teamcol = team.GetColor(ply:Team())
	
	if ply:Alive() then
		teamcol.a = 255
	else
		teamcol.a = 50
	end
	
	draw.RoundedBox( 6, xpos, ypos, w/2-14,35, teamcol )
	draw.SimpleText( ply:Nick(), "FF_Scoreboard", xpos+4, ypos + 17, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText( ply:Frags(), "FF_Scoreboard", xpos+300, ypos + 17, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText( ply:Deaths(), "FF_Scoreboard", xpos+350, ypos + 17, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText( ply:Ping(), "FF_Scoreboard", xpos+400, ypos + 17, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
end

local shouldDraw = false
local height = 100

function GM:HUDDrawScoreBoard()
	if shouldDraw then
		local width = 900
		
		local xpos = (ScrW()/2)-450
		
		//Main BG
		draw.RoundedBox( 4, xpos, 180, width, height, COLORS.DarkGrey)
		//Orange (Left)
		draw.RoundedBox( 4, xpos, 180, (width/2)-4, height, COLORS.DarkGrey)
		//Blue (Right)
		draw.RoundedBox( 4, xpos+454, 180, (width/2)-4, height, COLORS.DarkGrey)
		//Overline
		draw.RoundedBox( 4, xpos, 240, width, 6, color_black)
		
		//Labels Left Side
		draw.SimpleText( "Name", "FF_Scoreboard", xpos+10, 220, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( "K", "FF_Scoreboard", xpos+312, 220, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( "D", "FF_Scoreboard", xpos+362, 220, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( "Ping", "FF_Scoreboard", xpos+412, 220, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		//Labels Right Side
		draw.SimpleText( "Name", "FF_Scoreboard", xpos+10+454, 220, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( "K", "FF_Scoreboard", xpos+312+454, 220, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( "D", "FF_Scoreboard", xpos+362+454, 220, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( "Ping", "FF_Scoreboard", xpos+412+454, 220, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		
		local bluePlayers = 0
		local orangePlayers = 0
		
		for _, ply in pairs(player.GetAll()) do
			if ply:Team() == 1 then
				orangePlayers = orangePlayers+1
				DrawListItem(width, ply, -9, orangePlayers)
			else
				bluePlayers = bluePlayers+1
				DrawListItem(width, ply, 445, bluePlayers)
			end
		end
		
		height = (100)+(math.max(orangePlayers, bluePlayers)*35)
		
	end
end

function GM:ScoreboardShow()
	gui.EnableScreenClicker( true )
	shouldDraw = true
end

function GM:ScoreboardHide()
	gui.EnableScreenClicker( false )
	shouldDraw = false
end