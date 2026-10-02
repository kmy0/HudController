local cd = require("HudController.data.combo")
local color = require("HudController.util.imgui.color")
local combo_multi = require("HudController.util.imgui.combo.combo_multi")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local op = require("HudController.hud.manager.op.init")
local option = require("HudController.data.option.init")
local set = require("HudController.gui.set")
local user = require("HudController.hud.user.init")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")
local util_table = require("HudController.util.misc.table")

local mod_def = option.mod
local mod = data.mod
local ace_map = data.ace.map
local user_options_popup = {
    active = false,
    opts = {},
}

local this = {}

---@param user_manager UserManager
local function draw_user_sub_menu(user_manager)
    imgui.push_style_var(14, Vector2f.new(0, 2))

    local config_user = user_manager:get_config()
    local sorted = util_table.sort(util_table.keys(config_user))

    if util_table.empty(sorted) then
        imgui.text(config.lang:tr("menu.user.text_no_scripts"))
    end

    for i = 1, #sorted do
        local name = sorted[i]
        local pop_color = false

        if user_manager.failed[name] ~= nil then
            imgui.push_style_color(0, mod.enum.colors.bad)
            pop_color = true
        elseif config_user[name] ~= (user_manager.loaded[name] ~= nil) then
            imgui.push_style_color(0, mod.enum.colors.info)
            pop_color = true
        end

        if util_imgui.menu_item(name, config_user[name]) then
            config_user[name] = not config_user[name]
            config:save()
        end

        if pop_color then
            imgui.pop_style_color(1)
        end

        if user_manager.failed[name] ~= nil then
            util_imgui.tooltip(user_manager.failed[name])
        elseif config_user[name] ~= (user_manager.loaded[name] ~= nil) then
            util_imgui.tooltip(config.lang:tr("misc.text_reset_required"))
        end
    end

    imgui.pop_style_var(1)
end

local function draw_options_menu()
    imgui.spacing()
    imgui.indent(2)

    local config_mod = config.current.mod
    ---@type table<string, string>
    local all_opts = {}
    for k in pairs(config_mod.game_options.hud) do
        all_opts[k] = "GLOBAL"
    end

    for elem, opts in pairs(config_mod.game_options.elements) do
        for k in pairs(opts) do
            all_opts[k] = elem
        end
    end

    local width = util_imgui.get_available_width() / 2 - 6
    width = math.max(width, imgui.calc_item_width() * 1.5 / 2 - 6)
    imgui.set_next_item_width(width)
    set:combo_filter("##user_options_combo", "mod.combo.game_option", cd.combo.elem_option)
    imgui.same_line()

    local id = "##game_options_combo"
    if not imgui.is_popup_open("##" .. id .. "_custom_filter_popup") then
        user_options_popup.active = false
    end

    imgui.set_next_item_width(width)
    combo_multi.combo_custom_filter(id, nil, function(min, max, _)
        local width = max.x - min.x
        local height = max.y - min.y

        if width <= 0 or height <= 0 then
            return
        end

        local left = min.x + 1
        local right = max.x - 1
        local text_y = min.y + (height - config.lang.font_size) * 0.5

        local draw_list = imgui.get_window_draw_list()
        local text_col = color.with_alpha(0xffffffff)

        draw_list:push_clip_rect({ left, min.y }, { right, max.y }, true)
        draw_list:add_text(
            { left, text_y },
            text_col,
            config.lang:tr("menu.user.options.combo_game_options")
        )

        draw_list:pop_clip_rect()
    end, function(query, _)
        ace_map.tree_game_options:filter(query)

        if not user_options_popup.active then
            user_options_popup.active = true
            user_options_popup.opts = util_table.deep_copy(all_opts)
        end

        ---@param node TreeNode<AceOptionNode, nil>
        local function draw_node(node)
            if not util_table.empty(node.children) then
                imgui.indent(2)
                util_menubar.draw_menu(node.value.name, function()
                    for _, branch in ipairs(node.children) do
                        draw_node(branch)
                    end
                end)
                imgui.unindent(2)
            else
                imgui.begin_group()
                if
                    util_imgui.menu_item(
                        node.value.name,
                        all_opts[node.value.id_str] ~= nil,
                        user_options_popup.opts[node.value.id_str] ~= nil
                    )
                then
                    if all_opts[node.value.id_str] then
                        op.hud_game_options.remove_game_option_elem(
                            cd.combo.elem_option:get_key(config_mod.combo.game_option),
                            node.value.id_str
                        )
                        config:save()
                    else
                        op.hud_game_options.add_game_option_elem(
                            cd.combo.elem_option:get_key(config_mod.combo.game_option),
                            node.value.id_str
                        )
                        config:save()
                    end
                end
                imgui.end_group()

                local bound_elem = all_opts[node.value.id_str]
                if bound_elem then
                    util_imgui.tooltip(
                        string.format(
                            config.lang:tr("menu.user.options.tooltip_bound"),
                            cd.combo.elem_option:get_value_by_key(bound_elem)
                        )
                    )
                end
            end
        end

        for _, root in ipairs(ace_map.tree_game_options.nodes) do
            draw_node(root)
        end

        return false, nil
    end, false)

    option.draw(mod_def.opt.game_options_display_full_path)

    for _, elem in ipairs(cd.combo.elem_option.map) do
        local opts = elem.key == "GLOBAL" and config_mod.game_options.hud
            or config_mod.game_options.elements[elem.key]

        if opts and not util_table.empty(opts) then
            util_imgui.separator_text(elem.value)

            local keys = util_table.keys(opts)
            table.sort(keys)

            for _, key in ipairs(keys) do
                local opt = ace_map.option[key]
                if not opt then
                    goto continue
                end

                if util_imgui.draw_remove_button("##" .. opt.name) then
                    opts[key] = nil
                    op.hud_game_options.remove_game_option_elem(elem.key, opt.name)
                    config:save()
                end

                imgui.same_line()
                imgui.text(
                    config_mod.game_options.display_full_path and table.concat(opt.name_path, " > ")
                        or opt.name_local
                )
                ::continue::
            end
        end
    end

    imgui.unindent(2)
    imgui.spacing()
end

local function draw_user_menu()
    imgui.spacing()
    imgui.indent(2)

    util_menubar.draw_menu(util_gui.tr("menu.user.scripts.name"), function()
        draw_user_sub_menu(user.script)
    end, nil, user.script:is_need_attention() and mod.enum.colors.info or nil)
    util_imgui.tooltip(string.format(".../reframework/data/%s/user_scripts", config.name))

    util_menubar.draw_menu(util_gui.tr("menu.user.conditions.name"), function()
        draw_user_sub_menu(user.condition)
    end, nil, user.condition:is_need_attention() and mod.enum.colors.info or nil)
    util_imgui.tooltip(string.format(".../reframework/data/%s/user_conditions", config.name))

    util_menubar.draw_menu(util_gui.tr("menu.user.options.name"), function()
        draw_options_menu()
    end)

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    util_menubar.draw_menu(
        util_gui.tr("menu.user.name"),
        draw_user_menu,
        nil,
        (user.script:is_need_attention() or user.condition:is_need_attention())
                and mod.enum.colors.info
            or nil
    )
end

return this
