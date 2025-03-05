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

GUI.StatusDial = nil
GUI.LeftIcon = nil
GUI.RightIcon = nil

GUI.CycleTime = -1
GUI.CycleIndex = 0

GUI.WarningIcons = {}
GUI.WarningIcons["power"] = Material("alertpower.png")
GUI.WarningIcons["shield"] = Material("alertshield.png")
GUI.WarningIcons["lifesupport"] = Material("alertlifesupport.png")

function GUI:Enter()
    self.Super[BASE].Enter(self)

    self.StatusDial = sgui.Create(self, "statusdial")
    self.StatusDial:SetCentre(self:GetWidth() / 2, self:GetHeight() / 2)

    if self:GetSystem() then
        self.LeftIcon = sgui.Create(self, "image")
        self.RightIcon = sgui.Create(self, "image")

        local size = self:GetWidth() / 6
        local x, y = self:GetCentre()

        self.LeftIcon:SetSize(size, size)
        self.RightIcon:SetSize(size, size)

        self.LeftIcon:SetCentre(x - size * 2.125, y)
        self.RightIcon:SetCentre(x + size * 2.125, y)

        if CLIENT then
            self.LeftIcon.Material = self:GetSystemIcon()
            self:CycleIcons()
        end
    end
end

function GUI:Draw()
    if CurTime() > self.CycleTime and self:GetSystem() then
        self:CycleIcons()
    end

    self.Super[BASE].Draw(self)
end

function GUI:CycleIcons()
    self.CycleTime = CurTime() + 1
    self.CycleIndex = self.CycleIndex + 1

    local CycleImages = {}
    if self:CheckModuleDamaged(moduletype.SYSTEM_POWER) then
        CycleImages[#CycleImages + 1] = self.WarningIcons["power"]
    end
    if self:CheckModuleDamaged(moduletype.SHIELDS) then
        CycleImages[#CycleImages + 1] = self.WarningIcons["shield"]
    end
    if self:CheckModuleDamaged(moduletype.LIFE_SUPPORT) then
        CycleImages[#CycleImages + 1] = self.WarningIcons["lifesupport"]
    end

    if #CycleImages == 0 then
        self.RightIcon.Material = self:GetSystemIcon()
        self.RightIcon.Color = color_white
        return
    end


    if self.CycleIndex > #CycleImages then
        self.CycleIndex = 1 -- If we've cycled through everything, circle back
    end
    
    self.RightIcon.Material = CycleImages[self.CycleIndex]
    self.RightIcon.Color = COLORS.Warning
end

function GUI:SetIcons(material, color)
    self.LeftIcon.Material = material
    self.RightIcon.Material = material
    self.LeftIcon.Color = color
    self.RightIcon.Color = color
end

function GUI:CheckModuleDamaged(moduletocheck)
    local module = self:GetRoom():GetModule(moduletocheck)
    if not module then
        return true -- No module inserted
    end
    return module:GetDamaged() > 0
end