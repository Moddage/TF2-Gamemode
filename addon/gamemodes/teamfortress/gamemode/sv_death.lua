local allowedtaunts = {
"1",
"2",
"3",
}
local ENT_ID_CURRENT = 1
hook.Add("OnEntityCreated", "TF_DeathNoticeEntityID", function(ent)
	if IsValid(ent) then
		ent.DeathNoticeEntityID = ENT_ID_CURRENT
		ENT_ID_CURRENT = ENT_ID_CURRENT + 1
		if ENT_ID_CURRENT >= 16384 then
			ENT_ID_CURRENT = 1
		end
	end
end)

function GM:DoTFPlayerDeath(ent, attacker, dmginfo)
	if not IsValid(attacker) then return end
	
	local inflictor = (dmginfo and dmginfo:GetInflictor()) or game.GetWorld()
	
	local shouldgib = false
	
	
	ent:StopSound("Weapon_Minifun.Fire")
	ent:StopSound("Weapon_Minigun.Fire")
	ent:StopSound("Weapon_Tomislav.ShootLoop")
	ent:StopSound("Weapon_Minifun.FireCrit")
	ent:StopSound("Weapon_Minigun.FireCrit")
	ent:StopSound("Weapon_Tomislav.FireCrit")
	if ent:IsNPC() and dmginfo and dmginfo:IsDamageType(DMG_BLAST) then
		umsg.Start("GibNPC")
			umsg.Entity(ent)
			umsg.Short(ent.DeathFlags)
		umsg.End()
		for _,v in pairs(ents.FindByClass("class C_ClientRagdoll")) do
			v:Fire("Kill", "", 0.1)
		end
	end

	if ent:IsPlayer() and ent:HasDeathFlag(DF_DECAP) then
		umsg.Start("GibPlayerHead")
			umsg.Entity(ent)
			umsg.Short(ent.DeathFlags)
		umsg.End()
	end
	
	for k,v in ipairs(ents.FindByName("SpyWeaponModel"..ent:EntIndex())) do
		v:Fire("Kill", "", 0.1)
	end

	-- Remove all player states
	ent:SetPlayerState(0, true)
	if ent:GetNWBool("Taunting") == true then ent:SetNWBool("Taunting", false) ent:Freeze(false) ent:ConCommand("tf_firstperson") end
	attacker.customdeath = ""
	local InflictorClass = gamemode.Call("GetInflictorClass", ent, attacker, inflictor)
	
	if string.find(InflictorClass, "headshot") then
		attacker.customdeath = "headshot"
		ent:SetNWBool("DeathByHeadshot", true)
	elseif string.find(InflictorClass, "backstab") then
		attacker.customdeath = "backstab"
		ent:SetNWBool("DeathByBackstab", true)
	elseif inflictor:GetClass() == "obj_sentrygun" then
		if inflictor:GetBuildingType() == 1 then
			attacker.customdeath = "minisentrygun"
		else
			attacker.customdeath = "sentrygun"
		end
		
		inflictor:AddKills(1)
	end
	
	if inflictor and inflictor.OnPlayerKilled then
		inflictor:OnPlayerKilled(ent)
	end
	
	ApplyAttributesFromEntity(inflictor, "on_kill", ent, inflictor, attacker)
	if attacker:IsPlayer() then
		ApplyGlobalAttributesFromPlayer(attacker, "on_kill", ent, inflictor, attacker)
	end
	
	self:ExtinguishEntity(ent)
	self:RemoveDamageCooperationsOnDeath(ent)
	
	if ent:IsPlayer() then
		ent:AddDeaths(1)
	end
	
	if attacker:IsWeapon() then
		attacker = attacker:GetOwner()
	end
	
	if attacker:IsVehicle() and IsValid(attacker:GetDriver()) then
		attacker = attacker:GetDriver()
	end
	
	if attacker:IsPlayer() and attacker ~= ent then
		local score = inflictor.Score or 1
		if attacker.customdeath == "headshot" then
			attacker:AddHeadshots(1)
			score = score + (inflictor.HeadshotScore or 0.5)
		end
		if attacker.customdeath == "backstab" then
			attacker:AddBackstabs(1)
			score = score + 1
		end
		
		attacker:AddFrags(score * ent:GetScoreMultiplier())
		
		if ent:IsBuilding() then
			attacker:AddDestructions(1)
		else
			attacker:AddKills(1)
		end
	end
	
	local assistants = self:GetAllAssistants(ent, attacker)
	for a,v in pairs(assistants) do
		if a:IsPlayer() then
			a:AddAssists(1)
			a:AddFrags(0.5 * ent:GetScoreMultiplier())
			
			ApplyGlobalAttributesFromPlayer(a, "on_kill", ent, inflictor, attacker)
		end
		
		if v
			and isentity(v)
			and v.inflictor and
			v.inflictor:IsBuilding()
			and v.inflictor.AddAssists then
			v.inflictor:AddAssists(1)
		end
	end
	
	--[[
	print(ent)
	print("Global assist table")
	PrintTable(attacker.GlobalAssistants or {})
	print("Assist table")
	PrintTable(ent.DamageCooperations or {})
	print("Assistants")
	PrintTable(assistants)
	]]
	
	ent.KillerDominationInfo = 0
	
	if not ent.KillComboCounter then
		ent.KillComboCounter = {}
	end
	
	if not attacker.KillComboCounter then
		attacker.KillComboCounter = {}
	end
	
	ent.KillComboCounter[attacker] = 0
	attacker.KillComboCounter[ent] = (attacker.KillComboCounter[ent] or 0) + 1
	
	for a,_ in pairs(assistants) do
		if not a.KillComboCounter then
			a.KillComboCounter = {}
		end
		
		ent.KillComboCounter[a] = 0
		a.KillComboCounter[ent] = (a.KillComboCounter[ent] or 0) + 1
	end
	
	if attacker.KillComboCounter[ent] >= 4 then
		if self:PlayerIsNemesis(attacker, ent) then
			ent.KillerDominationInfo = 2 -- nemesis
		else
			self:TriggerDomination(ent, attacker)
			ent.KillerDominationInfo = 1 -- new nemesis
		end
	end
	
	for a,_ in pairs(assistants) do
		if a.KillComboCounter[ent] >= 4 then
			self:TriggerDomination(ent, a)
		end
	end
	
	if self:PlayerIsNemesis(ent, attacker) then
		self:TriggerRevenge(ent, attacker)
		ent.KillerDominationInfo = 3 -- revenge
	end
	
	for a,_ in pairs(assistants) do
		if self:PlayerIsNemesis(ent, a) then
			self:TriggerRevenge(ent, a)
		end
	end
	
	-- Voice responses
	if attacker:IsPlayer() and ent~=attacker then
		if ent:IsBuilding() then
			if attacker:GetInfoNum("tf_robot",0) != 1 then
				attacker:Speak("TLK_KILLED_OBJECT")
			end
		else
			self:AddKill(attacker)
			attacker.victimclass = ent.playerclass or ""
			if attacker:GetInfoNum("tf_robot",0) != 1 then
				attacker:Speak("TLK_KILLED_PLAYER")
			end
		end
	end
	attacker.domination = ""
end

function GM:PostTFPlayerDeath(ent, attacker, inflictor)
	if GAMEMODE:EntityTeam(attacker) == TEAM_HIDDEN then
		return
	end
	
	if IsValid(inflictor) and attacker == inflictor and inflictor:IsPlayer() then
		inflictor = inflictor:GetActiveWeapon()
		if not IsValid(inflictor) then inflictor = attacker end
	end
	
	local cooperator = self:GetDisplayedAssistant(ent, attacker) or NULL
	--print("Displayed assistant")
	--print(cooperator)

	if attacker:IsWeapon() then
		attacker = attacker:GetOwner()
	end
	
	if attacker:IsVehicle() and IsValid(attacker:GetDriver()) then
		attacker = attacker:GetDriver()
	end
	
	local killer = attacker
	
	--[[if inflictor.KillCreditAsInflictor then
		killer = inflictor
	end]]
	
	-- X fell to a clumsy, painful death
	if ent.LastDamageInfo and ent.LastDamageInfo:IsFallDamage() then
		umsg.Start("Notice_EntityFell")
			umsg.String(GAMEMODE:EntityDeathnoticeName(ent))
			umsg.Short(GAMEMODE:EntityTeam(ent))
			umsg.Short(GAMEMODE:EntityID(ent))
		umsg.End()
	elseif attacker == ent then
		-- Suicide
		if IsValid(cooperator) and GAMEMODE:EntityTeam(cooperator)~=TEAM_HIDDEN then
			-- Y finished off X
			umsg.Start("Notice_EntityFinishedOffEntity")
				umsg.String(GAMEMODE:EntityDeathnoticeName(ent))
				umsg.Short(GAMEMODE:EntityTeam(ent))
				umsg.Short(GAMEMODE:EntityID(ent))
				
				umsg.String(GAMEMODE:EntityDeathnoticeName(cooperator))
				umsg.Short(GAMEMODE:EntityTeam(cooperator))
				umsg.Short(GAMEMODE:EntityID(cooperator))
			umsg.End()
		elseif attacker==inflictor then
			-- X bid farewell, cruel world!
			umsg.Start("Notice_EntitySuicided")
				umsg.String(GAMEMODE:EntityDeathnoticeName(ent))
				umsg.Short(GAMEMODE:EntityTeam(ent))
				umsg.Short(GAMEMODE:EntityID(ent))
			umsg.End()
		else
			local InflictorClass = gamemode.Call("GetInflictorClass", ent, attacker, inflictor)
			
			-- <killicon> X
			umsg.Start("Notice_EntityKilledEntity")
				umsg.String(GAMEMODE:EntityDeathnoticeName(ent))
				umsg.Short(GAMEMODE:EntityTeam(ent))
				umsg.Short(GAMEMODE:EntityID(ent))
				
				umsg.String(InflictorClass)
				
				umsg.String(GAMEMODE:EntityDeathnoticeName(ent))
				umsg.Short(GAMEMODE:EntityTeam(ent))
				umsg.Short(GAMEMODE:EntityID(ent))
				
				umsg.String(GAMEMODE:EntityDeathnoticeName(cooperator))
				umsg.Short(GAMEMODE:EntityTeam(cooperator))
				umsg.Short(GAMEMODE:EntityID(cooperator))
				
				umsg.Bool(ent.LastDamageWasCrit)
			umsg.End()
		end
	else
		local InflictorClass = gamemode.Call("GetInflictorClass", ent, attacker, inflictor)
		
		-- Y <killicon> X
		umsg.Start("Notice_EntityKilledEntity")
			umsg.String(GAMEMODE:EntityDeathnoticeName(ent))
			umsg.Short(GAMEMODE:EntityTeam(ent))
			umsg.Short(GAMEMODE:EntityID(ent))
			
			umsg.String(InflictorClass)
			
			umsg.String(GAMEMODE:EntityDeathnoticeName(killer))
			umsg.Short(GAMEMODE:EntityTeam(killer))
			umsg.Short(GAMEMODE:EntityID(killer))
			
			umsg.String(GAMEMODE:EntityDeathnoticeName(cooperator))
			umsg.Short(GAMEMODE:EntityTeam(cooperator))
			umsg.Short(GAMEMODE:EntityID(cooperator))
			
			umsg.Bool(ent.LastDamageWasCrit)
		umsg.End()
	end
	
	if ent.PendingNemesises then
		for _,v in ipairs(ent.PendingNemesises) do
			if IsValid(v) then
				umsg.Start("Notice_EntityDominatedEntity")
					umsg.String(GAMEMODE:EntityDeathnoticeName(ent))
					umsg.Short(GAMEMODE:EntityTeam(ent))
					umsg.Short(GAMEMODE:EntityID(ent))
					
					umsg.String(GAMEMODE:EntityDeathnoticeName(v))
					umsg.Short(GAMEMODE:EntityTeam(v))
					umsg.Short(GAMEMODE:EntityID(v))
				umsg.End()
				if v:IsPlayer() or v:IsNPC() then
					v:SendLua("surface.PlaySound('misc/tf_domination.wav')")
					ent:SendLua("surface.PlaySound('misc/tf_nemesis.wav')")
				end
				umsg.Start("PlayerDomination")
					umsg.Entity(ent)
					umsg.Entity(v)
				umsg.End()
			end
		end
		ent.PendingNemesises = nil
	end
	
	if ent.PendingRevenges then
		for _,v in ipairs(ent.PendingRevenges) do
			if IsValid(v) then
				umsg.Start("Notice_EntityRevengeEntity")
					umsg.String(GAMEMODE:EntityDeathnoticeName(ent))
					umsg.Short(GAMEMODE:EntityTeam(ent))
					umsg.Short(GAMEMODE:EntityID(ent))
					
					umsg.String(GAMEMODE:EntityDeathnoticeName(v))
					umsg.Short(GAMEMODE:EntityTeam(v))
					umsg.Short(GAMEMODE:EntityID(v))
				umsg.End()
				
				if v:IsPlayer() or v:IsNPC() then
					ent:SendLua("surface.PlaySound('misc/tf_revenge.wav')")
					v:SendLua("surface.PlaySound('misc/tf_revenge.wav')")
				end
				umsg.Start("PlayerRevenge")
					umsg.Entity(ent)
					umsg.Entity(v)
				umsg.End()
			end
		end
		ent.PendingRevenges = nil
	end
	
	ent.LastDamageWasCrit = false
end

function GM:OnTFPlayerDominated(ent, attacker)
	if attacker:IsPlayer() then
		attacker:AddDominations(1)
	end
	
	if not ent.PendingNemesises then
		ent.PendingNemesises = {}
	end
	table.insert(ent.PendingNemesises, attacker)
end

function GM:OnTFPlayerRevenge(ent, attacker)
	if attacker:IsPlayer() then
		attacker:AddRevenges(1)
		attacker:AddFrags(1)
	end
	
	if not ent.PendingRevenges then
		ent.PendingRevenges = {}
	end
	table.insert(ent.PendingRevenges, attacker)
end

local player_gib_probability = CreateConVar("player_gib_probability", 0.33)

local function TransferBones( base, ragdoll ) -- Transfers the bones of one entity to a ragdoll's physics bones (modified version of some of RobotBoy655's code)
	if !IsValid( base ) or !IsValid( ragdoll ) then return end
	for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		local bone = ragdoll:GetPhysicsObjectNum( i )
		if ( IsValid( bone ) ) then
			local pos, ang = base:GetBonePosition( ragdoll:TranslatePhysBoneToBone( i ) )
			if ( pos ) then bone:SetPos( pos ) end
			if ( ang ) then bone:SetAngles( ang ) end
		end
	end
end

local function SetEntityStuff( ent1, ent2 ) -- Transfer most of the set things on entity 2 to entity 1
	if !IsValid( ent1 ) or !IsValid( ent2 ) then return false end
	ent1:SetModel( ent2:GetModel() )
	ent1:SetPos( ent2:GetPos() )
	ent1:SetAngles( ent2:GetAngles() )
	ent1:SetColor( ent2:GetColor() )
	ent1:SetSkin( ent2:GetSkin() )
	ent1:SetFlexScale( ent2:GetFlexScale() )
	for i = 0, ent2:GetNumBodyGroups() - 1 do ent1:SetBodygroup( i, ent2:GetBodygroup( i ) ) end
	for i = 0, ent2:GetFlexNum() - 1 do ent1:SetFlexWeight( i, ent2:GetFlexWeight( i ) ) end
	for i = 0, ent2:GetBoneCount() do
		ent1:ManipulateBoneScale( i, ent2:GetManipulateBoneScale( i ) )
		ent1:ManipulateBoneAngles( i, ent2:GetManipulateBoneAngles( i ) )
		ent1:ManipulateBonePosition( i, ent2:GetManipulateBonePosition( i ) )
		ent1:ManipulateBoneJiggle( i, ent2:GetManipulateBoneJiggle( i ) )
	end
end


function GM:DoPlayerDeath(ply, attacker, dmginfo)
	local inflictor = dmginfo:GetInflictor()
	gamemode.Call("DoTFPlayerDeath", ply, attacker, dmginfo)
	ply:StopSound( "GrappledFlesh" )
	ply:StopSound("Grappling")
	local drop
	for _,v in pairs(ply:GetWeapons()) do
		if v.DropAsAmmo then
			if v.GetItemData and v:GetItemData().item_slot == "primary" then
				drop = v
			end
			
			if v == ply:GetActiveWeapon() and not v.DropPrimaryWeaponInstead then
				drop = v
				break
			end
		end
	end
	if ply:GetActiveWeapon():GetClass() == "tf_weapon_builder" and ply:GetActiveWeapon():GetItemData().model_player == "models/weapons/c_models/c_p2rec/c_p2rec.mdl" then
		ply:EmitSound("Psap.Death")
	end
	if attacker:IsPlayer() and ply:IsPlayer() then
		if attacker == ply then
			ply:EmitSound("player/pl_fleshbreak.wav", 70, math.random(92,96))
		else
			if dmginfo:GetInflictor().Critical and dmginfo:GetInflictor():Critical() then
				attacker:EmitSound("player/crit_hit"..math.random(2,5)..".wav", 90, math.random(88, 100))
				ply:EmitSound("player/crit_received"..math.random(1,3)..".wav", 50, math.random(88, 100))
			elseif attacker:GetInfo("tf_dingalingaling_killsound") == "killsound_electro" then
				attacker:EmitSound("ui/"..attacker:GetInfo("tf_dingalingaling_killsound")..".wav", 50)
			elseif attacker:GetInfo("tf_dingalingaling_killsound") == "killsound" then 
				attacker:EmitSound("ui/"..attacker:GetInfo("tf_dingalingaling_killsound")..".wav", 50)
			elseif attacker:GetInfo("tf_dingalingaling_killsound") == "killsound_menu_note" then 
				attacker:EmitSound("ui/"..attacker:GetInfo("tf_dingalingaling_killsound")..".wav", 50)
			elseif attacker:GetInfo("tf_dingalingaling_killsound") == "killsound_percussion" then 
				attacker:EmitSound("ui/"..attacker:GetInfo("tf_dingalingaling_killsound")..".wav", 50)
			elseif attacker:GetInfo("tf_dingalingaling_killsound") == "killsound_retro" then 
				attacker:EmitSound("ui/"..attacker:GetInfo("tf_dingalingaling_killsound")..".wav", 50)
			elseif attacker:GetInfo("tf_dingalingaling_killsound") == "killsound_vortex" then 
				attacker:EmitSound("ui/"..attacker:GetInfo("tf_dingalingaling_killsound")..".wav", 50)
			elseif attacker:GetInfo("tf_dingalingaling_killsound") == "killsound_squasher" then 
				attacker:EmitSound("ui/"..attacker:GetInfo("tf_dingalingaling_killsound")..".wav", 50)
			elseif attacker:GetInfo("tf_dingalingaling_killsound") == "killsound_space" then 
				attacker:EmitSound("ui/"..attacker:GetInfo("tf_dingalingaling_killsound")..".wav", 50)
			elseif attacker:GetInfo("tf_dingalingaling_killsound") == "killsound_beepo" then 
				attacker:EmitSound("ui/"..attacker:GetInfo("tf_dingalingaling_killsound")..".wav", 50)
			end
		end
	end	

	if ply:GetPlayerClass() == "merc_dm" then
		if dmginfo:GetInflictor().Critical and dmginfo:GetInflictor():Critical() then
			if not inflictor.IsSilentKiller then	
				ply:EmitSound("vo/mercenary_paincrticialdeath0"..math.random(1,4)..".wav")
			end
		elseif dmginfo:IsDamageType(DMG_CLUB) or dmginfo:IsDamageType(DMG_SLASH) or inflictor.HoldType=="MELEE" then
			if not inflictor.IsSilentKiller then	
				ply:EmitSound("vo/mercenary_paincrticialdeath0"..math.random(1,4)..".wav")
			end
		else
			if not inflictor.IsSilentKiller then
				ply:EmitSound("vo/mercenary_painsevere0"..math.random(1,6)..".wav")
			end
		end
	end
	for k,v in ipairs(player.GetBots()) do
		if v == attacker then

			if v:GetPlayerClass() == "combinesoldier" then
				EmitSentence( "COMBINE_THROW_GRENADE" .. math.random( 0, 4 ), v:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
			end
			--[[if v:GetInfoNum("tf_robot", 0) == 1 then v:ChatPrint("You can't taunt as a robot!") return end
			if v:GetInfoNum("tf_giantrobot", 0) == 1 then v:ChatPrint("You can't taunt as a mighty robot!") return end]]
			if not table.HasValue(allowedtaunts, v:GetActiveWeapon():GetSlot() + 1) then return end
			if v:GetPlayerClass() != "spy" then
				if table.KeyFromValue(allowedtaunts,v:GetActiveWeapon():GetSlot() + 1) == 1 then
			
					if v:GetPlayerClass() == "combinesoldier" then
						v:DoAnimationEvent(ACT_SPECIAL_ATTACK1, true)
						v:SetNWBool("Taunting", true)
						v:SetNWBool("NoWeapon", true) 
						local frag = ents.Create("npc_grenade_frag")
						net.Start("ActivateTauntCam")
						net.Send(v)
						frag:SetPos(v:EyePos() + ( v:GetAimVector() * 16 ) )
						frag:SetAngles( v:EyeAngles() )
						frag:SetOwner(v)

						timer.Simple(0.6, function()
							frag:Spawn()
							
							local phys = frag:GetPhysicsObject()
								if ( !IsValid( phys ) ) then frag:Remove() return end
								
								
								
								local velocity = v:GetAimVector()
								velocity = velocity * 1000
								velocity = velocity + ( VectorRand() * 10 ) -- a random element
								phys:ApvForceCenter( velocity )
								frag:Fire("SetTimer",5,0)
								frag:SetOwner(v)
								--timer.Simple(3.5,function() frag:Ignite() end)
						end)
						timer.Simple(1.2, function()
							if not IsValid(v) or (not v:Alive() and not v:GetNWBool("Taunting")) then return end
							v:SetNWBool("Taunting", false)
							v:SetNWBool("NoWeapon", false)
							print("Thegay.")
							net.Start("DeActivateTauntCam")
							net.Send(v)
						end)
							
					end
					
					if v:GetPlayerClass() == "pyro" then
						if v:GetInfoNum("tf_robot", 0) == 1 and table.KeyFromValue(allowedtaunts,args[1]) == 1 then
							timer.Simple(0.1, function()
								v:EmitSound("vo/mvm/norm/pyro_mvm_paincrticialdeath0"..math.random(1,3)..".mp3", 95, 100)
							end)
							timer.Simple(3, function()
								if not IsValid(v) or (not v:Alive() and not v:GetNWBool("Taunting")) then return end
								v:SetNWBool("Taunting", false)
								v:SetNWBool("NoWeapon", false)
								print("Thegay.")
								net.Start("DeActivateTauntCam")
								net.Send(v)
							end)
						end
					elseif v:GetPlayerClass() == "heavy" then
						if v:GetInfoNum("tf_robot", 0) == 1 and table.KeyFromValue(allowedtaunts,args[1]) == 1 then
							timer.Simple(2, function()
								v:EmitSound("vo/mvm/norm/heavy_mvm_goodjob0"..math.random(1,3)..".mp3", 95, 100)
							end)
							timer.Simple(8, function()
								if not IsValid(v) or (not v:Alive() and not v:GetNWBool("Taunting")) then return end
								v:SetNWBool("Taunting", false)
								v:SetNWBool("NoWeapon", false)
								print("Thegay.")
								net.Start("DeActivateTauntCam")
								net.Send(v)
							end)
						end
					elseif v:GetPlayerClass() == "medic" then
						if v:GetInfoNum("tf_robot", 0) == 1 and table.KeyFromValue(allowedtaunts,args[1]) == 1 then
							timer.Simple(0.1, function()
								v:EmitSound("vo/mvm/norm/medic_mvm_specialcompleted01.mp3", 95, 100)
							end)
							timer.Simple(3, function()
								v:EmitSound("player/taunt_rubberglove_snap.wav")
							end)
							timer.Simple(1, function()
								v:EmitSound("player/taunt_rubberglove_stretch.wav")
							end)
							timer.Simple(6, function()
								if not IsValid(v) or (not v:Alive() and not v:GetNWBool("Taunting")) then return end
								v:SetNWBool("Taunting", false)
								v:SetNWBool("NoWeapon", false)
								print("Thegay.")
								net.Start("DeActivateTauntCam")
								net.Send(v)
							end)
						end
					elseif v:GetPlayerClass() == "soldier" then
						if v:GetInfoNum("tf_robot", 0) == 1 and table.KeyFromValue(allowedtaunts,args[1]) == 1 then
							timer.Simple(1.6, function()
								v:EmitSound("vo/mvm/norm/taunts/soldier_mvm_taunts01.mp3", 95, 100)
							end)
							timer.Simple(3, function()
								if not IsValid(v) or (not v:Alive() and not v:GetNWBool("Taunting")) then return end
								v:SetNWBool("Taunting", false)
								v:SetNWBool("NoWeapon", false)
								print("Thegay.")
								net.Start("DeActivateTauntCam")
								net.Send(v)
							end)
						elseif v:GetInfoNum("tf_robot", 0) == 1 and table.KeyFromValue(allowedtaunts,args[1]) == 2 then
							timer.Simple(3, function()
								v:EmitSound("vo/mvm/norm/soldier_mvm_cheers0"..math.random(5,6)..".mp3", 95, 100)
							end)
							timer.Simple(5, function()
								if not IsValid(v) or (not v:Alive() and not v:GetNWBool("Taunting")) then return end
								v:SetNWBool("Taunting", false)
								v:SetNWBool("NoWeapon", false)
								print("Thegay.")
								net.Start("DeActivateTauntCam")
								net.Send(v)
							end)
						elseif v:GetInfoNum("tf_robot", 0) == 1 and table.KeyFromValue(allowedtaunts,args[1]) == 3 then
							timer.Simple(0.1, function()
								v:EmitSound("vo/mvm/norm/soldier_mvm_directhittaunt02.mp3", 95, 100)
							end)
							timer.Simple(5, function()
								if not IsValid(v) or (not v:Alive() and not v:GetNWBool("Taunting")) then return end
								v:SetNWBool("Taunting", false)
								v:SetNWBool("NoWeapon", false)
								print("Thegay.")
								net.Start("DeActivateTauntCam")
								net.Send(v)
							end)
						end
					
					elseif v:GetPlayerClass() == "demoman" then
						if v:GetWeapons()[1]:GetClass() == "tf_weapon_grenadelauncher" then
							v:DoAnimationEvent(ACT_DOD_CROUCHWALK_AIM_MP40, true)
							v:SelectWeapon(v:GetWeapons()[1]:GetClass())
						else
							v:DoAnimationEvent(ACT_DOD_CROUCHWALK_AIM_MP40, true)
							v:SelectWeapon(v:GetWeapons()[1]:GetClass())				
						end
					elseif v:GetPlayerClass() == "engineer" then
						if v:GetWeapons()[1]:GetClass() == "tf_weapon_sentry_revenge" then
							v:SelectWeapon(v:GetWeapons()[1]:GetClass())
							v:DoAnimationEvent(ACT_DOD_RELOAD_DEPLOYED, true)
							v:PlayScene("scenes/player/engineer/low/taunt07.vcd")
							v:SetNWBool("Taunting", true)
							v:SetNWBool("NoWeapon", true)
							v:GetActiveWeapon().NameOverride = "taunt_guitar_kill"
							local animent2 = ents.Create( 'base_gmodentity' ) -- The entity used for the death animation	
							animent2:SetModel("models/player/items/engineer/guitar.mdl") 
							animent2:SetAngles(v:GetAngles())
							animent2:SetPos(v:GetPos())
							animent2:Spawn()
							animent2:Activate()
							animent2:SetParent(v)
							animent2:AddEffects(EF_BONEMERGE)
							animent2:SetName("GuitarModel"..v:EntIndex())
							timer.Simple(1.5, function()
								v:EmitSound("player/taunt_eng_strum.wav")
							end)
							timer.Simple(4.2, function()
								if not IsValid(v) or (not v:Alive() and not v:GetNWBool("Taunting")) then return end
								v:SetNWBool("Taunting", false)
								v:SetNWBool("NoWeapon", false)
								print("Thegay.")
								net.Start("DeActivateTauntCam")
								net.Send(v)
								animent2:Fire("Kill", "", 0.1)
							end)
							timer.Simple(3.7, function()
								v:EmitSound("player/taunt_eng_smash"..math.random(1,3)..".wav")
								for k,v in pairs(ents.FindInSphere(v:GetPos(), 90)) do 
									if v:IsNPC() and not v:IsFriendly(v) then
										v:TakeDamage(500, v, v)
									elseif v:IsPlayer() and not v:IsFriendly(v) then
										v:TakeDamage(500, v, v)
									end
								end
							end)
						end
					else
					
					v:SelectWeapon(v:GetWeapons()[1]:GetClass())
					v:DoAnimationEvent(ACT_DOD_CROUCH_AIM_C96, true)
					end
				elseif table.KeyFromValue(allowedtaunts,v:GetActiveWeapon():GetSlot() + 1) == 2 then
			
					if v:GetPlayerClass() == "combinesoldier" then
						v:DoAnimationEvent(ACT_SPECIAL_ATTACK1, true)
						v:SetNWBool("Taunting", true)
						v:SetNWBool("NoWeapon", true) 
						local frag = ents.Create("npc_grenade_frag")
						net.Start("ActivateTauntCam")
						net.Send(v)
						frag:SetPos(v:EyePos() + ( v:GetAimVector() * 16 ) )
						frag:SetAngles( v:EyeAngles() )
						frag:SetOwner(v)
						timer.Simple(0.6, function()
							frag:Spawn()
							
							local phys = frag:GetPhysicsObject()
								if ( !IsValid( phys ) ) then frag:Remove() return end
								
								
								
								local velocity = v:GetAimVector()
								velocity = velocity * 1000
								velocity = velocity + ( VectorRand() * 10 ) -- a random element
								phys:ApvForceCenter( velocity )
								frag:Fire("SetTimer",5,0)
								frag:SetOwner(v)
								--timer.Simple(3.5,function() frag:Ignite() end)
						end)
						timer.Simple(1.2, function()
							if not IsValid(v) or (not v:Alive() and not v:GetNWBool("Taunting")) then return end
							v:SetNWBool("Taunting", false)
							v:SetNWBool("NoWeapon", false)
							print("Thegay.")
							net.Start("DeActivateTauntCam")
							net.Send(v)
						end)
							 

					elseif v:GetPlayerClass() == "demoman" then
						v:SelectWeapon(v:GetWeapons()[2]:GetClass())
						v:DoAnimationEvent(ACT_DOD_CROUCH_AIM_C96, true)
					elseif v:GetPlayerClass() == "pyro" then
						timer.Simple(2, function()
							v:EmitSound("misc/flame_engulf.wav", 65, 100)
							for k,v in pairs(ents.FindInSphere(v:GetPos(), 90)) do 
								if v:IsNPC() and not v:IsFriendly(v) then
									v:TakeDamage(500, v, v)
								elseif v:IsPlayer() and not v:IsFriendly(v) then
									v:TakeDamage(500, v, v)
								end
							end
						end)
					else
					v:SelectWeapon(v:GetWeapons()[2]:GetClass())
					v:DoAnimationEvent(ACT_DOD_CROUCHWALK_AIM_MP40, true)
					end
				elseif table.KeyFromValue(allowedtaunts,v:GetActiveWeapon():GetSlot() + 1) == 3 then	
					if v:GetPlayerClass() == "pyro" then
						if v:GetWeapons()[3]:GetClass() == "tf_weapon_neonsign" then
							v:EmitSound("player/sign_bass_solo.wav", 95, 100)
						end
					end
					if v:GetPlayerClass() == "soldier" then
						if v:GetWeapons()[3]:GetClass() == "tf_weapon_pickaxe" then
							timer.Simple(2.5, function()
								for k,v in pairs(ents.FindInSphere(v:GetPos(), 90)) do 
									if v:IsNPC() and not v:IsFriendly(v) then
										local d = DamageInfo()
										d:SetDamage( v:Health() )
										d:Setv( v )
										d:SetDamageType( DMG_BLAST )
										v:TakeDamageInfo( d )
									elseif v:IsPlayer() and not v:IsFriendly(v) then
										local d = DamageInfo()
										d:SetDamage( v:Health() )
										d:Setv( v )
										d:SetDamageType( DMG_BLAST )
										v:TakeDamageInfo( d )
									end
								end
							end)
							v:SelectWeapon(v:GetWeapons()[3]:GetClass())
							v:DoAnimationEvent(ACT_DOD_STAND_AIM_KNIFE, true)
						else
							v:SelectWeapon(v:GetWeapons()[3]:GetClass())
							v:DoAnimationEvent(ACT_DOD_STAND_AIM_30CAL, true)
						end
					end
					if v:GetPlayerClass() == "heavy" then
						v:GetActiveWeapon().NameOverride = "taunt_heavy"
						timer.Simple(1.7, function()
							if v:GetEyeTrace().Entity:IsNPC() and not v:GetEyeTrace().Entity:IsFriendly(v) then
								v:GetEyeTrace().Entity:TakeDamage(500, v, v)
							elseif v:GetEyeTrace().Entity:IsPlayer() and not v:GetEyeTrace().Entity:IsFriendly(v) then
								v:GetEyeTrace().Entity:TakeDamage(500, v, v)
							end
						end)
					end
					if v:GetPlayerClass() == "medic" then
						timer.Simple(0.3, function()
						if v:GetWeapons()[3]:GetItemData().model_player == "models/weapons/c_models/c_uberneedle/c_uberneedle.mdl" then
							v:EmitSound("player/ubertaunt_v0"..math.random(1,7)..".wav", 95, 100)
						elseif v:GetWeapons()[3]:GetItemData().model_player != "models/weapons/c_models/c_ubersaw/c_ubersaw.mdl" then
							v:EmitSound("player/taunt_v0"..math.random(1,7)..".wav", 95, 100)
						end
						end)

						if v:GetWeapons()[3]:GetItemData().model_player == "models/weapons/c_models/c_ubersaw/c_ubersaw.mdl" then
							timer.Simple(2, function()
								v:GetActiveWeapon().NameOverride = "saw_kill"
								for k,v in pairs(ents.FindInSphere(v:GetPos(), 90)) do 
									if v:IsNPC() and not v:IsFriendly(v) then
										local d = DamageInfo()
										d:SetDamage( 50 )
										d:Setv( v )
										d:SetInflictor( v:GetActiveWeapon() )
										d:SetDamageType( DMG_CLUB )
										v:TakeDamage( d )
									elseif v:IsPlayer() and not v:IsFriendly(v) then
										local d = DamageInfo()
										d:SetDamage( 50 )
										d:Setv( v )
										d:SetInflictor( v:GetActiveWeapon() )
										d:SetDamageType( DMG_CLUB )
										v:TakeDamageInfo( d )
										v:ConCommand("tf_stunme")
									end
								end
							end)

							timer.Simple(2.89, function()
								for k,v in pairs(ents.FindInSphere(v:GetPos(), 90)) do 
									if v:IsNPC() and not v:IsFriendly(v) then
										local d = DamageInfo()
										d:SetDamage( 500 )
										d:Setv( v )
										d:SetInflictor( v:GetActiveWeapon() )
										d:SetDamageType( DMG_CLUB )
										v:TakeDamageInfo( d )
									elseif v:IsPlayer() and not v:IsFriendly(v) then
										local d = DamageInfo()
										d:SetDamage( 500 )
										d:Setv( v )
										d:SetInflictor( v:GetActiveWeapon() )
										d:SetDamageType( DMG_CLUB )
										v:TakeDamageInfo( d )
									end
								end
							end)
							v:PlayScene("scenes/player/medic/low/taunt08.vcd")
							v:SelectWeapon(v:GetWeapons()[3]:GetClass())
							v:DoAnimationEvent(ACT_SIGNAL2, true)
						else
							
							v:SelectWeapon(v:GetWeapons()[3]:GetClass())
							v:DoAnimationEvent(ACT_DOD_STAND_AIM_30CAL, true)

						end
					end
					if v:GetPlayerClass() == "demoman" then
						if v:GetWeapons()[3]:GetClass() == "tf_weapon_sword" then
							v:GetActiveWeapon().NameOverride = "taunt_demoman"
							timer.Simple(2.5, function()
								for k,v in pairs(ents.FindInSphere(v:GetPos(), 90)) do 
									if v:IsTFPlayer() and not v:IsFriendly(v) then
										v:AddDeathFlag(DF_DECAP)
										v:TakeDamage(500, v, v)
									end
								end
							end)
							v:SelectWeapon(v:GetWeapons()[3]:GetClass())
							v:DoAnimationEvent(ACT_DOD_STAND_AIM_KNIFE, true)
						else
							v:SelectWeapon(v:GetWeapons()[3]:GetClass())
							v:DoAnimationEvent(ACT_DOD_STAND_AIM_30CAL, true)
						end
					end
				else
				v:SelectWeapon(v:GetWeapons()[3]:GetClass())
				v:DoAnimationEvent(ACT_DOD_STAND_AIM_30CAL, true)
				end
				
			else
				if table.KeyFromValue(allowedtaunts,v:GetActiveWeapon():GetSlot() + 1) == 1 then
					v:SelectWeapon(v:GetWeapons()[1]:GetClass())
					v:DoAnimationEvent(ACT_DOD_CROUCH_AIM_C96, true)
				elseif table.KeyFromValue(allowedtaunts,v:GetActiveWeapon():GetSlot() + 1) == 3 then
					timer.Simple(2, function()
						for k,v in pairs(ents.FindInSphere(v:GetPos(), 90)) do 
							if v:IsNPC() and not v:IsFriendly(v) then
								v:TakeDamage(10, v, v)
								v:GetActiveWeapon().NameOverride = "taunt_spy"
							elseif v:IsPlayer() and not v:IsFriendly(v) then
								v:TakeDamage(10, v, v)
								v:GetActiveWeapon().NameOverride = "taunt_spy"
							end
						end
					end)		
					timer.Simple(2.3, function()
						for k,v in pairs(ents.FindInSphere(v:GetPos(), 90)) do 
							if v:IsNPC() and not v:IsFriendly(v) then
								v:TakeDamage(10, v, v)
								v:GetActiveWeapon().NameOverride = "taunt_spy"
							elseif v:IsPlayer() and not v:IsFriendly(v) then
								v:TakeDamage(10, v, v)
								v:GetActiveWeapon().NameOverride = "taunt_spy"
							end
						end
					end)	
					timer.Simple(4, function()
						for k,v in pairs(ents.FindInSphere(v:GetPos(), 90)) do 
							if v:IsNPC() and not v:IsFriendly(v) then
								v:TakeDamage(500, v, v)
								v:GetActiveWeapon().NameOverride = "taunt_spy"
							elseif v:IsPlayer() and not v:IsFriendly(v) then
								v:TakeDamage(500, v, v)
								v:GetActiveWeapon().NameOverride = "taunt_spy"
							end
						end
					end)			
					v:SelectWeapon(v:GetWeapons()[2]:GetClass())
					v:DoAnimationEvent(ACT_DOD_STAND_AIM_30CAL, true)
				elseif table.KeyFromValue(allowedtaunts,v:GetActiveWeapon():GetSlot() + 1) == 4 then
					v:SelectWeapon(v:GetWeapons()[3]:GetClass())
					v:DoAnimationEvent(ACT_DOD_SPRINT_AIM_SPADE, true)
				end		
			end
			v:Speak("TLK_PLAYER_TAUNT")
			v:SetNWBool("Taunting", true)
			if IsValid(v:GetActiveWeapon()) and table.HasValue(wep, v:GetActiveWeapon():GetClass()) then v:SetNWBool("NoWeapon", true) end
			net.Start("ActivateTauntCam")
			net.Send(v)
			
			if v:GetPlayerClass() != "combinesoldier" then
				print(v:GetNWBool("SpeechTime"))
				timer.Simple(v:GetNWBool("SpeechTime"), function()
					if not IsValid(v) or (not v:Alive() and not v:GetNWBool("Taunting")) then return end
					v:SetNWBool("Taunting", false)
					v:SetNWBool("NoWeapon", false)
					print("Thegay.")
					net.Start("DeActivateTauntCam")
					net.Send(v)
				end)
			end
		end
	end		
	if ply:HasDeathFlag(DF_DECAP) and not ply:IsHL2() then
		ply:RandomSentence("CritDeath")
		ply:EmitSound("player/flow.wav", 95)
		ply:Decap()
		local animent = ents.Create( 'base_gmodentity' ) -- The entity used for the death animation	
		animent:SetModel(ply:GetModel())
		animent:SetSkin(ply:GetSkin())
		animent:SetPos(ply:GetPos())
		animent:SetAngles(ply:GetAngles())
		animent:Spawn()
		animent:Activate()

		local b1 = animent:LookupBone("bip_head")
		local b2 = animent:LookupBone("bip_neck")
		local b3 = animent:LookupBone("prp_helmet")
		local b4 = animent:LookupBone("jaw_bone")
	
		local m1 = animent:GetBoneMatrix(b1)
		local m2 = animent:GetBoneMatrix(b2)
		animent:SetSolid( SOLID_OBB ) -- This stuff isn't really needed, but just for physics
		animent:PhysicsInit( SOLID_OBB )
		animent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		animent:SetSequence( "primary_death_headshot" )
		animent:SetPlaybackRate( 1 )
		animent.AutomaticFrameAdvance = true
		animent:ManipulateBoneScale(b1, Vector(0,0,0))
		animent:ManipulateBoneScale(b2, Vector(0,0,0))	
		if animent:GetModel() == "models/player/engineer.mdl" then
			animent:ManipulateBoneScale(b3, Vector(0,0,0))
		end
		if ply:GetRagdollEntity():IsValid() then
			ply:GetRagdollEntity():Remove()
		end
		function animent:Think() -- This makes the animation work
			if ply:GetRagdollEntity():IsValid() then
				ply:GetRagdollEntity():Remove()
			end
			self:NextThink( CurTime() )
			return true
		end
	
		timer.Simple( animent:SequenceDuration( "primary_death_headshot" ) + 0.2, function() -- After the sequence is done, spawn the ragdoll
			ply:CreateRagdoll()
			local rag = ply:GetRagdollEntity()
			SetEntityStuff( rag, animent )
			rag:Spawn() 
			rag:Activate()
			rag:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			TransferBones( animent, rag )
			animent:Remove()
		end )
	end	
	if ply:HasDeathFlag(DF_DECAP) and ply:IsHL2() then
		ply:EmitSound("TFPlayer.Decapitated")
		umsg.Start("GibNPCHead")
			umsg.Entity(ply)
			umsg.Short(ply.DeathFlags)
		umsg.End()
		local animent = ents.Create( 'base_gmodentity' ) -- The entity used for the death animation	
		animent:SetModel(ply:GetModel())
		animent:SetSkin(ply:GetSkin())
		animent:SetPos(ply:GetPos())
		animent:SetAngles(ply:GetAngles())
		animent:Spawn()
		animent:Activate()

		local b1 = animent:LookupBone("ValveBiped.Bip01_Head1")
	
		local m1 = animent:GetBoneMatrix(b1)
		animent:SetSolid( SOLID_OBB ) -- This stuff isn't really needed, but just for physics
		animent:PhysicsInit( SOLID_OBB )
		animent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		animent:SetSequence( "death_01" )
		animent:SetPlaybackRate( 1 )
		animent.AutomaticFrameAdvance = true
		animent:ManipulateBoneScale(b1, Vector(0,0,0))
		if animent:GetModel() == "models/player/engineer.mdl" then
			animent:ManipulateBoneScale(b3, Vector(0,0,0))
		end
		if ply:GetRagdollEntity():IsValid() then
			ply:GetRagdollEntity():Remove()
		end
		function animent:Think() -- This makes the animation work
			if ply:GetRagdollEntity():IsValid() then
				ply:GetRagdollEntity():Remove()
			end
			self:NextThink( CurTime() )
			return true
		end
	
		timer.Simple( animent:SequenceDuration( "death_01" ) + 0.2, function() -- After the sequence is done, spawn the ragdoll
			ply:CreateRagdoll()
			local rag = ply:GetRagdollEntity()
			SetEntityStuff( rag, animent )
			rag:Spawn() 
			rag:Activate()
			rag:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			TransferBones( animent, rag )
			animent:Remove()
		end )
	end	
	if ply:HasDeathFlag(DF_BACKSTAB) and not ply:IsHL2() then
		ply:RandomSentence("CritDeath")
		local animent = ents.Create( 'base_gmodentity' ) -- The entity used for the death animation	
		animent:SetModel(ply:GetModel())
		animent:SetSkin(ply:GetSkin())
		animent:SetPos(ply:GetPos())
		animent:SetAngles(ply:GetAngles())
		animent:Spawn()
		animent:Activate()
	
		animent:SetSolid( SOLID_OBB ) -- This stuff isn't really needed, but just for physics
		animent:PhysicsInit( SOLID_OBB )
		animent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		animent:SetSequence( "primary_death_backstab" )
		animent:SetPlaybackRate( 1 )
		animent.AutomaticFrameAdvance = true
		if ply:GetRagdollEntity():IsValid() then
			ply:GetRagdollEntity():Remove()
		end
		function animent:Think() -- This makes the animation work
			if ply:GetRagdollEntity():IsValid() then
				ply:GetRagdollEntity():Remove()
			end
			self:NextThink( CurTime() )
			return true
		end
	
		timer.Simple( animent:SequenceDuration( "primary_death_backstab" ) + 0.2, function() -- After the sequence is done, spawn the ragdoll
			ply:CreateRagdoll()
			local rag = ply:GetRagdollEntity()
			SetEntityStuff( rag, animent )
			rag:Spawn() 
			rag:Activate()
			rag:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			TransferBones( animent, rag )
			animent:Remove()
		end )
		
	end
	if ply:HasDeathFlag(DF_GOLDEN) then
	
		local engineer_golden_lines = {
			"scenes/Player/Engineer/low/3605.vcd",
			"scenes/Player/Engineer/low/3690.vcd",
			"scenes/Player/Engineer/low/3691.vcd",
		}
	
		if dmginfo:GetAttacker():GetPlayerClass() == "engineer" then
			dmginfo:GetAttacker():PlayScene(engineer_golden_lines[math.random( #engineer_golden_lines )])
		end
		local animent = ents.Create( 'base_gmodentity' ) -- The entity used for the death animation	
		animent:SetModel(ply:GetModel())
		animent:SetSkin(ply:GetSkin())
		animent:SetPos(ply:GetPos())
		animent:SetAngles(ply:GetAngles())
		animent:Spawn()
		animent:Activate()
	
		animent:SetSolid( SOLID_OBB ) -- This stuff isn't really needed, but just for physics
		animent:PhysicsInit( SOLID_OBB )
		animent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		if ply:IsHL2() then
			animent:SetSequence("death_01")
		else
			animent:SetSequence( "primary_death_backstab" )
		end
		animent:SetPlaybackRate( 1 )
		animent:SetMaterial("models/player/shared/gold_player")
		timer.Simple(0.15, function()
			animent:SetPlaybackRate( 0 )
		end)
		animent.AutomaticFrameAdvance = true
		if ply:GetRagdollEntity():IsValid() then
			ply:GetRagdollEntity():Remove()
		end
		function animent:Think() -- This makes the animation work
			if ply:GetRagdollEntity():IsValid() then
				ply:GetRagdollEntity():Remove()
			end
			self:NextThink( CurTime() )
			return true
		end
	
		timer.Simple( 20, function() -- After the sequence is done, spawn the ragdoll
			animent:Remove()
		end )
		
	end
	if ply:HasDeathFlag(DF_FROZEN) then
		local animent = ents.Create( 'base_gmodentity' ) -- The entity used for the death animation	
		animent:SetModel(ply:GetModel())
		animent:SetSkin(ply:GetSkin())
		animent:SetPos(ply:GetPos())
		animent:SetAngles(ply:GetAngles())
		animent:Spawn()
		animent:Activate()
	
		animent:SetSolid( SOLID_OBB ) -- This stuff isn't really needed, but just for physics
		animent:PhysicsInit( SOLID_OBB )
		animent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		ply:EmitSound("weapons/icicle_freeze_victim_01.wav", 95, 100)
		if ply:IsHL2() then
			animent:SetSequence( "death_02" )
		else
			animent:SetSequence( "primary_death_backstab" )
		end
		animent:SetPlaybackRate( 1 )
		animent:SetMaterial("models/player/shared/ice_player")
		timer.Simple(0.2, function()
			animent:SetPlaybackRate( 0 )
		end)
		animent.AutomaticFrameAdvance = true
		if ply:GetRagdollEntity():IsValid() then
			ply:GetRagdollEntity():Remove()
		end
		function animent:Think() -- This makes the animation work
			if ply:GetRagdollEntity():IsValid() then
				ply:GetRagdollEntity():Remove()
			end
			self:NextThink( CurTime() )
			return true
		end
	
		timer.Simple( 20, function() -- After the sequence is done, spawn the ragdoll
			animent:Remove()
		end )
		
	end
	
	if IsValid(drop) then
		drop:DropAsAmmo()
	end
	
	local killer = attacker
	if inflictor.KillCreditAsInflictor then
		killer = inflictor
	end
	
	if ply~=killer and not killer:IsWorld() and (killer:IsTFPlayer()) then
		umsg.Start("SetPlayerKiller", ply)
			umsg.Entity(killer)
			umsg.String(GAMEMODE:EntityDeathnoticeName(killer))
			umsg.Short(killer:EntityTeam())
			umsg.Char(ply.KillerDominationInfo)
			if killer ~= attacker then
				umsg.Entity(attacker)
			else
				umsg.Entity(NULL)
			end
		umsg.End()
	end
	
	--print("DoPlayerDeath", dmginfo:GetInflictor(), dmginfo:GetAttacker(), dmginfo:GetDamage(), dmginfo:GetDamageType())
	local shouldgib = false
	

	if dmginfo:IsFallDamage() then -- Fall damage
		ply.FallDeath = true
		ply:EmitSound("player/pl_fleshbreak.wav", 70, math.random(92,96))
		umsg.Start("Notice_EntityFell")
			umsg.String(GAMEMODE:EntityDeathnoticeName(ply))
			umsg.Short(GAMEMODE:EntityTeam(ply))
			umsg.Short(GAMEMODE:EntityID(ply))
		umsg.End()
	elseif dmginfo:IsDamageType(DMG_ALWAYSGIB) or dmginfo:IsDamageType(DMG_BLAST) or dmginfo:IsExplosionDamage() or inflictor.Explosive then -- Explosion damage
	
		if ply:GetMaterial() == "models/shadertest/predator" then return end
		ply:RandomSentence("ExplosionDeath")
		local p = player_gib_probability:GetFloat()
		p = 1
		
		if not ply:IsHL2() then
			if ply:GetInfoNum("tf_robot", 0) == 0 then
				ply:Explode()
				ply:EmitSound("physics/flesh/flesh_squishy_impact_hard2.wav", 80, 100)
				shouldgib = true
			elseif ply:GetInfoNum("tf_robot", 0) == 1 then
				ply:PrecacheGibs()
				ply:GibBreakClient( Vector(math.random(1,4), math.random(1,4), math.random(1,4)) )
				ply:GetRagdollEntity():Remove()
			elseif not ply:IsHL2() and ply:Team() == TEAM_BLU and string.find(game.GetMap(), "mvm_") then
				ply:PrecacheGibs()
				ply:GibBreakClient( Vector(math.random(1,4), math.random(1,4), math.random(1,4)) )
				ply:GetRagdollEntity():Remove()
			end
		else
			ply:Explode()
			ply:GetRagdollEntity():Remove()
		end
	elseif inflictor.Critical and inflictor:Critical() then -- Critical damage
		if not inflictor.IsSilentKiller then
			if ply:GetMaterial() == "models/shadertest/predator" then return end
			if not ply:IsHL2() and ply:Team() == TEAM_BLU and string.find(game.GetMap(), "mvm_") then return end
			ply:RandomSentence("CritDeath")
		end
	elseif dmginfo:IsDamageType(DMG_CLUB) or dmginfo:IsDamageType(DMG_SLASH) or inflictor.HoldType=="MELEE" then -- Melee damage
		if not inflictor.IsSilentKiller then	
			if ply:GetMaterial() == "models/shadertest/predator" then return end
			if not ply:IsHL2() and ply:Team() == TEAM_BLU and string.find(game.GetMap(), "mvm_") then return end
			ply:RandomSentence("MeleeDeath")
		end
	else -- Bullet/fire damage
		if not inflictor.IsSilentKiller then
			if ply:GetMaterial() == "models/shadertest/predator" then return end
			if not ply:IsHL2() and ply:Team() == TEAM_BLU and string.find(game.GetMap(), "mvm_") then return end
			ply:RandomSentence("Death")
		end
	end


	if not shouldgib then
		ply:CreateRagdoll()
	end
	
	ply.LastDamageInfo = CopyDamageInfo(dmginfo)
end

function GM:OnNPCKilled(ent, attacker, inflictor)
	if inflictor.IsSilentKiller then
		umsg.Start("SilenceNPC")
			umsg.Entity(ent)
		umsg.End()
	end
	
	if inflictor and inflictor.OnPlayerKilled then
		inflictor:OnPlayerKilled(ent)
	end
	
	gamemode.Call("DoTFPlayerDeath", ent, attacker, ent.LastDamageInfo)
	
	-- for Gran <3
	-- NPCs should spawn silly gibs if killed by damage of type DMG_ALWAYSGIB+DMG_REMOVENORAGDOLL
	if ent.LastDamageInfo and ent.LastDamageInfo:IsDamageType(DMG_ALWAYSGIB) and ent.LastDamageInfo:IsDamageType(DMG_BLAST) and ent.LastDamageInfo:IsDamageType(DMG_REMOVENORAGDOLL) then
		umsg.Start("GibNPC")
			umsg.Entity(ent)
			umsg.Short(ent.DeathFlags)
		umsg.End()
	end
	
	gamemode.Call("PostTFPlayerDeath", ent, attacker, inflictor)
end

function GM:PlayerDeath(ent, inflictor, attacker)
	-- Don't spawn for at least 2 seconds
	ent.NextSpawnTime = CurTime() + 7
	ent.DeathTime = CurTime()
	
	
	if GetConVar("tf_enable_revive_markers"):GetBool() then
		animent = ents.Create( 'reviver' ) -- The entity used for the death animation
		animent:SetPos(ent:GetPos())
		animent:SetAngles(ent:GetAngles())
		animent:Spawn()
		animent:Activate()
		animent:SetOwner(ent)
		
		if ent:GetPlayerClass() == "soldier" then
			animent:SetBodygroup(1, 2)
		elseif ent:GetPlayerClass() == "pyro" then
			animent:SetBodygroup(1, 6)
		elseif ent:GetPlayerClass() == "demoman" then
			animent:SetBodygroup(1, 3)
		elseif ent:GetPlayerClass() == "heavy" then
			animent:SetBodygroup(1, 5)
		elseif ent:GetPlayerClass() == "engineer" then
			animent:SetBodygroup(1, 8)
		elseif ent:GetPlayerClass() == "medic" then
			animent:SetBodygroup(1, 4)
		elseif ent:GetPlayerClass() == "sniper" then
			animent:SetBodygroup(1, 1)
		elseif ent:GetPlayerClass() == "spy" then
			animent:SetBodygroup(1, 7)
		end
			
	end
	
	timer.Simple(7, function()
		if IsValid(animent) then
			animent:Fire("Kill", "", 0.1)
		end
		if !ent:Alive() then
			ent:Spawn()
		end
	end)
	
	
	gamemode.Call("PostTFPlayerDeath", ent, attacker, inflictor)
end

-- No flatline sound
function GM:PlayerDeathSound()
	return true
end
