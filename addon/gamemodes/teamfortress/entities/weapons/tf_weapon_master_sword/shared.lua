if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then

SWEP.PrintName			= "The Master Sword"
SWEP.HasCModel = true
SWEP.Slot				= 2

SWEP.DamageType = DMG_SLASH
SWEP.CritDamageType = DMG_SLASH

SWEP.CriticalChance = 3

local WhisperIdle = Sound("")
local WhisperKill = Sound("")

usermessage.Hook("SwordWhisper", function(msg)
	local t = msg:ReadChar()
	if t==2 then	return nil
	else			return nil
	end
end)

function SWEP:InitializeCModel()
	self:CallBaseFunction("InitializeCModel")
	
	for _,v in pairs(self.Owner:GetTFItems()) do
		if v:GetClass() == "tf_wearable_item_demoshield" then
			self.ShieldEntity = v
			v:InitializeCModel(self)
		elseif v:GetClass() == "tf_wearable_item_hylianshield" then
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

end

SWEP.Base				= "tf_weapon_melee_base"

SWEP.ViewModel			= "models/weapons/c_models/c_demo_arms.mdl"
SWEP.WorldModel			= "models/weapons/c_models/c_claymore/c_claymore.mdl"
SWEP.Crosshair = "tf_crosshair3"
SWEP.ItemName = "Unique Achievement Sword"

SWEP.Swing = Sound("Weapon_Sword.Swing")
SWEP.SwingCrit = Sound("Weapon_Sword.SwingCrit")
SWEP.HitFlesh = Sound("Weapon_Sword.HitFlesh")
SWEP.HitWorld = Sound("Weapon_Sword.HitWorld")

SWEP.WhisperKillProbabilityPlayer = 0
SWEP.WhisperKillProbabilityNPC = 0

SWEP.WhisperIdleMinDelay = 999
SWEP.WhisperIdleMaxDelay = 999
SWEP.WhisperKillMinDelay = 999
SWEP.WhisperKillMaxDelay = 999

SWEP.MeleeRange = 100
SWEP.HealthBonus = 0

SWEP.BaseDamage = 65
SWEP.DamageRandomize = 0.1
SWEP.MaxDamageRampUp = 0
SWEP.MaxDamageFalloff = 0

--SWEP.CriticalChance = 0

SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay          = 0.8

SWEP.HoldType = "ITEM1"

SWEP.UsesSpecialAnimations = true

SWEP.VM_DRAW = ACT_VM_DRAW_SPECIAL
SWEP.VM_IDLE = ACT_VM_IDLE_SPECIAL
SWEP.VM_HITCENTER = ACT_VM_HITCENTER_SPECIAL
SWEP.VM_SWINGHARD = ACT_VM_HITCENTER_SPECIAL

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
	end
end

function SWEP:Think()
	self:CallBaseFunction("Think")
	
	if SERVER and self.dt.IsEyelander then
		if not self.NextWhisper then
			return nil
		end
	end
end

function SWEP:OnRemove()
	if SERVER then
		--self.Owner:SetNWInt("Heads", 0)
	end
end