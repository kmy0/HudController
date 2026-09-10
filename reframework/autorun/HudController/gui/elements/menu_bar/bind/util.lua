local config = require("HudController.config.init")
local mod = require("HudController.data.mod")
local operations = require("HudController.hud.manager.operations")
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

---@param opt string
---@return string
function this.get_option_hud_bind_name(opt)
    return config.lang:tr("hud." .. mod.map.options_hud[opt])
end

---@param opt string
---@return string
function this.get_option_mod_bind_name(opt)
    return config.lang:tr("menu.config." .. mod.map.options_mod[opt])
end

---@param opt {hud: integer, profile: integer}
---@return string
function this.get_hud_bind_name(opt)
    local hud_profile = operations.get_hud_by_key(opt.hud)
    local name = hud_profile.name

    if opt.profile ~= 0 then
        name = string.format("%s | %s", name, this.elem_profiles_to_name(hud_profile, opt.profile))
    end

    return name
end

return this
