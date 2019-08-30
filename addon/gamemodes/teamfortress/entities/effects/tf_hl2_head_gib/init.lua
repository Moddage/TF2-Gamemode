
EFFECT.LifeTime = 10
EFFECT.FadeTime = 2

local BoneList = {
	"ValveBiped.Bip01_Pelvis",
	"ValveBiped.Bip01_Spine",
	"ValveBiped.Bip01_Spine1",
	"ValveBiped.Bip01_Spine2",
	"ValveBiped.forward",
	
	"ValveBiped.Bip01_R_Clavicle",
	"ValveBiped.Bip01_R_UpperArm",
	"ValveBiped.Bip01_R_Forearm",
	"ValveBiped.Bip01_R_Hand",
	"ValveBiped.Anim_Attachment_RH",
	
	"ValveBiped.Bip01_L_Clavicle",
	"ValveBiped.Bip01_L_UpperArm",
	"ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_L_Hand",
	"ValveBiped.Anim_Attachment_LH",
	
	"ValveBiped.Bip01_R_Thigh",
	"ValveBiped.Bip01_R_Calf",
	"ValveBiped.Bip01_R_Foot",
	
	"ValveBiped.Bip01_L_Thigh",
	"ValveBiped.Bip01_L_Calf",
	"ValveBiped.Bip01_L_Foot",
	
	"ValveBiped.Bip01_R_Wrist",
	"ValveBiped.Bip01_R_Ulna",
	"ValveBiped.Bip01_L_Wrist",
	"ValveBiped.Bip01_L_Ulna",
}

local function HeadGibBuildBones(ent)
	local b, m
	
	b = ent:LookupBone("ValveBiped.Bip01_Head1")
	m = ent:GetBoneMatrix(b)
	m:SetTranslation(Vector(0,0,0))
	m:Scale(Vector(4,4,4))
	ent:SetBoneMatrix(b,m)
	
	b = ent:LookupBone("ValveBiped.Bip01_Spine4")
	m = ent:GetBoneMatrix(b)
	m:Scale(Vector(0.25,0.25,0.25))
	ent:SetBoneMatrix(b,m)
	
	local pos = ent:GetPos() + ent:GetUp() * 65
	
	for _,bone in ipairs(BoneList) do
		b = ent:LookupBone(bone)
		if b and b>=0 then
			m = ent:GetBoneMatrix(b)
			if m then
				m:Scale(Vector(0,0,0))
				m:SetTranslation(pos)
				ent:SetBoneMatrix(b, m)
			end
		end
	end
end

function EFFECT:Init(data)
	local pl = data:GetEntity()
	local pos = data:GetOrigin()
	local ang = data:GetAngles()
	
	self:SetModel("models/player/gibs/spygib007.mdl")
	--self:SetMaterial("models/wireframe")
	self:SetPos(pos)
	self:SetAngles(ang)
	self:PhysicsInit(SOLID_VPHYSICS)
	
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetCollisionBounds(Vector(-128,-128,-128), Vector(128,128,128))
	
	self.NextDeath = CurTime() + self.LifeTime
	self.Model = pl:GetModel()
end

function EFFECT:Think()
	if not self.DoneFirstThink then
		self.DoneFirstThink = true
		
		local phys = self:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:Wake()
			phys:SetVelocity(Vector(0, 0, math.Rand(200, 300)) + VectorRand() * math.Rand(0, 50))
			phys:AddAngleVelocity(Vector(math.Rand(-200,200),math.Rand(-200,200),math.Rand(-200,200)))
		end
		
		self.Ragdoll = ClientsideModel(self.Model)
		self.Ragdoll:SetNoDraw(true)
		self.Ragdoll:SetPos(self:GetPos())
		self.Ragdoll:SetAngles(self:GetAngles())
		self.Ragdoll:SetParent(self)
		self.Ragdoll.Parent = self
		--self.Ragdoll.BuildBonePositions = HeadGibBuildBones
		self.Ragdoll:AddBuildBoneHook("Head", HeadGibBuildBones)
		
		self.Ragdoll:InvalidateBoneCache()
		self.Ragdoll:SetupBones()
	end
	
	local diff = self.NextDeath - CurTime()
	
	if diff<self.FadeTime then
		local a = math.Clamp(255*diff/self.FadeTime, 0, 255)
		--self:SetColor(Color(255,255,255,a))
		self.Ragdoll:SetColor(255,255,255,a)
	end
	
	if diff<=0 then
		self.Ragdoll:Remove()
		self.Ragdoll = nil
	end
	
	return diff>0
end

function EFFECT:Render()
	if not IsValid(self.Ragdoll) then return end
	
	self.Ragdoll:SetRenderOrigin(self:GetPos() + self:GetUp() * 14)
	self.Ragdoll:DrawModel()
	--self:DrawModel()
end
