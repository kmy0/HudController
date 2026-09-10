local config = require("HudController.config.init")
local data = require("HudController.data.init")
local hud = require("HudController.hud.init")
local sorter = require("HudController.gui.elements.sorter")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_mod = require("HudController.util.mod.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod
local set = state.set

local this = {}
local reverse_sort = false

local function draw_hud()
    local config_mod = config.current.mod

    imgui.table_next_row()
    imgui.table_set_column_index(0)

    imgui.begin_group()
    util_imgui.begin_disabled(config_mod.enable_condition_binds)
    imgui.push_item_width(util_gui.get_item_size())
    if set:combo_filter(util_gui.tr("hud.combo"), "mod.combo.hud", state.combo.hud) then
        state.input = nil
        hud.request_hud_with_default(config_mod.hud[config_mod.combo.hud])
    end
    imgui.pop_item_width()

    imgui.table_set_column_index(1)

    if imgui.button(util_gui.tr("hud.button_new")) then
        state.input = nil
        hud.operations.new()
        config_mod.combo.hud = #config_mod.hud
        hud.request_hud_with_default(config_mod.hud[config_mod.combo.hud])
        config:save()
    end

    imgui.same_line()

    util_imgui.begin_disabled(state.input ~= nil or util_table.empty(config_mod.hud))
    if imgui.button(util_gui.tr("hud.button_rename")) then
        state.input = { buf = config_mod.hud[config_mod.combo.hud].name, type = "rename_hud" }
    end
    util_imgui.end_disabled()

    imgui.same_line()
    util_imgui.option_button("hud_choice", {
        {
            name = util_gui.tr("hud.button_remove"),
            callback = function()
                util_imgui.open_popup("hud_remove", 62, 30)
                state.input = nil
            end,
            disabled = util_table.empty(config_mod.hud),
        },
        {
            name = util_gui.tr("hud.button_export"),
            callback = function()
                hud.operations.export(config_mod.hud[config_mod.combo.hud])
            end,
            tooltip = config.lang:tr("hud.button_export_tooltip"),
            disabled = util_table.empty(config_mod.hud),
        },
        {
            name = util_gui.tr("hud.button_import"),
            callback = function()
                hud.operations.import()
                config:save()
            end,
            tooltip = config.lang:tr("hud.button_import_tooltip"),
        },
        {
            name = util_gui.tr("hud.button_save"),
            callback = function()
                config:backup()
                config:save_no_timer()
            end,
            tooltip = config.lang:tr("hud.tooltip_save"),
        },
        {
            name = util_gui.tr("hud.button_sort"),
            callback = function()
                state.input = nil
                sorter.is_opened = true
                mod.pause = true
            end,
            disabled = util_table.empty(config_mod.hud),
        },
    })

    util_imgui.end_disabled()
    imgui.end_group()
    if config_mod.enable_condition_binds then
        util_imgui.tooltip(config.lang:tr("hud.tooltip_choice_disabled"))
    end

    if
        util_imgui.popup_yesno(
            "hud_remove",
            config.lang:tr("misc.text_rusure"),
            config.lang:tr("misc.text_yes"),
            config.lang:tr("misc.text_no")
        )
    then
        hud.operations.remove(config_mod.hud[config_mod.combo.hud])
        if not util_table.empty(config_mod.hud) then
            hud.request_hud_with_default(config_mod.hud[config_mod.combo.hud])
        end

        config:save()
    end

    if
        state.input
        and not mod.pause
        and not util_mod.is_draw_canvas()
        and state.input.type == "rename_hud"
    then
        imgui.table_next_row()
        imgui.table_set_column_index(0)
        imgui.push_item_width(util_gui.get_item_size())
        local changed, _ = state.get_input()
        imgui.pop_item_width()
        if changed then
            hud.operations.rename(config_mod.hud[config_mod.combo.hud], state.input.buf)
            state.input = nil
            config:save()
        end
    end
end

local function draw_element()
    local config_mod = config.current.mod

    imgui.table_next_row()
    imgui.table_set_column_index(0)

    imgui.push_item_width(util_gui.get_item_size())
    set:combo_filter(util_gui.tr("hud_element.combo"), "mod.combo.hud_elem", state.combo.hud_elem)
    imgui.pop_item_width()

    imgui.table_set_column_index(1)

    if imgui.button(util_gui.tr("hud_element.button_add")) then
        hud.operations.add_element(
            state.combo.hud_elem:get_key(config_mod.combo.hud_elem) --[[@as string]]
        )
        config:save()
    end

    imgui.same_line()
    util_imgui.begin_disabled(
        not config_mod.hud[config_mod.combo.hud]
            or util_table.empty(config_mod.hud[config_mod.combo.hud].elements or {})
    )

    if imgui.button(util_gui.tr("hud_element.button_sort")) then
        local elements = config_mod.hud[config_mod.combo.hud].elements or {}
        hud.operations.sort_elements(util_table.values(elements), reverse_sort)
        config:save()
        reverse_sort = not reverse_sort
    end
    util_imgui.tooltip(config.lang:tr("hud_element.button_sort_tooltip"))

    util_imgui.end_disabled()
end

function this.draw()
    local config_mod = config.current.mod

    if imgui.begin_table("choice_table", 2, imgui.TableFlags.SizingFixedFit) then
        util_imgui.begin_disabled(config_mod.canvas.draw)
        draw_hud()
        util_imgui.end_disabled()

        util_imgui.begin_disabled(util_table.empty(config_mod.hud))
        draw_element()
        util_imgui.end_disabled()
        imgui.end_table()
    end
end

return this
