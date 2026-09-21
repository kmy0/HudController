local ace_misc = require("HudController.util.ace.misc")
local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local element_def = require("HudController.data.option.element.init")
local hud = require("HudController.hud.init")
local mod = require("HudController.data.mod")
local option_gui = require("HudController.gui.option")
local set = require("HudController.gui.set")
local user_option = require("HudController.hud.user.option")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")
local util_opt = require("HudController.data.option.util")
local util_table = require("HudController.util.misc.table")

local ace_map = data.ace.map

local this = {}

---@param option_key string
---@param item_config_key string
---@param callback fun(option_key: string, value: integer)?
---@param label string?
---@param add_default boolean?
---@return boolean
function this.draw_option(option_key, item_config_key, callback, label, add_default)
    local option_data = ace_map.option[option_key]
    label = label or string.format("%s##%s", option_data.name_local, option_data.name)
    add_default = add_default == nil or add_default

    local values = {}
    for _, item in ipairs(option_data.items) do
        table.insert(values, item.name_local)
    end

    if
        option_data.type == e.get("app.Option.TYPE").CHOICE
        and util_table.empty(option_data.items)
    then
        values = { config.lang:tr("misc.text_off"), config.lang:tr("misc.text_on") }
    end

    local default_value = add_default and -1 or 0
    local default_format = add_default and config.lang:tr("hud.option_disable") or nil
    local changed = false

    if not util_table.empty(values) then
        if add_default then
            table.insert(values, 1, default_format)
        end

        changed = set:slider_list(
            label,
            item_config_key,
            default_value,
            #values - (add_default and 2 or 1),
            values
        )

        if changed and callback then
            callback(option_key, config:get(item_config_key))
        end
    elseif
        option_data.type == e.get("app.Option.TYPE").VALUE
        and option_data.min ~= option_data.max
    then
        if option_data.decimal_place == 0 then
            changed = set:slider_int_default(
                label,
                item_config_key,
                option_data.min,
                option_data.max,
                default_value,
                default_format
            )

            if changed and callback then
                callback(option_key, config:get(item_config_key))
            end
        else
            changed = set:slider_float_scaled(
                label,
                item_config_key,
                option_data.min,
                option_data.max,
                option_data.decimal_place,
                default_value,
                default_format
            )

            if changed and callback then
                callback(option_key, config:get(item_config_key))
            end
        end
    else
        imgui.text_colored(option_data.name_local, mod.enum.colors.bad)
    end

    return changed
end

---@param option_keys string[]
---@param config_key string
---@param callback fun(option_key: string, value: integer)
function this.draw_options(option_keys, config_key, callback)
    for i = 1, #option_keys do
        local key = option_keys[i]
        local option_data = ace_map.option[key]

        if not option_data then
            goto continue
        end

        this.draw_option(key, string.format("%s.%s", config_key, key), callback)
        ::continue::
    end
end

---@param elem Notice | NameOther | NameAccess | Subtitles
---@param item_config_key string
---@param label string
---@param entry_key string
---@param set_fn fun(self: any, key: string, value: integer?)
---@param is_current_profile boolean
---@param combo_key string?
---@param button_label_path string?
function this.combo_hide(
    elem,
    item_config_key,
    label,
    entry_key,
    set_fn,
    is_current_profile,
    combo_key,
    button_label_path
)
    local combo = cd.get_profile_combo(
        combo_key or entry_key,
        item_config_key,
        function(item_config_key, key, _)
            return config:get(item_config_key)[key]
        end
    )
    local combo_index_key = string.format("__temp.%s_combo", item_config_key)
    button_label_path = button_label_path or "hud_element.entry.button_hide"
    imgui.set_next_item_width(
        util_imgui.get_something_with_button_width(config.lang:tr(button_label_path))
    )
    util_imgui.begin_disabled(combo:empty())
    option_gui.draw_combo(nil, item_config_key, "##" .. item_config_key, combo)

    imgui.same_line()
    if imgui.button(util_gui.tr(button_label_path, item_config_key)) then
        local index = config:get(combo_index_key) or 1
        local key = combo:get_key(index)
        local order = 0

        for _, o in
            pairs(config:get(item_config_key) --[[@as table<string, integer>]])
        do
            order = math.max(order, o + 1) --[[@as integer]]
        end

        if is_current_profile then
            set_fn(elem, key, order)
        end

        config:set(string.format("%s.%s", item_config_key, key), order)
        config:set(combo_index_key, combo:disable_item(key))
    end

    util_imgui.end_disabled()
    util_imgui.set_label(label, -1)

    this.child_window_thing_remove("entries" .. item_config_key, #combo.disabled, function()
        if imgui.button(util_gui.tr("hud_element.entry.button_remove_all", item_config_key)) then
            if is_current_profile then
                ---@diagnostic disable-next-line: no-unknown
                elem[entry_key] = {}
            end

            combo:enable_all_items()
            config:set(item_config_key, {})
            config:set(combo_index_key, 1)
        end

        local keys = util_table.sort(
            util_table.entries(config:get(item_config_key) --[[@as table<string, integer>]]),
            function(a, b)
                return a.value < b.value
            end
        )

        for i, map in ipairs(keys) do
            local value = combo:find_disabled(map.key)

            if
                util_imgui.draw_remove_button(
                    string.format("##%s|%s|%s", item_config_key, i, map.key)
                )
            then
                if is_current_profile then
                    set_fn(elem, map.key, nil)
                end

                config:set(string.format("%s.%s", item_config_key, map.key), nil)
                config:set(combo_index_key, combo:enable_item(map.key))
            end

            imgui.same_line()
            imgui.text(util_misc.split_string(value, "##")[1])
        end
    end)
end

---@param id string
---@param col_count integer
---@param draw_fn fun()
function this.table_thing(id, col_count, draw_fn)
    if
        imgui.begin_table(
            id,
            col_count,
            imgui.TableFlags.BordersH
                | imgui.TableFlags.BordersOuterV
                | imgui.TableFlags.SizingFixedFit
                | imgui.TableFlags.ScrollY --[[@as ImGuiTableFlags]],
            Vector2f.new(0, 4 * (config.lang.font_size * (46 / 16)))
        )
    then
        draw_fn()
        imgui.end_table()
    end
end

---@param id string
---@param size integer
---@param draw_fn fun()
function this.child_window_thing_remove(id, size, draw_fn)
    if size > 0 then
        size = size + 1
        local item_height = (config.lang.font_size + 6) * size + 4 * math.max(size - 1, 0)
        local height = math.min(item_height, 4 * (config.lang.font_size * (46 / 16)))

        if imgui.begin_child_window(id, { imgui.calc_item_width(), height }, false) then
            draw_fn()
        end

        imgui.end_child_window()
    end
end

---@param user_options table<string, RegisteredUserOption>
---@param config_key string
function this.draw_user_options(user_options, config_key)
    local groups = user_option.get_sorted_options(user_options)

    for i, group in ipairs(groups) do
        for _, opt in ipairs(group) do
            local item_config_key = string.format("%s.%s", config_key, opt.name)
            opt:draw(opt.label, item_config_key)
        end

        if i ~= #groups then
            imgui.separator()
        end
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
function this.draw(elem, elem_config, config_key)
    local opt = element_def.opt
    local ctx = { elem = elem, elem_config = elem_config, config_key = config_key }

    util_imgui.begin_disabled(ace_misc.is_item_slider_open())
    util_opt.draw_apply_elem(opt.hide, ctx)
    util_imgui.end_disabled()

    util_imgui.begin_disabled(
        util_opt.is_elem_available(opt.hide, elem_config)
            and util_opt.get_elem_config_value(opt.hide, elem_config)
            and not elem.hide_write
    )

    util_opt.draw_apply_elem(opt.scale, ctx)
    util_opt.draw_apply_elem(opt.offset, ctx)
    util_opt.draw_apply_elem(opt.rot, ctx)
    util_opt.draw_apply_elem(opt.opacity, ctx)
    util_opt.draw_apply_elem(opt.segment, ctx)

    if elem.hud_id then
        util_imgui.separator_text(config.lang:tr("hud_element.entry.category_profile_fade"))

        local current_hud = hud.get_current()
        ---@cast current_hud ModProfileConfig

        util_imgui.begin_disabled(not config.current.mod.enable_fade)
        util_imgui.begin_disabled(not current_hud.fade_opacity)

        util_opt.draw_apply_elem(opt.disable_fade_opacity, ctx)
        util_imgui.tooltip(config.lang:tr("hud_element.entry.tooltip_disable_fade_opacity"), true)

        util_imgui.end_disabled()
        util_opt.draw_apply_elem(opt.override_fade, ctx)
        util_imgui.end_disabled()
    end

    util_imgui.end_disabled()
end

return this
