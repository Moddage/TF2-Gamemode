if game.SinglePlayer() or CLIENT or engine.ActiveGamemode() ~= "teamfortress" then return end

local profiles = {}
local bots = {}

--local names = {"LeadKiller", "A Random Person", "Foxie117", "G.A.M.E.R v24", "Agent Agrimar"}
--local names = {"A Professional With Standards", "AimBot", "AmNot", "Aperture Science Prototype XR7", "Archimedes!", "BeepBeepBoop", "Big Mean Muther Hubbard", "Black Mesa", "BoomerBile", "Cannon Fodder", "CEDA", "Chell", "Chucklenuts", "Companion Cube", "Crazed Gunman", "CreditToTeam", "CRITRAWKETS", "Crowbar", "CryBaby", "CrySomeMore", "C++", "DeadHead", "Delicious Cake", "Divide by Zero", "Dog", "Force of Nature", "Freakin' Unbelievable", "Gentlemanne of Leisure", "GENTLE MANNE of LEISURE ", "GLaDOS", "Glorified Toaster with Legs", "Grim Bloody Fable", "GutsAndGlory!", "Hat-Wearing MAN", "Headful of Eyeballs", "Herr Doktor", "HI THERE", "Hostage", "Humans Are Weak", "H@XX0RZ", "I LIVE!", "It's Filthy in There!", "IvanTheSpaceBiker", "Kaboom!", "Kill Me", "LOS LOS LOS", "Maggot", "Mann Co.", "Me", "Mega Baboon", "Mentlegen", "Mindless Electrons", "MoreGun", "Nobody", "Nom Nom Nom", "NotMe", "Numnutz", "One-Man Cheeseburger Apocalypse", "Poopy Joe", "Pow!", "RageQuit", "Ribs Grow Back", "Saxton Hale", "Screamin' Eagles", "SMELLY UNFORTUNATE", "SomeDude", "Someone Else", "Soulless", "Still Alive", "TAAAAANK!", "Target Practice", "ThatGuy", "The Administrator", "The Combine", "The Freeman", "The G-Man", "THEM", "Tiny Baby Man", "Totally Not A Bot", "trigger_hurt", "WITCH", "ZAWMBEEZ", "Ze Ubermensch", "Zepheniah Mann", "0xDEADBEEF", "10001011101"}
local names = {"TFBot"}
local classtb = {"scout","scout","scout","soldier","soldier","soldier","soldier","pyro","pyro","pyro","pyro","pyro","pyro","demoman","demoman","demoman","demoman","demoman","heavy","heavy","heavy","heavy","heavy","spy","spy","spy","sniper","sniper","engineer","engineer","engineer","engineer","engineer","engineer","medic","medic","medic","medic","demoknight","ubermedic"}
--local classtb = {"demoknight"}
local classtbmvm = {"scout","scout","scout","soldier","soldier","soldier","soldier","pyro","pyro","pyro","pyro","pyro","pyro","demoman","demoman","demoman","demoman","demoman","heavy","heavy","heavy","heavy","heavy","spy","spy","spy","sniper","sniper","engineer","engineer","engineer","engineer","engineer","engineer","medic","medic","medic","medic","sentrybuster","giantscout","giantpyro","giantheavy","giantsoldier","superscout","giantheavyshotgun","giantheavyheater","giantsoldierrapidfire","giantsoldiercharged","soldierbuffed","soldierblackbox","soldierblackbox","soldierblackbox","soldierblackbox","soldierblackbox","soldierblackbox","soldierblackbox","soldierblackbox","soldierblackbox","soldierbuffed","soldierbuffed","demoknight","demoknight","demoknight","demoknight","demoknight","demoknight","demoknight","soldierbuffed","soldierbuffed","soldierbuffed","heavyshotgun","heavyshotgun","heavyshotgun","heavyshotgun","heavyweightchamp","heavyweightchamp","heavyweightchamp","heavyweightchamp","melee_scout","melee_scout","melee_scout","melee_scout","melee_scout","melee_scout","melee_scout","melee_scout","melee_scout","ubermedic","ubermedic","ubermedic","ubermedic","ubermedic","ubermedic"}
--local classtbmvm = {"combinesoldier","combinesoldier"}
local bot_class = CreateConVar("tf_bot_keep_class_after_death", "0", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY})
local bot_diff = CreateConVar("tf_bot_difficulty", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, "Sets the difficulty level for the bots. Values are: 0=easy, 1=normal, 2=hard, 3=expert. Default is \"Normal\" (1).")
local tf_bot_notarget = CreateConVar("tf_bot_notarget", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
local tf_bot_melee_only = CreateConVar("tf_bot_melee_only", "0", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY})
local seensentry = false
local combinesoldierweps = {"tf_weapon_capsulelauncher","tf_weapon_trenchknife"}
function LBAddProfile(tab) 
	if profiles[tab["name"]] then return end
	table.insert(profiles, tab) 
end  

function LBAddBot(team)
	--if !profiles[name] then MsgN("That is not a valid bot!") return end
	if !navmesh.IsLoaded() then
		navmesh.BeginGeneration()
		for k, v in pairs(player.GetAll()) do
			v:ChatPrint("GENERATING NAV")
		end
	end
	local diff = GetConVar("tf_bot_difficulty"):GetFloat() -- math.random(3)
--[[local diffn = "Normal"
	if diff == 0 then
		diffn = "Easy"
	if diff == 1 then 
		diffn = "Normal" 
	elseif diff == 2 then
		diffn = "Hard"
	elseif diff == 3 then
		diffn = "Expert"
	end]]
	local name = table.Random(names) -- .." (bot) "..diffn --"Bot"..math.random(0, 99)
	local bot = player.CreateNextBot(name)
	local teamd = TEAM_BLU
	if !string.find(game.GetMap(), "mvm_") then
		if team == 1 then
			teamd = table.Random({TEAM_RED,TEAM_BLU})
		end	
	else
		if team == 1 then
			teamd = TEAM_BLU
		end
	end
	bot.ControllerBot = ents.Create("ctf_bot_navigator")
	bot.ControllerBot:Spawn() 
	bot.LastPath = nil
	bot.CurSegment = 2
	--[[if string.find(game.GetMap(), "mvm_") and bot:Team() == TEAM_BLU then
		bot:SetPlayerClass(table.Random(classtbmvm))
	elseif !string.find(game.GetMap(), "mvm_") then
		bot:SetPlayerClass(table.Random(classtb))
	end]]
	bot:SetPlayerClass(table.Random(classtbmvm))
	for k, v in pairs(player.GetAll()) do
		v:ChatPrint(tostring(team))
	end
	timer.Simple(3, function()
		if IsValid(bot) then
			bot.LKBot = true
			if !string.find(game.GetMap(), "mvm_") then
				bot:SetTeam(table.Random({TEAM_RED,TEAM_BLU}))
			elseif string.find(game.GetMap(), "mvm_") then
				bot:SetTeam(TEAM_BLU)
			end
			bot:Kill()
			bot.Difficulty = diff
			table.insert(bots, bot)
		end
	end)
end

function LBFindClosest(bot)
	local players = player.GetHumans()
	local distance = 9999
	local player = player.GetHumans()[1]
	local distanceplayer = 9999
	for k, v in pairs(players) do
		distanceplayer = v:GetPos():Distance(bot:GetPos())
		if distance > distanceplayer and v ~= bot then
			distance = distanceplayer
			player = v
		end
	end

	--print(player:Nick().." is the closest!")
	bot.FollowPly = player
end

hook.Add("PostCleanupMap", "leadbot_cleanupmap", function()
	for k, v in pairs(player.GetBots()) do
		if IsValid(v) and v.LKBot then
			v.ControllerBot = ents.Create("ctf_bot_navigator")
			v.ControllerBot:Spawn()
		end
	end
end)

hook.Add("PlayerSpawn", "leadbot_spawn", function(ply)
	timer.Simple(0.1, function()
		if ply.LKBot then
			--[[ply:StripWeapons()
			ply:Give("cw_m1911")]]
			local classmvm = table.Random(classtbmvm)
			local class = table.Random(classtb)

			timer.Simple(1, function()
				if bot_class:GetFloat() == 0 then
					if string.find(game.GetMap(), "mvm_") then
						ply:SetPlayerClass(classmvm)
					else
						ply:SetPlayerClass(class)
					end
				end

				timer.Simple(0.1, function()				
					if bot_class:GetFloat() == 0 then
						ply:SetPlayerClass(ply:GetPlayerClass()	)
					end 
					RandomWeapon2(ply, "primary")
					RandomWeapon2(ply, "secondary")
					RandomWeapon2(ply, "melee")
				end)
				if ply:GetPlayerClass() == "combinesoldier" then
					ply:SelectWeapon(table.Random(combinesoldierweps))
				end
				ply:SetPlayerColor(Vector(math.random(0, 255) / 255,  math.random(0, 255) / 255, math.random(0, 255) / 255))
				ply:SetFOV(100, 0)
						
				timer.Create("CombineSoldierAttack2"..bot:EntIndex(), 15, 0, function()
					if bot:GetPlayerClass() == "combinesoldier" then
						if !bot:Alive() then timer.Stop("CombineSoldierAttack2"..bot:EntIndex()) return end
						bot:GetActiveWeapon():SecondaryAttack()
					end
				end)
			end)

			if tf_bot_melee_only:GetBool() then
				local weps = ply:GetWeapons()
				for k, v in pairs(weps) do
					if v.Base == "tf_weapon_melee_base" then
						timer.Simple(0.2, function()
							ply:SelectWeapon(v:GetClass()) 
						end)
						print(v)
					end
				end
			end

			--if !DeathMatch:GetBool() then return end
			--local spawns = {Vector(-213.596680, -1471.438721, -79.968750), Vector(369.839966, -1744.694458, -79.968750), Vector(-835.960327, -1636.255249, 5.029270), Vector(-441.878693, -1857.632935, -79.968750), Vector(557.627441, -1333.633301, 64.693993)}

			--ply:SetPos(table.Random(spawns) + Vector(0, 0, math.random(10, 70)))
		end
	end)
end)

hook.Add("PlayerDisconnected", "leadbot_removed", function(ply)
	if IsValid(ply) and IsValid(ply.ControllerBot) then
		ply.ControllerBot:Remove()
	end
end)

hook.Add("Think", "leadbot_think", function()
	--for _, bot in pairs(player.GetBots()) do
		--print(bot)
		--[[for m, n in pairs(ents.FindByClass("prop_buys")) do
			if n:GetPos():Distance(bot:GetPos()) < 120 then
				print(n)
			end
		end]]
		--[[if bot:Team() == TEAM_SPECTATOR then
			bot:SetTeam(TEAM_PLAYERS)
		end]]
		--[[if bot.LKBot then
			if IsValid(bot:GetActiveWeapon()) then
				local wep = bot:GetActiveWeapon()
				local ammoty = wep:GetPrimaryAmmoType() or wep.Primary.Ammo
				--bot:SetAmmo(32, ammoty)
			end]]

			--[[if nzRound:InState(ROUND_WAITING) and !IsValid(bot:GetActiveWeapon()) then
				bot:KillSilent()
			end]]	

			--if bot:GetActiveWeapon() == NULL or (IsValid(bot:GetActiveWeapon()) and bot:GetActiveWeapon():GetClass() ~= Entity(1):GetActiveWeapon():GetClass()) or !IsValid(bot:GetActiveWeapon()) then
				--if Entity(1):GetActiveWeapon():GetClass() ~= "nz_quickknife_crowbar" and Entity(1):GetActiveWeapon():GetClass() ~= "nz_grenade" and !IsValid(bot.UseTarget) then
					--bot:StripWeapons()
					--bot:Give(Entity(1):GetActiveWeapon():GetClass())
				--end
			--end
		--end
	--end
end)

hook.Add("OnPlayerReady", "leadbot_ready", function()
	RunConsoleCommand("lk.ready_bots")
end)

hook.Add("StartCommand", "leadbot_control", function(bot, cmd)
	if bot.LKBot then
		cmd:ClearMovement()
		cmd:ClearButtons()
		--cmd:SetButtons(IN_ATTACK)

		--bot:SetFOV(100, 0)

		--LBFindClosest(bot)
		
		if bot.ControllerBot:GetPos() ~= bot:GetPos() then
			bot.ControllerBot:SetPos(bot:GetPos())
			bot.ControllerBot:SetAngles(bot:EyeAngles())
		end

		--[[if bot.ControllerBot:GetModel() ~= bot:GetModel() then
			bot.ControllerBot:SetModel(bot:GetModel())
		end]]

		bot.TargetEnt = nil
		bot.UseTarget = nil
		bot.FollowPly = bot.FollowPly or bot

		local ignoreback = true -- false

		--if bot:GetPos():Distance(Vector(-4.121376, 3.947412, -165.17173)) <= 100 then
		--if bot:GetPos().z <= -155 then
			--bot:SetPos(Vector(-2.374759, -587.545959, 136.182220))
			-- bot:Kill() 
		--end

		local targetply = player.GetBots()[2]--Entity(4)
		local targetpos2 = Vector(457.283539, -3213.777588, -94.868698)--Vector(-489.159485, 3313.968750, -107.968750)--Vector(0, 0, 0)--ents.FindByClass("team_control_point")[1]:GetPos()--targetply:GetPos() -- Vector(-213.596680, -1471.438721, -79.968750)
		local intel
		local fintel
		local intelcap
		local fintelcap
		local fsentry
		local fsentrypoint
		local fsentryred
		local fsentrypointred
		if string.find(game.GetMap(), "ctf_") then 
			for k, v in pairs(ents.FindByClass("item_teamflag")) do
				if v.TeamNum ~= bot:Team() then
					intel = v
				else
					fintel = v
				end
			end

			for k, v in pairs(ents.FindByClass("func_capturezone")) do
				if v.TeamNum ~= bot:Team() then
					intelcap = v
				else
					fintelcap = v
				end
			end

			if !intel.Carrier and !fintel.Carrier then -- neither intel has a capture
				targetpos2 = intel:GetPos() -- goto enemy intel
				ignoreback = true
			elseif intel.Carrier == bot then -- or if friendly intelligence has capture
				targetpos2 = fintelcap.Pos -- goto friendly cap spot
				ignoreback = true
			elseif intel.Carrier then -- or else if we have it already carried
				targetpos2 = intel.Carrier:GetPos() -- follow that man
			end
		end
		if string.find(game.GetMap(), "mvm_") and bot:Team() == TEAM_BLU and bot:GetPlayerClass() != "engineer" and bot:GetPlayerClass() != "sentrybuster" then
			for k, v in pairs(ents.FindByClass("item_teamflag_mvm")) do
				if v.TeamNum ~= bot:Team() then
					intel = v
					fintel = v
				end
			end	
			
			for k, v in pairs(ents.FindByClass("item_teamflag")) do
				if v.TeamNum == bot:Team() then
					fintel = v
				end
			end

			for k, v in pairs(ents.FindByClass("func_capturezone")) do
				if v.TeamNum ~= bot:Team() then
					intelcap = v
				else
					fintelcap = v
				end
			end

			if !intel.Carrier and !fintel.Carrier then -- neither intel has a capture
				targetpos2 = intel:GetPos() -- goto enemy intel
				ignoreback = true
			elseif intel.Carrier == bot then -- or if friendly intelligence has capture
				targetpos2 = fintelcap.Pos -- goto friendly cap spot
				ignoreback = true
			elseif intel.Carrier then -- or else if we have it already carried
				targetpos2 = intel.Carrier:GetPos() -- follow that man
			end
		end



		if bot:GetPlayerClass() == "engineer" and bot:Team() == TEAM_RED then

			if bot:GetPlayerClass() == "engineer" then	
				for k, v in pairs(ents.FindInSphere(bot:GetPos(), 2300)) do
					if bot:GetPos():Distance(v:GetPos()) >= 40 and v:GetClass() == "bot_hint_sentrygun_red" then
						bot:Build(2,0)
						cmd:SetForwardMove(800)
						targetpos2 = v:GetPos()
					elseif bot:GetPos():Distance(v:GetPos()) <= 20 and v:GetClass() == "bot_hint_sentrygun_red" then
						cmd:SetButtons(IN_ATTACK)
						cmd:SetForwardMove(0)
						print("Buildin' a sentry!")
						targetpos2 = v:GetPos()
					end
				end
			end
		end
		

		--[[for k, v in pairs(player.GetAll()) do
			if v:Alive() and v:GetPos():Distance(bot:GetPos()) < 4096 and !v:IsBot() and !ignoreback then
				if bot:GetPos():Distance(v:GetPos()) > 150 then
					cmd:SetForwardMove( 800 )
				elseif bot:GetPos():Distance(v:GetPos()) < 100 then
					cmd:SetForwardMove( -250 )
				end
			elseif v:Alive() then
				cmd:SetForwardMove( 800 )
			end
		end ]]

		--[[for k, v in pairs(ents.GetAll()) do
			local class = v:GetClass()
			if (class == "prop_buys" or class == "func_button" or class == "func_door" or class == "func_door_rotating" or class == "prop_dynamic" or class == "prop_door_rotating" or class == "nz_script_triggerzone" or class == "nz_triggerbutton") and v:GetPos():Distance(bot:GetPos()) < 150 then
				nzDoors:BuyDoor( bot, v )
			elseif v:GetClass() == "wall_buys" and tonumber(v:GetPrice()) <= bot:GetPoints() and (IsValid(bot:GetActiveWeapon()) and bot:GetActiveWeapon():GetClass() ~= v:GetWepClass()) and bot.LastGunPrice <= tonumber(v:GetPrice()) and v:GetPos():Distance(bot:GetPos()) < 120 then
				--print(v:GetWepClass())
				v:Use(bot, bot, USE_SET, 1)
				bot.LastGunPrice = tonumber(v:GetPrice())
				timer.Simple(0.1, function() bot:SelectWeapon(v:GetWepClass()) end)
			elseif v:GetClass() == "breakable_entry" and v:GetPos():Distance(bot:GetPos()) < 180 then
				v:Use(bot, bot, USE_SET, 1)
			end
		end]]

		--[[for m, n in pairs(player.GetAll()) do
			if n:GetPos():Distance(bot:GetPos()) < 320 and !n:GetNotDowned() then
				--print(n:Nick().." is Downed!")
				bot.UseTarget = n
			end
		end]]


		if !bot:Alive() and bot:Team() ~= TEAM_SPECTATOR then
			cmd:SetButtons(IN_ATTACK)
		end

		--[[if bot:GetPlayerClass() == "engineer" then
			bot:ConCommand("build", "3")
		end]]
		
		if bot:GetPlayerClass() == "medic" or bot:GetPlayerClass() == "ubermedic" and (!IsValid(intel) or (IsValid(intel) and intel.Carrier ~= bot)) then
				--print(intel)
			local targetply = player.GetAll()[1]
			for k, v in pairs(player.GetAll()) do
				if v ~= bot and v:Team() == bot:Team() then
					targetply = v
				end
			end

			if IsValid(targetply) and targetply:Team() == bot:Team() then
				targetpos2 = targetply:GetPos()
				local trace = util.QuickTrace(bot:EyePos(), targetply:EyePos() - bot:EyePos(), bot)
				debugoverlay.Line(trace.StartPos, trace.HitPos, 1, Color( 255, 255, 0 ))

				if trace.Entity == targetply then
					bot.TargetEnt = targetply
					bot:SetEyeAngles((targetply:EyePos() - bot:GetShootPos()):Angle())
					bot:SelectWeapon("tf_weapon_medigun")
					bot:SelectWeapon("tf_weapon_medigun_qf")
					bot:SelectWeapon("tf_weapon_medigun_vaccinator")
					cmd:SetButtons(IN_ATTACK)
				else
					bot.TargetEnt = nil
				end
			end
		end

		--PrintTable(Entity(2):GetAttachments())

		if bot:GetPlayerClass() == "pyro" or bot:GetPlayerClass() == "giantpyro" then
			for k,v in ipairs(ents.FindInSphere(bot:GetPos(), 120)) do
				if v:GetClass() == "tf_projectile_arrow" or v:GetClass() == "tf_projectile_pipe_remote" or v:GetClass() == "tf_projectile_ball" or v:GetClass() == "tf_projectile_pipe" or v:GetClass() == "tf_projectile_flare" or v:GetClass() == "tf_projectile_sentryrocket" or v:GetClass() == "tf_projectile_rocket_airstrike" or v:GetClass() == "tf_projectile_rocket" or v:GetClass() == "rpg_missile" or v:GetClass() == "prop_combine_ball" or v:GetClass() == "npc_grenade_frag" or v:GetClass() == "crossbow_bolt" or v:GetClass() == "grenade_ar2" or v:GetClass() == "grenade_spit" or v:GetClass() == "soldierbot_rocket_launched" or v:GetClass() == "soldier_rocket_launched" then
					cmd:SetButtons(IN_ATTACK2)
				end
			end
		end
		local BotCanTarget = tf_bot_notarget:GetBool()
		local BotCanTargetPlayer = GetConVar("ai_ignoreplayers"):GetBool()
		if bot:GetPlayerClass() == "tank" and bot:GetPlayerClass() == "l4d_zombie" and bot:GetPlayerClass() == "boomer" and bot:GetPlayerClass() == "charger" and bot:GetPlayerClass() == "smoker" then
			local args = {"TLK_PLAYER_CLOAKEDSPY"}
			if bot:Speak(args[1]) then
				umsg.Start("TerrorPlayerVoice")
					umsg.Entity(bot)
				umsg.End()
			end
		end
		if !BotCanTarget then
			
			if !BotCanTargetPlayer then
				if bot:GetPlayerClass() == "sentrybuster" then
					
					for k, v in pairs(ents.GetAll()) do
						if v:GetClass() == "obj_sentrygun" and !v:IsFriendly(bot) and v:Health() >= 0 and GAMEMODE:EntityTeam(v) ~= TEAM_SPECTATOR then
							if !IsValid(v) then bot:SetPlayerClass("demoman") return end
							local att
							att = v:GetBonePosition(v:LookupBone("weapon_bone"))
							local trace = util.QuickTrace(bot:EyePos(), att - bot:EyePos(), team.GetPlayers(bot:Team()))
							
							for _,ents in ipairs(ents.FindInSphere(bot:GetPos(), 800)) do
								if ents == v then
									bot.TargetEnt = v
								end
							end
						end
					end

				else
					if bot:GetPlayerClass() != "spy" and bot:GetPlayerClass() != "engineer" then
						for k, v in pairs(player.GetAll()) do
							if v:Team() ~= bot:Team() and v:Alive() and v:Team() ~= TEAM_SPECTATOR and v:GetNoDraw() != true then

								local att
								if !v:IsHL2() then
									if v:GetPlayerClass() == "combinesoldier" then
										att = v:GetBonePosition(v:LookupBone("ValveBiped.Bip01_Head1"))
									else
										att = v:GetAttachment(v:LookupAttachment("head")).Pos
									end
								else
									att = v:GetBonePosition(v:LookupBone("ValveBiped.Bip01_Head1"))
								end
								local trace = util.QuickTrace(bot:EyePos(), att - bot:EyePos(), team.GetPlayers(bot:Team()))
								if v:GetPlayerClass() == "spy" then
									if v:GetModel() == "models/player/scout.mdl" or  v:GetModel() == "models/player/soldier.mdl" or  v:GetModel() == "models/player/pyro.mdl" or  v:GetModel() == "models/player/demo.mdl" or  v:GetModel() == "models/player/heavy.mdl" or  v:GetModel() == "models/player/engineer.mdl" or  v:GetModel() == "models/player/medic.mdl" or  v:GetModel() == "models/player/sniper.mdl" or  v:GetModel() == "models/player/hwm/spy.mdl" or v:GetModel() == "models/player/kleiner.mdl" then
										if trace.Entity == v then
											bot.TargetEnt = nil
										end
									end
								end
								if trace.Entity == v then
									bot.TargetEnt = v
								end
							elseif v:Team() ~= bot:Team() and v:Alive() and v:Team() ~= TEAM_SPECTATOR and v:GetNoDraw() == true then
								local args = {"TLK_PLAYER_CLOAKEDSPY"}
								if bot:Speak(args[1]) then
								
									umsg.Start("TFPlayerVoice")
										umsg.Entity(bot)
										umsg.String(args[1])
									umsg.End()
								end
							end
						end
					end
				end
			end
		end

		

		--[[if BotCanTarget and !IsValid(bot.TargetEnt) and (bot:GetPlayerClass() ~= "medic" or (bot:GetPlayerClass() == "medic" and bot:GetActiveWeapon() and bot:GetActiveWeapon():GetClass() ~= "tf_weapon_medigun")) then
			for k, v in pairs(ents.GetAll()) do
				if (v:IsNPC() or v:GetClass() == "obj_sentrygun" or v:IsPlayer())
				and (GAMEMODE:EntityTeam(v) ~= bot:Team() or GAMEMODE:EntityTeam(v) == TEAM_NEUTRAL)
				and v ~= bot and v:Alive() and v:IsBot() then --and v:GetPos():Distance(bot:GetPos()) < 350 then
					local headbone = v:LookupBone("ValveBiped.Bip01_Head1")
					local targetpos = v:GetPos()
					if !headbone then
						headbone = v:LookupBone("bip_head")
					end
					--print(headbone)
					if headbone then
						targetpos = v:GetBonePosition(headbone)
					end]]
					--[[for i=0, v:GetBoneCount()-1 do
						print(v:GetBoneName(i))
					end]]
						--[[local trace = util.TraceLine({
							start = bot:GetShootPos(),
							endpos = targetpos,
							filter = function( ent )
								if ent == v then
									return true
								end
							end
						})]]
						--[[local newpos = v:EyePos() or v:GetPos()
						local trace = util.QuickTrace(bot:EyePos(), newpos - bot:EyePos(), bot)
						local color = Color(255, 0, 0)
						-- debugoverlay.Line(trace.StartPos, trace.HitPos, 0.03, color)
					if trace.Entity == v then
						bot.TargetEnt = v
						--print(v)
					end
				end
			end
		end]]

		if bot:Health() < bot:GetMaxHealth() / 3 then
			if math.random(2) == 1 then
				local args = {"TLK_PLAYER_MEDIC"}
				if bot:Speak(args[1]) then
					bot:DoAnimationEvent(ACT_MP_GESTURE_VC_HANDMOUTH, true)
			
					umsg.Start("TFPlayerVoice")
						umsg.Entity(bot)
						umsg.String(args[1])
					umsg.End()
				end
			end
		end

		cmd:SetForwardMove(1000)
		
		if bot:GetPlayerClass() == "engineer" and bot:Team() == TEAM_BLU then

			if bot:GetPlayerClass() == "engineer" then	
				for k, v in pairs(ents.FindInSphere(bot:GetPos(), 2300)) do
					if bot:GetPos():Distance(v:GetPos()) >= 40 and v:GetClass() == "bot_hint_sentrygun" then
						bot:Build(2,0)
						cmd:SetForwardMove(800)
						targetpos2 = v:GetPos()
					elseif bot:GetPos():Distance(v:GetPos()) <= 20 and v:GetClass() == "bot_hint_sentrygun" then
						cmd:SetButtons(IN_ATTACK)
						print("Buildin' a sentry!")
						targetpos2 = v:GetPos()
					end
				end
			end
		end
		if IsValid(bot.TargetEnt) then
			--for i=0, bot.TargetEnt:GetBoneCount()-1 do
					--print(bot.TargetEnt:GetBoneName(i))
			--	end
			--[[if bot:GetPos():Distance(bot.TargetEnt:GetPos()) < 40 then
				bot:Give("nz_quickknife_crowbar")
				bot:SelectWeapon("nz_quickknife_crowbar")
			end]]
			--[[if (IsValid(bot:GetActiveWeapon()) and bot:GetActiveWeapon().Base ~= "tf_weapon_melee_base") and bot:GetPos():Distance(bot.TargetEnt:GetPos()) < 120 then
				cmd:SetForwardMove( -250 )
			else]]
			if bot:GetPos():Distance(bot.TargetEnt:GetPos()) < 450 and bot.TargetEnt:GetMaterial() != "models/shadertest/predator" then
			
				if bot:GetPlayerClass() == "demoknight" then
					if bot:GetPos():Distance(bot.TargetEnt:GetPos()) < 140 and bot.TargetEnt:GetMaterial() != "models/shadertest/predator" then
						cmd:SetButtons(IN_ATTACK)
					else
						cmd:SetButtons(IN_ATTACK2)
					end

				end

			end

			if bot:GetPos():Distance(bot.TargetEnt:GetPos()) < 250 and bot.TargetEnt:GetMaterial() != "models/shadertest/predator" then
				if !bot.TargetEnt:IsFriendly(bot) and bot.TargetEnt:GetClass() != "obj_sentrygun" and bot:GetActiveWeapon():GetClass() != "tf_weapon_fists" and bot:GetActiveWeapon():GetClass() != "tf_weapon_bat" and bot:GetActiveWeapon():GetClass() != "tf_weapon_bat_fish" and bot:GetActiveWeapon():GetClass() != "tf_weapon_sword" then
					cmd:SetForwardMove(-250)
				end
				if bot:GetPlayerClass() == "pyro" then
					if bot:GetNWBool("Taunting") == false then
						if bot:GetPlayerClass() == "merc_dm" and bot:GetActiveWeapon() == "tf_weapon_gatlinggun" then
							cmd:SetButtons(IN_ATTACK)
						else
							cmd:SetButtons(IN_ATTACK)
						end
					end
				end
			end
			--if IsValid(bot:GetActiveWeapon()) and bot:GetActiveWeapon():Clip1() ~= 0 then
				--print("SHOOT!!!")
				--bot:GetActiveWeapon():PrimaryAttack()
				--cmd:SetButtons(IN_CANCEL)
			if bot:GetPlayerClass() ~= "pyro" and bot:GetActiveWeapon():GetClass() != "tf_weapon_fists" then
				if math.random(2) == 1 or bot:GetPlayerClass() == "heavy" or bot:GetPlayerClass() == "pyro" or bot:GetPlayerClass() == "giantpyro" or bot:GetPlayerClass() == "giantheavy" or bot:GetPlayerClass() == "medic" and bot:GetActiveWeapon():GetClass() == "tf_weapon_medigun" or  bot:GetActiveWeapon():GetClass() == "tf_weapon_medigun_qf" and bot:GetActiveWeapon():GetClass() == "tf_weapon_medigun_vaccinator" and bot.TargetEnt:GetMaterial() != "models/shadertest/predator" then --[[or bot:GetActiveWeapon().Base ~= "tf_weapon_melee_base")]]
					if bot:GetNWBool("Taunting") == false then
						cmd:SetButtons(IN_ATTACK)
					end
				end
			end
				--bot:GetActiveWeapon():SetClip1(100)
			--end
		else
			cmd:SetButtons(IN_RELOAD)
			--[[if bot:GetPlayerClass() == "heavy" then
				--cmd:SetButtons(IN_ATTACK2)
			end]]
		end

		if IsValid(bot:GetActiveWeapon()) and bot:GetActiveWeapon():Clip1() == 0 then
			--print(bot:GetActiveWeapon():Clip1())
			--print("RELOAD")
			--bot:GetActiveWeapon():SetClip1(1)
			if math.random(2) == 1 then
				cmd:SetButtons(IN_RELOAD)
			end
		end

		--print(bot.UseTarget)

		--[[if IsValid(bot.UseTarget) then
			cmd:SetButtons(IN_USE)
			if bot:GetPos():Distance(bot.UseTarget:GetPos()) > 50 then
				cmd:SetForwardMove(250)
			end
		end

		if bot:GetMoveType() == MOVETYPE_LADDER then
			cmd:SetButtons(bit.bor(IN_JUMP, IN_DUCK))
			--cmd:SetForwardMove(-250)
			bot:SetMoveType(MOVETYPE_WALK)
			local pos = navmesh.GetNavArea(targetply:GetPos(), 5):GetRandomPoint()
			if isvector(pos) then
					bot:SetPos(pos)
			end

		end]]

		--print(math.abs(cmd:GetForwardMove()), math.floor(math.abs(tonumber(bot:GetVelocity():Length()))))

		--[[if math.floor(math.abs(tonumber(bot:GetVelocity():Length()))) <= 1 and math.abs(cmd:GetForwardMove()) >= 1 and bot:GetNotDowned() then
			cmd:SetButtons(IN_JUMP)
			print("Stuck!")
		end]]

		--print(bot.TargetEnt)
		
		if IsValid(bot.TargetEnt) then 
			targetpos2 = bot.TargetEnt:GetPos()
		end

		bot.ControllerBot.PosGen = targetpos2 --targetply:GetPos() --navmesh.GetNavArea(Entity(1):GetPos(), 1):GetCenter() or Entity(1):GetPos()
		--[[if bot:GetPos():Distance(bot.ControllerBot.PosGen) > 150 and !ignoreback then
			cmd:SetForwardMove( 1000 )
		elseif bot:GetPos():Distance(bot.ControllerBot.PosGen) < 100 and !ignoreback then
			cmd:SetForwardMove( -250 )
		else]]
			
		--end

		if bot.ControllerBot.P then
			bot.LastPath = bot.ControllerBot.P:GetAllSegments()
		end

		if !bot.ControllerBot.P then
			return
		end

		if bot.CurSegment ~= 2 and !table.EqualValues( bot.LastPath, bot.ControllerBot.P:GetAllSegments() ) then
			bot.CurSegment = 2
		end
		
		if !bot.LastPath then return end
		local curgoal = bot.LastPath[bot.CurSegment]
		if !curgoal then return end -- why tf does this not work??

		if bot:GetPos():Distance(curgoal.pos) < 50 then
			bot.LastSegmented = CurTime()
			if bot.LastPath[bot.CurSegment + 1] then
				curgoal = bot.LastPath[bot.CurSegment + 1] 
			end
		end
		--debugoverlay.Text(curgoal.pos, bot:Nick().."'s goal", 0.03, false)
		--bot:LookatPosXY( cmd, curgoal.pos )
		--bot:SetEyeAngles((curgoal.pos - bot:GetShootPos()):Angle())

		local lerp = 0.3
		if bot.Difficulty == 0 then
			lerp = 0.2
		elseif bot.Difficulty == 2 then
			lerp = 0.5
		elseif bot.Difficulty == 3 then
			lerp = 0.7
		end

		if IsValid(bot.TargetEnt) then
			bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (bot.TargetEnt:EyePos() - bot:GetShootPos()):Angle()))
		elseif curgoal and bot:GetPos():Distance(curgoal.pos) > 20 then
			bot:SetEyeAngles(LerpAngle(0.25, bot:EyeAngles(), ((curgoal.pos + Vector(0, 0, 65)) - bot:GetShootPos()):Angle()))
		end

		bot.LastSegmented = bot.LastSegmented or CurTime()

		--debugoverlay.Text(bot:GetPos(), bot:Nick().." LAST: "..bot.LastSegmented - CurTime().." DISTANCE: "..bot:GetPos():Distance( curgoal.pos ), 0.001, false)
		--debugoverlay.Sphere(bot:GetPos(), 10, 0.05, gamemode.Call("GetTeamColor", bot), true)
		--debugoverlay.Line(bot:GetPos(), curgoal.pos, 1.1, Color(0, 255, 0), true)


		--[[bot:SetEyeAngles((curgoal.pos - bot:GetShootPos()):Angle())

		if IsValid(bot.TargetEnt) then
			bot:SetEyeAngles((targetpos2 - bot:GetShootPos()):Angle())
		end]]

		--debugoverlay.Text(bot:EyePos() - Vector(0, 0, 15), math.abs(bot.LastSegmented - CurTime()), 0.005, false)
		
		--if bot.LastSegmented - CurTime() < -5 and !IsValid(bot.TargetEnt) and !util.IsInWorld(curgoal.pos) then -- ai fault check (buggy)
			--debugoverlay.Text(bot:EyePos(), "yikes!", 1, false)
			--[[bot.CurSegment = bot.CurSegment + 1
			bot.LastSegmented = CurTime()
			local curgoal = bot.LastPath[bot.CurSegment + 1]
			if !curgoal then return end
			bot:LookatPosXY( cmd, curgoal.pos + Vector(0, 0, 150) )
			--debugoverlay.Line(bot:GetPos(), curgoal.pos + Vector(0, 0, 150), 1.1, Color(255, 255, 255), true)
			cmd:SetForwardMove( 1000 )]]
			--bot:SetPos(curgoal.pos)
			--bot.LastSegmented = CurTime()
		--end

		--print(bot.CurSegment)
	end
end)

hook.Add("PostPlayerDeath", "leadbot_respawn", function(bot)
	timer.Simple(2, function() if bot.LKBot and !bot:Alive() then bot:Spawn() end end)
end)

function table.EqualValues(t1,t2,ignore_mt)
	ignore_mt = ignore_mt or true
	local ty1 = type(t1)
	local ty2 = type(t2)
	if ty1 ~= ty2 then return false end
	-- non-table types can be directly compared
	if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
	-- as well as tables which have the metamethod __eq
	local mt = getmetatable(t1)
	if not ignore_mt and mt and mt.__eq then return t1 == t2 end
	for k1,v1 in pairs(t1) do
		local v2 = t2[k1]
		if v2 == nil or not table.EqualValues(v1,v2) then return false end
	end
	for k2,v2 in pairs(t2) do
		local v1 = t1[k2]
		if v1 == nil or not table.EqualValues(v1,v2) then return false end
	end
	return true
end

debug.getregistry().Player.LookatPosXY = function( self, cmd, pos )
	if IsValid(self.TargetEnt) then
		local targetpos = self.TargetEnt:EyePos() or self.TargetEnt:GetPos()
		--[[if self.TargetEnt:LookupBone("bip_head") then
			targetpos = self.TargetEnt:GetBonePosition(self.TargetEnt:LookupBone("bip_head")) 
		elseif self.TargetEnt:LookupBone("ValveBiped.Bip01_Head1") then
			targetpos = self.TargetEnt:GetBonePosition(self.TargetEnt:LookupBone("ValveBiped.Bip01_Head1"))
		end]]

		local lerp = 0.2
		if self.Difficulty == 0 then
			lerp = 0.3
		elseif self.Difficulty == 2 then
			lerp = 0.1
		elseif self.Difficulty == 3 then
			lerp = 0
		end

		local angle = LerpAngle(lerp, self:EyeAngles(), (targetpos - self:GetShootPos()):Angle())
		--local angle = (targetpos - self:GetShootPos()):Angle()
		self:SetEyeAngles(angle)
		cmd:SetViewAngles(angle)
		return
	end

	local our_position = self:GetPos()
	local distance = our_position:Distance( pos )
	local pitch = math.atan2( -(pos.z - our_position.z), distance )
	local yaw = math.deg(math.atan2(pos.y - our_position.y, pos.x - our_position.x))

	--local angle = LerpAngle(0.2, self:EyeAngles(), Angle( pitch, yaw, 0 ))
	local angle = Angle( pitch, yaw, 0 )
	--print(pos)
	--local angle = (pos - self:GetShootPos()):Angle()

	self:SetEyeAngles( angle )
	cmd:SetViewAngles( angle )
end

concommand.Add("tf_bot_kick_all", function() for k, v in pairs(player.GetBots()) do v:Kick("Kicked from server") end end)
concommand.Add("tf_bot_bring_all", function(ply) for k, v in pairs(player.GetBots()) do v:SetPos(ply:GetPos()) end end)
concommand.Add("tf_bot_goto", function(ply) local bots = {} for k, v in pairs(player.GetBots()) do table.insert(bots, v) end ply:SetPos(table.Random(bots):GetPos()) end)
concommand.Add("tf_bot_bring", function(ply) local bots = {} for k, v in pairs(player.GetBots()) do table.insert(bots, v) end local pos = navmesh.GetNavArea(Entity(1):GetPos(), 5):GetRandomPoint() table.Random(bots):SetPos(pos) end)
concommand.Add("tf_bot_kill_all", function() for k, v in pairs(player.GetAll()) do if v:IsBot() then v:Kill() end end end)
concommand.Add("tf_bot_kill_bots", function() for k, v in pairs(player.GetBots()) do v:Kill() end end)
concommand.Add("tf_bot_say", function(ply, _, args) for k, v in pairs(player.GetBots()) do v:Say(args[1]) end end)

--concommand.Add("lk.noclip", function(ply) if ply:GetMoveType() == MOVETYPE_NOCLIP then ply:SetMoveType(MOVETYPE_WALK) else ply:SetMoveType(MOVETYPE_NOCLIP) end end)
--concommand.Add("lk.downme", function(ply) ply:DownPlayer() end)
concommand.Add("tf_bot_add", function(_, _, args) LBAddBot(args[1]) end)

concommand.Add("tf_bot_name_add", function(_, _, args) table.insert(names, args[1]) print(args[1].." added to names list!") end)
concommand.Add("tf_bot_quota", function(_, _, args) for i=0, args[1]-1 do LBAddBot() end end)

--concommand.Add("lk.playerclass", function(_, _, args) for k, v in pairs(player.GetBots()) do v:SetPlayerClass(args[1]) end end)

concommand.Add("tf_bot_scramble", function(_, _, args) for k, v in pairs(player.GetBots()) do local teamd = TEAM_RED if math.random(2) == 1 then teamd = TEAM_BLU end v:SetTeam(teamd) end end)

--concommand.Add("lk.neutral", function(_, _, args) for k, v in pairs(player.GetBots()) do v:SetTeam(TEAM_NEUTRAL) end end)
--:SpectateEntity(table.Random(player.GetBots()))
concommand.Add("tf_spectate_bot", function(ply, _, args) if args[1] == "2" then ply:Spectate(OBS_MODE_CHASE) return elseif args[1] == "1" then ply:Spectate(OBS_MODE_IN_EYE) return elseif args[1] == "3" then ply:Spectate(OBS_MODE_ROAMING) return end ply:StripWeapons() local bot = table.Random(player.GetBots()) ply:SpectateEntity(bot) ply:Spectate(OBS_MODE_IN_EYE) end)
concommand.Add("tf_unspectate_bot", function(ply) ply:UnSpectate() ply:KillSilent() ply:Spawn() end)

concommand.Add("tf_bot_takecontrol", function(ply) local bot = ply:GetObserverTarget() ply:UnSpectate() ply:SetMoveType(MOVETYPE_WALK) ply:KillSilent() ply:Spawn() ply:SetTeam(bot:Team()) ply:SetPlayerClass(bot:GetPlayerClass()) timer.Simple(0.1, function() ply:UnSpectate() ply:SetPlayerClass(bot:GetPlayerClass()) timer.Simple(0.1, function() ply:SetHealth(bot:Health()) ply:SetPos(bot:GetPos()) ply:SetEyeAngles(bot:EyeAngles()) ply:SendLua([[surface.PlaySound("misc/freeze_cam.wav")]]) bot:Kill() end) end) end)

--[[concommand.Add("tf_bot_difficulty", function(_, _, args)
	if !args[1] then MsgN("Defines the skill of bots joining the game.") return
	local diffn = "easy"
	if args[1] == "2" then
		diffn = "medium"
	elseif args[1] == "3" then
		diffn = "hard" 
	end

	for k, v in pairs(player.GetBots()) do
		v.Difficulty = args[1]
	end 

	for k, v in pairs(player.GetAll()) do 
		v:ChatPrint("Difficulty has been set to "..args[1].." ("..diffn..")") 
	end 
end)]]

include("profiles/default.lua")
PrintTable(profiles)