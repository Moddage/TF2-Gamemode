ENT.Type = "ai"    
ENT.Base = "base_entity"    
 
ENT.IsReviveMark = true 

ENT.AutomaticFrameAdvance = true

-- The obj_anim entity attached to this building can act as a second datatable just in case we run out of datatable slots
function ENT:CallFromModelEntity(func, default, ...)
	if not self.Model and CLIENT then
		for _,v in pairs(ents.FindByClass("obj_anim")) do
			if v:GetOwner() == self then
				self.Model = v
			end
		end
	end
	
	if IsValid(self.Model) and self.Model[func] then
		return self.Model[func](self.Model, ...)
	else
		return default
	end
end


function ENT:GetVictim()
	return self:CallFromModelEntity("GetVictim", NULL)
end

function ENT:SetVictim(b)
	self:CallFromModelEntity("SetVictim", nil, b)
end
