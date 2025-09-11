local config = require("HudController.config.init")
local data = require("HudController.data.init")
local gui_util = require("HudController.gui.util")
local m = require("HudController.util.ref.methods")
local state = require("HudController.gui.state")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod
local set = state.set

local this = {
    ---@type table<HudType, fun(elem: HudBase, elem_config: HudBaseConfig, config_key: string)>
    funcs = {},
}

---@param elem HudBase
---@param t table<string, boolean>
---@param t_config_key string
---@param f fun(self: HudBase, name_key: string, val: boolean)
local function group_things(elem, t, t_config_key, f)
    local sorted = util_table.sort(util_table.keys(t))
    local chunks = util_table.chunks(sorted, 5)

    for i = 1, #chunks do
        local chunk = chunks[i]

        imgui.begin_group()

        for j = 1, #chunk do
            local key = chunk[j]
            local item_config_key = string.format("%s.%s", t_config_key, key)
            imgui.begin_disabled(
                key ~= "ALL"
                    and config:get(t_config_key .. ".ALL") ~= nil
                    and config:get(t_config_key .. ".ALL")
            )

            if
                set:checkbox(
                    string.format(
                        "%s %s##%s",
                        config.lang:tr("hud_element.entry.box_hide"),
                        key,
                        item_config_key
                    ),
                    item_config_key
                )
            then
                f(elem, key, config:get(item_config_key))
                config.save_global()
            end

            imgui.end_disabled()
        end

        imgui.end_group()
        if i ~= #chunks then
            imgui.same_line()
        end
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_weapon(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_weapon_behavior"))

    ---@cast elem Weapon
    ---@cast elem_config WeaponConfig

    local item_config_key = config_key .. ".no_focus"
    if
        set:checkbox(
            gui_util.tr("hud_element.entry.box_weapon_no_focus", item_config_key),
            item_config_key
        )
    then
        elem:set_no_focus(elem_config.no_focus)
        config.save_global()
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_itembar(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_itembar_behavior"))

    ---@cast elem Itembar
    ---@cast elem_config ItembarConfig

    local item_config_key = config_key .. ".children.slider.appear_open"
    if
        set:checkbox(
            gui_util.tr("hud_element.entry.box_appear_open", item_config_key),
            item_config_key
        )
    then
        elem.children.slider:set_appear_open(elem_config.children.slider.appear_open)
        config.save_global()
    end

    item_config_key = config_key .. ".children.slider.move_next"
    if
        set:checkbox(
            gui_util.tr("hud_element.entry.box_move_next", item_config_key),
            item_config_key
        )
    then
        elem.children.slider:set_move_next(elem_config.children.slider.move_next)
        config.save_global()
    end
    util_imgui.tooltip(config.lang:tr("hud_element.entry.tooltip_itembar_move_next"), true)

    item_config_key = config_key .. ".start_expanded"
    if
        set:checkbox(
            gui_util.tr("hud_element.entry.box_start_expanded", item_config_key),
            item_config_key
        )
    then
        elem:set_start_expanded(elem_config.start_expanded)
        config.save_global()
    end

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_mantle_behavior"))

    item_config_key = config_key .. ".children.mantle.always_visible"
    if
        set:checkbox(
            gui_util.tr("hud_element.entry.box_always_visible", item_config_key),
            item_config_key
        )
    then
        elem.children.mantle:set_always_visible(elem_config.children.mantle.always_visible)
        config.save_global()
    end

    util_imgui.separator_text(
        config.lang:tr("hud_element.entry.category_expanded_itembar_behavior")
    )

    item_config_key = config_key .. ".children.all_slider.appear_open"
    if
        set:checkbox(
            gui_util.tr(
                "hud_element.entry.box_appear_open",
                item_config_key,
                "expanded_appear_open"
            ),
            item_config_key
        )
    then
        elem.children.all_slider:set_appear_open(elem_config.children.all_slider.appear_open)
        config.save_global()
    end

    item_config_key = config_key .. ".children.all_slider.ammo_visible"
    if
        set:checkbox(
            gui_util.tr("hud_element.entry.box_itembar_ammo_visible", item_config_key),
            item_config_key
        )
    then
        elem.children.all_slider:set_ammo_visible(elem_config.children.all_slider.ammo_visible)
        config.save_global()
    end

    item_config_key = config_key .. ".children.all_slider.slinger_visible"
    if
        set:checkbox(
            gui_util.tr("hud_element.entry.box_itembar_slinger_visible", item_config_key),
            item_config_key
        )
    then
        elem.children.all_slider:set_slinger_visible(
            elem_config.children.all_slider.slinger_visible
        )
        config.save_global()
    end

    item_config_key = config_key .. ".children.all_slider.disable_right_stick"
    if
        set:checkbox(
            gui_util.tr("hud_element.entry.box_itembar_disable_right_stick", item_config_key),
            item_config_key
        )
    then
        elem.children.all_slider:set_disable_right_stick(
            elem_config.children.all_slider.disable_right_stick
        )
        config.save_global()
    end

    item_config_key = config_key .. ".children.all_slider.enable_mouse_control"
    if
        set:checkbox(
            gui_util.tr("hud_element.entry.box_itembar_enable_mouse_control", item_config_key),
            item_config_key
        )
    then
        elem.children.all_slider:set_enable_mouse_control(
            elem_config.children.all_slider.enable_mouse_control
        )
        config.save_global()
    end

    item_config_key = config_key .. ".children.all_slider.control"
    local config_value = config:get(item_config_key)
    if
        set:slider_int(
            gui_util.tr("hud_element.entry.slider_expanded_itembar_control"),
            item_config_key,
            -1,
            #state.expanded_itembar_control - 1,
            (config_value == -1 and config.lang:tr("hud.option_disable"))
                or config.lang:tr(
                    "hud_element.entry." .. state.expanded_itembar_control[config_value + 1]
                )
        )
    then
        elem.children.all_slider:set_control(elem_config.children.all_slider.control)
        config.save_global()
    end

    item_config_key = config_key .. ".children.all_slider.decide_key"
    if not config:get(item_config_key .. "_combo") then
        config:set(
            item_config_key .. "_combo",
            state.combo.item_decide:get_index(config:get(item_config_key))
        )
    end

    if
        set:combo(
            gui_util.tr("hud_element.entry.combo_expanded_itembar_decide_key"),
            item_config_key .. "_combo",
            state.combo.item_decide.values
        )
    then
        local key = state.combo.item_decide:get_key(config:get(item_config_key .. "_combo"))
        elem.children.all_slider:set_decide_key(key)
        config:set(item_config_key, key)
        config.save_global()
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_notice(elem, elem_config, config_key)
    ---@cast elem_config NoticeConfig
    ---@cast elem Notice

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_tools"))
    local item_config_key = config_key .. ".tools_enemy_message_type"
    if not config:get(item_config_key .. "_combo") then
        config:set(
            item_config_key .. "_combo",
            state.combo.item_decide:get_index(config:get(item_config_key))
        )
    end

    if
        set:combo(
            gui_util.tr("hud_element.entry.category_notice_enemy"),
            item_config_key .. "_combo",
            state.combo.enemy_msg_type.values
        )
    then
        local key = state.combo.enemy_msg_type:get_key(config:get(item_config_key .. "_combo"))
        config:set(item_config_key, key)

        config.save_global()
    end

    imgui.same_line()

    if imgui.button(gui_util.tr("hud_element.entry.button_send", item_config_key)) then
        m.sendEnemyMessage(0, config:get(item_config_key))
    end

    item_config_key = config_key .. ".cache_msg"
    if
        set:checkbox(
            gui_util.tr("hud_element.entry.box_cache_messages", item_config_key),
            item_config_key
        )
    then
        elem:set_cache_msg(elem_config.cache_msg)
        config.save_global()
    end

    imgui.same_line()
    if imgui.button(gui_util.tr("hud_element.entry.button_clear", item_config_key)) then
        elem.message_log_cache:clear()
    end

    if elem_config.cache_msg then
        if
            imgui.begin_table(
                "notice_cached_messages",
                6,
                1 << 8 | 1 << 7 | 1 << 10 | 1 << 13 | 1 << 25 --[[@as ImGuiTableFlags]],
                Vector2f.new(0, 4 * 46)
            )
        then
            for _, header in ipairs({
                config.lang:tr("misc.text_row"),
                config.lang:tr("misc.text_type"),
                config.lang:tr("misc.text_sub_type"),
                config.lang:tr("misc.text_other_type"),
                config.lang:tr("misc.text_child_element"),
                config.lang:tr("misc.text_message"),
            }) do
                imgui.table_setup_column(header)
            end

            imgui.table_headers_row()
            for i = #elem.message_log_cache, 1, -1 do
                imgui.table_next_row()
                local entry = elem.message_log_cache[i]

                imgui.table_set_column_index(0)
                imgui.text(i)

                imgui.table_set_column_index(1)
                imgui.text(entry.type)

                imgui.table_set_column_index(2)
                imgui.text(entry.sub_type)

                imgui.table_set_column_index(3)
                imgui.text(entry.other_type)

                imgui.table_set_column_index(4)
                imgui.text(entry.cls)

                imgui.table_set_column_index(5)
                imgui.text(util_misc.trunc_string(entry.msg))
                util_imgui.tooltip(entry.msg)
            end

            imgui.end_table()
        end
    end

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_notice_system"))
    group_things(
        elem,
        elem_config.system_log,
        string.format("%s.%s", config_key, "system_log"),
        elem.set_system_log
    )

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_notice_enemy"))
    imgui.begin_disabled(elem_config.system_log.ALL or elem_config.system_log.ENEMY)
    group_things(
        elem,
        elem_config.enemy_log,
        string.format("%s.%s", config_key, "enemy_log"),
        elem.set_enemy_log
    )
    imgui.end_disabled()

    imgui.begin_disabled(elem_config.system_log.ALL or elem_config.system_log.CAMP)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_notice_camp"))
    group_things(
        elem,
        elem_config.camp_log,
        string.format("%s.%s", config_key, "camp_log"),
        elem.set_camp_log
    )
    imgui.end_disabled()

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_notice_lobby"))
    group_things(
        elem,
        elem_config.chat_log,
        string.format("%s.%s", config_key, "chat_log"),
        elem.set_chat_log
    )

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_notice_lobby_target"))
    group_things(
        elem,
        elem_config.lobby_log,
        string.format("%s.%s", config_key, "lobby_log"),
        elem.set_lobby_log
    )
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_name_access(elem, elem_config, config_key)
    ---@cast elem_config NameAccessConfig
    ---@cast elem NameAccess

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_npc_behavior"))
    local item_config_key = config_key .. ".npc_draw_distance"
    local config_value = config:get(item_config_key)
    if
        set:slider_float(
            gui_util.tr("hud_element.entry.slider_draw_distance"),
            item_config_key,
            0,
            50,
            (config_value == 0 and config.lang:tr("hud.option_disable")) or "%.1f"
        )
    then
        elem:set_npc_draw_distance(elem_config.npc_draw_distance)
        config.save_global()
    end

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_object_category"))
    group_things(
        elem,
        elem_config.object_category,
        string.format("%s.%s", config_key, "object_category"),
        elem.set_object_category
    )

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_npc_type"))
    group_things(
        elem,
        elem_config.npc_type,
        string.format("%s.%s", config_key, "npc_type"),
        elem.set_npc_type
    )

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_enemy_type"))
    group_things(
        elem,
        elem_config.enemy_type,
        string.format("%s.%s", config_key, "enemy_type"),
        elem.set_enemy_type
    )

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_panel_type"))
    group_things(
        elem,
        elem_config.panel_type,
        string.format("%s.%s", config_key, "panel_type"),
        elem.set_panel_type
    )

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_gossip_type"))
    group_things(
        elem,
        elem_config.gossip_type,
        string.format("%s.%s", config_key, "gossip_type"),
        elem.set_gossip_type
    )
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_name_other(elem, elem_config, config_key)
    ---@cast elem_config NameOtherConfig
    ---@cast elem NameOther

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_pl_behavior"))
    local item_config_key = config_key .. ".pl_draw_distance"
    local config_value = config:get(item_config_key)
    if
        set:slider_float(
            gui_util.tr("hud_element.entry.slider_draw_distance", item_config_key),
            item_config_key,
            0,
            50,
            (config_value == 0 and config.lang:tr("hud.option_disable")) or "%.1f"
        )
    then
        elem:set_pl_draw_distance(elem_config.pl_draw_distance)
        config.save_global()
    end

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_pet_behavior"))
    item_config_key = config_key .. ".pet_draw_distance"
    config_value = config:get(item_config_key)
    if
        set:slider_float(
            gui_util.tr("hud_element.entry.slider_draw_distance", item_config_key),
            item_config_key,
            0,
            50,
            (config_value == 0 and config.lang:tr("hud.option_disable")) or "%.1f"
        )
    then
        elem:set_pet_draw_distance(elem_config.pet_draw_distance)
        config.save_global()
    end

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_nameplate_type"))
    group_things(
        elem,
        elem_config.nameplate_type,
        string.format("%s.%s", config_key, "nameplate_type"),
        elem.set_nameplate_type
    )
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_ammo(elem, elem_config, config_key)
    ---@cast elem_config AmmoConfig
    ---@cast elem Ammo

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_parts_behavior"))
    local item_config_key = config_key .. ".no_hide_parts"
    if
        set:checkbox(gui_util.tr("hud_element.entry.box_no_hide", item_config_key), item_config_key)
    then
        elem:set_no_hide_parts(elem_config.no_hide_parts)
        config.save_global()
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_radial(elem, elem_config, config_key)
    ---@cast elem_config RadialConfig
    ---@cast elem Radial

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_radial_behavior"))
    local item_config_key = config_key .. ".expanded"
    if
        set:checkbox(
            gui_util.tr("hud_element.entry.box_always_expanded", item_config_key),
            item_config_key
        )
    then
        elem:set_expanded(elem_config.expanded)
        config.save_global()
    end

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_pallet_behavior"))
    item_config_key = config_key .. ".children.pallet.expanded"
    if
        set:checkbox(
            gui_util.tr("hud_element.entry.box_always_expanded", item_config_key),
            item_config_key
        )
    then
        elem.children.pallet:set_expanded(elem_config.children.pallet.expanded)
        config.save_global()
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_slinger_reticle(elem, elem_config, config_key)
    ---@cast elem_config SlingerReticleConfig
    ---@cast elem SlingerReticle

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_slinger_behavior"))
    local item_config_key = config_key .. ".children.slinger.hide_slinger_empty"
    if
        set:checkbox(
            gui_util.tr("hud_element.entry.box_hide_slinger_empty", item_config_key),
            item_config_key
        )
    then
        elem.children.slinger:set_hide_slinger_empty(
            elem_config.children.slinger.hide_slinger_empty
        )
        config.save_global()
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_sharpness(elem, elem_config, config_key)
    ---@cast elem_config SharpnessConfig
    ---@cast elem Sharpness

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_state_behavior"))
    local item_config_key = config_key .. ".state"
    local config_value = config:get(item_config_key)
    if
        set:slider_int(
            gui_util.tr("hud_element.entry.state"),
            item_config_key,
            -1,
            #state.sharpnes_state - 1,
            (config_value == -1 and config.lang:tr("hud.option_disable"))
                or config.lang:tr("hud_element.entry." .. state.sharpnes_state[config_value + 1])
        )
    then
        elem:set_state(elem_config.state)
        config.save_global()
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_clock(elem, elem_config, config_key)
    ---@cast elem_config ClockConfig
    ---@cast elem Clock

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_clock_behavior"))
    local item_config_key = config_key .. ".hide_map_visible"
    if
        set:checkbox(
            gui_util.tr("hud_element.entry.box_hide_map_visible", item_config_key),
            item_config_key
        )
    then
        elem:set_hide_map_visible(elem_config.hide_map_visible)
        config.save_global()
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_shortcut_keyboard(elem, elem_config, config_key)
    ---@cast elem_config ShortcutKeyboardConfig
    ---@cast elem ShortcutKeyboard

    util_imgui.separator_text(
        config.lang:tr("hud_element.entry.category_shortcut_keyboard_behavior")
    )
    local item_config_key = config_key .. ".no_hide_elements"
    if
        set:checkbox(
            gui_util.tr("hud_element.entry.box_no_hide_elements", item_config_key),
            item_config_key
        )
    then
        elem:set_no_hide_elements(elem_config.no_hide_elements)
        config.save_global()
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
function this.draw(elem, elem_config, config_key)
    local f = this.funcs[
        elem_config.hud_type --[[@as HudType]]
    ]
    if f then
        f(elem, elem_config, config_key)
    end
end

this.funcs[mod.enum.hud_type.WEAPON] = draw_weapon
this.funcs[mod.enum.hud_type.ITEMBAR] = draw_itembar
this.funcs[mod.enum.hud_type.NOTICE] = draw_notice
this.funcs[mod.enum.hud_type.NAME_ACCESS] = draw_name_access
this.funcs[mod.enum.hud_type.NAME_OTHER] = draw_name_other
this.funcs[mod.enum.hud_type.AMMO] = draw_ammo
this.funcs[mod.enum.hud_type.RADIAL] = draw_radial
this.funcs[mod.enum.hud_type.SLINGER_RETICLE] = draw_slinger_reticle
this.funcs[mod.enum.hud_type.SHARPNESS] = draw_sharpness
this.funcs[mod.enum.hud_type.CLOCK] = draw_clock
this.funcs[mod.enum.hud_type.SHORTCUT_KEYBOARD] = draw_shortcut_keyboard

return this
