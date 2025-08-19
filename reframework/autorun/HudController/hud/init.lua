local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

local this = {
    manager = require("HudController.hud.manager"),
    operations = require("HudController.hud.operations"),
}

---@param elements table<string, HudBaseConfig>
function this.update_elements(elements)
    this.manager.update_elements(elements)
end

function this.reset_elements()
    this.manager.reset_elements()
end

---@param option_name string
---@param option_value integer
function this.apply_option(option_name, option_value)
    this.manager.apply_option(option_name, option_value)
end

---@param element string | app.GUIHudDef.TYPE
---@return HudBase?
function this.get_element(element)
    if type(element) == "string" then
        element = rl(ace_enum.hud, element)
    end

    if not element then
        return
    end

    return this.manager.by_hudid[element]
end

---@param gui_id app.GUIID.ID
---@return HudBase?
function this.get_element_by_guiid(gui_id)
    return this.manager.by_guiid[gui_id]
end

---@param strict boolean?
---@return HudProfileConfig?
function this.get_current(strict)
    if
        not this.manager.current_hud
        or (strict and (not this.manager.current_hud.elements or util_table.empty(this.manager.current_hud.elements)))
    then
        return
    end

    return this.manager.current_hud
end

---@return boolean?
function this.get_hud_option(key)
    local current_hud = this.get_current()
    if not current_hud then
        return
    end

    local overridden = this.manager.overridden_options[key]
    if overridden ~= nil then
        return overridden
    end

    return current_hud[key]
end

---@param key string
---@param new_value boolean? nil for toggle
---@return boolean? -- changed value
function this.overwrite_hud_option(key, new_value)
    local current_hud = this.get_current()
    if not current_hud then
        return
    end

    if new_value == nil then
        if this.manager.overridden_options[key] ~= nil then
            this.manager.overridden_options[key] = not this.manager.overridden_options[key]
        else
            this.manager.overridden_options[key] = not current_hud[key]
        end
    else
        if this.manager.overridden_options[key] ~= new_value then
            this.manager.overridden_options[key] = new_value
        else
            return
        end
    end

    local func = this.manager.overridden_options_func[key]
    if func then
        func(key, this.manager.overridden_options[key])
    end

    return this.manager.overridden_options[key]
end

---@param key string
---@return boolean?
function this.get_overridden(key)
    return this.manager.overridden_options[key]
end

function this.clear_overridden(key)
    this.manager.overridden_options[key] = nil
end

---@param new_hud HudProfileConfig
---@param force boolean?
function this.request_hud(new_hud, force)
    this.manager.request_hud(new_hud, force)
end

function this.clear()
    this.manager.clear()
end

function this.update()
    this.manager.update()
end

return this
