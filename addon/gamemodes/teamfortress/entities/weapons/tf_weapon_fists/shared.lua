if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "Fists"
	SWEP.Slot				= 2
end

SWEP.Base				= "tf_weapon_melee_base"

SWEP.ViewModel			= "models/weapons/v_models/v_fist_heavy.mdl"
SWEP.WorldModel			= ""
SWEP.Crosshair = "tf_crosshair3"

SWEP.Swing = Sound("Weapon_Fist.Miss")
SWEP.SwingCrit = Sound("Weapon_Fist.MissCrit")
SWEP.HitFlesh = Sound("Weapon_Fist.HitFlesh")
SWEP.HitWorld = Sound("Weapon_Fist.HitWorld")

SWEP.CritEnabled = Sound("Weapon_BoxingGloves.CritEnabled")
SWEP.CritHit = Sound("Weapon_BoxingGloves.CritHit")

SWEP.DropPrimaryWeaponInstead = true

SWEP.BaseDamage = 65
SWEP.DamageRandomize = 0.1
SWEP.MaxDamageRampUp = 0
SWEP.MaxDamageFalloff = 0

SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay          = 0.8

SWEP.Secondary.Automatic		= true
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Delay          = 0.8

SWEP.CritForceAddPitch = 45

SWEP.HoldType = "MELEE"
SWEP.HasThirdpersonCritAnimation = true
SWEP.HasSecondaryFire = true
SWEP.UsesLeftRightAnim = true

function SWEP:OnCritBoostStarted()
	self.Owner:EmitSound(self.CritEnabled)
end

function SWEP:OnCritBoostAdded()
	self.Owner:EmitSound(self.CritHit)
end
