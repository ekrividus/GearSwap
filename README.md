# GearSwap

FFXI gearswap files that are currently the preferred flavor by me. I'm still actively working on this, there are some "features" that may or may not persist. Some features that are not working 100%. Some features aka bugs that have yet to be dealt with as they don't negatively impact overall function, just the odd error line then everything continues working as expected. There are also plenty of things I plan to do that I haven't yet. 
 
Largely this started as a way for me to not need to rewrite things across alts. It evolved over time as I found myself playing more jobs on each alt. It then took a few more big turns when LS members began asking for my gearswaps, and even a few non-LS members began asking. And well each of them offered a suggestion or pointed out a bug or other bit of funkiness. It has grown and changed.  

I try extremely hard not to alter core set names and to ensure that newly added set changing logic doesn't break if a set isn't defined. Occasionally that goes wrong though so I'd backup your current version before pulling any changes, just in case.

Honestly I'm entirely too lazy and tired to write out everything this gearswap does. A few key features, imo:
* Automatically maintains Manuevers, you need to put them up first it only maintains what you already have up.
* Automatically maintains "stances" like Yonin/Innin or Hasso/Seigan.
* Provides for keybound weapon and gear changes:
  * Idle gear: Standard, Refresh, Regen, Movement, and Town sets
  * Weapon sets for every occasion, you make them and name them it'll cycle whatever you make
  * Gear changes for Melee, Ranged, WS, and Magic Accuracy levels 
    * Melee sets can be defined per weapon_set so you can have different acc gearing for Calad v. Lib and the like
  * DT sets: DT, Max DT, PDT, MDT, and MEva sets all at a keypress
  * Pet sets: Pets are why this all began, there's lots of pet sets
  * Pet Hybrid sets: Yep more pet sets
  * Singing sets
  * Geomancy sets
  * Nuking sets, not to be confused with
  * Magic Bursting sets
  * TH sets, full-time or by WS using a simple macro command outlined later
  * Enmity sets, up, down or general
  * CP set: I actually don't remember exactly how this set works anymore
* A keybind to reequip your current aftercast set for those pesky mobs that strip gear
* More that I'm sure I'm forgetting

## Keybinds (currently located inside gs_functions, this is going to change soon ...)
These send gearswap commands to cycle/toggle various modes/gear/weapon/dt/cp/etc.  
This list of keybinds is going to get moved to a more user friendly place so that anyone can modify them and they won't be overwritten if/when I make changes to this particular file. Much like the Character_gear.lua setup is done there will be a keybinds.lua tucked in somewhere that anyone can safely edit.  

-- CTRL + FKey cycles various gearing modes  
CTRL + f7 gs c melee  
CTRL + f8 gs c ranged  
CTRL + f9 gs c ws  
CTRL + f10 gs c magic  
CTRL + f11 gs c interrupt  
CTRL + f12 gs c idle  

-- ALT + FKey cycles enmity and pet settings  
ALT + f7 gs c enmity  
ALT + f10 gs c pettype  
ALT + f11 gs c petpriority  
ALT + f12 gs c petdt  

-- Win + FKey Toggle various special modes  
Windows + f7 gs c cp  
Windows + f8 gs c th  
Windows + f12 gs c gearup  

-- Shift + FKey Toggle various base gear options  
Shift + f7 gs c weapon_f  
Shift + f8 gs c dual  
Shift + f9 gs c dt  
Shift + f10 gs c pdt  
Shift + f11 gs c mdt  
Shift + f12 gs c meva  

-- CTRL + Shift + FKey  
CTRL + Shift + f7 gs c weapon_b  

## Other commands, not currently keybound since they are kind of best used in a macro
Other commands  
gs c th_ws  
will tell gearswap to use the sets.WS.TH set on top of any other WS set for the next WS, automatically toggled off in aftercast best used in a macro like:  
```
/con gs c th_ws  
/ws "Aeolian Edge" <stnpc>  
```

gs c bursting 
will tell gearswap that you are going to be magic bursting and to use sets from the sets.Magic group that include a MB if possible. This will cascade sets including sets.Magic.MB sets.Magic.Elemental.MB etc. down to sets.Magic.Elemental["Stone VI"].MB with more specific sets getting applied last.

gs c notbursting
Will tell gearswap that you are no longer magic bursting and to stop using sets including MB. 

The previous 2 commands pair well in macros or with autoMB when the gearswap option is toggled on.
