local ace_porter = require("HudController.util.ace.porter")
local custom_condition = require("HudController.hud.bind_condition.conditions.custom")

return function()
    return custom_condition.new_condition("Riding", function(self, option_key)
        local riding = ace_porter.is_master_riding()
        if (riding and option_key == 1) or (not riding and option_key == 2) then
            return true
        end

        return false
    end, { "Yes", "No" })
end
