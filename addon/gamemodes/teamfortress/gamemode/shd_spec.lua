if CLIENT then return end

concommand.Add("tf_spectate", function(ply, _, args)
if args[1] == "2" then ply:Spectate(OBS_MODE_CHASE) ply.SpectateMode = 2 return
elseif args[1] == "1" then ply:Spectate(OBS_MODE_IN_EYE) ply.SpectateMode = 1 return
elseif args[1] == "3" then ply:Spectate(OBS_MODE_ROAMING) ply.SpectateMode = 3 return
elseif args[1] == "-1" then ply:UnSpectate() ply:SetTeam(TEAM_RED) ply.IsSpectating = false ply:KillSilent() ply:Spawn() return end

ply:StripWeapons()

local bot = table.Random(player.GetAll())
ply:SetTeam(TEAM_SPECTATOR)
--ply:Kill()
ply:SpectateEntity(bot)
ply.IsSpectating = true
ply:SetModel("models/weapons/c_arms_animations.mdl") -- anti ragdoll on death
end)

concommand.Add("tf_spectate_respawn", function(ply, _, args)
if args[1] == "2" then ply:Spectate(OBS_MODE_CHASE) ply.SpectateMode = 2 umsg.Start("ExitFreezecam", ply) umsg.End() return
elseif args[1] == "1" then ply:Spectate(OBS_MODE_IN_EYE) ply.SpectateMode = 1 umsg.Start("ExitFreezecam", ply) umsg.End() return
elseif args[1] == "3" then ply:Spectate(OBS_MODE_ROAMING) ply.SpectateMode = 3 umsg.Start("ExitFreezecam", ply) umsg.End() return end

ply:StripWeapons()

local bot = table.Random(player.GetAll())
--ply:Kill()
ply:SpectateEntity(bot)
ply.IsSpectating = true
umsg.Start("ExitFreezecam", ply)
umsg.End()
if CLIENT then
	if LocalPlayer().LastDead then
		LocalPlayer().CurrentView = nil
		LocalPlayer().Killer = nil
		LocalPlayer().LastKillerPos = nil
	end
	LocalPlayer().FreezeCam = false
	LocalPlayer().DeathCamPos = nil
	LocalPlayer().LastDead = false
end
ply:SetModel("models/weapons/c_arms_animations.mdl") -- anti ragdoll on death
end)

hook.Add("PlayerDeath", "tf_Spectate_", function(ply)
	if ply.IsSpectating then
		ply:UnSpectate()
		ply.IsSpectating = false
		if ply:Team() == TEAM_SPECTATOR then 
			ply:SetTeam(TEAM_RED)
		end
	end
end)

hook.Add("PlayerSpawn", "tf_Spectate_", function(ply)
	ply.IsSpectating = false
	ply:UnSpectate()
end)

hook.Add("KeyPress", "tf_Spectate_", function(ply, key)
	if ply.IsSpectating and ply:Team() == TEAM_SPECTATOR then
		if key == IN_ATTACK then
			ply:ConCommand("tf_spectate")
		elseif key == IN_ATTACK2 then
			ply:ConCommand("tf_spectate")
		elseif key == IN_JUMP then
			local number = 1
			local mode = ply.SpectateMode
			if ply.SpectateMode == 1 then number = 2
			elseif ply.SpectateMode == 2 then number = 3
			elseif ply.SpectateMode == 3 then number = 1
			end
			ply:ConCommand("tf_spectate "..number)
		end
		--cmd:ClearMovement()
		--cmd:ClearButtons()
	end
end)

hook.Add("SetupPlayerVisibility", "tf_Spectate_HackyAreaPortalyFixing", function(ply)
	if IsValid(ply:GetObserverTarget()) then
		AddOriginToPVS(ply:GetObserverTarget():EyePos())
	end
end)