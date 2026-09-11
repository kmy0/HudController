local bind_manager = require("HudController.hud.bind.key.init")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local state = require("HudController.gui.state")
local util_bind = require("HudController.util.game.bind.init")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")
local util_menubar_bind = require("HudController.gui.elements.menu_bar.bind.util")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod
local set = state.set

local this = {}

local function draw_bind_type()
    ---@type NotebookTab[]
    local tabs = {
        { label = config.lang:tr("menu.bind.key.all"), key = 0 },
        { label = config.lang:tr("menu.bind.key.hud"), key = 1 },
        { label = config.lang:tr("menu.bind.key.option"), key = 2 },
        { label = config.lang:tr("menu.bind.key.option_mod"), key = 3 },
    }

    if set:notebook("notebook_binds", "mod.bind.slider.key_bind", tabs, nil, nil, nil, true) then
        state.listener = nil
        bind_manager.monitor:unpause()
    end
end

---@param combo_id string
---@param config_key string
---@param combo any
local function draw_bind_combo(combo_id, config_key, combo)
    imgui.push_item_width(-1)
    set:combo_filter(combo_id, config_key, combo)
    imgui.pop_item_width()
end

---@param values HudBaseConfigProfileForShow[]
---@param disabled boolean
local function draw_elem_profile_combo(values, disabled)
    imgui.push_item_width(-util_imgui.get_button_width(util_gui.tr("menu.bind.key.button_add")) - 8)

    util_imgui.begin_disabled(disabled)

    set:combo_multi_bits_filter(
        "##elem_profile_hud_bind",
        disabled and "" or "mod.combo.key_bind.elem_profile",
        config.lang:tr("misc.text_none"),
        values,
        function(v)
            return v.key
        end,
        function(v)
            return v.name
        end
    )

    if not disabled then
        util_imgui.tooltip(config.lang:tr("menu.bind.key.tooltip_element_profile"))
    end

    util_imgui.end_disabled()
    imgui.pop_item_width()
end

---@param left_fn fun()
---@param right_fn fun()
local function draw_bind_table(left_fn, right_fn)
    imgui.push_style_var(imgui.ImGuiStyleVar.ItemSpacing, Vector2f.new(2, 2))

    if imgui.begin_table("bind_table1", 2, imgui.TableFlags.SizingStretchSame) then
        imgui.table_next_row()

        imgui.table_set_column_index(0)
        left_fn()

        imgui.table_set_column_index(1)
        right_fn()

        imgui.end_table()
    end

    imgui.pop_style_var(1)
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
        draw_bind_table(function()
            imgui.push_item_width(-1)

            if set:combo_filter("##bind_hud_combo", "mod.combo.key_bind.hud", state.combo.hud) then
                config_mod.combo.key_bind.elem_profile = 0
                config:save()
            end

            imgui.pop_item_width()

            local hud_profile = config_mod.hud[config_mod.combo.key_bind.hud]
            if hud_profile then
                values = util_table.slice(hud_profile.profile, 2, #hud_profile.profile)
            end
        end, function()
            config_mod.combo.key_bind.action_type = state.combo.bind_action_type:get_index("ENABLE") --[[@as integer]]

            util_imgui.begin_disabled(true)

            draw_bind_combo(
                "##bind_action_type_combo",
                "mod.combo.key_bind.action_type",
                state.combo.bind_action_type
            )

            util_imgui.tooltip(config.lang:tr("menu.bind.key.tooltip_action_type"))

            util_imgui.end_disabled()
        end)

        draw_elem_profile_combo(values, util_table.empty(values))

        return bind_manager.hud, "mod.bind.key.hud"
    end

    ---@type ModBindManager
    local manager
    ---@type string
    local config_key
    if bind_type == 2 then
        manager = bind_manager.option_hud
        config_key = "mod.bind.key.option_hud"
    else
        manager = bind_manager.option_mod
        config_key = "mod.bind.key.option_mod"
    end

    draw_bind_table(function()
        draw_bind_combo(
            "##bind_option_combo",
            "mod.combo.key_bind.option_hud",
            state.combo.option_bind
        )
    end, function()
        if bind_type == 2 then
            draw_bind_combo(
                "##bind_action_type_combo",
                "mod.combo.key_bind.action_type",
                state.combo.bind_action_type
            )
        else
            draw_bind_combo(
                "##bind_option_mod_combo",
                "mod.combo.key_bind.option_mod",
                state.combo.option_mod_bind
            )
        end

        util_imgui.tooltip(config.lang:tr("menu.bind.key.tooltip_action_type"))
    end)

    draw_elem_profile_combo({}, true)
    imgui.same_line()

    return manager, config_key
end

---@param manager ModBindManager
---@param config_mod ModSettings
---@return string | HudBindOpt
---@return string
local function get_selected_option(manager, config_mod)
    if manager.name == bind_manager.manager_names.HUD then
        local hud_profile = config_mod.hud[config_mod.combo.key_bind.hud]
        local opt = { hud = hud_profile.key, profile = config_mod.combo.key_bind.elem_profile }

        return opt, util_menubar_bind.get_hud_bind_name(opt)
    elseif manager.name == bind_manager.manager_names.OPTION_HUD then
        return state.combo.option_bind:get_key(config_mod.combo.key_bind.option_hud),
            state.combo.option_bind:get_value(config_mod.combo.key_bind.option_hud)
    end

    return state.combo.option_mod_bind:get_key(config_mod.combo.key_bind.option_mod),
        state.combo.option_mod_bind:get_value(config_mod.combo.key_bind.option_mod)
end

---@param manager ModBindManager
---@param config_mod ModSettings
local function draw_add_button(manager, config_mod)
    imgui.same_line()

    if not imgui.button(util_gui.tr("menu.bind.key.button_add")) then
        return
    end

    local opt, opt_name = get_selected_option(manager, config_mod)

    state.listener = {
        opt = opt,
        listener = util_bind.listener:new(),
        opt_name = opt_name,
    }
end

---@param manager ModBindManager
---@param bind ModBind
---@param config_mod ModSettings
local function set_bind_target(manager, bind, config_mod)
    if manager.name == bind_manager.manager_names.HUD then
        bind.bound_value = state.listener.opt
        bind.action_type = bind_manager.action_type.NONE
        return
    end

    ---@diagnostic disable-next-line: assign-type-mismatch
    bind.bound_value = state.listener.opt
    bind.action_type = state.combo.bind_action_type:get_key(config_mod.combo.key_bind.action_type)
end

---@param manager ModBindManager
---@param bind ModBind
---@return string
local function get_bind_target_name(manager, bind)
    if manager.name == bind_manager.manager_names.HUD then
        return util_menubar_bind.get_hud_bind_name(bind.bound_value)
    elseif manager.name == bind_manager.manager_names.OPTION_HUD then
        return util_menubar_bind.get_option_hud_bind_name(bind.bound_value)
    end

    return util_menubar_bind.get_option_mod_bind_name(bind.bound_value)
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

    state.listener.collision = get_bind_target_name(manager, collision)
end

---@param manager ModBindManager
---@param config_key string
---@param bind ModBind
local function save_bind(manager, config_key, bind)
    manager:register(bind)
    config:set(config_key, manager:get_base_binds())

    config:save()
    state.listener = nil
    bind_manager.monitor:unpause()
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
        state.listener = nil
        bind_manager.monitor:unpause()
    end

    imgui.end_table()

    if state.listener and state.listener.collision then
        imgui.text_colored(
            string.format(
                "%s %s",
                config.lang:tr("menu.bind.tooltip_bound"),
                util_misc.trunc_string2(
                    state.listener.collision,
                    config.lang.font_size * (215 / 16)
                )
            ),
            mod.enum.colors.bad
        )
    end

    imgui.text(table.concat(bind_name, " + "))
    imgui.separator()
end

---@param manager ModBindManager
---@param bind ModBind
---@return string
local function get_registered_bind_target_name(manager, bind)
    if manager.name == bind_manager.manager_names.HUD then
        return util_menubar_bind.get_hud_bind_name(bind)
    elseif manager.name == bind_manager.manager_names.OPTION_HUD then
        return util_menubar_bind.get_option_hud_bind_name(bind)
    end

    return util_menubar_bind.get_option_mod_bind_name(bind)
end

---@param manager ModBindManager
---@param bind ModBind
---@param remove ModBind[]
local function draw_registered_bind(manager, bind, remove)
    local opt_name = get_registered_bind_target_name(manager, bind)

    imgui.table_next_row()
    imgui.table_set_column_index(0)

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

    local truncated = util_misc.trunc_string2(opt_name, config.lang.font_size * (215 / 16))
    imgui.table_set_column_index(2)
    imgui.text(truncated)
    imgui.same_line()
    imgui.spacing()

    if truncated ~= opt_name then
        util_imgui.tooltip(opt_name)
    end

    imgui.table_set_column_index(3)
    imgui.text(util_menubar_bind.get_key_bind_name(bind))
    imgui.same_line()
    imgui.spacing()
end

---@param manager ModBindManager
---@param config_key string
local function draw_registered_binds(manager, config_key)
    local binds = config:get(config_key) --[=[@as ModBind[]]=]

    if util_table.empty(binds) then
        imgui.invisible_button("invbutton" .. config_key, { util_gui.get_item_size() * 1.5, 0 })
        return
    end

    if not imgui.begin_table("keybind_state", 4) then
        return
    end

    imgui.separator()

    ---@type ModBind[]
    local remove = {}
    for i = 1, #binds do
        local b = binds[i]
        local color = 0

        if state.listener and state.listener.collision == get_bind_target_name(manager, b) then
            color = mod.enum.colors.bad
        end

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
end

local function draw_all_registed_binds()
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

    if not any then
        util_imgui.tooltip_text(config.lang:tr("menu.bind.key.tooltip_no_binds"))
        imgui.invisible_button("invbutton_all_binds", { util_gui.get_item_size() * 1.5, 0 })
    end
end

local function draw_key_bind_menu()
    imgui.spacing()
    imgui.indent(2)

    local config_mod = config.current.mod

    -- draw_buffer(config_mod)

    imgui.begin_group()
    draw_bind_type()
    imgui.end_group()

    util_imgui.begin_disabled(
        state.listener ~= nil
            or config_mod.bind.slider.key_bind == 1 and util_table.empty(config_mod.hud)
    )

    imgui.same_line()
    imgui.begin_group()

    local manager, config_key = draw_bind_target(config_mod)

    if manager and config_key then
        draw_add_button(manager, config_mod)

        util_imgui.end_disabled()

        draw_listener(manager, config_key, config_mod)
        draw_registered_binds(manager, config_key)
    else
        util_imgui.end_disabled()
        draw_all_registed_binds()
    end

    imgui.end_group()

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    if not util_menubar.draw_menu(util_gui.tr("menu.bind.key.name"), draw_key_bind_menu) then
        state.listener = nil
        bind_manager.monitor:unpause()
    end
end

return this
