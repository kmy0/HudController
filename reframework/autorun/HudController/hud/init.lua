local e = require("HudController.util.game.enum")
local util_table = require("HudController.util.misc.table")

local this = {
    manager = require("HudController.hud.manager.init"),
    op = require("HudController.hud.manager.op.init"),
    options = require("HudController.hud.manager.options"),
    elements = require("HudController.hud.manager.elements"),
    profile_switcher = require("HudController.hud.manager.profile_switcher"),
}

---@param elements table<string, HudBaseConfig>
function this.update_elements(elements)
    this.elements.update_elements(elements)
end

function this.reset_elements()
    this.elements.reset_elements()
end

---@param option_name string
---@param option_value integer
function this.apply_option(option_name, option_value)
    this.options.apply_option(option_name, option_value)
end

---@param element string | app.GUIHudDef.TYPE
---@return HudBase?
function this.get_element(element)
    if type(element) == "string" then
        element = e.get("app.GUIHudDef.TYPE")[element]
    end

    if not element then
        return
    end

    return this.elements.by_hudid[element]
end

---@param element string | app.GUIHudDef.TYPE
---@return HudBaseConfig?
function this.get_element_config(element)
    local elem = this.get_element(element)
    if not elem then
        return
    end

    return elem:get_current_config()
end

---@param gui_id app.GUIID.ID
---@return HudBase?
function this.get_element_by_guiid(gui_id)
    return this.elements.by_guiid[gui_id]
end

---@param strict boolean?
---@return ModProfileConfig?
function this.get_current(strict)
    if
        not this.profile_switcher.current_hud
        or (
            strict
            and (
                not this.profile_switcher.current_hud.hud.elements
                or util_table.empty(this.profile_switcher.current_hud.hud.elements)
            )
        )
    then
        return
    end

    return this.profile_switcher.current_hud.hud
end

---@return boolean?
function this.get_hud_option(key)
    local current_hud = this.get_current()
    if not current_hud then
        return
    end

    local overridden = this.options.overridden_options[key]
    if overridden ~= nil then
        return overridden
    end

    return current_hud[key]
end

---@param key string
---@param new_value any
---@return any? -- changed value
function this.overwrite_hud_option(key, new_value)
    return this.options.overwrite_hud_option(key, new_value)
end

---@param key string
---@return any?
function this.get_overridden(key)
    return this.options.overridden_options[key]
end

function this.clear_overridden(key)
    this.options.clear_overridden(key)
end

---@param new_hud ModProfileConfig
---@param force boolean?
function this.request_hud_with_default(new_hud, force)
    this.profile_switcher.request_hud_with_default(new_hud, force)
end

---@param new_hud ModProfileConfig
---@param profile_bits integer[]
---@param force boolean?
function this.request_hud_with_profiles(new_hud, profile_bits, force)
    this.profile_switcher.request_hud_with_profiles(new_hud, profile_bits, force)
end

---@param new_hud ModProfileConfig
---@param profile_bits integer[]
function this.force_request_hud_with_profiles(new_hud, profile_bits)
    this.profile_switcher.request_hud_with_profiles(
        new_hud,
        profile_bits,
        this.manager.force_update
    )
    this.manager.force_update = false
end

function this.request_update()
    this.manager.request_update()
end

function this.clear()
    this.manager.clear()
end

function this.update()
    this.manager.update()
end

return this
