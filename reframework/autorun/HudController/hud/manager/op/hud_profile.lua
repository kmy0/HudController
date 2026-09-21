local bind_manager = require("HudController.hud.bind.key.init")
local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local factory = require("HudController.hud.factory")
local hud_manager = require("HudController.hud.manager.init")
local util_op = require("HudController.hud.manager.op.util")
local util_table = require("HudController.util.misc.table")

---@module "HudController.hud.init"
local hud = require("HudController.util.misc.init").lazy_require("HudController.hud.init")

local this = {}

---@protected
---@return ModProfileConfig
function this.new_hud_profile()
    local _key = 1
    util_table.do_something(config.current.mod.hud, function(_, _, value)
        _key = math.max(_key, value.key + 1) --[[@as integer]]
    end)

    return factory.get_hud_profile_config(_key, this.get_name("Hud" .. _key))
end

---@param new_hud ModProfileConfig?
function this.new(new_hud)
    local config_mod = config.current.mod
    table.insert(config_mod.hud, new_hud or this.new_hud_profile())
    this.reload()
end

function this.reload()
    local config_mod = config.current.mod
    util_op.refresh_hud_combo(config_mod)
end

---@param ordered_names string[]
function this.sort(ordered_names)
    local config_mod = config.current.mod
    local indexes = util_table.index_by_value(ordered_names)
    local current_hud = config_mod.hud[config_mod.combo.hud].name

    table.sort(config_mod.hud, function(a, b)
        return indexes[a.name] < indexes[b.name]
    end)

    config_mod.combo.hud = util_op.hud_index_by_name(config_mod.hud, current_hud) or 1
    util_op.refresh_hud_combo(config_mod)

    util_table.do_something(config_mod.bind.condition.hud, function(_, _, value)
        value.combo_profile = util_op.hud_index_by_key(config_mod.hud, value.key --[[@as integer]])
            or 1
    end)
    cd.clear_cache()
end

---@param hud_config ModProfileConfig
function this.remove(hud_config)
    local config_mod = config.current.mod
    local i = util_table.find_key(config_mod.hud, function(_, value)
        return value.key == hud_config.key
    end)

    if not i then
        return
    end

    config_mod.hud = util_table.filter_inplace(config_mod.hud, function(_, i2, _)
        return i ~= i2
    end)

    config_mod.combo.hud = math.max(config_mod.combo.hud - 1, 1)
    util_op.refresh_hud_combo(config_mod)

    if util_table.empty(config_mod.hud) then
        hud_manager.clear()
    end

    for _, bind in pairs(bind_manager.hud.binds) do
        if bind.bound_value == hud_config.key then
            bind_manager.hud:unregister(bind)
        end
    end

    config_mod.bind.key.hud = bind_manager.hud:get_base_binds()
    config_mod.bind.condition.hud = util_table.filter_array(
        config_mod.bind.condition.hud,
        function(_, value)
            return value.key ~= hud_config.key
        end
    )

    util_table.do_something(config_mod.bind.condition.hud, function(_, _, value)
        value.combo_profile = util_op.hud_index_by_key(config_mod.hud, value.key --[[@as integer]])
            or 1
    end)

    cd.clear_cache()
end

---@param name string
---@return string
function this.get_name(name)
    return util_op.get_unique_name(config.current.mod.hud, name)
end

---@param hud_config ModProfileConfig
---@param new_name string
function this.rename(hud_config, new_name)
    if hud_config.name == new_name or new_name == "" then
        return
    end

    local config_mod = config.current.mod
    hud_config.name = this.get_name(new_name)
    cd.combo.hud:swap(config_mod.hud)
end

function this.import()
    local hud_config = json.load_string(imgui.get_clipboard()) --[[@as ModProfileConfig?]]
    if
        not hud_config
        or not hud_config.elements
        or util_table.empty(hud_config.elements)
        or not hud_config.name
    then
        return
    end

    local new_hud = util_table.merge_protected({ "key" }, false, this.new_hud_profile(), hud_config)
    new_hud.name = this.get_name(hud_config.name)
    new_hud.elements = factory.verify_elements(hud_config.elements)
    if not util_table.empty(new_hud.elements) then
        this.new(new_hud)
    end
end

---@param hud_config ModProfileConfig
function this.export(hud_config)
    imgui.set_clipboard(json.dump_string(hud_config))
end

---@param key integer
---@return ModProfileConfig
function this.get_hud_by_key(key)
    return util_table.find_value(config.current.mod.hud, function(_, value)
        return value.key == key
    end) --[[@as ModProfileConfig]]
end

function this.verify_elements()
    local config_mod = config.current.mod
    for i = 1, #config_mod.hud do
        config_mod.hud[i] = factory.verify_hud(config_mod.hud[i])
        local hud = config_mod.hud[i]
        hud.elements = factory.verify_elements(hud.elements or {})
    end
end

function this.remove_element(name_key)
    local config_mod = config.current.mod
    local current_hud = config_mod.hud[config_mod.combo.hud]
    current_hud.elements[name_key] = nil

    cd.clear_cache()
    hud.update_elements(current_hud.elements)
end

return this
