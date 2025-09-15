local config = require("HudController.config.init")
local data = require("HudController.data.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local gui_util = require("HudController.gui.util")
local main_panel = require("HudController.gui.elements.profile.panel.main_panel")
local state = require("HudController.gui.state")
local sub_panel = require("HudController.gui.elements.profile.panel.sub_panel")
local util_imgui = require("HudController.util.imgui.init")
local util_table = require("HudController.util.misc.table")

local ace_map = data.ace.map
local set = state.set

local this = {}

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
---@param tree boolean?
local function draw_panel(elem, elem_config, config_key, tree)
    ---@type string
    local item_config_key
    tree = tree == nil and true or tree
    local node = tree
        and imgui.tree_node_str_id(
            string.format("%s_%s_tree", config_key, elem.name_key),
            string.format(
                "%s%s",
                elem.hud_id and ace_map.hudid_name_to_local_name[elem.name_key]
                    or (
                        ace_map.weaponid_name_to_local_name[elem.name_key]
                        or (ace_map.no_lang_key[elem.name_key] and elem.name_key)
                        or gui_util.tr_int("hud_subelement." .. elem.name_key)
                    ),
                elem:any_gui() and string.format(" (%s)", config.lang:tr("misc.text_changed")) or ""
            )
        )

    if not tree or node then
        generic.draw(elem, elem_config, config_key)

        imgui.begin_disabled(elem_config.hide ~= nil and elem_config.hide and not elem.hide_write)

        item_config_key = config_key .. ".options"
        local options = config:get(item_config_key)
        if options and not util_table.empty(options) then
            util_imgui.separator_text(config.lang:tr("hud_element.entry.category_ingame_settings"))

            ---@cast options table<string, integer>
            local sorted = util_table.sort(util_table.keys(options))
            generic.draw_options(sorted, item_config_key, function(option_key, option_config_key)
                elem:set_option(option_key, config:get(option_config_key))
            end)
        end

        main_panel.draw(elem, elem_config, config_key)
        sub_panel.draw(elem, elem_config, config_key)

        imgui.end_disabled()
        if node then
            imgui.tree_pop()
        end
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param children_filtered table<string, HudChildConfig>
---@param config_key string
---@param node_pos Vector2f?
local function draw_panel_child(elem, elem_config, children_filtered, config_key, node_pos)
    local elems = util_table.split(children_filtered, function(t, key, value)
        if gui_util.is_only_thing(value, value.gui_thing) then
            return "box"
        end
        return "panel"
    end) --[[@as {box: {[string]: HudChildConfig}?, panel: {[string]: HudChildConfig}}]]

    ---@type Vector2f[]
    local node_positions = {}
    local text_size = imgui.calc_text_size("")

    if node_pos then
        imgui.indent(20)
        node_pos = Vector2f.new(node_pos.x, node_pos.y)
        node_pos.x = node_pos.x + 20
        table.insert(node_positions, node_pos)
    end

    if elems.box then
        local keys = util_table.sort(util_table.keys(elems.box))
        local chunks = util_table.chunks(keys, 5)

        for i = 1, #chunks do
            local chunk = chunks[i]
            imgui.begin_group()

            for j = 1, #chunk do
                local key = chunk[j]
                local child = elem.children[key]

                if child.gui_ignore then
                    goto continue
                end

                local child_config = elem_config.children[key]
                local child_config_key = string.format("%s.children.%s", config_key, key)
                local cursor_pos = imgui.get_cursor_screen_pos()
                cursor_pos.y = cursor_pos.y + text_size.y / 2 - 3
                local var_key = child_config.gui_thing or "hide"

                if
                    set:checkbox(
                        string.format(
                            "%s %s##%s",
                            config.lang:tr("hud_element.entry.box_" .. var_key),
                            ace_map.weaponid_name_to_local_name[child_config.name_key]
                                or config.lang:tr("hud_subelement." .. child_config.name_key),
                            string.format("%s.%s", child_config_key, var_key)
                        ),
                        string.format("%s.%s", child_config_key, var_key)
                    )
                then
                    child["set_" .. var_key](child, child_config[var_key])
                end

                if node_pos and i == 1 then
                    table.insert(node_positions, cursor_pos)
                end
                ::continue::
            end

            imgui.end_group()
            if i ~= #chunks then
                imgui.same_line()
            end
        end
    end

    if elems.panel then
        local keys = util_table.sort(util_table.keys(elems.panel))
        for i = 1, #keys do
            local key = keys[i]
            local child = elem.children[key]

            if child.gui_ignore then
                goto continue
            end

            local child_config = elem_config.children[key]
            local child_config_key = string.format("%s.children.%s", config_key, key)
            local cursor_pos = imgui.get_cursor_screen_pos()
            cursor_pos.y = cursor_pos.y + text_size.y / 2 - 5

            draw_panel(child, child_config, child_config_key)

            imgui.begin_disabled(child_config.hide ~= nil and child_config.hide)

            local children = util_table.remove(child_config.children or {}, function(t, index, j)
                return not t[index].ignore
            end)

            if not util_table.empty(children) then
                draw_panel_child(child, child_config, children, child_config_key, cursor_pos)
            end

            imgui.end_disabled()

            if node_pos then
                table.insert(node_positions, cursor_pos)
            end
            ::continue::
        end
    end

    if node_pos then
        local start_pos = node_positions[1]
        start_pos.x = start_pos.x - 8
        start_pos.y = start_pos.y + text_size.y + 1

        imgui.draw_list_path_line_to(start_pos)

        for i = 2, #node_positions do
            local pos = node_positions[i]
            pos.x = pos.x - 8
            pos.y = pos.y + 5

            local _node_pos = Vector2f.new(pos.x, pos.y)
            _node_pos.x = _node_pos.x + 7

            imgui.draw_list_path_line_to(pos)
            imgui.draw_list_path_line_to(_node_pos)
            imgui.draw_list_path_line_to(pos)
        end

        imgui.unindent(20)
        imgui.draw_list_path_stroke(4285032552, false, 2)
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param children table<string, HudChildConfig>
---@param config_key string
local function draw_collapsed_child(elem, elem_config, children, config_key)
    local keys = util_table.sort(util_table.keys(children))
    for i = 1, #keys do
        local key = keys[i]
        local child = elem.children[key]

        if child.gui_ignore then
            goto continue
        end

        local child_config = elem_config.children[key]
        local child_config_key = string.format("%s.children.%s", config_key, key)

        if
            imgui.collapsing_header(
                string.format(
                    "%s##%s",
                    child.hud_id and ace_map.hudid_name_to_local_name[child.name_key]
                        or (
                            ace_map.weaponid_name_to_local_name[child.name_key]
                            or (ace_map.no_lang_key[child.name_key] and child.name_key)
                            or gui_util.tr_int("hud_subelement." .. child.name_key)
                        ),
                    string.format("%s_%s_tree", config_key, child.name_key)
                )
            )
        then
            draw_panel(child, child_config, child_config_key, false)

            imgui.begin_disabled(child_config.hide ~= nil and child_config.hide)

            local children = util_table.remove(child_config.children or {}, function(t, index, j)
                return not t[index].ignore
            end)

            if not util_table.empty(children) then
                util_imgui.separator_text(config.lang:tr("hud_element.entry.category_children"))
                draw_panel_child(child, child_config, children, child_config_key)
            end

            imgui.end_disabled()
        end
        ::continue::
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
function this.draw(elem, elem_config, config_key)
    if not elem.gui_ignore then
        draw_panel(elem, elem_config, config_key, false)
    end

    imgui.begin_disabled(elem_config.hide ~= nil and elem_config.hide and not elem.hide_write)

    local children = util_table.remove(elem_config.children or {}, function(t, i, j)
        return not t[i].ignore
    end)

    if not util_table.empty(children) then
        if not elem.gui_ignore then
            util_imgui.separator_text(config.lang:tr("hud_element.entry.category_children"))
        end

        if elem.gui_header_children then
            draw_collapsed_child(elem, elem_config, children, config_key)
        else
            draw_panel_child(elem, elem_config, children, config_key)
        end
    end

    imgui.end_disabled()
end

return this
