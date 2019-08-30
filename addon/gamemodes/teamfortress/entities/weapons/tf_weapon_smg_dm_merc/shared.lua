if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "Combat SMG"
	SWEP.Slot				= 3	
	SWEP.RenderGroup		= RENDERGROUP_BOTH 
end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/v_models/v_smg_dm.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_smg_dm.mdl"
SWEP.Crosshair = "tf_crosshair1"

SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Team Fortress 2"

SWEP.MuzzleEffect = "muzzle_smg"
SWEP.MuzzleOffset = Vector(20, 4, -2)

SWEP.ShootSound = Sound("weapons/smg_dm_shoot.wav")
SWEP.ShootCritSound = Sound("weapons/smg_dm_shoot_crit.wav")
SWEP.ReloadSound = Sound("Weapon_SMG.WorldReload")

SWEP.TracerEffect = "bullet_pistol_tracer01"
PrecacheParticleSystem("muzzle_smg")
PrecacheParticleSystem("bullet_pistol_tracer01_red")
PrecacheParticleSystem("bullet_pistol_tracer01_red_crit")
PrecacheParticleSystem("bullet_pistol_tracer01_blue")
PrecacheParticleSystem("bullet_pistol_tracer01_blue_crit")

SWEP.BaseDamage = 8
SWEP.DamageRandomize = 0
SWEP.MaxDamageRampUp = 0.5
SWEP.MaxDamageFalloff = 0.5

SWEP.BulletsPerShot = 1
SWEP.BulletSpread = 0.025

SWEP.Primary.ClipSize		= 35
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_SECONDARY
SWEP.Primary.Delay          = 0.1

SWEP.HoldType = "ITEM1"

SWEP.HoldTypeHL2 = "smg"

SWEP.ReloadTime = 2

SWEP.AutoReloadTime = 0.10

SWEP.IsRapidFire = true


function SWEP:Reload()
	self:StopTimers()
	if CLIENT and _G.NOCLIENTRELOAD then return end
	
	if self.NextReloadStart or self.NextReload or self.Reloading then return end
	
	if self.RequestedReload then
		if self.Delay and CurTime() < self.Delay then
			return false
		end
	else
		--MsgN("Requested reload!")
		self.RequestedReload = true
		return false
	end
	
	self.CanInspect = false
	
	--MsgN("Reload!")
	self.RequestedReload = false
	
	if self.Primary and self.Primary.Ammo and self.Primary.ClipSize ~= -1 then
		local available = self.Owner:GetAmmoCount(self.Primary.Ammo)
		local ammo = self:Clip1()
		
		if ammo < self.Primary.ClipSize and available > 0 then
			self.NextIdle = nil
			if self.ReloadSingle then
				--self:SendWeaponAnim(ACT_RELOAD_START)
				self.Owner:SetAnimation(PLAYER_RELOAD) -- reload start
				if self.ReloadTime == 1.1 then 
					self:SendWeaponAnimEx(self.VM_RELOAD_START)
					self.NextReloadStart = CurTime() + (self.ReloadStartTime or self:SequenceDuration() + 0.5)

					self.Owner:GetViewModel():SetPlaybackRate(0.6)
				else
					self:SendWeaponAnimEx(self.VM_RELOAD_START)
					self.NextReloadStart = CurTime() + (self.ReloadStartTime or self:SequenceDuration())
				end
			else
				self:SendWeaponAnimEx(self.VM_RELOAD)
				self.Owner:DoAnimationEvent(ACT_DOD_PRIMARYATTACK_PRONE_DEPLOYED)
				self.NextIdle = CurTime() + (self.ReloadTime or self:SequenceDuration())
				self.NextReload = self.NextIdle
				
				self.AmmoAdded = math.min(self.Primary.ClipSize - ammo, available)
				self.Reloading = true
				
				if self.ReloadSound and SERVER then
					umsg.Start("PlayTFWeaponWorldReload")
						umsg.Entity(self)
					umsg.End()
				end
				if self.ReloadTime == 0.71 then 
					self.Owner:GetViewModel():SetPlaybackRate(1.51)
				end
				--self.reload_cur_start = CurTime()
			end
			--self:SetNextPrimaryFire( CurTime() + ( self.Primary.Delay || 0.25 ) + 1.4 )
			--self:SetNextSecondaryFire( CurTime() + ( self.Primary.Delay || 0.25 ) + 1.4 )
			return true
		end
	end
end