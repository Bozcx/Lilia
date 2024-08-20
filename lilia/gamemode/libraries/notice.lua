﻿lia.notices = lia.notices or {}
lia.noticess = lia.noticess or {}
lia.config.NotifTypes = {
    [1] = {
        col = Color(200, 60, 60),
        icon = "icon16/exclamation.png"
    },
    [2] = {
        col = Color(255, 100, 100),
        icon = "icon16/cross.png"
    },
    [3] = {
        col = Color(255, 100, 100),
        icon = "icon16/cancel.png"
    },
    [4] = {
        col = Color(100, 185, 255),
        icon = "icon16/book.png"
    },
    [5] = {
        col = Color(64, 185, 85),
        icon = "icon16/accept.png"
    },
    [7] = {
        col = Color(100, 185, 255),
        icon = "icon16/information.png"
    }
}

function RemoveNotices(notice)
    for k, v in ipairs(lia.noticess) do
        if v == notice then
            notice:SizeTo(notice:GetWide(), 0, 0.2, 0, -1, function() notice:Remove() end)
            table.remove(lia.noticess, k)
            OrganizeNotices(true)
            break
        end
    end
end

function CreateNoticePanel(length, notimer)
    if not notimer then notimer = false end
    local notice = vgui.Create("noticePanel")
    notice.start = CurTime() + 0.25
    notice.endTime = CurTime() + length
    notice.oh = notice:GetTall()
    function notice:Paint(w, h)
        local t = lia.config.NotifTypes[7]
        local mat
        if self.notifType ~= nil and not isstring(self.notifType) and self.notifType > 0 then
            t = lia.config.NotifTypes[self.notifType]
            mat = lia.util.getMaterial(t.icon)
        end

        draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 35, 200))
        if self.start then
            local w2 = math.TimeFraction(self.start, self.endTime, CurTime()) * w
            local col = (t and t.col) or lia.config.Color
            draw.RoundedBox(4, w2, 0, w - w2, h, col)
        end

        if t and mat then
            local sw, sh = 24, 24
            surface.SetDrawColor(color_white)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(20, h / 2 - sh / 2, sw, sh)
        end
    end

    if not notimer then timer.Simple(length, function() RemoveNotices(notice) end) end
    return notice
end

function OrganizeNotices(alternate)
    local scrW = ScrW()
    local lastHeight = ScrH() - 100
    if alternate then
        for k, v in ipairs(lia.noticess) do
            local topMargin = 0
            for k2, v2 in pairs(lia.noticess) do
                if k < k2 then topMargin = topMargin + v2:GetTall() + 5 end
            end

            v:MoveTo(v:GetX(), topMargin + 5, 0.15, 0, 5)
        end
    else
        for k, v in ipairs(lia.notices) do
            local height = lastHeight - v:GetTall() - 10
            v:MoveTo(scrW - v:GetWide(), height, 0.15, (k / #lia.notices) * 0.25, nil)
            lastHeight = height
        end
    end
end

function lia.util.notify(message)
    local notice = vgui.Create("liaNotify")
    local i = table.insert(lia.notices, notice)
    notice:SetMessage(message)
    notice:SetPos(ScrW(), ScrH() - (i - 1) * (notice:GetTall() + 4) + 4)
    notice:MoveToFront()
    OrganizeNotices(false)
    timer.Simple(10, function()
        if IsValid(notice) then
            notice:AlphaTo(0, 1, 0, function()
                notice:Remove()
                for v, k in pairs(lia.notices) do
                    if k == notice then table.remove(lia.notices, v) end
                end

                OrganizeNotices(false)
            end)
        end
    end)

    MsgN(message)
end

function notification.AddLegacy(text)
    lia.util.notify(tostring(text))
end
