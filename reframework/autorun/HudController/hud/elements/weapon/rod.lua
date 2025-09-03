---@class (exact) Rod : HudChild
---@field get_config fun(): RodConfig
---@field children {
--- background: HudChild,
--- stamina: HudChild,
--- insect: HudChild,
--- buff: HudChild,
---}

---@class (exact) RodConfig : HudChildConfig
---@field children {
--- background: HudChildConfig,
--- stamina: HudChildConfig,
--- insect: HudChildConfig,
--- buff: HudChildConfig,
--- }

---@class (exact) RodControlArguments
---@field background PlayObjectGetterFn[]
---@field stamina PlayObjectGetterFn[]
---@field insect PlayObjectGetterFn[]
---@field buff PlayObjectGetterFn[]

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

---@class Rod
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_Scale
local control_arguments = {
    background = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_Base",
            },
        },
    },
    stamina = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_Stamina",
            },
        },
    },
    insect = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_Insects",
            },
        },
    },
    buff = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_Signal",
            },
        },
    },
}

---@param args RodConfig
---@param parent HudBase
---@return Rod
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        if gui_id ~= rl(ace_enum.gui_id, "UI020027") then
            return {}
        end

        return ctrl
    end)
    setmetatable(o, self)
    ---@cast o Rod

    o.children.background = hud_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.background)
    end)
    o.children.stamina = hud_child:new(args.children.stamina, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.stamina)
    end)
    o.children.insect = hud_child:new(args.children.insect, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.insect)
    end)
    o.children.buff = hud_child:new(args.children.buff, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.buff)
    end)

    return o
end

---@return RodConfig
function this.get_config()
    local base = hud_child.get_config("ROD") --[[@as RodConfig]]
    local children = base.children

    children.background = {
        name_key = "background",
        hide = false,
    }

    children.background = {
        name_key = "background",
        hide = false,
    }
    children.stamina = hud_child.get_config("stamina")
    children.insect = hud_child.get_config("insect")
    children.buff = hud_child.get_config("buff")

    return base
end

return this
