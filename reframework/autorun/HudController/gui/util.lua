local config = require("HudController.config.init")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")
---@module "HudController.gui.elements.init"
local gui_elements = util_misc.lazy_require("HudController.gui.elements.init")

local this = {}

---@param key string
---@param ... string | integer
---@return string
function this.tr(key, ...)
    local suffix = { ... }
    table.insert(suffix, key)

    local int = key:match("%d+$")
    ---@type string
    local msg
    if int then
        key = string.gsub(key, "%d", "")
        msg = string.format("%s %s", config.lang:tr(key), int)
    else
        msg = config.lang:tr(key)
    end

    return string.format("%s##%s", msg, table.concat(suffix, "_"))
end

---@param key string
---@return string
function this.tr_int(key)
    local int = key:match("%d+")
    ---@type string
    local msg
    if int then
        key = string.gsub(key, "%d", "")
        msg = string.format("%s %s", config.lang:tr(key), int)
    else
        msg = config.lang:tr(key)
    end

    return msg
end

---@param n string | number
---@param width integer?
function this.pad_zero(n, width)
    if type(n) == "number" then
        n = tostring(n)
    end

    width = width or 2

    local int_part, dec_part = n:match("([^%.]+)%.?(.*)")

    if #dec_part > 0 then
        local padded_int = string.format("%0" .. width .. "d", tonumber(int_part))
        return padded_int .. "." .. dec_part
    end
    return string.format("%0" .. width .. "d", tonumber(int_part))
end

---@param n number
---@param n_format string?
---@param pad boolean?
function this.seconds_to_minutes_string(n, n_format, pad)
    if not n_format then
        n_format = "%d"
    end

    local minutes = n / 60
    local seconds = n
    local seconds_f = string.format(n_format, seconds)
    local format = "%s %s"

    if minutes >= 1 then
        minutes = math.floor(minutes)
        seconds = n - minutes * 60
        seconds_f = string.format(n_format, seconds)
        format = string.format("%s, %s", format, format)
        local minutes_f = string.format(n_format, minutes)

        return string.format(
            format,
            pad and this.pad_zero(minutes_f) or minutes_f,
            minutes == 1 and config.lang:tr("misc.text_minute")
                or config.lang:tr("misc.text_minute_plural"),
            pad and this.pad_zero(seconds_f) or seconds_f,
            util_misc.round(seconds, 1) == 1 and config.lang:tr("misc.text_second")
                or config.lang:tr("misc.text_second_plural")
        )
    end

    return string.format(
        format,
        pad and this.pad_zero(seconds_f) or seconds_f,
        util_misc.round(seconds, 1) == 1 and config.lang:tr("misc.text_second")
            or config.lang:tr("misc.text_second_plural")
    )
end

---@param elem HudBase
---@param elem_config HudBaseConfig | MaterialConfig | Scale9Config
---@param thing string?
---@return boolean
function this.is_only_thing(elem, elem_config, thing)
    thing = thing or "hide"

    if elem_config[thing] == nil then
        return false
    end

    local all_bools = elem:get_boolean_config_keys()
    if
        (elem_config.children and not util_table.empty(elem_config.children))
        or util_table.any(all_bools, function(_, value)
            if value == thing then
                return false
            end
            return elem_config[value] ~= nil
        end)
    then
        return false
    end

    return true
end

function this.get_item_size()
    local step = 200 / config.lang.default_font_size
    return step * config.lang.font_size
end

function this.is_gui_disabled()
    return gui_elements.selector.is_opened or gui_elements.sorter.is_opened
end

return this
