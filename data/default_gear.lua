-- Basic settings
macrobook = 0
macroset = 0
lockstyle = 0

-- Default modes
modes.melee.type = "Min"
modes.ranged.type = "Min"
modes.ws.type = "Min"
modes.magic.type = "Min"
modes.weapons.set = "Empty"

--[[ This is an empty slate to start building out all gear sets for any job ]]--
-- Set a temporary set for aftercast gear_up, 
-- set to currently equipped gear with //gs c cur
-- This will override normal aftercast gear sets except DT
sets.Current = {}

--[[ Weapon Sets - Names should match the names in modes.weapons.options ]]--
sets.Weapons = {}

--[[ Engaged Sets ]]--

sets.Player = {}
sets.Player.Idle = {}
sets.Player.Idle.Mvt = {}
sets.Player.Idle.Reg = {}
sets.Player.Idle.Ref = {}
sets.Player.Idle.Town = {}

sets.Player.Engaged = {}
sets.Player.Engaged.MinAcc = set_combine(sets.Player.Engaged, {})
sets.Player.Engaged.MidAcc = set_combine(sets.Player.Engaged, {})
sets.Player.Engaged.MaxAcc = set_combine(sets.Player.Engaged, {})

sets.Weapons['Empty'] = {
    main="",
    sub="",
}
sets.Weapons['Empty'].MinAcc = set_combine(sets.Player.Engaged.MinAcc, {})
sets.Weapons['Empty'].MidAcc = set_combine(sets.Player.Engaged.MinAcc, {})
sets.Weapons['Empty'].MaxAcc = set_combine(sets.Player.Engaged.MinAcc, {})

sets.Weapons['Empty'].Aftermath = set_combine(sets.Player.Engaged, {})
sets.Weapons['Empty'].MinAcc.Aftermath = set_combine(sets.Weapons['Empty'].Aftermath, {})
sets.Weapons['Empty'].MidAcc.Aftermath = set_combine(sets.Weapons['Empty'].MinAcc.Aftermath, {})
sets.Weapons['Empty'].MaxAcc.Aftermath = set_combine(sets.Weapons['Empty'].MidAcc.Aftermath, {})

sets.Haste = {}
sets.Haste[10] = {}
sets.Haste[15] = {}
sets.Haste[20] = {}
sets.Haste[25] = {}
sets.DW = {}

--[[ Ranged Sets ]]--
sets.Ranged = {}

sets.Ranged.MinAcc = set_combine(sets.Ranged, {})
sets.Ranged.MidAcc = set_combine(sets.Ranged, {})
sets.Ranged.MaxAcc = set_combine(sets.Ranged, {})

sets.Ranged.Precast = {}
sets.Snapshot = {}
sets.Snapshot[10] = {}
sets.Snapshot[20] = {}
sets.Snapshot[30] = {}
sets.Snapshot[40] = {}
sets.Snapshot[50] = {}
sets.Snapshot[60] = {}
sets.Snapshot[70] = {}

--[[ Pet Sets ]]--
sets.Pet = {}
sets.Pet.DT = {}
sets.Pet.DT.DT = {}
sets.Pet.DT.PDT = {}
sets.Pet.DT.MDT = {}
sets.Pet.DT.MEVA = {}
sets.Pet.DT.Max = {}
sets.Pet.Idle = {}
sets.Pet.Engaged = {}
sets.Pet.Breath = {}

--[[ Pet Mode Sets ]]--
sets.Pet.Melee = {}
sets.Pet.Ranged = {}
sets.Pet.Tank = {}
sets.Pet.Caster = {}
sets.Pet.Healer = {}

--[[ Pet Hybrid Sets ]]--
sets.Hybrid = {}
sets.Hybrid.DT = {}
sets.Hybrid.DT.DT = {}
sets.Hybrid.DT.PDT = {}
sets.Hybrid.DT.MDT = {}
sets.Hybrid.DT.MEVA = {}
sets.Hybrid.DT.Max = {}
sets.Hybrid.Idle = {}
sets.Hybrid.Engaged = {}

--[[ Utility Sets ]]--
sets.Utility = {}

--[[ Enmity Sets ]]--
sets.Enmity = {}
sets.Enmity.Up = {}
sets.Enmity.Down = {}

--[[ Blood Pact Sets ]]--
sets.BloodPact = {}
sets.BloodPact.Precast = {}
sets.BloodPact.Midcast = {}
sets.BloodPact.Ward = {}
sets.BloodPact.Physical = {}
sets.BloodPact.Hybrid = {}
sets.BloodPact.Magic = {}
sets.BloodPact.Merit = {}

--[[ Beastmaster Ready Sets ]]--
sets.Ready = {}
sets.Ready.Physical = {}
sets.Ready.Magical = {}

--[[ Pet Pre, Mid, Aftercast ]]--
sets.Pet.Precast = {}
sets.Pet.Midcast = {}
sets.Pet.Aftercast = {}

--[[ 
    Weaponskill Sets 
    Merged in order: 
    sets.WS >
    sets.WS.Melee['Melee mode if available'] > 
    sets.WS.Melee.Physical['Melee mode if available'] | sets.WS.Melee.Elemental['Melee mode if available'] > 
    sets.WS.Belt >
    sets.WS['WS Name'] > sets.WS['WS Name'][modes.ws.type]
    sets.Weapons['set_name']['WS Name'] > sets.Weapons['set_name']['WS Name'][] -- Useful for overriding WS sets for Shining One for instance
    Will use Ranged in place of Melee if ranged WS is used.
    Will swap in ftp gorgets/belts if those sets are defined
    If a named set is created it is merged last and will override all previous gear with slots assigned
]]--
sets.WS = {}

sets.WS.Belt = {
    Liquefaction={waist="Flame Belt"},
    Impaction={waist="Thunder Belt"},
    Detonation={"Breeze Belt"},
    Scission={waist="Soil Belt"},
    Reverberation={waist="Aqua Belt"},
    Induration={waist="Snow Belt"},
    Compression={waist="Shadow Belt"},
    Transfixion={waist="Light Belt"},
    Fusion={waist="Flame Belt"},
    Fragmentation={waist="Thunder Belt"},
    Gravitation={waist="Soil Belt"},
    Distortion={waist="Snow Belt"},
    Light={waist="Flame Belt"},
    Darkness={waist="Snow Belt"},
    Radiance={waist="Flame Belt"},
    Umbra={waist="Snow Belt"}
}

sets.WS.Neck = {
    Liquefaction={},-- neck="Flame Belt"},
    Impaction={},-- neck="Thunder Belt"},
    Detonation={},-- neck="Breeze Belt"},
    Scission={},-- neck="Soil Belt"},
    Reverberation={},-- neck="Aqua Belt"},
    Induration={},-- neck="Snow Belt"},
    Compression={},-- neck="Shadow Belt"},
    Transfixion={},--neck="Light Belt"},
    Fusion={},-- neck="Flame Belt"},
    Fragmentation={},-- neck="Thunder Belt"},
    Gravitation={},-- neck="Soil Belt"},
    Distortion={},-- neck="Snow Belt"},
    Light={},-- neck="Flame Belt"},
    Darkness={},-- neck="Snow Belt"},
    Radiance={},-- neck="Flame Belt"},
    Umbra={},-- neck="Snow Belt"}
}

sets.WS.Gorget = sets.WS.Neck

sets.WS.Melee = {}

sets.WS.Melee.Physical = {}
sets.WS.Melee.Physical.MinAcc = {}
sets.WS.Melee.Physical.MidAcc = {}
sets.WS.Melee.Physical.MaxAcc = {}

sets.WS.Melee.Elemental = {}
sets.WS.Melee.Elemental.MinAcc = {}
sets.WS.Melee.Elemental.MidAcc = {}
sets.WS.Melee.Elemental.MaxAcc = {}

sets.WS.Ranged = {}

sets.WS.Ranged.Physical = {}
sets.WS.Ranged.Physical.MinAcc = {}
sets.WS.Ranged.Physical.MidAcc = {}
sets.WS.Ranged.Physical.MaxAcc = {}

sets.WS.Ranged.Elemental = {}
sets.WS.Ranged.Elemental.MinAcc = {}
sets.WS.Ranged.Elemental.MidAcc = {}
sets.WS.Ranged.Elemental.MaxAcc = {}

sets.WS['Weaponskill Name'] = {}

--[[ 
    Job Ability Sets Work only with named abilities or JA Type 
    i.e. CorsairRoll so you don't need to list every individual roll for instance 
]]--
sets.JA = {}
sets.JA['JobAbility Name'] = {}

--[[ 
    Fast Cast sets, like magic sets
    Will merge in order:
    spell skill (first word only) >
    spell name (first word only) >
    spell full name
]]--
sets.FC = {}
sets.FC.Blue = {}
sets.FC.Dark = {}
sets.FC.Divine = {}
sets.FC.Elemental = {}
sets.FC.Enfeebling = {}
sets.FC.Enhancing = {}
sets.FC.Geomancy = {}
sets.FC.Healing = {}
sets.FC.Ninjutsu = {}
sets.FC.Singing = {}
sets.FC.Singing.Dummy = {}

sets.FC.Summoning = {}

sets.FC.Fire = {}
sets.FC.Water = {}
sets.FC.Earth = {}
sets.FC.Thunder = {}
sets.FC.Wind = {}
sets.FC.Ice = {}

sets.FC.Cure = {}
sets.FC.Protect = {}
sets.FC.Shell = {}

--[[ Spell Interrupt sets
    Will merge these on top of spell sets, for best results make the Min/Mid sets
    leave out spaces where potency gear is, so if you have a potency waist and SI waist
    you can make SI min not include the SI waist, that way your min set will
    prioritize potency in that slot, and so on.
]]--
sets.SI = {}
sets.SI.Off = {}
sets.SI.Min = set_combine(sets.SI, {})
sets.SI.Mid = set_combine(sets.SI, {})
sets.SI.Max = set_combine(sets.SI, {})

--[[ Magic sets, sooo many magic sets 
    Will merge all sets in the following order:
    sets["Type"] - Can be "Magic" or "Ability"
    sets["SkillFirstWord"] - i.e. sets["Healing"] or sets["Geomancy"] or sets["Sword"]
    sets["SkillFirstWord"]["SpellShortName"] - i.e. sets["Singing"]["Ballad"] or sets["Elemental"]["Fire"]
    sets["SkillFirstWord"]["Spell Full Name"] - i.e. sets["Healing"]["Cure VI"]
    sets["SpellShortName"] - sets["Cure"] will work for Cure, Cure II, Cure III, etc.
    sets["Spell Full Name"] - i.e. sets["Animus Augeo"]

    Most spells short names are simply the first word, some exceptions below:
    Bard songs use the second word as the shortname, Ballad, Minuet, Madrigal, etc. 
    Geo spells short names are simply Indi or Geo 
    Ninjutsu spells short names are the first word and no ":" or ichi/ni/san
]]--
sets.Magic = {}
sets.Magic.MinAcc = set_combine(sets.Magic, {})
sets.Magic.MidAcc = set_combine(sets.Magic.MinAcc, {})
sets.Magic.MaxAcc = set_combine(sets.Magic.MidAcc, {})

sets.Dark = {}
sets.Divine = {}
sets.Elemental = {}
sets.Elemental.Fire = {}
sets.Elemental.Water = {}
sets.Elemental.Earth = {}
sets.Elemental.Thunder = {}
sets.Elemental.Wind = {}
sets.Elemental.Ice = {}
sets.Elemental.Light = {}
sets.Elemental.Dark = {}

sets.Enfeebling = {}

sets.Enhancing = {}
sets.Enhancing.Protect = {}
sets.Enhancing.Shell = {}

sets.Geomancy = {}

sets.Healing = {}
sets.Healing.Cure = {}

sets.Ninjutsu = {}
sets.Ninjutsu.Enhancing = {}
sets.Ninjutsu.Enfeebling = {}
sets.Ninjutsu.Elemental = {}

sets.Singing = {}
sets.Singing.Dummy = {}

sets.Summoning = {}

sets.Blue = {}
sets.Blue.Physical = {}
sets.Blue.Magical = {}
sets.Blue.Breath = {}
sets.Blue.Healing = {}
sets.Blue.Enhancing = {}
sets.Blue.Enfeebling = {}

--[[ Damage Taken Sets ]]--
sets.DT = {}
sets.DT.DT = {
}

sets.DT.PDT = {
}

sets.DT.MDT = {
}

sets.DT.Max = {
}

sets.DT.MEva = {
}

--[[ Buff Active Sets 
        These sets will be used anytime the given buff is active, this overrides pre, mid, idle, etc. set slots listed.
]]--
sets.BuffActive = {}

sets.BuffActive['Doom'] = { -- Doom removal gear

}
sets.BuffActive['Astral Conduit'] = {-- Anything that shouldn't get removed at all during Astral Conduit

}

--[[ Other Utility Sets ]]--
sets.TH = { -- Treasure Hunter gear equipped while engaged

}

sets.CP = { -- CP gear equipped all the time
    back = "Aptitude Mantle"
}
