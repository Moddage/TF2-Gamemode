if SERVER then
	AddCSLuaFile( "shared.lua" )
	
end

if CLIENT then

SWEP.PrintName			= "Stickybomb Launcher"
SWEP.Slot				= 1

SWEP.GlobalCustomHUD = {HudDemomanPipes = true}
SWEP.CustomHUD = {HudBowCharge = true}

function SWEP:ClientStartCharge()
	self.ClientCharging = true
	self.ClientChargeStart = CurTime()
end

function SWEP:ClientEndCharge()
	self.ClientCharging = false
end

end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.HasTeamColouredVModel = false
SWEP.HasTeamColouredWModel = false

SWEP.ViewModel			= "models/weapons/v_models/v_stickybomb_launcher_demo.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_stickybomb_launcher.mdl"
SWEP.Crosshair = "tf_crosshair3"

SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Team Fortress 2"

SWEP.MuzzleEffect = "muzzle_pipelauncher"
PrecacheParticleSystem("muzzle_pipelauncher")

SWEP.ShootSound = Sound("Weapon_StickyBombLauncher.Single")
SWEP.ShootCritSound = Sound("Weapon_StickyBombLauncher.SingleCrit")
SWEP.DetonateSound = Sound("Weapon_StickyBombLauncher.ModeSwitch")
SWEP.ChargeSound = Sound("Weapon_StickyBombLauncher.ChargeUp")
SWEP.ReloadSound = Sound("Weapon_StickyBombLauncher.WorldReload")
SWEP.Primary.ClipSize		= 8
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_SECONDARY
SWEP.Primary.Delay          = 0.6

SWEP.IsRapidFire = false
SWEP.ReloadSingle = true

SWEP.HoldType = "PRIMARY"

SWEP.MaxBombs = 8
SWEP.Bombs = {}

SWEP.ProjectileShootOffset = Vector(0, 13, -10)
SWEP.MinForce = 805
SWEP.MaxForce = 805*2.3
SWEP.AddPitch = -4

SWEP.SensorCone = 30
SWEP.NoSensorDetonateRadius = 100

SWEP.PunchView = Angle( -2, 0, 0 )

function SWEP:InspectAnimCheck()
self.VM_INSPECT_START = ACT_SECONDARY_VM_INSPECT_START
self.VM_INSPECT_IDLE = ACT_SECONDARY_VM_INSPECT_IDLE
self.VM_INSPECT_END = ACT_SECONDARY_VM_INSPECT_END

	if !self.SoundsCreated then
		self.ChargeUpSound = CreateSound(self, self.ChargeSound)

		self.SoundsCreated = true
	end
end

function SWEP:Deploy()
	if CLIENT then
		HudBowCharge:SetProgress(0)
	end
	
	return self:CallBaseFunction("Deploy")
end

function SWEP:OnEquipAttribute(a, owner)
	if a.attribute_class == "mult_maxammo_secondary" then
		self.Safe = true
	end
end

function SWEP:IsBombInSensorCone(ent)
	local dot = self.Owner:GetAimVector():Dot((ent:GetPos() - self.Owner:GetShootPos()):GetNormal())
	
	if not self.SensorCos then
		self.SensorCos = math.cos(math.rad(self.SensorCone * 0.5))
	end
	
	return dot >= self.SensorCos
end

function SWEP:InitOwner()
	self.Owner:SetNWInt("NumBombs", 0)
	self.Owner.Bombs = {}
end

function SWEP:PrimaryAttack()
	if not self.IsDeployed then return false end
	if self.Reloading then return false end
	
	self.NextDeployed = nil
	
	-- Already charging
	if self.Charging then return end
	
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
	self:SendWeaponAnim(self.VM_PULLBACK)
	
	if SERVER then
		self:CallOnClient("ClientStartCharge", "")
	end
	
	self.NextIdle2 = CurTime()+self:SequenceDuration()
	self.ChargeStartTime = CurTime()
end

function SWEP:Think()
	local BASESPEED = 3 --this is really bad if anyone has a better way of doing this please tell me
	local sp = 100
	self:CallBaseFunction("Think")
	self.Owner:SetWalkSpeed(BASESPEED * sp)
	
	if CLIENT then
		if self.ClientCharging and self.ClientChargeStart then
			HudBowCharge:SetProgress((CurTime()-self.ClientChargeStart) / 4)
		else
			HudBowCharge:SetProgress(0)
		end
	end
	
	if self.Charging then
		if (not self.Owner:KeyDown(IN_ATTACK) or CurTime() - self.ChargeStartTime > 4) then
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
		else
			if (game.SinglePlayer() or CLIENT) and not self.ChargeUpSound then
				self.ChargeUpSound = CreateSound(self, self.ChargeSound)
				self.ChargeUpSound:Play()
			end
		end
	end
end

function SWEP:GlobalSecondaryAttack()
	if SERVER then
		self:DetonateProjectiles()
	end
end

function SWEP:ShootProjectile()
		if self.Owner:GetInfoNum("tf_autoreload", 1) > 0 then
			timer.Create("AutoReload", (self:SequenceDuration() + self.AutoReloadTime), 1, function() self:Reload() end)
		end

	if SERVER then
		if not self.Owner.Bombs then
			self:InitOwner()
		end
		
		local grenade = ents.Create("tf_projectile_pipe_remote")
		grenade:SetPos(self:ProjectileShootPos())
		grenade:SetAngles(self.Owner:EyeAngles())
		
		if self:Critical() then
			grenade.critical = true
		end
		grenade:SetOwner(self.Owner)
		
		self:InitProjectileAttributes(grenade)
		
		grenade:Spawn()
		
		if self.Safe == true then
			grenade:SetModel("models/weapons/w_models/w_stickybomb2.mdl")
		end
		
		local force = Lerp((CurTime() - self.ChargeStartTime) / 4, self.MinForce, self.MaxForce)
		
		local vel = self.Owner:GetAimVector():Angle()
		vel.p = vel.p + self.AddPitch
		vel = vel:Forward() * force * (grenade.Mass or 10)
		
		grenade:GetPhysicsObject():AddAngleVelocity(Vector(math.random(-2000,2000),math.random(-2000,2000),math.random(-2000,2000)))
		grenade:GetPhysicsObject():ApplyForceCenter(vel)
		
		table.insert(self.Owner.Bombs, grenade)
		if #self.Owner.Bombs>self.MaxBombs then
			table.remove(self.Owner.Bombs, 1):DoExplosion()
		end
		
		self.Owner:SetNWInt("NumBombs", #self.Owner.Bombs)
		end
	self:ShootEffects()
	self.Owner:ViewPunch( self.PunchView )
end

function SWEP:DetonateProjectiles(nosound, noexplode)
	if SERVER then
		local owner = (IsValid(self.Owner) and self.Owner) or self.CurrentOwner
		
		if not self or not self:IsValid() then return end
		
		if not owner.Bombs then
			self:InitOwner()
		end
		
		local det = false
		
		if not owner.Bombs then return end
		
		for k=#owner.Bombs,1,-1 do
			local bomb = owner.Bombs[k]
			local ready = bomb and (bomb.Ready or noexplode)
			
			if ready and bomb.DetonateMode == 1 and not noexplode then
				if bomb:GetPos():Distance(owner:GetShootPos()) > self.NoSensorDetonateRadius and not self:IsBombInSensorCone(bomb) then
					ready = false
				end
			end
			
			if ready then
				if noexplode then
					bomb:Break()
				else
					bomb:DoExplosion()
					det = true
				end
				table.remove(owner.Bombs, k)
			end
		end
		
		if det and not nosound then
			self:EmitSound(self.DetonateSound, 100, 100)
		end
		
		owner:SetNWInt("NumBombs", #owner.Bombs)
	end
end

function SWEP:OnRemove()
	self:DetonateProjectiles(true, true)
	
	if (game.SinglePlayer() or CLIENT) and self.ChargeUpSound then
		self.ChargeUpSound:Stop()
	end
end
