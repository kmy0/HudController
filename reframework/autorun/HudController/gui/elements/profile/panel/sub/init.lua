local data = require("HudController.data.init")

local mod = data.mod
local this = {}

---@type table<HudSubType, fun(elem: HudBase, elem_config: HudBaseConfig, config_key: string)>
local funcs = {
    [mod.enum.hud_sub_type.MATERIAL] = require(
        "HudController.gui.elements.profile.panel.sub.material"
    ),
    [mod.enum.hud_sub_type.SCALE9] = require("HudController.gui.elements.profile.panel.sub.scale9"),
    [mod.enum.hud_sub_type.TEXT] = require("HudController.gui.elements.profile.panel.sub.text"),
    [mod.enum.hud_sub_type.DAMAGE_NUMBERS] = require(
        "HudController.gui.elements.profile.panel.sub.damage_numbers"
    ),
    [mod.enum.hud_sub_type.CTRL_CHILD] = require(
        "HudController.gui.elements.profile.panel.sub.control_child"
    ),
    [mod.enum.hud_sub_type.PROGRESS_TEXT] = require(
        "HudController.gui.elements.profile.panel.sub.progress_text"
    ),
    [mod.enum.hud_sub_type.PROGRESS_PART] = require(
        "HudController.gui.elements.profile.panel.sub.progress_part"
    ),
}

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
function this.draw(elem, elem_config, config_key)
    local fn = funcs[
        elem_config.hud_sub_type --[[@as HudSubType]]
    ]
    if fn then
        fn(elem, elem_config, config_key)
    end
end

return this
