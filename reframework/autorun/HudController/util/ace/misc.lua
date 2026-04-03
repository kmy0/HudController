local cache = require("HudController.util.misc.cache")
local frame_cache = require("HudController.util.misc.frame_cache")
local s = require("HudController.util.ref.singletons")
local util_ref = require("HudController.util.ref.init")

---@class AceMiscUtil
local this = {}

local function get_map_component()
    local map3d = s.get("app.GUIManager"):get_MAP3D()
    local GUI060000 = map3d:get_GUIFront()
    return this.get_gui_component(GUI060000)
end

---@return app.cGUIHudDisplayManager
function this.get_hud_manager()
    return s.get("app.GUIManager"):get_HudDisplayManager()
end

---@return ace.cPadInfo
function this.get_pad()
    return s.get("ace.PadManager"):get_MainPad()
end

---@return ace.cMouseKeyboardInfo
function this.get_kb()
    return s.get("ace.MouseKeyboardManager"):get_MainMouseKeyboard()
end

---@param message string
function this.send_message(message)
    s.get("app.ChatManager"):addSystemLog(message)
end

---@return boolean
function this.is_multiplayer()
    return s.get("app.PlayerManager"):get_InstancedPlayerNum() > 1
end

---@return boolean
function this.is_map_open()
    local map = get_map_component()
    if not map then
        return false
    end

    return map:get_Enabled()
end

---@param gui_base ace.GUIBase
---@return via.gui.GUI
function this.get_gui_component(gui_base)
    local gui_ctrl = gui_base:get_GUIController()
    return gui_ctrl:get_Component()
end

---@return boolean
function this.is_title_request()
    local request = s.get("ace.GameFlowManagerBase")._CurrentRequest
    return request and util_ref.is_a(request:get_NextGameState(), "app.TitleState") or false
end

get_map_component = cache.memoize(get_map_component)
this.get_hud_manager = cache.memoize(this.get_hud_manager)
this.get_pad = cache.memoize(this.get_pad)
this.get_kb = cache.memoize(this.get_kb)
this.get_gui_component = cache.memoize(this.get_gui_component)
this.is_map_open = frame_cache.memoize(this.is_map_open)

return this
