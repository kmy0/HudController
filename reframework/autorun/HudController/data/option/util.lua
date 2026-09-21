local config = require("HudController.config.init")
local option_gui = require("HudController.gui.option")
local set = require("HudController.gui.set")
local util_gui = require("HudController.gui.util")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

---@module "HudController.hud.manager.op.init"
local op = util_misc.lazy_require("HudController.hud.manager.op.init")

local this = {}

---@param label string?
---@param config_key string
---@return string
function this.get_label(label, config_key)
    return label or ("##" .. config_key)
end

---@param opt ElementOptionDef
---@param label string?
---@param config_key string
---@return boolean
function this.draw_elem(opt, label, config_key)
    ---@diagnostic disable-next-line: param-type-mismatch
    return opt:draw(label, string.format("%s.%s", config_key, opt.key))
end

---@param opt ElementOptionDef<HudBase, HudBaseConfig, any>
---@param ctx ElementOptionContext<HudBase, HudBaseConfig>
---@param label string?
---@return boolean
function this.draw_apply_elem(opt, ctx, label)
    if not this.is_elem_available(opt, ctx.elem_config) then
        return false
    end

    local is_current_profile = op.hud_elem.is_current_profile(ctx.elem)
    label = label or util_gui.tr(opt.lang_key, ctx.config_key)
    local changed = this.draw_elem(opt, label, ctx.config_key)

    if changed and is_current_profile then
        this.apply_elem(opt, ctx)
        ctx.elem.overridden_options[opt.key] = nil
    end

    if is_current_profile then
        local overridden = ctx.elem.overridden_options[opt.key]
        if overridden ~= nil then
            imgui.same_line()
            imgui.text(
                string.format(
                    "(%s %s)",
                    config.lang:tr("misc.text_overridden"),
                    opt:format(overridden)
                )
            )
        end
    end

    return changed
end

---@param opt ElementOptionDef<HudBase, HudBaseConfig, any>
---@param ctx ElementOptionContext<HudBase, HudBaseConfig>
function this.apply_elem(opt, ctx)
    opt:apply(ctx, this.get_elem_config_value(opt, ctx.elem_config))
end

---@param opt ElementOptionDef
---@param elem_config HudBaseConfig
---@return boolean
function this.is_elem_available(opt, elem_config)
    if opt.is_available then
        return opt:is_available(elem_config)
    end
    return elem_config[opt.key] ~= nil
end

---@param opt ElementOptionDef
---@param elem_config HudBaseConfig
---@return any
function this.get_elem_config_value(opt, elem_config)
    if opt.get_config_value then
        return opt:get_config_value(elem_config)
    end
    return elem_config[opt.key]
end

---@param ctx ElementOptionContext<HudBase, HudBaseConfig>
---@param path string
---@return ElementOptionContext<HudBase, HudBaseConfig>
function this.resolve_elem_ctx(ctx, path)
    local keys = util_table.split_path(path)

    return {
        elem = util_table.get_nested_value(ctx.elem, keys),
        elem_config = util_table.get_nested_value(ctx.elem_config, keys),
        config_key = string.format("%s.%s", ctx.config_key, path),
    }
end

---@param key string
---@param ... string | number imgui id
function this.tr(key, ...)
    local suffix = { ... }
    table.insert(suffix, key)

    return string.format("%s##%s", config.lang:tr(key), table.concat(suffix, "_"))
end

---@param self OptionDef | ElementOptionDef
---@param label string?
---@param config_key string
---@return boolean
---@diagnostic disable-next-line: unused-local
function this.checkbox(self, label, config_key)
    return set:checkbox(this.get_label(label, config_key), config_key)
end

---@param self OptionDef | ElementOptionDef
---@param val boolean
---@return string
---@diagnostic disable-next-line: unused-local
function this.format_checkbox(self, val)
    return val and config.lang:tr("misc.text_on") or config.lang:tr("misc.text_off")
end

---@param _ OptionDef | ElementOptionDef
---@param value any
---@return string
function this.format_value(_, value)
    return tostring(value)
end

---@param _ ElementOptionDef
---@param value {enabled: boolean, value: any}
---@return string
function this.format_enabled_value(_, value)
    if not value.enabled then
        return config.lang:tr("misc.text_disabled")
    end

    return tostring(value.value)
end

---@param format string
---@return fun(self: ElementOptionDef<any, any, EnabledNumber>, value: EnabledNumber): string
function this.format_enabled_number(format)
    return function(_, value)
        if not value.enabled then
            return config.lang:tr("misc.text_disabled")
        end

        return string.format(format, value.value)
    end
end

---@param format string
---@return fun(self: ElementOptionDef<any, any, EnabledVec2>, value: EnabledVec2): string
function this.format_enabled_vec2(format)
    return function(_, value)
        if not value.enabled then
            return config.lang:tr("misc.text_off")
        end

        return string.format("x=" .. format .. ", y=" .. format, value.x, value.y)
    end
end

---@param format string
---@return fun(self: OptionDef<number>, value: number): string
function this.format_number(format)
    return function(_, value)
        return string.format(format, value)
    end
end

---@param _ OptionDef<integer>
---@param value integer
---@return string
function this.format_seconds_short(_, value)
    return string.format("%d %s", value, config.lang:tr("misc.text_seconds_short"))
end

---@param speed number
---@param min number
---@param max number
---@param step number
---@param format string
---@return fun(self: ElementOptionDef, label: string?, config_key: string): boolean
function this.enabled_slider(speed, min, max, step, format)
    return function(_, label, config_key)
        return option_gui.draw_slider_settings(
            { config_key = config_key .. ".enabled" },
            { { config_key = config_key .. ".value" } },
            speed,
            min,
            max,
            step,
            format,
            label
        )
    end
end

---@param speed number
---@param min number
---@param max number
---@param step number
---@param format string
---@return fun(self: ElementOptionDef, label: string?, config_key: string): boolean
function this.enabled_vec2_slider(speed, min, max, step, format)
    return function(_, label, config_key)
        return option_gui.draw_slider_settings({ config_key = config_key .. ".enabled" }, {
            { config_key = config_key .. ".x" },
            { config_key = config_key .. ".y" },
        }, speed, min, max, step, format, label)
    end
end

---@param min number
---@param max number
---@return fun(self: OptionDef<number>, label: string?, config_key: string): boolean
function this.slider_float(min, max)
    return function(self, label, config_key)
        local value = config:get(config_key)
        return set:slider_float(
            this.get_label(label, config_key),
            config_key,
            min,
            max,
            self:format(value)
        )
    end
end

---@param min integer
---@param max integer
---@return fun(self: OptionDef<integer>, label: string?, config_key: string): boolean
function this.slider_int(min, max)
    return function(self, label, config_key)
        local value = config:get(config_key)
        return set:slider_int(
            this.get_label(label, config_key),
            config_key,
            min,
            max,
            self:format(value)
        )
    end
end

---@param speed number
---@param min integer
---@param max integer
---@return fun(self: OptionDef<integer>, label: string?, config_key: string): boolean
function this.drag_int(speed, min, max)
    return function(self, label, config_key)
        local value = config:get(config_key)
        return set:drag_int(
            this.get_label(label, config_key),
            config_key,
            speed,
            min,
            max,
            self:format(value)
        )
    end
end

---@param value number
---@param format string?
---@return string
function this.format_disabled_number(_, value, format)
    return value == 0 and config.lang:tr("hud.option_disable")
        or string.format(format or "%.1f", value)
end

---@param _ OptionDef<integer> | ElementOptionDef<any, any, integer>
---@param value integer
---@return string
function this.format_color(_, value)
    return string.format("0x%08X", value)
end

---@param _ ElementOptionDef<any, any, EnabledInteger>
---@param value EnabledInteger
---@return string
function this.format_enabled_color(_, value)
    if not value.enabled then
        return config.lang:tr("misc.text_disabled")
    end

    return string.format("0x%08X", value.value)
end

---@param _ OptionDef<integer> | ElementOptionDef<any, any, integer>
---@param label string?
---@param config_key string
---@return boolean
function this.color(_, label, config_key)
    return set:color_edit(this.get_label(label, config_key), config_key)
end

---@param _ ElementOptionDef<any, any, EnabledInteger>
---@param label string?
---@param config_key string
---@return boolean
function this.enabled_color(_, label, config_key)
    local enabled_key = config_key .. ".enabled"
    local value_key = config_key .. ".value"
    return option_gui.draw_enabled_color(
        { config_key = enabled_key },
        value_key,
        this.get_label(label, value_key)
    )
end

---@param self OptionDef
---@param val boolean
---@return boolean
---@diagnostic disable-next-line: unused-local
function this.active_checkbox(self, val)
    return val
end

---@param self OptionDef
---@param label string?
---@param config_key string
---@return boolean
function this.slider_list(self, label, config_key)
    return set:slider_list(
        this.get_label(label, config_key),
        config_key,
        1,
        #self.combo.values,
        self.combo.values
    )
end

---@param opt OptionDef
---@param config_key string
---@return boolean
function this.menu_item(opt, config_key)
    return set:menu_item(this.tr(opt.lang_key, config_key), config_key)
end

---@param self OptionDef
---@param index integer
---@return string
function this.format_combo(self, index)
    return self.combo.values[index]
end

return this
