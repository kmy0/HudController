local config = require("HudController.config.init")
local e = require("HudController.util.game.enum")
local user_option = require("HudController.hud.user.option")
local util_misc = require("HudController.util.misc.init")

local this = {}

---@param elem_config HudBaseConfig
function this.merge_elem_user_options(elem_config)
    local hud_name = e.get("app.GUIHudDef.TYPE")[elem_config.hud_id]

    for k, opt in pairs(user_option.element[hud_name] or {}) do
        elem_config.user_options[k] = user_option.get_default(opt)
    end

    for opt, _ in pairs(config.current.mod.game_options.elements[elem_config.name_key] or {}) do
        elem_config.options[opt] = -1
    end
end

---@param hud_config ModProfileConfig
function this.merge_hud_user_options(hud_config)
    for k, opt in pairs(user_option.hud) do
        hud_config.user_options[k] = user_option.get_default(opt)
    end

    for opt, _ in pairs(config.current.mod.game_options.hud) do
        hud_config.options[opt] = -1
    end
end

function this.merge_mod_user_settings()
    local config_mod = config.current.mod
    for k, opt in pairs(user_option.mod) do
        if config_mod.user_options[k] == nil then
            config_mod.user_options[k] = user_option.get_default(opt)
        end
    end
end

function this.verify_options()
    local config_mod = config.current.mod

    for k, _ in pairs(config_mod.user_options) do
        local reg_opt = user_option.bindable[k]

        if not reg_opt or reg_opt.module ~= "mod" then
            config_mod.user_options[k] = nil
        elseif reg_opt then
            local default_value = user_option.get_default(reg_opt)
            if
                not util_misc.eval_type(
                    config_mod.user_options[k],
                    user_option.get_default(reg_opt)
                )
            then
                config_mod.user_options[k] = default_value
            end
        end
    end

    for _, hud in pairs(config_mod.hud) do
        for k, _ in pairs(hud.user_options or {}) do
            local reg_opt = user_option.bindable[k]

            if not reg_opt or reg_opt.module ~= "hud" then
                hud.user_options[k] = nil
            elseif reg_opt then
                local default_value = user_option.get_default(reg_opt)

                if
                    not util_misc.eval_type(hud.user_options[k], user_option.get_default(reg_opt))
                then
                    hud.user_options[k] = default_value
                end
            end
        end

        for _, elem in pairs(hud.elements or {}) do
            local hud_name = e.get("app.GUIHudDef.TYPE")[elem.hud_id]
            for k, _ in pairs(elem.user_options or {}) do
                local reg_opt = user_option.bindable[k]

                if reg_opt.module ~= "element" or reg_opt.element ~= hud_name then
                    elem.user_options[k] = nil
                elseif reg_opt then
                    local default_value = user_option.get_default(reg_opt)

                    if
                        not util_misc.eval_type(
                            elem.user_options[k],
                            user_option.get_default(reg_opt)
                        )
                    then
                        elem.user_options[k] = default_value
                    end
                end
            end
        end
    end
end

return this
