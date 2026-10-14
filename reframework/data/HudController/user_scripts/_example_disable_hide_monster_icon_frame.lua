-- Disable Hide Monster Icon when map is open

local config = require("HudController.config.init")
local def = require("HudController.data.option.hud")
local hook_common = require("HudController.hud.hook.common")
local hud = require("HudController.hud.init")
local mod = require("HudController.data.mod")
local user_opt = require("HudController.hud.user.option")
local util_ace = require("HudController.util.ace.init")

---@type UserOption
local opt = {
    name = "my_name:my_opt", -- do not use dots here
    label = "Option Label",
    default = false,
    bindable = true,
    draw = function(self, label, config_key)
        local changed, value = imgui.checkbox(label, config:get(config_key))
        if changed then
            config:set(config_key, value)
        end

        return changed
    end,
    format = function(self, value)
        return tostring(value)
    end,
}

user_opt.register_hud(opt)

re.on_frame(function()
    local hud_config = hook_common.get_hud()

    if hud_config and hud_config.monster_icon ~= mod.enum.em_icon.DISABLED then
        local map_open = util_ace.misc.is_map_open()

        if map_open and hud.get_hud_option(def.opt.monster_icon) ~= mod.enum.em_icon.DISABLED then
            hud.overwrite_hud_option(def.opt.monster_icon.key, mod.enum.em_icon.DISABLED)
        elseif
            not map_open
            and hud.get_overridden(def.opt.monster_icon.key) == mod.enum.em_icon.DISABLED
        then
            hud.clear_overridden(def.opt.monster_icon.key)
        end
    end
end)
