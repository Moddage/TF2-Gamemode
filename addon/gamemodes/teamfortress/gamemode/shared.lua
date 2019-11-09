--[[
local old_include = include

function include(name)
	local time_start = SysTime()
	old_include(name)
	MsgN(Format("Included Lua file '%s', %f secs to load", name, SysTime() - time_start))
end
]]


sound.Add( {
	name = "Weapon_SMG1.Single",
	volume = 1.0,
	level = 120,
	channel = CHAN_WEAPON,
	pitch = { 94, 105 },
	sound = { ")weapons/smg1/smg1_fire1.wav" } 
} )
sound.Add( {
	name = "Weapon_SMG1.Burst",
	volume = 1.0,
	level = 120,
	pitch = { 94, 105 },
	channel = CHAN_WEAPON,
	sound = { "weapons/smg1/smg1_fireburst1.wav" } 
} )
sound.Add( {
	name = "AlienSlavePowerup",
	volume = 1.0,
	level = 140,
	channel = CHAN_WEAPON,
	pitch = { 130 },
	sound = { "debris/zap4.wav" } 
} )
sound.Add( {
	name = "AlienSlavePowerup2",
	volume = 1.0,
	level = 140,
	channel = CHAN_WEAPON,
	pitch = { 140 },
	sound = { "debris/zap4.wav" } 
} )
sound.Add( {
	name = "AlienSlavePowerup3",
	volume = 1.0,
	level = 140,
	channel = CHAN_WEAPON,
	pitch = { 150 },
	sound = { "debris/zap4.wav" } 
} )
sound.Add( {
	name = "AlienSlavePowerup4",
	volume = 1.0,
	level = 140,
	channel = CHAN_WEAPON,
	pitch = { 160 },
	sound = { "debris/zap4.wav" } 
} )
sound.Add( {
	name = "Weapon_AR2.Single",
	volume = 1.0,
	level = 150,
	pitch = { 85,95 },
	channel = CHAN_WEAPON,
	sound = { "weapons/ar2/fire1.wav" } 
} )
sound.Add( {
	name = "Weapon_Shotgun.Single",
	volume = 1.0,
	level = 150,
	pitch = { 92, 103 },
	channel = CHAN_WEAPON,
	sound = { "weapons/shotgun/shotgun_fire6.wav" } 
} )
sound.Add( {
	name = "Weapon_Shotgun.Double",
	volume = 1.0,
	level = 150,
	pitch = { 92, 103 },
	channel = CHAN_WEAPON,
	sound = { "weapons/shotgun/shotgun_dbl_fire.wav" } 
} )
sound.Add( {
	name = "Weapon_Pistol.Single",
	volume = 1.0,
	level = 150,
	pitch = { 100 },
	channel = CHAN_WEAPON,
	sound = { "^weapons/pistol/pistol_fire3.wav" } 
} )
sound.Add( {
	name = "Weapon_SuperShotGun.TubeOpen",
	volume = 1.0,
	level = 90,
	pitch = { 100 },
	sound = { "weapons/supershotgun_tube_open.wav" } 
} )
sound.Add( {
	name = "Weapon_SuperShotGun.TubeClose",
	volume = 1.0,
	level = 90,
	pitch = { 100 },
	sound = { "weapons/supershotgun_tube_close.wav" } 
} )
sound.Add( {
	name = "Weapon_SuperShotGun.ShellsIn",
	volume = 1.0,
	level = 90,
	pitch = { 100 },
	sound = { "weapons/supershotgun_shells_in.wav" } 
} )
sound.Add( {
	name = "Weapon_GrenadeLauncherDM.Cock_Back",
	volume = 1.0,
	level = 90,
	pitch = { 100 },
	sound = { "weapons/grenade_launcher_dm_cock_back.wav" } 
} )

sound.Add( {
	name = "Heavy.BattleCry01",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_battlecry01.wav" } 
} )
sound.Add( {
	name = "Heavy.Go01",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_Go01.wav" } 
} )
sound.Add( {
	name = "Heavy.Go02",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_Go02.wav" } 
} )
sound.Add( {
	name = "Heavy.Go03",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_Go03.wav" } 
} )

sound.Add( {
	name = "Heavy.BattleCry02",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_battlecry02.wav" } 
} )
sound.Add( {
	name = "Heavy.BattleCry03",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_battlecry03.wav" } 
} )
sound.Add( {
	name = "Heavy.BattleCry04",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_battlecry04.wav" } 
} )
sound.Add( {
	name = "Heavy.BattleCry05",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_battlecry05.wav" } 
} )
sound.Add( {
	name = "Heavy.BattleCry06",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_battlecry06.wav" } 
} )
sound.Add( {
	name = "Heavy.PainSharp05",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_PainSharp05.wav" } 
} )
sound.Add( {
	name = "Heavy.PainSharp04",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_PainSharp04.wav" } 
} )

sound.Add( {
	name = "Heavy.PainSharp03",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_PainSharp03.wav" } 
} )

sound.Add( {
	name = "Heavy.PainSharp02",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_PainSharp02.wav" } 
} )


sound.Add( {
	name = "Heavy.PainSharp01",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_PainSharp01.wav" } 
} )

sound.Add( {
	name = "Heavy.PainSevere01",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_PainSevere01.wav" } 
} )

sound.Add( {
	name = "Heavy.PainSevere02",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_PainSevere02.wav" } 
} )

sound.Add( {
	name = "Heavy.PainSevere03",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_PainSevere03.wav" } 
} )


sound.Add( {
	name = "Scout.PainSharp05",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Scout_PainSharp05.wav" } 
} )

sound.Add( {
	name = "Scout.PainSharp06",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Scout_PainSharp06.wav" } 
} )

sound.Add( {
	name = "Scout.PainSharp07",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Scout_PainSharp07.wav" } 
} )


sound.Add( {
	name = "Scout.PainSharp08",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Scout_PainSharp08.wav" } 
} )
sound.Add( {
	name = "Scout.PainSharp04",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Scout_PainSharp04.wav" } 
} )

sound.Add( {
	name = "Scout.PainSharp03",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Scout_PainSharp03.wav" } 
} )

sound.Add( {
	name = "Heavy.PainSharp02",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Heavy_PainSharp02.wav" } 
} )

sound.Add( {
	name = "Heavy.Cheers01",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Heavy_Cheers01.wav" } 
} )
sound.Add( {
	name = "Heavy.Cheers02",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Heavy_Cheers02.wav" } 
} )
sound.Add( {
	name = "Heavy.Cheers03",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Heavy_Cheers03.wav" } 
} )
sound.Add( {
	name = "Heavy.Cheers04",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Heavy_Cheers04.wav" } 
} )

sound.Add( {
	name = "Heavy.Cheers05",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Heavy_Cheers05.wav" } 
} )

sound.Add( {
	name = "Heavy.Cheers06",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Heavy_Cheers06.wav" } 
} )


sound.Add( {
	name = "Heavy.Cheers07",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Heavy_Cheers07.wav" } 
} )


sound.Add( {
	name = "Heavy.Cheers08",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Heavy_Cheers08.wav" } 
} )

sound.Add( {
	name = "Heavy.Generic01",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Heavy_Generic01.wav" } 
} )








sound.Add( {
	name = "Scout.PainSharp01",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Scout_PainSharp01.wav" } 
} )

sound.Add( {
	name = "Scout.PainSevere01",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Scout_PainSevere01.wav" } 
} )

sound.Add( {
	name = "Scout.PainSevere02",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Scout_PainSevere02.wav" } 
} )

sound.Add( {
	name = "Scout.PainSevere03",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Scout_PainSevere03.wav" } 
} )
sound.Add( {
	name = "Scout.PainSevere04",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Scout_PainSevere04.wav" } 
} )
sound.Add( {
	name = "Scout.PainSevere05",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Scout_PainSevere05.wav" } 
} )
sound.Add( {
	name = "Scout.PainSevere06",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Scout_PainSevere06.wav" } 
} )
sound.Add( {
	name = "Scout.BattleCry01",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Scout_BattleCry01.wav" } 
} )
sound.Add( {
	name = "Scout.BattleCry02",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Scout_BattleCry02.wav" } 
} )
sound.Add( {
	name = "Scout.BattleCry03",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Scout_BattleCry03.wav" } 
} )
sound.Add( {
	name = "Scout.BattleCry04",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Scout_BattleCry04.wav" } 
} )
sound.Add( {
	name = "Scout.BattleCry05",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/Scout_BattleCry05.wav" } 
} )



sound.Add( {
	name = "Heavy.HelpMe01",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_helpme01.wav" } 
} )
sound.Add( {
	name = "Heavy.HelpMe02",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_helpme02.wav" } 
} )
sound.Add( {
	name = "Heavy.HelpMe03",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_helpme03.wav" } 
} )
sound.Add( {
	name = "Heavy.Meleeing01",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_meleeing01.wav" } 
} )
sound.Add( {
	name = "Heavy.Meleeing02",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_meleeing02.wav" } 
} )
sound.Add( {
	name = "Heavy.Meleeing03",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_meleeing03.wav" } 
} )
sound.Add( {
	name = "Heavy.Meleeing04",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_meleeing04.wav" } 
} )
sound.Add( {
	name = "Heavy.Meleeing05",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_meleeing05.wav" } 
} )
sound.Add( {
	name = "Heavy.Meleeing06",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_meleeing06.wav" } 
} )
sound.Add( {
	name = "Heavy.Meleeing07",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_meleeing07.wav" } 
} )
sound.Add( {
	name = "Heavy.Meleeing08",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_meleeing08.wav" } 
} )
sound.Add( {
	name = "Heavy.Meleeing09",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_meleeing09.wav" } 
} )
sound.Add( {
	name = "Heavy.SandwichTaunt01",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_SandwichTaunt01.wav" } 
} )
sound.Add( {
	name = "Heavy.SandwichTaunt02",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_SandwichTaunt02.wav" } 
} )
sound.Add( {
	name = "Heavy.SandwichTaunt03",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_SandwichTaunt03.wav" } 
} )
sound.Add( {
	name = "Heavy.SandwichTaunt04",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_SandwichTaunt04.wav" } 
} )
sound.Add( {
	name = "Heavy.SandwichTaunt05",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_SandwichTaunt05.wav" } 
} )
sound.Add( {
	name = "Heavy.SandwichEat",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/SandwichEat09.wav" } 
} )
sound.Add( {
	name = "Heavy.SandwichTaunt06",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_SandwichTaunt06.wav" } 
} )
sound.Add( {
	name = "Heavy.SandwichTaunt07",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_SandwichTaunt07.wav" } 
} )
sound.Add( {
	name = "Heavy.SandwichTaunt08",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_SandwichTaunt08.wav" } 
} )
sound.Add( {
	name = "Heavy.SandwichTaunt09",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_SandwichTaunt09.wav" } 
} )
sound.Add( {
	name = "Heavy.SandwichTaunt10",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_SandwichTaunt10.wav" } 
} )
sound.Add( {
	name = "Heavy.SandwichTaunt11",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_SandwichTaunt11.wav" } 
} )
sound.Add( {
	name = "Heavy.SandwichTaunt12",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_SandwichTaunt12.wav" } 
} )
sound.Add( {
	name = "Heavy.SandwichTaunt13",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_SandwichTaunt13.wav" } 
} )
sound.Add( {
	name = "Heavy.SandwichTaunt14",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_SandwichTaunt14.wav" } 
} )
sound.Add( {
	name = "Heavy.SandwichTaunt15",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_SandwichTaunt15.wav" } 
} )
sound.Add( {
	name = "Heavy.SandwichTaunt16",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_SandwichTaunt16.wav" } 
} )
sound.Add( {
	name = "Heavy.SandwichTaunt17",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_SandwichTaunt17.wav" } 
} )
sound.Add( {
	name = "Heavy.PainCrticialDeath01",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_PainCrticialDeath01.wav" } 
} )
sound.Add( {
	name = "Heavy.PainCrticialDeath02",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_PainCrticialDeath02.wav" } 
} )
sound.Add( {
	name = "Heavy.PainCrticialDeath03",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "vo/heavy_PainCrticialDeath03.wav" } 
} )
sound.Add( {
	name = "Weapon_GrenadeLauncherDM.Cock_Forward",
	volume = 1.0,
	level = 90,
	pitch = { 100 },
	sound = { "weapons/grenade_launcher_dm_cock_forward.wav" } 
} )
sound.Add( {
	name = "Weapon_GrenadeLauncherDM.DrumLoad",
	volume = 1.0,
	level = 90,
	pitch = { 100 },
	sound = { "weapons/grenade_launcher_dm_drum_load.wav" } 
} )
sound.Add( {
	name = "Weapon_Pistol.SlideForward",
	volume = 1.0,
	level = 90,
	pitch = { 100 },
	sound = { "weapons/pistol_slideforward.wav" } 
} )
sound.Add( {
	name = "Weapon_Pistol.SlideBack",
	volume = 1.0,
	level = 90,
	pitch = { 100 },
	sound = { "weapons/pistol_slideback.wav" } 
} )
sound.Add( {
	name = "Weapon_Pistol.ClipIn",
	volume = 1.0,
	level = 90,
	pitch = { 100 },
	sound = { "weapons/pistol_clipin.wav" } 
} )
sound.Add( {
	name = "Weapon_Pistol.ClipOut",
	volume = 1.0,
	level = 90,
	pitch = { 100 },
	sound = { "weapons/pistol_clipout.wav" } 
} )

sound.Add( {
	name = "Weapon_Crowbar.Single",
	volume = 1.0,
	level = 90,
	pitch = { 85, 100 },
	sound = { "^weapons/iceaxe/iceaxe_swing1.wav" } 
} )
sound.Add( {
	name = "DosidoIntro",
	volume = 1.0,
	level = 90,
	channel = CHAN_REPLACE,
	pitch = { 100 },
	sound = { "music/fortress_reel_loop.wav" } 
} )
sound.Add( {
	name = "Weapon_Crowbar_HL1.HitFlesh",
	volume = 1.0,
	level = 90,
	pitch = { 100 },
	sound = { "^weapons/hl1/cbar_hitbod1.wav",  "^weapons/hl1/cbar_hitbod2.wav", "^weapons/hl1/cbar_hitbod3.wav" } 
} )
sound.Add( {
	name = "Weapon_Crowbar_HL1.HitWorld",
	volume = 1.0,
	level = 90,
	pitch = { 100 },
	sound = { "^weapons/hl1/cbar_hit1.wav",  "^weapons/hl1/cbar_hit2.wav"} 
} )
sound.Add( {
	name = "ClassSelection.ThemeNonMVM",
	volume = 1.0,
	level = 50,
	pitch = { 100 },
	sound = { "music/class_menu_bg.wav"} 
} )
sound.Add( {
	name = "ClassSelection.ThemeL4D",
	volume = 1.0,
	level = 50,
	pitch = { 100 },
	sound = { "music/unalive/themonsterswithin_l4d1.wav"} 
} )

sound.Add( {
	name = "Tank.Yell",
	channel = CHAN_VOICE,
	volume = 1.0,
	level = 120,
	pitch = { 100 },
	sound = { "vj_l4d/tank/voice/yell/tank_yell_01.wav","vj_l4d/tank/voice/yell/tank_yell_02.wav","vj_l4d/tank/voice/yell/tank_yell_03.wav","vj_l4d/tank/voice/yell/tank_yell_04.wav","vj_l4d/tank/voice/yell/tank_yell_05.wav","vj_l4d/tank/voice/yell/tank_yell_06.wav","vj_l4d/tank/voice/yell/tank_yell_07.wav","vj_l4d/tank/voice/yell/tank_yell_08.wav","vj_l4d/tank/voice/yell/tank_yell_09.wav","vj_l4d/tank/voice/yell/tank_yell_10.wav","vj_l4d/tank/voice/yell/tank_yell_11.wav","vj_l4d/tank/voice/yell/tank_yell_12.wav","vj_l4d/tank/voice/yell/tank_yell_13.wav","vj_l4d/tank/voice/yell/tank_yell_14.wav","vj_l4d/tank/voice/yell/hulk_yell_1.wav","vj_l4d/tank/voice/yell/hulk_yell_2.wav","vj_l4d/tank/voice/yell/hulk_yell_3.wav","vj_l4d/tank/voice/yell/hulk_yell_4.wav","vj_l4d/tank/voice/yell/hulk_yell_5.wav","vj_l4d/tank/voice/yell/hulk_yell_6.wav","vj_l4d/tank/voice/yell/hulk_yell_7.wav","vj_l4d/tank/voice/yell/hulk_yell_8.wav"} 
} )
sound.Add( {
	name = "Charger.Idle",
	channel = CHAN_VOICE,
	volume = 1.0,
	level = 120,
	pitch = { 100 },
	sound = {"charger/voice/alert/charger_alert_01.wav","charger/voice/alert/charger_alert_02.wav","charger/voice/idle/charger_lurk_01.wav","charger/voice/idle/charger_lurk_01.wav","charger/voice/idle/charger_lurk_02.wav","charger/voice/idle/charger_lurk_03.wav","charger/voice/idle/charger_lurk_04.wav","charger/voice/idle/charger_lurk_05.wav","charger/voice/idle/charger_lurk_06.wav","charger/voice/idle/charger_lurk_07.wav","charger/voice/idle/charger_lurk_08.wav","charger/voice/idle/charger_lurk_09.wav","charger/voice/idle/charger_lurk_10.wav","charger/voice/idle/charger_lurk_11.wav","charger/voice/idle/charger_lurk_14.wav","charger/voice/idle/charger_lurk_15.wav","charger/voice/idle/charger_lurk_16.wav","charger/voice/idle/charger_lurk_17.wav","charger/voice/idle/charger_lurk_18.wav","charger/voice/idle/charger_lurk_19.wav","charger/voice/idle/charger_lurk_20.wav","charger/voice/idle/charger_lurk_21.wav","charger/voice/idle/charger_lurk_22.wav","charger/voice/idle/charger_lurk_23.wav","charger/voice/idle/charger_spotprey_01.wav","charger/voice/idle/charger_spotprey_02.wav","charger/voice/idle/charger_spotprey_03.wav"} 
} )
sound.Add( {
	name = "Jockey.Idle",
	channel = CHAN_VOICE,
	volume = 1.0,
	level = 120,
	pitch = { 100 },
	sound = {"jockey/voice/idle/jockey_lurk01.wav","jockey/voice/idle/jockey_lurk03.wav","jockey/voice/idle/jockey_lurk04.wav","jockey/voice/idle/jockey_lurk05.wav","jockey/voice/idle/jockey_lurk06.wav","jockey/voice/idle/jockey_lurk07.wav","jockey/voice/idle/jockey_lurk09.wav","jockey/voice/idle/jockey_lurk11.wav","jockey/voice/idle/jockey_recognize02.wav","jockey/voice/idle/jockey_recognize06.wav","jockey/voice/idle/jockey_recognize07.wav","jockey/voice/idle/jockey_recognize08.wav","jockey/voice/idle/jockey_recognize09.wav","jockey/voice/idle/jockey_recognize10.wav","jockey/voice/idle/jockey_recognize11.wav","jockey/voice/idle/jockey_recognize12.wav","jockey/voice/idle/jockey_recognize13.wav","jockey/voice/idle/jockey_recognize15.wav","jockey/voice/idle/jockey_recognize16.wav","jockey/voice/idle/jockey_recognize16.wav","jockey/voice/idle/jockey_recognize18.wav","jockey/voice/idle/jockey_recognize19.wav","jockey/voice/idle/jockey_recognize20.wav","jockey/voice/idle/jockey_recognize24.wav","jockey/voice/idle/jockey_spotprey_01.wav","jockey/voice/idle/jockey_spotprey_02.wav"} 
} ) 
sound.Add( {
	name = "ClassSelection.ThemeMVM",
	volume = 1.0,
	level = 50,
	pitch = { 100 },
	sound = { "music/mvm_class_menu_bg.wav"} 
} )
sound.Add( {
	name = "Hunter.Music",
	volume = 1.0,
	level = 50,
	pitch = { 100 },
	sound = { "music/pzattack/exenteration.wav"} 
} )
sound.Add( {
	name = "Jockey.Music",
	volume = 1.0,
	level = 50,
	pitch = { 100 },
	sound = { "music/pzattack/vassalation.wav"} 
} )
sound.Add( {
	name = "BaseExplosionEffect.Sound",
	volume = 1.0,
	level = 95,
	pitch = { 100 },
	sound = { "tf/weapons/explode1.wav",  "tf/weapons/explode2.wav",  "tf/weapons/explode3.wav"} 
} )
sound.Add( {
	name = "NPC_AntlionGuard.StepLight",
	level = 75,
	pitch = { 70, 85 },
	sound = { "npc/antlion_guard/foot_light1.wav", "npc/antlion_guard/foot_light2.wav" } 
} )
sound.Add( {
	name = "NPC_AntlionGuard.StepHeavy",
	pitch = { 70, 85 },
	level = 75,
	sound = { "^npc/antlion_guard/antlionguard_foot_heavy1.wav", "^npc/antlion_guard/antlionguard_foot_heavy2.wav" }  
} )
sound.Add( {
	name = "NPC_AntlionGuard.FarStepLight",
	pitch = { 70, 85 },
	level = 155,
	sound = { "npc/antlion_guard/far_foot_light1.wav", "npc/antlion_guard/far_foot_light2.wav" }  
} )
sound.Add( {
	name = "NPC_AntlionGuard.FarStepHeavy",
	pitch = { 70, 85 },
	level = 155,
	sound = { "npc/antlion_guard/far_foot_heavy1.wav", "npc/antlion_guard/far_foot_heavy2.wav" }  
} )
sound.Add( {
	name = "NPC_AntlionGuard.NearStepLight",
	pitch = { 70, 85 },
	level = 125,
	sound = { "npc/antlion_guard/near_foot_heavy1.wav", "npc/antlion_guard/near_foot_heavy2.wav" }  
} )
sound.Add( {
	name = "NPC_CombineDropship.NearRotorLoop",
	pitch = 100,
	level = 150,
	sound = { "^npc/combine_gunship/dropship_engine_loop1.wav" } 
} )
sound.Add( {
	name = "NPC_Vortigaunt.RangedAttack",
	pitch = 150,
	level = 110,
	sound = { "npc/vort/attack_charge.wav" } 
} )
sound.Add( {
	name = "NPC_CombineDropship.RotorLoop",
	pitch = 100,
	level = 150,
	sound = { "^npc/combine_gunship/dropship_engine_loop1.wav" }
} )
sound.Add( {
	name = "NPC_AntlionGuard.NearStepHeavy",
	pitch = { 70, 85 },
	level = 85,
	sound = { "npc/antlion_guard/near_foot_heavy1.wav", "npc/antlion_guard/near_foot_heavy2.wav" } 
} )
sound.Add( {
	name = "Weapon_QuadLauncher.Reload",
	pitch = { 70, 105 },
	level = 85,
	sound = { "weapons/quake_ammo_pickup_remastered.wav" } 
} )
sound.Add( {
	name = "Weapon_QuadLauncher.Shoot",
	pitch = { 70, 105 },
	level = 85,
	channel = CHAN_WEAPON,
	sound = { "weapons/quake_rpg_fire_remastered.wav" } 
} )
sound.Add( {
	name = "Flesh.ImpactSoft",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "tf/physics/body/body_medium_impact_soft1.wav", "tf/physics/body/body_medium_impact_soft2.wav", "tf/physics/body/body_medium_impact_soft3.wav", "tf/physics/body/body_medium_impact_soft4.wav", "tf/physics/body/body_medium_impact_soft5.wav", "tf/physics/body/body_medium_impact_soft6.wav", "tf/physics/body/body_medium_impact_soft7.wav"} 
} )
sound.Add( {
	name = "Flesh.ImpactHard",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "tf/physics/body/body_medium_impact_hard1.wav", "tf/physics/body/body_medium_impact_hard2.wav", "tf/physics/body/body_medium_impact_hard3.wav", "tf/physics/body/body_medium_impact_hard4.wav", "tf/physics/body/body_medium_impact_hard5.wav", "tf/physics/body/body_medium_impact_hard6.wav"} 
} )

sound.Add( {
	name = "Selection.HeavyFootStomp",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_foot_stomp.wav"} 
} )

sound.Add( {
	name = "Selection.PyroFootStomp",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_foot_stomp.wav"} 
} )


sound.Add( {
	name = "Selection.HeavyEquipment1",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_equipment_gun2.wav"} 
} )

sound.Add( {
	name = "Selection.HeavyEquipment2",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_equipment_gun1.wav"} 
} )

sound.Add( {
	name = "Selection.PyroEquipment1",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_equipment_jingle3.wav"} 
} )

sound.Add( {
	name = "Selection.PyroEquipment2",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_equipment_jingle2.wav"} 
} )


sound.Add( {
	name = "Selection.EngineerWrenchShoulder",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_shotgun_shoulder.wav"} 
} )

sound.Add( {
	name = "Selection.EngineerFootStomp",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_foot_stomp.wav"} 
} )	

sound.Add( {
	name = "Selection.EngineerClothesRustle",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_clothes_rustle.wav"} 
} )


sound.Add( {
	name = "Taunt.Heavy01HoldGun",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_grenade_catch.wav"} 
} )


sound.Add( {
	name = "Taunt.Heavy01ClothesRustle",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_clothes_rustle.wav"} 
} )


sound.Add( {
	name = "Taunt.Heavy01EquipmentGun",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_equipment_gun1.wav"} 
} )

sound.Add( {
	name = "Taunt.Heavy01EquipmentGun2",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_equipment_gun2.wav"} 
} )

sound.Add( {
	name = "Taunt.Heavy01EquipmentRustleHeavy",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_equipment_jingle2.wav"} 
} )
sound.Add( {
	name = "Taunt.Heavy01HoldGunLight",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_hand_clap2.wav"} 
} )

sound.Add( {
	name = "Selection.HeavyClothesRustle",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_clothes_rustle.wav"} 
} )


sound.Add( {
	name = "Selection.ScoutShotgunShoulder",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_shotgun_shoulder.wav"} 
} )


sound.Add( {
	name = "Selection.MedicHeelClick",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_heel_click.wav"} 
} )

sound.Add( {
	name = "Selection.MedicFootStomp",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_foot_stomp.wav"} 
} )	

sound.Add( {
	name = "Selection.MedicFootSlide",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_foot_spin.wav"} 
} )	

sound.Add( {
	name = "Selection.ScoutShotgunTwirl",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_shotgun_twirl.wav"} 
} )

sound.Add( {
	name = "Selection.PyroClothesRustle",
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = {"player/taunt_clothes_rustle.wav"} 
} )

sound.Add( {
	name = "Dirt.StepLeft",
	volume = 1.0,
	level = 95,
	pitch = { 92, 103 },
	channel = CHAN_BODY,
	sound = {"tf/player/footsteps/dirt1.wav","tf/player/footsteps/dirt3.wav","tf/player/footsteps/dirt2.wav","tf/player/footsteps/dirt4.wav"} 
} )
sound.Add( {
	name = "Dirt.StepRight",
	volume = 1.0,
	level = 95,
	pitch = { 92, 103 },
	channel = CHAN_BODY,
	sound = {"tf/player/footsteps/dirt2.wav","tf/player/footsteps/dirt4.wav","tf/player/footsteps/dirt1.wav","tf/player/footsteps/dirt3.wav"} 
} )
sound.Add( {
	name = "Grass.StepLeft",
	volume = 1.0,
	level = 95,
	pitch = { 92, 103 },
	channel = CHAN_BODY,
	sound = {"tf/player/footsteps/grass1.wav","tf/player/footsteps/grass3.wav","tf/player/footsteps/grass2.wav","tf/player/footsteps/grass4.wav"} 
} )
sound.Add( {
	name = "MVM.GiantHeavyStep",
	volume = 1.0,
	level = 150,
	pitch = 100,
	channel = CHAN_BODY,
	sound = {"^mvm/giant_common/giant_common_step_01.wav","^mvm/giant_common/giant_common_step_02.wav","^mvm/giant_common/giant_common_step_03.wav","^mvm/giant_common/giant_common_step_04.wav","^mvm/giant_common/giant_common_step_05.wav","^mvm/giant_common/giant_common_step_06.wav","^mvm/giant_common/giant_common_step_07.wav","^mvm/giant_common/giant_common_step_08.wav"} 
} )
sound.Add( {
	name = "Grass.StepRight",
	volume = 1.0,
	level = 95,
	pitch = { 92, 103 },
	channel = CHAN_BODY,
	sound = {"tf/player/footsteps/grass2.wav","tf/player/footsteps/grass4.wav","tf/player/footsteps/grass1.wav","tf/player/footsteps/grass3.wav"} 
} )
sound.Add( {
	name = "Default.StepLeft",
	volume = 1.0,
	level = 95,
	pitch = { 92, 103 },
	channel = CHAN_BODY,
	sound = {"tf/player/footsteps/concrete1.wav","tf/player/footsteps/concrete3.wav","tf/player/footsteps/concrete1.wav","tf/player/footsteps/concrete3.wav"} 
} )
sound.Add( {
	name = "Concrete.StepRight",
	volume = 1.0,
	level = 95,
	pitch = { 92, 103 },
	channel = CHAN_BODY,
	sound = {"tf/player/footsteps/concrete2.wav","tf/player/footsteps/concrete4.wav","tf/player/footsteps/concrete1.wav","tf/player/footsteps/concrete3.wav"} 
} ) 
sound.Add( {
	name = "Concrete.StepLeft",
	volume = 1.0,
	level = 95,
	pitch = { 92, 103 },
	channel = CHAN_BODY,
	sound = {"tf/player/footsteps/concrete1.wav","tf/player/footsteps/concrete3.wav","tf/player/footsteps/concrete1.wav","tf/player/footsteps/concrete3.wav"} 
} )
sound.Add( {
	name = "Default.StepRight",
	volume = 1.0,
	level = 95,
	pitch = { 92, 103 },
	channel = CHAN_BODY,
	sound = {"tf/player/footsteps/concrete2.wav","tf/player/footsteps/concrete4.wav","tf/player/footsteps/concrete1.wav","tf/player/footsteps/concrete3.wav"} 
} ) 
sound.Add( {
	name = "Wood.StepLeft",
	volume = 1.0,
	level = 95,
	pitch = { 92, 103 },
	channel = CHAN_BODY,
	sound = {"tf/player/footsteps/wood1.wav","tf/player/footsteps/wood3.wav","tf/player/footsteps/wood2.wav","tf/player/footsteps/wood4.wav"} 
} )
sound.Add( {
	name = "Wood.StepRight",
	volume = 1.0,
	level = 95,
	pitch = { 92, 103 },
	channel = CHAN_BODY,
	sound = {"tf/player/footsteps/wood2.wav","tf/player/footsteps/wood4.wav","tf/player/footsteps/wood1.wav","tf/player/footsteps/wood3.wav"} 
} )
sound.Add( {
	name = "SolidMetal.StepLeft",
	volume = 1.0,
	level = 95,
	pitch = { 92, 103 },
	channel = CHAN_BODY,
	sound = {"tf/player/footsteps/metal1.wav","tf/player/footsteps/metal3.wav","tf/player/footsteps/metal2.wav","tf/player/footsteps/metal4.wav",} 
} )
sound.Add( {
	name = "SolidMetal.StepRight",
	volume = 1.0,
	level = 95,
	pitch = { 92, 103 },
	channel = CHAN_BODY,
	sound = {"tf/player/footsteps/metal2.wav","tf/player/footsteps/metal4.wav","tf/player/footsteps/metal1.wav","tf/player/footsteps/metal3.wav"} 
} )
sound.Add( {
	name = "Tile.StepLeft",
	volume = 1.0,
	level = 95,
	pitch = { 92, 103 },
	channel = CHAN_BODY,
	sound = {"tf/player/footsteps/tile1.wav","tf/player/footsteps/tile2.wav","tf/player/footsteps/tile3.wav","tf/player/footsteps/tile4.wav"} 
} )
sound.Add( {
	name = "Tile.StepRight",
	volume = 1.0,
	level = 95,
	pitch = { 92, 103 },
	channel = CHAN_BODY,
	sound = {"tf/player/footsteps/tile1.wav","tf/player/footsteps/tile2.wav","tf/player/footsteps/tile3.wav","tf/player/footsteps/tile4.wav"} 
} )
sound.Add( {
	name = "Grass.StepLeft",
	volume = 1.0,
	level = 95,
	pitch = { 92, 103 },
	channel = CHAN_BODY,
	sound = {"tf/player/footsteps/grass1.wav","tf/player/footsteps/grass2.wav","tf/player/footsteps/grass3.wav","tf/player/footsteps/grass4.wav"} 
} )
sound.Add( {
	name = "Grass.StepRight",
	volume = 1.0,
	level = 95,
	pitch = { 92, 103 },
	channel = CHAN_BODY,
	sound = {"tf/player/footsteps/grass1.wav","tf/player/footsteps/grass3.wav","tf/player/footsteps/grass3.wav","tf/player/footsteps/grass4.wav"} 
} )
sound.Add( {
	name = "Weapon_FrontierJustice.Single",
	volume = 1.0,
	level = 95,
	pitch = { 100 },
	sound = {"weapons/frontier_justice_shoot.wav"} 
} )
sound.Add( {
	name = "Weapon_FrontierJustice.SingleCrit",
	volume = 1.0,
	level = 95,
	pitch = { 100 },
	sound = {"weapons/frontier_justice_shoot_crit.wav"} 
} )
sound.Add( {
	name = "HalloweenMerasmus.MERLAGMUS",
	volume = 1.0,
	level = 0,
	channel = CHAN_VOICE,
	pitch = { 100 },
	sound = {
		"vo/halloween_merasmus/sf12_found01.mp3",
		"vo/halloween_merasmus/sf12_found02.mp3",
		"vo/halloween_merasmus/sf12_found03.mp3",
		"vo/halloween_merasmus/sf12_found04.mp3",
		"vo/halloween_merasmus/sf12_found05.mp3",
		"vo/halloween_merasmus/sf12_found07.mp3",
		"vo/halloween_merasmus/sf12_found08.mp3",
		"vo/halloween_merasmus/sf12_found09.mp3",
	}
} )

sound.Add( {
	name = "SappedRobot",
	channel = CHAN_REPLACE,
	volume = 1.0,
	level = 80,
	pitch = { 100 },
	sound = { "weapons/sapper_timer.wav" }
} )
sound.Add( {
	name = "BanjoSong",
	channel = CHAN_REPLACE,
	volume = 1.0,
	level = 80,
	pitch = { 100 },
	sound = { "player/taunt_bumpkins_banjo_music.wav" }
} )
sound.Add( {
	name = "BanjoSongStop",
	channel = CHAN_REPLACE,
	volume = 1.0,
	level = 80,
	pitch = { 100 },
	sound = { "player/taunt_bumpkins_banjo_music_stop.wav" }
} )
sound.Add( {
	name = "GrappledFlesh",
	channel = CHAN_REPLACE,
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "weapons/grappling_hook_impact_flesh_loop.wav" }
} )
sound.Add( {
	name = "BusterLoop",
	channel = CHAN_REPLACE,
	volume = 1.0,
	level = 125,
	pitch = { 100 },
	sound = { "mvm/sentrybuster/mvm_sentrybuster_loop.wav" }
} )
sound.Add( {
	name = "TankMusicLoop",
	channel = CHAN_REPLACE,
	volume = 1.0,
	level = 50,
	pitch = { 100 },
	sound = { "music/tank/taank.wav" }
} )

sound.Add( {
	name = "Ambient.NucleusElectricity",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 105,
	pitch = { 100 },
	sound = { ")ambient/nucleus_electricity.wav" }
} )
sound.Add( {
	name = "Grappling",
	channel = CHAN_REPLACE,
	volume = 1.0,
	level = 75,
	pitch = { 100 },
	sound = { "weapons/grappling_hook_reel_start.wav" }
} )
sound.Add( {
	name = "TappedRobot",
	channel = CHAN_REPLACE,
	volume = 1.0,
	level = 80,
	pitch = { 100 },
	sound = { "weapons/spy_tape_01.wav","weapons/spy_tape_02.wav","weapons/spy_tape_03.wav","weapons/spy_tape_04.wav" ,"weapons/spy_tape_05.wav" }
} )


HOOK_WARNING_THRESHOLD = 0.1

local old_hook_call = hook.Call
function hook.Call(name, gm, ...)
	if HOOK_WARNING_THRESHOLD then
		local time_start = SysTime()
		local res = {old_hook_call(name, gm, ...)}
		local time = SysTime() - time_start
		
		if time > HOOK_WARNING_THRESHOLD then
			MsgFN("Warning: hook '%s' took %f seconds to execute!", name, time)
		end
		
		return unpack(res)
	else
		return old_hook_call(name, gm, ...)
	end
end

if not util.PrecacheModel0 then
	util.PrecacheModel0 = util.PrecacheModel
end

function util.PrecacheModel(mdl)
	if SERVER and game.SinglePlayer() then return end
	return util.PrecacheModel0(mdl)
end

include("particle_manifest.lua")
include("vmatrix_extension.lua")

include("tf_lang_module.lua")
tf_lang.Load("tf_english.txt")

include("particle_manifest.lua")
include("vmatrix_extension.lua")

include("shd_nwtable.lua")
include("shd_utils.lua")
include("shd_enums.lua")
include("tf_util_module.lua")
include("tf_item_module.lua")
include("tf_timer_module.lua")
include("tf_soundscript_module.lua")

include("shd_objects.lua")
include("shd_attributes.lua")
include("shd_loadout.lua")
include("shd_extras.lua")
include("shd_workshop.lua")

include("shd_competitive.lua")
include("shd_spec.lua")

--include("shd_items_temp.lua")

include("shd_maptypes.lua")
include("shd_playeranim.lua")

include("shd_criticals.lua")

include("shd_ragdolls.lua")

include("shd_items_game.lua")
 
tf_soundscript.Load("teamfortress/scripts/game_sounds_weapons_tf.txt")


CreateConVar('tf_talkicon_computablecolor', 1, FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_SERVER_CAN_EXECUTE, 'Compute color from location brightness.')
CreateConVar('tf_talkicon_showtextchat', 1, FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_SERVER_CAN_EXECUTE, 'Show icon on using text chat.')
CreateConVar('tf_talkicon_ignoreteamchat', 1, FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_SERVER_CAN_EXECUTE, 'Disable over-head icon on using team chat.')

hook.Add( "EntityEmitSound", "TimeWarpSounds", function( t )

	local p = t.Pitch

	if ( game.GetTimeScale() != 1 ) then
		p = p * game.GetTimeScale()
	end

	if ( GetConVarNumber( "host_timescale" ) != 1 && GetConVarNumber( "sv_cheats" ) >= 1 ) then
		p = p * GetConVarNumber( "host_timescale" )
	end

	if ( p != t.Pitch ) then
		t.Pitch = math.Clamp( p, 0, 255 )
		return true
	end

	if ( CLIENT && engine.GetDemoPlaybackTimeScale() != 1 ) then
		t.Pitch = math.Clamp( t.Pitch * engine.GetDemoPlaybackTimeScale(), 0, 255 )
		return true
	end

end )

if (SERVER) then

	RunConsoleCommand('mp_show_voice_icons', '0')

	util.AddNetworkString('TalkIconChat')

	net.Receive('TalkIconChat', function(_, ply)
		local bool = net.ReadBool()
		ply:SetNW2Bool('ti_istyping', (bool ~= nil) and bool or false)
	end)

elseif (CLIENT) then

	local computecolor = GetConVar('tf_talkicon_computablecolor')
	local showtextchat = GetConVar('tf_talkicon_showtextchat')
	local noteamchat = GetConVar('tf_talkicon_ignoreteamchat')

	local voice_mat = Material('effects/speech_voice_red')
	local voice_mat2 = Material('effects/speech_voice_blue')
	local text_mat = Material('effects/speech_typing')

	hook.Add('PostPlayerDraw', 'TalkIcon', function(ply)
		if ply == LocalPlayer() and GetViewEntity() == LocalPlayer()
			and (GetConVar('thirdperson') and GetConVar('thirdperson'):GetInt() != 0) then return end
		if not ply:Alive() then return end
		if not ply:IsSpeaking() and not (showtextchat:GetBool() and ply:GetNW2Bool('ti_istyping')) then return end

		local pos = ply:GetPos() + Vector(0, 0, ply:GetModelRadius() + 10)

		if LocalPlayer():Team() == TEAM_BLU then
			render.SetMaterial(ply:IsSpeaking() and voice_mat2 or voice_mat2)
		else
			render.SetMaterial(ply:IsSpeaking() and voice_mat or voice_mat)		
		end

		local color_var = 255

		if computecolor:GetBool() then
			local computed_color = render.ComputeLighting(ply:GetPos(), Vector(0, 0, 1))
			local max = math.max(computed_color.x, computed_color.y, computed_color.z)
			color_var = math.Clamp(max * 255 * 1.11, 0, 255)
		end

		render.DrawSprite(pos, 16, 16, Color(color_var, color_var, color_var, 255))
	end)

	hook.Add('StartChat', 'TalkIcon', function(isteam)
		if isteam and noteamchat:GetBool() then return end
		net.Start('TalkIconChat')
		net.WriteBool(true)
		net.SendToServer()
	end)

	hook.Add('FinishChat', 'TalkIcon', function()
		net.Start('TalkIconChat')
		net.WriteBool(false)
		net.SendToServer() 
	end)

	hook.Add("InitPostEntity", "RemoveChatBubble", function()
		hook.Remove("StartChat", "StartChatIndicator")
		hook.Remove("FinishChat", "EndChatIndicator")

		hook.Remove("PostPlayerDraw", "DarkRP_ChatIndicator")
		hook.Remove("CreateClientsideRagdoll", "DarkRP_ChatIndicator")
		hook.Remove("player_disconnect", "DarkRP_ChatIndicator")
	end)

end

function GM:PostTFLibsLoaded()
end

hook.Call("PostTFLibsLoaded", GM)

GM.Name 		= "Team Fortress 2"
GM.Author 		= "_Kilburn; Fixed by wango911; Ported by Jcw87; Workshopped by Agent Agrimar"
GM.Email 		= "N/A"
GM.Website 		= "N/A"
GM.TeamBased 	= true

GM.Data = {}

DEFINE_BASECLASS("gamemode_sandbox")
DeriveGamemode("sandbox")
GM.IsSandboxDerived = true

function GM:GetGameDescription()
	return self.Name
end

local VoiceMenuChatMessage = {
	["TLK_PLAYER_MEDIC"] = 			"#Voice_Menu_Medic",
	["TLK_PLAYER_THANKS"] = 		"#Voice_Menu_Thanks",
	["TLK_PLAYER_GO"] = 			"#Voice_Menu_Go",
	["TLK_PLAYER_MOVEUP"] = 		"#Voice_Menu_MoveUp",
	["TLK_PLAYER_LEFT"] = 			"#Voice_Menu_Left",
	["TLK_PLAYER_RIGHT"] = 			"#Voice_Menu_Right",
	["TLK_PLAYER_YES"] = 			"#Voice_Menu_Yes",
	["TLK_PLAYER_NO"] = 			"#Voice_Menu_No",
	["TLK_PLAYER_INCOMING"] = 		"#Voice_Menu_Incoming",
	["TLK_PLAYER_CLOAKEDSPY"] = 	"#Voice_Menu_CloakedSpy",
	["TLK_PLAYER_SENTRYAHEAD"] = 	"#Voice_Menu_SentryAhead",
	["TLK_PLAYER_ACTIVATECHARGE"] = "#Voice_Menu_ActivateCharge",
	["TLK_PLAYER_HELP"] = 			"#Voice_Menu_Help",
}

concommand.Remove("__svspeak")

--[[concommand.Add( "changeteam", function( pl, cmd, args )
	--if tonumber( args[ 1 ] ) >= 5 then return end
	hook.Call( "PlayerRequestTeam", GAMEMODE, pl, tonumber( args[ 1 ] ) )
	print("changeteam?? to what, oh, team "..tonumber( args[ 1 ] ).."!")
end )]]

if SERVER then

util.AddNetworkString("ActivateTauntCam")
util.AddNetworkString("DeActivateTauntCam")

concommand.Add("__svspeak", function(pl,_,args)
	if pl:Speak(args[1]) then
		
		umsg.Start("TFPlayerVoice")
			umsg.Entity(pl)
			umsg.String(args[1])
		umsg.End()
	end
end)

concommand.Add("l4d__svspeak", function(pl,_,args)
	if pl:GetPlayerClass() == "tank" then
		pl:EmitSound("Tank.Yell")
	elseif pl:GetPlayerClass() == "charger" then
		pl:EmitSound("Charger.Idle")
	elseif pl:GetPlayerClass() == "boomer" then
		pl:EmitSound("vj_l4d/boomer/voice/idle/boomer_lurk_0"..math.random(1,9)..".wav")
	elseif pl:GetPlayerClass() == "l4d_zombie" then
		pl:EmitSound("vj_l4d_com/attack_b/male/rage_"..math.random(50,82)..".wav")
	end
end)

else

usermessage.Hook("TFPlayerVoice", function(msg)
	local pl = msg:ReadEntity()
	local voice = msg:ReadString()
	
	if not IsValid(pl) or not pl:IsPlayer() then return end
	if pl:Team() ~= TEAM_SPECTATOR and pl:Team() ~= LocalPlayer():Team() then return end
	
	local v = VoiceMenuChatMessage[voice]
	if not v then return end
	
	chat.AddText(
		team.GetColor(pl:Team()),
		Format("(%s) %s", tf_lang.GetRaw("#Voice"), pl:GetName()),
		color_white,
		Format(": %s", tf_lang.GetRaw(v))
	)
end)

end

GIBS_DEMOMAN_START	= 1
GIBS_ENGINEER_START	= 7
GIBS_HEAVY_START	= 14
GIBS_MEDIC_START	= 21
GIBS_PYRO_START		= 29
GIBS_SCOUT_START	= 37
GIBS_SNIPER_START	= 46
GIBS_SOLDIER_START	= 53
GIBS_SPY_START		= 61
GIBS_ORGANS_START	= 68
GIBS_SILLY_START	= 69
GIBS_LAST			= 87

GIB_UNKNOWN		= -1
GIB_HAT			= 0
GIB_LEFTLEG		= 1
GIB_RIGHTLEG	= 2
GIB_LEFTARM		= 3
GIB_RIGHTARM	= 4
GIB_TORSO		= 5
GIB_TORSO2		= 6
GIB_EQUIPMENT1	= 7
GIB_EQUIPMENT2	= 8
GIB_HEAD		= 9
GIB_HEADGEAR1	= 10
GIB_HEADGEAR2	= 11
GIB_ORGAN		= 12

TEAM_RED = 1
TEAM_BLU = 2
TEAM_HIDDEN = 3
TEAM_NEUTRAL = 4

TeamSecondaryColors = {}
function SetTeamSecondaryColor(t, c)
	TeamSecondaryColors[t] = c
end

function GetTeamSecondaryColor(t)
	return TeamSecondaryColors[t] or team.GetColor(t)
end

function GM:CreateTeams()
	team.SetUp(TEAM_RED, "RED", Color(255, 64, 64))
	SetTeamSecondaryColor(TEAM_RED, Color(180, 92, 77))
	team.SetSpawnPoint(TEAM_RED, "info_player_start")
	
	team.SetUp(TEAM_BLU, "BLU", Color(153, 204, 255))
	SetTeamSecondaryColor(TEAM_BLU, Color(104, 124, 155))
	team.SetSpawnPoint(TEAM_BLU, "info_player_start")
	
	team.SetUp(TEAM_NEUTRAL, "NEUTRAL", Color(110, 255, 80))
	SetTeamSecondaryColor(TEAM_NEUTRAL, Color(74, 130, 54))
	team.SetSpawnPoint(TEAM_NEUTRAL, "info_player_start")
	
	team.SetUp(TEAM_SPECTATOR, "Spectator", Color(204, 204, 204))
	SetTeamSecondaryColor(TEAM_SPECTATOR, Color(255, 255, 255))
	team.SetSpawnPoint(TEAM_SPECTATOR, "worldspawn") 
	
end

function GM:EntityName(ent, nolocalize)
	if ent then
		if ent:IsPlayer() and ent:IsValid() then
			return ent:Name()
		elseif ent:IsValid() and list.Get("NPC")[ent:GetClass()] and list.Get("NPC")[ent:GetClass()].Name then
			return list.Get("NPC")[ent:GetClass()].Name
		elseif ent:IsValid() and scripted_ents.GetList()[ent:GetClass()] and scripted_ents.GetList()[ent:GetClass()].t and scripted_ents.GetList()[ent:GetClass()].t.PrintName then
			return scripted_ents.GetList()[ent:GetClass()].t.PrintName
		elseif ent:IsValid() then
			return "#"..ent:GetClass()
		else
			return ""
		end
	end
	return ""
end

function GM:EntityDeathnoticeName(ent, nolocalize)
	if ent:IsWeapon() then
		ent = ent:GetOwner()
	end
	if ent.GetDeathnoticeName then
		return ent:GetDeathnoticeName(nolocalize)
	else
		return self:EntityName(ent, nolocalize)
	end
end

function GM:EntityTargetIDName(ent, nolocalize)
	if ent.GetTargetIDName then
		return ent:GetTargetIDName(nolocalize)
	else
		return self:EntityName(ent, nolocalize)
	end
end

function GM:EntityTeam(ent)
	if not ent or not ent:IsValid() then return TEAM_NEUTRAL end
	
	if type(ent.Team)=="function" then
		return ent:Team()
	elseif isstring(ent.Team) and (ent.Team == "RED" or ent.Team == "BLU" or string.sub(ent:GetModel(), 1, 12) == "models/bots/") then
		if ent.Team == "RED" then
			return TEAM_RED
		elseif ent.Team == "BLU" then
			return TEAM_BLU
		elseif string.sub(ent:GetModel(), 1, 12) == "models/bots/" then
			return TEAM_BLU
		end
	else
		local t = ent:GetNWInt("Team") or 0
		if t>=1 then
			return t
		else
			t = ent:GetNPCData().team
			if not t and IsValid(ent:GetOwner()) then
				return self:EntityTeam(ent:GetOwner())
			else
				if type(t)=="function" then
					return t() or TEAM_NEUTRAL
				else
					return t or TEAM_NEUTRAL
				end
			end
		end
	end
end

function GM:EntityID(ent)
	if ent:IsPlayer() then
		return ent:UserID()
	elseif ent.DeathNoticeEntityID then
		return -ent.DeathNoticeEntityID
	else
		return 0
	end
end

function ParticleSuffix(t)
	if t==TEAM_BLU then return "blue"
	else return "red"
	end
end

function GM:ShouldCollide(ent1, ent2)
	if not IsValid(ent1) or not IsValid(ent2) then
		return true
	end
	
	if ent1.ShouldCollide then
		local c = ent1:ShouldCollide(ent2)
		if c ~= nil then return c end
	end
	
	if ent2.ShouldCollide then
		local c = ent2:ShouldCollide(ent1)
		if c ~= nil then return c end
	end
	
	if IsValid(ent1:GetOwner()) and (ent1:GetOwner():IsPlayer() or ent1:GetOwner():IsNPC()) then ent1 = ent1:GetOwner() end
	if IsValid(ent2:GetOwner()) and (ent2:GetOwner():IsPlayer() or ent2:GetOwner():IsNPC()) then ent2 = ent2:GetOwner() end
	
	local t1 = self:EntityTeam(ent1)
	local t2 = self:EntityTeam(ent2)
	
	if (ent1:IsPlayer() or ent2:IsPlayer()) and (t1==TEAM_RED or t1==TEAM_BLU) and t1==t2 then
		return false
	end
	
	if CLIENT then
		local c1, c2 = ent1:GetClass(), ent2:GetClass()
		
		if c2=="class C_HL2MPRagdoll" then
			c1,c2=c2,c1
		end
		
		if (c1=="class C_HL2MPRagdoll" or c1=="class CLuaEffect") and c2=="class CLuaEffect" then
			return false
		end
	end
	
	--[[
	if ent2:GetClass()=="phys_bone_follower" then
		ent1,ent2 = ent2,ent1
	end]]
	
	return true
end

HumanGibs = {
	"models/player/gibs/demogib001.mdl", -- 1
	"models/player/gibs/demogib002.mdl",
	"models/player/gibs/demogib003.mdl",
	"models/player/gibs/demogib004.mdl",
	"models/player/gibs/demogib005.mdl",
	"models/player/gibs/demogib006.mdl",
	"models/player/gibs/engineergib001.mdl", -- 7
	"models/player/gibs/engineergib002.mdl",
	"models/player/gibs/engineergib003.mdl",
	"models/player/gibs/engineergib004.mdl",
	"models/player/gibs/engineergib005.mdl",
	"models/player/gibs/engineergib006.mdl",
	"models/player/gibs/engineergib007.mdl",
	"models/player/gibs/heavygib001.mdl", -- 14
	"models/player/gibs/heavygib002.mdl",
	"models/player/gibs/heavygib003.mdl",
	"models/player/gibs/heavygib004.mdl",
	"models/player/gibs/heavygib005.mdl",
	"models/player/gibs/heavygib006.mdl",
	"models/player/gibs/heavygib007.mdl",
	"models/player/gibs/medicgib001.mdl", -- 21
	"models/player/gibs/medicgib002.mdl",
	"models/player/gibs/medicgib003.mdl",
	"models/player/gibs/medicgib004.mdl",
	"models/player/gibs/medicgib005.mdl",
	"models/player/gibs/medicgib006.mdl",
	"models/player/gibs/medicgib007.mdl",
	"models/player/gibs/medicgib008.mdl",
	"models/player/gibs/pyrogib001.mdl", -- 29
	"models/player/gibs/pyrogib002.mdl",
	"models/player/gibs/pyrogib003.mdl",
	"models/player/gibs/pyrogib004.mdl",
	"models/player/gibs/pyrogib005.mdl",
	"models/player/gibs/pyrogib006.mdl",
	"models/player/gibs/pyrogib007.mdl",
	"models/player/gibs/pyrogib008.mdl",
	"models/player/gibs/scoutgib001.mdl", -- 37
	"models/player/gibs/scoutgib002.mdl",
	"models/player/gibs/scoutgib003.mdl",
	"models/player/gibs/scoutgib004.mdl",
	"models/player/gibs/scoutgib005.mdl",
	"models/player/gibs/scoutgib006.mdl",
	"models/player/gibs/scoutgib007.mdl",
	"models/player/gibs/scoutgib008.mdl",
	"models/player/gibs/scoutgib009.mdl",
	"models/player/gibs/snipergib001.mdl", -- 46
	"models/player/gibs/snipergib002.mdl",
	"models/player/gibs/snipergib003.mdl",
	"models/player/gibs/snipergib004.mdl",
	"models/player/gibs/snipergib005.mdl",
	"models/player/gibs/snipergib006.mdl",
	"models/player/gibs/snipergib007.mdl",
	"models/player/gibs/soldiergib001.mdl", -- 53
	"models/player/gibs/soldiergib002.mdl",
	"models/player/gibs/soldiergib003.mdl",
	"models/player/gibs/soldiergib004.mdl",
	"models/player/gibs/soldiergib005.mdl",
	"models/player/gibs/soldiergib006.mdl",
	"models/player/gibs/soldiergib007.mdl",
	"models/player/gibs/soldiergib008.mdl",
	"models/player/gibs/spygib001.mdl", -- 61
	"models/player/gibs/spygib002.mdl",
	"models/player/gibs/spygib003.mdl",
	"models/player/gibs/spygib004.mdl",
	"models/player/gibs/spygib005.mdl",
	"models/player/gibs/spygib006.mdl",
	"models/player/gibs/spygib007.mdl",
	"models/player/gibs/random_organ.mdl", -- 68
	"models/player/gibs/gibs_balloon.mdl", -- 69
	"models/player/gibs/gibs_bolt.mdl",
	"models/player/gibs/gibs_boot.mdl",
	"models/player/gibs/gibs_burger.mdl",
	"models/player/gibs/gibs_can.mdl",
	"models/player/gibs/gibs_clock.mdl",
	"models/player/gibs/gibs_duck.mdl",
	"models/player/gibs/gibs_fish.mdl",
	"models/player/gibs/gibs_gear1.mdl",
	"models/player/gibs/gibs_gear2.mdl",
	"models/player/gibs/gibs_gear3.mdl",
	"models/player/gibs/gibs_gear4.mdl",
	"models/player/gibs/gibs_gear5.mdl",
	"models/player/gibs/gibs_hubcap.mdl",
	"models/player/gibs/gibs_licenseplate.mdl",
	"models/player/gibs/gibs_spring1.mdl",
	"models/player/gibs/gibs_spring2.mdl",
	"models/player/gibs/gibs_teeth.mdl",
	"models/player/gibs/gibs_tire.mdl",
	"models/gibs/hgibs.mdl", -- 88
}

NPCModels = {
	"models/Humans/Group01/female_01.mdl",
	"models/Humans/Group01/female_02.mdl",
	"models/Humans/Group01/female_03.mdl",
	"models/Humans/Group01/female_04.mdl",
	"models/Humans/Group01/female_05.mdl",
	"models/Humans/Group01/female_06.mdl",
	"models/Humans/Group01/female_07.mdl",
	"models/Humans/Group01/male_01.mdl",
	"models/Humans/Group01/male_02.mdl",
	"models/Humans/Group01/male_03.mdl",
	"models/Humans/Group01/male_04.mdl",
	"models/Humans/Group01/male_05.mdl",
	"models/Humans/Group01/male_06.mdl",
	"models/Humans/Group01/male_07.mdl",
	"models/Humans/Group01/male_08.mdl",
	"models/Humans/Group01/male_09.mdl",
	
	"models/Humans/Group02/female_01.mdl",
	"models/Humans/Group02/female_02.mdl",
	"models/Humans/Group02/female_03.mdl",
	"models/Humans/Group02/female_04.mdl",
	"models/Humans/Group02/female_05.mdl",
	"models/Humans/Group02/female_06.mdl",
	"models/Humans/Group02/female_07.mdl",
	"models/Humans/Group02/male_01.mdl",
	"models/Humans/Group02/male_02.mdl",
	"models/Humans/Group02/male_03.mdl",
	"models/Humans/Group02/male_04.mdl",
	"models/Humans/Group02/male_05.mdl",
	"models/Humans/Group02/male_06.mdl",
	"models/Humans/Group02/male_07.mdl",
	"models/Humans/Group02/male_08.mdl",
	"models/Humans/Group02/male_09.mdl",
	
	"models/Humans/Group03/female_01.mdl",
	"models/Humans/Group03/female_02.mdl",
	"models/Humans/Group03/female_03.mdl",
	"models/Humans/Group03/female_04.mdl",
	"models/Humans/Group03/female_05.mdl",
	"models/Humans/Group03/female_06.mdl",
	"models/Humans/Group03/female_07.mdl",
	"models/Humans/Group03/male_01.mdl",
	"models/Humans/Group03/male_02.mdl",
	"models/Humans/Group03/male_03.mdl",
	"models/Humans/Group03/male_04.mdl",
	"models/Humans/Group03/male_05.mdl",
	"models/Humans/Group03/male_06.mdl",
	"models/Humans/Group03/male_07.mdl",
	"models/Humans/Group03/male_08.mdl",
	"models/Humans/Group03/male_09.mdl",
	
	"models/Humans/Group03m/female_01.mdl",
	"models/Humans/Group03m/female_02.mdl",
	"models/Humans/Group03m/female_03.mdl",
	"models/Humans/Group03m/female_04.mdl",
	"models/Humans/Group03m/female_05.mdl",
	"models/Humans/Group03m/female_06.mdl",
	"models/Humans/Group03m/female_07.mdl",
	"models/Humans/Group03m/male_01.mdl",
	"models/Humans/Group03m/male_02.mdl",
	"models/Humans/Group03m/male_03.mdl",
	"models/Humans/Group03m/male_04.mdl",
	"models/Humans/Group03m/male_05.mdl",
	"models/Humans/Group03m/male_06.mdl",
	"models/Humans/Group03m/male_07.mdl",
	"models/Humans/Group03m/male_08.mdl",
	"models/Humans/Group03m/male_09.mdl",
	
	"models/alyx.mdl",
	"models/barney.mdl",
	"models/breen.mdl",
	"models/eli.mdl",
	"models/gman.mdl",
	"models/gman_high.mdl",
	"models/kleiner.mdl",
	"models/monk.mdl",
	"models/mossman.mdl",
	"models/vortigaunt.mdl",
}

--[[
for _,v in pairs(NPCModels) do
	util.PrecacheModel(v)
end]]

PlayerModels = {
	"models/player/demo.mdl",
	"models/player/engineer.mdl",
	"models/player/heavy.mdl",
	"models/player/medic.mdl",
	"models/player/pyro.mdl",
	"models/player/scout.mdl",
	"models/player/sniper.mdl",
	"models/player/soldier.mdl",
	"models/player/spy.mdl",
}

AnimationModels = {
	"models/weapons/c_models/c_demo_animations.mdl",
	"models/weapons/c_models/c_heavy_animations.mdl",
	"models/weapons/c_models/c_medic_animations.mdl",
	"models/weapons/c_models/c_pyro_animations.mdl",
	"models/weapons/c_models/c_scout_animations.mdl",
	"models/weapons/c_models/c_sniper_animations.mdl",
	"models/weapons/c_models/c_soldier_animations.mdl",
	"models/weapons/c_models/c_spy_animations.mdl",
}

include("shd_precaches.lua")
include("shd_movement.lua")
include("shd_npcdata.lua")
include("shd_playerclasses.lua")
include("ply_extension.lua")
include("ent_extension.lua")
include("shd_playerstates.lua")

include("shd_maphooks.lua")

concommand.Add("+inspect", function(pl)
	pl:SetNWString("inspect", "inspecting_start")
end)

concommand.Add("-inspect", function(pl)
	pl:SetNWString("inspect", "inspecting_released")
	timer.Simple( 0.02, function() pl:SetNWString("inspect", "inspecting_done") end )
end)