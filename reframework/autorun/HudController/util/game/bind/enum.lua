---@class BindEnum
---@field input_device table<ace.GUIDef.INPUT_DEVICE, string>
---@field pad_btn table<ace.ACE_PAD_KEY.BITS, string>
---@field kb_btn table<ace.ACE_MKB_KEY.INDEX, string>

local game_data = require("HudController.util.game.data")
local util_table = require("HudController.util.misc.table")

---@class BindEnum
local this = {
    input_device = {},
    pad_btn = {},
    kb_btn = {},
}

---@return boolean
function this.init()
    game_data.get_enum("ace.ACE_PAD_KEY.BITS", this.pad_btn, nil, { "HOME", "DECIDE", "CANCEL" })
    game_data.get_enum("ace.ACE_MKB_KEY.INDEX", this.kb_btn)
    game_data.get_enum("ace.GUIDef.INPUT_DEVICE", this.input_device)

    if
        util_table.any(this, function(key, value)
            if type(value) ~= "table" then
                return false
            end

            return util_table.empty(value)
        end)
    then
        return false
    end

    return true
end

return this
