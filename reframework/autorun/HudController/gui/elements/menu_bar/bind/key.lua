local bind_manager = require("HudController.hud.bind.key.init")
local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local set = require("HudController.gui.set")
local state = require("HudController.gui.state")
local user_option = require("HudController.hud.user.option")
local util_bind = require("HudController.util.game.bind.init")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")
local util_menubar_bind = require("HudController.gui.elements.menu_bar.bind.util")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

local this = {}

---@return number
local function get_width()
    return config.lang.font_size * (200 / 16) * 3
        + 6 * 4
        + util_imgui.get_button_width(config.lang:tr("menu.bind.key.button_add"))
end

---@return number
local function get_bind_text_width()
    return config.lang.font_size * (215 / 16)
end

local function clear_listener()
    state.listener = nil
    bind_manager.monitor:unpause()
end

---@param opt BindOpt
---@param opt_name string
local function start_listener(opt, opt_name)
    state.listener = {
        opt = opt,
        listener = util_bind.listener:new(),
        opt_name = opt_name,
    }
end

local function draw_bind_type()
    local config_mod = config.current.mod
    ---@type NotebookTab[]
    local tabs = {
        { label = config.lang:tr("menu.bind.key.all"), key = 0 },
        { label = config.lang:tr("menu.bind.key.hud"), key = 1 },
        { label = config.lang:tr("menu.bind.key.option"), key = 2 },
        { label = config.lang:tr("menu.bind.key.option_mod"), key = 3 },
        { label = config.lang:tr("menu.bind.key.option_game"), key = 4 },
    }

    if not cd.combo.option_user_bind:empty() then
        table.insert(tabs, { label = config.lang:tr("menu.bind.key.option_user"), key = 5 })
    end

    config_mod.bind.slider.key_bind = math.min(config_mod.bind.slider.key_bind, #tabs)
    if set:notebook("notebook_binds", "mod.bind.slider.key_bind", tabs, nil, nil, nil, true) then
        clear_listener()
        config_mod.combo.key_bind.action_type = 1
        config_mod.combo.key_bind.trigger_type = 1
        config_mod.combo.key_bind.target = 1
        config_mod.combo.key_bind.value = 0

        if config:get("mod.bind.slider.key_bind") == 5 then
            local opt = cd.combo.option_user_bind:get_key(config:get("mod.combo.key_bind.target")) --[[@as RegisteredUserOption]]
            config_mod.combo.key_bind.value = user_option.get_default(opt)
        end

        config:save()
    end
end

---@param manager ModBindManager
---@param config_mod ModSettings
---@return BindOpt
---@return string
local function get_selected_option(manager, config_mod)
    if manager.name == mod.enum.manager_names.HUD then
        local hud_profile = config_mod.hud[config_mod.combo.key_bind.target]
        local opt = { key = hud_profile.key, value = config_mod.combo.key_bind.value }

        return opt, util_menubar_bind.get_hud_bind_name(opt)
    elseif manager.name == mod.enum.manager_names.OPTION_HUD then
        local opt = {
            key = cd.combo.option_bind:get_key(config_mod.combo.key_bind.target),
            value = config_mod.combo.key_bind.value,
        }
        return opt, util_menubar_bind.get_option_hud_bind_name(opt)
    elseif manager.name == mod.enum.manager_names.OPTION_GAME then
        local opt = {
            key = cd.combo.option_game_bind:get_key(config_mod.combo.key_bind.target),
            value = config_mod.combo.key_bind.value,
        }
        return opt, util_menubar_bind.get_option_game_bind_name(opt)
    elseif manager.name == mod.enum.manager_names.OPTION_USER then
        local user_opt = cd.combo.option_user_bind:get_key(config:get("mod.combo.key_bind.target")) --[[@as RegisteredUserOption]]
        local opt = {
            key = user_opt.key,
            value = config_mod.combo.key_bind.value,
        }
        return opt, util_menubar_bind.get_option_user_bind_name(opt)
    end

    local opt = {
        key = cd.combo.option_mod_bind:get_key(config_mod.combo.key_bind.target),
        value = config_mod.combo.key_bind.value,
    }
    return opt, util_menubar_bind.get_option_mod_bind_name(opt)
end

---@param manager ModBindManager
---@param config_mod ModSettings
local function draw_add_button(manager, config_mod)
    if not imgui.button(util_gui.tr("menu.bind.key.button_add")) then
        return
    end

    local opt, opt_name = get_selected_option(manager, config_mod)

    start_listener(opt, opt_name)
end

local function draw_trigger_combo()
    set:combo_filter(
        "##bind_trigger_type_combo",
        "mod.combo.key_bind.trigger_type",
        cd.combo.bind_trigger_type
    )
end

local function draw_action_combo()
    set:combo_filter(
        "##bind_action_type_combo",
        "mod.combo.key_bind.action_type",
        cd.combo.bind_action_type
    )
end

---@param target_fn fun()
---@param trigger_fn fun()
---@param action_fn fun()
---@param manager ModBindManager
---@param config_mod ModSettings
local function draw_bind_table(target_fn, trigger_fn, action_fn, manager, config_mod)
    imgui.push_style_var(imgui.ImGuiStyleVar.ItemSpacing, Vector2f.new(2, 2))

    local item_width = config.lang.font_size * (200 / 16)
    if imgui.begin_table("bind_table1", 4) then
        imgui.table_setup_column(
            util_gui.tr("menu.bind.key.combo_target"),
            imgui.ColumnFlags.WidthFixed,
            item_width
        )
        imgui.table_setup_column(
            util_gui.tr("menu.bind.key.combo_trigger"),
            imgui.ColumnFlags.WidthFixed,
            item_width
        )
        imgui.table_setup_column(
            util_gui.tr("menu.bind.key.combo_action"),
            imgui.ColumnFlags.WidthFixed,
            item_width
        )
        imgui.table_setup_column("##Add", imgui.ColumnFlags.WidthFixed)

        imgui.push_style_color(45, 0x00000000)
        imgui.push_style_color(25, 0x00000000)
        imgui.push_style_color(26, 0x00000000)

        imgui.push_style_var(imgui.ImGuiStyleVar.CellPadding, Vector2f.new(2, 2))
        imgui.table_headers_row()
        imgui.pop_style_var(1)

        imgui.pop_style_color(3)
        imgui.table_next_row()

        imgui.table_set_column_index(0)
        imgui.set_next_item_width(item_width)
        target_fn()

        imgui.table_set_column_index(1)
        imgui.set_next_item_width(item_width)
        trigger_fn()

        imgui.table_set_column_index(2)
        imgui.set_next_item_width(item_width)
        action_fn()

        imgui.table_set_column_index(3)
        draw_add_button(manager, config_mod)
        imgui.same_line()
        util_imgui.dummy_button3("##ibutton_bind1", { 4, 0 })

        imgui.end_table()
    end

    imgui.pop_style_var(1)
end

---@param combo_key string
---@param combo Combo
---@param manager ModBindManager
---@param config_mod ModSettings
local function draw_option_bind_table(combo_key, combo, manager, config_mod)
    draw_bind_table(function()
        if set:combo_filter("##bind_option_combo", combo_key, combo) then
            config_mod.combo.key_bind.value = 0
            config:save()
        end
    end, draw_trigger_combo, draw_action_combo, manager, config_mod)

    imgui.set_next_item_width(get_width())
    set:slider_list(
        "##option_bind_list",
        "mod.combo.key_bind.value",
        0,
        1,
        { config.lang:tr("misc.text_off"), config.lang:tr("misc.text_on") }
    )
end

---@param config_mod ModSettings
---@return ModBindManager?
---@return string?
local function draw_bind_target(config_mod)
    local bind_type = config_mod.bind.slider.key_bind
    if bind_type == 0 then
        return
    end

    if bind_type == 1 then
        ---@type HudBaseConfigProfileForShow[]
        local values = {}
        draw_bind_table(
            function()
                if
                    set:combo_filter("##bind_hud_combo", "mod.combo.key_bind.target", cd.combo.hud)
                then
                    config_mod.combo.key_bind.value = 0
                    config:save()
                end

                local hud_profile = config_mod.hud[config_mod.combo.key_bind.target]
                if hud_profile then
                    values = util_table.slice(hud_profile.profile, 2, #hud_profile.profile)
                end
            end,
            draw_trigger_combo,
            function()
                config_mod.combo.key_bind.action_type = cd.combo.bind_action_type:get_index("SET") --[[@as integer]]

                util_imgui.begin_disabled(true)
                draw_action_combo()
                util_imgui.end_disabled()
            end,
            bind_manager.hud,
            config_mod
        )

        util_imgui.begin_disabled(util_table.empty(values))
        imgui.set_next_item_width(get_width())
        set:combo_multi_bits_filter(
            "##elem_profile_hud_bind",
            "mod.combo.key_bind.value",
            config.lang:tr("misc.text_none"),
            values,
            function(v)
                return v.key
            end,
            function(v)
                return v.name
            end
        )
        util_imgui.end_disabled()

        return bind_manager.hud, "mod.bind.key.hud"
    elseif bind_type == 2 then
        draw_option_bind_table(
            "mod.combo.key_bind.target",
            cd.combo.option_bind,
            bind_manager.option_hud,
            config_mod
        )

        return bind_manager.option_hud, "mod.bind.key.option_hud"
    elseif bind_type == 3 then
        draw_option_bind_table(
            "mod.combo.key_bind.target",
            cd.combo.option_mod_bind,
            bind_manager.option_mod,
            config_mod
        )

        return bind_manager.option_mod, "mod.bind.key.option_mod"
    elseif bind_type == 4 then
        draw_bind_table(
            function()
                if
                    set:combo_filter(
                        "##bind_option_game_combo",
                        "mod.combo.key_bind.target",
                        cd.combo.option_game_bind
                    )
                then
                    config_mod.combo.key_bind.value = 0
                    config:save()
                end
            end,
            draw_trigger_combo,
            function()
                set:combo_filter(
                    "##bind_action_type_combo",
                    "mod.combo.key_bind.action_type",
                    cd.combo.bind_action_type
                )
            end,
            bind_manager.option_game,
            config_mod
        )

        if not cd.combo.option_game_bind:empty() then
            imgui.set_next_item_width(get_width())
            local key =
                cd.combo.option_game_bind:get_key(config:get("mod.combo.key_bind.option_game"))
            generic.draw_option(key, "mod.combo.key_bind.value", nil, "##" .. key, false)
        end

        return bind_manager.option_game, "mod.bind.key.option_game"
    elseif bind_type == 5 then
        draw_bind_table(function()
            if
                set:combo_filter(
                    "##bind_option_user_combo",
                    "mod.combo.key_bind.target",
                    cd.combo.option_user_bind
                )
            then
                local opt =
                    cd.combo.option_user_bind:get_key(config:get("mod.combo.key_bind.target")) --[[@as RegisteredUserOption]]
                config_mod.combo.key_bind.value = user_option.get_default(opt)
                config:save()
            end
        end, draw_trigger_combo, draw_action_combo, bind_manager.option_user, config_mod)

        local opt = cd.combo.option_user_bind:get_key(config:get("mod.combo.key_bind.target")) --[[@as RegisteredUserOption]]
        imgui.set_next_item_width(get_width())
        local changed, value = opt.draw(config_mod.combo.key_bind.value, "mod.combo.key_bind.value")
        if changed then
            config:set("mod.combo.key_bind.value", value)
        end

        return bind_manager.option_user, "mod.bind.key.option_user"
    end
end

---@param config_mod ModSettings
---@return boolean
local function is_repeat_trigger(config_mod)
    return cd.combo.bind_trigger_type:get_key(config_mod.combo.key_bind.trigger_type) == "REPEAT"
end

---@param manager ModBindManager
---@param bind ModBind
---@param config_mod ModSettings
local function set_bind_target(manager, bind, config_mod)
    if manager.name == mod.enum.manager_names.HUD then
        bind.action_type = mod.enum.action_type.NONE
    else
        bind.action_type = cd.combo.bind_action_type:get_key(config_mod.combo.key_bind.action_type)
    end

    ---@diagnostic disable-next-line: assign-type-mismatch
    bind.bound_value = state.listener.opt
    bind.trigger_repeat = is_repeat_trigger(config_mod)
end

---@param manager ModBindManager
---@param bind ModBind
---@return string
local function get_bind_name(manager, bind)
    if manager.name == mod.enum.manager_names.HUD then
        return util_menubar_bind.get_hud_bind_name(bind)
    elseif manager.name == mod.enum.manager_names.OPTION_HUD then
        return util_menubar_bind.get_option_hud_bind_name(bind)
    elseif manager.name == mod.enum.manager_names.OPTION_GAME then
        return util_menubar_bind.get_option_game_bind_name(bind)
    elseif manager.name == mod.enum.manager_names.OPTION_USER then
        return util_menubar_bind.get_option_user_bind_name(bind)
    end

    return util_menubar_bind.get_option_mod_bind_name(bind)
end

---@param manager ModBindManager
---@param bind ModBind
---@param config_mod ModSettings
local function update_collision(manager, bind, config_mod)
    state.listener.collision = nil

    if not manager:is_valid(bind) then
        return
    end

    set_bind_target(manager, bind, config_mod)

    local is_collision, collision = manager:is_collision(bind)
    if not is_collision or not collision then
        return
    end

    state.listener.collision = get_bind_name(manager, collision)
end

---@param manager ModBindManager
---@param config_key string
---@param bind ModBind
local function save_bind(manager, config_key, bind)
    manager:register(bind)
    config:set(config_key, manager:get_base_binds())

    config:save()
    clear_listener()
end

---@param manager ModBindManager
---@param config_key string
---@param config_mod ModSettings
local function draw_listener(manager, config_key, config_mod)
    if not state.listener then
        return
    end

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

    update_collision(manager, bind, config_mod)

    util_imgui.begin_disabled(state.listener.collision ~= nil or bind.name == "")

    if imgui.button(util_gui.tr("menu.bind.key.button_save")) then
        save_bind(manager, config_key, bind)
    end

    util_imgui.end_disabled()
    imgui.same_line()

    util_imgui.begin_disabled(util_table.empty(bind.keys))
    if imgui.button(util_gui.tr("menu.bind.key.button_undo")) then
        state.listener.listener:undo()
    end
    util_imgui.end_disabled()

    imgui.same_line()
    if imgui.button(util_gui.tr("menu.bind.key.button_clear")) then
        state.listener.listener:clear()
    end

    imgui.same_line()

    if imgui.button(util_gui.tr("menu.bind.key.button_cancel")) then
        clear_listener()
    end

    imgui.end_table()

    if state.listener and state.listener.collision then
        imgui.text_colored(
            string.format(
                "%s %s",
                config.lang:tr("menu.bind.tooltip_bound"),
                util_misc.trunc_string2(state.listener.collision, get_bind_text_width())
            ),
            mod.enum.colors.bad
        )
    end

    imgui.text(table.concat(bind_name, " + "))
    imgui.separator()
end

---@param manager ModBindManager
---@param bind ModBind
---@param remove ModBind[]
local function draw_registered_bind(manager, bind, remove)
    local opt_name = get_bind_name(manager, bind)

    if
        imgui.button(
            util_gui.tr("menu.bind.key.button_remove", bind.name, tostring(bind.bound_value))
        )
    then
        table.insert(remove, bind)
    end

    imgui.same_line()
    imgui.spacing()

    imgui.table_set_column_index(1)
    imgui.text(util_menubar_bind.get_action_name(bind))
    imgui.same_line()
    imgui.spacing()

    imgui.table_set_column_index(2)
    imgui.text(util_menubar_bind.get_trigger_name(bind))
    imgui.same_line()
    imgui.spacing()

    local truncated = util_misc.trunc_string2(opt_name, get_bind_text_width())
    imgui.table_set_column_index(3)
    imgui.text(truncated)
    imgui.same_line()
    imgui.spacing()

    if truncated ~= opt_name then
        util_imgui.tooltip(opt_name)
    end

    imgui.table_set_column_index(4)
    imgui.text(util_menubar_bind.get_key_bind_name(bind))
    imgui.same_line()
    imgui.spacing()
end

---@param manager ModBindManager
---@param config_key string
local function draw_registered_binds(manager, config_key)
    local binds = config:get(config_key) --[=[@as ModBind[]]=]

    if util_table.empty(binds) then
        imgui.invisible_button("invbutton" .. config_key, { get_width(), 0 })
        return
    end

    util_imgui.adjust_pos(0, -2)
    imgui.push_style_var(imgui.ImGuiStyleVar.ItemSpacing, Vector2f.new(2, 0))
    if
        not imgui.begin_table(
            "keybind_state",
            5,
            imgui.TableFlags.NoClip,
            Vector2f.new(get_width(), 0)
        )
    then
        imgui.pop_style_var(1)
        return
    end

    imgui.separator()

    ---@type ModBind[]
    local remove = {}
    for i = 1, #binds do
        local b = binds[i]
        local color = 0

        if state.listener and state.listener.collision == get_bind_name(manager, b) then
            color = mod.enum.colors.bad
        end
        imgui.table_next_row()
        imgui.table_set_column_index(0)

        imgui.push_style_color(5, color)
        imgui.begin_rect()

        draw_registered_bind(manager, b, remove)
        imgui.end_rect(0, 0)
        imgui.pop_style_color(1)
    end

    if not util_table.empty(remove) then
        for _, bind in pairs(remove) do
            manager:unregister(bind)
        end

        config:set(config_key, manager:get_base_binds())
    end

    imgui.end_table()
    imgui.pop_style_var(1)
end

local function draw_all_registered_binds()
    local any = false

    if not util_table.empty(bind_manager.hud.binds) then
        any = true
        util_imgui.separator_text(config.lang:tr("menu.bind.key.hud"))
        draw_registered_binds(bind_manager.hud, "mod.bind.key.hud")
    end

    if not util_table.empty(bind_manager.option_hud.binds) then
        any = true
        util_imgui.separator_text(config.lang:tr("menu.bind.key.option"))
        draw_registered_binds(bind_manager.option_hud, "mod.bind.key.option_hud")
    end

    if not util_table.empty(bind_manager.option_mod.binds) then
        any = true
        util_imgui.separator_text(config.lang:tr("menu.bind.key.option_mod"))
        draw_registered_binds(bind_manager.option_mod, "mod.bind.key.option_mod")
    end

    if not util_table.empty(bind_manager.option_game.binds) then
        any = true
        util_imgui.separator_text(config.lang:tr("menu.bind.key.option_game"))
        draw_registered_binds(bind_manager.option_game, "mod.bind.key.option_game")
    end

    if not util_table.empty(bind_manager.option_user.binds) then
        any = true
        util_imgui.separator_text(config.lang:tr("menu.bind.key.option_user"))
        draw_registered_binds(bind_manager.option_user, "mod.bind.key.option_user")
    end

    if not any then
        util_imgui.tooltip_text(config.lang:tr("menu.bind.key.tooltip_no_binds"))
        imgui.invisible_button("invbutton_all_binds", { get_width(), 0 })
    end
end

local function draw_key_bind_menu()
    imgui.spacing()
    imgui.indent(2)

    local config_mod = config.current.mod

    imgui.begin_group()
    draw_bind_type()
    imgui.end_group()

    util_imgui.begin_disabled(
        state.listener ~= nil
            or config_mod.bind.slider.key_bind == 1 and util_table.empty(config_mod.hud)
            or config_mod.bind.slider.key_bind == 4 and cd.combo.option_game_bind:empty()
    )

    imgui.same_line()
    imgui.begin_group()

    local manager, config_key = draw_bind_target(config_mod)

    if manager and config_key then
        util_imgui.end_disabled()

        draw_listener(manager, config_key, config_mod)
        draw_registered_binds(manager, config_key)
    else
        util_imgui.end_disabled()
        draw_all_registered_binds()
    end

    imgui.end_group()

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    if not util_menubar.draw_menu(util_gui.tr("menu.bind.key.name"), draw_key_bind_menu) then
        clear_listener()
    end
end

return this
