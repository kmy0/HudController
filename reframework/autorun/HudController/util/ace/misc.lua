---@class AceMiscUtil
---@field cache table<string, any>

local s = require("HudController.util.ref.singletons")

---@class AceMiscUtil
local this = {
    cache = {},
}

---@return app.cGUIHudDisplayManager
function this.get_hud_manager()
    if not this.cache.hud_manager then
        this.cache.hud_manager = s.get("app.GUIManager"):get_HudDisplayManager()
    end
    return this.cache.hud_manager
end

---@return ace.cPadInfo
function this.get_pad()
    if not this.cache.pad then
        this.cache.pad = s.get("ace.PadManager"):get_MainPad()
    end

    return this.cache.pad
end

---@return ace.cMouseKeyboardInfo
function this.get_kb()
    if not this.cache.kb then
        this.cache.kb = s.get("ace.MouseKeyboardManager"):get_MainMouseKeyboard()
    end

    return this.cache.kb
end

---@param message string
function this.send_message(message)
    s.get("app.ChatManager"):addSystemLog(message)
end

---@return boolean
function this.is_multiplayer()
    return s.get("app.PlayerManager"):get_InstancedPlayerNum() > 1
end

return this
