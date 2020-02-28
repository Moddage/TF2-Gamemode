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
				pl:AnimRestartGesture(GESTURE_SLOT_JUMP, ACT_MP_JUMP_LAND, true)
			end
		end
		
		if pl.anim_Jumping then
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
	
	if pl:Crouching() and !pl:IsHL2() then
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
		maxspeed = c.Speed
	end
	
	if (pl:OnGround() and pl:Crouching()) then
		maxspeed = maxspeed * 0.3
	elseif pl:WaterLevel() > 1 then
		maxspeed = maxspeed * 0.8
	end
	
	if c and c.ModifyMaxAnimSpeed then
		maxspeed = c.ModifyMaxAnimSpeed(pl, maxspeed)
	end
	
	maxspeed = maxspeed * 3
	
	local vel = 1 * velocity
	vel:Rotate(Angle(0,-pl:EyeAngles().y,0))
	vel:Rotate(Angle(-vel:Angle().p,0,0))
	
	pl:SetPoseParameter("move_x", vel.x / maxspeed)
	pl:SetPoseParameter("move_y", -vel.y / maxspeed)
	
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
	[ACT_DOD_HS_CROUCH_KNIFE] = "layer_taunt_laugh",
	[ACT_DOD_CROUCH_AIM_C96] = "layer_taunt01",
	[ACT_DOD_CROUCHWALK_AIM_MP40] = "layer_taunt02",
	[ACT_DOD_STAND_AIM_30CAL] = "layer_taunt03",
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
		return ACT_KART_IDLE or act
	end
	
	return pl:TranslateWeaponActivity(act)
end

function GM:DoAnimationEvent(pl, event, data, taunt)
	if pl:IsHL2() then
		return self.BaseClass:DoAnimationEvent(pl, event, data)
	end
	
	print(event, data)
	
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
			end
		end
		
		self:SetModel(self.ViewModelOverride)
		self.Owner:GetViewModel():SetModel(self.ViewModelOverride)
	end

	OldSendWeaponAnim(self,act)
end
