
local LOGFILE = "teamfortress/log_client.txt"
file.Delete(LOGFILE)
file.Append(LOGFILE, "Loading clientside script\n")
local load_time = SysTime()

include("tf_lang_module.lua")
tf_lang.Load("tf_english.txt")

include("cl_proxies.lua")
include("cl_pickteam.lua")

include("shared.lua")
include("cl_entclientinit.lua")
include("cl_deathnotice.lua")
include("cl_scheme.lua")

include("cl_camera.lua")

include("tf_draw_module.lua")

include("cl_materialfix.lua")

CreateClientConVar( "tf_haltinspect", "1", FCVAR_CLIENTCMD_CAN_EXECUTE, "Whether or not players can inspect while no-clipping." )

function GM:ShouldDrawWorldModel(pl)
	return true
end

--[[
timer.Create("lol",0.2,0,function() m=T:GetBoneMatrix(T:LookupBone("bip_head")) m:Translate(Vector(0,-5,0)) local e=EffectData() e:SetOrigin(m:GetTranslation()) e:SetAngles(Angle(180,0,0)) util.Effect("BloodImpact",e) end)

LocalPlayer().BuildBonePositions=function(pl) local m = pl:GetBoneMatrix(pl:LookupBone("bip_neck")) m:Scale(Vector(0,0,0)) m:Translate(Vector(0,0,0)) pl:SetBoneMatrix(pl:LookupBone("bip_neck"),m) end

TBB=function() local m=P:GetBoneMatrix(P:LookupBone("bip_spine_3")) m:Rotate(Angle(-10,0,-20)) m:Translate(Vector(0,-8,-3.5)) T:SetBoneMatrix(T:LookupBone("bip_head"),m) end

]]

--include("vgui/vgui_teammenubg.lua")

--[[
tf_util.AddDebugInfo("move_x", function()
	return "forward : "..tostring(LocalPlayer():GetNWFloat("MoveForward"))
end)

tf_util.AddDebugInfo("move_y", function()
	return "side : "..tostring(LocalPlayer():GetNWFloat("MoveSide"))
end)

tf_util.AddDebugInfo("move_z", function()
	return "up : "..tostring(LocalPlayer():GetNWFloat("MoveUp"))
end)]]

hook.Add("RenderScreenspaceEffects", "RenderPlayerStateOverlay", function()
	if IsValid(LocalPlayer()) then
		LocalPlayer():DrawStateOverlay()
	end
end)

concommand.Add("muzzlepos", function(pl)
	local att = pl:GetViewModel():GetAttachment(pl:GetViewModel():LookupAttachment("muzzle"))
	if not att then return end
	
	print(att.Pos - pl:GetShootPos())
end)

function GM:PlayerBindPress(pl, bind)
	local w = pl:GetActiveWeapon()
	if w and w:IsValid() and w:GetNWBool("SlotInputEnabled") then
		local num = tonumber(string.match(bind, "^slot(%d)") or "")
		if num then
			pl:ConCommand("select_slot "..num)
			return true
		end
	end
end

function GetPlayerByUserID(id)
	for _,v in pairs(player.GetAll()) do
		if v:UserID()==id then
			return v
		end
	end
	return NULL
end

-- Spawn player gibs
usermessage.Hook("GibPlayer", function(um)
	local pl = GetPlayerByUserID(um:ReadLong())
	if not IsValid(pl) then return end
	
	pl.DeathFlags = um:ReadShort()
	
	local effectdata = EffectData()
		effectdata:SetEntity(pl)
	util.Effect("tf_player_gibbed", effectdata)
end)

usermessage.Hook("GibNPC", function(um)
	local npc = um:ReadEntity()
	if not IsValid(npc) then return end
	
	npc.DeathFlags = um:ReadShort()
	
	local effectdata = EffectData()
		effectdata:SetEntity(npc)
	util.Effect("tf_player_gibbed", effectdata)
end)

usermessage.Hook("SilenceNPC", function(um)
	local npc = um:ReadEntity()
	if not IsValid(npc) then return end
	
	timer.Simple(0, function() npc:EmitSound("AI_BaseNPC.SentenceStop") end)
	timer.Simple(0.1, function() npc:EmitSound("AI_BaseNPC.SentenceStop") end)
end)

-- Critical hit notifications
usermessage.Hook("CriticalHit", function(um)
	local pos = um:ReadVector()
	LocalPlayer():EmitSound("TFPlayer.CritHit")
	ParticleEffect("crit_text", pos, Angle(0,0,0))
end)

usermessage.Hook("CriticalHitMini", function(um)
	local pos = um:ReadVector()
	LocalPlayer():EmitSound("TFPlayer.CritHit")
	ParticleEffect("minicrit_text", pos, Angle(0,0,0))
end)

usermessage.Hook("CriticalHitMiniOther", function(um)
	local pos = um:ReadVector()
	sound.Play("TFPlayer.CritHitMini", pos)
	ParticleEffect("minicrit_text", pos, Angle(0,0,0))
end)

usermessage.Hook("CriticalHitReceived", function(um)
	LocalPlayer():EmitSound("TFPlayer.CritPain", 100, 100)
end)

-- Domination notifications
usermessage.Hook("PlayerDomination", function(um)
	local victim = um:ReadEntity()
	local attacker = um:ReadEntity()
	if not IsValid(victim) or not IsValid(attacker) then
		return
	end
	
	if victim == LocalPlayer() then
		local data = EffectData()
			data:SetOrigin(attacker:GetPos())
			data:SetEntity(attacker)
		util.Effect("tf_nemesis_icon", data)
		LocalPlayer():EmitSound("Game.Nemesis")
	elseif attacker == LocalPlayer() then
		LocalPlayer():EmitSound("Game.Domination")
	end
	
	if not victim.NemesisesList then victim.NemesisesList = {} end
	if not attacker.DominationsList then attacker.DominationsList = {} end
	
	victim.NemesisesList[attacker] = true
	attacker.DominationsList[victim] = true
end)

usermessage.Hook("PlayerRevenge", function(um)
	local victim = um:ReadEntity()
	local attacker = um:ReadEntity()
	if not IsValid(victim) or not IsValid(attacker) then
		return
	end
	
	if attacker == LocalPlayer() then
		if IsValid(victim.NemesisEffect) and victim.NemesisEffect.Destroy then
			victim.NemesisEffect:Destroy()
		end
		LocalPlayer():EmitSound("Game.Revenge")
	elseif victim == LocalPlayer() then
		LocalPlayer():EmitSound("Game.Revenge")
	end
	
	if attacker.NemesisesList then
		attacker.NemesisesList[victim] = nil
	end
	
	if victim.DominationsList then
		victim.DominationsList[attacker] = nil
	end
end)

usermessage.Hook("PlayerResetDominations", function(um)
	local pl = um:ReadEntity()
	if not IsValid(pl) then return end
	
	pl.NemesisesList = nil
	pl.DominationsList = nil
	
	if IsValid(pl.NemesisEffect) and pl.NemesisEffect.Destroy then
		pl.NemesisEffect:Destroy()
	end
	
	for _,v in pairs(player.GetAll()) do
		if v ~= pl then
			if v.NemesisesList then
				v.NemesisesList[pl] = nil
			end
			if v.DominationsList then
				v.DominationsList[pl] = nil
			end
		end
	end
end)

usermessage.Hook("SendPlayerDominations", function(um)
	local pl = um:ReadEntity()
	if not IsValid(pl) then return end
	
	local num = um:ReadChar()
	if num <= 0 then return end
	
	pl.DominationsList = {}
	for i=1,num do
		local k = um:ReadEntity()
		if IsValid(pl) then
			pl.DominationsList[k] = true
		end
	end
end)

local function DoHealthBonusEffect(ent, positive)
	if not IsValid(ent) then return end
	
	local col = "red"
	if ent:EntityTeam()==TEAM_BLU then col = "blu" end
	
	local pos = ent:GetPos() + Vector(0,0,75) + math.Rand(0,4) * Angle(math.Rand(-180,180),math.Rand(-180,180),0):Forward()
	
	if positive then
		ParticleEffect("healthgained_"..col, pos, Angle(0,0,0))
	else
		ParticleEffect("healthlost_"..col, pos, Angle(0,0,0))
	end
end

usermessage.Hook("PlayerHealthBonusEffect", function(um)
	local ent = GetPlayerByUserID(um:ReadLong())
	local positive = um:ReadBool()
	
	if ent ~= LocalPlayer() or ent:ShouldDrawLocalPlayer() then
		DoHealthBonusEffect(ent, positive)
	end
end)

usermessage.Hook("EntityHealthBonusEffect", function(um)
	local ent = um:ReadEntity()
	local positive = um:ReadBool()
	DoHealthBonusEffect(ent, positive)
end)

usermessage.Hook("PlayerRocketJumpEffect", function(um)
	local ent = GetPlayerByUserID(um:ReadLong())
	
	if ent ~= LocalPlayer() or ent:ShouldDrawLocalPlayer() then
		ParticleEffectAttach("rocketjump_smoke", PATTACH_POINT_FOLLOW, ent, ent:LookupAttachment("foot_L"))
		ParticleEffectAttach("rocketjump_smoke", PATTACH_POINT_FOLLOW, ent, ent:LookupAttachment("foot_R"))
	end
end)

usermessage.Hook("PlayChargeReadySound", function(um)
	LocalPlayer():EmitSound("TFPlayer.ReCharged")
end)

include("cl_hud.lua")

file.Append(LOGFILE, Format("Done loading, time = %f\n", SysTime() - load_time))
local load_time = SysTime()

function ClassSelection()
local ply = LocalPlayer()
local ClassFrame = vgui.Create("DFrame") --create a frame
ClassFrame:SetSize(840, 130) --set its size
ClassFrame:Center() --position it at the center of the screen
ClassFrame:SetTitle("TF2 Menu") --set the title of the menu 
ClassFrame:SetDraggable(false) --can you move it around
ClassFrame:SetSizable(false) --can you resize it?
ClassFrame:ShowCloseButton(true) --can you close it
ClassFrame:MakePopup() --make it appear
 
local ScoutButton = vgui.Create("DButton", ClassFrame)
ScoutButton:SetSize(100, 30)
ScoutButton:SetPos(10, 35)
ScoutButton:SetText("Scout")
ScoutButton.DoClick = function() RunConsoleCommand("changeclass", "scout") surface.PlaySound( "/music/class_menu_01.wav" ) ClassFrame:Close() end
 
local SoldierButton = vgui.Create("DButton", ClassFrame)
SoldierButton:SetSize(100, 30)
SoldierButton:SetPos(100, 35)
SoldierButton:SetText("Soldier") --Set the name of the button
SoldierButton.DoClick = function() RunConsoleCommand("changeclass", "soldier") surface.PlaySound( "/music/class_menu_02.wav" ) ClassFrame:Close() end

local PyroButton = vgui.Create("DButton", ClassFrame)
PyroButton:SetSize(100, 30)
PyroButton:SetPos(190, 35)
PyroButton:SetText("Pyro") --Set the name of the button
PyroButton.DoClick = function() RunConsoleCommand("changeclass", "pyro") surface.PlaySound( "/music/class_menu_03.wav" ) ClassFrame:Close() end

local DemomanButton = vgui.Create("DButton", ClassFrame)
DemomanButton:SetSize(100, 30)
DemomanButton:SetPos(280, 35)
DemomanButton:SetText("Demoman") --Set the name of the button
DemomanButton.DoClick = function() RunConsoleCommand("changeclass", "demoman") surface.PlaySound( "/music/class_menu_04.wav" ) ClassFrame:Close() end

local HeavyButton = vgui.Create("DButton", ClassFrame)
HeavyButton:SetSize(100, 30)
HeavyButton:SetPos(370, 35)
HeavyButton:SetText("Heavy") --Set the name of the button
HeavyButton.DoClick = function() RunConsoleCommand("changeclass", "heavy") surface.PlaySound( "/music/class_menu_05.wav" ) ClassFrame:Close() end

local EngineerButton = vgui.Create("DButton", ClassFrame)
EngineerButton:SetSize(100, 30)
EngineerButton:SetPos(460, 35)
EngineerButton:SetText("Engineer") --Set the name of the button
EngineerButton.DoClick = function() RunConsoleCommand("changeclass", "engineer") surface.PlaySound( "/music/class_menu_06.wav" ) ClassFrame:Close() end

local MedicButton = vgui.Create("DButton", ClassFrame)
MedicButton:SetSize(100, 30)
MedicButton:SetPos(550, 35)
MedicButton:SetText("Medic") --Set the name of the button
MedicButton.DoClick = function() RunConsoleCommand("changeclass", "medic") surface.PlaySound( "/music/class_menu_07.wav" ) ClassFrame:Close() end

local SniperButton = vgui.Create("DButton", ClassFrame)
SniperButton:SetSize(100, 30)
SniperButton:SetPos(640, 35)
SniperButton:SetText("Sniper") --Set the name of the button
SniperButton.DoClick = function() RunConsoleCommand("changeclass", "sniper") surface.PlaySound( "/music/class_menu_08.wav" ) ClassFrame:Close() end

local SpyButton = vgui.Create("DButton", ClassFrame)
SpyButton:SetSize(100, 30)
SpyButton:SetPos(730, 35)
SpyButton:SetText("Spy") --Set the name of the button
SpyButton.DoClick = function() RunConsoleCommand("changeclass", "spy") surface.PlaySound( "/music/class_menu_09.wav" ) ClassFrame:Close() end

local GmodButton = vgui.Create("DButton", ClassFrame)
GmodButton:SetSize(100, 30)
GmodButton:SetPos(366, 70)
GmodButton:SetText("GMod Player") --Set the name of the button
GmodButton.DoClick = function() RunConsoleCommand("changeclass", "gmodplayer") ClassFrame:Close() end

--local Hint = vgui.Create( "DLabel", ClassFrame )
--Hint:SetPos( 10, 98 )
--Hint:SetText(  string.upper(input.LookupBinding( "gm_showteam" )).." Change Team" )
--Hint:SizeToContents()

local Hint2 = vgui.Create( "DLabel", ClassFrame )
Hint2:SetPos( 10, 110 )
Hint2:SetText(  string.upper(input.LookupBinding( "gm_showspare1" )).." to open this menu" )
Hint2:SizeToContents()

local TeamRed = vgui.Create( "DButton", ClassFrame )
function TeamRed.DoClick() RunConsoleCommand( "changeteam", 1 ) ClassFrame:Close() end
TeamRed:SetPos( 700, 65 )
TeamRed:SetSize( 130, 20 )
TeamRed:SetText( "RED Team" )
local TeamBlu = vgui.Create( "DButton", ClassFrame )
function TeamBlu.DoClick() RunConsoleCommand( "changeteam", 2 ) ClassFrame:Close() end
TeamBlu:SetPos( 700, 105 )
TeamBlu:SetSize( 130, 20 )
TeamBlu:SetText( "BLU Team" )
local TeamNeu = vgui.Create( "DButton", ClassFrame )
function TeamNeu.DoClick() RunConsoleCommand( "changeteam", 4 ) ClassFrame:Close() end
TeamNeu:SetPos( 700, 85 )
TeamNeu:SetSize( 130, 20 )
TeamNeu:SetText( "Neutral Team" )

local Option1 = vgui.Create( "DCheckBox", ClassFrame )
Option1:SetPos( 130, 110 )
Option1:SetValue( GetConVar("tf_righthand"):GetInt() )

function Option1:OnChange(new)
	if new == false then
		RunConsoleCommand("tf_righthand", 0)
	else
		RunConsoleCommand("tf_righthand", 1)
	end
end

local Option1text = vgui.Create( "DLabel", ClassFrame )
Option1text:SetPos( 150, 110 )
Option1text:SetText(  "Right handed" )
Option1text:SizeToContents()

local Option2 = vgui.Create( "DCheckBox", ClassFrame )
Option2:SetPos( 220, 110 )
Option2:SetValue( GetConVar("tf_autoreload"):GetInt() )

function Option2:OnChange(new)
	if new == false then
		RunConsoleCommand("tf_autoreload", 0)
	else
		RunConsoleCommand("tf_autoreload", 1)
	end
end

local Option2text = vgui.Create( "DLabel", ClassFrame )
Option2text:SetPos( 240, 110 )
Option2text:SetText(  "Autoreload" )
Option2text:SizeToContents()


end

--[[function GM:PlayerBindPress(pl, bind, pressed)
	if (bind == "+menu") then
		RunConsoleCommand("lastinv")
	end
end]]

concommand.Add("tf_changeclass", ClassSelection)
concommand.Add("tf_menu", ClassSelection)
--spawnmenu.AddCreationTab( "Team Fortress 2", function()

	--local ctrl = vgui.Create( "SpawnmenuContentPanel" )
	--return ctrl

--end, "icon16/control_repeat_blue.png", 200 )

--[[function GM:OnSpawnMenuOpen()
	return --ply:IsAdmin()
end]]

hook.Add( "PlayerSay", "Change class", function( ply, text, public )
	text = string.lower( text ) -- Make the chat message entirely lowercase
	if ( string.sub( text, 1 ) == "!changeclass" ) then
		RunConsoleCommand("tf_changeclass")
		return false
	end
end )

hook.Add( "PlayerSay", "Class Scout", function( ply, text, public )
	text = string.lower( text ) -- Make the chat message entirely lowercase
	if ( string.sub( text, 1 ) == "!changeclass scout" ) then
		RunConsoleCommand("changeclass", "scout")
		return false
	end
end )

hook.Add( "PlayerSay", "Class Soldier", function( ply, text, public )
	text = string.lower( text ) -- Make the chat message entirely lowercase
	if ( string.sub( text, 1 ) == "!changeclass soldier" ) then
		RunConsoleCommand("changeclass", "soldier")
		return false
	end
end )

hook.Add( "PlayerSay", "Class Pyro", function( ply, text, public )
	text = string.lower( text ) -- Make the chat message entirely lowercase
	if ( string.sub( text, 1 ) == "!changeclass pyro" ) then
		RunConsoleCommand("changeclass", "pyro")
		return false
	end
end )

hook.Add( "PlayerSay", "Class Demoman", function( ply, text, public )
	text = string.lower( text ) -- Make the chat message entirely lowercase
	if ( string.sub( text, 1 ) == "!changeclass demoman" ) then
		RunConsoleCommand("changeclass", "demoman")
		return false
	end
end )

hook.Add( "PlayerSay", "Class Heavy", function( ply, text, public )
	text = string.lower( text ) -- Make the chat message entirely lowercase
	if ( string.sub( text, 1 ) == "!changeclass heavy" ) then
		RunConsoleCommand("changeclass", "heavy")
		return false
	end
end )

hook.Add( "PlayerSay", "Class Engineer", function( ply, text, public )
	text = string.lower( text ) -- Make the chat message entirely lowercase
	if ( string.sub( text, 1 ) == "!changeclass engineer" ) then
		RunConsoleCommand("changeclass", "engineer")
		return false
	end
end )

hook.Add( "PlayerSay", "Class Medic", function( ply, text, public )
	text = string.lower( text ) -- Make the chat message entirely lowercase
	if ( string.sub( text, 1 ) == "!changeclass medic" ) then
		RunConsoleCommand("changeclass", "medic")
		return false
	end
end )

hook.Add( "PlayerSay", "Class Sniper", function( ply, text, public )
	text = string.lower( text ) -- Make the chat message entirely lowercase
	if ( string.sub( text, 1 ) == "!changeclass sniper" ) then
		RunConsoleCommand("changeclass", "sniper")
		return false
	end
end )

hook.Add( "PlayerSay", "Class Spy", function( ply, text, public )
	text = string.lower( text ) -- Make the chat message entirely lowercase
	if ( string.sub( text, 1 ) == "!changeclass spy" ) then
		RunConsoleCommand("changeclass", "spy")
		return false
	end
end )

hook.Add( "PlayerSay", "Change Team Red", function( ply, text, public )
	text = string.lower( text ) -- Make the chat message entirely lowercase
	if ( string.sub( text, 1 ) == "!changeteam red" ) then
		RunConsoleCommand("changeteam", "1")
		return false
	end
end )

hook.Add( "PlayerSay", "Change Team Blu", function( ply, text, public )
	text = string.lower( text ) -- Make the chat message entirely lowercase
	if ( string.sub( text, 1 ) == "!changeteam blu" ) then
		RunConsoleCommand("changeteam", "2")
		return false
	end
end )

hook.Add( "PlayerSay", "Change Team Blu", function( ply, text, public )
	text = string.lower( text ) -- Make the chat message entirely lowercase
	if ( string.sub( text, 1 ) == "!changeteam blu" ) then
		RunConsoleCommand("changeteam", "2")
		return false
	end
end )
