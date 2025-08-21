local bind_manager = require("HudController.hud.bind")
local config = require("HudController.config")
local data = require("HudController.data")
local fade_manager = require("HudController.hud.fade")
local gui_debug = require("HudController.gui.debug")
local gui_selector = require("HudController.gui.elements.selector")
local gui_util = require("HudController.gui.util")
local hud = require("HudController.hud")
local set = require("HudController.gui.set")
local state = require("HudController.gui.state")
local util_ace = require("HudController.util.ace")
local util_bind = require("HudController.util.game.bind")
local util_imgui = require("HudController.util.imgui")
local util_table = require("HudController.util.misc.table")

local ace_map = data.ace.map
local mod = data.mod

local this = {}

---@param label string
---@param draw_func fun()
---@param enabled_obj boolean?
---@return boolean
local function draw_menu(label, draw_func, enabled_obj)
    enabled_obj = enabled_obj == nil and true or enabled_obj

    local menu = imgui.begin_menu(label, enabled_obj)
    if menu then
        imgui.spacing()
        imgui.indent(2)

        draw_func()

        imgui.unindent(2)
        imgui.spacing()
        imgui.end_menu()
    end

    return menu
end

local function draw_mod_menu()
    local config_mod = config.current.mod

    if imgui.menu_item(gui_util.tr("menu.config.enabled"), nil, config_mod.enabled) then
        config_mod.enabled = not config_mod.enabled
        hud.reset_elements()
        config.save_global()
    end

    if imgui.menu_item(gui_util.tr("menu.config.enable_fade"), nil, config_mod.enable_fade) then
        config_mod.enable_fade = not config_mod.enable_fade
        fade_manager.abort()
        config.save_global()
    end

    if imgui.menu_item(gui_util.tr("menu.config.enable_notification"), nil, config_mod.enable_notification) then
        config_mod.enable_notification = not config_mod.enable_notification
        config.save_global()
    end

    if imgui.menu_item(gui_util.tr("menu.config.enable_weapon_binds"), nil, config_mod.enable_weapon_binds) then
        config_mod.enable_weapon_binds = not config_mod.enable_weapon_binds
        config.save_global()
    end

    if imgui.menu_item(gui_util.tr("menu.config.enable_key_binds"), nil, config_mod.enable_key_binds) then
        config_mod.enable_key_binds = not config_mod.enable_key_binds
        config.save_global()
    end

    imgui.separator()

    if
        imgui.menu_item(
            gui_util.tr("menu.config.disable_weapon_binds_timed"),
            nil,
            config_mod.disable_weapon_binds_timed
        )
    then
        config_mod.disable_weapon_binds_timed = not config_mod.disable_weapon_binds_timed
        config.save_global()
    end
    util_imgui.tooltip(config.lang:tr("menu.config.disable_weapon_binds_timed_tooltip"))

    imgui.begin_disabled(not config_mod.disable_weapon_binds_timed)
    local item_config_key = "mod.disable_weapon_binds_time"
    local item_value = config:get(item_config_key)
    if
        set.slider_int(
            "##" .. item_config_key,
            item_config_key,
            1,
            300,
            gui_util.seconds_to_minutes_string(item_value, "%.0f")
        )
    then
        config.save_global()
    end
    imgui.end_disabled()

    if
        imgui.menu_item(gui_util.tr("menu.config.disable_weapon_binds_held"), nil, config_mod.disable_weapon_binds_held)
    then
        config_mod.disable_weapon_binds_held = not config_mod.disable_weapon_binds_held
        config.save_global()
    end
    util_imgui.tooltip(config.lang:tr("menu.config.disable_weapon_binds_held_tooltip"))
end

local function draw_lang_menu()
    local config_lang = config.current.mod.lang

    for i = 1, #config.lang.sorted do
        local menu_item = config.lang.sorted[i]
        if imgui.menu_item(menu_item, nil, config_lang.file == menu_item) then
            config_lang.file = menu_item
            config.lang:change()
            state.translate_combo()
            config.save_global()
        end
    end

    imgui.separator()

    if imgui.menu_item(gui_util.tr("menu.language.fallback"), nil, config_lang.fallback) then
        config_lang.fallback = not config_lang.fallback
        config.save_global()
    end
    util_imgui.tooltip(config.lang:tr("menu.language.fallback_tooltip"))
end

local function draw_key_bind_menu()
    local config_mod = config.current.mod

    if
        set.slider_int(
            gui_util.tr("menu.bind.key.slider_buffer"),
            "mod.bind.key.buffer",
            1,
            11,
            config_mod.bind.key.buffer - 1 == 0 and config.lang:tr("misc.text_disabled")
                or config_mod.bind.key.buffer - 1 == 1 and string.format(
                    "%s %s",
                    config_mod.bind.key.buffer - 1,
                    config.lang:tr("misc.text_frame")
                )
                or string.format("%s %s", config_mod.bind.key.buffer - 1, config.lang:tr("misc.text_frame_plural"))
        )
    then
        bind_manager.monitor:set_max_buffer_frame(config_mod.bind.key.buffer)
        config:save()
    end
    util_imgui.tooltip(config.lang:tr("menu.bind.key.tooltip_buffer"))

    imgui.separator()

    if
        set.slider_int(
            gui_util.tr("menu.bind.key.slider_bind_type"),
            "mod.bind.slider.key_bind",
            1,
            3,
            config_mod.bind.slider.key_bind == 1 and config.lang:tr("menu.bind.key.hud")
                or config_mod.bind.slider.key_bind == 2 and config.lang:tr("menu.bind.key.option")
                or config_mod.bind.slider.key_bind == 3 and config.lang:tr("menu.bind.key.option_mod")
        )
    then
        state.listener = nil
        bind_manager.monitor:unpause()
    end

    local spacing = 4
    local width = imgui.calc_item_width() / 2 - spacing

    imgui.begin_disabled(
        state.listener ~= nil or config_mod.bind.slider.key_bind == 1 and util_table.empty(config_mod.hud)
    )

    ---@type ModBindManager
    local manager
    ---@type string
    local config_key
    if config_mod.bind.slider.key_bind == 1 then
        manager = bind_manager.hud
        config_key = "mod.bind.key.hud"
        set.combo("##bind_hud_combo", "mod.combo.key_bind.hud", state.combo.hud.values)
    elseif config_mod.bind.slider.key_bind == 2 then
        manager = bind_manager.option_hud
        config_key = "mod.bind.key.option_hud"

        imgui.push_item_width(width)

        set.combo("##bind_option_combo", "mod.combo.key_bind.option_hud", state.combo.option_bind.values)
        imgui.same_line()
        set.combo("##bind_action_type_combo", "mod.combo.key_bind.action_type", state.combo.bind_action_type.values)
        util_imgui.tooltip(config.lang:tr("menu.bind.key.tooltip_action_type"))

        imgui.pop_item_width()
    elseif config_mod.bind.slider.key_bind == 3 then
        manager = bind_manager.option_mod
        config_key = "mod.bind.key.option_mod"

        imgui.push_item_width(width)

        set.combo("##bind_option_mod_combo", "mod.combo.key_bind.option_mod", state.combo.option_mod_bind.values)
        imgui.same_line()
        set.combo("##bind_action_type_combo", "mod.combo.key_bind.action_type", state.combo.bind_action_type.values)
        util_imgui.tooltip(config.lang:tr("menu.bind.key.tooltip_action_type"))

        imgui.pop_item_width()
    end

    imgui.same_line()

    if imgui.button(gui_util.tr("menu.bind.key.button_add")) then
        ---@type string | HudProfileConfig
        local opt
        ---@type string
        local opt_name
        if manager.name == bind_manager.manager_names.HUD then
            opt = config_mod.hud[config_mod.combo.key_bind.hud]
            opt_name = opt.name
        elseif manager.name == bind_manager.manager_names.OPTION_HUD then
            opt = state.combo.option_bind:get_key(config_mod.combo.key_bind.option_hud)
            opt_name = state.combo.option_bind:get_value(config_mod.combo.key_bind.option_hud)
        elseif manager.name == bind_manager.manager_names.OPTION_MOD then
            opt = state.combo.option_mod_bind:get_key(config_mod.combo.key_bind.option_mod)
            opt_name = state.combo.option_mod_bind:get_value(config_mod.combo.key_bind.option_mod)
        end

        state.listener = {
            opt = opt,
            listener = util_bind.listener:new(),
            opt_name = opt_name,
        }
    end

    imgui.end_disabled()

    if state.listener then
        bind_manager.monitor:pause()

        imgui.separator()

        local bind = state.listener.listener:listen() --[[@as ModBind]]
        ---@type string[]
        local bind_name

        if bind.name ~= "" then
            bind_name = { state.listener.listener:get_name_ordered(bind), "..." }
        else
            bind_name = { config.lang:tr("menu.bind.key.text_default") }
        end

        imgui.begin_table("keybind_listener", 1, 1 << 9)
        imgui.table_next_row()

        util_imgui.adjust_pos(0, 3)

        imgui.table_set_column_index(0)

        if manager:is_valid(bind) then
            if manager.name == bind_manager.manager_names.HUD then
                bind.bound_value = state.listener.opt.key
                bind.action_type = bind_manager.action_type.NONE
            else
                ---@diagnostic disable-next-line: assign-type-mismatch
                bind.bound_value = state.listener.opt
                bind.action_type = state.combo.bind_action_type:get_key(config_mod.combo.key_bind.action_type)
            end

            local is_col, col = manager:is_collision(bind)
            if is_col and col then
                ---@type string
                local col_name
                if manager.name == bind_manager.manager_names.HUD then
                    col_name = util_table.value(config_mod.hud, function(key, value)
                        return col.bound_value == value.key
                    end).name
                elseif manager.name == bind_manager.manager_names.OPTION_HUD then
                    col_name = config.lang:tr("hud." .. mod.map.options_hud[col.bound_value])
                elseif manager.name == bind_manager.manager_names.OPTION_MOD then
                    col_name = config.lang:tr("menu.config." .. mod.map.options_mod[col.bound_value])
                end

                state.listener.collision = string.format("%s %s", config.lang:tr("menu.bind.tooltip_bound"), col_name)
            else
                state.listener.collision = nil
            end
        else
            state.listener.collision = nil
        end

        imgui.begin_disabled(state.listener.collision ~= nil or bind.name == "")

        local save_button = imgui.button(gui_util.tr("menu.bind.key.button_save"))

        if save_button then
            manager:register(bind)
            config:set(config_key, manager:get_base_binds())

            config.save_global()
            state.listener = nil
            bind_manager.monitor:unpause()
        end

        imgui.end_disabled()
        imgui.same_line()

        if imgui.button(gui_util.tr("menu.bind.key.button_clear")) then
            state.listener.listener:clear()
        end

        imgui.same_line()

        if imgui.button(gui_util.tr("menu.bind.key.button_cancel")) then
            state.listener = nil
            bind_manager.monitor:unpause()
        end

        imgui.end_table()
        imgui.separator()

        if state.listener and state.listener.collision then
            imgui.text_colored(state.listener.collision, state.colors.bad)
            imgui.separator()
        end

        imgui.text(table.concat(bind_name, " + "))
        imgui.separator()
    end

    if not util_table.empty(config:get(config_key)) and imgui.begin_table("keybind_state", 4, 1 << 9) then
        imgui.separator()

        ---@type ModBind[]
        local remove = {}
        local binds = config:get(config_key) --[=[@as ModBind[]]=]
        for i = 1, #binds do
            local bind = binds[i]
            ---@type string
            local opt_name

            if manager.name == bind_manager.manager_names.HUD then
                ---@diagnostic disable-next-line: param-type-mismatch
                opt_name = hud.operations.get_hud_by_key(bind.bound_value).name
            elseif manager.name == bind_manager.manager_names.OPTION_HUD then
                opt_name = config.lang:tr("hud." .. mod.map.options_hud[bind.bound_value])
            elseif manager.name == bind_manager.manager_names.OPTION_MOD then
                opt_name = config.lang:tr("menu.config." .. mod.map.options_mod[bind.bound_value])
            end

            imgui.table_next_row()

            imgui.table_set_column_index(0)

            if imgui.button(gui_util.tr("menu.bind.key.button_remove", bind.name, bind.bound_value)) then
                table.insert(remove, bind)
            end

            imgui.table_set_column_index(1)
            imgui.text(opt_name)
            imgui.table_set_column_index(2)
            imgui.text(bind.name)
            imgui.table_set_column_index(3)

            imgui.text(
                bind.action_type ~= bind_manager.action_type.NONE
                        and config.lang:tr("menu.bind.key.action_type." .. bind.action_type)
                    or ""
            )
        end

        if not util_table.empty(remove) then
            for _, bind in pairs(remove) do
                manager:unregister(bind)
            end

            config:set(config_key, manager:get_base_binds())
            config.save_global()
        end

        imgui.end_table()
    end
end

local function draw_weapon_bind_menu()
    local config_mod = config.current.mod

    imgui.begin_disabled(util_table.empty(config_mod.hud))

    local changed = false
    changed = set.checkbox(gui_util.tr("menu.bind.weapon.quest_in_combat"), "mod.bind.weapon.quest_in_combat")
    changed = set.checkbox(gui_util.tr("menu.bind.weapon.ride_ignore_combat"), "mod.bind.weapon.ride_ignore_combat")
        or changed
    util_imgui.tooltip(config.lang:tr("menu.bind.weapon.ride_ignore_combat_tooltip"), true)
    changed = set.slider_int(
        gui_util.tr("menu.bind.weapon.out_of_combat_delay"),
        "mod.bind.weapon.out_of_combat_delay",
        0,
        600,
        config_mod.bind.weapon.out_of_combat_delay == 0 and config.lang:tr("misc.text_disabled")
            or gui_util.seconds_to_minutes_string(config_mod.bind.weapon.out_of_combat_delay, nil, true)
    ) or changed
    changed = set.slider_int(
        gui_util.tr("menu.bind.weapon.in_combat_delay"),
        "mod.bind.weapon.in_combat_delay",
        0,
        600,
        config_mod.bind.weapon.in_combat_delay == 0 and config.lang:tr("misc.text_disabled")
            or gui_util.seconds_to_minutes_string(config_mod.bind.weapon.in_combat_delay, nil, true)
    ) or changed

    if changed then
        config.save_global()
    end

    imgui.separator()

    set.slider_int(
        gui_util.tr("menu.bind.weapon.game_mode"),
        "mod.bind.slider.weapon_bind",
        1,
        2,
        config_mod.bind.slider.weapon_bind == 1 and config.lang:tr("menu.bind.weapon.singleplayer")
            or config.lang:tr("menu.bind.weapon.multiplayer")
    )

    local key = config_mod.bind.slider.weapon_bind == 1 and "singleplayer" or "multiplayer"
    local sorted = util_table.sort(
        util_table.values(config_mod.bind.weapon[key]) --[=[@as WeaponBindConfig[]]=],
        function(a, b)
            local a_id = util_table.index(ace_map.additional_weapon, a.name)
            local b_id = util_table.index(ace_map.additional_weapon, b.name)
            a_id = a_id and -a_id or a.weapon_id
            b_id = b_id and -b_id or b.weapon_id
            return a_id < b_id
        end
    ) --[[@as table<integer, WeaponBindConfig>]]

    if imgui.begin_table("weapon_state", 5) then
        for _, header in ipairs({
            gui_util.tr("menu.bind.weapon.header_enabled"),
            gui_util.tr("menu.bind.weapon.header_combat_in"),
            gui_util.tr("menu.bind.weapon.header_combat_out"),
            gui_util.tr("menu.bind.weapon.header_camp"),
            gui_util.tr("menu.bind.weapon.header_weapon_name"),
        }) do
            imgui.table_setup_column(header)
        end

        imgui.table_headers_row()

        for i = 1, #sorted do
            imgui.table_next_row()
            imgui.table_set_column_index(0)

            local weapon = sorted[i]

            imgui.begin_disabled(
                weapon.name ~= "GLOBAL" and config:get(string.format("mod.bind.weapon.%s.%s.enabled", key, "GLOBAL"))
            )

            changed = false
            local config_key = string.format("mod.bind.weapon.%s.%s.enabled", key, weapon.name)
            if set.checkbox(string.format("##%s", weapon.name), config_key) then
                changed = true
            end

            local function draw_combo(sub_key)
                imgui.push_item_width(100)

                config_key = string.format("mod.bind.weapon.%s.%s.%s.combo", key, weapon.name, sub_key)
                changed = set.combo(
                    string.format("##%s_%s_%s", weapon.name, sub_key, key),
                    config_key,
                    state.combo.hud.values
                ) or changed

                if changed then
                    config:set(
                        string.format("mod.bind.weapon.%s.%s.%s.hud_key", key, weapon.name, sub_key),
                        config_mod.hud[config:get(config_key)].key
                    )
                    config.save_global()
                end

                imgui.pop_item_width()
            end

            imgui.table_set_column_index(1)
            imgui.begin_disabled(not config:get(config_key))
            draw_combo("combat_in")

            imgui.table_set_column_index(2)
            draw_combo("combat_out")

            imgui.table_set_column_index(3)
            draw_combo("camp")

            imgui.table_set_column_index(4)
            imgui.text(
                weapon.weapon_id < 0 and config.lang:tr("menu.bind.weapon.name_" .. weapon.name:lower())
                    or ace_map.weaponid_name_to_local_name[weapon.name]
            )
            imgui.end_disabled()
            imgui.end_disabled()
        end

        imgui.end_table()
    end

    imgui.end_disabled()
end

local function draw_bind_menu()
    if not draw_menu(gui_util.tr("menu.bind.key.name"), draw_key_bind_menu) then
        state.listener = nil
        bind_manager.monitor:unpause()
    end

    draw_menu(gui_util.tr("menu.bind.weapon.name"), draw_weapon_bind_menu)
end

local function draw_grid_menu()
    local changed = false
    if set.checkbox(gui_util.tr("menu.grid.box_draw"), "mod.grid.draw") then
        util_ace.scene_fade.reset()
        changed = true
    end

    changed = set.slider_int(
        gui_util.tr("menu.grid.combo_ratio"),
        "mod.grid.combo_grid_ratio",
        1,
        #state.grid_ratio,
        state.grid_ratio[config:get("mod.grid.combo_grid_ratio")]
    ) or changed
    changed = set.color_edit(gui_util.tr("menu.grid.color_center"), "mod.grid.color_center") or changed
    changed = set.color_edit(gui_util.tr("menu.grid.color_grid"), "mod.grid.color_grid") or changed
    changed = set.color_edit(gui_util.tr("menu.grid.color_fade"), "mod.grid.color_fade") or changed
    changed = set.slider_float(gui_util.tr("menu.grid.fade_alpha"), "mod.grid.fade_alpha", 0, 1, "%.2f") or changed

    if changed then
        config.save_global()
    end
end

function this.draw()
    draw_menu(gui_util.tr("menu.config.name"), draw_mod_menu)
    draw_menu(gui_util.tr("menu.language.name"), draw_lang_menu)
    draw_menu(gui_util.tr("menu.grid.name"), draw_grid_menu)
    draw_menu(gui_util.tr("menu.bind.name"), draw_bind_menu)

    if imgui.button(gui_util.tr("selector.name")) then
        mod.pause = true
        gui_selector.is_opened = true
        gui_debug.close()
        config.save_global()
        config.selector:reload()
        state.combo.config:swap(config.selector.sorted)
        state.combo.config_backup:swap(config.selector.sorted_backup)
    end

    if imgui.button(gui_util.tr("debug.name")) then
        local config_debug = config.gui.current.gui.debug
        config_debug.is_opened = not config_debug.is_opened
        config.save_global()
    end
end

return this
