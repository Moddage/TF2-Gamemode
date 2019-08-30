	if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "Wrangler"
	SWEP.Slot				= 1	
	SWEP.RenderGroup 		= RENDERGROUP_BOTH
end

heavysandvichtaunt = { "vo/heavy_sandwichtaunt01.mp3", "vo/heavy_sandwichtaunt02.mp3", "vo/heavy_sandwichtaunt03.mp3", "vo/heavy_sandwichtaunt04.mp3", "vo/heavy_sandwichtaunt05.mp3", "vo/heavy_sandwichtaunt06.mp3", "vo/heavy_sandwichtaunt07.mp3", "vo/heavy_sandwichtaunt08.mp3", "vo/heavy_sandwichtaunt09.mp3", "vo/heavy_sandwichtaunt10.mp3", "vo/heavy_sandwichtaunt11.mp3", "vo/heavy_sandwichtaunt12.mp3", "vo/heavy_sandwichtaunt13.mp3", "vo/heavy_sandwichtaunt14.mp3", "vo/heavy_sandwichtaunt15.mp3", "vo/heavy_sandwichtaunt16.mp3", "vo/heavy_sandwichtaunt17.mp3" }	

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/v_models/v_pistol_engineer.mdl"
SWEP.WorldModel			= "models/weapons/c_models/c_wrangler.mdl"
SWEP.Crosshair = "tf_crosshair3"

SWEP.Swing = Sound("")
SWEP.SwingCrit = Sound("")
SWEP.HitFlesh = Sound("")
SWEP.HitWorld = Sound("")

SWEP.BaseDamage = 45
SWEP.DamageRandomize = 0.1
SWEP.MaxDamageRampUp = 0
SWEP.MaxDamageFalloff = 0

SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay          = 30
SWEP.Secondary.Automatic		= true
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Delay          = 30
SWEP.RangedMinHealing = 45
SWEP.RangedMaxHealing = 85

SWEP.HoldType = "ITEM1"
SWEP.HoldTypeHL2 = "pistol"
SWEP.NextFireRocket = 1
SWEP.NextFireBullets = 0
SWEP.NextOuch = 3

function SWEP:InspectAnimCheck()
	self:CallBaseFunction("InspectAnimCheck")
	self.VM_DRAW = ACT_ITEM1_VM_DRAW
	self.VM_IDLE = ACT_ITEM1_VM_IDLE
	self.VM_PRIMARYATTACK = ACT_ITEM1_VM_RELOAD
end

function SWEP:PrimaryAttack() 
	for k,v in pairs(ents.FindByClass("obj_sentrygun")) do
		if v:GetBuilder() == self.Owner then
			if not self.NextFireBullets or CurTime()>=self.NextFireBullets then
				v.TargetPos = self.Owner:GetEyeTrace().HitPos	
				if SERVER then
					if v:GetLevel() == 1 then
						v:RestartGesture(ACT_RANGE_ATTACK1, true)
						v.Model:RestartGesture(ACT_RANGE_ATTACK1, true)
					else
						v:RestartGesture(ACT_RANGE_ATTACK1_LOW, true)
						v.Model:RestartGesture(ACT_RANGE_ATTACK1_LOW, true)
					end
					local ok = v:TakeAmmo1(1)
					if ok then
						v:ShootBullets()
					else
						v:EmitSound(v.Sound_Empty)
						if not self.NextOuch or CurTime()>=self.NextOuch then	
							self.Owner:EmitSound("Weapon_Wrangler.Ouch")
							self.NextOuch = CurTime() + 3
						end	
					end
				end

				if v:GetLevel() >= 1 then
					self.NextFireBullets = CurTime() + 0.1
				else
					self.NextFireBullets = CurTime() + 0.3
				end
			end
		end
	end
end

function SWEP:Think()
	for k,v in pairs(ents.FindByClass("obj_sentrygun")) do
		if v:GetBuilder() == self.Owner then
			v.Target = nil
			if SERVER then
				v:SetPoseParameter("aim_pitch", -self.Owner:GetPoseParameter("body_pitch"))
				v:SetPoseParameter("aim_yaw", self.Owner:GetPoseParameter("body_yaw"))
				v.Model:SetPoseParameter("aim_pitch", -self.Owner:GetPoseParameter("body_pitch"))
				v.Model:SetPoseParameter("aim_yaw", self.Owner:GetPoseParameter("body_yaw"))
			end
		end
	end
	return self:CallBaseFunction("Think")
end
		
function SWEP:Holster()
	
	for k,v in pairs(ents.FindByClass("obj_sentrygun")) do
		if v:GetBuilder() == self.Owner then
			if v:GetLevel() == 1 then
				v.Shoot_Sound = Sound("Building_Sentrygun.Fire")
			elseif v:GetLevel() == 2 then
				v.Shoot_Sound = Sound("Building_Sentrygun.Fire2")
			elseif v:GetLevel() == 3 then
				v.Shoot_Sound = Sound("Building_Sentrygun.Fire3")
			end
			if SERVER then
				v.Wrangled = false
			end
		end
	end

	
	self.Owner:PrintMessage(HUD_PRINTCENTER, "Wrangler Disabled!")

	return self.BaseClass.Holster(self)

end

function SWEP:Deploy()
	self:CallBaseFunction("Deploy")
	for k,v in pairs(ents.FindByClass("obj_sentrygun")) do
		if v:GetBuilder() == self.Owner then
			if v:GetLevel() == 1 then
				v.Shoot_Sound = Sound("Building_Sentrygun.ShaftFire")
			elseif v:GetLevel() == 2 then
				v.Shoot_Sound = Sound("Building_Sentrygun.ShaftFire2")
			elseif v:GetLevel() == 3 then
				v.Shoot_Sound = Sound("Building_Sentrygun.ShaftFire3")
			end
			v.Wrangled = true 
			self.Owner:PrintMessage(HUD_PRINTCENTER, "Wrangler Enabled!")
		end
	end	
end 

function SWEP:SecondaryAttack()
	for k,v in pairs(ents.FindByClass("obj_sentrygun")) do
		if v:GetBuilder() == self.Owner then
			if not self.NextFireRocket or CurTime()>=self.NextFireRocket then
				v.TargetPos = self.Owner:GetEyeTrace().HitPos	
				if SERVER then
					local ok = v:TakeAmmo2(1)
					if ok then
						v:ShootRocket()
						self.NextFireRocket = CurTime() + 3	
						v:RestartGesture(ACT_RANGE_ATTACK2, true)
						v.Model:RestartGesture(ACT_RANGE_ATTACK2, true)
					else
						v:EmitSound(v.Sound_Empty)
						self.NextFireRocket = CurTime() + 0.25
						self:SendWeaponAnim(ACT_ITEM1_VM_IDLE_2)
					end
				end
			end
		end
	end
end