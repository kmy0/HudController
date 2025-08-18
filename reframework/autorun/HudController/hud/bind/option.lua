---@class (exact) OptionBindManager : BindManager
---@field is_collision fun(self: OptionBindManager, bind: BindBase): boolean, OptionBindKey?

---@class (exact) OptionBindBase : BindBase
---@field name string
---@field device string
---@field key string

---@class (exact) OptionBindPad : OptionBindBase, BindPad
---@field bit integer

---@class (exact) OptionBindKb : OptionBindBase, BindKb
---@field keys integer[]

---@class (exact) OptionBindKey : OptionBindBase, Bind
---@field key string

local ace_misc = require("HudController.util.ace.misc")
local config = require("HudController.config")
local data = require("HudController.data")
local game_bind = require("HudController.util.game.bind")
local util_table = require("HudController.util.misc.table")
---@module "HudController.hud"
local hud

local mod = data.mod

local function action(bind)
    if not hud then
        hud = require("HudController.hud")
    end

    local val = hud.overwrite_hud_option(bind.key)
    if val == nil then
        return
    end

    if config.current.mod.enable_notification then
        ace_misc.send_message(
            string.format(
                "%s %s %s",
                config.lang:tr("hud." .. mod.map.hud_options[bind.key]),
                config.lang:tr("misc.text_override_notifcation_message"),
                val
            )
        )
    end
end

---@class OptionBindManager
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = game_bind.manager })

---@return OptionBindManager
function this:new()
    local o = game_bind.manager.new(self)
    setmetatable(o, self)
    ---@cast o OptionBindManager
    return o
end

---@param binds OptionBindBase[]
function this:load(binds)
    local res = util_table.deep_copy(binds) --[=[@as OptionBindKey[]]=]
    for _, bind in pairs(res) do
        bind.action = function()
            action(bind)
        end
    end

    game_bind.manager.load(self, res)
end

---@param bind OptionBindBase
---@return boolean, OptionBindBase?
function this:register(bind)
    ---@cast bind OptionBindKey
    bind.action = function()
        action(bind)
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return game_bind.manager.register(self, bind)
end

return this
