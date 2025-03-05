if SERVER then
	AddCSLuaFile("sh_races.lua")

	local ply_mt = FindMetaTable("Player")

    function ply_mt:UpdateRace(var)
        if var == nil then var = self:GetRace() end
        local raceTable = PLAYER_RACES[var]
		if not istable(raceTable) then
			var = "human"
			raceTable = PLAYER_RACES[var]
		end
        self:SetRace(var)
        self:SetMaxHealth(raceTable.hp)
        self:SetHealth(raceTable.hp)
        self:SetMaxArmor(raceTable.armor)
        self:SetArmor(raceTable.armor)
    end
	
end

local ply_mt = getmetatable("Player")


if CLIENT then
	local RACEMENU = {}
	local PNL = nil

    function RACEMENU:SelectRace(race)
        net.Start("ff_race_select")
        net.WriteString(race)
        net.SendToServer()
    end

	function RACEMENU:AddRaceButton(var, tbl, par)
		if not istable(tbl) then return end
		local btn = vgui.Create("DButton", par)
		btn:Dock(LEFT)
		btn:SetWide(150)
		btn:SetFont("CTextTiny")
		btn:DockMargin(0,0,20,0)
		btn:SetText(tbl.NiceName)
		btn:SetContentAlignment(8)
		btn:SetTextColor(color_white)
		btn:InvalidateParent(true)
		function btn:OnRemove()
			if IsValid(self.tooltip) then
				self.tooltip:Remove()
			end
		end

		btn.tooltip = vgui.Create("DLabel")
		btn.tooltip:SetVisible(false)
		btn.tooltip:SetDrawOnTop(true)
		btn.tooltip:SetText(tbl.Description)
		btn.tooltip:SetFont("CTextTiny")
		btn.tooltip:SizeToContents()
		function btn.tooltip:Paint(w,h)
			surface.SetDrawColor(0,0,0)
			surface.DrawRect(0, 0, w, h)
			--draw.SimpleText(self.txt, "CTextTiny", 0, 0, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end

		btn.race = var
		btn.grayout = Color(200,200,200)
		if LocalPlayer():GetRace() == var then
			btn:SetMouseInputEnabled(false)
		end
		function btn:Paint(w,h)
			if LocalPlayer():GetRace() == var then
				surface.SetDrawColor(self.grayout)
			else
				surface.SetDrawColor(team.GetColor(1))
			end
			surface.DrawRect(0,0,w,h)
			if self:IsHovered() then
				--self.tooltip:SetPos(input.GetCursorPos())
				self.tooltip:SetVisible(true)
				local posx, posy = input.GetCursorPos()
				posx = posx - self.tooltip:GetWide()/2
				posy = posy - self.tooltip:GetTall()
				self.tooltip:SetPos(posx, posy)
			else
				self.tooltip:SetVisible(false)
			end
		end
		function btn:DoClick()
			RACEMENU:SelectRace(self.race)
			PNL:Close()
		end
	end

	function RACEMENU:Open()
		if PNL ~= nil then PNL:Remove() end
		PNL = vgui.Create("DFrame")
		PNL:SetTall(180)
		PNL:SetTitle("Race Selection")
		PNL:DockPadding(5,25,5,5)
		PNL:ShowCloseButton(false)
		PNL:SetVisible(true)
		PNL:SetDraggable(false)
		PNL:MakePopup()
        PNL:Center()
		PNL:ParentToHUD()

		local warn = vgui.Create("DLabel", PNL)
		warn:Dock(TOP)
		warn:SetText("WARNING: CHANGING RACE WILL KILL YOU!")
		warn:DockMargin(0,0,0,5)
		warn:SetFont("CTextTiny")
		warn:SetTextColor(color_red)
		warn:SetContentAlignment(5)


		local close_button = vgui.Create("DButton",PNL)
		close_button:Dock(BOTTOM)
		close_button:SetTall(20)
		close_button:SetText("Close")
        close_button:SetColor(color_white)
		close_button:DockMargin(0,10,0,0)

		function PNL:Paint()
			draw.RoundedBox(8,0,0,self:GetWide(),self:GetTall(),COLORS.TransparentBlack)
		end

		for k, tbl in pairs(PLAYER_RACES) do
			RACEMENU:AddRaceButton(k, tbl, PNL)
		end

		PNL:SizeToChildren(true, false)
		PNL:Center()

		
		function close_button:Paint()
			draw.RoundedBox(8,0,0,close_button:GetWide(),close_button:GetTall(),COLORS.DarkRed)
			surface.DrawRect(0,0,close_button:GetWide(),close_button:GetTall())
		end
		
		function close_button:DoClick()
			PNL:Close()
		end
	end
	
	concommand.Add("ff_racemenu",RACEMENU.Open)
end

if SERVER then
    util.AddNetworkString("ff_race_select")

    net.Receive("ff_race_select",function(len,ply)
        local race = net.ReadString()

		ply:Spawn()
		ply:UpdateRace(race)
		
        MsgN("Selected race: ", race)
    end)
end