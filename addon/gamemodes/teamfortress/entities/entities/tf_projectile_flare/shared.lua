-- Flare

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"

PrecacheParticleSystem("flaregun_trail_red")
PrecacheParticleSystem("flaregun_trail_blue")
PrecacheParticleSystem("flaregun_crit_red")
PrecacheParticleSystem("flaregun_crit_blue")
PrecacheParticleSystem("flaregun_destroyed")

ENT.IsTFWeapon = true

function ENT:InitEffects()
	local effect = "flaregun"
	
	if self.critical then
		effect = effect.."_crit_"
	else
		effect = effect.."_trail_"
	end
	
	effect = effect..ParticleSuffix(GAMEMODE:EntityTeam(self:GetOwner()))
	
	ParticleEffectAttach(effect, PATTACH_ABSORIGIN_FOLLOW, self, 0)
end

if CLIENT then

function ENT:Initialize()
	self:InitEffects()
end

function ENT:Draw()
	self:DrawModel()
end

end

if SERVER then

AddCSLuaFile( "shared.lua" )

ENT.Model = "models/weapons/w_models/w_flaregun_shell.mdl"

ENT.BaseDamage = 30
ENT.DamageRandomize = 0.1
ENT.MaxDamageRampUp = 0
ENT.MaxDamageFalloff = 0
ENT.DamageModifier = 1

ENT.HitboxSize = 0.5

ENT.CritDamageMultiplier = 3

ENT.HitSound = Sound("Default.FlareImpact")

function ENT:Critical()
	return self.critical
end

function ENT:MiniCrit()
	return self.minicrit
end

function ENT:CalculateDamage(ownerpos)
	return tf_util.CalculateDamage(self, self:GetPos(), ownerpos)
end

function ENT:Initialize()
	local min = Vector(-self.HitboxSize, -self.HitboxSize, -self.HitboxSize)
	local max = Vector( self.HitboxSize,  self.HitboxSize,  self.HitboxSize)
	
	self:SetModel(self.ModelOverride or self.Model)
	
	self:SetMoveType(MOVETYPE_FLYGRAVITY)
	self:SetMoveCollide(MOVECOLLIDE_FLY_CUSTOM)
	self:SetCollisionBounds(min, max)
	self:SetSolid(SOLID_BBOX)
	
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	
	self:SetLocalVelocity(self:GetForward() * (self.Force or 1650))
	self:SetGravity(0.5)
	
	if GAMEMODE:EntityTeam(self:GetOwner()) == TEAM_BLU then
		self:SetSkin(1)
	end
	
	self:InitEffects()
end

function ENT:Think()
	self:SetAngles(self:GetVelocity():Angle())
end

function ENT:Hit(ent)
	self.Touch = nil
	
	self:EmitSound(self.HitSound)
	
	local explosion = ents.Create("info_particle_system")
	explosion:SetKeyValue("effect_name", "flaregun_destroyed")
	explosion:SetKeyValue("start_active", "1")
	explosion:SetPos(self:GetPos()) 
	explosion:SetAngles(self:GetAngles())
	explosion:Spawn()
	explosion:Activate() 
	explosion:Fire("Kill", "", 0.5)
	
	local owner = self:GetOwner()
	if not owner or not owner:IsValid() then owner = self end
	
	local damage = self:CalculateDamage(owner:GetPos())
	local dir = self:GetVelocity():GetNormal()
	
	if ent:IsTFPlayer() and ent:HasPlayerState(PLAYERSTATE_ONFIRE) then
		self.minicrit = true
	end
	
	self:FireBullets{
		Src=self:GetPos(),
		Attacker=owner,
		Dir=dir,
		Spread=Vector(0,0,0),
		Num=1,
		Damage=damage,
		Tracer=0,
		HullSize=self.HitboxSize*2,
	}
	
	if ent:IsFlammable() then
		GAMEMODE:IgniteEntity(ent, self, owner, 10)
	end
	
	self:SetLocalVelocity(Vector(0,0,0))
	self:SetMoveType(MOVETYPE_NONE)
	self:SetNotSolid(true)
	self:SetNoDraw(true)
	self:Fire("kill", "", 0.1)
end

function ENT:Touch(ent)
	if not ent:IsTrigger() then
		self:Hit(ent)
	end
end

end
