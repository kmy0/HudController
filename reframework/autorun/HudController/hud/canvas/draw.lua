---@class CanvasDraw
---@field anchors {[app.GUIHudDef.TYPE]: {x: number, y: number}}
---@field hovered app.GUIHudDef.TYPE?
---@field candidate_index integer?

local bind_monitor = require("HudController.hud.canvas.bind.init")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local hud = require("HudController.hud.init")
local m = require("HudController.util.ref.methods")
local mod = require("HudController.data.mod")
local play_object = require("HudController.hud.play_object.init")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")
local util_mod = require("HudController.util.mod.init")
local util_table = require("HudController.util.misc.table")

local ace_map = data.ace.map

---@class CanvasDraw
local this = {
    anchors = {},
}
local keybinds_drag = util_misc.dragable()

---@param action CanvasAction
local function get_action_value(action)
    ---@type string|number
    local value
    local action_name = util_table.reverse_lookup(mod.enum.canvas, action.type) --[[@as string]]
    local name = config.lang:tr("canvas.actions." .. action_name)
    if action.type == mod.enum.canvas.POS then
        local pos = action.elem:get_global_pos()

        value = string.format(
            "x=%s, y=%s",
            pos and util_misc.round(pos.x, 0) or "?",
            pos and util_misc.round(pos.y, 0) or "?"
        )
    elseif action.type == mod.enum.canvas.ROT then
        value = util_misc.round(action.value, 1)
    elseif action.type == mod.enum.canvas.OPACITY then
        value = util_misc.round(action.value, 2)
    elseif action.type == mod.enum.canvas.SCALE then
        value = util_misc.round(action.value, 2)
    end

    return string.format("%s: %s", name, value)
end

local function get_anchors()
    local ignore = { "NAME_ACCESSIBLE", "NAME_OTHER" }

    for hudname, hudid in pairs(e.get_nocache("app.GUIHudDef.TYPE").field_to_enum) do
        if util_table.contains(ignore, hudname) then
            goto continue
        end

        ---@type via.gui.Control?
        local root
        local guiids = ace_map.hudid_to_guiid[hudid]

        if hudname == "WEAPON" then
            for _, guiid in pairs(guiids) do
                root = util_mod.get_root_window2(guiid)
                local gui = root:get_Component()

                if not gui:get_Enabled() then
                    root = nil
                else
                    break
                end
            end
        elseif hudname == "SHORTCUT_KEYBOARD" then
            root = util_mod.get_root_window2(guiids[1])
            root = play_object.control.get(root, {
                "PNL_All",
            })
        else
            root = util_mod.get_root_window2(guiids[1])
        end

        if not root then
            goto continue
        end

        local pos = m.getGUIscreenPos(root:get_GlobalPosition())
        this.anchors[hudid] = { x = pos.x, y = pos.y }
        ::continue::
    end
end

---@param mouse_pos via.Point
---@param drag_trigger boolean
local function draw_keybinds(mouse_pos, drag_trigger)
    local config_canvas = config.current.mod.canvas

    ---@type [string, string][]
    local keybinds = {}
    for _, bind in ipairs(bind_monitor.monitor.managers["actions"].manager.binds) do
        local action_name = util_table.reverse_lookup(mod.enum.canvas, bind.bound_value) --[[@as string]]
        table.insert(keybinds, {
            string.format("[%s]", config.lang:tr("canvas.keybinds." .. action_name)),
            config.lang:tr("canvas.keybind_actions." .. action_name),
        })
    end

    local line_height = imgui.calc_text_size("A").y + 4
    local col_width = 0
    local action_width = 0
    for _, bind in ipairs(keybinds) do
        local kw = imgui.calc_text_size(bind[1]).x
        local aw = imgui.calc_text_size(bind[2]).x
        if kw > col_width then
            col_width = kw
        end
        if aw > action_width then
            action_width = aw
        end
    end

    local padding = 8
    local box_w = col_width + action_width + padding * 3
    local box_h = #keybinds * line_height + padding * 2
    local pos_x, pos_y = config_canvas.keybinds.pos_x, config_canvas.keybinds.pos_y

    for i, bind in ipairs(keybinds) do
        local row_y = pos_y + padding + (i - 1) * line_height
        util_imgui.draw_text_outlined(
            bind[1],
            pos_x + padding,
            row_y,
            config_canvas.color_hover,
            config_canvas.color_outline
        )
        util_imgui.draw_text_outlined(
            bind[2],
            pos_x + col_width + padding * 2,
            row_y,
            config_canvas.color_default,
            config_canvas.color_outline
        )
    end

    local changed = false
    changed, config_canvas.keybinds.pos_x, config_canvas.keybinds.pos_y = keybinds_drag(
        { x = pos_x, y = pos_y },
        { x = box_w, y = box_h },
        mouse_pos,
        drag_trigger,
        true
    )

    if changed then
        config:save()
    end
end

---@param text string
---@param circle_x number
---@param circle_y number
---@param radius number
---@return number, number
local function get_text_pos(text, circle_x, circle_y, radius, area_w, area_h)
    local text_size = imgui.calc_text_size(text)
    local pos_y = circle_y - text_size.y / 2
    local left_x = circle_x - radius - text_size.x
    local right_x = circle_x + radius

    local x = (right_x + text_size.x <= area_w or circle_x <= area_w / 2) and right_x or left_x
    return util_misc.clamp_text(text, x, pos_y, area_w, area_h)
end

---@param hudid app.GUIHudDef.TYPE
---@param mouse_pos via.Point
---@param selected boolean
---@param action CanvasAction?
---@return app.GUIHudDef.TYPE?
local function draw_elem(hudid, mouse_pos, selected, action)
    local config_canvas = config.current.mod.canvas

    imgui.push_font(config.lang.font)

    local anchor = this.anchors[hudid]
    local pos = util_table.deep_copy(anchor)
    local elem = hud.get_element(hudid)
    pos.x = pos.x + config_canvas.anchor.offset_x
    pos.y = pos.y + config_canvas.anchor.offset_y

    if elem and elem.offset then
        local offset_x, offset_y = util_mod.from_offset(elem.offset.x, elem.offset.y)
        pos.x = pos.x + offset_x
        pos.y = pos.y + offset_y
    end

    local color = (selected and config_canvas.color_select)
        or (hudid == this.hovered and config_canvas.color_hover)
        or config_canvas.color_default

    local cir_x, cir_y = util_misc.clamp_circle(pos.x, pos.y, config_canvas.anchor.radius)
    draw.filled_circle(cir_x, cir_y, config_canvas.anchor.radius, color, 16)
    draw.outline_circle(cir_x, cir_y, config_canvas.anchor.radius, config_canvas.color_outline, 16)

    ---@type number, number, Vector2f
    local name_x, name_y, name_size
    if config_canvas.display_name or (config_canvas.display_value and action) then
        local name_value = config_canvas.display_name
            and ace_map.hudid_name_to_local_name[e.get("app.GUIHudDef.TYPE")[hudid]]
        local action_value = config_canvas.display_value and action and get_action_value(action)

        local line_h = imgui.calc_text_size("A").y
        local screen = imgui.get_display_size()
        local total_h = line_h * ((name_value and 1 or 0) + (action_value and 1 or 0))
        local center_y = math.max(0, math.min(cir_y - line_h / 2, screen.y - total_h))

        if name_value then
            name_size = imgui.calc_text_size(name_value)
            name_x, name_y = get_text_pos(
                name_value,
                cir_x,
                cir_y,
                config_canvas.anchor.radius + 5,
                screen.x,
                screen.y
            )
            util_imgui.draw_text_outlined(
                name_value,
                name_x,
                center_y,
                color,
                config_canvas.color_outline
            )
        end

        if action_value then
            local vx = get_text_pos(
                action_value,
                cir_x,
                cir_y,
                config_canvas.anchor.radius + 5,
                screen.x,
                screen.y
            )
            util_imgui.draw_text_outlined(
                action_value,
                vx,
                center_y + line_h,
                color,
                config_canvas.color_outline
            )
        end
    end

    imgui.pop_font()

    if not selected then
        if
            util_misc.is_inside_circle(
                { x = cir_x, y = cir_y },
                config_canvas.anchor.radius,
                mouse_pos
            )
        then
            return hudid
        end

        if
            config_canvas.display_name
            and name_x
            and util_misc.is_inside_rect({ x = name_x, y = name_y }, name_size, mouse_pos)
        then
            return hudid
        end
    end
end

function this.clear()
    this.anchors = {}
    this.hovered = nil
end

---@param mouse_pos via.Point
---@param mouse_wheel_delta number
---@param action CanvasAction?
---@return app.GUIHudDef.TYPE?
function this.draw(mouse_pos, mouse_wheel_delta, action)
    local selected = action and action.hudid
    local config_canvas = config.current.mod.canvas

    if util_table.empty(this.anchors) then
        get_anchors()
    end

    if config_canvas.keybinds.draw then
        draw_keybinds(
            mouse_pos,
            not action and util_table.contains(bind_monitor.monitor:get_held_key_names(), "L_CLICK")
        )
    end

    ---@type app.GUIHudDef.TYPE[]
    local candidates = {}
    local keys = util_table.sort(util_table.keys(this.anchors))
    for _, hudid in ipairs(keys) do
        if config_canvas.hide_elem_disabled and not util_mod.is_enabled(hudid) then
            goto continue
        end

        if config_canvas.hide_elem_not_present and not hud.get_element(hudid) then
            goto continue
        end

        if hudid == selected or hudid == this.hovered then
            goto continue
        end

        local elem = draw_elem(hudid, mouse_pos, false)
        if elem and not selected then
            table.insert(candidates, elem)
        end
        ::continue::
    end

    if selected then
        draw_elem(selected, mouse_pos, true, action)
    elseif this.hovered and draw_elem(this.hovered, mouse_pos, false) then
        table.insert(candidates, this.hovered)
    end

    if selected then
        this.hovered = nil
    elseif not util_table.empty(candidates) then
        if not this.candidate_index then
            this.candidate_index = 1
        end

        this.candidate_index =
            util_misc.wrap_number(this.candidate_index + mouse_wheel_delta, 1, #candidates)
        table.sort(candidates)
        this.hovered = candidates[this.candidate_index]
    else
        this.hovered = nil
    end

    if not this.hovered then
        this.candidate_index = nil
    end

    return this.hovered
end

return this
