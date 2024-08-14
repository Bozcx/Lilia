﻿function MODULE:SaveData()
    local data = {}
    for _, v in ents.Iterator() do
        if v:IsLiliaPersistent() then
            data[#data + 1] = {
                pos = v:GetPos(),
                class = v:GetClass(),
                model = v:GetModel(),
                angles = v:GetAngles(),
            }
        end
    end

    self:setData(data)
end

local function IsEntityNearby(pos, class)
    for _, ent in ipairs(ents.FindByClass(class)) do
        if ent:GetPos():Distance(pos) <= 50 then return true end
    end
    return false
end

function MODULE:LoadData()
    for _, v in pairs(self:getData() or {}) do
        if not IsEntityNearby(v.pos, v.class) then
            local ent = ents.Create(v.class)
            if IsValid(ent) then
                if v.pos then ent:SetPos(v.pos) end
                if v.angles then ent:SetAngles(v.angles) end
                if v.model then ent:SetModel(v.model) end
                ent:Spawn()
                ent:Activate()
            end
        end
    end
end
