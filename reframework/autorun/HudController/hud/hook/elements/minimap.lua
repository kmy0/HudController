local ace_misc = require("HudController.util.ace.misc")
local common = require("HudController.hud.hook.common")
local util_ref = require("HudController.util.ref.init")

local this = {}
local attach_up_pos = util_ref.value_type("via.Position")
local icon_size = util_ref.value_type("via.Float3")

attach_up_pos.x, attach_up_pos.y, attach_up_pos.z = 0, 0, 0

function this.classic_minimap_fov_post(retval)
    local minimap = common.get_elem_t("Minimap")
    if minimap and minimap.enabled_classic_minimap then
        local cam_ctrl = util_ref.get_this() --[[@as app.cGUIMapCameraController]]
        local param = cam_ctrl._GUICameraParam
        local arg = param._CurrentCameraParamArg

        arg:set_AttachUPos(attach_up_pos)
        if minimap.classic_minimap.fov_map then
            arg._FOV = 180 - minimap.classic_minimap.fov_map
        end
    end
end

function this.classic_minimap_icon_scale_post(retval)
    local minimap = common.get_elem_t("Minimap")
    if
        minimap
        and minimap.enabled_classic_minimap
        and minimap.classic_minimap.scale_icon
        and not ace_misc.is_map_open()
    then
        local cam_ctrl = util_ref.get_this() --[[@as app.cGUIMapIconModelSize]]
        icon_size.x, icon_size.y, icon_size.z =
            minimap.classic_minimap.scale_icon,
            minimap.classic_minimap.scale_icon,
            minimap.classic_minimap.scale_icon
        cam_ctrl._IconSizeParam:setValue(icon_size)
    end
end

function this.classic_minimap_no_resize_pre(args)
    local minimap = common.get_elem_t("Minimap")
    if minimap and minimap.enabled_classic_minimap then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

return this
