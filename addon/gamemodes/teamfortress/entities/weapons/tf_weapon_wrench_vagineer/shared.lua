if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "Wrench"
SWEP.Slot				= 2
SWEP.GlobalCustomHUD = {HudAccountPanel = true}
SWEP.RenderGroup 		= RENDERGROUP_BOTH
end

SWEP.Base				= "tf_weapon_melee_base"

SWEP.ViewModel			= "models/weapons/v_models/v_wrench_engineer.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_wrench.mdl"
SWEP.Crosshair = "tf_crosshair3"

SWEP.Swing = Sound("Weapon_Wrench.Miss")
SWEP.SwingCrit = Sound("Weapon_Wrench.MissCrit")
SWEP.HitFlesh = Sound("Weapon_Wrench.HitFlesh")
SWEP.HitWorld = Sound("Weapon_Wrench.HitWorld")

SWEP.BaseDamage = 10000
SWEP.DamageRandomize = 0.1
SWEP.MaxDamageRampUp = 0
SWEP.MaxDamageFalloff = 0

SWEP.Primary.Delay = 0.8
SWEP.ReloadTime = 0.8

SWEP.HoldType = "MELEE"