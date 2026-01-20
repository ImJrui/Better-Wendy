local config_ghostflowerhat = GetModConfigData("ghostflowerhat")
if not config_ghostflowerhat then return end

GLOBAL.setmetatable(
    env,
    {
        __index = function(t, k)
            return GLOBAL.rawget(GLOBAL, k)
        end
    }
)

AllRecipes["ghostflowerhat"].ingredients = {Ingredient("ghostflower", 6), Ingredient("pigskin", 1)}


