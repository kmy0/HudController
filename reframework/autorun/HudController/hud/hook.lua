local ace_em = require("HudController.util.ace.enemy")
local ace_misc = require("HudController.util.ace.misc")
local ace_npc = require("HudController.util.ace.npc")
local ace_player = require("HudController.util.ace.player")
local ace_porter = require("HudController.util.ace.porter")
local call_queue = require("HudController.hud.call_queue")
local config = require("HudController.config")
local data = require("HudController.data")
local elements = require("HudController.hud.elements")
local game_data = require("HudController.util.game.data")
local hud = require("HudController.hud")
local m = require("HudController.util.ref.methods")
local play_object = require("HudController.hud.play_object")
local s = require("HudController.util.ref.singletons")
local timer = require("HudController.util.misc.timer")
local util_game = require("HudController.util.game")
local util_misc = require("HudController.util.misc")
local util_ref = require("HudController.util.ref")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum
local ace_map = data.ace.map
local mod = data.mod
local rl = game_data.reverse_lookup

local this = {}
---@type {
--- visible: boolean,
--- frame: integer,
--- cursor_init: boolean,
--- force_mouse_pos: via.vec3?,
--- skip_mouse_update: boolean,
--- }
local expanded_item_bar = {
    visible = false,
    frame = 0,
    cursor_init = true,
    force_mouse_pos = nil,
    skip_mouse_update = false,
}
local porter = {
    timer_key = "master_porter_timer",
    call_timer_key = "master_porter_call_timer",
    touch_timer_key = "master_porter_touch_timer",
    hidden = false,
}
local handler_key = "handler_touch_timer"
local ammo_slider = {
    open = false,
    item_slider_open = false,
}
local progress_reset_arr = false

local function is_ok()
    return mod.initialized and config.get("mod.enabled")
end

---@generic T
---@param name `T`
---@return T?
local function get_elem_t(name)
    if not is_ok() then
        return
    end

    return hud.get_element(elements[name])
end

---@return HudProfileConfig?
local function get_hud()
    if not is_ok() then
        return
    end

    return hud.get_current()
end

---@param pnl via.gui.Control
local function force_opacity(pnl)
    local scale = pnl:get_ColorScale()
    scale.w = 1.0
    pnl:set_ColorScale(scale)
end

---@return boolean?, boolean?
local function is_result_skip()
    local hud_config = get_hud()
    local skip = hud_config and hud.get_hud_option("skip_quest_result")
    local notice = get_elem_t("Notice")
    local skip_seamless = notice and (notice.hide or notice.system_log.ALL or notice.system_log["QUEST_RESULT"])
    return skip, skip_seamless
end

function this.update_pre(args)
    if not is_ok() then
        return
    end

    util_ref.capture_this(args, 3)
end

function this.update_post(retval)
    if not is_ok() then
        return
    end

    local disp_ctrl = util_ref.get_this() --[[@as app.cGUIHudDisplayControl?]]
    if not disp_ctrl then
        return
    end

    local hudbase = disp_ctrl:get_Owner()
    local gui_id = hudbase:get_ID()

    call_queue.consume(gui_id)

    local hud_elem = hud.get_element_by_guiid(gui_id)

    -- NamesAccess is updated here @update_name_access_icons_post
    if not hud_elem or hud_elem.hud_id == rl(ace_enum.hud, "NAME_ACCESSIBLE") then
        return
    end

    hud_elem:write(hudbase, gui_id, disp_ctrl._TargetControl)
end

function this.hide_radial_post(retval)
    local itembar = get_elem_t("Itembar")
    if
        itembar
        and itembar.start_expanded
        and (not expanded_item_bar.visible or expanded_item_bar.frame < 2)
        and ace_player.check_continue_flag(rl(ace_enum.hunter_continue_flag, "OPEN_ITEM_SLIDER"))
    then
        return false
    end

    local shortcut = get_elem_t("Radial")
    if not shortcut then
        return
    end

    if shortcut and shortcut.hide then
        return false
    end
end

function this.hide_radial_pallet_pre(args)
    local shortcut = get_elem_t("Radial")
    if shortcut and shortcut.children.pallet.hide then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.disable_gui_sound_pre(args)
    local hud_config = get_hud()
    if not hud_config then
        return
    end

    if
        hud.get_hud_option("mute_gui")
        or (
            hud.get_hud_option("skip_quest_end_timer")
            and util_ref.to_short(args[3]) == rl(ace_enum.gui_id, "UI020202")
        )
    then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.hide_subtitles_pre(args)
    local hud_config = get_hud()
    if not hud_config then
        return
    end

    if hud.get_hud_option("hide_subtitles") then
        local req = sdk.to_managed_object(args[3]) --[[@as app.cDialogueSubtitleManager.RequestData]]
        local param = req.SubTitleParam
        local type = param.DialogueType

        if type == rl(ace_enum.dialog, "GOSSIP") or type == rl(ace_enum.dialog, "NAGARA") then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.open_expanded_itembar_pre(args)
    local itembar = get_elem_t("Itembar")
    if not itembar then
        return
    end

    if itembar and itembar.start_expanded then
        local GUI020006 = itembar:get_GUI020006()
        local flag = ace_player.check_continue_flag(rl(ace_enum.hunter_continue_flag, "OPEN_ITEM_SLIDER"))

        if not expanded_item_bar.visible and flag then
            if GUI020006:get_IsAllSliderMode() then
                return
            end

            --FIXME: sometimes this throws
            if not util_misc.try(function()
                GUI020006:startAllSlider()
            end) then
                return
            end

            expanded_item_bar.visible = true
        elseif not flag then
            expanded_item_bar.visible = false
        end
    end

    if expanded_item_bar.visible then
        expanded_item_bar.frame = expanded_item_bar.frame + 1
    else
        expanded_item_bar.frame = 0
    end
end

function this.keep_ammo_open_pre(args)
    local itembar = get_elem_t("Itembar")
    if itembar and itembar.children.all_slider.ammo_visible then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.keep_slinger_open1_post(retval)
    local itembar = get_elem_t("Itembar")
    if itembar and itembar.children.all_slider.slinger_visible then
        local GUI020017 = util_ref.get_this() --[[@as app.GUI020017]]
        if GUI020017:get__SetMainAmmoType() ~= 0 then
            return sdk.to_ptr(false)
        end
    end
end

function this.keep_slinger_open0_post(retval)
    local itembar = get_elem_t("Itembar")
    if itembar then
        local GUI020017 = util_ref.get_this() --[[@as app.GUI020017]]

        if itembar.children.all_slider.slinger_visible and GUI020017:get__SetMainAmmoType() ~= 0 then
            return sdk.to_ptr(true)
        end
    end
end

function this.unblock_camera_control_post(retval)
    local itembar = get_elem_t("Itembar")
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
    local itembar = get_elem_t("Itembar")
    if not itembar then
        return
    end

    if
        itembar
        and itembar.children.all_slider.enable_mouse_control
        and itembar:get_GUI020006():get_IsAllSliderMode()
        and ace_enum.input_device[s.get("app.GUIManager"):get_LastInputDeviceIgnoreMouseMove()] ~= "PAD"
    then
        local all_slider = util_ref.get_this() --[[@as app.GUI020006PartsAllSlider]]
        local current_item = all_slider:getCurrentItem()
        local current_sel = current_item:get__BaseItem()

        if expanded_item_bar.cursor_init then
            expanded_item_bar.force_mouse_pos = m.getGUIscreenPos(current_sel:get_GlobalPosition())
            expanded_item_bar.cursor_init = false
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
                all_slider:callbackOther(all_slider.SLOT_ITEM_USE, fsg_ctrl, current_sel, current_index)
            end
        end
    else
        expanded_item_bar.cursor_init = true
    end
end

function this.force_mouse_pos_pre(args)
    if expanded_item_bar.force_mouse_pos then
        local GUI000006 = sdk.to_managed_object(args[2]) --[[@as app.GUI000006]]
        local cursor_pos = GUI000006:get_CurrentCursorPosition()
        local screen_size = util_game.get_screen_size()
        local screen_center = { x = screen_size.x / 2, y = screen_size.y / 2 }

        cursor_pos.x = (expanded_item_bar.force_mouse_pos.x - screen_center.x) / screen_center.x
        cursor_pos.y = -(expanded_item_bar.force_mouse_pos.y - screen_center.y) / screen_center.y
        GUI000006:setCursorPosition(cursor_pos)
        expanded_item_bar.force_mouse_pos = nil
    end
end

function this.force_cursor_visible_post(retval)
    local itembar = get_elem_t("Itembar")
    if not itembar then
        return
    end

    if
        itembar
        and itembar.children.all_slider.enable_mouse_control
        and itembar:get_GUI020006():get_IsAllSliderMode()
        and ace_enum.input_device[s.get("app.GUIManager"):get_LastInputDeviceIgnoreMouseMove()] ~= "PAD"
    then
        expanded_item_bar.skip_mouse_update = true
        return sdk.to_ptr(true)
    end

    expanded_item_bar.skip_mouse_update = false
end

-- prevents mouse cursor flicker to 0,0 when closing itembar
function this.skip_mouse_update_pre(args)
    if expanded_item_bar.skip_mouse_update then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.skip_system_message_pre(args)
    local notice = get_elem_t("Notice")
    if notice then
        if notice.hide or notice.system_log.ALL then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end

        local def = sdk.to_managed_object(args[3]) --[[@as app.ChatDef.SystemMessage]]
        local name = ace_enum.system_msg[def:get_SystemMsgType()]

        if notice.system_log[name] then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end

        local log_name = ""
        local log_t = {}
        if util_ref.is_a(def, "app.ChatDef.EnemyMessage") then
            ---@cast def app.ChatDef.EnemyMessage
            log_name = ace_enum.enemy_log[def:get_EnemyLogType()]
            log_t = notice.enemy_log
        elseif util_ref.is_a(def, "app.ChatDef.CampMessage") then
            ---@cast def app.ChatDef.CampMessage
            log_name = ace_enum.camp_log[def:get_CampLogType()]
            log_t = notice.camp_log
        end

        if log_t[log_name] then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.skip_lobby_message_pre(args)
    local notice = get_elem_t("Notice")
    if notice then
        if notice.hide or notice.chat_log.ALL then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end

        local def = sdk.to_managed_object(args[3]) --[[@as app.ChatDef.ChatBase]]
        local name = ace_enum.chat_log[def:get_MsgType()]

        if notice.chat_log[name] then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end

        name = ace_enum.send_target[def:get_SendTarget()]
        if notice.lobby_log[name] then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.refresh_all_slider_post(retval)
    local itembar = get_elem_t("Itembar")
    if itembar and itembar.children.all_slider.appear_open and not itembar:get_GUI020006():get_IsAllSliderMode() then
        itembar:get_GUI020006():initAllList()
    end

    return retval
end

function this.move_next_item_pre(args)
    local itembar = get_elem_t("Itembar")
    if not itembar then
        return
    end

    local item_id = sdk.to_int64(args[2]) --[[@as app.ItemDef.ID]]
    if
        itembar
        and true
        and not itembar:get_GUI020006():get_IsAllSliderMode()
        and itembar:get_GUI020006():get_SelectedItemId() == item_id
        and m.getItemNum(item_id, rl(ace_enum.stock_type, "POUCH")) == 1
    then
        local slider = itembar.children.slider:get_part()
        slider:callbackOther(slider.SLOT_LEFT, nil, nil, 0)
    end
end

function this.hide_iteractables_post(retval)
    local name_access = get_elem_t("NameAccess")
    if name_access and (not name_access.hide or hud.get_hud_option("hide_monster_icon")) then
        local access_control = util_ref.get_this() --[[@as app.GUIAccessIconControl]]
        ---@type Vector3f?
        local player_pos
        local any_panel = name_access:any_panel()
        local any_npc = name_access:any_npc()
        local any_gossip = name_access:any_gossip()

        util_game.do_something(access_control:get_AccessIconInfos(), function(system_array, index, value)
            if name_access.object_category["ALL"] then
                value:clear()
            else
                if any_panel and name_access.panel_type[ace_enum.interact_panel_type[value:getCurrentPanelType()]] then
                    value:clear()
                    return
                end

                local cat = value:get_ObjectCategory()
                local cat_name = ace_enum.object_access_category[cat]

                if cat_name == "NPC" then
                    if name_access.npc_draw_distance > 0 then
                        local game_object = value:get_GameObject()
                        if game_object then
                            local transform = game_object:get_Transform()
                            local pos = transform:get_Position()

                            if not player_pos then
                                player_pos = access_control:get_PlayerPosition()
                            end

                            if (pos - player_pos):length() > name_access.npc_draw_distance then
                                value:clear()
                                return
                            end
                        end
                    end

                    if
                        (any_npc and name_access.npc_type[ace_enum.interact_npc_type[value:getCurrentNpcType()]])
                        or (
                            any_gossip
                            and name_access.gossip_type[ace_enum.interact_gossip_type[value:getCurrentGossipType()]]
                        )
                    then
                        value:clear()
                        return
                    end
                elseif
                    cat_name == "ENEMY"
                    and not name_access.object_category[cat_name]
                    and hud.get_hud_option("hide_monster_icon")
                then
                    local game_object = value:get_GameObject()
                    if not game_object then
                        return
                    end

                    local char = ace_em.get_char_base(game_object)
                    if not char then
                        return
                    end

                    if ace_em.is_boss(char) and not ace_em.is_paintballed_char(char) then
                        value:clear()
                        return
                    end
                end

                if name_access.object_category[cat_name] then
                    value:clear()
                end
            end
        end)
    end
end

function this.disable_scoutflies_pre(args)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("disable_scoutflies") then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.disable_scoutflies_post(retval)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("disable_scoutflies") then
        return false
    end
end

function this.disable_porter_call_cmd_pre(args)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("disable_porter_call") then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.update_porter_call_post(retval)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("hide_porter") and not hud.get_hud_option("disable_porter_call") then
        timer.restart_key(porter.call_timer_key)
    end
end

function this.hide_porter_post(retval)
    local hud_config = get_hud()
    if not hud_config then
        return
    end

    if
        hud_config
        and hud.get_hud_option("hide_porter")
        and not ace_porter.is_master_riding()
        and timer.check(porter.call_timer_key, config.porter_timeout)
        and not ace_porter.is_master_quest_interrupt()
    then
        if ace_porter.is_master_touch() then
            timer.restart_key(porter.touch_timer_key)
        end

        if
            timer.check(porter.timer_key, config.porter_timeout)
            and (porter.hidden or timer.check(porter.touch_timer_key, config.porter_timeout))
        then
            ace_porter.change_fade_speed(0.5)
            ace_porter.set_master_continue_flag(rl(ace_enum.porter_continue_flag, "DISABLE_RIDE_HUNTER"), true)
            ace_porter.set_master_continue_flag(rl(ace_enum.porter_continue_flag, "ALPHA_ZERO"), true)
            porter.hidden = true
        end
    else
        timer.restart_key(porter.touch_timer_key)
        timer.restart_key(porter.timer_key)
        ace_porter.change_fade_speed(5.0)
        porter.hidden = false
    end
end

function this.hide_handler_post(retval)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("hide_handler") then
        local handler_id_fixed = m.getHandlerNpcIDFixed(true)
        local handler_id = ace_npc.get_npc_id_from_fixed(handler_id_fixed)

        if ace_npc.is_touch(handler_id) then
            timer.restart_key(handler_key)
        elseif timer.check(handler_key, config.handler_timeout) then
            local char_base = ace_npc.get_char_base(handler_id)
            if not char_base then
                return
            end

            ace_npc.set_continue_flag(handler_id, rl(ace_enum.npc_continue_flag, "DISABLE_TALK"), true)
            ace_npc.set_continue_flag(handler_id, rl(ace_enum.npc_continue_flag, "ALPHA_ZERO"), true)

            local handler_porter = ace_porter.get_porter(char_base)
            if not handler_porter then
                return
            end

            ace_porter.set_continue_flag(handler_porter, rl(ace_enum.porter_continue_flag, "DISABLE_RIDE_HUNTER"), true)
            ace_porter.set_continue_flag(handler_porter, rl(ace_enum.porter_continue_flag, "ALPHA_ZERO"), true)
        end
    end
end

function this.hide_danger_line_post(retval)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("hide_danger") then
        local arr = sdk.to_managed_object(retval) --[[@as System.Array<app.AttackAreaResult>]]
        arr:Clear()
    end
end

function this.disable_area_intro_pre(args)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("disable_area_intro") then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.disable_quest_intro_outro_post(retval)
    local hud_config = get_hud()
    if hud_config then
        local GUI020201 = util_ref.get_this() --[[@as app.GUI020201]]
        local type = GUI020201._CurType
        local name = ace_enum.quest_gui_type[type]

        if
            (name == "START" and hud.get_hud_option("disable_quest_intro"))
            or hud.get_hud_option("disable_quest_end_outro")
        then
            local pnl = GUI020201._StampPanels:get_Item(type) --[[@as via.gui.Panel]]
            pnl:set_PlayState("DISABLE")
        end
    end
end

function this.hide_nameplate_post(retval)
    local name_other = get_elem_t("NameOther")
    if name_other and not name_other.hide then
        if name_other.nameplate_type["ALL"] then
            return false
        end

        local GUI020016 = util_ref.get_this() --[[@as app.GUI020016PartsBase]]
        local type = GUI020016:get_Type()
        if name_other.nameplate_type[ace_enum.nameplate_type[type]] then
            return false
        end
    end
end

function this.no_hide_ammo_slider_parts_pre(args)
    local ammo = get_elem_t("Ammo")
    if ammo and not ammo.hide and ammo.no_hide_parts then
        -- setting slider status to Active before its actually open
        -- app.GUI020007.controlSliderStatus closes parts when BulletSliderStatus transitions from Default to Active
        -- or its opened with ctrl
        local GUI020007 = sdk.to_managed_object(args[2]) --[[@as app.GUI020007]]
        local flag = ace_player.check_continue_flag(rl(ace_enum.hunter_continue_flag, "OPEN_ITEM_SLIDER"))
        local open_timer = GUI020007:get__OpenTimer()
        local is_rapid = GUI020007:get_IsRapidMode()

        if (not flag and ammo_slider.item_slider_open) or (not flag and open_timer <= 0 and is_rapid) then
            -- this is necessary when in rapid mode, to avoid fade in of energy bar
            GUI020007:setBulletSliderState("UNFOCUS")
            GUI020007:set__SliderStatus(rl(ace_enum.bullet_slider_status, "Default"))

            -- prevents lingering after opening with ctrl
            GUI020007:set__OpenTimer(0.0)
            ammo_slider.open = false
            ammo_slider.item_slider_open = false
        end

        if GUI020007:get__SliderStatus() == rl(ace_enum.bullet_slider_status, "Default") then
            ammo_slider.open = false
            ammo_slider.item_slider_open = false
        end

        -- opened with scroll
        if open_timer > 0 then
            GUI020007:set__SliderStatus(rl(ace_enum.bullet_slider_status, "Active"))
            ammo_slider.open = true
        end

        -- opened with ctrl
        if flag and not ammo_slider.open then
            ammo_slider.open = true
            ammo_slider.item_slider_open = true

            GUI020007:set__SliderStatus(rl(ace_enum.bullet_slider_status, "Active"))
            -- opening with scroll instead,
            GUI020007:callbackOther(GUI020007.SLOT_DOWN, nil, nil, 0)
            GUI020007:callbackOther(GUI020007.SLOT_UP, nil, nil, 0)
            -- stoping scroll animation
            GUI020007:setBulletSliderState("FOCUS")
        end

        -- function has to be skipped when in rapid mode, something there spams fadein on energy bar,
        -- not sure how else deal with it
        if GUI020007:get_IsRapidMode() then
            local pnl_slider = GUI020007:get__PanelBulletSlider()
            local pnl_pat = play_object.control.get_parent(pnl_slider, "PNL_Pat00") --[[@as via.gui.Control]]
            local pnl_change = play_object.control.get(pnl_pat, "PNL_change") --[[@as via.gui.Control]]

            force_opacity(pnl_change)
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.no_hide_ammo_slider_reload_pre(args)
    local ammo = get_elem_t("Ammo")
    if ammo and not ammo.hide and ammo.no_hide_parts and not ammo.children.reload.hide then
        local GUI020007 = sdk.to_managed_object(args[2]) --[[@as app.GUI020007]]
        local slider_pnl = GUI020007:get__PanelBulletSlider()
        local pnl = play_object.control.get(slider_pnl, {
            "PNL_reload",
        }) --[[@as via.gui.Control]]

        if GUI020007:get__SliderStatus() ~= rl(ace_enum.bullet_slider_status, "Active") then
            return
        end

        local req_playstate = (sdk.to_managed_object(args[3]) --[[@as System.String]]):ToString()
        if req_playstate ~= "FADE_OUT" then
            pnl:set_PlayState("DEFAULT")
            pnl:set_Visible(true)
        else
            pnl:set_PlayState("HIDDEN")
            pnl:set_Visible(false)
        end

        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.disable_quest_end_camera_post(args)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("disable_quest_end_camera") then
        return false
    end
end

function this.hide_icon_out_post(retval)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("hide_monster_icon") then
        local out_frame_target = util_ref.get_this() --[[@as app.cGUI060000OutFrameTarget]]
        local arr = out_frame_target._OutFrameIcons

        if arr then
            util_game.do_something(arr, function(system_array, index, value)
                if value then
                    local beacon = value:get_TargetBeacon()
                    if not beacon or not util_ref.is_a(beacon, "app.cGUIBeaconEM") then
                        return
                    end

                    ---@cast beacon app.cGUIBeaconEM
                    local ctx = beacon:getGameContext()
                    local char = ace_em.ctx_to_char(ctx)

                    if not char then
                        return
                    end

                    if ace_em.is_boss(char) and not ace_em.is_paintballed_ctx(ctx) then
                        value:setVisible(false)
                    end
                end
            end)
        end
    end
end

function this.reveal_monster_icon_post(retval)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("hide_lock_target") then
        return true
    end
end

function this.hide_monster_icon_pre(args)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("hide_monster_icon") then
        local beacon_man = sdk.to_managed_object(args[2]) --[[@as app.GUIMapBeaconManager]]
        local beacons = beacon_man:get_EmBossBeaconContainer()

        util_game.do_something(beacons._BeaconListSafe, function(system_array, index, value)
            local ctx = value:getGameContext()
            if not ace_em.is_paintballed_ctx(ctx) then
                local flags = ctx:get_ContinueFlag()
                flags:on(
                    rl(
                        ace_enum.enemy_continue_flag,
                        hud.get_hud_option("hide_lock_target") and "HIDE_MAP_WITH_DISABLE_PIN" or "HIDE_MAP"
                    )
                )
            end
        end)
    end
end

function this.get_near_monsters_pre(args)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("hide_monster_icon") then
        local pos = sdk.to_valuetype(args[3], "via.vec3") --[[@as via.vec3]]
        local player_pos = Vector3f.new(pos.x, pos.y, pos.z)
        local range = sdk.to_float(args[4])
        local emman = s.get("app.EnemyManager")
        local em_arr = emman._EnemyList:get_Array() --[[@as System.Array<app.cEnemyManageInfo>]]
        local arr = {}

        util_game.do_something(em_arr, function(system_array, index, value)
            if (value:get_Pos() - player_pos):length() <= range then
                local browser = value:get_Browser()
                local ctx = browser:get_EmContext()
                local char = ace_em.ctx_to_char(ctx)
                if char and ace_em.is_boss(char) and ace_em.is_paintballed_ctx(ctx) then
                    table.insert(arr, value)
                end
            end
        end)

        if not util_table.empty(arr) then
            ---@diagnostic disable-next-line: no-unknown
            thread.get_hook_storage()["ret"] = util_game.lua_array_to_system_array(arr, "app.cEnemyManageInfo")
        end
    end
end

function this.get_near_monsters_post(retval)
    local ret = thread.get_hook_storage()["ret"] --[[@as System.Array<app.cEnemyManageInfo>?]]
    if ret then
        return ret
    end
end

function this.hide_recommend_pre(args)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("hide_monster_icon") then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.hide_recommend_post(retval)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("hide_monster_icon") then
        local GUI060000Recommend = util_ref.get_this() --[[@as app.cGUI060000Recommend]]
        util_game.do_something(GUI060000Recommend._RecommendSignParts, function(system_array, index, value)
            value.IsActive = false
        end)
    end
end

function this.skip_monster_select_pre(args)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("hide_monster_icon") then
        local ctx_holder = sdk.to_managed_object(args[3]) --[[@as app.cEnemyContextHolder]]
        local ctx = ctx_holder:get_Em()

        if not ace_em.is_paintballed_ctx(ctx) then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.skip_quest_end_timer_pre(args)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("skip_quest_end_timer") then
        local quest_dir = s.get("app.MissionManager"):get_QuestDirector()
        quest_dir:QuestReturnSkip()
    end
end

function this.skip_quest_end_animation_pre(args)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("disable_quest_end_outro") then
        local flow = sdk.to_managed_object(args[3]) --[[@as app.cQuestFlowPartsBase]]
        local before_flows = {
            "app.cQuestSuccessShowingBefore",
            "app.cQuestLeaveShowingBefore",
            "app.cQuestFailedShowingBefore",
        }
        local flows = {
            "app.cQuestFailedShowing",
            "app.cQuestSuccessShowing",
            "app.cQuestLeaveShowing",
            "app.cQuestResult",
        }

        for _, fl in pairs(before_flows) do
            if util_ref.is_a(flow, fl) then
                -- cba to type those
                flow:set_field("_ShowingBeforeTimer", 0.0)
                return sdk.PreHookResult.SKIP_ORIGINAL
            end
        end

        if util_table.any(flows, function(key, value)
            return util_ref.is_a(flow, value)
        end) then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.hide_quest_result_setup_post(retval)
    local skip, skip_seamless = is_result_skip()
    if not skip and not skip_seamless then
        return
    end

    local flow = util_ref.get_this() --[[@as app.GUIFlowQuestResult.cContext]]
    if skip then
        flow:set_SkipReward(true)
    elseif skip_seamless then
        local mode = flow:getMode()
        if ace_enum.quest_result_mode[mode] == "SEAMLESS" then
            flow:set_SkipReward(true)
        end
    end
end

function this.hide_quest_result_pre(args)
    local skip, skip_seamless = is_result_skip()
    if
        skip
        or (
            skip_seamless
            and util_ref.is_a(
                sdk.to_managed_object(args[2]) --[[@as REManagedObject]],
                "app.GUIFlowQuestResult.Flow.SeamlessResultList"
            )
        )
    then
        util_ref.capture_this(args)
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.hide_quest_result_post(retval)
    local skip, skip_seamless = is_result_skip()
    if not skip and not skip_seamless then
        return
    end

    local flow = util_ref.get_this() --[[@as app.GUIFlowQuestResult.Flow.SeamlessResultList | app.GUIFlowQuestResult.Flow.FixResultList]]
    if skip then
        flow:endFlow()
    elseif skip_seamless and util_ref.is_a(flow, "app.GUIFlowQuestResult.Flow.SeamlessResultList") then
        flow:endFlow()
    end
end

function this.skip_gui_open_pre(args)
    local hud_config = get_hud()
    if
        hud_config
        and (hud.get_hud_option("skip_quest_end_timer"))
        and sdk.to_int64(args[3]) == rl(ace_enum.gui_id, "UI020202")
    then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.hide_quest_end_input(args)
    local GUI020202 = sdk.to_managed_object(args[2]) --[[@as app.GUI020202]]
    local skip_panel = GUI020202._SkipPanel
    local input = GUI020202._Input
    local hud_config = get_hud()

    if
        hud_config
        and (not hud.get_hud_option("skip_quest_end_timer") and hud.get_hud_option("hide_quest_end_timer"))
    then
        input:setEnableCtrl(false)
        skip_panel:set_ForceInvisible(true)
    --FIXME: game does not recreate the gui, so this is necessary, which kind of sucks
    else
        input:setEnableCtrl(true)
        skip_panel:set_ForceInvisible(false)
    end
end

function this.stop_hide_gui_post(retval)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("disable_quest_end_outro") then
        local quest_dir = util_ref.get_this() --[[@as app.cQuestDirector]]
        local flow = quest_dir:get_CurFlow()

        if not flow then
            return
        end

        local flows = {
            "app.cQuestSuccessShowingBefore",
            "app.cQuestSuccessShowing",
            "app.cQuestResult",
        }

        if util_table.any(flows, function(key, value)
            return util_ref.is_a(flow, value)
        end) then
            local guiman = s.get("app.GUIManager")
            local flags = guiman:get_AppContinueFlag()
            flags:off(rl(ace_enum.gui_continue_flag, "HIDE_GUI"))
        end
    end
end

function this.update_subtitles_pre(args)
    if not is_ok() then
        return
    end

    local subtitles_guiid = rl(ace_enum.gui_id, ace_map.additional_hud_to_guiid_name["SUBTITLES"])
    local subtitles_choice_guiid = rl(ace_enum.gui_id, ace_map.additional_hud_to_guiid_name["SUBTITLES_CHOICE"])

    call_queue.consume(subtitles_guiid)
    call_queue.consume(subtitles_choice_guiid)

    local subtitles = get_elem_t("Subtitles")
    if subtitles then
        local subman = sdk.to_managed_object(args[2])--[[@as app.cDialogueSubtitleManager]]
        local GUI020400 = subman._SubtitlesGUI

        if not GUI020400 then
            return
        end

        ---@diagnostic disable-next-line: param-type-mismatch
        subtitles:write(GUI020400, subtitles_guiid, subtitles:get_scale_panel(GUI020400))
    end

    local subtitles_choice = get_elem_t("SubtitlesChoice")
    if subtitles_choice then
        local subman = sdk.to_managed_object(args[2])--[[@as app.cDialogueSubtitleManager]]
        local GUI020401 = subman._ChoiceGUI

        if not GUI020401 then
            return
        end

        ---@diagnostic disable-next-line: param-type-mismatch
        subtitles_choice:write(GUI020401, subtitles_guiid, subtitles_choice:get_scale_panel(GUI020401))
    end
end

function this.set_control_global_pos_pre(args)
    local control = get_elem_t("Control")
    if
        control
        and not control.hide
        and not control.children.control_guide1.hide
        and control.children.control_guide1.offset
        and not util_ref.to_bool(args[3])
    then
        util_ref.capture_this(args)
    end
end

function this.set_control_global_pos_post(retval)
    local GUI020014 = util_ref.get_this() --[[@as app.GUI020014]]
    if GUI020014 then
        local control_guide00 = GUI020014:get__PNL_ControlGuide00()
        local pat = play_object.control.get_parent(control_guide00, "PNL_Pat00") --[[@as via.gui.Control]]

        local pat_default = play_object.default.get_default(pat)
        if not pat_default then
            return
        end

        pat:set_Position(Vector3f.new(pat_default.offset.x, pat_default.offset.y, 0))
    end
end

function this.hide_map_navi_points_post(retval)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("disable_scoutflies") then
        return false
    end
end

function this.update_damage_numbers_post(retval)
    local dmg_guiid = rl(ace_enum.gui_id, ace_map.additional_hud_to_guiid_name["DAMAGE_NUMBERS"])

    call_queue.consume(dmg_guiid)

    local dmg = get_elem_t("DamageNumbers")
    if dmg then
        util_table.do_something(dmg:get_dmg(), function(_, key, _)
            ---@diagnostic disable-next-line: param-type-mismatch
            dmg:write(key, dmg_guiid, nil)
        end)
    end
end

function this.update_training_room_hud_post(retval)
    if not is_ok() then
        return
    end

    local training_room_hud_guiid = rl(ace_enum.gui_id, ace_map.additional_hud_to_guiid_name["TRAINING_ROOM_HUD"])

    call_queue.consume(training_room_hud_guiid)

    local training_room_hud = get_elem_t("TrainingRoomHud")
    if training_room_hud then
        local hudbase = util_ref.get_this() --[[@as app.GUI600100]]
        local ctrl = training_room_hud:get_pnl_all()
        if ctrl then
            ---@diagnostic disable-next-line: param-type-mismatch
            training_room_hud:write(hudbase, hudbase:get_ID(), ctrl)
        end
    end
end

function this.update_name_access_icons_post(retval)
    local name_access = get_elem_t("NameAccess")
    if name_access then
        local GUI020001PanelBase = util_ref.get_this() --[[@as app.GUI020001PanelBase]]
        local params = GUI020001PanelBase:get_Params()
        local owner = params:get_MyOwner()

        name_access:write(owner, owner:get_ID(), GUI020001PanelBase:get_BasePanel())
    end
end

function this.hide_no_talk_npc_pre(args)
    local hud_config = get_hud()
    if hud_config then
        local no_talk = hud.get_hud_option("hide_no_talk_npc")
        local no_facility = hud.get_hud_option("hide_no_facility_npc")

        if not no_talk and not no_facility then
            return
        end

        local npc_base = sdk.to_managed_object(args[2]) --[[@as app.NpcCharacter]]
        if
            (no_facility and ace_npc.is_facility(npc_base) == false)
            or (no_talk and ace_npc.is_talk(npc_base) == false)
        then
            ace_npc.set_continue_flag(npc_base, rl(data.ace.enum.npc_continue_flag, "ALPHA_ZERO"), true)
            ace_npc.set_continue_flag(npc_base, rl(data.ace.enum.npc_continue_flag, "DISABLE_TALK"), true)
        end
    end
end

function this.stop_camp_target_pre(args)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("monster_ignore_camp") then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.stop_camp_damage_post(retval)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("monster_ignore_camp") then
        local gm_break = util_ref.get_this() --[[@as app.mcGimmickBreak]]
        local gm = gm_break:get_OwnerGimmick()
        if util_ref.is_a(gm, "app.Gm100_000") then
            return false
        end
    end
end

function this.hide_small_monsters_pre(args)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("hide_small_monsters") then
        local beacon_man = sdk.to_managed_object(args[2]) --[[@as app.GUIMapBeaconManager]]
        local beacons = beacon_man:get_EmZakoBeaconContainer()

        util_game.do_something(beacons._BeaconListSafe, function(system_array, index, value)
            ace_em.set_continue_flags(
                value:getGameContext(),
                true,
                rl(data.ace.enum.enemy_continue_flag, "DRAW_OFF"),
                rl(data.ace.enum.enemy_continue_flag, "HIDE_MAP_WITH_DISABLE_PIN")
            )
        end)
    end
end

function this.disable_scar_stamp_pre(args)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("disable_scar") then
        local state = sdk.to_int64(args[3]) --[[@as app.cEmModuleScar.cScarParts.STATE]]
        if
            state ~= rl(ace_enum.scar_state, "NONE")
            and state ~= rl(ace_enum.scar_state, "OLD")
            and state ~= rl(ace_enum.scar_state, "HEAL")
        then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.disable_scar_activate_pre(args)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("disable_scar") then
        local state = sdk.to_int64(args[6]) --[[@as app.cEmModuleScar.cScarParts.STATE]]
        if
            state ~= rl(ace_enum.scar_state, "NONE")
            and state ~= rl(ace_enum.scar_state, "OLD")
            and state ~= rl(ace_enum.scar_state, "HEAL")
        then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.disable_scar_state_pre(args)
    local hud_config = get_hud()
    if hud_config and hud.get_hud_option("disable_scar") then
        local state = sdk.to_int64(args[4]) --[[@as app.cEmModuleScar.cScarParts.STATE]]
        if
            state ~= rl(ace_enum.scar_state, "NONE")
            and state ~= rl(ace_enum.scar_state, "OLD")
            and state ~= rl(ace_enum.scar_state, "HEAL")
        then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.reset_hud_default_post(retval)
    play_object.default.clear()
end

function this.reset_progress_default_pre(args)
    local progress = get_elem_t("Progress")

    if progress then
        if progress_reset_arr or progress:get_GUI020018()._MissionDuplicatePanelDataList:get_Count() > 0 then
            progress:reset()
            progress_reset_arr = false
        end
    end
end

function this.reset_progress_mission_pre(args)
    local progress = get_elem_t("Progress")
    if progress then
        progress_reset_arr = true
    end
end

return this
