---@class (exact) Whistle : HudChild
---@field get_config fun(): WhistleConfig
---@field children {
--- background: HudChild,
--- resonance: HudChild,
--- melody: HudChild,
--- notice: WhistleNotice,
--- perform: WhistlePerform,
---}

---@class (exact) WhistlePerform : HudChild
---@field children {
--- melody1: HudChild,
--- melody2: HudChild,
--- melody3: HudChild,
--- arrow: HudChild,
--- }
---@class (exact) WhistleNotice : HudChild
---@field children {
--- arrow: CtrlChild,
--- }

---@class (exact) WhistleConfig : HudChildConfig
---@field children {
--- background: HudChildConfig,
--- resonance: HudChildConfig,
--- melody: HudChildConfig,
--- notice: WhistleNoticeConfig,
--- perform: WhistlePerformConfig,
--- }

---@class (exact) WhistlePerformConfig : HudChildConfig
---@field children {
--- melody1: HudChildConfig,
--- melody2: HudChildConfig,
--- melody3: HudChildConfig,
--- arrow: HudChildConfig,
--- }

---@class (exact) WhistleNoticeConfig : HudChildConfig
---@field children {
--- arrow: CtrlChildConfig,
--- }

local ctrl_child = require("HudController.hud.def.ctrl_child")
local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

---@class Whistle
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- ctrl = PNL_All
local ctrl_args = {
    background = {
        {
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_UnderBase",
            },
        },
    },
    resonance = {
        {
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_Resonance",
            },
        },
    },
    melody = {
        {
            {
                "PNL_Scale1",
                "PNL_Pat00",
                "PNL_Melody",
            },
        },
    },
    notice = {
        {
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_Score",
                "PNL_Notice",
            },
        },
    },
    ["notice.arrow"] = {
        {
            {
                "PNL_Notice00",
                "PNL_NoticeAnim",
            },
            "tex_arrow",
            "via.gui.Texture",
        },
        {
            {
                "PNL_Notice01",
                "PNL_NoticeAnim",
            },
            "tex_arrow",
            "via.gui.Texture",
        },
    },
    perform = {
        {
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_Perform",
            },
        },
    },
    ["perform.melody"] = {
        {
            {},
            "PNL_PMelody",
            true,
        },
    },
    ["perform.melody.arrow"] = {
        {
            {
                "PNL_arrow",
            },
        },
    },
}

---@param args WhistleConfig
---@param parent HudBase
---@return Whistle
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        if gui_id ~= rl(ace_enum.gui_id, "UI020030") then
            return {}
        end

        return ctrl
    end)
    setmetatable(o, self)
    ---@cast o Whistle

    o.children.background = hud_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.background)
    end)
    o.children.resonance = hud_child:new(args.children.resonance, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.resonance)
    end)
    o.children.melody = hud_child:new(args.children.melody, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.melody)
    end)

    o.children.notice = hud_child:new(args.children.notice, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.notice)
    end) --[[@as WhistleNotice]]
    o.children.notice.children.arrow = ctrl_child:new(
        args.children.notice.children.arrow,
        o.children.notice,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.child.get, ctrl, ctrl_args["notice.arrow"])
        end
    )

    o.children.perform = hud_child:new(args.children.perform, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.perform)
    end) --[[@as WhistlePerform]]
    for i = 1, 3 do
        o.children.perform.children["melody" .. i] = hud_child:new(
            args.children.perform.children["melody" .. i],
            o.children.perform,
            function(s, hudbase, gui_id, ctrl)
                return play_object.control.get(ctrl, "PNL_PMelody0" .. i - 1)
            end
        )
    end
    o.children.perform.children.arrow = hud_child:new(
        args.children.perform.children.arrow,
        o.children.perform,
        function(s, hudbase, gui_id, ctrl)
            local ret = {}
            local melody = play_object.iter_args(play_object.control.all, ctrl, ctrl_args["perform.melody"])
            for _, m in pairs(melody) do
                ---@cast m via.gui.Control
                util_table.array_merge_t(
                    ret,
                    play_object.iter_args(play_object.control.get, m, ctrl_args["perform.melody.arrow"])
                )
            end

            return ret
        end
    )

    return o
end

---@return WhistleConfig
function this.get_config()
    local base = hud_child.get_config("WHISTLE") --[[@as WhistleConfig]]
    local children = base.children

    children.background = {
        name_key = "background",
        hide = false,
    }
    children.resonance = hud_child.get_config("resonance")
    children.melody = hud_child.get_config("melody")

    children.perform = hud_child.get_config("perform") --[[@as WhistlePerformConfig]]
    for i = 1, 3 do
        children.perform.children["melody" .. i] = hud_child.get_config("melody" .. i)
    end
    children.perform.children.arrow = hud_child.get_config("arrow")

    children.notice = hud_child.get_config("notice") --[[@as WhistleNoticeConfig]]
    children.notice.children.arrow = { name_key = "arrow", hide = false }

    return base
end

return this
