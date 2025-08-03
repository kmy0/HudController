---@class (exact) SubtitlesChoice : HudBase
---@field get_config fun(): SubtitlesChoiceConfig
---@field children  {
--- background: HudChild,
--- }

---@class (exact) SubtitlesChoiceConfig : HudBaseConfig
---@field children  {
--- background: HudChildConfig,
--- }

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local s = require("HudController.util.ref.singletons")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class SubtitlesChoice
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

local ctrl_args = {
    background = {
        {
            {
                "PNL_Group00",
                "PNL_txtBG",
            },
        },
    },
}

---@param args SubtitlesChoiceConfig
---@return SubtitlesChoice
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o SubtitlesChoice

    o.children.background = hud_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.background)
    end)

    return o
end

---@param hudbase app.GUI020401
---@return via.gui.Control
function this:get_scale_panel(hudbase)
    local root = hudbase._RootWindow
    return play_object.control.get(root, {
        "PNL_All",
        "PNL_Scale",
    }) --[[@as via.gui.Control]]
end

---@param key HudBaseWriteKey
function this:reset(key)
    if not self.initialized then
        return
    end

    local subman = s.get("app.DialogueManager"):get_SubtitleManager()
    local hudbase = subman._ChoiceGUI

    if hudbase then
        local ctrl = self:get_scale_panel(subman._ChoiceGUI)
        self:reset_ctrl(ctrl, key)
        ---@diagnostic disable-next-line: param-type-mismatch
        self:reset_children(hudbase, nil, ctrl, key)
    end
end

---@return SubtitlesChoiceConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "SUBTITLES_CHOICE"), "SUBTITLES_CHOICE") --[[@as SubtitlesChoiceConfig]]

    base.hud_type = mod.enum.hud_type.SUBTITLES_CHOICE
    base.children.background = {
        name_key = "background",
        hide = false,
    }

    return base
end

return this
