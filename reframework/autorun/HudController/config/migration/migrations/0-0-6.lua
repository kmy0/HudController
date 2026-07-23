---@diagnostic disable: undefined-field, no-unknown, inject-field

local migration_base = require("HudController.util.misc.migration_base")

local this = migration_base.new("0.0.6")

---@param config MainSettings
function this.fns.objectives(config)
    for _, profile in pairs(config.mod.hud) do
        for key, elem in pairs(profile.elements or {}) do
            if
                key ~= "PROGRESS"
                or not elem.children
                or not elem.children.timer
                or elem.children.quest_timer
            then
                goto continue
            end

            local quest_timer_config = elem.children.timer
            elem.children.timer = nil

            quest_timer_config.name_key = "quest_timer"
            elem.children.quest_timer = quest_timer_config
            ::continue::
        end
    end
end

return this
