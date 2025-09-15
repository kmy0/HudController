---@class GuiDebug
---@field window GuiWindow
---@field sub_window GuiWindow
---@field sub_window_pos table<string, Vector2f>
---@field first_frame boolean

local config = require("HudController.config.init")
local config_set_base = require("HudController.util.imgui.config_set")
local defaults = require("HudController.hud.defaults.init")
local gui_util = require("HudController.gui.util")
local hud_debug = require("HudController.hud.debug.init")
local state = require("HudController.gui.state")
local util_imgui = require("HudController.util.imgui.init")
local util_table = require("HudController.util.misc.table")

local set = config_set_base:new(config.debug)

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
    ---@type table<string, Vector2f>
    sub_window_pos = {},
    first_frame = true,
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
        local open = imgui.begin_window(
            string.format("%s##window_%s", panel.name, key),
            true,
            this.sub_window.flags
        )

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
                    panel.visible and config.lang:tr("debug.button_hide")
                        or config.lang:tr("debug.button_show"),
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

        if
            imgui.button(
                string.format("%s##%s", config.lang:tr("debug.button_copy_args"), key),
                button_size
            )
        then
            imgui.set_clipboard(hud_debug.get_chain(panel))
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

    if panel.states and #panel.states > 1 then
        name = string.format("%s / %s", name, panel.obj:get_PlayState())
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
        if not hud_debug.draw_pos(panel, panel.name, 0xFFFFFFFF) then
            panel.draw_name = false
        end
    end
end

function this.close()
    local gui_debug = config.gui.current.gui.debug
    gui_debug.is_opened = false

    this.sub_window_pos = {}
    hud_debug.clear()
    config.gui:save()
end

function this.draw()
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

    hud_debug.init()

    imgui.spacing()
    imgui.indent(2)

    ---@type string[]
    local keys

    util_imgui.draw_child_window("debug_child_window", function()
        if imgui.button(gui_util.tr("debug.button_add_profile")) then
            hud_debug.add_all_element_profile()
        end

        imgui.same_line()

        if imgui.button(gui_util.tr("debug.button_write_all")) then
            hud_debug.write_all_elements()
        end
        util_imgui.tooltip(config.lang:tr("debug.tooltip_write_all"))

        imgui.same_line()

        if imgui.button(gui_util.tr("debug.button_clear_default")) then
            defaults.play_object:clear()
        end
        util_imgui.tooltip(config.lang:tr("debug.tooltip_clear_default"))
        util_imgui.tooltip(
            string.format(
                "%s\n%s\n%s\n%s",
                config.lang:tr("debug.text_option_info"),
                string.format("H - %s", config.lang:tr("debug.text_hidden")),
                string.format("S - %s", config.lang:tr("debug.text_states")),
                config.lang:tr("debug.text_pos_info")
            ),
            true,
            string.format("(%s?)", config.lang:tr("misc.text_help"))
        )

        set:checkbox(gui_util.tr("debug.box_show_disabled"), "debug.show_disabled")
        util_imgui.tooltip(config.lang:tr("debug.tooltip_show_disabled"))
        set:checkbox(gui_util.tr("debug.box_disable_cache"), "debug.disable_cache")
        util_imgui.tooltip(config.lang:tr("debug.tooltip_disable_cache"))
        set:checkbox(gui_util.tr("debug.box_enable_log"), "debug.is_debug")
        imgui.same_line()
        set:checkbox(gui_util.tr("debug.box_filter_known_errors"), "debug.filter_known_errors")

        keys = hud_debug.get_keys(not config_debug.show_disabled)

        if imgui.button(gui_util.tr("debug.button_snapshot")) then
            hud_debug.make_snapshot(keys)
        end
        util_imgui.tooltip(config.lang:tr("debug.tooltip_snapshot"))

        imgui.same_line()
        imgui.begin_disabled(util_table.empty(hud_debug.snapshot))

        set:checkbox(gui_util.tr("debug.box_filter"), "debug.is_filter")
        util_imgui.tooltip(config.lang:tr("debug.tooltip_filter"))
        imgui.end_disabled()

        imgui.begin_disabled(hud_debug.perf.total ~= hud_debug.perf.completed)

        if imgui.button(gui_util.tr("debug.button_perf_test")) then
            hud_debug.perf_test()
        end
        util_imgui.tooltip(".../reframework/data/HudController/perf_log.txt")

        imgui.end_disabled()

        if hud_debug.perf.total ~= hud_debug.perf.completed then
            imgui.same_line()
            imgui.text(string.format("%s/%s", hud_debug.perf.completed, hud_debug.perf.total))
            util_imgui.tooltip(table.concat(hud_debug.perf.obj, "\n"), true)
        end

        if config_debug.is_filter and not util_table.empty(hud_debug.snapshot) then
            keys = hud_debug.filter(keys)
        end

        imgui.unindent(2)
    end, 152, 4)

    imgui.separator()
    imgui.begin_child_window("debug_elements_child_window", { -1, -1 }, false)
    for i = 1, #keys do
        local key = keys[i]
        local gui_elem = hud_debug.elements[key]
        ---@diagnostic disable-next-line: missing-fields
        hud_debug.draw_pos({ obj = gui_elem.root }, key, 4278190335)

        if imgui.collapsing_header(key) then
            draw_panel_tree(gui_elem.ctrl, key)
        end
    end
    imgui.end_child_window()

    if config.lang.font then
        imgui.pop_font()
    end

    imgui.end_window()
    this.first_frame = false
end

return this
