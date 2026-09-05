local bind_manager = require("HudController.hud.bind.init")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local elements = require("HudController.hud.elements.init")
local factory = require("HudController.hud.factory")
local hud_elements = require("HudController.hud.manager.elements")
local hud_manager = require("HudController.hud.manager.init")
local state = require("HudController.gui.state")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local ace_map = data.ace.map
local mod_enum = data.mod.enum

local this = {}

---@param hud ModProfileConfig[]
---@param key integer
---@return integer?
local function hud_index_by_key(hud, key)
    return util_table.index(hud, function(o)
        return o.key == key
    end)
end

---@param hud ModProfileConfig[]
---@param name string
---@return integer?
local function hud_index_by_name(hud, name)
    return util_table.index(hud, function(o)
        return o.name == name
    end)
end

---@param config_mod ModSettings
local function refresh_hud_combo(config_mod)
    state.combo.hud:swap(config_mod.hud)
    config_mod.combo.key_bind.hud = 1
end

---@param items HudBaseConfigProfileForShow[]|ModProfileConfig[]
---@param name string
---@return string
local function get_unique_name(items, name)
    local key = 1
    local ret = name

    while util_table.value(items, function(_, value)
        return value.name == ret
    end) do
        key = key + 1
        ret = name .. key
    end

    return ret
end

---@protected
---@return ModProfileConfig
function this._new()
    local _key = 1
    util_table.do_something(config.current.mod.hud, function(_, _, value)
        _key = math.max(_key, value.key + 1) --[[@as integer]]
    end)

    return factory.get_hud_profile_config(_key, this.get_name("Hud" .. _key))
end

---@param new_hud ModProfileConfig?
function this.new(new_hud)
    local config_mod = config.current.mod
    table.insert(config_mod.hud, new_hud or this._new())
    this.reload()
end

function this.reload()
    local config_mod = config.current.mod
    refresh_hud_combo(config_mod)
end

---@param ordered_names string[]
function this.sort(ordered_names)
    local config_mod = config.current.mod
    local indexes = util_table.array_to_map(ordered_names)
    local current_hud = config_mod.hud[config_mod.combo.hud].name

    table.sort(config_mod.hud, function(a, b)
        return indexes[a.name] < indexes[b.name]
    end)

    config_mod.combo.hud = hud_index_by_name(config_mod.hud, current_hud) or 1
    refresh_hud_combo(config_mod)

    util_table.do_something(config_mod.bind.condition.hud, function(_, _, value)
        value.combo_profile = hud_index_by_key(config_mod.hud, value.key) or 1
    end)
end

---@param hud_config ModProfileConfig
function this.remove(hud_config)
    local config_mod = config.current.mod
    local i = util_table.key(config_mod.hud, function(_, value)
        return value.key == hud_config.key
    end)

    if not i then
        return
    end

    config_mod.hud = util_table.remove(config_mod.hud, function(_, i2, _)
        return i ~= i2
    end)

    config_mod.combo.hud = math.max(config_mod.combo.hud - 1, 1)
    refresh_hud_combo(config_mod)

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
        value.combo_profile = hud_index_by_key(config_mod.hud, value.key) or 1
    end)
end

---@param name string
---@return string
function this.get_name(name)
    return get_unique_name(config.current.mod.hud, name)
end

---@param hud_config ModProfileConfig
---@param new_name string
function this.rename(hud_config, new_name)
    if hud_config.name == new_name or new_name == "" then
        return
    end

    local config_mod = config.current.mod
    hud_config.name = this.get_name(new_name)
    state.combo.hud:swap(config_mod.hud)
end

---@param name_key string
function this.add_element(name_key)
    local _hud = config.current.mod.hud[config.current.mod.combo.hud]
    _hud.elements = _hud.elements or {}

    if _hud.elements[name_key] then
        return
    end

    local key = 1
    for _, elem in pairs(_hud.elements) do
        key = math.max(key, elem.key + 1)
    end

    local hud_elem = factory.get_config(e.get("app.GUIHudDef.TYPE")[name_key])
    hud_elem.key = key

    _hud.elements[name_key] = hud_elem
    hud_elements.update_elements(_hud.elements)
end

---@param hud_config ModProfileConfig
function this.export(hud_config)
    imgui.set_clipboard(json.dump_string(hud_config))
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

    local new_hud = util_table.merge2_t({ "key" }, false, this._new(), hud_config)
    new_hud.name = this.get_name(hud_config.name)
    new_hud.elements = factory.verify_elements(hud_config.elements)
    if not util_table.empty(new_hud.elements) then
        this.new(new_hud)
    end
end

---@param key integer
---@return ModProfileConfig
function this.get_hud_by_key(key)
    return util_table.value(config.current.mod.hud, function(_, value)
        return value.key == key
    end) --[[@as ModProfileConfig]]
end

---@param elements HudBaseConfig[]
---@param reverse boolean
function this.sort_elements(elements, reverse)
    table.sort(elements, function(a, b)
        if reverse then
            return this.tr_element(a) < this.tr_element(b)
        end
        return this.tr_element(a) > this.tr_element(b)
    end)
    for i, elem in ipairs(elements) do
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

---@param profiles HudBaseConfigProfileForShow[]
---@return HudBaseConfigProfileForShow?
function this.new_elem_profile_for_show(profiles)
    for i = 1, config.max_profile do
        if
            not util_table.index(profiles, function(o)
                return o.key == i
            end)
        then
            table.insert(profiles, {
                key = i,
                name = tostring(i),
                protected = false,
            })
            return profiles[#profiles]
        end
    end
end

---@param profiles HudBaseConfigProfileForShow[]
---@param profile HudBaseConfigProfileForShow
---@param new_name string
function this.rename_elem_profile_for_show(profiles, profile, new_name)
    profile.name = get_unique_name(profiles, new_name)
end

---@param root HudBaseConfig
---@param key integer
---@return HudBaseConfigProfile
function this.get_elem_profile(root, key)
    if key == mod_enum.elem_profile.DEFAULT then
        return root --[[@as HudBaseConfigProfile]]
    end

    local k = this.get_elem_profile_key(key)
    if not root.profile[k] then
        local new = elements[root.name_key].get_config() --[[@as HudBaseConfigProfile]]
        new.profile = nil
        new.current_profile = nil
        new.current_profile_gui = nil
        new.key = key
        new.enabled = false
        new.default_profile = nil

        root.profile[k] = new
    end

    return root.profile[k]
end

---@param root HudBaseConfig
function this.apply_elem_profile(root)
    local new_profile = this.get_elem_profile(root, root.current_profile_gui)

    if new_profile.enabled then
        root.current_profile = root.current_profile_gui
        hud_elements.update_element_profile(new_profile)
    else
        -- if selected profile is disabled, switch to default profile
        -- if default profile is disabled, switch to root profile
        if new_profile.key == root.default_profile then
            root.default_profile = mod_enum.elem_profile.DEFAULT
        end

        root.current_profile = root.default_profile
        new_profile = this.get_elem_profile(root, root.current_profile)
        hud_elements.update_element_profile(new_profile)
    end
end

---@param hud_config ModProfileConfig
---@param key integer
function this.remove_elem_profile(hud_config, key)
    for _, elem in pairs(hud_config.elements) do
        elem.profile[this.get_elem_profile_key(key)] = nil

        if key == elem.default_profile then
            elem.default_profile = mod_enum.elem_profile.DEFAULT
        end

        if key == elem.current_profile then
            elem.current_profile = elem.default_profile
            local profile = this.get_elem_profile(elem, elem.current_profile)
            hud_elements.update_element_profile(profile)
        end

        if key == elem.current_profile_gui then
            elem.current_profile_gui = elem.current_profile
        end
    end

    ---@return integer
    local function filter_binds(t, t_key)
        local elem_profile_keys = util_misc.unpack_bits(t[t_key])
        local filtered = util_table.filter_array(elem_profile_keys, function(_, value)
            return value ~= key
        end)
        ---@diagnostic disable-next-line: no-unknown
        t[t_key] = util_misc.pack_bits(filtered)
        return t[t_key]
    end

    local config_mod = config.current.mod
    for _, bind in pairs(config_mod.bind.key.hud) do
        local bound_value = bind.bound_value
        ---@cast bound_value HudBindOpt
        if bound_value.hud == hud_config.key then
            filter_binds(bound_value, "profile")
        end
    end

    for _, cond_set in pairs(config_mod.bind.condition.hud) do
        if cond_set.key == hud_config.key then
            for _, cond_child in pairs(cond_set.children) do
                cond_child.combo_profile = filter_binds(cond_child, "key")
            end
        end

        cond_set.children = util_table.filter_array(cond_set.children, function(_, value)
            return value.combo_profile ~= 0
        end)
    end

    config_mod.combo.key_bind.elem_profile = 0
end

---@param root HudBaseConfig
---@return HudBaseConfig
function this.import_elem_profile(root)
    local profile = json.load_string(imgui.get_clipboard()) --[[@as HudBaseConfigProfile?]]
    if not profile then
        return root
    end

    if profile.name_key ~= root.name_key then
        return root
    end

    local config_mod = config.current.mod
    if root.current_profile_gui == mod_enum.elem_profile.DEFAULT then
        local merged_root = factory.merge_profile(root, profile)
        config_mod.hud[config_mod.combo.hud].elements[root.name_key] = merged_root
        return merged_root
    else
        local profiles = root.profile
        local key = this.get_elem_profile_key(root.current_profile_gui)
        profiles[key] = factory.merge_profile(profiles[key], profile) --[[@as HudBaseConfigProfile]]
    end

    return root
end

---@param key integer
---@return HudProfileKey
function this.get_elem_profile_key(key)
    return tostring(key)
end

return this
