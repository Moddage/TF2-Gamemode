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
SWEP.ReloadTime = 0.5
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
CreateClientConVar("tf_sprintinspect", "0", true, true)
CreateClientConVar("tf_reloadinspect", "1", true, true)
CreateClientConVar("tf_use_min_viewmodels", "0", true, false)

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

function SWEP:CalcViewModelView(vm, oldpos, oldang, newpos, newang)
	if not self.VMMinOffset and self:GetItemData() then
		local data = self:GetItemData()
		if data.static_attrs and data.static_attrs.min_viewmodel_offset then
			self.VMMinOffset = Vector(data.static_attrs.min_viewmodel_offset)
		end
	end

	if GetConVar("tf_use_min_viewmodels"):GetBool() then -- TODO: Check for inspecting
		newpos = newpos + (newang:Forward() * self.VMMinOffset.x)
		newpos = newpos + (newang:Right() * self.VMMinOffset.y)
		newpos = newpos + (newang:Up() * self.VMMinOffset.z)
	end

	return newpos, newang
end


hook.Add("EntityRemoved", "TFWeaponRemoved", function(ent)
	if ent.IsTFWeapon then
		if IsValid(ent.WModel2) then ent.WModel2:Remove() end
		if IsValid(ent.AttachedWModel) then ent.AttachedWModel:Remove() end
	end
end)


function SWEP:DrawWorldModel(from_postplayerdraw)
	--self:CheckUpdateItem()
	--self:SetNoDraw(true)
	
	-- this function is now called from PostPlayerDraw, don't do anything if it isn't
	if IsValid(self.WModel2) and not from_postplayerdraw then
		return
	end
	
	if not gamemode.Call("ShouldDrawWorldModel", self.Owner) then
		return
	end
	
	self:StartVisualOverrides()
	
	self.DrawingViewModel = false
	--if self.WorldModel and self.WorldModel~="" then
	if SERVER and self:GetClass() != "tf_weapon_robo_arm" then
		if IsValid(self.WModel2) then
			self.WModel2:SetSkin(self.WeaponSkin or 0)
			self.WModel2:SetMaterial(self.WeaponMaterial or 0)
		end
		if IsValid(self.AttachedWModel) then
			self.AttachedWModel:SetSkin(self.WeaponSkin or 0)
			self.AttachedWModel:SetMaterial(self.WeaponMaterial or 0)
		end
		--self:SetSkin(self.WeaponSkin or 0)
	end
	--end
	
	--[[
	for _,v in pairs(self.Owner:GetWeapons()) do
		if v~=self and v.PermanentWorldModel then
			v:DrawWorldModel(from_postplayerdraw)
		end
	end
	]]
	
	self:EndVisualOverrides()
	--render.SetBlend(0)	-- Rendering the world model also re-renders the player
	
	self:ModelDrawn(false)
end


-- Instead of using using DrawWorldModel to render the world model, do it here (at least it guarantees that it will be always drawn if the player is visible)
-- any potential problem with this?
hook.Add("PostPlayerDraw", "ForceDrawTFWorldModel", function(pl)
	if pl.RenderingWorldModel then
		render.SetBlend(1)
		return
	end
	
	if IsValid(pl:GetActiveWeapon()) and IsValid(pl:GetActiveWeapon().WModel2) then
		pl.RenderingWorldModel = true
		pl:GetActiveWeapon():DrawWorldModel(true)
		pl.RenderingWorldModel = false
	end
end)

function SWEP:InitializeWModel2()
--Msg("InitializeWModel2\n")
	if SERVER then
		if self:GetItemData().model_player then
			if IsValid(self.WModel2) then
				self.WModel2:SetModel(self:GetItemData().model_player)
			else
				self.WModel2 = ents.Create( 'base_gmodentity' )
				if not IsValid(self.WModel2) then return end
					
				self.WModel2:SetPos(self.Owner:GetPos())
				self.WModel2:SetModel(self:GetItemData().model_player)
				self.WModel2:SetAngles(self.Owner:GetAngles())
				self.WModel2:AddEffects(bit.bor(EF_BONEMERGE, EF_BONEMERGE))
				self.WModel2:SetParent(self.Owner)
				self.WModel2:SetColor(Color(255, 255, 255))
				self.WModel2:DrawShadow( false )
					
				if wmodel == "models/weapons/w_models/w_shotgun.mdl" then
					self.WModel2:SetMaterial("models/weapons/w_shotgun_tf/w_shotgun_tf")
				end
			end
			
			if IsValid(self.WModel2) then
				self.WModel2.Player = self.Owner
				self.WModel2.Weapon = self
					
				if self.MaterialOverride then
					self.WModel2:SetMaterial(self.MaterialOverride)
				end
			end
		end
	end
end

function SWEP:InitializeAttachedModels()
--Msg("InitializeAttachedModels\n")
	if SERVER then
		if IsValid(self.AttachedWModel) then
			if self.AttachedWorldModel then
				self.AttachedWModel:SetModel(self.AttachedWorldModel)
			else
				self.AttachedWModel:Remove()
			end
		elseif self.AttachedWorldModel then
			local ent = (IsValid(self.WModel2) and self.WModel2) or self
			
			self.AttachedWModel = ents.Create( 'base_gmodentity' )
			self.AttachedWModel:SetPos(ent:GetPos())
			self.AttachedWModel:SetModel(self:GetItemData().model_player)
			self.AttachedWModel:SetAngles(ent:GetAngles())
			self.AttachedWModel:AddEffects(EF_BONEMERGE)
			self.AttachedWModel:SetParent(ent)
		end
		
		if IsValid(self.AttachedWModel) then
			self.AttachedWModel.Player = self.Owner
			self.AttachedWModel.Weapon = self
			
			if self.MaterialOverride then
				self.AttachedWModel:SetMaterial(self.MaterialOverride)
			end
		end
	end
end

function SWEP:Deploy()
	--MsgFN("Deploy %s", tostring(self))
	for k, v in pairs(player.GetAll()) do
		if v == self.Owner then		
			if v:IsHL2() then 
				self:SetHoldType(self.HoldTypeHL2)
				if self.DeploySound then
					self:EmitSound(self.DeploySound)
				end
			else
				self:SetHoldType(self.HoldType)
			end
		end
	end	
	self:InitializeWModel2()
	self:InitializeAttachedModels()
	if SERVER then
		if IsValid(self.WModel2) then
			self.WModel2:SetSkin(self.WeaponSkin or self.Owner:GetSkin())
			self.WModel2:SetMaterial(self.WeaponMaterial or 0)
		end
	end
	if self.Owner:IsPlayer() and not self.Owner:IsHL2() and self.Owner:Team() == TEAM_BLU and string.find(game.GetMap(), "mvm_") then
		if SERVER then
			self.Owner:SetBloodColor(BLOOD_COLOR_MECH)
		end
	end
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
	if GetConVar("tf_righthand") and not self:GetClass() == "tf_weapon_compound_bow" then
	if GetConVar("tf_righthand"):GetInt() == 0	then
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
	
	local draw_duration = self:SequenceDuration() - 0.5
	local deploy_duration = self.DeployDuration - 0.5 
	
	if self.Owner.TempAttributes and self.Owner.TempAttributes.DeployTimeMultiplier then
		draw_duration = draw_duration * self.Owner.TempAttributes.DeployTimeMultiplier
		deploy_duration = deploy_duration * self.Owner.TempAttributes.DeployTimeMultiplier
	end
	
	self.NextIdle = CurTime() + draw_duration
	self.NextDeployed = CurTime() + deploy_duration
	--[[
	if CLIENT and self.DeploySound and not self.DeployPlayed then
		self:EmitSound(self.DeploySound)
		self.DeployPlayed = true
	end]]
	
	--self.IsDeployed = false
	self:RollCritical()
	timer.Simple(0.2, function()
		if IsValid(self) then
			if IsValid(self.Owner) then
				if IsValid(self.Owner:GetViewModel()) then  
					self.Owner:GetViewModel():SetPlaybackRate(1.2)
				end
			end
		end
	end)
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
		if ( self:GetOwner():KeyPressed( IN_SPEED ) and inspecting == false and GetConVar("tf_caninspect"):GetBool() and self.Owner:GetInfoNum("tf_sprintinspect", 1) == 1 ) then
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
		
		if ( self:GetOwner():KeyReleased( IN_SPEED ) and inspecting_idle == true and GetConVar("tf_caninspect"):GetBool() and self.Owner:GetInfoNum("tf_sprintinspect", 1) == 1 ) then
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

		if ( self:GetOwner():KeyPressed( IN_RELOAD ) and ((self.Base ~= "tf_weapon_melee_base" and self:Clip1() == self:GetMaxClip1()) or self.Base == "tf_weapon_melee_base") and inspecting == false and GetConVar("tf_caninspect"):GetBool() and self.Owner:GetInfoNum("tf_reloadinspect", 1) == 1 ) then
			inspecting = true
			self:SendWeaponAnim( self.VM_INSPECT_START )
			timer.Create("StartInspection", self:SequenceDuration(), 1, function()
				if self:GetOwner():KeyDown( IN_RELOAD ) then 
					self:SendWeaponAnim( self.VM_INSPECT_IDLE )
					inspecting_idle = true
				else
					self:SendWeaponAnim( self.VM_INSPECT_END )
					inspecting_post = false
					inspecting = false
					timer.Create("PostInspection", self:SequenceDuration(), 1, function()
						if !self:GetOwner():KeyDown( IN_RELOAD ) then
							self:SendWeaponAnim( self.VM_IDLE )
						end
					end )
				end
			end )
		end
		
		if ( self:GetOwner():KeyReleased( IN_RELOAD ) and inspecting_idle == true and GetConVar("tf_caninspect"):GetBool() and self.Owner:GetInfoNum("tf_reloadinspect", 1) == 1 ) then
			self:SendWeaponAnim( self.VM_INSPECT_END )
			inspecting_post = false
			inspecting_idle = false
			inspecting = false 
			timer.Create("PostInspection", self:SequenceDuration(), 1, function()
				if !self:GetOwner():KeyDown( IN_RELOAD ) then
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
	if SERVER then
		if IsValid(self.WModel2) then
			self.WModel2:Remove()
		end
	end
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
	if (self.Primary.ClipSize == -1 and self:Ammo1() > 0 and self.Owner:GetNWBool("Bonked") == false) or self:Clip1() > 0 then
		return true
	end
	
	if (self.Owner:GetNWBool("Bonked") != false) then
		return false
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
	if self.Owner:GetMaterial() == "models/shadertest/predator" then return false end
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
		--self:ShootBullet(0, self.BulletsPerShot, self.BulletSpread)
		self:FireBullets({Num = self.BulletsPerShot, Src = self.Owner:GetShootPos(), Dir = self.Owner:GetAimVector(), Spread = Vector(self.BulletSpread, self.BulletSpread, 0), Tracer = 0, Force = 0, Damage = 0, AmmoType = ""})
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
	if self then
		if self.Owner:GetInfoNum("tf_autoreload", 1) == 1 then
			if self.Owner:Alive() then
				if self.Primary.ClipSize >= 0 and self:Ammo1() > 0 and not self:CanPrimaryAttack() then
				--MsgFN("Deployed with empty clip, reloading")
					self:Reload()
				end
	

				self:Reload()
			end
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
				self.Owner:SetAnimation(PLAYER_RELOAD) -- reload start
				if self.ReloadTime == 1.1 then 
					self:SendWeaponAnimEx(self.VM_RELOAD_START)
					self.NextReloadStart = CurTime() + (self.ReloadStartTime or self:SequenceDuration() + 0.5)

					self.Owner:GetViewModel():SetPlaybackRate(0.6)
				else
					self:SendWeaponAnimEx(self.VM_RELOAD_START)
					self.NextReloadStart = CurTime() + (self.ReloadStartTime or self:SequenceDuration())
				end
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
				if self.ReloadTime == 0.71 then 
					self.Owner:GetViewModel():SetPlaybackRate(1.51)
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
	if self:GetClass() != "tf_weapon_robo_arm" and self:GetClass() != "tf_weapon_trenchknife" and self:GetClass() != "tf_weapon_capsulelauncher" and self:GetClass() != "tf_weapon_tranqulizer" and self:GetClass() != "tf_weapon_pistol_m9"  and self:GetClass() != "tf_weapon_wrench_vagineer" then
		if self.Owner:GetNWBool("NoWeapon") == true then 
			if SERVER then
				self.WModel2:SetNoDraw(true)
			end
		else
			if SERVER then
				self.WModel2:SetNoDraw(false)
			end
		end
	end
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
				if self:GetHoldType() == "PRIMARY" and self.Owner:GetPlayerClass() == "engineer" or self.Owner:GetPlayerClass() == "scout" or self.Owner:GetPlayerClass() == "demoman" then
					self.Owner:DoAnimationEvent(ACT_SMG2_DRAW2, true)
				elseif self:GetHoldType() == "PRIMARY" and self.Owner:GetPlayerClass() != "engineer" then
					self.Owner:DoAnimationEvent(ACT_SMG2_IDLE2, true)
				elseif self:GetHoldType() == "SECONDARY" and self.Owner:GetPlayerClass() == "heavy" or self.Owner:GetPlayerClass() == "pyro" or self.Owner:GetPlayerClass() == "demoman" then 
					self.Owner:DoAnimationEvent(ACT_SMG2_RELOAD2, true)	
				elseif self:GetHoldType() == "SECONDARY" and self.Owner:GetPlayerClass() != "heavy"  then
					self.Owner:DoAnimationEvent(ACT_SMG2_FIRE2, true)				
				end
				self.NextIdle = CurTime() + self:SequenceDuration()
			else
				self:SendWeaponAnim(self.VM_IDLE)
				self.NextIdle = nil
			end
			self.NextReload = nil
		else
			self:SendWeaponAnim(self.VM_RELOAD)
			--self.Owner:SetAnimation(10000)	
			if SERVER then	
			self.Owner:DoAnimationEvent(ACT_MP_RELOAD_STAND_LOOP, true)
			end
			if self.ReloadTime == 0.2 then
				self.Owner:GetViewModel():SetPlaybackRate(2)
			end
			if self.ReloadTime == 1.1 then 
				if self:GetItemData().model_player == "models/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl" then
					if CLIENT then
						self.Owner:EmitSound("Weapon_DumpsterRocket.Reload")
					end
				end
				self.Owner:GetViewModel():SetPlaybackRate(0.7)
			end
			self.NextReload = CurTime() + (self.ReloadTime)
				
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
		if SERVER then	
			self.Owner:DoAnimationEvent(ACT_MP_RELOAD_STAND_LOOP, true)
		end
		if self.ReloadTime == 0.2 then
			self.Owner:GetViewModel():SetPlaybackRate(2)
		end
		if self.ReloadTime == 1.1 then 
			if self:GetItemData().model_player == "models/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl" then
				if CLIENT then
					self.Owner:EmitSound("Weapon_DumpsterRocket.Reload")
				end
			end
			self.Owner:GetViewModel():SetPlaybackRate(0.7)
		end
		self.NextReload = CurTime() + (self.ReloadTime)
		
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
	self:SetWeaponHoldType(self.HoldType)
end
