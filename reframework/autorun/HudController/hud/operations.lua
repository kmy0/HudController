local bind_manager = require("HudController.hud.bind")
local config = require("HudController.config")
local data = require("HudController.data")
local factory = require("HudController.hud.factory")
local hud_manager = require("HudController.hud.manager")
local state = require("HudController.gui.state")
local util_game = require("HudController.util.game")
local util_table = require("HudController.util.misc.table")

local rl = util_game.data.reverse_lookup
local ace_enum = data.ace.enum
local ace_map = data.ace.map

local this = {}

---@protected
---@return HudProfileConfig
function this._new()
    local _key = 1
    util_table.do_something(config.current.mod.hud, function(t, key, value)
        _key = math.max(_key, value.key + 1) --[[@as integer]]
    end)

    return factory.get_hud_profile_config(_key, this.get_name("Hud" .. _key))
end

---@param new_hud HudProfileConfig?
function this.new(new_hud)
    local config_mod = config.current.mod
    table.insert(config_mod.hud, new_hud or this._new())
    this.reload()
end

function this.reload()
    local config_mod = config.current.mod
    state.combo.hud:swap(config_mod.hud)
end

---@param hud_config HudProfileConfig
function this.remove(hud_config)
    local config_mod = config.current.mod
    local i = util_table.key(config_mod.hud, function(key, value)
        return value.key == hud_config.key
    end)

    if not i then
        return
    end

    config_mod.hud = util_table.remove(config_mod.hud, function(t, i2, j)
        return i ~= i2
    end)
    state.combo.hud:swap(config_mod.hud)
    config_mod.combo_hud = math.max(config_mod.combo_hud - 1, 1)

    if util_table.empty(config_mod.hud) then
        hud_manager.clear()
    end

    for _, key in pairs({ "singleplayer", "multiplayer" }) do
        for _, weapon in
            pairs(config_mod.bind.weapon[key] --[[@as table<string, WeaponBindConfig>]])
        do
            for _, key2 in pairs({ "combat_in", "combat_out" }) do
                local t = weapon[key2] --[[@as WeaponBindConfigData]]
                if t.hud_key == hud_config.key then
                    t.hud_key = -1
                    t.combo = 1
                    weapon.enabled = false
                end
            end
        end
    end

    for _, bind in pairs(bind_manager.hud_manager.binds) do
        if bind.key == hud_config.key then
            bind_manager.hud_manager:unregister(bind)
        end
    end

    config_mod.combo_hud_key_bind = 1
    config_mod.bind.key.hud = bind_manager.hud_manager:get_base_binds()
end

---@param name string
---@return string
function this.get_name(name)
    local key = 1
    local ret = name
    while 1 do
        local _hud = util_table.value(config.current.mod.hud, function(_, value)
            return value.name == ret
        end)

        if _hud then
            key = key + 1
            ret = name .. key
        else
            break
        end
    end
    return ret
end

---@param hud_config HudProfileConfig
---@param new_name string
function this.rename(hud_config, new_name)
    if hud_config.name == new_name or new_name == "" then
        return
    end

    hud_config.name = this.get_name(new_name)
    state.combo.hud:swap(config.current.mod.hud)
end

---@param name_key string
function this.add_element(name_key)
    local _hud = config.current.mod.hud[config.current.mod.combo_hud]
    _hud.elements = _hud.elements or {}

    if _hud.elements[name_key] then
        return
    end

    local key = 1
    for _, elem in pairs(_hud.elements) do
        key = math.max(key, elem.key + 1)
    end

    local hud_elem = factory.get_config(rl(ace_enum.hud, name_key))
    hud_elem.key = key

    _hud.elements[name_key] = hud_elem
    hud_manager.update_elements(_hud.elements)
end

---@param hud_config HudProfileConfig
function this.export(hud_config)
    imgui.set_clipboard(json.dump_string(hud_config))
end

function this.import()
    local hud_config = json.load_string(imgui.get_clipboard()) --[[@as HudProfileConfig?]]
    if not hud_config or not hud_config.elements or util_table.empty(hud_config.elements) or not hud_config.name then
        return
    end

    local new_hud = util_table.merge2_t({ "key" }, false, this._new(), hud_config)
    new_hud.name = this.get_name(hud_config.name)
    new_hud.elements = factory.verify_elements(hud_config.elements)
    if not util_table.empty(hud_config.elements) then
        this.new(new_hud)
    end
end

---@param key integer
---@return HudProfileConfig
function this.get_hud_by_key(key)
    return util_table.value(config.current.mod.hud, function(_, value)
        return value.key == key
    end) --[[@as HudProfileConfig]]
end

---@param elements HudBaseConfig[]
function this.sort_elements(elements)
    table.sort(elements, function(a, b)
        return this.tr_element(a) > this.tr_element(b)
    end)
    for i, elem in pairs(elements) do
        elem.key = i
    end
end

---@param element HudBaseConfig
function this.tr_element(element)
    local name = ace_map.hudid_name_to_local_name[element.name_key]
    if name == ace_map.hud_tr_flag then
        name = config.lang:tr("hud_element.name." .. element.name_key)
    end
    return name
end

return this
