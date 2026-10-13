---@class ElemProfileConditionConfig : ConditionConfigBase
---@field profile integer

local cd = require("HudController.data.combo")
local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")
local set = require("HudController.gui.set")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

---@module "HudController.hud.manager.profile_switcher"
local profile_switcher = util_misc.lazy_require("HudController.hud.manager.profile_switcher")
---@module "HudController.hud.manager.op.init"
local op = util_misc.lazy_require("HudController.hud.manager.op.init")

---@class ElemProfileCondition : ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@return ElemProfileCondition
function this:new()
    local o = condition_base.new(
        self,
        "_ELEM_PROFILE",
        config.lang.make_placeholder("menu.bind.condition.condition_elem_profile"),
        {}
    )
    setmetatable(o, self)
    ---@cast o ElemProfileCondition

    return o
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
---@return boolean
function this:update(hud_key, profile_bit)
    local current = profile_switcher.current_hud
    if not current then
        return false
    end

    if current.hud.key ~= hud_key then
        return false
    end

    if profile_bit == 0 and #current.profile_bits == 1 and current.profile_bits[1] == 0 then
        return true
    end

    local unpacked = util_misc.unpack_bits(profile_bit)
    for _, bit_a in pairs(current.profile_bits) do
        for _, bit_b in pairs(unpacked) do
            if (bit_a & (1 << bit_b)) ~= 0 then
                return true
            end
        end
    end

    return false
end

---@param options ElemProfileConditionConfig
---@return integer, integer
function this:get_update_arg(options)
    return options.combo_key, options.profile
end

---@return ElemProfileConditionConfig
function this:new_config()
    local ret = condition_base.new_config(self)
    return util_table.merge(ret, {
        profile = 0,
    }) --[[@as ElemProfileConditionConfig]]
end

return this
