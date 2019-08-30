if SERVER then
	AddCSLuaFile( "shared.lua" )
	
end

if CLIENT then

SWEP.PrintName			= "Rocket Launcher"
SWEP.Slot				= 0

function SWEP:ClientStartCharge()
	self.ClientCharging = true
	self.ClientChargeStart = CurTime()
end

function SWEP:ClientEndCharge()
	self.ClientCharging = false
end

end

function SWEP:OnEquipAttribute(a, owner)
	if a.attribute_class == "set_weapon_mode" then
		if a.value == 1 then
			if CLIENT then
				self.CustomHUD = {HudBowCharge = true}
			end
		end
	end
end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/v_models/v_rocketlauncher_soldier.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_rocketlauncher.mdl"
SWEP.Crosshair = "tf_crosshair3"

SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Team Fortress 2"

SWEP.MuzzleEffect = "rocketbackblast"
PrecacheParticleSystem("rocketbackblast")

SWEP.ShootSound = Sound("weapons/rocket_shoot.wav")
SWEP.ShootCritSound = Sound("Weapon_RPG.SingleCrit")
SWEP.ChargeSound = Sound("Weapon_StickyBombLauncher.ChargeUp")
SWEP.ReloadSound = Sound("Weapon_RPG.WorldReload")

SWEP.Primary.ClipSize		= 4
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_PRIMARY

SWEP.Primary.Delay = 0.8
SWEP.ReloadTime = 0.8
SWEP.IsRapidFire = false
SWEP.ReloadSingle = true

SWEP.HoldType = "PRIMARY"
SWEP.HoldTypeHL2 = "rpg"

SWEP.ProjectileShootOffset = Vector(0, 13, -4)

SWEP.PunchView = Angle( 0, 0, 0 )

SWEP.Properties = {}

SWEP.ChargeTime = 2
SWEP.MinForce = 150
SWEP.MaxForce = 2800

SWEP.MinAddPitch = -1
SWEP.MaxAddPitch = -6

SWEP.MinGravity = 1
SWEP.MaxGravity = 1

function SWEP:Deploy()
	if CLIENT then
		HudBowCharge:SetProgress(0)
	end
	
	return self:CallBaseFunction("Deploy")
end

function SWEP:PrimaryAttack()
	if self.WeaponMode ~= 1 then
		return self:CallBaseFunction("PrimaryAttack")
	end
	
	if not self.IsDeployed then return false end
	if self.Reloading then return false end
	
	self.NextDeployed = nil
	
	-- Already charging
	if self.Charging or self.LockAttackKey then return end
	
	local Delay = self.Delay or -1
	local QuickDelay = self.QuickDelay or -1
	
	if (not(self.Primary.QuickDelay>=0 and self.Owner:KeyPressed(IN_ATTACK)) and Delay>=0 and CurTime()<Delay)
	or (self.Primary.QuickDelay>=0 and self.Owner:KeyPressed(IN_ATTACK) and QuickDelay>=0 and CurTime()<QuickDelay) then
		return
	end
	
	self.Delay =  CurTime() + self.Primary.Delay
	self.QuickDelay =  CurTime() + self.Primary.QuickDelay
	
	if not self:CanPrimaryAttack() then
		return
	end
	
	if self.NextReload or self.NextReloadStart then
		self.NextReload = nil
		self.NextReloadStart = nil
	end
	
	-- Start charging
	self.Charging = true
	self:SendWeaponAnim(self.VM_IDLE)
	
	if SERVER then
		self:CallOnClient("ClientStartCharge", "")
	end
	
	self.ChargeStartTime = CurTime()
end

function SWEP:Think()
	self:CallBaseFunction("Think")
	
	if self.WeaponMode ~= 1 then return end
	
	if CLIENT then
		if self.ClientCharging and self.ClientChargeStart then
			HudBowCharge:SetProgress((CurTime()-self.ClientChargeStart) / self.ChargeTime)
		else
			HudBowCharge:SetProgress(0)
		end
	end
	
	if self.LockAttackKey and not self.Owner:KeyDown(IN_ATTACK) then
		self.LockAttackKey = nil
	end
	
	if self.Charging then
		if (not self.Owner:KeyDown(IN_ATTACK) or CurTime() - self.ChargeStartTime > self.ChargeTime) then
			self.Charging = false
			
			self:SendWeaponAnim(self.VM_PRIMARYATTACK)
			self.Owner:DoAttackEvent()
			
			self.NextIdle = CurTime() + self:SequenceDuration()
			
			self:ShootProjectile()
			self:TakePrimaryAmmo(1)
			
			self.Delay =  CurTime() + self.Primary.Delay
			self.QuickDelay =  CurTime() + self.Primary.QuickDelay
			
			if SERVER then
				self:CallOnClient("ClientEndCharge", "")
			end
			
			if self:Clip1() <= 0 then
				self:Reload()
			end
			
			if SERVER and not self.Primary.NoFiringScene then
				self.Owner:Speak("TLK_FIREWEAPON", true)
			end
			
			self:RollCritical() -- Roll and check for criticals first
			
			if (game.SinglePlayer() or CLIENT) and self.ChargeUpSound then
				self.ChargeUpSound:Stop()
				self.ChargeUpSound = nil
			end
			
			self.LockAttackKey = true
		else
			if (game.SinglePlayer() or CLIENT) and not self.ChargeUpSound then
				self.ChargeUpSound = CreateSound(self, self.ChargeSound)
				self.ChargeUpSound:PlayEx(1, 400 / self.ChargeTime)
			end
		end
	end
	self:Inspect()
end

function SWEP:ShootProjectile()
	if SERVER then
		local rocket = ents.Create("tf_projectile_rocket")
		rocket:SetPos(self:ProjectileShootPos())
		local ang = self.Owner:EyeAngles()
		if self:GetItemData().model_player == "models/weapons/c_models/c_rocketjumper/c_rocketjumper.mdl" then
			rocket.ExplosionSound = "weapons/rocket_jumper_explode1.wav"
		end
		if self.WeaponMode == 1 then
			local charge = (CurTime() - self.ChargeStartTime) / self.ChargeTime
			rocket.Gravity = Lerp(1 - charge, self.MinGravity, self.MaxGravity)
			rocket.BaseSpeed = Lerp(charge, self.MinForce, self.MaxForce)
			ang.p = ang.p + Lerp(1 - charge, self.MinAddPitch, self.MaxAddPitch)
		end
		
		rocket:SetAngles(ang)
		
		if self:Critical() then
			rocket.critical = true
		end
		
		for k,v in pairs(self.Properties) do
			rocket[k] = v
		end
		
		rocket:SetOwner(self.Owner)
		self:InitProjectileAttributes(rocket)
		
		rocket:Spawn()
		rocket:Activate()
	end
	
	self:ShootEffects()
end

function SWEP:OnRemove()
	if (game.SinglePlayer() or CLIENT) and self.ChargeUpSound then
		self.ChargeUpSound:Stop()
		self.ChargeUpSound = nil
	end
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
			umsg.Start("DoRPGMuzzleFlash")
				umsg.Entity(self)
			umsg.End()
		end
	end
end
