local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local op = require("HudController.hud.manager.op.init")
local set = require("HudController.gui.set")
local user = require("HudController.hud.user.init")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")
local util_table = require("HudController.util.misc.table")

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

    imgui.set_next_item_width(
        util_imgui.get_something_with_button_width(util_gui.tr("menu.user.options.button_add"))
    )
    set:combo_filter("##user_options_combo", "mod.combo.user_option", cd.combo.elem_option)
    imgui.same_line()

    if not imgui.is_popup_open("##" .. util_gui.tr("menu.user.options.button_add") .. "_popup") then
        user_options_popup.active = false
    end

    util_imgui.button_with_popup(util_gui.tr("menu.user.options.button_add"), function()
        if not user_options_popup.active then
            user_options_popup.active = true
            user_options_popup.opts = util_table.deep_copy(all_opts)
        end

        ---@param option AceOption
        ---@param label string
        local function draw_option(option, label)
            imgui.begin_group()
            if
                util_imgui.menu_item(
                    label,
                    all_opts[option.name] ~= nil,
                    user_options_popup.opts[option.name] ~= nil
                )
            then
                if all_opts[option.name] then
                    op.hud_game_options.remove_game_option_elem(
                        cd.combo.elem_option:get_key(config_mod.combo.user_option),
                        option.name
                    )
                else
                    op.hud_game_options.add_game_option_elem(
                        cd.combo.elem_option:get_key(config_mod.combo.user_option),
                        option.name
                    )
                end
            end
            imgui.end_group()

            local bound_elem = all_opts[option.name]
            if bound_elem then
                util_imgui.tooltip(
                    string.format(
                        config.lang:tr("menu.user.options.tooltip_bound"),
                        cd.combo.elem_option:get_value_by_key(bound_elem)
                    )
                )
            end
        end

        ---@param node AceOptionNode
        local function draw_node(node)
            local option = node.option
            local has_children = not util_table.empty(node.children)
            local has_value = not util_table.empty(node.option.items)
                or option.type == e.get("app.Option.TYPE").CHOICE
                or option.type == e.get("app.Option.TYPE").VALUE

            if not has_children then
                if has_value then
                    draw_option(option, option.name_local)
                end

                return
            end

            util_menubar.draw_menu(option.name_local, function()
                if has_value then
                    draw_option(
                        option,
                        string.format(
                            "%s %s",
                            option.name_local,
                            config.lang:tr("menu.user.options.text_toggle")
                        )
                    )
                end

                for _, child in ipairs(node.children) do
                    draw_node(child)
                end
            end)
        end

        local categories = util_table.sort(util_table.keys(ace_map.game_options))
        for _, category in ipairs(categories) do
            util_menubar.draw_menu(category, function()
                for _, node in ipairs(ace_map.game_options[category]) do
                    draw_node(node)
                end
            end)
        end
    end)

    set:checkbox(
        util_gui.tr("menu.user.options.box_display_full_path"),
        "mod.game_options.display_full_path"
    )

    for _, elem in ipairs(cd.combo.elem_option.map) do
        local opts = elem.key == "GLOBAL" and config_mod.game_options.hud
            or config_mod.game_options.elements[elem.key]

        if opts then
            util_imgui.separator_text(elem.value)

            local keys = util_table.keys(opts)
            table.sort(keys)

            for _, key in ipairs(keys) do
                local opt = ace_map.option[key]
                if not opt then
                    goto continue
                end

                if imgui.button(util_gui.tr("menu.user.options.button_remove", opt.name)) then
                    opts[key] = nil
                    op.hud_game_options.remove_game_option_elem(elem.key, opt.name)
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
    util_imgui.tooltip(config.lang:tr("menu.user.tooltip_options"))

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
