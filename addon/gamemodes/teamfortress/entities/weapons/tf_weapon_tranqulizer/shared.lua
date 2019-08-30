if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then

SWEP.PrintName			= "Revolver"
SWEP.Slot				= 0
SWEP.RenderGroup		= RENDERGROUP_BOTH

end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/c_models/c_spy_arms.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_tranq.mdl"
SWEP.Crosshair = "tf_crosshair2"

SWEP.MuzzleEffect = "muzzle_revolver"
SWEP.MuzzleOffset = Vector(20, 4, -2)

SWEP.ShootSound = Sound("weapons/doom_sniper_smg.wav")
SWEP.ShootCritSound = Sound("weapons/doom_sniper_smg.wav")
SWEP.ReloadSound = Sound("Weapon_SMG1.Reload")

SWEP.TracerEffect = "bullet_pistol_tracer01"
PrecacheParticleSystem("bullet_pistol_tracer01_red")
PrecacheParticleSystem("bullet_pistol_tracer01_blue")
PrecacheParticleSystem("bullet_pistol_tracer01_red_crit")
PrecacheParticleSystem("bullet_pistol_tracer01_blue_crit")
PrecacheParticleSystem("muzzle_revolver")

SWEP.BaseDamage = 9
SWEP.DamageRandomize = 0
SWEP.MaxDamageRampUp = 0.5
SWEP.MaxDamageFalloff = 0.52
SWEP.BulletsPerShot = 1
SWEP.BulletSpread = 0.025

SWEP.Primary.ClipSize		= 3
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_PRIMARY
SWEP.Primary.Delay          = 0.3
SWEP.ReloadTime = 2.2

SWEP.HoldType = "SECONDARY"
SWEP.HoldTypeHL2 = "revolver"

SWEP.DeploySound = Sound("weapons/draw_secondary.wav")

SWEP.AutoReloadTime = 0.10

SWEP.IsRapidFire = false

-- Ambassador properties
SWEP.AccuracyRecoveryStartDelay = 0.5
SWEP.AccuracyRecoveryDelay = 0.75

SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Team Fortress 2"

SWEP.MinSpread = 0
SWEP.MaxSpread = 0.06
SWEP.CrosshairMaxScale = 3

function SWEP:InspectAnimCheck()
self:CallBaseFunction("InspectAnimCheck")
self.VM_DRAW = ACT_PRIMARY_VM_DRAW
self.VM_IDLE = ACT_PRIMARY_VM_IDLE
self.VM_PRIMARYATTACK = ACT_PRIMARY_VM_PRIMARYATTACK
self.VM_SECONDARYATTACK = ACT_PRIMARY_VM_SECONDARYATTACK
self.VM_RELOAD = ACT_PRIMARY_VM_RELOAD
self.VM_RELOAD_START = ACT_RELOAD_START
self.VM_RELOAD_FINISH = ACT_RELOAD_FINISH
end
function SWEP:Deploy()
	self:CallBaseFunction("Deploy")
	if self.Owner:GetPlayerClass() == "merc_dm" then
		self:SetHoldType("MELEE_ALLCLASS")
		self.Primary.Ammo		= TF_SECONDARY
	end
end
function SWEP:Reload()
	self:CallBaseFunction("Reload")
	if self.Owner:GetPlayerClass() == "merc_dm" then
		self.Owner:SetAnimation(PLAYER_RELOAD1)
	end
end

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
