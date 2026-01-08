local cache = require("HudController.util.misc.cache")
local frame_cache = require("HudController.util.misc.frame_cache")
local s = require("HudController.util.ref.singletons")

---@class AceMiscUtil
local this = {}

local function get_map_component()
    local map3d = s.get("app.GUIManager"):get_MAP3D()
    local GUI060000 = map3d:get_GUIFront()
    local gui_ctrl = GUI060000:get_GUIController()
    return gui_ctrl:get_Component()
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

get_map_component = cache.memoize(get_map_component)
this.get_hud_manager = cache.memoize(this.get_hud_manager)
this.get_pad = cache.memoize(this.get_pad)
this.get_kb = cache.memoize(this.get_kb)
this.is_map_open = frame_cache.memoize(this.is_map_open)

return this
