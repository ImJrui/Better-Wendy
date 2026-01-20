local config_blossom_sisturn = GetModConfigData("blossom_sisturn")
if not config_blossom_sisturn then return end

GLOBAL.setmetatable(
    env,
    {
        __index = function(t, k)
            return GLOBAL.rawget(GLOBAL, k)
        end
    }
)

local ABIGAIL_HEAL_RANGE = 8
local HEAL_AMOUNT_NOTEPIC = 0.01
local HEAL_AMOUNT_SMALLEPIC = 0.10
local HEAL_AMOUNT_EPIC = 0.33

local INVALID_EPIC_CREATURES =
{
    alterguardian_phase1 = true,
    alterguardian_phase2 = true,
}

local function CanBeHealed(inst)

    local blossoms = TheWorld.components.sisturnregistry and 
                     TheWorld.components.sisturnregistry:IsBlossom() or nil
    local evils = TheWorld.components.sisturnregistry and 
                  TheWorld.components.sisturnregistry:IsEvil() or nil
    local skilled = inst.components.follower and 
                    inst.components.follower.leader and 
                    inst.components.follower.leader.components.skilltreeupdater and 
                    inst.components.follower.leader.components.skilltreeupdater:IsActivated("wendy_sisturn_3") or nil
    local inworld = not inst:HasTag("INLIMBO") and (inst.sg and not inst.sg:HasStateTag("dissipate") ) or nil

    return not blossoms and evils and skilled and inworld
end

local function Heal_Amount(inst, ent)
    local max_health = inst.components.health.maxhealth
    local heal_amount = 0
    if ent:HasTag("epic") and not ent:HasTag("smallepic") and not INVALID_EPIC_CREATURES[ent.prefab] then
        heal_amount = max_health * HEAL_AMOUNT_EPIC
    elseif ent:HasTag("epic")then
        heal_amount = max_health * HEAL_AMOUNT_SMALLEPIC
    else
        heal_amount = max_health * HEAL_AMOUNT_NOTEPIC
    end
    return heal_amount
end

local function TryToHealAbigail(inst, data)
    -- print("tutu:CanBeHealed", CanBeHealed(inst))
    if not CanBeHealed(inst) then return end
    local ent = data.inst -- 获取死亡的实体
    -- 排除无效目标：自身、无生命组件、玩家、或已标记不处理的实体
    if ent and ent ~= inst and ent:IsValid() and ent.components.health and not ent:HasTag("player") then
        -- 计算与死亡实体的距离
        local dist_sq = inst:GetDistanceSqToInst(ent)
        -- print("tutu:dist"..dist_sq.."heal_range:" .. ABIGAIL_HEAL_RANGE)
        if dist_sq <= ABIGAIL_HEAL_RANGE then
            -- 计算治疗量并应用
            local heal_amount = Heal_Amount(inst, ent)
            inst.components.health:DoDelta(heal_amount, true, "heal_from_death")
        end
    end
end


AddPrefabPostInit("abigail", function (inst)
    if not TheWorld.ismastersim then
        return
    end

    inst.TryToHealAbigail = function(src, data) TryToHealAbigail(inst, data) end
    inst:ListenForEvent("entity_death", inst.TryToHealAbigail, TheWorld)
end)



