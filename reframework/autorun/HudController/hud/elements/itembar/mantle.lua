---@class (exact) ItembarMantle : HudChild
---@field get_config fun(): ItembarMantleConfig
---@field parent Itembar
---@field always_visible boolean
---@field ctrl_getter fun(self: ItembarMantle, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?
---@field ctrl_writer (fun(self: ItembarMantle, ctrl: via.gui.Control): boolean)?
---@field children {
--- mantle_state: HudChild,
--- visible_state: HudChild,
--- }

---@class (exact) ItembarMantleConfig : HudChildConfig
---@field always_visible boolean
---@field children {
--- mantle_state: HudChildConfig,
--- visible_state: HudChildConfig,
--- }

---@class (exact) ItembarMantleArguments
---@field mantle PlayObjectGetterFn[]

local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local util_table = require("HudController.util.misc.table")

---@class ItembarMantle
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_Scale
---@type ItembarMantleArguments
local control_arguments = {
    mantle = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_mantleSet",
                "PNL_mantleSetMove",
                "PNL_mantleSetMode",
            },
        },
    },
}

local always_visible_states = {
    mantle_state = "dummy",
    visible_state = "dummy",
}

---@param args ItembarMantleConfig
---@param parent Itembar
function this:new(args, parent)
    local o = hud_child:new(args, parent, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.mantle)
    end)
    setmetatable(o, self)
    ---@cast o ItembarMantle

    o.children.mantle_state = hud_child:new(
        args.children.mantle_state,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.control.get_parent(ctrl, "PNL_mantleSet")
        end,
        function(s, ctrl)
            if s.play_state then
                ctrl:set_PlayState("DEFAULT")
            end

            return true
        end,
        nil,
        true
    )
    o.children.visible_state = hud_child:new(
        args.children.visible_state,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.control.get_parent(ctrl, "PNL_mantleSetMove")
        end,
        function(s, ctrl)
            if s.play_state then
                ctrl:set_Visible(true)
            end

            return true
        end,
        nil,
        true
    )

    if args.always_visible then
        o:set_always_visible(args.always_visible)
    end

    return o
end

---@param always_visible boolean
function this:set_always_visible(always_visible)
    self.always_visible = always_visible
    if self.always_visible then
        self:set_play_states(always_visible_states)
    else
        self:reset_play_states(always_visible_states)
    end
end

---@return boolean
function this:any_gui()
    return util_table.any(self.properties, function(key, value)
        if key ~= "always_visible" and self[key] then
            return true
        end
        return false
    end)
end

---@return ItembarMantleConfig
function this.get_config()
    local base = hud_child.get_config("mantle") --[[@as ItembarMantleConfig]]
    local children = base.children

    base.always_visible = false

    children.mantle_state = { name_key = "__mantle_state", play_state = "" }
    children.visible_state = { name_key = "__visible_state", play_state = "" }

    return base
end

return this
