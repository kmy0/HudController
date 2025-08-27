-- Disable Hide Monster Icon when map is open

local cache = require("HudController.util.misc.cache")
local hook_common = require("HudController.hud.hook.common")
local hud = require("HudController.hud")
local s = require("HudController.util.ref.singletons")

---@return via.gui.GUI?
local function get_map()
    local map3d = s.get("app.GUIManager"):get_MAP3D()
    local GUI060000 = map3d:get_GUIFront()
    return GUI060000._GUI
end

---@return boolean
local function is_map_open()
    local map = get_map()
    if not map then
        return false
    end

    return map:get_Enabled()
end

re.on_frame(function()
    local hud_config = hook_common.get_hud()
    if hud_config and hud_config.hide_monster_icon then
        local map_open = is_map_open()
        if map_open and hud.get_hud_option("hide_monster_icon") then
            hud.overwrite_hud_option("hide_monster_icon", false)
        elseif not map_open and not hud.get_overridden("hide_monster_icon") then
            hud.manager.overridden_options["hide_monster_icon"] = nil
        end
    end
end)

get_map = cache.memoize(get_map)
