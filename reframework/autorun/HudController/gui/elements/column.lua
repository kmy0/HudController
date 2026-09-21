local config = require("HudController.config.init")
local gui_elements = require("HudController.gui.elements.init")
local util_imgui = require("HudController.util.imgui.init")

local this = {}

function this.draw()
    util_imgui.adjust_pos(0, -2)

    if
        imgui.begin_table(
            "main_table",
            2,
            imgui.TableFlags.BordersInnerV | imgui.TableFlags.Resizable --[[@as ImGuiTableFlags]],
            Vector2f.new(-1, -1)
        )
    then
        imgui.table_setup_column("##main_select", nil, 0.3)
        imgui.table_setup_column("##main_content", nil, 0.7)
        imgui.table_next_row()

        imgui.table_set_column_index(0)

        gui_elements.choice.draw()
        imgui.separator()

        local sel_name, sel_draw = gui_elements.profile.draw()

        if sel_name and sel_draw then
            imgui.table_set_column_index(1)

            imgui.push_font(config.lang.font_header)
            imgui.spacing()
            imgui.same_line()
            imgui.text(sel_name)
            imgui.pop_font()
            util_imgui.separator(4)

            sel_draw()
            imgui.spacing()
        end
        imgui.end_table()
    end
end

return this
