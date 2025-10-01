---@class (exact) ChatLogFilter: HudChild
---@field get_config fun(): ChatLogFilterConfig
---@field children {
--- background: HudChild,
--- }

---@class (exact) ChatLogFilterConfig : HudChildConfig
---@field children {
--- background: HudChildConfig,
--- }

---@class (exact) ChatLogFilterControlArguments
---@field background PlayObjectGetterFn[]
---@field filter PlayObjectGetterFn[]

local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object.init")

---@class ChatLogFilter
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_All
---@type ChatLogFilterControlArguments
local control_arguments = {
    filter = {
        {
            play_object.control.get,
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_filtering",
            },
        },
    },
    background = {
        {
            play_object.control.get,
            {
                "PNL_ref_filtering",
                "PNL_filtering",
                "PNL_base_filter",
            },
        },
    },
}

---@param args ChatLogFilterConfig
---@param parent HudBase
---@return ChatLogFilter
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.filter)
    end)
    setmetatable(o, self)
    ---@cast o ChatLogFilter

    o.children.background = hud_child:new(
        args.children.background,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.background)
        end
    )

    return o
end

---@return ChatLogFilterConfig
function this.get_config()
    local base = hud_child.get_config("filter") --[[@as ChatLogFilterConfig]]
    local children = base.children

    children.background = { name_key = "background", hide = false }

    return base
end

return this
