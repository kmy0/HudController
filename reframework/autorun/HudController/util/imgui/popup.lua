---@class (exact) Popup
---@field id string
---@field fn fun(id: string, callback: fun())
---@field callback fun()

local config = require("HudController.config.init")
local util_imgui = require("HudController.util.imgui.init")

local this = {}
---@type table<string, Popup>
local active = {}
---@type table<string, Popup>
local queue = {}

---@param popup Popup
function this.request(popup)
    if active[popup.id] or queue[popup.id] then
        return
    end

    queue[popup.id] = popup
end

---@param id string
---@param callback fun()
function this.popup_yesno(id, callback)
    if
        util_imgui.popup_yesno(
            id,
            config.lang:tr("misc.text_rusure"),
            config.lang:tr("misc.text_yes"),
            config.lang:tr("misc.text_no")
        )
    then
        callback()
    end
end

function this.resolve()
    for _, popup in pairs(queue) do
        util_imgui.open_popup(popup.id, 62, 30)
        queue[popup.id] = nil
        active[popup.id] = popup
    end

    for _, popup in pairs(active) do
        popup.fn(popup.id, popup.callback)

        if not imgui.is_popup_open(popup.id) then
            active[popup.id] = nil
        end
    end
end

return this
