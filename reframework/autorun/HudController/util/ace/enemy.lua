local cache = require("HudController.util.misc.cache")
local s = require("HudController.util.ref.singletons")
local util_game = require("HudController.util.game.init")
local util_misc = require("HudController.util.misc.init")

---@class EnemyUtil
local this = {}

---@param em_ctx app.cEnemyContext
---@return boolean
function this.is_paintballed_ctx(em_ctx)
    local arr = em_ctx.PaintHitInfoIndex
    local any = false

    if arr then
        util_game.do_something(arr, function(_, _, value)
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
        util_game.do_something(arr, function(_, _, value)
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

---@param em_ctx app.cEnemyContext
---@return app.EnemyCharacter
function this.ctx_to_char(em_ctx)
    local browser = em_ctx:get_Browser()
    return browser._Character
end

---@param char_base app.EnemyCharacter
---@return ace.cSafeContinueFlagGroup?
function this.get_flags(char_base)
    local ctx = this.get_ctx(char_base)

    if not ctx then
        return
    end

    return ctx:get_ContinueFlag()
end

---@param char_base app.EnemyCharacter
---@return boolean
function this.destroy_em_char(char_base)
    local ret = false

    util_misc.try(function()
        local game_object = char_base:get_GameObject()
        if not game_object then
            return
        end

        game_object:destroy(game_object)
        ret = true
    end)

    return ret
end

---@param em_ctx_holder app.cEnemyContextHolder
---@return boolean
function this.destroy_em_ctx(em_ctx_holder)
    local ret = false

    util_misc.try(function()
        local handle = em_ctx_holder:get_Handle()
        s.get("app.ContextManager"):requestRemoveContext_Enemy(handle)
        ret = true
    end)

    return ret
end

---@param char_base app.EnemyCharacter
---@param flag app.EnemyDef.CONTINUE_FLAG
---@param value boolean
function this.set_continue_flag(char_base, flag, value)
    local flags = this.get_flags(char_base)

    if not flags then
        return
    end

    if value then
        flags:on(flag)
    else
        flags:off(flag)
    end
end

---@param char_base app.EnemyCharacter
---@return boolean?
function this.is_small(char_base)
    local ctx = this.get_ctx(char_base)
    if not ctx then
        return
    end

    return ctx:get_IsZako()
end

---@param char_base app.EnemyCharacter
---@return boolean?
function this.is_animal(char_base)
    local ctx = this.get_ctx(char_base)
    if not ctx then
        return
    end

    return ctx:get_IsAnimal()
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
    ---@type app.EnemyCharacter?
    local ret
    util_misc.try(function()
        ret = util_game.get_component(game_object, "app.EnemyCharacter")
    end)
    return ret
end

this.get_char_base = cache.memoize(this.get_char_base, function(cached_value)
    ---@cast cached_value app.EnemyCharacter
    return cached_value:get_Valid()
end)
this.get_ctx = cache.memoize(this.get_ctx)
this.is_boss = cache.memoize(this.is_boss)
this.get_flags = cache.memoize(this.get_flags)
this.is_small = cache.memoize(this.is_small)
this.is_animal = cache.memoize(this.is_animal)
this.ctx_to_char = cache.memoize(this.ctx_to_char)

return this
