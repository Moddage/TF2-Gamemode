ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize()
end

function ENT:InitPostEntity()
	print(self)
	self.CapturePoint = ents.FindByName(self.Properties.area_cap_point or "")[1] or NULL
	
	if IsValid(self.CapturePoint) then
		self.CapturePoint.TriggerEntity = self
		self.CapturePoint.TeamCanCap = {
			[2]=(self.Properties.team_cancap_2==1),
			[3]=(self.Properties.team_cancap_3==1),
		}
	end
	
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

function ENT:AcceptInput(name, activator, caller, data)
	
end

function ENT:StartTouch(ent)
	if IsValid(self.CapturePoint) and ent:IsPlayer() then
		if ent.CurrentControlPoint ~= self.CapturePoint.ID then
			ent.CurrentControlPoint = self.CapturePoint.ID
			umsg.Start("TF_EnterControlPoint", ent)
				umsg.Char(ent.CurrentControlPoint)
			umsg.End()
		end
	end
end

function ENT:EndTouch(ent)
	if IsValid(self.CapturePoint) and ent:IsPlayer() then
		if ent.CurrentControlPoint == self.CapturePoint.ID then
			ent.CurrentControlPoint = -1
			umsg.Start("TF_ExitControlPoint", ent)
			umsg.End()
		end
	end
end
