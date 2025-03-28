﻿local PANEL = {}
function PANEL:Init()
	self.MODULE = 64
end

function PANEL:setIconSize( MODULE )
	self.MODULE = MODULE
end

function PANEL:setItem( item )
	self.Icon:SetSize( self.MODULE * ( item.width or 1 ), self.MODULE * ( item.height or 1 ) )
	self.Icon:InvalidateLayout( true )
	self:setItemType( item:getID() )
	self:centerIcon()
end

function PANEL:centerIcon( w, h )
	w = w or self:GetWide()
	h = h or self:GetTall()
	local iconW, iconH = self.Icon:GetSize()
	self.Icon:SetPos( ( w - iconW ) * 0.5, ( h - iconH ) * 0.5 )
end

function PANEL:PaintBehind( w, h )
	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.DrawRect( 0, 0, w, h )
	surface.DrawOutlinedRect( 0, 0, w, h )
end

function PANEL:PerformLayout( w, h )
	self:centerIcon( w, h )
end

vgui.Register( "liaGridInvItem", PANEL, "liaItemIcon" )
