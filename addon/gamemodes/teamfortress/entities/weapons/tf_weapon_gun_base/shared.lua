if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "Gun"
end

SWEP.Base				= "tf_weapon_base"

SWEP.ViewModel			= "models/weapons/v_models/v_scattergun_scout.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_scattergun.mdl"

SWEP.MuzzleEffect = "muzzle_flash"
SWEP.MuzzleOffset = Vector(0,0,0)

SWEP.ShootSound = Sound("")
SWEP.ShootCritSound = Sound("")
SWEP.ReloadSound = Sound("")

SWEP.TracerEffect = "bullet_tracer01"
PrecacheParticleSystem("muzzle_flash")

SWEP.BulletsPerShot = 1
SWEP.BulletSpread = 0.2

SWEP.PunchView = Angle( 0, 0, 0 )

SWEP.HoldType = "PRIMARY"

SWEP.AutoReloadTime = 0.01

idle_timer = 1
end_timer = 1
post_timer = 5.30

inspecting = false
inspecting_post = false

CreateClientConVar("tf_autoreload", "1", true, true)

function SWEP:ShootPos()
	--local vm = self.Owner:GetViewModel()
	--return vm:GetAttachment(vm:LookupAttachment("muzzle"))
	
	return self:GetAttachment(self:LookupAttachment("muzzle")).Pos
end

function SWEP:PrimaryAttack()
	self:StopTimers()

	if not self:CallBaseFunction("PrimaryAttack") then return false end
	
	if self.Owner:GetMaterial() == "models/shadertest/predator" then return end
	
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
	self:TakePrimaryAmmo(1)
	
	if self:Clip1() <= 0 then
		self:Reload()
	end
	
	if self.Owner:GetPlayerClass() == "spy" then
		if self.Owner:GetModel() == "models/player/scout.mdl" or  self.Owner:GetModel() == "models/player/soldier.mdl" or  self.Owner:GetModel() == "models/player/pyro.mdl" or  self.Owner:GetModel() == "models/player/demo.mdl" or  self.Owner:GetModel() == "models/player/heavy.mdl" or  self.Owner:GetModel() == "models/player/engineer.mdl" or  self.Owner:GetModel() == "models/player/medic.mdl" or  self.Owner:GetModel() == "models/player/sniper.mdl" or  self.Owner:GetModel() == "models/player/hwm/spy.mdl"	 or self.Owner:GetModel() == "models/player/kleiner.mdl" then
			if self.Owner:KeyDown( IN_ATTACK ) then
				if self.Owner:GetInfoNum("tf_robot", 0) == 0 then
					self.Owner:SetModel("models/player/spy.mdl") 
				else
					self.Owner:SetModel("models/bots/spy/bot_spy.mdl")
				end
				if IsValid( button) then 
					button:Remove() 
				end
				for _,v in pairs(ents.GetAll()) do
					if v:IsNPC() and not v:IsFriendly(self.Owner) then
						v:AddEntityRelationship(self.Owner, D_HT, 99)
					end
				end
				if self.Owner:Team() == TEAM_BLU then 
					self.Owner:SetSkin(1) 
				else 
					self.Owner:SetSkin(0) 
				end 
				self.Owner:EmitSound("player/spy_disguise.wav", 65, 100) 
			end
		end
	end
	
	self:RollCritical() -- Roll and check for criticals first
	
	self.Owner:ViewPunch( self.PunchView )
	
	self.NextReloadStart = nil
	self.NextReload = nil
	self.Reloading = false
	
	return true
end

--local force_bullets_lagcomp = CreateConVar("force_bullets_lagcomp", 0, {FCVAR_REPLICATED})

function SWEP:ShootProjectile(num_bullets, aimcone)
	self:StopTimers()
	
	if self.Owner:GetMaterial() == "models/shadertest/predator" then return end
	
	--local b = force_bullets_lagcomp:GetBool()
	
	--if b then
		self.Owner:LagCompensation(true)
	--end
	
	self:FireTFBullets{
		Num = num_bullets,
		Src = self.Owner:GetShootPos(),
		--Src = self:ShootPos(),
		Dir = self.Owner:GetAimVector(),
		Spread = Vector(aimcone, aimcone, 0),
		Attacker = self.Owner,
		
		Team = GAMEMODE:EntityTeam(self.Owner),
		Damage = self.BaseDamage,
		RampUp = self.MaxDamageRampUp,
		Falloff = self.MaxDamageFalloff,
		Critical = self:Critical(),
		CritMultiplier = self.CritDamageMultiplier,
		DamageModifier = self.DamageModifier,
		DamageRandomize = self.DamageRandomize,
		
		Tracer = 1,
		TracerName = self.TracerEffect,
		Force = 1,
	}
	
	--if b then
		self.Owner:LagCompensation(false)
	--end
	
	self:ShootEffects()
end

function SWEP:ShootEffects()

	if self.Owner:GetMaterial() == "models/shadertest/predator" then return end
	if self:GetVisuals() and self:GetVisuals()["sound_single_shot"] then
		self.ShootSound = self:GetVisuals()["sound_single_shot"]
		self.ShootCritSound = self:GetVisuals()["sound_burst"]
	end
	if self:Critical() then
		self:EmitSound(self.ShootCritSound)
	else
		self:EmitSound(self.ShootSound, self.ShootSoundLevel, self.ShootSoundPitch)
	end
	
	if SERVER then
		if self.MuzzleEffect and self.MuzzleEffect~="" then
			umsg.Start("DoMuzzleFlash")
				umsg.Entity(self)
			umsg.End()
		end
	end
end