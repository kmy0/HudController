local util_misc = require("HudController.util.misc.init")

local this = {
    condition = require("HudController.hud.user.condition"),
    script = require("HudController.hud.user.script"),
    option = require("HudController.hud.user.option"),
}

function this.reinit()
    this.script:reinit()
    this.option.init()
end

---@return boolean
function this.init()
    util_misc.with_custom_require(function()
        this.script:init()
        this.condition:init()
    end)

    return this.option.init()
end

return this
