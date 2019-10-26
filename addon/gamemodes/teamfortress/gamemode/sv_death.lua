
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
	
	
	if dmginfo:IsDamageType(DMG_DISSOLVE) then
		if not inflictor.IsSilentKiller then
			ent:EmitSound("player/dissolve.wav", 85)
		end
	end
	ent:StopSound("Weapon_Minifun.Fire")
	ent:StopSound("Weapon_Minigun.Fire")
	ent:StopSound("Weapon_Tomislav.ShootLoop")
	ent:StopSound("Weapon_Minifun.FireCrit")
	ent:StopSound("Weapon_Minigun.FireCrit")
	ent:StopSound("Weapon_Tomislav.FireCrit")
	if ent:IsNPC() and ent:HasDeathFlag(DF_DECAP) then
		umsg.Start("GibNPCHead")
			umsg.Entity(ent)
			umsg.Short(ent.DeathFlags)
		umsg.End()
	end
	if ent:IsNPC() and dmginfo:IsDamageType(DMG_BLAST) then
		umsg.Start("GibNPC")
			umsg.Entity(ent)
			umsg.Short(ent.DeathFlags)
		umsg.End()
		ent:Fire("Kill", "", 0.1)
	end

	if ent:IsPlayer() and ent:HasDeathFlag(DF_DECAP) then
		umsg.Start("GibPlayerHead")
			umsg.Entity(ent)
			umsg.Short(ent.DeathFlags)
		umsg.End()
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
	
	if IsValid(inflictor) and attacker == inflictor and inflictor:IsTFPlayer() then
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
	if ply:HasDeathFlag(DF_HEADSHOT) and not ply:IsHL2() then
		ply:RandomSentence("CritDeath")
		local animent = ents.Create( 'base_gmodentity' ) -- The entity used for the death animation	
		animent:SetModel(ply:GetModel())
		animent:SetSkin(ply:GetSkin())
		animent:SetPos(ply:GetPos())
		animent:SetAngles(ply:GetAngles())
		animent:Spawn()
		animent:Activate()
	
		local b1 = animent:LookupBone("bip_head")
		local b2 = animent:LookupBone("bip_neck")
		local b3 = animent:LookupBone("jaw_bone")
		animent:SetSolid( SOLID_OBB ) -- This stuff isn't really needed, but just for physics
		animent:PhysicsInit( SOLID_OBB )
		animent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		animent:SetSequence( "primary_death_headshot" )
		animent:SetPlaybackRate( 1 )
		animent.AutomaticFrameAdvance = true

		if ply:GetInfoNum("tf_robot", 0) == 1 then
		
			ply:EmitSound("MVM_Weapon_BaseballBat.HitFlesh")
			if ply:GetPlayerClass() == "heavy" then
				local animent2 = ents.Create( 'base_gmodentity' ) -- The entity used for the death animation	
				animent2:SetModel(ply:GetActiveWeapon():GetModel()) 
				animent2:SetAngles(ply:GetAngles())
				animent2:SetPos(animent:GetPos())
				animent2:Spawn()
				animent2:Activate()
				animent2:SetParent(animent)
				animent2:AddEffects(EF_BONEMERGE)
				animent:ManipulateBoneScale(b1, Vector(0,0,0))
				animent:ManipulateBoneScale(b2, Vector(0,0,0))
				animent:ManipulateBoneScale(b3, Vector(0,0,0))
				local rag2 = ents.Create( 'prop_physics' )
				rag2:SetPos(animent:GetPos())
				rag2:SetAngles(animent:GetAngles())
				rag2:SetModel("models/bots/gibs/heavybot_gib_head.mdl")
				rag2:Spawn()
				rag2:Activate()
				rag2:SetCollisionGroup( COLLISION_GROUP_DEBRIS ) 
			end
			
		end
		if ply:IsBot() and GetConVar("tf_botbecomerobots"):GetInt() == 1 and ply:Team() == TEAM_BLU then
		
			ply:EmitSound("MVM_Weapon_BaseballBat.HitFlesh")
			if ply:GetPlayerClass() == "heavy" then
				local animent2 = ents.Create( 'base_gmodentity' ) -- The entity used for the death animation	
				animent2:SetModel(ply:GetActiveWeapon():GetModel()) 
				animent2:SetAngles(ply:GetAngles())
				animent2:SetPos(animent:GetPos())
				animent2:Spawn()
				animent2:Activate()
				animent2:SetParent(animent)
				animent2:AddEffects(EF_BONEMERGE)
				animent:ManipulateBoneScale(b1, Vector(0,0,0))
				animent:ManipulateBoneScale(b2, Vector(0,0,0))
				animent:ManipulateBoneScale(b3, Vector(0,0,0))
				local rag2 = ents.Create( 'prop_physics' )
				rag2:SetPos(animent:GetPos())
				rag2:SetAngles(animent:GetAngles())
				rag2:SetModel("models/bots/gibs/heavybot_gib_head.mdl")
				rag2:Spawn()
				rag2:Activate()
				rag2:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			end
			
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
			if IsValid(rag2) then
				rag2:Remove()
			end
			animent:Remove()
		end )
	end		
	if ply:HasDeathFlag(DF_DECAP) and not ply:IsHL2() then
		ply:RandomSentence("CritDeath")
		inflictor:EmitSound("TFPlayer.Decapitated")
		local animent = ents.Create( 'base_gmodentity' ) -- The entity used for the death animation	
		animent:SetModel(ply:GetModel())
		animent:SetSkin(ply:GetSkin())
		animent:SetPos(ply:GetPos())
		animent:SetAngles(ply:GetAngles())
		animent:Spawn()
		animent:Activate()
		if ent:IsPlayer() and ent:HasDeathFlag(DF_DECAP) then
			umsg.Start("GibPlayerHead")
				umsg.Entity(ent)
				umsg.Short(ent.DeathFlags)
			umsg.End()
		end

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
		if ply:GetInfoNum("tf_robot", 0) == 1 and not ply:IsBot() then
			if ply:GetPlayerClass() == "heavy" then
				local animent2 = ents.Create( 'base_gmodentity' ) -- The entity used for the death animation	
				animent2:SetModel(ply:GetActiveWeapon():GetModel()) 
				animent2:SetAngles(ply:GetAngles())
				animent2:SetPos(animent:GetPos())
				animent2:Spawn()
				animent2:Activate()
				animent2:SetParent(animent)
				animent2:AddEffects(EF_BONEMERGE)
				local rag2 = ents.Create( 'prop_physics' )
				rag2:SetPos(animent:GetPos())
				rag2:SetAngles(animent:GetAngles())
				rag2:SetModel("models/bots/gibs/heavybot_gib_head.mdl")
				rag2:Spawn()
				rag2:Activate()
				rag2:SetCollisionGroup( COLLISION_GROUP_DEBRIS ) 
			end
			ply:EmitSound("MVM_Weapon_BaseballBat.HitFlesh")
			local rag2 = ents.Create( 'prop_physics' )
			rag2:SetPos(animent:GetPos())
			rag2:SetAngles(animent:GetAngles())
			if ply:GetPlayerClass() != "demoman" and ply:GetPlayerClass() != "engineer" then
				rag2:SetModel("models/bots/gibs/"..ply:GetPlayerClass().."bot_gib_head.mdl")
			elseif ply:GetPlayerClass() == "demoman" then	
				rag2:SetModel("models/bots/gibs/demobot_gib_head.mdl")
			elseif ply:GetPlayerClass() == "engineer" then
				rag2:SetModel("models/player/gibs/engineergib006.mdl")
			end
			rag2:SetSkin(ply:GetSkin())
			rag2:Spawn()
			rag2:Activate()
			rag2:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		elseif not ply:IsBot() then
			local rag2 = ents.Create( 'prop_physics' )
			rag2:SetPos(animent:GetPos())
			rag2:SetAngles(animent:GetAngles())
			if ply:GetPlayerClass() == "scout" then
				rag2:SetModel("models/player/gibs/scoutgib007.mdl")
			elseif ply:GetPlayerClass() == "soldier" then
				rag2:SetModel("models/player/gibs/soldiergib007.mdl")
			elseif ply:GetPlayerClass() == "pyro" then
				rag2:SetModel("models/player/gibs/pyrogib008.mdl")
			elseif ply:GetPlayerClass() == "demoman" then
				rag2:SetModel("models/player/gibs/demogib006.mdl")
			elseif ply:GetPlayerClass() == "heavy" then
				rag2:SetModel("models/player/gibs/heavygib007.mdl")
			elseif ply:GetPlayerClass() == "engineer" then
				rag2:SetModel("models/player/gibs/engineergib006.mdl")
			elseif ply:GetPlayerClass() == "medic" then
				rag2:SetModel("models/player/gibs/medicgib007.mdl")
			elseif ply:GetPlayerClass() == "sniper" then
				rag2:SetModel("models/player/gibs/snipergib005.mdl")
			elseif ply:GetPlayerClass() == "spy" then
				rag2:SetModel("models/player/gibs/spygib007.mdl")
			end
			rag2:SetSkin(ply:GetSkin())
			rag2:Spawn()
			rag2:Activate()
			rag2:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			animent:EmitSound("player/flow.wav", 95, math.random(98, 100))
		end
		if ply:IsBot() and GetConVar("tf_botbecomerobots"):GetInt() == 1 and ply:Team() == TEAM_BLU then
			if ply:GetPlayerClass() == "heavy" then
				local animent2 = ents.Create( 'base_gmodentity' ) -- The entity used for the death animation	
				animent2:SetModel(ply:GetActiveWeapon():GetModel()) 
				animent2:SetAngles(ply:GetAngles())
				animent2:SetPos(animent:GetPos())
				animent2:Spawn()
				animent2:Activate()
				animent2:SetParent(animent)
				animent2:AddEffects(EF_BONEMERGE)
				local rag2 = ents.Create( 'prop_physics' )
				rag2:SetPos(animent:GetPos())
				rag2:SetAngles(animent:GetAngles())
				rag2:SetModel("models/bots/gibs/heavybot_gib_head.mdl")
				rag2:Spawn()
				rag2:Activate()
				rag2:SetCollisionGroup( COLLISION_GROUP_DEBRIS ) 
			end
			ply:EmitSound("MVM_Weapon_BaseballBat.HitFlesh")
			local rag2 = ents.Create( 'prop_physics' )
			rag2:SetPos(animent:GetPos())
			rag2:SetAngles(animent:GetAngles())
			if ply:GetPlayerClass() != "demoman" and ply:GetPlayerClass() != "engineer" then
				rag2:SetModel("models/bots/gibs/"..ply:GetPlayerClass().."bot_gib_head.mdl")
			elseif ply:GetPlayerClass() == "demoman" then	
				rag2:SetModel("models/bots/gibs/demobot_gib_head.mdl")
			elseif ply:GetPlayerClass() == "engineer" then
				rag2:SetModel("models/player/gibs/engineergib006.mdl")
			end
			rag2:SetSkin(ply:GetSkin())
			rag2:Spawn()
			rag2:Activate()
			rag2:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

		elseif ply:IsBot() and GetConVar("tf_botbecomerobots"):GetInt() == 0 then
			animent:EmitSound("player/flow.wav", 95, math.random(98, 100))
			local rag2 = ents.Create( 'prop_physics' )
			rag2:SetPos(animent:GetPos())
			rag2:SetAngles(animent:GetAngles())
			if ply:GetPlayerClass() == "scout" then
				rag2:SetModel("models/player/gibs/scoutgib007.mdl")
			elseif ply:GetPlayerClass() == "soldier" then
				rag2:SetModel("models/player/gibs/soldiergib007.mdl")
			elseif ply:GetPlayerClass() == "pyro" then
				rag2:SetModel("models/player/gibs/pyrogib008.mdl")
			elseif ply:GetPlayerClass() == "demoman" then
				rag2:SetModel("models/player/gibs/demogib006.mdl")
			elseif ply:GetPlayerClass() == "heavy" then
				rag2:SetModel("models/player/gibs/heavygib007.mdl")
			elseif ply:GetPlayerClass() == "engineer" then
				rag2:SetModel("models/player/gibs/engineergib006.mdl")
			elseif ply:GetPlayerClass() == "medic" then
				rag2:SetModel("models/player/gibs/medicgib007.mdl")
			elseif ply:GetPlayerClass() == "sniper" then
				rag2:SetModel("models/player/gibs/snipergib005.mdl")
			elseif ply:GetPlayerClass() == "spy" then
				rag2:SetModel("models/player/gibs/spygib007.mdl")
			end
			rag2:SetSkin(ply:GetSkin())
			rag2:Spawn()
			rag2:Activate()
			rag2:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			animent:EmitSound("player/flow.wav", 95, math.random(98, 100))
		end
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
	elseif dmginfo:IsDamageType(DMG_ALWAYSGIB) or dmginfo:IsDamageType(DMG_BLAST) or dmginfo:IsExplosionDamage() or inflictor.Explosive then -- Explosion damage
	
		if ply:GetMaterial() == "models/shadertest/predator" then return end
		ply:RandomSentence("ExplosionDeath")
		local p = player_gib_probability:GetFloat()
		p = 1
		
		if not ply:IsHL2() then
			if ply:GetInfoNum("tf_robot", 0) == 0 then
				if not ply:IsHL2() and ply:Team() == TEAM_BLU and string.find(game.GetMap(), "mvm_") then
					return
				end
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


	if killer:IsPlayer() and not killer:IsHL2() then
		killer:EmitSound("ui/killsound.wav", 50, 100)
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
	ent.NextSpawnTime = CurTime() + 2
	ent.DeathTime = CurTime()
	
	gamemode.Call("PostTFPlayerDeath", ent, attacker, inflictor)
end

-- No flatline sound
function GM:PlayerDeathSound()
	return true
end
