---@class (exact) CompanionPlayerSkillList : HudChild
---@field get_config fun(): CompanionPlayerSkillListConfig
---@field children {
--- icon: HudChild,
--- }

---@class (exact) CompanionPlayerSkillListConfig : HudChildConfig
---@field children {
--- icon: HudChildConfig,
--- }

---@class (exact) CompanionPlayerSkillListControlArguments
---@field icon PlayObjectGetterFn[]

local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

---@class CompanionPlayerSkillList
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_StateIcons00
---@type CompanionPlayerSkillListControlArguments
local control_arguments = {
    icon = {
        {
            play_object.control.all,
            {},
            "PNL_STIcon",
        },
    },
}

---@param args CompanionPlayerSkillListConfig
---@param parent CompanionPlayer
---@param ctrl_getter fun(self: HudChild, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): PlayObject[] | PlayObject?
---@return CompanionPlayerSkillList
function this:new(args, parent, ctrl_getter)
    local o = hud_child.new(self, args, parent, ctrl_getter)
    setmetatable(o, self)
    ---@cast o CompanionPlayerSkillList

    o.children.icon = hud_child:new(args.children.icon, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.icon)
    end)

    return o
end

---@return CompanionPlayerSkillListConfig
function this.get_config()
    local base = hud_child.get_config("skill_list") --[[@as CompanionPlayerSkillListConfig]]
    local children = base.children

    children.icon = {
        name_key = "icon",
        enabled_rot = false,
        rot = 0,
    }

    return base
end

return this
