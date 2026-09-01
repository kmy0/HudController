local ace_em = require("HudController.util.ace.enemy")
local common = require("HudController.hud.hook.common")
local e = require("HudController.util.game.enum")
local hud = require("HudController.hud.init")
local util_game = require("HudController.util.game.init")
local util_ref = require("HudController.util.ref.init")

local this = {}

function this.hide_iteractables_post(_)
    local name_access = common.get_elem_t("NameAccess")
    if name_access and (not name_access.hide or hud.get_hud_option("hide_monster_icon")) then
        local access_control = util_ref.get_this() --[[@as app.GUIAccessIconControl]]
        ---@type Vector3f?
        local player_pos
        local any_panel = name_access:any_panel()
        local any_npc = name_access:any_npc()
        local any_gossip = name_access:any_gossip()
        local any_enemy = name_access:any_enemy()

        util_game.do_something(access_control:get_AccessIconInfos(), function(_, _, value)
            if name_access.object_category["ALL"] then
                value:clear()
            else
                if
                    any_panel
                    and name_access.panel_type[e.get("app.GUI020001PanelParams.PANEL_TYPE")[value:getCurrentPanelType()]]
                then
                    value:clear()
                    return
                end

                local cat = value:get_ObjectCategory()
                local cat_name = e.get("app.GUIAccessIconControl.OBJECT_CATEGORY")[cat]
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
                        (
                            any_npc
                            and name_access.npc_type[e.get("app.GUI020001PanelParams.NPC_TYPE")[value:getCurrentNpcType()]]
                        )
                        or (
                            any_gossip
                            and name_access.gossip_type[e.get(
                                "app.GUI020001PanelParams.GOSSIP_TYPE"
                            )[value:getCurrentGossipType()]]
                        )
                    then
                        value:clear()
                        return
                    end
                elseif
                    cat_name == "ENEMY"
                    and any_enemy
                    and not name_access.object_category[cat_name]
                then
                    local game_object = value:get_GameObject()
                    if not game_object then
                        return
                    end

                    local char = ace_em.get_char_base(game_object)
                    if not char then
                        return
                    end

                    if
                        (name_access.enemy_type["ZAKO"] and ace_em.is_small(char))
                        or (name_access.enemy_type["ANIMAL"] and ace_em.is_animal(char))
                        or (name_access.enemy_type["BOSS"] and ace_em.is_boss(char))
                    then
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

return this
