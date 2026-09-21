local config = require("HudController.config.init")
local data = require("HudController.data.init")

local ace_map = data.ace.map

local this = {}

local function translate_ace_option()
    ---@param node AceOptionNode
    local function translate_node(node)
        node.option.name_local = config.lang:try_replace(node.option.name_local)
        for k, v in pairs(node.option.name_path) do
            node.option.name_path[k] = config.lang:try_replace(v)
        end

        for _, item in pairs(node.option.items) do
            item.name_local = config.lang:try_replace(item.name_local)
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

local function translate_elements()
    for k, v in pairs(ace_map.hudid_name_to_local_name) do
        ace_map.hudid_name_to_local_name[k] = config.lang:try_replace(v)
    end
end

function this.inject_literals()
    for key, str in pairs(data.ace.map.literals) do
        config.lang:add_key("literal." .. key, str)
    end
end

---@return boolean
function this.init()
    translate_ace_option()
    translate_elements()
    this.inject_literals()
    return true
end

return this
