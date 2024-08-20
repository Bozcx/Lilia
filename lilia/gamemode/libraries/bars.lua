﻿--- Helper library for generating bars.
-- @library lia.bar
lia.bar = lia.bar or {}
lia.bar.delta = lia.bar.delta or {}
lia.bar.list = {}
lia.bar.actionText = ""
lia.bar.actionStart = 0
lia.bar.actionEnd = 0
--- Retrieves information about a bar identified by its identifier.
-- @string identifier The identifier of the bar.
-- @return table The information about the bar if found, nil otherwise.
-- @realm client
function lia.bar.get(identifier)
    for i = 1, #lia.bar.list do
        local bar = lia.bar.list[i]
        if bar and bar.identifier == identifier then return bar end
    end
end

--- Adds a new bar or updates an existing one.
-- @func getValue The function to retrieve the current value of the bar.
-- @color[opt] color The color of the bar.
-- @int[opt] priority The priority of the bar in the draw order.
-- @string[opt] identifier The identifier of the bar.
-- @return int The priority of the added or updated bar.
-- @realm client
function lia.bar.add(getValue, color, priority, identifier)
    if identifier then
        local oldBar = lia.bar.get(identifier)
        if oldBar then table.remove(lia.bar.list, oldBar.priority) end
    end

    priority = priority or table.Count(lia.bar.list) + 1
    local info = lia.bar.list[priority]
    lia.bar.list[priority] = {
        getValue = getValue,
        color = color or info.color or Color(math.random(150, 255), math.random(150, 255), math.random(150, 255)),
        priority = priority,
        lifeTime = 0,
        identifier = identifier
    }
    return priority
end

--- Removes a bar identified by its identifier.
-- @string identifier The identifier of the bar to remove.
-- @realm client
function lia.bar.remove(identifier)
    local bar
    for _, v in ipairs(lia.bar.list) do
        if v.identifier == identifier then
            bar = v
            break
        end
    end

    if bar then table.remove(lia.bar.list, bar.priority) end
end

--- Draws a single bar with the specified parameters.
-- @int x The x-coordinate of the top-left corner of the bar.
-- @int y The y-coordinate of the top-left corner of the bar.
-- @int w The width of the bar.
-- @int h The height of the bar.
-- @int value The current value of the bar (0 to 1).
-- @tab color The color of the bar.
-- @realm client
function lia.bar.draw(x, y, w, h, value, color)
    lia.util.drawBlurAt(x, y, w, h)
    surface.SetDrawColor(255, 255, 255, 15)
    surface.DrawRect(x, y, w, h)
    surface.DrawOutlinedRect(x, y, w, h)
    x, y, w, h = x + 2, y + 2, (w - 4) * math.min(value, 1), h - 4
    surface.SetDrawColor(color.r, color.g, color.b, 250)
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor(255, 255, 255, 8)
    surface.SetMaterial(lia.util.getMaterial("vgui/gradient-u"))
    surface.DrawTexturedRect(x, y, w, h)
end

local mathApproach = math.Approach
--- Draws the action bar, if applicable.
-- @realm client
-- @internal
function lia.bar.drawAction()
    local start, finish = lia.bar.actionStart, lia.bar.actionEnd
    local curTime = CurTime()
    local scrW, scrH = ScrW(), ScrH()
    if finish > curTime then
        local fraction = 1 - math.TimeFraction(start, finish, curTime)
        local alpha = fraction * 255
        if alpha > 0 then
            local w, h = scrW * 0.35, 28
            local x, y = (scrW * 0.5) - (w * 0.5), (scrH * 0.725) - (h * 0.5)
            lia.util.drawBlurAt(x, y, w, h)
            surface.SetDrawColor(35, 35, 35, 100)
            surface.DrawRect(x, y, w, h)
            surface.SetDrawColor(0, 0, 0, 120)
            surface.DrawOutlinedRect(x, y, w, h)
            surface.SetDrawColor(lia.config.Color)
            surface.DrawRect(x + 4, y + 4, (w * fraction) - 8, h - 8)
            surface.SetDrawColor(200, 200, 200, 20)
            surface.SetMaterial(lia.util.getMaterial("vgui/gradient-d"))
            surface.DrawTexturedRect(x + 4, y + 4, (w * fraction) - 8, h - 8)
            draw.SimpleText(lia.bar.actionText, "liaMediumFont", x + 2, y - 22, Color(20, 20, 20))
            draw.SimpleText(lia.bar.actionText, "liaMediumFont", x, y - 24, Color(240, 240, 240))
        end
    end
end

--- Draws all bars in the list.
-- @realm client
-- @internal
function lia.bar.drawAll()
    lia.bar.drawAction()
    if hook.Run("ShouldHideBars") then return end
    local w, h = ScrW() * 0.35, 10
    local x, y = 4, 4
    local deltas = lia.bar.delta
    local frameTime = FrameTime()
    local curTime = CurTime()
    local updateValue = frameTime * 0.6
    for i = 1, #lia.bar.list do
        local bar = lia.bar.list[i]
        if bar then
            local realValue = bar.getValue()
            local value = mathApproach(deltas[i] or 0, realValue, updateValue)
            deltas[i] = value
            if deltas[i] ~= realValue then bar.lifeTime = curTime + 5 end
            if bar.lifeTime >= curTime or bar.visible or hook.Run("ShouldBarDraw", bar) then
                lia.bar.draw(x, y, w, h, value, bar.color, bar)
                y = y + h + 2
            end
        end
    end
end
