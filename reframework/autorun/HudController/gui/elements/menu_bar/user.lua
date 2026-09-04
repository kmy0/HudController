local config = require("HudController.config.init")
local data = require("HudController.data.init")
local gui_util = require("HudController.gui.util")
local user = require("HudController.hud.user.init")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

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

local function draw_user_menu()
    imgui.spacing()
    imgui.indent(2)

    util_menubar.draw_menu(gui_util.tr("menu.user.scripts.name"), function()
        draw_user_sub_menu(user.script)
    end, nil, user.script:is_need_attention() and mod.enum.colors.info or nil)
    util_imgui.tooltip(string.format(".../reframework/data/%s/user_scripts", config.name))

    util_menubar.draw_menu(gui_util.tr("menu.user.conditions.name"), function()
        draw_user_sub_menu(user.condition)
    end, nil, user.condition:is_need_attention() and mod.enum.colors.info or nil)
    util_imgui.tooltip(string.format(".../reframework/data/%s/user_conditions", config.name))

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    util_menubar.draw_menu(
        gui_util.tr("menu.user.name"),
        draw_user_menu,
        nil,
        (user.script:is_need_attention() or user.condition:is_need_attention())
                and mod.enum.colors.info
            or nil
    )
end

return this
