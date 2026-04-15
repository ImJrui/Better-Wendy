local PLENV = env
GLOBAL.setfenv(1, GLOBAL)

ToolUtil = {}
PLENV.ToolUtil = ToolUtil

---@param t table
function ToolUtil.IsArray(t)
    if type(t) ~= "table" or not next(t) then
        return false
    end

    local n = #t
    for i, v in pairs(t) do
        if type(i) ~= "number" or i <= 0 or i > n then
            return false
        end
    end

    return true
end

---@param target table
---@param add_table table
---@param override boolean
function ToolUtil.MergeTable(target, add_table, override)
    target = target or {}

    for k, v in pairs(add_table) do
        if type(v) == "table" then
            if not target[k] then
                target[k] = {}
            elseif type(target[k]) ~= "table" then
                if override then
                    target[k] = {}
                else
                    error("Can not override" .. k .. " to a table")
                end
            end

            ToolUtil.MergeTable(target[k], v, override)
        else
            if ToolUtil.IsArray and not override then
                table.insert(target, v)
            elseif not target[k] or override then
                target[k] = v
            end
        end
    end
end
