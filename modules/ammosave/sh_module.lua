--------------------------------------------------------------------------------------------------------
lia.ammo = lia.ammo or {}
--------------------------------------------------------------------------------------------------------
MODULE.ammoList = {}
--------------------------------------------------------------------------------------------------------
MODULE.name = "Ammo Saver"
MODULE.author = "STEAM_0:1:176123778/Black Tea"
MODULE.desc = "Saves the ammo of a character."
--------------------------------------------------------------------------------------------------------
lia.util.include("sv_module.lua")
--------------------------------------------------------------------------------------------------------
lia.config.AmmoRegister = {"ar2", "pistol", "357", "smg1", "xbowbolt", "buckshot", "rpg_round", "smg1_grenade", "grenade", "ar2altfire", "slam", "alyxgun", "sniperround", "sniperpenetratedround", "thumper", "gravity", "battery", "gaussenergy", "combinecannon", "airboatgun", "striderminigun", "helicoptergun"}
--------------------------------------------------------------------------------------------------------
lia.config.Ammo = {
    ["7.92x33mm Kurz"] = "ar2",
    ["300 AAC Blackout"] = "ar2",
    ["5.7x28mm"] = "ar2",
    ["7.62x25mm Tokarev"] = "smg1",
    [".50 BMG"] = "ar2",
    ["5.56x45mm"] = "ar2",
    ["7.62x51mm"] = "ar2",
    ["7.62x31mm"] = "ar2",
    ["Frag Grenades"] = "grenade",
    ["Flash Grenades"] = "grenade",
    ["Smoke Grenades"] = "grenade",
    ["9x17MM"] = "pistol",
    ["9x19MM"] = "pistol",
    ["9x19mm"] = "pistol",
    [".45 ACP"] = "pistol",
    ["9x18MM"] = "pistol",
    ["9x39MM"] = "pistol",
    [".40 S&W"] = "pistol",
    [".44 Magnum"] = "357",
    [".50 AE"] = "357",
    ["5.45x39MM"] = "ar2",
    ["5.56x45MM"] = "ar2",
    ["5.7x28MM"] = "ar2",
    ["7.62x51MM"] = "ar2",
    ["7.62x54mmR"] = "ar2",
    ["12 Gauge"] = "buckshot",
    [".338 Lapua"] = "sniperround",
}

--------------------------------------------------------------------------------------------------------
function lia.ammo.register(name)
    table.insert(MODULE.ammoList, name)
end

--------------------------------------------------------------------------------------------------------
for k, v in pairs(lia.config.Ammo) do
    lia.ammo.register(v)
    lia.ammo.register(k)
end

--------------------------------------------------------------------------------------------------------
for _, v in pairs(lia.config.AmmoRegister) do
    lia.ammo.register(v)
end
--------------------------------------------------------------------------------------------------------