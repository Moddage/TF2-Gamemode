-- Real class name: tf_weapon_handgun_scout_primary (see shd_items.lua)

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

	SWEP.PrintName			= "Scattergun"
SWEP.Slot				= 0

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/v_models/v_scattergun_scout.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_scattergun.mdl"
SWEP.Crosshair = "tf_crosshair1"

SWEP.MuzzleEffect = "muzzle_scattergun"
SWEP.MuzzleOffset = Vector(20, 4, -3)

SWEP.ShootSound = Sound("Weapon_Scatter_Gun.Single")
SWEP.ShootCritSound = Sound("Weapon_Scatter_Gun.SingleCrit")
SWEP.ReloadSound = Sound("Weapon_Scatter_Gun.WorldReload")

SWEP.TracerEffect = "bullet_scattergun_tracer01"

SWEP.BaseDamage = 12
SWEP.DamageRandomize = 0
SWEP.MaxDamageRampUp = 0.5
SWEP.MaxDamageFalloff = 0.5

SWEP.BulletsPerShot = 4
SWEP.BulletSpread = 0.035

SWEP.Primary.ClipSize		= 4
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_SECONDARY
SWEP.Primary.Delay          = 0.36

SWEP.AutoReloadTime = 0.21

--SWEP.ReloadSingle = true

SWEP.HoldType = "SECONDARY"
SWEP.IsRapidFire = true