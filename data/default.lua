-- Basic (gearless) gs file for any job, rename to [character][_job][_subjob].lua to suit and fill out gearsets

require('lists')
require('logger')
include('organizer-lib')
require('sets')
require('strings')
require('tables')
require('queues')
files = require('files')

config = require('config')
texts = require('texts')

gui = nil
settings = {}
modes = {}

just_zoned = false
zone_delay = 5

last_update = 0
update_freq = 0.25

last_stance_check_time = 0
stance_check_delay = 3

last_maneuver_check_time = 0
maneuver_check_delay = 3
maneuvers = Q{}
maneuvers_to_apply = Q{}

last_potion_check_time = 0
potion_check_delay = 1

haste_needed = 0
snapshot_needed = 0

player_action = false
pet_action = false
pet_action_start_time = 0
pet_action_max_time = 2

no_prerender = true

-- Newly added variables that might be missing in modes object, but hopefully aren't
modes.keep_tp = modes.keep_tp or {
    active = true,
    amount = 700,
}

function gear_up(spell)
    if (not spell or not spell.name) then
        spell = { name = "None", }
    end

    local time = os.clock()
    if (time > (pet_action_start_time + pet_action_max_time)) then
        pet_action = false
    end

    if (pet_action) then 
        if (modes.verbose.active) then
            windower.add_to_chat(207, "Gearup cancelled - Pet Ability Overide time: "..tostring(pet_action and time < (pet_action_start_time + pet_action_max_time)))
        end

        return
    end

    local set = T(set_combine(set, sets.Player.Idle, sets.Player.Idle[modes.idle.type], sets.Current))
    local sets_list = "---- Gear Up ---- \nPlayer Status: "..player.status.."\n"
    if (pet.isvalid) then
        sets_list = sets_list.."Pet Status: "..tostring(pet.status).."\n"
    end

    local dw_in_use = false
    if (sets.Weapons[modes.weapons.set]) then
        set = set_combine(set, sets.Weapons[modes.weapons.set])
    end
    sets_list = sets_list.."\nGear sets: "

-- Add weapons to set
    if (weapons_changed or (modes.keep_tp.active == false and modes.keep_tp.amount and player.tp < modes.keep_tp.amount)) then
        if (sets.Weapons[modes.weapons.set]) then
            sets_list = sets_list..'Weapon-'..tostring(modes.weapons.set).." "
            set = set_combine(set, sets.Weapons[modes.weapons.set])
        end
    end

-- Merge player set by player state
    if (player.status == 'Engaged') then
        sets_list = sets_list..('Player-'..tostring(melee_set_names[modes.melee.type])..' ')
        set = set_combine(set, sets.Player.Engaged, sets.Player.Engaged[melee_set_names[modes.melee.type]])
        -- Merge in weapon specific melee sets, should really do this for ranged and maybe even casting weapons ... Ranged for sure
        if (sets.Weapons[modes.weapons.set] and sets.Weapons[modes.weapons.set][melee_set_names[modes.melee.type]]) then
            set = set_combine(set, sets.Weapons[modes.weapons.set][melee_set_names[modes.melee.type]])
            if (buffactive["Aftermath: Lv.3"] or buffactive["Aftermath: Lv.2"] or buffactive["Aftermath: Lv.1"]) then
                set = set_combine(set, sets.Weapons[modes.weapons.set].Aftermath, sets.Weapons[modes.weapons.set][melee_set_names[modes.melee.type]].Aftermath)
            end
        end

        -- Add Haste gear as needed
        haste_needed, dw_needed = calc_haste()
        if (sets.Haste and sets.Haste[haste_needed]) then
            set = set_combine(set, sets.Haste[haste_needed])
        end
        if (player.equipment.sub ~= nil and player.equipment.sub ~= "" and player.equipment.sub ~= "empty") then
            dw_in_use = gearswap.res.items:with('english', player.equipment.sub).category == "Weapon"
        end
        if (dw_in_use) then
            if (sets.DW and sets.DW[dw_needed]) then
                set = set_combine(set, sets.Dw[dw_needed])
            end
        end
    else
        sets_list = sets_list..('Player-Idle ')
    end

-- Merge pet set by pet state and priority
    if (pet.isvalid) then
        if (player.status == 'Idle' or modes.pet.priority == 'Pet') then
            sets_list = sets_list.."Pet-"..modes.pet.type
            set = set_combine(set, sets.Pet[pet.status])
            if (pet.status == 'Engaged') then
                set = set_combine(set, sets.Pet[modes.pet.type])
            end
        elseif (player.status == 'Engaged' and modes.pet.priority == 'Hybrid') then
            sets_list = sets_list.."Hybrid-"..tostring(melee_set_names[modes.melee.type])
            set = set_combine(set, sets.Hybrid[melee_set_names[modes.melee.type]])
        end
    end

-- Pet DT Modes if a pet is present
    if (pet.isvalid and modes.pet.dt.type ~= 'Off') then
        sets_list = sets_list..'Pet-'..tostring(modes.pet.dt.type)..' '
        set = set_combine(set, sets.Pet.DT[modes.pet.dt.type])
    end

-- Enmity gear +/- should be on engaged or not 
    if (modes.enmity.type == "Up" and sets.Utility and sets.Enmity) then 
        sets_list = sets_list..('Player-EnmityUp ')
        set = set_combine(set, sets.Enmity.Up)
    elseif (modes.enmity.type == "Dwn" and sets.Utility and sets.Enmity) then
        sets_list = sets_list..('Player-EnmityDown ')
        set = set_combine(set, sets.Enmity.Down)
    end

-- Buff Active Gear if job has any buffactive sets and that buff is active keep the gear on
if (sets.BuffActive) then
    if (modes.verbose.active) then
        windower.add_to_chat(207, "BuffActive sets present, cycling ...")
    end
    sets_list = sets_list..('Player-BuffActive ')
    for k,v in pairs (sets.BuffActive) do
        if (modes.verbose.active) then
            windower.add_to_chat(207, "Buff Sets ["..k.."] Buff Active? "..(buffactive[k]==1 and "Yes " or "No ").."| Just Cast? "..(spell.name == k and "Yes " or "No "))
        end
        if (buffactive[k] or spell.name == k) then
            if (modes.verbose.active) then
                windower.add_to_chat(207, "Set && buffactive["..k.."], equipping.")
            end
            set = set_combine(set, sets.BuffActive[k])
        end
    end
end

-- Enspell gear if we have and Enspell set and are engaged and an Enspell is active
if (player.status == 'Engaged' and sets.Player.Engaged.Enspell) then
    for k,v in pairs (enspells) do
        if (buffactive[k] or spell.name == k) then
            set = set_combine(set, sets.Player.Engaged.Enspell, sets.Player.Engaged.Enspell[k:split(" ")[1]])
        end
    end
end

-- TH Gear should stay on if TH mode is on and we're engage, maybe f/t would be better?
    if (modes.th.active and player.status == "Engaged") then
        sets_list = sets_list..('Player-TH ')
        set = set_combine(set, sets.TH)
    end

-- DT Modes trump most things
    if (modes.dt.type ~= 'Off' or modes.dt.meva ~= 'Off') then
        sets_list = sets_list..'Player-'..modes.dt.type..' '
        if (sets.DT and sets.DT[modes.dt.type] and sets.DT[modes.dt.type][modes.weapons.set]) then
            sets_list = sets_list..'Player-Weapon-'..modes.dt.type..' '
            set = set_combine(set, sets.DT[modes.dt.type][modes.weapons.set], sets.DT[modes.dt.type][modes.weapons.set][melee_set_names[modes.melee.type]])
        else
            if (modes.dt.meva ~= 'Off') then
                set = set_combine(set, sets.DT.MEva)
            end
            set = set_combine(set, sets.DT[modes.dt.type])
        end
    end

-- DT Temp Mode triggered by danger function wins
    if (modes.dt.temp ~= 'Off') then
        sets_list = sets_list..'React-'..modes.dt.temp..' '
        set = set_combine(set, sets.DT[modes.dt.temp])
    end

-- Low HP Auto DT equips max DT gear
    if (modes.auto_dt.low_hp and (player.hpp < modes.dt.low_hp)) then
        sets_list = sets_list..'Low-HP-DT '
        set = set_combine(set, sets.DT.DT, sets.DT.MEva, sets.DT.Max)
    end

-- Overdrive is life
    if ((buffactive["Overdrive"] or spell.name == "Overdrive") and sets.Pet.Overdrive) then
        sets_list = sets_list..'Pup-Overdrive '
        set = set_combine(set, sets.Pet.Overdrive, sets.Pet.Overdrive[modes.pet.type])
    end

-- AFAC active don't take off BP gear
    if (buffactive["Astral Conduit"] or spell.name == "Astral Conduit") then
        sets_list = "Astral Flow + Astral Conduit Only"
        set = {}
    end

-- CP back stays on 
    if (modes.cp.active) then
        sets_list = sets_list..('Player-CP ')
        set = set_combine(set, sets.CP)
    end

-- We're in Town lets put on something fun
    if (in_town()) then
        sets_list = sets_list..(' ***Town*** ')
        set = set_combine(set, sets.Player.Idle.Town)
    end

    if (modes.verbose.active) then
        windower.add_to_chat(207, sets_list)
    end


    equip(set)
    return set
end

--[[-------------------- Setup (get_sets()) --------------------]]--
function get_sets()
    include('gs_danger.lua')
    include('gs_tables.lua')
    include('gs_functions.lua')
    load_gear_file()

    set_key_binds()
    load_settings()
    init_gui()

    if (macrobook ~= 0) then
        send_command('wait 6; input /macro book '..macrobook)
    end
    if (macroset ~= 0) then
        send_command('wait 8; input /macro set '..macroset)
    end
    if (lockstyle ~= 0) then
        send_command('wait 20; input /lockstyleset '..lockstyle)
    end
end

----[[[[ Pretarget ]]]]----
function pretarget(spell) 
    -- windower.add_to_chat(207, "Spell Pretarget")
    local set = T{}
    if spell.type == 'BloodPactWard' or spell.type == 'BloodPactRage' then
        set = set_combine(set, sets.BloodPact.Precast)
        pet_action = true
        if buffactive["Astral Conduit"] then
            if spell.type == 'BloodPactWard' then -- Summoner
                set = set_combine(set, sets.BloodPact.Ward)
                if blood_pacts_physical:contains(spell.name) then
                    set = set_combine(set, sets.BloodPact.Physical)
                elseif blood_pacts_hybrid:contains(spell.name) then
                    set = set_combine(set, sets.BloodPact.Hybrid)
                elseif blood_pacts_magical:contains(spell.name) then
                    set = set_combine(set, sets.BloodPact.Magical)
                    if blood_pacts_merit:contains(spell.name) then
                        set = set_combine(set, sets.BloodPact.Merit)
                    end
                end            
            elseif spell.type == 'BloodPactRage' then -- Summoner
                if blood_pacts_physical:contains(spell.name) then
                    set = set_combine(set, sets.BloodPact.Physical)
                elseif blood_pacts_hybrid:contains(spell.name) then
                    set = set_combine(set, sets.BloodPact.Hybrid)
                elseif blood_pacts_magical:contains(spell.name) then
                    set = set_combine(set, sets.BloodPact.Magical)
                    if blood_pacts_merit:contains(spell.name) then
                        set = set_combine(set, sets.BloodPact.Merit)
                    end
                end            
            end
        end
        equip(set)
    end
end

----[[[[ Player Precast ]]]]----
function precast(spell)
    if (not spell.name) then return end
    -- windower.add_to_chat(207, "Spell Precast")

    if ((spell.name == 'Ranged' or (spell.type == 'WeaponSkill' and ranged_weaponskills:contains(spell.name))) and no_shoot_gear:contains(player.equipment.ammo)) then
        send_command('input /equip ammo ""')
        windower.add_to_chat(207, 'Ranged attack canceled due to ammo conflict! '..player.equipment.ammo..' should not be shot!')
        cancel_spell()
        gear_up()
        return
    end

    player_action = true
    -- Don't overwrite certain effects, Warcy and such --
    if (spell.name == 'Warcry' or spell.name == 'Blood Rage') then
        if (buffactive['Blood Rage'] or  buffactive['Warcry']) then
            windower.add_to_chat(207, "Cancelled: "..spell.name..", conflicting buff already active!")
            cancel_spell()
            gear_up()
            return
        end
    end
    if (spell.name == 'Valiance' or spell.name == 'Vallation') then
        if (buffactive['Valiance'] or  buffactive['Vallation']) then
            windower.add_to_chat(207, "Cancelled: "..spell.name..", conflicting buff already active!")
            cancel_spell()
            gear_up()
            return
        end
    end

    local sets_list = ""
    local set = T{}

    local short_element = (spell.element ~= nil and spell.element:split(" ")[1] or "N/A")
    local short_spell = spell.english:split(" ")[1]
    local short_spell_2 = spell.english:split(" ")[2] or "N/A"
    local short_skill = (spell.skill ~= nil and spell.skill:split(" ")[1] or "N/A")
    
    if short_skill and short_skill == "Singing" then
        short_spell = spell.english:split(" ")[2]
    elseif short_skill and short_skill == "Geomancy" then
        short_spell = spell.english:split("-")[1]
    elseif short_skill and short_skill == "Ninjutsu" then
        short_spell = spell.english:split(":")[1]
    end

    if (modes.verbose.active) then
        windower.add_to_chat(207, "---- Precast\n Spell: "..tostring(short_spell).." Type: "..tostring(spell.type).." Skill: "..tostring(short_skill).." Ele: "..tostring(short_element))
    end
    
    if spell.cast_time then
        set = set_combine(set, sets.FC)
        if (sets.FC and sets.FC[short_skill]) then
            set = set_combine(set, sets.FC[short_skill])
        end
        if (sets.FC and sets.FC[short_element]) then
            set = set_combine(set, sets.FC[short_element])
        end
        if (sets.FC and sets.FC[short_spell]) then
            set = set_combine(set, sets.FC[short_spell])
        end
        if (sets.FC and sets.FC[short_skill] and sets.FC[short_skill][short_spell]) then
            set = set_combine(set, sets.FC[short_skill][short_spell])
        end
        if (sets.FC and sets.FC[spell.english]) then
            set = set_combine(set, sets[spell.english])
        end
    end

    if spell.english == 'Ranged' then
        if (spell.english == 'Ranged' and ranged_set_names[modes.ranged.type] == 'Off') then
            cancel_spell()
            windower.add_to_chat(207, 'Aborting ranged attack: Disabled')
            return
        end
        set = set_combine(set, sets.Ranged, sets.Ranged.Precast)
        -- Add Flurry gear as needed
        local snapshot_needed = calc_flurry()
        if (snapshot_needed > 0) then
            set = set_combine(set, sets.Snapshot[snapshot_needed])
        end
    elseif spell.type == 'Monster' then
        set = set_combine(set, sets.Ready.Precast)
        pet_action = true
    elseif spell.type == 'BloodPactWard' or spell.type == 'BloodPactRage' then
        set = set_combine(set, sets.BloodPact.Precast)
        pet_action = true
        if spell.type == 'BloodPactWard' or spell.type == 'BloodPactRage' then
            set = set_combine(set, sets.BloodPact.Precast)
            pet_action = true
            if buffactive["Astral Conduit"] or buffactive["Apogee"] then
                if spell.type == 'BloodPactWard' then
                    set = set_combine(set, sets.BloodPact.Ward)
                    if blood_pacts_physical:contains(spell.name) then
                        set = set_combine(set, sets.BloodPact.Physical)
                    elseif blood_pacts_hybrid:contains(spell.name) then
                        set = set_combine(set, sets.BloodPact.Hybrid)
                    elseif blood_pacts_magical:contains(spell.name) then
                        set = set_combine(set, sets.BloodPact.Magical)
                        if blood_pacts_merit:contains(spell.name) then
                            set = set_combine(set, sets.BloodPact.Merit)
                        end
                    end            
                    elseif spell.type == 'BloodPactRage' then
                    if blood_pacts_physical:contains(spell.name) then
                        set = set_combine(set, sets.BloodPact.Physical)
                    elseif blood_pacts_hybrid:contains(spell.name) then
                        set = set_combine(set, sets.BloodPact.Hybrid)
                    elseif blood_pacts_magical:contains(spell.name) then
                        set = set_combine(set, sets.BloodPact.Magical)
                        if blood_pacts_merit:contains(spell.name) then
                            set = set_combine(set, sets.BloodPact.Merit)
                        end
                    end            
                end
                equip(set)
                return
            end
        end
    elseif spell.type == 'WeaponSkill' then
        local in_range = ((spell.range * 2) + (spell.target.model_size ~= nil and spell.target.model_size or 1)/2)
        --if (ranged_weaponskills:contains(spell.english)) then in_range = 23 end

        if (spell.target and spell.range and (spell.target.distance > in_range)) then
            cancel_spell()
            gear_up()
            windower.add_to_chat(207, 'Aborting '..spell.name..' (Out of range)')
            return
        end
    
        set = set_combine(set, sets.WS)
        if ranged_weaponskills:contains(spell.english) then
            set = set_combine(set, sets.WS.Ranged, sets.WS.Ranged[ws_set_names[modes.ws.type]], sets.WS.Ranged.Physical, sets.WS.Ranged.Physical[ws_set_names[modes.ws.type]])
        else
            set = set_combine(set, sets.WS.Melee, sets.WS.Melee[ws_set_names[modes.ws.type]], sets.WS.Melee.Physical, sets.WS.Melee.Physical[ws_set_names[modes.ws.type]])
        end

        if sets.WS.Belt and ftp_weaponskills:contains(spell.english) then
            if sets.WS.Belt[spell.skillchain_a] then
                set = set_combine(set, sets.WS.Belt[spell.skillchain_a])
            elseif sets.WS.Belt[spell.skillchain_b] then
                set = set_combine(set, sets.WS.Belt[spell.skillchain_b])
            elseif sets.WS.Belt[spell.skillchain_c] then
                set = set_combine(set, sets.WS.Belt[spell.skillchain_c])
            end
        end
        if sets.WS.Gorget and ftp_weaponskills:contains(spell.english) then
            if sets.WS.Gorget[spell.skillchain_a] then
                set = set_combine(set, sets.WS.Gorget[spell.skillchain_a])
            elseif sets.WS.Gorget[spell.skillchain_b] then
                set = set_combine(set, sets.WS.Gorget[spell.skillchain_b])
            elseif sets.WS.Gorget[spell.skillchain_c] then
                set = set_combine(set, sets.WS.Gorget[spell.skillchain_c])
            end
        end

        if sets.WS[spell.english] then
            set = set_combine(
                set, sets.WS[spell.english], sets.WS[spell.english][ws_set_names[modes.ws.type]], 
                sets.WS[spell.name][world.day_element], sets.WS[spell.name][world.weather_element]
            )
            if (buffactive["Trick Attack"]) then 
                set = set_combine(set, sets.WS[spell.english].TA)
            end
            if (buffactive["Sneak Attack"]) then 
                set = set_combine(set, sets.WS[spell.english].SA)
            end
        end
        if (sets.Weapons[modes.weapon_set] and sets.Weapons[modes.weapon_set][spell.name]) then
            set = set_combine(
                set, sets.Weapons[modes.weapon_set][spell.name], sets.Weapons[modes.weapon_set][spell.name][ws_set_names[modes.ws.type]], 
                sets.Weapons[modes.weapon_set][spell.name][world.day_element], sets.Weapons[modes.weapon_set][spell.name][world.weather_element]
            )
        end

        -- SATA gear after everything else except enmity adjusters
        if (buffactive["Trick Attack"]) then 
            set = set_combine(set, sets.WS.TA)
        end
        if (buffactive["Sneak Attack"]) then 
            set = set_combine(set, sets.WS.SA)
        end

        -- Enmity adjustment gear if desired
        if (modes.enmity.type == "Up" and sets.Enmity) then
            set = set_combine(set, sets.Enmity.Up)
        elseif (modes.enmity.type == "Dwn" and sets.Enmity) then
            set = set_combine(set, sets.Enmity.Down)
        end

        -- If this is a TH tagged WS then put on the TH WS set
        if (th_ws) then
            set = set_combine(set, sets.WS.TH)
        end

        if player.main_job == "DRG" and pet.isvalid then
            pet_action = true
        end
    end
    
    if (sets.JA[spell.type]) then
        set = set_combine(set, sets.JA[spell.type])
    end
    if (sets.JA[short_spell]) then 
        set = set_combine(set, sets.JA[short_spell])
    end
    if (short_spell_2 and short_spell_2 ~= "N/A" and sets.JA[short_spell_2]) then
        set = set_combine(set, sets.JA[short_spell_2])
    end
    if (sets.JA[spell.english]) then
        set = set_combine(set, sets.JA[spell.english])
    end
    if (dummy_songs and dummy_songs:contains(spell.name) and sets.FC and sets.FC.Singing) then 
        set = set_combine(set, sets.FC.Singing, sets.FC.Singing.Dummy)
    end

    -- Enmity adjustment gear if desired
    if (spell.type == "JobAbility" and enmity_generators:contains(short_spell) and modes.enmity.type == "Up" and sets.Enmity) then
        set = set_combine(set, sets.Enmity.Up)
    elseif (spell.type == "JobAbility" and enmity_generators:contains(short_spell) and modes.enmity.type == "Dwn" and sets.Enmity) then
        set = set_combine(set, sets.Enmity.Down)
    end

    -- TODO: Make this smarter to allow insturment swaps or ammo swaps but not both
    if (modes.keep_tp.active and modes.keep_tp.amount and player.tp >= modes.keep_tp.amount) then
        set.main = nil
        set.sub = nil
    end

    equip(set)

end

----[[[[ Player Midcast ]]]]----
function midcast(spell)
    -- windower.add_to_chat(207, "Spell Midcast")
    -- Don't change out of BloodPact Gear between Bloodpacts during Astral Conduit
    if (buffactive["Astral Conduit"] and (spell.type == 'BloodPactWard' or spell.type == "BloodPactRage")) then
        if (modes.verbose.active) then
            windower.add_to_chat(207, 'Player - Midcast: Astral Conduit Active. All gear left in place.')
        end
        return
    end

    player_action = true
    local set = T{}

    local short_element = (spell.element ~= nil and spell.element:split(" ")[1] or "N/A")
    local short_spell = (#spell.english > 1 and spell.english:split(" ")[1] or spell.english)
    local short_skill = (spell.skill ~= nil and spell.skill:split(" ")[1] or "N/A")
    local short_type = ability_types[short_skill] ~= nil and ability_types[short_skill] or "Ability"
    local set = {}

    if (modes.verbose.active) then
        windower.add_to_chat(207, "---- Midcast\nSpell: "..short_spell.." Type: "..short_type.." Skill: "..(short_skill and short_skill or "N/A"))
        windower.add_to_chat(207, "---- Day: "..world.day_element.." Weather: "..world.weather_element)
    end

    if short_skill and short_skill == "Singing" then
        short_spell = spell.english:split(" ")[2]
    elseif short_skill and short_skill == "Geomancy" then
        short_spell = spell.english:split("-")[1]
    elseif short_skill and short_skill == "Ninjutsu" then
        short_spell = spell.english:split(":")[1]
    end

    if sets[short_type] then
        set = set_combine(set, sets[short_type])
        if (spell.target.type == "SELF") then
            if (modes.verbose.active) then
                windower.add_to_chat(207, "Self Casting Set - sets['"..short_type.."'] - ON")
            end
            set = set_combine(set, sets[short_type].Self)
        end
    end
    if sets[spell.type] then 
        set = set_combine(set, sets[spell.type])
        if (spell.target.type == "SELF") then
            if (modes.verbose.active) then
                windower.add_to_chat(207, "Self Casting Set - sets['"..spell.type.."'] - ON")
            end
            set = set_combine(set, sets[spell.type].Self)
        end
    end

    if (short_skill == "Blue" and sets.Blue) then
        local blue_set = "None"
        if (blue_breath:contains(spell.name)) then
            set = set_combine(set, sets.Blue.Breath)
            blue_set = "Breath"
        elseif (blue_healing:contains(spell.name)) then
            set = set_combine(set, sets.Blue.Healing)
            blue_set = "Healing"
        elseif (blue_enhancing:contains(spell.name)) then
            set = set_combine(set, sets.Blue.Enhancing)
            blue_set = "Enhancing"
        elseif (blue_enfeebling:contains(spell.name)) then
            set = set_combine(set, sets.Blue.Enfeebling)
            blue_set = "Enfeebling"
        elseif (blue_magical:contains(spell.name)) then
            set = set_combine(set, sets.Blue.Magical)
            blue_set = "Magical"
        elseif (blue_physical:contains(spell.name)) then
            set = set_combine(set, sets.Blue.Physical)
            blue_set = "Physical"
        end
        if (modes.verbose.active == true) then
            windower.add_to_chat(207, "Blue Set Engaged: "..blue_set)
        end
    end

    if (short_skill == "Ninjutsu" and sets.Ninjutsu) then
        if (ninjutsu_enhancing:contains(short_spell)) then
            set = set_combine(set, sets.Ninjutsu.Enhancing)
        elseif (ninjutsu_enfeebling:contains(short_spell)) then
            set = set_combine(set, sets.Ninjutsu.Enfeebling)
        elseif (ninjutsu_elemental:contains(short_spell)) then
            set = set_combine(set, sets.Ninjutsu.Elemental)
            --windower.add_to_chat(207, short_element.." == "..world.weather_element.." ? "..spell.element)
            if (short_element == world.weather_element and sets.Elemental and sets.Elemental.Belts) then
                --windower.add_to_chat(207, "Using elemental belt: "..(sets.Elemental.Belts[short_element] and sets.Elemental.Belts[short_element].waist or "no set for belt"))
                set = set_combine(set, sets.Elemental.Belts[short_element])
            end
        end
    end
    
    if (spell.target.type == "SELF" and short_skill and sets[short_skill] and sets[short_skill].Self) then 
        if (modes.verbose.active) then
            windower.add_to_chat(207, "Self Casting Set - sets['"..short_skill.."'] - ON")
        end
        set = set_combine(set, sets[short_skill].Self)
    end

    if (short_skill and sets[short_skill] and sets[short_skill][short_spell]) then
        set = set_combine(set, sets[short_skill][short_spell])
        if (spell.target.type == "SELF") then
            if (modes.verbose.active) then
                windower.add_to_chat(207, "Self Casting Set - sets['"..short_skill.."']['"..short_spell.."'] - ON")
            end
            set = set_combine(set, sets[short_skill][short_spell].Self)
        end
    end
    if short_skill and sets[short_skill] and sets[short_skill][spell.name] then
        set = set_combine(set, sets[short_skill][spell.name])
        if (spell.target.type == "SELF") then
            if (modes.verbose.active) then
                windower.add_to_chat(207, "Self Casting Set - sets['"..short_skill.."']['"..spell.name.."'] - ON")
            end
            set = set_combine(set, sets[short_skill][spell.name].Self)
        end
    end
    if sets[short_spell] then 
        set = set_combine(set, sets[short_spell])
        if (spell.target.type == "SELF") then
            if (modes.verbose.active) then
                windower.add_to_chat(207, "Self Casting Set - sets['"..short_spell.."'] - ON")
            end
            set = set_combine(set, sets[short_spell].Self)
        end
    end
    if sets[spell.name] then
        set = set_combine(set, sets[spell.name])
        if (spell.target.type == "SELF") then
            if (modes.verbose.active) then
                windower.add_to_chat(207, "Self Casting Set - sets['"..spell.name.."'] - ON")
            end
            set = set_combine(set, sets[spell.name].Self)
        end
    end

    if (barspells and (barspells:contains(short_spell) or barspells:contains(spell.name)) and sets.Enhancing) then
        set = set_combine(set, sets.Enhancing.Barspell)
    end

    if (enspells and (enspells:contains(short_spell) or enspells:contains(spell.name)) and sets.Enhancing) then
        set = set_combine(set, sets.Enhancing.Enspell)
    end
    
    if (spell.name:split("-")[1] == "Absorb" and sets.Dark) then
        set = set_combine(set, sets.Dark.Absorb)
    end
    
    if (dummy_songs and dummy_songs:contains(spell.name) and sets.FC and sets.FC.Singing) then 
        set = set_combine(set, sets.FC.Singing, sets.FC.Singing.Dummy)
    end

    if (modes.bursting.active) then
        set = set_combine(set, sets.MB, sets.Magic.MB)
        if (sets[short_skill]) then
            set = set_combine(set, sets[short_skill].MB)
        end
    end

    if (modes.interrupt.type ~= 'Off') then
        set = set_combine(set, sets.SI, sets.SI[modes.interrupt.type])
    end

    if (short_skill == 'Elemental' and sets[short_skill] and sets[short_skill].Belts) then
        if (short_element == world.day_element) then
            set = set_combine(set, sets[short_skill].Belts[world.day_element])
        end
        if (short_element == world.weather_element) then
            set = set_combine(set, sets[short_skill].Belts[world.weather_element])
        end
    end

    if (spell.english == 'Ranged') then
        set = set_combine(set, sets.Ranged, sets.Ranged[ranged_set_names[modes.ranged.type]])
    end

    if spell.type == 'BloodPactWard' then -- Summoner
        pet_action_start_time = os.clock()
        pet_action = true
            set = set_combine(set, sets.BloodPact.Ward)
    elseif spell.type == 'BloodPactRage' then -- Summoner
        pet_action_start_time = os.clock()
        pet_action = true
            if blood_pacts_physical:contains(spell.name) then
            set = set_combine(set, sets.BloodPact.Physical)
        elseif blood_pacts_hybrid:contains(spell.name) then
            set = set_combine(set, sets.BloodPact.Hybrid)
        elseif blood_pacts_magical:contains(spell.name) then
            set = set_combine(set, sets.BloodPact.Magical)
        end
        if blood_pacts_merit:contains(spell.name) then
            set = set_combine(set, sets.BloodPact.Merit)
        end
    end            

    if (modes.keep_tp.active and modes.keep_tp.amount and player.tp >= modes.keep_tp.amount) then
        set.main = nil
        set.sub = nil
    end

    -- Enmity adjustment gear if desired
    if (enmity_generators and enmity_generators:contains(short_spell) and modes.enmity.type == "Up" and sets.Enmity) then
        set = set_combine(set, sets.Enmity.Up)
    elseif (enmity_generators and enmity_generators:contains(short_spell) and modes.enmity.type == "Dwn" and sets.Enmity) then
        set = set_combine(set, sets.Enmity.Down)
    end

    equip(set)
end

----[[[[ Pet Midcast ]]]]----
function pet_midcast(spell)
    -- windower.add_to_chat(207, "Pet Midcast")

    pet_action = true
    -- Don't change out of BloodPact Gear between Bloodpacts during Astral Conduit
    if (buffactive["Astral Conduit"] and (spell.type == 'BloodPactWard' or spell.type == "BloodPactRage")) then
        if (modes.verbose.active) then
            windower.add_to_chat(207, 'Pet - Midcast: Astral Conduit Active. All gear left in place.')
        end
        return
    end

    pet_action = true
    local set = {}
    local short_element = (spell.element ~= nil and spell.element:split(" ")[1] or "N/A")
    local short_spell = spell.english:split(" ")[1]
    local short_skill = (spell.skill ~= nil and spell.skill:split(" ")[1] or "N/A")

    local bstr = "Pet Midcast: "
    if spell.type == 'MonsterSkill' then -- Beastmaster
        set = set_combine(set, sets.Ready)
        if ready_physical:contains(spell.name) then
            bstr = bstr.."Physical - "..spell.name
            set = set_combine(set, sets.Ready.Physical)
        elseif ready_magical:contains(spell.name) then
            bstr = bstr.."Magical - "..spell.name
            set = set_combine(set, sets.Ready.Magical)
        end
    elseif wyvern_breath_attack:contains(spell.name) then
        bstr = bstr..spell.name
    elseif wyvern_breath_healing:contains(spell.name) then
        bstr = bstr..spell.name
    elseif spell.type == 'BloodPactWard' then -- Summoner
        set = set_combine(set, sets.BloodPact.Ward)
        bstr = bstr.."Bloodpact Ward - "..spell.name
    elseif spell.type == 'BloodPactRage' then -- Summoner
        if blood_pacts_physical:contains(spell.name) then
            set = set_combine(set, sets.BloodPact.Physical)
        elseif blood_pacts_hybrid:contains(spell.name) then
            set = set_combine(set, sets.BloodPact.Hybrid)
        elseif blood_pacts_magical:contains(spell.name) then
            set = set_combine(set, sets.BloodPact.Magical)
            if blood_pacts_merit:contains(spell.name) then
                set = set_combine(set, sets.BloodPact.Merit)
            end
        end            
        bstr = bstr.."Bloodpact Rage - "..spell.name
    elseif false then -- Puppetmaster auto is casting a spell
        set = set_combine(set, sets.Pet[modes.pet.type].midcast)
    end

    equip(set)
end

----[[[[ Aftercast ]]]]----
function aftercast(spell)
    set = {}
    -- Disable TH WS gear
    if (th_ws) then
        th_ws = false
    end
    
    -- Don't change out of BloodPact Gear between Bloodpacts during Astral Conduit
    if (buffactive["Astral Conduit"] and (spell.type == 'BloodPactWard' or spell.type == "BloodPactRage")) then
        if (modes.verbose.active) then
            windower.add_to_chat(207, 'Astral Conduit Active. All gear left in place.')
        end
        return
    end

    -- windower.add_to_chat(207, "Spell Aftercast")
    if (player.main_job == "DRG" and pet_action and sets.Pet and sets.Pet.Breath) then
        if (modes.verbose.active) then
            windower.add_to_chat(207, "Wyvern Breath Attack Set Equip")
        end
        if (T{"WAR","MNK","THF","BST","RNG","SAM","COR","PUP","DNC","PLD","DRK","BRD","NIN","RUN"}:contains(player.sub_job)) then
            if (modes.verbose.active) then
                windower.add_to_chat(207, "Wyvern Breath Attack Set Equip")
            end
            if (sets.Pet and sets.Pet.Breath) then
                equip(sets.Pet.Breath, sets.Pet.Breath.Attack)
            end
        end
    end

    if (pet_action) then 
        if (modes.verbose.active) then
            windower.add_to_chat(207, spell.name.." - Aftercast cancelled - Pet Ability Overide")
        end
        return 
    end

    player_action = false
    gear_up(spell)
end

function pet_aftercast(spell)
    local delta_pet_time = os.clock() - pet_action_start_time

    -- Don't change out of BloodPact Gear between Bloodpacts during Astral Conduit
    if (buffactive["Astral Conduit"] and (spell.type == 'BloodPactWard' or spell.type == "BloodPactRage")) then
        if (modes.verbose.active) then
            windower.add_to_chat(207, 'Astral Conduit Active. All gear left in place.')
        end
        return
    end

    if (modes.verbose.active) then
        windower.add_to_chat(207, "Pet Aftercast "..delta_pet_time)
    end
    
    pet_action = false
    gear_up(spell)
end

----[[[[ Status Change Functions ]]]]----
function status_change(new,old)
    gear_up()
end

function pet_status_change(new,old)
    gear_up()
end

function pet_change(pet, gain)
    gear_up()
end

----[[[[ Buff Changes ]]]]----
function buff_change(name, gain, buff_details)
    if (name == "Doom") then
        send_command("input /echo *** DOOM"..(gain and "ED " or " OFF ").."***")
    end
    
    -- Stance changes
    if (gain and stances:with('name', name)) then
        modes.stance = stances:with('name', name)
    -- Pup Maneuver management
    elseif (name:contains("Overload") and gain) then
        maneuvers:clear()
        maneuvers_to_apply:clear()
    elseif (name:contains("Maneuver")) then
        if (gain == true) then
            maneuvers:push(name)
            if (maneuvers:length() > 2) then
                maneuvers_to_apply:clear()
            end
            if (maneuvers_to_apply and maneuvers_to_apply:length() > 0) then
                for k, v in pairs(maneuvers_to_apply) do
                    if (k=="data") then
                        for k2, v2 in pairs(v) do
                            if (v2 == name) then
                                maneuvers_to_apply:remove(k2)
                                break
                            end
                        end
                    end
                end
            end
        elseif (gain == false) then
            maneuvers:pop()
            if (maneuvers:length() < 3) then
                maneuvers_to_apply:push(name)
            else
                maneuvers_to_apply:clear()
            end
        end
    end
end

----[[[[ Prerender, every frame, function ]]]]----
windower.raw_register_event('prerender', function(...)
    --update_gui()
    local time = os.clock()
    if (just_zoned) then return end
    if (time < last_update + update_freq) then return end
    last_update = time

    -- If we had a stance set and it has worn off lets get it back up
    if (time > last_stance_check_time + stance_check_delay) then
        if (not is_disabled() and not cities:contains(world.area)) then
            last_stance_check_time = time
            if (modes.stance) then
                if (stances:with('name', modes.stance.name)) then
                    local d = windower.ffxi.get_ability_recasts()[gearswap.res.job_abilities:with('name', modes.stance.name).recast_id]
                    if (not buffactive[modes.stance.name] and d and d == 0) then
                        apply_stance(modes.stance)
                    end
                end
            end
        end
    end

    -- If we have 1 or more maneuvers to apply then go ahead and apply one
    if (time > last_maneuver_check_time + maneuver_check_delay) then
        if (not is_disabled()) then
            last_maneuver_check_time = time
            if (buffactive['Overload']) then
                return
            end

            if (pet_engage_commands:contains(player.main_job) and modes.pet.auto_engage and player.status == "Engaged" and player.status_id <= 1 and pet.isvalid and pet.status ~= "Engaged") then
                send_command('input /pet "'..pet_engage_commands[player.main_job]..'" <t>')
            end
        
            if (modes.pet.auto_maneuvers and maneuvers_to_apply and maneuvers_to_apply:length() > 0) then
                --windower.add_to_chat(17, "Maneuvers: "..tostring(maneuvers:length()))
                if (not pet.isvalid or player.status_id >= 2 or cities:contains(world.area)) then
                    maneuvers:clear()
                    maneuvers_to_apply:clear()
                elseif (maneuvers:length() >= 3) then
                    maneuvers_to_apply:clear()
                elseif (pet.isvalid and pet.name and player.status_id <= 1) then
                    if (modes.verbose.active) then
                        windower.add_to_chat(17, "Reapplying "..maneuvers_to_apply[1])
                    end
                    local d = windower.ffxi.get_ability_recasts()[210]
                    if (d and d > 0) then
                        if (modes.verbose.active) then
                            windower.add_to_chat(17, "Waiting on recast "..maneuvers_to_apply[1])
                        end
                        return
                    end

                    send_command('input /ja "'..maneuvers_to_apply[1]..'" <me>')
                end
            end
        end
    end

    -- Auto Item Use
    if (last_potion_check_time + potion_check_delay) then
        if (player.status_id <= 1 and not is_disabled()) then
            last_potion_check_time = time
            if (buffactive['Doom'] and modes.potions and modes.potions.doom) then
                if (player.inventory[4154] and player.inventory[4154].count > 0) then
                    send_command("input /item 'holy water' <me>")
                end
            elseif (buffactive['Blind'] and modes.potions and modes.potions.blind) then
                if (player.inventory[4150] and player.inventory[4150].count > 0) then
                    send_command("input /item 'eye drops' <me>")
                end
            end
        end
    end

    -- Auto DT Check
    if (not player_action and not pet_action) then
        if (modes.auto_dt and modes.auto_dt.low_hp and modes.dt.hp_temp == 'Off' and player.hpp < modes.dt.low_hp) then
            modes.dt.hp_temp = 'Max'
            gear_up()
        elseif (modes.dt.hp_temp ~= 'Off') then
            modes.dt.hp_temp = 'Off'
        end
    end
end)

----[[[[ Action Packet Processing ]]]]----
windower.raw_register_event('action', function(act)
    local current_action = T(act)
    local actor = T{}
    local is_mob = false
    local mob = nil

    actor.id = current_action.actor_id
    
    if actor.id == nil then return end
    mob = windower.ffxi.get_mob_by_id(actor.id)
    if mob == nil then return end
    actor.name = windower.ffxi.get_mob_by_id(actor.id).name

    local ext_param = current_action.param
    local targets = current_action.targets
    local party = T(windower.ffxi.get_party())
    local danger_type = 'ability' 
    local danger = false
    local player = T(windower.ffxi.get_player())
    
    if (trusts:contains(actor.name)) then
        return
    end

    is_mob = mob.is_npc or (not mob.is_npc and mob.charmed)

    if is_mob and S{7,8}:contains(current_action.category) and ext_param ~= 28787 then
        local action = targets[1].actions[1]
        if current_action.category == 8 then 
            danger_type = 'spell'
        end

        local word = danger_check(actor.name, danger_type, action.param)
        if (word.set ~= '' or word.turn == true) then
            if (modes.verbose.active) then
                windower.add_to_chat(207, "Danger "..danger_type..": "..tostring(word.ability).." equipping "..tostring(word.set).." in "..tostring(word.delay).." second(s) to counter.")
            end
            danger_start(modes.auto_dt.active and word.set or '', word.delay, mob, modes.auto_turn.active and word.turn or false, word.hold)
            return
        end
    end
end)

----[[[[ Zone Changes ]]]]----
windower.raw_register_event('zone change', function()
    -- Clear stances and such 
    maneuvers:clear()
    maneuvers_to_apply:clear()
    modes.stance = {}

    last_maneuver_check_time = os.clock() + 60
    last_stance_check_time = os.clock() + 60
end)

----[[[[ Player Command Processing ]]]]----
function self_command(command)
    local args = T(command:split(" "))
    local cmd = args[1]:lower()
    args:remove(1)

    if command == 'weapon_f' then
        rotate_weapons_forward()
        gear_up()
    elseif command == 'weapon_b' then
        rotate_weapons_backward()
        gear_up()
    elseif command == 'pettype' then
        rotate_pet_type_forward()
        gear_up()
    elseif command == 'petpriority' then
        if modes.pet.priority == 'Player' then
            modes.pet.priority = 'Hybrid'
        elseif modes.pet.priority == 'Hybrid' then
            modes.pet.priority = 'Pet'
        else
            modes.pet.priority = 'Player'
        end
        gear_up()
    elseif command == 'petdt' then
        if modes.pet.dt.type == 'Off' then
            modes.pet.dt.type = 'Min'
        elseif modes.pet.dt.type == 'Min' then
            modes.pet.dt.type = 'Max'
        else
            modes.pet.dt.type = 'Off'
        end
        gear_up()
    elseif command == 'idle' then
        rotate_idle_forward()
        gear_up()
    elseif command == 'melee' then
        rotate_melee_forward()
        if modes.verbose.active then
            windower.add_to_chat(207, 'melee mode is now: '..melee_set_names[modes.melee.type])
        end
        gear_up()
    elseif command == "ranged" then
        rotate_ranged_forward()
        if modes.verbose.active then
            windower.add_to_chat(207, 'ranged mode is now: '..ranged_set_names[modes.ranged.type])
        end
        gear_up()
    elseif command == 'magic' then
        rotate_magic_forward()
        if modes.verbose.active then
            windower.add_to_chat(207, 'magic mode is now: '..magic_set_names[modes.magic.type])
        end
        gear_up()
    elseif command == 'interrupt' then
        if modes.interrupt.type == 'Off' then
            modes.interrupt.type='Min'
        elseif modes.interrupt.type == 'Min' then
            modes.interrupt.type='Mid'
        elseif modes.interrupt.type == 'Mid' then
            modes.interrupt.type='Max'
        else
            modes.interrupt.type='Off'
        end
        if modes.verbose.active then
            windower.add_to_chat(207, 'Interrupt mode is now: '..modes.interrupt.type)
        end
    elseif command == "ws" then
        rotate_ws_forward()
        if modes.verbose.active then
            windower.add_to_chat(207, 'ws mode is now: '..ws_set_names[modes.ws.type])
        end
    elseif command =="dt" then
        if modes.dt.type == 'Off' then
            modes.dt.type='DT'
        elseif modes.dt.type == 'DT' then
            modes.dt.type='Max'
        else
            modes.dt.type='Off'
        end
        if modes.verbose.active then
            windower.add_to_chat(207, 'DT mode is now: '..modes.dt.type)
        end
        gear_up()
    elseif command =="pdt" then
        if modes.dt.type == 'Max' then return end
        if modes.dt.type == 'PDT' then
            modes.dt.type = 'Off'
        else
            modes.dt.type = 'PDT'
        end
        gear_up()
    elseif command =="mdt" then
        if modes.dt.type == 'Max' then return end
        if modes.dt.type == 'MDT' then
            modes.dt.type = 'Off'
        else
            modes.dt.type = 'MDT'
        end
        gear_up()
    elseif command == "meva" then
        if modes.dt.meva == 'MEva' then
            modes.dt.meva = 'Off'
        else
            modes.dt.meva = 'MEva'
        end
        gear_up()
    elseif command == "enmity" then
        if modes.enmity.type == "Up" then
            modes.enmity.type = "Dwn"
        elseif modes.enmity.type == "Dwn" then
            modes.enmity.type = "Off"
        else
            modes.enmity.type = "Up"
        end
        if modes.verbose.active then
            windower.add_to_chat(207, 'Enmity option set to '..(modes.enmity.type))
        end
        gear_up()
    elseif command == 'dual' then
        modes.dual_wield.active = not modes.dual_wield.active
        if modes.verbose.active then
            windower.add_to_chat(207, 'Dual Wield mode '..(modes.dual_wield.active and 'On' or 'Off'))
        end
        gear_up()
    elseif command == 'keeptp' then
        modes.keep_tp.active = not modes.keep_tp.active
        if modes.verbose.active then
            windower.add_to_chat(207, 'CP Mode: '..(modes.keep_tp.active and 'On' or 'Off'))
        end
    elseif command == 'cp' then
        modes.cp.active = not modes.cp.active
        if modes.verbose.active then
            windower.add_to_chat(207, 'CP Mode: '..(modes.cp.active and 'On' or 'Off'))
        end
        gear_up()
    elseif command == 'th' then
        modes.th.active = not modes.th.active
        if (sets.Weapons and sets.Weapons['TH']) then
            modes.weapons.set = 'TH'
        elseif (sets.Weapons and sets.Weapons['Treasure Hunter']) then
            modes.weapons.set = 'Treasure Hunter'
        end

        if modes.verbose.active then
            windower.add_to_chat(207, 'TH Mode: '..(modes.th.active and 'On' or 'Off'))
        end
        gear_up()
    elseif command == 'gearup' then
        if modes.verbose.active then
            windower.add_to_chat(207, 'Re-equipping gear')
        end
        gear_up()
    elseif command == 'naked' then
        send_command('input /gs equip naked')
        if modes.verbose.active then
            windower.add_to_chat(207, 'Stripping gear')
        end
    elseif command == 'current' or command == 'cur' then
        sets.Current = player.equipment
        if modes.verbose.active then
            windower.add_to_chat(207, 'Updated current gearset')
        end
    elseif cmd == 'add_danger' or cmd == 'danger' or cmd == 'dng' then
        if modes.verbose.active then
            windower.add_to_chat(207, "Adding Danger: "..args:concat(', '))
        end
        add_danger(args)
    elseif cmd == 'auto' then
        if #args > 1 then
            if args[1] == turn then
                modes.auto_turn.active = not modes.auto_turn.active
            elseif args[1] == dt then
                modes.auto_dt.active = not modes.auto_dt.active
            end
            if (modes.verbose.active) then
                windower.add_to_chat(207, "Auto DT: "..(modes.auto_dt.active and "On" or "Off").." - Auto Turn: "..(modes.auto_turn.active and "On" or "Off"))
            end
        else
            windower.add_to_chat(207, "Usage: gs c auto <turn|dt>")
        end
    elseif command == 'verbose' then
        modes.verbose.active = not modes.verbose.active
        if modes.verbose.active then
            windower.add_to_chat(207, 'Verbose output enabled')
        end
    elseif command == 'th_ws' then
        th_ws = true
    elseif command == 'bp_precast' then
        pet_action = true
        equip(sets.BloodPact.Precast)
    elseif command == 'bp_physical' then
        equip(sets.BloodPact.Physical)
    elseif command == 'bp_hybrid' then
        equip(sets.BloodPact.Hybrid)
    elseif command == 'bp_magical' then
        equip(sets.BloodPact.Magical)
    elseif command == 'bp_ward' then
        equip(sets.BloodPact.Ward)
    elseif command == 'bp_complete' then
        pet_action = false
        gear_up()
    elseif command == 'bursting' then
        if (modes.verbose.active) then
            windower.add_to_chat(207, "MB Set on, Burst Incoming")
        end
        modes.bursting.active = true
    elseif command == 'notbursting' then
        if (modes.verbose.active) then
            windower.add_to_chat(207, "MB Set off, normal nukes incoming")
        end
        modes.bursting.active = false
    elseif cmd == 'turn' then
        local angle = 3
        angle = tonumber(args[1])
        if (angle == nil) then
            angle = 0
        end
        windower.add_to_chat(207, "Angle: "..angle)
        windower.ffxi.turn(angle)
    elseif command == 'info' then
        windower.add_to_chat(207, "Zone: "..world.area.." Day: "..world.day_element.." Weather: "..world.weather_element)
    elseif command == 'save' then
        settings:save('all')
        windower.add_to_chat(207, "Gearswap: Settings saved.")
    end

    update_gui()
end
