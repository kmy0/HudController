local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local this = {}

---@param hud_config ModProfileConfig
---@param bits integer
---@return string
function this.elem_profiles_to_name(hud_config, bits)
    local elem_profile_keys = util_misc.unpack_bits(bits)
    ---@type string[]
    local names = {}
    for _, key in ipairs(elem_profile_keys) do
        local profile = util_table.find_value(hud_config.profile, function(_, value)
            return value.key == key
        end) --[[@as HudBaseConfigProfileForShow]]
        if profile then
            table.insert(names, profile.name)
        end
    end

    return table.concat(names, ", ")
end

return this
