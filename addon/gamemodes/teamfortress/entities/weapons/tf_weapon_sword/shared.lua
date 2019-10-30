if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then

SWEP.PrintName			= "The Eyelander"
SWEP.Slot				= 2

function SWEP:InitializeCModel()
	--Msg("InitializeCModel\n")
	local vm = self.Owner:GetViewModel()
	
	if IsValid(self.CModel) then
		self.CModel:SetModel(self:GetItemData().model_player)
	elseif IsValid(vm) then
		self.CModel = ents.CreateClientProp()
		
		self.CModel:SetPos(vm:GetPos())
		self.CModel:SetModel(self:GetItemData().model_player)
		self.CModel:SetAngles(vm:GetAngles())
		self.CModel:AddEffects(EF_BONEMERGE)
		self.CModel:SetParent(vm)
	end
	
	if IsValid(self.CModel) then
		self.CModel.Player = self.Owner
		self.CModel.Weapon = self
		
		if self.MaterialOverride then
			self.CModel:SetMaterial(self.MaterialOverride)
		end
	end	
	
	for _,v in pairs(self.Owner:GetTFItems()) do
		if v:GetClass() == "tf_wearable_item_demoshield" then
			self.ShieldEntity = v
			v:InitializeCModel(self)
		end
	end
	for _,v in pairs(self.Owner:GetTFItems()) do
		if v:GetClass() == "tf_wearable_item_tideturnr" then
			self.ShieldEntity = v
			v:InitializeCModel(self)
		end
	end
end

function SWEP:ViewModelDrawn()
	local vm = self.Owner:GetViewModel()
	vm.Player = self.Owner
	
	if not self.IsDeployed then
		local seq = vm:GetSequence()
		if vm:GetSequenceActivity(seq) == self.VM_DRAW then
			self.DeploySequence = seq
		end
		
		if self.Owner.TempAttributes and self.Owner.TempAttributes.DeployTimeMultiplier then
			vm:SetPlaybackRate(1 / self.Owner.TempAttributes.DeployTimeMultiplier)
		else
			vm:SetPlaybackRate(1)
		end
	else
		if self.DeploySequence ~= true and vm:GetSequence() ~= self.DeploySequence then
			vm:SetPlaybackRate(1)
			self.DeploySequence = true
		end
	end	
	
	if self.FixViewModel then
		if IsValid(self.CModel) then
			self.CModel:SetParent(vm)
		end
		self.FixViewModel = false
	end
	
	if self.ViewModelOverride --[[and self:GetModel()~=self.ViewModelOverride]] then
		self.ViewModel = self.ViewModelOverride
		self:SetModel(self.ViewModelOverride)
		vm:SetModel(self.ViewModelOverride)
	end
	
	self.DrawingViewModel = true
	if IsValid(self.CModel) then
		self.CModel:SetSkin(self.WeaponSkin or 0)
		self.CModel:SetMaterial(self.WeaponMaterial or 0)
	end
	if IsValid(self.AttachedVModel) then
		self.AttachedVModel:SetSkin(self.WeaponSkin or 0)
		//self.AttachedVModel:SetMaterial(self.WeaponMaterial or 0)
	end
	self.Owner:GetViewModel():SetSkin(self.WeaponSkin or 0)
	self.Owner:GetViewModel():SetMaterial(self.WeaponMaterial or 0)
	
	if self.ViewModelFlip then
		render.CullMode(MATERIAL_CULLMODE_CW)
	end
	self:StartVisualOverrides()
	
	self:RenderCModel()
	
	self:EndVisualOverrides()
	if self.ViewModelFlip then
		render.CullMode(MATERIAL_CULLMODE_CCW)
	end
	
	self:ModelDrawn(true)
	
	if IsValid(self.ShieldEntity) and IsValid(self.ShieldEntity.CModel) then
		self.ShieldEntity:StartVisualOverrides()
		self.ShieldEntity.CModel:DrawModel()
		self.ShieldEntity:EndVisualOverrides()
	end
end


local WhisperIdle = Sound("Sword.Idle")
local WhisperKill = Sound("Sword.Hit")

usermessage.Hook("SwordWhisper", function(msg)
	local t = msg:ReadChar()
	if t==2 then	LocalPlayer():EmitSound(WhisperKill)
	else			LocalPlayer():EmitSound(WhisperIdle)
	end
end)

function SWEP:InitializeCModel()
	self:CallBaseFunction("InitializeCModel")
	
	for _,v in pairs(self.Owner:GetTFItems()) do
		if v:GetClass() == "tf_wearable_item_demoshield" then
			self.ShieldEntity = v
			v:InitializeCModel(self)
		end
	end
	for _,v in pairs(self.Owner:GetTFItems()) do
		if v:GetClass() == "tf_wearable_item_tideturnr" then
			self.ShieldEntity = v
			v:InitializeCModel(self)
		end
	end
end

function SWEP:ViewModelDrawn()
	self:CallBaseFunction("ViewModelDrawn")
	
	if IsValid(self.ShieldEntity) and IsValid(self.ShieldEntity.CModel) then
		self.ShieldEntity:StartVisualOverrides()
		self.ShieldEntity.CModel:DrawModel()
		self.ShieldEntity:EndVisualOverrides()
	end
end

SWEP.GlobalCustomHUD = {HudItemEffectMeter_Demoman = function(self) return self.dt.IsEyelander end}

end

SWEP.Base				= "tf_weapon_melee_base"

SWEP.ViewModel			= "models/weapons/c_models/c_demo_arms.mdl"
SWEP.WorldModel			= "models/weapons/c_models/c_claymore/c_claymore.mdl"
SWEP.Crosshair = "tf_crosshair3"

SWEP.Swing = Sound("Weapon_Sword.Swing")
SWEP.SwingCrit = Sound("Weapon_Sword.SwingCrit")
SWEP.HitFlesh = Sound("Weapon_Sword.HitFlesh")
SWEP.HitRobot = Sound("MVM_Weapon_Sword.HitFlesh")
SWEP.HitWorld = Sound("Weapon_Sword.HitWorld")

SWEP.WhisperKillProbabilityPlayer = 0.5
SWEP.WhisperKillProbabilityNPC = 0.2

SWEP.WhisperIdleMinDelay = 10
SWEP.WhisperIdleMaxDelay = 60
SWEP.WhisperKillMinDelay = 2
SWEP.WhisperKillMaxDelay = 4

SWEP.MeleeRange = 100
SWEP.HealthBonus = 15

SWEP.BaseDamage = 65
SWEP.DamageRandomize = 0.1
SWEP.MaxDamageRampUp = 0	
SWEP.MaxDamageFalloff = 0

--SWEP.CriticalChance = 0

SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay = 0.8

SWEP.HoldType = "ITEM1"
SWEP.HoldTypeHL2 = "melee2"

SWEP.UsesSpecialAnimations = true

SWEP.VM_DRAW = ACT_VM_DRAW_SPECIAL
SWEP.VM_IDLE = ACT_VM_IDLE_SPECIAL
SWEP.VM_HITCENTER = ACT_VM_HITCENTER_SPECIAL
SWEP.VM_SWINGHARD = ACT_VM_SWINGHARD_SPECIAL

--[[
SWEP.VM_DRAW = "cm_draw"
SWEP.VM_IDLE = "cm_idle"
SWEP.VM_HITCENTER = "cm_swing_a,cm_swing_b"
SWEP.VM_SWINGHARD = "cm_swing_c"]]

function SWEP:SetupDataTables()
	self:CallBaseFunction("SetupDataTables")
	self:DTVar("Bool", 0, "IsEyelander")
end

-- The following weapons should not collect heads

local NoHeadCollecting = {
	[172] = true,	-- Scotsman's Skullcutter
	[327] = true,	-- Claidheamohmor
}

function SWEP:InitAttributes(owner, attributes)
	self:CallBaseFunction("InitAttributes", owner, attributes)
	
	
	if NoHeadCollecting[self:ItemIndex()] then
		return
	end
	
	self.dt.IsEyelander = true
end

function SWEP:OnPlayerKilled(ent)
	--ent:SetNWBool("ShouldDropDecapitatedRagdoll", true)
	if ent:CanGiveHead() then
		ent:AddDeathFlag(DF_DECAP)
		umsg.Start("GibPlayerHead")
			umsg.Entity(ent)
			umsg.Short(ent.DeathFlags)
		umsg.End()
	end
	
	if self.dt.IsEyelander and ent:CanGiveHead() then
		self.Owner:SetNWInt("Heads", self.Owner:GetNWInt("Heads") + 1)
		self.Owner:AddPlayerState(PLAYERSTATE_EYELANDER)
		self.Owner:UpdateState(0.1)
		
		if self.Owner:GetNWInt("Heads")<=4 then
			--self.Owner:SetClassSpeed(self.Owner:GetClassSpeed() + self.SpeedBonus)
			self.Owner.TempAttributes.AdditiveSpeedBonus = (self.Owner.TempAttributes.AdditiveSpeedBonus or 0) + 7.5
			if self.Owner:GetInfoNum("tf_giant_robot",0) != 1 then
			self.Owner:ResetClassSpeed()
			end
			
			self.Owner:SetMaxHealth(self.Owner:GetMaxHealth() + self.HealthBonus)
			--self.Owner:SetNWInt("PlayerMaxHealthBuff", self.HealthBonus * self:GetNWInt("Heads"))
		end
		self.Owner:SetHealth(self.Owner:Health() + self.HealthBonus)
		
		local prob
		if ent:IsPlayer() then	
			prob = self.WhisperKillProbabilityPlayer
			umsg.Start("GibPlayerHead")
				umsg.Entity(ent)
				umsg.Short(ent.DeathFlags)
			umsg.End()
		else					
			prob = self.WhisperKillProbabilityNPC
			umsg.Start("GibNPCHead")
				umsg.Entity(ent)
				umsg.Short(ent.DeathFlags)
			umsg.End()
			ent:EmitSound("player/flow.wav")
		end
		
		if math.random()<prob then
			self.WhisperType = 2
			self.NextWhisper = CurTime() + math.Rand(self.WhisperKillMinDelay, self.WhisperKillMaxDelay)
		end
	end
end

function SWEP:Think()
	self:CallBaseFunction("Think")
	if SERVER and self.dt.IsEyelander then
		if self.Owner:Armor() <= 60 then
			self.Owner:SetArmor(60)
		end
		if not self.NextWhisper then
			self.WhisperType = 1
			self.NextWhisper = CurTime() + math.Rand(self.WhisperIdleMinDelay, self.WhisperIdleMaxDelay)
		elseif CurTime()>self.NextWhisper then
			if self.WhisperType == 2 then
				if not self.Owner.NextSpeak or CurTime()>self.Owner.NextSpeak then
					umsg.Start("SwordWhisper", self.Owner)
						umsg.Char(2)
					umsg.End()
					self.WhisperType = 1
					self.NextWhisper = CurTime() + math.Rand(self.WhisperIdleMinDelay, self.WhisperIdleMaxDelay)
				else
					self.NextWhisper = CurTime() + math.Rand(self.WhisperKillMinDelay, self.WhisperKillMaxDelay)
				end
			else
				if not self.Owner.NextSpeak or CurTime()>self.Owner.NextSpeak then
					umsg.Start("SwordWhisper", self.Owner)
						umsg.Char(1)
					umsg.End()
				end
				self.NextWhisper = CurTime() + math.Rand(self.WhisperIdleMinDelay, self.WhisperIdleMaxDelay)
			end
		end
	end
end

function SWEP:OnRemove()
	if SERVER then
		--self.Owner:SetNWInt("Heads", 0)
	end
end