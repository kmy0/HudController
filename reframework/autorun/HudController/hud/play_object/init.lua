---@alias PlayObject via.gui.Control | via.gui.Text | via.gui.Rect | via.gui.Material | via.gui.Scale9Grid
---@alias ControlChild via.gui.Text | via.gui.Rect | via.gui.Material | via.gui.Scale9Grid

local lru = require("HudController.util.misc.lru")
local util_game = require("HudController.util.game")
local util_table = require("HudController.util.misc.table")

local this = {
    control = require("HudController.hud.play_object.control"),
    child = require("HudController.hud.play_object.child"),
    default = require("HudController.hud.play_object.default"),
}

---@param item PlayObject | PlayObject[]
---@return boolean
local function is_ok(item)
    if not item then
        return false
    end

    if type(item) == "table" then
        return util_table.all(item, function(o)
            return not util_game.is_only_my_ref(o)
        end)
    end
    return not util_game.is_only_my_ref(item)
end

---@protected
---@param func fun(ctrl: via.gui.Control, ...): PlayObject[] | PlayObject?
---@param ctrl via.gui.Control
---@param args table<integer, ...[]>
---@return PlayObject[]
function this.iter_args(func, ctrl, args)
    ---@type PlayObject[]
    local ret = {}

    for _, a in pairs(args) do
        local res = func(ctrl, table.unpack(a))
        if not res then
            goto continue
        end

        if type(res) == "table" then
            util_table.array_merge_t(ret, res)
        else
            table.insert(ret, res)
        end
        ::continue::
    end

    return ret
end

this.control.get = lru.memoize(this.control.get, 1000, is_ok)
this.control.all = lru.memoize(this.control.all, 1000, is_ok)
this.control.from_func = lru.memoize(this.control.from_func, 1000, is_ok)
this.control.top = lru.memoize(this.control.top, 1000, is_ok)
this.control.get_parent = lru.memoize(this.control.get_parent, 1000, is_ok)
this.child.get = lru.memoize(this.child.get, 1000, is_ok)

return this
