local config = require("HudController.config.init")
local data = require("HudController.data.init")
local drag_util = require("HudController.gui.drag")
local generic = require("HudController.gui.elements.profile.panel.generic")
local hook = require("HudController.hud.hook.init")
local hud = require("HudController.hud.init")
local op = require("HudController.hud.manager.op.init")
local option = require("HudController.data.option.init")
local panel = require("HudController.gui.elements.profile.panel.init")
local state = require("HudController.gui.state")
local timer = require("HudController.util.misc.timer")
local user_option = require("HudController.hud.user.option")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_table = require("HudController.util.misc.table")

local hud_def = option.hud
local mod_enum = data.mod.enum
local ace_map = data.ace.map

local this = {}
local drag = drag_util:new()
local drag_profile = drag_util:new()
local reverse_sort = false

---@param changed boolean
---@param opt OptionDef
---@return boolean
local function check_overriden(changed, key, opt)
    if changed then
        hud.clear_overridden(key)
    end

    local val = hud.get_overridden(key)
    if val ~= nil then
        imgui.same_line()
        imgui.text(
            string.format("(%s %s)", config.lang:tr("misc.text_overridden"), opt:format(val))
        )
    end

    return changed
end

---@param id string
---@param name string
---@param draw fun()
---@return fun()?
local function draw_entry(id, name, draw)
    local selected = config.current.mod.combo.selection == id

    if util_imgui.draw_sel_button(name, selected, { -1, 0 }) then
        config.current.mod.combo.selection = id
        selected = true
    end

    if selected then
        return draw
    end
end

---@param key string
local function draw_option(key)
    local opt = hud_def.opt[key] --[[@as OptionDef]]
    check_overriden(option.draw(opt, nil, config.current.mod.combo.hud), key, opt)
end

local function draw_options()
    imgui.begin_child_window("hud_elements_child_window_options", { -1, -1 }, false)

    local config_mod = config.current.mod

    util_imgui.separator_text(config.lang:tr("hud.category_general"))
    draw_option("mute_gui")
    draw_option("disable_area_intro")

    util_imgui.separator_text(config.lang:tr("hud.category_player"))
    draw_option("hide_danger")
    util_imgui.tooltip(config.lang:tr("hud.tooltip_hide_danger"), true)
    draw_option("hide_aggro")
    draw_option("disable_scoutflies")
    draw_option("hide_weapon")
    util_imgui.tooltip(config.lang:tr("hud.tooltip_hide_weapon"), true)

    util_imgui.separator_text(config.lang:tr("hud.category_npc"))
    draw_option("hide_handler")
    imgui.same_line()
    imgui.set_next_item_width(util_imgui.get_drag_with())
    draw_option("hide_handler_timeout")
    draw_option("hide_pet")
    util_imgui.tooltip(config.lang:tr("hud.tooltip_hide_pet"), true)
    draw_option("hide_npc")

    util_imgui.separator_text(config.lang:tr("hud.category_monster"))
    draw_option("monster_wound")
    draw_option("monster_icon")
    util_imgui.tooltip(config.lang:tr("hud.tooltip_hide_monster_icon"), true)

    draw_option("hide_small_monsters")
    draw_option("monster_ignore_camp")
    util_imgui.tooltip(config.lang:tr("hud.tooltip_monster_ignore_camp"), true)

    util_imgui.separator_text(config.lang:tr("hud.category_quest"))
    draw_option("disable_quest_intro")
    draw_option("disable_quest_end_camera")
    draw_option("disable_quest_end_outro")
    draw_option("skip_quest_result")
    util_imgui.tooltip(config.lang:tr("hud.tooltip_skip_quest_result"), true)

    util_imgui.separator_text(config.lang:tr("hud.category_porter"))
    draw_option("disable_porter_call")
    draw_option("hide_porter")
    imgui.same_line()
    imgui.set_next_item_width(util_imgui.get_drag_with())
    draw_option("hide_porter_timeout")
    draw_option("disable_porter_tracking")

    util_imgui.separator_text(config.lang:tr("hud.category_profile"))
    draw_option("show_notification")
    util_imgui.tooltip(config.lang:tr("hud.tooltip_show_notification"), true)

    util_imgui.separator_text(config.lang:tr("hud.category_fade"))
    util_imgui.tooltip(config.lang:tr("hud.tooltip_category_fade"))
    draw_option("fade_opacity")
    util_imgui.tooltip(config.lang:tr("hud.tooltip_fade_opacity"), true)
    draw_option("fade_in")
    draw_option("fade_out")

    if not util_table.empty(config_mod.hud[config_mod.combo.hud].options) then
        util_imgui.separator_text(config.lang:tr("hud_element.entry.category_ingame_settings"))

        local sorted =
            util_table.sort(util_table.keys(config_mod.hud[config_mod.combo.hud].options))
        generic.draw_options(
            sorted,
            hud_def.make_config_key_from_key("options", config_mod.combo.hud),
            function(option_key, value)
                hud.apply_option(option_key, value)
            end
        )
    end

    if not util_table.empty(user_option.hud) then
        util_imgui.separator_text(config.lang:tr("hud.category_user_options"))
        generic.draw_user_options(
            user_option.hud,
            hud_def.make_config_key_from_key("user_options", config_mod.combo.hud)
        )
    end

    hook.hook_options(config_mod.hud[config_mod.combo.hud])

    imgui.end_child_window()
end

local function make_content_draw_fn(elem_config, config_key)
    local elem = hud.get_element(elem_config.hud_id)
    return function()
        if elem then
            panel.draw(elem, elem_config, config_key)
        end
    end
end

---@return string?, fun()?
local function draw_elements()
    imgui.begin_child_window("hud_elements_child_window_elements", { -1, -1 }, false)

    ---@type string?, fun()?, string?, string?
    local sel_name, sel_draw, sel_name_key
    local config_mod = config.current.mod
    local elements = config_mod.hud[config_mod.combo.hud].elements or {}
    local sorted = util_table.sort(util_table.values(elements), function(a, b)
        return a.key > b.key
    end)
    local config_key_format = "mod.hud.int:%s.elements.%s"

    util_imgui.spacer(0, 1)

    ---@type string[]
    local remove = {}
    drag:clear()
    for i = 1, #sorted do
        local elem_config = sorted[i]
        local config_key = config_key_format:format(config_mod.combo.hud, elem_config.name_key)

        drag:draw_drag_button(config_key, elem_config)
        imgui.same_line()

        if
            util_imgui.draw_remove_button("##" .. elem_config.name_key, config.lang.font_size + 6)
        then
            table.insert(remove, elem_config.name_key)
        end

        imgui.same_line()

        local name = ace_map.hudid_name_to_local_name[elem_config.name_key]
        local display_name = name
        if config_mod.display_active_element_profile_name then
            display_name = string.format(
                "%s (%s)",
                name,
                op.hud_elem_profile.get_profile_name(elem_config.current_profile)
            )
        end

        local draw = draw_entry(
            elem_config.name_key,
            string.format("%s##%s_header", display_name, elem_config.name_key),
            make_content_draw_fn(elem_config, config_key)
        )
        if draw then
            sel_draw = draw
            sel_name = name
            sel_name_key = elem_config.name_key
        end

        drag:check_drag_pos(elem_config)
    end

    imgui.spacing()

    if drag:is_released() then
        config.save_global()
    elseif drag:is_drag() then
        for i, elem in
            pairs(util_table.sort(util_table.values(elements), function(a, b)
                return drag.item_pos[a] > drag.item_pos[b]
            end))
        do
            elem.key = i
        end
    end

    if not util_table.empty(remove) then
        for _, name_key in pairs(remove) do
            if name_key == sel_name_key then
                if #sorted > 1 then
                    local index = util_table.index(sorted, function(o)
                        return o.name_key == name_key
                    end) --[[@as integer]]
                    index = index == 1 and math.min(index + 1, #sorted) or math.max(index - 1, 1)

                    local elem_config = sorted[index]
                    local config_key =
                        config_key_format:format(config_mod.combo.hud, elem_config.name_key)
                    sel_draw = make_content_draw_fn(elem_config, config_key)
                    sel_name = ace_map.hudid_name_to_local_name[elem_config.name_key]
                    config_mod.combo.selection = elem_config.name_key
                else
                    sel_draw = nil
                    sel_name = nil
                    sel_name_key = nil
                end
            end

            op.hud_profile.remove_element(name_key)
        end

        config.save_global()
    end

    imgui.end_child_window()
    return sel_name, sel_draw
end

---@return string?, fun()?
local function draw_profiles()
    local config_mod = config.current.mod
    local profiles = config_mod.hud[config_mod.combo.hud].profile

    util_imgui.begin_disabled(#profiles >= config.max_profile)
    if util_imgui.draw_add_button("new_elem_profile") then
        state.input = nil
        op.hud_elem_profile.new_elem_profile_for_show(profiles)
    end
    util_imgui.end_disabled()

    imgui.same_line()
    if util_imgui.draw_sort_button("sort_elem_profile") then
        state.input = nil
        table.sort(profiles, function(a, b)
            if a.protected then
                return true
            elseif b.protected then
                return false
            end

            if reverse_sort then
                return a.name > b.name
            end

            return a.name < b.name
        end)

        reverse_sort = not reverse_sort
        hud.request_update()
    end
    util_imgui.tooltip(config.lang:tr("hud_profile.tooltip_button_sort"))

    imgui.same_line()
    imgui.text_colored(
        string.format("%s/%s", #profiles - 1, config.max_profile),
        mod_enum.colors.info
    )

    imgui.separator()

    drag_profile:clear()
    imgui.begin_child_window("hud_elements_child_window_profiles", { -1, -1 }, false)
    ---@type integer?
    local to_remove
    for i, profile in ipairs(profiles) do
        util_imgui.begin_disabled(profile.protected)
        drag_profile:draw_drag_button(tostring(profile.key), profile.key)
        imgui.same_line()

        if util_imgui.draw_remove_button(string.format("##%s", profile.key)) then
            to_remove = i
            op.hud_elem_profile.remove_elem_profile(
                config_mod.hud[config_mod.combo.hud],
                profile.key
            )
        end

        imgui.same_line()
        util_imgui.begin_disabled(state.input ~= nil)
        if util_imgui.draw_rename_button("##rename_elem_profile|" .. profile.key) then
            state.input = {
                buf = profile.name,
                type = "rename_hud_profile",
                key = profile.key,
            }
        end
        util_imgui.end_disabled()

        imgui.same_line()
        util_imgui.header(
            profile.name == "__placeholder_default"
                    and config.lang:tr("hud_profile.text_default_profile")
                or profile.name,
            nil,
            profile.protected
        )
        drag_profile:check_drag_pos(profile.key)
        util_imgui.end_disabled()

        if
            state.input
            and state.input.key == profile.key
            and state.input.type == "rename_hud_profile"
        then
            local changed, _ = state.get_input()
            if changed then
                op.hud_elem_profile.rename_elem_profile_for_show(profiles, profile, state.input.buf)
                state.input = nil

                config:save()
            end
        end
    end

    if drag_profile:is_drag() then
        state.input = nil
    end

    if to_remove then
        table.remove(profiles, to_remove)
        config:save()
    end

    if not drag_profile:is_released() and drag_profile:is_drag() then
        table.sort(profiles, function(a, b)
            if a.protected then
                return true
            elseif b.protected then
                return false
            end
            return drag_profile.item_pos[a.key] < drag_profile.item_pos[b.key]
        end)

        config:save()
        timer.request_one_timer("on_elem_profile_sort", 2, hud.request_update, "frame")
    end

    imgui.end_child_window()
end

---@return string?, fun()?
function this.draw()
    if util_table.empty(config.current.mod.hud) then
        return
    end

    ---@type string?, fun()?
    local sel_name, sel_draw
    local draw = draw_entry("HUD_OPTIONS", util_gui.tr("hud.header_hud_options"), draw_options)
    if draw then
        sel_name = config.lang:tr("hud.header_hud_options")
        sel_draw = draw
    end

    draw = draw_entry("HUD_PROFILES", util_gui.tr("hud_profile.header_hud_profile"), draw_profiles)
    if draw then
        sel_name = config.lang:tr("hud_profile.header_hud_profile")
        sel_draw = draw
    end

    imgui.separator()
    local name, draw = draw_elements()
    if draw then
        sel_name = name
        sel_draw = draw
    end

    return sel_name, sel_draw
end

return this
