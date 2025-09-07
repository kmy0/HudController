---@class Separator
---@field ordered_keys string[]
---@field protected _count integer
---@field protected _start_count integer

local config = require("HudController.config")
local util_misc = require("HudController.util.misc")
local util_table = require("HudController.util.misc.table")

local this = {}
local all_bools = {
    "enabled_scale",
    "enabled_offset",
    "enabled_rot",
    "enabled_opacity",
    "enabled_play_state",
    "enabled_alpha_channel",
    "enabled_blend",
    "enabled_color",
    "enabled_control_point",
    "enabled_ignore_alpha",
    "enabled_var0",
    "enabled_var1",
    "enabled_var2",
    "enabled_var3",
    "enabled_var4",
    "enabled_size_x",
    "enabled_size_y",
    "enabled_segment",
    "hide_glow",
    "enabled_glow_color",
    "enabled_font_size",
    "enabled_offset_x",
    "align_left",
    "enabled_page_alignment",
    "enabled_num_offset_x",
    "enabled_clock_offset_x",
}

---@class Separator
local Separator = {}
---@diagnostic disable-next-line: inject-field
Separator.__index = Separator

---@param ordered_keys any
---@return Separator
function Separator:new(ordered_keys)
    local o = {
        ordered_keys = ordered_keys,
        _count = -1,
        _start_count = -1,
    }
    setmetatable(o, self)
    return o
end

---@param t table<string, any>
function Separator:refresh(t)
    self._count = -1
    for i = 1, #self.ordered_keys do
        if t[self.ordered_keys[i]] ~= nil then
            self._count = self._count + 1
        end
    end
    self._start_count = self._count
end

function Separator:has_separators()
    return self._count > 0
end

function Separator:had_separators()
    return self._start_count > -1
end

function Separator:draw()
    if self:has_separators() then
        imgui.separator()
        self._count = self._count - 1
    end
end

---@param key string
---@param ... string
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

---@param elem_config HudBaseConfig | MaterialConfig | Scale9Config
---@param thing string?
---@return boolean
function this.is_only_thing(elem_config, thing)
    thing = thing or "hide"

    if elem_config[thing] == nil then
        return false
    end

    if elem_config.name_key == "text" then
        util_table.any(all_bools, function(key, value)
            return elem_config[value] ~= nil
        end)
    end
    if
        (elem_config.children and not util_table.empty(elem_config.children))
        or util_table.any(all_bools, function(key, value)
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

this.separator = Separator
return this
