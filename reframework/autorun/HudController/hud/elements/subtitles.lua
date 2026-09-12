---@class Subtitles : HudBase
---@field get_config fun(): SubtitlesConfig
---@field previous_category string?
---@field cache_subtitles boolean
---@field cache_sfx boolean
---@field cache_sfx_cooldown integer
---@field subtitles_cache CircularBuffer<CachedSubtitle>
---@field cache_sfx_pause boolean
---@field sfx_cache CircularBuffer<CachedSfx>
---@field hide_subtitles table<string, integer>
---@field hide_npc_id table<string, integer>
---@field hide_dialogue_type table<string, integer>
---@field hide_dialogue_actor_type table<string, integer>
---@field mute_subtitles table<string, integer>
---@field mute_npc_id table<string, integer>
---@field mute_dialogue_type table<string, integer>
---@field mute_dialogue_actor_type table<string, integer>
---@field mute_sfx table<string, integer>
---@field children table<string, HudChild> | {
--- background: Scale9,
--- }

---@class (exact) SubtitlesConfig : HudBaseConfig
---@field cache_subtitles boolean
---@field cache_sfx boolean
---@field cache_sfx_cooldown integer
---@field hide_subtitles table<string, integer>
---@field hide_npc_id table<string, integer>
---@field hide_dialogue_type table<string, integer>
---@field hide_dialogue_actor_type table<string, integer>
---@field mute_subtitles table<string, integer>
---@field mute_npc_id table<string, integer>
---@field mute_dialogue_type table<string, integer>
---@field mute_dialogue_actor_type table<string, integer>
---@field mute_sfx table<string, integer>
---@field children table<string, HudChildConfig> | {
--- background: Scale9Config,
--- }

---@class (exact) SubtitlesControlArguments
---@field group PlayObjectGetterFn[]
---@field background PlayObjectGetterFn[]

---@class (exact) CachedSubtitle
---@field text string
---@field type string
---@field npc string
---@field talker_type string
---@field cls string

---@class (exact) CachedSfx
---@field game_object string
---@field event_id string

local circular_buffer = require("HudController.util.misc.circular_buffer")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local frame_cache = require("HudController.util.misc.frame_cache")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object.init")
local s = require("HudController.util.ref.singletons")
local scale9 = require("HudController.hud.def.scale9")
local util_mod = require("HudController.util.mod.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

-- PNL_Scale
---@type SubtitlesControlArguments
local control_arguments = {
    group = {
        {
            play_object.control.get,
            {
                "PNL_Group00",
            },
        },
    },
    background = {
        {
            play_object.child.all_type,
            "s9g_accessibility_BG",
            "via.gui.Scale9Grid",
        },
    },
}

---@class Subtitles
local this = {
    subtitles_cache = circular_buffer:new(50),
    sfx_cache = circular_buffer:new(200),
}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args SubtitlesConfig
---@return Subtitles
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Subtitles

    o.hide_subtitles = args.hide_subtitles
    o.hide_npc_id = args.hide_npc_id
    o.hide_dialogue_type = args.hide_dialogue_type
    o.hide_dialogue_actor_type = args.hide_dialogue_actor_type

    o.mute_subtitles = args.mute_subtitles
    o.mute_npc_id = args.mute_npc_id
    o.mute_dialogue_type = args.mute_dialogue_type
    o.mute_dialogue_actor_type = args.mute_dialogue_actor_type
    o.mute_sfx = args.mute_sfx
    o.cache_subtitles = args.cache_subtitles
    o.cache_sfx = args.cache_sfx
    o.cache_sfx_pause = false
    o.cache_sfx_cooldown = args.cache_sfx_cooldown

    for _, child in pairs(args.children) do
        o.children[child.name_key] = hud_child:new(child, o, function(sel, hudbase, _, ctrl)
            ---@cast hudbase app.GUI020400
            local category = e.get("app.GUI020400.SUBTITLES_CATEGORY")[hudbase._SubtitlesCategory]

            if o.previous_category and o.previous_category ~= category and not sel:any() then
                sel:reset()
                o.previous_category = nil
            end

            if category ~= sel.name_key then
                return {}
            end

            if sel:any() then
                o.previous_category = category
            end

            return play_object.iter_args(ctrl, control_arguments.group)
        end, { no_cache = true })
    end

    o.children.background = scale9:new(
        args.children.background --[[@as Scale9Config]],
        o,
        function(_, _, _, ctrl)
            return play_object.iter_args(ctrl, control_arguments.background)
        end
    )

    return o
end

---@param hudbase app.GUI020400
---@return via.gui.Control
function this:get_scale_panel(hudbase)
    local root = util_mod.get_root_window(hudbase)
    return play_object.control.get(root, {
        "PNL_All",
        "PNL_Scale",
    }) --[[@as via.gui.Control]]
end

---@param val boolean
function this:set_cache_subtitles(val)
    self.cache_subtitles = val
end

---@param val boolean
function this:set_cache_sfx(val)
    self.cache_sfx = val
end

---@param msg CachedSubtitle
function this:push_back_subtitle(msg)
    this.subtitles_cache:push_back(msg)
end

---@param msg CachedSfx
function this:push_back_sfx(msg)
    this.sfx_cache:push_back(msg)
end

---@param name_key string
---@param order integer?
function this:set_hide_subtitles(name_key, order)
    self.hide_subtitles[name_key] = order
end

---@param name_key string
---@param order integer?
function this:set_hide_npc_id(name_key, order)
    self.hide_npc_id[name_key] = order
end

---@param name_key string
---@param order integer?
function this:set_hide_dialogue_type(name_key, order)
    self.hide_dialogue_type[name_key] = order
end

---@param name_key string
---@param order integer?
function this:set_hide_dialogue_actor_type(name_key, order)
    self.hide_dialogue_actor_type[name_key] = order
end

---@param name_key string
---@param order integer?
function this:set_mute_subtitles(name_key, order)
    self.mute_subtitles[name_key] = order
end

---@param name_key string
---@param order integer?
function this:set_mute_npc_id(name_key, order)
    self.mute_npc_id[name_key] = order
end

---@param name_key string
---@param order integer?
function this:set_mute_dialogue_type(name_key, order)
    self.mute_dialogue_type[name_key] = order
end

---@param name_key string
---@param order integer?
function this:set_mute_dialogue_actor_type(name_key, order)
    self.mute_dialogue_actor_type[name_key] = order
end

---@param name_key string
---@param order integer?
function this:set_mute_sfx(name_key, order)
    self.mute_sfx[name_key] = order
end

---@return boolean
function this:any_hide()
    for _, t in pairs({
        self.hide_subtitles,
        self.hide_npc_id,
        self.hide_dialogue_type,
        self.hide_dialogue_actor_type,
    }) do
        if not util_table.empty(t) then
            return true
        end
    end

    return false
end

---@return boolean
function this:any_mute()
    for _, t in pairs({
        self.mute_subtitles,
        self.mute_npc_id,
        self.mute_dialogue_type,
        self.mute_dialogue_actor_type,
    }) do
        if not util_table.empty(t) then
            return true
        end
    end

    return false
end

---@return boolean
function this:any_mute_sfx()
    return not util_table.empty(self.mute_sfx)
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
    ---@diagnostic disable-next-line: param-type-mismatch
    self:reset_children(hudbase, nil, ctrl, key)
end

---@return SubtitlesConfig
function this.get_config()
    local base = hud_base.get_config(e.get_noexact("app.GUIHudDef.TYPE").SUBTITLES, "SUBTITLES") --[[@as SubtitlesConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.SUBTITLES

    for name, _ in e.iter("app.GUI020400.SUBTITLES_CATEGORY") do
        children[name] = hud_child.get_config(name)
    end

    children.background = {
        name_key = "background",
        hide = false,
    }

    base.cache_subtitles = false
    base.cache_sfx = false
    base.cache_sfx_cooldown = 3
    base.hide_subtitles = {}
    base.hide_npc_id = {}
    base.hide_dialogue_type = {}
    base.hide_dialogue_actor_type = {}

    base.mute_subtitles = {}
    base.mute_npc_id = {}
    base.mute_dialogue_type = {}
    base.mute_dialogue_actor_type = {}
    base.mute_sfx = {}

    return base
end

---@diagnostic disable-next-line: inject-field
this.get_scale_panel = frame_cache.memoize(this.get_scale_panel)

return this
