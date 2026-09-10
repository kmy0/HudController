local config = require("HudController.config.init")
local e = require("HudController.util.game.enum")
local m = require("HudController.util.ref.methods")
local s = require("HudController.util.ref.singletons")
local util_mod = require("HudController.util.mod.init")

local this = {}

function this.block_input_all_post(_)
    local config_mod = config.current.mod
    if
        config_mod.block_input
        and reframework:is_drawing_ui()
        and config.gui.current.gui.main.is_opened
    then
        m.enablePlNoHit()
        s.get("app.GameInputManager")
            :setPlayerButtonMask(e.get("app.PlayerDef.ButtonMask.USER").ALL)
    end
end

function this.block_input_itembar_pre(_)
    local config_mod = config.current.mod
    --FIXME: disabling all input is not enough to stop the wheel?
    if
        config_mod.block_input
        and reframework:is_drawing_ui()
        and config.gui.current.gui.main.is_opened
    then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.draw_canvas_cursor_post(_)
    if util_mod.is_draw_canvas() then
        return true
    end
end

return this
