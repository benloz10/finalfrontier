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

local BASE = "page"

GUI.BaseName = BASE
GUI._advanced = false
GUI._selectJump = false

GUI._grid = nil
GUI._zoomLabel = nil
GUI._zoomSlider = nil
GUI._sectorLabel = nil
GUI._coordLabel = nil
GUI._angleLabel = nil
GUI._powerBar = nil
GUI._advancedButton = nil


GUI._cloakButton = nil
GUI._cloakLabel = nil
GUI._jumpButton = nil
GUI._jumpLabel = nil
GUI._jumpSlider = nil
GUI._closeButton = nil

function GUI:Advanced(adv)
	self:RemoveAllChildren()
	if adv then
		self._selectJump = false
		self._advanced = true

		self._grid = nil
		self._zoomLabel = nil
		self._zoomSlider = nil
		self._sectorLabel = nil
		self._coordLabel = nil
		self._angleLabel = nil
		self._powerBar = nil
		self._advancedButton = nil

		self._cloakButton = sgui.Create(self, "button")
		self._cloakButton:SetOrigin(16, 8)
		self._cloakButton:SetSize(self:GetWidth() - 32, 48)
		self._cloakButton.Text = "Cloak: Currently unknown"

		self._cloakLabel = sgui.Create(self, "label")
		self._cloakLabel.AlignX = TEXT_ALIGN_CENTER
		self._cloakLabel.AlignY = TEXT_ALIGN_CENTER
		self._cloakLabel:SetOrigin(self:GetWidth()/2, self._cloakButton:GetBottom() + 8)
		self._cloakLabel:SetSize(16, 32)
		self._cloakLabel.Text = "WARNING: CLOAK DISABLES SHIELDS AND WEAPONS!"

		self._jumpButton = sgui.Create(self, "button")
		self._jumpButton:SetOrigin(16, self._cloakLabel:GetBottom() + 8)
		self._jumpButton:SetSize(256, 48)
		self._jumpButton.Text = "Prepare Jump"

		self._jumpSlider = sgui.Create(self, "slider")
		self._jumpSlider:SetOrigin(self._jumpButton:GetRight() + 8, self._cloakLabel:GetBottom() + 8)
		self._jumpSlider:SetSize(self:GetWidth() - 296 , 48)
		self._jumpSlider.CanClick = false
		self._jumpSlider.TextColorNeg = self._jumpSlider.TextColorPos
		self._jumpSlider.Value = self:GetSystem():GetJumpCharge()/100

		self._jumpLabel = sgui.Create(self, "label")
		self._jumpLabel.AlignX = TEXT_ALIGN_CENTER
		self._jumpLabel.AlignY = TEXT_ALIGN_CENTER
		self._jumpLabel:SetOrigin(self:GetWidth()/2, self._jumpSlider:GetBottom() + 8)
		self._jumpLabel:SetSize(16, 32)
		self._jumpLabel.Text = "Required power for jump: unknown"

		self._closeButton = sgui.Create(self, "button")
		self._closeButton:SetOrigin(16, self:GetHeight() - 48 - 16)
		self._closeButton:SetSize(self:GetWidth() - 32, 48)
		self._closeButton.Text = "Return to Pilot Control"

		if SERVER then
			self._cloakButton.OnClick = function(btn, button)
				self:GetSystem():TryCloak()
				self:GetScreen():UpdateLayout()
				return true
			end

			self._jumpButton.OnClick = function(btn, button)
				if not self:GetSystem():GetIsJumping() then
					self._selectJump = true
					self:GetSystem():SetIsSelectingJump(true)
					self:Advanced(false)
					self:GetScreen():UpdateLayout()
					return true
				end
			end

			function self._closeButton.OnClick(btn, x, y, button)
				self:Advanced(false)
				self:GetScreen():UpdateLayout()
				return true
			end
		end
	else
		self._advanced = false
		self._cloakButton = nil
		self._cloakLabel = nil
		self._jumpButton = nil
		self._jumpLabel = nil
		self._jumpSlider = nil
		self._closeButton = nil

		self._grid = sgui.Create(self, "sectorgrid")
		self._grid:SetOrigin(8, 8)
		self._grid:SetSize(self:GetWidth() * 0.6 - 16, self:GetHeight() - 16)
		self._grid:SetCentreObject(nil)
		self._grid:SetInitialScale(self._grid:GetMinScale())
		self._grid:SetScaleRatio(0)

		local colLeft = self._grid:GetRight() + 16
		local colWidth = self:GetWidth() * 0.4 - 16

		if SERVER then
			function self._grid.OnClick(grid, x, y, button)
				if button == MOUSE1 and not self:GetSystem():GetIsJumping() then
					local sx, sy = self:GetShip():GetCoordinates()
					local tx, ty = grid:ScreenToCoordinate(x - grid:GetLeft(), y - grid:GetTop())
					local dx, dy = universe:GetDifference(sx, sy, tx, ty)
					if self._selectJump then
						self:GetSystem():TryJump(tx, ty)
						self:GetSystem():SetIsSelectingJump(false)
						self:Advanced(true)
						self:GetScreen():UpdateLayout()
					else
						self:GetSystem():SetTargetHeading(dx, dy)
					end
				elseif button == MOUSE2 then
					if self._selectJump then
						self:GetSystem():SetIsSelectingJump(false)
						self:Advanced(true)
						self:GetScreen():UpdateLayout()
					else
						self:GetSystem():FullStop()
					end
				end
				return true
			end
		end



		self._zoomLabel = sgui.Create(self, "label")
		self._zoomLabel.AlignX = TEXT_ALIGN_CENTER
		self._zoomLabel.AlignY = TEXT_ALIGN_CENTER
		self._zoomLabel:SetOrigin(colLeft, 16)
		self._zoomLabel:SetSize(colWidth, 32)
		self._zoomLabel.Text = "View Zoom"

		self._zoomSlider = sgui.Create(self, "slider")
		self._zoomSlider:SetOrigin(colLeft, self._zoomLabel:GetBottom() + 8)
		self._zoomSlider:SetSize(colWidth, 48)
		if SERVER then
			self._zoomSlider.Value = self._grid:GetScaleRatio()

			function self._zoomSlider.OnValueChanged(slider, value)
				self._grid:SetScaleRatio(value)
			end
		end

		self._sectorLabel = sgui.Create(self, "label")
		self._sectorLabel.AlignX = TEXT_ALIGN_CENTER
		self._sectorLabel.AlignY = TEXT_ALIGN_CENTER
		self._sectorLabel:SetOrigin(colLeft, self._zoomSlider:GetBottom() + 16)
		self._sectorLabel:SetSize(colWidth, 32)

		self._coordLabel = sgui.Create(self, "label")
		self._coordLabel.AlignX = TEXT_ALIGN_CENTER
		self._coordLabel.AlignY = TEXT_ALIGN_CENTER
		self._coordLabel:SetOrigin(colLeft, self._sectorLabel:GetBottom() + 8)
		self._coordLabel:SetSize(colWidth, 32)

		self._angleLabel = sgui.Create(self, "label")
		self._angleLabel.AlignX = TEXT_ALIGN_CENTER
		self._angleLabel.AlignY = TEXT_ALIGN_CENTER
		self._angleLabel:SetOrigin(colLeft, self._coordLabel:GetBottom() + 8)
		self._angleLabel:SetSize(colWidth, 32)

		self._powerBar = sgui.Create(self, "powerbar")
		self._powerBar:SetOrigin(colLeft, self:GetHeight() - 64)
		self._powerBar:SetSize(colWidth, 48)

		self._advancedButton = sgui.Create(self, "button")
		self._advancedButton:SetOrigin(colLeft, self._angleLabel:GetBottom() + 8)
		self._advancedButton:SetSize(colWidth, 48)
		self._advancedButton.Text = "Advanced"

		if SERVER then
			self._advancedButton.OnClick = function(btn, button)
				self:GetSystem():SetIsSelectingJump(false)
				self:Advanced(true)
				self:GetScreen():UpdateLayout()
				return true
			end
		end
	end
end

function GUI:Enter()
    self.Super[BASE].Enter(self)

	self:GetSystem():SetIsSelectingJump(false)
	self._selectJump = false
	self:Advanced(false)
end

if SERVER then
	function GUI:UpdateLayout(layout)
		self.Super[BASE].UpdateLayout(self, layout)

		layout.advanced = self._advanced
	end
elseif CLIENT then
    function GUI:Draw()
		if not self._advanced then
			local sx, sy = self:GetShip():GetCoordinates()
			self._coordLabel.Text = "x: " .. FormatNum(sx, 1, 2) .. ", y: " .. FormatNum(sy, 1, 2)
			self._angleLabel.Text = "bearing: " .. FormatBearing(self:GetShip():GetRotation())
		else
			local dest = self:GetSystem():GetJumpCharge()/100

			local cloakStatus = "Disengaged"
			local cloakColor = COLORS.Red
			if self:GetShip():GetObject():GetIsCloakedShip() then
				cloakStatus = "Engaged"
				cloakColor = COLORS.Green
			end
			self._cloakButton.Text = "Cloak: Currently " .. cloakStatus
			self._cloakButton.Color = cloakColor

			self._jumpSlider.Value = self._jumpSlider.Value + (dest - self._jumpSlider.Value) * 0.1

			local reactor = self:GetShip():GetSystem("reactor")

			local availpower = reactor:GetTotalPower() - reactor:GetTotalSupplied()
			local jumpColor = COLORS.Red
			if self:GetSystem():GetJumpPowerNeeded() <= availpower then
				jumpColor = COLORS.Green
			end

			self._jumpLabel.Text = "Jump Power: " .. math.Round(self:GetSystem():GetJumpPowerNeeded(), 2) .. "/" .. math.Round(availpower, 2)
			self._jumpLabel.Color = jumpColor
		end


		self.Super[BASE].Draw(self)
    end

    function GUI:UpdateLayout(layout)
        if self._advanced ~= layout.advanced then
			self:Advanced(layout.advanced)
		end



		if self._advanced then
			local old = self._jumpSlider.Value
			self.Super[BASE].UpdateLayout(self, layout)
			self._jumpSlider.Value = old
		else
			self.Super[BASE].UpdateLayout(self, layout)
			local sectors = ents.FindByClass("info_ff_sector")
			local sx, sy = self:GetShip():GetCoordinates()
			sx = math.floor(sx)
			sy = math.floor(sy)
			for _, sector in pairs(sectors) do
				local x, y = sector:GetCoordinates()
				x = math.floor(x)
				y = math.floor(y)
				if math.abs(x - sx) < 0.5 and math.abs(y - sy) < 0.5 then
					if self._sectorLabel then
						self._sectorLabel.Text = sector:GetSectorName()
					end
					break
				end
			end
		end
    end
end
