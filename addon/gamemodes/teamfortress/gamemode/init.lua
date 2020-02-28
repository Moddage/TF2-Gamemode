include("sv_clientfiles.lua")
include("sv_resource.lua")
include("sv_response_rules.lua")

include("shared.lua")
include("sv_hl2replace.lua")
include("sv_gamelogic.lua")
include("sv_damage.lua")
include("sv_death.lua")
include("sv_ctf_bots.lua")
include("sv_chat.lua")
include("shd_taunts.lua")

local LOGFILE = "teamfortress/log_server.txt"
file.Delete(LOGFILE)
file.Append(LOGFILE, "Loading serverside script\n")
local load_time = SysTime()

include("sv_npc_relationship.lua")
include("sv_ent_substitute.lua")

response_rules.Load("talker/tf_response_rules.txt")
response_rules.Load("talker/demoman_custom.txt")
response_rules.Load("talker/heavy_custom.txt")

CreateConVar( "tf_use_hl_hull_size", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether or not players use the HL2 hull size found on coop." )
CreateConVar( "tf_kill_on_change_class", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether or not players will die if they change class." )
CreateConVar( "tf_flashlight", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether or not players will have a flashlight as a TF2 Class" )

-- Quickfix for Valve's typo in tf_reponse_rules.txt
response_rules.AddCriterion([[criterion "WeaponIsScattergunDouble" "item_name" "The Force-a-Nature" "required" weight 10]])

--concommand.Add("lua_pick", function(pl, cmd, args)
--	getfenv()[args[1]] = pl:GetEyeTrace().Entity
--end)

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

function GM:PlayerSpawn(ply)
	if ply.CPPos and ply.CPAng then
		ply:SetPos(ply.CPPos)
		ply:SetEyeAngles(ply.CPAng)
	end
	
	--ply:ShouldDropWeapon(true)
	--[[ply:SetNWBool("ShouldDropBurningRagdoll", false)
	ply:SetNWBool("ShouldDropDecapitatedRagdoll", false)
	ply:SetNWBool("DeathByHeadshot", false)]]
	ply:ResetDeathFlags()
	
	ply.LastWeapon = nil
	self:ResetKills(ply)
	self:ResetDamageCounter(ply)
	self:ResetCooperations(ply)
	self:StopCritBoost(ply)
	
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
	ply:SetNoCollideWithTeammates(true)
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