if SERVER then AddCSLuaFile("sh_races.lua") end

if CLIENT then
    function RaceSelect(race)
        net.Start("ff_race_select")
        net.WriteString(race)
        net.SendToServer()
    end

	function RaceMenu()
		local RaceMenu = vgui.Create("DFrame")
		RaceMenu:SetPos(ScrW() / 2,ScrH() / 2)
		RaceMenu:SetSize(260,210)
		RaceMenu:SetTitle("Race Selection")
		RaceMenu:ShowCloseButton(false)
		RaceMenu:SetVisible(true)
		RaceMenu:SetDraggable(false)
		RaceMenu:MakePopup()
        RaceMenu:Center()

		function RaceMenu:Paint()
			draw.RoundedBox(8,0,0,self:GetWide(),self:GetTall(),Color(0,0,0,200))
		end 
		
		local human = vgui.Create("DButton",RaceMenu)
		human:SetPos(5,30)
		human:SetSize(250,30)
		human:SetText("Human")
		human:SetTextColor(Color(255,255,255))
        human:SetTooltip("Regular Human")
		
		human.Paint = function()
			surface.SetDrawColor(team.GetColor(1))
			surface.DrawRect(0,0,human:GetWide(),human:GetTall())
		end
		
		human.DoClick = function()
			RaceSelect("human")
			RaceMenu:Close()
		end
		
		local rockmen = vgui.Create("DButton",RaceMenu)
		rockmen:SetPos(5,62)
		rockmen:SetSize(250,30)
		rockmen:SetText("Rockmen")
		rockmen:SetTextColor(Color(255,255,255))
        rockmen:SetTooltip("Rockmen, has higher Health")
		
		rockmen.Paint = function()
			surface.SetDrawColor(team.GetColor(1))
			surface.DrawRect(0,0,rockmen:GetWide(),rockmen:GetTall())
		end
		
		rockmen.DoClick = function()
			RaceSelect("rockmen")
			RaceMenu:Close()
		end

        local zoltan = vgui.Create("DButton",RaceMenu)
		zoltan:SetPos(5,94)
		zoltan:SetSize(250,30)
		zoltan:SetText("Zoltan")
		zoltan:SetTextColor(Color(255,255,255))
        zoltan:SetTooltip("Zoltan, Powers rooms they're in")
		
		zoltan.Paint = function()
			surface.SetDrawColor(team.GetColor(1))
			surface.DrawRect(0,0,zoltan:GetWide(),zoltan:GetTall())
		end
		
		zoltan.DoClick = function()
			RaceSelect("zoltan")
			RaceMenu:Close()
		end

        local lanius = vgui.Create("DButton",RaceMenu)
		lanius:SetPos(5,126)
		lanius:SetSize(250,30)
		lanius:SetText("Lanius")
		lanius:SetTextColor(Color(255,255,255))
        lanius:SetTooltip("Lanius, Doesn't need oxygen, and drains oxygen from the room they're in")
		
		lanius.Paint = function()
			surface.SetDrawColor(team.GetColor(1))
			surface.DrawRect(0,0,lanius:GetWide(),lanius:GetTall())
		end
		
		lanius.DoClick = function()
			RaceSelect("lanius")
			RaceMenu:Close()
		end
		
		local close_button = vgui.Create("DButton",RaceMenu)
		close_button:SetPos(5,185)
		close_button:SetSize(250,20)
		close_button:SetText("Close")
        close_button:SetColor(Color(255,255,255,255))
		
		close_button.Paint = function()
			draw.RoundedBox(8,0,0,close_button:GetWide(),close_button:GetTall(),Color(150,0,0,225))
			surface.DrawRect(0,0,close_button:GetWide(),close_button:GetTall())
		end
		
		close_button.DoClick = function()
			RaceMenu:Close()
		end
	end
	
	concommand.Add("ff_racemenu",RaceMenu)
end

if SERVER then
    util.AddNetworkString("ff_race_select")

    net.Receive("ff_race_select",function(len,ply)
        local race = net.ReadString()

        if(race == "human") then
            ply:SetHealth(100)
            ply:SetMaxHealth(100)
            ply:SetArmor(100)
            ply:SetMaxArmor(100)
        elseif(race == "rockmen") then
            ply:SetHealth(150)
            ply:SetMaxHealth(150)
            ply:SetArmor(150)
            ply:SetMaxArmor(150)
        elseif(race == "zoltan") then
            ply:SetHealth(80)
            ply:SetMaxHealth(80)
            ply:SetArmor(100)
            ply:SetMaxArmor(100)
        elseif(race == "lanius") then
            ply:SetHealth(100)
            ply:SetMaxHealth(100)
            ply:SetArmor(100)
            ply:SetMaxArmor(100)
        end

        ply:SetNWString("race",race)
        print(race)
        print(ply:Health())
    end)
end