local data = require("HudController.data.init")
local game_data = require("HudController.util.game.data")
local s = require("HudController.util.ref.singletons")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

local this = {}

---@generic T
---@param type `T` app.GUIXXXXXX
---@return T
function this.get_gui_cls(type)
    return s.get("app.GUIManager"):getGUI(rl(ace_enum.gui_id, string.sub(type, 6)))
end

return this
