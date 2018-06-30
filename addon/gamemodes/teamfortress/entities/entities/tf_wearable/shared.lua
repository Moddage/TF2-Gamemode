
DEFINE_BASECLASS( "base_gmodentity" )

ENT.IsTFWearableItem = true

tf_item.InitializeAsBaseItem(ENT)
ENT.SetupDataTables0 = ENT.SetupDataTables

function ENT:SetupDataTables()
	self:SetupDataTables0()
	self:DTVar("Int", 1, "ItemTint")
end

function ENT:GetItemTint(t)
	return self.dt.ItemTint
end

if SERVER then

AddCSLuaFile("shared.lua")

function ENT:SetItemTint(t)
	self.dt.ItemTint = t
end

end

if CLIENT then

function ENT:Think()
	if self:GetOwner() ~= LocalPlayer() or LocalPlayer():ShouldDrawLocalPlayer() then
		if self.ShadowCreated ~= true then
			self.ShadowCreated = true
			self:CreateShadow()
		end
	else
		if self.ShadowCreated ~= false then
			self.ShadowCreated = false
			self:DestroyShadow()
		end
	end
end

function ENT:Draw()
	if self:GetOwner() ~= LocalPlayer() or LocalPlayer():ShouldDrawLocalPlayer() then
		self:StartVisualOverrides()
		self:StartItemTint(self:GetItemTint())
		self:GetOwner().RenderingWorldModel = true
		self:DrawModel()
		self:GetOwner().RenderingWorldModel = false
		self:EndItemTint()
		self:EndVisualOverrides()
	end
end

-- Called when the player is ragdolled or gibbed (if gibbed, rag = NULL)
function ENT:SetupPlayerRagdoll(rag)
	local item = self:GetItemData()
	
	self.CheckUpdateItem = nil
	self:ClearParticles()
	
	if not self.Model or not util.IsValidModel(self.Model) then return end
	
	local effectdata = EffectData()
	effectdata:SetEntity(self)
	
	if item.drop_type == "drop" then
		local mat = self:GetBoneMatrix(0)
		
		-- Spawn a hat gib
		effectdata:SetMagnitude(GIB_HAT)
		if mat then
			effectdata:SetOrigin(mat:GetTranslation())
			effectdata:SetAngles(mat:GetAngles())
		else
			effectdata:SetOrigin(self:GetOwner():GetPos())
			effectdata:SetAngles(self:GetOwner():GetAngles())
		end
		effectdata:SetNormal(Vector(0,0,0.8))
		effectdata:SetRadius(0.8)
		util.Effect("tf_gib", effectdata)
	else
		if IsValid(rag) then
			-- This hat doesn't drop, attach it to the player's ragdoll
			util.Effect("tf_hat_attached", effectdata)
		end
	end
end

end

function ENT:Initialize()
	self.Owner = self:GetOwner()
	self:AddToPlayerItems()
		
	local item = self:GetItemData()
	
	if item.model_player then
		if item.model_player == "" then
			self.Model = nil
		else
			self.Model = item.model_player
		end
	elseif item.model_player_per_class and item.model_player_per_class[self:GetOwner():GetPlayerClass()] then
		self.Model = item.model_player_per_class[self:GetOwner():GetPlayerClass()]
	end
	
	if SERVER then
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:SetParent(self:GetOwner())
		
		if self.Model then
			self:SetModel(self.Model)
			self:SetKeyValue("effects", "1")
			
			if item.set_sequence_to_class then
				self:AddEffects(EF_NOINTERP)
				self:ResetSequence(self:LookupSequence(self.Owner:GetPlayerClass()))
			end
		else
			self:SetNoDraw(true)
			self:DrawShadow(false)
		end
	end
end

function ENT:OnRemove()
	self:RemoveFromPlayerItems()
end

function ENT:OnOwnerDeath()
	self.Dead = true
	self:SetNoDraw(true)
	self:DrawShadow(false)
	SafeRemoveEntityDelayed(self, 1)
end

hook.Add("DoPlayerDeath", "DetachPlayerHat", function(pl)
	for _,v in pairs(pl:GetTFItems()) do
		if v.OnOwnerDeath then
			v:OnOwnerDeath()
		end
	end
end)
