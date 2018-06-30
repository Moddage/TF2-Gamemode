
EFFECT.LifeTime = 0.5

EFFECT.Model = "models/effects/sentry1_muzzle/sentry1_muzzle.mdl"

EFFECT.SineStart = 70
EFFECT.SineEnd = 180

EFFECT.RenderGroup = RENDERGROUP_BOTH

function EFFECT:Init(data)
	local ent = data:GetEntity()
	
	self.Entity:SetModel(self.Model)
	self.Entity:SetPos(ent:GetPos())
	self.Entity:SetAngles(ent:GetAngles())
	self.Entity:SetParent(ent)
	self.Entity:SetColor(255,255,255,255)
	self.Entity:SetRenderMode(RENDERMODE_GLOW)
	
	self.Parent = ent
	self.NextDeath = CurTime() + self.LifeTime
end

function EFFECT:Think()
	if IsValid(self.Parent) and self.NextDeath then
		return CurTime()<self.NextDeath
	end
	return false
end

function EFFECT:Render()
	local diff = 1 - ((self.NextDeath - CurTime()) / self.LifeTime)
	local size = math.sin(math.rad(Lerp(diff, self.SineStart, self.SineEnd)))
	
	local att = self.Parent:LookupAttachment("muzzle")
	if att<0 then return end
	
	att = self.Parent:GetAttachment(att)
	
	self.Entity:SetModelScale(Vector(size, size, size))
	self.Entity:SetPos(att.Pos)
	self.Entity:SetAngles(att.Ang)
	--TEST:SetupBones()
	render.UpdateRefractTexture()
	self.Entity:DrawModel(128)
end
