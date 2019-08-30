if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "Crowbar"
	SWEP.Slot				= 0
	SWEP.RenderGroup				= RENDERGROUP_BOTH
end

SWEP.Base				= "tf_weapon_melee_base"

SWEP.ViewModel			= "models/weapons/v_models/v_crowbar_merc.mdl"
SWEP.WorldModel			= "models/weapons/c_models/c_pickaxe/c_crowbar.mdl" 
SWEP.Crosshair = "tf_crosshair3"

SWEP.Swing = Sound("weapons/hl1/cbar_miss1.wav")
SWEP.SwingCrit = Sound("weapons/hl1/bar_miss1_crit.wav")
SWEP.HitFlesh = Sound("Weapon_Crowbar_HL1.HitFlesh")
SWEP.HitWorld = Sound("Weapon_Crowbar_HL1.HitWorld")

SWEP.DropPrimaryWeaponInstead = true

SWEP.BaseDamage = 65
SWEP.DamageRandomize = 0.1
SWEP.MaxDamageRampUp = 0
SWEP.MaxDamageFalloff = 0

SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay          = 0.4

SWEP.CritForceAddPitch = 45

SWEP.HoldType = "MELEE"
SWEP.HoldTypeHL2 = "fist"

SWEP.ShouldOccurFists = true

function SWEP:OnCritBoostStarted()
	self.Owner:EmitSound(self.CritEnabled)
end

function SWEP:OnCritBoostAdded()
	self.Owner:EmitSound(self.CritHit)
end

function SWEP:Think() 
	self:CallBaseFunction("Think")
	if self.Owner:KeyDown(IN_ATTACK) or self.Owner:KeyDown(IN_ATTACK2) then
		if self.ShouldOccurFists == true then
			if SERVER then
				if self.Owner:GetPlayerClass() == "heavy" and self.Owner:GetInfoNum("jakey_antlionfbii", 0) != 1 then
					self.Owner:EmitSound("vo/heavy_meleeing0"..math.random(1,6)..".mp3", 80, 100)
					self.ShouldOccurFists = false 
					timer.Simple(4, function()
						self.ShouldOccurFists = true
					end)
				elseif self.Owner:GetInfoNum("jakey_antlionfbii", 0) == 1 then
					self.Owner:EmitSound("NPC_AntlionGuard.Roar", 150, 100)
					self.ShouldOccurFists = false
					self.HitFlesh = Sound("npc/antlion_guard/shove1.wav", 120)
					self.HitWorld = Sound("npc/antlion_guard/shove1.wav", 120)
					self.BaseDamage = 180
					timer.Simple(0.8, function()
						self.ShouldOccurFists = true
					end)
				end
			end
		end
	end
end
		
