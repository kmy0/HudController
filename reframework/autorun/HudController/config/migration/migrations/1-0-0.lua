---@diagnostic disable: undefined-field, no-unknown, inject-field, assign-type-mismatch

local migration_base = require("HudController.util.misc.migration_base")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")
local mod_enum = require("HudController.data.mod").enum

---@module "HudController.hud.factory"
local factory = util_misc.lazy_require("HudController.hud.factory")
---@module "HudController.hud.elements.subtitles"
local subtitles = util_misc.lazy_require("HudController.hud.elements.subtitles")
---@module "HudController.hud.elements.quest_end_timer"
local quest_end_timer = util_misc.lazy_require("HudController.hud.elements.quest_end_timer")

local this = migration_base.new("1.0.0")

local bind_option_migration = {
    hide_no_talk_npc = {
        key = "hide_npc",
        value = mod_enum.hide_npc.NO_TALK,
        disabled = mod_enum.hide_npc.DISABLED,
    },
    hide_no_facility_npc = {
        key = "hide_npc",
        value = mod_enum.hide_npc.NO_FACILITY,
        disabled = mod_enum.hide_npc.DISABLED,
    },
    hide_monster_icon = {
        key = "monster_icon",
        value = mod_enum.em_icon.HIDE_ICON,
        disabled = mod_enum.em_icon.DISABLED,
    },
    hide_lock_target = {
        key = "monster_icon",
        value = mod_enum.em_icon.HIDE_ICON_TARGET,
        disabled = mod_enum.em_icon.DISABLED,
    },
    hide_wounds = {
        key = "monster_wound",
        value = mod_enum.em_scar.HIDE,
        disabled = mod_enum.em_scar.DISABLED,
    },
    show_wounds = {
        key = "monster_wound",
        value = mod_enum.em_scar.SHOW,
        disabled = mod_enum.em_scar.DISABLED,
    },
    disable_scar = {
        key = "monster_wound",
        value = mod_enum.em_scar.DISABLE,
        disabled = mod_enum.em_scar.DISABLED,
    },
}

---@param t table<string, boolean>
---@return table<string, integer>
local function bool_table_to_ordered(t)
    local ret = {}
    local keys = util_table.keys(util_table.filter(t, function(_, value)
        return value
    end))
    table.sort(keys)
    for i, key in ipairs(keys) do
        ret[key] = i
    end

    return ret
end

---@param config MainSettings
function this.fns.notice(config)
    for _, profile in pairs(config.mod.hud) do
        for key, elem in pairs(profile.elements or {}) do
            if key == "NOTICE" then
                for _, entry in pairs({
                    "system_log",
                    "lobby_log",
                    "chat_log",
                    "enemy_log",
                    "camp_log",
                    "auto_id",
                }) do
                    elem[entry] = bool_table_to_ordered(elem[entry])
                end
            end
        end
    end
end

---@param config MainSettings
function this.fns.name_access(config)
    for _, profile in pairs(config.mod.hud) do
        for key, elem in pairs(profile.elements or {}) do
            if key == "NAME_ACCESSIBLE" then
                for _, entry in pairs({
                    "object_category",
                    "gossip_type",
                    "npc_type",
                    "panel_type",
                    "enemy_type",
                }) do
                    elem[entry] = bool_table_to_ordered(elem[entry])
                end
            end
        end
    end
end

---@param config MainSettings
function this.fns.name_other(config)
    for _, profile in pairs(config.mod.hud) do
        for key, elem in pairs(profile.elements or {}) do
            if key == "NAME_OTHER" then
                for _, entry in pairs({
                    "nameplate_type",
                }) do
                    elem[entry] = bool_table_to_ordered(elem[entry])
                end
            end
        end
    end
end

---@param config MainSettings
function this.fns.subtitles(config)
    for _, profile in pairs(config.mod.hud) do
        if profile.hide_subtitles or profile.mute_gossip then
            local elem = factory.merge(profile.elements.SUBTITLES or subtitles.get_config()) --[[@as SubtitlesConfig]]

            if profile.hide_subtitles then
                elem.hide_dialogue_type = {
                    GOSSIP = 1,
                    NAGARA = 2,
                }
            end

            if profile.mute_gossip then
                elem.mute_dialogue_type = {
                    GOSSIP = 1,
                    NAGARA = 2,
                }
            end

            profile.elements.SUBTITLES = elem
        end

        profile.hide_subtitles = nil
        profile.mute_gossip = nil
    end
end

---@param config MainSettings
function this.fns.binds(config)
    for _, b in pairs(config.mod.bind.key.hud) do
        b.bound_value = {
            key = b.bound_value,
            value = 0,
        }
        b.trigger_repeat = false
    end

    for _, binds in pairs({
        config.mod.bind.key.option_hud,
        config.mod.bind.key.option_mod,
    }) do
        for _, b in pairs(binds) do
            local old_key = b.bound_value
            local enabled = false

            if b.action_type == "ENABLE" or b.action_type == "TOGGLE" then
                enabled = true
                b.action_type = "SET"
            elseif b.action_type == "TOGGLE_HOLD" then
                enabled = true
                b.action_type = "SET_HOLD"
            elseif b.action_type == "DISABLE" then
                b.action_type = "SET"
            end

            local migration = bind_option_migration[old_key]
            b.bound_value = {
                key = migration and migration.key or old_key,
                value = migration and (enabled and migration.value or migration.disabled)
                    or (enabled and 1 or 0),
            }

            b.trigger_repeat = false
        end
    end
end

---@param config MainSettings
function this.fns.conditions(config)
    for _, b in pairs(config.mod.bind.condition.hud) do
        b.key = b.hud_key
        b.combo_profile = b.combo_hud
        b.expected_result = 1
    end
end

---@param config MainSettings
function this.fns.quest_end_timer(config)
    for _, profile in pairs(config.mod.hud) do
        if profile.skip_quest_end_timer or profile.hide_quest_end_timer then
            local elem =
                factory.merge(profile.elements.QUEST_END_TIMER or quest_end_timer.get_config()) --[[@as QuestEndTimerConfig]]

            if profile.skip_quest_end_timer then
                elem.quest_end_timer = mod_enum.quest_end_timer.SKIP
            elseif profile.hide_quest_end_timer then
                elem.quest_end_timer = mod_enum.quest_end_timer.HIDE
            end

            profile.elements.QUEST_END_TIMER = elem
        end
    end
end

---@param config MainSettings
function this.fns.hud_options(config)
    for _, profile in pairs(config.mod.hud) do
        if profile.hide_monster_icon and profile.hide_lock_target then
            profile.monster_icon = mod_enum.em_icon.HIDE_ICON_TARGET
        elseif profile.hide_monster_icon then
            profile.monster_icon = mod_enum.em_icon.HIDE_ICON
        else
            profile.monster_icon = mod_enum.em_icon.DISABLED
        end

        if profile.hide_no_talk_npc then
            profile.hide_npc = mod_enum.hide_npc.NO_TALK
        elseif profile.hide_no_facility_npc then
            profile.hide_npc = mod_enum.hide_npc.NO_FACILITY
        else
            profile.hide_npc = mod_enum.hide_npc.DISABLED
        end

        if profile.hide_wounds then
            profile.monster_wound = mod_enum.em_scar.HIDE
        elseif profile.show_wounds then
            profile.monster_wound = mod_enum.em_scar.SHOW
        elseif profile.disable_scar then
            profile.monster_wound = mod_enum.em_scar.DISABLE
        else
            profile.monster_wound = mod_enum.em_scar.DISABLED
        end

        profile.hide_monster_icon = nil
        profile.hide_lock_target = nil

        profile.hide_no_talk_npc = nil
        profile.hide_no_facility_npc = nil

        profile.hide_wounds = nil
        profile.show_wounds = nil
        profile.disable_scar = nil
    end
end

---@param config MainSettings
function this.fns.hud_config(config)
    local function f(elem_config)
        if elem_config.enabled_scale ~= nil then
            elem_config.scale = {
                enabled = elem_config.enabled_scale,
                x = elem_config.scale.x,
                y = elem_config.scale.y,
            }
            elem_config.enabled_scale = nil
        end

        if elem_config.enabled_offset ~= nil then
            elem_config.offset = {
                enabled = elem_config.enabled_offset,
                x = elem_config.offset.x,
                y = elem_config.offset.y,
            }
            elem_config.enabled_offset = nil
        end

        if elem_config.enabled_rot ~= nil then
            elem_config.rot = {
                enabled = elem_config.enabled_rot,
                value = elem_config.rot,
            }
            elem_config.enabled_rot = nil
        end

        if elem_config.enabled_color ~= nil then
            elem_config.color = {
                enabled = elem_config.enabled_color,
                value = elem_config.color,
            }
            elem_config.enabled_color = nil
        end

        if elem_config.enabled_size_x ~= nil then
            elem_config.size_x = {
                enabled = elem_config.enabled_size_x,
                value = elem_config.size_x,
            }
            elem_config.enabled_size_x = nil
        end

        if elem_config.enabled_size_y ~= nil then
            elem_config.size_y = {
                enabled = elem_config.enabled_size_y,
                value = elem_config.size_y,
            }
            elem_config.enabled_size_y = nil
        end

        if elem_config.enabled_opacity ~= nil then
            elem_config.opacity = {
                enabled = elem_config.enabled_opacity,
                value = elem_config.opacity,
            }
            elem_config.enabled_opacity = nil
        end

        if elem_config.enabled_segment ~= nil then
            elem_config.segment = {
                enabled = elem_config.enabled_segment,
                value = elem_config.segment,
            }
            elem_config.enabled_segment = nil
        end

        if elem_config.enabled_play_state ~= nil then
            elem_config.play_state = {
                enabled = elem_config.enabled_play_state,
                value = elem_config.play_state,
            }
            elem_config.enabled_play_state = nil
        end

        if elem_config.enabled_color_scale ~= nil then
            elem_config.color_scale = {
                enabled = elem_config.enabled_color_scale,
                x = elem_config.color_scale.x,
                y = elem_config.color_scale.y,
                z = elem_config.color_scale.z,
            }
            elem_config.enabled_color_scale = nil
        end

        for i = 0, 4 do
            local key = "var" .. i
            local enabled_key = "enabled_" .. key

            if elem_config[enabled_key] ~= nil then
                local var = elem_config[key]

                elem_config[key] = {
                    enabled = elem_config[enabled_key],
                    name_key = var.name_key,
                    key = key,
                    value = var.value,
                }

                elem_config[enabled_key] = nil
            end
        end

        if elem_config.enabled_control_point ~= nil then
            elem_config.control_point = {
                enabled = elem_config.enabled_control_point,
                value = elem_config.control_point,
            }
            elem_config.enabled_control_point = nil
        end

        if elem_config.enabled_blend ~= nil then
            elem_config.blend = {
                enabled = elem_config.enabled_blend,
                value = elem_config.blend,
            }
            elem_config.enabled_blend = nil
        end

        if elem_config.enabled_alpha_channel ~= nil then
            elem_config.alpha_channel = {
                enabled = elem_config.enabled_alpha_channel,
                value = elem_config.alpha_channel,
            }
            elem_config.enabled_alpha_channel = nil
        end

        if elem_config.enabled_ignore_alpha ~= nil then
            elem_config.ignore_alpha = elem_config.enabled_ignore_alpha
            elem_config.enabled_ignore_alpha = nil
        end

        if elem_config.enabled_glow_color ~= nil then
            elem_config.glow_color = {
                enabled = elem_config.enabled_glow_color,
                value = elem_config.glow_color,
            }
            elem_config.enabled_glow_color = nil
        end

        if elem_config.enabled_font_size ~= nil then
            elem_config.font_size = {
                enabled = elem_config.enabled_font_size,
                value = elem_config.font_size,
            }
            elem_config.enabled_font_size = nil
        end

        if elem_config.enabled_page_alignment ~= nil then
            elem_config.page_alignment = {
                enabled = elem_config.enabled_page_alignment,
                value = elem_config.page_alignment,
            }
            elem_config.enabled_page_alignment = nil
        end

        if elem_config.enabled_offset_x ~= nil then
            elem_config.offset_x = {
                enabled = elem_config.enabled_offset_x,
                value = elem_config.offset_x,
            }
            elem_config.enabled_offset_x = nil
        end

        if elem_config.enabled_clock_offset_x ~= nil then
            elem_config.clock_offset_x = {
                enabled = elem_config.enabled_clock_offset_x,
                value = elem_config.clock_offset_x,
            }
            elem_config.enabled_clock_offset_x = nil
        end

        if elem_config.enabled_num_offset_x ~= nil then
            elem_config.num_offset_x = {
                enabled = elem_config.enabled_num_offset_x,
                value = elem_config.num_offset_x,
            }
            elem_config.enabled_num_offset_x = nil
        end

        if elem_config.enabled_box ~= nil then
            elem_config.box = {
                enabled = elem_config.enabled_box,
                x = elem_config.box.x,
                y = elem_config.box.y,
                w = elem_config.box.w,
                h = elem_config.box.h,
            }
            elem_config.enabled_box = nil
        end

        if elem_config.enabled_fov ~= nil then
            elem_config.fov_map = {
                enabled = elem_config.enabled_fov,
                value = elem_config.fov_map,
            }
            elem_config.enabled_fov = nil
        end

        if elem_config.enabled_icon_scale ~= nil then
            elem_config.scale_icon = {
                enabled = elem_config.enabled_icon_scale,
                value = elem_config.scale_icon,
            }
            elem_config.enabled_icon_scale = nil
        end

        if elem_config.enabled_rot_map ~= nil then
            elem_config.rot_map = {
                enabled = elem_config.enabled_rot_map,
                value = elem_config.rot_map,
            }
            elem_config.enabled_rot_map = nil
        end

        if elem_config.enabled_angle_map ~= nil then
            elem_config.angle_map = {
                enabled = elem_config.enabled_angle_map,
                value = elem_config.angle_map,
            }
            elem_config.enabled_angle_map = nil
        end

        for _, child in pairs(elem_config.children or {}) do
            f(child)
        end
    end

    for _, profile in pairs(config.mod.hud) do
        for _, elem_config in pairs(profile.elements) do
            f(elem_config)
        end
    end

    for _, profile in pairs(config.mod.hud) do
        local minimap = profile.elements.MINIMAP
        if minimap then
            local classic_minimap = minimap.children.classic_minimap
            classic_minimap.enabled_classic_minimap = minimap.enabled_classic_minimap
            classic_minimap.hide_pl_pulse = minimap.pl_icon_pulse.play_state.enabled
            minimap.front = nil
            minimap.mask = nil
            minimap.pl_icon_pulse = nil
            minimap.enabled_classic_minimap = nil
        end
    end
end

return this
