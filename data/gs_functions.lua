require('gs_tables')

local weapons_changed = false
local mode_changed = false

local danger_up = nil

local function tchelper(first, rest)
    return first:upper()..rest:lower()
end

function title_case(str)
    str = str:gsub("(%a)([%w_']*)", tchelper)
    return str
end

function set_key_binds()
    -- CTRL + FKey cycles various gearing modes
    send_command('bind ^f7 gs c melee') 
    send_command('bind ^f8 gs c ranged') 
    send_command('bind ^f9 gs c ws')
    send_command('bind ^f10 gs c magic')
    send_command('bind ^f11 gs c interrupt')
    send_command('bind ^f12 gs c idle') 

    -- ALT + FKey cycles enmity and pet settings
    send_command('bind !f7 gs c enmity') 
    send_command('bind !f10 gs c pettype') 
    send_command('bind !f11 gs c petpriority') 
    send_command('bind !f12 gs c petdt')

    -- Win + FKey Toggle various special modes
    send_command('bind @f7 gs c cp')
    send_command('bind @f8 gs c th')
    send_command('bind @f12 gs c gearup')

    -- Shift + FKey Toggle various base gear options
    send_command('bind ~f7 gs c weapon_f') 
    send_command('bind ^~f7 gs c weapon_b') 
    send_command('bind ~f8 gs c dual')
    send_command('bind ~f9 gs c dt')
    send_command('bind ~f10 gs c pdt')
    send_command('bind ~f11 gs c mdt')
    send_command('bind ~f12 gs c meva')
end

function load_settings()
    danger = config.load('data\\settings\\danger.xml', danger_defaults)
    settings = config.load('data\\settings\\'..player.name..'_'..player.main_job..'.xml', defaults)
    settings.job = settings.job or {
        cure_potency=0,
        waltz_potency=0,
    }
end

function load_gear_file()
    local path = windower.addon_path.."data/"
    local file = 'default_gear'
    local file_found = false
    
    if (windower.file_exists(path..player.name.."/"..player.name.."_"..player.main_job.."_"..player.sub_job.."_gear"..".lua")) then
        file = player.name.."/"..player.name.."_"..player.main_job.."_"..player.sub_job.."_gear"..".lua"
        file_found = true
    elseif (windower.file_exists(path..player.name.."/"..player.main_job.."_"..player.sub_job.."_gear"..".lua")) then
        file = player.name.."/"..player.main_job.."_"..player.sub_job.."_gear"..".lua"
        file_found = true
    elseif (windower.file_exists(path..player.name.."/"..player.name.."_"..player.main_job.."_gear"..".lua")) then
        file = player.name.."/"..player.name.."_"..player.main_job.."_gear"..".lua"
        file_found = true
    elseif (windower.file_exists(path..player.name.."/"..player.main_job.."_gear"..".lua")) then
        file = player.name.."/"..player.main_job.."_gear"..".lua"
        file_found = true
    elseif (windower.file_exists(path..player.name.."_"..player.main_job.."_"..player.sub_job.."_gear"..".lua")) then
        file = player.name.."_"..player.main_job.."_"..player.sub_job.."_gear"..".lua"
        file_found = true
    elseif (windower.file_exists(path..player.name.."_"..player.main_job.."_gear"..".lua")) then
        file = player.name.."_"..player.main_job.."_gear"..".lua"
        file_found = true
    end
    if (file_found) then
        include(file)
        print("Gear File Loaded: "..file)
    else
        include('default_gear.lua')
        print("Loaded: default_gear.lua")
    end
end

function init_gui()
    gui = texts.new(defaults.gui, defaults)
    gui:append('Wpn ([C]S+F7): ${weapon_set|Unk} |')
    gui:append('Idl (C+F12): ${idle_type|Unk} |')
    gui:append('Mle (C+F7): ${melee_type|Unk} |')
    
    if (T{'WAR','THF','NIN','COR','RNG','DNC'}:contains(player.main_job) or T{'WAR','THF','NIN','COR','RNG','DNC'}:contains(player.sub_job)) then
        gui:append('Rng (C+F8): ${ranged_type|Unk} |')
    end
    gui:append('WS (C+F9): ${ws_type|Unk} |')
    
    if (T{'WHM','BLM','RDM','PLD','DRK','BRD','NIN','SMN','BLU','SCH','GEO','RUN'}:contains(player.main_job) or T{'WHM','BLM','RDM','PLD','DRK','BRD','NIN','SMN','BLU','SCH','GEO','RUN'}:contains(player.sub_job)) then
        gui:append('Mgc (C+F10/F11): ${magic_type|Unk} ${magic_si|Unk} |')
    end
    
    if (T{'NIN','DNC','THF','BLU'}:contains(player.main_job) or T{'NIN','DNC'}:contains(player.sub_job)) then
        gui:append('DW (S+F8): ${dual_wield|Unk} |')
    end
    
    if (T{'BST','SMN','PUP','GEO'}:contains(player.main_job)) then
        gui:append('Pet (A+F10~F12): ${pet_type|Unk} ${pet_priority|Unk} ${pet_dt|Unk} |')
    end

    gui:append('DT (S+F9~F12): ${dt_type|Unk} ${dt_meva|Unk} |')
    gui:append('Enm (A+F7): ${enmity_type|Unk} |')
    
    if (T{'THF','RNG'}:contains(player.main_job) or T{'THF'}:contains(player.sub_job)) then
        gui:append('TH (W+F8): ${th|Unk} |')
    end

    if (modes.stance and modes.stance.name) then
        gui:append('Stance: ${stance|None} |')
    end

    gui:append('CP (W+F7): ${cp|Unk} |')
    gui:append('G.Up (W+F12)')
    
    update_gui()
    gui:show()
end

function update_gui()
    if (gui == nil) then
        init_gui()
    end

    if (modes ~= nil) then
        gui.stance = modes.stance and modes.stance.name or "None"
        gui.weapon_set = modes.weapons.set
        gui.melee_type = modes.melee.type
        gui.ranged_type = modes.ranged.type
        gui.magic_type = modes.magic.type
        gui.magic_si = modes.interrupt.type
        gui.ws_type = modes.ws.type
        gui.enmity_type = modes.enmity.type == "Up" and "Up " or modes.enmity.type
        gui.idle_type = modes.idle.type
        gui.dt_type = modes.dt.type == "DT" and "DT " or modes.dt.type
        gui.dt_meva = modes.dt.meva == "MEva" and "MEv" or modes.dt.meva
        gui.dual_wield = modes.dual_wield.active and "Yes" or "Off"
        gui.th = modes.th.active and "Yes" or "Off"
        gui.cp = modes.cp.active and "Yes" or "Off"
        gui.pet_type = modes.pet.type
        gui.pet_dt = modes.pet.dt.type == "DT" and "DT " or modes.pet.dt.type
        gui.pet_priority = modes.pet.priority
    end
end

function rotate_weapons_forward()
    local next = false
    local new_weapon_set, first = nil, nil
    for k,v in pairs(sets.Weapons) do
        if next == true then
            new_weapon_set = k
            break
        end
        if first == nil then
            first = k
        end
        if modes.weapons.set == k then
            next = true
        end
    end
    if new_weapon_set == nil then
        new_weapon_set = first
    end
    if new_weapon_set ~= nil then
        if sets.Weapons[new_weapon_set] then
            modes.weapons.set = new_weapon_set
            weapons_changed = true
        end
    end
end

function rotate_weapons_backward()
    local prev = nil
    local first = nil
    local new_weapon_set, first = nil, nil
    for k,v in pairs(sets.Weapons) do
        if (first == nil) then
            first = K
        end
        if modes.weapons.set == k then
            new_weapon_set = prev
        end
        prev = k
    end
    if new_weapon_set == nil then
        new_weapon_set = prev
    end
    if new_weapon_set ~= nil then
        if sets.Weapons[new_weapon_set] then
            modes.weapons.set = new_weapon_set
        end
    end    
end

function rotate_idle_forward()
    local next = false
    local new_idle_mode, first = nil, nil
    for k,v in pairs(idle_set_names) do
        if next == true then
            new_idle_mode = k
            break
        end
        if first == nil then
            first = k
        end
        if modes.idle.type == k then
            next = true
        end
    end
    if new_idle_mode == nil then
        new_idle_mode = first
    end
    if new_idle_mode ~= nil then
        modes.idle.type = new_idle_mode
    end
end

function rotate_melee_forward()
    local next = false
    local new_melee_mode, first = nil, nil
    for k,v in pairs(melee_set_names) do
        if next == true then
            new_melee_mode = k
            break
        end
        if first == nil then
            first = k
        end
        if modes.melee.type == k then
            next = true
        end
    end
    if new_melee_mode == nil then
        new_melee_mode = first
    end
    if new_melee_mode ~= nil then
        modes.melee.type = new_melee_mode
    end
end

function rotate_ranged_forward()
    local next = false
    local new_ranged_mode, first = nil, nil
    for k,v in pairs(ranged_set_names) do
        if next == true then
            new_ranged_mode = k
            break
        end
        if first == nil then
            first = k
        end
        if modes.ranged.type == k then
            next = true
        end
    end
    if new_ranged_mode == nil then
        new_ranged_mode = first
    end
    if new_ranged_mode ~= nil then
        modes.ranged.type = new_ranged_mode
    end
end

function rotate_ws_forward()
    local next = false
    local new_ws_mode, first = nil, nil
    for k,v in pairs(ws_set_names) do
        if next == true then
            new_ws_mode = k
            break
        end
        if first == nil then
            first = k
        end
        if modes.ws.type == k then
            next = true
        end
    end
    if new_ws_mode == nil then
        new_ws_mode = first
    end
    if new_ws_mode ~= nil then
        modes.ws.type = new_ws_mode
    end
end

function rotate_magic_forward()
    local next = false
    local new_magic_mode, first = nil, nil
    for k,v in pairs(magic_set_names) do
        if next == true then
            new_magic_mode = k
            break
        end
        if first == nil then
            first = k
        end
        if modes.magic.type == k then
            next = true
        end
    end
    if new_magic_mode == nil then
        new_magic_mode = first
    end
    if new_magic_mode ~= nil then
        modes.magic.type = new_magic_mode
    end
end

function rotate_pet_type_forward()
    local next = false
    local new_pet_type, first = nil, nil
    for k,v in pairs(pet_type_names) do
        if next == true then
            new_pet_type = v
            break
        end
        if first == nil then
            first = v
        end
        if modes.pet.type == v then
            next = true
        end
    end
    if new_pet_type == nil then
        new_pet_type = first
    end
    if new_pet_type ~= nil then
        modes.pet.type = new_pet_type
    end
end


----[[[[ In Town Check ]]]]----
function in_town()
    local zone = gearswap.res.zones[windower.ffxi.get_info().zone].en
    if cities:contains(zone) then
        return true
    end
    return false
end

----[[[[ Check for disabled states]]]]
function buff_active(id)
    if T(windower.ffxi.get_player().buffs):contains(id) == true then
        return true
    end
    return false
end

function is_disabled()
    if (buff_active(0)) then -- KO
        return true
    elseif (buff_active(2)) then -- Sleep
        return true
    elseif (buff_active(6)) then -- Silence
        return true
    elseif (buff_active(7)) then -- Petrification
        return true
    elseif (buff_active(10)) then -- Stun
        return true
    elseif (buff_active(14)) then -- Charm
        return true
    elseif (buff_active(28)) then -- Terrorize
        return true
    elseif (buff_active(29)) then -- Mute
        return true
    elseif (buff_active(193)) then -- Lullaby
        return true
    elseif (buff_active(262)) then -- Omerta
        return true
    end
    return false
end


----[[[[ Calculate Haste/Flurry Gear Needed ]]]]----
function calc_haste()
    local haste_val, mhaste, haste_needed, dw_needed = 0, 0, 25, 100

    if (buffactive[580]) then
        haste_val = haste_val + 30
    elseif (buffactive["Haste"]) then
        haste_val = haste_val + 15
    end
    if (buffactive["Refueling"]) then
        haste_val = haste_val + 10
    end
    if (buffactive["Animating Wail"]) then
        haste_val = haste_val + 15
    end
    if (buffactive["Mighty Guard"]) then
        haste_val = haste_val + 15
    end
    if (buffactive["Erratic Flutter"]) then
        haste_val = haste_val + 30
    end
    if (buffactive["Advancing March"]) then
        haste_val = haste_val + 15
    end
    if (buffactive["Victory March"]) then
        haste_val = haste_val + 25
    end
    if (buffactive["Honor March"]) then
        haste_val = haste_val + 15
    end
    if (buffactive["Indi-Haste"]) then
        haste_val = haste_val + 30
    end
    if (buffactive["Geo-Haste"]) then
        haste_val = haste_val + 30
    end
    mhaste = haste_val <= 43.75 and haste_val or 43.75
    haste_val = 0

    if (buffactive["Hasso"]) then
        haste_val = haste_val + 10
    end
    if (buffactive["Haste Samba"]) then
        haste_val = haste_val + 5
        if (player.main_job == "DNC") then
            haste_val = haste_val + 10
        end
    end
    if (buffactive["Last Resort"]) then
        haste_val = haste_val + 15
        if (player.main_job == "DRK") then
            if (windower.ffxi.get_player().merits["Desperate Blows"] ~= nil) then
                haste_val = haste_val + windower.ffxi.get_player().merits["Desperate Blows"] * 2
            end
        end
    end
    if (buffactive['Aftermath'] and player.equipment.main == "Apocalypse") then
        haste_val = haste_val + 10
    end
    if (player.main_job=="DRG" and pet.name ~= nil) then
        haste_val = haste_val + 10
    end

    haste_val = mhaste + (haste_val <= 25 and haste_val or 25)
    if (haste_val >= 70) then
        haste_needed = 10
    elseif (haste_val >= 65) then
        haste_needed = 15
    elseif (haste_val >= 60) then
        haste_needed = 20
    else
        haste_needed = 25
    end

    if (T{'NIN','DNC','THF'}:contains(player.main_job)) then
        if (haste_val <= 0) then
            dw_needed = 39
        elseif (haste_val <= 5) then
            dw_needed = 37
        elseif (haste_val <= 10) then
            dw_needed = 35
        elseif (haste_val <= 15) then
            dw_needed = 32
        elseif (haste_val <= 20) then
            dw_needed = 29
        elseif (haste_val <= 25) then
            dw_needed = 25
        elseif (haste_val <= 30) then
            dw_needed = 21
        elseif (haste_val <= 35) then
            dw_needed = 15
        elseif (haste_val <= 40) then
            dw_needed = 7
        elseif (haste_val <= 45) then
            dw_needed = 1
        end
    elseif (T{'NIN','DNC','THF'}:contains(player.sub_job) or player.main_job == "BLU") then
        if (haste_val <= 0) then
            dw_needed = 49
        elseif (haste_val <= 5) then
            dw_needed = 47
        elseif (haste_val <= 10) then
            dw_needed = 45
        elseif (haste_val <= 15) then
            dw_needed = 42
        elseif (haste_val <= 20) then
            dw_needed = 39
        elseif (haste_val <= 25) then
            dw_needed = 35
        elseif (haste_val <= 30) then
            dw_needed = 31
        elseif (haste_val <= 35) then
            dw_needed = 25
        elseif (haste_val <= 40) then
            dw_needed = 17
        elseif (haste_val <= 45) then
            dw_needed = 11
        elseif (haste_val <= 50) then
            dw_needed = 5
        end
    end            
    return haste_needed, dw_needed
end

function calc_flurry()
    local snapshot_val = 0
    local snapshot_needed = 70

    if (buffactive[581]) then
        snapshot_val = snapshot_val + 30
    elseif (buffactive["Flurry"]) then
        snapshot_val = snapshot_val + 15
    end
    if (buffactive["Courser's Roll"]) then
        snapshot_val = snapshot_val + 10
    end
    if (buffactive["Embrava"]) then
        snapshot_val = snapshot_val + 10
    end
    if (player.main_job=="COR") then
        snapshot_val = snapshot_val + 10
    end

    if (snapshot_val >= 70) then
        snapshot_needed = 0
    elseif (snapshot_val >= 60) then
        snapshot_needed = 10
    elseif (snapshot_val >= 50) then
        snapshot_needed = 20
    elseif (snapshot_val >= 40) then
        snapshot_needed = 30
    elseif (snapshot_val >= 30) then
        snapshot_needed = 40
    elseif (snapshot_val >= 20) then
        snapshot_needed = 50
    elseif (snapshot_val >= 10) then
        snapshot_needed = 60
    else
        snapshot_needed = 70
    end
    return snapshot_needed
end

----[[[[ Maneuver Maintenance ]]]]----
function apply_maneuver(manuever)
    if (manuever == nil) then
        return
    end
end

----[[[[ Stance Maintenance ]]]]----
function apply_stance(stance)
    if (modes.verbose.active) then
        windower.add_to_chat(207, "Stance Maint. re-applying stance: "..stance.name)
    end
    if (not stance or not stance.name or not stance.cmd) then return end

    if (buffactive[stance.name]) then
        return
    elseif (player.status_id <= 1 and not is_disabled() and not in_town()) then
        windower.send_command("input "..stance.cmd)
    end
end

----[[[[ Reactions for Danger, Statuses, etc. ]]]]----
function face_target(mob, turn_away) 
	local target = {}
	local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)

    if (turn_away == nil) then
        turn_away = false
    end

    if mob then 
		target = mob
	else 
		target = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().target_index or 0)
	end

    if target then  -- Pleaes note if you target yourself you will face due West
        local angle = (math.atan2((target.y - self_vector.y), (target.x - self_vector.x))*180/math.pi)*-1
        angle = (angle+(turn_away == true and 180 or 0))
        local rads = angle:radian()
		windower.ffxi.turn(rads)
        if (modes.verbose.active) then
            windower.add_to_chat(207, "Facing "..(turn_away and "Away from " or "Towards ")..target.name.." - Rads: "..rads)
        end
    end
end

function danger_start(which, delay, mob, turn, hold)
    if (modes.verbose.active) then
        windower.add_to_chat(207, "Danger Start: DT Mode - "..which.."; Turn? "..(turn and "Yes" or "No").."; Hold for "..hold.." seconds")
    end

    if (delay and delay > 1) then
        coroutine.schedule(danger_start:prepare(which, 0, mob, turn, hold), delay - 1)
        return
    end

    if (mob ~= nil and turn) then
        face_target(mob, turn)
    end

    if (T{'MDT','PDT','DT','MAX','MEVA'}:contains(which:upper())) then
        modes.dt.temp = which
        gear_up()
    end

    if (danger_up ~= nil) then
        --windower.add_to_chat(207, "Danger Already Up: "..tostring(danger_up))
        coroutine.close(danger_up)
    end
    danger_up = coroutine.schedule(danger_finish:prepare(mob, turn), hold)
end

function danger_finish(mob, turn)
    modes.dt.temp = 'Off'
    danger_up = nil
    if (modes.verbose.active) then
        windower.add_to_chat(207, "Danger Finish: DT Mode - "..modes.dt.type.." Turn? "..(turn and "Yes" or "No"))
    end

    if (turn) then
        face_target(mob)
    end

    gear_up()
end

function danger_check(mob_id, mob_name, type, id)
    local word = ''
    local cast_time = 0
    local danger = danger or T{}
    local mob = windower.ffxi.get_mob_by_id(mob_id)

    if not mob then 
        return
    end

    if (modes.verbose.active) then
        windower.add_to_chat(207, 
            mob_name.." ["..mob_id.."] - Action Type: "..type.." Action ID: "..id..
                " Valid T? "..(mob.valid_target and "yes" or "no").." S_Type: "..mob.spawn_type
        )
    end

    if mob.spawn_type == 2 then
        return
    end

    if (type == 'spell') then
        word = gearswap.res.spells:with('id', id).name
        cast_time = gearswap.res.spells:with('id', id).cast_time
    elseif (id <= 255) then
        word = gearswap.res.weapon_skills:with('id', id).name
    elseif (pet.isvalid and mob_name == pet.name) then 
        word = gearswap.res.job_abilities:with('id', id).name
    else
        word = gearswap.res.monster_abilities:with('id', id).name
    end

    if (not word or word == '') then
        return {set='', delay=0, ability=word, turn=false, hold=1}
    end

    for m, v in pairs(danger) do
        if (v.ability == word) then
            if (modes.verbose.active) then
                windower.add_to_chat(207, mob_name..": "..v.ability.."["..id.."] == "..word.."? "..(v.ability == word and "Yes" or "No"))
            end
            return {set=v.set, delay=cast_time, ability=word, turn=v.turn, hold=v.hold}
        end
    end
    return {set='', delay=0, ability=word, turn=false, hold=1}
end

function add_danger(args)
    if (args == nil) then return end

    local set_name = ''
    local turn_away = false
    local ability_name = ''
    local hold = 0

    for i, v in ipairs(args) do
        if (dt_set_names:contains(args[i]:lower())) then
            set_name = args[i]
            args:remove(i)
            break
        end
    end
    for i, v in ipairs(args) do
        if (args[i]:lower() == 'turn') then
            turn_away = true
            args:remove(i)
            break
        end
    end
    for i, v in ipairs(args) do
        hold = args[i]:tonumber()
        if (hold ~= nil and hold ~= 0) then
            args:remove(i)
            break
        end
    end

    if (hold == nil) then hold = 1 end

    set_name = set_name:lower() == 'off' and 'Off' or (set_name:lower() == 'max' and 'Max' or (set_name:lower() == 'meva' and 'MEva' or set_name:upper()))
    ability_name = title_case(args:concat(" "))

    local spell = gearswap.res.spells:with('name', ability_name)
    local ability = gearswap.res.monster_abilities:with('name', ability_name)

    if (spell == nil and ability == nil) then
        windower.add_to_chat(207, "GS Danger: No spell or monster ability with name: "..ability_name)
        return
    end

    for i, v in pairs(danger) do
        if (v.ability == ability_name) then
            danger[i].set = set_name
            danger[i].turn = turn_away
            danger[i].hold = hold
            danger:save('all')
            windower.add_to_chat(207, "GS Danger: "..ability_name.." updated to set: "..(set_name == '' and "None" or set_name)..(turn_away and " and Auto Turn" or "").." Hold for "..hold.." seconds.")
            return
        end
    end
    
    danger:append({ability=ability_name, set=set_name, turn=turn_away, delay=delay})
    windower.add_to_chat(207, "GS Danger: "..ability_name.." added with set: "..(set_name == '' and "None" or set_name)..(turn_away and " and Auto Turn" or "").." Hold for "..hold.." seconds.")
    danger:save('all')
end

--[[
    TODO: Adjust -na, any -na spell cast will be swapped for priority -na cursna > silena > poisona for instance
]]
function adjust_na_spell(spell, target)
    return spell.name
end

function get_missing_hp(target)
    local alliance = windower.ffxi.get_party()
    local missingHP = -1
    if (not target.hpp) then
        return 1
    end

    if (target.isallymember) then
        for k, v in pairs (alliance) do
            if (type(v) == "table") then
                for i, m in pairs (v) do
                    if (v.name == target.name) then
                        missingHP = math.floor((v.hp / (v.hpp/100)) - v.hp)
                    end
                end
            end
        end
    else
        missingHP = math.floor(1800 - (1800 * (target.hpp/100)))
        windower.add_to_chat(207, "Gearswap Cure Target: "..target.name.." HP Missing: "..missingHP)
    end
    return missingHP
end

--[[
    TODO: Adjust cure/curaga spells based on targets missing hp and cure potency
]]
function adjust_cure(spell)
    local spell_short = spell.name:split(" ")[1]
    local recasts = windower.ffxi.get_spell_recasts()
    local missingHP = get_missing_hp(spell.target)
    local spell_tiers = {"", "II", "III", "IV", "V", "VI"}
    local spell_tier = spell.name:split(" ")[2]

    if (spell_tier) then
        for k, v in ipairs(spell_tiers) do
            if (spell_tier == v) then
                spell_tier = k
                break
            end
        end
    else
        spell_tier = 1
    end

    if (recasts[gearswap.res.spells:with("name", spell.name).id] <= 0 and (spell_tier == 1 or missingHP >= cure_amounts[spell_tier] * (1 + (settings.job.cure_potency/100)))) then
        return
    end

    if (recasts[6] == 0 and missingHP >= cure_amounts[6] * (1 + (settings.job.cure_potency/100))) then
        cancel_spell()
        windower.chat.input("/ma \""..spell_short.." "..spell_tiers[6].."\" "..spell.target.id)
        return
    elseif (recasts[5] == 0 and missingHP >= cure_amounts[5] * (1 + (settings.job.cure_potency/100))) then
        cancel_spell()
        windower.chat.input("/ma \""..spell_short.." "..spell_tiers[5].."\" "..spell.target.id)
        return
    elseif (recasts[4] == 0 and missingHP >= cure_amounts[4] * (1 + (settings.job.cure_potency/100))) then
        cancel_spell()
        windower.chat.input("/ma \""..spell_short.." "..spell_tiers[4].."\" "..spell.target.id)
        return
    elseif (recasts[3] == 0 and missingHP >= cure_amounts[3] * (1 + (settings.job.cure_potency/100))) then
        cancel_spell()
        windower.chat.input("/ma \""..spell_short.." "..spell_tiers[3].."\" "..spell.target.id)
        return
    elseif (recasts[2] == 0 and missingHP >= cure_amounts[2] * (1 + (settings.job.cure_potency/100))) then
        cancel_spell()
        windower.chat.input("/ma \""..spell_short.." "..spell_tiers[2].."\" "..spell.target.id)
        return
    elseif (recasts[1] == 0) then -- and missingHP >= cure_amounts[1] * (1 + (settings.job.cure_potency/100))) then
        cancel_spell()
        windower.chat.input("/ma \""..spell_short.."\" "..spell.target.id)
        return
    else
        cancel_spell()
        return
    end
end

--[[
    TODO: Adjust waltz abilities based on targets missing hp and waltz potency
]]
function adjust_waltz(spell)
    local recasts = windower.ffxi.get_spell_recasts()
    local spell_short = T(spell.name:split(" ")):slice(1,2):concat(" ")
    local missingHP = get_missing_hp(spell.target)
    local spell_tiers = {"", "II", "III", "IV", "V"}
    local spell_tier = spell.name:split(" ")[3]

    if (spell_tier) then
        for k, v in ipairs(spell_tiers) do
            if (spell_tier == v) then
                spell_tier = k
                break
            end
        end
    else
        spell_tier = 1
    end

    if (recasts[gearswap.res.job_abilities:with("name", spell.name).id] <= 0 and (spell_tier == 1  or missingHP >= waltz_amounts[spell_tier] * (1 + (settings.job.waltz_potency/100)))) then
        return
    end

    if (recasts[gearswap.res.job_abilities:with("name", "Curing Waltz V")] == 0 and missingHP >= waltz_amounts[5] * (1 + (settings.job.waltz_potency/100))) then
        cancel_spell()
        windower.chat.input("/ma \"".."Curing Waltz "..spell_tiers[5].."\" "..spell.target.name)
        return
    elseif (recasts[gearswap.res.job_abilities:with("name", "Curing Waltz IV")] == 0 and missingHP >= waltz_amounts[4] * (1 + (settings.job.waltz_potency/100))) then
        cancel_spell()
        windower.chat.input("/ma \"".."Curing Waltz "..spell_tiers[4].."\" "..spell.target.name)
        return
    elseif (recasts[gearswap.res.job_abilities:with("name", "Curing Waltz III")] == 0 and missingHP >= waltz_amounts[3] * (1 + (settings.job.waltz_potency/100))) then
        cancel_spell()
        windower.chat.input("/ma \"".."Curing Waltz "..spell_tiers[3].."\" "..spell.target.name)
        return
    elseif (recasts[gearswap.res.job_abilities:with("name", "Curing Waltz II")] == 0 and missingHP >= waltz_amounts[2] * (1 + (settings.job.waltz_potency/100))) then
        cancel_spell()
        windower.chat.input("/ma \"".."Curing Waltz "..spell_tiers[2].."\" "..spell.target.name)
        return
    elseif (recasts[gearswap.res.job_abilities:with("name", "Curing Waltz").id] == 0 and missingHP >= waltz_amounts[1] * (1 + (settings.job.waltz_potency/100))) then
        cancel_spell()
        windower.chat.input("/ma \"".."Curing Waltz\" "..spell.target.name)
        return
    else
        cancel_spell()
        windower.chat.input("/ma \"Curing Waltz\" "..spell.target.name)
        return
    end
end

--[[
    TODO: auto_potion checks for "status" and if it exists uses the appropriate potion, will cancel current spell
]]
function auto_potion(status)
    return false
end

--[[
    TODO: status alerts for various "important" debuffs, Doom for instance
]]
function status_alert(status, gained)
    if (settings.status_alerts and settings.status_alerts:contains(status.name)) then
        if (gained) then
            windower.send_command("input /"..(settings.status_alerts.channel or "p").." --[ I've just been "..status.name.."ed! ]--")
        else
            windower.send_command("input /"..(settings.status_alerts.channel or "p").." --[ "..status.name.." has been removed! ]--")
        end
    end
end