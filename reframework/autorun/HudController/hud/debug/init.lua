---@class HudDebug
---@field elements table<string, AceGUI>
---@field snapshot string[]
---@field perf {
--- total: integer,
--- completed: integer,
--- obj: string[],
--- }
---@field initialized boolean

---@class (exact) AceBase
---@field obj any
---@field name string
---@field draw_name boolean
---@field visible boolean
---@field type string

---@class (exact) AceControl : AceBase
---@field obj via.gui.Control
---@field name string
---@field chain_state boolean
---@field tree boolean
---@field children table<integer, AceControl | AceBase>
---@field states string[]

---@class (exact) AceGUI
---@field gui via.gui.GUI
---@field root via.gui.Control
---@field view via.gui.View
---@field ctrl AceControl

---@alias AceElem AceControl | AceBase

local config = require("HudController.config")
local data = require("HudController.data")
local factory = require("HudController.hud.factory")
local hud = require("HudController.hud")
local m = require("HudController.util.ref.methods")
local perf = require("HudController.util.misc.perf")
local play_object = require("HudController.hud.play_object")
local util_game = require("HudController.util.game")
local util_misc = require("HudController.util.misc")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum

---@class HudDebug
local this = {
    elements = {},
    snapshot = {},
    initialized = false,
    perf = {
        total = 0,
        completed = 0,
        obj = {},
    },
}

---@param ctrl via.gui.Control
---@return AceControl
local function get_ctrl(ctrl)
    ---@type AceControl
    local ret = {
        obj = ctrl,
        name = ctrl:get_Name(),
        visible = not (not ctrl:get_Visible() or ctrl:get_ForceInvisible()),
        draw_name = false,
        chain_state = false,
        tree = false,
        children = {},
        text = {},
        states = {},
        type = "via.gui.Control",
    }

    util_game.do_something(
        ctrl:get_PlayStateNames() --[[@as System.Array<System.String>]],
        function(system_array, index, value)
            table.insert(ret.states, value)
        end
    )

    local child = ctrl:get_Child()
    while child do
        local type = child:get_type_definition() --[[@as RETypeDefinition]]
        ---@type AceBase
        local obj
        if type:is_a("via.gui.Control") then
            ---@cast child via.gui.Control
            obj = get_ctrl(child)
        else
            obj = {
                obj = child,
                visible = not (not child:get_Visible() or child:get_ForceInvisible()),
                name = child:get_Name(),
                draw_name = false,
                type = type:get_full_name(),
            }
        end

        table.insert(ret.children, obj)
        child = child:get_Next()
    end

    table.sort(ret.children, function(a, b)
        local a_empty = not a.children or util_table.empty(a.children)
        local b_empty = not b.children or util_table.empty(b.children)
        if a_empty and not b_empty then
            return false
        elseif b_empty and not a_empty then
            return true
        end

        return a.name < b.name
    end)

    return ret
end

---@param elem AceElem
---@return string
function this.get_chain(elem)
    ---@type string[]
    local rev = {}
    ---@type string[]
    local res = {}
    ---@type via.gui.Control?
    local o = elem.obj
    ---@type string
    local child_name

    while o do
        table.insert(rev, o:get_Name())
        o = o:get_Parent()
    end

    if elem.type ~= "via.gui.Control" then
        child_name = table.remove(rev, 1)
    end

    for i = #rev, 1, -1 do
        table.insert(res, string.format(' "%s"', rev[i]))
    end

    local ret = string.format("{\n%s\n}", table.concat(res, ",\n"))
    if elem.type ~= "via.gui.Control" then
        return string.format('%s, "%s", "%s"', ret, child_name, elem.type)
    end
    return ret
end

---@param elem AceElem
---@param text string
---@param color integer
---@return boolean
function this.draw_pos(elem, text, color)
    local o = elem.obj
    local pos = m.getGUIscreenPos(o:get_GlobalPosition())

    local screen_size = util_game.get_screen_size()
    local text_size = imgui.calc_text_size(text)
    if pos.x + text_size.x > screen_size.x then
        pos.x = pos.x - (pos.x + (text_size.x - screen_size.x))
    end

    if pos.y + text_size.y > screen_size.y then
        pos.y = pos.y - (pos.y + (text_size.y - screen_size.y))
    end

    if pos.x < 0 then
        pos.x = 0
    end

    if pos.y < 0 then
        pos.y = 0
    end

    if pos.x ~= 0 or pos.y ~= 0 then
        draw.text(text, pos.x, pos.y, color)
        return true
    end
    return false
end

---@return table<string, AceGUI>
function this.get_components()
    ---@type table<string, AceGUI>
    local ret = {}
    local gui_elems = util_game.get_all_components("via.gui.GUI")
    local gui_elems_enum = util_game.get_array_enum(gui_elems)

    while gui_elems_enum:MoveNext() do
        local elem = gui_elems_enum:get_Current() --[[@as via.gui.GUI]]
        local path = elem:ToString() --[[@as string]]

        if path:sub(1, 3) == "GUI" then
            local view = elem:get_View()
            if not view then
                goto continue
            end
            local root = play_object.control.get(view, { "RootWindow" }) --[[@as via.gui.Control]]

            ret[path] = {
                gui = elem,
                root = root,
                view = view,
                ctrl = get_ctrl(view),
            }
        end
        ::continue::
    end
    return ret
end

---@param enabled_only boolean? by default, true
---@return string[]
function this.get_keys(enabled_only)
    enabled_only = enabled_only == nil and true or enabled_only
    local keys = util_table.filter(util_table.sort(util_table.keys(this.elements)), function(key, value)
        local gui_elem = this.elements[value]
        return not enabled_only or gui_elem.gui:get_Enabled()
    end)
    return util_table.sort(util_table.values(keys))
end

---@param keys string[]
function this.make_snapshot(keys)
    this.snapshot = util_table.deep_copy(keys)
end

function this.add_all_element_profile()
    local new_config = hud.operations._new()
    new_config.name = hud.operations.get_name("All Elements")
    new_config.elements = {}
    local key = 1

    for enum, name in pairs(ace_enum.hud) do
        local hud_elem = factory.get_config(enum)
        hud_elem.key = key
        new_config.elements[name] = hud_elem
        key = key + 1
    end

    hud.operations.new(new_config)
end

function this.perf_test()
    local current_hud = hud.manager.by_hudid
    local output_file = util_misc.join_paths(config.name, "perf_log.txt")
    local output_file_sorted = util_misc.join_paths(config.name, "perf_log_sorted.txt")
    local trim_percent = 10
    local it = 1000
    ---@type number[]
    local total = {}
    ---@type [string, PerfStats][]
    local all_stats = {}

    this.perf.completed = 0
    this.perf.total = 0
    this.perf.obj = {}

    local file = io.open(output_file, "w")
    if file then
        file:write("")
        file:close()
    end

    file = io.open(output_file_sorted, "w")
    if file then
        file:write("")
        file:close()
    end

    ---@param stats PerfStats
    ---@return boolean
    local function predicate(stats)
        return true
        -- return stats.trimmed_mean >= 50
    end

    ---@param name string
    ---@param stats PerfStats
    ---@param measurements number[]
    local function callback(name, stats, measurements)
        this.perf.completed = this.perf.completed + 1
        this.perf.obj = util_table.remove(this.perf.obj, function(t, i, j)
            return t[i] ~= name
        end)

        table.insert(all_stats, { name, stats })

        if name:match(".*write.*") then
            if util_table.empty(total) then
                total = util_table.deep_copy(measurements)
            else
                for i = 1, #measurements do
                    total[i] = total[i] + measurements[i]
                end
            end
        end

        if this.perf.completed == this.perf.total then
            table.insert(all_stats, { "TOTAL write", perf.calc_stats(total, trim_percent) })
            table.sort(all_stats, function(a, b)
                return a[2].trimmed_mean > b[2].trimmed_mean
            end)

            ---@type string[]
            local str = {}
            for i = 1, #all_stats do
                local _stats = all_stats[i]
                table.insert(str, perf.format_stats(_stats[1], _stats[2]))
            end

            local file = io.open(output_file_sorted, "a")
            if file then
                file:write(table.concat(str, "\n"))
                file:close()
            end
        end
    end

    local function wrap(hudbase)
        for _, child in pairs(hudbase.children) do
            ---@diagnostic disable-next-line: invisible
            if hudbase.write_nodes[child] and not util_table.empty(child._getter_cache) then
                local name = string.format("%s %s", child:whoami(), "ctrl_getter")
                ---@diagnostic disable-next-line: invisible
                child._ctrl_getter = perf.perf(
                    ---@diagnostic disable-next-line: invisible
                    child._ctrl_getter,
                    it,
                    name,
                    trim_percent,
                    output_file,
                    predicate,
                    callback
                )
                this.perf.total = this.perf.total + 1
                table.insert(this.perf.obj, name)
            end

            wrap(child)
        end
    end

    for _, hudbase in pairs(current_hud) do
        local name = string.format("%s %s", hudbase:whoami(), "write")
        hudbase.write = perf.perf(hudbase.write, it, name, trim_percent, output_file, predicate, callback)
        wrap(hudbase)
        this.perf.total = this.perf.total + 1
        table.insert(this.perf.obj, name)
    end
end

function this.write_all_elements()
    local current_hud = hud.manager.by_hudid

    local function write_offset(hudbase)
        hudbase:set_offset({ x = 999, y = 999 })
        ---@diagnostic disable-next-line: no-unknown
        for _, child in pairs(hudbase.children) do
            ---@diagnostic disable-next-line: invisible
            write_offset(child)
        end
    end

    for _, hudbase in pairs(current_hud) do
        write_offset(hudbase)
    end
end

---@param keys string[]
---@return string[]
function this.filter(keys)
    keys = util_table.filter(keys, function(key, value)
        return not util_table.contains(this.snapshot, value)
    end)
    return util_table.sort(util_table.values(keys))
end

function this.clear()
    this.snapshot = {}
    this.elements = {}
    this.initialized = false
end

---@return boolean
function this.init()
    if this.initialized then
        return true
    end

    this.elements = this.get_components()
    this.initialized = true
    return true
end

return this
