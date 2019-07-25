if SERVER then

AddCSLuaFile("shared.lua")

CreateConVar("tf_unlimited_buildings", 0, {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_CHEAT})

end

if CLIENT then

SWEP.GlobalCustomHUD = {HudBuildingStatus = true}

end

SWEP.Base				= "tf_weapon_base"

SWEP.ViewModel			= "models/weapons/v_models/v_toolbox_engineer.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_toolbox.mdl"

SWEP.HoldType = "BUILDING"

SWEP.Primary.Delay		= 0.1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.Delay		= 0.1
SWEP.Secondary.Automatic	= false
SWEP.HasSecondaryFire = true

SWEP.DeployDuration = 0.1

function SWEP:SetupDataTables()
	self:CallBaseFunction("SetupDataTables")
	self:DTVar("Int", 1, "BuildGroup")
	self:DTVar("Int", 2, "BuildMode")
end

function SWEP:GetBuildGroup()
	return self.dt.BuildGroup
end

function SWEP:GetBuildMode()
	return self.dt.BuildMode
end

function SWEP:GetBuilding()
	local group, mode = self.dt.BuildGroup, self.dt.BuildMode
	if self then
		if self.Owner then
			if self.Owner.Buildings then
				if self.Owner.Buildings[group] and self.Owner.Buildings[group][mode] then
					return self.Owner.Buildings[group][mode]
				end
			end
		end
	end
end

function SWEP:SetupBuilding(obj)
	if obj.v_model and obj.w_model then
		self.ViewModelOverride = obj.v_model
		self.ViewModel = self.ViewModelOverride
		self:SetModel(self.ViewModelOverride)
		if IsValid(self.Owner:GetViewModel()) then
			self.Owner:GetViewModel():SetModel(self.ViewModelOverride)
		end
		self.WorldModelOverride = obj.w_model
		
		if CLIENT then
			self.WorldModelOverride2 = obj.w_model
			
			if IsValid(self.WModel2) then
				if self.WModel2:GetModel() == self.WorldModelOverride then
					return
				else
					self.WModel2:Remove()
					self.WModel2 = nil
				end
			end
			
			self:InitializeWModel2()

			self.HasCModel = false
			if IsValid(self.CModel) then
				self.CModel:Remove()
			end
		end
		
		self:SetupCModelActivities(nil, true)
	end
end

function SWEP:CheckUpdateItem()
	self:CallBaseFunction("CheckUpdateItem")
	
	if self.dt.BuildGroup ~= self.CurrentBuildGroup or self.dt.BuildMode ~= self.CurrentBuildMode then
		local obj = tf_objects.Get(self.dt.BuildGroup, self.dt.BuildMode)
		if obj then
			self:SetupBuilding(obj)
		end
		self.CurrentBuildGroup = self.dt.BuildGroup
		self.CurrentBuildMode = self.dt.BuildMode
	end
end

function SWEP:Equip()
	if SERVER then
		--print("Equip building", self.Owner)
		--PrintTable(self.Owner.Buildings)
		
		local group, mode = self.dt.BuildGroup, self.dt.BuildMode
		if not self.Owner.Buildings[group] or not self.Owner.Buildings[group][mode] then
			--print("Not a valid building, changing current building mode")
			for group=0,tf_objects.NumObjects()-1 do
				if self.Owner.Buildings[group] then
					self.dt.BuildGroup = group
					self.dt.BuildMode = 0
					break
				end
			end
		end
		
		--print("group",self.dt.BuildGroup,"mode",self.dt.BuildMode)
	end
	
	return self:CallBaseFunction("Equip")
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return true
end

function SWEP:PrimaryAttack()
	
	if SERVER then
		if IsValid(self.Blueprint) then
			local ammo = self.Owner:GetAmmoCount(TF_METAL)
			if self:GetBuilding().cost > ammo then
				return
			end
			
			if self.Blueprint:Build() then
				self.Owner.objtype = self:GetBuilding().objtype
				self.Owner:Speak("TLK_BUILDING_OBJECT")
				
				self.Owner:RemoveAmmo(self:GetBuilding().cost, TF_METAL)
				umsg.Start("PlayerMetalBonus", self.Owner)
					umsg.Short(-self:GetBuilding().cost)
				umsg.End()
				
				-- temp
				self.Owner.ForgetLastWeapon = true
				self.Owner:SelectWeapon(self.LastWeapon)
			end
		end
	end
	
	return true
end

function SWEP:SecondaryAttack()
	if not self:CallBaseFunction("SecondaryAttack") then return false end
	
	if SERVER then
		if IsValid(self.Blueprint) then
			self.Blueprint:RotateBlueprint()
		end
	end
	
	return true
end

function SWEP:Reload()
end

if SERVER then

function SWEP:SetBuilding(group, mode)
	if self.Owner.Buildings[group] and self.Owner.Buildings[group][mode] then
		local cost = self.Owner.Buildings[group][mode].cost
		if self.Owner:GetAmmoCount(TF_METAL) < cost then
			return false
		end
		
		self.dt.BuildGroup = group
		self.dt.BuildMode = mode
		return true
	end
end

local old_group_translate = {
	[0] = {0,0},
	[1] = {1,0},
	[2] = {1,1},
	[3] = {2,0},
	[4] = {3,0},
}

local builds = {}
builds[2] = "obj_sentrygun"
builds[0] = "obj_dispenser"
builds[1] = "obj_teleporter"

concommand.Add("destroy", function(pl, cmd, args)
	local group = tonumber(args[1])
	local sub = tonumber(args[2])
	
	local builder = pl:GetWeapon("tf_weapon_builder")
	
	if not IsValid(builder) then return end
	if not group then return end
	
	if not sub then
		if not old_group_translate[group] then return end
		
		group, sub = unpack(old_group_translate[group])
	end
	
	if builds[group] then
		local tab = ents.FindByClass(builds[group])
		for k, v in pairs(tab) do
			if v.Player == pl and builds[group] ~= "obj_teleporter" then
				v:Explode()
			elseif v.Player == pl and builds[group] == "obj_teleporter" then
				for i, o in pairs(tab) do
					if (sub == 0 and v:IsEntrance() and o:IsEntrance()) or (sub == 1 and v:IsExit() and o:IsExit()) then
						v:Explode()
					end
				end
			end
		end
	end
	
	local current = pl:GetActiveWeapon()
	if current.IsPDA then
		local last = pl:GetWeapon(pl.LastWeapon)
		if not IsValid(last) or last.IsPDA then
			last = pl:GetWeapons()[1]
		end
		builder.LastWeapon = last:GetClass()
		pl:SelectWeapon(last:GetClass())
	else
		builder.LastWeapon = current:GetClass()
	end
end)

concommand.Add("build", function(pl, cmd, args)
	local group = tonumber(args[1])
	local sub = tonumber(args[2])
	
	local builder = pl:GetWeapon("tf_weapon_builder")
	
	if not IsValid(builder) then return end
	if not group then return end
	
	if not sub then
		if not old_group_translate[group] then return end
		
		group, sub = unpack(old_group_translate[group])
	end
	
	if builds[group] and (!GetConVar("tf_unlimited_buildings"):GetBool() or GetConVar("tf_competitive"):GetBool()) then
		local tab = ents.FindByClass(builds[group])
		for k, v in pairs(tab) do
			if v.Player == pl and builds[group] ~= "obj_teleporter" then
				return
			elseif v.Player == pl and builds[group] == "obj_teleporter" then
				for i, o in pairs(tab) do
					if (sub == 0 and v:IsEntrance() and o:IsEntrance()) or (sub == 1 and v:IsExit() and o:IsExit()) then
						return
					end
				end
			end
		end
	end
	
	local current = pl:GetActiveWeapon()
	if builder:SetBuilding(group, sub) and current ~= builder then
		if current.IsPDA then
			local last = pl:GetWeapon(pl.LastWeapon)
			if not IsValid(last) or last.IsPDA then
				last = pl:GetWeapons()[1]
			end
			builder.LastWeapon = last:GetClass()
			pl:SelectWeapon(last:GetClass())
		else
			builder.LastWeapon = current:GetClass()
		end
		pl:SelectWeapon("tf_weapon_builder")
	end
end)

function SWEP:Deploy()
	local result = self:CallBaseFunction("Deploy")
	
	if SERVER then
		if IsValid(self.Blueprint) then
			self.Blueprint:Remove()
		end
		self.Blueprint = ents.Create("tf_obj_blueprint")
		self.Blueprint:SetOwner(self)
		self.Blueprint:Spawn()
		
		if self:GetBuildGroup() == 2 and self.Owner.TempAttributes.BuildsMiniSentries then
			self.Blueprint.dt.Scale = 0.75
		elseif self:GetBuildGroup() == 2 and self.Owner.TempAttributes.BuildsMegaSentries then
			self.Blueprint.dt.Scale = 1.2
		end
	end
	
	return result
end

function SWEP:Holster()
	if self:CallBaseFunction("Holster") == false then return false end
	
	if SERVER then
		if IsValid(self.Blueprint) then
			self.Blueprint:Remove()
		end
	end
	
	return true
end

end

if CLIENT then

SWEP.PrintName			= "Builder"
SWEP.Slot				= 1
SWEP.Crosshair = "tf_crosshair6"

function SWEP:InitializeBuildings(buildings)
	-- Change the slot of the weapon depending on which buildings are available
	for _,group in pairs(buildings) do
		for _,obj in pairs(group) do
			self.Slot = obj.slot
			self.Hidden = obj.hidden
		end
	end
	
	self.BuildingsInitialized = true
	HudWeaponSelection:UpdateLoadout()
end

hook.Add("Think", "TFBuilderInitialize", function()
	for _,v in pairs(ents.FindByClass("tf_weapon_builder")) do
		if not v.BuildingsInitialized and IsValid(v.Owner) and v.Owner:IsPlayer() then
			if v.Owner.BuilderInit then
				v:InitializeBuildings(v.Owner.BuilderInit)
				v.Owner.BuilderInit = nil
			end
		end
	end
end)

end
