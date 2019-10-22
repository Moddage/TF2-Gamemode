if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "Fire Axe"
SWEP.Slot				= 2
end

SWEP.Base				= "tf_weapon_melee_base"

SWEP.ViewModel			= "models/weapons/v_models/v_fireaxe_pyro.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_fireaxe.mdl"
SWEP.Crosshair = "tf_crosshair2"

SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Team Fortress 2"

SWEP.Swing = Sound("Weapon_FireAxe.Miss")
SWEP.SwingCrit = Sound("Weapon_FireAxe.MissCrit")
SWEP.HitFlesh = Sound("Weapon_FireAxe.HitFlesh")
SWEP.HitRobot = Sound("MVM_Weapon_Sword.HitFlesh")
SWEP.HitWorld = Sound("Weapon_FireAxe.HitWorld")

SWEP.BaseDamage = 65
SWEP.DamageRandomize = 0.1
SWEP.MaxDamageRampUp = 0
SWEP.MaxDamageFalloff = 0

SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay = 0.8
SWEP.ReloadTime = 0.8

SWEP.HoldType = "MELEE"
SWEP.HoldTypeHL2 = "MELEE2"

SWEP.DamageType = DMG_SLASH
--SWEP.CritDamageType = DMG_SLASH|DMG_CRUSH
SWEP.CritDamageType = DMG_SLASH, DMG_CRUSH

-- The following weapons should not cut zombies in half
local NoSlashDamage = {
	[153] = true,	-- Homewrecker
	[214] = true,	-- Powerjack
	[326] = true,	-- Back Scratcher
}

function SWEP:InitAttributes(owner, attributes)
	self:CallBaseFunction("InitAttributes", owner, attributes)
	
	if NoSlashDamage[self:ItemIndex()] then
		self.DamageType = DMG_CLUB
		self.CritDamageType = DMG_CLUB
	end
end