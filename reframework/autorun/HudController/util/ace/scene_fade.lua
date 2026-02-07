---@class SceneFade
---@field protected _fader {
--- obj: ace.GUIFade,
--- ori_color: via.Color,
--- ori_seg: app.GUIDefApp.DRAW_SEGMENT,
--- }?

local util_game = require("HudController.util.game.init")

---@class SceneFade
local this = {
    enum = {},
}

function this.reset()
    if this._fader then
        this._fader.obj:setFadeAlpha(0.0)
        this._fader.obj:setFadeColor(this._fader.ori_color)
        this._fader.obj:setDrawSegment(this._fader.ori_seg)
        this._fader.obj:close()
        this._fader = nil
    end
end

---@return ace.GUIFade
function this.get()
    if not this._fader then
        this._fader = {}
        util_game.do_something(util_game.get_all_components("ace.GUIFade"), function(_, _, value)
            local game_oject = value:get_GameObject()
            if game_oject:get_Name() == "FadeAppSecond" then
                this._fader.obj = value
                return false
            end
        end)

        this._fader.ori_color = this._fader.obj._Color
        local root = this._fader.obj._RootWindow
        ---@diagnostic disable-next-line: assign-type-mismatch
        this._fader.ori_seg = root:get_Segment()
        this._fader.obj:open()
    end

    return this._fader.obj
end

---@param alpha number
---@param color integer?
---@param segment app.GUIDefApp.DRAW_SEGMENT?
---@return ace.GUIFade
function this.set(alpha, color, segment)
    if not this._fader then
        this.get()
    end

    if color then
        local c = this._fader.obj._Color
        c.rgba = color
        this._fader.obj:setFadeColor(c)
    end

    if segment then
        this._fader.obj:setDrawSegment(segment)
    end

    this._fader.obj:setFadeAlpha(alpha)
    return this._fader.obj
end

---@return boolean
function this.init()
    re.on_script_reset(function()
        this.reset()
    end)

    return true
end

return this
