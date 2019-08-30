
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

ENT.NumLevels = 3
ENT.Levels = {
{Model("models/buildables/teleporter.mdl"), Model("models/buildables/teleporter_light.mdl")},
{Model("models/buildables/teleporter.mdl"), Model("models/buildables/teleporter_light.mdl")},
{Model("models/buildables/teleporter.mdl"), Model("models/buildables/teleporter_light.mdl")},
}
ENT.IdleSequence = "running"
ENT.DisableDuringUpgrade = false
ENT.NoUpgradedModel = true

ENT.Sound_Ready = Sound("Building_Teleporter.Ready")
ENT.Sound_Send = Sound("Building_Teleporter.Send")
ENT.Sound_Receive = Sound("Building_Teleporter.Receive")

ENT.Sound_Spin1 = Sound("Building_Teleporter.SpinLevel1")
ENT.Sound_Spin2 = Sound("Building_Teleporter.SpinLevel2")
ENT.Sound_Spin3 = Sound("Building_Teleporter.SpinLevel3")

ENT.Sound_Explode = Sound("Building_Teleporter.Explode")

--ENT.Sound_DoneBuilding = Sound("Building_Sentrygun.Built")

ENT.TeleportDelay = 1

ENT.RechargeTime = 10
ENT.MinRechargingSpinSpeed = 0.2

ENT.Acceleration = 0

ENT.Spawnpoint = false

ENT.Sapped = false

ENT.Gibs = {
Model("models/buildables/Gibs/teleporter_gib1.mdl"),
Model("models/buildables/Gibs/teleporter_gib2.mdl"),
Model("models/buildables/Gibs/teleporter_gib3.mdl"),
Model("models/buildables/Gibs/teleporter_gib4.mdl"),
}

ENT.Accelerations = {
	{acc=0.003, dec=0.002},
}

function ENT:SetAcceleration(a)
	self.Acceleration = a
end

function ENT:OnStartBuilding()
end

function ENT:PostEnable(laststate)
	if laststate == 1 then
		for _,v in pairs(ents.FindByClass("obj_teleporter")) do
			if v ~= self and v:GetBuilder() == self:GetBuilder() and v:GetState() == 3 and not IsValid(v:GetLinkedTeleporter()) then
				if (self:IsEntrance() and v:IsExit()) or (self:IsExit() and v:IsEntrance()) then
					self:SetLinkedTeleporter(v)
					v:SetLinkedTeleporter(self)
					self:OnLink(v)
					v:OnLink(self)
				end
			end
		end
		
		self.SpinSpeed = 0
		self:SetPlaybackRate(0)
	end
	if self.Spawnpoint == true then
		self:SetLinkedTeleporter(self)
		self:OnLink(self)
		self.SpinSpeed = 0
		self:SetPlaybackRate(0)
		for k,v in pairs(player.GetAll()) do
			if !v:IsFriendly(self) then
				v:SendLua([[surface.PlaySound("vo/announcer_mvm_eng_tele_activated0"..math.random(1,4)..".mp3")]])
			end
			v:SendLua([[surface.PlaySound("mvm/mvm_tele_activate.wav")]])
		end
	end
end

function ENT:OnLink(ent)
	if self.Spin_Sound then
		self.Spin_Sound:Stop()
	end
	self.Spin_Sound = CreateSound(self, self.Sound_Spin1)
	self.Spin_Sound:Play()
	
	self:SetAcceleration(0.005)
	self:SetChargePercentage(1)

end

function ENT:OnUnlink(ent)
	if self.Spin_Sound then
		self.Spin_Sound:Stop()
		self.Spin_Sound = nil
	end
	
	self:SetAcceleration(-0.005)
end

function ENT:OnStartUpgrade()
	if IsValid(self:GetLinkedTeleporter()) then
		self:SetChargePercentage(1)
		
		if self.Spin_Sound then
			self.Spin_Sound:Stop()
		end
		
		if self:GetLevel()==2 then
			self.Spin_Sound = CreateSound(self, self.Sound_Spin2)
			self.Spin_Sound:Play()
		elseif self:GetLevel()==3 then
			self.Spin_Sound = CreateSound(self, self.Sound_Spin3)
			self.Spin_Sound:Play()
		end
	end
end

function ENT:GetExitPosition()
	local att = self:GetAttachment(self:LookupAttachment("centre_attach"))
	return att.Pos + 2*vector_up
end

function ENT:Teleport(pl)
	if not self:IsEntrance() then return end
	local exit = self:GetLinkedTeleporter()
	if not IsValid(exit) then return end
	
	self:EmitSound(self.Sound_Send)
	
	self:SetChargePercentage(0)
	self.SpinSpeed = 0.9
	self:SetAcceleration(-0.002)
	self.NextRecharge = CurTime() + self.RechargeTime
	self.NextRestartMotor = CurTime() + 0.5 * self.RechargeTime
	
	exit.SpinSpeed = 0.9
	exit:SetAcceleration(-0.002)
	exit.NextRestartMotor = CurTime() + 0.5 * self.RechargeTime
	if pl:IsPlayer() then
		pl:SetFOV(50, 0.7)
		ParticleEffect("teleportedin_red", self:GetPos(), self:GetAngles(), pl)
		pl:ScreenFade( SCREENFADE.OUT, Color( 255, 255, 255, 150 ), 0.5, 0.65 )
		timer.Simple(0.7, function()
			pl:SetFOV(0, 1.5)
		end)
	end
	timer.Simple(0.6, function()
		pl:SetPos(exit:GetExitPosition())
		ParticleEffect("teleportedin_red", exit:GetPos(), exit:GetAngles(), pl)
		exit:EmitSound(self.Sound_Receive)
		local y = self:GetAngles().y
		if pl:IsPlayer() then
			local ang = pl:EyeAngles()
			ang.y = y
			pl:SetEyeAngles(ang)
			umsg.Start("TFTeleportEffect", pl)
			umsg.End()
		else
			local ang = pl:GetAngles()
			ang.y = y
			pl:SetAngles(ang)
		end
	end)
	self.DoneInitialWarmup = true
end

function ENT:OnThinkActive()
	if self:IsEntrance() and IsValid(self:GetLinkedTeleporter()) then
		self:SetBodygroup(2, 1)
		self:SetPoseParameter("direction", self:GetAngles().y-(self:GetPos()-self:GetLinkedTeleporter():GetPos()):Angle().y)
		self.Model:SetBodygroup(2, 1)
		self.Model:SetPoseParameter("direction", self:GetAngles().y-(self:GetPos()-self:GetLinkedTeleporter():GetPos()):Angle().y)
	else
		self:SetBodygroup(2, 0)
		self.Model:SetBodygroup(2, 0)
	end
	
	if self.NextRecharge then
		local r = math.Clamp(1 - (self.NextRecharge - CurTime()) / self.RechargeTime, 0, 1)
		self:SetChargePercentage(r)
		if r == 1 then
			self.NextRecharge = nil
			self.SpinSpeed = 1
		end
	end
	
	if self.NextRestartMotor and CurTime() >= self.NextRestartMotor then
		self:SetAcceleration(0.003)
		self.NextRestartMotor = nil
	end
	
	self.SpinSpeed = math.Clamp(self.SpinSpeed + self.Acceleration, 0, 1)
	self:SetPlaybackRate(self.SpinSpeed)
	if self.DoneInitialWarmup and self.Spin_Sound then
		self.Spin_Sound:ChangePitch(math.Clamp(100*self.SpinSpeed, 1, 100), 0)
	end
	
	if self.SpinSpeed == 1 then
		self:SetBodygroup(1,1)
		self.DoneInitialWarmup = true
	else
		self:SetBodygroup(1,0)
	end
	
	local ready = self:IsReady()
	if ready ~= self.LastReady then
		if ready then
			self:EmitSound(self.Sound_Ready)
			self.Clients = {}
		end
		self.LastReady = ready
	end
	
	if ready and self:IsEntrance() then
		local pos = self:GetPos()
		local teleported = false
		
		for _,v in pairs(self.Clients) do
			v.removeme = true
		end
		
		for _,pl in pairs(ents.FindInBox(pos + Vector(-10, -10, 0), pos + Vector(10, 10, 30))) do
			if pl:IsTFPlayer() and self:IsFriendly(pl) and not pl:IsBuilding() and (pl:GetMoveType()==MOVETYPE_WALK or pl:GetMoveType()==MOVETYPE_STEP) then
				if not self.Clients[pl] then
					self.Clients[pl] = {starttime = CurTime()}
				else
					self.Clients[pl].removeme = nil
					if not teleported and CurTime() - self.Clients[pl].starttime > self.TeleportDelay then
						teleported = true
						self.Clients[pl] = nil
						self:Teleport(pl)
					end
				end
			end
		end
		
		for k,v in pairs(self.Clients) do
			if v.removeme then
				self.Clients[k] = nil
			end
		end
	end
end

function ENT:OnRemove()
	if self.Spin_Sound then
		self.Spin_Sound:Stop()
	end
end
