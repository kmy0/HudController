local ace_player = require("HudController.util.ace.player")
local custom_condition = require("HudController.hud.bind_condition.conditions.custom")
local e = require("HudController.util.game.enum")

local this = {}
this.__index = this
setmetatable(this, { __index = custom_condition })

function this:new()
    local enum = e.new("app.WeaponDef.KIREAJI_TYPE")
    local sharpness_color = {}

    for name, _ in e.iter("app.WeaponDef.KIREAJI_TYPE") do
        table.insert(sharpness_color, name)
    end

    table.sort(sharpness_color, function(a, b)
        return enum[a] < enum[b]
    end)

    local o = custom_condition.new(self, "Sharpness Color", sharpness_color)
    setmetatable(o, self)
    o.sharpness_color = sharpness_color

    return o
end

function this:update(option_key)
    local char = ace_player.get_master_char()
    if not char then
        return false
    end

    local handling = char:get_WeaponHandling()
    if not handling then
        return false
    end

    local kireaji = handling:get_Kireaji()
    if not kireaji then
        return false
    end

    local sharpness = kireaji:get_CurrentType()
    local option_name = self.sharpness_color[option_key]
    local sharpness_name = e.get("app.WeaponDef.KIREAJI_TYPE")[sharpness]

    return option_name == sharpness_name
end

return this
