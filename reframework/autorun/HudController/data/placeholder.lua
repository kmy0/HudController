local config = require("HudController.config.init")
local data = require("HudController.data.init")

local ace_map = data.ace.map

local this = {}

local function translate_ace_option()
    for _, opt in pairs(ace_map.option) do
        opt.name_local = config.lang:try_replace(opt.name_local)

        for _, item in pairs(opt.items) do
            item.name_local = config.lang:try_replace(item.name_local)
        end

        for i, name in ipairs(opt.name_path) do
            opt.name_path[i] = config.lang:try_replace(name)
        end
    end

    local function translate_branch(branch)
        branch.name = config.lang:try_replace(branch.name)
        branch.name = config.lang:try_replace(branch.name)

        ---@diagnostic disable-next-line: no-unknown
        for _, child in pairs(branch.children) do
            translate_branch(child)
        end

        for i, name in ipairs(branch.name_path) do
            branch.name_path[i] = config.lang:try_replace(name)
        end

        table.sort(branch.children, function(a, b)
            return a.name < b.name
        end)
    end

    for _, branch in pairs(ace_map.tree_game_options.source) do
        translate_branch(branch)
    end

    table.sort(ace_map.tree_game_options.source, function(a, b)
        return a.name < b.name
    end)

    ace_map.tree_game_options:swap(ace_map.tree_game_options.source)
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
