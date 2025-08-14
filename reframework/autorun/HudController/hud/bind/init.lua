---@class ModBindManager
---@field option_manager OptionBindManager
---@field hud_manager HudBindManager

---@class (exact) BindCollision
---@field manager_type BindManagerType
---@field bind OptionBindKey | HudBindKey

---@alias ModBind HudBindKb | HudBindPad | OptionBindKb | OptionBindPad

local config = require("HudController.config")
local hud_bind_manager = require("HudController.hud.bind.hud")
local option_bind_manager = require("HudController.hud.bind.option")

---@class ModBindManager
local this = {}

---@enum BindManagerType
this.manager_type = {
    OPTION = 1,
    HUD = 2,
}

---@param manager_type BindManagerType
---@param bind BindBase
---@return boolean, BindCollision?
function this.register(manager_type, bind)
    local is_col, col = this.is_collision(bind)
    if is_col and col then
        return is_col, col
    end

    local ret = false
    if manager_type == this.manager_type.OPTION then
        ---@diagnostic disable-next-line: param-type-mismatch
        ret, _ = this.option_manager:register(bind)
    else
        ---@diagnostic disable-next-line: param-type-mismatch
        ret, _ = this.hud_manager:register(bind)
    end

    return ret
end

---@param manager_type BindManagerType
---@param bind Bind
function this.unregister(manager_type, bind)
    if manager_type == this.manager_type.OPTION then
        this.option_manager:unregister(bind)
    else
        this.hud_manager:unregister(bind)
    end
end

---@param manager_type BindManagerType
---@return ModBind[]
function this.get_base_binds(manager_type)
    if manager_type == this.manager_type.OPTION then
        return this.option_manager:get_base_binds()
    else
        return this.hud_manager:get_base_binds()
    end
end

---@param bind BindBase
---@return boolean, BindCollision?
function this.is_collision(bind)
    local is_col, col = this.option_manager:is_collision(bind)
    if is_col and col then
        return is_col, { manager_type = this.manager_type.OPTION, bind = col }
    end

    ---@diagnostic disable-next-line: cast-local-type
    is_col, col = this.hud_manager:is_collision(bind)
    if is_col and col then
        return is_col, { manager_type = this.manager_type.HUD, bind = col }
    end

    return false
end

---@param bind ModBind
function this.is_valid(bind)
    return this.hud_manager:is_valid(bind)
end

---@param pause boolean
function this.set_pause(pause)
    this.option_manager.pause = pause
    this.hud_manager.pause = pause
end

---@return boolean
function this.init()
    local bind_key = config.current.mod.bind.key
    this.option_manager = option_bind_manager:new()
    this.hud_manager = hud_bind_manager:new()

    this.option_manager:load(bind_key.option)
    this.hud_manager:load(bind_key.hud)
    return true
end

return this
