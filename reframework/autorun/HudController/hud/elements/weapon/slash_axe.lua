---@class (exact) SlashAxe : HudChild
---@field get_config fun(): SlashAxeConfig
---@field children {
--- background: HudChild,
---}

---@class (exact) SlashAxeConfig : HudChildConfig
---@field children {background: HudChildConfig}

---@class (exact) SlashAxeControlArguments
---@field background PlayObjectGetterFn[]

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

---@class SlashAxe
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_Scale
---@type SlashAxeControlArguments
local control_arguments = {
    background = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_UnderBase",
            },
        },
    },
}

---@param args SlashAxeConfig
---@param parent HudBase
---@return SlashAxe
function this:new(args, parent)
    local o = hud_child.new(
        self,
        args,
        parent,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        rl(ace_enum.gui_id, "UI020029")
    )
    setmetatable(o, self)
    ---@cast o SlashAxe

    o.children.background = hud_child:new(
        args.children.background,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.background)
        end
    )

    return o
end

---@return SlashAxeConfig
function this.get_config()
    local base = hud_child.get_config("SLASH_AXE") --[[@as SlashAxeConfig]]
    local children = base.children

    children.background = {
        name_key = "background",
        hide = false,
    }

    return base
end

return this
