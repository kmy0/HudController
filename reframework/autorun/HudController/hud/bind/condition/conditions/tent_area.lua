local ace_player = require("HudController.util.ace.player")
local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")
local e = require("HudController.util.game.enum")
local frame_cache = require("HudController.util.misc.frame_cache")
local s = require("HudController.util.ref.singletons")
local util_game = require("HudController.util.game.init")

---@class TentAreaCondition : ConditionBase
---@field pos_cache table<app.Gm100_003, Vector3f>
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@return System.Array<app.Gm100_003>
local function get_temp_tents()
    return s.get("app.GimmickManager")
        :findGimmick_ID(e.get_noexact("app.GimmickDef.ID").GM100_003_00) --[[@as System.Array<app.Gm100_003>]]
end

---@return TentAreaCondition
function this:new()
    local o = condition_base.new(
        self,
        "_TENT_AREA",
        config.lang.make_placeholder("menu.bind.condition.condition_tent_area")
    )
    setmetatable(o, self)
    ---@cast o TentAreaCondition

    o.pos_cache = {}
    return o
end

---@return boolean
function this:update()
    local master_char = ace_player.get_master_char()
    if not master_char or master_char:get_IsInTent() then
        return true
    end

    local ctx = master_char:get_HunterContext()
    local tent_info = ctx:get_TentAreaInfo()

    if tent_info:get_IsInTentArea() then
        return true
    end

    local ret = false
    local temp_tents = get_temp_tents()

    if temp_tents then
        local player_pos = ace_player.get_master_pos()
        local min_dist = 15.0
        util_game.do_something(temp_tents, function(_, _, value)
            local pos = self.pos_cache[value]
            if not pos then
                local go = value:get_GameObject()
                local transform = go:get_Transform()
                pos = transform:get_Position()
                self.pos_cache[value] = pos
            end

            local vec = player_pos - pos
            if vec:length() <= min_dist then
                ret = true
                return false
            end
        end)
    end

    return ret
end

get_temp_tents = frame_cache.memoize(get_temp_tents, { max_frame = 120 })

return this
