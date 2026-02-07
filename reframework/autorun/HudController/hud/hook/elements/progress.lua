local common = require("HudController.hud.hook.common")

local this = {}
local do_reset = false

function this.reset_progress_default_pre(_)
    local progress = common.get_elem_t("Progress")

    if progress then
        if do_reset or progress:get_GUI020018()._MissionDuplicatePanelDataList:get_Count() > 0 then
            progress:reset()
            progress:reset_defaults()
            do_reset = false
        end
    end
end

function this.reset_progress_mission_pre(_)
    local progress = common.get_elem_t("Progress")
    if progress then
        do_reset = true
    end
end

function this.clear_cache_pre(_)
    local progress = common.get_elem_t("Progress")
    if progress then
        local GUI020018 = progress:get_GUI020018()
        if GUI020018._FadeInWaitPanelList:get_Count() > 0 then
            progress:do_something_to_children(function(hudchild)
                hudchild:clear_cache()
            end)
        end
    end
end

return this
