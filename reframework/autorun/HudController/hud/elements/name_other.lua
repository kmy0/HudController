---@class (exact) NameOther : HudBase
---@field get_config fun(): NameOtherConfig
---@field nameplate_type table<string, integer>
---@field pl_draw_distance number
---@field pet_draw_distance number
---@field GUI020016 app.GUI020016?

---@class (exact) NameOtherConfig : HudBaseConfig
---@field nameplate_type table<string, integer>
---@field pl_draw_distance number
---@field pet_draw_distance number

local cache = require("HudController.util.misc.cache")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local hud_base = require("HudController.hud.def.hud_base")
local play_object = require("HudController.hud.play_object.init")
local util_game = require("HudController.util.game.init")
local util_mod = require("HudController.util.mod.init")
local play_object_defaults = require("HudController.hud.defaults.init").play_object

local mod = data.mod

---@class NameOther
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args NameOtherConfig
---@return NameOther
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o NameOther

    o.nameplate_type = args.nameplate_type
    o.pl_draw_distance = args.pl_draw_distance
    o.pet_draw_distance = args.pet_draw_distance
    o.get_all_ctrl = cache.memoize(o.get_all_ctrl)
    return o
end

---@param val number
function this:set_pl_draw_distance(val)
    self.pl_draw_distance = val
end

---@param val number
function this:set_pet_draw_distance(val)
    self.pet_draw_distance = val
end

---@param name_key string
---@param order integer
function this:set_nameplate_type(name_key, order)
    self.nameplate_type[name_key] = order
end

---@return {ctrl: via.gui.Control, hud_base: app.GUIHudBase, gui_id: app.GUIID.ID}[]
function this:get_all_ctrl()
    ---@type {ctrl: via.gui.Control, hud_base: app.GUIHudBase, gui_id: app.GUIID.ID}[]
    local ret = {}
    local hudbase = util_mod.get_gui_cls("app.GUI020016")

    if hudbase then
        local gui_id = hudbase:get_ID()
        local root = util_mod.get_root_window(hudbase)
        local pnls = play_object.control.all(root, {}, "PNL_All", true) --[=[@as via.gui.Control[]]=]

        for _, pnl in pairs(pnls) do
            table.insert(ret, {
                ctrl = play_object.control.get(pnl, {
                    "PNL_Scale",
                    "PNL_Pat00",
                    "PNL_NamePos",
                    "PNL_NameDisplay",
                }),
                hud_base = hudbase,
                gui_id = gui_id,
            })
        end
    end

    return ret
end

---@return app.GUI020016
function this:get_GUI020016()
    if not self.GUI020016 then
        self.GUI020016 = util_mod.get_gui_cls("app.GUI020016") --[[@as app.GUI020016]]
    end

    return self.GUI020016
end

---@protected
---@param ctrl via.gui.Control
---@return boolean
function this:_write(ctrl)
    play_object_defaults:check(ctrl)

    local ret = self:_write_hide(ctrl)
    if ret and self:any() then
        local GUI020016 = self:get_GUI020016()
        local arr = GUI020016._NameInfoList

        if arr then
            util_game.do_something(arr, function(_, _, value)
                local pnl = value:get__PanelDisplay()
                play_object_defaults:check(pnl)

                self:_write_other(pnl)
            end)
        end
    end

    return ret
end

---@return NameOtherConfig
function this.get_config()
    local base = hud_base.get_config(e.get("app.GUIHudDef.TYPE").NAME_OTHER, "NAME_OTHER") --[[@as NameOtherConfig]]

    base.hud_type = mod.enum.hud_type.NAME_OTHER
    base.nameplate_type = {}
    base.pl_draw_distance = 0
    base.pet_draw_distance = 0

    return base
end

return this
