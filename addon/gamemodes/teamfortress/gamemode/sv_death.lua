
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
			attacker:Speak("TLK_KILLED_OBJECT")
		else
			self:AddKill(attacker)
			attacker.victimclass = ent.playerclass or ""
			attacker:Speak("TLK_KILLED_PLAYER")
		end
	end
	attacker.domination = ""
end

function GM:PostTFPlayerDeath(ent, attacker, inflictor)
	if GAMEMODE:EntityTeam(attacker) == TEAM_HIDDEN then
		return
	end
	
	if IsValid(inflictor) and attacker == inflictor and inflictor:IsTFPlayer() then
		inflictor = inflictor:GetActiveWeapon()
		if not IsValid(inflictor) then inflictor = attacker end
	end
	
	local cooperator = self:GetDisplayedAssistant(ent, attacker) or NULL
	--print("Displayed assistant")
	--print(cooperator)
	
	local killer = attacker
	print(attacker, "is a killer!")
	if attacker:IsWeapon() then
		attacker = attacker:GetOwner()
	end
	print(attacker, "is a killer!")
	
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
		if attacker:IsWeapon() then
			attacker = ent:GetOwner()
		end
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

function GM:DoPlayerDeath(ply, attacker, dmginfo)
	local inflictor = dmginfo:GetInflictor()
	gamemode.Call("DoTFPlayerDeath", ply, attacker, dmginfo)
	
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
	elseif dmginfo:IsDamageType(DMG_ALWAYSGIB) or dmginfo:IsExplosionDamage() or inflictor.Explosive then -- Explosion damage
		ply:RandomSentence("ExplosionDeath")
		
		local p = player_gib_probability:GetFloat()
		if dmginfo:IsDamageType(DMG_NEVERGIB) then
			p = 0
		elseif dmginfo:IsDamageType(DMG_ALWAYSGIB) then
			p = 1
		end
		
		if not ply:IsHL2() then
			if ply:GetInfoNum("tf_robot", 0) == 0 then
				if math.random()<p then -- gib that player
					ply:Explode()
					shouldgib = true
				end
			end
		end
	elseif inflictor.Critical and inflictor:Critical() then -- Critical damage
		if not inflictor.IsSilentKiller then
			ply:RandomSentence("CritDeath")
		end
	elseif dmginfo:IsDamageType(DMG_CLUB) or dmginfo:IsDamageType(DMG_SLASH) or inflictor.HoldType=="MELEE" then -- Melee damage
		if not inflictor.IsSilentKiller then
			ply:RandomSentence("MeleeDeath")
		end
	else -- Bullet/fire damage
		if not inflictor.IsSilentKiller then
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
	
	gamemode.Call("DoTFPlayerDeath", ent, attacker, ent.LastDamageInfo)
	
	-- for Gran <3
	-- NPCs should spawn silly gibs if killed by damage of type DMG_ALWAYSGIB+DMG_REMOVENORAGDOLL
	if ent.LastDamageInfo and ent.LastDamageInfo:IsDamageType(DMG_ALWAYSGIB) and ent.LastDamageInfo:IsDamageType(DMG_REMOVENORAGDOLL) then
		umsg.Start("GibNPC")
			umsg.Entity(ent)
			umsg.Short(ent.DeathFlags or 0)
		umsg.End()
	end
	
	gamemode.Call("PostTFPlayerDeath", ent, attacker, inflictor)
end

function GM:PlayerDeath(ent, inflictor, attacker)
	-- Don't spawn for at least 2 seconds
	ent.NextSpawnTime = CurTime() + 2
	ent.DeathTime = CurTime()
	
	gamemode.Call("PostTFPlayerDeath", ent, attacker, inflictor)
end

-- No flatline sound
function GM:PlayerDeathSound()
	return true
end
