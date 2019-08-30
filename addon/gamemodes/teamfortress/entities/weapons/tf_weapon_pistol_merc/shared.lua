if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "Mercenary Pistol"
	SWEP.Slot				= 1
	SWEP.RenderGroup		= RENDERGROUP_BOTH
end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/v_models/v_pistol_mercenary.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_pistol_mercenary.mdl"
SWEP.Crosshair = "tf_crosshair1"

SWEP.MuzzleEffect = "muzzle_pistol"
SWEP.MuzzleOffset = Vector(20, 4, -2)

SWEP.ShootSound = Sound("weapons/pistol_dm_shoot.wav")
SWEP.ShootCritSound = Sound("weapons/pistol_dm_shoot_crit.wav")
SWEP.ReloadSound = Sound("weapons/pistol_worldreload_merc.wav")

SWEP.TracerEffect = "bullet_pistol_tracer01"
PrecacheParticleSystem("bullet_pistol_tracer01_red")
PrecacheParticleSystem("bullet_pistol_tracer01_red_crit")
PrecacheParticleSystem("bullet_pistol_tracer01_blue")
PrecacheParticleSystem("bullet_pistol_tracer01_blue_crit")
PrecacheParticleSystem("muzzle_pistol")

SWEP.BaseDamage = 15
SWEP.DamageRandomize = 0
SWEP.MaxDamageRampUp = 0.5
SWEP.MaxDamageFalloff = 0.5

SWEP.BulletsPerShot = 1
SWEP.BulletSpread = 0.04

SWEP.Primary.ClipSize		= 15
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_SECONDARY
SWEP.Primary.Delay          = 0.15

SWEP.HoldType = "SECONDARY2"

SWEP.HoldTypeHL2 = "pistol"

SWEP.IsRapidFire = true

function SWEP:InspectAnimCheck()

end