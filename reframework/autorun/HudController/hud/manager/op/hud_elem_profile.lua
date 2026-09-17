local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local factory = require("HudController.hud.factory")
local hud_elements = require("HudController.hud.manager.elements")
local hud_manager = require("HudController.hud.manager.init")
local util_misc = require("HudController.util.misc.init")
local util_op = require("HudController.hud.manager.op.util")
local util_table = require("HudController.util.misc.table")

local mod_enum = data.mod.enum

local this = {}

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
    profile.name = util_op.get_unique_name(profiles, new_name)
end

---@param root HudBaseConfig
---@param key integer
---@return HudBaseConfigProfile
function this.get_elem_profile(root, key)
    if key == mod_enum.elem_profile.DEFAULT then
        return root --[[@as HudBaseConfigProfile]]
    end

    local k = tostring(key)
    if not root.profile[k] then
        local new = factory.get_config(root.hud_id) --[[@as HudBaseConfigProfile]]
        new.profile = nil
        new.current_profile = nil
        new.current_profile_gui = nil
        new.profile_key = key
        new.enabled = false
        new.default_profile = nil

        root.profile[k] = new
    end

    return root.profile[k]
end

---@param root HudBaseConfig
function this.apply_elem_profile(root)
    local current_profile = this.get_elem_profile(root, root.current_profile)
    if
        current_profile.enabled
        and config.current.mod.enable_condition_binds
        and hud_manager.is_profile_selected(root.name_key, root.current_profile)
    then
        return
    end

    local new_profile = this.get_elem_profile(root, root.current_profile_gui)
    if new_profile.enabled then
        root.current_profile = root.current_profile_gui
    else
        -- if selected profile is disabled, switch to default profile
        -- if default profile is disabled, switch to root profile
        if new_profile.profile_key == root.default_profile then
            root.default_profile = mod_enum.elem_profile.DEFAULT
        end

        root.current_profile = root.default_profile
        new_profile = this.get_elem_profile(root, root.current_profile)
    end

    hud_elements.update_element_profile(new_profile)
end

---@param hud_config ModProfileConfig
---@param key integer
function this.remove_elem_profile(hud_config, key)
    for _, elem in pairs(hud_config.elements) do
        elem.profile[tostring(key)] = nil

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
        if cond_set.key == hud_config.key and cond_set.element_profile then
            for _, cond_child in pairs(cond_set.element_profile) do
                cond_child.combo_profile = filter_binds(cond_child, "key")
            end

            cond_set.element_profile = util_table.filter_array(
                cond_set.element_profile,
                function(_, value)
                    return value.combo_profile ~= 0
                end
            )
        end
    end

    config_mod.combo.key_bind.elem_profile = 0
    cd.clear_cache()
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
        local key = tostring(root.current_profile_gui)
        profiles[key] = factory.merge_profile(profiles[key], profile) --[[@as HudBaseConfigProfile]]
    end

    return root
end

return this
