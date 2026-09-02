---@class (exact) FaderGroup
---@field faders table<app.GUIHudDef.TYPE, Fader>

---@class FaderGroup
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param faders table<app.GUIHudDef.TYPE, Fader>
---@return FaderGroup
function this:new(faders)
    local o = {
        faders = faders,
    }

    setmetatable(o, self)

    ---@cast o FaderGroup
    return o
end

---@return boolean
function this:update()
    local has_synchronized = false
    local all_synchronized_waiting = true

    for _, f in pairs(self.faders) do
        if not f:is_finished() then
            f:update_stage()

            if f:is_waiting() then
                if f.synchronized then
                    has_synchronized = true
                else
                    f:advance()
                end
            end
        end

        if f.synchronized and not f:is_finished() then
            has_synchronized = true

            if not f:is_waiting() then
                all_synchronized_waiting = false
            end
        end
    end

    if has_synchronized and all_synchronized_waiting then
        for _, f in pairs(self.faders) do
            if f.synchronized and f:is_waiting() then
                f:advance()
            end
        end
    end

    return self:is_finished()
end

---@return boolean
function this:is_finished()
    for _, f in pairs(self.faders) do
        if not f:is_finished() then
            return false
        end
    end

    return true
end

---@param mod number
function this:accelerate(mod)
    for _, f in pairs(self.faders) do
        if not f:is_finished() then
            f:accelerate(mod)
        end
    end
end

---@param hud_id app.GUIHudDef.TYPE
---@return boolean
function this:is_active(hud_id)
    local f = self.faders[hud_id]
    return f ~= nil and not f:is_finished()
end

---@param hud_id app.GUIHudDef.TYPE
---@return Fader?
function this:get_fader(hud_id)
    return self.faders[hud_id]
end

return this
