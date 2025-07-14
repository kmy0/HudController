---@class (exact) Subtitles : HudBase
---@field get_config fun(): SubtitlesConfig
---@field previous_category string?
---@field children table<string, HudChild> | {
--- background: Scale9,
--- }

---@class (exact) SubtitlesConfig : HudBaseConfig
---@field children table<string, HudChildConfig> | {
--- background: Scale9Config,
--- }

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local s = require("HudController.util.ref.singletons")
local scale9 = require("HudController.hud.def.scale9")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

-- ctrl = PNL_Scale
local ctrl_args = {
    group = {
        {
            {
                "PNL_Group00",
            },
        },
    },
    background = {
        {
            "s9g_accessibility_BG",
            "via.gui.Scale9Grid",
        },
    },
}

---@class Subtitles
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args SubtitlesConfig
---@return Subtitles
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Subtitles

    for _, child in pairs(args.children) do
        o.children[child.name_key] = hud_child:new(child, o, function(s, hudbase, gui_id, ctrl)
            ---@cast hudbase app.GUI020400
            local category = ace_enum.subtitles_category[hudbase._SubtitlesCategory]

            if o.previous_category and o.previous_category ~= category and not s:any() then
                s:reset()
                o.previous_category = nil
            end

            if category ~= s.name_key then
                return {}
            end

            if s:any() then
                o.previous_category = category
            end

            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.group)
        end)
    end

    o.children.background = scale9:new(
        args.children.background --[[@as Scale9Config]],
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.child.all_type, ctrl, ctrl_args.background)
        end
    )

    return o
end

---@param hudbase app.GUI020400
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
    local hudbase = subman._SubtitlesGUI

    if not hudbase then
        return
    end

    local ctrl = self:get_scale_panel(hudbase)
    self:reset_ctrl(ctrl, key)
end

---@return SubtitlesConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "SUBTITLES"), "SUBTITLES") --[[@as SubtitlesConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.SUBTITLES

    for _, name in pairs(ace_enum.subtitles_category) do
        children[name] = hud_child.get_config(name)
    end

    children.background = {
        name_key = "background",
        hide = false,
    }

    return base
end

return this
