local bind_manager = require("HudController.hud.bind")
local config = require("HudController.config")
local data = require("HudController.data")
local fade_manager = require("HudController.hud.fade")
local gui_debug = require("HudController.gui.debug")
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
    if imgui.menu_item(gui_util.tr("menu.config.enabled"), nil, config.current.mod.enabled) then
        config.current.mod.enabled = not config.current.mod.enabled
        hud.reset_elements()
        config.save()
    end

    if imgui.menu_item(gui_util.tr("menu.config.enable_fade"), nil, config.current.mod.enable_fade) then
        config.current.mod.enable_fade = not config.current.mod.enable_fade
        fade_manager.abort()
        config.save()
    end

    if imgui.menu_item(gui_util.tr("menu.config.enable_notification"), nil, config.current.mod.enable_notification) then
        config.current.mod.enable_notification = not config.current.mod.enable_notification
        config.save()
    end

    if imgui.menu_item(gui_util.tr("menu.config.enable_weapon_binds"), nil, config.current.mod.enable_weapon_binds) then
        config.current.mod.enable_weapon_binds = not config.current.mod.enable_weapon_binds
        config.save()
    end

    if imgui.menu_item(gui_util.tr("menu.config.enable_key_binds"), nil, config.current.mod.enable_key_binds) then
        config.current.mod.enable_key_binds = not config.current.mod.enable_key_binds
        config.save()
    end

    imgui.separator()

    if
        imgui.menu_item(
            gui_util.tr("menu.config.disable_weapon_binds_timed"),
            nil,
            config.current.mod.disable_weapon_binds_timed
        )
    then
        config.current.mod.disable_weapon_binds_timed = not config.current.mod.disable_weapon_binds_timed
        config.save()
    end
    util_imgui.tooltip(config.lang.tr("menu.config.disable_weapon_binds_timed_tooltip"))

    imgui.begin_disabled(not config.current.mod.disable_weapon_binds_timed)
    local item_config_key = "mod.disable_weapon_binds_time"
    local item_value = config.get(item_config_key)
    if
        set.slider_int(
            "##" .. item_config_key,
            item_config_key,
            1,
            300,
            gui_util.seconds_to_minutes_string(item_value, "%.0f")
        )
    then
        config.save()
    end
    imgui.end_disabled()

    if
        imgui.menu_item(
            gui_util.tr("menu.config.disable_weapon_binds_held"),
            nil,
            config.current.mod.disable_weapon_binds_held
        )
    then
        config.current.mod.disable_weapon_binds_held = not config.current.mod.disable_weapon_binds_held
        config.save()
    end
    util_imgui.tooltip(config.lang.tr("menu.config.disable_weapon_binds_held_tooltip"))
end

local function draw_lang_menu()
    for i = 1, #config.lang.sorted do
        local menu_item = config.lang.sorted[i]
        if imgui.menu_item(menu_item, nil, config.current.gui.lang.file == menu_item) then
            config.current.gui.lang.file = menu_item
            config.lang.change()
            state.tr_combo()
            config.save()
        end
    end

    imgui.separator()

    if imgui.menu_item(gui_util.tr("menu.language.fallback"), nil, config.current.gui.lang.fallback) then
        config.current.gui.lang.fallback = not config.current.gui.lang.fallback
        config.save()
    end
    util_imgui.tooltip(config.lang.tr("menu.language.fallback_tooltip"))
end

local function draw_key_bind_menu()
    if
        set.slider_int(
            "##mod.slider_key_bind",
            "mod.slider_key_bind",
            1,
            2,
            config.current.mod.slider_key_bind == 1 and config.lang.tr("menu.bind.key.hud")
                or config.lang.tr("menu.bind.key.option")
        )
    then
        state.listener = nil
        bind_manager.set_pause(false)
    end

    ---@type BindManagerType
    local manager_type
    ---@type string
    local config_key
    if config.current.mod.slider_key_bind == 1 then
        manager_type = bind_manager.manager_type.HUD
        config_key = "mod.bind.key.hud"
        set.combo("##bind_hud_combo", "mod.combo_hud_key_bind", state.combo.hud.values)
    else
        manager_type = bind_manager.manager_type.OPTION
        config_key = "mod.bind.key.option"
        set.combo("##bind_option_combo", "mod.combo_option_key_bind", state.combo.option_bind.values)
    end

    imgui.same_line()

    if imgui.button(gui_util.tr("menu.bind.key.button_add")) then
        if
            (manager_type == bind_manager.manager_type.HUD and not util_table.empty(config.current.mod.hud))
            or manager_type == bind_manager.manager_type.OPTION
        then
            state.listener = {
                opt = manager_type == bind_manager.manager_type.HUD
                        and config.current.mod.hud[config.current.mod.combo_hud_key_bind]
                    or state.combo.option_bind:get_key(config.current.mod.combo_option_key_bind),
                listener = util_bind.listener:new(),
            }
        end
    end

    if state.listener then
        bind_manager.set_pause(true)

        imgui.separator()

        local bind = state.listener.listener:listen() --[[@as ModBind]]
        ---@type string[]
        local bind_name

        if bind.name ~= "" then
            bind_name = { bind.name, "..." }
        else
            bind_name = { config.lang.tr("menu.bind.key.text_default") }
        end

        imgui.begin_table("keybind_listener", 2, 1 << 9)
        imgui.table_next_row()
        imgui.table_set_column_index(0)

        util_imgui.adjust_pos(0, 3)

        imgui.text(
            manager_type == bind_manager.manager_type.HUD and state.listener.opt.name
                or config.lang.tr("hud." .. mod.map.hud_options[state.listener.opt])
        )
        imgui.table_set_column_index(1)

        if bind_manager.is_valid(bind) then
            local is_col, col = bind_manager.is_collision(bind)

            if is_col and col then
                local type = col.manager_type == bind_manager.manager_type.HUD and config.lang.tr("menu.bind.key.hud")
                    or config.lang.tr("menu.bind.key.option")
                local name = col.manager_type == bind_manager.manager_type.HUD
                        and util_table.value(config.current.mod.hud, function(key, value)
                            return col.bind.key == value.key
                        end).name
                    or config.lang.tr("hud." .. mod.map.hud_options[col.bind.key])

                state.listener.collision =
                    string.format("%s %s %s", config.lang.tr("menu.bind.tooltip_bound"), type, name)
            else
                state.listener.collision = nil
            end
        else
            state.listener.collision = nil
        end

        imgui.begin_disabled(state.listener.collision ~= nil)

        local save_button = imgui.button(gui_util.tr("menu.bind.key.button_save"))

        if save_button then
            ---@diagnostic disable-next-line: assign-type-mismatch
            bind.key = manager_type == bind_manager.manager_type.HUD and state.listener.opt.key or state.listener.opt

            bind_manager.register(manager_type, bind)
            config.set(config_key, bind_manager.get_base_binds(manager_type))

            config.save()
            state.listener = nil
            bind_manager.set_pause(false)
        end

        imgui.end_disabled()
        imgui.same_line()

        if imgui.button(gui_util.tr("menu.bind.key.button_clear")) then
            state.listener.listener:clear()
        end

        imgui.same_line()

        if imgui.button(gui_util.tr("menu.bind.key.button_cancel")) then
            state.listener = nil
            bind_manager.set_pause(false)
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

    if not util_table.empty(config.get(config_key)) and imgui.begin_table("keybind_state", 3, 1 << 9) then
        imgui.separator()

        ---@type HudBindKey[]
        local remove = {}
        local binds = config.get(config_key) --[=[@as HudBindKey[]]=]
        for i = 1, #binds do
            local bind = binds[i]
            imgui.table_next_row()

            imgui.table_set_column_index(0)

            if imgui.button(gui_util.tr("menu.bind.key.button_remove", bind.name)) then
                table.insert(remove, bind)
            end

            imgui.table_set_column_index(1)
            imgui.text(
                ---@diagnostic disable-next-line: param-type-mismatch
                manager_type == bind_manager.manager_type.HUD and hud.operations.get_hud_by_key(bind.key).name
                    or config.lang.tr("hud." .. mod.map.hud_options[bind.key])
            )
            imgui.table_set_column_index(2)
            imgui.text(bind.name)
        end

        if not util_table.empty(remove) then
            for _, bind in pairs(remove) do
                bind_manager.unregister(manager_type, bind)
            end

            config.set(config_key, bind_manager.get_base_binds(manager_type))
            config.save()
        end

        imgui.end_table()
    end
end

local function draw_weapon_bind_menu()
    imgui.begin_disabled(util_table.empty(config.current.mod.hud))

    local changed = false
    changed = set.checkbox(gui_util.tr("menu.bind.weapon.quest_in_combat"), "mod.bind.weapon.quest_in_combat")
    changed = set.checkbox(gui_util.tr("menu.bind.weapon.ride_ignore_combat"), "mod.bind.weapon.ride_ignore_combat")
        or changed
    util_imgui.tooltip(config.lang.tr("menu.bind.weapon.ride_ignore_combat_tooltip"), true)
    changed = set.slider_int(
        gui_util.tr("menu.bind.weapon.out_of_combat_delay"),
        "mod.bind.weapon.out_of_combat_delay",
        0,
        600,
        config.current.mod.bind.weapon.out_of_combat_delay == 0 and config.lang.tr("misc.text_disabled")
            or gui_util.seconds_to_minutes_string(config.current.mod.bind.weapon.out_of_combat_delay, nil, true)
    ) or changed
    changed = set.slider_int(
        gui_util.tr("menu.bind.weapon.in_combat_delay"),
        "mod.bind.weapon.in_combat_delay",
        0,
        600,
        config.current.mod.bind.weapon.in_combat_delay == 0 and config.lang.tr("misc.text_disabled")
            or gui_util.seconds_to_minutes_string(config.current.mod.bind.weapon.in_combat_delay, nil, true)
    ) or changed

    if changed then
        config.save()
    end

    imgui.separator()

    set.slider_int(
        gui_util.tr("menu.bind.weapon.game_mode"),
        "mod.slider_weapon_bind",
        1,
        2,
        config.current.mod.slider_weapon_bind == 1 and config.lang.tr("menu.bind.weapon.singleplayer")
            or config.lang.tr("menu.bind.weapon.multiplayer")
    )

    local key = config.current.mod.slider_weapon_bind == 1 and "singleplayer" or "multiplayer"
    local sorted = util_table.sort(
        util_table.values(config.current.mod.bind.weapon[key]) --[=[@as WeaponBindConfig[]]=],
        function(a, b)
            return a.weapon_id < b.weapon_id
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
                weapon.name ~= "GLOBAL" and config.get(string.format("mod.bind.weapon.%s.%s.enabled", key, "GLOBAL"))
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
                    config.set(
                        string.format("mod.bind.weapon.%s.%s.%s.hud_key", key, weapon.name, sub_key),
                        config.current.mod.hud[config.get(config_key)].key
                    )
                    config.save()
                end

                imgui.pop_item_width()
            end

            imgui.table_set_column_index(1)
            imgui.begin_disabled(not config.get(config_key))
            draw_combo("combat_in")

            imgui.table_set_column_index(2)
            draw_combo("combat_out")

            imgui.table_set_column_index(3)
            draw_combo("camp")

            imgui.table_set_column_index(4)
            imgui.text(
                weapon.name == "GLOBAL" and config.lang.tr("menu.bind.weapon.name_global")
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
        bind_manager.hud_manager.pause = false
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
        state.grid_ratio[config.get("mod.grid.combo_grid_ratio")]
    ) or changed
    changed = set.color_edit(gui_util.tr("menu.grid.color_center"), "mod.grid.color_center") or changed
    changed = set.color_edit(gui_util.tr("menu.grid.color_grid"), "mod.grid.color_grid") or changed
    changed = set.color_edit(gui_util.tr("menu.grid.color_fade"), "mod.grid.color_fade") or changed
    changed = set.slider_float(gui_util.tr("menu.grid.fade_alpha"), "mod.grid.fade_alpha", 0, 1, "%.2f") or changed

    if changed then
        config.save()
    end
end

function this.draw()
    draw_menu(gui_util.tr("menu.config.name"), draw_mod_menu)
    draw_menu(gui_util.tr("menu.language.name"), draw_lang_menu)
    draw_menu(gui_util.tr("menu.grid.name"), draw_grid_menu)
    draw_menu(gui_util.tr("menu.bind.name"), draw_bind_menu)

    if imgui.button("Debug") then
        gui_debug.is_opened = not gui_debug.is_opened
    end
end

return this
