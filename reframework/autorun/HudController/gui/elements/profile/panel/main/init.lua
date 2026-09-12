local data = require("HudController.data.init")

local mod = data.mod
local this = {}

---@type table<HudType, fun(elem: HudBase, elem_config: HudBaseConfig, config_key: string)>
local funcs = {
    [mod.enum.hud_type.WEAPON] = require("HudController.gui.elements.profile.panel.main.weapon"),
    [mod.enum.hud_type.ITEMBAR] = require("HudController.gui.elements.profile.panel.main.itembar"),
    [mod.enum.hud_type.NOTICE] = require("HudController.gui.elements.profile.panel.main.notice"),
    [mod.enum.hud_type.NAME_ACCESS] = require(
        "HudController.gui.elements.profile.panel.main.name_access"
    ),
    [mod.enum.hud_type.NAME_OTHER] = require(
        "HudController.gui.elements.profile.panel.main.name_other"
    ),
    [mod.enum.hud_type.AMMO] = require("HudController.gui.elements.profile.panel.main.ammo"),
    [mod.enum.hud_type.RADIAL] = require("HudController.gui.elements.profile.panel.main.radial"),
    [mod.enum.hud_type.SLINGER_RETICLE] = require(
        "HudController.gui.elements.profile.panel.main.slinger_reticle"
    ),
    [mod.enum.hud_type.SHARPNESS] = require(
        "HudController.gui.elements.profile.panel.main.sharpness"
    ),
    [mod.enum.hud_type.CLOCK] = require("HudController.gui.elements.profile.panel.main.clock"),
    [mod.enum.hud_type.SHORTCUT_KEYBOARD] = require(
        "HudController.gui.elements.profile.panel.main.shortcut_keyboard"
    ),
    [mod.enum.hud_type.MINIMAP] = require("HudController.gui.elements.profile.panel.main.minimap"),
    [mod.enum.hud_type.STAMINA] = require("HudController.gui.elements.profile.panel.main.stamina"),
    [mod.enum.hud_type.SUBTITLES] = require(
        "HudController.gui.elements.profile.panel.main.subtitles"
    ),
}

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
function this.draw(elem, elem_config, config_key)
    local fn = funcs[
        elem_config.hud_type --[[@as HudType]]
    ]
    if fn then
        fn(elem, elem_config, config_key)
    end
end

return this
