local config_skill_connects = GetModConfigData("skill_connects")
if not config_skill_connects then return end

GLOBAL.setmetatable(
    env,
    {
        __index = function(t, k)
            return GLOBAL.rawget(GLOBAL, k)
        end
    }
)

local skilltree_defs = require("prefabs/skilltree_defs")

local skills = {
    "wendy_ghostflower_butterfly",
    "wendy_ghostflower_hat",
    "wendy_gravestone_1",
}

for _,skill in ipairs(skills) do
    local connects = skilltree_defs.SKILLTREE_DEFS["wendy"][skill].connects or {}
    if connects then
        for _,connect in ipairs(connects) do
            skilltree_defs.SKILLTREE_DEFS["wendy"][connect].root = true
            skilltree_defs.SKILLTREE_DEFS["wendy"][connect].must_have_one_of = nil
        end
        connects = {}
    end
end