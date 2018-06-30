-- Not for use with Sandbox gamemode, so we don't care about this
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

-- Viewmodel FOV should be constant, don't change this
SWEP.ViewModelFOV	= GetConVar( "viewmodel_fov" )
-- Ugly hack for the viewmodel resetting on draw
if GetConVar("tf_use_viewmodel_fov") then
	if GetConVar("tf_use_viewmodel_fov"):GetInt() >= 0 then
		SWEP.ViewModelFOV	= GetConVar( "viewmodel_fov_tf" ):GetInt()
	else
		SWEP.ViewModelFOV	= GetConVar( "viewmodel_fov" )
	end
end

SWEP.ViewModelFlip	= false
--eugh, another ugly hack.
if GetConVar("tf_righthand") then
	if GetConVar("tf_righthand"):GetInt() == 0 then
		SWEP.ViewModelFlip = true
	else
		SWEP.ViewModelFlip = false
	end
end


function SWEP:TFViewModelFOV()
	if GetConVar("tf_use_viewmodel_fov"):GetInt() > 0 then
		self.ViewModelFOV	= GetConVar( "viewmodel_fov_tf" ):GetInt()
	else
		self.ViewModelFOV	= GetConVar( "viewmodel_fov" )
	end
end

function SWEP:TFFlipViewmodel()
	if GetConVar("tf_righthand"):GetInt() > 0 then
		self.ViewModelFlip = false
	else
		self.ViewModelFlip = true
	end
end
-- View/World model
SWEP.ViewModel		= "models/weapons/v_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"

SWEP.IsTFWeapon = true

SWEP.HasTeamColouredVModel = true
SWEP.HasTeamColouredWModel = true

SWEP.Primary.ClipSize		= 8
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= TF_PRIMARY
SWEP.Primary.Delay          = 0
SWEP.Primary.QuickDelay     = -1
SWEP.Primary.NoFiringScene	= false

SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Delay        = 0.1
SWEP.Secondary.QuickDelay   = -1
SWEP.Secondary.NoFiringScene	= false

SWEP.m_WeaponDeploySpeed = 1.4
SWEP.DeployDuration = 0.8

SWEP.ReloadType = 0

SWEP.BulletsPerShot = 1
SWEP.BulletSpread = 0.00

SWEP.BaseDamage = 0
SWEP.DamageRandomize = 0
SWEP.MaxDamageRampUp = 0.2
SWEP.MaxDamageFalloff = 0.5
SWEP.DamageModifier = 1

SWEP.IsRapidFire = false
SWEP.CriticalChance = 2
SWEP.CritSpreadDuration = 2
SWEP.CritDamageMultiplier = 3

SWEP.HasSecondaryFire = false

SWEP.ProjectileShootOffset = Vector(0,0,0)

SWEP.CanInspect = true

SWEP.LastClass = "scout"

CreateClientConVar("viewmodel_fov_tf", "54", true, false)
CreateClientConVar("tf_use_viewmodel_fov", "1", true, false)
CreateClientConVar("tf_righthand", "1", true, true)

-- Initialize the weapon as a TF item
tf_item.InitializeAsBaseItem(SWEP)

include("shd_util.lua")
include("shd_anim.lua")
include("shd_sound.lua")
include("shd_crits.lua")

function SWEP:StopTimers()
	timer.Stop("StartInspection")
	timer.Stop("EndInspection")
	timer.Stop("PostInspection")
	inspecting = false
	inspecting_post = false
end

function SWEP:ProjectileShootPos()
	local pos, ang = self.Owner:GetShootPos(), self.Owner:EyeAngles()
	if self then
		if self.Owner:GetInfoNum("tf_righthand", 1) == 0 then
		return pos +
			self.ProjectileShootOffset.x * ang:Forward() - 
			self.ProjectileShootOffset.y * ang:Right() + 
			self.ProjectileShootOffset.z * ang:Up()
		else return pos +
			self.ProjectileShootOffset.x * ang:Forward() + 
			self.ProjectileShootOffset.y * ang:Right() + 
			self.ProjectileShootOffset.z * ang:Up()
		end
	end
end

function SWEP:Precache()
	if self.MuzzleEffect then
		PrecacheParticleSystem(self.MuzzleEffect)
	end
	
	if self.TracerEffect then
		PrecacheParticleSystem(self.TracerEffect.."_red")
		PrecacheParticleSystem(self.TracerEffect.."_blue")
		PrecacheParticleSystem(self.TracerEffect.."_red_crit")
		PrecacheParticleSystem(self.TracerEffect.."_blue_crit")
	end
end

function SWEP:PreCalculateDamage(ent)
	
end

function SWEP:PostCalculateDamage(dmg, ent)
	return dmg
end

function SWEP:CalculateDamage(hitpos, ent)
	return self:PostCalculateDamage(tf_util.CalculateDamage(self, hitpos), ent)
end

function SWEP:Equip()
	self.CurrentOwner = self.Owner
	
--	if not inspectMessage and self.Owner:IsPlayer() then
	--	self.Owner:ChatPrint("Press 'SHIFT' to Inspect!")
	--	inspectMessage = true
	--	timer.Simple(30, function() inspectMessage = false end)
--	end
	
	self:StopTimers()
	
	if SERVER then
		--MsgN(Format("Equip %s (owner:%s)",tostring(self),tostring(self:GetOwner())))
		
		--[[if IsValid(self.Owner) and self.Owner.WeaponItemIndex then
			self:SetItemIndex(self.Owner.WeaponItemIndex)
		end]]
		--MsgFN("Equip %s", tostring(self))
		
		if self.DeployedBeforeEquip then
			-- FIXED since gmod update 104, this does not seem to be called anymore
			
			-- Call the Deploy function again if the weapon is deployed before it has an owner attributed
			-- This happens when a player is given a weapon right after the ammo for that weapon has been stripped
			self:Deploy()
			self.DeployedBeforeEquip = nil
			--MsgN("Deployed before equip!")
		elseif _G.TFWeaponItemIndex then
			self:SetItemIndex(_G.TFWeaponItemIndex)
		end
		
		-- quickfix for deploy animations since gmod update 104
		self.NextReplayDeployAnim = CurTime() + 0.1
	end
end

function SWEP:Deploy()
	--MsgFN("Deploy %s", tostring(self))
	self:StopTimers()
	self.DeployPlayed = nil
	if self:GetItemData().hide_bodygroups_deployed_only then
		local visuals = self:GetVisuals()
		local owner = self.Owner
		
		if visuals.hide_player_bodygroup_names then
			for _,group in ipairs(visuals.hide_player_bodygroup_names) do
				local b = PlayerNamedBodygroups[owner:GetPlayerClass()]
				if b and b[group] then
					owner:SetBodygroup(b[group], 1)
				end
				
				b = PlayerNamedViewmodelBodygroups[owner:GetPlayerClass()]
				if b and b[group] then
					if IsValid(owner:GetViewModel()) then
						owner:GetViewModel():SetBodygroup(b[group], 1)
					end
				end
			end
		end
	end
	
	for k,v in pairs(self:GetVisuals()) do
		if k=="hide_player_bodygroup" then
			self.Owner:SetBodygroup(v,1)
		end
	end
	if GetConVar("tf_righthand") then
	if GetConVar("tf_righthand"):GetInt() == 0 then
		self.ViewModelFlip = true
	else
		self.ViewModelFlip = false
	end
	end

	if GetConVar("tf_use_viewmodel_fov"):GetInt() > 0 then
		self.ViewModelFOV	= GetConVar( "viewmodel_fov_tf" ):GetInt()
	else
		self.ViewModelFOV	= GetConVar( "viewmodel_fov" )
	end

	if SERVER then
		--MsgN(Format("Deploy %s (owner:%s)",tostring(self),tostring(self:GetOwner())))
		
		--[[if IsValid(self.Owner) and self.Owner.WeaponItemIndex then
			self:SetItemIndex(self.Owner.WeaponItemIndex)
		end]]
		
		if not IsValid(self.Owner) then
			--MsgFN("Deployed before equip %s",tostring(self))
			self.DeployedBeforeEquip = true
			self.NextReplayDeployAnim = nil
			--self:SendWeaponAnim(ACT_INVALID)
			return true
		end
		
		if _G.TFWeaponItemIndex then
			self:SetItemIndex(_G.TFWeaponItemIndex)
		end
		self:CheckUpdateItem()
		
		self.Owner.weaponmode = string.lower(self.HoldType)
		
		if self.HasTeamColouredWModel then
			if GAMEMODE:EntityTeam(self.Owner)==TEAM_BLU then
				self:SetSkin(1)
			else
				self:SetSkin(0)
			end
		else
			self:SetSkin(0)
		end
		
		self.Owner:ResetClassSpeed()
	end
	
	if CLIENT and not self.DoneFirstDeploy then
		self.RestartClientsideDeployAnim = true
		self.DoneFirstDeploy = true
	end
	
	--MsgFN("SendWeaponAnim %s %d", tostring(self), self.VM_DRAW)
	self:SendWeaponAnim(self.VM_DRAW)
	
	local draw_duration = self:SequenceDuration()
	local deploy_duration = self.DeployDuration
	
	if self.Owner.TempAttributes and self.Owner.TempAttributes.DeployTimeMultiplier then
		draw_duration = draw_duration * self.Owner.TempAttributes.DeployTimeMultiplier
		deploy_duration = deploy_duration * self.Owner.TempAttributes.DeployTimeMultiplier
	end
	
	self.NextIdle = CurTime() + draw_duration
	self.NextDeployed = CurTime() + deploy_duration
	
	if CLIENT and self.DeploySound and not self.DeployPlayed then
		self:EmitSound(self.DeploySound)
		self.DeployPlayed = true
	end
	
	--self.IsDeployed = false
	self:RollCritical()
	
	if self.Owner.ForgetLastWeapon then
		self.Owner.ForgetLastWeapon = nil
		return false
	end
	
	return true
end

function SWEP:InspectAnimCheck()

end

function SWEP:ResetInspect()

end

function SWEP:Inspect()
	self:InspectAnimCheck()

	if (self:GetOwner():GetMoveType()==MOVETYPE_NOCLIP) and GetConVar("tf_haltinspect"):GetBool() and self.CanInspect == true then
		//self.CanInspect = false
		//self:StopTimers()
		return false
	--[[else
		if self.Owner:OnGround() and self.IsDeployed and self.Reloading == false then
			self.CanInspect = true 
		end]]
	end
	
	//if self:GetSequenceActivity(self:GetSequence()) == self.VM_INSPECT_IDLE then

	if self.IsDeployed and self.CanInspect then
		if self.Owner ~= nil then
		if ( self:GetOwner():KeyPressed( IN_SPEED ) and inspecting == false and GetConVar("tf_caninspect"):GetBool() ) then
			inspecting = true
			self:SendWeaponAnim( self.VM_INSPECT_START )
			timer.Create("StartInspection", self:SequenceDuration(), 1,function()
				if self:GetOwner():KeyDown( IN_SPEED ) then 
					self:SendWeaponAnim( self.VM_INSPECT_IDLE )
					inspecting_idle = true
				else
					self:SendWeaponAnim( self.VM_INSPECT_END )
					inspecting_post = false
					inspecting = false
					timer.Create("PostInspection", self:SequenceDuration(), 1, function()
						if !self:GetOwner():KeyDown( IN_SPEED ) then
							self:SendWeaponAnim( self.VM_IDLE )
						end
					end )
				end
			end )
		end
		
		if ( self:GetOwner():KeyReleased( IN_SPEED ) and inspecting_idle == true and GetConVar("tf_caninspect"):GetBool() ) then
			self:SendWeaponAnim( self.VM_INSPECT_END )
			inspecting_post = false
			inspecting_idle = false
			inspecting = false 
			timer.Create("PostInspection", self:SequenceDuration(), 1, function()
				if !self:GetOwner():KeyDown( IN_SPEED ) then
					self:SendWeaponAnim( self.VM_IDLE )
				end
			end )
		end
		end
	end
end

--[[function SWEP:Inspect()
	self:InspectAnimCheck()
	
	if (self:GetOwner():GetMoveType()==MOVETYPE_NOCLIP) and inspecting == true and GetConVar("tf_haltinspect"):GetBool() or (self:GetOwner():GetMoveType()==MOVETYPE_NOCLIP) and inspecting_post == true and GetConVar("tf_haltinspect"):GetBool() then
		self:SendWeaponAnim( self.VM_IDLE )
		self:StopTimers()
		return false
	end

	if ( self:GetOwner():GetNWString("inspect") == "inspecting_start" and inspecting == false and GetConVar("tf_caninspect"):GetBool() ) then
		inspecting = true
		self:SendWeaponAnim( self.VM_INSPECT_START )
		timer.Create("StartInspection", self:SequenceDuration(), 1, function()self:SendWeaponAnim( self.VM_INSPECT_IDLE ) end )
	end
	
	if ( self:GetOwner():GetNWString("inspect") == "inspecting_released" and inspecting_post == false and GetConVar("tf_caninspect"):GetBool() ) then
		inspecting_post = true
		timer.Create("EndInspection", self:SequenceDuration(), 1, function()self:SendWeaponAnim( self.VM_INSPECT_END )
			timer.Create("PostInspection", self:SequenceDuration(), 1, function()
				self:SendWeaponAnim( self.VM_IDLE )
				inspecting_post = false
				inspecting = false 
			end )
		end)
	end
end]]

function SWEP:Holster()
	self:StopTimers()
	if IsValid(self.Owner) then
		if self:GetItemData().hide_bodygroups_deployed_only then
			local visuals = self:GetVisuals()
			local owner = self.Owner
			
			if visuals.hide_player_bodygroup_names then
				for _,group in ipairs(visuals.hide_player_bodygroup_names) do
					local b = PlayerNamedBodygroups[owner:GetPlayerClass()]
					if b and b[group] then
						owner:SetBodygroup(b[group], 0)
					end
					
					b = PlayerNamedViewmodelBodygroups[owner:GetPlayerClass()]
					if b and b[group] then
						if IsValid(owner:GetViewModel()) then
							owner:GetViewModel():SetBodygroup(b[group], 0)
						end
					end
				end
			end
		end
	
		for k,v in pairs(self:GetVisuals()) do
			if k=="hide_player_bodygroup" then
				self.Owner:SetBodygroup(v,0)
			end
		end
	end
	
	self.NextIdle = nil
	self.NextReloadStart = nil
	self.NextReload = nil
	self.Reloading = nil
	self.RequestedReload = nil
	self.NextDeployed = nil
	self.IsDeployed = nil
	
	if IsValid(self.Owner) then
		self.Owner.LastWeapon = self:GetClass()
	end
	
	return true
end

function SWEP:OwnerChanged()
	self:Holster()
end

function SWEP:OnRemove()
	self:StopTimers()
	--self:Holster()
end

function SWEP:CanPrimaryAttack()
	if (self.Primary.ClipSize == -1 and self:Ammo1() > 0) or self:Clip1() > 0 then
		return true
	end
	
	return false
end

function SWEP:CanSecondaryAttack()
	if (self.Secondary.ClipSize == -1 and self:Ammo2() > 0) or self:Clip2() > 0 then
		return true
	end
	
	return false
end

function SWEP:PrimaryAttack(noscene)
	if not self.IsDeployed then return false end
	//if self.Reloading then return false end
	
	self.NextDeployed = nil
	
	local Delay = self.Delay or -1
	local QuickDelay = self.QuickDelay or -1
	
	if (not(self.Primary.QuickDelay>=0 and self.Owner:KeyPressed(IN_ATTACK)) and Delay>=0 and CurTime()<Delay)
	or (self.Primary.QuickDelay>=0 and self.Owner:KeyPressed(IN_ATTACK) and QuickDelay>=0 and CurTime()<QuickDelay) then
		return
	end
	
	self.Delay =  CurTime() + self.Primary.Delay
	self.QuickDelay =  CurTime() + self.Primary.QuickDelay
	
	if not self:CanPrimaryAttack() then
		return
	end
	
	if self.NextReload or self.NextReloadStart then
		self.NextReload = nil
		self.NextReloadStart = nil
	end
	self:RustyBulletHole()
	if SERVER and not self.Primary.NoFiringScene and not noscene then
		self.Owner:Speak("TLK_FIREWEAPON", true)
	end
	--print(self.Base)
	self.NextIdle = nil
	
	return true
end

function SWEP:RustyBulletHole()
	--print(self.ProjectileShootOffset)
	if self.Base ~= "tf_weapon_melee_base" and self.GetClass ~= "tf_weapon_builder" and not self.IsPDA and self.ProjectileShootOffset == Vector(0,0,0) or self.ProjectileShootOffset == Vector(3,8,-5) and self.IsDeployed == true then
		self:ShootBullet(0, self.BulletsPerShot, self.BulletSpread)
	end
end

function SWEP:SecondaryAttack(noscene)
	if self.HasSecondaryFire then
		if not self.IsDeployed then return false end
		if not self:CanSecondaryAttack() or self.Reloading then return false end
		
		self.NextDeployed = nil
		
		local Delay = self.Delay or -1
		local QuickDelay = self.QuickDelay or -1
		
		if (not(self.Secondary.QuickDelay>=0 and self.Owner:KeyPressed(IN_ATTACK2)) and Delay>=0 and CurTime()<Delay)
		or (self.Secondary.QuickDelay>=0 and self.Owner:KeyPressed(IN_ATTACK2) and QuickDelay>=0 and CurTime()<QuickDelay) then
			return
		end
		
		if self.NextReload or self.NextReloadStart then
			self.NextReload = nil
			self.NextReloadStart = nil
		end
		
		self.Delay = CurTime() + self.Secondary.Delay
		self.QuickDelay = CurTime() + self.Secondary.QuickDelay
		
		if SERVER and not self.Secondary.NoFiringScene and not noscene then
			self.Owner:Speak("TLK_FIREWEAPON", true)
		end

		self.NextIdle = nil
		
		return true
	else
		for _,w in pairs(self.Owner:GetWeapons()) do
			if w.GlobalSecondaryAttack then
				w:GlobalSecondaryAttack()
			end
		end
		return false
	end
end

function SWEP:CheckAutoReload()
	if self.Primary.ClipSize >= 0 and self:Ammo1() > 0 and not self:CanPrimaryAttack() then
		--MsgFN("Deployed with empty clip, reloading")
		self:Reload()
	end
	
	if self then
		if self.Owner:GetInfoNum("tf_righthand", 1) == 0 then
			self:Reload()
		end
	end
end

function SWEP:Reload()
	self:StopTimers()
	if CLIENT and _G.NOCLIENTRELOAD then return end
	
	if self.NextReloadStart or self.NextReload or self.Reloading then return end
	
	if self.RequestedReload then
		if self.Delay and CurTime() < self.Delay then
			return false
		end
	else
		--MsgN("Requested reload!")
		self.RequestedReload = true
		return false
	end
	
	self.CanInspect = false
	
	--MsgN("Reload!")
	self.RequestedReload = false
	
	if self.Primary and self.Primary.Ammo and self.Primary.ClipSize ~= -1 then
		local available = self.Owner:GetAmmoCount(self.Primary.Ammo)
		local ammo = self:Clip1()
		
		if ammo < self.Primary.ClipSize and available > 0 then
			self.NextIdle = nil
			if self.ReloadSingle then
				--self:SendWeaponAnim(ACT_RELOAD_START)
				self:SendWeaponAnimEx(self.VM_RELOAD_START)
				self.Owner:SetAnimation(PLAYER_RELOAD) -- reload start
				self.NextReloadStart = CurTime() + (self.ReloadStartTime or self:SequenceDuration())
			else
				self:SendWeaponAnimEx(self.VM_RELOAD)
				self.Owner:SetAnimation(PLAYER_RELOAD)
				self.NextIdle = CurTime() + (self.ReloadTime or self:SequenceDuration())
				self.NextReload = self.NextIdle
				
				self.AmmoAdded = math.min(self.Primary.ClipSize - ammo, available)
				self.Reloading = true
				
				if self.ReloadSound and SERVER then
					umsg.Start("PlayTFWeaponWorldReload")
						umsg.Entity(self)
					umsg.End()
				end
				
				--self.reload_cur_start = CurTime()
			end
			--self:SetNextPrimaryFire( CurTime() + ( self.Primary.Delay || 0.25 ) + 1.4 )
			--self:SetNextSecondaryFire( CurTime() + ( self.Primary.Delay || 0.25 ) + 1.4 )
			return true
		end
	end
end

function SWEP:Think()
	self:TFViewModelFOV()
	self:TFFlipViewmodel()
	//deployspeed = math.Round(GetConVar("tf_weapon_deploy_speed"):GetFloat() - GetConVar("tf_weapon_deploy_speed"):GetInt(), 2)
	//deployspeed = math.Round(GetConVar("tf_weapon_deploy_speed"):GetFloat(),2)
	
	if SERVER and self.NextReplayDeployAnim then
		if CurTime() > self.NextReplayDeployAnim then
			--MsgFN("Replaying deploy animation %d", self.VM_DRAW)
			timer.Simple(0.1, function() self:SendWeaponAnim(self.VM_DRAW) end)
			self.NextReplayDeployAnim = nil
		end
	end
	
	if not game.SinglePlayer() or SERVER then
		if self.NextIdle and CurTime()>=self.NextIdle then
			self:SendWeaponAnim(self.VM_IDLE)
			self.NextIdle = nil
		end
		
		if self.RequestedReload then
			self:Reload()
		end
	end
	
	if not self.IsDeployed and self.NextDeployed and CurTime()>=self.NextDeployed then
		self.IsDeployed = true
		self.CanInspect = true
		self:CheckAutoReload()
	end
	
	if self.IsDeployed then
		self.CanInspect = true
	end
			
	//print(deployspeed)
	
	if self.NextReload and CurTime()>=self.NextReload then
		self:SetClip1(self:Clip1() + self.AmmoAdded)
		
		if not self.ReloadSingle and self.ReloadDiscardClip then
			self.Owner:RemoveAmmo(self.Primary.ClipSize, self.Primary.Ammo, false)
		else
			self.Owner:RemoveAmmo(self.AmmoAdded, self.Primary.Ammo, false)
		end
		
		self.Delay = -1
		self.QuickDelay = -1
		
		if self:Clip1()>=self.Primary.ClipSize or self.Owner:GetAmmoCount(self.Primary.Ammo)==0 then
			-- Stop reloading
			self.Reloading = false
			self.CanInspect = true
			if self.ReloadSingle then
				--self:SendWeaponAnim(ACT_RELOAD_FINISH)
				self:SendWeaponAnim(self.VM_RELOAD_FINISH)
				self.CanInspect = true
				--self.Owner:SetAnimation(10001) -- reload finish
				self.Owner:DoAnimationEvent(ACT_MP_RELOAD_STAND_END, true)
				self.NextIdle = CurTime() + self:SequenceDuration()
			else
				self:SendWeaponAnim(self.VM_IDLE)
				self.NextIdle = nil
			end
			self.NextReload = nil
		else
			self:SendWeaponAnim(self.VM_RELOAD)
			--self.Owner:SetAnimation(10000)
			self.Owner:DoAnimationEvent(ACT_MP_RELOAD_STAND_LOOP, true)
			self.NextReload = CurTime() + (self.ReloadTime or self:SequenceDuration())
				
			if self.ReloadSound and SERVER then
				umsg.Start("PlayTFWeaponWorldReload")
					umsg.Entity(self)
				umsg.End()
			end
			
		end
	end
	
	if self.NextReloadStart and CurTime()>=self.NextReloadStart then
		self:SendWeaponAnim(self.VM_RELOAD)
		--self.Owner:SetAnimation(10000) -- reload loop
		self.Owner:DoAnimationEvent(ACT_MP_RELOAD_STAND_LOOP, true)
		self.NextReload = CurTime() + (self.ReloadTime or self:SequenceDuration())
		
		self.AmmoAdded = 1
		
		if self.ReloadSound and SERVER then
			umsg.Start("PlayTFWeaponWorldReload")
				umsg.Entity(self)
			umsg.End()
		end
		
		self.NextReloadStart = nil
	end
	
	self:Inspect()
end

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType or "PRIMARY")
end
