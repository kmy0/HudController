local common = require("HudController.hud.hook.common")

local this = {}

function this.hide_radial_post(_)
    local shortcut = common.get_elem_t("Radial")
    if not shortcut then
        return
    end

    if shortcut and shortcut.hide then
        return false
    end
end

function this.hide_radial_pallet_pre(_)
    local shortcut = common.get_elem_t("Radial")
    if shortcut and shortcut.children.pallet.hide then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

return this
