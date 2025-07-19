local ace_misc = require("HudController.util.ace.misc")
local config = require("HudController.config")
local data = require("HudController.data")
local m = require("HudController.util.ref.methods")
local util_game = require("HudController.util.game")
local util_misc = require("HudController.util.misc")

local ace_map = data.ace.map
local ace_enum = data.ace.enum

local this = {
    ---@type table<string, HudBaseDefault>
    by_path = {},
    ---@type table<PlayObject, HudBaseDefault>
    by_obj = {},
    ---@type table<string, PlayObject>
    path_to_obj = {},
    boot_time = util_misc.get_boot_time(),
}

---@param obj PlayObject
---@return HudBaseDefault
function this.create_default(obj)
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
        display = ace_enum.hud_display[ace_misc.get_hud_manager():getHudDisplay(hudid)]
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
        segment = ace_enum.draw_segment[obj:get_Segment()],
    }

    return ret
end

---@param obj PlayObject
---@return string
function this.get_path(obj)
    local path = m.getPlayObjectFullPath(obj)
    local gui = obj:get_Component()
    return string.format("%s/%s", gui:ToString(), path)
end

function this.clear()
    this.by_path = {}
    this.by_obj = {}
    json.dump_file(config.hud_default_path, { boot_time = this.boot_time, cache = this.by_path })
end

---@param path string
function this.clear_obj(path)
    for p in pairs(this.by_path) do
        if p:match(path) then
            this.by_path[p] = nil
            local obj = this.path_to_obj[p]
            if obj then
                this.by_obj[obj] = nil
            end
            this.path_to_obj[p] = nil
        end
    end

    json.dump_file(config.hud_default_path, { boot_time = this.boot_time, cache = this.by_path })
end

---@param obj PlayObject
function this.check(obj)
    if this.by_obj[obj] then
        return
    end

    local path = this.get_path(obj)
    this.path_to_obj[path] = obj
    if this.by_path[path] then
        this.by_obj[obj] = this.by_path[path]
        return
    end

    local default = this.create_default(obj)
    this.by_path[path] = default
    this.by_obj[obj] = default

    json.dump_file(config.hud_default_path, { boot_time = this.boot_time, cache = this.by_path })
end

---@param obj PlayObject
---@return HudBaseDefault?
function this.get_default(obj)
    return this.by_obj[obj]
end

---@return boolean
function this.init()
    local j = json.load_file(config.hud_default_path)
    if j and math.abs(this.boot_time - j.boot_time) < 5 then
        this.by_path = j.cache or {}
    else
        json.dump_file(config.hud_default_path, { boot_time = this.boot_time, cache = {} })
    end
    return true
end

return this
