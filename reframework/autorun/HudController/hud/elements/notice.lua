---@class (exact) Notice : HudBase
---@field get_config fun(): NoticeConfig
---@field system_log table<string, boolean>
---@field lobby_log table<string, boolean>
---@field enemy_log table<string, boolean>
---@field camp_log table<string, boolean>
---@field chat_log table<string, boolean>

---@class (exact) NoticeConfig : HudBaseConfig
---@field system_log table<string, boolean>
---@field lobby_log table<string, boolean>
---@field enemy_log table<string, boolean>
---@field camp_log table<string, boolean>
---@field chat_log table<string, boolean>

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class Notice
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args NoticeConfig
---@return Notice
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Notice

    o.system_log = args.system_log
    o.lobby_log = args.lobby_log
    o.enemy_log = args.enemy_log
    o.camp_log = args.camp_log
    o.chat_log = args.chat_log

    return o
end

---@param name_key string
---@param hide boolean
function this:set_system_log(name_key, hide)
    self.system_log[name_key] = hide
end

---@param name_key string
---@param hide boolean
function this:set_lobby_log(name_key, hide)
    self.lobby_log[name_key] = hide
end

---@param name_key string
---@param hide boolean
function this:set_enemy_log(name_key, hide)
    self.enemy_log[name_key] = hide
end

---@param name_key string
---@param hide boolean
function this:set_camp_log(name_key, hide)
    self.camp_log[name_key] = hide
end

---@param name_key string
---@param hide boolean
function this:set_chat_log(name_key, hide)
    self.chat_log[name_key] = hide
end

---@return NoticeConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "NOTICE"), "NOTICE") --[[@as NoticeConfig]]

    base.hud_type = mod.enum.hud_type.NOTICE
    base.system_log = { ALL = false }
    base.lobby_log = {}
    base.chat_log = { ALL = false }
    base.enemy_log = {}
    base.camp_log = {}

    for _, name in pairs(ace_enum.system_msg) do
        base.system_log[name] = false
    end

    for _, name in pairs(ace_enum.send_target) do
        base.lobby_log[name] = false
    end

    for _, name in pairs(ace_enum.enemy_log) do
        base.enemy_log[name] = false
    end

    for _, name in pairs(ace_enum.camp_log) do
        base.camp_log[name] = false
    end

    for _, name in pairs(ace_enum.chat_log) do
        base.chat_log[name] = false
    end

    return base
end

return this
