-- Copyright (c) 2014 James King [metapyziks@gmail.com]
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

if SERVER then AddCSLuaFile("sh_teams.lua") end

if CLIENT and not team._nwdata then
    team._count = 0	
end

team._nwdata = NetworkTable("teams")

function team.GetDeadColor(t)
    local clr = team.GetColor(t)
    return Color(clr.r * 0.5, clr.g * 0.5, clr.b * 0.5, 255)
end

function team.GetShip(t)
    return ships.GetByName(team._nwdata[t].shipname)
end

if SERVER then
    function team.Add(ship)
        local t = {}
        t.shipname = ship:GetName()
        t.name = ship:GetFullName()
        t.color = ship:GetUIColor()

        table.insert(team._nwdata, t)
        team._nwdata:Update()

        local i = #team._nwdata

        team.SetUp(i, t.name, t.color, true)
    end

    function team.GetLeastPopulated()
        local min = {}

        for t, _ in ipairs(team._nwdata) do
            local players = team.NumPlayers(t)
            if #min == 0 or players < min[1].players then
                min = { { team = t, players = players } }
            elseif min[1].players == players then
                table.insert(min, { team = t, players = players })
            end
        end

        return table.Random(min).team
    end

    function team.AutoAssign(ply)
        ply:SetTeam(team.GetLeastPopulated())
    end
	
	local lastTeamSwitch = 0
	
	function TEAM_1( ply )
		if lastTeamSwitch < CurTime() then
			if ply:Team() != 1 then
				ply:UnSpectate()
				ply:SetTeam( 1 )
				ply:Spawn()
				lastTeamSwitch = CurTime() + 10
			else ply:ChatPrint( "You are already on this team." ) end
		else
			ply:ChatPrint( "You must wait " .. math.Round(lastTeamSwitch - CurTime(), 1) .. " seconds to switch teams." )
		end
	end
	concommand.Add("ff_team1", TEAM_1)
	 
	 
	function TEAM_2( ply )
		if lastTeamSwitch < CurTime() then
			if ply:Team() != 2 then
				ply:UnSpectate()
				ply:SetTeam( 2 )
				ply:Spawn()
				lastTeamSwitch = CurTime() + 10
			else ply:ChatPrint( "You are already on this team." ) end
		else
			ply:ChatPrint( "You must wait " .. math.Round(lastTeamSwitch - CurTime(), 1) .. " seconds to switch teams." )
		end
	end
	concommand.Add("ff_team2", TEAM_2)
	
elseif CLIENT then
    function team.Think()
        if team._count >= #team._nwdata then return end

        for t = team._count + 1, #team._nwdata do
            local data = team._nwdata[t]
            team.SetUp(t, data.name, data.color, true)
        end
    end
	
	function TeamMenu(  )
	
		local TeamMenu = vgui.Create( "DFrame" )
		TeamMenu:SetPos( ScrW() / 2 - 250, ScrH() / 2 -200 )
		TeamMenu:SetSize( 260, 210 )
		TeamMenu:SetTitle( "Team Selection" )
		TeamMenu:ShowCloseButton( false )
		TeamMenu:SetVisible( true )
		TeamMenu:SetDraggable( false )
		TeamMenu:MakePopup( )
		function TeamMenu:Paint()
			draw.RoundedBox( 8, 0, 0, self:GetWide(), self:GetTall(), COLORS.TransparentBlack )
		end 
		
		
		local team_1 = vgui.Create( "DButton", TeamMenu )
		team_1:SetPos( 5, 30 )
		team_1:SetSize( 250, 30 )
		team_1:SetText( "Team 1" )
		team_1:SetTextColor( color_white )
		
		team_1.Paint = function()
			surface.SetDrawColor( team.GetColor(1) )
			surface.DrawRect( 0, 0, team_1:GetWide(), team_1:GetTall() )
		end
		
		team_1.DoClick = function()
			RunConsoleCommand( "ff_team1" )
			TeamMenu:Close()
		end
		
		
		local team_2 = vgui.Create( "DButton", TeamMenu )
		team_2:SetPos( 5, 70 )
		team_2:SetSize( 250, 30 )
		team_2:SetText( "Team 2" )
		team_2:SetTextColor( color_white )
		
		team_2.Paint = function()
			surface.SetDrawColor( team.GetColor(2) )
			surface.DrawRect( 0, 0, team_2:GetWide(), team_2:GetTall() )
		end
		
		team_2.DoClick = function()
			RunConsoleCommand( "ff_team2" )
			TeamMenu:Close()
		end
		
		
		local close_button = vgui.Create( "DButton", TeamMenu )
		close_button:SetPos( 5, 185 )
		close_button:SetSize( 250, 20 )
		close_button:SetText( "Close this menu" )
		
		close_button.Paint = function()
			draw.RoundedBox( 8, 0, 0, close_button:GetWide(), close_button:GetTall(), Color( 0,0,0,225 ) )
			surface.DrawRect( 0, 0, close_button:GetWide(), close_button:GetTall() )
		end
		
		close_button.DoClick = function()
			TeamMenu:Close()
		end
	
	end
	
	concommand.Add("ff_teammenu", TeamMenu)
	 
end

function GM:OnPlayerChat( ply, text, teamChat, isDead )
	if text == "!ffteam" then
		RunConsoleCommand("ff_teammenu")
		return true
	end
end
