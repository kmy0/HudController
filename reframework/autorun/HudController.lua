local call_queue = require("HudController.hud.call_queue")
local config = require("HudController.config.init")
local config_menu = require("HudController.gui.init")
local data = require("HudController.data.init")
local grid = require("HudController.gui.elements.grid")
local gui_debug = require("HudController.gui.debug")
local hook = require("HudController.hud.hook.init")
local hud = require("HudController.hud.init")
local hud_base = require("HudController.hud.def.hud_base")
local sorter = require("HudController.gui.elements.sorter")
local user = require("HudController.hud.user")
local util = require("HudController.util.init")
local logger = util.misc.logger.g

local init = util.misc.init_chain:new(
    "MAIN",
    config.init,
    data.init,
    util.game.bind.init,
    util.ace.scene_fade.init,
    util.ace.porter.init,
    config_menu.init,
    hud.manager.init,
    hook.init,
    data.mod.init,
    user.init
)
---@class MethodUtil
local m = util.ref.methods

m.getGUIscreenPos = m.wrap(m.get("app.GUIUtilApp.getScreenPosByGrobalPosition(via.vec3)")) --[[@as fun(global_pos: via.vec3): via.vec3]]
m.getWeaponName = m.wrap(m.get("app.WeaponUtil.getWeaponTypeName(app.WeaponDef.TYPE)")) --[[@as fun(weapon_type: app.WeaponDef.TYPE): System.Guid]]
m.setOptionValue = m.wrap(m.get("app.OptionUtil.setOptionValue(app.Option.ID, System.Int32)")) --[[@as fun(option_id: app.Option.ID, option_value: System.Int32)]]
m.getOptionValue = m.wrap(m.get("app.OptionUtil.getOptionValue(app.Option.ID)")) --[[@as fun(option_id: app.Option.ID): System.Int32]]
m.getOptionData = m.wrap(m.get("app.OptionUtil.getOptionData(app.Option.ID)")) --[[@as fun(option_id: app.Option.ID): app.user_data.OptionData.Data]]
m.getPlayObjectFullPath = m.wrap(m.get("app.GUIUtilApp.getFullPath(via.gui.PlayObject)")) --[[@as fun(o: via.gui.PlayObject): System.String]]
m.getItemNum = m.wrap(m.get("app.ItemUtil.getItemNum(app.ItemDef.ID, app.ItemUtil.STOCK_TYPE)")) --[[@as fun(item_id: app.ItemDef.ID, stock_type: app.ItemUtil.STOCK_TYPE): System.Int32]]
-- bool is something story related if false
m.getHandlerNpcIDFixed = m.wrap(m.get("app.NpcPartnerUtil.getCurAdvisorID(System.Boolean)")) --[[@as fun(bool: System.Boolean): app.NpcDef.ID_Fixed]]
m.sendEnemyMessage =
    m.wrap(m.get("app.ChatLogUtil.addEnemyLog(app.EnemyDef.ID, app.ChatDef.ENEMY_LOG_TYPE)")) --[[@as fun(em_id: app.EnemyDef.ID, msg_type: app.ChatDef.ENEMY_LOG_TYPE)]]
m.isGunnerWeapon =
    util.misc.cache.memoize(m.wrap(m.get("app.WeaponUtil.isGunnerWeapon(app.WeaponDef.TYPE)"))) --[[@as fun(weapon_type: app.WeaponDef.TYPE): System.Boolean]]
m.requestMapFilter = m.wrap_obj(
    m.get_by_regex("app.cGUIFilteringSortPartsCtrl", "^<requestFilterSortMenu>.-0") --[[@as REMethodDefinition]]
) --[[@as fun(self: app.cGUIFilteringSortPartsCtrl, control: via.gui.Control?, sel_item: via.gui.SelectItem?, index: System.UInt32)]]

re.on_draw_ui(function()
    if imgui.button(string.format("%s %s", config.name, config.commit)) and init.ok then
        local gui_main = config.gui.current.gui.main
        gui_main.is_opened = not gui_main.is_opened
    end

    if not init.failed then
        local errors = logger:format_errors()
        if errors then
            imgui.same_line()
            imgui.text_colored("Error!", config_menu.state.colors.bad)
            util.imgui.tooltip_exclamation(errors)
        elseif not init.ok then
            imgui.same_line()
            imgui.text_colored("Initializing...", config_menu.state.colors.info)
        end
    else
        imgui.same_line()
        imgui.text_colored("Init failed!", config_menu.state.colors.bad)
    end
end)

re.on_application_entry("BeginRendering", function()
    init:init() -- reframework does not like nested re.on_frame
end)

re.on_frame(function()
    if not init.ok then
        return
    end

    hud.update()

    local config_gui = config.gui.current.gui
    local config_mod = config.current.mod

    if not reframework:is_drawing_ui() then
        config_gui.main.is_opened = false
        config_gui.debug.is_opened = false
    end

    if config_gui.main.is_opened then
        config_menu.draw()
    end

    if config_mod.grid.draw then
        grid.draw()
    end

    if config_gui.debug.is_opened then
        gui_debug.draw()
    end

    if sorter.is_opened then
        sorter.draw()
    end

    config.run_save()
end)

re.on_config_save(function()
    if data.mod.initialized then
        config.save_no_timer_global()
    end
end)
re.on_script_reset(function()
    data.mod.is_reset = true
    hud.clear()
    call_queue.clear()
    hud_base.restore_all_force_invis()
end)
