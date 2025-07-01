local config = require("HudController.config")
local data = require("HudController.data")
local state = require("HudController.gui.state")
local util_ace = require("HudController.util.ace")
local util_game = require("HudController.util.game")

local rl = util_game.data.reverse_lookup
local ace_enum = data.ace.enum

local this = {}

function this.draw()
    local screen_size = util_game.get_screen_size()
    local center_x = screen_size.x / 2
    local center_y = screen_size.y / 2
    local grid_size = config.grid_size / tonumber(state.grid_ratio[config.current.mod.grid.combo_grid_ratio])
    local grid_x = math.ceil(screen_size.x / grid_size)
    local grid_y = math.ceil(screen_size.y / grid_size)

    for i = 0, grid_x do
        local x = i * grid_size

        if i == grid_x then
            x = x - 1
        end

        draw.line(x, 0, x, screen_size.y, config.current.mod.grid.color_grid)
    end

    for i = 0, grid_y do
        local y = i * grid_size

        if i == grid_y then
            y = y - 1
        end

        draw.line(0, y, screen_size.x, y, config.current.mod.grid.color_grid)
    end

    draw.line(center_x, 0, center_x, screen_size.y, config.current.mod.grid.color_center)
    draw.line(0, center_y, screen_size.x, center_y, config.current.mod.grid.color_center)

    util_ace.scene_fade.set(
        config.current.mod.grid.fade_alpha,
        config.current.mod.grid.color_fade,
        --FIXME: both of those have the same enum and i cba to cover this edge case :)
        rl(ace_enum.draw_segment, "LOWEST") or rl(ace_enum.draw_segment, "HUD_WORLD")
    )
end

return this
