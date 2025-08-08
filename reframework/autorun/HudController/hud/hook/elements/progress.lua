local common = require("HudController.hud.hook.common")

local this = {}
local do_reset = false

function this.reset_progress_default_pre(args)
    local progress = common.get_elem_t("Progress")

    if progress then
        if do_reset or progress:get_GUI020018()._MissionDuplicatePanelDataList:get_Count() > 0 then
            progress:reset()
            do_reset = false
        end
    end
end

function this.reset_progress_mission_pre(args)
    local progress = common.get_elem_t("Progress")
    if progress then
        do_reset = true
    end
end

return this
