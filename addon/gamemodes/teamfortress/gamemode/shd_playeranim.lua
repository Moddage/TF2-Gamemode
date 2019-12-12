function GM:HandlePlayerJumping(pl)
	if pl:IsHL2() then
		return self.BaseClass:HandlePlayerJumping(pl)
	end
	
	if not pl.anim_Jumping and not pl:OnGround() and pl:WaterLevel() <= 0 then
		if not pl.anim_GroundTime then
			pl.anim_GroundTime = CurTime()
		else --[[if CurTime() - pl.anim_GroundTime > 0.2 then]]
			pl.anim_Jumping = true
			pl.anim_FirstJumpFrame = false
			pl.anim_JumpStartTime = 0
		end
	end
	
	if pl.anim_Jumping then
		local firstjumpframe = pl.anim_FirstJumpFrame
		
		if pl.anim_FirstJumpFrame then
			pl.anim_FirstJumpFrame = false
			pl:AnimRestartMainSequence()
		end
		
		if pl:WaterLevel() >= 2 or --[[(CurTime() - pl.anim_JumpStartTime > 0.2 and]] pl:OnGround() --[[)]] then
			pl.anim_Jumping = false
			pl.anim_GroundTime = nil
			pl:AnimRestartMainSequence()
			
			if pl:OnGround() then
				if pl:GetPlayerClass() == "combinesoldier" or pl:GetPlayerClass() == "rebel" or pl:GetPlayerClass() == "metrocop" then
					pl:AnimRestartGesture(GESTURE_SLOT_JUMP, ACT_LAND, true)
				else
					pl:AnimRestartGesture(GESTURE_SLOT_JUMP, ACT_MP_JUMP_LAND, true)
				end
			end
		end
		
		
		if pl.anim_Jumping then
			if pl:GetPlayerClass() == "combinesoldier" or pl:GetPlayerClass() == "rebel" or pl:GetPlayerClass() == "metrocop" then
				if pl.anim_JumpStartTime == 0 then
					if pl.anim_Airwalk then
						pl.anim_CalcIdeal = ACT_GLIDE
					else
						return false
					end
				elseif not firstjumpframe and CurTime() - pl.anim_JumpStartTime > pl:SequenceDuration() then
					pl.anim_CalcIdeal = ACT_GLIDE
				else
					pl.anim_CalcIdeal = ACT_JUMP
				end
			else
				if pl.anim_JumpStartTime == 0 then
					if pl.anim_Airwalk then
						pl.anim_CalcIdeal = ACT_MP_AIRWALK
					else
						return false
					end
				elseif not firstjumpframe and CurTime() - pl.anim_JumpStartTime > pl:SequenceDuration() then
					pl.anim_CalcIdeal = ACT_MP_JUMP_FLOAT
				else
					pl.anim_CalcIdeal = ACT_MP_JUMP_START
				end
			end
			return true
		end
	end
	
	pl.anim_Airwalk = false
	return false
end

function GM:HandlePlayerDucking(pl, vel)
	if pl:IsHL2() then
		return self.BaseClass:HandlePlayerDucking(pl, vel)
	end
	
	if pl:Crouching() then
		local len2d = vel:Length2D()
		
		-- fucking shit garry, you broke GetCrouchedWalkSpeed
		local cl = pl:GetPlayerClassTable()
		
		
		if len2d > 0.5 and (not cl or not cl.NoDeployedCrouchwalk) then
			pl.anim_CalcIdeal = (pl.anim_Deployed and ACT_MP_CROUCH_DEPLOYED) or ACT_MP_CROUCHWALK
		else
			pl.anim_CalcIdeal = (pl.anim_Deployed and ACT_MP_CROUCH_DEPLOYED_IDLE) or ACT_MP_CROUCH_IDLE
		end
		
		return true
	end
	
	return false
end

function GM:HandlePlayerSwimming(pl)
	if pl:IsHL2() then
		return self.BaseClass:HandlePlayerSwimming(pl)
	end
	
	if pl:WaterLevel() >= 2 then
		if pl.anim_FirstSwimFrame then
			pl:AnimRestartMainSequence()
			pl.anim_FirstSwimFrame = false
		end
		
		pl.anim_InSwim = true
		pl.anim_CalcIdeal = (pl.anim_Deployed and ACT_MP_SWIM_DEPLOYED) or ACT_MP_SWIM
		
		return true
	else
		pl.anim_InSwim = false
		if not pl.anim_FirstSwimFrame then
			pl.anim_FirstSwimFrame = true
		end
	end
	
	return false
end

function GM:HandlePlayerDriving(pl)
	if pl:IsHL2() then
		return self.BaseClass:HandlePlayerDriving(pl)
	end

	return false
end

function GM:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	if pl:IsHL2() then
		return self.BaseClass:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	end
	
	local c = pl:GetPlayerClassTable()
	local maxspeed = 100
	
	maxspeed = pl:GetRealClassSpeed()
	
	if c and c.Speed then 
	if (pl:OnGround() and pl:Crouching()) then
		maxspeed = c.Speed
	end
	
		maxspeed = maxspeed * 0.3
	elseif pl:WaterLevel() > 1 then
		maxspeed = maxspeed * 0.8
	end
	
	if c and c.ModifyMaxAnimSpeed then
		maxspeed = c.ModifyMaxAnimSpeed(pl, maxspeed)
	end
	if pl:IsPlayer() and pl:GetInfoNum("tf_giant_robot", 0) != 1 then
		maxspeed = maxspeed * 3
		
		local vel = 1 * velocity
		vel:Rotate(Angle(0,-pl:EyeAngles().y,0))
		vel:Rotate(Angle(-vel:Angle().p,0,0))
		
		pl:SetPoseParameter("move_x", vel.x / maxspeed)
		pl:SetPoseParameter("move_y", -vel.y / maxspeed)
	
	elseif pl:IsPlayer() and pl:GetPlayerClass() == "tank" then
		maxspeed = maxspeed * 3
		
		local vel = 1 * velocity
		vel:Rotate(Angle(0,-pl:EyeAngles().y,0))
		vel:Rotate(Angle(-vel:Angle().p,0,0))
		
		pl:SetPoseParameter("move_x", vel.x / maxspeed)
		pl:SetPoseParameter("move_y", vel.y / maxspeed)
	
	elseif pl:IsPlayer() and pl:GetPlayerClass() == "metrocop" then
		maxspeed = maxspeed * 3
		
		local vel = 1 * velocity
		vel:Rotate(Angle(0,-pl:EyeAngles().y,0))
		vel:Rotate(Angle(-vel:Angle().p,0,0))
		
		pl:SetPoseParameter("move_x", vel.x / maxspeed)
		pl:SetPoseParameter("move_yaw", -vel.y / maxspeed)
	elseif pl:IsPlayer() and pl:GetPlayerClass() == "combinesoldier" then
		maxspeed = maxspeed * 3
		
		local vel = 1 * velocity
		vel:Rotate(Angle(0,-pl:EyeAngles().y,0))
		vel:Rotate(Angle(-vel:Angle().p,0,0))
		
		pl:SetPoseParameter("move_x", vel.x / maxspeed)
		pl:SetPoseParameter("move_yaw", -vel.y / maxspeed)
	else
		maxspeed = maxspeed * 3
		
		local vel = 1 * velocity
		vel:Rotate(Angle(0,-pl:EyeAngles().y,0))
		vel:Rotate(Angle(-vel:Angle().p,0,0))
		
		local maxspeed2 =  pl:GetClassSpeed()
		
		pl:SetPoseParameter("move_x", vel.x / maxspeed2)
		pl:SetPoseParameter("move_y", -vel.y / maxspeed2)		
	
	end
	
	local pitch = math.Clamp(math.NormalizeAngle(-pl:EyeAngles().p), -45, 90)
	pl:SetPoseParameter("body_pitch", pitch)
	
	if not pl.PlayerBodyYaw or not pl.TargetBodyYaw then
		pl.TargetBodyYaw = pl:EyeAngles().y
		pl.PlayerBodyYaw = pl.TargetBodyYaw
	end
	
	local diff
	diff = pl.PlayerBodyYaw - pl:EyeAngles().y
	
	if velocity:Length2D() > 0.5 or diff > 45 or diff < -45 then
		pl.TargetBodyYaw = pl:EyeAngles().y
	end
		
	local d = pl.TargetBodyYaw - pl.PlayerBodyYaw
	if d > 180 then
		pl.PlayerBodyYaw = math.NormalizeAngle(Lerp(0.2, pl.PlayerBodyYaw+360, pl.TargetBodyYaw))
	elseif d < -180 then
		pl.PlayerBodyYaw = math.NormalizeAngle(Lerp(0.2, pl.PlayerBodyYaw-360, pl.TargetBodyYaw))
	else
		pl.PlayerBodyYaw = Lerp(0.2, pl.PlayerBodyYaw, pl.TargetBodyYaw)
	end
	
	pl:SetPoseParameter("body_yaw", diff)
	
	local vel = 1 * velocity
	vel:Rotate(Angle(0,-pl:EyeAngles().y,0))
	vel:Rotate(Angle(-vel:Angle().p,0,0))
	pl:SetPoseParameter("move_yaw", -vel.y / maxspeed)
	
	if CLIENT then
		pl:SetRenderAngles(Angle(0, pl.PlayerBodyYaw, 0))
		--pl:SetRenderAngles(Angle(0, pl:EyeAngles().y, 0))
	end
end

function GM:CalcMainActivity(pl, vel)
	if pl:IsHL2() then
		return self.BaseClass:CalcMainActivity(pl, vel)
	end
	
	pl.anim_CalcIdeal = (pl.anim_Deployed and ACT_MP_DEPLOYED_IDLE) or ACT_MP_STAND_IDLE
	pl.anim_CalcSeqOverride = -1
	
	if
		self:HandlePlayerDriving(pl) or
		self:HandlePlayerSwimming(pl) or
		self:HandlePlayerJumping(pl) or
		self:HandlePlayerDucking(pl, vel) then
		-- do nothing
	else
		local len2d = vel:Length2D()
		
		if len2d > 0.5 then
			pl.anim_CalcIdeal = (pl.anim_Deployed and ACT_MP_DEPLOYED) or ACT_MP_RUN
		end
	end
	
	return pl.anim_CalcIdeal, pl.anim_CalcSeqOverride
end

local LoserStateActivityTranslate = {}

local VoiceCommandGestures = {
	[ACT_MP_GESTURE_VC_HANDMOUTH] = true,
	[ACT_MP_GESTURE_VC_THUMBSUP] = true,
	[ACT_MP_GESTURE_VC_FINGERPOINT] = true,
	[ACT_MP_GESTURE_VC_FISTPUMP] = true,
}

local TauntGestures = {
	[ACT_DOD_HS_CROUCH_KNIFE] = "taunt_laugh",
	[ACT_DOD_CROUCH_AIM_C96] = "taunt01",
	[ACT_DOD_CROUCHWALK_AIM_MP40] = "taunt02",
	[ACT_DOD_STAND_AIM_30CAL] = "taunt03",
	[ACT_DOD_SPRINT_AIM_SPADE] = "taunt04",
	[ACT_DOD_CROUCH_AIM_RIFLE] = "taunt07_halloween",
	[ACT_DOD_WALK_IDLE_MP44] = "taunt11_howl",
	[ACT_DOD_CROUCHWALK_AIM_30CAL] = "taunt_replay",
	[ACT_DOD_STAND_ZOOM_BOLT] = "taunt_hifivesuccess",
	[ACT_DOD_CROUCH_ZOOM_BOLT] = "taunt_highfivesuccess",
	[ACT_DOD_CROUCHWALK_ZOOM_BOLT] = "taunt_highfivesuccessfull",
	[ACT_DOD_WALK_ZOOM_BOLT] = "taunt_hifivesuccessfull",
	[ACT_DOD_SECONDARYATTACK_PRONE_BOLT] = "taunt_dosido_dance",
	[ACT_DOD_PRONEWALK_IDLE_BAR] = "taunt_rps_scissors_win",
	[ACT_DOD_SPRINT_IDLE_BAR] = "taunt_rps_scissors_lose",
	[ACT_DOD_PRIMARYATTACK_BOLT] = "throw_fire",
	[ACT_DOD_SECONDARYATTACK_BOLT] = "taunt_flip_success_initiator",
	[ACT_WALK_SCARED] = "taunt_party_trick",
	[ACT_DOD_PRIMARYATTACK_PRONE_BOLT] = "taunt_flip_success_receiver",
	[ACT_DOD_RUN_IDLE_MG] = "taunt_headbutt_success",
	[ACT_DOD_CROUCH_IDLE_TOMMY] = "taunt06",
	[ACT_DOD_STAND_AIM_KNIFE] = "taunt09",
	[ACT_DOD_CROUCHWALK_IDLE_PISTOL] = "taunt_conga",
	[ACT_DI_ALYX_ZOMBIE_TORSO_MELEE] = "taunt_russian",
	[ACT_DOD_CROUCH_IDLE_PISTOL] = "taunt04",
	[ACT_DOD_WALK_AIM_PSCHRECK] = "taunt_brutallegend",
	[ACT_DOD_ZOOMLOAD_BAZOOKA] = "taunt_rps_rock_win",
	[ACT_DOD_RELOAD_PSCHRECK] = "taunt_rps_rock_lose",
	[ACT_DOD_ZOOMLOAD_PSCHRECK] = "taunt_rps_paper_win",
	[ACT_DOD_RELOAD_DEPLOYED_FG42] = "taunt_rps_paper_lose",
	[ACT_DOD_DEPLOYED] = "Shoved_Backward",
	[ACT_DOD_PRONE_DEPLOYED] = "melee_pounce",
	[ACT_DOD_IDLE_ZOOMED] = "Charger_punch",
	[ACT_DOD_WALK_ZOOMED] = "a_grapple_pull_idle",
	[ACT_DOD_CROUCH_ZOOMED] = "a_grapple_SHOOT",
	[ACT_DOD_CROUCHWALK_ZOOMED] = "a_grapple_pull_start",
	[ACT_DOD_PRONE_ZOOMED] = "rocketpack_stand_launch",
	[ACT_DOD_PRONE_FORWARD_ZOOMED] = "SECONDARY_fire_alt",
	[ACT_DOD_PRIMARYATTACK_DEPLOYED] = "ReloadStand_MELEE_ALLCLASS",
	[ACT_DOD_PRIMARYATTACK_PRONE_DEPLOYED] = "ReloadStand_ITEM1",
	[ACT_SIGNAL1] = "stomp_ITEM4",
	[ACT_SIGNAL2] = "taunt08",
	[ACT_DOD_RELOAD_DEPLOYED] = "taunt07",
	[ACT_DOD_RELOAD_PRONE_DEPLOYED] = "selectionMenu_Anim01",
	[ACT_SMG2_IDLE2] = "ReloadStand_PRIMARY_end",
	[ACT_SMG2_FIRE2] = "ReloadStand_SECONDARY_end",
	[ACT_SMG2_DRAW2] = "PRIMARY_reload_end",
	[ACT_SMG2_RELOAD2] = "a_SECONDARY_reload_end",
	[ACT_SMG2_DRYFIRE2] = "a_primary_reload_end",
	[ACT_RUN_AIM] = "taunt_dosido_intro",
	[ACT_RUN_CROUCH] = "taunt_rps_start",
	[ACT_SIGNAL3] = "taunt_bumpkins_banjo_fastloop",
	[ACT_SIGNAL_ADVANCE] = "taunt_bumpkins_banjo_outro",
}

function GM:TranslateActivity(pl, act)
	if pl:IsHL2() then
		return self.BaseClass:TranslateActivity(pl, act)
	end
	
	if pl:IsLoser() then
		if LoserStateActivityTranslate[ACT_MP_STAND_IDLE] ~= ACT_MP_STAND_LOSERSTATE then
			LoserStateActivityTranslate[ACT_MP_STAND_IDLE] 						= ACT_MP_STAND_LOSERSTATE
			LoserStateActivityTranslate[ACT_MP_RUN] 							= ACT_MP_RUN_LOSERSTATE
			LoserStateActivityTranslate[ACT_MP_CROUCH_IDLE] 					= ACT_MP_CROUCH_LOSERSTATE
			LoserStateActivityTranslate[ACT_MP_CROUCHWALK] 						= ACT_MP_CROUCHWALK_LOSERSTATE
			LoserStateActivityTranslate[ACT_MP_SWIM] 							= ACT_MP_SWIM_LOSERSTATE
			LoserStateActivityTranslate[ACT_MP_AIRWALK] 						= ACT_MP_AIRWALK_LOSERSTATE

			LoserStateActivityTranslate[ACT_MP_JUMP_START] 						= ACT_MP_JUMP_START_LOSERSTATE
			LoserStateActivityTranslate[ACT_MP_JUMP_FLOAT] 						= ACT_MP_JUMP_FLOAT_LOSERSTATE
			LoserStateActivityTranslate[ACT_MP_JUMP_LAND] 						= ACT_MP_JUMP_LAND_LOSERSTATE
		end
		
		return LoserStateActivityTranslate[act] or act
	end

	if pl:InVehicle() then
		return ACT_DOD_RELOAD_DEPLOYED or act
	end
	
	return pl:TranslateWeaponActivity(act)
end

function GM:DoAnimationEvent(pl, event, data, taunt)
	if pl:IsHL2() then
		return self.BaseClass:DoAnimationEvent(pl, event, data)
	end
	
	local w = pl:GetActiveWeapon()
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		if pl.anim_InSwim then
			pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_SWIM_PRIMARYFIRE, true)
		elseif pl:Crouching() then
			pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_CROUCH_PRIMARYFIRE, true)
		else
			pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_STAND_PRIMARYFIRE, true)
		end
		
		--return ACT_INVALID
		if IsValid(w) and w.GetPrimaryFireActivity then
			return w:GetPrimaryFireActivity()
		else
			return ACT_INVALID
		end
	elseif event == PLAYERANIMEVENT_RELOAD then
		if pl.anim_InSwim then
			pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_SWIM, true)
		elseif pl:Crouching() then
			pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_CROUCH, true)
		else
			pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_STAND, true)
		end
		
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_CUSTOM_GESTURE then
		if data == ACT_MP_DOUBLEJUMP then
			-- Double jump
			pl:AnimRestartGesture(GESTURE_SLOT_JUMP, ACT_MP_DOUBLEJUMP, true)
		elseif data == ACT_MP_GESTURE_FLINCH_CHEST then
			-- Flinch
			pl:AnimRestartGesture(GESTURE_SLOT_FLINCH, ACT_MP_GESTURE_FLINCH_CHEST, true)
		elseif data == ACT_MP_AIRWALK then
			-- Go into airwalk animation
			if pl.anim_Jumping then
				pl.anim_Jumping = false
			end
			pl.anim_Airwalk = true
			pl:AnimRestartMainSequence()
		elseif data == ACT_MP_RELOAD_STAND_LOOP then
			-- Reload loop
			if pl.anim_InSwim then
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_SWIM_LOOP, true)
			elseif pl:Crouching() then
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_CROUCH_LOOP, true)
			else
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_STAND_LOOP, true)
			end
		elseif data == ACT_MP_RELOAD_STAND_END then
			-- Reload end
			if pl.anim_InSwim then
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_SWIM_END, true)
			elseif pl:Crouching() then
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_CROUCH_END, true)
			else
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_STAND_END, true)
			end
		elseif data == ACT_MP_ATTACK_STAND_PREFIRE then
			-- Prefire gesture
			local act
			--MsgN("Restarting prefire gesture")
			if pl.anim_InSwim then
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_SWIM_PREFIRE, true)
			elseif pl:Crouching() then
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_CROUCH_PREFIRE, true)
			else
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_STAND_PREFIRE, true)
			end
			pl.anim_Deployed = true
		elseif data == ACT_MP_ATTACK_STAND_POSTFIRE then
			-- Postfire gesture
			if pl.anim_InSwim then
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_SWIM_POSTFIRE, true)
			elseif pl:Crouching() then
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_CROUCH_POSTFIRE, true)
			else
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_STAND_POSTFIRE, true)
			end
			pl.anim_Deployed = false
		elseif data == ACT_MP_ATTACK_STAND_SECONDARYFIRE then
			-- Secondary attack gesture
			if pl.anim_InSwim then
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_SWIM_SECONDARYFIRE, true)
			elseif pl:Crouching() then
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_CROUCH_SECONDARYFIRE, true)
			else
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_STAND_SECONDARYFIRE, true)
			end
		elseif data == ACT_MP_ATTACK_STAND_PRIMARY_DEPLOYED then
			-- Deployed attack gesture
			if pl.anim_InSwim then
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_SWIM_PRIMARY_DEPLOYED, true)
			elseif pl:Crouching() then
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_CROUCH_PRIMARY_DEPLOYED, true)
			else
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_STAND_PRIMARY_DEPLOYED, true)
			end
		elseif data == ACT_MP_DEPLOYED then
			-- Enter deployed state
			if not pl.anim_Deployed then
				pl.anim_Deployed = true
				pl:AnimRestartMainSequence()
			end
		elseif data == ACT_MP_STAND_PRIMARY then
			-- Leave deployed state
			if pl.anim_Deployed then
				pl.anim_Deployed = false
				pl:AnimRestartMainSequence()
			end
		elseif VoiceCommandGestures[data] then
			pl:AnimRestartGesture(GESTURE_SLOT_CUSTOM, data, true)
		elseif TauntGestures[data] then -- laugh
			pl:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, pl:LookupSequence(TauntGestures[data]), 0, true)
		else
			-- just let us do custom ones man
			pl:AnimRestartGesture(GESTURE_SLOT_CUSTOM, data, true)
		end
		
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_JUMP then
		pl.anim_Jumping = true
		pl.anim_FirstJumpFrame = true
		pl.anim_JumpStartTime = CurTime()
		
		pl:AnimRestartMainSequence()
		
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_CANCEL_RELOAD then
		pl:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
		return ACT_INVALID
	end
end

local meta = FindMetaTable("Weapon")

local OldSendWeaponAnim = meta.SendWeaponAnim

function meta:SendWeaponAnim(act)
	if not act or act == -1 then return end
	--MsgN(Format("SendWeaponAnim %d %s",act,tostring(self)))
	if IsValid(self.Owner) and self.Owner:IsPlayer() and IsValid(self.Owner:GetViewModel()) and self.ViewModelOverride then
		for k, v in pairs(self.Owner:GetWeapons()) do
			if IsValid(v) and v:GetClass() == "tf_weapon_robot_arm" and v.IsRoboArm then
				self.ViewModelOverride = "models/weapons/c_models/c_engineer_gunslinger.mdl"
			elseif IsValid(v) and v:GetClass() == "tf_weapon_shortcircuit" and v.IsRoboArm then
				self.Owner:GetViewModel():SetBodygroup(2, 1)
			end
		end
		
		self:SetModel(self.ViewModelOverride)
		self.Owner:GetViewModel():SetModel(self.ViewModelOverride)
	end

	OldSendWeaponAnim(self,act)
end
