if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "Shotgun"
SWEP.Slot				= 1
end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/v_models/v_shotgun_heavy.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_shotgun.mdl"
SWEP.Crosshair = "tf_crosshair1"

SWEP.MuzzleEffect = "muzzle_shotgun"
SWEP.MuzzleOffset = Vector(20, 4, -3)

SWEP.ShootSound = Sound("weapons/shotgun_shoot.wav")
SWEP.ShootCritSound = Sound("Weapon_Shotgun.SingleCrit")
SWEP.ReloadSound = Sound("Weapon_Shotgun.WorldReload")

SWEP.TracerEffect = "bullet_shotgun_tracer01"
PrecacheParticleSystem("bullet_shotgun_tracer01_red")
PrecacheParticleSystem("bullet_shotgun_tracer01_red_crit")
PrecacheParticleSystem("bullet_shotgun_tracer01_blue")
PrecacheParticleSystem("bullet_shotgun_tracer01_blue_crit")
PrecacheParticleSystem("muzzle_shotgun")

SWEP.BaseDamage = 15
SWEP.DamageRandomize = 0.5 * 2
SWEP.MaxDamageRampUp = 0.5

SWEP.BulletsPerShot = 10
SWEP.BulletSpread = 0.0675

SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_SECONDARY
SWEP.Primary.Delay          = 0.625
SWEP.ReloadTime = 0.5

SWEP.PunchView = Angle( -2, 0, 0 )

SWEP.ReloadSingle = true

SWEP.HoldType = "SECONDARY"

function SWEP:CanPrimaryAttack()
	if (self.Primary.ClipSize == -1 and self:Ammo1() > 0) or self:Clip1() > 0 then
		return true
	end
	self:EmitSound("weapons/shotgun_empty.wav", 80, 100)
	self:SetNextPrimaryFire(CurTime() + 0.5)
	return false
end