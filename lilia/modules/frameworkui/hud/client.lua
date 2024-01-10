
function FrameworkHUD:ShouldHideBars()
    return self.BarsDisabled
end


function FrameworkHUD:HUDShouldDraw(element)
    if table.HasValue(self.HiddenHUDElements, element) then return false end
end


function FrameworkHUD:HUDPaintBackground()
    if self:ShouldDrawBranchWarning() then self:DrawBranchWarning() end
    if self:ShouldDrawBlur() then self:DrawBlur() end
    self:RenderEntities()
end


function FrameworkHUD:HUDPaint()
    local weapon = LocalPlayer():GetActiveWeapon()
    if self:ShouldDrawAmmo(weapon) then self:DrawAmmo(weapon) end
    if self:ShouldDrawCrosshair() then self:DrawCrosshair() end
    if self:ShouldDrawVignette() then self:DrawVignette() end
end


function FrameworkHUD:ForceDermaSkin()
    return self.DarkTheme and "lilia_darktheme" or "lilia"
end
-------------------
