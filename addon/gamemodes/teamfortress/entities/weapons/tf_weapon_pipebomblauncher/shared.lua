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
SWEP.ReloadTime = 0.7

SWEP.IsRapidFire = false
SWEP.ReloadSingle = true

SWEP.HoldType = "PRIMARY"
SWEP.HoldTypeHL2 = "ar2qs"

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
end

function SWEP:Deploy()
	if CLIENT then
		HudBowCharge:SetProgress(0)
	end
					
	if self.Owner:IsPlayer() and not self.Owner:IsHL2() and self.Owner:Team() == TEAM_BLU and string.find(game.GetMap(), "mvm_") then
		timer.Create("Unstuck"..self.Owner:EntIndex(), 0.01, 0, function()
			if SERVER then
				if self.Owner:IsInWorld() == false then
					self.Owner:Spawn()
				end
			end
		end)
		self.Owner:SetBloodColor(BLOOD_COLOR_MECH)
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

function SWEP:CreateSounds()
	self.ChargeUpSound = CreateSound(self, self.ChargeSound)
	
	self.SoundsCreated = true
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
				if self:GetHoldType() == "PRIMARY" and self.Owner:GetPlayerClass() == "engineer" or self.Owner:GetPlayerClass() == "scout" or self.Owner:GetPlayerClass() == "demoman" then
					self.Owner:DoAnimationEvent(ACT_SMG2_DRAW2, true)
				elseif self:GetHoldType() == "PRIMARY" and self.Owner:GetPlayerClass() != "engineer" then
					self.Owner:DoAnimationEvent(ACT_SMG2_IDLE2, true)
				elseif self:GetHoldType() == "SECONDARY" and self.Owner:GetPlayerClass() == "heavy" or self.Owner:GetPlayerClass() == "pyro" or self.Owner:GetPlayerClass() == "demoman" then 
					self.Owner:DoAnimationEvent(ACT_SMG2_RELOAD2, true)	
				elseif self:GetHoldType() == "SECONDARY" and self.Owner:GetPlayerClass() != "heavy"  then
					self.Owner:DoAnimationEvent(ACT_SMG2_FIRE2, true)				
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
			if SERVER then	
			self.Owner:DoAnimationEvent(ACT_MP_RELOAD_STAND_LOOP, true)
			end
			if self.ReloadTime == 0.2 then
				self.Owner:GetViewModel():SetPlaybackRate(2)
			end
			if self.ReloadTime == 1.1 then 
				if self:GetItemData().model_player == "models/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl" then
					if CLIENT then
						self.Owner:EmitSound("Weapon_DumpsterRocket.Reload")
					end
				end
				self.Owner:GetViewModel():SetPlaybackRate(0.7)
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
		if self.ReloadTime == 0.2 then
			self.Owner:GetViewModel():SetPlaybackRate(2)
		end
		if self.ReloadTime == 1.1 then 
			if self:GetItemData().model_player == "models/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl" then
				if CLIENT then
					self.Owner:EmitSound("Weapon_DumpsterRocket.Reload")
				end
			end
			self.Owner:GetViewModel():SetPlaybackRate(0.7)
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
	if SERVER then
		if not self.Owner.Bombs then
			self:InitOwner()
		end
		
		if auto_reload then
			timer.Create("AutoReload", (self:SequenceDuration() + self.AutoReloadTime), 1, function() self:Reload() end)
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

		if self:GetItemData().model_player == "models/workshop/weapons/c_models/c_kingmaker_sticky/c_kingmaker_sticky.mdl" then
			grenade:SetModel("models/workshop/weapons/c_models/c_kingmaker_sticky/w_kingmaker_stickybomb.mdl")
			grenade.ExplosionSound = Sound("Weapon_TackyGrendadier.Explode")
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
		if self:GetItemData().model_player == "models/weapons/c_models/c_sticky_jumper/c_sticky_jumper.mdl" then
			grenade.ExplosionSound = Sound("weapons/sticky_jumper_explode1.wav")
		end
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
			self.Owner:EmitSound(self.DetonateSound, 100, 100)
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

