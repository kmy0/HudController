---@class (exact) BarrelScorePoints : HudChild
---@field get_config fun(name: string): BarrelScorePointsConfig
---@field children {
--- background: HudChild,
--- line: HudChild,
--- name: HudChild,
--- points: HudChild,
--- }

---@class (exact) BarrelScorePointsConfig : HudChildConfig
---@field children {
--- background: HudChildConfig,
--- line: HudChildConfig,
--- name: HudChildConfig,
--- points: HudChildConfig,
--- }

---@class (exact) BarrelScorePointsControlArguments
---@field line PlayObjectGetterFn[]
---@field background PlayObjectGetterFn[]
---@field name PlayObjectGetterFn[]
---@field points PlayObjectGetterFn[]

local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object.init")

---@class BarrelScorePoints
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_First | PNL_Second
---@type BarrelScorePointsControlArguments
local control_arguments = {
    background = {
        {
            play_object.control.get,
            {
                "PNL_PointBase",
            },
        },
    },
    line = {
        {
            play_object.control.get,
            {
                "PNL_BaseLine",
            },
        },
    },
    name = {
        {
            play_object.control.get,
            {
                "PNL_Heading",
            },
        },
    },
    points = {
        {
            play_object.control.get,
            {
                "PNL_Point",
            },
        },
    },
}

---@param args BarrelScorePointsConfig
---@param parent BarrelScore
---@param ctrl_getter fun(self: BarrelScorePoints, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?)
---@param ctrl_writer (fun(self: BarrelScorePoints, ctrl: via.gui.Control): boolean)?
---@param default_overwrite HudChildDefaultOverwrite?
---@param gui_ignore boolean?
---@param children_sort (fun(a: HudChild, b: HudChild): boolean)?
---@param no_cache boolean?
---@param valid_guiid (app.GUIID.ID | app.GUIID.ID[])?
---@return BarrelScorePoints
function this:new(
    args,
    parent,
    ctrl_getter,
    ctrl_writer,
    default_overwrite,
    gui_ignore,
    children_sort,
    no_cache,
    valid_guiid
)
    local o = hud_child.new(
        self,
        args,
        parent,
        ctrl_getter,
        ctrl_writer,
        default_overwrite,
        gui_ignore,
        children_sort,
        no_cache,
        valid_guiid
    )
    setmetatable(o, self)

    ---@cast o BarrelScorePoints
    o.children.background = hud_child:new(args.children.background, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.background)
    end)
    o.children.line = hud_child:new(args.children.line, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.line)
    end)
    o.children.name = hud_child:new(args.children.name, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.name)
    end)
    o.children.points = hud_child:new(args.children.points, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.points)
    end)

    return o
end

---@param name string
---@return BarrelScorePointsConfig
function this.get_config(name)
    local base = hud_child.get_config(name) --[[@as BarrelScorePointsConfig]]
    local children = base.children

    children.background = { name_key = "background", hide = false }
    children.line = { name_key = "line", hide = false }
    children.name = hud_child.get_config("name")
    children.points = hud_child.get_config("points")

    return base
end

return this
