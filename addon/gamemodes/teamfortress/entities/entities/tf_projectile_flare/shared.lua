-- Flare

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"

PrecacheParticleSystem("flaregun_trail_red")
PrecacheParticleSystem("flaregun_trail_blue")
PrecacheParticleSystem("flaregun_crit_red")
PrecacheParticleSystem("flaregun_crit_blue")
PrecacheParticleSystem("flaregun_destroyed")

ENT.IsTFWeapon = true

ENT.MannMelter = false

function ENT:InitEffects()
	local effect = "flaregun"
	
	if self.critical then
		effect = effect.."_crit_"
	else
		effect = effect.."_trail_"
	end
	
	effect = effect..ParticleSuffix(GAMEMODE:EntityTeam(self:GetOwner()))
	
	if self.MannMelter == true then
		
		ParticleEffectAttach( "drg_manmelter_projectile", PATTACH_ABSORIGIN_FOLLOW, self, 0 )

	else
		
		ParticleEffectAttach(effect, PATTACH_ABSORIGIN_FOLLOW, self, 0)

	end
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

ENT.ExplosionSound = "weapons/flare_detonator_explode.wav"

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
	
	if self.MannMelter == true then
		
		self:SetMaterial("Models/effects/vol_light001")

	end

	self:SetLocalVelocity(self:GetForward() * (self.Force or 1650))
	self:SetGravity(0.3)
	
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
	if ent:IsNPC() or ent:IsPlayer() then
		self:EmitSound("player/pl_impact_flare"..math.random(1,3)..".wav", 85, 100)
	else
		self:EmitSound("physics/concrete/concrete_impact_flare"..math.random(1,4)..".wav", 85, 100)
	end
	
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
	
	if ent:IsFlammable() then
		GAMEMODE:IgniteEntity(ent, self, owner, 10)
	end
	
	self:SetLocalVelocity(Vector(0,0,0))
	self:SetMoveType(MOVETYPE_NONE)
	self:SetNotSolid(true)
	self:SetNoDraw(true)
	self:Fire("kill", "", 0.1)
end


function ENT:DoExplosion()
	self.Touch = nil
	
	local effect, angle

	if self.Nuke then
		self:EmitSound(self.ExplosionSoundNuke)
		effect = "cinefx_goldrush"
		angle = Angle(0,self:GetAngles().y, 0)
		
		local explosion = ents.Create("info_particle_system")
		explosion:SetKeyValue("effect_name", effect)
		explosion:SetKeyValue("start_active", "1")
		explosion:SetPos(self:GetPos()) 
		explosion:SetAngles(self:GetAngles())
		explosion:Spawn()
		explosion:Activate() 
		
		explosion:Fire("Kill", "", 5)
	else
		--[[if self.FastRocket then
			self:EmitSound(self.ExplosionSoundFast)
		else]]
			self:EmitSound(self.ExplosionSound, 120)
		--end
		
		local flags = 0
		
		if self:WaterLevel()>0 then
			flags = bit.bor(flags, 1)
		end
		
		local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetAttachment(flags)
		util.Effect("tf_explosion", effectdata, true, true)
	end
	
	local owner = self:GetOwner()
	if not owner or not owner:IsValid() then owner = self end
	
	--local damage = self:CalculateDamage(owner:GetPos()+Vector(0,0,1))
	local range = 20
	if self.ExplosionRadiusMultiplier and self.ExplosionRadiusMultiplier>1 then
		range = range * self.ExplosionRadiusMultiplier
	end
	--[[if self.FastRocket then
		range = range * 0.4
	end]]
	
	--self.ResultDamage = damage
	
	if self.Nuke then
		--util.BlastDamage(self, owner, self:GetPos(), range*6, damage*6)
		util.BlastDamage(self, owner, self:GetPos(), range*6, 100)
	else
		--util.BlastDamage(self, owner, self:GetPos(), range, damage)
		util.BlastDamage(self, owner, self:GetPos(), range*1, 50)
	end
	
	for k,v in ipairs(ents.FindInSphere(self:GetPos(), 80)) do
		if v:Health() >= 0 then
			GAMEMODE:IgniteEntity(v, self, owner, 10)
		end
	end
	
	self:Remove()
end

function ENT:Touch(ent)
	if ent:IsSolid() then
		self:Hit(ent)
	end
end

end
