---@class ElementOptionDef<E, C, T>
---@field key string
---@field lang_key string
---@field bindable boolean
---@field draw fun(_: ElementOptionDef<E, C, T>, label: string?, config_key: string): boolean
---@field format fun(_: ElementOptionDef<E, C, T>, value: T): string
---@field apply fun(_: ElementOptionDef<E, C, T>, ctx: ElementOptionContext<E, C>, value: T)
---@field is_available? fun(_: ElementOptionDef<E, C, T>, elem_config: C): boolean
---@field get_config_value? fun(_: ElementOptionDef<E, C, T>, elem_config: C): T

---@class (exact) ElementOptionContext<E, C>
---@field elem E
---@field elem_config C
---@field config_key string

---@class (exact) OptionCtxPath
---@field hud_id app.GUIHudDef.TYPE
---@field path string

---@class NamedElementOptionDef<E, C, T> : ElementOptionDef<E, C, T>
---@field name string
---@field path string
---@field name_path string[]
---@field default_value T
---@field ctx_path OptionCtxPath

---@class ElementOptNode
---@field name_key string
---@field name string
---@field path string
---@field opt table<string, NamedElementOptionDef>
---@field children table<string, ElementOptNode>
---@field config_key string
---@field hud_id app.GUIHudDef.TYPE
---@field hud_sub_type HudSubType
---@field hud_type HudType

---@class BindElemOptNode : ElementOptNode
---@field opt NamedElementOptionDef[]
---@field children BindElemOptNode[]

---@class ElementBooleanDef : ElementOptionDef<HudBase, HudBaseConfig, boolean>
---@class ElementVec2Def : ElementOptionDef<HudBase, HudBaseConfig, EnabledVec2>
---@class ElementNumberDef : ElementOptionDef<HudBase, HudBaseConfig, EnabledNumber>
---@class ElementStringDef : ElementOptionDef<HudBase, HudBaseConfig, EnabledString>
---@class ElementFadeDef : ElementOptionDef<HudBase, HudBaseConfig, EnabledFadeOverride>

local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local e = require("HudController.util.game.enum")
local option_gui = require("HudController.gui.option")
local set = require("HudController.gui.set")
local tree = require("HudController.util.imgui.tree")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")
local util_opt = require("HudController.data.option.util")
local util_table = require("HudController.util.misc.table")

---@module "HudController.hud.factory"
local factory = util_misc.lazy_require("HudController.hud.factory")

---@class ElementOptionDefinitions
local this = {
    main = require("HudController.data.option.element.main"),
    sub = require("HudController.data.option.element.sub"),
    ---@type table<string, ElementOptNode>
    map = {},
    ---@type Tree<BindElemOptNode, NamedElementOptionDef>
    tree = {},
    opt = {
        ---@type ElementBooleanDef
        hide = {
            key = "hide",
            lang_key = "hud_element.entry.box_hide",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_hide(value)
            end,
        },
        ---@type ElementVec2Def
        scale = {
            key = "scale",
            lang_key = "hud_element.entry.box_enable_scale",
            bindable = true,
            apply = function(_, ctx, value)
                ctx.elem:set_scale(value)
            end,
            format = util_opt.format_enabled_vec2("%.2f"),
            draw = util_opt.enabled_vec2_slider(0.01, -10.0, 10.0, 0.01, "%.2f"),
        },
        ---@type ElementVec2Def
        offset = {
            key = "offset",
            lang_key = "hud_element.entry.box_enable_offset",
            bindable = true,
            draw = util_opt.enabled_vec2_slider(1, -1920, 1920, 1, "%.0f"),
            apply = function(_, ctx, value)
                ctx.elem:set_offset(value)
            end,
            format = util_opt.format_enabled_vec2("%.0f"),
        },
        ---@type ElementNumberDef
        rot = {
            key = "rot",
            lang_key = "hud_element.entry.box_enable_rotation",
            bindable = true,
            format = util_opt.format_enabled_number("%.1f"),
            draw = util_opt.enabled_slider(0.1, 0, 360, 0.1, "%.1f"),
            apply = function(_, ctx, value)
                ctx.elem:set_rot(value)
            end,
        },
        ---@type ElementNumberDef
        opacity = {
            key = "opacity",
            lang_key = "hud_element.entry.box_enable_opacity",
            bindable = true,
            format = util_opt.format_enabled_number("%.2f"),
            draw = util_opt.enabled_slider(0.01, 0, 1, 0.01, "%.2f"),
            apply = function(_, ctx, value)
                ctx.elem:set_opacity(value)
            end,
        },
        ---@type ElementStringDef
        segment = {
            key = "segment",
            lang_key = "hud_element.entry.box_enable_segment",
            bindable = true,
            format = util_opt.format_enabled_value,
            apply = function(_, ctx, value)
                ctx.elem:set_segment(value)
            end,
            draw = function(_, label, config_key)
                local value_key = config_key .. ".value"
                local changed = option_gui.draw_combo(
                    { config_key = config_key .. ".enabled" },
                    config_key .. ".value",
                    util_opt.get_label(label, config_key),
                    cd.combo.segment,
                    ---@diagnostic disable-next-line: param-type-mismatch
                    cd.combo.segment:get_index(nil, config:get(value_key))
                )

                if changed then
                    config:set(value_key, changed.value)
                    return true
                end

                return false
            end,
        },
        ---@type ElementBooleanDef
        disable_fade_opacity = {
            key = "disable_fade_opacity",
            is_available = function(_, elem_config)
                return elem_config.hud_id ~= nil
            end,
            lang_key = "hud_element.entry.box_disable_fade_opacity",
            bindable = false,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            apply = function(_, ctx, value)
                config:set(ctx.config_key, value)
            end,
        },
        ---@type ElementFadeDef
        override_fade = {
            key = "override_fade",
            is_available = function(_, elem_config)
                return elem_config.hud_id ~= nil
            end,
            lang_key = "hud_element.entry.box_override_fade_duration",
            bindable = false,
            draw = function(_, label, config_key)
                local changed =
                    set:checkbox(util_opt.get_label(label, config_key), config_key .. ".enabled")

                util_imgui.begin_disabled(not config:get(config_key .. ".enabled"))

                local fade_in_key = config_key .. ".fade_in"
                local fade_in = config:get(fade_in_key)
                changed = set:slider_float(
                    config.lang:tr("hud.slider_fade_in"),
                    fade_in_key,
                    0,
                    10,
                    fade_in == 0 and config.lang:tr("misc.text_off")
                        or util_gui.seconds_to_minutes_string(fade_in, "%.1f")
                ) or changed

                local fade_out_key = config_key .. ".fade_out"
                local fade_out = config:get(fade_out_key)
                changed = set:slider_float(
                    config.lang:tr("hud.slider_fade_out"),
                    fade_out_key,
                    0,
                    10,
                    fade_out == 0 and config.lang:tr("misc.text_off")
                        or util_gui.seconds_to_minutes_string(fade_out, "%.1f")
                ) or changed

                util_imgui.end_disabled()
                return changed
            end,
            apply = function(self, ctx, value)
                config:set(
                    string.format("%s.%s.%s", ctx.config_key, self.key, "enabled"),
                    value.enabled
                )
                config:set(
                    string.format("%s.%s.%s", ctx.config_key, self.key, "fade_in"),
                    value.fade_in
                )
                config:set(
                    string.format("%s.%s.%s", ctx.config_key, self.key, "fade_out"),
                    value.fade_out
                )
            end,
            format = function(_, value)
                if not value.enabled then
                    return config.lang:tr("misc.text_off")
                end

                return string.format(
                    "%s: %s, %s: %s",
                    config.lang:tr("hud.slider_fade_in"),
                    value.fade_in == 0 and config.lang:tr("misc.text_disabled")
                        or util_gui.seconds_to_minutes_string(value.fade_in, "%.1f"),
                    config.lang:tr("hud.slider_fade_out"),
                    value.fade_out == 0 and config.lang:tr("misc.text_disabled")
                        or util_gui.seconds_to_minutes_string(value.fade_out, "%.1f")
                )
            end,
        },
    },
}

local function get_elem_option_map()
    ---@type table<string, ElementOptNode>
    local res = {}

    ---@param elem_config HudBaseConfig
    ---@param hud_id app.GUIHudDef.TYPE
    ---@param options table<string, ElementOptionDef>
    ---@param keys string[]
    ---@param path string[]
    ---@param names string[]
    ---@param out table<string, NamedElementOptionDef>
    local function make_opt(elem_config, hud_id, options, keys, path, names, out)
        for _, opt in pairs(options) do
            local key = opt.key
            local available = util_opt.is_elem_available(opt, elem_config)

            if available then
                ---@diagnostic disable-next-line: no-unknown
                local default_value = util_opt.get_elem_config_value(opt, elem_config)

                out[key] = util_table.deep_copy(opt) --[[@as NamedElementOptionDef]]
                out[key].name = config.lang:tr(out[key].lang_key)
                out[key].path = string.format("%s.%s.%s", table.concat(path, "."), "opt", key)
                out[key].default_value = util_table.deep_copy(default_value)
                out[key].ctx_path =
                    { hud_id = hud_id, path = table.concat(util_table.slice(keys, 2, #keys), ".") }

                out[key].name_path = util_table.deep_copy(names)
                table.insert(out[key].name_path, out[key].name)
            end
        end
    end

    ---@param elem_config HudBaseConfig
    ---@param hud_id app.GUIHudDef.TYPE
    ---@param base_opt table<string, ElementBooleanDef>
    ---@param main_opt table<string, ElementBooleanDef>
    ---@param sub_opt table<string, ElementBooleanDef>
    ---@param keys string[]
    ---@param path string[]
    ---@param names string[]
    ---@return ElementOptNode?
    local function make_node(elem_config, hud_id, base_opt, main_opt, sub_opt, keys, path, names)
        if elem_config.name_key:sub(1, 2) == "__" then
            return
        end

        table.insert(path, elem_config.name_key)
        table.insert(keys, elem_config.name_key)

        ---@type ElementOptNode
        local node = {
            name_key = elem_config.name_key,
            hud_sub_type = elem_config.hud_sub_type,
            hud_id = elem_config.hud_id,
            hud_type = elem_config.hud_type,
            name = util_gui.tr_elem_name(elem_config.hud_id, elem_config.name_key),
            path = table.concat(path, "."),
            config_key = table.concat(keys, "."),
            opt = {},
            children = {},
        }

        table.insert(names, node.name)
        make_opt(elem_config, hud_id, base_opt, keys, path, names, node.opt)
        make_opt(elem_config, hud_id, main_opt, keys, path, names, node.opt)
        make_opt(elem_config, hud_id, sub_opt, keys, path, names, node.opt)

        table.insert(keys, "children")
        table.insert(path, "children")
        for _, child_config in pairs(elem_config.children or {}) do
            node.children[child_config.name_key] = make_node(
                child_config,
                hud_id,
                base_opt,
                main_opt,
                sub_opt,
                util_table.deep_copy(keys),
                util_table.deep_copy(path),
                util_table.deep_copy(names)
            )
        end

        return node
    end

    for _, enum in e.iter("app.GUIHudDef.TYPE") do
        local elem_config = factory.get_config(enum)
        local main = this.main[elem_config.hud_type]
        local sub = this.sub[elem_config.hud_sub_type]

        res[elem_config.name_key] = make_node(
            elem_config,
            elem_config.hud_id,
            this.opt,
            main and main.opt or {},
            sub and sub.opt or {},
            {},
            {},
            {}
        )
    end

    this.map = res
end

function this.make_tree()
    ---@param node BindElemOptNode
    ---@return BindElemOptNode?
    local function make_bind_node(node)
        ---@type NamedElementOptionDef[]
        local opt = {}
        for _, o in pairs(node.opt) do
            if o.bindable then
                ---@diagnostic disable-next-line: assign-type-mismatch
                table.insert(opt, o)
            end
        end

        table.sort(opt, function(a, b)
            return a.name < b.name
        end)
        node.opt = opt

        ---@type BindElemOptNode[]
        local children = {}
        for _, child in pairs(node.children) do
            table.insert(children, make_bind_node(child))
        end

        if #node.opt == 0 and #node.children == 0 then
            return nil
        end

        node.children = children
        return node
    end

    ---@type BindElemOptNode[]
    local bind_tree = {}
    for _, node in pairs(this.map) do
        local bind_node = make_bind_node(util_table.deep_copy(node) --[[@as BindElemOptNode]])
        if bind_node then
            table.insert(bind_tree, bind_node)
        end
    end

    table.sort(bind_tree, function(a, b)
        return a.name < b.name
    end)
    this.tree = tree:new(bind_tree, function(node)
        return node.children
    end, function(node)
        return node.opt
    end, {
        filter_fn = function(node)
            return node.name
        end,
        filter_leaf_fn = function(leaf)
            return leaf.name
        end,
    })
end

---@param path string
---@return NamedElementOptionDef
function this.get_opt(path)
    return util_table.get_by_path(this.map, path)
end

---@return boolean
function this.init()
    get_elem_option_map()
    this.make_tree()
    return true
end

return this
