local enum = require("HudController.util.game.bind.enum")

local this = {
    listener = require("HudController.util.game.bind.listener"),
    manager = require("HudController.util.game.bind.manager"),
}

---@return boolean
function this.init()
    return enum.init()
end

return this
