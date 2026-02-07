local e = require("HudController.util.game.enum")
local lang = require("HudController.util.game.lang")
local util_ref = require("HudController.util.ref.init")
local util_table = require("HudController.util.misc.table")
---@class MethodUtil
local m = require("HudController.util.ref.methods")

m.addMoney = m.wrap(m.get("app.BasicParamUtil.addMoney(System.Int32, System.Boolean)")) --[[@as fun(money: integer, round: boolean)]]
m.addPoints = m.wrap(m.get("app.BasicParamUtil.addPoint(System.Int32, System.Boolean)")) --[[@as fun(points: integer, round: boolean)]]
m.getItemData = m.wrap(m.get("app.ItemDef.Data(app.ItemDef.ID)")) --[[@as fun(item: app.ItemDef.ID): app.user_data.ItemData.cData]]

local this = {
    ---@type table<string, app.ItemDef.ID>
    local_name_to_item_id = {},
}

local function get_item_map()
    if not util_table.empty(this.local_name_to_item_id) then
        return
    end

    local current_lang = lang.get_language()
    for _, item_id in e.iter("app.ItemDef.ID") do
        local item_data = m.getItemData(item_id)
        local local_name = lang.get_message_local(item_data:get_RawName(), current_lang, true)
        this.local_name_to_item_id[local_name] = item_id
    end
end

---@param item_name string name in in-game lang
---@return app.ItemDef.ID?
function this.get_item_id(item_name)
    get_item_map()
    return this.local_name_to_item_id[item_name]
end

---@param money integer
function this.add_money(money)
    m.addMoney(money, true)
end

---@param points integer
function this.add_points(points)
    m.addPoints(points, true)
end

---@param item app.ItemDef.ID | string name in in-game lang
---@param count integer
function this.add_item(item, count)
    if type(item) == "string" then
        local item_id = this.get_item_id(item)
        if not item_id then
            return
        end

        item = item_id
    end
    ---@cast item app.ItemDef.ID

    local item_info = util_ref.ctor("app.cReceiveItemInfo")
    item_info:set_ItemId(item)
    item_info:set_Num(count)
    item_info:judge(false)

    if item_info:isValid() then
        item_info:receive(false)
    end
end

return this
