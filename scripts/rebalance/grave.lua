local config_gravestone = GetModConfigData("gravestone")
local ghostflower_spawn_chance_percent = 1.0
if not config_gravestone then
    return
elseif config_gravestone == 1 then
    ghostflower_spawn_chance_percent = 0.5
elseif config_gravestone == 2 then
    ghostflower_spawn_chance_percent = 1.0
elseif config_gravestone == 3 then
    ghostflower_spawn_chance_percent = 1.5
end

GLOBAL.setmetatable(
    env,
    {
        __index = function(t, k)
            return GLOBAL.rawget(GLOBAL, k)
        end
    }
)

local DECORATED_GRAVESTONE_EVILFLOWER_TIME = (TUNING.WENDYSKILL_GRAVESTONE_DECORATETIME / TUNING.WENDYSKILL_GRAVESTONE_EVILFLOWERCOUNT)
local DECORATED_GRAVESTONE_GHOSTFLOWER_TIME = TUNING.WENDYSKILL_GRAVESTONE_DECORATETIME / 9

local function try_ghostflower(inst)
    local ghost_spawn_chance = TUNING.GHOST_GRAVESTONE_CHANCE
    for _, v in ipairs(AllPlayers) do
        if v:HasTag("ghostlyfriend") then
            ghost_spawn_chance = ghost_spawn_chance + TUNING.GHOST_GRAVESTONE_CHANCE

            if v.components.skilltreeupdater and v.components.skilltreeupdater:IsActivated("wendy_smallghost_1") then
                ghost_spawn_chance = ghost_spawn_chance + TUNING.WENDYSKILL_SMALLGHOST_EXTRACHANCE
            end
        end
    end

    local ghostflower_spawn_chance = (ghost_spawn_chance + 0.15) * ghostflower_spawn_chance_percent
    print("ghostflower spawn chance: " .. ghostflower_spawn_chance)
    if math.random() < ghostflower_spawn_chance then
        local angle = math.random(0, 359) * DEGREES
        local ix, iy, iz = inst.Transform:GetWorldPosition()
        local x_offset = (angle and math.cos(angle)) or 0
        local z_offset = (angle and math.sin(angle)) or 0
        local ghostflower = SpawnPrefab("ghostflower")
        ghostflower.Transform:SetPosition(ix + x_offset, iy, iz - z_offset)
        ghostflower:DelayedGrow()
    end
end

-- Upgrade (decorate)
local FLOWER_TAG = {"flower"}
local FLOWER_SPAWN_RADIUS = 1.5
local function try_evil_flower(inst)
    if TheWorld.state.iswinter then return end

    local ix, iy, iz = inst.Transform:GetWorldPosition()
    if TheSim:CountEntities(ix, iy, iz, 2 * FLOWER_SPAWN_RADIUS, FLOWER_TAG) < TUNING.WENDYSKILL_GRAVESTONE_EVILFLOWERCOUNT then
        local random_angle = PI2 * math.random()
        ix = ix + (FLOWER_SPAWN_RADIUS * math.cos(random_angle))
        iz = iz - (FLOWER_SPAWN_RADIUS * math.sin(random_angle))

        local evil_flower = SpawnPrefab("flower_evil")
        evil_flower.Transform:SetPosition(ix, iy, iz)
        SpawnPrefab("attune_out_fx").Transform:SetPosition(ix, iy, iz)
    end
end

local function initiate_flower_state(inst)
    inst.AnimState:Show("flower")

    -- We call this when loading, and our onload happens after the timer component,
    -- so we might have loaded a more correct one. It knows how to handle constructor-started
    -- timers, but not onload-started ones, sadly.
    if not inst.components.timer:TimerExists("petal_decay") then
        -- Currently just matching the perish rate of petals.
        inst.components.timer:StartTimer("petal_decay", TUNING.PERISH_FAST)
    end

    if not inst.components.timer:TimerExists("try_evil_flower") then
        inst.components.timer:StartTimer(
            "try_evil_flower", DECORATED_GRAVESTONE_EVILFLOWER_TIME * (1 + 0.5 * math.random())
        )
    end

    if not inst.components.timer:TimerExists("try_ghostflower") then
        inst.components.timer:StartTimer(
            "try_ghostflower", DECORATED_GRAVESTONE_GHOSTFLOWER_TIME * (0.5 + math.random())
        )
    end

    TheWorld.components.decoratedgrave_ghostmanager:RegisterDecoratedGrave(inst)
end

local function OnDecorated(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    SpawnPrefab("attune_out_fx").Transform:SetPosition(ix, iy, iz)

    initiate_flower_state(inst)
end

local function OnPetalAdded(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    SpawnPrefab("ghostflower_spirit1_fx").Transform:SetPosition(ix, iy, iz)
end

-- Timer
local function OnTimerDone(inst, data)
    if data.name == "petal_decay" then
        inst.components.timer:StopTimer("try_ghostflower")
    elseif data.name == "try_ghostflower" then
        try_ghostflower(inst)
        inst.components.timer:StartTimer(
            "try_ghostflower", DECORATED_GRAVESTONE_GHOSTFLOWER_TIME * (0.5 + math.random())
        )
    end
end

AddPrefabPostInit("gravestone", function(inst)
    if not TheWorld.ismastersim then return end

    if inst.components.upgradeable then
        inst.components.upgradeable.onstageadvancefn = OnDecorated
        -- inst.components.upgradeable:SetOnUpgradeFn(OnPetalAdded)
    end

    inst:ListenForEvent("timerdone", OnTimerDone)
end)