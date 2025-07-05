---@class BindManager
---@field enum BindEnum
---@field binds Bind[]
---@field hold table<Bind, boolean>
---@field on_release_callbacks table<string, fun()>
---@field pause boolean

---@class (exact) BindBase
---@field name string
---@field device string

---@class (exact) BindPad : BindBase
---@field bit integer

---@class (exact) BindKb : BindBase
---@field keys integer[]

---@class (exact) Bind : BindKb, BindPad
---@field action fun()

local ace_misc = require("HudController.util.ace.misc")
local enum = require("HudController.util.game.bind.enum")
local singletons = require("HudController.util.ref.singletons")
local util_table = require("HudController.util.misc.table")

---@class BindManager
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@return BindManager
function this:new()
    local o = { binds = {}, hold = {}, pause = false, on_release_callbacks = {} }
    setmetatable(o, self)
    ---@cast o BindManager
    return o
end

---@param binds Bind[]
function this:load(binds)
    self.binds = binds
end

---@param bind Bind
---@return boolean, Bind?
function this:register(bind)
    if self:is_valid(bind) then
        local is_collision, col = self:is_collision(bind)
        if is_collision then
            return false, col
        end
        table.insert(self.binds, bind)
        return true
    end

    return false
end

---@param bind BindBase
---@return boolean, Bind?
function this:is_collision(bind)
    for _, b in pairs(self.binds) do
        if b.name == bind.name then
            return true, b
        end
    end

    return false
end

---@param bind Bind
function this:unregister(bind)
    self.binds = util_table.remove(self.binds, function(t, i, j)
        return self.binds[i].name ~= bind.name
    end)
end

---@return BindKb | BindPad[]
function this:get_base_binds()
    local ret = util_table.deep_copy(self.binds)
    util_table.do_something(ret, function(t, key, value)
        value.action = nil
    end)
    return ret
end

---@param bind BindPad | BindKb
---@return boolean
function this:is_valid(bind)
    if bind.device == "PAD" then
        return bind.bit ~= 0
    elseif bind.device == "KEYBOARD" then
        return not util_table.empty(bind.keys)
    end

    return false
end

---@param bind Bind?
---@return boolean
function this:is_held(bind)
    if bind then
        return self.hold[bind]
    end

    return util_table.any(self.hold, function(key, value)
        return value
    end)
end

---@return Bind[]
function this:get_held()
    return util_table.keys(util_table.filter(self.hold, function(key, value)
        return value
    end))
end

---@param bind Bind | Bind[]
---@param callback fun()
function this:register_on_release_callback(bind, callback)
    if type(bind) ~= "table" then
        bind = { bind }
    end

    for _, b in pairs(bind) do
        self.on_release_callbacks[b.name] = callback
    end
end

---@return boolean
function this:monitor()
    if self.pause or util_table.empty(self.binds) then
        return false
    end

    local device = enum.input_device[singletons.get("app.GUIManager"):get_LastInputDeviceIgnoreMouseMove()]
    ---@type ace.cMouseKeyboardInfo
    local kb
    ---@type integer
    local bit
    local ret = false

    if device == "PAD" then
        local pad = ace_misc.get_pad()
        bit = pad:get_KeyOn()
    elseif device == "KEYBOARD" then
        kb = ace_misc.get_kb()
    end

    for _, bind in pairs(self.binds) do
        local function do_action()
            if not self.hold[bind] then
                bind.action()
                ret = true
            end

            self.hold[bind] = true
        end

        if bit and bind.device == "PAD" then
            if bit & bind.bit == bind.bit then
                do_action()
                goto continue
            end
        elseif kb and bind.device == "KEYBOARD" then
            if util_table.all(bind.keys, function(o)
                return kb:isOn(o)
            end) then
                do_action()
                goto continue
            end
        end

        if self.on_release_callbacks[bind.name] then
            self.on_release_callbacks[bind.name]()
            self.on_release_callbacks[bind.name] = nil
        end

        self.hold[bind] = false
        ::continue::
    end

    return ret
end

return this
