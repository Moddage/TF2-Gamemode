ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize()
--[[
	self.Brush = ents.Create("func_brush")
	self.Brush:SetPos(self:GetPos())
	self.Brush:SetAngles(self:GetAngles())
	self.Brush:SetModel(self:GetModel())
	self.Brush:Spawn()]]
end

function ENT:InitPostEntity()
	print(self)
	PrintTable(self.Properties or {})
end

function ENT:KeyValue(key,value)
	key = string.lower(key)
	
	if not self.Properties then
		self.Properties = {}
	end
	if tonumber(value) then value=tonumber(value) end
	self.Properties[key] = value
end

function ENT:Think()
	if not GAMEMODE.PostEntityDone then return end
	if GAMEMODE.PostEntityDone and not self.PostEntityDone then
		self:InitPostEntity()
		self.PostEntityDone = true
		return
	end
end
