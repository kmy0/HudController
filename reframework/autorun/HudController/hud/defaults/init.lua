---@class (exact) DefaultsState
---@field do_dump boolean

local this = {
    option = require("HudController.hud.defaults.option"),
    play_object = require("HudController.hud.defaults.play_object"),
}
---@type DefaultsState
local state = {
    do_dump = true,
}

---@param func fun()
function this.with_dump(func)
    state.do_dump = false
    func()
    state.do_dump = true
    this.dump()
end

function this.dump()
    this.option.dump()
    this.play_object.dump()
end

---@return boolean
function this.init()
    this.play_object.init(state)
    this.option.init(state)
    return true
end

return this
