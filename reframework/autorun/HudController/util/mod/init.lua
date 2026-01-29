local ace_misc = require("HudController.util.ace.misc")
local cache = require("HudController.util.misc.cache")
local data = require("HudController.data.init")
local game_data = require("HudController.util.game.data")
---@module "HudController.hud.play_object.init"
local play_object
local s = require("HudController.util.ref.singletons")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

local this = {}

---@generic T
---@param type `T` app.GUIXXXXXX
---@return T
function this.get_gui_cls(type)
    return s.get("app.GUIManager"):getGUI(rl(ace_enum.gui_id, string.sub(type, 6)))
end

--- roundabout way o getting RootWindow, reframework 1208 cant read parent fields properly
---@param gui_base ace.GUIBase
---@return via.gui.Control
function this.get_root_window(gui_base)
    if not play_object then
        play_object = require("HudController.hud.play_object.init")
    end

    local gui = ace_misc.get_gui_component(gui_base)
    return play_object.control.get(gui:get_View(), "RootWindow") --[[@as via.gui.Control]]
end

---@param type string app.GUIXXXXXX
---@return [app.GUIHudBase, app.GUIID.ID, via.gui.Control]?
function this.get_hud_write_args(type)
    local cls = this.get_gui_cls(type) --[[@as app.GUIHudBase]]

    if not cls then
        return
    end

    local disp_ctrl = cls._DisplayControl
    local gui_id = cls:get_ID()
    return { cls, gui_id, disp_ctrl._TargetControl }
end

this.get_root_window = cache.memoize(this.get_root_window)
this.get_hud_write_args = cache.memoize(this.get_hud_write_args)

return this
