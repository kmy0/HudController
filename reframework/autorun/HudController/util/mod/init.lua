local ace = require("HudController.data.ace")
local ace_misc = require("HudController.util.ace.misc")
local cache = require("HudController.util.misc.cache")
local config = require("HudController.config.init")
local e = require("HudController.util.game.enum")
local mod = require("HudController.data.mod")
local s = require("HudController.util.ref.singletons")
local util_game = require("HudController.util.game.init")
local util_misc = require("HudController.util.misc.init")
local util_ref = require("HudController.util.ref.init")
---@module "HudController.hud.play_object.init"
local play_object = util_misc.lazy_require("HudController.hud.play_object.init")

local this = {}

---@param cls_type string | app.GUIID.ID
---@return string
local function to_cls_name(cls_type)
    ---@type string
    local cls_name
    if type(cls_type) == "number" then
        cls_name = "app.G" .. e.get("app.GUIID.ID")[cls_type] --[[@as string]]
    else
        ---@cast cls_type string
        cls_name = cls_type
    end

    return cls_name
end

---@generic T
---@param type `T` app.GUIXXXXXX
---@return T
function this.get_gui_cls(type)
    return s.get("app.GUIManager"):getGUI(e.get("app.GUIID.ID")[string.sub(type, 6)])
end

---@param cls_type string | app.GUIID.ID
---@return via.gui.GUI
function this.get_component(cls_type)
    local cls = this.get_gui_cls(to_cls_name(cls_type)) --[[@as ace.GUIBase]]
    return ace_misc.get_gui_component(cls)
end

---@param cls_type string | app.GUIID.ID
---@return via.gui.Control
function this.get_root_window2(cls_type)
    local cls = this.get_gui_cls(to_cls_name(cls_type)) --[[@as ace.GUIBase]]
    return this.get_root_window(cls)
end

---@param hudid app.GUIHudDef.TYPE
---@return boolean
function this.is_enabled(hudid)
    local guiids = ace.map.hudid_to_guiid[hudid]
    for _, guiid in pairs(guiids) do
        local component = this.get_component(guiid)
        if component:get_Enabled() then
            return true
        end
    end

    return false
end

---@param ctrl via.gui.Control
---@return app.GUIID.ID
function this.get_gui_id(ctrl)
    local component = ctrl:get_Component()
    local game_object = component:get_GameObject()
    local name = game_object:get_Name()
    return e.get("app.GUIID.ID")[string.sub(name, 2)]
end

--- roundabout way o getting RootWindow, reframework 1208 cant read parent fields properly
---@param gui_base ace.GUIBase
---@return via.gui.Control
function this.get_root_window(gui_base)
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

---@param file_name string
---@return boolean
function this.is_ok_user_file(file_name)
    return not string.find(file_name, "example") and not string.match(file_name, "^_")
end

---@param dir string
---@return string[]
function this.get_user_files(dir)
    return fs.glob(util_misc.join_paths_b(config.name, dir, ".*lua"))
end

---@return app.cGUISystemModuleSystemInputOpenController.cGUISystemInputOpenCtrlPCShortcut
function this.get_pc_shortcut_input()
    ---@type app.cGUISystemModuleSystemInputOpenController.cGUISystemInputOpenCtrlPCShortcut
    local ret
    local system_input_ctrl = s.get("app.GUIManager")._SystemInputOpenCtrl

    util_game.do_something(system_input_ctrl._Ctrls, function(_, _, value)
        if
            util_ref.is_a(
                value,
                "app.cGUISystemModuleSystemInputOpenController.cGUISystemInputOpenCtrlPCShortcut"
            )
        then
            ---@cast value app.cGUISystemModuleSystemInputOpenController.cGUISystemInputOpenCtrlPCShortcut
            ret = value
            return false
        end
    end)

    return ret
end

---@param x number
---@param y number
---@return number, number
function this.to_offset(x, y)
    local screen_size = util_game.get_screen_size()
    return x * (1920 / screen_size.x), y * (1080 / screen_size.y)
end

---@param x number
---@param y number
---@return number, number
function this.from_offset(x, y)
    local screen_size = util_game.get_screen_size()
    return x * (screen_size.x / 1920), y * (screen_size.y / 1080)
end

---@return boolean
function this.is_draw_canvas()
    local config_mod = config.current.mod
    return config_mod.canvas.draw and config_mod.enabled and mod.is_ok()
end

this.get_root_window = cache.memoize(this.get_root_window)
this.get_hud_write_args = cache.memoize(this.get_hud_write_args)
this.get_pc_shortcut_input = cache.memoize(this.get_pc_shortcut_input)

return this
