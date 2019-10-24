if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "Super Shotgun"
	SWEP.Slot				= 3
	SWEP.RenderGroup		= RENDERGROUP_BOTH 
end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/v_models/v_supershotgun_mercenary.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_supershotgun.mdl"
SWEP.Crosshair = "tf_crosshair1"

SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Team Fortress 2"

SWEP.MuzzleEffect = "muzzle_scattergun"
SWEP.MuzzleOffset = Vector(20, 4, -3)

SWEP.ShootSound = Sound("weapons/supershotgun_shoot.wav")
SWEP.ShootCritSound = Sound("weapons/supershotgun_shoot_crit.wav")
SWEP.ReloadSound = Sound("weapons/supershotgun_worldreload.wav")
SWEP.DeploySound = Sound("weapons/draw_secondary.wav")

SWEP.TracerEffect = "bullet_scattergun_tracer01"
PrecacheParticleSystem("bullet_scattergun_tracer01_red")
PrecacheParticleSystem("bullet_scattergun_tracer01_red_crit")
PrecacheParticleSystem("bullet_scattergun_tracer01_blue")
PrecacheParticleSystem("bullet_scattergun_tracer01_blue_crit")
PrecacheParticleSystem("muzzle_scattergun")


SWEP.BaseDamage = 18
SWEP.DamageRandomize = 0.5
SWEP.MaxDamageRampUp = 0.8
SWEP.MaxDamageFalloff = 0.3

SWEP.BulletsPerShot = 10
SWEP.BulletSpread = 0.0675

SWEP.Primary.ClipSize		= 2
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_PRIMARY
SWEP.Primary.Delay          = 0.35

SWEP.ReloadSingle = true
SWEP.ReloadTime = 2
SWEP.HoldType = "SECONDARY"

SWEP.HoldTypeHL2 = "shotgun"

SWEP.KnockbackForceOwner = 225


SWEP.KnockbackMaxForce = 600
SWEP.MinKnockbackDistance = 512
SWEP.KnockbackAddPitch = -30

SWEP.PunchView = Angle( -2, 0, 0 )
SWEP.ReloadSingle = false
SWEP.ScattergunHasKnockback = true

function SWEP:OnEquipAttribute(a, owner)
	if a.attribute_class == "set_scattergun_no_reload_single" then
		self.ReloadDiscardClip = true
	elseif a.attribute_class == "set_scattergun_has_knockback" then
		self.ScattergunHasKnockback = true
	end
end

if SERVER then

function SWEP:DoOwnerKnockback()
	if self.Owner:OnGround() then return end
	if self.Owner.KnockbackJumpsRemaining and self.Owner.KnockbackJumpsRemaining <= 0 then return end
	
	local vel = self.Owner:GetVelocity()
	local dir = self.Owner:GetAimVector()
	local work = vel:Dot(dir)
	--if work < 0 then work = 0 end
	
	local force = self.KnockbackForceOwner + work
	if force < 0 then force = 0 end
	
	self.Owner:SetVelocity(-force * dir)
	
	self.Owner.KnockbackJumpsRemaining = (self.Owner.KnockbackJumpsRemaining or 1) - 1
	self.Owner:SetThrownByExplosion(true)
end

hook.Add("OnPlayerHitGround", "TFKnockbackJumpsReset", function(pl)
	pl.KnockbackJumpsRemaining = 1
end)

hook.Add("PostScaleDamage", "TFKnockbackDamage", function(ent, hitgroup, dmginfo)
	local inf = dmginfo:GetInflictor()
	local att = dmginfo:GetAttacker()
	
	if inf.ScattergunHasKnockback and not ent:IsThrownByExplosion() then
		local dist = inf:GetPos():Distance(ent:GetPos())
		if dist < inf.MinKnockbackDistance then
			if not inf.MaxKnockbackDamage then
				inf.MaxKnockbackDamage = inf.BaseDamage * (1 + inf.MaxDamageRampUp + inf.DamageRandomize) * inf.BulletsPerShot
			end
			
			local force = inf.KnockbackMaxForce * dmginfo:GetDamage() / inf.MaxKnockbackDamage
			local ang = att:EyeAngles()
			ang.p = ang.p + inf.KnockbackAddPitch
			
			ent:SetGroundEntity(NULL)
			ent:SetVelocity(ang:Forward() * force)
			ent:SetThrownByExplosion(true)
		end
	end
end)

end

function SWEP:PrimaryAttack()
	if not self:CallBaseFunction("PrimaryAttack") then return end
	
	if SERVER and self.ScattergunHasKnockback then
		self:DoOwnerKnockback()
	end
	
	return
end
