if SERVER then
	AddCSLuaFile( "shared.lua" )
end
game.AddParticles( "particles/soldierbuff.pcf" )
PrecacheParticleSystem( "soldierbuff_red_buffed" )
PrecacheParticleSystem( "soldierbuff_blue_buffed" )

if CLIENT then
	SWEP.PrintName			= "Concheror"
	SWEP.Slot				= 1
	SWEP.HasCModel			= true

	SWEP.RenderGroup 		= RENDERGROUP_BOTH
	
end


SWEP.Base				= "tf_weapon_melee_base"

SWEP.ViewModel			= "models/weapons/c_models/c_soldier_arms.mdl"
SWEP.WorldModel			= "models/weapons/c_models/c_shogun_warhorn/c_shogun_warhorn.mdl"
SWEP.Crosshair = "tf_crosshair3"

SWEP.Spawnable = true
SWEP.SpeedEnabled = false
SWEP.AdminSpawnable = false
SWEP.Category = "Team Fortress 2"

SWEP.Swing = Sound("weapons/samurai/tf_conch.wav")	
SWEP.HitFlesh = Sound("")
SWEP.HitWorld = Sound("weapons/buff_banner_flag.wav")

SWEP.BaseDamage = 45
SWEP.DamageRandomize = 0.1
SWEP.MaxDamageRampUp = 0
SWEP.MaxDamageFalloff = 0

SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay          = 28
SWEP.Secondary.Automatic		= true
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Delay          = 30
SWEP.RangedMinHealing = 45
SWEP.RangedMaxHealing = 85

SWEP.HoldType = "MELEE"

SWEP.Ready = true

function SWEP:PrimaryAttack()

	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )	
	self.Owner:DoAnimationEvent(ACT_MP_ATTACK_STAND_ITEM2, true)
	self:SendWeaponAnim(ACT_ITEM1_VM_SECONDARYATTACK)
	self:EmitSound("items/samurai/tf_conch.wav", 90, 100)
	timer.Simple(3, function()
		if SERVER then
		timer.Create("SetFasterSpeed1", 0.001, 0, function()
			if self.Owner:GetPlayerClass() == "soldier" then
				self.Owner:SetClassSpeed(110)
			elseif self.Owner:GetPlayerClass() == "scout" then
				self.Owner:SetClassSpeed(150)
			end
		end)
		self.Ready = false
		timer.Create("HealFor20Secs", 1, 20, function()
			GAMEMODE:HealPlayer(self.Owner, self.Owner, 10, false, false)
		end)
		self.SpeedEnabled = true
		self.Owner:Speak("TLK_PLAYER_BATTLECRY")
		self.Owner:SelectWeapon("tf_weapon_rocketlauncher")
		self.Owner:SelectWeapon("tf_weapon_rocketlauncher_bbox")
		self.Owner:SelectWeapon("tf_weapon_rocketlauncher_qrl")
		self.Owner:SelectWeapon("tf_weapon_rocketlauncher_dh")
		self.Owner:SelectWeapon("tf_weapon_rocketlauncher_dt")
		self.Owner:SelectWeapon("tf_weapon_rocketlauncher_airstrike")
		GAMEMODE:StartMiniCritBoost(self.Owner)
		ParticleEffectAttach("soldierbuff_red_buffed", PATTACH_ABSORIGIN_FOLLOW, self.Owner, 0)
		end
	end)
	timer.Simple(20, function()
		if SERVER then
			timer.Stop("SetFasterSpeed1")
			GAMEMODE:StopCritBoost(self.Owner)
			self.Owner:SetClassSpeed(80)			
		end
		self.Owner:StopParticlesNamed("soldierbuff_red_buffed")
		self.SpeedEnabled = false
		self.Ready = true
	end)
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_ITEM2_VM_DRAW)
	
	return self:CallBaseFunction("Holster")
end

function SWEP:Holster()
	self.NextMeleeAttack = nil
	
	self:StopTimers()
	
	return self:CallBaseFunction("Holster")
end