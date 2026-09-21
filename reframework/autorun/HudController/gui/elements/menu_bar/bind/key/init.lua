local bind_manager = require("HudController.hud.bind.key.init")
local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local managers = require("HudController.gui.elements.menu_bar.bind.key.managers.init")
local state = require("HudController.gui.state")
local util_bind = require("HudController.util.game.bind.init")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_key = require("HudController.gui.elements.menu_bar.bind.key.util")
local util_menubar = require("HudController.gui.elements.menu_bar.util")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

local this = {
    ---@type table<BindKeyType, GuiKeyManagerBase>
    managers = {},
}
---@enum BindKeyType
local tab_type = {
    ALL = 1,
    HUD = 2,
    OPTION_ELEM = 3,
    OPTION_HUD = 4,
    OPTION_MOD = 5,
    OPTION_GAME = 6,
    OPTION_USER = 7,
}

---@return number
local function get_width()
    return config.lang.font_size * (200 / 16) * 3
        + 6 * 4
        + util_imgui.get_button_width(config.lang:tr("menu.bind.key.button_add"))
end

local function restore_indexes()
    config:set("__temp.combo_target", 1)
    config:set("__temp.combo_target_elem", "")
    config:set("__temp.combo_action_type", 1)
    config:set("__temp.combo_trigger_type", 1)
    config:set("__temp.option_value", 0)
end

local function clear_listener()
    state.listener = nil
    bind_manager.monitor:unpause()
end

local function start_listener()
    state.listener = {
        listener = util_bind.listener:new(),
    }
end

---@param manager GuiKeyManagerBase
local function draw_listener(manager)
    if not state.listener then
        return
    end

    util_imgui.adjust_pos(0, -2)
    bind_manager.monitor:pause()

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

    util_imgui.adjust_pos(0, 4)
    imgui.table_set_column_index(0)

    state.listener.collision = manager:is_collision(bind)

    util_imgui.begin_disabled(state.listener.collision ~= nil or bind.name == "")

    if imgui.button(util_gui.tr("menu.bind.key.button_save")) then
        manager:register(bind)
        clear_listener()
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
                util_misc.trunc_string2(state.listener.collision, util_imgui.get_available_width())
            ),
            mod.enum.colors.bad
        )
    end

    imgui.text(table.concat(bind_name, " + "))
    imgui.separator()
end

---@return BindKeyType
local function draw_buttons()
    local config_mod = config.current.mod
    local buttons = {
        { label = config.lang:tr("menu.bind.key.all"), key = tab_type.ALL },
        { label = config.lang:tr("menu.bind.key.hud"), key = tab_type.HUD },
        { label = config.lang:tr("menu.bind.key.option_elem"), key = tab_type.OPTION_ELEM },
        { label = config.lang:tr("menu.bind.key.option"), key = tab_type.OPTION_HUD },
        { label = config.lang:tr("menu.bind.key.option_mod"), key = tab_type.OPTION_MOD },
        { label = config.lang:tr("menu.bind.key.option_game"), key = tab_type.OPTION_GAME },
    }

    if not cd.combo.option_user_bind:empty() then
        table.insert(
            buttons,
            { label = config.lang:tr("menu.bind.key.option_user"), key = tab_type.OPTION_USER }
        )
    end

    config_mod.bind.key.key_type_selection =
        math.min(config_mod.bind.key.key_type_selection, #buttons)

    local max_width = 0
    for _, b in pairs(buttons) do
        local text_size = imgui.calc_text_size(b.label)
        max_width = math.max(max_width, text_size.x) --[[@as number]]
    end
    max_width = max_width + config.lang.font_size * 3

    local changed = false
    for _, b in ipairs(buttons) do
        if
            util_imgui.draw_sel_button(
                string.format("%s##bind_key_sel_button|%s", b.label, b.key),
                config_mod.bind.key.key_type_selection == b.key,
                { max_width, 0 }
            )
        then
            changed = true
            config_mod.bind.key.key_type_selection = b.key
            config:save()
        end
    end

    if changed then
        local manager = this.managers[config_mod.bind.key.key_type_selection]

        clear_listener()
        restore_indexes()

        if manager then
            manager:make_base_bind(true)
        end
    end

    return config_mod.bind.key.key_type_selection
end

---@param manager GuiKeyManagerBase
local function draw_registered_binds(manager)
    util_imgui.adjust_pos(0, -2)
    imgui.push_style_var(imgui.ImGuiStyleVar.ItemSpacing, Vector2f.new(2, 0))

    if
        imgui.begin_table("keybind_state", 5, imgui.TableFlags.NoClip, Vector2f.new(get_width(), 0))
    then
        imgui.table_setup_column("##0", imgui.ColumnFlags.WidthFixed)
        imgui.table_setup_column("##1", imgui.ColumnFlags.WidthFixed)
        imgui.table_setup_column("##2", imgui.ColumnFlags.WidthFixed)
        imgui.table_setup_column("##3", imgui.ColumnFlags.WidthFixed)
        imgui.table_setup_column("##4", imgui.ColumnFlags.WidthStretch)

        local binds = manager.manager:get_base_binds()

        imgui.separator()

        ---@type ModBind[]
        local remove = {}
        for i = 1, #binds do
            local bind = binds[i]
            local color = 0

            if state.listener and state.listener.collision == manager:get_bind_name(bind) then
                color = mod.enum.colors.bad
            end

            imgui.table_next_row()
            imgui.table_set_column_index(0)
            imgui.push_style_color(5, color)
            imgui.begin_rect()

            local opt_name = manager:get_bind_name(bind)

            if
                util_imgui.draw_remove_button(
                    string.format("##%s|%s", bind.name, util_table.repr_any(bind.bound_value))
                )
            then
                table.insert(remove, bind)
            end

            imgui.same_line()
            imgui.spacing()

            imgui.table_set_column_index(1)
            imgui.text(util_key.get_action_name(bind))
            imgui.same_line()
            imgui.spacing()

            imgui.table_set_column_index(2)
            imgui.text(util_key.get_trigger_name(bind))
            imgui.same_line()
            imgui.spacing()

            imgui.table_set_column_index(3)
            imgui.text(util_key.get_key_bind_name(bind))
            imgui.same_line()
            imgui.spacing()

            imgui.table_set_column_index(4)
            local truncated = util_misc.trunc_string2(opt_name, util_imgui.get_available_width())
            imgui.text(truncated)
            imgui.same_line()
            imgui.spacing()

            if truncated ~= opt_name then
                util_imgui.tooltip(opt_name)
            end

            imgui.end_rect(0, 0)
            imgui.pop_style_color(1)
        end

        if not util_table.empty(remove) then
            for _, bind in pairs(remove) do
                manager.manager:unregister(bind)
            end

            config:set(manager.config_key, manager.manager:get_base_binds())
        end

        imgui.end_table()
    end

    imgui.pop_style_var(1)
end

local function draw_all_registered_binds()
    local any = false

    if not util_table.empty(bind_manager.hud.binds) then
        any = true
        util_imgui.separator_text(config.lang:tr("menu.bind.key.hud"))
        draw_registered_binds(this.managers[tab_type.HUD])
    end

    if not util_table.empty(bind_manager.option_elem.binds) then
        any = true
        util_imgui.separator_text(config.lang:tr("menu.bind.key.option_elem"))
        draw_registered_binds(this.managers[tab_type.OPTION_ELEM])
    end

    if not util_table.empty(bind_manager.option_hud.binds) then
        any = true
        util_imgui.separator_text(config.lang:tr("menu.bind.key.option"))
        draw_registered_binds(this.managers[tab_type.OPTION_HUD])
    end

    if not util_table.empty(bind_manager.option_mod.binds) then
        any = true
        util_imgui.separator_text(config.lang:tr("menu.bind.key.option_mod"))
        draw_registered_binds(this.managers[tab_type.OPTION_MOD])
    end

    if not util_table.empty(bind_manager.option_game.binds) then
        any = true
        util_imgui.separator_text(config.lang:tr("menu.bind.key.option_game"))
        draw_registered_binds(this.managers[tab_type.OPTION_GAME])
    end

    if not util_table.empty(bind_manager.option_user.binds) then
        any = true
        util_imgui.separator_text(config.lang:tr("menu.bind.key.option_user"))
        draw_registered_binds(this.managers[tab_type.OPTION_USER])
    end

    if not any then
        util_imgui.tooltip_text(config.lang:tr("menu.bind.key.tooltip_no_binds"))
        imgui.invisible_button("i_button|all_binds", { get_width() + 6, 0 })
    end
end

---@param manager GuiKeyManagerBase
local function draw_bind_option_table(manager)
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
        if manager:draw_target() then
            manager:make_base_bind(true)
        end

        imgui.table_set_column_index(1)
        imgui.set_next_item_width(item_width)
        if manager:draw_trigger() then
            manager:make_base_bind()
        end

        imgui.table_set_column_index(2)
        imgui.set_next_item_width(item_width)
        if manager:draw_action() then
            manager:make_base_bind()
        end

        imgui.table_set_column_index(3)

        if imgui.button(util_gui.tr("menu.bind.key.button_add")) then
            start_listener()
        end

        imgui.push_style_var(imgui.ImGuiStyleVar.ItemSpacing, Vector2f.new(0, 2))
        imgui.same_line()
        util_imgui.dummy_button3("##i_button|bind1", { 6, 0 })
        imgui.end_table()
        imgui.pop_style_var(1)
    end

    imgui.push_item_width(get_width())
    if manager:draw_option() then
        manager:make_base_bind()
    end
    imgui.pop_item_width()
end

local function draw_key_bind_menu()
    imgui.spacing()
    imgui.indent(2)

    if
        imgui.begin_table(
            "bind_key_main_table",
            2,
            imgui.TableFlags.BordersInnerV | imgui.TableFlags.SizingStretchProp --[[@as ImGuiTableFlags]]
        )
    then
        imgui.table_setup_column("##buttons")
        imgui.table_setup_column("##content")

        imgui.table_next_row()
        imgui.table_set_column_index(0)
        local selected = draw_buttons()
        local manager = this.managers[selected]

        imgui.table_set_column_index(1)
        util_imgui.begin_disabled(state.listener ~= nil or manager and manager:is_disabled())

        if manager then
            draw_bind_option_table(manager)
            util_imgui.end_disabled()
            draw_listener(manager)
            draw_registered_binds(manager)
        else
            util_imgui.end_disabled()
            draw_all_registered_binds()
        end

        imgui.end_table()
    end

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    if not util_menubar.draw_menu(util_gui.tr("menu.bind.key.name"), draw_key_bind_menu) then
        clear_listener()
    end
end

---@return boolean
function this.init()
    restore_indexes()

    this.managers[tab_type.HUD] = managers.hud:new(bind_manager.hud, "mod.bind.key.hud")
    this.managers[tab_type.OPTION_MOD] =
        managers.option_mod:new(bind_manager.option_mod, "mod.bind.key.option_mod")
    this.managers[tab_type.OPTION_ELEM] =
        managers.option_elem:new(bind_manager.option_elem, "mod.bind.key.option_elem")
    this.managers[tab_type.OPTION_HUD] =
        managers.option_hud:new(bind_manager.option_hud, "mod.bind.key.option_hud")
    this.managers[tab_type.OPTION_GAME] =
        managers.option_game:new(bind_manager.option_game, "mod.bind.key.option_game")
    this.managers[tab_type.OPTION_USER] =
        managers.option_user:new(bind_manager.option_user, "mod.bind.key.option_user")

    local manager = this.managers[config.current.mod.bind.key.key_type_selection]
    if manager then
        manager:make_base_bind(true)
    end

    return true
end

return this
