local combo_multi = require("HudController.util.imgui.combo_multi")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local def_mod = require("HudController.data.option.mod")
local e = require("HudController.util.game.enum")
local generic = require("HudController.gui.elements.profile.panel.generic")
local hud = require("HudController.hud.init")
local main_panel = require("HudController.gui.elements.profile.panel.main.init")
local op = require("HudController.hud.manager.op.init")
local option = require("HudController.data.option.init")
local set = require("HudController.gui.set")
local sub_panel = require("HudController.gui.elements.profile.panel.sub.init")
local user_option = require("HudController.hud.user.option")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local ace_map = data.ace.map
local mod_enum = data.mod.enum

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

    if tree == tree_type.TREE and imgui.tree_node_str_id(id, label) or tree == tree_type.NONE then
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
    elseif tree == tree_type.FAKE then
        util_imgui.fake_tree_node(id, label, function()
            if indent then
                imgui.indent(indent)
            end

            draw_panel_contents(elem, elem_config, config_key)

            if indent then
                imgui.unindent(indent)
            end
        end)
    end

    util_imgui.end_disabled()
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param children_filtered table<string, HudChildConfig>
---@param config_key string
---@param node_pos Vector2f?
local function draw_panel_child(elem, elem_config, children_filtered, config_key, node_pos)
    local elems = util_table.groupby(children_filtered, function(_, name_key, value)
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
    local indent = config.lang.font_size * (20 / 16)
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
                    ) and op.hud_elem.is_current_profile(elem)
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
        local offset_x = config.lang.font_size * (8 / 16)
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
    local indent = config.lang.font_size * (20 / 16)

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

        util_imgui.begin_disabled(child_config.hide ~= nil and child_config.hide)

        local children = util_table.filter_inplace(
            child_config.children or {},
            function(t, index, _)
                return not t[index].ignore
            end
        )

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

            util_imgui.begin_disabled(child_config.hide ~= nil and child_config.hide)

            local children = util_table.filter_inplace(
                child_config.children or {},
                function(t, index, _)
                    return not t[index].ignore
                end
            )

            if not util_table.empty(children) then
                util_imgui.separator_text(config.lang:tr("hud_element.entry.category_children"))
                draw_panel_child(child, child_config, children, child_config_key)
            end

            util_imgui.end_disabled()
        end
        ::continue::
    end
end

---@param draw_list ImDrawList
---@param center Vector2f|number[]
---@param radius number
---@param filled boolean
---@param color integer
local function draw_star(draw_list, center, radius, filled, color)
    local inner_radius = radius * 0.45

    draw_list:path_clear()

    for i = 0, 9 do
        local r = i % 2 == 0 and radius or inner_radius
        local angle = -math.pi * 0.5 + i * math.pi / 5

        draw_list:path_line_to({
            center[1] + math.cos(angle) * r,
            center[2] + math.sin(angle) * r,
        })
    end

    if filled then
        draw_list:path_fill_concave(color)
    else
        draw_list:path_stroke(color, 1, 1)
    end
end

---@param elem_config HudBaseConfig
---@param config_key string
local function draw_profile_selector(elem_config, config_key)
    local root = elem_config

    local star_radius = config.lang.font_size * 0.35
    local active_radius = config.lang.font_size * 0.20
    local spacing = 6
    local row_height = config.lang.font_size + 6
    local icon_size = row_height
    local circle_radius = config.lang.font_size * 0.25

    local accent_color = 0xffd47b35
    local star_color = mod_enum.colors.info
    local text_color = 0xffffffff

    imgui.set_next_item_width(
        util_imgui.get_something_with_button_width(config.lang:tr("misc.text_ellipsis"))
    )
    if
        combo_multi.combo_custom_filter(
            "##elem_profile." .. config_key,
            elem_config.current_profile_gui,
            function(min, max, value)
                local width = max.x - min.x
                local height = max.y - min.y

                if width <= 0 or height <= 0 then
                    return
                end

                local draw_list = imgui.get_window_draw_list()
                local is_active = root.current_profile == value
                local is_default = root.default_profile == value
                local name = op.hud_elem_profile.get_profile_name(value)

                draw_list:push_clip_rect(min, max, true)

                local cy = (min.y + max.y) * 0.5
                local text_y = min.y + (height - config.lang.font_size) * 0.5

                local left = min.x + 1
                local right = max.x - 1

                local star_col = star_color
                if util_imgui.is_disabled() then
                    star_col = util_misc.mul_alpha(star_col, 0.6)
                end

                -- active profile indicator
                if is_active then
                    local cx = left + active_radius

                    draw_list:add_quad_filled(
                        { cx, cy - active_radius },
                        { cx + active_radius, cy },
                        { cx, cy + active_radius },
                        { cx - active_radius, cy },
                        star_col
                    )

                    left = left + active_radius * 2 + spacing
                end

                local text_width = imgui.calc_text_size(name).x
                local min_name_width = math.min(text_width, config.lang.font_size * 2)
                local star_diameter = star_radius * 2
                local show_star = is_default
                    and right - left >= min_name_width + spacing + star_diameter

                local star_center_x = nil
                local text_right = right

                if show_star then
                    local natural_star_x = left + text_width + spacing + star_radius
                    local max_star_x = right - star_radius
                    star_center_x = math.min(natural_star_x, max_star_x)
                    text_right = star_center_x - star_radius - spacing
                end

                local text_col = text_color
                if util_imgui.is_disabled() then
                    text_col = util_misc.mul_alpha(text_col, 0.6)
                end

                if text_right > left then
                    draw_list:push_clip_rect({ left, min.y }, { text_right, max.y }, true)
                    draw_list:add_text({ left, text_y }, text_col, name)
                    draw_list:pop_clip_rect()
                end

                -- default profile indicator
                if show_star then
                    draw_star(draw_list, { star_center_x, cy }, star_radius, true, star_col)
                end

                draw_list:pop_clip_rect()
            end,
            function(query, value)
                imgui.indent(3)
                util_imgui.adjust_pos(0, 5)
                option.draw(def_mod.opt.hide_disabled_element_profiles)
                imgui.unindent(3)
                imgui.separator()

                imgui.push_style_var(11, Vector2f.new(0, 0))
                imgui.push_style_var(14, Vector2f.new(0, 0))

                local config_mod = config.current.mod
                local changed = false

                local filtered = util_table.filter_array(
                    config_mod.hud[config_mod.combo.hud].profile,
                    function(_, p)
                        local name = op.hud_elem_profile.get_profile_name(p.key)
                        return name:lower():find(query:lower(), 1, true) ~= nil
                    end
                )

                local draw_list = imgui.get_window_draw_list()
                for _, profile_for_show in ipairs(filtered) do
                    local key = profile_for_show.key
                    local profile = op.hud_elem_profile.get_elem_profile_no_create(root, key)

                    local is_enabled = profile and profile.enabled
                    if config_mod.hide_disabled_element_profiles and not is_enabled then
                        goto continue
                    end

                    local is_default = root.default_profile == key
                    local is_active = root.current_profile == key
                    local is_selected = value == key

                    local row_pos = imgui.get_cursor_screen_pos()
                    local window_pos = imgui.get_window_pos()
                    local window_size = imgui.get_window_size()
                    local window_padding_x = row_pos.x - window_pos.x
                    local row_right = window_pos.x + window_size.x - window_padding_x

                    -- enabled indicator
                    util_imgui.begin_disabled(profile_for_show.key == mod_enum.elem_profile.DEFAULT)
                    if imgui.invisible_button("##enabled_" .. key, { icon_size, icon_size }) then
                        profile = op.hud_elem_profile.get_elem_profile(root, key)
                        profile.enabled = not is_enabled
                        is_enabled = profile.enabled
                        changed = true

                        if key == root.default_profile then
                            root.default_profile = mod_enum.elem_profile.DEFAULT
                        end

                        if is_selected then
                            is_selected = false

                            root.current_profile_gui = root.default_profile
                        end

                        op.hud_elem_profile.apply_elem_profile(root)
                        hud.request_update()
                    end

                    local enabled_center = {
                        row_pos.x + icon_size * 0.5,
                        row_pos.y + row_height * 0.5,
                    }
                    local enabled_col = imgui.is_item_hovered() and 0xffe38a45 or accent_color

                    if util_imgui.is_disabled() then
                        enabled_col = util_misc.mul_alpha(enabled_col, 0.6)
                    end

                    if is_enabled then
                        draw_list:add_circle_filled(enabled_center, circle_radius, enabled_col, 12)
                    else
                        draw_list:add_circle(enabled_center, circle_radius, enabled_col, 12, 1)
                    end
                    util_imgui.end_disabled()

                    imgui.same_line()

                    -- default indicator
                    util_imgui.begin_disabled(not is_enabled)
                    if imgui.invisible_button("##default_" .. key, { icon_size, icon_size }) then
                        root.default_profile = key
                        is_default = true
                        changed = true

                        hud.request_update()
                    end

                    local default_center = {
                        row_pos.x + icon_size + icon_size * 0.5,
                        row_pos.y + row_height * 0.5,
                    }
                    local default_col = imgui.is_item_hovered() and 0xff45f7fa or star_color

                    if util_imgui.is_disabled() then
                        default_col = util_misc.mul_alpha(default_col, 0.6)
                    end

                    draw_star(draw_list, default_center, star_radius, is_default, default_col)
                    util_imgui.end_disabled()

                    imgui.same_line()

                    -- selector
                    local name_pos = imgui.get_cursor_screen_pos()
                    local name_width = row_right - name_pos.x
                    util_imgui.begin_disabled(not is_enabled)
                    if imgui.invisible_button("##profile_" .. key, { name_width, row_height }) then
                        root.current_profile_gui = key
                        is_selected = true
                        changed = true

                        op.hud_elem_profile.apply_elem_profile(root)
                    end

                    local name_max = Vector2f.new(row_right, name_pos.y + row_height)
                    if imgui.is_item_hovered() then
                        draw_list:add_rect_filled(
                            name_pos,
                            name_max,
                            is_selected and 0xff684328 or 0xff4f4e4d,
                            0,
                            0
                        )
                    elseif is_selected then
                        draw_list:add_rect_filled(name_pos, name_max, 0xff49301f, 0, 0)
                    end

                    if is_selected then
                        draw_list:add_rect_filled({
                            name_pos.x,
                            name_pos.y + 2,
                        }, {
                            name_pos.x + 2,
                            name_pos.y + row_height - 2,
                        }, accent_color, 1, 0)
                    end

                    -- active profile indicator
                    local text_x = name_pos.x + 7
                    if is_active then
                        local cx = text_x + active_radius
                        local cy = name_pos.y + row_height * 0.5

                        draw_list:add_quad_filled(
                            { cx, cy - active_radius },
                            { cx + active_radius, cy },
                            { cx, cy + active_radius },
                            { cx - active_radius, cy },
                            star_color
                        )

                        text_x = text_x + active_radius * 2 + 6
                    end

                    local text_col = text_color
                    if not is_enabled then
                        text_col = util_misc.mul_alpha(text_col, 0.6)
                    end

                    local text_y = name_pos.y + (row_height - config.lang.font_size) * 0.5
                    draw_list:add_text(
                        { text_x, text_y },
                        text_col,
                        profile_for_show.name == "__placeholder_default"
                                and config.lang:tr("hud_profile.text_default_profile")
                            or profile_for_show.name
                    )
                    util_imgui.end_disabled()
                    ::continue::
                end

                imgui.pop_style_var(2)
                return changed, root.current_profile_gui
            end
        )
    then
        config:save()
    end

    imgui.same_line()
    util_imgui.option_button("##elem_profile_settings." .. config_key, {
        {
            name = config.lang:tr("hud_profile.button_import"),
            tooltip = config.lang:tr("hud_profile.tooltip_button_import"),
            callback = function()
                root = op.hud_elem_profile.import_elem_profile(root)
                local profile = op.hud_elem_profile.get_elem_profile(root, root.current_profile_gui)

                if profile.enabled then
                    op.hud_elem_profile.apply_elem_profile(root)
                end
            end,
        },
        {
            name = config.lang:tr("hud_profile.button_export"),
            tooltip = config.lang:tr("hud_profile.tooltip_button_export"),
            callback = function()
                local profile = op.hud_elem_profile.get_elem_profile(root, root.current_profile_gui)
                imgui.set_clipboard(json.dump_string(profile))
            end,
        },
    })
    util_imgui.set_label("Element Profile", -1)

    imgui.separator()

    if root.current_profile_gui ~= mod_enum.elem_profile.DEFAULT then
        config_key = string.format("%s.profile.%s", config_key, root.current_profile_gui)
        elem_config = op.hud_elem_profile.get_elem_profile(root, root.current_profile_gui)
    end

    return elem_config, config_key
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
function this.draw(elem, elem_config, config_key)
    if not elem.gui_ignore then
        elem_config, config_key = draw_profile_selector(elem_config, config_key)
    end

    imgui.begin_child_window("hud_elements_child_window_element_panel", { -1, -1 }, false)

    if not elem.gui_ignore then
        draw_panel(elem, elem_config, config_key, tree_type.NONE, true)
    end

    util_imgui.begin_disabled(elem_config.hide ~= nil and elem_config.hide and not elem.hide_write)

    local children = util_table.filter_inplace(elem_config.children or {}, function(t, i, _)
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

    util_imgui.end_disabled()
    imgui.end_child_window()
end

return this
