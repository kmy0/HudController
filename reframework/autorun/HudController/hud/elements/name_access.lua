---@class (exact) NameAccess : HudBase
---@field npc_draw_distance number
---@field GUI020001 app.GUI020001
---@field get_config fun(): NameAccessConfig
---@field object_category table<string, boolean>

---@class (exact) NameAccessConfig : HudBaseConfig
---@field object_category table<string, boolean>
---@field npc_draw_distance number

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local play_object = require("HudController.hud.play_object")
local util_game = require("HudController.util.game")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class NameAccess
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args NameAccessConfig
---@return NameAccess
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o NameAccess

    o.object_category = args.object_category
    o.npc_draw_distance = args.npc_draw_distance
    return o
end

---@param name_key string
---@param hide boolean
function this:set_object_category(name_key, hide)
    self.object_category[name_key] = hide
end

---@param val number
function this:set_npc_draw_distance(val)
    self.npc_draw_distance = val
end

---@return {ctrl: via.gui.Control, hud_base: app.GUIHudBase, gui_id: app.GUIID.ID}[]
function this:get_all_ctrl()
    ---@type {ctrl: via.gui.Control, hud_base: app.GUIHudBase, gui_id: app.GUIID.ID}[]
    local ret = {}
    local hudbase = self:get_GUI020001()
    local disp_ctrl = hudbase._DisplayControl
    local ctrl = disp_ctrl._TargetControl
    local gui_id = hudbase:get_ID()
    local pnl = play_object.control.all(ctrl, "PNL_Pat00", "PNL_Pat", true) --[=[@as via.gui.Control[]]=]

    for _, name_pnl in pairs(pnl) do
        table.insert(ret, { ctrl = name_pnl, hud_base = hudbase, gui_id = gui_id })
    end

    return ret
end

---@return app.GUI020001
function this:get_GUI020001()
    if not self.GUI020001 then
        self.GUI020001 = util_game.get_component_any("app.GUI020001") --[[@as app.GUI020001]]
    end

    return self.GUI020001
end

---@return NameAccessConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "NAME_ACCESSIBLE"), "NAME_ACCESSIBLE") --[[@as NameAccessConfig]]

    -- FIXME: offset is used for icon position on screen
    base.enabled_offset = nil
    base.hud_type = mod.enum.hud_type.NAME_ACCESS
    base.object_category = { ALL = false }
    base.npc_draw_distance = 0

    for _, name in pairs(ace_enum.object_access_category) do
        base.object_category[name] = false
    end

    return base
end

return this
