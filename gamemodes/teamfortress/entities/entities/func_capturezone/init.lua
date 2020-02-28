ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize()
	local pos = Vector(0, 0, 0)
	local mins, maxs = self:WorldSpaceAABB() -- https://forum.facepunch.com/gmoddev/lmcw/Brush-entitys-ent-GetPos/1/#postdwfmq
	pos = (mins + maxs) * 0.5

	self.Team = self.Team or 0
	self.TeamNum = self.TeamNum or 0
	self.Pos = pos
	SetGlobalFloat("tf_ctf_red", 0)
	SetGlobalFloat("tf_ctf_blu", 0)
	--SetGlobalFloat("tf_ctf_red_lastcap", CurTime() - 120)
	--SetGlobalFloat("tf_ctf_blu_lastcap", CurTime() - 120)
end

function ENT:KeyValue(key,value)
	key = string.lower(key)
	
	if key=="teamnum" then
		local t = tonumber(value)
		
		if t==0 then
			self.TeamNum = 0
		elseif t==2 then
			self.TeamNum = TEAM_RED
		elseif t==3 then
			self.TeamNum = TEAM_BLU
		end

		self.Team = tonumber(value)
	end
	print(key, value, tonumber(value), self.Team)
end

function ENT:StartTouch(ply)
	for _,v in pairs(ents.FindByClass("item_teamflag")) do
		--print(self.Team, v.te, self.Pos:Distance(ply) <= 50)
		--print(self.Team ~= v.te, v.Carrier == ply, v:GetPos():Distance(ply:GetPos()) <= 50)
		if v.Carrier==ply and self.Team ~= v.te and v.Prop:GetPos():Distance(ply:GetPos()) <= 100 then
			v:Capture()
			--team.AddScore(v.TeamNum, 1)
			if v.TeamNum == TEAM_RED then
				team.AddScore(TEAM_BLU, 1)
				--SetGlobalFloat("tf_ctf_blu", GetGlobalFloat("tf_ctf_blu") + 1)
			else
				team.AddScore(TEAM_RED, 1)
				--SetGlobalFloat("tf_ctf_red", GetGlobalFloat("tf_ctf_red") + 1)
			end

			--SetGlobalFloat("tf_ctf_red_lastcap", CurTime())
			--SetGlobalFloat("tf_ctf_blu_lastcap", CurTime())

			for _, ply in pairs(player.GetAll()) do
				if ply:Team() ~= v.TeamNum then
					ply:SendLua([[surface.PlaySound("vo/intel_teamcaptured.mp3")]])
					GAMEMODE:StartCritBoost(ply)
					timer.Simple(10, function()
						if IsValid(ply) then
							GAMEMODE:StopCritBoost(ply)
						end
					end)
				else
					ply:SendLua([[surface.PlaySound("vo/intel_enemycaptured.mp3")]])
				end
			end
		end
	end
end

function ENT:EndTouch(ent)
end