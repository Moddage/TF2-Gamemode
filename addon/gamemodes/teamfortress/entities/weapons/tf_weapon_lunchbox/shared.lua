	if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "Sandvich"
SWEP.Slot				= 1
end

heavysandwichtaunt = { "scenes/player/heavy/low/sandwichtaunt01.vcd", "scenes/player/heavy/low/sandwichtaunt02.vcd", "scenes/player/heavy/low/sandwichtaunt03.vcd", "scenes/player/heavy/low/sandwichtaunt04.vcd", "scenes/player/heavy/low/sandwichtaunt05.vcd", "scenes/player/heavy/low/sandwichtaunt06.vcd",  "scenes/player/heavy/low/sandwichtaunt07.vcd", "scenes/player/heavy/low/sandwichtaunt08.vcd", "scenes/player/heavy/low/sandwichtaunt09.vcd", "scenes/player/heavy/low/sandwichtaunt10.vcd", "scenes/player/heavy/low/sandwichtaunt11.vcd", "scenes/player/heavy/low/sandwichtaunt12.vcd", "scenes/player/heavy/low/sandwichtaunt13.vcd", "scenes/player/heavy/low/sandwichtaunt14.vcd", "scenes/player/heavy/low/sandwichtaunt15.vcd", "scenes/player/heavy/low/sandwichtaunt16.vcd", "scenes/player/heavy/low/sandwichtaunt01.vcd", "scenes/player/heavy/low/sandwichtaunt17.vcd" }	

SWEP.Base				= "tf_weapon_base"

SWEP.ViewModel			= "models/weapons/c_models/c_heavy_arms.mdl"
SWEP.WorldModel			= "models/weapons/c_models/c_sandwich/c_sandwich.mdl"
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

SWEP.Force = 80
SWEP.AddPitch = -4
SWEP.HoldType = "ITEM1"

function SWEP:InspectAnimCheck()
	self:CallBaseFunction("InspectAnimCheck")
	self.VM_DRAW = ACT_ITEM1_VM_DRAW
	self.VM_IDLE = ACT_ITEM1_VM_IDLE
	self.VM_PRIMARYATTACK = ACT_ITEM1_VM_RELOAD	
	self.VM_INSPECT_START = ACT_ITEM1_VM_INSPECT_START
	self.VM_INSPECT_IDLE = ACT_ITEM1_VM_INSPECT_IDLE
	self.VM_INSPECT_END = ACT_ITEM1_VM_INSPECT_END
end

function SWEP:PrimaryAttack()
	if self.Owner:Health() <= self.Owner:GetMaxHealth() then
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	else
		self:SetNextPrimaryFire( CurTime() + 5 )
	end
	net.Start("ActivateTauntCam")
	if SERVER then
	net.Send(self.Owner)
	end
	self.Owner:DoAnimationEvent(ACT_DOD_CROUCH_IDLE_PISTOL, true)
	self.Owner:SetNWBool("Taunting", true)
	
	if CLIENT then
		timer.Simple(1, function()	
			self.CModel:SetBodygroup(0, 1)
		end)
	end
	if SERVER then
	timer.Simple(1, function()
		self.WModel2:SetBodygroup(0, 1)
		if self.Owner:GetInfoNum("tf_giant_robot",0) == 1 then
			return
		elseif self.Owner:GetInfoNum("tf_robot",0) == 1 then
			return
		else
			self.Owner:EmitSound("Heavy.SandwichEat")
			GAMEMODE:HealPlayer(self.Owner, self.Owner, 50, true, false)
		end
	end)
	timer.Simple(2, function()
		GAMEMODE:HealPlayer(self.Owner, self.Owner, 50, true, false)
	end)
	timer.Simple(3, function()
		GAMEMODE:HealPlayer(self.Owner, self.Owner, 50, true, false)
	end)
	timer.Simple(4, function()
		GAMEMODE:HealPlayer(self.Owner, self.Owner, 50, true, false)
		net.Start("DeActivateTauntCam")
		net.Send(self.Owner)
		self.Owner:SetNWBool("Taunting", false)
		self.Owner:SelectWeapon(self.Owner:GetWeapons()[1])
	end)
	timer.Simple(5, function()
		if self.Owner:GetInfoNum("tf_giant_robot",0) == 1 then
			self.Owner:EmitSound("vo/mvm/mght/heavy_mvm_m_sandwichtaunt"..math.random(10,17)..".mp3", 80, 100)
		elseif self.Owner:GetInfoNum("tf_robot",0) == 1 then
			self.Owner:EmitSound("vo/mvm/norm/heavy_mvm_sandwichtaunt"..math.random(10,17)..".mp3", 80, 100)
		else
			self.Owner:PlayScene(table.Random(heavysandwichtaunt))
		end
	end)
	end
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire( CurTime() + 20 )
	if SERVER then
		local healthkit = ents.Create("item_healthkit_small")
		healthkit:SetPos(self.Owner:GetEyeTrace().StartPos)
		healthkit.RespawnTime = -1
		healthkit:Spawn()  
		if self:GetItemData().model_player == "models/workshop/weapons/c_models/c_chocolate/c_chocolate.mdl" or self:GetItemData().model_player == "models/weapons/c_models/c_chocolate/c_chocolate.mdl" then
			healthkit:SetModel("models/workshop/weapons/c_models/c_chocolate/plate_chocolate.mdl")	
		elseif self:GetItemData().model_player == "models/workshop/weapons/c_models/c_chocolate/c_chocolate.mdl" or self:GetItemData().model_player == "models/weapons/c_models/c_chocolate/c_chocolate.mdl" then
			healthkit:SetModel("models/items/banana/plate_banana.mdl")
		elseif self:GetItemData().model_player == "models/weapons/c_models/c_sandwich/c_robo_sandwich.mdl" then
			healthkit:SetModel("models/items/plate_robo_sandwich.mdl")
		else
			healthkit:SetModel("models/items/plate.mdl")
		end
		local vel = self.Owner:GetAimVector():Angle()
		vel.p = vel.p + self.AddPitch
		vel = vel:Forward() * self.Force * 10
		
		healthkit:GetPhysicsObject():AddAngleVelocity(Vector(math.random(-2000,2000),math.random(-2000,2000),math.random(-2000,2000)))
		healthkit:GetPhysicsObject():ApplyForceCenter(vel)
		healthkit.HealthPercentage = 40.5
		healthkit:DropWithGravity(vel)
		self.Owner:SelectWeapon(self.Owner:GetWeapons()[1])
	end
end



function SWEP:Inspect()
	self:InspectAnimCheck()

	if (self.Owner:GetMoveType()==MOVETYPE_NOCLIP) and GetConVar("tf_haltinspect"):GetBool() and self.CanInspect == true then
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
			if ( self.Owner:KeyPressed( IN_SPEED ) and inspecting == false and self.Owner:GetInfoNum("tf_reloadinspect", 1) == 9 ) then
				inspecting = true
				self:SendWeaponAnim( ACT_ITEM1_VM_INSPECT_START )
				timer.Create("StartInspection", self:SequenceDuration(), 1, function()
					if self.Owner:KeyDown( IN_SPEED ) then 
						self:SendWeaponAnim( ACT_ITEM1_VM_INSPECT_IDLE )
						inspecting_idle = true
					else
						self:SendWeaponAnim( ACT_ITEM1_VM_INSPECT_END )
						inspecting_post = false
						inspecting = false
						timer.Create("PostInspection", self:SequenceDuration(), 1, function()
							if !self.Owner:KeyDown( IN_SPEED ) then
								self:SendWeaponAnim( ACT_ITEM1_VM_INSPECT_IDLE  )
							end
						end )
					end
				end )
			end
			
			if ( self.Owner:KeyReleased( IN_SPEED ) and inspecting_idle == true and GetConVar("tf_caninspect"):GetBool() and self.Owner:GetInfoNum("tf_reloadinspect", 1) == 0 ) then
				self:SendWeaponAnim( ACT_ITEM1_VM_INSPECT_END )
				inspecting_post = false
				inspecting_idle = false
				inspecting = false 
				timer.Create("PostInspection", self:SequenceDuration(), 1, function()
					if !self.Owner:KeyDown( IN_SPEED ) then
						self:SendWeaponAnim( ACT_ITEM1_VM_INSPECT_IDLE  )
					end
				end )
			end

		if ( self.Owner:KeyPressed( IN_RELOAD ) and inspecting == false and self.Owner:GetInfoNum("tf_reloadinspect", 1) == 1 ) then
			inspecting = true
			self:SendWeaponAnim( ACT_ITEM1_VM_INSPECT_START )
			timer.Create("StartInspection", self:SequenceDuration(), 1, function()
				if self.Owner:KeyDown( IN_RELOAD ) then 
					self:SendWeaponAnim( ACT_ITEM1_VM_INSPECT_IDLE )
					inspecting_idle = true
				else
					self:SendWeaponAnim( ACT_ITEM1_VM_INSPECT_END )
					inspecting_post = false
					inspecting = false
					timer.Create("PostInspection", self:SequenceDuration(), 1, function()
						if !self.Owner:KeyDown( IN_RELOAD ) then
							self:SendWeaponAnim( ACT_ITEM1_VM_INSPECT_IDLE  )
						end
					end )
				end
			end )
		end
		
		if ( self.Owner:KeyReleased( IN_RELOAD ) and inspecting_idle == true and GetConVar("tf_caninspect"):GetBool() and self.Owner:GetInfoNum("tf_reloadinspect", 1) == 1 ) then
			self:SendWeaponAnim( ACT_ITEM1_VM_INSPECT_END )
			inspecting_post = false
			inspecting_idle = false
			inspecting = false 
			timer.Create("PostInspection", self:SequenceDuration(), 1, function()
				if !self.Owner:KeyDown( IN_RELOAD ) then
					self:SendWeaponAnim( ACT_ITEM1_VM_INSPECT_IDLE  )
				end
			end )
		end
		end
	end
end	