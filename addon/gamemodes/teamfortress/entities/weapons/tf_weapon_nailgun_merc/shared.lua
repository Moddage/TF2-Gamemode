if SERVER then
	AddCSLuaFile( "shared.lua" )
	
end

if CLIENT then

SWEP.PrintName			= "Mercenary Nailgun"
SWEP.Slot				= 2
SWEP.RenderGroup		= RENDERGROUP_BOTH

end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/advancedweaponiser/nailgun/v_nailgun.mdl"
SWEP.WorldModel			= "models/advancedweaponiser/nailgun/c_nailgun.mdl"
SWEP.Crosshair = 		"tf_crosshair1"

SWEP.MuzzleEffect = "muzzle_pistol"

SWEP.ShootSound = Sound("weapons/nail_gun_shoot.wav")
SWEP.ShootCritSound = Sound("weapons/nail_gun_shoot_crit.wav")
SWEP.ReloadSound = Sound("weapons/syringegun_worldreload.wav")

SWEP.Primary.ClipSize		= 40
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_SECONDARY
SWEP.Primary.Delay          = 0.1

SWEP.BulletSpread = 0.01

SWEP.IsRapidFire = true
SWEP.ReloadSingle = false

SWEP.HoldType = "ITEM1"

SWEP.ProjectileShootOffset = Vector(0, 8, -5)

function SWEP:ShootProjectile()
	if SERVER then
		local syringe = ents.Create("tf_projectile_nail")
		local ang = self.Owner:EyeAngles()
		local vec = ang:Forward() + math.Rand(-self.BulletSpread,self.BulletSpread) * ang:Right() + math.Rand(-self.BulletSpread,self.BulletSpread) * ang:Up()
		
		syringe:SetPos(self:ProjectileShootPos())
		syringe:SetAngles(vec:Angle())
		if self:Critical() then
			syringe.critical = true
		end
		syringe:SetOwner(self.Owner)
		--syringe:SetProjectileType(1)
		
		self:InitProjectileAttributes(syringe)
		
		syringe:Spawn()
	end
	
	self:ShootEffects()
end

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