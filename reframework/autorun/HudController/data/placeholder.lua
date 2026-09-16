local config = require("HudController.config.init")
local data = require("HudController.data.init")

local ace_map = data.ace.map

local this = {}

local function translate_ace_option()
    ---@param node AceOptionNode
    local function translate_node(node)
        node.option.name_local = config.lang:try_replace(node.option.name_local)
        for _, item in pairs(node.option.items) do
            item.name_local = config.lang:try_replace(item.name_local)
        end

        for _, child in pairs(node.children) do
            translate_node(child)
        end
    end

    for _, nodes in pairs(ace_map.game_options) do
        for _, node in pairs(nodes) do
            translate_node(node)
        end
    end
end

---@return boolean
function this.init()
    translate_ace_option()
    return true
end

return this
