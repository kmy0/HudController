---@class (exact) DamageNumbersCriticalState : DamageNumbersOffset, HudChild
---@field get_config fun(name_key: string): DamageNumbersCriticalStateConfig
---@field parent DamageNumbers
---@field root DamageNumbers
---@field children {[string]: DamageNumbersDamageState}

---@class (exact) DamageNumbersCriticalStateConfig : DamageNumbersOffsetConfig, HudChildConfig
---@field children {[string]: DamageNumbersDamageStateConfig}

local damage_state = require("HudController.hud.elements.damage_numbers.damage_state")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local hud_child = require("HudController.hud.def.hud_child")
local numbers_offset = require("HudController.hud.elements.damage_numbers.numbers_offset")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

---@class DamageNumbersCriticalState
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

---@param args DamageNumbersCriticalStateConfig
---@param parent DamageNumbers
---@return DamageNumbersCriticalState
function this:new(args, parent)
    local o = hud_child.new(
        self,
        args,
        parent,
        function(s, hudbase, _, ctrl)
            ---@cast hudbase app.GUI020020.DAMAGE_INFO?
            ---@cast s DamageNumbersCriticalState

            if
                not hudbase -- reset only
            then
                return ctrl
            end

            local state = s.root:get_state_value(hudbase, "<criticalState>k__BackingField") --[[@as app.GUI020020.CRITICAL_STATE]]
            if
                args.name_key == "ALL"
                or e.get("app.GUI020020.CRITICAL_STATE")[state] == args.name_key
            then
                s:adjust_offset(hudbase)
                return ctrl
            end
        end,
        nil,
        nil,
        nil,
        function(a_key, b_key)
            if a_key.name_key == "ALL" then
                return true
            end

            if b_key.name_key == "ALL" then
                return false
            end
            return a_key.name_key < b_key.name_key
        end,
        true
    )

    setmetatable(o, self)
    numbers_offset.wrap(o, args)
    ---@cast o DamageNumbersCriticalState

    for name, _ in e.iter("app.GUI020020.State") do
        o.children[name] = damage_state:new(args.children[name], o)
    end

    o.children.ALL = damage_state:new(args.children.ALL, o)

    ---@diagnostic disable-next-line: no-unknown
    for _, child in pairs(o.children) do
        child.reset = function(s, key)
            ---@diagnostic disable-next-line: param-type-mismatch
            o.reset(s, key)
        end
    end

    return o
end

---@param key HudChildWriteKey
function this:reset(key)
    if not self.initialized then
        return
    end

    self.pos_cache = {}
    util_table.do_something(self.root:get_all_panels(), function(_, _, value)
        ---@diagnostic disable-next-line: param-type-mismatch
        local ctrl = self:ctrl_getter(nil, nil, value)

        if type(ctrl) ~= "table" then
            ctrl = { ctrl }
        end

        for _, c in pairs(ctrl) do
            self:reset_ctrl(c, key)
        end
    end)
end

---@param name_key string
---@return DamageNumbersCriticalStateConfig
function this.get_config(name_key)
    local base = hud_child.get_config(name_key) --[[@as DamageNumbersCriticalStateConfig]]
    local children = base.children

    base.hud_sub_type = mod.enum.hud_sub_type.DAMAGE_NUMBERS
    base.box = { x = 0, y = 0, w = 0, h = 0 }
    base.enabled_box = false

    for name, _ in e.iter("app.GUI020020.State") do
        children[name] = damage_state.get_config(name)
    end
    children.ALL = damage_state.get_config("ALL")

    return base
end

return this
