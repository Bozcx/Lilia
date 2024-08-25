﻿local GM = GM or GAMEMODE
function GM:PlayerSay(client, message)
    local chatType, message, anonymous = lia.chat.parse(client, message, true)
    if (chatType == "ic") and lia.command.parse(client, message) then return "" end
    if utf8.len(message) <= lia.config.MaxChatLength then
        local isOOC = chatType == "ooc"
        local isLOOC = chatType == "looc"
        lia.chat.send(client, chatType, message, anonymous)
        local logType
        if isOOC then
            logType = "chatOOC"
            lia.log.add(client, logType, message)
        elseif isLOOC then
            logType = "chatLOOC"
            lia.log.add(client, logType, message)
        else
            logType = "chat"
            lia.log.add(client, logType, chatType and chatType:upper() or "??", message)
        end

        hook.Run("PostPlayerSay", client, message, chatType, anonymous)
    else
        client:notify("Your message is too long and has not been sent.")
    end
    return ""
end

function GM:EntityTakeDamage(entity, dmgInfo)
    if IsValid(entity.liaPlayer) then
        if dmgInfo:IsDamageType(DMG_CRUSH) then
            if (entity.liaFallGrace or 0) < CurTime() then
                if dmgInfo:GetDamage() <= 10 then dmgInfo:SetDamage(0) end
                entity.liaFallGrace = CurTime() + 0.5
            else
                return
            end
        end

        entity.liaPlayer:TakeDamageInfo(dmgInfo)
    end
end

function GM:KeyPress(client, key)
    if key == IN_USE then
        local trace = util.TraceLine({
            start = client:GetShootPos(),
            endpos = client:GetShootPos() + client:GetAimVector() * 96,
            filter = client
        })

        local entity = trace.Entity
        if IsValid(entity) and (entity:isDoor() or entity:IsPlayer()) then hook.Run("PlayerUse", client, entity) end
    elseif key == IN_JUMP then
        local traceStart = client:GetShootPos() + Vector(0, 0, 15)
        local traceEndHi = traceStart + client:GetAimVector() * 30
        local traceEndLo = traceStart + client:GetAimVector() * 30
        local trHi = util.TraceLine({
            start = traceStart,
            endpos = traceEndHi,
            filter = client
        })

        local trLo = util.TraceLine({
            start = client:GetShootPos(),
            endpos = traceEndLo,
            filter = client
        })

        if trLo.Hit and not trHi.Hit then
            local dist = math.abs(trHi.HitPos.z - client:GetPos().z)
            client:SetVelocity(Vector(0, 0, 50 + dist * 3))
        end
    end
end

function GM:EntityNetworkedVarChanged(entity, varName, _, newVal)
    if varName == "Model" and entity.SetModel then hook.Run("PlayerModelChanged", entity, newVal) end
end

function GM:GetPreferredCarryAngles(entity)
    if entity.preferedAngle then return entity.preferedAngle end
    local class = entity:GetClass()
    if class == "lia_item" then
        local itemTable = entity:getItemTable()
        if itemTable then
            local preferedAngle = itemTable.preferedAngle
            if preferedAngle then return preferedAngle end
        end
    end
end

function GM:InitializedSchema()
    local persistString = GetConVar("sbox_persist"):GetString()
    if persistString == "" or string.StartWith(persistString, "lia_") then
        local newValue = "lia_" .. SCHEMA.folder
        game.ConsoleCommand("sbox_persist " .. newValue .. "\n")
    end
end

function GM:GetGameDescription()
    return (lia.config.GamemodeName == "A Lilia Gamemode" and istable(SCHEMA)) and tostring(SCHEMA.name) or lia.config.GamemodeName
end

function GM:PlayerSpray()
    return true
end

function GM:PlayerDeathSound()
    return true
end

function GM:CanPlayerSuicide()
    return false
end

function GM:AllowPlayerPickup()
    return false
end

function GM:PlayerDeathThink(client)
    if client:getChar() and not client:IsOnDeathTimer() then client:Spawn() end
    return false
end

function GM:PlayerShouldTakeDamage(client)
    return client:getChar() ~= nil
end

function GM:CanDrive(client)
    if not client:IsSuperAdmin() then return false end
end

function GM:Think()
    if (self.NextDBRefresh or 0) < CurTime() then
        lia.db.query("SELECT 1 + 1", onSuccess)
        self.NextDBRefresh = CurTime() + 10
    end
end
