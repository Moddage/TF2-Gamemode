
--==================================================================
-- FIRSTPERSON ANIMATIONS
--==================================================================

SWEP.VM_DRAW = ACT_VM_DRAW
SWEP.VM_IDLE = ACT_VM_IDLE
SWEP.VM_PRIMARYATTACK = ACT_VM_PRIMARYATTACK
SWEP.VM_SECONDARYATTACK = ACT_VM_SECONDARYATTACK
SWEP.VM_RELOAD = ACT_VM_RELOAD
SWEP.VM_RELOAD_START = ACT_RELOAD_START
SWEP.VM_RELOAD_FINISH = ACT_RELOAD_FINISH

local ActivityNameTranslate = {
	ACT_VM_DRAW				= "VM_DRAW",
	ACT_VM_IDLE				= "VM_IDLE",
	ACT_VM_PRIMARYATTACK	= "VM_PRIMARYATTACK",
	ACT_VM_SECONDARYATTACK	= "VM_SECONDARYATTACK",
	ACT_VM_RELOAD			= "VM_RELOAD",
	ACT_RELOAD_START		= "VM_RELOAD_START",
	ACT_RELOAD_FINISH		= "VM_RELOAD_FINISH",
	ACT_VM_HITLEFT			= "VM_HITLEFT",
	ACT_VM_HITRIGHT			= "VM_HITRIGHT",
	ACT_VM_HITCENTER		= "VM_HITCENTER",
	ACT_VM_SWINGHARD		= "VM_SWINGHARD",
}

function SWEP:SetupCModelActivities(item, noreplace)
	tf_util.ReadActivitiesFromModel(self)
	
	if item then
		local hold = string.upper(item.anim_slot or item.item_slot)
		--MsgN(Format("SetupCModelActivities %s", tostring(self)))
		
		self.VM_DRAW			= _G["ACT_"..hold.."_VM_DRAW"]
		self.VM_IDLE			= _G["ACT_"..hold.."_VM_IDLE"]
		self.VM_PRIMARYATTACK	= _G["ACT_"..hold.."_VM_PRIMARYATTACK"]
		self.VM_SECONDARYATTACK	= _G["ACT_"..hold.."_VM_SECONDARYATTACK"]
		self.VM_RELOAD			= _G["ACT_"..hold.."_VM_RELOAD"]
		self.VM_RELOAD_START	= _G["ACT_"..hold.."_RELOAD_START"]
		self.VM_RELOAD_FINISH	= _G["ACT_"..hold.."_RELOAD_FINISH"]
		
		-- Special activities
		self.VM_CHARGE			= _G["ACT_"..hold.."_VM_CHARGE"]
		self.VM_DRYFIRE			= _G["ACT_"..hold.."_VM_DRYFIRE"]
		self.VM_IDLE_2			= _G["ACT_"..hold.."_VM_IDLE_2"]
		self.VM_CHARGE_IDLE_3	= _G["ACT_"..hold.."_VM_CHARGE_IDLE_3"]
		self.VM_IDLE_3			= _G["ACT_"..hold.."_VM_IDLE_3"]
		self.VM_PULLBACK		= _G["ACT_"..hold.."_VM_PULLBACK"]
		self.VM_PREFIRE			= _G["ACT_"..hold.."_ATTACK_STAND_PREFIRE"]
		self.VM_POSTFIRE		= _G["ACT_"..hold.."_ATTACK_STAND_POSTFIRE"]
		
		self.VM_INSPECT_START	= _G["ACT_"..hold.."_VM_INSPECT_START"]
		self.VM_INSPECT_IDLE	= _G["ACT_"..hold.."_VM_INSPECT_IDLE"]
		self.VM_INSPECT_END		= _G["ACT_"..hold.."_VM_INSPECT_END"]
		
		self.VM_HITLEFT			= ACT_VM_HITLEFT
		self.VM_HITRIGHT		= ACT_VM_HITRIGHT
		
		-- those melee activities are just so weird, sometimes it's ACT_VM_HITCENTER, sometimes it's ACT_MELEE_VM_HITCENTER
		if self:SelectWeightedSequence(ACT_VM_HITCENTER) < 0 then
			self.VM_HITCENTER		= _G["ACT_"..hold.."_VM_HITCENTER"] or ACT_VM_HITCENTER
			self.VM_SWINGHARD		= _G["ACT_"..hold.."_VM_SWINGHARD"] or ACT_VM_SWINGHARD
		else
			self.VM_HITCENTER		= ACT_VM_HITCENTER
			self.VM_SWINGHARD		= ACT_VM_SWINGHARD
		end
	else
		self.VM_DRAW			= ACT_VM_DRAW
		self.VM_IDLE			= ACT_VM_IDLE
		self.VM_PRIMARYATTACK	= ACT_VM_PRIMARYATTACK
		self.VM_SECONDARYATTACK	= ACT_VM_SECONDARYATTACK
		self.VM_RELOAD			= ACT_VM_RELOAD
		self.VM_RELOAD_START	= ACT_RELOAD_START
		self.VM_RELOAD_FINISH	= ACT_RELOAD_FINISH
		
		self.VM_CHARGE			= ACT_INVALID
		self.VM_DRYFIRE			= ACT_INVALID
		self.VM_IDLE_2			= ACT_INVALID
		self.VM_CHARGE_IDLE_3	= ACT_INVALID
		self.VM_IDLE_3			= ACT_INVALID
		self.VM_PULLBACK		= ACT_VM_PULLBACK
		self.VM_PREFIRE			= ACT_MP_ATTACK_STAND_PREFIRE
		self.VM_POSTFIRE		= ACT_MP_ATTACK_STAND_POSTFIRE
		
		self.VM_INSPECT_START	= ACT_PRIMARY_VM_INSPECT_START
		self.VM_INSPECT_IDLE	= ACT_PRIMARY_VM_INSPECT_IDLE
		self.VM_INSPECT_END		= ACT_PRIMARY_VM_INSPECT_END
		
		self.VM_HITLEFT			= ACT_VM_HITLEFT
		self.VM_HITRIGHT		= ACT_VM_HITRIGHT
		self.VM_HITCENTER		= ACT_VM_HITCENTER
		self.VM_SWINGHARD		= ACT_VM_SWINGHARD
	end
	
	if self.UsesSpecialAnimations then
		self.VM_DRAW = ACT_VM_DRAW_SPECIAL
		self.VM_IDLE = ACT_VM_IDLE_SPECIAL
		--self.VM_HITLEFT = ACT_VM_HITLEFT_SPECIAL
		--self.VM_HITRIGHT = ACT_VM_HITRIGHT_SPECIAL
		self.VM_HITCENTER = ACT_VM_HITCENTER_SPECIAL
		self.VM_SWINGHARD = ACT_VM_SWINGHARD_SPECIAL
	end
	
	if not noreplace then
		local visuals = self:GetVisuals()
		if visuals and visuals.animations then
			for act,rep in pairs(visuals.animations) do
				if ActivityNameTranslate[act] then
					self[ActivityNameTranslate[act]] = _G[rep]
				end
			end
		end
	end
end

function SWEP:SendWeaponAnimEx(anim)
	local t = type(anim)
	
	if t=="string" then
		if string.find(anim,",") then
			anim = string.Explode(",", anim)
			t = "table"
		end
	end
	
	if t=="table" then
		anim = table.Random(anim)
		t = type(anim)
	end
	
	if t=="number" then
		self:SendWeaponAnim(anim)
	elseif t=="string" then
		print(anim)
		local s = self.Owner:GetViewModel():LookupSequence(anim)
		self:SetSequence(s)
		self.Owner:GetViewModel():SetSequence(s)
	end
end

--==================================================================
-- THIRDPERSON ANIMATIONS
--==================================================================

function SWEP:SetWeaponHoldType(t)
	local owner = (IsValid(self.Owner) and self.Owner) or _G.TFWeaponItemOwner
	
	if IsValid(owner) then
		tf_util.ReadActivitiesFromModel(owner)
	end

	local slot = self:GetItemData()["item_slot"]
	
	if isstring(slot) then
		t = string.upper(slot)
	end
	
	if not _G["ACT_MP_STAND_"..t] then
		MsgN("SWEP:SetWeaponHoldType - Unknown TF2 weapon hold type '"..t.."'! Defaulting to PRIMARY")
		t = "PRIMARY"
	end
	
	self.ActivityTranslate = {}
	self.ActivityTranslate[ACT_MP_STAND_IDLE] 						= _G["ACT_MP_STAND_"..t]
	self.ActivityTranslate[ACT_MP_RUN] 								= _G["ACT_MP_RUN_"..t]
	self.ActivityTranslate[ACT_MP_CROUCH_IDLE] 						= _G["ACT_MP_CROUCH_"..t]
	self.ActivityTranslate[ACT_MP_CROUCHWALK] 						= _G["ACT_MP_CROUCHWALK_"..t]
	self.ActivityTranslate[ACT_MP_SWIM] 							= _G["ACT_MP_SWIM_"..t]
	self.ActivityTranslate[ACT_MP_AIRWALK] 							= _G["ACT_MP_AIRWALK_"..t]
	
	if t == "PRIMARY" then
		self.ActivityTranslate[ACT_MP_DEPLOYED_IDLE] 				= ACT_MP_DEPLOYED_IDLE
		self.ActivityTranslate[ACT_MP_DEPLOYED] 					= ACT_MP_DEPLOYED_PRIMARY
		self.ActivityTranslate[ACT_MP_CROUCH_DEPLOYED_IDLE] 		= ACT_MP_CROUCH_DEPLOYED_IDLE
		self.ActivityTranslate[ACT_MP_CROUCH_DEPLOYED] 				= ACT_MP_CROUCHWALK_DEPLOYED
		self.ActivityTranslate[ACT_MP_SWIM_DEPLOYED] 				= ACT_MP_SWIM_DEPLOYED_PRIMARY
	else
		self.ActivityTranslate[ACT_MP_DEPLOYED_IDLE] 				= _G["ACT_MP_DEPLOYED_IDLE_"..t]
		self.ActivityTranslate[ACT_MP_DEPLOYED] 					= _G["ACT_MP_DEPLOYED_"..t]
		self.ActivityTranslate[ACT_MP_CROUCH_DEPLOYED_IDLE] 		= _G["ACT_MP_CROUCH_DEPLOYED_IDLE_"..t]
		self.ActivityTranslate[ACT_MP_CROUCH_DEPLOYED] 				= _G["ACT_MP_CROUCHWALK_DEPLOYED_"..t]
		self.ActivityTranslate[ACT_MP_SWIM_DEPLOYED] 				= _G["ACT_MP_SWIM_DEPLOYED_"..t]
	end
	
	self.ActivityTranslate[ACT_MP_ATTACK_STAND_PRIMARYFIRE] 		= _G["ACT_MP_ATTACK_STAND_"..t]
	self.ActivityTranslate[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE]		= _G["ACT_MP_ATTACK_CROUCH_"..t]
	self.ActivityTranslate[ACT_MP_ATTACK_SWIM_PRIMARYFIRE]			= _G["ACT_MP_ATTACK_SWIM_"..t]
	
	if _G["ACT_MP_ATTACK_STAND_HARD_"..t] then
		self.ActivityTranslate[ACT_MP_ATTACK_STAND_SECONDARYFIRE] 		= _G["ACT_MP_ATTACK_STAND_HARD_"..t]
		self.ActivityTranslate[ACT_MP_ATTACK_CROUCH_SECONDARYFIRE]		= _G["ACT_MP_ATTACK_CROUCH_HARD_"..t]
		self.ActivityTranslate[ACT_MP_ATTACK_SWIM_SECONDARYFIRE]		= _G["ACT_MP_ATTACK_SWIM_HARD_"..t]
	else
		self.ActivityTranslate[ACT_MP_ATTACK_STAND_SECONDARYFIRE] 		= _G["ACT_MP_ATTACK_STAND_"..t.."_SECONDARY"]
		self.ActivityTranslate[ACT_MP_ATTACK_CROUCH_SECONDARYFIRE]		= _G["ACT_MP_ATTACK_CROUCH_"..t.."_SECONDARY"]
		self.ActivityTranslate[ACT_MP_ATTACK_SWIM_SECONDARYFIRE]		= _G["ACT_MP_ATTACK_SWIM_"..t.."_SECONDARY"]
	end
	
	self.ActivityTranslate[ACT_MP_ATTACK_STAND_PRIMARY_DEPLOYED] 	= _G["ACT_MP_ATTACK_STAND_"..t.."_DEPLOYED"]
	self.ActivityTranslate[ACT_MP_ATTACK_CROUCH_PRIMARY_DEPLOYED] 	= _G["ACT_MP_ATTACK_CROUCH_"..t.."_DEPLOYED"]
	self.ActivityTranslate[ACT_MP_ATTACK_SWIM_PRIMARY_DEPLOYED or 0]= _G["ACT_MP_ATTACK_SWIM_"..t.."_DEPLOYED"]
	
	self.ActivityTranslate[ACT_MP_ATTACK_STAND_PREFIRE]				= ACT_MP_ATTACK_STAND_PREFIRE
	self.ActivityTranslate[ACT_MP_ATTACK_CROUCH_PREFIRE]			= ACT_MP_ATTACK_CROUCH_PREFIRE
	self.ActivityTranslate[ACT_MP_ATTACK_SWIM_PREFIRE]				= ACT_MP_ATTACK_SWIM_PREFIRE
	
	self.ActivityTranslate[ACT_MP_ATTACK_STAND_POSTFIRE]			= ACT_MP_ATTACK_STAND_POSTFIRE
	self.ActivityTranslate[ACT_MP_ATTACK_CROUCH_POSTFIRE]			= ACT_MP_ATTACK_CROUCH_POSTFIRE
	self.ActivityTranslate[ACT_MP_ATTACK_SWIM_POSTFIRE]				= ACT_MP_ATTACK_SWIM_POSTFIRE
	
	self.ActivityTranslate[ACT_MP_RELOAD_STAND]		 				= _G["ACT_MP_RELOAD_STAND_"..t]
	self.ActivityTranslate[ACT_MP_RELOAD_CROUCH]		 			= _G["ACT_MP_RELOAD_CROUCH_"..t]
	self.ActivityTranslate[ACT_MP_RELOAD_SWIM]		 				= _G["ACT_MP_RELOAD_SWIM_"..t]
	self.ActivityTranslate[ACT_MP_RELOAD_AIRWALK]					= _G["ACT_MP_RELOAD_STAND_"..t]
	
	self.ActivityTranslate[ACT_MP_RELOAD_STAND_LOOP]		 		= _G["ACT_MP_RELOAD_STAND_"..t.."_LOOP"]
	self.ActivityTranslate[ACT_MP_RELOAD_CROUCH_LOOP]		 		= _G["ACT_MP_RELOAD_CROUCH_"..t.."_LOOP"]
	self.ActivityTranslate[ACT_MP_RELOAD_SWIM_LOOP]		 			= _G["ACT_MP_RELOAD_SWIM_"..t.."_LOOP"]
	
	self.ActivityTranslate[ACT_MP_RELOAD_STAND_END]		 			= _G["ACT_MP_RELOAD_STAND_"..t.."_END"]
	self.ActivityTranslate[ACT_MP_RELOAD_CROUCH_END]		 		= _G["ACT_MP_RELOAD_CROUCH_"..t.."_END"]
	self.ActivityTranslate[ACT_MP_RELOAD_SWIM_END]		 			= _G["ACT_MP_RELOAD_SWIM_"..t.."_END"]
	
	self.ActivityTranslate[ACT_MP_JUMP_START] 						= _G["ACT_MP_JUMP_START_"..t]
	self.ActivityTranslate[ACT_MP_JUMP_FLOAT] 						= _G["ACT_MP_JUMP_FLOAT_"..t]
	self.ActivityTranslate[ACT_MP_JUMP_LAND] 						= _G["ACT_MP_JUMP_LAND_"..t]
	
	self.ActivityTranslate[ACT_MP_GESTURE_VC_HANDMOUTH] 			= _G["ACT_MP_GESTURE_VC_HANDMOUTH_"..t]
	self.ActivityTranslate[ACT_MP_GESTURE_VC_THUMBSUP] 				= _G["ACT_MP_GESTURE_VC_THUMBSUP_"..t]
	self.ActivityTranslate[ACT_MP_GESTURE_VC_FINGERPOINT] 			= _G["ACT_MP_GESTURE_VC_FINGERPOINT_"..t]
	self.ActivityTranslate[ACT_MP_GESTURE_VC_FISTPUMP] 				= _G["ACT_MP_GESTURE_VC_FISTPUMP_"..t]
end

function SWEP:TranslateActivity(act)
	return self.ActivityTranslate[act] or -1
end
