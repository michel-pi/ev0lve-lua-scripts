-- copyright: https://github.com/michel-pi
-- version: 1.0

local gui_enable = gui.new_checkbox("Enable", "enable", true)
local gui_only_local = gui.new_checkbox("Only on Local Player", "local_only", true)

local gui_footsteps = gui.new_checkbox("Footsteps", "footsteps", true)
local gui_footstep_volume = gui.new_slider("Footstep Volume", "footstep_volume", 100, 1, 100, 1)

local gui_hurt = gui.new_checkbox("Hurt", "hurt", true)
local gui_hurt_volume = gui.new_slider("Hurt Volume", "hurt_volume", 100, 1, 100, 1)

local gui_explode = gui.new_checkbox("Bomb explode", "explode", true)
local gui_explode_volume = gui.new_slider("Explode Volume", "explode_volume", 100, 1, 100, 1)

local gui_defuse = gui.new_checkbox("Bomb defuse", "defuse", true)
local gui_defuse_volume = gui.new_slider("Defuse Volume", "defuse_volume", 100, 1, 100, 1)

local gui_beep = gui.new_checkbox("Bomb beep", "beep", true)
local gui_beep_volume = gui.new_slider("Beep Volume", "beep_volume", 50, 1, 100, 1)

local function play_sound(sound_name, volume)
    if sound_name == "" or nil then return end

    engine_client.exec(string.format("playvol %s %s", sound_name, volume / 100))
end

local function play_random_footstep_sound()
    local name = string.format("minecraft-soundpack/footstep_%s.mp3", tostring(utils.random_int(1, 11)))

    play_sound(name, gui_footstep_volume:get_value())
end

local function is_local_player(user_id)
    local targetIndex = engine_client.get_player_for_userid(user_id)

    if targetIndex == -1 then return false end

    local target = entity_list.get_entity(targetIndex)

    if target == nil then return false end

    local me = entity_list.get_entity(engine_client.get_local_player())

    return me:index() == target:index()
end

local function get_bomb_time(index)
    local bomb = entity_list.get_entity(index)
    local me = entity_list.get_entity(engine_client.get_local_player())

    local tickBase = me:get_prop_float("m_nTickBase") * global_vars.interval_per_tick
    local blow = bomb:get_prop_float("m_flC4Blow")

    return blow - tickBase
end

function on_player_footstep(ev)
    if not gui_footsteps:get_value() then return end

    if ev == nil then return end

    local user_id = ev:get_int('userid', 0)

    if user_id == 0 then return end

    if gui_only_local:get_value() and not is_local_player(user_id) then return end

    play_random_footstep_sound()
end

function on_player_hurt(ev)
    if not gui_hurt:get_value() then return end

    if ev == nil then return end

    local user_id = ev:get_int('userid', 0)

    if user_id == 0 then return end

    if gui_only_local:get_value() and not is_local_player(user_id) then return end

    play_sound("minecraft-soundpack/hurt.mp3", gui_hurt_volume:get_value())
end

function on_bomb_exploded(ev)
    if not gui_explode:get_value() then return end

    if ev == nil then return end

    play_sound("minecraft-soundpack/explode.mp3", gui_explode_volume:get_value())
end

function on_bomb_defused(ev)
    if not gui_defuse:get_value() then return end

    if ev == nil then return end

    play_sound("minecraft-soundpack/fire.mp3", gui_defuse_volume:get_value())
end

function on_bomb_beep(ev)
    if not gui_beep:get_value() then return end

    if ev == nil then return end

    local timeRemaining = get_bomb_time(ev:get_uint64('entindex', 0))

    print(tostring(timeRemaining))

    if timeRemaining < 5.0 then
        play_sound("minecraft-soundpack/creeper.mp3", gui_beep_volume:get_value())
    else
        play_sound("minecraft-soundpack/orb.mp3", gui_beep_volume:get_value())
    end
end