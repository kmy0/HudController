-- Disable Hide Monster Icon when map is open

local hook_common = require("HudController.hud.hook.common")
local hud = require("HudController.hud.init")
local util_ace = require("HudController.util.ace.init")

re.on_frame(function()
    local hud_config = hook_common.get_hud()
    if hud_config and hud_config.hide_monster_icon then
        local map_open = util_ace.misc.is_map_open()
        if map_open and hud.get_hud_option("hide_monster_icon") then
            hud.overwrite_hud_option("hide_monster_icon", false)
        elseif not map_open and not hud.get_overridden("hide_monster_icon") then
            hud.manager.overridden_options["hide_monster_icon"] = nil
        end
    end
end)
