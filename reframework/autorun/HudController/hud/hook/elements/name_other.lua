local ace_npc = require("HudController.util.ace.npc")
local ace_otomo = require("HudController.util.ace.otomo")
local ace_player = require("HudController.util.ace.player")
local ace_porter = require("HudController.util.ace.porter")
local common = require("HudController.hud.hook.common")
local data = require("HudController.data")
local util_ref = require("HudController.util.ref")

local ace_enum = data.ace.enum

local this = {}
local master_pl_pos = Vector3f.new(0, 0, 0)

function this.name_other_update_player_pos_pre()
    local name_other = common.get_elem_t("NameOther")
    if name_other and (name_other.pl_draw_distance > 0 or name_other.pet_draw_distance > 0) then
        master_pl_pos = ace_player.get_master_pos()
    end
end

function this.hide_nameplate_post(retval)
    local name_other = common.get_elem_t("NameOther")
    if name_other and not name_other.hide then
        if name_other.nameplate_type["ALL"] then
            return false
        end

        local GUI020016Part = util_ref.get_this() --[[@as app.GUI020016PartsBase]]
        local type = GUI020016Part:get_Type()
        if name_other.nameplate_type[ace_enum.nameplate_type[type]] then
            return false
        end

        if name_other.pl_draw_distance > 0 and ace_enum.nameplate_type[type] == "PL" then
            ---@cast GUI020016Part app.GUI020016PartsPlayer
            local pl_pos = ace_player.get_pos(GUI020016Part._PlayerManageInfo)
            if (master_pl_pos - pl_pos):length() > name_other.pl_draw_distance then
                return false
            end
        elseif
            name_other.pl_draw_distance > 0 and ace_enum.nameplate_type[type] == "SUPPORT_PL"
        then
            ---@cast GUI020016Part app.GUI020016PartsPlayer
            local npc_pos = ace_npc.get_pos(GUI020016Part._NpcManageInfo)
            if (master_pl_pos - npc_pos):length() > name_other.pl_draw_distance then
                return false
            end
        elseif name_other.pet_draw_distance > 0 and ace_enum.nameplate_type[type] == "SEIKRET" then
            ---@cast GUI020016Part app.GUI020016PartsSeikret
            local porter_pos = ace_porter.get_pos(GUI020016Part._PorterManageInfo)
            if (master_pl_pos - porter_pos):length() > name_other.pet_draw_distance then
                return false
            end
        elseif
            name_other.pet_draw_distance > 0
            and (
                ace_enum.nameplate_type[type] == "OT"
                or ace_enum.nameplate_type[type] == "SUPPORT_OT"
            )
        then
            ---@cast GUI020016Part app.GUI020016PartsOtomo
            local otomo_pos = ace_otomo.get_pos(GUI020016Part._OtomoManageInfo)
            if (master_pl_pos - otomo_pos):length() > name_other.pet_draw_distance then
                return false
            end
        end
    end
end

return this
