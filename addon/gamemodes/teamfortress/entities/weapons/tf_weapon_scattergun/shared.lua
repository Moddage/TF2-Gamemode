if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "Scattergun"
SWEP.Slot				= 0
end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/v_models/v_scattergun_scout.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_scattergun.mdl"
SWEP.Crosshair = "tf_crosshair1"

SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Team Fortress 2"

SWEP.MuzzleEffect = "muzzle_scattergun"
SWEP.MuzzleOffset = Vector(20, 4, -3)

SWEP.ShootSound = Sound("Weapon_Scatter_Gun.Single")
SWEP.ShootCritSound = Sound("Weapon_Scatter_Gun.SingleCrit")
SWEP.ReloadSound = Sound("Weapon_Scatter_Gun.WorldReload")
SWEP.DeploySound = Sound("weapons/draw_secondary.wav")

SWEP.TracerEffect = "bullet_scattergun_tracer01"
PrecacheParticleSystem("bullet_scattergun_tracer01_red")
PrecacheParticleSystem("bullet_scattergun_tracer01_red_crit")
PrecacheParticleSystem("bullet_scattergun_tracer01_blue")
PrecacheParticleSystem("bullet_scattergun_tracer01_blue_crit")
PrecacheParticleSystem("muzzle_scattergun")


SWEP.BaseDamage = 15
SWEP.DamageRandomize = 0.5 * 2
SWEP.MaxDamageRampUp = 0.5

SWEP.BulletsPerShot = 10
SWEP.BulletSpread = 0.0675

SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_PRIMARY
SWEP.Primary.Delay          = 0.6
SWEP.ReloadTime = 0.5

SWEP.ReloadSingle = true

SWEP.HoldType = "PRIMARY"

SWEP.HoldTypeHL2 = "shotgun"

SWEP.KnockbackForceOwner = 225

SWEP.KnockbackMaxForce = 600
SWEP.MinKnockbackDistance = 512
SWEP.KnockbackAddPitch = -30

SWEP.PunchView = Angle( -2, 0, 0 )

function SWEP:OnEquipAttribute(a, owner)
	if a.attribute_class == "set_scattergun_no_reload_single" then
		self.ReloadSingle = false
		self.ReloadDiscardClip = true
	elseif a.attribute_class == "set_scattergun_has_knockback" then
		self.ScattergunHasKnockback = true
		self.ReloadTime = 1.6
		self.ReloadSound = Sound("")
	end
end


function SWEP:CanPrimaryAttack()
	if (self.Primary.ClipSize == -1 and self:Ammo1() > 0) or self:Clip1() > 0 then
		return true
	end
	self:EmitSound("weapons/shotgun_empty.wav", 80, 100)
	self:SetNextPrimaryFire(CurTime() + 0.5)
	return false
end

function SWEP:SetupCModelActivities(item)
	if item then
		for _,a in pairs(item.attributes or {}) do
			if a.attribute_class == "set_scattergun_no_reload_single" and a.value == 1 then
				item = table.Copy(item)
				item.anim_slot = "ITEM2"
				self.HoldType = "ITEM2"
				self:SetWeaponHoldType("ITEM2")
				break
			end
		end
	end
	
	if self:GetItemData().model_player == "models/weapons/c_models/c_xms_double_barrel.mdl" then
		self.HoldType = "ITEM2"
		self:SetWeaponHoldType("ITEM2")		
		self.ScattergunHasKnockback = true
		self.ReloadTime = 1.6
		self.ReloadSound = Sound("")
		self.ReloadSingle = false
		self.ReloadDiscardClip = true
		self.Primary.ClipSize		= 2
		self.Primary.DefaultClip	= 2
		self.Primary.Delay = 0.3
		self:SetClip1(2)
		self.ShootSound = Sound("weapons/scatter_gun_double_shoot.wav")
	end	

	
	if self:GetItemData().model_player == "models/weapons/c_models/c_double_barrel.mdl" then
		self.HoldType = "ITEM2"
		self:SetWeaponHoldType("ITEM2")		
		self.ScattergunHasKnockback = true
		self.ReloadTime = 1.6
		self.Primary.Delay = 0.3
		self.ReloadSingle = false
		self.ReloadDiscardClip = true
		self.Primary.ClipSize		= 2
		self.Primary.DefaultClip	= 2
		self.ReloadSound = "Weapon_SMG1.Reload"
		self:SetClip1(2)
		self.ShootSound = Sound("weapons/scatter_gun_double_shoot.wav")
		self.ShootCritSound = Sound("weapons/scatter_gun_double_shoot_crit.wav")
	end
	
	if self:GetItemData().model_player == "models/workshop/weapons/c_models/c_soda_popper/c_soda_popper.mdl" then
		self.HoldType = "ITEM2"
		self:SetWeaponHoldType("ITEM2")		
		self.ScattergunHasKnockback = true
		self.ReloadTime = 1.15
		self.Primary.Delay = 0.3
		self.ReloadSingle = false
		self.ReloadDiscardClip = true
		self.Primary.ClipSize		= 2
		self.Primary.DefaultClip	= 2
		self.ReloadSound = "Weapon_SMG1.Reload"
		self:SetClip1(2)
		self.ShootSound = Sound("weapons/scatter_gun_double_bonk_shoot.wav")
		self.ShootCritSound = Sound("weapons/scatter_gun_double_bonk_shoot_crit.wav")
	end	
	
	return self:CallBaseFunction("SetupCModelActivities", item)
end

if SERVER then

function SWEP:DoOwnerKnockback()
	if self.Owner:OnGround() then return end
	if self.Owner.KnockbackJumpsRemaining and self.Owner.KnockbackJumpsRemaining <= 0 then return end
	
	local vel = self.Owner:GetVelocity()
	local dir = self.Owner:GetAimVector()
	local work = vel:Dot(dir)
	--if work < 0 then work = 0 end
	
	local force = self.KnockbackForceOwner + work
	if force < 0 then force = 0 end
	
	self.Owner:SetVelocity(-force * dir)
	
	self.Owner.KnockbackJumpsRemaining = (self.Owner.KnockbackJumpsRemaining or 1) - 1
	self.Owner:SetThrownByExplosion(true)
end

hook.Add("OnPlayerHitGround", "TFKnockbackJumpsReset", function(pl)
	pl.KnockbackJumpsRemaining = 1
end)

hook.Add("PostScaleDamage", "TFKnockbackDamage", function(ent, hitgroup, dmginfo)
	local inf = dmginfo:GetInflictor()
	local att = dmginfo:GetAttacker()
	
	if inf.ScattergunHasKnockback and not ent:IsThrownByExplosion() then
		local dist = inf:GetPos():Distance(ent:GetPos())
		if dist < inf.MinKnockbackDistance then
			if not inf.MaxKnockbackDamage then
				inf.MaxKnockbackDamage = inf.BaseDamage * (1 + inf.MaxDamageRampUp + inf.DamageRandomize) * inf.BulletsPerShot
			end
			
			local force = inf.KnockbackMaxForce * dmginfo:GetDamage() / inf.MaxKnockbackDamage
			local ang = att:EyeAngles()
			ang.p = ang.p + inf.KnockbackAddPitch
			
			ent:SetGroundEntity(NULL)
			ent:SetVelocity(ang:Forward() * force)
			ent:SetThrownByExplosion(true)
		end
	end
end)

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
				self:SendWeaponAnimEx(self.VM_RELOAD_START)
				self.Owner:SetAnimation(PLAYER_RELOAD) -- reload start
				self.NextReloadStart = CurTime() + (self.ReloadStartTime or self:SequenceDuration())
			else
				self:SendWeaponAnimEx(self.VM_RELOAD)
				self.Owner:SetAnimation(PLAYER_RELOAD)
				if self.ReloadTime == 1.15 then
					self.Owner:GetViewModel():SetPlaybackRate(1.4)
				end
				self.NextIdle = CurTime() + (self.ReloadTime or self:SequenceDuration())
				self.NextReload = self.NextIdle
				
				self.AmmoAdded = math.min(self.Primary.ClipSize - ammo, available)
				self.Reloading = true
				
				if self.ReloadSound and SERVER then
					umsg.Start("PlayTFWeaponWorldReload")
						umsg.Entity(self)
					umsg.End()
				end
				
				--self.reload_cur_start = CurTime()
			end
			--self:SetNextPrimaryFire( CurTime() + ( self.Primary.Delay || 0.25 ) + 1.4 )
			--self:SetNextSecondaryFire( CurTime() + ( self.Primary.Delay || 0.25 ) + 1.4 )
			return true
		end
	end
end


function SWEP:Think()
	self:TFViewModelFOV()
	self:TFFlipViewmodel()
	//deployspeed = math.Round(GetConVar("tf_weapon_deploy_speed"):GetFloat() - GetConVar("tf_weapon_deploy_speed"):GetInt(), 2)
	//deployspeed = math.Round(GetConVar("tf_weapon_deploy_speed"):GetFloat(),2)
	
	if SERVER and self.NextReplayDeployAnim then
		if CurTime() > self.NextReplayDeployAnim then
			--MsgFN("Replaying deploy animation %d", self.VM_DRAW)
			timer.Simple(0.1, function() self:SendWeaponAnim(self.VM_DRAW) end)
			self.NextReplayDeployAnim = nil
		end
	end
	
	if not game.SinglePlayer() or SERVER then
		if self.NextIdle and CurTime()>=self.NextIdle then
			self:SendWeaponAnim(self.VM_IDLE)
			self.NextIdle = nil
		end
		
		if self.RequestedReload then
			self:Reload()
		end
	end
	


	if not self.IsDeployed and self.NextDeployed and CurTime()>=self.NextDeployed then
		self.IsDeployed = true
		self.CanInspect = true
		self:CheckAutoReload()
	end
	
	if self.IsDeployed then
		self.CanInspect = true
	end
			
	//print(deployspeed)
	
	if self.NextReload and CurTime()>=self.NextReload then
		self:SetClip1(self:Clip1() + self.AmmoAdded)
		
		if not self.ReloadSingle and self.ReloadDiscardClip then
			self.Owner:RemoveAmmo(self.Primary.ClipSize, self.Primary.Ammo, false)
		else
			self.Owner:RemoveAmmo(self.AmmoAdded, self.Primary.Ammo, false)
		end
		
		self.Delay = -1
		self.QuickDelay = -1
		
		if self:Clip1()>=self.Primary.ClipSize or self.Owner:GetAmmoCount(self.Primary.Ammo)==0 then
			-- Stop reloading
			self.Reloading = false
			self.CanInspect = true
			if self.ReloadSingle then
				--self:SendWeaponAnim(ACT_RELOAD_FINISH)
				self:SendWeaponAnim(self.VM_RELOAD_FINISH)
				self.CanInspect = true
				--self.Owner:SetAnimation(10001) -- reload finish
				self.Owner:DoAnimationEvent(ACT_SMG2_DRAW2, true)
				self.NextIdle = CurTime() + self:SequenceDuration()
			else
				self:SendWeaponAnim(self.VM_IDLE)
				self.NextIdle = nil
			end
			self.NextReload = nil
		else
			self:SendWeaponAnim(self.VM_RELOAD)
			--self.Owner:SetAnimation(10000)	
			if SERVER then	
			self.Owner:DoAnimationEvent(ACT_MP_RELOAD_STAND_LOOP, true)
			end
			local fx = EffectData()
			fx:SetOrigin(self.Owner:GetPos() + Vector(0, 0, 50))
			util.Effect("ShotgunShellEject", fx)
			if self.ReloadTime == 0.2 then
				self.Owner:GetViewModel():SetPlaybackRate(2)
			end
			self.NextReload = CurTime() + (self.ReloadTime)
				
			if self.ReloadSound and SERVER then
				umsg.Start("PlayTFWeaponWorldReload")
					umsg.Entity(self)
				umsg.End()
			end
			
		end
	end
	
	if self.NextReloadStart and CurTime()>=self.NextReloadStart then
		self:SendWeaponAnim(self.VM_RELOAD)
		--self.Owner:SetAnimation(10000) -- reload loop
		if SERVER then	
			self.Owner:DoAnimationEvent(ACT_MP_RELOAD_STAND_LOOP, true)
		end		
		local fx = EffectData()
		fx:SetOrigin(self.Owner:GetPos() + Vector(0, 0, 50))
		util.Effect("ShotgunShellEject", fx)
		if self.ReloadTime == 0.2 then
			self.Owner:GetViewModel():SetPlaybackRate(2)
		end
		self.NextReload = CurTime() + (self.ReloadTime)
		
		self.AmmoAdded = 1
		
		if self.ReloadSound and SERVER then
			umsg.Start("PlayTFWeaponWorldReload")
				umsg.Entity(self)
			umsg.End()
		end
		
		self.NextReloadStart = nil
	end
	
	self:Inspect()
end

function SWEP:PrimaryAttack()
	if not self:CallBaseFunction("PrimaryAttack") then return end
	
	if SERVER and self.ScattergunHasKnockback then
		self:DoOwnerKnockback()
	end
	
	return
end
