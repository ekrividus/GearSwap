ranged_weaponskills = T{
    -- Archery
    "Flaming Arrow",
    "Piercing Arrow",
    "Dulling Arrow",
    "Sidewinder",
    "Blast Arrow",
    "Arching Arrow",
    "Empyreal Arrow",
    "Refulgent Arrow",
    "Apex Arrow",
    "Namas Arrow",
    "Jishnu's Radiance",
    -- Marksmanship 
    "Hot Shot",
    "Split Shot",
    "Sniper Shot",
    "Slug Shot",
    "Blast Shot",
    "Heavy Shot",
    "Detonator",
    "Numbing Shot",
    "Last Stand",
    "Coronach",
    "Wildfire",
    "Trueflight",
    "Leaden Salute",
}

ftp_weaponskills = T{
    "Jishnu's Radiance",
    "Decimation",
    "Rampage",
    "Ruinator",
    "Hexa Strike",
    "Realmrazer",
    "Dancing Edge",
    "Evisceration",
    "Exenterator",
    "Pyrrhic Kleos",
    "Resolution",
    "Ascetic's Fury",
    "Asuran Fists",
    "Backhand Blow",
    "Combo",
    "Dragon Kick",
    "Howling Fist",
    "One Inch Punch",
    "Raging Fists",
    "Shijin Spiral",
    "Shoulder Tackle",
    "Spinning Attack",
    "Stringing Pummel",
    "Tornado Kick",
    "Victory Smite",
    "Blade: Jin",
    "Blade: Ku",
    "Blade: Shun",
    "Last Stand",
    "Stardiver",
    "Entropy",
    "Chant du Cygne",
    "Requiescat",
    "Swift Blade",
    "Vorpal Blade",
}

no_shoot_gear = T{
    "Aeolus Arrow",
    "Animikii Bullet",
    "Hauksbok Bullet",
    "Fire Bomblet",
    "Iron Gobbet",
    "Grenade Core",
    "Amar Cluster",
    "Expeditious Pinion",
    "Incantor Stone",
    "Qirmiz Tathlum",
    "Thew Bomblet",
    "Fire Bomblet",
    "Phtm. Tathlum",
    "Bomb Core",
    "Holy Ampulla",
    "Happy Egg",
    "Fortune Egg",
    "Orphic Egg",
    "Kalboron Stone",
    "Witchstone",
    "Jinx Ampulla",
    "Attar of Roses",
    "Incantor Stone",
    "Sancus Sachet",
    "Sancus Sachet +1",
    "Snow Sachet",
    "Breeze Sachet",
    "Soil Sachet",
    "Thunder Sachet",
    "Aqua Sachet",
    "Light Sachet",
    "Automat. Oil",
    "Automat. Oil +1",
    "Automat. Oil +2",
    "Automat. Oil +3",
}

idle_set_names      = T{Std="Std", Mvt="Mvt", Ref="Ref", Reg="Reg", Town="Twn"}
melee_set_names     = T{Min="MinAcc", Mid="MidAcc", Max="MaxAcc"}
ranged_set_names    = T{Min="MinAcc", Mid="MidAcc", Max="MaxAcc", Off="Off"}
magic_set_names     = T{Min="MinAcc", Mid="MidAcc", Max="MaxAcc"}
ws_set_names        = T{Min="MinAcc", Mid="MidAcc", Max="MaxAcc"}
haste_set_names     = T{"none", "5%", "10%", "15%", "20%", "25%"}
flurry_set_names    = T{"none", "5%", "10%", "15%", "20%", "25%"}
dt_set_names        = T{"dt", "pdt", "mdt", "meva", "max", "off"}
pet_type_names      = T{"Melee", "Ranged", "Tank", "Caster","Healer"}
enmity_type         = T{"Up", "Off", "Dwn"}

modes = T{
    weapons = {
        options = {[0]="DD", [1]="Tank",}, -- Add/change weapon_sets based on what weapon sets you need per job
        set = "Empty" -- Should be whatever you want by default
    },
    idle = {
        type = "Std"
    },
    melee = {
        type = "Min"
    },
    ranged = {
        type = "Off"
    },
    magic = {
        type = "Min"
    },
    interrupt = {
        type = "Off"
    },
    ws = {
        type = "Min"
    },
    dt = {
        type = "Off",
        meva = "Off",
        low_hp = 30,
        hp_temp = "Off",
        temp = "Off",
    },
    enmity = {
        type = "Off",
    },
    keep_tp = {
        active = true,
        amount = 700,
    },
    dual_wield = {
        active = false,
        auto = true,
        need = 32,
    },
    fencer = {
        active = false,
    },
    th = {
        active = false,
    },
    cp = {
        active = false,
    },
    verbose = {
        active = false,
    },
    pet = {
        auto_activate = false,
        auto_engage = true,
        auto_maneuvers = true,
        priority = "Player", -- can be Player | Hybrid | Pet
        type = "Melee", -- can be Melee | Ranged | Tank | Caster | Healer
        dt = {
            type = "Off", -- can be DT | MDT | PDT | MEva | Max | Off
        },
    },
    bursting = {
        active = false,
    },
    auto_dt = {
        active = true,
        low_hp = true,
    },
    auto_turn = {
        active = true,
    },
    potions = {
        doom = true,
        silence = false,
        blind = false,
    },
    stance = {},
}

defaults = T{}
defaults.gui = {}
defaults.gui.pos = {}
defaults.gui.pos.x = 2
defaults.gui.pos.y = -19
defaults.gui.bg = {}
defaults.gui.bg.alpha = 70
defaults.gui.bg.red = 0
defaults.gui.bg.green = 0
defaults.gui.bg.blue = 0
defaults.gui.bg.visible = true
defaults.gui.flags = {}
defaults.gui.flags.right = false
defaults.gui.flags.bottom = true
defaults.gui.flags.bold = false
defaults.gui.flags.draggable = false
defaults.gui.flags.italic = false
defaults.gui.padding = 2
defaults.gui.text = {}
defaults.gui.text.size = 12
defaults.gui.text.font = "Consolas"
defaults.gui.text.fonts = {}
defaults.gui.text.alpha = 255
defaults.gui.text.red = 255
defaults.gui.text.green = 255
defaults.gui.text.blue = 255
defaults.gui.text.stroke = {}
defaults.gui.text.stroke.width = 2
defaults.gui.text.stroke.alpha = 128
defaults.gui.text.stroke.red = 0
defaults.gui.text.stroke.green = 0
defaults.gui.text.stroke.blue = 0

defaults.job = {
    cure_potency=0,
    waltz_potency=0,
}

trusts = S(gearswap.res.spells:type("Trust"):map(string.gsub-{" ", ""} .. table.get-{"name"}))

cities = S{
    "Northern San d'Oria", "Southern San d'Oria", "Port San d'Oria", "Chateau d'Oraguille",
    "Bastok Markets", "Bastok Mines", "Port Bastok", "Metalworks",
    "Windurst Walls", "Windurst Waters", "Windurst Woods", "Port Windurst", "Heavens Tower",
    "Ru'Lude Gardens", "Upper Jeuno", "Lower Jeuno", "Port Jeuno",
    "Selbina", "Mhaura", "Kazham", "Norg", "Rabao", "Tavnazian Safehold",
    "Aht Urhgan Whitegate", "Al Zahbi", "Nashmau",
    "Southern San d'Oria (S)", "Bastok Markets (S)", "Windurst Waters (S)",
    "Western Adoulin", "Eastern Adoulin", "Celennia Memorial Library",
    "Bastok-Jeuno Airship", "Kazham-Jeuno Airship", "San d'Oria-Jeuno Airship", "Windurst-Jeuno Airship",
    "Ship bound for Mhaura", "Ship bound for Selbina", "Open sea route to Al Zahbi", "Open sea route to Mhaura",
    "Silver Sea route to Al Zahbi", "Silver Sea route to Nashmau", "Manaclipper", "Phanauet Channel",
    "Chocobo Circuit", "Feretory", "Mog Garden",
}

ability_types = T{
    WhiteMagic="Magic",
    BlackMagic="Magic",
    SummonerPact="BloodPact",
    Ninjutsu="Ninjutsu",
    BardSong="Song",
    BlueMagic="Blue",
    Geomancy="Geomancy",
    Trust="Trust",
}

----[[[[ Stances ]]]]----
stances = T{
    [0]={name="Saber Dance", cmd="/ja \"Saber Dance\" <me>"},
    [1]={name="Fan Dance", cmd="/ja \"Fan Dance\" <me>"},
    [2]={name="Innin", cmd="/ja \"Innin\" <me>"},
    [3]={name="Yonin", cmd="/ja \"Yonin\" <me>"},
    [4]={name="Hasso", cmd="/ja \"Hasso\" <me>"},
    [5]={name="Seigan", cmd="/ja \"Seigan\" <me>"},
    [6]={name="Afflatus Misery", cmd="/ja \"Afflatus Misery\" <me>"},
    [7]={name="Afflatus Solace", cmd="/ja \"Afflatus Solace\" <me>"}
}

----[[[[ Pet Engagement Commands ]]]]----
pet_engage_commands = T{ BST="Fight", SMN="Assault", PUP="Deploy", }

----[[[[ Beastmaster Ready Move ]]]]----
ready_physical = T{
    "Tail Blow", "Fireball", "Blockhead", "Brain Crush", -- Warlike Patrick - Hill Lizards
    "Razor Fang", "Claw Cyclone", "Crossthrash", -- Blackbeard Randy - Tigers
    "Swooping Frenzy", "Pentapeck", -- Swooping Zhivago - Tulfaire
    "Big Scissors", -- Aged Angus - Crabs
    "Sensilla Blades", "Tegmina Buffet", -- Bouncing Bertha - Chapuli
}

ready_magical = T{
    "Purulent Ooze", "Corrosive Ooze", -- Generous Arthur - Slugs
    "Fireball", "Infrasonics", "Secretion", -- Warlike Patrick - Hill Lizards
    "Roar", "Predatory Glare", -- Blackbeard Randy - Tigers
    "Foul Waters", "Pestilent Plume", -- Fluffy Bredo - Acuex(es?)
    "Molting Plumage", -- Swooping Zhivago - Tulfaire
    "Bubble Shower", "Bubble Curtain", "Scissor Guard", "Metallic Body", -- Aged Angus - Crabs
}

----[[[[ Puppet Master Pet Skills ]]]]--

----[[[[ Dragoon Wyvern SKills ]]]]----
wyvern_breath_attack = T{
    "Flame Breath", "Frost Breath", "Sand Breath", "Hydro Breath", "Gust Breath", "Lightning Breath",
}

wyvern_breath_healing = T{
    "Healing Breath I", "Healing Breath II", "Healing Breath III", "Healing Breath IV",
}

----[[[[ Summoning Magic Tables ]]]]----
blood_pacts_physical = T{
    "Poison Nails",
    "Moonlit Charge",
    "Punch", 
    "Rock Throw",
    "Barracuda Dive",
    "Claw",
    "Axe Kick", "Rush",
    "Shock Strike", "Volt Strike",
    "Camisado",
    "Regal Scratch", "Regal Gash",
    "Welt", "Roundhouse", "Hysteric Assault",
}
blood_pacts_hybrid = T{"Burning Strike", "Flaming Crush"}
blood_pacts_magical = T{
    "Healing Ruby", "Metorite", "Holy Mist", "Soothing Ruby", "Searing Light",                          -- Carby
    "Lunar Bay", "Impact", "Howling Moon",                                                              -- Fenrir
    "Fire II", "Fire IV", "Meteor Strike", "Conflag Strike", "Inferno",                                 -- Ifrit
    "Stone II", "Stone IV", "Geocrush", "Earthen Fury",                                                 -- Titan
    "Water II", "Water IV", "Spring Water", "Grand Fall", "Tidal Wave",                                 -- Levi
    "Aero II", "Aero IV", "Whispering Wind", "Wind Blade", "Aerial Blast",                              -- Garuda
    "Blizzard II", "Blizzard IV", "Heavenly Strike", "Diamond Dust",                                    -- Shiva
    "Thunder II", "Thunder IV", "Thunderspark", "Thunderstorm", "Shock Squall", "Judgement Bolt",       -- Ramuh
    "Nightmare", "Ultimate Terror", "Nether Blast", "Night Terror", "Pavor Nocturnus", "Ruinous Omen",  -- Diabolos
    "Level ? Holy", "Mewing Lullaby",                                                                   -- Cait Sith
    "Sonic Buffet", "Tornado II", "Carsach Call",                                                       -- Siren
}
blood_pacts_merit = T{
    "Meteor Strike", "Geocrush", "Grand Fall", "Wind Blade", "Heavenly Strike", "Thunderstorm", 
}

----[[[[ Ninjutsu Tables ]]]]----
ninjutsu_enhancing = T{"Tonko", "Utsusemi", "Monomi", "Myoshu", "Migawari", "Gekka", "Yain", "Kakka"}
ninjutsu_enfeebling = T{"Kurayami", "Hojo", "Dokumori", "Jubaku", "Aisha", "Yurin"}
ninjutsu_elemental = T{"Katon", "Suiton", "Raiton", "Doton", "Huton", "Hyoton"}

----[[[[ Enmity Generators ]]]]----
enmity_generators = T{"Provoke", "Flash", "Stun", "Kurayami", "Hojo", "Dokumori", "Jubaku", "Aisha", "Yurin"}

----[[[[ Blue Magic Tables ]]]]----
blue_physical = T{
    "Foot Kick", "Sprout Smack", "Wild Oats", "Power Attack", "Battle Dance",
    "Head Butt", "Helldive", "Bludgeon", "Claw Cyclone", "Screwdriver",
    "Grand Slam", "Smite of Rage", "Uppercut", "Jet Stream", "Terror Touch",
    "Mandibular Bite", "Sickle Slash", "Dimensional Death", "Death Scissors",
    "Spiral Spin", "Seedspray", "Body Slam", "Spinal Cleave", "Frenetic Rip",
    "Frypan", "Hydro Shot", "Tail Slap", "Hysteric Barrage", "Cannonball",
    "Asuran Claws", "Disseverment", "Ram Charge", "Vertical Cleave", "Final Sting",
    "Goblin Rush", "Vanity Dive", "Whirl of Rage", "Benthic Typhoon", "Quad. Continuum",
    "Empty Thrash", "Delta Thrust", "Heavy Strike", "Sudden Lunge", "Quadrastrike",
    "Tourbillion", "Amorphic Strikes", "Barbed Crescent", "Bilgestorm", "Bloodrake",
    "Glutinous Dart", "Paralyzing Triad", "Thrashing Assault", "Sinker Drill",
    "Sweeping Gouge", "Saurian Slide", "Quesyshroom", "Feather Storm", "Pinecone Bomb",
}
blue_magical = T{
    "Pollen", "Sandspin", "Cocoon", "Metallic Body", "Healing Breeze", "Sheep Song",
    "Cursed Sphere", "Blastbomb", "Blood Drain", "Poison Breath", "Sporofic", "Bomb Toss",
    "Wild Carrot", "Chaotic Eye", "Sound Blast", "Death Ray", "Digest", "Blank Gaze", 
    "Mysterious Light", "MP Drainkiss", "Venom Shell", "Stinking Gas", "Blitzstrahl",
    "Awful Eye", "Geist Wall", "Magnetite Cloud", "Jettatura", "Blood Saber", "Refueling",
    "Ice Break", "Self-Destruct", "Frightful Roar", "Cold Wave", "Filamented Hold", "Radiant Breath",
    "Feather Barrier", "Light of Penance", "Flying Hip Press", "Magic Fruit", "Eyes On Me", "Bad Breath",
    "Maelstrom", "1000 Needles", "Memento Mori", "Voracious Trunk", "Feather Tickle", "Yawn",
    "Infrasonics", "Zephyr Mantle", "Corrosive Ooze", "Sandspray", "Frost Breath", "Diamondhide",
    "Enervation", "Firespit", "Warm-Up", "Regurgitation", "Amplification", "Heat Breath", "Lowing",
    "Triumphant Roar", "Saline Coat", "Temporal Shift", "Mind Blast", "Actinic Burst", "Reactor Cool",
    "Magic Hammer", "Exuviation", "Plasma Charge", "Plenilune Embrace", "Acrid Stream", "Leafstorm",
    "Cimicine Discharge", "Regeneration", "Animating Wail", "Battery Charge", "Blazing Bound", 
    "Demoralizing Roar", "Magic Barrier", "Auroral Drape", "Osmosis", "Fantod", "Thermal Pulse",
    "Dream Flower", "Occultation", "Charged Whisker", "Winds of Promy.", "Evryone. Grudge", "Reaving Wind",
    "Barrier Tusk","Mortal Ray", "Water Bomb", "Dark Orb", "White Wind", "Thunderbolt", "Harden Shell",
    "Vapor Spray", "Absolute Terror", "Thunder Breath", "Gates of Hades", "O. Counterstance", "Pyric Bulwark",
    "Wind Breath", "Nature's Meditation", "Tem. Upheaval", "Embalming Earth", "Rending Deluge", "Foul Waters",
    "Retinal Glare", "Droning Whirlwind", "Carcharian Verve", "Blistering Roar", "Erratic Flutter", "Subduction",
    "Diffusing Ray", "Rail Cannon", "Restoral", "Uproot", "Crashing Thunder", "Polar Roar", "Molting Plumage",
    "Nectarous Deluge", "Atra. Libations", "Searing Tempest", "Blinding Fulgor", "Spectral Floe", 
    "Scouring Spate", "Anvil Lightning", "Silent Storm", "Entomb", "Tenebral Crush", "Palling Salvo",
    "Mighty Guard", "Cruel Joke", "Cesspool", "Tearing Gust",
}
blue_breath = T{
    "Poison Breath", "Magnetite Cloud", "Hecatomb Wave", "Radiant Breath", "Flying Hip Press", "Bad Breath",
    "Frost Breath", "Heat Breath", "Vapor Spray", "Thunder Breath", "Wind Breath",
}
blue_healing = T{
    "Pollen", "Healing Breeze", "Wild Carrot", "Magic Fruit", "Exuviation", "Plenilune Embrace", "White Wind", 
    "Restoral", 
}
blue_enhancing = T{
    "Metallic Body", "Cocoon", "Refueling", "Feather Barrier", "Memento Mori", "Voracious Trunk", "Zephyr Mantle",
    "Diamondhide", "Warm-Up", "Amplification", "Triumphant Roar", "Saline Coat", "Reactor Cool", "Plasma Charge", 
    "Regeneration", "Animating Wail", "Battery Charge", "Magic Barrier", "Fantod", "Occultation", 
    "Winds of Promy.", "Barrier Tusk", "Orcish Counterstance", "Harden Shell", "Pyric Bulwark", "Nature's Meditation",
    "Carcharian Verve", "Erratic Flutter", "Mighty Guard", 
}
blue_enfeebling = T{
    "Filamented Hold", "Cimicine Discharge", "Demoralizing Roar", "Venom Shell", "Light of Penance", "Sandspray",
    "Auroral Drape", "Frightful Roar", "Enervation", "Infrasonics", "Lowing", "Cold Wave", "Awful Eye", "Sheep Song",
    "Soporific", "Yawn", "Dream Flower", "Chaotic Eye", "Sound Blast", "Blank Gaze", "Stinking Gas", "Geist Wall",
    "Jettatura", "Feather Tickle", "Temporarly Shift", "Actinic Burst", "Reaving Wind", "Mortal Ray", "Absolute Terror",
    "Blistering Roar",
}

----[[[[ Enhancing Magic Tables ]]]]----
barspells = T{
    "Barfire", "Barfira",
    "Barblizzard", "Barblizzara",
    "Baraero", "Baraera",
    "Barstone", "Barstonra",
    "Barthunder", "Barthundra",
    "Barwater", "Barwatera",
}

enspells = T{
    "Enthunder", "Enstone", "Enaero", "Enblizzard", "Enfire", "Enwater", "Enlight", "Endark", 
    "Enthunder II", "Enstone II", "Enaero II", "Enblizzard II", "Enfire II", "Enwater II", "Enlight II","Endark II",
}

----[[[[ Bard Dummy Songs ]]]]----
dummy_songs = T{"Army's Paeon", "Army's Paeon II", }

----[[[[ Cure Spell and Waltz Heal Amounts ]]]]----
cure_amounts = T{ 70, 150, 300, 600, 800, 1000 }
curaga_amounts = T{ 90, 190, 390, 690, 960 }
waltz_amounts = T{ 150, 100, 200, 300, 450 }
divine_amounts = T{ 60, 280 }