local bind_manager = require("HudController.hud.bind.init")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local hud = require("HudController.hud.init")
local state = require("HudController.gui.state")
local util_bind = require("HudController.util.game.bind.init")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")
local util_table = require("HudController.util.misc.table")

local mod = data.mod
local set = state.set

local this = {}

---@param config_mod ModSettings
local function draw_buffer(config_mod)
    local buffer = config_mod.bind.key.buffer - 1

    local display_value = config.lang:tr("misc.text_disabled")
    if buffer == 1 then
        display_value = string.format("%s %s", buffer, config.lang:tr("misc.text_frame"))
    elseif buffer > 1 then
        display_value = string.format("%s %s", buffer, config.lang:tr("misc.text_frame_plural"))
    end

    if
        set:slider_int(
            util_gui.tr("menu.bind.key.slider_buffer"),
            "mod.bind.key.buffer",
            1,
            11,
            display_value
        )
    then
        bind_manager.monitor:set_max_buffer_frame(config_mod.bind.key.buffer)
    end

    util_imgui.tooltip(config.lang:tr("menu.bind.key.tooltip_buffer"))
end

---@param config_mod ModSettings
local function draw_bind_type(config_mod)
    local bind_type = config_mod.bind.slider.key_bind

    ---@diagnostic disable-next-line: param-type-mismatch
    local display_value = (bind_type == 1 and config.lang:tr("menu.bind.key.hud"))
        or (bind_type == 2 and config.lang:tr("menu.bind.key.option"))
        or (bind_type == 3 and config.lang:tr("menu.bind.key.option_mod"))
        or ""

    if
        set:slider_int(
            util_gui.tr("menu.bind.key.slider_bind_type"),
            "mod.bind.slider.key_bind",
            1,
            3,
            display_value
        )
    then
        state.listener = nil
        bind_manager.monitor:unpause()
    end
end

---@param config_mod ModSettings
---@return ModBindManager
---@return string
local function draw_bind_target(config_mod)
    local bind_type = config_mod.bind.slider.key_bind
    local width = imgui.calc_item_width() / 2 - 4

    if bind_type == 1 then
        set:combo("##bind_hud_combo", "mod.combo.key_bind.hud", state.combo.hud.values)

        return bind_manager.hud, "mod.bind.key.hud"
    end

    imgui.push_item_width(width)

    ---@type ModBindManager
    local manager
    ---@type string
    local config_key

    if bind_type == 2 then
        manager = bind_manager.option_hud
        config_key = "mod.bind.key.option_hud"

        set:combo(
            "##bind_option_combo",
            "mod.combo.key_bind.option_hud",
            state.combo.option_bind.values
        )
    else
        manager = bind_manager.option_mod
        config_key = "mod.bind.key.option_mod"

        set:combo(
            "##bind_option_mod_combo",
            "mod.combo.key_bind.option_mod",
            state.combo.option_mod_bind.values
        )
    end

    imgui.same_line()

    set:combo(
        "##bind_action_type_combo",
        "mod.combo.key_bind.action_type",
        state.combo.bind_action_type.values
    )
    util_imgui.tooltip(config.lang:tr("menu.bind.key.tooltip_action_type"))

    imgui.pop_item_width()

    return manager, config_key
end

---@param manager ModBindManager
---@param config_mod ModSettings
---@return string | ModProfileConfig
---@return string
local function get_selected_option(manager, config_mod)
    if manager.name == bind_manager.manager_names.HUD then
        local opt = config_mod.hud[config_mod.combo.key_bind.hud]
        return opt, opt.name
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
        bind.bound_value = state.listener.opt.key
        bind.action_type = bind_manager.action_type.NONE
        return
    end

    ---@diagnostic disable-next-line: assign-type-mismatch
    bind.bound_value = state.listener.opt
    bind.action_type = state.combo.bind_action_type:get_key(config_mod.combo.key_bind.action_type)
end

---@param manager ModBindManager
---@param bind ModBind
---@param config_mod ModSettings
---@return string
local function get_bind_target_name(manager, bind, config_mod)
    if manager.name == bind_manager.manager_names.HUD then
        local profile = util_table.value(config_mod.hud, function(_, value)
            return bind.bound_value == value.key
        end) --[[@as ModProfileConfig]]

        return profile.name
    elseif manager.name == bind_manager.manager_names.OPTION_HUD then
        return config.lang:tr("hud." .. mod.map.options_hud[bind.bound_value])
    end

    return config.lang:tr("menu.config." .. mod.map.options_mod[bind.bound_value])
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

    local collision_name = get_bind_target_name(manager, collision, config_mod)

    state.listener.collision =
        string.format("%s %s", config.lang:tr("menu.bind.tooltip_bound"), collision_name)
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

    imgui.begin_disabled(state.listener.collision ~= nil or bind.name == "")

    if imgui.button(util_gui.tr("menu.bind.key.button_save")) then
        save_bind(manager, config_key, bind)
    end

    imgui.end_disabled()
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
    imgui.separator()

    if state.listener and state.listener.collision then
        imgui.text_colored(state.listener.collision, mod.enum.colors.bad)
        imgui.separator()
    end

    imgui.text(table.concat(bind_name, " + "))
    imgui.separator()
end

---@param manager ModBindManager
---@param bind ModBind
---@return string
local function get_registered_bind_target_name(manager, bind)
    if manager.name == bind_manager.manager_names.HUD then
        ---@diagnostic disable-next-line: param-type-mismatch
        return hud.operations.get_hud_by_key(bind.bound_value).name
    elseif manager.name == bind_manager.manager_names.OPTION_HUD then
        return config.lang:tr("hud." .. mod.map.options_hud[bind.bound_value])
    end

    return config.lang:tr("menu.config." .. mod.map.options_mod[bind.bound_value])
end

---@param bind ModBind
---@return string
local function get_action_type_name(bind)
    if bind.action_type == bind_manager.action_type.NONE then
        return ""
    end

    return config.lang:tr("menu.bind.key.action_type." .. bind.action_type)
end

---@param manager ModBindManager
---@param bind ModBind
---@param remove ModBind[]
local function draw_registered_bind(manager, bind, remove)
    local opt_name = get_registered_bind_target_name(manager, bind)

    imgui.table_next_row()

    imgui.table_set_column_index(0)

    if imgui.button(util_gui.tr("menu.bind.key.button_remove", bind.name, bind.bound_value)) then
        table.insert(remove, bind)
    end

    imgui.table_set_column_index(1)
    imgui.text(opt_name)

    imgui.table_set_column_index(2)
    imgui.text(bind.name_display)

    imgui.table_set_column_index(3)
    imgui.text(get_action_type_name(bind))
end

---@param manager ModBindManager
---@param config_key string
local function draw_registered_binds(manager, config_key)
    local binds = config:get(config_key) --[=[@as ModBind[]]=]

    if util_table.empty(binds) then
        return
    end

    if not imgui.begin_table("keybind_state", 4, 1 << 9) then
        return
    end

    imgui.separator()

    ---@type ModBind[]
    local remove = {}
    for i = 1, #binds do
        draw_registered_bind(manager, binds[i], remove)
    end

    if not util_table.empty(remove) then
        for _, bind in pairs(remove) do
            manager:unregister(bind)
        end

        config:set(config_key, manager:get_base_binds())
    end

    imgui.end_table()
end

local function draw_key_bind_menu()
    imgui.spacing()
    imgui.indent(2)

    local config_mod = config.current.mod

    draw_buffer(config_mod)

    imgui.separator()

    draw_bind_type(config_mod)

    imgui.begin_disabled(
        state.listener ~= nil
            or config_mod.bind.slider.key_bind == 1 and util_table.empty(config_mod.hud)
    )

    local manager, config_key = draw_bind_target(config_mod)

    draw_add_button(manager, config_mod)

    imgui.end_disabled()

    draw_listener(manager, config_key, config_mod)
    draw_registered_binds(manager, config_key)

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
