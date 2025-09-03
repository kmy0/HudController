---@class (exact) CompanionPlayer : HudChild
---@field get_config fun(name_key: string): CompanionPlayerConfig
---@field children {
--- gauge: CompanionPlayerGauge,
--- icon: HudChild,
--- text: HudChild,
--- skill_list: CompanionPlayerSkillList,
---}

---@class (exact) CompanionPlayerConfig : HudChildConfig
---@field children {
--- gauge: CompanionPlayerGaugeConfig,
--- skill_list: CompanionPlayerSkillListConfig,
--- icon: HudChildConfig,
--- text: HudChildConfig,
--- }

---@class (exact) CompanionPlayerControlArguments
---@field gauge PlayObjectGetterFn[]
---@field skill_list PlayObjectGetterFn[]
---@field icon PlayObjectGetterFn[]
---@field text PlayObjectGetterFn[]

local gauge = require("HudController.hud.elements.companion.player.gauge")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local skill_list = require("HudController.hud.elements.companion.player.skill_list")

---@class CompanionPlayer
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_playerXX
---@type CompanionPlayerControlArguments
local control_arguments = {
    gauge = {
        {
            play_object.control.get,
            {
                "PNL_playerSet00",
                "PNL_hp00",
            },
        },
    },
    icon = {
        {
            play_object.control.get,
            {
                "PNL_playerSet00",
                "PNL_iconPlayer00",
            },
        },
        {
            play_object.control.get,
            {
                "PNL_playerSet00",
                "PNL_battle00",
            },
        },
    },
    text = {
        {
            play_object.child.get,
            {
                "PNL_playerSet00",
            },
            "txt_name00",
            "via.gui.Text",
        },
    },
    skill_list = {
        {
            play_object.control.get,
            {
                "PNL_playerSet00",
                "PNL_StateIcons00",
            },
        },
    },
}

---@param args CompanionPlayerConfig
---@param parent HudBase
---@param ctrl_getter fun(self: HudChild, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): PlayObject[] | PlayObject?
---@return CompanionPlayer
function this:new(args, parent, ctrl_getter)
    local o = hud_child.new(self, args, parent, ctrl_getter)
    setmetatable(o, self)
    ---@cast o CompanionPlayer

    o.children.gauge = gauge:new(args.children.gauge, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.gauge)
    end)
    o.children.skill_list = skill_list:new(args.children.skill_list, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.skill_list)
    end)
    o.children.icon = hud_child:new(args.children.icon, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.icon)
    end)
    o.children.text = hud_child:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.text)
    end)
    return o
end

---@param name_key string
---@return CompanionPlayerConfig
function this.get_config(name_key)
    local base = hud_child.get_config(name_key) --[[@as CompanionPlayerConfig]]
    local children = base.children

    children.icon = hud_child.get_config("icon")
    children.skill_list = skill_list.get_config()
    children.gauge = gauge.get_config()
    children.text = {
        name_key = "text",
        hide = false,
    }

    return base
end

return this
