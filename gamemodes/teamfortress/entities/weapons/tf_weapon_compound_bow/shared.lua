if SERVER then
	AddCSLuaFile( "shared.lua" )
	SWEP.HeadshotScore = 1
end

if CLIENT then

SWEP.PrintName			= "The Huntsman"
SWEP.HasCModel = true
SWEP.Slot				= 0

function SWEP:InspectAnimCheck()
inspect_start = NONE
inspect_idle = NONE
inspect_end = NONE
inspect_post = NONE
end

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

SWEP.ViewModel			= Model("models/weapons/c_models/c_sniper_arms.mdl")
SWEP.WorldModel			= Model("models/weapons/c_models/c_bow/c_bow.mdl")
SWEP.Crosshair = "tf_crosshair1"
SWEP.ViewModelFlip	= false

SWEP.MuzzleEffect = ""

SWEP.ShootSound = Sound("Weapon_CompoundBow.Single")
SWEP.ShootCritSound = Sound("Weapon_CompoundBow.SingleCrit")
SWEP.PullSound = Sound("Weapon_CompoundBow.SinglePull")
SWEP.DeniedSound = Sound("Player.UseDeny")

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 12
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= TF_PRIMARY
SWEP.Primary.Delay          = 1.94

SWEP.Secondary.Automatic	= true

SWEP.IsRapidFire = false
SWEP.ReloadSingle = false

SWEP.HoldType = "ITEM2"

SWEP.ProjectileShootOffset = Vector(0, 6, -5)

SWEP.Properties = {}

function SWEP:Deploy()
	if CLIENT then
		HudBowCharge:SetProgress(0)
	end
	
	return self:CallBaseFunction("Deploy")
end

function SWEP:SendSequence(seq)
	local s = self.Owner:GetViewModel():LookupSequence(seq)
	self:SetSequence(s)
	self.Owner:GetViewModel():SetSequence(s)
end

function SWEP:PrimaryAttack()
	if not self.IsDeployed then return false end
	
	-- Already charging
	if self.Charging or self.NextIdle then return end
	
	if not self:CanPrimaryAttack() then
		return
	end
	
	-- Start charging
	self.Charging = true
	if SERVER then
		self:CallOnClient("ClientStartCharge", "")
	end
	
	self:SendWeaponAnim(self.VM_CHARGE)
	--self:SendSequence("bw_charge")
	--self.Owner:SetAnimation(PLAYER_PREFIRE)
	self.Owner:DoAnimationEvent(ACT_MP_DEPLOYED, true)
	
	self.NextIdle2 = CurTime()+self:SequenceDuration()
	self.ChargeStartTime = CurTime()
	self:EmitSound(self.PullSound)
	--[[
	self:Critical(1)
	self:ShootProjectile()
	
	self:TakePrimaryAmmo(1)]]
	
	if SERVER then
		self.Owner:SetClassSpeed(45 * (self.DeployMoveSpeedMultiplier or 1))
		self.Owner:SetCrouchedWalkSpeed(0.33)
		self.Owner:SetJumpPower(0)
	end
end

function SWEP:SecondaryAttack()
	if not self.IsDeployed then return false end
	
	if self.Charging and not self.NextIdle2 then
		self.Charging = false
		self:SendWeaponAnim(self.VM_DRYFIRE)
		--self:SendSequence("bw_dryfire")
		self.Owner:DoAnimationEvent(ACT_MP_STAND_PRIMARY, true)
		self.NextIdle = CurTime()+self:SequenceDuration()
		
		if SERVER then
			self:CallOnClient("ClientEndCharge", "")
			self.Owner:ResetClassSpeed()
		end
	end
end

function SWEP:ShootProjectile()
	if SERVER then
		local arrow = ents.Create("tf_projectile_arrow")
		arrow:SetPos(self:ProjectileShootPos())
		
		if CurTime()-self.ChargeStartTime>5 then
			arrow:SetAngles(self.Owner:EyeAngles() + Angle(math.Rand(-15,15),math.Rand(-15,15),0))
		else
			arrow:SetAngles(self.Owner:EyeAngles())
		end
		
		--[[
		if arrow:Critical() then
			rocket.critical = true
		end]]
		
		for k,v in pairs(self.Properties) do
			arrow[k] = v
		end
		
		arrow.Charge = math.Clamp((CurTime()-self.ChargeStartTime) / 1.25, 0, 1)
		arrow.MinForce = self.MinForce
		arrow.MaxForce = self.MaxForce
		arrow.MinGravity = self.MinGravity
		arrow.MaxGravity = self.MaxGravity
		arrow:SetOwner(self.Owner)
		self:InitProjectileAttributes(arrow)
		
		arrow.NameOverride = self:GetItemData().item_iconname
		arrow:Spawn()
		arrow:Activate()
	end
	
	self:ShootEffects()
end

function SWEP:Think()
	self:TFViewModelFOV()

	if GetConVar("tf_righthand") then
		if GetConVar("tf_righthand"):GetInt() == 1 then
			self.ViewModelFlip = true
		else
			self.ViewModelFlip = false
		end
	end

	if SERVER and self.NextReplayDeployAnim then
		if CurTime() > self.NextReplayDeployAnim then
			--MsgFN("Replaying deploy animation %d", self.VM_DRAW)
			timer.Simple(0.1, function() self:SendWeaponAnim(self.VM_DRAW) end)
			self.NextReplayDeployAnim = nil
		end
	end
	
	if CLIENT then
		if self.ClientCharging and self.ClientChargeStart then
			HudBowCharge:SetProgress((CurTime()-self.ClientChargeStart) / 1.25)
		else
			HudBowCharge:SetProgress(0)
		end
	end
	
	if not self.IsDeployed and self.NextDeployed and CurTime()>=self.NextDeployed then
		self.IsDeployed = true
		self.CanInspect = true
		self:CheckAutoReload()
	end
	
	if self.NextIdle and CurTime()>=self.NextIdle then
		self:SendWeaponAnim(self.VM_IDLE)
		self.NextIdle = nil
		self.NextIdle2 = nil
		self.NextCharge3 = nil
		self.NextIdle3 = nil
	end
	
	if self.NextIdle2 and CurTime()>=self.NextIdle2 then
		self:SendWeaponAnim(self.VM_IDLE_2)
		--self:SendSequence("bw_idle2")
		self.NextIdle2 = nil
		self.NextCharge3 = CurTime()+5
	end
	
	if self.NextCharge3 and CurTime()>=self.NextCharge3 then
		self:SendWeaponAnim(self.VM_CHARGE_IDLE_3)
		--self:SendSequence("bw_shake")
		self.NextCharge3 = nil
		self.NextIdle3 = CurTime()+self:SequenceDuration()
	end
	
	if self.NextIdle3 and CurTime()>=self.NextIdle3 then
		self:SendWeaponAnim(self.VM_IDLE_3)
		--self:SendSequence("bw_idle3")
		self.NextIdle3 = nil
	end
	
	if self.Charging and not self.Idle2 and not self.Owner:KeyDown(IN_ATTACK) and self.Owner:IsOnGround() then
		self.Charging = false
		if SERVER then
			self:CallOnClient("ClientEndCharge", "")
		end
		self.NextIdle = nil
		self.NextIdle2 = nil
		self.NextCharge3 = nil
		self.NextIdle3 = nil
		self:ShootProjectile()
		self:TakePrimaryAmmo(1)
		
		self:SendWeaponAnim(self.VM_PRIMARYATTACK)
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self.Owner:DoAnimationEvent(ACT_MP_STAND_PRIMARY, true)
		self.NextIdle = CurTime()+self:SequenceDuration()
		if self.Owner:GetAmmoCount(self.Primary.Ammo)>0 then
			self.Reloading = true
			self.AmmoAdded = 1
			self.NextReload = self.NextIdle-0.1
		end
		
		if SERVER then
			self.Owner:ResetClassSpeed()
		end
	end
	
	if self.NextReload and CurTime()>=self.NextReload then
		self:SetClip1(self:Clip1() + self.AmmoAdded)
		self.Owner:RemoveAmmo(self.AmmoAdded, self.Primary.Ammo, false)
		self.NextReload = nil
	end
end