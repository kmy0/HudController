local config = require("HudController.config.init")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local factory = require("HudController.hud.factory")
local hud_elements = require("HudController.hud.manager.elements")

local ace_map = data.ace.map

local this = {}

---@param name_key string
function this.add_element(name_key)
    local hud_profile = config.current.mod.hud[config.current.mod.combo.hud]
    hud_profile.elements = hud_profile.elements or {}

    if hud_profile.elements[name_key] then
        return
    end

    local key = 1
    for _, elem in pairs(hud_profile.elements) do
        key = math.max(key, elem.key + 1)
    end

    local hud_elem = factory.get_config(e.get("app.GUIHudDef.TYPE")[name_key])
    hud_elem.key = key

    hud_profile.elements[name_key] = hud_elem
    hud_elements.update_elements(hud_profile.elements)
end

---@param elements HudBaseConfig[]
---@param reverse boolean
function this.sort_elements(elements, reverse)
    table.sort(elements, function(a, b)
        if reverse then
            return this.tr_element(a) < this.tr_element(b)
        end
        return this.tr_element(a) > this.tr_element(b)
    end)
    for i, elem in ipairs(elements) do
        elem.key = i
    end
end

---@param element HudBaseConfig
function this.tr_element(element)
    local name = ace_map.hudid_name_to_local_name[element.name_key]
    if name == ace_map.tr_flag then
        name = config.lang:tr("hud_element.name." .. element.name_key)
    end
    return name
end

---@param elem HudBase
---@return boolean
function this.is_current_profile(elem)
    local root = elem:get_root()
    local root_config = root:get_current_config()
    return root_config.current_profile == root_config.current_profile_gui
end

return this
