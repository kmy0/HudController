---@class (exact) RodReticle : HudBase
---@field get_config fun(): RodReticleConfig
---@field children {
--- reticle: HudChild,
--- extract: HudChild,
--- extract_frame: Material,
--- }

---@class (exact) RodReticleConfig : HudBaseConfig
---@field children {
--- reticle: HudChildConfig,
--- extract: HudChildConfig,
--- extract_frame: MaterialConfig,
--- }

---@class (exact) RodReticleControlArguments
---@field reticle PlayObjectGetterFn[]
---@field extract PlayObjectGetterFn[]
---@field extract_frame PlayObjectGetterFn[]

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local material = require("HudController.hud.def.material")
local play_object = require("HudController.hud.play_object")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class RodReticle
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- PNL_Scale
---@type RodReticleControlArguments
local control_arguments = {
    reticle = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_Reticle",
            },
        },
    },
    extract = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_Reticle",
                "PNL_Ext",
            },
        },
    },
    extract_frame = {
        {
            play_object.child.get,
            {
                "PNL_Pat00",
                "PNL_Reticle",
            },
            "mat_frameT",
            "via.gui.Material",
        },
        {
            play_object.child.get,
            {
                "PNL_Pat00",
                "PNL_Reticle",
            },
            "mat_frameB",
            "via.gui.Material",
        },
    },
}

---@param args RodReticleConfig
---@return RodReticle
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o RodReticle

    o.children.reticle = hud_child:new(args.children.reticle, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.reticle)
    end)
    o.children.extract = hud_child:new(args.children.extract, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.extract)
    end)

    o.children.extract_frame = material:new(
        args.children.extract_frame,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.extract_frame)
        end
    )
    return o
end

---@return RodReticleConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "ROD_RETICLE"), "ROD_RETICLE") --[[@as RodReticleConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.ROD_RETICLE

    children.reticle = hud_child.get_config("reticle")
    children.extract = hud_child.get_config("extract")
    children.extract_frame = {
        name_key = "extract_frame",
        hud_sub_type = mod.enum.hud_sub_type.MATERIAL,
        hide = false,
    }

    return base
end
return this
