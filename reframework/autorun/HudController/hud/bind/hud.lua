---@class (exact) HudBindManager : BindManager
---@field binds HudBindKey[]
---@field is_collision fun(self: HudBindManager, bind: BindBase): boolean, HudBindKey?

---@class (exact) HudBindBase : BindBase
---@field name string
---@field device string
---@field key integer

---@class (exact) HudBindPad : HudBindBase, BindPad
---@field bit integer

---@class (exact) HudBindKb : HudBindBase, BindKb
---@field keys integer[]

---@class (exact) HudBindKey : HudBindBase, Bind
---@field key integer

local config = require("HudController.config")
local game_bind = require("HudController.util.game.bind")
local util_table = require("HudController.util.misc.table")
---@module "HudController.hud"
local hud

---@class HudBindManager
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = game_bind.manager })

---@param bind HudBindBase
local function action(bind)
    if not hud then
        hud = require("HudController.hud")
    end

    local config_mod = config.current.mod
    local hud_config = hud.operations.get_hud_by_key(bind.key)
    hud.request_hud(hud_config)
    config_mod.combo_hud = util_table.index(config_mod.hud, function(o)
        return o.key == bind.key
    end) --[[@as integer]]
    config.save_global()
end

---@return HudBindManager
function this:new()
    local o = game_bind.manager.new(self)
    setmetatable(o, self)
    ---@cast o HudBindManager
    return o
end

---@param binds HudBindBase[]
function this:load(binds)
    local res = util_table.deep_copy(binds) --[=[@as HudBindKey[]]=]
    for _, bind in pairs(res) do
        bind.action = function()
            action(bind)
        end
    end

    game_bind.manager.load(self, res)
end

---@param bind HudBindBase
---@return boolean, HudBindBase?
function this:register(bind)
    ---@cast bind HudBindKey
    bind.action = function()
        action(bind)
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return game_bind.manager.register(self, bind)
end

return this
