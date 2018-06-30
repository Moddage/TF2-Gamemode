--[[
local old_include = include

function include(name)
	local time_start = SysTime()
	old_include(name)
	MsgN(Format("Included Lua file '%s', %f secs to load", name, SysTime() - time_start))
end
]]
HOOK_WARNING_THRESHOLD = 0.1

local old_hook_call = hook.Call
function hook.Call(name, gm, ...)
	if HOOK_WARNING_THRESHOLD then
		local time_start = SysTime()
		local res = {old_hook_call(name, gm, ...)}
		local time = SysTime() - time_start
		
		if time > HOOK_WARNING_THRESHOLD then
			MsgFN("Warning: hook '%s' took %f seconds to execute!", name, time)
		end
		
		return unpack(res)
	else
		return old_hook_call(name, gm, ...)
	end
end

if not util.PrecacheModel0 then
	util.PrecacheModel0 = util.PrecacheModel
end

function util.PrecacheModel(mdl)
	if SERVER and game.SinglePlayer() then return end
	return util.PrecacheModel0(mdl)
end

include("particle_manifest.lua")
include("vmatrix_extension.lua")

include("shd_nwtable.lua")
include("shd_utils.lua")
include("shd_enums.lua")
include("tf_util_module.lua")
include("tf_item_module.lua")
include("tf_timer_module.lua")
include("tf_soundscript_module.lua")

include("shd_objects.lua")
include("shd_attributes.lua")
include("shd_loadout.lua")
include("shd_extras.lua")

--include("shd_items_temp.lua")

include("shd_maptypes.lua")
include("shd_playeranim.lua")

include("shd_criticals.lua")

include("shd_ragdolls.lua")
tf_soundscript.Load("teamfortress/scripts/game_sounds_weapons_tf.txt")

function GM:PostTFLibsLoaded()
end

hook.Call("PostTFLibsLoaded", GM)

GM.Name 		= "Team Fortress 2"
GM.Author 		= "_Kilburn; Fixed by wango911; Ported by Jcw87; Workshopped by Agent Agrimar"
GM.Email 		= "N/A"
GM.Website 		= "N/A"
GM.TeamBased 	= true

GM.Data = {}

DEFINE_BASECLASS("gamemode_sandbox")
DeriveGamemode("sandbox")
GM.IsSandboxDerived = true

function GM:GetGameDescription()
	return self.Name
end

local VoiceMenuChatMessage = {
	["TLK_PLAYER_MEDIC"] = 			"#Voice_Menu_Medic",
	["TLK_PLAYER_THANKS"] = 		"#Voice_Menu_Thanks",
	["TLK_PLAYER_GO"] = 			"#Voice_Menu_Go",
	["TLK_PLAYER_MOVEUP"] = 		"#Voice_Menu_MoveUp",
	["TLK_PLAYER_LEFT"] = 			"#Voice_Menu_Left",
	["TLK_PLAYER_RIGHT"] = 			"#Voice_Menu_Right",
	["TLK_PLAYER_YES"] = 			"#Voice_Menu_Yes",
	["TLK_PLAYER_NO"] = 			"#Voice_Menu_No",
	["TLK_PLAYER_INCOMING"] = 		"#Voice_Menu_Incoming",
	["TLK_PLAYER_CLOAKEDSPY"] = 	"#Voice_Menu_CloakedSpy",
	["TLK_PLAYER_SENTRYAHEAD"] = 	"#Voice_Menu_SentryAhead",
	["TLK_PLAYER_ACTIVATECHARGE"] = "#Voice_Menu_ActivateCharge",
	["TLK_PLAYER_HELP"] = 			"#Voice_Menu_Help",
}

local VoiceMenuGesture = {
	["TLK_PLAYER_MEDIC"] =			ACT_MP_GESTURE_VC_HANDMOUTH,
	["TLK_PLAYER_THANKS"] =			ACT_MP_GESTURE_VC_THUMBSUP,
	["TLK_PLAYER_GO"] =				ACT_MP_GESTURE_VC_FINGERPOINT,
	["TLK_PLAYER_MOVEUP"] =			ACT_MP_GESTURE_VC_FINGERPOINT,
	["TLK_PLAYER_LEFT"] =			ACT_MP_GESTURE_VC_FINGERPOINT,
	["TLK_PLAYER_RIGHT"] =			ACT_MP_GESTURE_VC_FINGERPOINT,
	["TLK_PLAYER_YES"] =			nil,
	["TLK_PLAYER_NO"] =				nil,
	["TLK_PLAYER_INCOMING"] =		ACT_MP_GESTURE_VC_HANDMOUTH,
	["TLK_PLAYER_CLOAKEDSPY"] =		nil,
	["TLK_PLAYER_SENTRYAHEAD"] =	ACT_MP_GESTURE_VC_FINGERPOINT,
	["TLK_PLAYER_TELEPORTERHERE"] =	nil,
	["TLK_PLAYER_DISPENSERHERE"] =	nil,
	["TLK_PLAYER_SENTRYHERE"] =		nil,
	["TLK_PLAYER_ACTIVATECHARGE"] =	nil,
	["TLK_PLAYER_CHARGEREADY"] =	ACT_MP_GESTURE_VC_THUMBSUP,
	["TLK_PLAYER_HELP"] =			ACT_MP_GESTURE_VC_HANDMOUTH,
	["TLK_PLAYER_BATTLECRY"] =		ACT_MP_GESTURE_VC_FISTPUMP,
	["TLK_PLAYER_CHEERS"] =			ACT_MP_GESTURE_VC_FISTPUMP,
	["TLK_PLAYER_JEERS"] =			nil,
	["TLK_PLAYER_POSITIVE"] =		nil,
	["TLK_PLAYER_NEGATIVE"] =		nil,
	["TLK_PLAYER_NICESHOT"] =		ACT_MP_GESTURE_VC_THUMBSUP,
	["TLK_PLAYER_GOODJOB"] =		ACT_MP_GESTURE_VC_THUMBSUP,
}

concommand.Remove("__svspeak")

concommand.Add( "changeteam", function( pl, cmd, args )
	if tonumber( args[ 1 ] ) >= 5 then return end
	hook.Call( "PlayerRequestTeam", GAMEMODE, pl, tonumber( args[ 1 ] ) )
end )

if SERVER then

concommand.Add("__svspeak", function(pl,_,args)
	if pl:Speak(args[1]) then
		if VoiceMenuGesture[args[1]] then
			pl:DoAnimationEvent(VoiceMenuGesture[args[1]], true)
		end
		
		umsg.Start("TFPlayerVoice")
			umsg.Entity(pl)
			umsg.String(args[1])
		umsg.End()
	end
end)

else

usermessage.Hook("TFPlayerVoice", function(msg)
	local pl = msg:ReadEntity()
	local voice = msg:ReadString()
	
	if not IsValid(pl) or not pl:IsPlayer() then return end
	if pl:Team() ~= TEAM_SPECTATOR and pl:Team() ~= LocalPlayer():Team() then return end
	
	local v = VoiceMenuChatMessage[voice]
	if not v then return end
	
	chat.AddText(
		team.GetColor(pl:Team()),
		Format("(%s) %s", tf_lang.GetRaw("#Voice"), pl:GetName()),
		color_white,
		Format(": %s", tf_lang.GetRaw(v))
	)
end)

end

GIBS_DEMOMAN_START	= 1
GIBS_ENGINEER_START	= 7
GIBS_HEAVY_START	= 14
GIBS_MEDIC_START	= 21
GIBS_PYRO_START		= 29
GIBS_SCOUT_START	= 37
GIBS_SNIPER_START	= 46
GIBS_SOLDIER_START	= 53
GIBS_SPY_START		= 61
GIBS_ORGANS_START	= 68
GIBS_SILLY_START	= 69
GIBS_LAST			= 87

GIB_UNKNOWN		= -1
GIB_HAT			= 0
GIB_LEFTLEG		= 1
GIB_RIGHTLEG	= 2
GIB_LEFTARM		= 3
GIB_RIGHTARM	= 4
GIB_TORSO		= 5
GIB_TORSO2		= 6
GIB_EQUIPMENT1	= 7
GIB_EQUIPMENT2	= 8
GIB_HEAD		= 9
GIB_HEADGEAR1	= 10
GIB_HEADGEAR2	= 11
GIB_ORGAN		= 12

TEAM_RED = 1
TEAM_BLU = 2
TEAM_HIDDEN = 3
TEAM_NEUTRAL = 4

TeamSecondaryColors = {}
function SetTeamSecondaryColor(t, c)
	TeamSecondaryColors[t] = c
end

function GetTeamSecondaryColor(t)
	return TeamSecondaryColors[t] or team.GetColor(t)
end

function GM:CreateTeams()
	team.SetUp(TEAM_RED, "RED Team", Color(255, 64, 64))
	SetTeamSecondaryColor(TEAM_RED, Color(180, 92, 77))
	team.SetSpawnPoint(TEAM_RED, "info_player_start")
	
	team.SetUp(TEAM_BLU, "BLU Team", Color(153, 204, 255))
	SetTeamSecondaryColor(TEAM_BLU, Color(104, 124, 155))
	team.SetSpawnPoint(TEAM_BLU, "info_player_start")
	
	team.SetUp(TEAM_NEUTRAL, "NEUTRAL Team", Color(110, 255, 80))
	SetTeamSecondaryColor(TEAM_NEUTRAL, Color(74, 130, 54))
	team.SetSpawnPoint(TEAM_NEUTRAL, "info_player_start")
	
	team.SetUp(TEAM_SPECTATOR, "Spectator", Color(204, 204, 204))
	SetTeamSecondaryColor(TEAM_SPECTATOR, Color(255, 255, 255))
	team.SetSpawnPoint(TEAM_SPECTATOR, "worldspawn") 
	
end

function GM:EntityName(ent, nolocalize)
	if ent then
		if ent:IsPlayer() and ent:IsValid() then
			return ent:Name()
		elseif ent:IsValid() then
			return "#"..ent:GetClass()
		else
			return ""
		end
	end
	return ""
end

function GM:EntityDeathnoticeName(ent, nolocalize)
	if ent.GetDeathnoticeName then
		return ent:GetDeathnoticeName(nolocalize)
	else
		return self:EntityName(ent, nolocalize)
	end
end

function GM:EntityTargetIDName(ent, nolocalize)
	if ent.GetTargetIDName then
		return ent:GetTargetIDName(nolocalize)
	else
		return self:EntityName(ent, nolocalize)
	end
end

function GM:EntityTeam(ent)
	if not ent or not ent:IsValid() then return TEAM_NEUTRAL end
	
	if type(ent.Team)=="function" then
		return ent:Team()
	else
		local t = ent:GetNWInt("Team") or 0
		if t>=1 then
			return t
		else
			t = ent:GetNPCData().team
			if not t and IsValid(ent:GetOwner()) then
				return self:EntityTeam(ent:GetOwner())
			else
				if type(t)=="function" then
					return t() or TEAM_NEUTRAL
				else
					return t or TEAM_NEUTRAL
				end
			end
		end
	end
end

function GM:EntityID(ent)
	if ent:IsPlayer() then
		return ent:UserID()
	elseif ent.DeathNoticeEntityID then
		return -ent.DeathNoticeEntityID
	else
		return 0
	end
end

function ParticleSuffix(t)
	if t==TEAM_BLU then return "blue"
	else return "red"
	end
end

function GM:ShouldCollide(ent1, ent2)
	if not IsValid(ent1) or not IsValid(ent2) then
		return true
	end
	
	if ent1.ShouldCollide then
		local c = ent1:ShouldCollide(ent2)
		if c ~= nil then return c end
	end
	
	if ent2.ShouldCollide then
		local c = ent2:ShouldCollide(ent1)
		if c ~= nil then return c end
	end
	
	if IsValid(ent1:GetOwner()) and (ent1:GetOwner():IsPlayer() or ent1:GetOwner():IsNPC()) then ent1 = ent1:GetOwner() end
	if IsValid(ent2:GetOwner()) and (ent2:GetOwner():IsPlayer() or ent2:GetOwner():IsNPC()) then ent2 = ent2:GetOwner() end
	
	local t1 = self:EntityTeam(ent1)
	local t2 = self:EntityTeam(ent2)
	
	if (ent1:IsPlayer() or ent2:IsPlayer()) and (t1==TEAM_RED or t1==TEAM_BLU) and t1==t2 then
		return false
	end
	
	if CLIENT then
		local c1, c2 = ent1:GetClass(), ent2:GetClass()
		
		if c2=="class C_HL2MPRagdoll" then
			c1,c2=c2,c1
		end
		
		if (c1=="class C_HL2MPRagdoll" or c1=="class CLuaEffect") and c2=="class CLuaEffect" then
			return false
		end
	end
	
	--[[
	if ent2:GetClass()=="phys_bone_follower" then
		ent1,ent2 = ent2,ent1
	end]]
	
	return true
end

HumanGibs = {
	"models/player/gibs/demogib001.mdl", -- 1
	"models/player/gibs/demogib002.mdl",
	"models/player/gibs/demogib003.mdl",
	"models/player/gibs/demogib004.mdl",
	"models/player/gibs/demogib005.mdl",
	"models/player/gibs/demogib006.mdl",
	"models/player/gibs/engineergib001.mdl", -- 7
	"models/player/gibs/engineergib002.mdl",
	"models/player/gibs/engineergib003.mdl",
	"models/player/gibs/engineergib004.mdl",
	"models/player/gibs/engineergib005.mdl",
	"models/player/gibs/engineergib006.mdl",
	"models/player/gibs/engineergib007.mdl",
	"models/player/gibs/heavygib001.mdl", -- 14
	"models/player/gibs/heavygib002.mdl",
	"models/player/gibs/heavygib003.mdl",
	"models/player/gibs/heavygib004.mdl",
	"models/player/gibs/heavygib005.mdl",
	"models/player/gibs/heavygib006.mdl",
	"models/player/gibs/heavygib007.mdl",
	"models/player/gibs/medicgib001.mdl", -- 21
	"models/player/gibs/medicgib002.mdl",
	"models/player/gibs/medicgib003.mdl",
	"models/player/gibs/medicgib004.mdl",
	"models/player/gibs/medicgib005.mdl",
	"models/player/gibs/medicgib006.mdl",
	"models/player/gibs/medicgib007.mdl",
	"models/player/gibs/medicgib008.mdl",
	"models/player/gibs/pyrogib001.mdl", -- 29
	"models/player/gibs/pyrogib002.mdl",
	"models/player/gibs/pyrogib003.mdl",
	"models/player/gibs/pyrogib004.mdl",
	"models/player/gibs/pyrogib005.mdl",
	"models/player/gibs/pyrogib006.mdl",
	"models/player/gibs/pyrogib007.mdl",
	"models/player/gibs/pyrogib008.mdl",
	"models/player/gibs/scoutgib001.mdl", -- 37
	"models/player/gibs/scoutgib002.mdl",
	"models/player/gibs/scoutgib003.mdl",
	"models/player/gibs/scoutgib004.mdl",
	"models/player/gibs/scoutgib005.mdl",
	"models/player/gibs/scoutgib006.mdl",
	"models/player/gibs/scoutgib007.mdl",
	"models/player/gibs/scoutgib008.mdl",
	"models/player/gibs/scoutgib009.mdl",
	"models/player/gibs/snipergib001.mdl", -- 46
	"models/player/gibs/snipergib002.mdl",
	"models/player/gibs/snipergib003.mdl",
	"models/player/gibs/snipergib004.mdl",
	"models/player/gibs/snipergib005.mdl",
	"models/player/gibs/snipergib006.mdl",
	"models/player/gibs/snipergib007.mdl",
	"models/player/gibs/soldiergib001.mdl", -- 53
	"models/player/gibs/soldiergib002.mdl",
	"models/player/gibs/soldiergib003.mdl",
	"models/player/gibs/soldiergib004.mdl",
	"models/player/gibs/soldiergib005.mdl",
	"models/player/gibs/soldiergib006.mdl",
	"models/player/gibs/soldiergib007.mdl",
	"models/player/gibs/soldiergib008.mdl",
	"models/player/gibs/spygib001.mdl", -- 61
	"models/player/gibs/spygib002.mdl",
	"models/player/gibs/spygib003.mdl",
	"models/player/gibs/spygib004.mdl",
	"models/player/gibs/spygib005.mdl",
	"models/player/gibs/spygib006.mdl",
	"models/player/gibs/spygib007.mdl",
	"models/player/gibs/random_organ.mdl", -- 68
	"models/player/gibs/gibs_balloon.mdl", -- 69
	"models/player/gibs/gibs_bolt.mdl",
	"models/player/gibs/gibs_boot.mdl",
	"models/player/gibs/gibs_burger.mdl",
	"models/player/gibs/gibs_can.mdl",
	"models/player/gibs/gibs_clock.mdl",
	"models/player/gibs/gibs_duck.mdl",
	"models/player/gibs/gibs_fish.mdl",
	"models/player/gibs/gibs_gear1.mdl",
	"models/player/gibs/gibs_gear2.mdl",
	"models/player/gibs/gibs_gear3.mdl",
	"models/player/gibs/gibs_gear4.mdl",
	"models/player/gibs/gibs_gear5.mdl",
	"models/player/gibs/gibs_hubcap.mdl",
	"models/player/gibs/gibs_licenseplate.mdl",
	"models/player/gibs/gibs_spring1.mdl",
	"models/player/gibs/gibs_spring2.mdl",
	"models/player/gibs/gibs_teeth.mdl",
	"models/player/gibs/gibs_tire.mdl",
	-- 88
}

NPCModels = {
	"models/Humans/Group01/female_01.mdl",
	"models/Humans/Group01/female_02.mdl",
	"models/Humans/Group01/female_03.mdl",
	"models/Humans/Group01/female_04.mdl",
	"models/Humans/Group01/female_05.mdl",
	"models/Humans/Group01/female_06.mdl",
	"models/Humans/Group01/female_07.mdl",
	"models/Humans/Group01/male_01.mdl",
	"models/Humans/Group01/male_02.mdl",
	"models/Humans/Group01/male_03.mdl",
	"models/Humans/Group01/male_04.mdl",
	"models/Humans/Group01/male_05.mdl",
	"models/Humans/Group01/male_06.mdl",
	"models/Humans/Group01/male_07.mdl",
	"models/Humans/Group01/male_08.mdl",
	"models/Humans/Group01/male_09.mdl",
	
	"models/Humans/Group02/female_01.mdl",
	"models/Humans/Group02/female_02.mdl",
	"models/Humans/Group02/female_03.mdl",
	"models/Humans/Group02/female_04.mdl",
	"models/Humans/Group02/female_05.mdl",
	"models/Humans/Group02/female_06.mdl",
	"models/Humans/Group02/female_07.mdl",
	"models/Humans/Group02/male_01.mdl",
	"models/Humans/Group02/male_02.mdl",
	"models/Humans/Group02/male_03.mdl",
	"models/Humans/Group02/male_04.mdl",
	"models/Humans/Group02/male_05.mdl",
	"models/Humans/Group02/male_06.mdl",
	"models/Humans/Group02/male_07.mdl",
	"models/Humans/Group02/male_08.mdl",
	"models/Humans/Group02/male_09.mdl",
	
	"models/Humans/Group03/female_01.mdl",
	"models/Humans/Group03/female_02.mdl",
	"models/Humans/Group03/female_03.mdl",
	"models/Humans/Group03/female_04.mdl",
	"models/Humans/Group03/female_05.mdl",
	"models/Humans/Group03/female_06.mdl",
	"models/Humans/Group03/female_07.mdl",
	"models/Humans/Group03/male_01.mdl",
	"models/Humans/Group03/male_02.mdl",
	"models/Humans/Group03/male_03.mdl",
	"models/Humans/Group03/male_04.mdl",
	"models/Humans/Group03/male_05.mdl",
	"models/Humans/Group03/male_06.mdl",
	"models/Humans/Group03/male_07.mdl",
	"models/Humans/Group03/male_08.mdl",
	"models/Humans/Group03/male_09.mdl",
	
	"models/Humans/Group03m/female_01.mdl",
	"models/Humans/Group03m/female_02.mdl",
	"models/Humans/Group03m/female_03.mdl",
	"models/Humans/Group03m/female_04.mdl",
	"models/Humans/Group03m/female_05.mdl",
	"models/Humans/Group03m/female_06.mdl",
	"models/Humans/Group03m/female_07.mdl",
	"models/Humans/Group03m/male_01.mdl",
	"models/Humans/Group03m/male_02.mdl",
	"models/Humans/Group03m/male_03.mdl",
	"models/Humans/Group03m/male_04.mdl",
	"models/Humans/Group03m/male_05.mdl",
	"models/Humans/Group03m/male_06.mdl",
	"models/Humans/Group03m/male_07.mdl",
	"models/Humans/Group03m/male_08.mdl",
	"models/Humans/Group03m/male_09.mdl",
	
	"models/alyx.mdl",
	"models/barney.mdl",
	"models/breen.mdl",
	"models/eli.mdl",
	"models/gman.mdl",
	"models/gman_high.mdl",
	"models/kleiner.mdl",
	"models/monk.mdl",
	"models/mossman.mdl",
	"models/vortigaunt.mdl",
}

--[[
for _,v in pairs(NPCModels) do
	util.PrecacheModel(v)
end]]

PlayerModels = {
	"models/player/demo.mdl",
	"models/player/engineer.mdl",
	"models/player/heavy.mdl",
	"models/player/medic.mdl",
	"models/player/pyro.mdl",
	"models/player/scout.mdl",
	"models/player/sniper.mdl",
	"models/player/soldier.mdl",
	"models/player/spy.mdl",
}

AnimationModels = {
	"models/weapons/c_models/c_demo_animations.mdl",
	"models/weapons/c_models/c_heavy_animations.mdl",
	"models/weapons/c_models/c_medic_animations.mdl",
	"models/weapons/c_models/c_pyro_animations.mdl",
	"models/weapons/c_models/c_scout_animations.mdl",
	"models/weapons/c_models/c_sniper_animations.mdl",
	"models/weapons/c_models/c_soldier_animations.mdl",
	"models/weapons/c_models/c_spy_animations.mdl",
}

include("shd_precaches.lua")
include("shd_movement.lua")
include("shd_npcdata.lua")
include("shd_playerclasses.lua")
include("ply_extension.lua")
include("ent_extension.lua")
include("shd_playerstates.lua")

include("shd_maphooks.lua")

concommand.Add("+inspect", function(pl)
	pl:SetNWString("inspect", "inspecting_start")
	print(pl:GetNWString("inspect"))
end)

concommand.Add("-inspect", function(pl)
	pl:SetNWString("inspect", "inspecting_released")
	print(pl:GetNWString("inspect"))
	timer.Simple( 0.02, function() pl:SetNWString("inspect", "inspecting_done") print(pl:GetNWString("inspect")) end )
end)

function GM:PlayerCanJoinTeam( ply, teamid )

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

