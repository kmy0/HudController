---@class GuiConditionKeyManager : GuiKeyManagerBase
---@field manager ModBindManager

local base = require("HudController.gui.elements.menu_bar.bind.key.managers.base")
local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local op = require("HudController.hud.manager.op.init")
local util_imgui = require("HudController.util.imgui.init")

---@class GuiConditionKeyManager
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = base })

---@param manager ModBindManager
---@param config_key string
---@return GuiConditionKeyManager
function this:new(manager, config_key)
    local o = base.new(self, manager, config_key)
    setmetatable(o, self)
    ---@cast o GuiConditionKeyManager
    return o
end

---@return boolean
function this:draw_target()
    util_imgui.begin_disabled(true)
    imgui.combo("##bind_target_combo")
    util_imgui.end_disabled()
    return false
end

function this:draw_action()
    util_imgui.begin_disabled(true)
    base.draw_action(self)
    util_imgui.end_disabled()
    return false
end

function this:draw_trigger()
    util_imgui.begin_disabled(true)
    base.draw_trigger(self)
    util_imgui.end_disabled()
    return false
end

---@param set_default boolean?
---@return ModBind
function this:make_base_bind(set_default)
    if set_default then
        config:set("__temp.option_value", 0)
        config:set("__temp.combo_trigger_type", cd.combo.bind_trigger_type:get_index("REPEAT"))
        config:set("__temp.combo_action_type", cd.combo.bind_action_type:get_index("SET"))
    end

    self.base_bind = {
        action_type = cd.combo.bind_action_type:get_key(config:get("__temp.combo_action_type")),
        trigger_repeat = cd.combo.bind_trigger_type:get_key(
            config:get("__temp.combo_trigger_type")
        ) == "REPEAT",
    }

    ---@diagnostic disable-next-line: return-type-mismatch
    return self.base_bind
end

---@param bind ModBind<integer, any>
---@return string
function this:get_bind_name(bind)
    if bind.invalid then
        return config.lang:tr("misc.text_unknown")
    end

    return ""
end

---@param bind_base ModBindBase
function this:register(bind_base)
    base.register(self, bind_base)
    op.bind.check_condition_key_bind(bind_base, false)
end

---@param bind ModBind
function this:unregister(bind)
    op.bind.check_condition_key_bind(bind, true)
    base.unregister(self, bind)
end

return this
