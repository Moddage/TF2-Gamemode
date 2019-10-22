if SERVER then
	AddCSLuaFile( "shared.lua" )
	
end

if CLIENT then

SWEP.PrintName			= "Sniper Rifle"
SWEP.Slot				= 0

usermessage.Hook("ClearZoomStatus",function(msg)
	local pl = msg:ReadEntity()
	
	if IsValid(pl) and pl:IsPlayer() then
		pl.TargetZoom = 1
		if pl==LocalPlayer() then
			HudSniperChargeMeter:SetVisible(false)
		end
	end
end)

usermessage.Hook("SetZoomStatus",function(msg)
	local self = msg:ReadEntity()
	local b = msg:ReadBool()
	self.ZoomStatus = b
	if b and IsValid(self.Owner) then
		self.Owner.TargetZoom = 3 * (self.ZoomMultiplier or 1)
		if self.Owner==LocalPlayer() then
			HudSniperChargeMeter:SetVisible(true)
			if self.DisableSniperCharge then
				HudSniperChargeMeter:SetProgress(-1)	-- hide the charge meter
			else
				HudSniperChargeMeter:SetProgress(0)
			end
		end
		self.ChargeTimerStart = CurTime()
		self.Time0 = 0
		self.Rate = 1
		self.DrawCrosshair = false
	else
		if self and IsValid(self.Owner) then
			self.Owner.TargetZoom = 1
			if self.Owner==LocalPlayer() then
				HudSniperChargeMeter:SetVisible(false)
			end
		end
		
		self.ChargeTimerStart = nil
		self.DrawCrosshair = true
	end
end)

usermessage.Hook("SynchronizeSniperCharge", function(msg)
	local self = msg:ReadEntity()
	if not IsValid(self) then return end
	
	self.Time0 = self.Time0 + (CurTime() - self.ChargeTimerStart) * self.Rate
	if self.Time0==0 then return end
	self.Rate = msg:ReadFloat() / self.Time0
	self.ChargeTimerStart = CurTime()
end)

function SWEP:TranslateFOV(fov)
	if self.Owner.TargetZoom and not self.DisableSniperCharge then
		if not self.Owner.CurrentZoom then self.Owner.CurrentZoom = 1 end
		self.Owner.CurrentZoom = Lerp(0.5, self.Owner.CurrentZoom, self.Owner.TargetZoom)
		return fov / self.Owner.CurrentZoom
	else
		return fov
	end
end

local W = ScrW()
local H = ScrH()
local Scale = H/480

local sniperdot_red = surface.GetTextureID("effects/sniperdot_red")
local sniperdot_blue = surface.GetTextureID("effects/sniperdot_blue")

function SWEP:DrawHUD()
	if self.ChargeTimerStart then
		local charge
		
		if self.DisableSniperCharge then
			charge = 0
		else
			charge = self.Time0 + (CurTime() - self.ChargeTimerStart) * self.Rate
			local chargetime = self.ChargeTime / (self.SniperChargeRateMultiplier or 1)
			
			charge = math.Clamp(100*charge/chargetime, 0, 100)
			HudSniperChargeMeter:SetProgress(charge)
		end
		
		local tex
		if self.Owner:EntityTeam()==TEAM_BLU then
			tex = sniperdot_blue
		else
			tex = sniperdot_red
		end
		
		local tr = util.TraceLine{
			start=self.Owner:GetShootPos(),
			endpos=self.Owner:GetShootPos()+10000*self.Owner:GetAimVector(),
			filter=self.Owner,
			mask=MASK_SHOT,
		}
		local dist = tr.Fraction * 10000
		
		local s = math.floor(math.Clamp(2000*Scale/(dist+1), 4*Scale, 24*Scale))
		
		surface.SetDrawColor(255,255,255,100)
		surface.SetTexture(tex)
		
		local cx, cy = math.floor(W/2), math.floor(H/2)
		
		surface.DrawTexturedRect(cx - s, cy - s, 2*s, 2*s)
		s = math.floor(Lerp(charge*0.01, 0.2, 1) * s)
		
		if s>0 then
			surface.SetDrawColor(255,255,255,255)
			surface.DrawTexturedRect(cx - s, cy - s, 2*s, 2*s)
		end
	end
end
--[[
function SWEP:ModelDrawn(v)
	if self.ZoomStatus then
		local start = self.Owner:GetShootPos()
		local endpos = start + 10000*self.Owner:GetAimVector()
		local tr = util.TraceLine{
			start=start,
			endpos=endpos,
			filter=self.Owner,
		}
		
		if tr.Hit and not tr.HitSky then
			
		end
	end
end]]

end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/v_models/v_sniperrifle_sniper.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_sniperrifle.mdl"
SWEP.Crosshair = "tf_crosshair2"

SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Team Fortress 2"

SWEP.MuzzleEffect = "muzzle_sniperrifle"

SWEP.ShootSound = Sound("weapons/sniper_shoot.wav")
SWEP.ShootCritSound = Sound("Weapon_SniperRifle.SingleCrit")
SWEP.ReloadSound = Sound("Weapon_SniperRifle.WorldReload")

SWEP.TracerEffect = "bullet_tracer01"
PrecacheParticleSystem("muzzle_sniperrifle")
PrecacheParticleSystem("bullet_tracer01_red")
PrecacheParticleSystem("bullet_tracer01_red_crit")
PrecacheParticleSystem("bullet_tracer01_blue")
PrecacheParticleSystem("bullet_tracer01_blue_crit")

SWEP.MinDamage = 50
SWEP.MaxDamage = 150
SWEP.DamageRandomize = 0.14
SWEP.MaxDamageRampUp = 0
SWEP.MaxDamageFalloff = 0

SWEP.CriticalChance = 0
SWEP.CritsOnHeadshot = true
SWEP.HeadshotName = "tf_weapon_sniperrifle_headshot"

SWEP.BulletsPerShot = 1
SWEP.BulletSpread = 0

SWEP.Primary.ClipSize		= -1
SWEP.Primary.Ammo			= TF_PRIMARY
SWEP.Primary.Delay          = 1.5

SWEP.IsRapidFire = false
SWEP.ReloadSingle = false

SWEP.HoldType = "PRIMARY"

SWEP.HoldTypeHL2 = "smg"

SWEP.ProjectileShootOffset = Vector(3, 8, -5)
SWEP.ChargeTime = 4

SWEP.PredictCritServerside = true

function SWEP:ZoomIn()
	if CLIENT then return end
	
	self.NextAutoZoomIn = nil
	if not self.ZoomStatus then
		self.LaserDot:Enable()
		self.ZoomStatus = true
		umsg.Start("SetZoomStatus")
			umsg.Entity(self)
			umsg.Bool(true)
		umsg.End()
		self.Owner:DoAnimationEvent(ACT_MP_DEPLOYED, true)
		
		--self.Owner:DrawViewModel(false)
		self.ChargeTimerStart = CurTime()
	end
	
	if not self.DisableZoomSpeedPenalty then
		self.Owner:SetClassSpeed(27 * (self.DeployMoveSpeedMultiplier or 1))
		self.Owner:SetCrouchedWalkSpeed(0.33)
	end
	
end

function SWEP:AdjustMouseSensitivity()
	if self.ZoomStatus then
		return 0.35
	end
end

function SWEP:ZoomOut()
	if CLIENT then return end
	
	self.NextAutoZoomOut = nil
	if self.ZoomStatus then
		self.LaserDot:Disable()
		self.ZoomStatus = false
		umsg.Start("SetZoomStatus")
			umsg.Entity(self)
			umsg.Bool(false)
		umsg.End()
		self.Owner:DoAnimationEvent(ACT_MP_STAND_PRIMARY, true)
		
		--self.Owner:DrawViewModel(true)
		self.ChargeTimerStart = nil
	end
	
	if not self.DisableZoomSpeedPenalty then
		local owner = self.CurrentOwner or self.Owner
		owner:ResetClassSpeed()
	end
end

function SWEP:ToggleZoom()
	if self.ZoomStatus then self:ZoomOut()
	else self:ZoomIn()
	end
end

function SWEP:PrimaryAttack()
	if not self.IsDeployed then return false end


	if self.NextIdle then return end
	
	if not self:CanPrimaryAttack() then
		return
	end
	
	--self.Owner:DrawViewModel(true)
	
	self:SendWeaponAnim(self.VM_PRIMARYATTACK)
	if self.ZoomStatus then
		self.Owner:DoAnimationEvent(ACT_MP_ATTACK_STAND_PRIMARY_DEPLOYED, true)
	else
		self.Owner:SetAnimation(PLAYER_ATTACK1)
	end
	
	self.NextAllowZoom = CurTime() + self:SequenceDuration()
	if self.ZoomStatus then self.NextAutoZoomIn = CurTime()+self:SequenceDuration() end
	
	if self.WeaponMode == 1 then
		self.CritsOnHeadshot = false
	else
		self.CritsOnHeadshot = self.ZoomStatus
	end
	
	self:RollCritical()
	if self.ChargeTimerStart and not self.DisableSniperCharge then
		local chargetime = self.ChargeTime / (self.SniperChargeRateMultiplier or 1)
		self.BaseDamage = Lerp(math.Clamp((CurTime()-self.ChargeTimerStart)/chargetime, 0, 1), self.MinDamage, self.MaxDamage)
	else
		self.BaseDamage = self.MinDamage
	end
	--print(self.BaseDamage)
	self:ShootProjectile(self.BulletsPerShot, self.BulletSpread)
	self:TakePrimaryAmmo(1)
	self:RustyBulletHole()
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	if SERVER then
		self.NextAutoZoomOut = CurTime()+0.6
	end
	
	self.NextIdle = CurTime()+self:SequenceDuration()
	self.AmmoAdded = 1
end

function SWEP:SecondaryAttack()
	if not self.IsDeployed then return false end
	
	if SERVER then
		if (not self.NextAllowZoom or CurTime()>self.NextAllowZoom) and self.Owner:IsOnGround() then
			self:ToggleZoom()
			self.NextAllowZoom = CurTime() + 0.4
		elseif self.NextAutoZoomIn then -- No, don't zoom me in automatically after that
			self.NextAutoZoomIn = nil
		end
	end
end

function SWEP:UpdateLaserDotPosition(dot)
	local tr = util.TraceLine{
		start=self.Owner:GetShootPos(),
		endpos=self.Owner:GetShootPos()+10000*self.Owner:GetAimVector(),
		filter=self.Owner,
		mask=MASK_SHOT,
	}
	
	if tr.Hit then
		dot:SetNoDraw(false)
		dot:SetPos(tr.HitPos - 2*self.Owner:GetAimVector())
		dot:SetHitEntity(tr.Entity)
	else
		dot:SetNoDraw(true)
		dot:SetHitEntity(NULL)
	end
end

function SWEP:Think()
	self:TFViewModelFOV()
	
	if self:GetItemData().model_player == "models/workshop/weapons/c_models/c_bazaar_sniper/c_bazaar_sniper.mdl" then
		self.ShootSound = "Weapon_Bazaar_Bargain.Single"
		self.ShootCritSound = "Weapon_Bazaar_Bargain.SingleCrit"
	end
	
	for k, v in pairs(player.GetAll()) do
		if v == self.Owner then
			if v:IsHL2() then
				if self.ZoomStatus then
					self:SetHoldType( "rpg" )
				else
					self:SetHoldType( "smg" )
				end
			end
		end
	end

	if SERVER and self.NextReplayDeployAnim then
		if CurTime() > self.NextReplayDeployAnim then
			--MsgFN("Replaying deploy animation %d", self.VM_DRAW)
			timer.Simple(0.1, function() self:SendWeaponAnim(self.VM_DRAW) end)
			self.NextReplayDeployAnim = nil
		end
	end
	
	if SERVER then
		if not self.LastOwner then
			self.LastOwner = self.Owner
		end
		
		if not IsValid(self.LaserDot) then
			self.LaserDot = ents.Create("sniper_dot")
			self.LaserDot:SetPos(self:GetPos())
			self.LaserDot:SetOwner(self)
			self.LaserDot:Spawn()
		end
		
		if self.ChargeTimerStart and (not self.NextClientChargeUpdate or CurTime()>self.NextClientChargeUpdate) then
			umsg.Start("SynchronizeSniperCharge")
				umsg.Entity(self)
				umsg.Float(CurTime() - self.ChargeTimerStart)
			umsg.End()
			self.NextClientChargeUpdate = CurTime() + 0.1
		end
		
		if self.ZoomStatus and not self.Owner:IsOnGround() then
			self:ZoomOut()
			self.NextAllowZoom = CurTime() + 0.4
		end
	end
	
	if not self.IsDeployed and self.NextDeployed and CurTime()>=self.NextDeployed then
		self.IsDeployed = true
	end
	
	if self.NextIdle and CurTime()>=self.NextIdle then
		self:SendWeaponAnim(self.VM_IDLE)
		self.NextIdle = nil
	end
	
	if self.NextAutoZoomOut and CurTime()>=self.NextAutoZoomOut then
		self:ZoomOut()
	end
	
	if self.NextAutoZoomIn and CurTime()>=self.NextAutoZoomIn then
		self:ZoomIn()
	end
	
	self:Inspect()
end

function SWEP:Holster()
	if SERVER then
		umsg.Start("ClearZoomStatus")
			umsg.Entity(self.LastOwner)
		umsg.End()
		
		self.NextAutoZoomIn = nil
	end
	
	self:ZoomOut()
	
	return self:CallBaseFunction("Holster")
end

function SWEP:OnRemove()
	self:Holster()
end



if SERVER then

hook.Add("PreScaleDamage", "BackstabSetDamage2", function(ent, hitgroup, dmginfo)
	if dmginfo:GetInflictor().ZoomStatus then	
		ent:AddDeathFlag(DF_HEADSHOT)
	end
end)

end
