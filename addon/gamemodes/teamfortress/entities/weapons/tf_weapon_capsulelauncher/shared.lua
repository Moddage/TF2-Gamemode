if SERVER then
	AddCSLuaFile( "shared.lua" )
	
end

if CLIENT then

SWEP.PrintName			= "Capsule Launcher"
SWEP.HasCModel = true
SWEP.Slot				= 0

function SWEP:InitializeCModel()
	self:CallBaseFunction("InitializeCModel")
	
	if IsValid(self.CModel) then
		self.CModel:SetBodygroup(1, 1)
	end
end

function SWEP:InitializeWModel2()
	self:CallBaseFunction("InitializeWModel2")
	
	--[[if IsValid(self.WModel2) then
		self.WModel2:SetBodygroup(1, 1)
	end]]
end

end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/c_models/c_demo_arms.mdl"
SWEP.WorldModel			= "models/weapons/c_models/c_capsulelauncher/c_capsulelauncher.mdl"
SWEP.Crosshair = "tf_crosshair3"

SWEP.MuzzleEffect = "muzzle_grenadelauncher"

SWEP.ShootSound = Sound("Weapon_GrenadeLauncher.Single")
SWEP.ShootCritSound = Sound("Weapon_GrenadeLauncher.SingleCrit")

SWEP.Primary.ClipSize		= 4
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_PRIMARY
SWEP.Primary.Delay          = 0.6
SWEP.ReloadTime = 0.6

SWEP.IsRapidFire = false
SWEP.ReloadSingle = true

SWEP.HoldType = "SECONDARY"

SWEP.ProjectileShootOffset = Vector(0, 7, -6)
SWEP.Force = 1100
SWEP.AddPitch = -4

SWEP.Properties = {}

function SWEP:ShootProjectile()
	if SERVER then
		local grenade = ents.Create("tf_projectile_capsule")
		grenade:SetPos(self:ProjectileShootPos())
		grenade:SetAngles(self.Owner:EyeAngles())
		
		if self:Critical() then
			grenade.critical = true
		end
		
		for k,v in pairs(self.Properties) do
			grenade[k] = v
		end
		
		grenade:SetOwner(self.Owner)
		
		self:InitProjectileAttributes(grenade)
		
		grenade.NameOverride = self:GetItemData().item_iconname
		grenade:Spawn()
		
		local vel = self.Owner:GetAimVector():Angle()
		vel.p = vel.p + self.AddPitch
		vel = vel:Forward() * self.Force * (grenade.Mass or 10)
		
		grenade:GetPhysicsObject():AddAngleVelocity(Vector(math.random(-2000,2000),math.random(-2000,2000),math.random(-2000,2000)))
		grenade:GetPhysicsObject():ApplyForceCenter(vel)
	end
	
	self:ShootEffects()
end
