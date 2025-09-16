---@class (exact) ProgressTimer : ProgressPartBase
---@field get_config fun(): ProgressTimerConfig
---@field children {
--- text: ProgressPartBase,
--- rank: ProgressPartBase,
--- }
---@field root Progress

---@class (exact) ProgressTimerConfig : ProgressPartBaseConfig
---@field children {
--- text: ProgressPartBaseConfig,
--- rank: ProgressPartBaseConfig,
--- }

---@class (exact) ProgressTimerControlArguments
---@field text PlayObjectGetterFn[]
---@field rank PlayObjectGetterFn[]

local part_base = require("HudController.hud.elements.progress.part_base")
local play_object = require("HudController.hud.play_object.init")

---@class ProgressTimer
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = part_base })

-- PNL_time
---@type ProgressTimerControlArguments
local control_arguments = {
    text = {
        {
            play_object.control.get,
            {
                "PNL_txt_time",
            },
        },
    },
    rank = {
        {
            play_object.control.get,
            {
                "PNL_ref_arenaRankIcon00",
            },
        },
    },
}

---@param args ProgressTimerConfig
---@param parent Progress
---@param ctrl_getter fun(self: ProgressPartBase, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?)
---@param ctrl_writer (fun(self: ProgressPartBase, ctrl: via.gui.Control): boolean)?
---@param default_overwrite ProgressPartBaseDefaultOverwrite?
---@param gui_ignore boolean?
---@param children_sort (fun(a: HudChild, b: HudChild): boolean)?
---@param no_cache boolean?
---@param valid_guiid (app.GUIID.ID | app.GUIID.ID[])?
---@return ProgressTimer
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
    local o = part_base.new(
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
    ---@cast o ProgressTimer

    o.children.text = part_base:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.text)
    end, nil, { hide = false })
    o.children.rank = part_base:new(args.children.rank, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.rank)
    end, nil, { hide = false })

    return o
end

---@return ProgressTimerConfig
function this.get_config()
    local base = part_base.get_config("timer") --[[@as ProgressTimerConfig]]
    local children = base.children

    children.text = {
        name_key = "text",
        hide = false,
    }
    children.rank = {
        name_key = "rank",
        hide = false,
    }

    return base
end

return this
