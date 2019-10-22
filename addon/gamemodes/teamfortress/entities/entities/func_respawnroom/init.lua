ENT.Base = "base_brush"
ENT.Type = "brush"

randomscoutubertaunt = 
{
	"vo/mvm/norm/Scout_mvm_specialcompleted12.mp3",
	"vo/mvm/norm/Scout_mvm_award05.mp3", 
	"vo/mvm/norm/taunts/Scout_mvm_taunts02.mp3",
	"vo/mvm/norm/taunts/Scout_mvm_taunts09.mp3"
}	
randomsoldierubertaunt = 
{
	"vo/mvm/norm/taunts/Soldier_mvm_taunts05.mp3",
	"vo/mvm/norm/taunts/Soldier_mvm_taunts11.mp3", 
	"vo/mvm/norm/taunts/Soldier_mvm_taunts21.mp3",
	"vo/mvm/norm/taunts/Soldier_mvm_taunts06.mp3",
	"vo/mvm/norm/taunts/Soldier_mvm_taunts15.mp3",
	"vo/mvm/norm/taunts/Soldier_mvm_taunts04.mp3",
	"vo/mvm/norm/taunts/Soldier_mvm_taunts12.mp3"
}		
randomdemomanubertaunt = 
{
	"vo/mvm/norm/taunts/demoman_mvm_taunts01.mp3",
	"vo/mvm/norm/taunts/demoman_mvm_taunts07.mp3",
	"vo/mvm/norm/taunts/demoman_mvm_taunts09.mp3",
	"vo/mvm/norm/taunts/demoman_mvm_taunts15.mp3",
}
		
randompyroubertaunt = 
{
	"vo/mvm/norm/Pyro_mvm_specialcompleted01.mp3",
	"vo/mvm/norm/Pyro_mvm_laughlong01.mp3",
}

function ENT:Initialize()
	self.Team	 = 0
	self.Players = {}
	self:SetTrigger(true)
end

function ENT:KeyValue(key,value)

	if ( key == "teamnum" ) then
		self.Team = tonumber(value)
		return false
	end
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() and ent:Team() == TEAM_BLU then
		self.Players[ent] = -1
		print(self.Team) 
		if ent:Team() == TEAM_BLU and ent:GetInfoNum("tf_robot", 0) == 1 then  
			timer.Create("LoopGod", 0.001, 0, function()
				if self:GetName() == "red_respawnroom1" or self:GetName() == "red_respawnroom2" then
					ent:TakeDamage(50000)
					timer.Simple(0.3, function()
						ent:EmitSound("vo/engineer_no0"..math.random(1,3)..".mp3", 80, 100)
					end)
				else
					ent:SetSkin(3)
					ent:GodEnable()
				end
			end)
		end 
		if ent:Team() == TEAM_BLU and ent:IsBot() and GetConVar("tf_botbecomerobots"):GetInt() == 1 then 
			timer.Create("LoopGod", 0.001, 0, function()
				if self:GetName() == "red_respawnroom1" or self:GetName() == "red_respawnroom2" then
					ent:TakeDamage(50000)
					timer.Simple(0.3, function()
						ent:EmitSound("vo/engineer_no0"..math.random(1,3)..".mp3", 80, 100)
					end)
				else
					ent:SetSkin(3)
					ent:GodEnable()
				end
			end)
		end
	end
end

function ENT:EndTouch(ent)
	if ent:IsPlayer() then
		self.Players[ent] = nil
		if ent:Team() == TEAM_BLU and ent:GetInfoNum("tf_robot", 0) == 1 and ent:Alive() then
			timer.Stop("LoopGod")
			ent:GodDisable() 
			if ent:GetPlayerClass() == "scout" then
				ent:EmitSound(table.Random(randomscoutubertaunt), 80, 100, 1, CHAN_VOICE )
			elseif ent:GetPlayerClass() == "soldier" then
				ent:EmitSound(table.Random(randomsoldierubertaunt), 80, 100, 1, CHAN_VOICE 	)
			elseif ent:GetPlayerClass() == "pyro" then
				ent:EmitSound(table.Random(randompyroubertaunt), 80, 100, 1, CHAN_VOICE 	)
			elseif ent:GetPlayerClass() == "demoman" then
				ent:EmitSound(table.Random(randomdemomanubertaunt), 80, 100, 1, CHAN_VOICE 	)
			end
			ent:SetSkin(1)
		end
		if ent:Team() == TEAM_BLU and string.find(game.GetMap(), "mvm_") and ent:Alive() then
			timer.Stop("LoopGod")
			ent:GodDisable() 
			if ent:GetPlayerClass() == "scout" then
				ent:EmitSound(table.Random(randomscoutubertaunt), 80, 100, 1, CHAN_VOICE )
			elseif ent:GetPlayerClass() == "soldier" then
				ent:EmitSound(table.Random(randomsoldierubertaunt), 80, 100, 1, CHAN_VOICE 	)
			elseif ent:GetPlayerClass() == "pyro" then
				ent:EmitSound(table.Random(randompyroubertaunt), 80, 100, 1, CHAN_VOICE 	)
			elseif ent:GetPlayerClass() == "demoman" then
				ent:EmitSound(table.Random(randomdemomanubertaunt), 80, 100, 1, CHAN_VOICE 	)
			end
			ent:SetSkin(1)
		end
	end
end