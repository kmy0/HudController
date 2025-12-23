local ace_em = require("HudController.util.ace.enemy")
local common = require("HudController.hud.hook.common")
local data = require("HudController.data.init")
local game_data = require("HudController.util.game.data")
local hud = require("HudController.hud.init")
local s = require("HudController.util.ref.singletons")
local util_game = require("HudController.util.game.init")
local util_ref = require("HudController.util.ref.init")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

local this = {}
local clear_map_navi = true

---@return boolean
local function clear_map_navi_lines()
    local guiman = s.get("app.GUIManager")
    local GUI060002Accessor = guiman:get_GUI060002Accessor()
    local GUI060002 = GUI060002Accessor.GUIs:get_Item(0) --[[@as app.GUI060002]]
    local icon_ctrl = GUI060002:get_IconController()
    if icon_ctrl then
        local line_ctrl = icon_ctrl._LineCtrl
        util_game.do_something(line_ctrl._Handlers, function(system_array, index, value)
            value:clearAll()
        end)
        return true
    end
    return false
end

--#region hide_monster_icon
function this.hide_monster_icon_out_post(retval)
    local hud_config = common.get_hud()
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

function this.hide_monster_icon_pre(args)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("hide_monster_icon") then
        if clear_map_navi then
            if clear_map_navi_lines() then
                clear_map_navi = false
            end
        end

        local beacon_man = sdk.to_managed_object(args[2]) --[[@as app.GUIMapBeaconManager]]
        local beacons = beacon_man:get_EmBossBeaconContainer()
        util_game.do_something_dynamic(beacons._BeaconList, function(system_array, index, value)
            local ctx = value:getGameContext()
            if not ace_em.is_paintballed_ctx(ctx) then
                local flags = ctx:get_ContinueFlag()
                flags:on(
                    rl(
                        ace_enum.enemy_continue_flag,
                        hud.get_hud_option("hide_lock_target") and "HIDE_MAP_WITH_DISABLE_PIN"
                            or "HIDE_MAP"
                    )
                )
            end
        end)
    else
        clear_map_navi = true
    end
end

function this.skip_monster_select_pre(args)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("hide_monster_icon") then
        local ctx_holder = sdk.to_managed_object(args[3]) --[[@as app.cEnemyContextHolder]]
        local ctx = ctx_holder:get_Em()

        if not ace_em.is_paintballed_ctx(ctx) then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.reveal_monster_icon_post(retval)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("hide_lock_target") then
        return true
    end
end

--#region fix lock target
function this.get_near_monsters_pre(args)
    local hud_config = common.get_hud()
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
                if
                    char
                    and ace_em.is_boss(char)
                    and (
                        not hud.get_hud_option("hide_lock_target")
                        or ace_em.is_paintballed_ctx(ctx)
                    )
                then
                    table.insert(arr, value)
                end
            end
        end)

        if not util_table.empty(arr) then
            ---@diagnostic disable-next-line: no-unknown
            thread.get_hook_storage()["ret"] =
                util_game.lua_array_to_system_array(arr, "app.cEnemyManageInfo")
        end
    end
end

function this.get_near_monsters_post(retval)
    local ret = thread.get_hook_storage()["ret"] --[[@as System.Array<app.cEnemyManageInfo>?]]
    if ret then
        return ret
    end
end
--#endregion

--#region hide_monster_recommend
function this.hide_monster_recommend_pre(args)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("hide_monster_icon") then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.hide_monster_recommend_post(retval)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("hide_monster_icon") then
        local GUI060000Recommend = util_ref.get_this() --[[@as app.cGUI060000Recommend]]
        util_game.do_something(
            GUI060000Recommend._RecommendSignParts,
            function(system_array, index, value)
                value.IsActive = false
            end
        )
    end
end
--#endregion
--#endregion

function this.hide_small_monsters_pre(args)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("hide_small_monsters") then
        local beacon_man = sdk.to_managed_object(args[2]) --[[@as app.GUIMapBeaconManager]]
        local beacons = beacon_man:get_EmZakoBeaconContainer()

        util_game.do_something_dynamic(beacons._BeaconList, function(system_array, index, value)
            ace_em.destroy_em_ctx(value:get_ContextHolder())
        end)
    end
end

--#region monster_ignore_camp
function this.stop_camp_target_pre(args)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("monster_ignore_camp") then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.stop_camp_damage_post(retval)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("monster_ignore_camp") then
        local gm_break = util_ref.get_this() --[[@as app.mcGimmickBreak]]
        local gm = gm_break:get_OwnerGimmick()
        if util_ref.is_a(gm, "app.Gm100_000") then
            return false
        end
    end
end
--#endregion

return this
