---@alias PlayObject via.gui.Control | via.gui.Text | via.gui.Rect | via.gui.Material | via.gui.Scale9Grid | via.gui.TextureSet
---@alias ControlChild via.gui.Text | via.gui.Rect | via.gui.Material | via.gui.Scale9Grid | via.gui.TextureSet

local util_table = require("HudController.util.misc.table")

local this = {
    control = require("HudController.hud.play_object.control"),
    child = require("HudController.hud.play_object.child"),
}

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

return this
