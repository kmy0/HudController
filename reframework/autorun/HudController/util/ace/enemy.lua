local cache = require("HudController.util.misc.cache")
local s = require("HudController.util.ref.singletons")
---@class MethodUtil
local m = require("HudController.util.ref.methods")
local util_game = require("HudController.util.game")
local util_misc = require("HudController.util.misc")
local util_ref = require("HudController.util.ref")

local this = {}

---@param em_ctx app.cEnemyContext
---@return boolean
function this.is_paintballed_ctx(em_ctx)
    local arr = em_ctx.PaintHitInfoIndex
    local any = false

    if arr then
        util_game.do_something(arr, function(system_array, index, value)
            if value.enable then
                any = true
                return false
            end
        end)
    end

    return any
end

---@param char_base app.EnemyCharacter
---@return boolean
function this.is_paintballed_char(char_base)
    local em_ctx = this.get_ctx(char_base)
    if not em_ctx then
        return false
    end

    local arr = em_ctx.PaintHitInfoIndex
    local any = false

    if arr then
        util_game.do_something(arr, function(system_array, index, value)
            if value.enable then
                any = true
                return false
            end
        end)
    end

    return any
end

---@param char_base app.EnemyCharacter
---@return boolean?
function this.is_boss(char_base)
    local ctx = this.get_ctx(char_base)
    if not ctx then
        return
    end

    return ctx:get_IsBoss()
end

---@param char_base app.EnemyCharacter
---@return app.cEnemyContext?
function this.get_ctx(char_base)
    local holder = char_base._Context
    if not holder then
        return
    end

    return holder:get_Em()
end

---@param game_object via.GameObject
---@return app.EnemyCharacter?
function this.get_char_base(game_object)
    return util_game.get_component(game_object, "app.EnemyCharacter")
end

this.get_char_base = cache.memoize(this.get_char_base, function(cached_value)
    ---@cast cached_value app.EnemyCharacter
    return cached_value:get_Valid()
end)
this.get_ctx = cache.memoize(this.get_ctx)
this.is_boss = cache.memoize(this.is_boss)

return this
