local config_moondial = GetModConfigData("moondial")
if not config_moondial then return end

GLOBAL.setmetatable(
    env,
    {
        __index = function(t, k)
            return GLOBAL.rawget(GLOBAL, k)
        end
    }
)


local function domutatefn(inst,doer)
    if TheWorld:HasTag("cave") then
        return false, "CAVE"
    end

    local ghostlybond = doer.components.ghostlybond

    if ghostlybond == nil or ghostlybond.ghost == nil or not ghostlybond.summoned then
        return false, "NOGHOST"

    elseif not TheWorld.state.isnight then
        return false, "NOTNIGHT"

    elseif ghostlybond.ghost:HasTag("gestalt") then
        ghostlybond.ghost:ChangeToGestalt(false)
    else
        ghostlybond.ghost:ChangeToGestalt(true)
    end

    return true
end

AddPrefabPostInit("moondial", function(inst)
    if not TheWorld.ismastersim then return end

    if not inst.components.ghostgestalter then
        inst:AddComponent("ghostgestalter")
    end
    inst.components.ghostgestalter.forcerightclickaction = true
    inst.components.ghostgestalter.domutatefn = domutatefn 
end)
