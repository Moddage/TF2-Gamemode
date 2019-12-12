include("sv_clientfiles.lua")
include("sv_resource.lua")
include("sv_response_rules.lua")

include("shared.lua")
include("sv_hl2replace.lua")
include("sv_gamelogic.lua")
include("sv_damage.lua")
include("sv_death.lua")
include("sv_ctf_bots.lua")
include("sv_mvm_bots_red.lua")
include("shd_gravitygun.lua")
include("sv_chat.lua")
include("shd_taunts.lua")
 
local LOGFILE = "teamfortress/log_server.txt"
file.Delete(LOGFILE)
file.Append(LOGFILE, "Loading serverside script\n")
local load_time = SysTime()

include("sv_npc_relationship.lua")
include("sv_ent_substitute.lua")

CreateConVar("grapple_distance", -1, false) 
response_rules.Load("talker/tf_response_rules.txt")
response_rules.Load("talker/demoman_custom.txt")
response_rules.Load("talker/heavy_custom.txt")

CreateConVar( "tf_use_hl_hull_size", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether or not players use the HL2 hull size found on coop." )
CreateConVar( "tf_kill_on_change_class", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether or not players will die if they change class." )
CreateConVar( "tf_flashlight", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether or not players will have a flashlight as a TF2 Class" )
CreateConVar( "tf_muselk_zombies", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Zombies")
CreateConVar( "tf_enable_revive_markers", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Enable/Disable Revive Markers" )
CreateConVar( "tf_disable_nonred_mvm", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Disable BLU and neutral" )
CreateConVar('tf_opentheorangebox', 0, FCVAR_ARCHIVE + FCVAR_SERVER_CAN_EXECUTE, 'Enables 2007 mode')
-- Quickfix for Valve's typo in tf_reponse_rules.txt
response_rules.AddCriterion([[criterion "WeaponIsScattergunDouble" "item_name" "The Force-a-Nature" "required" weight 10]])

--concommand.Add("lua_pick", function(pl, cmd, args)
--	getfenv()[args[1]] = pl:GetEyeTrace().Entity
--end)

local cvar_voteEnable = CreateConVar("hl1_coop_sv_vote_enable", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Allow voting on server")
local cvar_voteSpec = CreateConVar("hl1_coop_sv_vote_allowspectators", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Allow spectators to vote")
local cvar_voteTime = CreateConVar("hl1_coop_sv_vote_time", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY})

local sndVoteStart = "ambient/alarms/warningbell1.wav"
local sndVotePassed = "friends/friend_join.wav"
local sndVoteFailed = "buttons/button10.wav"
local sndVote = "buttons/blip1.wav"

local voteTypes = {
	["map"] = "<mapname>",
	["kick"] = "<nickname>",
	["kickid"] = "<userid>",
	["skill"] = "<number 1-4>",
	["restart"] = "",
	["speedrunmode"] = "",
	["survivalmode"] = "",
	["crackmode"] = "",
	["skiptripmines"] = ""
}

local voteExecuteDelay = 3
local voteExecuteTime = 0

local function VoteEnd(result, nomsg)
	if result == 1 then
		local voteType = GetGlobalString("VoteType")
		if voteType == "map" then
			timer.Simple(voteExecuteDelay, function()
				local maptochange = GetGlobalString("VoteName")
				RunConsoleCommand("changelevel", maptochange)
				GAMEMODE:TransitPlayers(maptochange)
			end)
		elseif voteType == "kick" then
			timer.Simple(voteExecuteDelay, function()
				RunConsoleCommand("kick", GetGlobalString("VoteName"))
			end)
		elseif voteType == "kickid" then
			timer.Simple(voteExecuteDelay, function()
				game.KickID(GetGlobalString("VoteName"), "Kicked by vote")
			end)
		end
		if !nomsg then ChatMessage("#vote_votepassed", 3) end
		net.Start("PlayClientSound")
		net.WriteString(sndVotePassed)
		net.Broadcast()
		voteExecuteTime = CurTime() + voteExecuteDelay
	else
		if !nomsg then ChatMessage("#vote_votefailed", 3) end
		net.Start("PlayClientSound")
		net.WriteString(sndVoteFailed)
		net.Broadcast()
	end
	GAMEMODE:SetGlobalBool("Vote", false)
	for k, v in pairs(player.GetAll()) do
		v.voteOption = nil
	end
end

local function VoteCancel(ply)
	if IsValid(ply) and !ply:IsAdmin() then return end
	if !GetGlobalBool("Vote") then
		if IsValid(ply) then
			ply:ChatMessage("#vote_noactivevote", 3)
		else
			print("No vote in progress")
		end
		return
	end
	VoteEnd(0, true)
	if IsValid(ply) then
		ChatMessage(ply:Nick() .. " " .. "#vote_plyvetoed", 3)
	else
		ChatMessage("#vote_canceled", 3)
	end
end

local nextCheck = RealTime()
function GM:VoteThink()	
	if GetGlobalBool("Vote") then
		if nextCheck and nextCheck <= RealTime() then
			local plyCount = (cvar_voteSpec:GetBool() or GetGlobalBool("FirstLoad")) and player.GetCount() or team.NumPlayers(TEAM_COOP)
			if plyCount == 0 then
				VoteCancel()
				return
			end
			local yes, no = GetGlobalInt("VoteNumYes"), GetGlobalInt("VoteNumNo")
			local total = yes + no
			if (GetGlobalFloat("VoteTime") - CurTime()) <= 0 then
				if yes > no and total > 1 then
					VoteEnd(1)
				else				
					VoteEnd()
				end
			elseif yes > math.floor(plyCount / 2) then			
				VoteEnd(1)
			elseif no >= yes and no >= math.ceil(plyCount / 2) then
				VoteEnd()
			end
			
			nextCheck = RealTime() + .5
		end
	end
end

local function RemovePlayerVote(ply)
	local vote = ply.voteOption
	if vote then
		if vote == 1 then
			SetGlobalInt("VoteNumYes", GetGlobalInt("VoteNumYes") - 1)
		else
			SetGlobalInt("VoteNumNo", GetGlobalInt("VoteNumNo") - 1)
		end
		ply.voteOption = nil
	end
end

function GM:VotePlayerJoinedSpectators(ply)
	if GetGlobalBool("Vote") and !cvar_voteSpec:GetBool() then
		RemovePlayerVote(ply)
	end
end

function GM:VotePlayerDisconnected(ply)
	if GetGlobalBool("Vote") then
		RemovePlayerVote(ply)
		
		local voteType = GetGlobalString("VoteType")
		local voteName = GetGlobalString("VoteName")
		if voteType == "kick" then
			if ply:Nick() == voteName then
				local ip = ply:IPAddress()
				RunConsoleCommand("addip", 1, ip)
				VoteEnd(0, true)
			end
		elseif voteType == "kickid" then
			if ply == Player(voteName) then
				local ip = ply:IPAddress()
				RunConsoleCommand("addip", 1, ip)
				VoteEnd(0, true)
			end
		end
	end
end

local function PrintHelpText(ply)
	ply:PrintMessage(HUD_PRINTTALK, "Usage:")
	for k, v in SortedPairs(voteTypes) do
		ply:PrintMessage(HUD_PRINTTALK, k.." "..v)
	end
end

concommand.Add("callvote", function(ply, cmd, args)
	if GetGlobalBool("FirstWaiting") then return end
	if !cvar_voteEnable:GetBool() then
		ply:ChatMessage("#vote_votedisabled", 3)
		return
	end
	if !cvar_voteSpec:GetBool() then -- if spectators cannot vote
		if ply:Team() == TEAM_SPECTATOR then
			ply:ChatMessage("#vote_speccantcall", 3)
			return
		end
		if !GetGlobalBool("FirstLoad") and team.NumPlayers(TEAM_COOP) == 0 then
			ply:ChatMessage("#vote_cannotnow", 3)
			return
		end
	end 
	if !ply:IsAdmin() and ply.NextVote and ply.NextVote > CurTime() then
		ply:ChatMessage("#vote_voteagain".." "..math.ceil(ply.NextVote - CurTime()).."s", 3)
		return
	end

	if voteTypes[args[1]] then
		if GetGlobalBool("Vote") or voteExecuteTime > CurTime() then
			ply:ChatMessage("#vote_alreadyactive", 3)
			return
		end
		
		if args[1] == "map" and args[2] then
			local mapcheck = file.Exists("maps/"..args[2]..".bsp", "GAME")
			if !mapcheck then
				ply:PrintMessage(HUD_PRINTTALK, "Not a valid map!")
				return
			end
			SetGlobalString("VoteName", args[2])
		elseif args[1] == "kick" and args[2] then
			local playercheck = player.GetAll()
			local notvalid
			for k, v in pairs(playercheck) do
				if string.lower(v:Nick()) != string.lower(args[2]) then
					notvalid = true
				else
					--if v:IsSuperAdmin() or v:IsAdmin() then
						--ply:ChatMessage("Fuck you")
						--return
					--end
					notvalid = nil
					break
				end
			end
			if notvalid then
				ply:PrintMessage(HUD_PRINTTALK, "Not a valid player!")
				return
			else
				SetGlobalString("VoteName", args[2])
			end
		elseif args[1] == "kickid" and args[2] then
			local plyid = tonumber(args[2])
			local playercheck = Player(plyid)
			if IsValid(playercheck) then
				--if playercheck:IsAdmin() then
					--ply:ChatMessage("Fuck you")
					--return
				--end
				SetGlobalString("VoteName", plyid)
			else
				ply:PrintMessage(HUD_PRINTTALK, "Not a valid player!")
				return
			end
		end
		GAMEMODE:SetGlobalBool("Vote", true)
		ChatMessage(ply:Nick().." ".."#vote_plycalled", 3)
		SetGlobalString("VoteType", args[1])
		SetGlobalInt("VoteNumYes", 1)
		SetGlobalInt("VoteNumNo", 0)
		GAMEMODE:SetGlobalFloat("VoteTime", CurTime() + cvar_voteTime:GetFloat())
		print(ply:Nick().." called vote: "..GetGlobalString("VoteType").." "..GetGlobalString("VoteName"))
		ply.voteOption = 1
		ply.NextVote = CurTime() + 60
		
		if player.GetCount() > 1 then
			net.Start("PlayClientSound")
			net.WriteString(sndVoteStart)
			net.Broadcast()
		end
	else
		PrintHelpText(ply)
	end
end)

local function CVote(v, ply)
	if !GetGlobalBool("Vote") then
		ply:ChatMessage("#vote_noactivevote", 3)
		return
	end
	if !cvar_voteSpec:GetBool() and ply:Team() == TEAM_SPECTATOR then
		ply:ChatMessage("#vote_speccantvote", 3)
		return
	end
	if ply.voteOption then
		ply:ChatMessage("#vote_alreadycast", 3)
		return
	end
	ply.voteOption = v
	ply:ChatMessage("#vote_votecast", 3)
	if v == 1 then
		SetGlobalInt("VoteNumYes", GetGlobalInt("VoteNumYes") + 1)
	else
		SetGlobalInt("VoteNumNo", GetGlobalInt("VoteNumNo") + 1)
	end
	
	net.Start("PlayClientSound")
	net.WriteString(sndVote)
	net.Broadcast()
end

concommand.Add("vote_yes", function(ply)
	CVote(1, ply)
end)

concommand.Add("vote_no", function(ply)
	CVote(0, ply)
end)
	
concommand.Add("vote_cancel", function(ply)
	VoteCancel(ply)
end)

concommand.Add("taunt", function(pl)
	GAMEMODE:PlayerStartTaunt(pl, ACT_DIESIMPLE, 1 )
end)

concommand.Add("select_slot", function(pl, cmd, args)
	local n = tonumber(args[1] or "")
	local w = pl:GetActiveWeapon()
	if n and w and w:IsValid() and w.OnSlotSelected then
		w:OnSlotSelected(n)
	end
end)

concommand.Add("decapme", function(pl, cmd, args)
--	pl:SetNWBool("ShouldDropDecapitatedRagdoll", true)
	pl:AddDeathFlag(DF_DECAP)
	pl:Kill()
end)

concommand.Add("tf_stripme", function(pl, cmd, args)
	pl:StripWeapons()
end)


hook.Add("PlayerSelectSpawn", "PlayerSelectTeamSpawn", function(pl)
	if !string.find(game.GetMap(), "mvm_") then
		for k,v in pairs(ents.FindByClass("info_player_redspawn"), ents.FindByClass("info_player_bluspawn")) do
			if v:IsValid() then
				local spawns1 = ents.FindByClass( "info_player_redspawn" )
				local random_entry = math.random( #spawns1 ) 
				local spawns2 = ents.FindByClass( "info_player_bluspawn" )
				local random_entry2 = math.random( #spawns2 )
				if pl:Team() == TEAM_RED or pl:Team() == TEAM_NEUTRAL then
					return spawns1[ random_entry ]
				elseif pl:Team() == TEAM_BLU then
					return spawns2[ random_entry2 ]
				end
			end
		end
	else
		for k,v in pairs( ents.FindByClass("info_player_bluspawn")) do
			if v:IsValid() then
				local spawns1 = ents.FindByClass( "info_player_bluspawn" )
				local random_entry = math.random( #spawns1 )
				if pl:Team() == TEAM_BLU then
					return spawns1[ random_entry ] 
				end
			end
		end
	end
end)

hook.Add("PlayerFootstep", "RoboStep", function( ply, pos, foot, sound, volume, rf)
	if not ply:IsHL2() and ply:GetInfoNum("tf_robot", 0) == 1 then
		if ply:GetPlayerClass() != "medic" then
			ply:EmitSound( "MVM.BotStep" ) -- Play the footsteps hunter is using
		else
			ply:EmitSound( "items/cart_rolling_"..table.Random({"stop", "start"})..".wav", 75, 100, 0.5)
		end
		return true -- Don't allow default footsteps
	end
	if not ply:IsHL2() and ply:GetInfoNum("tf_hhh", 0) == 1 then
		ply:EmitSound( "Halloween.HeadlessBossFootfalls" )
		if ply:GetInfoNum("tf_giant_robot", 0) == 1 then
			ply:EmitSound("^mvm/giant_common/giant_common_step_0"..math.random(1,8)..".wav", 150, 80)
		end
		return true -- Don't allow default footsteps
	end
	if ply:GetPlayerClass() == "tank" then
		ply:EmitSound("vj_l4d/footsteps/tank/walk/tank_walk0"..math.random(1,6)..".wav")
	end
	if not ply:IsHL2() and ply:GetInfoNum("tf_mvm_voodoo", 0) == 1 then
		if ply:GetPlayerClass() != "medic" then
			ply:EmitSound( "MVM.BotStep" ) -- Play the footsteps hunter is using
		else
			ply:EmitSound( "items/cart_rolling_"..table.Random({"stop", "start"})..".wav", 75, 100, 0.5)
		end
		return true -- Don't allow default footsteps
	end
	if not ply:IsHL2() and ply:Team() == TEAM_BLU and ply:IsBot() and GetConVar("tf_botbecomerobots"):GetInt() == 1 then
		if ply:GetPlayerClass() != "medic" then
			ply:EmitSound( "MVM.BotStep" ) -- Play the footsteps hunter is using
		else
			ply:EmitSound( "items/cart_rolling_"..table.Random({"stop", "start"})..".wav", 75, 100, 0.5)
		end
		return true -- Don't allow default footsteps
	end
	if not ply:IsHL2() and ply:GetInfoNum("tf_giant_robot", 0) == 1 then
		ply:EmitSound( "MVM.GiantHeavyStep" ) -- Play the footsteps hunter is using
		return true -- Don't allow default footsteps
	end
	if not ply:IsHL2() and ply:GetInfoNum("jakey_antlionfbii", 0) == 1 then
		ply:EmitSound( "^npc/antlion_guard/antlionguard_foot_heavy"..math.random(1,2)..".wav", 120, math.random(98, 103) ) -- Play the footsteps hunter is using
		return true -- Don't allow default footsteps
	end
	if ply:GetInfoNum("dylan_rageheavy", 0) == 1 then
		ply:EmitSound( "physics/concrete/boulder_impact_hard"..math.random(1,3)..".wav", 150, math.random(70,120) ) -- Play the footsteps hunter is using
		return true -- Don't allow default footsteps
	end
	if not ply:IsHL2() and ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 1 then
		ply:EmitSound( "MVM.GiantHeavyStep" ) -- Play the footsteps hunter is using
		return true -- Don't allow default footsteps
	end
	if not ply:IsHL2() and ply:GetInfoNum("tf_sentrybuster", 0) == 1 then
		ply:EmitSound( "MVM.SentryBusterStep" ) -- Play the footsteps hunter is using
		return true -- Don't allow default footsteps
	end
	if not ply:IsHL2() and ply:GetPlayerClass() == "merc_dm" and ply:GetInfoNum("tf_silentthirdpersonsteps", 0) == 1 then
		ply:EmitSound("npc/combine_soldier/vo/_period.wav")
		return true
	end
end)

hook.Add("PlayerHurt", "RoboIsHurt", function( ply, pos, foot, sound, volume, rf )
	local dmginfo = DamageInfo()
	if ply:Alive() and ply:GetModel() == "models/survivfix/survivor_mechanic.mdl" then
		if ply:Health() >= 50 then
			ply:EmitSound("player/survivor/voice/mechanic/hurtminor0"..math.random(1,7)..".wav")
		else
			ply:EmitSound("player/survivor/voice/mechanic/hurtcritical0"..math.random(2,5)..".wav")
		end 
	end
	if ply:GetPlayerClass() == "boomer" then
		ply:EmitSound("vj_l4d/boomer/voice/pain/boomer_painshort_0"..math.random(2,7)..".wav")
	end
	if ply:GetPlayerClass() == "tank" then
		ply:EmitSound("vj_l4d/tank/voice/pain/tank_pain_0"..math.random(1,8)..".wav")
	end
	if ply:GetPlayerClass() == "charger" then
		ply:EmitSound("charger/voice/pain/charger_pain_0"..math.random(1,6)..".wav")
	end
	

	if ply:GetPlayerClass() == "combinesoldier" then
		EmitSentence( "COMBINE_PAIN" .. math.random( 0, 3 ), ply:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
	end
	if ply:GetPlayerClass() == "metrocop" then
		EmitSentence( "METROPOLICE_PAIN" .. math.random( 0, 3 ), ply:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
	end
	if not ply:IsHL2() and ply:GetInfoNum("tf_robot", 0) == 1 then
		if ( shouldOccur ) then
			if ply:Health() <= 50 then
				if ply:GetPlayerClass() == "scout" then
					ply:EmitSound("vo/mvm/norm/scout_mvm_painsevere0"..math.random(1,6)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "soldier" then
					ply:EmitSound("vo/mvm/norm/soldier_mvm_painsevere0"..math.random(1,6)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "pyro" then
					ply:EmitSound("vo/mvm/norm/pyro_mvm_painsevere0"..math.random(1,6)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "demoman" then
					ply:EmitSound("vo/mvm/norm/demoman_mvm_painsevere0"..math.random(1,4)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "heavy" then
					ply:EmitSound("vo/mvm/norm/heavy_mvm_painsevere0"..math.random(1,3)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "engineer" then
					ply:EmitSound("vo/mvm/norm/engineer_mvm_painsevere0"..math.random(1,7)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "medic" then
					ply:EmitSound("vo/mvm/norm/medic_mvm_painsevere0"..math.random(1,4)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "sniper" then
					ply:EmitSound("vo/mvm/norm/sniper_mvm_painsevere0"..math.random(1,4)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "spy" then
					ply:EmitSound("vo/mvm/norm/spy_mvm_painsevere0"..math.random(1,5)..".mp3", 95, 100, 1, CHAN_VOICE)
				end
			else
				if ply:GetPlayerClass() == "scout" then
					ply:EmitSound("vo/mvm/norm/scout_mvm_painsharp0"..math.random(1,8)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "soldier" then
					ply:EmitSound("vo/mvm/norm/soldier_mvm_painsharp0"..math.random(1,8)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "pyro" then
					ply:EmitSound("vo/mvm/norm/pyro_mvm_painsharp0"..math.random(1,4)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "demoman" then
					ply:EmitSound("vo/mvm/norm/demoman_mvm_painsharp0"..math.random(1,7)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "heavy" then
					ply:EmitSound("vo/mvm/norm/heavy_mvm_painsharp0"..math.random(1,5)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "engineer" then
					ply:EmitSound("vo/mvm/norm/engineer_mvm_painsharp0"..math.random(1,8)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "medic" then
					ply:EmitSound("vo/mvm/norm/medic_mvm_painsharp0"..math.random(1,8)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "sniper" then
					ply:EmitSound("vo/mvm/norm/sniper_mvm_painsharp0"..math.random(1,4)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "spy" then
					ply:EmitSound("vo/mvm/norm/spy_mvm_painsharp0"..math.random(1,4)..".mp3", 95, 100, 1, CHAN_VOICE)
				end
			end
			shouldOccur = false
			timer.Simple( hurtdelay, function() shouldOccur = true end )
		end
			 
				
		ply:EmitSound( "MVM_Robot.BulletImpact" )
	end
	if not ply:IsHL2() and ply:Team() == TEAM_BLU and string.find(game.GetMap(), "mvm_") then
		if ( shouldOccur ) then
			if ply:Health() <= 50 then
				if ply:GetPlayerClass() == "scout" then
					ply:EmitSound("vo/mvm/norm/scout_mvm_painsevere0"..math.random(1,6)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "soldier" then
					ply:EmitSound("vo/mvm/norm/soldier_mvm_painsevere0"..math.random(1,6)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "pyro" then
					ply:EmitSound("vo/mvm/norm/pyro_mvm_painsevere0"..math.random(1,6)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "demoman" then
					ply:EmitSound("vo/mvm/norm/demoman_mvm_painsevere0"..math.random(1,4)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "heavy" then
					ply:EmitSound("vo/mvm/norm/heavy_mvm_painsevere0"..math.random(1,3)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "engineer" then
					ply:EmitSound("vo/mvm/norm/engineer_mvm_painsevere0"..math.random(1,7)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "medic" then
					ply:EmitSound("vo/mvm/norm/medic_mvm_painsevere0"..math.random(1,4)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "sniper" then
					ply:EmitSound("vo/mvm/norm/sniper_mvm_painsevere0"..math.random(1,4)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "spy" then
					ply:EmitSound("vo/mvm/norm/spy_mvm_painsevere0"..math.random(1,5)..".mp3", 95, 100, 1, CHAN_VOICE)
				end
			else
				if ply:GetPlayerClass() == "scout" then
					ply:EmitSound("vo/mvm/norm/scout_mvm_painsharp0"..math.random(1,8)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "soldier" then
					ply:EmitSound("vo/mvm/norm/soldier_mvm_painsharp0"..math.random(1,8)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "pyro" then
					ply:EmitSound("vo/mvm/norm/pyro_mvm_painsharp0"..math.random(1,4)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "demoman" then
					ply:EmitSound("vo/mvm/norm/demoman_mvm_painsharp0"..math.random(1,7)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "heavy" then
					ply:EmitSound("vo/mvm/norm/heavy_mvm_painsharp0"..math.random(1,5)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "engineer" then
					ply:EmitSound("vo/mvm/norm/engineer_mvm_painsharp0"..math.random(1,8)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "medic" then
					ply:EmitSound("vo/mvm/norm/medic_mvm_painsharp0"..math.random(1,8)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "sniper" then
					ply:EmitSound("vo/mvm/norm/sniper_mvm_painsharp0"..math.random(1,4)..".mp3", 95, 100, 1, CHAN_VOICE)
				elseif ply:GetPlayerClass() == "spy" then
					ply:EmitSound("vo/mvm/norm/spy_mvm_painsharp0"..math.random(1,4)..".mp3", 95, 100, 1, CHAN_VOICE)
				end
			end
			shouldOccur = false
			timer.Simple( hurtdelay, function() shouldOccur = true end )
		end
			 
				
		ply:EmitSound( "MVM_Robot.BulletImpact" )
	end
	
	if not ply:IsHL2() and ply:GetInfoNum("tf_hhh", 0) == 1 then
		ply:EmitSound( "Halloween.HeadlessBossPain" ) -- Play the footsteps hunter is using
	end

	if ply:GetPlayerClass() == "merc_dm" then
		if ( shouldOccur ) then
			if ply:Health() <= 50 then
				ply:EmitSound("vo/mercenary_painsevere0"..math.random(1,6)..".wav")
			elseif dmginfo:IsFallDamage() then
				ply:EmitSound("vo/mercenary_painsevere0"..math.random(1,6)..".wav")
			else
				ply:EmitSound("vo/mercenary_painsharp0"..math.random(1,8)..".wav")
			end
			shouldOccur = false
			timer.Simple( hurtdelay, function() shouldOccur = true end )
		end
	end
	
	
	if not ply:IsHL2() and ply:GetInfoNum("tf_mvm_voodoo", 0) == 1 then
		ply:EmitSound( "MVM_Robot.BulletImpact" )
	end
	if not ply:IsHL2() and ply:GetInfoNum("jakey_antlionfbii", 0) == 1 then
		ply:EmitSound("npc/antlion/shell_impact"..math.random(1,4)..".wav", 80, 100)
		if ( shouldOccur ) then
			ply:EmitSound( "npc/antlion_guard/antlion_guard_pain"..math.random(1,2)..".wav", 150, math.random(87, 103) )
			shouldOccur = false
			timer.Simple( hurtdelay, function() shouldOccur = true end )
		end
	end
	if ply:GetInfoNum("dylan_rageheavy", 0) == 1 then
		ply:EmitSound("vo/heavy_paincrticialdeath0"..math.random(1,3)..".mp3", 150, 100)
		if ply:GetInfoNum("tf_giant_robot", 0) == 1 then
				ply:SetModelScale(6)
				ply:EmitSound("music/stingers/hl1_stinger_song28.mp3", 0, 80)
				ply:EmitSound("music/stingers/hl1_stinger_song28.mp3", 0, 75)
		 end
	end
	if not ply:IsHL2() and ply:GetInfoNum("tf_giant_robot", 0) == 1 then
		ply:EmitSound( "MVM_Giant.BulletImpact" )
	end 
	if not ply:IsHL2() and ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 1 then
		ply:EmitSound( "MVM_Giant.BulletImpact" )
	end	
	if ply:GetPlayerClass() == "spy" then
		for k,v in pairs(ents.FindByClass("tf_weapon_invis_dringer")) do
			if v.Owner == ply and v.dt.Ready == true then
				v:StartCloaking()
				ply:CreateRagdoll()
			end
		end
	end
end)


concommand.Add("voicemenu_combine", function(pl, cmd, args)
	local a, b = tonumber(args[1]), tonumber(args[2])
	if not a or not b then return end

	if a == 0 and b == 6 then
		if pl:GetPlayerClass() == "combinesoldier" then
			EmitSentence( "COMBINE_ANSWER" .. math.random( 0, 4 ), pl:GetPos(), 1, CHAN_AUTO, 1, 95, 0, 100 )
		end
	end
	if a == 0 and b == 2 then
		if pl:GetPlayerClass() == "combinesoldier" then
			EmitSentence( "METROPOLICE_IDLE_HARASS_PLAYER1", pl:GetPos(), 1, CHAN_AUTO, 1, 95, 0, 100 )
		end
	end
	if a == 0 and b == 3 then
		if pl:GetPlayerClass() == "combinesoldier" then
			EmitSentence( "METROPOLICE_IDLE_HARASS_PLAYER0", pl:GetPos(), 1, CHAN_AUTO, 1, 95, 0, 100 )
		end
	end
	if a == 2 and b == 5 then
		if pl:GetPlayerClass() == "combinesoldier" then
			EmitSentence( "COMBINE_LAST_OF_SQUAD" .. math.random( 0, 7 ), pl:GetPos(), 1, CHAN_AUTO, 1, 95, 0, 100 )
		end
	end
	if a == 1 and b == 0 then
		if pl:GetPlayerClass() == "combinesoldier" then
			EmitSentence( "COMBINE_ALERT" .. math.random( 0, 9 ), pl:GetPos(), 1, CHAN_AUTO, 1, 95, 0, 100 )
		end
	end
	if a == 1 and b == 1 then
		if pl:GetPlayerClass() == "combinesoldier" then
			EmitSentence( "COMBINE_TAUNT" .. math.random( 0, 2 ), pl:GetPos(), 1, CHAN_AUTO, 1, 95, 0, 100 )
		end
	end
	if a == 1 and b == 2 then
		if pl:GetPlayerClass() == "combinesoldier" then
			EmitSentence( "COMBINE_QUEST" .. math.random( 0, 5 ), pl:GetPos(), 1, CHAN_AUTO, 1, 95, 0, 100 )
		end
	end
end)


hook.Add("PlayerDeath", "PlayerRobotDeath", function( ply, attacker, inflictor)
	local dmginfo = DamageInfo()
	ply:SetParent()
	for k,v in pairs(ents.FindInSphere(ply:GetPos(), 110)) do
		if v:IsPlayer() then
			v:SetParent()
		end
	end
	
	if attacker:IsPlayer() and !attacker:IsFriendly(ply) and attacker:GetPlayerClass() == "combinesoldier" then
		EmitSentence( "COMBINE_PLAYER_DEAD" .. math.random( 0, 6 ), attacker:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
	end
	
	for k,v in ipairs(team.GetPlayers(ply:Team())) do
		if v:Alive() and v:Nick() != ply:Nick() and v:GetPlayerClass() == "combinesoldier" then
			EmitSentence( "COMBINE_MAN_DOWN" .. math.random( 0, 4 ), v:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
		end
	end	
	
	for k,v in ipairs(team.GetPlayers(ply:Team())) do
		if v:Alive() and v:Nick() != ply:Nick() and v:GetPlayerClass() == "metrocop" then
			EmitSentence( "METROPOLICE_MAN_DOWN" .. math.random( 0, 3 ), v:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
		end
	end

	if ply:IsHL2() then
		if ply:GetPlayerClass() == "gmodplayer" then
			if ply:GetModel() == "models/survivfix/survivor_mechanic.mdl" then
				ply:EmitSound("player/survivor/voice/mechanic/deathscream0"..math.random(1,6)..".wav")
			elseif ply:GetModel() == "models/survivfix/survivor_namvet.mdl" then
				ply:EmitSound("player/survivor/voice/namvet/deathscream0"..math.random(1,8)..".wav")
			elseif ply:GetModel() == "models/survivfix/survivor_manager.mdl" then
				ply:EmitSound("player/survivor/voice/manager/deathscream0"..math.random(1,9)..".wav")
			elseif ply:GetModel() == "models/survivfix/survivor_biker.mdl" then
				ply:EmitSound("player/survivor/voice/biker/deathscream0"..math.random(1,9)..".wav")
			end
		end
	end
	if ply:GetPlayerClass() == "charger" then
		ply:EmitSound("charger/voice/die/charger_die_0"..math.random(1,4)..".wav")
	end
	if ply:GetPlayerClass() == "combinesoldier" then
		EmitSentence( "COMBINE_DIE" .. math.random( 0, 3 ), ply:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
	end
 
	if ply:GetPlayerClass() == "metrocop" then
		EmitSentence( "METROPOLICE_DIE" .. math.random( 0, 4 ), ply:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
	end
	
	if ply:GetPlayerClass() == "tank" then
		for k,v in ipairs(player.GetAll()) do
			v:StopSound("TankMusicLoop")
		end
		ply:EmitSound("vj_l4d/tank/voice/die/tank_death_0"..math.random(1,7)..".wav")
	end
	if not ply:IsHL2() and ply:GetInfoNum("tf_hhh", 0) == 1 then
		ply:EmitSound("Halloween.HeadlessBossDeath")
		ply:EmitSound("Halloween.HeadlessBossDying")
		
		for k,v in pairs(player.GetAll()) do
			v:SendLua([[surface.PlaySound("ui/halloween_boss_defeated_fx.wav")]])
			v:SendLua([[LocalPlayer():PrintMessage(HUD_PRINTCENTER, "The Horseless Headless Horsemann has been defeated!")]])
		end
		local blood = ents.Create("info_particle_system")
		blood:SetKeyValue( "effect_name", "halloween_boss_death" )
		blood:SetPos( ply:GetPos() )
		blood:Spawn()
		blood:Activate()
		blood:Fire( "Start", "", 0 )
		blood:Fire( "Kill", "", 0.1 )
		ply:PrecacheGibs()
		ply:GibBreakClient( Vector(math.random(1,4), math.random(1,4), math.random(1,4)) )
		ply:GetRagdollEntity():Remove()
	end
	if not ply:IsHL2() and ply:GetInfoNum("tf_sentrybuster", 0) == 1 then			
		for k,v in pairs(player.GetAll()) do
			if not v:IsFriendly(ply) and v:Alive() and not v:IsHL2() then
				if v:GetPlayerClass() == "heavy" then
					v:EmitSound("vo/heavy_mvm_sentry_buster02.mp3", 85, 100, 1, CHAN_REPLACE)
				elseif v:GetPlayerClass() == "medic" then
					v:EmitSound("vo/medic_mvm_sentry_buster02.mp3", 85, 100, 1, CHAN_REPLACE)
				elseif v:GetPlayerClass() == "soldier" then
					v:EmitSound("vo/soldier_mvm_sentry_buster02.mp3", 85, 100, 1, CHAN_REPLACE)
				elseif v:GetPlayerClass() == "engineer" then
					v:EmitSound("vo/engineer_mvm_sentry_buster02.mp3", 85, 100, 1, CHAN_REPLACE)
				end
			end
		end
	end
	if not ply:IsHL2() and ply:GetInfoNum("jakey_antlionfbii", 0) == 1 then			
		ply:EmitSound("npc/antlion_guard/antlion_guard_die"..math.random(1,2)..".wav", 120, 100)
	end
	if not ply:IsHL2() and ply:GetInfoNum("tf_merasmus", 0) == 1 then
		ply:EmitSound("Halloween.MerasmusBanish")
		ply:EmitSound("Halloween.HeadlessBossDeath")
		ply:PrecacheGibs()
		ply:GibBreakClient( Vector(math.random(1,4), math.random(1,4), math.random(1,4)) )
		ply:GetRagdollEntity():Remove()
	end
	if attacker:IsPlayer() and victim ~= attacker and attacker:GetInfoNum("tf_merasmus", 0) == 1 then
		attacker:EmitSound("Halloween.MerasmusBombTaunt")
	end
	if attacker:IsPlayer() and victim ~= attacker and attacker:GetInfoNum("tf_saxxy", 0) == 1 then
		attacker:EmitSound("SaxtonHale.KillVictim")
	end
	if attacker:IsPlayer() and victim ~= attacker and attacker:GetInfoNum("tf_hhh", 0) == 1 and victim:IsNPC() then
		attacker:EmitSound("vo/halloween_boss/knight_laugh0"..math.random(1,3)..".mp3", 95, 100)
	end
	if attacker:IsPlayer() and victim ~= attacker and attacker:GetInfoNum("tf_merasmus", 0) == 1 and victim:IsNPC() then
		attacker:EmitSound("Halloween.MerasmusBombTaunt")
	end
	if attacker:IsPlayer() and victim ~= attacker and not attacker:IsHL2() and attacker:GetInfoNum("tf_hhh", 0) == 1 then
		attacker:EmitSound("vo/halloween_boss/knight_laugh0"..math.random(1,3)..".mp3", 95, 100)
	end
	if not ply:IsHL2() and ply:Team() == TEAM_BLU and string.find(game.GetMap(), "mvm_") then
		if ply:GetPlayerClass() == "scout" then
			ply:EmitSound("vo/mvm/norm/scout_mvm_paincrticialdeath0"..math.random(1,8)..".mp3", 95, 100, 1, CHAN_VOICE)
		elseif ply:GetPlayerClass() == "soldier" then
			ply:EmitSound("vo/mvm/norm/soldier_mvm_paincrticialdeath0"..math.random(1,8)..".mp3", 95, 100, 1, CHAN_VOICE)
		elseif ply:GetPlayerClass() == "pyro" then
			ply:EmitSound("vo/mvm/norm/pyro_mvm_paincrticialdeath0"..math.random(1,4)..".mp3", 95, 100, 1, CHAN_VOICE)
		elseif ply:GetPlayerClass() == "demoman" then
			ply:EmitSound("vo/mvm/norm/demoman_mvm_paincrticialdeath0"..math.random(1,7)..".mp3", 95, 100, 1, CHAN_VOICE)
		elseif ply:GetPlayerClass() == "heavy" then
			ply:EmitSound("vo/mvm/norm/heavy_mvm_paincrticialdeath0"..math.random(1,5)..".mp3", 95, 100, 1, CHAN_VOICE)
		elseif ply:GetPlayerClass() == "engineer" then
			ply:EmitSound("vo/mvm/norm/engineer_mvm_paincrticialdeathp0"..math.random(1,8)..".mp3", 95, 100, 1, CHAN_VOICE)
		elseif ply:GetPlayerClass() == "medic" then
			ply:EmitSound("vo/mvm/norm/medic_mvm_paincrticialdeath0"..math.random(1,8)..".mp3", 95, 100, 1, CHAN_VOICE)
		elseif ply:GetPlayerClass() == "sniper" then
			ply:EmitSound("vo/mvm/norm/sniper_mvm_paincrticialdeath0"..math.random(1,4)..".mp3", 95, 100, 1, CHAN_VOICE)
		elseif ply:GetPlayerClass() == "spy" then
			ply:EmitSound("vo/mvm/norm/spy_mvm_paincrticialdeath0"..math.random(1,4)..".mp3", 95, 100, 1, CHAN_VOICE)
		end
			 
				
		ply:EmitSound( "MVM_Robot.BulletImpact" )
	end
	if not ply:IsHL2() and ply:GetInfoNum("tf_robot", 0) == 1 then
		ply:EmitSound( "MVM_Robot.BulletImpact" ) -- Play the footsteps hunter is using
	end
	if not ply:IsHL2() and ply:GetInfoNum("tf_robot", 0) == 1 then
		if eyeparticle1:IsValid() then
			eyeparticle1:Fire("kill", 0.001)
		end
		if eyeparticle2:IsValid() then
			eyeparticle2:Fire("kill", 0.001)
		end
		if ply:GetPlayerClass() == "scout" then
			ply:EmitSound("vo/mvm/norm/scout_mvm_painsevere0"..math.random(1,6)..".mp3", 95, 100, 1, CHAN_VOICE)
		elseif ply:GetPlayerClass() == "soldier" then
			ply:EmitSound("vo/mvm/norm/soldier_mvm_painsevere0"..math.random(1,6)..".mp3", 95, 100, 1, CHAN_VOICE)
		elseif ply:GetPlayerClass() == "pyro" then
			ply:EmitSound("vo/mvm/norm/pyro_mvm_painsevere0"..math.random(1,6)..".mp3", 95, 100, 1, CHAN_VOICE)
		elseif ply:GetPlayerClass() == "demoman" then
			ply:EmitSound("vo/mvm/norm/demoman_mvm_painsevere0"..math.random(1,4)..".mp3", 95, 100, 1, CHAN_VOICE)
		elseif ply:GetPlayerClass() == "heavy" then
			ply:EmitSound("vo/mvm/norm/heavy_mvm_painsevere0"..math.random(1,3)..".mp3", 95, 100, 1, CHAN_VOICE)
		elseif ply:GetPlayerClass() == "engineer" then
			ply:EmitSound("vo/mvm/norm/engineer_mvm_painsevere0"..math.random(1,7)..".mp3", 95, 100, 1, CHAN_VOICE)
		elseif ply:GetPlayerClass() == "medic" then
			ply:EmitSound("vo/mvm/norm/medic_mvm_painsevere0"..math.random(1,4)..".mp3", 95, 100, 1, CHAN_VOICE)
		elseif ply:GetPlayerClass() == "sniper" then
			ply:EmitSound("vo/mvm/norm/sniper_mvm_painsevere0"..math.random(1,4)..".mp3", 95, 100, 1, CHAN_VOICE)
		elseif ply:GetPlayerClass() == "spy" then
			ply:EmitSound("vo/mvm/norm/spy_mvm_painsevere0"..math.random(1,5)..".mp3", 95, 100, 1, CHAN_VOICE)
		end
	end
	if not ply:IsHL2() and ply:GetInfoNum("tf_mvm_voodoo", 0) == 1 then
		ply:EmitSound( "MVM_Robot.BulletImpact" ) -- Play the footsteps hunter is using
	end
	ply:StopSound("BusterLoop")
	if not ply:IsHL2() and ply:GetPlayerClass() == "sentrybuster" then
		ply:EmitSound("MVM.SentryBusterExplode")
	end
	if not ply:IsHL2() and ply:GetInfoNum("tf_sentrybuster", 0) == 1 then
		ply:EmitSound("MVM.SentryBusterExplode")
	end
	if not ply:IsHL2() and ply:GetInfoNum("tf_giant_robot", 0) == 1 then
		ply:EmitSound( "MVM.GiantCommonExplodes" ) -- Play the footsteps hunter is using
		ply:PrecacheGibs()
		ply:GibBreakClient( Vector(math.random(1,4), math.random(1,4), math.random(1,4)) )
		ply:GetRagdollEntity():Remove()	
		for k,v in pairs(player.GetAll()) do
			if not v:IsFriendly(ply) and v:Alive() and not v:IsHL2() then
				if v:GetPlayerClass() == "heavy" then
					v:EmitSound("vo/heavy_mvm_giant_robot02.mp3", 85, 100, 1, CHAN_REPLACE)
				elseif v:GetPlayerClass() == "medic" then
					v:EmitSound("vo/medic_mvm_giant_robot02.mp3", 85, 100, 1, CHAN_REPLACE)
				end
			end
		end
	end
	if not ply:IsHL2() and ply:GetPlayerClass() == "giantheavy" or ply:GetPlayerClass() == "giantdemoman" or ply:GetPlayerClass() == "giantsoldier" or ply:GetPlayerClass() == "giantpyro" then
		ply:EmitSound( "MVM.GiantCommonExplodes" ) -- Play the footsteps hunter is using
		ply:PrecacheGibs()
		ply:GibBreakClient( Vector(math.random(1,4), math.random(1,4), math.random(1,4)) )
		ply:GetRagdollEntity():Remove()	
		for k,v in pairs(player.GetAll()) do
			if not v:IsFriendly(ply) and v:Alive() and not v:IsHL2() then
				if v:GetPlayerClass() == "heavy" then
					v:EmitSound("vo/heavy_mvm_giant_robot02.mp3", 85, 100, 1, CHAN_REPLACE)
				elseif v:GetPlayerClass() == "medic" then
					v:EmitSound("vo/medic_mvm_giant_robot02.mp3", 85, 100, 1, CHAN_REPLACE)
				end
			end
		end
	end
	if not ply:IsHL2() and ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 1 then
		ply:EmitSound( "MVM.GiantCommonExplodes" ) -- Play the footsteps hunter is using
		ply:PrecacheGibs()
		ply:GibBreakClient( Vector(math.random(1,4), math.random(1,4), math.random(1,4)) )
		ply:GetRagdollEntity():Remove()	
		for k,v in pairs(player.GetAll()) do
			if not v:IsFriendly(ply) and v:Alive() and not v:IsHL2() then
				if ply:GetPlayerClass() == "heavy" then
					ply:EmitSound("vo/heavy_mvm_giant_robot02.mp3", 85, 100, 1, CHAN_REPLACE)
				elseif ply:GetPlayerClass() == "medic" then
					ply:EmitSound("vo/medic_mvm_giant_robot02.mp3", 85, 100, 1, CHAN_REPLACE)
				end
			end
		end
	end
end)



hook.Add("PlayerStepSoundTime", "FootTime", function(ply, iType, iWalking)
	if not ply:Crouching() then
	if ply:GetPlayerClass() == "heavy" and ply:GetInfoNum("tf_giant_robot", 0) == 1 then
		if ply:GetActiveWeapon():GetClass()	!= "tf_weapon_shotgun_hwg" then
			return 650
		else
			return 260
		end
	elseif ply:GetPlayerClass() == "soldier" and ply:GetInfoNum("tf_giant_robot", 0) == 1 then
		return 520
	elseif ply:GetPlayerClass() == "pyro" and ply:GetInfoNum("tf_giant_robot", 0) == 1 then
		return 520
	elseif ply:GetPlayerClass() == "demoman" and ply:GetInfoNum("tf_giant_robot", 0) == 1 then
		return 520
	elseif ply:GetPlayerClass() == "scout" and ply:GetInfoNum("tf_giant_robot", 0) == 1 then
		return 200
	elseif ply:GetInfoNum("tf_hhh", 0) == 1 then
		return 300
	end
	if ply:GetPlayerClass() == "demoman" and ply:GetInfoNum("tf_sentrybuster", 0) == 1 then
		return 300
	end
	if ply:GetPlayerClass() == "heavy" and ply:GetInfoNum("mp_cl_enable_custom_footstep_time", 0) == 1 then
		return 260
	elseif ply:GetPlayerClass() == "pyro" and ply:GetInfoNum("mp_cl_enable_custom_footstep_time", 0) == 1 then
		return 290
	elseif ply:GetPlayerClass() == "soldier" and ply:GetInfoNum("mp_cl_enable_custom_footstep_time", 0) == 1 then
		return 335
	elseif ply:GetPlayerClass() == "demoman" and ply:GetInfoNum("mp_cl_enable_custom_footstep_time", 0) == 1 then
		return 300
	elseif ply:GetPlayerClass() == "engineer" and ply:GetInfoNum("mp_cl_enable_custom_footstep_time", 0) == 1 then
		return 280
	elseif ply:GetPlayerClass() == "medic" and ply:GetInfoNum("mp_cl_enable_custom_footstep_time", 0) == 1 then
		return 285
	elseif ply:GetPlayerClass() == "sniper" and ply:GetInfoNum("mp_cl_enable_custom_footstep_time", 0) == 1 then
		return 290
	elseif ply:GetPlayerClass() == "spy" and ply:GetInfoNum("mp_cl_enable_custom_footstep_time", 0) == 1 then
		return 310
	elseif ply:GetPlayerClass() == "scout" and ply:GetInfoNum("mp_cl_enable_custom_footstep_time", 0) == 1 then
		return 200
	end
	if ply:GetPlayerClass() == "heavy" and ply:IsBot() and GetConVar("tf_botbecomerobots"):GetInt() == 1 then
		return 260
	elseif ply:GetPlayerClass() == "pyro" and ply:IsBot() and GetConVar("tf_botbecomerobots"):GetInt() == 1 then
		return 290
	elseif ply:GetPlayerClass() == "soldier" and ply:IsBot() and GetConVar("tf_botbecomerobots"):GetInt() == 1 then
		return 325
	elseif ply:GetPlayerClass() == "demoman" and ply:IsBot() and GetConVar("tf_botbecomerobots"):GetInt() == 1 then
		return 300
	elseif ply:GetPlayerClass() == "engineer" and ply:IsBot() and GetConVar("tf_botbecomerobots"):GetInt() == 1 then
		return 280
	elseif ply:GetPlayerClass() == "medic" and ply:IsBot() and GetConVar("tf_botbecomerobots"):GetInt() == 1 then
		return 285
	elseif ply:GetPlayerClass() == "sniper" and ply:IsBot() and GetConVar("tf_botbecomerobots"):GetInt() == 1 then
		return 305
	elseif ply:GetPlayerClass() == "spy" and ply:IsBot() and GetConVar("tf_botbecomerobots"):GetInt() == 1 then
		return 310
	elseif ply:GetPlayerClass() == "scout" and ply:IsBot() and GetConVar("tf_botbecomerobots"):GetInt() == 1 then
		return 200
	end
	if ply:GetPlayerClass() == "heavy" and ply:GetInfoNum("tf_robot", 0) == 1 then
		return 260
	elseif ply:GetPlayerClass() == "pyro" and ply:GetInfoNum("tf_robot", 0) == 1 then
		return 290
	elseif ply:GetPlayerClass() == "soldier" and ply:GetInfoNum("tf_robot", 0) == 1 then
		return 335
	elseif ply:GetPlayerClass() == "demoman" and ply:GetInfoNum("tf_robot", 0) == 1 then
		return 300
	elseif ply:GetPlayerClass() == "engineer" and ply:GetInfoNum("tf_robot", 0) == 1 then
		return 280
	elseif ply:GetPlayerClass() == "medic" and ply:GetInfoNum("tf_robot", 0) == 1 then
		return 285
	elseif ply:GetPlayerClass() == "sniper" and ply:GetInfoNum("tf_robot", 0) == 1 then
		return 290
	elseif ply:GetPlayerClass() == "spy" and ply:GetInfoNum("tf_robot", 0) == 1 then
		return 310
	elseif ply:GetPlayerClass() == "scout" and ply:GetInfoNum("tf_robot", 0) == 1 then
		return 200
	end
	if ply:GetInfoNum("jakey_antlionfbii", 0) == 1 then
		return 180
	end
	if ply:GetPlayerClass() == "heavy" and ply:GetInfoNum("tf_mvm_voodoo", 0) == 1 then
		return 260
	elseif ply:GetPlayerClass() == "pyro" and ply:GetInfoNum("tf_mvm_voodoo", 0) == 1 then
		return 290
	elseif ply:GetPlayerClass() == "soldier" and ply:GetInfoNum("tf_mvm_voodoo", 0) == 1 then
		return 335
	elseif ply:GetPlayerClass() == "demoman" and ply:GetInfoNum("tf_mvm_voodoo", 0) == 1 then
		return 300
	elseif ply:GetPlayerClass() == "demoman" and ply:GetInfoNum("tf_hhh", 0) == 1 then
		return 300
	elseif ply:GetPlayerClass() == "engineer" and ply:GetInfoNum("tf_mvm_voodoo", 0) == 1 then
		return 280
	elseif ply:GetPlayerClass() == "medic" and ply:GetInfoNum("tf_mvm_voodoo", 0) == 1 then
		return 285
	elseif ply:GetPlayerClass() == "sniper" and ply:GetInfoNum("tf_mvm_voodoo", 0) == 1 then
		return 290
	elseif ply:GetPlayerClass() == "spy" and ply:GetInfoNum("tf_mvm_voodoo", 0) == 1 then
		return 310
	elseif ply:GetPlayerClass() == "scout" and ply:GetInfoNum("tf_mvm_voodoo", 0) == 1 then
		return 200
	end
	if ply:GetPlayerClass() == "heavy" and ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 1 then
		return 260
	elseif ply:GetPlayerClass() == "pyro" and ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 1 then
		return 290
	elseif ply:GetPlayerClass() == "soldier" and ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 1 then
		return 335
	elseif ply:GetPlayerClass() == "demoman" and ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 1 then
		return 300
	elseif ply:GetPlayerClass() == "engineer" and ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 1 then
		return 280
	elseif ply:GetPlayerClass() == "medic" and ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 1 then
		return 285
	elseif ply:GetPlayerClass() == "sniper" and ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 1 then
		return 290
	elseif ply:GetPlayerClass() == "spy" and ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 1 then
		return 310
	elseif ply:GetPlayerClass() == "scout" and ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 1 then
		return 200
	end
	end
end)

hook.Remove("PlayerFootstep", "TA:Paint_Footsteps")

concommand.Add( "tf_sentrybuster_explode", function( ply, cmd )

	if ply:GetInfoNum("tf_sentrybuster", 0) == 1 then
	ply:SetNoDraw(true)
	ply:EmitSound("MVM.SentryBusterSpin")
	ply:SetNWBool("Taunting", true)
	ply:SetNWBool("NoWeapon", true)
	net.Start("ActivateTauntCam")
	net.Send(ply)
	local animent = ents.Create( 'base_gmodentity' ) -- The entity used as a reference for the bone positioning
	animent:SetModel( ply:GetModel() )
	animent:SetModelScale( ply:GetModelScale() )
	timer.Create("SetAnimPos", 0.01, 0, function()
		if not animent:IsValid() then timer.Stop("SetAnimPos") return end
		animent:SetPos( ply:GetPos() )
		animent:SetAngles( ply:GetAngles() )
	end )
	animent:SetNoDraw( false ) -- The ragdoll is the thing getting seen
	animent:Spawn()
	
	animent:SetSequence( "sentry_buster_preexplode" ) -- If the sequence isn't valid, the sequence length is 0, so the timer takes care of things
	animent:SetPlaybackRate( 1 )
	animent.AutomaticFrameAdvance = true
	
	animent:SetSolid( SOLID_OBB ) -- This stuff isn't really needed, but just for physics
	animent:PhysicsInit( SOLID_OBB )
	animent:SetMoveType( MOVETYPE_FLYGRAVITY )
	animent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	animent:PhysWake()
	
	function animent:Think() -- This makes the animation work
		self:NextThink( CurTime() )
		return true
	end
	timer.Simple(2.5, function()
		ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
		ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
		ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
		ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
	
		ParticleEffect("cinefx_goldrush_flash", ply:GetPos(), ply:GetAngles())
		ParticleEffect("fireSmoke_Collumn_mvmAcres", ply:GetPos(), Angle())
		ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(50,50,25), ply:GetAngles())
		ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(-50,-50,25), ply:GetAngles())
		ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(-50,50,25), ply:GetAngles())
		ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(50,-50,25), ply:GetAngles())

		ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(50,50,25), ply:GetAngles())
		ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(-50,-50,25), ply:GetAngles())
		ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(-50,50,25), ply:GetAngles())
		ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(50,-50,25), ply:GetAngles())

		if animent:IsValid() then
			animent:Remove() 
		end
	
		ply:EmitSound("MvM.SentryBusterExplode")
		ply:EmitSound("MvM.SentryBusterExplode")
		ply:EmitSound("MvM.SentryBusterExplode")
		ply:SetNoDraw(false)

		ply:SetNWBool("Taunting", false)
		ply:SetNWBool("NoWeapon", false)
		net.Start("DeActivateTauntCam")
		net.Send(ply)
		if ply:GetRagdollEntity():IsValid() then
			ply:GetRagdollEntity():Remove()
		end
		for k,v in pairs(ents.FindInSphere(ply:GetPos(), 800)) do 
			if !v:IsPlayer() and v:Health() >= 0 and not v:IsFriendly(ply) then
				v:TakeDamage( v:Health(), ply, ply:GetActiveWeapon() )
			elseif v:IsPlayer() and not v:IsFriendly(ply) and v:Alive() and v:Nick() != ply:Nick() then
				v:TakeDamage( v:Health(), ply, ply:GetActiveWeapon() )
			end
		end
		ply:TakeDamage( ply:Health(), ply, ply:GetActiveWeapon() )
	end)
	end
end)


hook.Add( "DoAnimationEvent" , "AnimEventTest" , function( ply , event , data )
	if event == PLAYERANIMEVENT_ATTACK_GRENADE then
		if data == 123 then
			ply:AnimRestartGesture( GESTURE_SLOT_GRENADE, ACT_GMOD_GESTURE_ITEM_THROW, true )
			return ACT_INVALID
		end

		if data == 321 then
			ply:AnimRestartGesture( GESTURE_SLOT_GRENADE, ACT_GMOD_GESTURE_ITEM_DROP, true )
			return ACT_INVALID
		end
	end
end )

concommand.Add("merc_impulse101", function(ply)
	if ply:GetPlayerClass() == "merc_dm" then
		ply:Give("tf_weapon_pistol_merc")
		ply:Give("tf_weapon_shotgun_merc")
		ply:Give("tf_weapon_rocketlauncher_merc")
		ply:Give("tf_weapon_rocketlauncher_rapidfire") 
		ply:Give("tf_weapon_nailgun_merc")
		ply:Give("tf_weapon_revolver_merc")
		ply:Give("tf_weapon_grenadelauncher_merc")
		ply:Give("tf_weapon_smg_dm_merc")
		ply:Give("tf_weapon_smg_merc")
		ply:Give("tf_weapon_gatlinggun")
		ply:Give("tf_weapon_supershotgun_merc")
		ply:Give("tf_weapon_sniperrifle_merc")
		ply:Give("tf_weapon_medigun_merc")
		ply:Give("tf_weapon_flamethrower_merc")
		ply:Give("tf_weapon_knife_merc")
		ply:Give("tf_weapon_railgun_merc")
		ply:Give("tf_weapon_minigun_merc")
		ply:Give("tf_weapon_pda_engineer_destroy_merc")
		ply:Give("tf_weapon_pda_engineer_build_merc")
		ply:Give("tf_weapon_wrench_merc")
		ply:Give("tf_weapon_scattergun_merc")
		ply:Give("tf_weapon_pipebomblauncher_merc")
		ply:GiveItem("TF_WEAPON_BUILDER")
		ply:EmitSound("items/spawn_item.wav")
	end
end)

concommand.Add("tf_givegravitygun", function(ply) 
	if not ply:IsHL2() then
		ply:Give("tf_weapon_physcannon") 
		ply:EmitSound("weapons/physcannon/physcannon_charge.wav")
	end
end)



concommand.Add("tf_givemegagravitygun", function(ply) 
	if not ply:IsHL2() then
		ply:Give("tf_weapon_superphyscannon") 
		ply:EmitSound("weapons/physcannon/superphys_chargeup.wav")
	end
end)


local function PlayerGiantBotSpawn( ply, mv )
	-- dun dun dun dun dun dun dun dun DO THE LOSKY
	if ply:GetModel() == "models/player/loskybasics/losky_pm.mdl" then
		ply:EmitSound("vo/losky_respawn01.wav")
	end
	timer.Simple(0.4, function()
		if ply:GetInfoNum("tf_lazyzombie", 0) == 1 then
			if ply:GetPlayerClass() != "demoman" then
				ply:SetModel("models/lazy_zombies_v2/"..ply:GetPlayerClass()..".mdl")
			else
				ply:SetModel("models/lazy_zombies_v2/demo.mdl")
			end
		end
		if GetConVar("tf_muselk_zombies"):GetBool() then
			if ply:Team() == TEAM_RED then
				ply:SetPlayerClass("engineer")
				
				ply:PrintMessage(HUD_PRINTCENTER, "You are now defending! You must find a place to hide! If the zombies team doesn't do it in the next 5 minutes, YOU WIN!")
					
			elseif ply:Team() == TEAM_NEUTRAL then
				ply:SetTeam(TEAM_RED)
				ply:SetPlayerClass("engineer")
				
				ply:PrintMessage(HUD_PRINTCENTER, "You are now defending! You must find a place to hide! If the zombies team doesn't do it in the next 5 minutes, YOU WIN!")
			elseif ply:Team() == TEAM_BLU then
				ply:GetWeapons()[1]:Remove()
				ply:GetWeapons()[2]:Remove()
				ply:SetPos(Vector(9086.43, 10060.49, -10786.25)) 
				ply:PrintMessage(HUD_PRINTCENTER, "You are now attacking! You must find the engineers and infect them! If your team doesn't do it in the next 5 minutes, YOU LOSE!")
				timer.Simple(0.4, function()
					if ply:GetPlayerClass() != "demoman" then
						ply:SetModel("models/lazy_zombies_v2/"..ply:GetPlayerClass()..".mdl")
					else
						ply:SetModel("models/lazy_zombies_v2/demo.mdl")
					end
				end)
			end
		end
	end)
	timer.Simple(0.18, function()
			
		timer.Create("VoiceL4d"..ply:EntIndex(), math.random(5,8), 0, function()
			if ply:Health() <= 1 then timer.Stop("VoiceL4d"..ply:EntIndex()) end
			if !IsValid(ply) then timer.Stop("VoiceL4d"..ply:EntIndex()) end
			if ply:GetPlayerClass() == "tank" then
				ply:EmitSound("Tank.Yell")
			elseif ply:GetPlayerClass() == "jockey" then
				ply:EmitSound("Jockey.Idle")
			elseif ply:GetPlayerClass() == "charger" then
				ply:EmitSound("Charger.Idle")
			elseif ply:GetPlayerClass() == "boomer" then
				ply:EmitSound("vj_l4d/boomer/voice/idle/boomer_lurk_0"..math.random(1,9)..".wav")
			elseif ply:GetPlayerClass() == "boomette" then
				ply:EmitSound("boomer/voice/idle/female_boomer_lurk_0"..math.random(1,9)..".wav")
			elseif ply:GetPlayerClass() == "l4d_zombie" then
				ply:EmitSound("vj_l4d_com/attack_b/male/rage_"..math.random(50,82)..".wav")
			end
		end)
		if ply:GetPlayerClass() == "tank" then
			ply:EmitSound("Tank.Yell")
		elseif ply:GetPlayerClass() == "charger" then
			ply:EmitSound("Charger.Idle")
		elseif ply:GetPlayerClass() == "jockey" then
			ply:EmitSound("Jockey.Idle")
		elseif ply:GetPlayerClass() == "boomer" then
			ply:EmitSound("vj_l4d/boomer/voice/idle/boomer_lurk_0"..math.random(1,9)..".wav")
		elseif ply:GetPlayerClass() == "boomette" then
			ply:EmitSound("boomer/voice/idle/female_boomer_lurk_0"..math.random(1,9)..".wav")
		elseif ply:GetPlayerClass() == "l4d_zombie" then
			ply:EmitSound("vj_l4d_com/attack_b/male/rage_"..math.random(50,82)..".wav")
		end
		if ply:GetPlayerClass() == "pyro" and ply:GetInfoNum("tf_femmepyro", 0) == 1 then
			ply:SetModel("models/femmepyro_renovation/femmepyro.mdl")
		end
		if ply:GetPlayerClass() == "tank" then
			ply:EmitSound("Tank.Yell")
			for k,v in ipairs(player.GetAll()) do
				v:EmitSound("TankMusicLoop")
			end
		end

		timer.Create("TankYell", 20, 0, function()
			if !ply:Alive() then timer.Stop("TankYell") return end 
			if ply:GetPlayerClass() != "tank" then timer.Stop("TankYell") return end 
			ply:EmitSound("Tank.Yell")
		end)
		if ply:IsBot() then
			timer.Create("Unstuck"..ply:EntIndex(), 0.01, 0, function()
				if SERVER then
					if ply:IsInWorld() == false then
						ply:Spawn()
					end
				end
			end)
			timer.Simple(0.1, function()
			if GetConVar("tf_botbecomerobots"):GetInt() == 1 then
				if ply:Team() == TEAM_BLU then
				ply:SetBloodColor(BLOOD_COLOR_MECH)
				if ply:GetPlayerClass() == "scout" then
					ply:SetModel("models/bots/scout/bot_scout.mdl")	
				elseif ply:GetPlayerClass() == "soldier" then
					ply:SetModel("models/bots/soldier/bot_soldier.mdl")	
				elseif ply:GetPlayerClass() == "demoman" then
					ply:SetModel("models/bots/demo/bot_demo.mdl")	
				elseif ply:GetPlayerClass() == "heavy" then
					ply:SetModel("models/bots/heavy/bot_heavy.mdl")	
				elseif ply:GetPlayerClass() == "pyro" then
					ply:SetModel("models/bots/pyro/bot_pyro.mdl")	
				elseif ply:GetPlayerClass() == "medic" then
					ply:SetModel("models/bots/medic/bot_medic.mdl")	
				elseif ply:GetPlayerClass() == "engineer" then
					ply:SetModel("models/bots/engineer/bot_engineer.mdl")	
				elseif ply:GetPlayerClass() == "sniper" then
					ply:SetModel("models/bots/sniper/bot_sniper.mdl")	
				elseif ply:GetPlayerClass() == "spy" then
					ply:SetModel("models/bots/spy/bot_spy.mdl")	
				end
				local ID = ply:LookupAttachment( "eye_1" )
				local Attachment = ply:GetAttachment( ID )
				if (Attachment == nil) then return end

				if ply:GetPlayerClass() == "scout" then
					ply:SetName("Scout")
				elseif ply:GetPlayerClass() == "soldier" then
					ply:SetName("Soldier")
				elseif ply:GetPlayerClass() == "pyro" then
					ply:SetName("Pyro")
				elseif ply:GetPlayerClass() == "demoman" then
					ply:SetName("Demoman")
				elseif ply:GetPlayerClass() == "heavy" then
					ply:SetName("Heavy")
				elseif ply:GetPlayerClass() == "engineer" then
					ply:SetName("Engineer")
				elseif ply:GetPlayerClass() == "medic" then
					ply:SetName("Medic")
				elseif ply:GetPlayerClass() == "sniper" then
					ply:SetName("Sniper")
				elseif ply:GetPlayerClass() == "spy" then
					ply:SetName("Spyware")
				end

				eyeparticle1 = ents.Create( "info_particle_system" )
				eyeparticle1:SetPos( Attachment.Pos )
				eyeparticle1:SetAngles( Attachment.Ang )
				eyeparticle1:SetName("eyeparticle1")
				eyeparticle1:SetOwner(ply)
				ply:DeleteOnRemove(eyeparticle1)

				PrecacheParticleSystem("bot_eye_glow")
				eyeparticle1:SetKeyValue( "effect_name", "alt_bot_eye_glow" )
				eyeparticle1:SetKeyValue( "start_active", "1")

				local colorcontrol = ents.Create( "info_particle_system" )
				if ply:Team() == TEAM_RED then
					colorcontrol:SetPos( Vector(204,0,0) )
				elseif ply:Team() == TEAM_BLU then
					colorcontrol:SetPos( Vector(51,255,255) )
				end
				eyeparticle1:DeleteOnRemove(colorcontrol)
				colorcontrol:SetKeyValue( "effect_name", "alt_bot_eye_glow" )
				//colorcontrol:SetKeyValue( "globalname", "colorcontrol_".. eyeparticle1:EntIndex())
				colorcontrol:SetName("colorcontrol_".. eyeparticle1:EntIndex())
				colorcontrol:Spawn()

				eyeparticle1:SetParent(ply)
				eyeparticle1:Fire("setparentattachment", "eye_1", 0.01)
				eyeparticle1:SetKeyValue( "cpoint1", "colorcontrol_".. eyeparticle1:EntIndex() ) 
								
				eyeparticle1:Spawn()
				eyeparticle1:Activate()
				local ID = ply:LookupAttachment( "eye_2" )
				local Attachment = ply:GetAttachment( ID )
				if (Attachment != nil) then 
					eyeparticle2 = ents.Create( "info_particle_system" )
					eyeparticle2:SetPos( Attachment.Pos )
					eyeparticle2:SetAngles( Attachment.Ang )
					eyeparticle1:DeleteOnRemove(eyeparticle2)
					eyeparticle2:SetKeyValue( "effect_name", "alt_bot_eye_glow" )
					eyeparticle2:SetKeyValue( "start_active", "1")
					eyeparticle2:SetParent(ply)
					eyeparticle2:SetName("eyeparticle2")
					eyeparticle2:Fire("setparentattachment", "eye_2", 0.01)
					eyeparticle2:SetKeyValue( "cpoint1", "colorcontrol_".. eyeparticle1:EntIndex() )
					eyeparticle2:Spawn()
					eyeparticle2:Activate()
				end
				ply:SetBloodColor(BLOOD_COLOR_MECH)
				timer.Create("KillParticlesOnDeath", 0.001, 0, function()
					if ply:Alive() then
						return true
					else
						for k,v in pairs(ents.FindByName("eyeparticle1")) do 
							if v:GetOwner() == ply then
								v:Remove()
							end
						end
						timer.Stop("KillParticlesOnDeath")
						return false
					end
				end)
				end
			end
			end)
		end
	end)
	timer.Simple(0.3, function()
		if not ply:IsHL2() and ply:GetInfoNum("tf_sentrybuster", 0) == 1 then
			if ply:GetPlayerClass() != "demoman" then ply:SetPlayerClass("demoman") end
			for k,v in pairs(player.GetAll()) do
				if not v:IsFriendly(ply) and v:Alive() and not v:IsHL2() then
					if v:GetPlayerClass() == "heavy" then
						v:EmitSound("vo/heavy_mvm_sentry_buster01.mp3", 85, 100, 1, CHAN_REPLACE)
					elseif v:GetPlayerClass() == "medic" then
						v:EmitSound("vo/medic_mvm_sentry_buster01.mp3", 85, 100, 1, CHAN_REPLACE)
					elseif v:GetPlayerClass() == "soldier" then
						v:EmitSound("vo/soldier_mvm_sentry_buster01.mp3", 85, 100, 1, CHAN_REPLACE)
					elseif v:GetPlayerClass() == "engineer" then
						v:EmitSound("vo/engineer_mvm_sentry_buster01.mp3", 85, 100, 1, CHAN_REPLACE)
					end
				end
			end
			for k,v in ipairs(player.GetAll()) do
				v:EmitSound("Announcer.MVM_Sentry_Buster_Alert")
			end
			ply:EmitSound("MVM.SentryBusterIntro")
			ply:EmitSound("BusterLoop")
			ply:SetModel("models/bots/demo/bot_sentry_buster.mdl")
			ply:SetHealth(3600)
			ply:StripWeapon("tf_weapon_grenadelauncher")
			ply:StripWeapon("tf_weapon_pipebomblauncher")
			ply:SetModelScale(1.75)

			timer.Create("HHHSpeed2", 0.01, 0, function()
				if not ply:Alive() then timer.Stop("HHHSpeed2") return end
				if ply:GetInfoNum("tf_sentrybuster", 0) == 0 then timer.Stop("HHHSpeed2") return end
				ply:SetWalkSpeed(700)
				ply:SetRunSpeed(800)
			end)
			timer.Create("SentryBusterIntroLoop", 4, 0, function()
				if not ply:Alive() then timer.Stop("HHHSpeed2") return end
				if ply:GetInfoNum("tf_sentrybuster", 0) == 0 then timer.Stop("HHHSpeed2") return end
				ply:EmitSound("MVM.SentryBusterIntro")
			end)
		
			timer.Create("SentryBusterExplodeNearSentry"..ply:EntIndex(), 0.1, 0, function()
				if !ply:Alive() then timer.Stop("SentryBusterExplodeNearSentry"..ply:EntIndex()) return end
				if ply:GetInfoNum("tf_sentrybuster",0) != 1 then timer.Stop("SentryBusterExplodeNearSentry"..ply:EntIndex()) return end
				if ply:GetInfoNum("tf_sentrybuster",0) != 1 then return end
				for _,building in pairs(ents.FindInSphere(ply:GetPos(), 80)) do
					if building:GetClass() == "obj_sentrygun" then	
					ply:SetNoDraw(true)
					ply:EmitSound("MVM.SentryBusterSpin")
					ply:SetNWBool("Taunting", true)
					ply:SetNWBool("NoWeapon", true)
					net.Start("ActivateTauntCam")
					net.Send(ply)
					local animent = ents.Create( 'base_gmodentity' ) -- The entity used as a reference for the bone positioning
					animent:SetModel( ply:GetModel() )
					animent:SetModelScale( ply:GetModelScale() )
					timer.Create("SetAnimPos", 0.01, 0, function()
						if not animent:IsValid() then timer.Stop("SetAnimPos") return end
						animent:SetPos( ply:GetPos() )
						animent:SetAngles( ply:GetAngles() )
					end )
					animent:SetNoDraw( false ) -- The ragdoll is the thing getting seen
					animent:Spawn()
										
					animent:SetSequence( "sentry_buster_preexplode" ) -- If the sequence isn't valid, the sequence length is 0, so the timer takes care of things
					animent:SetPlaybackRate( 1 )
					animent.AutomaticFrameAdvance = true
											
					animent:SetSolid( SOLID_OBB ) -- This stuff isn't really needed, but just for physics
					animent:PhysicsInit( SOLID_OBB )
					animent:SetMoveType( MOVETYPE_FLYGRAVITY )
					animent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
					animent:PhysWake()
										
					function animent:Think() -- This makes the animation work
						self:NextThink( CurTime() )
						return true
					end
					timer.Simple(2.5, function()
						ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
						ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
						ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
						ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
										
						ParticleEffect("cinefx_goldrush_flash", ply:GetPos(), ply:GetAngles())
							ParticleEffect("fireSmoke_Collumn_mvmAcres", ply:GetPos(), Angle())
						ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(50,50,25), ply:GetAngles())
						ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(-50,-50,25), ply:GetAngles())
						ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(-50,50,25), ply:GetAngles())
						ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(50,-50,25), ply:GetAngles())

						ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(50,50,25), ply:GetAngles())
						ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(-50,-50,25), ply:GetAngles())
						ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(-50,50,25), ply:GetAngles())
						ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(50,-50,25), ply:GetAngles())

						if animent:IsValid() then
							animent:Remove() 
						end

						ply:EmitSound("MvM.SentryBusterExplode")
						ply:EmitSound("MvM.SentryBusterExplode")
						ply:EmitSound("MvM.SentryBusterExplode")
						ply:SetNoDraw(false)

						ply:SetNWBool("Taunting", false)
						ply:SetNWBool("NoWeapon", false)
						net.Start("DeActivateTauntCam")
						net.Send(ply)
						if ply:GetRagdollEntity():IsValid() then
							ply:GetRagdollEntity():Remove()
						end
						for k,v in pairs(ents.FindInSphere(ply:GetPos(), 800)) do 
							if !v:IsPlayer() and v:Health() >= 0 and not v:IsFriendly(ply) then
								v:TakeDamage( v:Health(), ply, ply:GetActiveWeapon() )
							elseif v:IsPlayer() and not v:IsFriendly(ply) and v:Alive() and v:Nick() != ply:Nick() then
								v:TakeDamage( v:Health(), ply, ply:GetActiveWeapon() )
							end
						end
						ply:TakeDamage( ply:Health(), ply, ply:GetActiveWeapon() )
					end)
					timer.Stop("SentryBusterExplodeNearSentry"..ply:EntIndex())
					end
				end
			end)
			timer.Create("SentryBusterExplodeOnDeath", 0.1, 0, function()
				if !ply:Alive() then timer.Stop("SentryBusterExplodeOnDeath"..ply:EntIndex()) return end
				if ply:GetInfoNum("tf_sentrybuster",0) != 1 then timer.Stop("SentryBusterExplodeOnDeath"..ply:EntIndex()) return end
				if ply:GetInfoNum("tf_sentrybuster",0) != 1 then return end
				if ply:Health() <= 30 then
				ply:EmitSound("MVM.SentryBusterSpin")
				timer.Simple(0.1, function()
				ply:GodEnable()
				ply:SetNoDraw(true)
				ply:SetNWBool("Taunting", true)
				ply:SetNWBool("NoWeapon", true)
				net.Start("ActivateTauntCam")
				local animent = ents.Create( 'base_gmodentity' ) -- The entity used as a reference for the bone positioning
				animent:SetModel( ply:GetModel() )
				animent:SetModelScale( ply:GetModelScale() )
				timer.Create("SetAnimPos", 0.01, 0, function()
					if not animent:IsValid() then timer.Stop("SetAnimPos") return end
					animent:SetPos( ply:GetPos() )
					animent:SetAngles( ply:GetAngles() )
				end )
				animent:SetNoDraw( false ) -- The ragdoll is the thing getting seen
				animent:Spawn()
	
				animent:SetSequence( "sentry_buster_preexplode" ) -- If the sequence isn't valid, the sequence length is 0, so the timer takes care of things
				animent:SetPlaybackRate( 1 )
				animent.AutomaticFrameAdvance = true
	
				animent:SetSolid( SOLID_OBB ) -- This stuff isn't really needed, but just for physics
				animent:PhysicsInit( SOLID_OBB )
				animent:SetMoveType( MOVETYPE_FLYGRAVITY )
				animent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
				animent:PhysWake()
	
				function animent:Think() -- This makes the animation work
					self:NextThink( CurTime() - 5 )
					return true
				end
				timer.Simple(2, function()
					ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
					ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
					ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
					ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
	
					ParticleEffect("cinefx_goldrush_flash", ply:GetPos(), ply:GetAngles())
					ParticleEffect("fireSmoke_Collumn_mvmAcres", ply:GetPos(), Angle())
					ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(50,50,25), ply:GetAngles())
					ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(-50,-50,25), ply:GetAngles())
					ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(-50,50,25), ply:GetAngles())
					ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(50,-50,25), ply:GetAngles())

					ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(50,50,25), ply:GetAngles())
					ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(-50,-50,25), ply:GetAngles())
					ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(-50,50,25), ply:GetAngles())
					ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(50,-50,25), ply:GetAngles())
		
					if animent:IsValid() then
						animent:Remove()
					end
	
					ply:EmitSound("MvM.SentryBusterExplode")
					ply:SetNoDraw(false)
					ply:GodDisable()

					ply:SetNWBool("Taunting", false)
					ply:SetNWBool("NoWeapon", false)
					net.Start("DeActivateTauntCam")
					if ply:GetRagdollEntity():IsValid() then
						ply:GetRagdollEntity():Remove()
					end
					for k,v in pairs(ents.FindInSphere(ply:GetPos(), 800)) do 
						if v:IsNPC() and not v:IsFriendly(ply) then
							v:TakeDamage( v:Health(), ply, ply:GetActiveWeapon() )
						elseif v:IsPlayer() and not v:IsFriendly(ply) and ply:Alive() then
							v:TakeDamage( v:Health(), ply, ply:GetActiveWeapon() )
						end
					end
					ply:Kill()
				end)
				end)
				timer.Stop("SentryBusterExplodeOnDeath")
				end
			end)
		end

		if ply:GetPlayerClass() == "sentrybuster" then 
			for k,v in pairs(player.GetAll()) do
				if not v:IsFriendly(ply) and v:Alive() and not v:IsHL2() then
					if v:GetPlayerClass() == "heavy" then
						v:EmitSound("vo/heavy_mvm_sentry_buster01.mp3", 85, 100, 1, CHAN_REPLACE)
					elseif v:GetPlayerClass() == "medic" then
						v:EmitSound("vo/medic_mvm_sentry_buster01.mp3", 85, 100, 1, CHAN_REPLACE)
					elseif v:GetPlayerClass() == "soldier" then
						v:EmitSound("vo/soldier_mvm_sentry_buster01.mp3", 85, 100, 1, CHAN_REPLACE)
					elseif v:GetPlayerClass() == "engineer" then
						v:EmitSound("vo/engineer_mvm_sentry_buster01.mp3", 85, 100, 1, CHAN_REPLACE)
					end
				end
			end
			for k,v in ipairs(player.GetAll()) do
				v:EmitSound("Announcer.MVM_Sentry_Buster_Alert")
			end
			ply:EmitSound("MVM.SentryBusterIntro")
			ply:EmitSound("BusterLoop")
			ply:SetModel("models/bots/demo/bot_sentry_buster.mdl")
			ply:SetHealth(3600)
			ply:StripWeapon("tf_weapon_grenadelauncher")
			ply:StripWeapon("tf_weapon_pipebomblauncher")
			ply:SetModelScale(1.75)

			timer.Create("HHHSpeed2"..ply:EntIndex(), 0.01, 0, function()
				if !ply:Alive() then timer.Stop("HHHSpeed2"..ply:EntIndex()) return end
				if ply:GetPlayerClass() != "sentrybuster" then timer.Stop("HHHSpeed2"..ply:EntIndex()) return end
				ply:SetWalkSpeed(700)
				ply:SetRunSpeed(800)
			end)
			timer.Create("SentryBusterIntroLoop"..ply:EntIndex(), 4, 0, function()
				if !ply:Alive() then timer.Stop("SentryBusterIntroLoop"..ply:EntIndex()) return end
				if ply:GetPlayerClass() != "sentrybuster" then timer.Stop("SentryBusterIntroLoop"..ply:EntIndex()) return end
				ply:EmitSound("MVM.SentryBusterIntro")
			end)
		
			timer.Create("SentryBusterExplodeNearSentry"..ply:EntIndex(), 0.1, 0, function()
				if !ply:Alive() then timer.Stop("SentryBusterExplodeNearSentry") return end
				if ply:GetPlayerClass() != "sentrybuster" then timer.Stop("SentryBusterExplodeNearSentry") return end
				if ply:GetPlayerClass() != "sentrybuster" then return end
				for _,building in pairs(ents.FindInSphere(ply:GetPos(), 80)) do
					if building:GetClass() == "obj_sentrygun" then	
					ply:SetNoDraw(true)
					ply:EmitSound("MVM.SentryBusterSpin")
					ply:SetNWBool("Taunting", true)
					ply:SetNWBool("NoWeapon", true)
					net.Start("ActivateTauntCam")
					net.Send(ply)
					local animent = ents.Create( 'base_gmodentity' ) -- The entity used as a reference for the bone positioning
					animent:SetModel( ply:GetModel() )
					animent:SetModelScale( ply:GetModelScale() )
					timer.Create("SetAnimPos", 0.01, 0, function()
						if not animent:IsValid() then timer.Stop("SetAnimPos") return end
						animent:SetPos( ply:GetPos() )
						animent:SetAngles( ply:GetAngles() )
					end )
					animent:SetNoDraw( false ) -- The ragdoll is the thing getting seen
					animent:Spawn()
										
					animent:SetSequence( "sentry_buster_preexplode" ) -- If the sequence isn't valid, the sequence length is 0, so the timer takes care of things
					animent:SetPlaybackRate( 1 )
					animent.AutomaticFrameAdvance = true
											
					animent:SetSolid( SOLID_OBB ) -- This stuff isn't really needed, but just for physics
					animent:PhysicsInit( SOLID_OBB )
					animent:SetMoveType( MOVETYPE_FLYGRAVITY )
					animent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
					animent:PhysWake()
										
					function animent:Think() -- This makes the animation work
						self:NextThink( CurTime() )
						return true
					end
					timer.Simple(2.5, function()
						ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
						ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
						ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
						ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
										
						ParticleEffect("cinefx_goldrush_flash", ply:GetPos(), ply:GetAngles())
							ParticleEffect("fireSmoke_Collumn_mvmAcres", ply:GetPos(), Angle())
						ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(50,50,25), ply:GetAngles())
						ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(-50,-50,25), ply:GetAngles())
						ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(-50,50,25), ply:GetAngles())
						ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(50,-50,25), ply:GetAngles())

						ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(50,50,25), ply:GetAngles())
						ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(-50,-50,25), ply:GetAngles())
						ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(-50,50,25), ply:GetAngles())
						ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(50,-50,25), ply:GetAngles())

						if animent:IsValid() then
							animent:Remove() 
						end

						ply:EmitSound("MvM.SentryBusterExplode")
						ply:EmitSound("MvM.SentryBusterExplode")
						ply:EmitSound("MvM.SentryBusterExplode")
						ply:SetNoDraw(false)

						ply:SetNWBool("Taunting", false)
						ply:SetNWBool("NoWeapon", false)
						net.Start("DeActivateTauntCam")
						net.Send(ply)
						if ply:GetRagdollEntity():IsValid() then
							ply:GetRagdollEntity():Remove()
						end
						for k,v in pairs(ents.FindInSphere(ply:GetPos(), 800)) do 
							if !v:IsPlayer() and v:Health() >= 0 and not v:IsFriendly(ply) then
								v:TakeDamage( v:Health(), ply, ply:GetActiveWeapon() )
							elseif v:IsPlayer() and not v:IsFriendly(ply) and v:Alive() and v:Nick() != ply:Nick() then
								v:TakeDamage( v:Health(), ply, ply:GetActiveWeapon() )
							end
						end
						ply:TakeDamage( ply:Health(), ply, ply:GetActiveWeapon() )
					end)
					timer.Stop("SentryBusterExplodeNearSentry"..ply:EntIndex())
					end
				end
			end)
			timer.Create("SentryBusterExplodeOnDeath", 0.1, 0, function()
				if !ply:Alive() then timer.Stop("SentryBusterExplodeOnDeath") return end
				if ply:GetPlayerClass() != "sentrybuster" then timer.Stop("SentryBusterExplodeOnDeath") return end
				if ply:GetPlayerClass() != "sentrybuster" then return end
				if ply:Health() <= 30 then
				ply:EmitSound("MVM.SentryBusterSpin")
				timer.Simple(0.1, function()
				ply:GodEnable()
				ply:SetNoDraw(true)
				ply:SetNWBool("Taunting", true)
				ply:SetNWBool("NoWeapon", true)
				net.Start("ActivateTauntCam")
				local animent = ents.Create( 'base_gmodentity' ) -- The entity used as a reference for the bone positioning
				animent:SetModel( ply:GetModel() )
				animent:SetModelScale( ply:GetModelScale() )
				timer.Create("SetAnimPos", 0.01, 0, function()
					if not animent:IsValid() then timer.Stop("SetAnimPos") return end
					animent:SetPos( ply:GetPos() )
					animent:SetAngles( ply:GetAngles() )
				end )
				animent:SetNoDraw( false ) -- The ragdoll is the thing getting seen
				animent:Spawn()
	
				animent:SetSequence( "sentry_buster_preexplode" ) -- If the sequence isn't valid, the sequence length is 0, so the timer takes care of things
				animent:SetPlaybackRate( 1 )
				animent.AutomaticFrameAdvance = true
	
				animent:SetSolid( SOLID_OBB ) -- This stuff isn't really needed, but just for physics
				animent:PhysicsInit( SOLID_OBB )
				animent:SetMoveType( MOVETYPE_FLYGRAVITY )
				animent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
				animent:PhysWake()
	
				function animent:Think() -- This makes the animation work
					self:NextThink( CurTime() - 5 )
					return true
				end
				timer.Simple(2, function()
					ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
					ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
					ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
					ParticleEffect("asplode_hoodoo_shockwave", ply:GetPos() + Vector(0,0,35), ply:GetAngles())
	
					ParticleEffect("cinefx_goldrush_flash", ply:GetPos(), ply:GetAngles())
					ParticleEffect("fireSmoke_Collumn_mvmAcres", ply:GetPos(), Angle())
					ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(50,50,25), ply:GetAngles())
					ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(-50,-50,25), ply:GetAngles())
					ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(-50,50,25), ply:GetAngles())
					ParticleEffect("fluidSmokeExpl_ring_mvm", ply:GetPos() + Vector(50,-50,25), ply:GetAngles())

					ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(50,50,25), ply:GetAngles())
					ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(-50,-50,25), ply:GetAngles())
					ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(-50,50,25), ply:GetAngles())
					ParticleEffect("fireSmoke_Collumn_mvmAcres_sm", ply:GetPos() + Vector(50,-50,25), ply:GetAngles())
		
					if animent:IsValid() then
						animent:Remove()
					end
	
					ply:EmitSound("MvM.SentryBusterExplode")
					ply:SetNoDraw(false)
					ply:GodDisable()

					ply:SetNWBool("Taunting", false)
					ply:SetNWBool("NoWeapon", false)
					net.Start("DeActivateTauntCam")
					if ply:GetRagdollEntity():IsValid() then
						ply:GetRagdollEntity():Remove()
					end
					for k,v in pairs(ents.FindInSphere(ply:GetPos(), 800)) do 
						if v:IsNPC() and not v:IsFriendly(ply) then
							v:TakeDamage( v:Health(), ply, ply:GetActiveWeapon() )
						elseif v:IsPlayer() and not v:IsFriendly(ply) and ply:Alive() then
							v:TakeDamage( v:Health(), ply, ply:GetActiveWeapon() )
						end
					end
					ply:Kill()
				end)
				end)
				timer.Stop("SentryBusterExplodeOnDeath")
				end
			end)
		end
		if not ply:IsHL2() and ply:GetInfoNum("tf_robot", 0) == 1 then
			local ID = ply:LookupAttachment( "eye_1" )
			local Attachment = ply:GetAttachment( ID )
			if (Attachment == nil) then return end

			eyeparticle1 = ents.Create( "info_particle_system" )
			eyeparticle1:SetPos( Attachment.Pos )
			eyeparticle1:SetAngles( Attachment.Ang )
			eyeparticle1:SetName("eyeparticle1")
			eyeparticle1:SetOwner(ply)
			ply:DeleteOnRemove(eyeparticle1)

			PrecacheParticleSystem("bot_eye_glow")
			eyeparticle1:SetKeyValue( "effect_name", "alt_bot_eye_glow" )
			eyeparticle1:SetKeyValue( "start_active", "1")

			local colorcontrol = ents.Create( "info_particle_system" )
			if ply:Team() == TEAM_RED then
				colorcontrol:SetPos( Vector(204,0,0) )
			elseif ply:Team() == TEAM_BLU then
				colorcontrol:SetPos( Vector(51,255,255) )
			end
			eyeparticle1:DeleteOnRemove(colorcontrol)
			colorcontrol:SetKeyValue( "effect_name", "alt_bot_eye_glow" )
			//colorcontrol:SetKeyValue( "globalname", "colorcontrol_".. eyeparticle1:EntIndex())
			colorcontrol:SetName("colorcontrol_".. eyeparticle1:EntIndex())
			colorcontrol:Spawn()

			eyeparticle1:SetParent(ply)
			eyeparticle1:Fire("setparentattachment", "eye_1", 0.01)
			eyeparticle1:SetKeyValue( "cpoint1", "colorcontrol_".. eyeparticle1:EntIndex() ) //the color is controlled by the position of this entity - 
										 			     //if the colorcontroller's position is 255, 255, 255, 
											 		     //the color of the particle becomes white (255 255 255)
			eyeparticle1:Spawn()
			eyeparticle1:Activate()
			//now for eye two
			local ID = ply:LookupAttachment( "eye_2" )
			local Attachment = ply:GetAttachment( ID )
			if (Attachment != nil) then 
				eyeparticle2 = ents.Create( "info_particle_system" )
				eyeparticle2:SetPos( Attachment.Pos )
				eyeparticle2:SetAngles( Attachment.Ang )
				eyeparticle1:DeleteOnRemove(eyeparticle2)
				eyeparticle2:SetKeyValue( "effect_name", "alt_bot_eye_glow" )
				eyeparticle2:SetKeyValue( "start_active", "1")
				eyeparticle2:SetParent(ply)
				eyeparticle2:SetName("eyeparticle2")
				eyeparticle2:Fire("setparentattachment", "eye_2", 0.01)
				eyeparticle2:SetKeyValue( "cpoint1", "colorcontrol_".. eyeparticle1:EntIndex() )
				eyeparticle2:Spawn()
				eyeparticle2:Activate()							

			end
			ply:SetBloodColor(BLOOD_COLOR_MECH)
			timer.Create("KillParticlesOnDeath", 0.001, 0, function()
				if ply:Alive() then
					return true
				else
					for k,v in pairs(ents.FindByName("eyeparticle1")) do 
						if v:GetOwner() == ply then
							v:Remove()
						end
					end
					timer.Stop("KillParticlesOnDeath")
					return false
				end
			end)
		else
			ply:SetBloodColor(BLOOD_COLOR_RED)
		end
		
		if not ply:IsHL2() and ply:GetInfoNum("tf_hhh", 0) == 1 then
			ply:Give("tf_weapon_katana")
			ply:Give("tf_weapon_hhh_axe")
			ply:SetModel("models/bots/headless_hatman.mdl")
			ply:SetHealth(5000)
			ply:SetMaxHealth(5000)
			ply:SetWalkSpeed(500)
			ply:SetMaxSpeed(500)
			ply:SetRunSpeed(500)
			if ply:GetInfoNum("tf_giant_robot", 0) == 1 then
				ply:SetModelScale(6)
				ply:EmitSound("music/stingers/hl1_stinger_song28.mp3", 0, 80)

				timer.Create("GiantRobotSpeed2",  100, 0, function()
					if not ply:Alive() then timer.Stop("GiantRobotSpeed2") return end
					if ply:GetInfoNum("tf_hhh", 0) == 0 then timer.Stop("GiantRobotSpeed2") return end
					ply:PlaySound("music/hl2_song6.mp3", 0, 100)
				end)
			end
			timer.Create("GiantRobotSpeed", 0.01, 0, function()
				if not ply:Alive() then timer.Stop("GiantRobotSpeed") return end
				if ply:GetInfoNum("tf_hhh", 0) == 0 then timer.Stop("GiantRobotSpeed") return end
				ply:SetWalkSpeed(500)
				ply:SetMaxSpeed(500)
				ply:SetRunSpeed(500)
			end)
			ply:StripWeapon("tf_weapon_bottle")
			ply:StripWeapon("tf_weapon_pipebomblauncher")
			ply:StripWeapon("tf_weapon_grenadelauncher")
			for k,v in pairs(player.GetAll()) do
				v:SendLua([[surface.PlaySound("ui/halloween_boss_summoned_fx.wav")]])
				v:SendLua([[LocalPlayer():PrintMessage(HUD_PRINTCENTER, "The Horseless Headless Horsemann has been spawned!")]])
			end
			ply:EmitSound("ui/halloween_boss_summon_rumble.wav", 95, 100)
		end
		if not ply:IsHL2() and ply:GetInfoNum("tf_giant_robot", 0) == 1 then

			for k,v in pairs(player.GetAll()) do
				if not v:IsFriendly(ply) and v:Alive() and not v:IsHL2() then
					if v:GetPlayerClass() == "heavy" then
						v:EmitSound("vo/heavy_mvm_giant_robot04.mp3", 85, 100, 1, CHAN_REPLACE)
					elseif v:GetPlayerClass() == "medic" then
						v:EmitSound("vo/medic_mvm_giant_robot01.mp3", 85, 100, 1, CHAN_REPLACE)
					elseif v:GetPlayerClass() == "soldier" then
						v:EmitSound("vo/soldier_mvm_giant_robot0"..math.random(1,2)..".mp3", 85, 100, 1, CHAN_REPLACE)
					elseif v:GetPlayerClass() == "engineer" then
						v:EmitSound("vo/engineer_mvm_giant_robot0"..math.random(1,2)..".mp3", 85, 100, 1, CHAN_REPLACE)
					end
				end
			end
			if ply:GetPlayerClass() == "scout" then
				timer.Create("GiantRobotSpeed", 0.01, 0, function()
					if not ply:Alive() then timer.Stop("GiantRobotSpeed") return end
					if ply:GetInfoNum("tf_giant_robot", 0) == 0 then timer.Stop("GiantRobotSpeed") return end
					ply:SetWalkSpeed(500)
					ply:SetMaxSpeed(500)
					ply:SetRunSpeed(500)
				end)
				ply:SetModel("models/bots/scout_boss/bot_scout_boss.mdl")
				ply:SetModelScale(1.75)
				ply:SetHealth(1600)
				ply:SetMaxHealth(1600)
			elseif ply:GetPlayerClass() == "soldier" then
				timer.Create("GiantRobotSpeed", 0.01, 0, function()
					if not ply:Alive() then timer.Stop("GiantRobotSpeed") return end
					if ply:GetInfoNum("tf_giant_robot", 0) == 0 then timer.Stop("GiantRobotSpeed") return end
					ply:SetClassSpeed(40)
				end)
				ply:SetModel("models/bots/soldier_boss/bot_soldier_boss.mdl")
				ply:SetModelScale(1.75)
				ply:SetHealth(3600)
				ply:SetMaxHealth(3600)
			elseif ply:GetPlayerClass() == "demoman" then
				timer.Create("GiantRobotSpeed", 0.01, 0, function()
					if not ply:Alive() then timer.Stop("GiantRobotSpeed") return end
					if ply:GetInfoNum("tf_giant_robot", 0) == 0 then timer.Stop("GiantRobotSpeed") return end
					ply:SetClassSpeed(40)
					ply:SetPoseParameter("move_x", 1)
				end)
				ply:SetModel("models/bots/demo_boss/bot_demo_boss.mdl")
				ply:SetModelScale(1.75)
				ply:SetHealth(3600)
				ply:SetMaxHealth(3600)
			elseif ply:GetPlayerClass() == "heavy" then
				timer.Create("GiantRobotSpeed", 0.01, 0, function()
					if not ply:Alive() then timer.Stop("GiantRobotSpeed") return end
					if ply:GetInfoNum("tf_giant_robot", 0) == 0 then timer.Stop("GiantRobotSpeed") return end
					ply:SetClassSpeed(40)
					ply:SetPoseParameter("move_x", 1)
				end)
				ply:EmitSound("MVM.GiantHeavyEntrance")
				ply:SetModel("models/bots/heavy_boss/bot_heavy_boss.mdl")
				ply:SetModelScale(1.75)
				ply:SetHealth(5000)
			elseif ply:GetPlayerClass() == "pyro" then
				timer.Create("GiantRobotSpeed", 0.01, 0, function()
					if not ply:Alive() then timer.Stop("GiantRobotSpeed") return end
					if ply:GetInfoNum("tf_giant_robot", 0) == 0 then timer.Stop("GiantRobotSpeed") return end
					ply:SetClassSpeed(40)
					ply:SetPoseParameter("move_x", 1)
				end)
				ply:SetModel("models/bots/pyro_boss/bot_pyro_boss.mdl")
				ply:SetModelScale(1.75)
				ply:SetHealth(3600)
				ply:SetMaxHealth(3600)
			elseif ply:GetPlayerClass() == "medic" then
				timer.Create("GiantRobotSpeed", 0.01, 0, function()
					if not ply:Alive() then timer.Stop("GiantRobotSpeed") return end
					if ply:GetInfoNum("tf_giant_robot", 0) == 0 then timer.Stop("GiantRobotSpeed") return end
					ply:SetClassSpeed(40)
					ply:SetPoseParameter("move_x", 1)
				end)
				ply:SetModel("models/bots/medic/bot_medic.mdl")
				ply:SetModelScale(1.75)
				ply:SetHealth(3600)
				ply:SetMaxHealth(3600)
			end
		end
		if ply:GetInfoNum("tf_zombie", 0) == 1 then
			if ply:GetPlayerClass() == "scout" then
				ply:SetModel("models/lazy_zombies_v2/scout.mdl")
				ply:StripWeapon("tf_weapon_scattergun")
				ply:StripWeapon("tf_weapon_pistol_scout")
			elseif ply:GetPlayerClass() == "gmodplayer" then
				timer.Create("GiantRobotSpeed2", 0.01, 0, function()
					if not ply:Alive() then timer.Stop("GiantRobotSpeed2") return end
					if ply:GetInfoNum("tf_zombie", 0) == 0 then timer.Stop("GiantRobotSpeed2") return end
					ply:SetWalkSpeed(65)
					ply:SetRunSpeed(105)
				end)
				ply:SetModel( table.Random(zombiemodel) )
				ply:StripWeapons()
				ply:Give("weapon_fists")	
			elseif ply:GetPlayerClass() == "soldier" then
				ply:SetModel("models/lazy_zombies_v2/soldier.mdl")
				ply:StripWeapon("tf_weapon_rocketlauncher")
				ply:StripWeapon("tf_weapon_shotgun_soldier")
			elseif ply:GetPlayerClass() == "demoman" then
				ply:SetModel("models/lazy_zombies_v2/demo.mdl")
				ply:StripWeapon("tf_weapon_grenadelauncher")
				ply:StripWeapon("tf_weapon_pipebomblauncher")
			elseif ply:GetPlayerClass() == "heavy" then
				ply:SetModel("models/lazy_zombies_v2/heavy.mdl")
				ply:StripWeapon("tf_weapon_minigun")
				ply:StripWeapon("tf_weapon_shotgun_heavy")
			elseif ply:GetPlayerClass() == "pyro" then
				ply:SetModel("models/lazy_zombies_v2/pyro.mdl")
				ply:StripWeapon("tf_weapon_flamethrower")
				ply:StripWeapon("tf_weapon_shotgun_pyro")
			elseif ply:GetPlayerClass() == "medic" then
				ply:SetModel("models/lazy_zombies_v2/medic.mdl")
				ply:StripWeapon("tf_weapon_syringegun")
				ply:StripWeapon("tf_weapon_medigun")
			elseif ply:GetPlayerClass() == "engineer" then
				ply:SetModel("models/lazy_zombies_v2/engineer.mdl")
				ply:StripWeapon("tf_weapon_shotgun_primary")
				ply:StripWeapon("tf_weapon_pistol")
			elseif ply:GetPlayerClass() == "sniper" then
				ply:SetModel("models/lazy_zombies_v2/sniper.mdl")
				ply:StripWeapon("tf_weapon_sniperrifle")
				ply:StripWeapon("tf_weapon_smg")
			elseif ply:GetPlayerClass() == "spy" then
				ply:SetModel("models/lazy_zombies_v2/spy.mdl")
				ply:StripWeapon("tf_weapon_revolver")
				ply:StripWeapon("tf_weapon_builder")
				ply:StripWeapon("tf_weapon_pda_spy")
			end
		end
		if not ply:IsHL2() and ply:GetInfoNum("tf_voodoo", 0) == 1 then
			if ply:GetPlayerClass() == "scout" then
				ply:SetModel("models/lazy_zombies_v2/scout.mdl")	
			elseif ply:GetPlayerClass() == "soldier" then
				ply:SetModel("models/lazy_zombies_v2/soldier.mdl")
			elseif ply:GetPlayerClass() == "demoman" then
				ply:SetModel("models/lazy_zombies_v2/demo.mdl")
			elseif ply:GetPlayerClass() == "heavy" then
				ply:SetModel("models/lazy_zombies_v2/heavy.mdl")
			elseif ply:GetPlayerClass() == "pyro" then
				ply:SetModel("models/lazy_zombies_v2/pyro.mdl")
			elseif ply:GetPlayerClass() == "medic" then
				ply:SetModel("models/lazy_zombies_v2/medic.mdl")
			elseif ply:GetPlayerClass() == "engineer" then
				ply:SetModel("models/lazy_zombies_v2/engineer.mdl")
				ply:StripWeapon("tf_weapon_pistol")
			elseif ply:GetPlayerClass() == "sniper" then
				ply:SetModel("models/lazy_zombies_v2/sniper.mdl")
			elseif ply:GetPlayerClass() == "spy" then
				ply:SetModel("models/lazy_zombies_v2/spy.mdl")
			end
		end
		if not ply:IsHL2() and ply:GetInfoNum("tf_bigzombie", 0) == 1 then
			ply:SetModelScale(1.85)
			if ply:GetPlayerClass() == "scout" then
				ply:SetModel("models/lazy_zombies_v2/scout.mdl")
				ply:StripWeapon("tf_weapon_scattergun")
				ply:StripWeapon("tf_weapon_pistol_scout")
			elseif ply:GetPlayerClass() == "soldier" then
				ply:SetModel("models/lazy_zombies_v2/soldier.mdl")
				ply:StripWeapon("tf_weapon_rocketlauncher")
				ply:StripWeapon("tf_weapon_shotgun_soldier")
			elseif ply:GetPlayerClass() == "demoman" then
				ply:SetModel("models/lazy_zombies_v2/demo.mdl")
				ply:StripWeapon("tf_weapon_grenadelauncher")
				ply:StripWeapon("tf_weapon_pipebomblauncher")
			elseif ply:GetPlayerClass() == "heavy" then
				ply:SetModel("models/lazy_zombies_v2/heavy.mdl")
				ply:StripWeapon("tf_weapon_minigun")
				ply:StripWeapon("tf_weapon_shotgun_heavy")
			elseif ply:GetPlayerClass() == "pyro" then
				ply:SetModel("models/lazy_zombies_v2/pyro.mdl")
				ply:StripWeapon("tf_weapon_flamethrower")
				ply:StripWeapon("tf_weapon_shotgun_pyro")
			elseif ply:GetPlayerClass() == "medic" then
				ply:SetModel("models/lazy_zombies_v2/medic.mdl")
				ply:StripWeapon("tf_weapon_syringegun")
				ply:StripWeapon("tf_weapon_medigun")
			elseif ply:GetPlayerClass() == "engineer" then
				ply:SetModel("models/lazy_zombies_v2/engineer.mdl")
				ply:StripWeapon("tf_weapon_shotgun_primary")
				ply:StripWeapon("tf_weapon_pistol")
			elseif ply:GetPlayerClass() == "sniper" then
				ply:SetModel("models/lazy_zombies_v2/sniper.mdl")
				ply:StripWeapon("tf_weapon_sniperrifle")
				ply:StripWeapon("tf_weapon_smg")
			elseif ply:GetPlayerClass() == "spy" then
				ply:SetModel("models/lazy_zombies_v2/spy.mdl")
				ply:StripWeapon("tf_weapon_revolver")
				ply:StripWeapon("tf_weapon_builder")
				ply:StripWeapon("tf_weapon_pda_spy")
			end
		end
	
		if not ply:IsHL2() and ply:GetInfoNum("jakey_antlionfbii", 0) == 1 then
			if ply:GetPlayerClass() != "heavy" then ply:SetPlayerClass("heavy") end
			ply:SetModel("models/player/antlion_fbi/antlion_guard.mdl")
			ply:SetHealth(5200)
			ply:SetMaxHealth(5000)
			ply:StripWeapon("tf_weapon_minigun")
			ply:StripWeapon("tf_weapon_shotgun_hwg") 
			ply:SetWalkSpeed(600)
			ply:SetRunSpeed(600)
			ply:SetBloodColor(BLOOD_COLOR_ANTLION)
		end
		if ply:GetInfoNum("dylan_rageheavy", 0) == 1 then
			if !ply:IsAdmin() then return end
			if ply:GetPlayerClass() != "heavy" then ply:SetPlayerClass("heavy") end
			ply:SetHealth(1000000000000)
			ply:SetMaxHealth(1000000000000)
			timer.Create("GiantRobotSpeed", 0.01, 0, function()
				if not ply:Alive() then timer.Stop("GiantRobotSpeed") return end
				if ply:GetInfoNum("dylan_rageheavy", 0) == 0 then timer.Stop("GiantRobotSpeed") return end
				ply:SetWalkSpeed(1250)
				ply:SetMaxSpeed(1250)
				ply:SetRunSpeed(1250)
			end)
		end
		if ply:GetInfoNum("hahahahahahahahaowneronly_ragespy", 0) == 1 then
			if !ply:IsAdmin() then return end
			if ply:GetPlayerClass() != "spy" then ply:SetPlayerClass("spy") end
			ply:SetHealth(1000000000000)
			ply:SetMaxHealth(1000000000000)
			timer.Create("GiantRobotSpeed", 0.01, 0, function()
				if not ply:Alive() then timer.Stop("GiantRobotSpeed") return end
				if ply:GetInfoNum("hahahahahahahahaowneronly_ragespy", 0) == 0 then timer.Stop("GiantRobotSpeed") return end
				ply:SetWalkSpeed(1250)
				ply:SetMaxSpeed(1250)
				ply:SetRunSpeed(1250)
			end)
		end

		if not ply:IsHL2() and ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 1 then
			ply:SetModelScale(1.75)
			if ply:GetPlayerClass() == "scout" then
				timer.Create("GiantRobotSpeed", 0.01, 0, function()
					if not ply:Alive() then timer.Stop("GiantRobotSpeed") return end
					if ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 0 then timer.Stop("GiantRobotSpeed") return end
					ply:SetWalkSpeed(500)
					ply:SetMaxSpeed(500)
					ply:SetRunSpeed(500)
				end)
				ply:SetModel("models/lazy_zombies_v2/scout.mdl")
			elseif ply:GetPlayerClass() == "soldier" then
				timer.Create("GiantRobotSpeed", 0.01, 0, function()
					if not ply:Alive() then timer.Stop("GiantRobotSpeed") return end
					if ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 0 then timer.Stop("GiantRobotSpeed") return end
					ply:SetWalkSpeed(150)
					ply:SetMaxSpeed(150)
					ply:SetRunSpeed(150)
				end)
				ply:SetModel("models/lazy_zombies_v2/soldier.mdl")
			elseif ply:GetPlayerClass() == "demoman" then
				timer.Create("GiantRobotSpeed", 0.01, 0, function()
					if not ply:Alive() then timer.Stop("GiantRobotSpeed") return end
					if ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 0 then timer.Stop("GiantRobotSpeed") return end
					ply:SetWalkSpeed(150)
					ply:SetMaxSpeed(150)
					ply:SetRunSpeed(150)
				end)
				ply:SetModel("models/lazy_zombies_v2/demo.mdl")
			elseif ply:GetPlayerClass() == "heavy" then
				timer.Create("GiantRobotSpeed", 0.01, 0, function()
					if not ply:Alive() then timer.Stop("GiantRobotSpeed") return end
					if ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 0 then timer.Stop("GiantRobotSpeed") return end
					ply:SetWalkSpeed(150)
					ply:SetMaxSpeed(150)
					ply:SetRunSpeed(150)
				end)
				ply:SetModel("models/lazy_zombies_v2/heavy.mdl")
			elseif ply:GetPlayerClass() == "pyro" then
				timer.Create("GiantRobotSpeed", 0.01, 0, function()
					if not ply:Alive() then timer.Stop("GiantRobotSpeed") return end
					if ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 0 then timer.Stop("GiantRobotSpeed") return end
					ply:SetWalkSpeed(150)
					ply:SetMaxSpeed(150)
					ply:SetRunSpeed(150)
				end)
				ply:SetModel("models/lazy_zombies_v2/pyro.mdl")
			elseif ply:GetPlayerClass() == "medic" then
				timer.Create("GiantRobotSpeed", 0.01, 0, function()
					if not ply:Alive() then timer.Stop("GiantRobotSpeed") return end
					if ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 0 then timer.Stop("GiantRobotSpeed") return end
					ply:SetWalkSpeed(150)
					ply:SetMaxSpeed(150)
					ply:SetRunSpeed(150)
				end)
				ply:SetModel("models/lazy_zombies_v2/medic.mdl")
			elseif ply:GetPlayerClass() == "engineer" then
				timer.Create("GiantRobotSpeed", 0.01, 0, function()
					if not ply:Alive() then timer.Stop("GiantRobotSpeed") return end
					if ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 0 then timer.Stop("GiantRobotSpeed") return end
					ply:SetWalkSpeed(150)
					ply:SetMaxSpeed(150)
					ply:SetRunSpeed(150)
				end)
				ply:SetModel("models/lazy_zombies_v2/engineer.mdl")
			elseif ply:GetPlayerClass() == "sniper" then
				timer.Create("GiantRobotSpeed", 0.01, 0, function()
					if not ply:Alive() then timer.Stop("GiantRobotSpeed") return end
					if ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 0 then timer.Stop("GiantRobotSpeed") return end
					ply:SetWalkSpeed(150)
					ply:SetMaxSpeed(150)
					ply:SetRunSpeed(150)
				end)
				ply:SetModel("models/lazy_zombies_v2/sniper.mdl")
			elseif ply:GetPlayerClass() == "spy" then
				timer.Create("GiantRobotSpeed", 0.01, 0, function()
					if not ply:Alive() then timer.Stop("GiantRobotSpeed") return end
					if ply:GetInfoNum("tf_mvm_giant_voodoo", 0) == 0 then timer.Stop("GiantRobotSpeed") return end
					ply:SetWalkSpeed(150)
					ply:SetMaxSpeed(150)
					ply:SetRunSpeed(150)
				end)
				ply:SetModel("models/lazy_zombies_v2/spy.mdl")
			end
		end
		if not ply:IsHL2() and ply:GetInfoNum("tf_mvm_voodoo", 0) == 1 then
			if ply:GetPlayerClass() == "scout" then
				ply:SetModel("models/lazy_zombies_v2/scout.mdl")
			elseif ply:GetPlayerClass() == "soldier" then
				ply:SetModel("models/lazy_zombies_v2/soldier.mdl")
			elseif ply:GetPlayerClass() == "demoman" then
				ply:SetModel("models/lazy_zombies_v2/demo.mdl")
			elseif ply:GetPlayerClass() == "heavy" then
				ply:SetModel("models/lazy_zombies_v2/heavy.mdl")
			elseif ply:GetPlayerClass() == "pyro" then
				ply:SetModel("models/lazy_zombies_v2/pyro.mdl")
			elseif ply:GetPlayerClass() == "medic" then
				ply:SetModel("models/lazy_zombies_v2/medic.mdl")
			elseif ply:GetPlayerClass() == "engineer" then
				ply:SetModel("models/lazy_zombies_v2/engineer.mdl")
			elseif ply:GetPlayerClass() == "sniper" then
				ply:SetModel("models/lazy_zombies_v2/sniper.mdl")
			elseif ply:GetPlayerClass() == "spy" then
				ply:SetModel("models/lazy_zombies_v2/spy.mdl")
			end
		end
	end)
end

hook.Add( "PlayerSpawn", "PlayerGiantRoBotSpawn", PlayerGiantBotSpawn)

concommand.Add("changeclass", function(pl, cmd, args)
	if pl:Team()==TEAM_SPECTATOR then return end
	if pl:GetObserverMode() ~= OBS_MODE_NONE then pl:Spectate(OBS_MODE_NONE) end
	if pl:Alive() and GetConVar("tf_kill_on_change_class"):GetInt() ~= 0 then pl:Kill() end	
	--if GetConVar("tf_kill_on_change_class"):GetInt() ~= 0 then pl:SetPlayerClass("gmodplayer") end
	pl:SetPlayerClass(args[1])
end, function() return GAMEMODE.PlayerClassesAutoComplete end)

concommand.Add( "changeteam", function( pl, cmd, args )
	--if ( tonumber( args[ 1 ] ) >= 5 and args[ 1 ] ~= 1002 ) then return end
	if ( tonumber( args[ 1 ] ) == 0 or tonumber( args[ 1 ] ) == 3 ) then pl:ChatPrint("Invalid Team!") return end
	if ( pl:Team() == tonumber( args[ 1 ] ) ) then return false end
	if ( GetConVar("tf_competitive"):GetBool() and tonumber( args[ 1 ] ) == 4 ) then pl:ChatPrint("Competitive mode is on!") return end
	if ( string.find(game.GetMap(), "mvm_") and tonumber( args[ 1 ] ) == 4 ) then pl:ChatPrint("Neutral Team is disabled!") return end

	if ( GetConVar("tf_disable_nonred_mvm"):GetBool() and string.find(game.GetMap(), "syn_") and tonumber( args[ 1 ] ) == 2 ) and !pl:IsAdmin() then pl:ChatPrint("Blue Team is disabled!") return end
	if ( GetConVar("tf_disable_nonred_mvm"):GetBool() and string.find(game.GetMap(), "bb_coop_") and tonumber( args[ 1 ] ) == 2 ) and !pl:IsAdmin() then pl:ChatPrint("Blue Team is disabled!") return end
	if ( GetConVar("tf_disable_nonred_mvm"):GetBool() and string.find(game.GetMap(), "cl_coop_") and tonumber( args[ 1 ] ) == 2 ) and !pl:IsAdmin() then pl:ChatPrint("Blue Team is disabled!") return end
	if ( GetConVar("tf_disable_nonred_mvm"):GetBool() and string.find(game.GetMap(), "js_coop_") and tonumber( args[ 1 ] ) == 2 ) and !pl:IsAdmin() then pl:ChatPrint("Blue Team is disabled!") return end
	if ( GetConVar("tf_disable_nonred_mvm"):GetBool() and string.find(game.GetMap(), "coop_") and tonumber( args[ 1 ] ) == 2 ) and !pl:IsAdmin() then pl:ChatPrint("Blue Team is disabled!") return end
	if ( GetConVar("tf_disable_nonred_mvm"):GetBool() and string.find(game.GetMap(), "mvm_") and tonumber( args[ 1 ] ) == 2 ) and !pl:IsAdmin() then pl:ChatPrint("Blue Team is disabled!") return end
	if pl:Team() == TEAM_SPECTATOR then
		pl:KillSilent()
	end
	pl:SetTeam( tonumber( args[ 1 ] ) )  
	timer.Simple(0.3, function() if !IsValid(pl) then return end pl:SendLua("chat.AddText( Color( 235, 226, 202 ), 'Player ', LocalPlayer():Nick(), ' joined team ', team.GetName(LocalPlayer():Team()) )") end)
	if pl:Alive() then pl:Kill() end 
end )


local SpawnableItems = {
	"item_ammopack_small",
	"item_ammopack_medium",
	"item_ammopack_full",
	"item_healthkit_small",
	"item_healthkit_medium",
	"item_healthkit_full",
	"item_duck",
}

hook.Add("InitPostEntity", "TF_InitSpawnables", function()
	local base = scripted_ents.GetStored("item_base")
	if not base or not base.t or not base.t.SpawnFunction then return end
	
	for _,v in ipairs(SpawnableItems) do
		local ent = scripted_ents.GetStored(v)
		if ent and ent.t then
			ent.t.SpawnFunction = base.t.SpawnFunction
		end
	end
end)

function GM:PlayerInitialSpawn(ply)
	ply:SetTeam(TEAM_RED)
	ply:KillSilent()
	-- Wait until InitPostEntity has been called
	if not self.PostEntityDone then
		timer.Simple(0.05, function() self:PlayerInitialSpawn(ply) end)
		return
	end
	
	Msg("PlayerInitialSpawn : "..ply:GetName().." "..tostring(self.Landmark).."\n")
	if self.Landmark then--and self.Landmark:IsValidMap() then
		self.Landmark:LoadPlayerData(ply)
	end
end

function GM:OnPlayerChangedTeam(ply, oldteam, newteam)
	if newteam == TEAM_SPECTATOR then
		ply:SetTeam(TEAM_RED)
		local Pos = ply:EyePos()
		ply:Spawn()
		ply:SetPos( Pos )
	elseif oldteam == TEAM_SPECTATOR then
		ply:Spawn()
	end
 
	PrintMessage(HUD_PRINTTALK, Format("%s joined '%s'", ply:Nick(), team.GetName(newteam)))
	
	self:ClearDominations(ply)
	self:UpdateEntityRelationship(ply)
end

local function CanSpawn(ply) if ply:Team() == TEAM_SPECTATOR or GetConVar("tf_competitive"):GetBool() then return false end return true end

function GM:CanPlayerSuicide(ply)
	if ply:Team() == TEAM_SPECTATOR then return false end
	return true
end

function GM:PlayerSpawnSWEP(ply)
	return CanSpawn(ply)
end

function GM:PlayerSpawnVehicle(ply)
	return CanSpawn(ply)
end

function GM:PlayerSpawnNPC(ply)
	return CanSpawn(ply)
end

function GM:PlayerSpawnSENT(ply)
	return CanSpawn(ply)
end

function GM:PlayerSpawnObject(ply)
	return CanSpawn(ply)
end

function RandomWeapon(ply, wepslot)
	local weps = tf_items.ReturnItems()
	local validweapons = {}
	for k, v in pairs(weps) do
		if v and istable(v) and isstring(wepslot) and v["name"] and v["item_slot"] == wepslot and !string.StartWith(v["name"], "Australium") and v["craft_class"] == "weapon" then
			PrintTable(v)
			table.insert(validweapons, v["name"])
		end
	end

	local wep = table.Random(validweapons)

	ply:PrintMessage(HUD_PRINTTALK, "You were given " .. wep .. "!")
	ply:EquipInLoadout(wep)
end

-- by hl2 campaign https://github.com/daunknownfox2010/half-life-2-campaign/blob/master/gamemode/init.lua but edited
function GM:EntityKeyValue( ent, key, value )

	if ( ( ent:GetClass() == "trigger_changelevel" ) && ( key == "map" ) ) then
	
		ent.map = value
	
	end

	if ( ( ent:GetClass() == "npc_combine_s" ) && ( key == "additionalequipment" ) && ( value == "weapon_shotgun" ) ) then
	
		ent:SetSkin( 1 )
	 
	end

end

concommand.Add("changelevel2", function(ply,com,arg) 
    if ply:IsValid() then return end --only let server console access this command
    RunConsoleCommand("changelevel", arg[1])
end)


if ( file.Exists( "teamfortress/gamemode/maps/"..game.GetMap()..".lua", "LUA" ) ) then

	include( "maps/"..game.GetMap()..".lua" )

end

-- Called by GoToNextLevel
function GM:GrabAndSwitch()

	changingLevel = true

	game.ConsoleCommand( "changelevel "..NEXT_MAP.."\n" )

end


function GM:ShouldDrawWorldModel(pl) 
	
	if pl:GetNWBool("NoWeapon") == true then 
		if SERVER then
			pl:GetActiveWeapon().WModel2:SetNoDraw(true)
		end
		return false 
	end
	if SERVER then
		pl:GetActiveWeapon().WModel2:SetNoDraw(false)
	end
	return true
end

function GM:PlayerButtonDown( pl, key )
	if key == KEY_G then
		pl:ConCommand("tf_taunt "..pl:GetActiveWeapon():GetSlotPos())
		print("taunt")
		print(pl:GetActiveWeapon():GetSlot())
	end
	if key == KEY_Z then
		pl:ConCommand("voice_menu_1") 
	end
	if key == KEY_X then
		pl:ConCommand("voice_menu_2") 
	end
	if key == KEY_C then
		pl:ConCommand("voice_menu_3") 
	end
	if key == KEY_COMMA then
		pl:ConCommand("tf_changeclass")
	end
	if key == KEY_M then
		pl:ConCommand("gm_showspare2")
	end
	if key == KEY_N then
		pl:ConCommand("gm_showspare1")
	end
	if key == KEY_PERIOD then
		pl:ConCommand("tf_changeteam")
	end
end

function RandomWeapon2(ply, wepslot)
	local weps = tf_items.ReturnItems()
	local class = ply:GetPlayerClass()
	local validweapons = {}
	for k, v in pairs(weps) do
		if v and istable(v) and isstring(wepslot) and v["name"] and v["item_slot"] == wepslot and v["used_by_classes"] and v["used_by_classes"][class] and !string.StartWith(v["name"], "Australium") and v["craft_class"] == "weapon" then
			table.insert(validweapons, v["name"])
		end
	end

	local wep = table.Random(validweapons)
	ply:EquipInLoadout(wep)
end

function RandomWeapon(ply, wepslot)
	local weps = tf_items.ReturnItems()
	local validweapons = {}
	for k, v in pairs(weps) do
		if v and istable(v) and isstring(wepslot) and v["name"] and v["item_slot"] == wepslot and !string.StartWith(v["name"], "Australium") and v["craft_class"] == "weapon" then
			PrintTable(v)
			table.insert(validweapons, v["name"])
		end
	end

	local wep = table.Random(validweapons)

	ply:PrintMessage(HUD_PRINTTALK, "You were given " .. wep .. "!")
	ply:ConCommand("giveitem " .. wep)
end

concommand.Add("randomweapon", function(ply, _, args)
	if !args[1] then
		local random = math.random(1, 3)
		if random == 1 then
			RandomWeapon(ply, "primary")
		elseif random == 2 then
			RandomWeapon(ply, "secondary")
		elseif random == 3 then
			RandomWeapon(ply, "melee")
		end
	else
		RandomWeapon(ply, args[1])
	end
end)

function GM:MouthMoveAnimation( ply )

	local flexes = {
		ply:GetFlexIDByName( "jaw_drop" ),
		ply:GetFlexIDByName( "left_part" ),
		ply:GetFlexIDByName( "right_part" ),
		ply:GetFlexIDByName( "left_mouth_drop" ),
		ply:GetFlexIDByName( "right_mouth_drop" )
	}
	
	local flexes2 ={
		ply:GetFlexIDByName( "ah" )
	}
	
	local weight = ply:IsSpeaking() && math.Clamp( ply:VoiceVolume() * 2, 0, 2 ) || 0

	for k, v in pairs( flexes ) do
		if ply:IsHL2() then
			ply:SetFlexWeight( v, weight )
		end

	end

	for k, v in pairs( flexes2 ) do

		if not ply:IsHL2() then
			ply:SetFlexWeight( v, weight )
		end

	end
end


function GM:PlayerSpawn(ply)
	if ply.CPPos and ply.CPAng then
		ply:SetPos(ply.CPPos)
		ply:SetEyeAngles(ply.CPAng)
	end 
	ply:SetNoCollideWithTeammates( true )
	if ply:GetPlayerClass() == "soldierbuffed" then 
		timer.Simple(0.8, function()
			ply:SelectWeapon("tf_weapon_buff_item_conch")
			ply:GetActiveWeapon():PrimaryAttack()
		end)
	end
	if ply:GetPlayerClass() == "engineer" and ply:IsBot() and string.find(game.GetMap(), "mvm_") then 
		timer.Simple(0.1, function()
			ply:SelectWeapon("tf_weapon_wrench")
		end)
		timer.Simple(0.8, function()
			ply:Build(2,0)
		end)
	end
	--ply:ShouldDropWeapon(true)
	--[[ply:SetNWBool("ShouldDropBurningRagdoll", false)
	ply:SetNWBool("ShouldDropDecapitatedRagdoll", false)
	ply:SetNWBool("DeathByHeadshot", false)]]
	ply:ResetDeathFlags()
	ply:EnablePhonemes()
	ply.LastWeapon = nil
	self:ResetKills(ply)
	self:ResetDamageCounter(ply)
	self:ResetCooperations(ply)
	self:StopCritBoost(ply)
	for k,v in ipairs(ents.FindByClass("trigger_weapon_strip")) do
		if IsValid(v) then
			v:Fire("Kill", "", 0.1)
		end
	end
	for k,v in ipairs(ents.FindByClass("player_weaponstrip")) do
		if IsValid(v) then
			v:Fire("Kill", "", 0.1)
		end
	end
	ply:UnSpectate()
	-- Reinitialize class
	if ply:GetPlayerClass()=="" then
		ply:ConCommand("tf_changeclass")
		ply:SetPlayerClass("gmodplayer")
		--ply:Spectate(OBS_MODE_FIXED)
		--ply:StripWeapons()
	--[[elseif ply:GetPlayerClass()=="sniper" then -- dumb hack wtf??
		ply:SetPlayerClass("scout")
		timer.Simple(0.1, function()
			if IsValid(ply) then
				ply:SetPlayerClass("sniper")
			end
		end)
		if ply:GetObserverMode() ~= OBS_MODE_NONE then
			ply:UnSpectate()
		end]]
	elseif ply:GetPlayerClass()=="sniper" then
		ply:SetPlayerClass("scout")
		ply:SetPlayerClass("sniper")
		timer.Simple(0.1, function()
			ply:SetPlayerClass("sniper")
		end)
	else
		timer.Simple(0.1, function() -- god i'm such a timer whore
			ply:SetPlayerClass(ply:GetPlayerClass())
		end)

		if ply:GetObserverMode() ~= OBS_MODE_NONE then
			ply:UnSpectate()
		end
	end
	
	if ply:Team()==TEAM_SPECTATOR then
		GAMEMODE:PlayerSpawnAsSpectator( ply )
	end
	
	if ply:IsHL2() then
		ply:SetupHands()
		ply:EquipSuit()
		ply:AllowFlashlight(true)
	end
	
	if !ply:IsHL2() then
		ply:AllowFlashlight(GetConVar("tf_flashlight"):GetBool())

		if ply:Team()==TEAM_BLU then
			ply:SetSkin(1)
		else
			ply:SetSkin(0)
		end

		for k, v in pairs(ents.FindByClass('tf_wearable_item')) do
			if v:GetClass() == 'tf_wearable_item' then
				if v:GetOwner() == ply and string.find(v:GetModel(), "zombie") then
					if ply:Team()==TEAM_BLU then
						ply:SetSkin(5)
					else
						ply:SetSkin(4)
					end
				end
			end
		end
	end

	ply:Speak("TLK_PLAYER_EXPRESSION", true)

	local playercolorconv = ply:GetInfo("cl_playercolor")
	local weaponcolorconv = ply:GetInfo("cl_weaponcolor")
	local playercolor = Vector(string.sub(playercolorconv, 1, 8), string.sub(playercolorconv, 10, 17), string.sub(playercolorconv, 19, 26))
	local weaponcolor = Vector(string.sub(weaponcolorconv, 1, 8), string.sub(weaponcolorconv, 10, 17), string.sub(weaponcolorconv, 19, 26))

	ply:SetPlayerColor(playercolor)
	ply:SetWeaponColor(weaponcolor)
	ply:SetAvoidPlayers(true)
	
	if GetConVar("tf_randomizer"):GetBool() and !ply:IsHL2() then
		RandomWeapon(ply, "primary")
		RandomWeapon(ply, "secondary")
		RandomWeapon(ply, "melee")
	end

	umsg.Start("ExitFreezecam", ply)
	umsg.End()
end

function GM:PlayerSetHandsModel( ply, ent )
	local simplemodel = player_manager.TranslateToPlayerModelName( ply:GetModel() )
	local info = player_manager.TranslatePlayerHands( simplemodel )
	if ( info ) then
		if ply:IsHL2() then
			ent:SetModel( info.model )
			ent:SetSkin( info.skin )
			ent:SetBodyGroups( info.body )
		else
			ent:SetModel( "models/weapons/c_arms_animations.mdl" )
			ent:SetSkin( info.skin )
			ent:SetBodyGroups( info.body )
		end
	end
end

-- Fixing spawning at the wrong spawnpoint on HL2 maps
function GM:PlayerSelectSpawn(pl)
	if self.MasterSpawn==nil then
		self.MasterSpawn = false
		for _,v in pairs(ents.FindByClass("info_player_start")) do
			if v.IsMasterSpawn then
				self.MasterSpawn = v
				break
			end
		end
	end
	
	if self.MasterSpawn then
		return self.MasterSpawn
	end

	local spawnsred = {}
	local spawnsblu = {}

	for k, v in pairs(ents.FindByClass("info_player_teamspawn")) do
		--print(v, "says")
		if v:GetKeyValues()["StartDisabled"] == 0 then
		if v:GetKeyValues()["TeamNum"] == 3 then
			table.insert(spawnsblu, v)
		elseif v:GetKeyValues()["TeamNum"] == 2 then
			table.insert(spawnsred, v)
		end
		end
	end


	if pl:Team() == TEAM_RED and IsValid(spawnsred[1]) then
		return table.Random(spawnsred)
	elseif pl:Team() == TEAM_BLU and IsValid(spawnsblu[1]) then
		return table.Random(spawnsblu)
	end
	
	return self.BaseClass:PlayerSelectSpawn(pl)
end

local PlayerGiveAmmoTypes = {TF_PRIMARY, TF_SECONDARY, TF_METAL}
function GM:GiveAmmoPercent(pl, pc, nometal)
	--Msg("Giving "..pc.."% ammo to "..pl:GetName().." : ")
	local ammo_given = false
	
	for _,v in ipairs(PlayerGiveAmmoTypes) do
		if not nometal or v ~= TF_METAL then
			if pl:GiveTFAmmo(pc * 0.01, v, true) then
				ammo_given = true
			end
		end
	end
	
	--Msg("\n")
	if ammo_given then
		if pl:GetActiveWeapon().CheckAutoReload then
			pl:GetActiveWeapon():CheckAutoReload()
		end
	end
	
	return ammo_given
end

function GM:GiveAmmoPercentNoMetal(pl, pc)
	return self:GiveAmmoPercent(pl, pc, true)
end

function GM:GiveHealthPercent(pl, pc)
	return pl:GiveHealth(pc * 0.01, true)
end

function GM:ShowHelp(ply)
	ply:ConCommand("tf_hatpainter")
end

function GM:ShowTeam(ply)
	ply:ConCommand("tf_menu")
end

function GM:ShowSpare1(ply)
	ply:ConCommand("tf_itempicker hat")
end

function GM:ShowSpare2(ply)
	ply:ConCommand("tf_itempicker wep")
end

function GM:HealPlayer(healer, pl, h, effect, allowoverheal)
	local health_given = pl:GiveHealth(h, false, allowoverheal)
	--print(health_given)
	if effect then
		if pl:IsPlayer() then
			umsg.Start("PlayerHealthBonus", pl)
				umsg.Short(h)
			umsg.End()
			
			umsg.Start("PlayerHealthBonusEffect")
				umsg.Long(pl:UserID())
				umsg.Bool(h>0)
			umsg.End()
		else
			umsg.Start("EntityHealthBonusEffect")
				umsg.Entity(pl)
				umsg.Bool(h>0)
			umsg.End()
		end
	end
	
	if health_given <= 0 then return end
	if not healer or not healer:IsPlayer() then return end
	
	healer.AddedHealing = (healer.AddedHealing or 0) + health_given
	healer.HealingScoreProgress = (healer.HealingScoreProgress or 0) + health_given
end

-- Deprecated, use HealPlayer instead
function GM:GiveHealthBonus(pl, h, allowoverheal)
	pl:GiveHealth(h, false, allowoverheal)
	
	if pl:IsPlayer() then
		umsg.Start("PlayerHealthBonus", pl)
			umsg.Short(h)
		umsg.End()
		
		umsg.Start("PlayerHealthBonusEffect")
			umsg.Long(pl:UserID())
			umsg.Bool(h>0)
		umsg.End()
	else
		umsg.Start("EntityHealthBonusEffect")
			umsg.Entity(pl)
			umsg.Bool(h>0)
		umsg.End()
	end
	
	return true
end

file.Append(LOGFILE, Format("Done loading, time = %f\n", SysTime() - load_time))
local load_time = SysTime()

//Half-Life 2 Campaign

// Include the configuration for this map
function GM:GrabAndSwitch()
	for _, pl in pairs(player.GetAll()) do
		local plInfo = {}
		local plWeapons = pl:GetWeapons()
		
		plInfo.predicted_map = NEXT_MAP
		plInfo.health = pl:Health()
		plInfo.armor = pl:Armor()
		plInfo.score = pl:Frags()
		plInfo.deaths = pl:Deaths()
		plInfo.model = pl.modelName
		
		if plWeapons && #plWeapons > 0 then
			plInfo.loadout = {}
			
			for _, wep in pairs(plWeapons) do
				plInfo.loadout[wep:GetClass()] = {pl:GetAmmoCount(wep:GetPrimaryAmmoType()), pl:GetAmmoCount(wep:GetSecondaryAmmoType())}
			end
		end
		
		file.Write("tf2_userid_info/tf2_userid_info_"..pl:UniqueID()..".txt", util.TableToKeyValues(plInfo))
	end
	
	-- Crash Recovery --
	if game.IsDedicated(true) then
		local savedMap = {}
		
		savedMap.predicted_crash = NEXT_MAP
		
		file.Write("tf2_data/tf2_crash_recovery.txt", util.TableToKeyValues(savedMap))
	end
	-- End --
	
	// Switch maps
	game.ConsoleCommand("changelevel "..NEXT_MAP.."\n")
end

if file.Exists("tf2/maps/"..game.GetMap()..".lua", "LUA") then
	include("tf2/maps/"..game.GetMap()..".lua")
elseif file.Exists("maps/"..game.GetMap()..".lua", "LUA") then
	include("maps/"..game.GetMap()..".lua")
end

//Disables use key on objects (Can Be Re-enabled)
RunConsoleCommand("sv_playerpickupallowed", "0")
//Sets the gravity to 800 (Can be set back to default "600")
RunConsoleCommand("sv_gravity", "700")
//Sets to a impact force similar to TF2 so things to go flying balls of the walls!
RunConsoleCommand("phys_impactforcescale", "0.05")
//Ditto
//RunConsoleCommand("phys_pushscale", "0.10")

function GM:PlayerNoClip( pl )
	if GetConVar("sbox_noclip"):GetInt() <= 0 then
		return
	end

	if pl:Team() == TEAM_SPECTATOR then
		return false
	else
		return true
	end
end

function GM:EntityRemoved(ent, ply)
	if ent:GetClass() == "item_battery" then
		ent:Remove("item_battery")
	end
end

function GM:PlayerRequestTeam( ply, teamid )
	-- This team isn't joinable
	if ( !team.Joinable( teamid ) or teamid == 0 or teamid == 3 ) then
		ply:ChatPrint( "You can't join that team" )
	return end

	-- This team isn't joinable
	if ( !GAMEMODE:PlayerCanJoinTeam( ply, teamid ) ) then
		-- Messages here should be outputted by this function
	return end

	GAMEMODE:PlayerJoinTeam( ply, teamid )
end

function GM:PlayerCanJoinTeam( ply, teamid )
	--print("Requested "..teamid.." for "..ply:GetName().."!".." (aka team "..team.GetName(teamid).."!)")
	local TimeBetweenSwitches = GAMEMODE.SecondsBetweenTeamSwitches or 5
	if ( ply.LastTeamSwitch && RealTime()-ply.LastTeamSwitch < TimeBetweenSwitches ) then
		ply.LastTeamSwitch = ply.LastTeamSwitch + 1
		ply:ChatPrint( Format( "Please wait %i more seconds before trying to change team again!", ( TimeBetweenSwitches - ( RealTime() - ply.LastTeamSwitch ) ) + 1 ) )
		return false
	end

	-- Already on this team!
	if ( ply:Team() == teamid ) then
		ply:ChatPrint( "You're already on that team" )
		return false
	end

	return true
end

-- Networking
util.AddNetworkString("UpdateLoadout")

function GM:PlayerDroppedWeapon(ply)
	if IsValid(ply) and ply:IsPlayer() and !ply:IsHL2() then
		net.Start("UpdateLoadout")
		net.Send(ply)
	end
end