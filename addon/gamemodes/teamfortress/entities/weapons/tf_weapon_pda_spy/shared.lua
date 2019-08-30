if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Base				= "tf_weapon_base"

SWEP.ViewModel			= "models/weapons/v_models/v_pda_spy.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_cigarette_case.mdl"

SWEP.HoldType = "PDA"

SWEP.IsPDA = true
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay 			= 1

SWEP.Secondary.Delay		= 5

if CLIENT then

SWEP.PrintName			= "Disguise PDA"
SWEP.Slot				= 3
SWEP.Crosshair = ""

end

function SWEP:SecondaryAttack()
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + 1 )
	self.Owner:ConCommand("tf_spydisguise")
	timer.Simple(3, function()
		for _,v in pairs(ents.GetAll()) do
			if v:IsNPC() and not v:IsFriendly(self.Owner) then
				v:AddEntityRelationship(self.Owner, D_LI, 99)
			end
		end
	end)
	if self.Owner:Team() == TEAM_RED or self.Owner:Team() == TEAM_NEUTRAL then
		ParticleEffectAttach( "spy_start_disguise_red", PATTACH_ABSORIGIN_FOLLOW, self.Owner, 1 )
	else
		ParticleEffectAttach( "spy_start_disguise_blue", PATTACH_ABSORIGIN_FOLLOW, self.Owner, 1 )
	end
end