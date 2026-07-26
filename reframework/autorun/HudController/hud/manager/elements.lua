---@class HudElements
---@field by_hudid table<app.GUIHudDef.TYPE, HudBase>
---@field by_guiid table<app.GUIID.ID, HudBase>

local call_queue = require("HudController.hud.call_queue")
local data = require("HudController.data.init")
local factory = require("HudController.hud.factory")
---@module "HudController.hud.hook.init"
local hook = require("HudController.util.misc.init").lazy_require("HudController.hud.hook.init")

local ace_map = data.ace.map

---@class HudElements
local this = {
    by_hudid = {},
    by_guiid = {},
}

---@param element HudBaseConfig
function this.add_element(element)
    this.by_hudid[element.hud_id] = factory.new_elem(element)

    hook.hook_hud(element.hud_id, element.name_key)

    for _, gui_id in pairs(ace_map.hudid_to_guiid[element.hud_id]) do
        this.by_guiid[gui_id] = this.by_hudid[element.hud_id]
    end
end

---@param elements table<string, HudBaseConfig>
function this.update_elements(elements)
    this.by_guiid = {}

    --[[
        hiding main hud elements happens over a few frames.
        when an element is hidden in the current profile and hidden in the new profile,
        resetting the element to be visible again makes it flicker for a frame.
        this just makes the reset skip the hide setting, not exactly great but better than nothing.
    ]]

    for _, elem in pairs(elements) do
        if ace_map.hudid_to_can_hide[elem.hud_id] then
            local old_elem = this.by_hudid[elem.hud_id]
            if old_elem and elem.hide and old_elem.hide then
                old_elem.hide = false
            end
        end
    end

    for _, elem in pairs(this.by_hudid) do
        call_queue.queue_func(elem.hud_id, function()
            elem:reset()
        end)
    end

    this.by_hudid = {}
    for _, elem in pairs(elements) do
        this.add_element(elem)
    end
end

---@param elements table<string, HudBaseConfig>
function this.update_elements_partial(elements)
    for _, elem in pairs(this.by_hudid) do
        if not elements[elem.name_key] or (not elem.hide and elem.opacity ~= 0) then
            call_queue.queue_func(elem.hud_id, function()
                elem:reset()

                if not elements[elem.name_key] then
                    elem.opacity = 1
                end
            end)
        end
    end

    for _, elem in pairs(elements) do
        if
            (
                not elem.hide
                and (not elem.enabled_opacity or elem.opacity > 0)
                and not elem.disable_fade_opacity
            ) or elem.disable_fade
        then
            this.add_element(elem)
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
