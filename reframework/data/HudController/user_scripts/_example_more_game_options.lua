local e = require("HudController.util.game.enum")
local factory = require("HudController.hud.factory")
local m = require("HudController.util.ref.methods")

--this will print option enum name in the Debug Console when option is changed in the ingame options
m.hook("app.OptionUtil.setOptionValue(app.Option.ID, System.Int32)", function(args)
    log.info(e.get("app.Option.ID")[sdk.to_int64(args[2])])
end)

local o_fn = factory.get_hud_profile_config
factory.get_hud_profile_config = function(key, name)
    local ret = o_fn(key, name)
    if ret then
        -- only multiple choice options will work
        local option_enum_name = "AUTO_SHEATHING" -- app.Option.ID
        ret.options[option_enum_name] = -1

        -- if added correctly, the option will be available under Hud Options > Ingame Settings
    end

    return ret
end
