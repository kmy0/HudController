---@class ModHook
---@field is_hud_hooked table<string, boolean>
---@field is_option_hooked table<string, boolean>
---@field is_option_mod_hooked table<string, boolean>
---@field is_hud_option_hooked table<string, boolean>
---@field is_fun_hooked table<fun(), true>
---@field hud_hooks table<string, fun(...)>
---@field hud_option_hooks table<string, table<string, {condition: (fun(config_path: string): boolean), fn: fun()}>>
---@field option_hooks table<string, fun()>
---@field option_mod_hooks table<string, fun()>
---@field hud table<string, fun()|fun()[]>
---@field option table<string, fun()|fun()[]>
---@field option_mod table<string, fun()|fun()[]>

local common = require("HudController.hud.hook.common")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local elements = require("HudController.hud.hook.elements.init")
local hooks = require("HudController.hud.hook.hooks.init")
local hud = require("HudController.hud.init")
local hud_def = require("HudController.data.option.hud")
local m = require("HudController.util.ref.methods")
local misc = require("HudController.hud.hook.misc")
local mod_def = require("HudController.data.option.mod")
local option = require("HudController.data.option.init")
local util_ref = require("HudController.util.ref.init")

local ace_map = data.ace.map

---@class ModHook
local this = {
    is_hud_hooked = {},
    is_option_hooked = {},
    is_option_mod_hooked = {},
    is_fun_hooked = {},
    is_hud_option_hooked = {},
    hud_hooks = hooks.hud.hud_hooks,
    hud_option_hooks = hooks.hud.hud_option_hooks,
    option_hooks = hooks.option.option_hooks,
    option_mod_hooks = hooks.option.option_mod_hooks,
    hud = {},
    option = {},
    option_mod = {},
}
---@type table<string, boolean>
local on_render_hooks = {}

m.hook("app.GUIManager.resetTitleApp()", nil, misc.reset_hud_default_post)
m.hook(
    "app.HunterCharacter.warp(via.vec3, System.Nullable`1<via.Quaternion>, System.Boolean)",
    nil,
    misc.reset_cache_post
)
m.hook("app.GUIManager.lateUpdateApp()", nil, function(_)
    if not common.is_ok() then
        return
    end

    for gui_type in pairs(on_render_hooks) do
        elements.update.update_post(gui_type)
    end
end)

local function hook_fn(fn)
    if type(fn) ~= "table" then
        fn = { fn }
    end

    for _, f in pairs(fn) do
        if not this.is_fun_hooked[f] then
            f()
            this.is_fun_hooked[f] = true
        end
    end
end

---@param hud_id app.GUIHudDef.TYPE
---@param hud_name string
function this.hook_hud(hud_id, hud_name)
    for _, gui_id in pairs(ace_map.hudid_to_guiid[hud_id]) do
        local gui_type = string.format("app.G%s", e.get("app.GUIID.ID")[gui_id])
        local key = string.format("%s|%s", hud_name, gui_type)

        if this.is_hud_hooked[key] then
            goto continue
        end

        -- NamesAccess is updated here @update_name_access_icons_post
        if
            util_ref.is_a_str(gui_type, "app.GUIHudBase")
            and hud_id ~= e.get("app.GUIHudDef.TYPE").NAME_ACCESSIBLE
        then
            on_render_hooks[gui_type] = true
        end

        local fn = this.hud[hud_name]
        if fn then
            hook_fn(fn)
        end

        this.hook_hud_options(hud_name)
        this.is_hud_hooked[key] = true
        ::continue::
    end
end

function this.hook_option(option_key)
    if this.is_option_hooked[option_key] then
        return
    end

    local fn = this.option[option_key]
    if fn then
        hook_fn(fn)
    end

    this.is_option_hooked[option_key] = true
end

---@param profile_config  ModProfileConfig
function this.hook_options(profile_config)
    for key, opt in pairs(hud_def.opt) do
        if
            option.is_active(opt --[[@as OptionDef]], profile_config[key])
        then
            this.hook_option(key)
        end
    end
end

function this.hook_options_mod()
    for k, fn in pairs(this.option_mod) do
        if this.is_option_mod_hooked[k] then
            goto continue
        end

        local opt = mod_def.opt[k] --[[@as OptionDef]]
        if option.is_active(opt, config:get(option.get_config_key(mod_def.opt[k]))) then
            hook_fn(fn)
            this.is_option_mod_hooked[k] = true
        end

        ::continue::
    end
end

---@param hud_name string?
function this.hook_hud_options(hud_name)
    local function f(hooks)
        for config_path, hook in pairs(hooks) do
            if this.is_hud_option_hooked[config_path] then
                goto continue
            end

            if hook.condition(config_path) then
                hook_fn(hook.fn)
                this.is_hud_option_hooked[config_path] = true
            end

            ::continue::
        end
    end

    if not hud_name then
        for elem_name, hooks in pairs(this.hud_option_hooks) do
            local elem = hud.get_element(elem_name)
            if not elem then
                goto continue
            end

            f(hooks)
            ::continue::
        end
    else
        local hooks = this.hud_option_hooks[hud_name]
        if not hooks then
            return
        end

        local elem = hud.get_element(hud_name)
        if not elem then
            return
        end

        f(hooks)
    end
end

---@return boolean
function this.init()
    this.hud["TARGET_RETICLE"] = this.hud_hooks.target_reticle
    this.hud["MENU_BUTTON_GUIDE"] = this.hud_hooks.menu_button_guide
    this.hud["DAMAGE_NUMBERS"] = this.hud_hooks.damage_numbers
    this.hud["SUBTITLES"] = this.hud_hooks.subtitles
    this.hud["SUBTITLES_CHOICE"] = this.hud_hooks.subtitles
    this.hud["TRAINING_ROOM_HUD"] = this.hud_hooks.training_room_hud
    this.hud["NAME_ACCESSIBLE"] = this.hud_hooks.name_access
    this.hud["BARREL_BOWLING_SCORE"] = this.hud_hooks.barrel_bowling_score
    this.hud["CHAT_LOG"] = this.hud_hooks.chat_log
    this.hud["SHORTCUT_GAMEPAD"] = this.hud_hooks.radial
    this.hud["SLIDER_ITEM"] = this.hud_hooks.itembar
    this.hud["SLIDER_BULLET"] = this.hud_hooks.ammo
    this.hud["NAME_OTHER"] = this.hud_hooks.name_other
    this.hud["CONTROL"] = this.hud_hooks.control
    this.hud["PROGRESS"] = this.hud_hooks.progress
    this.hud["NOTICE"] = this.hud_hooks.notice
    this.hud["SHORTCUT_KEYBOARD"] = this.hud_hooks.shortcut_keyboard
    this.hud["MINIMAP"] = this.hud_hooks.minimap
    this.hud["QUEST_END_TIMER"] = this.hud_hooks.quest_end_timer
    this.hud["BUTTON_PRESS"] = this.hud_hooks.button_press
    --
    this.option["disable_scoutflies"] = this.option_hooks.disable_scoutflies
    this.option["disable_porter_call"] = this.option_hooks.disable_porter_call
    this.option["hide_porter"] =
        { this.option_hooks.hide_porter, this.option_hooks.disable_porter_call }
    this.option["disable_porter_tracking"] = this.option_hooks.disable_porter_tracking
    this.option["monster_icon"] = this.option_hooks.hide_monster_icon
    this.option["hide_small_monsters"] = this.option_hooks.hide_small_monsters
    this.option["monster_ignore_camp"] = this.option_hooks.monster_ignore_camp
    this.option["hide_handler"] = this.option_hooks.hide_handler
    this.option["hide_npc"] = this.option_hooks.hide_npc
    this.option["hide_pet"] = this.option_hooks.hide_pet
    this.option["disable_quest_intro"] = this.option_hooks.disable_quest_intro
    this.option["disable_quest_end_outro"] =
        { this.option_hooks.disable_quest_intro, this.option_hooks.disable_quest_end_outro }
    this.option["disable_quest_end_camera"] = this.option_hooks.disable_quest_end_camera
    this.option["skip_quest_result"] = this.option_hooks.skip_quest_result
    this.option["monster_wound"] = this.option_hooks.scar
    this.option["hide_danger"] = this.option_hooks.hide_danger
    this.option["hide_weapon"] = this.option_hooks.hide_weapon
    this.option["mute_gui"] = this.option_hooks.mute_gui
    this.option["disable_area_intro"] = this.option_hooks.disable_area_intro
    this.option["hide_aggro"] = this.option_hooks.hide_aggro
    --
    this.option_mod["block_input"] = this.option_mod_hooks.block_input
    this.option_mod["canvas_draw"] = this.option_mod_hooks.draw_canvas
    return true
end

return this
