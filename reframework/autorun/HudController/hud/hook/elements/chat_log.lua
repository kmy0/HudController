local common = require("HudController.hud.hook.common")

local this = {}

function this.clear_cache_pre(_)
    local chat_log = common.get_elem_t("ChatLog")
    if chat_log then
        chat_log:do_something_to_children(function(hudchild)
            hudchild:clear_cache()
        end)
    end
end

return this
