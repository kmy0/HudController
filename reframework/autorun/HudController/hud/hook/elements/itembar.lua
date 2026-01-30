local ace_misc = require("HudController.util.ace.misc")
local ace_player = require("HudController.util.ace.player")
local common = require("HudController.hud.hook.common")
local data = require("HudController.data.init")
local game_data = require("HudController.util.game.data")
local m = require("HudController.util.ref.methods")
local play_object = require("HudController.hud.play_object.init")
local s = require("HudController.util.ref.singletons")
local util_game = require("HudController.util.game.init")
local util_misc = require("HudController.util.misc.init")
local util_ref = require("HudController.util.ref.init")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

local this = {
    ---@type {
    --- visible: boolean,
    --- frame: integer,
    --- cursor_init: boolean,
    --- force_mouse_pos: via.vec3?,
    --- skip_mouse_update: boolean,
    --- }
    expanded = {
        visible = false,
        frame = 0,
        cursor_init = true,
        force_mouse_pos = nil,
        skip_mouse_update = false,
    },
}

function this.open_expanded_itembar_pre(args)
    local itembar = common.get_elem_t("Itembar")
    if not itembar then
        return
    end

    if itembar and itembar.start_expanded then
        local GUI020006 = itembar:get_GUI020006()
        local flag =
            ace_player.check_continue_flag(rl(ace_enum.hunter_continue_flag, "OPEN_ITEM_SLIDER"))

        if not this.expanded.visible and flag then
            if GUI020006:get_IsAllSliderMode() then
                return
            end

            --FIXME: sometimes this throws
            if
                not util_misc.try(function()
                    GUI020006:startAllSlider()
                end)
            then
                return
            end

            this.expanded.visible = true
        elseif not flag then
            this.expanded.visible = false
        end
    end

    if this.expanded.visible then
        this.expanded.frame = this.expanded.frame + 1
    else
        this.expanded.frame = 0
    end
end

function this.keep_ammo_open_pre(args)
    local itembar = common.get_elem_t("Itembar")
    if itembar and itembar.children.all_slider.ammo_visible then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.keep_slinger_open1_post(retval)
    local itembar = common.get_elem_t("Itembar")
    if itembar and itembar.children.all_slider.slinger_visible then
        local GUI020017 = util_ref.get_this() --[[@as app.GUI020017]]
        if GUI020017:get__SetMainAmmoType() ~= 0 then
            return sdk.to_ptr(false)
        end
    end
end

function this.keep_slinger_open0_post(retval)
    local itembar = common.get_elem_t("Itembar")
    if itembar then
        local GUI020017 = util_ref.get_this() --[[@as app.GUI020017]]

        if
            itembar.children.all_slider.slinger_visible
            and GUI020017:get__SetMainAmmoType() ~= 0
        then
            return sdk.to_ptr(true)
        end
    end
end

function this.unblock_camera_control_post(retval)
    local itembar = common.get_elem_t("Itembar")
    if itembar and itembar.children.all_slider.disable_right_stick then
        if itembar:get_GUI020006():get_IsAllSliderMode() then
            local flag = 1 << rl(ace_enum.button_mask, "CAMERA") --[[@as integer]]
            local inputman = s.get("app.GameInputManager")
            local bit_flags = inputman._PlayerButtonMaskFlagStore

            util_game.do_something(bit_flags, function(system_array, index, bit_flag)
                local value = bit_flag._Value

                if value & flag == flag then
                    bit_flag._Value = value ~ flag
                    bit_flags:set_Item(index, bit_flag)
                end
            end)
        end
    end
end

function this.expanded_itembar_mouse_control_post(retval)
    local itembar = common.get_elem_t("Itembar")
    if not itembar then
        return
    end

    if
        itembar
        and itembar.children.all_slider.enable_mouse_control
        and itembar:get_GUI020006():get_IsAllSliderMode()
        and ace_enum.input_device[s.get("app.GUIManager"):get_LastInputDeviceIgnoreMouseMove()]
            ~= "PAD"
    then
        local all_slider = util_ref.get_this() --[[@as app.GUI020006PartsAllSlider]]
        local current_item = all_slider:getCurrentItem()
        local current_sel = current_item:get__BaseItem()

        if this.expanded.cursor_init then
            this.expanded.force_mouse_pos = m.getGUIscreenPos(current_sel:get_GlobalPosition())
            this.expanded.cursor_init = false
            return
        end

        local pnl_all_slider = itembar:get_GUI020006():get__PanelAllSlider()
        local mouse_pos = ace_misc.get_kb():get_MousePos()

        -- technically, making cursor visible is enough to make mouse selection work,
        -- but applying scale to itembar or expanded itembar breaks it,
        -- this always works
        if pnl_all_slider:hitTest(mouse_pos) then
            local current_index = current_sel:get_ListIndex()
            local fsg_ctrl = play_object.control.get(pnl_all_slider, {
                "PNL_ASL_Pos",
                "FSG_ASList",
            }) --[[@as via.gui.Control]]
            local mouse_over = false

            -- when expanded item bar is in 'Selected Stack Only' mode, all icons of a stack are in the same place before mouseover
            -- iterating in reverse makes sure that correct icon is selected
            util_game.do_something(all_slider:get__GridParts(), function(system_array, index, item)
                local sel = item:get__BaseItem()
                local sel_index = sel:get_ListIndex()

                if sel:hitTest(mouse_pos) then
                    if current_index ~= sel_index then
                        local int2 = util_ref.value_type("via.Int2")
                        local input_ctrl = itembar.children.all_slider:get_input_ctrl()
                        input_ctrl:getIndexFromItemCore(sel, int2)
                        input_ctrl:requestSelectIndexCore(int2.x, int2.y)

                        current_sel = sel
                        current_index = sel_index
                        current_item = item
                    end

                    mouse_over = true
                    return false
                end
            end, true)

            if mouse_over and ace_misc.get_kb():isOn(rl(ace_enum.kb_btn, "L_CLICK")) then
                all_slider:callbackOther(
                    all_slider.SLOT_ITEM_USE,
                    fsg_ctrl,
                    current_sel,
                    current_index
                )
            end
        end
    else
        this.expanded.cursor_init = true
    end
end

function this.force_mouse_pos_pre(args)
    if this.expanded.force_mouse_pos then
        local GUI000006 = sdk.to_managed_object(args[2]) --[[@as app.GUI000006]]
        local cursor_pos = GUI000006:get_CurrentCursorPosition()
        local screen_size = util_game.get_screen_size()
        local screen_center = { x = screen_size.x / 2, y = screen_size.y / 2 }

        cursor_pos.x = (this.expanded.force_mouse_pos.x - screen_center.x) / screen_center.x
        cursor_pos.y = -(this.expanded.force_mouse_pos.y - screen_center.y) / screen_center.y
        GUI000006:setCursorPosition(cursor_pos)
        this.expanded.force_mouse_pos = nil
    end
end

function this.force_cursor_visible_post(retval)
    local itembar = common.get_elem_t("Itembar")
    if not itembar then
        return
    end

    if
        itembar
        and itembar.children.all_slider.enable_mouse_control
        and itembar:get_GUI020006():get_IsAllSliderMode()
        and ace_enum.input_device[s.get("app.GUIManager"):get_LastInputDeviceIgnoreMouseMove()]
            ~= "PAD"
    then
        this.expanded.skip_mouse_update = true
        return sdk.to_ptr(true)
    end

    this.expanded.skip_mouse_update = false
end

-- prevents mouse cursor flicker to 0,0 when closing itembar
function this.skip_mouse_update_pre(args)
    if this.expanded.skip_mouse_update then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.refresh_all_slider_post(retval)
    local itembar = common.get_elem_t("Itembar")
    if
        itembar
        and itembar.children.all_slider.appear_open
        and not itembar:get_GUI020006():get_IsAllSliderMode()
    then
        itembar:get_GUI020006():initAllList()
    end

    return retval
end

function this.move_next_item_pre(args)
    local itembar = common.get_elem_t("Itembar")
    if not itembar or not itembar.children.slider.move_next then
        return
    end

    local item_id = sdk.to_int64(args[2]) --[[@as app.ItemDef.ID]]
    if
        not itembar:get_GUI020006():get_IsAllSliderMode()
        and itembar:get_GUI020006():get_SelectedItemId() == item_id
        and m.getItemNum(item_id, rl(ace_enum.stock_type, "POUCH")) == 1
    then
        local slider = itembar.children.slider:get_part()
        slider:callbackOther(slider.SLOT_LEFT, nil, nil, 0)
    end
end

function this.clear_cache_pre(args)
    local itembar = common.get_elem_t("Itembar")
    if itembar then
        itembar.children.all_slider:do_something_to_children(function(hudchild)
            hudchild:clear_cache()
        end)
    end
end

function this.hide_radial_post(retval)
    local itembar = common.get_elem_t("Itembar")
    if
        itembar
        and itembar.start_expanded
        and (not this.expanded.visible or this.expanded.frame < 2)
        and ace_player.check_continue_flag(rl(ace_enum.hunter_continue_flag, "OPEN_ITEM_SLIDER"))
    then
        return false
    end
end

return this
