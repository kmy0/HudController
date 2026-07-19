local bind_condition = require("HudController.hud.bind_condition.init")
local hook_common = require("HudController.hud.hook.common")

re.on_frame(function()
    local health = hook_common.get_elem_t("Health")
    local condition = bind_condition.conditions["Health Changed"]

    if not health or not condition then
        return
    end

    local b = condition:update()
    if health.hide and b then
        health:set_hide(false)
        health.hide_changed = false -- normally set to true to stop the original fade in/fade out animations, but here it looks bad without the fade, so it's set to false
    elseif not health.hide and not b then
        health:set_hide(true)
        health.hide_changed = false
    end
end)
