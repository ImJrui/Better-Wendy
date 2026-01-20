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


AddComponentPostInit("sisturnregistry", function(self)
    local inst = self.inst
    --Private
    local _sisturns = {}
    local _is_active = false
    local _is_blossom = false
    local _is_evil = false

    local function UpdateSisturnState()
        if POPULATING then
            if self.init_task == nil then
                self.init_task = self.inst:DoTaskInTime(0, function() UpdateSisturnState() self.init_task = nil end)
            end
            return
        end
        
        local is_active = false
        local is_blossom = false
        local is_evil = false
    
        for _, v in pairs(_sisturns) do
            if v then
                local getsisturnfeel = _:getsisturnfeel()
                if getsisturnfeel == "BLOSSOM" then
                    is_blossom = true
                elseif getsisturnfeel == "EVIL" then
                    is_evil = true
                end
                is_active = true
            end
        end
    
        if is_active ~= _is_active or is_blossom ~= _is_blossom or is_evil ~= _is_evil then
            _is_active = is_active
            _is_blossom = is_blossom
            _is_evil = is_evil
            -- TheWorld:PushEvent("onsisturnstatechanged", {is_active = is_active, is_blossom=is_blossom}) -- Wendy will be listening for this event
        end
    end

    local function OnRemoveSisturn(sisturn)
        if _sisturns[sisturn] ~= nil then
            _sisturns[sisturn] = nil
            inst:RemoveEventCallback("onremove", OnRemoveSisturn, sisturn)
            inst:RemoveEventCallback("onburnt", OnRemoveSisturn, sisturn)
        end
    
        UpdateSisturnState()
    end

    local function OnUpdateSisturnState(world, data)
        _sisturns[data.inst] = data.is_active == true
        UpdateSisturnState()
    end

    self.inst:ListenForEvent("ms_updatesisturnstate", OnUpdateSisturnState)

    -- function self:Register(sisturn)
    --     if sisturn ~= nil and _sisturns[sisturn] ~= nil then
    --         return
    --     end
    
    --     _sisturns[sisturn] = false
    
    --     inst:ListenForEvent("onremove", OnRemoveSisturn, sisturn)
    --     inst:ListenForEvent("onburnt", OnRemoveSisturn, sisturn)
    -- end

    function self:IsEvil()
        return _is_evil
    end
    
    -- 延迟初始化以等待世界加载完成
    self.inst:DoTaskInTime(0, UpdateSisturnState)
end)