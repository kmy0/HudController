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

local m = require("HudController.util.ref.methods")
local play_object = require("HudController.hud.play_object")
local util_game = require("HudController.util.game")
local util_table = require("HudController.util.misc.table")

local this = {}

---@param ctrl via.gui.Control
---@return AceControl
function this.get_ctrl(ctrl)
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
            obj = this.get_ctrl(child)
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
function this.get_gui()
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
                ctrl = this.get_ctrl(view),
            }
        end
        ::continue::
    end
    return ret
end

return this
