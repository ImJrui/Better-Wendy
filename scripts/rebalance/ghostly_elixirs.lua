local config_evil_sisturn = GetModConfigData("evil_sisturn")
if not config_evil_sisturn then return end

GLOBAL.setmetatable(
    env,
    {
        __index = function(t, k)
            return GLOBAL.rawget(GLOBAL, k)
        end
    }
)

AddPrefabPostInit("ghostlyelixir_slowregen_buff", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    inst.potion_tunings.TICK_FN = function(inst, target)
        -- local mult = 1
        target.components.health:DoDelta(TUNING.GHOSTLYELIXIR_SLOWREGEN_HEALING, true, inst.prefab)
    end
end)

AddPrefabPostInit("ghostlyelixir_fastregen_buff", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    inst.potion_tunings.TICK_FN = function(inst, target)
        -- local mult = 1
        target.components.health:DoDelta(TUNING.GHOSTLYELIXIR_FASTREGEN_HEALING, true, inst.prefab)
    end
end)

