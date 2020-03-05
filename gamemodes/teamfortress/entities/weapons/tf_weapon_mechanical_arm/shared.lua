if SERVER then
	AddCSLuaFile( "shared.lua" )
end

	SWEP.PrintName			= "Pistol"
SWEP.Slot				= 1

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/v_models/v_pistol_engineer.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_pistol.mdl"
SWEP.Crosshair = "tf_crosshair1"

SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.Category = "Team Fortress 2"

SWEP.MuzzleEffect = "muzzle_pistol"
SWEP.MuzzleOffset = Vector(20, 4, -2)

SWEP.ShootSound = Sound("weapons/pistol_shoot.wav")
SWEP.ShootCritSound = Sound("Weapon_Pistol.SingleCrit")
SWEP.ReloadSound = Sound("Weapon_Pistol.WorldReloadEngineer")

SWEP.TracerEffect = "bullet_pistol_tracer01"
PrecacheParticleSystem("bullet_pistol_tracer01_red")
PrecacheParticleSystem("bullet_pistol_tracer01_red_crit")
PrecacheParticleSystem("bullet_pistol_tracer01_blue")
PrecacheParticleSystem("bullet_pistol_tracer01_blue_crit")
PrecacheParticleSystem("muzzle_pistol")

SWEP.BaseDamage = 0
SWEP.DamageRandomize = 0
SWEP.MaxDamageRampUp = 0.5
SWEP.MaxDamageFalloff = 0.5

SWEP.BulletsPerShot = 1
SWEP.BulletSpread = 0.04

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			= TF_METAL
SWEP.Primary.Delay          = 0.225

SWEP.HoldType = "SECONDARY"

SWEP.IsRapidFire = true

function SWEP:InspectAnimCheck()
self:CallBaseFunction("InspectAnimCheck")
self.VM_DRAW = ACT_SECONDARY_VM_DRAW
self.VM_IDLE = ACT_SECONDARY_VM_IDLE

self.VM_INSPECT_START = ACT_SECONDARY_ALT2_VM_INSPECT_START
self.VM_INSPECT_IDLE = ACT_SECONDARY_ALT2_VM_INSPECT_IDLE
self.VM_INSPECT_END = ACT_SECONDARY_ALT2_VM_INSPECT_END
end

function SWEP:PreDrawViewModel(vm, wpn, ply)
	vm:SetBodygroup(1, 1)
end

function SWEP:Deploy()
	self.BaseClass.Deploy(self)
	if IsValid(self.Owner) then
		self.Owner:SetBodygroup(2, 2)
	end
end

function SWEP:Holster()
	if IsValid(self.Owner) then
		self.Owner:SetBodygroup(2, 0)
		if self.Owner:HasWeapon("tf_weapon_robot_arm") then
			self.Owner:SetBodygroup(2, 1)
		end
	end
	return self.BaseClass.Holster(self)
end

function SWEP:OnRemove()
	self:Holster()
	return self.BaseClass.OnRemove(self)
end

function SWEP:CanPrimaryAttack()
	if (self.Primary.ClipSize == -1 and self:Ammo1() > 0) or self:Clip1() > 0 then
		return true
	end
	self:EmitSound("string soundName")
	return false
end

function SWEP:PrimaryAttack()
	self:StopTimers()

	if not self:CallBaseFunction("PrimaryAttack") then return false end
	
	auto_reload = self.Owner:GetInfoNum("tf_righthand", 1)
	
	self:SendWeaponAnim(self.VM_PRIMARYATTACK)
	self.Owner:DoAttackEvent()
	
	self.NextIdle = CurTime() + self:SequenceDuration()
	if self then
		if self.Owner:GetInfoNum("tf_autoreload", 1) == 1 then
			if auto_reload then
				timer.Create("AutoReload", (self:SequenceDuration() + self.AutoReloadTime), 1, function() if IsValid(self) and IsValid(self.Owner) and isfunction(self:Reload()) then self:Reload() end end)
			end
		end
	end
	self:ShootProjectile(self.BulletsPerShot, self.BulletSpread)
	self:TakePrimaryAmmo(5)
	
	if self:Clip1() <= 0 then
		self:Reload()
	end
	
	self:RollCritical() -- Roll and check for criticals first
	
	self.Owner:ViewPunch( self.PunchView )
	
	self.NextReloadStart = nil
	self.NextReload = nil
	self.Reloading = false
	
	return true
end