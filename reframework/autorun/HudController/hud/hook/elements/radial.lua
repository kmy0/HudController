local ace_player = require("HudController.util.ace.player")
local common = require("HudController.hud.hook.common")
local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hook_itembar = require("HudController.hud.hook.elements.itembar")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

local this = {}

function this.hide_radial_post(retval)
    local itembar = common.get_elem_t("Itembar")
    if
        itembar
        and itembar.start_expanded
        and (not hook_itembar.expanded.visible or hook_itembar.expanded.frame < 2)
        and ace_player.check_continue_flag(rl(ace_enum.hunter_continue_flag, "OPEN_ITEM_SLIDER"))
    then
        return false
    end

    local shortcut = common.get_elem_t("Radial")
    if not shortcut then
        return
    end

    if shortcut and shortcut.hide then
        return false
    end
end

function this.hide_radial_pallet_pre(args)
    local shortcut = common.get_elem_t("Radial")
    if shortcut and shortcut.children.pallet.hide then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

return this
