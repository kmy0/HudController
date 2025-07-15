local config = require("HudController.config")
local elem = require("HudController.gui.debug.elem")
local play_object = require("HudController.hud.play_object")
local util_table = require("HudController.util.misc.table")

local this = { is_opened = false, show_disabled = false }
local window = {
    flags = 0,
    condition = 2,
    font = nil,
    pos = { 50, 50 },
    size = { 800, 700 },
}
local ace_gui_elements = {}
---@type table<string, Vector2f>
local sub_window = {}

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
        sub_window = {}
        sub_window[key] = imgui.get_mouse()
    end

    if sub_window[key] then
        local button_size = { 100, 20 }

        imgui.set_next_window_pos(sub_window[key])
        local open = imgui.begin_window(
            string.format("%s##window_%s", panel.name, key),
            true,
            1 << 1 | 1 << 2 | 1 << 8 | 1 << 6 | 1 << 5
        )

        if not open then
            sub_window[key] = nil
            imgui.end_window()
            return
        end

        imgui.spacing()
        imgui.indent(3)

        if imgui.button(string.format("%s##%s", panel.visible and "Hide" or "Show", key), button_size) then
            panel.obj:set_Visible(not panel.visible)
        end

        imgui.same_line()

        if imgui.button(string.format("%s##%s", panel.draw_name and "Hide Pos" or "Draw Pos", key), button_size) then
            panel.draw_name = not panel.draw_name
        end

        imgui.same_line()

        if
            panel.children
            and #panel.children > 0
            and imgui.button(
                string.format("%s Chain##%s", not panel.chain_state and "Open" or "Close", key),
                button_size
            )
        then
            local bool = not panel.chain_state
            do_to_all(panel, function(p)
                p.chain_state = bool
            end)
        end

        imgui.same_line()

        if imgui.button("Copy Path##" .. key, button_size) then
            imgui.set_clipboard(elem.get_chain(panel))
        end

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
                mouse.x < sub_window[key].x
                or mouse.y < sub_window[key].y
                or mouse.x > sub_window[key].x + win_size.x
                or mouse.y > sub_window[key].y + win_size.y
            )
        then
            sub_window[key] = nil
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
        imgui.set_next_item_open(panel.chain_state)

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

function this.draw()
    imgui.set_next_window_pos(window.pos, window.condition)
    imgui.set_next_window_size(window.size, window.condition)

    this.is_opened = imgui.begin_window("HudController Debug", this.is_opened, window.flags)

    if not this.is_opened then
        ace_gui_elements = {}
        imgui.end_window()
        return
    end

    if util_table.empty(ace_gui_elements) then
        ace_gui_elements = elem.get_gui()
    end

    imgui.spacing()
    imgui.indent(2)

    if imgui.button("Clear HUD Defaults") then
        play_object.default.clear()
    end

    imgui.same_line()

    _, this.show_disabled = imgui.checkbox("Show Disabled", this.show_disabled)
    _, config.is_debug = imgui.checkbox("Enable Debug Log", config.is_debug)

    imgui.text("Right click tree nodes for options")
    imgui.text("H - Hidden")
    imgui.text("S - Has States")

    imgui.unindent(2)
    imgui.separator()

    local keys = util_table.sort(util_table.keys(ace_gui_elements))
    for i = 1, #keys do
        local key = keys[i]
        local gui_elem = ace_gui_elements[key]

        if this.show_disabled or gui_elem.gui:get_Enabled() then
            ---@diagnostic disable-next-line: missing-fields
            elem.draw_pos({ obj = gui_elem.root }, key, 4278190335)

            if imgui.collapsing_header(key) then
                draw_panel_tree(gui_elem.ctrl, key)
            end
        end
    end

    imgui.end_window()
end

return this
