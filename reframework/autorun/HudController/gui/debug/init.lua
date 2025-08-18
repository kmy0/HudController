---@class GuiDebug
---@field window GuiWindow
---@field sub_window GuiWindow
---@field ace_gui_elements table<string, AceGUI>
---@field sub_window_pos table<string, Vector2f>
---@field snapshot string[]
---@field first_frame boolean

local config = require("HudController.config")
local defaults = require("HudController.hud.defaults")
local elem = require("HudController.gui.debug.elem")
local gui_util = require("HudController.gui.util")
local state = require("HudController.gui.state")
local util_imgui = require("HudController.util.imgui")
local util_table = require("HudController.util.misc.table")

---@class GuiDebug
local this = {
    window = {
        flags = 0,
        condition = 2,
    },
    sub_window = {
        flags = 1 << 1 | 1 << 2 | 1 << 8 | 1 << 6 | 1 << 5,
        condition = 0,
    },
    ace_gui_elements = {},
    ---@type table<string, Vector2f>
    sub_window_pos = {},
    snapshot = {},
    first_frame = true,
    window_size = 170,
}

---@param panel AceElem
---@param f fun(panel: AceElem)
local function do_to_all(panel, f)
    f(panel)
    for _, c in pairs(panel.children or {}) do
        do_to_all(c, f)
    end
end

---@param panel AceElem
---@param key string
local function draw_option_window(panel, key)
    if imgui.is_mouse_clicked(1) and imgui.is_item_hovered() then
        this.sub_window_pos = {}
        this.sub_window_pos[key] = imgui.get_mouse()
    end

    if this.sub_window_pos[key] then
        local button_size = { 100, 20 }

        imgui.set_next_window_pos(this.sub_window_pos[key])
        local open = imgui.begin_window(string.format("%s##window_%s", panel.name, key), true, this.sub_window.flags)

        if not open then
            this.sub_window_pos[key] = nil
            imgui.end_window()
            return
        end

        imgui.spacing()
        imgui.indent(3)

        if
            imgui.button(
                string.format(
                    "%s##%s",
                    panel.visible and config.lang:tr("debug.button_hide") or config.lang:tr("debug.button_show"),
                    key
                ),
                button_size
            )
        then
            panel.obj:set_Visible(not panel.visible)
            panel.obj:set_ForceInvisible(panel.visible)
        end

        imgui.same_line()

        if
            imgui.button(
                string.format(
                    "%s##%s",
                    panel.draw_name and config.lang:tr("debug.button_hide_pos")
                        or config.lang:tr("debug.button_draw_pos"),
                    key
                ),
                button_size
            )
        then
            panel.draw_name = not panel.draw_name
        end

        imgui.same_line()

        if
            panel.children
            and #panel.children > 0
            and imgui.button(
                string.format(
                    "%s##%s",
                    not panel.chain_state and config.lang:tr("debug.button_open_chain")
                        or config.lang:tr("debug.button_close_chain"),
                    key
                ),
                button_size
            )
        then
            local bool = not panel.chain_state
            do_to_all(panel, function(p)
                p.chain_state = bool
            end)
        end

        imgui.same_line()

        if imgui.button(string.format("%s##%s", config.lang:tr("debug.button_copy_args"), key), button_size) then
            imgui.set_clipboard(elem.get_chain(panel))
        end
        util_imgui.tooltip(config.lang:tr("debug.tooltip_copy_args"))

        if panel.states and #panel.states > 1 then
            imgui.separator()

            local groups = util_table.chunks(panel.states, 4)
            for i = 1, #groups do
                local states = groups[i]

                imgui.begin_group()

                for j = 1, #states do
                    if imgui.button(states[j], button_size) then
                        panel.obj:set_PlayState(states[j])
                    end
                end

                imgui.end_group()

                if i ~= #groups then
                    imgui.same_line()
                end
            end
        end

        local mouse = imgui.get_mouse()
        local lbm = imgui.is_mouse_clicked(0) or imgui.is_mouse_clicked(1)
        local win_size = imgui.get_window_size()

        if
            lbm
            and (
                mouse.x < this.sub_window_pos[key].x
                or mouse.y < this.sub_window_pos[key].y
                or mouse.x > this.sub_window_pos[key].x + win_size.x
                or mouse.y > this.sub_window_pos[key].y + win_size.y
            )
        then
            this.sub_window_pos[key] = nil
        end

        imgui.spacing()
        imgui.unindent(3)
        imgui.end_window()
    end
end

---@param panel AceElem
---@param key string
local function draw_panel_tree(panel, key)
    panel.visible = not (not panel.obj:get_Visible() or panel.obj:get_ForceInvisible())
    key = key .. panel.name
    local keys = {}

    if not panel.visible then
        table.insert(keys, "H")
    end

    if panel.states and #panel.states > 1 then
        table.insert(keys, "S")
    end

    local name = panel.name
    if #keys > 0 then
        name = string.format("%s - %s", name, table.concat(keys, ", "))
    end

    if not util_table.empty(panel.children or {}) then
        if not this.first_frame then
            imgui.set_next_item_open(panel.chain_state)
        end

        local node = imgui.tree_node_str_id(string.format("%s##%s", panel.name, key), name)
        draw_option_window(panel, key)

        if node then
            for i = 1, #panel.children do
                draw_panel_tree(panel.children[i], key)
            end

            imgui.tree_pop()

            if not panel.tree then
                panel.tree = true
                panel.chain_state = true
            end
        elseif panel.tree then
            panel.chain_state = false
            panel.tree = false
        end
    else
        imgui.text("   •   " .. name)
        draw_option_window(panel, key)
    end

    if panel.draw_name then
        if not elem.draw_pos(panel, panel.name, 0xFFFFFFFF) then
            panel.draw_name = false
        end
    end
end

function this.close()
    local gui_debug = config.gui.current.gui.debug
    gui_debug.is_opened = false

    this.sub_window_pos = {}
    this.snapshot = {}
    this.ace_gui_elements = {}
    config.gui:save()
end

function this.draw()
    local changed = false
    local gui_debug = config.gui.current.gui.debug
    local config_debug = config.debug.current.debug

    imgui.set_next_window_pos(
        Vector2f.new(gui_debug.pos_x, gui_debug.pos_y),
        not state.redo_win_pos.debug and this.window.condition or nil
    )
    imgui.set_next_window_size(
        Vector2f.new(gui_debug.size_x, gui_debug.size_y),
        not state.redo_win_pos.debug and this.window.condition or nil
    )
    state.redo_win_pos.debug = false

    if config.lang.font then
        imgui.push_font(config.lang.font)
    end

    gui_debug.is_opened = imgui.begin_window(
        string.format("%s %s", config.name, config.lang:tr("debug.name")),
        gui_debug.is_opened,
        this.window.flags
    )

    local pos = imgui.get_window_pos()
    local size = imgui.get_window_size()

    gui_debug.pos_x, gui_debug.pos_y = pos.x, pos.y
    gui_debug.size_x, gui_debug.size_y = size.x, size.y

    if not gui_debug.is_opened then
        if config.lang.font then
            imgui.pop_font()
        end

        this.close()
        imgui.end_window()
        return
    end

    if util_table.empty(this.ace_gui_elements) then
        this.ace_gui_elements = elem.get_gui()
    end

    imgui.spacing()
    imgui.indent(2)

    imgui.begin_child_window("debug_child_window", { 0, this.window_size }, false, 1 << 3)
    local pos = imgui.get_cursor_pos()

    if imgui.button(gui_util.tr("debug.button_clear_default")) then
        defaults.play_object.clear()
    end
    util_imgui.tooltip(config.lang:tr("debug.tooltip_clear_default"))

    imgui.same_line()

    changed, config_debug.show_disabled =
        imgui.checkbox(gui_util.tr("debug.box_show_disabled"), config_debug.show_disabled)
    util_imgui.tooltip(config.lang:tr("debug.tooltip_show_disabled"))

    local keys = util_table.filter(util_table.sort(util_table.keys(this.ace_gui_elements)), function(key, value)
        local gui_elem = this.ace_gui_elements[value]
        return config_debug.show_disabled or gui_elem.gui:get_Enabled()
    end)
    keys = util_table.sort(util_table.values(keys))

    if imgui.button(gui_util.tr("debug.button_snapshot")) then
        this.snapshot = util_table.deep_copy(keys)
    end
    util_imgui.tooltip(config.lang:tr("debug.tooltip_snapshot"))

    imgui.same_line()
    imgui.begin_disabled(util_table.empty(this.snapshot))
    changed, config_debug.is_filter = imgui.checkbox(gui_util.tr("debug.box_filter"), config_debug.is_filter)
    util_imgui.tooltip(config.lang:tr("debug.tooltip_filter"))
    imgui.end_disabled()

    if config_debug.is_filter and not util_table.empty(this.snapshot) then
        keys = util_table.filter(keys, function(key, value)
            return not util_table.contains(this.snapshot, value)
        end)
        keys = util_table.sort(util_table.values(keys))
    end

    changed, config_debug.is_debug = imgui.checkbox(gui_util.tr("debug.box_enable_log"), config_debug.is_debug)
    imgui.text(config.lang:tr("debug.text_option_info"))
    imgui.text(string.format("H - %s", config.lang:tr("debug.text_hidden")))
    imgui.text(string.format("S - %s", config.lang:tr("debug.text_states")))
    imgui.text(config.lang:tr("debug.text_pos_info"))

    local spacing = 4
    local size = imgui.get_cursor_pos().y - pos.y - spacing
    this.window_size = size > 0 and size or this.window_size

    imgui.unindent(2)
    imgui.end_child_window()
    imgui.separator()

    imgui.begin_child_window("debug_elements_child_window", { -1, -1 }, false)
    for i = 1, #keys do
        local key = keys[i]
        local gui_elem = this.ace_gui_elements[key]
        ---@diagnostic disable-next-line: missing-fields
        elem.draw_pos({ obj = gui_elem.root }, key, 4278190335)

        if imgui.collapsing_header(key) then
            draw_panel_tree(gui_elem.ctrl, key)
        end
    end
    imgui.end_child_window()

    if config.lang.font then
        imgui.pop_font()
    end

    if changed then
        config.save_global()
    end

    imgui.end_window()
    this.first_frame = false
end

return this
