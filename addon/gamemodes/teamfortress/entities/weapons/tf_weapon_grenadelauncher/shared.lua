if SERVER then
	AddCSLuaFile( "shared.lua" )
	
end

if CLIENT then

SWEP.PrintName			= "Grenade Launcher"
SWEP.Slot				= 0

function SWEP:InitializeCModel()
	self:CallBaseFunction("InitializeCModel")
	
	if IsValid(self.CModel) then
		self.CModel:SetBodygroup(1, 1)
	end
	
	for _,v in pairs(self.Owner:GetTFItems()) do
		if v:GetClass() == "tf_wearable_item_demoshield" then
			self.ShieldEntity = v
			v:InitializeCModel(self)
		end
	end	
	
	for _,v in pairs(self.Owner:GetTFItems()) do
		if v:GetClass() == "tf_wearable_item_tideturnr" then
			self.ShieldEntity = v
			v:InitializeCModel(self)
		end
	end
end


function SWEP:ViewModelDrawn()
	self:CallBaseFunction("ViewModelDrawn")
	
	if IsValid(self.ShieldEntity) and IsValid(self.ShieldEntity.CModel) then
		self.ShieldEntity:StartVisualOverrides()
		self.ShieldEntity.CModel:DrawModel()
		self.ShieldEntity:EndVisualOverrides()
	end
end

function SWEP:InitializeWModel2()
	self:CallBaseFunction("InitializeWModel2")
	
	--[[if IsValid(self.WModel2) then
		self.WModel2:SetBodygroup(1, 1)
	end]]
end

end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/v_models/v_grenadelauncher_demo.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_grenadelauncher.mdl"
SWEP.Crosshair = "tf_crosshair3"

SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Team Fortress 2"

--[[ --Viewmodel Settings Override (left-over from testing; works well)
SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= false
]]

SWEP.MuzzleEffect = "muzzle_grenadelauncher"
PrecacheParticleSystem("muzzle_grenadelauncher")

SWEP.ShootSound = Sound("Weapon_GrenadeLauncher.Single")
SWEP.ShootCritSound = Sound("Weapon_GrenadeLauncher.SingleCrit")
SWEP.ReloadSound = Sound("Weapon_GrenadeLauncher.WorldReload")

SWEP.Primary.ClipSize		= 4
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_PRIMARY
SWEP.Primary.Delay          = 0.6
SWEP.ReloadTime = 0.6

SWEP.IsRapidFire = false
SWEP.ReloadSingle = true

SWEP.HoldType = "SECONDARY"

SWEP.HoldTypeHL2 = "shotgun"

SWEP.ProjectileShootOffset = Vector(0, 7, -6)
SWEP.Force = 1100
SWEP.AddPitch = -4

SWEP.PunchView = Angle( -2, 0, 0 )

SWEP.Properties = {}

SWEP.SpinSound = true

function SWEP:OnEquipAttribute(a, owner)
	if a.attribute_class == "mult_clipsize" then
		self.SpinSound = false
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
				self.Owner:DoAnimationEvent(ACT_SMG2_RELOAD2, true)	
				self:SendWeaponAnim(self.VM_RELOAD_FINISH)
				self.CanInspect = true
				--self.Owner:SetAnimation(10001) -- reload finish
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

function SWEP:InspectAnimCheck()
self.VM_INSPECT_START = ACT_PRIMARY_VM_INSPECT_START
self.VM_INSPECT_IDLE = ACT_PRIMARY_VM_INSPECT_IDLE
self.VM_INSPECT_END = ACT_PRIMARY_VM_INSPECT_END
	
	if self:GetItemData().model_player == "models/weapons/c_models/c_lochnload/c_lochnload.mdl" then
		self.ShootSound = Sound("weapons/loch_n_load_shoot.wav")
		self.ShootCritSound = Sound("weapons/loch_n_load_shoot_crit.wav")
	end
	if ( self:GetOwner():KeyPressed( IN_SPEED ) and inspecting == false and GetConVar("tf_caninspect"):GetBool() and self.Owner:GetInfoNum("tf_sprintinspect", 1) == 1 ) then
		timer.Create("StartInspection", self:SequenceDuration(), 1,function()
			if self:GetOwner():KeyDown( IN_SPEED ) then 
				inspecting_idle = true
			else
				if CLIENT then
					timer.Create("PlaySpin", 1.07, 1, function() surface.PlaySound( "player/taunt_clip_spin_long.wav" ) end)
				end
				inspecting_idle = false
			end
		end )
	end

	if ( self:GetOwner():KeyReleased( IN_SPEED ) and inspecting_idle == true and GetConVar("tf_caninspect"):GetBool() and self.Owner:GetInfoNum("tf_sprintinspect", 1) == 1 ) then
		if CLIENT then
			timer.Create("PlaySpin", 1.07, 1, function() surface.PlaySound( "player/taunt_clip_spin_long.wav" ) end)
		end
	end

	if ( self:GetOwner():KeyPressed( IN_RELOAD ) and self:Clip1() == self:GetMaxClip1() and inspecting == false and GetConVar("tf_caninspect"):GetBool() and self.Owner:GetInfoNum("tf_reloadinspect", 1) == 1 ) then
		timer.Create("StartInspection", self:SequenceDuration(), 1,function()
			if self:GetOwner():KeyDown( IN_RELOAD ) then 
				inspecting_idle = true
			else
				if CLIENT then
					timer.Create("PlaySpin", 1.07, 1, function() surface.PlaySound( "player/taunt_clip_spin_long.wav" ) end)
				end
				inspecting_idle = false
			end
		end )
	end

	if ( self:GetOwner():KeyReleased( IN_RELOAD ) and self:Clip1() == self:GetMaxClip1() and inspecting_idle == true and GetConVar("tf_caninspect"):GetBool() and self.Owner:GetInfoNum("tf_reloadinspect", 1) == 1 ) then
		if CLIENT then
			timer.Create("PlaySpin", 1.07, 1, function() surface.PlaySound( "player/taunt_clip_spin_long.wav" ) end)
		end
	end
	
	--[[	if ( self:GetOwner():GetNWString("inspect") == "inspecting_released" and inspecting_post == false and GetConVar("tf_caninspect"):GetBool() and self.SpinSound == true and !(self.Owner:GetMoveType()==MOVETYPE_NOCLIP) ) then
		if CLIENT then
			timer.Create("PlaySpin", 2.06, 1, function() surface.PlaySound( "player/taunt_clip_spin_long.wav" ) end)
		end
	end]]
end

function SWEP:StopTimers()
	self:CallBaseFunction("StopTimers")
	timer.Remove("PlaySpin")
end

function SWEP:ShootProjectile()
	if SERVER then
		local grenade = ents.Create("tf_projectile_pipe")
		grenade:SetPos(self:ProjectileShootPos())
		grenade:SetAngles(self.Owner:EyeAngles())

		if self:Critical() then
			grenade.critical = true
		end
		
		for k,v in pairs(self.Properties) do
			grenade[k] = v
		end
		
		grenade:SetOwner(self.Owner)
		
		self:InitProjectileAttributes(grenade)
		grenade.NameOverride = self:GetItemData().item_iconname		
		grenade:Spawn()
		
		if self:GetItemData().model_player == "models/workshop/weapons/c_models/c_quadball/c_quadball.mdl" then
			grenade:SetModel("models/workshop/weapons/c_models/c_quadball/w_quadball_grenade.mdl")
			grenade.ExplosionSound = Sound("Weapon_Airstrike.Explosion")
		end
		if self.VM_RELOAD == ACT_PRIMARY_VM_RELOAD_2 then
			grenade.DetonateMode = 2
			else
			grenade.DetonateMode = 0
		end
		
		local vel = self.Owner:GetAimVector():Angle()
		vel.p = vel.p + self.AddPitch
		vel = vel:Forward() * self.Force * (grenade.Mass or 10)
		
		if self.Owner.TempAttributes.ProjectileModelModifier == 1 then
			grenade:GetPhysicsObject():AddAngleVelocity(Vector(math.random(-800,800),math.random(-800,800),math.random(-800,800)))
		else
			grenade:GetPhysicsObject():AddAngleVelocity(Vector(math.random(-2000,2000),math.random(-2000,2000),math.random(-2000,2000)))
		end
		grenade:GetPhysicsObject():ApplyForceCenter(vel)
	end

		
	
	self:StopTimers()
	self:ShootEffects()
end