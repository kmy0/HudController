---@class ElemProfileConditionConfig : MultiSelectConditionConfig
---@field profile integer

local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local multi_select = require("HudController.hud.bind.condition.conditions.multi_select")
local set = require("HudController.gui.set")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

---@module "HudController.hud.manager.profile_switcher"
local profile_switcher = util_misc.lazy_require("HudController.hud.manager.profile_switcher")
---@module "HudController.hud.manager.op.init"
local op = util_misc.lazy_require("HudController.hud.manager.op.init")

local ace_map = data.ace.map

---@class ElemProfileCondition : MultiSelectCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = multi_select })

---@return ElemProfileCondition
function this:new()
    local o = multi_select.new(
        self,
        "_ELEM_PROFILE",
        config.lang.make_placeholder("menu.bind.condition.condition_elem_profile"),
        {}
    )
    setmetatable(o, self)
    ---@cast o ElemProfileCondition

    return o
end

---@return { key: string, value: string }[], string[]
function this:get_sorted()
    ---@type { key: string, value: string }[]
    local sorted = util_table.sort(
        util_table.entries(ace_map.hudid_name_to_local_name),
        function(a, b)
            return a.key < b.key
        end
    )

    local sorted_values = util_table.transform(sorted, function(value)
        return value.value
    end)

    return sorted, sorted_values
end

---@param config_key string
---@return boolean
function this:draw_options(config_key)
    local width = util_imgui.get_available_width() / 2 - 5
    imgui.set_next_item_width(width)

    local config_mod = config.current.mod
    local opt = self:get_option_table(config_key) --[[@as ElemProfileConditionConfig]]
    local combo_key = config_key .. ".combo"
    local profile_key = config_key .. ".profile"
    local index = config:get(combo_key)
    local hud_config = config_mod.hud[index]
    local ignore_changed = false

    if not hud_config or hud_config.key ~= opt.combo_key then
        config:set(
            combo_key,
            util_table.index(config_mod.hud, function(o)
                return o.key == opt.combo_key
            end)
        )

        if not config:get(combo_key) then
            ignore_changed = true
        end
    end

    util_imgui.begin_disabled(cd.combo.hud:empty())
    local changed =
        set:combo_filter("##elem_profile_cond_1|" .. config_key, combo_key, cd.combo.hud)
    hud_config = config.current.mod.hud[config:get(combo_key)]

    if changed and hud_config then
        config:set(profile_key, 0)
        config:set(config_key .. ".combo_key", hud_config.key)
    end

    ---@type HudBaseConfigProfileForShow[]
    local values
    if hud_config then
        values = hud_config.profile
    else
        values = {}
    end

    imgui.same_line()
    imgui.set_next_item_width(width)
    multi_select.draw_options(self, config_key)

    imgui.set_next_item_width(-3)
    changed = set:combo_multi_bits_filter(
        "##elem_profile_cond_2|" .. config_key,
        profile_key,
        config.lang:tr("misc.text_none"),
        values,
        function(v)
            return v.key
        end,
        function(v)
            return op.hud_elem_profile.tr_profile(v)
        end
    ) or changed

    if ignore_changed then
        changed = false
    end

    util_imgui.end_disabled()
    return changed
end

---@param hud_key integer
---@param profile_bit integer
---@param selection table<any, boolean>
---@return boolean
function this:update(hud_key, profile_bit, selection)
    local current = profile_switcher.current_hud
    if not current then
        return false
    end

    if current.hud.key ~= hud_key then
        return false
    end

    if util_table.empty(selection) then
        if profile_bit == 0 and #current.profile_bits == 1 and current.profile_bits[1] == 0 then
            return true
        end

        for _, bit_a in pairs(current.profile_bits) do
            if (bit_a & profile_bit) ~= 0 then
                return true
            end
        end
    else
        for elem_name, _ in pairs(selection) do
            local profile = current.profile[elem_name]
            if profile and (profile & profile_bit) ~= 0 then
                return true
            end
        end
    end

    return false
end

---@param options ElemProfileConditionConfig
---@return integer, integer, table<any, boolean>
function this:get_update_arg(options)
    return options.combo_key, options.profile, options.selection
end

---@return ElemProfileConditionConfig
function this:new_config()
    local ret = multi_select.new_config(self)
    return util_table.merge(ret, {
        profile = 0,
    }) --[[@as ElemProfileConditionConfig]]
end

return this
