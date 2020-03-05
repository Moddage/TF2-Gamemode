if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName			= "Revolver"
SWEP.Slot				= 0

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/v_models/v_revolver_spy.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_revolver.mdl"
SWEP.Crosshair = "tf_crosshair2"

SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Team Fortress 2"

SWEP.MuzzleEffect = "muzzle_revolver"
SWEP.MuzzleOffset = Vector(20, 4, -2)

SWEP.ShootSound = Sound("Weapon_Revolver.Single")
SWEP.ShootCritSound = Sound("Weapon_Revolver.SingleCrit")
SWEP.ReloadSound = Sound("Weapon_Revolver.WorldReload")

SWEP.TracerEffect = "bullet_pistol_tracer01"
PrecacheParticleSystem("bullet_pistol_tracer01_red")
PrecacheParticleSystem("bullet_pistol_tracer01_blue")
PrecacheParticleSystem("bullet_pistol_tracer01_red_crit")
PrecacheParticleSystem("bullet_pistol_tracer01_blue_crit")
PrecacheParticleSystem("muzzle_revolver")

SWEP.BaseDamage = 40
SWEP.DamageRandomize = 0
SWEP.MaxDamageRampUp = 0.5
SWEP.MaxDamageFalloff = 0.52

SWEP.BulletsPerShot = 1
SWEP.BulletSpread = 0.025

SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_PRIMARY
SWEP.Primary.Delay          = 0.58

SWEP.HoldType = "SECONDARY"

SWEP.AutoReloadTime = 0.10

SWEP.IsRapidFire = false

-- Ambassador properties
SWEP.AccuracyRecoveryStartDelay = 0.5
SWEP.AccuracyRecoveryDelay = 0.75

SWEP.MinSpread = 0
SWEP.MaxSpread = 0.06
SWEP.CrosshairMaxScale = 3

if CLIENT then

	usermessage.Hook("AmbassadorFired", function(msg)
		local self = msg:ReadEntity()
		
		self.CrosshairScale = self.CrosshairMaxScale
		self.NextStartRecovery = CurTime() + self.AccuracyRecoveryStartDelay
		self.NextEndRecovery = nil
	end)

end

function SWEP:OnEquipAttribute(a, owner)
	if a.attribute_class == "set_weapon_mode" then
		if a.value == 1 then
			self.CriticalChance = 0
			self.CritsOnHeadshot = true
			self.BulletSpread = 0
			self.HeadshotName = "tf_weapon_ambassador_headshot"
			self.PredictCritServerside = true
			self.AutoReloadTime = 0.21
		end
	end
end

function SWEP:PrimaryAttack()
	if not self:CallBaseFunction("PrimaryAttack") then return false end
	
	if self.WeaponMode == 1 then
		self.CritsOnHeadshot = false
		self.NameOverride = nil
		
		self.BulletSpread = self.MaxSpread
		
		self.NextStartRecovery = CurTime() + self.AccuracyRecoveryStartDelay
		self.NextEndRecovery = nil
		
		if SERVER then
			umsg.Start("AmbassadorFired", self.Owner)
				umsg.Entity(self)
			umsg.End()
		end
	end
	
	return true
end

function SWEP:Think()
	self:CallBaseFunction("Think")
	
	if self.WeaponMode == 1 then
		if self.NextStartRecovery and CurTime()>self.NextStartRecovery then
			self.NextStartRecovery = nil
			self.NextEndRecovery = CurTime() + self.AccuracyRecoveryDelay
		end
		
		if self.NextEndRecovery then
			local diff = self.NextEndRecovery - CurTime()
			local r = math.Clamp(diff/self.AccuracyRecoveryDelay, 0, 1)
			self.CrosshairScale = Lerp(r, 1, self.CrosshairMaxScale)
			self.BulletSpread = Lerp(r, self.MinSpread, self.MaxSpread)
			
			if diff<=0 then
				self.CritsOnHeadshot = true
				self.NextEndRecovery = nil
			end
		end
	end
end
