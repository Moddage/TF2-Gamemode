if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "Mercenary Scattergun"
SWEP.Slot				= 4
SWEP.RenderGroup		= RENDERGROUP_BOTH
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


SWEP.BaseDamage = 3 * 4
SWEP.DamageRandomize = 0.5 * 3
SWEP.MaxDamageRampUp = 0.5 * 3
SWEP.MaxDamageFalloff = 0.3

SWEP.BulletsPerShot = 10
SWEP.BulletSpread = 0.0675

SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_PRIMARY
SWEP.Primary.Delay          = 0.6
SWEP.ReloadTime = 0.625

SWEP.ReloadSingle = true

SWEP.HoldType = "SECONDARY"

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
	end
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
				if CLIENT then
					self.Owner:DoAnimationEvent(ACT_MP_RELOAD_STAND_END, true)
				end
				self.NextIdle = CurTime() + self:SequenceDuration()
			else
				self:SendWeaponAnim(self.VM_IDLE)
				self.NextIdle = nil
			end
			self.NextReload = nil
		else
			self:SendWeaponAnim(self.VM_RELOAD)
			--self.Owner:SetAnimation(10000)		
			self.Owner:DoAnimationEvent(ACT_MP_RELOAD_STAND_LOOP, true)
			self.NextReload = CurTime() + (self.ReloadTime or self:SequenceDuration())
				

			local fx = EffectData()
			fx:SetOrigin(self:GetPos())
			util.Effect("ShotgunShellEject", fx)
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
		self.Owner:DoAnimationEvent(ACT_MP_RELOAD_STAND_LOOP, true)
		local fx = EffectData()
		fx:SetOrigin(self:GetPos())
		util.Effect("ShotgunShellEject", fx)
		self.NextReload = CurTime() + (self.ReloadTime or self:SequenceDuration())
		
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
