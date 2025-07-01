---@class (exact) TwinSword : HudChild
---@field get_config fun(): TwinSwordConfig
---@field children {
--- background: HudChild,
--- background_sword: HudChild,
---}

---@class (exact) TwinSwordConfig : HudChildConfig
---@field children {background: HudChildConfig, background_sword: HudChildConfig}

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

---@class TwinSword
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- ctrl = PNL_Scale
local ctrl_args = {
    background = {
        {
            {
                "PNL_Pat00",
                "PNL_UnderBase",
            },
        },
    },
    background_sword = {
        {
            {
                "PNL_Pat00",
                "PNL_frame01",
            },
        },
        {
            {
                "PNL_Pat00",
                "PNL_demon",
                "PNL_demonlight2",
            },
        },
    },
}

---@param args TwinSwordConfig
---@param parent HudBase
---@return TwinSword
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        if gui_id ~= rl(ace_enum.gui_id, "UI020033") then
            return {}
        end
        return ctrl
    end)
    setmetatable(o, self)
    ---@cast o TwinSword

    o.children.background = hud_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.background)
    end)
    o.children.background_sword = hud_child:new(args.children.background_sword, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.background_sword)
    end)

    return o
end

---@return TwinSwordConfig
function this.get_config()
    local base = hud_child.get_config("TWIN_SWORD") --[[@as TwinSwordConfig]]
    local children = base.children

    children.background = {
        name_key = "background",
        hide = false,
    }
    children.background_sword = {
        name_key = "background_sword",
        hide = false,
    }

    return base
end

return this
