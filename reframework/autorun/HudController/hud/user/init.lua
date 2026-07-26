local util_misc = require("HudController.util.misc.init")

local this = {
    condition = require("HudController.hud.user.condition"),
    script = require("HudController.hud.user.script"),
}

function this.reinit()
    this.script:reinit()
end

---@return boolean
function this.init()
    util_misc.with_custom_require(function()
        this.script:init()
        this.condition:init()
    end)

    return true
end

return this
