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

if SERVER then AddCSLuaFile("player_ff_default.lua") end

local PLAYER = {}

PLAYER.WalkSpeed            = 175
PLAYER.RunSpeed             = 250

PLAYER.DisplayName = "Cosmonaut"

local _models = {
    "models/player/group03/male_01.mdl",
    "models/player/group03/male_02.mdl",
    "models/player/group03/male_03.mdl",
    "models/player/group03/male_04.mdl",
    "models/player/group03/male_05.mdl",
    "models/player/group03/male_06.mdl",
    "models/player/group03/male_07.mdl",
    "models/player/group03/male_08.mdl",
    "models/player/group03/male_09.mdl",
    "models/player/group03/female_01.mdl",
    "models/player/group03/female_02.mdl",
    "models/player/group03/female_03.mdl",
    "models/player/group03/female_04.mdl",
    "models/player/group03/female_05.mdl",
    "models/player/group03/female_06.mdl"
}
/*
local _race = {
    "human",
    "rockmen",
    "zoltan",
    "lanius"
}
*/
if SERVER then
    function PLAYER:Init()
        team.AutoAssign(self.Player)
        self.Player:SetArmor(100)
    end

    function PLAYER:Spawn()
        local ship = team.GetShip(self.Player:Team())
        local pad = table.Random(ship:GetAvailableTransporterTargets())
		local teamcol=team.GetColor(self.Player:Team())
        self.Player:SetPos(pad)
        self.Player:SetShip(ship)
		self.Player:SetPlayerColor(Vector(teamcol.r/255, teamcol.g/255, teamcol.b/255))

        self.Player:SetArmor(100)
        self.Player:SetCanWalk(true)
        /*
        self.Player:SetPlayerRace( table.Random(_race) )
        print(self.Player:GetPlayerRace())
        */
        TeleportArriveEffect(self.Player, self.Player:GetPos())
    end

    function PLAYER:SetModel()
        self.Player:SetModel(table.Random(_models))
    end

    function PLAYER:Loadout()
        self.Player:Give("weapon_crowbar")
        self.Player:Give("weapon_ff_repair_tool")
    end
end

function PLAYER:SetupDataTables()
    local ply = self.Player or self

    ply:NetworkVar("String", 0, "ShipName")
    //ply:NetworkVar("String", 1, "PlayerRace" )

    ply:NetworkVar("Int", 0, "RoomIndex")

    ply:NetworkVar("Bool", 0, "UsingScreen")

    ply:NetworkVar("Entity", 0, "CurrentScreen")
    ply:NetworkVar("Entity", 1, "OldWeapon")

    ply._permissions = ply:NetworkTable(0, "Permissions")
end

SetupPlayerDataTables = PLAYER.SetupDataTables

player_manager.RegisterClass("player_ff_default", PLAYER, "player_default")

if CLIENT then
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
end