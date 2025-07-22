---@class Language
---@field ref Config
---@field files table<string, LanguageFile>
---@field sorted string[]
---@field font integer?
---@field default LanguageFile

---@class LanguageFile
---@field _font {name: string?, size: integer}?

local util_misc = require("HudController.util.misc")
local util_table = require("HudController.util.misc.table")

---@class Language
local this = {
    files = {},
    sorted = {},
}
this.default = {
    _font = {
        name = nil,
        size = 16,
    },
    misc = {
        text_no_hud = "No Hud...",
        text_changed = "Modified",
        text_notification_message = "is now active",
        text_override_notifcation_message = "overridden to",
        text_overridden = "Overridden to",
        text_disabled = "Disabled",
        text_second = "Second",
        text_second_plural = "Seconds",
        text_minute = "Minute",
        text_minute_plural = "Minutes",
        text_yes = "Yes",
        text_no = "No",
        text_rusure = "Are you sure?",
    },
    menu = {
        config = {
            name = "Mod",
            enabled = "Enabled",
            enable_fade = "Enable Fade",
            enable_notification = "Enable Notifications",
            enable_weapon_binds = "Enable Weapon Binds",
            enable_key_binds = "Enable Key Binds",
            disable_weapon_binds_held = "Disable Weapon Binds Held",
            disable_weapon_binds_timed = "Disable Weapon Binds Timed",
            disable_weapon_binds_held_tooltip = "Disable Weapon Binds while Hud key bind is held",
            disable_weapon_binds_timed_tooltip = "Disable Weapon Binds for 30 seconds after Hud key bind is pressed",
            show_order_buttons = "Enable Manual Sorting",
            show_order_buttons_tooltip = "Display sorting buttons for manual element reordering",
        },
        language = {
            name = "Language",
            fallback = "Fallback",
            fallback_tooltip = "Display message in english if key is missing",
        },
        grid = {
            name = "Grid",
            box_draw = "Draw",
            color_center = "Center",
            color_grid = "Grid",
            color_fade = "Fade",
            fade_alpha = "Fade Opacity",
            combo_ratio = "Ratio",
        },
        bind = {
            name = "Bind",
            tooltip_bound = "Already bound to",
            weapon = {
                name = "Weapon",
                name_global = "Global",
                singleplayer = "Singleplayer",
                multiplayer = "Multiplayer",
                game_mode = "Game Mode",
                header_enabled = "",
                header_combat_in = "In Combat",
                header_combat_out = "Out of Combat",
                header_camp = "Village",
                header_weapon_name = "Weapon Name",
                out_of_combat_delay = "Out of Combat Delay",
                in_combat_delay = "In Combat Delay",
                quest_in_combat = "Quest = In Combat",
                ride_ignore_combat = "Riding = Out of Combat",
                ride_ignore_combat_tooltip = "While riding on a Seikret, In Combat state won't trigger",
            },
            key = {
                name = "Key",
                hud = "Hud",
                option = "Option",
                text_default = "Press any key...",
                button_add = "Add",
                button_save = "Save",
                button_remove = "Remove",
                button_cancel = "Cancel",
                button_clear = "Clear",
            },
        },
    },
    hud = {
        button_new = "New",
        button_save = "Save",
        button_remove = "Remove",
        button_rename = "Rename",
        button_import = "Import",
        button_import_tooltip = "Import hud json string from clipboard",
        button_export = "Export",
        button_export_tooltip = "Export hud json string to clipboard",
        combo = "Hud",
        input = "New Name",
        option_disable = "Do Not Change",
        box_mute_gui = "Mute GUI Sounds",
        category_fade = "Fade",
        box_show_notification = "Show notification",
        tooltip_show_notification = "Show notification when switching to this profile",
        box_fade_opacity = "Fade only opacity-modified elements",
        box_fade_opacity_both = "Require this setting in both profiles",
        tooltip_fade_opacity_both = "Apply only when both profiles (the one you are switching out from and the one you are switching to) have it enabled",
        slider_fade_in = "Fade In",
        slider_fade_out = "Fade Out",
        header_hud_options = "Hud Options",
        box_hide_subtitles = "Hide Gossip Subtitles",
        box_disable_scoutflies = "Disable Scoutflies",
        box_disable_porter_call = "Disable Call Seikret Command",
        box_hide_porter = "Hide Seikret",
        category_porter = "Seikret",
        category_profile = "Profile",
        category_general = "General",
        category_monster = "Monster",
        category_player = "Player",
        box_hide_handler = "Hide Handler",
        box_hide_danger = "Hide Danger Line",
        tooltip_hide_danger = "Hide red line indicating fatal attack",
        box_disable_area_intro = "Disable Area Intro",
        box_disable_quest_intro = "Disable Quest Intro",
        box_disable_quest_end_camera = "Disable Quest End Camera",
        box_hide_monster_icon = "Hide Icons",
        box_hide_lock_target = "Hide Lock Target",
        tooltip_hide_monster_icon = "Monster icons are hidden unless paintballed",
        tooltip_hide_lock_target = "Target Lock is hidden and tracking is disabled unless monster is paintballed",
        box_skip_quest_end_timer = "Skip Quest End Timer",
        box_disable_quest_end_outro = "Disable Quest Outro",
        box_hide_quest_end_timer = "Hide Quest End Timer Input",
        category_quest = "Quest",
        category_npc = "Npc",
        box_hide_no_talk_npc = "Hide Non Interactable",
        box_hide_no_facility_npc = "Hide Non Facility",
        box_monster_ignore_camp = "Ignore Camps",
        tooltip_monster_ignore_camp = "Camps can’t be targeted or destroyed by monsters",
        box_hide_small_monsters = "Hide Small Monsters",
        box_disable_scar = "Disable Wounds",
        box_skip_quest_result = "Skip Quest Result",
        tooltip_skip_quest_result = "You still get all rewards",
        box_disable_focus_turn = "Disable Focus Mode Aim",
        box_hide_scar = "Hide Wounds",
        box_show_scar = "Always Display Wounds",
        slider_wound_state = "Wounds",
        box_disable_porter_tracking = "Disable Monster Tracking",
    },
    hud_element = {
        combo = "Hud Element",
        button_add = "Add",
        button_remove = "Remove",
        button_sort = "Sort",
        button_sort_tooltip = "Sort elements alphabetically",
        name = {
            SLINGER_RETICLE = "General Reticle",
            GUN_RETICLE = "Gun Reticle",
            BOW_RETICLE = "Bow Reticle",
            SUBTITLES = "Subtitles",
            SUBTITLES_CHOICE = "Subtitles Choice",
            DAMAGE_NUMBERS = "Damage Numbers",
            PREPARE_WINDOW = "Quest Prepare",
            ROD_RETICLE = "Insect Glaive Reticle",
            TRAINING_ROOM_HUD = "Training Room HUD",
            ACTION_TUTORIAL = "Action Tutorial",
        },
        entry = {
            category_ingame_settings = "Ingame Settings",
            category_children = "Child Elements",
            category_animation = "Animation Settings",
            category_texture = "Texture Settings",
            category_itembar_behavior = "Item Bar Behavior",
            category_expanded_itembar_behavior = "Expanded Item Bar Behavior",
            category_weapon_behavior = "Weapon Behavior",
            category_notice_system = "System Message",
            category_notice_lobby = "Lobby Message",
            category_notice_lobby_target = "Lobby Message Target",
            category_notice_enemy = "Enemy Message Type",
            category_notice_camp = "Camp Message Type",
            category_object_category = "Object Category",
            category_mantle_behavior = "Mantle Behavior",
            category_nameplate_type = "Nameplate Type",
            category_parts_behavior = "Parts Behavior",
            category_radial_behavior = "Radial Behavior",
            category_pallet_behavior = "Pallet Behavior",
            category_npc_behavior = "NPC Behavior",
            category_numbers_behavior = "Numbers Behavior",
            category_slinger_behavior = "Slinger Behavior",
            category_pl_behavior = "Player Behavior",
            category_npc_type = "NPC Type",
            category_gossip_type = "Gossip Type",
            category_panel_type = "Panel Type",
            category_enemy_type = "Enemy Type",
            box_hide_slinger_empty = "Hide When Empty",
            box_enable_box = "Enable Box",
            tooltip_numbers_box = "Scales numbers position to fit inside a box. Disables Offset.",
            box_no_hide = "Do Not Hide",
            box_hide = "Hide",
            box_itembar_disable_right_stick = "Disable Right Stick / Enable Camera Control",
            box_itembar_ammo_visible = "Do Not Hide Ammo",
            box_itembar_slinger_visible = "Do Not Hide Slinger",
            box_itembar_enable_mouse_control = "Enable Mouse Control",
            box_always_visible = "Always Visible",
            box_appear_open = "Appear Open",
            box_always_expanded = "Always Expanded",
            box_itembar_hide_slider = "Hide Slider",
            combo_expanded_itembar_decide_key = "Item Confirm Key",
            slider_expanded_itembar_control = "Navigation",
            expanded_itembar_disable_dpad = "Disable DPad",
            expanded_itembar_disable_face = "Disable Face Buttons",
            box_start_expanded = "Start Expanded",
            box_enable_scale = "Enable Scale",
            box_enable_offset = "Enable Offset",
            box_enable_rotation = "Enable Rotation",
            box_enable_opacity = "Enable Opacity",
            box_enable_size_x = "Enable Size X",
            box_enable_size_y = "Enable Size Y",
            box_enable_color = "Enable Color",
            box_enable_segment = "Enable Layer",
            box_enable_offset_x = "Enable Offset X",
            box_enable_material_width_scale = "Enable Width Scale",
            box_enable_material_anim_speed_scale = "Enable Animation Speed Scale",
            box_enable_material_size_x_scale = "Enable Size X Scale",
            box_enable_material_size_y_scale = "Enable Size Y Scale",
            box_enable_material_side_mag_scale = "Enable Side Position Scale",
            box_enable_material_level_max_scale = "Enable Level Max Scale",
            box_enable_scale9_alpha_channel = "Enable Alpha Channel",
            box_enable_num_offset_x = "Enable Num Offset X",
            box_weapon_no_focus = "No Focus",
            box_enable_scale9_ignore_alpha = "Enable Ignore Alpha",
            box_scale9_ignore_alpha = "Ignore Alpha",
            box_enable_scale9_control_point = "Enable Control Point",
            box_enable_scale9_blend_type = "Enable Blend Type",
            box_align_left = "Align Left",
            box_move_next = "Move Next",
            box_preview_box = "Preview Box",
            box_enable_font_size = "Enable Font Size",
            box_enable_page_alignment = "Enable Alignment",
            box_enable_clock_offset_x = "Enable Clock Offset X",
            tooltip_itembar_move_next = "Move to the next item if slot is empty after use",
            slider_x = "X",
            slider_y = "Y",
            slider_draw_distance = "Draw Distance",
            box_enable_glow_color = "Enable Glow Color",
            box_hide_glow = "Hide Glow",
            size_x = "Height",
            size_y = "Width",
            pos_x = "Pos X",
            pos_y = "Pos Y",
            big = "Big",
            small = "Small",
            category_state_behavior = "State Behavior",
            state = "State",
        },
    },
    hud_subelement = {
        background = "Background",
        frame = "Frame",
        frame_max = "Frame Max",
        frame_base = "Frame Base",
        frame_main = "Frame Main",
        light_start = "Light Start",
        light_end = "Light End",
        gauge = "Gauge",
        skill_list = "Buff List",
        icon = "Icon",
        keybind = "Keybind",
        text = "Text",
        clock = "Clock",
        task = "Task",
        timer = "Timer",
        pin = "Pin",
        mantle = "Mantle",
        limit = "Limit",
        pallet = "Pallet",
        anim_danger = "Danger Animation",
        anim_low_health = "Low Health Animation",
        red_health = "Red Health",
        incoming_health = "Incoming Health",
        axe = "Axe",
        shield = "Shield",
        sword = "Sword",
        phials = "Phials",
        melody = "Melody",
        resonance = "Resonance",
        notice = "Notice",
        notes = "Notes",
        music_left = "Music Left",
        music_right = "Music Right",
        ammo = "Ammo",
        pile = "Pile",
        stamina = "Stamina",
        insect = "Insect",
        buff = "Buff",
        energy = "Energy",
        sp_ammo = "Special Ammo",
        sp_ammo_frame = "Special Ammo Frame",
        reload = "Reload",
        mode_icon = "Mode Icon",
        anim_max = "Max Animation",
        player = "Player",
        other_slinger = "Other Slinger",
        life_line = "Life Line",
        line = "Line",
        line_shadow = "Line Shadow",
        slider = "Slider Item Bar",
        slider_part = "Slider Part",
        all_slider = "Expanded Item Bar",
        background_sword = "Sword Background",
        skill_line = "Skill Line",
        akuma_bar = "Akuma Bar",
        itembar = "Item Bar",
        out_of_range = "Out of Range",
        reticle = "Reticle",
        bow_phials = "Bow Phial",
        light = "Light",
        arrow = "Arrow",
        phial = "Phial",
        bow_icon = "Bow Icon",
        rank = "Rank",
        control_guide = "Control Guide",
        skill_name = "Skill Name",
        reticle_main = "Main Reticle",
        reticle_lockon = "Lock-On Reticle",
        lockon = "Lock-On",
        max_fall = "Max Health Fall",
        point = "Point",
        craft = "Craft Panel",
        center = "Center",
        select = "Select",
        select_base = "Select Base",
        select_arrow = "Select Arrow",
        perform = "Perform",
        out_frame_icon = "Out Frame Icon",
        circle = "Circle",
        horizontal_line = "Horizontal Line",
        wound = "Wound",
        affinity = "Affinity",
        negative_affinity = "Negative Affinity",
        extract = "Extract",
        extract_frame = "Extract Frame",
        damage = "Damage",
        button_guide = "Button Guide",
        command_history = "Command History",
        combo_guide = "Combo Guide",
        capture = "Capture",
        slinger = "Slinger",
        focus = "Focus",
        checkbox = "Checkbox",
        num = "Num",
        guide_assign = "Button Assign",
        base = "Base",
        name_main = "Main Name",
        name_sub = "Sub Name",
        best_timer = "Best Times",
        faint = "Faints",
        quest_timer = "Quest Timer",
        next_line = "Next Line",
        edge = "Edge",
    },
}

---@param config_ref Config
---@return boolean
function this.init(config_ref)
    this.ref = config_ref
    this.load()

    local t = this.files[this.ref.current.gui.lang.file]
    if not t then
        this.ref.current.gui.lang.file = this.ref.default.gui.lang.file
    end

    this.change()
    return true
end

function this.load()
    json.dump_file(this.ref.default_lang_path, this.default)

    local files = fs.glob(string.format([[%s\\lang\\.*json]], this.ref.name))
    for i = 1, #files do
        local file = files[i]
        local fn = file:match("([^/\\]+)$") --[[@as string]]
        local name = fn:match("(.+)%..+$") --[[@as string]]
        this.files[name] = json.load_file(file)
        table.insert(this.sorted, name)
    end

    table.sort(this.sorted)
end

function this.change()
    local t = this.files[this.ref.current.gui.lang.file]
    local font = t._font or {}

    this.font =
        imgui.load_font(font.name or this.default._font.name, font.size or this.default._font.size, { 0x1, 0xFFFF, 0 })
end

---@protected
---@param t table<string, any>
---@param key string
---@param fallback boolean?
---@return string
function this._tr(t, key, fallback)
    ---@type string
    local ret

    if not key:find(".") then
        ret = t[key]
    else
        ret = util_table.get_nested_value(t, util_misc.split_string(key, "%."))
    end

    if not ret and fallback and this.ref.current.gui.lang.file ~= this.ref.default.gui.lang.file then
        return this._tr(this.default, key)
    elseif not ret then
        return string.format("Bad key: %s", key)
    end

    return ret
end

---@param key string
---@return string
function this.tr(key)
    return this._tr(this.files[this.ref.current.gui.lang.file], key, this.ref.current.gui.lang.fallback)
end

return this
