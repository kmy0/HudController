local cd = require("HudController.data.combo")
local combo_multi = require("HudController.util.imgui.combo_multi")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local hud = require("HudController.hud.init")
local op = require("HudController.hud.manager.op.init")
local popup = require("HudController.util.imgui.popup")
local set = require("HudController.gui.set")
local sorter = require("HudController.gui.elements.sorter")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_mod = require("HudController.util.mod.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

local this = {}
local reverse_sort = false

local function draw_hud()
    local config_mod = config.current.mod

    imgui.table_next_row()
    imgui.table_set_column_index(0)

    imgui.begin_group()
    util_imgui.begin_disabled(config_mod.enable_condition_binds)
    imgui.set_next_item_width(-1)
    if set:combo_filter("##hud_combo", "mod.combo.hud", cd.combo.hud) then
        state.input = nil
        hud.request_hud_with_default(config_mod.hud[config_mod.combo.hud])
    end

    imgui.table_set_column_index(1)

    util_imgui.option_button("hud_choice", {
        {
            name = util_gui.tr("hud.button_new"),
            callback = function()
                state.input = nil
                op.hud_profile.new()
                config_mod.combo.hud = #config_mod.hud
                hud.request_hud_with_default(config_mod.hud[config_mod.combo.hud])
                config:save()
            end,
        },
        {
            name = util_gui.tr("hud.button_rename"),
            callback = function()
                state.input =
                    { buf = config_mod.hud[config_mod.combo.hud].name, type = "rename_hud" }
            end,
            disabled = state.input ~= nil or util_table.empty(config_mod.hud),
        },
        {
            name = util_gui.tr("hud.button_remove"),
            callback = function()
                state.input = nil
                popup.request({
                    id = "hud_emove",
                    callback = function()
                        op.hud_profile.remove(config_mod.hud[config_mod.combo.hud])
                        if not util_table.empty(config_mod.hud) then
                            hud.request_hud_with_default(config_mod.hud[config_mod.combo.hud])
                        end

                        config:save()
                    end,
                    fn = popup.popup_yesno,
                })
            end,
            disabled = util_table.empty(config_mod.hud),
        },
        {
            name = util_gui.tr("hud.button_export"),
            callback = function()
                op.hud_profile.export(config_mod.hud[config_mod.combo.hud])
            end,
            tooltip = config.lang:tr("hud.button_export_tooltip"),
            disabled = util_table.empty(config_mod.hud),
        },
        {
            name = util_gui.tr("hud.button_import"),
            callback = function()
                op.hud_profile.import()
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
        state.input
        and not mod.pause
        and not util_mod.is_draw_canvas()
        and state.input.type == "rename_hud"
    then
        imgui.table_next_row()
        imgui.table_set_column_index(0)
        imgui.set_next_item_width(-1)
        local changed, _ = state.get_input(false)

        imgui.table_set_column_index(1)
        if imgui.button(util_gui.tr("hud.button_cancel", "input")) then
            state.input = nil
        end

        if changed then
            op.hud_profile.rename(config_mod.hud[config_mod.combo.hud], state.input.buf)
            state.input = nil
            config:save()
        end
    end
end

local function draw_element()
    local config_mod = config.current.mod

    imgui.table_next_row()
    imgui.table_set_column_index(0)

    ---@type boolean[]
    local selected = {}
    local hud_profile = hud.get_current()
    if hud_profile then
        for _, name_key in ipairs(cd.combo.hud_elem:get_keys()) do
            table.insert(selected, hud_profile.elements[name_key] ~= nil)
        end
    end

    imgui.set_next_item_width(-1)
    local changed, new_selected = combo_multi.combo_multi_filter(
        "##elem_combo",
        util_table.deep_copy(selected),
        config.lang:tr("hud.text_add_elements"),
        cd.combo.hud_elem.values,
        true
    )

    if changed then
        for i, _ in ipairs(selected) do
            if new_selected[i] ~= selected[i] then
                local name_key = cd.combo.hud_elem:get_key(i)

                if new_selected[i] then
                    op.hud_elem.add_element(name_key)
                    config_mod.combo.selection = name_key
                else
                    op.hud_profile.remove_element(name_key)
                end
            end
        end

        config.save_global()
    end

    imgui.table_set_column_index(1)
    util_imgui.option_button("elem_choice", {
        {
            name = util_gui.tr("hud_element.button_sort"),
            callback = function()
                local elements = config_mod.hud[config_mod.combo.hud].elements or {}
                op.hud_elem.sort_elements(util_table.values(elements), reverse_sort)
                config:save()
                reverse_sort = not reverse_sort
            end,
            tooltip = config.lang:tr("hud_element.button_sort_tooltip"),
            disabled = not config_mod.hud[config_mod.combo.hud]
                or util_table.empty(config_mod.hud[config_mod.combo.hud].elements or {}),
        },
    })
end

function this.draw()
    local config_mod = config.current.mod

    if
        imgui.begin_table(
            "choice_table",
            2,
            imgui.TableFlags.SizingFixedFit --[[@as ImGuiTableFlags]]
        )
    then
        imgui.table_setup_column("##combo", imgui.ColumnFlags.WidthStretch)
        imgui.table_setup_column("##actions", imgui.ColumnFlags.WidthFixed)

        util_imgui.begin_disabled(config_mod.canvas.draw)
        draw_hud()
        util_imgui.end_disabled()

        util_imgui.begin_disabled(util_table.empty(config_mod.hud))
        draw_element()
        util_imgui.end_disabled()

        imgui.push_style_var(imgui.ImGuiStyleVar.ItemSpacing, Vector2f.new(0, 2))
        imgui.end_table()
        imgui.pop_style_var(1)
    end
end

return this
