---@class (exact) SubtitlesChoice : HudBase
---@field get_config fun(): SubtitlesChoiceConfig

---@class (exact) SubtitlesChoiceConfig : HudBaseConfig

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
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

---@param args SubtitlesChoiceConfig
---@return SubtitlesChoice
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o SubtitlesChoice

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
    local ctrl = self:get_scale_panel(subman._ChoiceGUI)
    self:reset_ctrl(ctrl, key)
end

---@return SubtitlesChoiceConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "SUBTITLES_CHOICE"), "SUBTITLES_CHOICE") --[[@as SubtitlesChoiceConfig]]

    base.hud_type = mod.enum.hud_type.SUBTITLES_CHOICE

    return base
end

return this
