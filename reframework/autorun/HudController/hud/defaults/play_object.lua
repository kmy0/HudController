---@class (exact) PlayObjectDefaultJsonCache : JsonCache

local ace_misc = require("HudController.util.ace.misc")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local json_cache = require("HudController.util.misc.json_cache")
local m = require("HudController.util.ref.methods")
local util_game = require("HudController.util.game.init")

local ace_map = data.ace.map

---@class PlayObjectDefaultJsonCache
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = json_cache })

---@return PlayObjectDefaultJsonCache
function this:new()
    local o = json_cache.new(self, config.hud_default_path)
    ---@cast o PlayObjectDefaultJsonCache
    return o
end

---@param key PlayObject
---@return string
function this:to_json_key(key)
    local path = m.getPlayObjectFullPath(key)
    local gui = key:get_Component()
    return string.format("%s/%s", gui:ToString(), path)
end

---@param obj PlayObject
---@return HudBaseDefault
function this:create_default(obj)
    local offset = obj:get_Position()
    local hide = obj:get_ForceInvisible()
    local rot = obj:get_Rotation()
    local type = obj:get_type_definition() --[[@as RETypeDefinition]]

    if not type:is_a("via.gui.Control") then
        ---@type via.Size
        local size
        if type:is_a("via.gui.Text") then
            ---@cast obj via.gui.Text
            size = obj:get_FontSize()
        elseif type:is_a("via.gui.TextureSet") then
            ---@cast obj via.gui.TextureSet
            size = obj:get_RegionSize()
        else
            ---@cast obj via.gui.Rect | via.gui.Material
            size = obj:get_Size()
        end

        local ret = {
            hide = hide,
            offset = { x = offset.x, y = offset.y },
            rot = rot.x,
            scale = { x = size.w, y = size.h },
            color = obj:get_Color().rgba,
        }

        if type:is_a("via.gui.Material") then
            ---@cast obj via.gui.Material
            ---@cast ret MaterialDefault
            ret.var_float = {
                var0 = obj:get_VariableFloat0(),
                var1 = obj:get_VariableFloat1(),
                var2 = obj:get_VariableFloat2(),
                var3 = obj:get_VariableFloat3(),
                var4 = obj:get_VariableFloat4(),
            }
        elseif type:is_a("via.gui.Scale9Grid") then
            ---@cast obj via.gui.Scale9Grid
            ---@cast ret Scale9Default
            ret.control_point = obj:get_ControlPoint()
            ret.blend = obj:get_BlendType()
            ret.ignore_alpha = obj:get_IgnoreAlpha()
            ret.alpha_channel = obj:get_AlphaChannelType()
        elseif type:is_a("via.gui.Text") then
            ---@cast obj via.gui.Text
            ---@cast ret TextDefault
            ret.hide_glow = not obj:get_GlowEnable()
            ret.glow_color = obj:get_GlowColor().rgba
            ret.page_alignment = obj:get_PageAlignment()
        end

        return ret
    end

    ---@cast obj via.gui.Control
    ---@type string?
    local display
    local gui = obj:get_Component()
    local game_object = gui:get_GameObject()
    local base_app = util_game.get_component(game_object, "app.GUIBaseApp") --[[@as app.GUIBaseApp]]
    local guiid = base_app:get_ID()
    local hudid = ace_map.guiid_to_hudid[guiid]

    if hudid and ace_map.hudid_to_can_hide[hudid] then
        display = e.get("app.GUIHudDef.DISPLAY")[ace_misc.get_hud_manager():getHudDisplay(hudid)]
    end

    local scale = obj:get_Scale()
    local color = obj:get_ColorScale()
    local ret = {
        hide = hide,
        offset = { x = offset.x, y = offset.y },
        rot = rot.z,
        opacity = color.w,
        scale = { x = scale.x, y = scale.y },
        play_state = obj:get_PlayState(),
        color_scale = { x = color.x, y = color.y, z = color.z },
        display = display,
        segment = e.get("app.GUIDefApp.DRAW_SEGMENT")[obj:get_Segment()],
    }

    return ret
end

---@param json_key string
function this:remove_by_json_key(json_key)
    for _json_key in pairs(self._json_map) do
        if _json_key:match(json_key) then
            local key = self._json_key_map[_json_key]
            self._json_map[_json_key] = nil
            self._json_key_map[_json_key] = nil

            if key then
                self._map[key] = nil
                self._map_key_json[key] = nil
            end
        end
    end

    if self._do_dump then
        self:dump()
    end
end

---@param obj PlayObject
function this:check(obj)
    if self:get(obj) then
        return
    end

    self:set(obj, self:create_default(obj))
end

return this
