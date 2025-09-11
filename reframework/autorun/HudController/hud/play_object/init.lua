---@alias PlayObjectGetterFn ControlGetFn | ControlAllFn | ControlChildGetFn | ControlChildAllTypeFn

---@alias ControlGetFn [fun(ctrl: via.gui.Control, chain: string[] | string): via.gui.Control?, string[] | string]]
---@alias ControlAllFn [fun(ctrl: via.gui.Control, chain: string[] | string, target: string, lowercase: boolean?): via.gui.Control[]?, string[] | string, string, boolean?]
---@alias ControlChildGetFn [fun(ctrl: via.gui.Control, chain: string[] | string, child_name: string, child_type: string): via.gui.Control?, string[] | string, string, string]
---@alias ControlChildAllTypeFn [fun(ctrl: via.gui.Control, regex: string?,  child_type: string): via.gui.Control[], string?, string]

---@alias PlayObject via.gui.Control | via.gui.Text | via.gui.Rect | via.gui.Material | via.gui.Scale9Grid | via.gui.TextureSet
---@alias ControlChild via.gui.Text | via.gui.Rect | via.gui.Material | via.gui.Scale9Grid | via.gui.TextureSet

local config = require("HudController.config.init")
local hud_debug_log = require("HudController.hud.debug.log")
local util_table = require("HudController.util.misc.table")

local this = {
    control = require("HudController.hud.play_object.control"),
    child = require("HudController.hud.play_object.child"),
}

---@param ctrl via.gui.Control | via.gui.Control[]
---@param args PlayObjectGetterFn[]
---@return PlayObject[]
function this.iter_args(ctrl, args)
    ---@type PlayObject[]
    local ret = {}

    if type(ctrl) ~= "table" then
        ctrl = { ctrl }
    end

    for _, control in pairs(ctrl) do
        for _, arguments in pairs(args) do
            local fn = arguments[1]
            ---@diagnostic disable-next-line: param-type-mismatch
            local res = fn(control, table.unpack(arguments, 2))

            if not res then
                if config.debug.current.debug.is_debug then
                    hud_debug_log.log(
                        string.format(
                            "iter_args failed!\nCtrl: %s\nArguments: %s",
                            control:get_Name(),
                            util_table.to_string({ table.unpack(arguments, 2) })
                        ),
                        hud_debug_log.log_debug_type.CONTROL_GETTER_ITER
                    )
                end
                goto continue
            end

            if type(res) == "table" then
                util_table.array_merge_t(ret, res)
            else
                table.insert(ret, res)
            end
            ::continue::
        end
    end

    return ret
end

return this
