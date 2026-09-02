---@class HudElements
---@field by_hudid table<app.GUIHudDef.TYPE, HudBase>
---@field by_guiid table<app.GUIID.ID, HudBase>

local call_queue = require("HudController.hud.call_queue")
local data = require("HudController.data.init")
local factory = require("HudController.hud.factory")
---@module "HudController.hud.hook.init"
local hook = require("HudController.util.misc.init").lazy_require("HudController.hud.hook.init")

local ace_map = data.ace.map
local mod_enum = data.mod.enum

---@class HudElements
local this = {
    by_hudid = {},
    by_guiid = {},
}

---@param element HudBaseConfig
function this.get_element_profile(element)
    if element.current_profile == mod_enum.elem_profile.DEFAULT then
        return element
    end

    return element.profile[tostring(element.current_profile)]
end

---@param element HudBaseConfig
function this.update_element_profile(element)
    local hudbase = this.by_hudid[element.hud_id]
    if hudbase then
        call_queue.queue_func(hudbase.hud_id, function()
            hudbase:reset()
        end)
    end

    hook.hook_hud(element.hud_id, element.name_key)

    this.by_hudid[element.hud_id] = factory.new_elem(element)
    for _, gui_id in pairs(ace_map.hudid_to_guiid[element.hud_id]) do
        this.by_guiid[gui_id] = this.by_hudid[element.hud_id]
    end
end

---@param element HudBaseConfig
function this.add_element(element)
    element = this.get_element_profile(element)
    this.by_hudid[element.hud_id] = factory.new_elem(element)

    hook.hook_hud(element.hud_id, element.name_key)

    for _, gui_id in pairs(ace_map.hudid_to_guiid[element.hud_id]) do
        this.by_guiid[gui_id] = this.by_hudid[element.hud_id]
    end
end

---@param elements table<string, HudBaseConfig>
function this.update_elements(elements)
    for _, elem in pairs(elements) do
        this.update_element(elem)
    end

    this.cleanup(elements)
end

---@param elem HudBaseConfig
function this.update_element(elem)
    --[[
        hiding main hud elements happens over a few frames.
        when an element is hidden in the current profile and hidden in the new profile,
        resetting the element to be visible again makes it flicker for a frame.
        this just makes the reset skip the hide setting, not exactly great but better than nothing.
    ]]

    if ace_map.hudid_to_can_hide[elem.hud_id] then
        local old_elem = this.by_hudid[elem.hud_id]
        if old_elem and elem.hide and old_elem.hide then
            old_elem.hide = false
        end
    end

    local hudbase = this.by_hudid[elem.hud_id]
    if hudbase then
        call_queue.queue_func(elem.hud_id, function()
            hudbase:reset()
        end)
    end

    this.add_element(elem)
end

---@param hud_id app.GUIHudDef.TYPE
function this.remove_element(hud_id)
    local hudbase = this.by_hudid[hud_id]
    if hudbase then
        hudbase:reset()
        this.by_hudid[hud_id] = nil

        for _, gui_id in pairs(ace_map.hudid_to_guiid[hud_id]) do
            this.by_guiid[gui_id] = this.by_hudid[hud_id]
        end
    end
end

---@param elements table<string, HudBaseConfig>
function this.cleanup(elements)
    ---@type table<app.GUIHudDef.TYPE, boolean>
    local ok_hudid = {}
    ---@type table<app.GUIID.ID, boolean>
    local ok_guiid = {}

    for _, elem in pairs(elements) do
        ok_hudid[elem.hud_id] = true

        for _, gui_id in pairs(ace_map.hudid_to_guiid[elem.hud_id]) do
            ok_guiid[gui_id] = true
        end
    end

    for id, _ in pairs(this.by_guiid) do
        if not ok_guiid[id] then
            this.by_guiid[id] = nil
        end
    end

    for id, _ in pairs(this.by_hudid) do
        if not ok_hudid[id] then
            this.by_hudid[id] = nil
        end
    end
end

function this.reset_elements()
    for _, elem in pairs(this.by_hudid) do
        elem:reset()
    end
end

function this.clear()
    this.by_hudid = {}
    this.by_guiid = {}
end

return this
