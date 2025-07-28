---@class (exact) CompanionPlayer : HudChild
---@field get_config fun(name_key: string): CompanionPlayerConfig
---@field children {
--- gauge: CompanionHealth,
--- icon: HudChild,
--- text: HudChild,
--- skill_list: SkillList,
---}

---@class (exact) CompanionHealth : HudChild
---@field children {
--- frame: HudChild,
--- light_end: HudChild,
--- light_start: HudChild,
--- line: Material,
--- line_shadow: Material,
--- }

---@class (exact) CompanionPlayerHealthConfig : HudChildConfig
---@field children {
--- frame: HudChildConfig,
--- light_end: HudChildConfig,
--- light_start:HudChildConfig,
--- line: MaterialConfig,
--- line_shadow: MaterialConfig,
--- }

---@class (exact) CompanionPlayerConfig : HudChildConfig
---@field children {
--- gauge: CompanionPlayerHealthConfig,
--- skill_list: SkillListConfig,
--- icon: HudChildConfig,
--- text: HudChildConfig,
--- }

local data = require("HudController.data")
local hud_child = require("HudController.hud.def.hud_child")
local material = require("HudController.hud.def.material")
local play_object = require("HudController.hud.play_object")

local mod = data.mod

---@class CompanionPlayer
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- ctrl = PNL_playerXX
local ctrl_args = {
    gauge = {
        {
            {
                "PNL_playerSet00",
                "PNL_hp00",
            },
        },
    },
    -- ctrl = PNL_hp00
    ["gauge.frame"] = {
        {
            {
                "PNL_gaugeMode00",
                "PNL_bese",
            },
        },
    },
    ["gauge.light_end"] = {
        {
            {
                "PNL_gaugeMode00",
                "PNL_gauge00",
                "PNL_light00",
            },
        },
    },
    ["gauge.light_start"] = {
        {
            {
                "PNL_gaugeMode01",
            },
        },
    },
    ["gauge.line"] = {
        {
            {
                "PNL_gaugeMode00",
                "PNL_gauge00",
            },
            "mat_gauge00",
            "via.gui.Material",
        },
    },
    ["gauge.line_shadow"] = {
        {
            {
                "PNL_gaugeMode00",
                "PNL_gauge00",
            },
            "mat_gauge01",
            "via.gui.Material",
        },
    },
    icon = {
        {
            {
                "PNL_playerSet00",
                "PNL_iconPlayer00",
            },
            {
                "PNL_playerSet00",
                "PNL_battle00",
            },
        },
    },
    text = {
        {
            {
                "PNL_playerSet00",
            },
            "txt_name00",
            "via.gui.Text",
        },
    },
    skill_list = {
        {
            {
                "PNL_playerSet00",
                "PNL_StateIcons00",
            },
        },
    },
    -- ctrl = PNL_StateIcons00
    ["skill_list.icon"] = {
        {
            {},
            "PNL_STIcon",
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

    o.children.gauge = hud_child:new(args.children.gauge, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.gauge)
    end) --[[@as CompanionHealth]]
    o.children.gauge.children.frame = hud_child:new(
        args.children.gauge.children.frame,
        o.children.gauge,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args["gauge.frame"])
        end
    )
    o.children.gauge.children.light_end = hud_child:new(
        args.children.gauge.children.light_end,
        o.children.gauge,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args["gauge.light_end"])
        end
    )
    o.children.gauge.children.light_start = hud_child:new(
        args.children.gauge.children.light_start,
        o.children.gauge,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args["gauge.light_start"])
        end
    )
    o.children.gauge.children.line = material:new(
        args.children.gauge.children.line,
        o.children.gauge,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.child.get, ctrl, ctrl_args["gauge.line"])
        end
    )
    o.children.gauge.children.line_shadow = material:new(
        args.children.gauge.children.line_shadow,
        o.children.gauge,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.child.get, ctrl, ctrl_args["gauge.line_shadow"])
        end
    )

    o.children.skill_list = hud_child:new(args.children.skill_list, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.skill_list)
    end) --[[@as SkillList]]
    o.children.skill_list.children.icon = hud_child:new(
        args.children.skill_list.children.icon,
        o.children.skill_list,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.all, ctrl, ctrl_args["skill_list.icon"])
        end
    )

    o.children.icon = hud_child:new(args.children.icon, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.icon)
    end) --[[@as CompanionHealth]]
    o.children.text = hud_child:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.text)
    end) --[[@as CompanionHealth]]
    return o
end

---@param name_key string
---@return CompanionPlayerConfig
function this.get_config(name_key)
    local base = hud_child.get_config(name_key) --[[@as CompanionPlayerConfig]]
    local children = base.children

    children.icon = hud_child.get_config("icon")
    children.skill_list = hud_child.get_config("skill_list") --[[@as SkillListConfig]]
    children.gauge = hud_child.get_config("gauge") --[[@as CompanionPlayerHealthConfig]]
    children.text = {
        name_key = "text",
        hide = false,
    }

    children.skill_list.children.icon = {
        name_key = "icon",
        enabled_rot = false,
        rot = { x = 0, y = 0, z = 0 },
    }

    children.gauge.children = {
        frame = {
            name_key = "frame",
            hide = false,
        },
        light_end = {
            name_key = "light_end",
            hide = false,
        },
        light_start = {
            name_key = "light_start",
            hide = false,
        },
        line = {
            name_key = "line",
            hide = false,
            enabled_scale = false,
            scale = { x = 1, y = 1 },
            enabled_offset = false,
            offset = { x = 0, y = 0 },
            enabled_size_y = false,
            size_y = 1,
            enabled_var0 = false,
            var0 = { name_key = "material_width_scale", value = 1 },
            enabled_var1 = false,
            var1 = { name_key = "material_anim_speed_scale", value = 1 },
            enabled_var2 = false,
            var2 = { name_key = "material_side_mag_scale", value = 1 },
            hud_sub_type = mod.enum.hud_sub_type.MATERIAL,
        },
        line_shadow = {
            name_key = "line_shadow",
            hide = false,
            enabled_scale = false,
            scale = { x = 1, y = 1 },
            enabled_offset = false,
            offset = { x = 0, y = 0 },
            enabled_size_y = false,
            size_y = 1,
            enabled_var0 = false,
            var0 = { name_key = "material_width_scale", value = 1 },
            enabled_var1 = false,
            var1 = { name_key = "material_anim_speed_scale", value = 1 },
            enabled_var2 = false,
            var2 = { name_key = "material_side_mag_scale", value = 1 },
            hud_sub_type = mod.enum.hud_sub_type.MATERIAL,
        },
    }

    return base
end

return this
