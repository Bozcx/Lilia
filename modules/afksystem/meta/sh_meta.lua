--------------------------------------------------------------------------------------------------------
local playerMeta = FindMetaTable("Player")
--------------------------------------------------------------------------------------------------------
function playerMeta:IsAFK()
    return self:getNetVar("afk")
end
--------------------------------------------------------------------------------------------------------
function playerMeta:IsAFKForLong()
    return self:getNetVar("superafk")
end
--------------------------------------------------------------------------------------------------------
function playerMeta:AFKTime()
    return SysTime() - (TimeStamp[self:UserID() or -1] or Now())
end
--------------------------------------------------------------------------------------------------------