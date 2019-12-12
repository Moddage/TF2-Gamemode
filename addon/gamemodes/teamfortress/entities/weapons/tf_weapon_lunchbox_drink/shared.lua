if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "Bonk! Atomic Punch"
SWEP.Slot				= 1
 
function SWEP:ResetParticles(state_override)
	self:CallBaseFunction("ResetParticles", state_override)
	
	if not self.DoneDeployParticle then
		if self.Owner==LocalPlayer() and not LocalPlayer():ShouldDrawLocalPlayer() then
			local ent = self:GetViewModelEntity()
			if IsValid(ent) then
				ParticleEffectAttach("energydrink_splash", PATTACH_POINT_FOLLOW, ent, ent:LookupAttachment("drink_spray"))
			end
		end
		
		self.DoneDeployParticle = true
	end
end 

function SWEP:Deploy()
	self:CallBaseFunction("Deploy")
	
	ParticleEffectAttach("energydrink_splash", PATTACH_POINT_FOLLOW, ent, ent:LookupAttachment("drink_spray"))
end

end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/c_models/c_scout_arms.mdl"
SWEP.WorldModel			= "models/weapons/c_models/c_energy_drink/c_energy_drink.mdl"
SWEP.Crosshair = "tf_crosshair3"

SWEP.Swing = Sound("")
SWEP.SwingCrit = Sound("")
SWEP.HitFlesh = Sound("")
SWEP.HitWorld = Sound("")

SWEP.BaseDamage = 45
SWEP.DamageRandomize = 0.1
SWEP.MaxDamageRampUp = 0
SWEP.MaxDamageFalloff = 0

SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay          = 0.8
SWEP.RangedMinHealing = 45
SWEP.RangedMaxHealing = 85

SWEP.HoldType = "ITEM1"

function SWEP:Deploy()
	self:EmitSound("player/pl_scout_dodge_can_open.wav", 85)
	self.BaseClass.Deploy(self)
end

function SWEP:PrimaryAttack()
	if SERVER then
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		self.Owner:EmitSound("common/stuck2.wav")
		self.Owner:PrintMessage(HUD_PRINTTALK, " !! Bonk Atomic Punch is disabled due to a game breaking bug involving primary attacks + secondary attacks. !!")
	end
-- NO BUG ALLOWED
--[[	self.Owner:DoAnimationEvent(ACT_DOD_SPRINT_AIM_SPADE, true)
	self.Owner:SetNWBool("Taunting", true)
	self.Owner:SetNWBool("Bonked", true)
	self.Owner:ConCommand("tf_thirdperson")
	timer.Simple(0.5, function()
		if SERVER then
		self:EmitSound( "player/pl_scout_dodge_can_drink_fast.wav", 85 )
		end
	end)
	timer.Simple(0.92, function() 
		self.Owner:SetNWBool("Taunting", false)  
		ParticleEffectAttach( 'warp_version', PATTACH_POINT_FOLLOW, self.Owner, 0)
		ParticleEffectAttach( 'scout_dodge_socks', PATTACH_POINT_FOLLOW, self.Owner, 0 )
		ParticleEffectAttach( 'scout_dodge_pants', PATTACH_POINT_FOLLOW, self.Owner, 0 )
		if self.Owner:Team() == TEAM_BLU then
			ParticleEffectAttach( 'scout_dodge_blue', PATTACH_POINT_FOLLOW, self.Owner, 3 )
		else
			ParticleEffectAttach( 'scout_dodge_red', PATTACH_POINT_FOLLOW, self.Owner, 3 )
		end
		if SERVER then
		self.Owner:GodEnable()
		end
	end)
	timer.Simple(15, function()
		if SERVER then
			self:EmitSound("player/pl_scout_dodge_tired.wav", 85)
		self.Owner:ConCommand("tf_firstperson")
		self.Owner:GodDisable()
		self.Owner:StopParticles() 
		self.Owner:SetNWBool("Bonked", false)
		end
	end)
	timer.Simple(40, function()
		if CLIENT then
		self.Owner:EmitSound("player/recharged.wav", 95)
		end
	end)
	timer.Simple(7, function()
		if SERVER then
		self:EmitSound( "Scout.Invincible0"..math.random(1,4))
		end
	end)
]]
end