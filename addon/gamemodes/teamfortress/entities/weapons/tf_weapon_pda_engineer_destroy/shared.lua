if SERVER then

AddCSLuaFile("shared.lua")

end

SWEP.Base				= "tf_weapon_base"

SWEP.ViewModel			= "models/weapons/v_models/v_pda_engineer.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_pda_engineer.mdl"

SWEP.HoldType = "PDA"
SWEP.IsPDA = true

SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

if CLIENT then

SWEP.PrintName			= "Demolish PDA"
SWEP.Slot				= 4
SWEP.Crosshair = "tf_crosshair6"

SWEP.CustomHUD = {HudEngyMenuDestroy = true}

end
