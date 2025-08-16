local config = require("HudController.config")
local m = require("HudController.util.ref.methods")
local util_misc = require("HudController.util.misc")

local this = {
    ---@type table<string, integer>
    by_opt = {},
    boot_time = util_misc.get_boot_time(),
    ---@class DefaultsState
    state = {},
}

---@param opt app.Option.ID
---@return integer?
function this.get_default(opt)
    return this.by_opt[tostring(opt)]
end

---@param state DefaultsState
---@return boolean
function this.init(state)
    this.state = state

    local j = json.load_file(config.option_default_path)
    if j and math.abs(this.boot_time - j.boot_time) < 5 then
        this.by_opt = j.cache or {}
    else
        json.dump_file(config.option_default_path, { boot_time = this.boot_time, cache = {} })
    end
    return true
end

function this.dump()
    json.dump_file(config.option_default_path, { boot_time = this.boot_time, cache = this.by_opt })
end

---@param opt app.Option.ID
function this.check(opt)
    local key = tostring(opt)
    if this.by_opt[key] then
        return
    end

    this.by_opt[key] = m.getOptionValue(opt)
    if this.state.do_dump then
        this.dump()
    end
end

return this
