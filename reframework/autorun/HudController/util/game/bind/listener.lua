---@class (exact) BindListener
---@field protected _current_keys BindPad | BindKb
---@field protected _last_device string

local ace_misc = require("HudController.util.ace.misc")
local enum = require("HudController.util.game.bind.enum")
local s = require("HudController.util.ref.singletons")
local util_table = require("HudController.util.misc.table")

---@class BindListener
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

function this:new()
    local o = { _current_keys = {}, _last_device = "PAD" }
    setmetatable(o, self)
    ---@cast o BindListener
    return o
end

function this:clear()
    if self._current_keys.device == "PAD" then
        self._current_keys.bit = 0
    elseif self._current_keys.device == "KEYBOARD" then
        self._current_keys.keys = {}
    end

    self._current_keys.name = ""
end

---@return BindPad | BindKb
function this:listen()
    local device = enum.input_device[s.get("app.GUIManager"):get_LastInputDeviceIgnoreMouseMove()]
    if device == "KEYBOARD" or device == "PAD" then
        self._last_device = device
    end

    if self._last_device == "KEYBOARD" then
        if not self._current_keys or self._current_keys.device ~= "KEYBOARD" then
            self._current_keys = {
                keys = {},
                name = "",
                device = "KEYBOARD",
            }
        end

        local kb = ace_misc.get_kb()
        local btn_names = {}
        local sorted = util_table.sort(util_table.keys(enum.kb_btn))

        if self._current_keys.name ~= "" then
            table.insert(btn_names, self._current_keys.name)
        end

        for i = 1, #sorted do
            local index = sorted[i]
            local name = enum.kb_btn[index]

            if
                not name:match("CLICK")
                and kb:isOn(index)
                and not util_table.contains(self._current_keys.keys, index)
            then
                table.insert(self._current_keys.keys, index)
                table.insert(btn_names, enum.kb_btn[index])
            end
        end

        table.sort(self._current_keys.keys)
        self._current_keys.name = table.concat(btn_names, " + ")
        return self._current_keys
    end

    if not self._current_keys or self._current_keys.device ~= "PAD" then
        self._current_keys = {
            bit = 0,
            name = "",
            device = "PAD",
        }
    end

    local pad = ace_misc.get_pad()
    local btn = pad:get_KeyOn()

    if btn == 0 then
        return self._current_keys
    end

    local btn_names = {}
    local sorted = util_table.sort(util_table.keys(enum.pad_btn))

    if self._current_keys.name ~= "" then
        table.insert(btn_names, self._current_keys.name)
    end

    for i = 1, #sorted do
        local bit = sorted[i]
        if bit & self._current_keys.bit ~= bit and btn & bit == bit then
            table.insert(btn_names, enum.pad_btn[bit])
            self._current_keys.bit = self._current_keys.bit | bit
        end
    end

    self._current_keys.name = table.concat(btn_names, " + ")
    return self._current_keys
end

return this
