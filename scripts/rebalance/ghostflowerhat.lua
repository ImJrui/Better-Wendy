local config_ghostflowerhat = GetModConfigData("ghostflowerhat")
if not config_ghostflowerhat then
    return
elseif config_ghostflowerhat == 1 then
    TUNING.ARMOR_GHOSTFLOWERHAT_ABSORPTION = 0.7
elseif config_ghostflowerhat == 2 then
    TUNING.ARMOR_GHOSTFLOWERHAT_ABSORPTION = 0.8
elseif config_ghostflowerhat == 3 then
    TUNING.ARMOR_GHOSTFLOWERHAT_ABSORPTION = 0.8
    TUNING.ARMOR_GHOSTFLOWERHAT_PLANAR_DEF = 5
end

GLOBAL.setmetatable(
    env,
    {
        __index = function(t, k)
            return GLOBAL.rawget(GLOBAL, k)
        end
    }
)

FORGEMATERIALS.GHOSTFLOWER = "ghostflower"
local GHOSTFLOWERHAT_PERISH_PERIOD = 16

local function IsInElixirContainer(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner or nil
    if owner and owner.prefab == "elixir_container" then
        -- print("tutu:in elixir container")
        return true
    end
    return false
end
local function DoPerish(inst)
    inst._perishcount = inst._perishcount + 1
    -- print("tutu:_perishcount", inst._perishcount)
    if inst._perishcount >= GHOSTFLOWERHAT_PERISH_PERIOD then
        if inst.components.armor then
            inst.components.armor:TakeDamage(1)
        end
        inst._perishcount = 0
    end
end

local function GhostFlowerHatTask(inst)
    if inst.debuff then
        inst.debuff.duration = inst.debuff.duration - 1
        if inst.debuff.duration <= 0 then
            inst.debuff = nil
            -- print("tutu:debuff end")
        end
    end

    if not IsInElixirContainer(inst) then
        DoPerish(inst)
    end
end

local function DoApplyElixir(inst, giver, target)
    -- print("tutu:ApplyElixir,GetTimeLeft",inst.debuff.duration)
	local buff_type = "elixir_buff"

	-- if inst.potion_tunings.super_elixir then
	-- 	buff_type = "super_elixir_buff"
	-- end

	local buff = target:AddDebuff(buff_type, inst.debuff.prefab, nil, nil, function()
		local cur_buff = target:GetDebuff(buff_type)
		if cur_buff ~= nil and cur_buff.prefab ~= inst.debuff.prefab then
			target:RemoveDebuff(buff_type)
		end
	end)

	if buff then
		local new_buff = target:GetDebuff(buff_type)
		new_buff:buff_skill_modifier_fn(giver, target)
        new_buff.components.timer:StopTimer("decay")
        new_buff.components.timer:StartTimer("decay", inst.debuff.duration)
		return buff
	end
    
    inst.debuff = nil
end

local function ghostflower_onequip(inst, owner)
    if inst.debuff and inst.debuff.duration then
        DoApplyElixir(inst, owner, owner)
    end
    if inst._onequip ~= nil then
        inst:_onequip(owner)
    end
end

local function ghostflower_onunequip(inst, owner)
    local debuff = owner:GetDebuff("elixir_buff")
    local duration = debuff and math.floor(debuff.components.timer:GetTimeLeft("decay")) or 0
    -- print("tutu:On Save Elixir GetTimeLeft",duration)
    if duration > 0 then
        inst.debuff = {
            prefab = debuff.prefab,
            duration = duration,
        }
    else
        inst.debuff = nil
    end

    if inst._onunequip ~= nil then
        inst:_onunequip(owner)
    end
end

AddPrefabPostInit("ghostflowerhat", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    if inst.components.perishable then
        inst:RemoveComponent("perishable")
    end

    if not inst.components.armor then
        inst:AddComponent("armor")
    end
    inst.components.armor:InitCondition(TUNING.ARMOR_FOOTBALLHAT, TUNING.ARMOR_GHOSTFLOWERHAT_ABSORPTION)

    if config_ghostflowerhat == 3 then
        if not inst.components.planardefense then
            inst:AddComponent("planardefense")
        end
        inst.components.planardefense:SetBaseDefense(TUNING.ARMOR_GHOSTFLOWERHAT_PLANAR_DEF)
    end

    inst:AddComponent("forgerepairable")
	inst.components.forgerepairable:SetRepairMaterial(FORGEMATERIALS.GHOSTFLOWER)
	-- inst.components.forgerepairable:SetOnRepaired(OnRepaired)

    if not inst.components.equippable then
        inst:AddComponent("equippable")
    end
    inst._onequip = inst.components.equippable.onequipfn
    inst._onunequip = inst.components.equippable.onunequipfn
    inst.components.equippable:SetOnEquip(ghostflower_onequip)
    inst.components.equippable:SetOnUnequip(ghostflower_onunequip)

    -- 启动周期性耐久衰减
    inst._perishcount = 0
    inst._task = inst:DoPeriodicTask(1, GhostFlowerHatTask)

    -- 确保任务安全回收
    inst:ListenForEvent("onremove", function()
        if inst._task then
            inst._task:Cancel()
            inst._task = nil
        end
    end)

    local _OnSave = inst.OnSave or function () end
    inst.OnSave = function (inst, data)
        if inst.debuff ~= nil then
            data.debuff = {}
            for k, v in pairs(inst.debuff) do
                data.debuff[k] = v
            end
        end
        data._perishcount = inst._perishcount or 0
        return _OnSave(inst, data)
    end

    local _OnLoad = inst.OnLoad or function () end
    inst.OnLoad = function (inst, data)
        if data and data.debuff ~= nil then
            inst.debuff = {}
            for k, v in pairs(data.debuff) do
                inst.debuff[k] = v
            end
        end
        inst._perishcount = data._perishcount or 0
        return _OnLoad(inst, data)
    end
end)

local function _OnRepaired(inst, target, doer)
	doer:PushEvent("repair")
end

AddPrefabPostInit("ghostflower", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    inst:AddComponent("forgerepair")
    inst.components.forgerepair:SetRepairMaterial(FORGEMATERIALS.GHOSTFLOWER)
    inst.components.forgerepair:SetOnRepaired(_OnRepaired)
end)

---------------------------------------------------
local containers = require("containers")
local params = containers.params
local _itemtestfn = params.elixir_container.itemtestfn

function params.elixir_container.itemtestfn(container, item, slot)
    return item.prefab == "ghostflowerhat" or _itemtestfn(container, item, slot)
end

