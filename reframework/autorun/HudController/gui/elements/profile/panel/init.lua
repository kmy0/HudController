local config = require("HudController.config.init")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local element_def = require("HudController.data.option.element.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local main_panel = require("HudController.gui.elements.profile.panel.main.init")
local op = require("HudController.hud.manager.op.init")
local selector = require("HudController.gui.elements.profile.panel.profile_selector")
local sub_panel = require("HudController.gui.elements.profile.panel.sub.init")
local user_option = require("HudController.hud.user.option")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_opt = require("HudController.data.option.util")
local util_table = require("HudController.util.misc.table")

local ace_map = data.ace.map

local this = {}
---@enum TreeType
local tree_type = {
    NONE = 1,
    TREE = 2,
    FAKE = 3,
}
---@type fun(elem: HudBase, elem_config: HudBaseConfig, config_key: string, elems: {[string]: HudChildConfig}, tree: TreeType, out_node_positions: Vector2f[]?)
local draw_panel_child_contents

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_panel_contents(elem, elem_config, config_key)
    generic.draw(elem, elem_config, config_key)

    util_imgui.begin_disabled(elem_config.hide ~= nil and elem_config.hide and not elem.hide_write)

    local item_config_key = config_key .. ".options"
    local options = config:get(item_config_key)
    if options and not util_table.empty(options) then
        util_imgui.separator_text(config.lang:tr("hud_element.entry.category_ingame_settings"))

        ---@cast options table<string, integer>
        local sorted = util_table.sort(util_table.keys(options))
        generic.draw_options(sorted, item_config_key, function(option_key, value)
            if op.hud_elem.is_current_profile(elem) then
                elem:set_option(option_key, value)
            end
        end)
    end

    local user_opt = user_option.element[e.get("app.GUIHudDef.TYPE")[elem.hud_id]] or {}
    if not util_table.empty(user_opt) then
        util_imgui.separator_text(config.lang:tr("hud.category_user_options"))
        generic.draw_user_options(user_opt, string.format("%s.user_options", config_key))
    end

    main_panel.draw(elem, elem_config, config_key)
    sub_panel.draw(elem, elem_config, config_key)

    util_imgui.end_disabled()
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
---@param tree TreeType?
---@param root_elem boolean?
---@param indent number?
local function draw_panel(elem, elem_config, config_key, tree, root_elem, indent)
    if root_elem then
        util_imgui.begin_disabled(not config:get(string.format("%s.enabled", config_key)))
    else
        util_imgui.begin_disabled(false)
    end

    tree = tree == nil and tree_type.TREE or tree
    local id = string.format("%s_%s_tree", config_key, elem.name_key)
    local label = string.format(
        "%s%s",
        util_gui.tr_elem_name(elem.hud_id, elem.name_key),
        elem:any_gui() and string.format(" (%s)", config.lang:tr("misc.text_changed")) or ""
    )

    local function draw_contents()
        if indent then
            imgui.indent(indent)
        end

        draw_panel_contents(elem, elem_config, config_key)
        if tree == tree_type.TREE then
            imgui.tree_pop()
        end

        if indent then
            imgui.unindent(indent)
        end
    end

    if tree == tree_type.TREE and imgui.tree_node_str_id(id, label) or tree == tree_type.NONE then
        draw_contents()
    elseif tree == tree_type.FAKE then
        util_imgui.fake_tree_node(id, label, draw_contents)
    end

    util_imgui.end_disabled()
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param children table<string, HudChildConfig>
---@param config_key string
---@param node_pos Vector2f?
local function draw_panel_child(elem, elem_config, children, config_key, node_pos)
    local elems = util_table.groupby(children, function(_, name_key, value)
        local child = elem.children[name_key]
        if util_gui.is_only_thing(child, value, value.gui_thing) then
            if child.children and not util_table.empty(child.children) then
                return "panel_fake"
            end

            return "box"
        end

        return "panel"
    end) --[[@as {box: {[string]: HudChildConfig}?, panel: {[string]: HudChildConfig}, panel_fake: {[string]: HudChildConfig}}]]

    ---@type Vector2f[]
    local node_positions = {}
    local text_size = imgui.calc_text_size("")
    local indent = util_imgui.scale_w_font_size(20)
    local indent_offset = -(config.lang.font_size - 16) / 4

    if node_pos then
        imgui.indent(indent)
        node_pos = Vector2f.new(node_pos.x, node_pos.y)
        node_pos.x = node_pos.x + indent + indent_offset
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
                local ctx =
                    { elem = child, elem_config = child_config, config_key = child_config_key }
                local label = string.format(
                    "%s %s##%s",
                    config.lang:tr("hud_element.entry.box_" .. var_key),
                    ace_map.weaponid_name_to_local_name[child_config.name_key]
                        or config.lang:tr("hud_subelement." .. child_config.name_key),
                    string.format("%s.%s", child_config_key, var_key)
                )

                if var_key == "hide" then
                    util_opt.draw_apply_elem(element_def.opt.hide, ctx, label)
                else
                    local def = element_def.sub[child_config.hud_sub_type]
                    local opt = def.opt[var_key]
                    util_opt.draw_apply_elem(opt, ctx, label)
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
        draw_panel_child_contents(
            elem,
            elem_config,
            config_key,
            elems.panel,
            tree_type.TREE,
            node_pos and node_positions
        )
    end

    if elems.panel_fake then
        draw_panel_child_contents(
            elem,
            elem_config,
            config_key,
            elems.panel_fake,
            tree_type.FAKE,
            node_pos and node_positions
        )
    end

    if node_pos then
        local offset_x = util_imgui.scale_w_font_size(8)
        local start_pos = node_positions[1]
        start_pos.x = start_pos.x - offset_x
        start_pos.y = start_pos.y + text_size.y + 1
        local dl = imgui.get_window_draw_list()

        for i = 2, #node_positions do
            local s_pos = node_positions[i]
            s_pos.x = s_pos.x - offset_x + indent_offset
            s_pos.y = s_pos.y + 5
            local e_pos = Vector2f.new(s_pos.x, s_pos.y)
            e_pos.x = e_pos.x + offset_x - 2

            dl:add_line(start_pos, s_pos, 4285032552, 2)
            dl:add_line(s_pos, e_pos, 4285032552, 2)

            start_pos = s_pos
        end

        imgui.unindent(indent)
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
---@param elems {[string]: HudChildConfig}
---@param tree TreeType
---@param out_node_positions Vector2f[]?
function draw_panel_child_contents(elem, elem_config, config_key, elems, tree, out_node_positions)
    local text_size = imgui.calc_text_size("")
    local indent = util_imgui.scale_w_font_size(20)

    local keys = util_table.sort(util_table.keys(elems))
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

        draw_panel(child, child_config, child_config_key, tree, nil, indent - 21)

        util_imgui.begin_disabled(child_config.hide ~= nil and child_config.hide or false)

        local children = child_config.children or {}
        if not util_table.empty(children) then
            draw_panel_child(child, child_config, children, child_config_key, cursor_pos)
        end

        util_imgui.end_disabled()

        if out_node_positions then
            table.insert(out_node_positions, cursor_pos)
        end
        ::continue::
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
                    util_gui.tr_elem_name(child.hud_id, child.name_key),
                    string.format("%s_%s_tree", config_key, child.name_key)
                )
            )
        then
            draw_panel(child, child_config, child_config_key, tree_type.NONE)

            util_imgui.begin_disabled(child_config.hide ~= nil and child_config.hide or false)

            local children = child_config.children or {}
            if not util_table.empty(children) then
                util_imgui.separator_text(config.lang:tr("hud_element.entry.category_children"))
                draw_panel_child(child, child_config, children, child_config_key)
            end

            util_imgui.end_disabled()
        end
        ::continue::
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
function this.draw(elem, elem_config, config_key)
    if not elem.gui_ignore then
        elem_config, config_key = selector.draw(elem_config, config_key)
    end

    imgui.begin_child_window("hud_elements_child_window_element_panel", { -1, -1 }, false)

    if not elem.gui_ignore then
        draw_panel(elem, elem_config, config_key, tree_type.NONE, true)
    end

    util_imgui.begin_disabled(elem_config.hide ~= nil and elem_config.hide and not elem.hide_write)

    local children = elem_config.children or {}
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

    util_imgui.end_disabled()
    imgui.end_child_window()
end

return this
