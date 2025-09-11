---@class (exact) HealthSkillList : HudChild
---@field get_config fun(): HealthSkillListConfig
---@field children {icon : HudChild, timer: HudChild}

---@class (exact) HealthSkillListConfig : HudChildConfig
---@field children {icon: HudChildConfig, timer: HudChildConfig}

---@class (exact) HealthSkillListControlArguments
---@field icon PlayObjectGetterFn[]
---@field virus PlayObjectGetterFn[]
---@field timer PlayObjectGetterFn[]

local frame_cache = require("HudController.util.misc.frame_cache")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object.init")
local util_table = require("HudController.util.misc.table")

---@class HealthSkillList
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_StateIcons
---@type HealthSkillListControlArguments
local control_arguments = {
    icon = {
        {
            play_object.control.all,
            {},
            "PNL_STIcon",
        },
    },
    virus = {
        {
            play_object.control.get,
            {
                "PNL_Virus",
            },
        },
    },
    timer = {
        {
            play_object.control.get,
            {
                "PNL_timerLong",
            },
        },
        {
            play_object.control.get,
            {
                "PNL_timerNum",
            },
        },
    },
}

---@param ctrl via.gui.Control
local function get_icons(ctrl)
    return play_object.iter_args(ctrl, control_arguments.icon)
end

---@param args HealthSkillListConfig
---@param parent Health
---@param ctrl_getter fun(self: HudChild, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): PlayObject[] | PlayObject?
---@return HealthSkillList
function this:new(args, parent, ctrl_getter)
    local o = hud_child.new(self, args, parent, ctrl_getter)
    setmetatable(o, self)
    ---@cast o HealthSkillList

    o.children.icon = hud_child:new(args.children.icon, o, function(s, hudbase, gui_id, ctrl)
        return util_table.array_merge_t(
            play_object.iter_args(ctrl, control_arguments.virus),
            get_icons(ctrl)
        )
    end)
    o.children.timer = hud_child:new(args.children.timer, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(get_icons(ctrl), control_arguments.timer)
    end)

    return o
end

---@return HealthSkillListConfig
function this.get_config()
    local base = hud_child.get_config("skill_list") --[[@as HealthSkillListConfig]]
    local children = base.children

    children.icon = {
        name_key = "icon",
        enabled_rot = false,
        rot = 0,
    }
    children.timer = {
        name_key = "timer",
        hide = false,
    }

    return base
end

get_icons = frame_cache.memoize(get_icons)

return this
