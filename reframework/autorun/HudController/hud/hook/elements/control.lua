local common = require("HudController.hud.hook.common")
local play_object = require("HudController.hud.play_object.init")
local play_object_defaults = require("HudController.hud.defaults.init").play_object
local util_ref = require("HudController.util.ref.init")

local this = {}

function this.set_control_global_pos_pre(args)
    local control = common.get_elem_t("Control")
    if
        control
        and not control.hide
        and not control.children.control_guide1.hide
        and control.children.control_guide1.offset
        and not util_ref.to_bool(args[3])
    then
        util_ref.capture_this(args)
    end
end

function this.set_control_global_pos_post(retval)
    local GUI020014 = util_ref.get_this() --[[@as app.GUI020014]]
    if GUI020014 then
        local control_guide00 = GUI020014:get__PNL_ControlGuide00()
        local pat = play_object.control.get_parent(control_guide00, "PNL_Pat00") --[[@as via.gui.Control]]

        local pat_default = play_object_defaults:get(pat)
        if not pat_default then
            return
        end

        pat:set_Position(Vector3f.new(pat_default.offset.x, pat_default.offset.y, 0))
    end
end

return this
