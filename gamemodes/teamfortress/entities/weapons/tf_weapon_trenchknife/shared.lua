if SERVER then

AddCSLuaFile("shared.lua")

end

SWEP.PrintName			= "Trench Knife"
SWEP.Slot				= 2

if CLIENT then

function SWEP:ResetBackcritState()
	self.NextBackcritIdle = nil
	self.BackcritState = false
	self.NextAllowBackcritAnim = CurTime() + 0.8
end

end

SWEP.Base				= "tf_weapon_melee_base"

SWEP.ViewModel			= "models/weapons/v_models/v_knife_spy.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_knife.mdl"
SWEP.Crosshair = "tf_crosshair3"

SWEP.Swing = Sound("Weapon_Knife.Miss")
SWEP.SwingCrit = Sound("Weapon_Knife.MissCrit")
SWEP.HitFlesh = Sound("Weapon_Knife.HitFlesh")
SWEP.HitWorld = Sound("Weapon_Knife.HitWorld")

SWEP.BaseDamage = 52
SWEP.DamageRandomize = 0.35
SWEP.MaxDamageRampUp = 0
SWEP.MaxDamageFalloff = 0

SWEP.CriticalChance = 0

SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay          = 0.8

SWEP.HoldType = "MELEE"

SWEP.MeleePredictTolerancy = 0.1
SWEP.MeleeAttackDelay = 0.15
SWEP.BackstabAngle = 180

-- ACT_MELEE_VM_STUN

function SWEP:ShouldBackcrit(ent)
	if not ent then
		local tr = self:MeleeAttack(true)
		ent = tr.Entity
	end
	
	if not IsValid(ent) or ent:Health()<=0 or not self.Owner:CanDamage(ent) or not ent:CanReceiveCrits() then
		return false
	end
	
	if not self.BackstabCos then
		self.BackstabCos = math.cos(math.rad(self.BackstabAngle * 0.5))
	end
	
	local v1 = ent:GetPos() - self.Owner:GetPos()
	local v2 = ent:GetAngles():Forward()
	
	v1.z = 0
	v2.z = 0
	v1:Normalize()
	v2:Normalize()
	
	return v1:Dot(v2) > self.BackstabCos
end

function SWEP:Critical(ent,dmginfo)
	if self:ShouldBackcrit(ent) then
		return true
	end
	
	return self:CallBaseFunction("Critical", ent, dmginfo)
end

function SWEP:PredictCriticalHit()
	if self:ShouldBackcrit() then
		return true
	end
end

function SWEP:Think()
	self:CallBaseFunction("Think")
	
	if CLIENT and self.IsDeployed then
		if not self.NextAllowBackcritAnim or CurTime() >= self.NextAllowBackcritAnim then
			local shouldbackcrit = self:ShouldBackcrit()
			
			if shouldbackcrit and not self.BackcritState then
				self.NextBackcritIdle = CurTime() + self:SequenceDuration()
			elseif not shouldbackcrit and self.BackcritState then
				self.NextBackcritIdle = nil
			end
			self.BackcritState = shouldbackcrit
			
			if self.NextBackcritIdle and CurTime()>=self.NextBackcritIdle then
				self.NextBackcritIdle = nil
			end
			
			self.NextAllowBackcritAnim = nil
		end
	end
end

function SWEP:PrimaryAttack()
	if not self:CallBaseFunction("PrimaryAttack") then return false end
	
	self.NameOverride = nil
	
	if game.SinglePlayer() then
		self:CallOnClient("ResetBackcritState", "")
	elseif CLIENT then
		self:ResetBackcritState()
	end
end

if SERVER then

hook.Add("PreScaleDamage", "BackcritSetDamage", function(ent, hitgroup, dmginfo)
	local inf = dmginfo:GetInflictor()
	if inf.ShouldBackcrit and inf:ShouldBackcrit(ent) then
		inf.ResetBaseDamage = inf.BaseDamage
		inf.BaseDamage = 50
		dmginfo:SetDamage(inf.BaseDamage)
	end
end)

hook.Add("PostScaleDamage", "BackcritResetDamage", function(ent, hitgroup, dmginfo)
	local inf = dmginfo:GetInflictor()
	if inf.ResetBaseDamage then
		inf.BaseDamage = inf.ResetBaseDamage
	end
end)

end
