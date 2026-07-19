local custom_condition = require("HudController.hud.bind_condition.conditions.custom")
local s = require("HudController.util.ref.singletons")

return function()
    return custom_condition.new_condition("Minimap State", function(self, option_key)
        local map = s.get("app.GUIManager"):get_MAP3D()
        if not map then
            return false
        end

        local radar_front = map:get_GUIRadarFront()
        local radar = radar_front:get_Radar()
        local pnl = radar._PerimeterChangerPanel
        local play_state = pnl:get_PlayState()

        if option_key == 1 then
            return play_state == "DEFAULT"
        elseif option_key == 2 then
            return play_state == "BLACK_CIRCLE"
        elseif option_key == 3 then
            return play_state == "RED_CIRCLE"
        elseif option_key == 4 then
            return play_state == "WHITE_CIRCLE"
        elseif option_key == 5 then
            return play_state == "PURPLE_CIRCLE"
        end

        return false
    end, { "None", "Black Circle", "Red Circle", "White Circle", "Purple Circle" })
end
