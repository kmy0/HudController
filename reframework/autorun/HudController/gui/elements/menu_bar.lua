local bind_manager = require("HudController.hud.bind.init")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local fade_manager = require("HudController.hud.fade.init")
local gui_debug = require("HudController.gui.debug")
local gui_selector = require("HudController.gui.elements.selector")
local gui_util = require("HudController.gui.util")
local hud = require("HudController.hud.init")
local state = require("HudController.gui.state")
local user = require("HudController.hud.user")
local util_ace = require("HudController.util.ace.init")
local util_bind = require("HudController.util.game.bind.init")
local util_imgui = require("HudController.util.imgui.init")
local util_table = require("HudController.util.misc.table")

local ace_map = data.ace.map
local mod = data.mod
local set = state.set

local this = {}

---@param label string
---@param draw_func fun()
---@param enabled_obj boolean?
---@param text_color integer?
---@return boolean
local function draw_menu(label, draw_func, enabled_obj, text_color)
    enabled_obj = enabled_obj == nil and true or enabled_obj

    if text_color then
        imgui.push_style_color(0, text_color)
    end

    local menu = imgui.begin_menu(label, enabled_obj)

    if text_color then
        imgui.pop_style_color(1)
    end

    if menu then
        draw_func()
        imgui.end_menu()
    end

    return menu
end

local function draw_user_scripts_menu()
    imgui.push_style_var(14, Vector2f.new(0, 2))

    local config_mod = config.current.mod

    local sorted = util_table.sort(util_table.keys(config_mod.user_scripts))

    if util_table.empty(sorted) then
        imgui.text(config.lang:tr("menu.user_scripts.text_no_scripts"))
    end

    for i = 1, #sorted do
        local name = sorted[i]
        local pop_color = false

        if user.failed[name] ~= nil then
            imgui.push_style_color(0, state.colors.bad)
            pop_color = true
        elseif config_mod.user_scripts[name] ~= (user.loaded[name] ~= nil) then
            imgui.push_style_color(0, state.colors.info)
            pop_color = true
        end

        if util_imgui.menu_item(name, config_mod.user_scripts[name]) then
            config_mod.user_scripts[name] = not config_mod.user_scripts[name]
            config:save()
        end

        if pop_color then
            imgui.pop_style_color(1)
        end

        if user.failed[name] ~= nil then
            util_imgui.tooltip(user.failed[name])
        elseif config_mod.user_scripts[name] ~= (user.loaded[name] ~= nil) then
            util_imgui.tooltip(config.lang:tr("misc.text_reset_required"))
        end
    end

    imgui.pop_style_var(1)
end

local function draw_mod_menu()
    local config_mod = config.current.mod
    imgui.push_style_var(14, Vector2f.new(0, 2))

    if set:menu_item(gui_util.tr("menu.config.enabled"), "mod.enabled") then
        hud.reset_elements()
    end

    if set:menu_item(gui_util.tr("menu.config.enable_fade"), "mod.enable_fade") then
        fade_manager.abort()
    end

    set:menu_item(gui_util.tr("menu.config.enable_notification"), "mod.enable_notification")
    set:menu_item(gui_util.tr("menu.config.enable_weapon_binds"), "mod.enable_weapon_binds")
    set:menu_item(gui_util.tr("menu.config.enable_key_binds"), "mod.enable_key_binds")

    imgui.separator()

    set:menu_item(
        gui_util.tr("menu.config.disable_weapon_binds_timed"),
        "mod.disable_weapon_binds_timed"
    )
    util_imgui.tooltip(config.lang:tr("menu.config.disable_weapon_binds_timed_tooltip"))

    imgui.begin_disabled(not config_mod.disable_weapon_binds_timed)
    imgui.indent(2)
    local item_config_key = "mod.disable_weapon_binds_time"
    local item_value = config:get(item_config_key)
    set:slider_int(
        "##" .. item_config_key,
        item_config_key,
        1,
        300,
        gui_util.seconds_to_minutes_string(item_value, "%.0f")
    )

    imgui.end_disabled()
    imgui.unindent(2)

    set:menu_item(
        gui_util.tr("menu.config.disable_weapon_binds_held"),
        "mod.disable_weapon_binds_held"
    )
    util_imgui.tooltip(config.lang:tr("menu.config.disable_weapon_binds_held_tooltip"))

    imgui.pop_style_var(1)
end

local function draw_lang_menu()
    local config_lang = config.current.mod.lang
    imgui.push_style_var(14, Vector2f.new(0, 2))

    for i = 1, #config.lang.sorted do
        local menu_item = config.lang.sorted[i]
        if util_imgui.menu_item(menu_item, config_lang.file == menu_item) then
            config_lang.file = menu_item
            config.lang:change()
            state.translate_combo()
            config:save()
        end
    end

    imgui.separator()

    set:menu_item(gui_util.tr("menu.language.fallback"), "mod.lang.fallback")
    util_imgui.tooltip(config.lang:tr("menu.language.fallback_tooltip"))

    imgui.pop_style_var(1)
end

local function draw_key_bind_menu()
    imgui.spacing()
    imgui.indent(2)

    local config_mod = config.current.mod

    if
        set:slider_int(
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
                or string.format(
                    "%s %s",
                    config_mod.bind.key.buffer - 1,
                    config.lang:tr("misc.text_frame_plural")
                )
        )
    then
        bind_manager.monitor:set_max_buffer_frame(config_mod.bind.key.buffer)
    end
    util_imgui.tooltip(config.lang:tr("menu.bind.key.tooltip_buffer"))

    imgui.separator()

    if
        set:slider_int(
            gui_util.tr("menu.bind.key.slider_bind_type"),
            "mod.bind.slider.key_bind",
            1,
            3,
            ---@diagnostic disable-next-line: param-type-mismatch
            (config_mod.bind.slider.key_bind == 1 and config.lang:tr("menu.bind.key.hud"))
                or (config_mod.bind.slider.key_bind == 2 and config.lang:tr("menu.bind.key.option"))
                or (
                    config_mod.bind.slider.key_bind == 3
                    and config.lang:tr("menu.bind.key.option_mod")
                )
        )
    then
        state.listener = nil
        bind_manager.monitor:unpause()
    end

    local spacing = 4
    local width = imgui.calc_item_width() / 2 - spacing

    imgui.begin_disabled(
        state.listener ~= nil
            or config_mod.bind.slider.key_bind == 1 and util_table.empty(config_mod.hud)
    )

    ---@type ModBindManager
    local manager
    ---@type string
    local config_key
    if config_mod.bind.slider.key_bind == 1 then
        manager = bind_manager.hud
        config_key = "mod.bind.key.hud"
        set:combo("##bind_hud_combo", "mod.combo.key_bind.hud", state.combo.hud.values)
    elseif config_mod.bind.slider.key_bind == 2 then
        manager = bind_manager.option_hud
        config_key = "mod.bind.key.option_hud"

        imgui.push_item_width(width)

        set:combo(
            "##bind_option_combo",
            "mod.combo.key_bind.option_hud",
            state.combo.option_bind.values
        )
        imgui.same_line()
        set:combo(
            "##bind_action_type_combo",
            "mod.combo.key_bind.action_type",
            state.combo.bind_action_type.values
        )
        util_imgui.tooltip(config.lang:tr("menu.bind.key.tooltip_action_type"))

        imgui.pop_item_width()
    elseif config_mod.bind.slider.key_bind == 3 then
        manager = bind_manager.option_mod
        config_key = "mod.bind.key.option_mod"

        imgui.push_item_width(width)

        set:combo(
            "##bind_option_mod_combo",
            "mod.combo.key_bind.option_mod",
            state.combo.option_mod_bind.values
        )
        imgui.same_line()
        set:combo(
            "##bind_action_type_combo",
            "mod.combo.key_bind.action_type",
            state.combo.bind_action_type.values
        )
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

        if bind.name_display ~= "" then
            bind_name = { bind.name_display, "..." }
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
                bind.action_type =
                    state.combo.bind_action_type:get_key(config_mod.combo.key_bind.action_type)
            end

            local is_col, col = manager:is_collision(bind)
            if is_col and col then
                ---@type string
                local col_name
                if manager.name == bind_manager.manager_names.HUD then
                    col_name = util_table.value(config_mod.hud, function(_, value)
                        return col.bound_value == value.key
                    end).name
                elseif manager.name == bind_manager.manager_names.OPTION_HUD then
                    col_name = config.lang:tr("hud." .. mod.map.options_hud[col.bound_value])
                elseif manager.name == bind_manager.manager_names.OPTION_MOD then
                    col_name =
                        config.lang:tr("menu.config." .. mod.map.options_mod[col.bound_value])
                end

                state.listener.collision =
                    string.format("%s %s", config.lang:tr("menu.bind.tooltip_bound"), col_name)
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

            config:save()
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

    if
        not util_table.empty(config:get(config_key))
        and imgui.begin_table("keybind_state", 4, 1 << 9)
    then
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

            if
                imgui.button(
                    gui_util.tr("menu.bind.key.button_remove", bind.name, bind.bound_value)
                )
            then
                table.insert(remove, bind)
            end

            imgui.table_set_column_index(1)
            imgui.text(opt_name)
            imgui.table_set_column_index(2)
            imgui.text(bind.name_display)
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
        end

        imgui.end_table()
    end

    imgui.unindent(2)
    imgui.spacing()
end

local function draw_weapon_bind_menu()
    imgui.spacing()
    imgui.indent(2)

    local config_mod = config.current.mod

    imgui.begin_disabled(util_table.empty(config_mod.hud))

    set:checkbox(gui_util.tr("menu.bind.weapon.quest_in_combat"), "mod.bind.weapon.quest_in_combat")
    set:checkbox(
        gui_util.tr("menu.bind.weapon.ride_ignore_combat"),
        "mod.bind.weapon.ride_ignore_combat"
    )
    util_imgui.tooltip(config.lang:tr("menu.bind.weapon.ride_ignore_combat_tooltip"), true)
    set:slider_int(
        gui_util.tr("menu.bind.weapon.out_of_combat_delay"),
        "mod.bind.weapon.out_of_combat_delay",
        0,
        600,
        config_mod.bind.weapon.out_of_combat_delay == 0 and config.lang:tr("misc.text_disabled")
            or gui_util.seconds_to_minutes_string(
                config_mod.bind.weapon.out_of_combat_delay,
                nil,
                true
            )
    )
    set:slider_int(
        gui_util.tr("menu.bind.weapon.in_combat_delay"),
        "mod.bind.weapon.in_combat_delay",
        0,
        600,
        config_mod.bind.weapon.in_combat_delay == 0 and config.lang:tr("misc.text_disabled")
            or gui_util.seconds_to_minutes_string(config_mod.bind.weapon.in_combat_delay, nil, true)
    )

    imgui.separator()

    set:slider_int(
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
            local a_id = util_table.index(ace_map.weapon_binds.additional_weapon, a.name)
            local b_id = util_table.index(ace_map.weapon_binds.additional_weapon, b.name)
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
                weapon.name ~= "GLOBAL"
                    and config:get(string.format("mod.bind.weapon.%s.%s.enabled", key, "GLOBAL"))
            )

            local config_key = string.format("mod.bind.weapon.%s.%s.enabled", key, weapon.name)
            local changed = set:checkbox(string.format("##%s", weapon.name), config_key)

            local function draw_combo(sub_key)
                imgui.push_item_width(100)

                config_key =
                    string.format("mod.bind.weapon.%s.%s.%s.combo", key, weapon.name, sub_key)
                changed = set:combo(
                    string.format("##%s_%s_%s", weapon.name, sub_key, key),
                    config_key,
                    state.combo.hud.values
                ) or changed

                if changed then
                    config:set(
                        string.format("mod.bind.weapon.%s.%s.%s.hud_key", key, weapon.name, sub_key),
                        config_mod.hud[config:get(config_key)].key
                    )
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
                weapon.weapon_id < 0
                        and config.lang:tr("menu.bind.weapon.name_" .. weapon.name:lower())
                    or ace_map.weaponid_name_to_local_name[weapon.name]
            )
            imgui.end_disabled()
            imgui.end_disabled()
        end

        imgui.end_table()
    end

    imgui.end_disabled()

    imgui.unindent(2)
    imgui.spacing()
end

local function draw_bind_menu()
    imgui.spacing()
    imgui.indent(2)

    if not draw_menu(gui_util.tr("menu.bind.key.name"), draw_key_bind_menu) then
        state.listener = nil
        bind_manager.monitor:unpause()
    end

    draw_menu(gui_util.tr("menu.bind.weapon.name"), draw_weapon_bind_menu)

    imgui.unindent(2)
    imgui.spacing()
end

local function draw_grid_menu()
    imgui.spacing()
    imgui.indent(2)

    if set:checkbox(gui_util.tr("menu.grid.box_draw"), "mod.grid.draw") then
        util_ace.scene_fade.reset()
    end

    set:slider_int(
        gui_util.tr("menu.grid.combo_ratio"),
        "mod.grid.combo_grid_ratio",
        1,
        #state.grid_ratio,
        state.grid_ratio[config:get("mod.grid.combo_grid_ratio")]
    )
    set:color_edit(gui_util.tr("menu.grid.color_center"), "mod.grid.color_center")

    set:color_edit(gui_util.tr("menu.grid.color_grid"), "mod.grid.color_grid")
    set:color_edit(gui_util.tr("menu.grid.color_fade"), "mod.grid.color_fade")
    set:slider_float(gui_util.tr("menu.grid.fade_alpha"), "mod.grid.fade_alpha", 0, 1, "%.2f")

    imgui.unindent(2)
    imgui.spacing()
end

local function draw_tools_menu()
    if util_imgui.menu_item(gui_util.tr("selector.name"), nil, nil, true) then
        mod.pause = true
        gui_selector.is_opened = true
        gui_debug.close()
        config.save_global()
        config.selector:reload()
        state.combo.config:swap(config.selector.sorted)
        state.combo.config_backup:swap(config.selector.sorted_backup)
    end

    if util_imgui.menu_item(gui_util.tr("debug.name"), nil, nil, true) then
        local config_debug = config.gui.current.gui.debug
        config_debug.is_opened = not config_debug.is_opened
        config.save_global()
    end
end

function this.draw()
    draw_menu(gui_util.tr("menu.config.name"), draw_mod_menu)
    draw_menu(gui_util.tr("menu.language.name"), draw_lang_menu)
    draw_menu(gui_util.tr("menu.grid.name"), draw_grid_menu)
    draw_menu(gui_util.tr("menu.bind.name"), draw_bind_menu)
    draw_menu(
        gui_util.tr("menu.user_scripts.name"),
        draw_user_scripts_menu,
        nil,
        user.is_need_attention() and state.colors.info or nil
    )
    util_imgui.tooltip(string.format(".../reframework/data/%s/user_scripts", config.name))
    draw_menu(gui_util.tr("menu.tools.name"), draw_tools_menu)
end

return this
