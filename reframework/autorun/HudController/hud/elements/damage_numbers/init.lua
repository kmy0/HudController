---@class (exact) DamageNumbers : DamageNumbersOffset, HudBase
---@field get_config fun(): DamageNumbersConfig
---@field GUI020020 app.GUI020020[]?
---@field panels table<via.gui.Panel, DamageInfo>>
---@field panels_by_cls table<app.GUI020020, table<via.gui.Panel, DamageInfo>>
---@field children {[string]: DamageNumbersCriticalState}

---@class (exact) DamageNumbersConfig : DamageNumbersOffsetConfig, HudBaseConfig
---@field children {[string]: DamageNumbersCriticalStateConfig}

---@class (exact) DamageInfo
---@field cls app.GUI020020
---@field written boolean
---@field state app.GUI020020.State
---@field critical_state app.GUI020020.CRITICAL_STATE
---@field pnl_wrap via.gui.Panel
---@field pnl_parent via.gui.Panel
---@field screen_pos Vector3f
---@field txt_damage via.gui.Text

local critical_state = require("HudController.hud.elements.damage_numbers.critical_state")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local hud_base = require("HudController.hud.def.hud_base")
local numbers_offset = require("HudController.hud.elements.damage_numbers.numbers_offset")
local util_game = require("HudController.util.game.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

---@class DamageNumbers
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args DamageNumbersConfig
---@return DamageNumbers
function this:new(args)
    local o = hud_base.new(self, args, nil, nil, true, true, function(a_key, b_key)
        if a_key.name_key == "ALL" then
            return true
        end

        if b_key.name_key == "ALL" then
            return false
        end
        return a_key.name_key < b_key.name_key
    end)
    setmetatable(o, self)
    numbers_offset.wrap(o, args)
    ---@cast o DamageNumbers

    o.panels = {}
    o.panels_by_cls = {}

    for name, _ in e.iter("app.GUI020020.CRITICAL_STATE") do
        o.children[name] = critical_state:new(args.children[name], o)
    end

    o.children.ALL = critical_state:new(args.children.ALL, o)

    return o
end

---@return app.GUI020020[]
function this:get_GUI020020()
    if not self.GUI020020 then
        self.GUI020020 =
            util_game.system_array_to_lua(util_game.get_all_components("app.GUI020020"))
    end

    return self.GUI020020
end

---@return [via.gui.Panel, via.gui.Panel][]
function this:get_all_panels()
    local ret = {}
    util_table.do_something(self:get_GUI020020(), function(_, _, GUI020020)
        local arr = GUI020020._DamageInfo
        if arr then
            util_game.do_something(arr, function(_, _, value)
                table.insert(ret, {
                    value:get_field("<PanelWrap>k__BackingField"),
                    value:get_field("<ParentPanel>k__BackingField"),
                })
            end)
        end
    end)

    return ret
end

---@protected
---@param GUI020020 app.GUI020020
---@param pnl_wrap via.gui.Panel
---@param damage_info app.GUI020020.DAMAGE_INFO
---@return DamageInfo
function this:_get_damage_info(GUI020020, pnl_wrap, damage_info)
    local pnl_parent = damage_info:get_field("<ParentPanel>k__BackingField")
    ---@type DamageInfo
    return {
        cls = GUI020020,
        written = false,
        pnl_parent = pnl_parent,
        pnl_wrap = pnl_wrap,
        screen_pos = pnl_parent:get_Position(),
        critical_state = damage_info:get_field("<criticalState>k__BackingField"),
        state = damage_info:get_field("<State>k__BackingField"),
        txt_damage = damage_info:get_field("<TextDamage>k__BackingField"),
    }
end

---@protected
---@param GUI020020 app.GUI020020
---@param info app.GUI020020.DAMAGE_INFO
function this:_set_damage_info(GUI020020, info)
    local pnl_wrap = info:get_field("<PanelWrap>k__BackingField")
    if pnl_wrap:get_Visible() and not self.panels[pnl_wrap] then
        local pnl_parent = info:get_field("<ParentPanel>k__BackingField")
        ---@type DamageInfo
        local damage_info = {
            cls = GUI020020,
            written = false,
            pnl_parent = pnl_parent,
            pnl_wrap = pnl_wrap,
            screen_pos = pnl_parent:get_Position(),
            critical_state = info:get_field("<criticalState>k__BackingField"),
            state = info:get_field("<State>k__BackingField"),
            txt_damage = info:get_field("<TextDamage>k__BackingField"),
        }
        self.panels[pnl_wrap] = damage_info
        util_table.set_nested_value(self.panels_by_cls, { GUI020020, pnl_wrap }, damage_info)
    end
end

---@param GUI020020 app.GUI020020
---@return table<via.gui.Panel, DamageInfo>
function this:get_dmg(GUI020020)
    local arr = GUI020020._DamageInfoList
    if arr then
        util_game.do_something(arr, function(_, _, value)
            self:_set_damage_info(GUI020020, value)
        end)
    end

    return self.panels_by_cls[GUI020020]
end

---@param GUI020020 app.GUI020020
---@return table<via.gui.Panel, DamageInfo>
function this:get_dmg_static(GUI020020)
    local arr = GUI020020._DamageInfo
    if arr then
        util_game.do_something(arr, function(_, _, value)
            self:_set_damage_info(GUI020020, value)
        end)
    end

    return self.panels_by_cls[GUI020020]
end

---@param GUI020020 app.GUI020020
---@param gui_id app.GUIID.ID
function this:write_dmg(GUI020020, gui_id)
    local dmg = self.panels_by_cls[GUI020020]
    if not dmg then
        return
    end

    for _, damage_info in pairs(dmg) do
        self:write(damage_info.pnl_wrap, gui_id, damage_info.pnl_parent)
    end
end

---@param key HudBaseWriteKey
function this:reset(key)
    if not self.initialized then
        return
    end

    self.panels = {}
    self.panels_by_cls = {}

    util_table.do_something(self:get_all_panels(), function(_, _, value)
        self:reset_ctrl(value[2], key)
        ---@diagnostic disable-next-line: param-type-mismatch
        self:reset_children(value[1], nil, value, key)
    end)
end

---@param pnl_wrap via.gui.Panel
---@param gui_id app.GUIID.ID
---@param pnl_parent via.gui.Control?
function this:write(pnl_wrap, gui_id, pnl_parent)
    local damage_info = self.panels[pnl_wrap]
    pnl_parent = damage_info.pnl_parent

    if not damage_info.pnl_wrap:get_Visible() then
        self.panels[pnl_wrap] = nil
        self.panels_by_cls[damage_info.cls][pnl_wrap] = nil

        if not damage_info.written then
            return
        end

        local crit_child =
            self.children[e.get("app.GUI020020.CRITICAL_STATE")[damage_info.critical_state]]
        local dmg_child = crit_child.children[e.get("app.GUI020020.State")[damage_info.state]]

        self.children.ALL:reset_ctrl(pnl_parent)
        ---@diagnostic disable-next-line: param-type-mismatch
        self.children.ALL.children.ALL:reset_specific(pnl_wrap, gui_id, pnl_parent)
        self.children.ALL.children[e.get("app.GUI020020.State")[damage_info.state]]:reset_specific(
            ---@diagnostic disable-next-line: param-type-mismatch
            pnl_wrap,
            gui_id,
            pnl_parent
        )
        crit_child:reset_ctrl(pnl_parent)
        ---@diagnostic disable-next-line: param-type-mismatch
        crit_child.children.ALL:reset_specific(pnl_wrap, gui_id, pnl_parent)
        ---@diagnostic disable-next-line: param-type-mismatch
        dmg_child:reset_specific(pnl_wrap, gui_id, pnl_parent)

        return
    end

    damage_info.written = true
    self:adjust_offset(damage_info)
    ---@diagnostic disable-next-line: param-type-mismatch
    hud_base.write(self, pnl_wrap, gui_id, pnl_parent)
end

---@return DamageNumbersConfig
function this.get_config()
    local base = hud_base.get_config(e.get("app.GUIHudDef.TYPE").DAMAGE_NUMBERS, "DAMAGE_NUMBERS") --[[@as DamageNumbersConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.DAMAGE_NUMBERS
    base.box = { x = 0, y = 0, w = 0, h = 0 }
    base.enabled_box = false

    for name, _ in e.iter("app.GUI020020.CRITICAL_STATE") do
        base.children[name] = critical_state.get_config(name)
    end
    children.ALL = critical_state.get_config("ALL")

    return base
end

return this
