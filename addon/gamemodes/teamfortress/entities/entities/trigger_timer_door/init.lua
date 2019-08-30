ENT.Base = "base_brush"
ENT.Type = "brush"

ENT.FullyOpenGate1 = false
ENT.FullyOpenGate2 = false

function ENT:Initialize()
	self.Team = 0
	self.Players = {}
	self.Opened = false
end

function ENT:KeyValue(key,value)
	key = string.lower(key)
	
	if key=="teamnum" then
		self.Team = tonumber(value)
	elseif key=="associatedmodel" then
		self.ResupplyLockerName = value
	end
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() then
		self.Players[ent] = -1
		if ent:Team() == TEAM_BLU then
		if self:GetName() == "gate1_door_trigger" then
			if self.FullyOpenGate1 != false then return end
			for k,v in pairs(ents.FindByName("gate1_spawn_door")) do
				v:Fire("SetSpeed", "15")
				v:Fire("Open")
				for _,alarm in pairs (ents.FindByName("gate1_alarm_yellow_flash")) do
					alarm:Fire("Start")
				end
				for _,light in pairs (ents.FindByName("gate1_emergency_light")) do
					light:Fire("Skin", "3")
					light:Fire("SetAnimation", "spin")
				end
			end
			timer.Create("CloseGate0Door", 14, 1, function()
			for k,v in pairs(ents.FindByName("gate0_entrance_door")) do
				v:Fire("SetSpeed", "15")
				v:Fire("Close")
			end
			ent:EmitSound("mvm/mvm_robo_stun.wav", 0, 100)

			timer.Simple(21.519, function()
				ent:EmitSound("misc/cp_harbor_red_whistle.wav", 0, 100)
			end)
			for k,v in pairs(team.GetPlayers(2)) do
				if v:GetNWBool("Taunting") == true then return end
				if not v:IsOnGround() then return end
				if v:WaterLevel() ~= 0 then return end
				timer.Create("StunRobot100", 0.001, 1, function()
					v:DoAnimationEvent(ACT_MP_STUN_BEGIN)
					timer.Create("StunRobotloop103", 0.6, 0, function()
						timer.Create("StunRobotloop104", 0.22, 0, function()
							v:DoAnimationEvent(ACT_MP_STUN_MIDDLE)
						end)
					end)
				end)
				v:SetNWBool("Taunting", true)
				v:SetNWBool("NoWeapon", true)
				net.Start("ActivateTauntCam")
				net.Send(v)
				timer.Simple(21.519, function()
					if not IsValid(v) or (not v:Alive() and not v:GetNWBool("Taunting")) then v:Freeze(false) return end
					timer.Stop("StunRobotloop103")
					timer.Stop("StunRobotloop104")
					v:DoAnimationEvent(ACT_MP_STUN_END)
					net.Start("DeActivateTauntCam")
					net.Send(v)
					v:Freeze(false)
					v:SetNWBool("NoWeapon", false)
					v:SetNWBool("Taunting", false)
				end)
			end
			for _,alarm in pairs (ents.FindByName("gate1_alarm_yellow_flash")) do
				alarm:Fire("Stop")
			end
			for _,light in pairs (ents.FindByName("gate1_emergency_light")) do
				light:Fire("Skin", "1")
				light:Fire("SetAnimation", "idle")
			end
			for _,blockedbitch in pairs	(ents.FindByName("gate1_bot_blocker")) do
				blockedbitch:Fire("Disable")
			end
			for k,v in pairs(ents.FindByClass("info_player_bluspawn")) do
				v:Remove()
			end
			local bluspawn1 = ents.Create("info_player_bluspawn")
			bluspawn1:SetPos(Vector(1848.03, -2781.50, 68.03))
			bluspawn1:Spawn()
			bluspawn1:Activate()
			local bluspawn2 = ents.Create("info_player_bluspawn")
			bluspawn2:SetPos(Vector(1854.96, -2807.50, 68.03))
			bluspawn2:Spawn()
			bluspawn2:Activate()
			local bluspawn3 = ents.Create("info_player_bluspawn")
			bluspawn3:SetPos(Vector(1826.76, -2433.88, 68.03))
			bluspawn3:Spawn()
			bluspawn3:Activate()
			local bluspawn4 = ents.Create("info_player_bluspawn")
			bluspawn4:SetPos(Vector(2000.51, -2427.32, 68.03))
			bluspawn4:Spawn()
			bluspawn4:Activate()
			local bluspawn5 = ents.Create("info_player_bluspawn")
			bluspawn5:SetPos(Vector(2228.10, -2435.53, 68.03))
			bluspawn5:Spawn()
			bluspawn5:Activate()
			self.FullyOpenGate1 = true
			end)
		end
		if self:GetName() == "gate2_door_trigger" then
			if self.FullyOpenGate2 != false then return end
			for k,v in pairs(ents.FindByName("gate2_spawn_door")) do
				v:Fire("SetSpeed", "15")
				v:Fire("Open")
				for _,alarm in pairs (ents.FindByName("gate2_alarm_yellow_flash")) do
					alarm:Fire("Start")
				end
				for _,light in pairs (ents.FindByName("gate2_emergency_light")) do
					light:Fire("Skin", "3")
					light:Fire("SetAnimation", "spin")
				end
			end
			timer.Create("CloseGate1Door", 14, 1, function()
				for k,v in pairs(ents.FindByName("gate1_entrance_door")) do
					v:Fire("Close")
				end
				for _,alarm in pairs (ents.FindByName("gate2_alarm_yellow_flash")) do
					alarm:Fire("Stop")
				end
				for _,light in pairs (ents.FindByName("gate2_emergency_light")) do
					light:Fire("Skin", "1")
					light:Fire("SetAnimation", "idle")
				end
				for k,v in pairs(ents.FindByClass("info_player_bluspawn")) do
					v:Remove() 
				end
				for _,blockedbitch in pairs	(ents.FindByName("gate1_bot_blocker")) do
					blockedbitch:Fire("Enable")
				end
				for _,blockedbitch in pairs	(ents.FindByName("gate2_bot_blocker")) do
					blockedbitch:Fire("Disable")
				end
				local bluspawn6 = ents.Create("info_player_bluspawn")
				bluspawn6:SetPos(Vector(-1793.97, -1575, -3.97))
				bluspawn6:Spawn()
				bluspawn6:Activate()
				local bluspawn7 = ents.Create("info_player_bluspawn")
				bluspawn7:SetPos(Vector(-2021, -1592.87, -9.04))
				bluspawn7:Spawn()
				bluspawn7:Activate()
				local bluspawn8 = ents.Create("info_player_bluspawn")
				bluspawn8:SetPos(Vector(-2225.57, -1610.30, -35.97))
				bluspawn8:Spawn()
				bluspawn8:Activate()
				local bluspawn9 = ents.Create("info_player_bluspawn")
				bluspawn9:SetPos(Vector(-2529.72, -1522.82, -35.97))
				bluspawn9:Spawn()
				bluspawn9:Activate()
				self.FullyOpenGate2	= true
			end)
			timer.Create("OpenGate4Door", 25, 1, function()
				for k,v in pairs(ents.FindByName("gate2_fence_door")) do
					v:Fire("SetSpeed", "15")
					v:Fire("Open")
				end
				local bluspawn10 = ents.Create("info_player_bluspawn")
				bluspawn10:SetPos(Vector(-1704.85, -2347.95, -21.23))
				bluspawn10:Spawn()
				bluspawn10:Activate()
				local bluspawn11 = ents.Create("info_player_bluspawn")
				bluspawn11:SetPos(Vector(-1700.12, -2153.78, 271.94))
				bluspawn11:Spawn()
				bluspawn11:Activate()
			end)
		end
		end
	end
end

function ENT:EndTouch(ent)
	if ent:IsPlayer() then
		self.Players[ent] = nil
		if ent:Team() == TEAM_BLU then
		if self:GetName() == "gate1_door_trigger" then
			for k,v in pairs(ents.FindByName("gate1_spawn_door")) do
				if self.FullyOpenGate1 != false then return end
				timer.Stop("CloseGate0Door")
				v:Fire("SetSpeed", "15")
				v:Fire("Close")
				for _,alarm in pairs (ents.FindByName("gate1_alarm_yellow_flash")) do
					alarm:Fire("Stop")
				end
				for _,light in pairs (ents.FindByName("gate1_emergency_light")) do
					light:Fire("Skin", "1")
					light:Fire("SetAnimation", "idle")
				end
			end
		end
		if self:GetName() == "gate2_door_trigger" then
			for k,v in pairs(ents.FindByName("gate2_spawn_door")) do
				if self.FullyOpenGate2 != false then return end
				timer.Stop("CloseGate1Door")
				timer.Stop("OpenGate4Door")
				v:Fire("SetSpeed", "25")
				v:Fire("Close")
				for _,alarm in pairs (ents.FindByName("gate2_alarm_yellow_flash")) do
					alarm:Fire("Stop")
				end
				for _,light in pairs (ents.FindByName("gate2_emergency_light")) do
					light:Fire("Skin", "1")
					light:Fire("SetAnimation", "idle")
				end
			end
		end
		end
	end
end 
