if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Base				= "tf_weapon_base"

SWEP.ViewModel			= "models/weapons/v_models/v_pda_spy.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_cigarette_case.mdl"

SWEP.HoldType = "PDA"

SWEP.IsPDA = true
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

if CLIENT then

SWEP.PrintName			= "Build PDA"
SWEP.Slot				= 3
SWEP.Crosshair = ""

end