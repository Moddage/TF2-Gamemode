if SERVER then

AddCSLuaFile("shared.lua")

end

if CLIENT then

SWEP.PrintName			= "Knife"
SWEP.Slot				= 2

function SWEP:ResetBackstabState()
	self.NextBackstabIdle = nil
	self.BackstabState = false
	self.NextAllowBackstabAnim = CurTime() + 0.8
end

end

SWEP.Base				= "tf_weapon_melee_base"

SWEP.ViewModel			= "models/weapons/v_models/v_knife_spy.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_knife.mdl"
SWEP.Crosshair = "tf_crosshair3"

SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Team Fortress 2"

SWEP.Swing = Sound("Weapon_Knife.Miss")
SWEP.SwingCrit = Sound("Weapon_Knife.MissCrit")
SWEP.HitFlesh = Sound("Weapon_Knife.HitFlesh")
SWEP.HitRobot = Sound("MVM_Weapon_Knife.HitFlesh")
SWEP.HitWorld = Sound("Weapon_Knife.HitWorld")

SWEP.BaseDamage = 40
SWEP.DamageRandomize = 0.35
SWEP.MaxDamageRampUp = 0
SWEP.MaxDamageFalloff = 0

SWEP.CriticalChance = 0

SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay = 0.8
SWEP.ReloadTime = 0.8
SWEP.HoldTypeHL2 = "knife"
SWEP.HasThirdpersonCritAnimation = true

SWEP.MeleePredictTolerancy = 0.1
SWEP.MeleeAttackDelay = 0
SWEP.BackstabAngle = 180
SWEP.ShouldOccurFists = true
-- ACT_MELEE_VM_STUN

function SWEP:Deploy()
	self:CallBaseFunction("Deploy")
end

function SWEP:ShouldBackstab(ent)
	if not ent then
		local tr = self:MeleeAttack(true)
		ent = tr.Entity
	end
	
	if not IsValid(ent) or not self.Owner:CanDamage(ent) or ent:Health()<=0 or not ent:CanReceiveCrits() or inspecting == true or inspecting_post == true then
		return false
	end
	
	if not self.BackstabCos then
		self.BackstabCos = math.cos(math.rad(self.BackstabAngle * 0.5))
	end
	
	local v1 = ent:GetPos() - self.Owner:GetPos()
	local v2 = ent:GetAngles():Forward()
	
	v1.z = 0
	v2.z = 0
	v1:Normalize()
	v2:Normalize()
	
	return v1:Dot(v2) > self.BackstabCos
end

function SWEP:Critical(ent,dmginfo)
	if self:ShouldBackstab(ent) then
		return true
	end
	
	return self:CallBaseFunction("Critical", ent, dmginfo)
end

function SWEP:OnMeleeHit(tr)
	if CLIENT then return end
	
	local ent = tr.Entity
	
	if self.ShouldBackstab and self:ShouldBackstab(ent) then
		if self:GetItemData().model_player == "models/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl" then
			if ent:IsPlayer() and !ent:IsHL2() and not ent:IsFriendly(self.Owner) and not ent:HasGodMode() then
				ent:SetMaterial("models/shadertest/predator")
				ent:GetRagdollEntity():SetMaterial("models/shadertest/predator")
				ent:TakeDamage(ent:Health() * 2, self.Owner, self)
				timer.Simple(0.2, function()
					self.Owner:SetModel(ent:GetModel())
					self.Owner:SetSkin(ent:GetSkin())
				end)
			end
		end
	end
end

function SWEP:PredictCriticalHit()
	if self:ShouldBackstab() then
		return true
	end
end

function SWEP:Think()
	self:CallBaseFunction("Think")
	if self.Owner:KeyDown(IN_ATTACK) or self.Owner:KeyDown(IN_ATTACK2) then
		if self.ShouldOccurFists == true then
			if SERVER then
				if self.Owner:GetPlayerClass() == "spy" and self.Owner:GetInfoNum("hahahahahahahahaowneronly_ragespy", 0) == 1 then
					self.Owner:EmitSound("vo/spy_paincrticialdeath0"..math.random(1,3)..".mp3", 80, math.random(80,130))
					self.ShouldOccurFists = false 
					self.Primary.Delay = 0.1					
					self.HitFlesh = Sound("NPC_AttackHelicopter.Crash")
					self.BaseDamage = 1000000000000000000000000000000000000000000000000
					timer.Simple(0.1, function()
						self.ShouldOccurFists = true
					end)
				end
			end
		end
	end
	if CLIENT and self.IsDeployed then
		if not self.NextAllowBackstabAnim or CurTime() >= self.NextAllowBackstabAnim then
			local shouldbackstab = self:ShouldBackstab()
			
			if shouldbackstab and not self.BackstabState then
				self:SendWeaponAnim(ACT_BACKSTAB_VM_UP)
				self.NextBackstabIdle = CurTime() + self:SequenceDuration()
			elseif not shouldbackstab and self.BackstabState then
				self:SendWeaponAnim(ACT_BACKSTAB_VM_DOWN)
				self.NextBackstabIdle = nil
			end
			self.BackstabState = shouldbackstab
			
			if self.NextBackstabIdle and CurTime()>=self.NextBackstabIdle then
				self:SendWeaponAnim(ACT_BACKSTAB_VM_IDLE)
				self.NextBackstabIdle = nil
			end
			
			self.NextAllowBackstabAnim = nil
		end
	end
end

function SWEP:Deploy()
	--MsgFN("Deploy %s", tostring(self))
	if self.Owner:GetPlayerClass() == "spy" then
		if self.Owner:GetModel() == "models/player/scout.mdl" or  self.Owner:GetModel() == "models/player/soldier.mdl" or  self.Owner:GetModel() == "models/player/pyro.mdl" or  self.Owner:GetModel() == "models/player/demo.mdl" or  self.Owner:GetModel() == "models/player/heavy.mdl" or  self.Owner:GetModel() == "models/player/engineer.mdl" or  self.Owner:GetModel() == "models/player/medic.mdl" or  self.Owner:GetModel() == "models/player/sniper.mdl" or  self.Owner:GetModel() == "models/player/hwm/spy.mdl" then
			
			animent2 = ents.Create( 'base_gmodentity' ) -- The entity used for the death animation	
			if self.Owner:GetModel() == "models/player/engineer.mdl" then
				animent2:SetModel("models/weapons/c_models/c_shotgun/c_shotgun.mdl")
			elseif self.Owner:GetModel() == "models/player/scout.mdl" then
				animent2:SetModel("models/weapons/c_models/c_scattergun.mdl")
			elseif self.Owner:GetModel() == "models/player/heavy.mdl" then
				animent2:SetModel("models/weapons/c_models/c_minigun/c_minigun.mdl")
			elseif self.Owner:GetModel() == "models/player/soldier.mdl" then
				animent2:SetModel("models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl")
			elseif self.Owner:GetModel() == "models/player/pyro.mdl" then
				animent2:SetModel("models/weapons/c_models/c_flamethrower/c_flamethrower.mdl")
			elseif self.Owner:GetModel() == "models/player/spy.mdl" then
				animent2:SetModel("models/weapons/w_models/w_knife.mdl")
			elseif self.Owner:GetModel() == "models/player/sniper.mdl" then
				animent2:SetModel("models/weapons/c_models/c_smg/c_smg.mdl")
			elseif self.Owner:GetModel() == "models/player/medic.mdl" then
				animent2:SetModel("models/weapons/c_models/c_medigun/c_medigun.mdl")
			elseif self.Owner:GetModel() == "models/player/demo.mdl" then
				animent2:SetModel("models/weapons/w_models/w_stickybomb_launcher.mdl")
			end
			animent2:SetAngles(self.Owner:GetAngles())
			animent2:SetPos(self.Owner:GetPos())
			animent2:Spawn() 
			animent2:Activate()
			animent2:SetParent(self.Owner)
			animent2:AddEffects(EF_BONEMERGE)
			animent2:SetName("SpyWeaponModel"..self.Owner:EntIndex())
			animent2:SetSkin(self.Owner:GetSkin())
			self:SetHoldType("PRIMARY")
			if SERVER then
				timer.Create("SpyCloakDetector"..self.Owner:EntIndex(), 0.01, 0, function()
					if self.Owner:GetPlayerClass() == "spy" then
						if self.Owner:GetNoDraw() == true then
							if IsValid(animent2) then
								animent2:SetNoDraw(true)
							end
						else
							if IsValid(animent2) then
								animent2:SetNoDraw(false)
							end
						end
					else
						timer.Stop("SpyCloakDetector"..self.Owner:EntIndex())
						return
					end
				end)
			end
		else
			if IsValid(animent2) then
				animent2:Remove()
			end
			self:SetHoldType("MELEE")
		end
	end
	return self:CallBaseFunction("Deploy")
end

function SWEP:Holster()
	self:StopTimers()
	if IsValid(self.Owner) then
		timer.Simple(0.1, function()
			if IsValid(self.CModel3) then
				self.CModel3:Remove()
			end
		end)
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
	if IsValid(animent2) then
		animent2:Fire("Kill", "", 0.1)
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

function SWEP:PrimaryAttack()
	if not self:CallBaseFunction("PrimaryAttack") then return false end
	
	self.NameOverride = nil
	
	if game.SinglePlayer() then
		self:CallOnClient("ResetBackstabState", "")
	elseif CLIENT then
		self:ResetBackstabState()
	end
end

if SERVER then

hook.Add("PreScaleDamage", "BackstabSetDamage", function(ent, hitgroup, dmginfo)
	local inf = dmginfo:GetInflictor()
	if ent:IsNPC() and ent:GetClass() == "npc_antlion" then
		ent:EmitSound("npc/antlion/shell_impact"..math.random(1,4)..".wav", 80, 100)
	elseif ent:IsNPC() and ent:GetClass() == "npc_antlionguard" then
		ent:EmitSound("npc/antlion/shell_impact"..math.random(1,4)..".wav", 80, 100)
	end
	if inf.ShouldBackstab and inf:ShouldBackstab(ent) and inf:GetClass() != "tf_weapon_knife_icicle" then
		inf.ResetBaseDamage = inf.BaseDamage
		if ent:IsPlayer() and ent:GetInfoNum("tf_hhh", 0) == 1 then
			inf.BaseDamage = 20
			inf.Owner:EmitSound("player/spy_shield_break.wav", 80, 100)
			timer.Simple(0.04, function()
				inf:SendWeaponAnimEx(ACT_MELEE_VM_STUN) 
				inf.Owner:GetViewModel():SetPlaybackRate(0.5)
				inf:SetNextPrimaryFire(CurTime() + 2)
			end) 
		elseif ent:IsPlayer() and ent:GetInfoNum("hahahahahahahahaowneronly_ragespy", 0) == 1 then
			inf.BaseDamage = 1
			inf.Owner:EmitSound("player/spy_shield_break.wav", 80, 100)
			ent:EmitSound("vo/test_two.mp3", 80, 100)
			timer.Simple(0.04, function()
				inf:SendWeaponAnimEx(ACT_MELEE_VM_STUN) 
				inf.Owner:GetViewModel():SetPlaybackRate(0.5)
				inf:SetNextPrimaryFire(CurTime() + 2)
			end)
		elseif ent:IsPlayer() and ent:GetInfoNum("tf_vagineer", 0) == 1 then
			inf.BaseDamage = 20
			inf.Owner:EmitSound("player/spy_shield_break.wav", 80, 100)
			timer.Simple(0.04, function()
				inf:SendWeaponAnimEx(ACT_MELEE_VM_STUN)
				inf.Owner:GetViewModel():SetPlaybackRate(0.5)
				inf:SetNextPrimaryFire(CurTime() + 2)
			end)
		elseif ent:IsPlayer() and ent:GetInfoNum("tf_giant_robot", 0) == 1 then
			inf.BaseDamage = 20
			inf.Owner:EmitSound("player/spy_shield_break.wav", 80, 100)
			timer.Simple(0.04, function()
				inf:SendWeaponAnimEx(ACT_MELEE_VM_STUN)
				inf.Owner:GetViewModel():SetPlaybackRate(0.5)
				inf:SetNextPrimaryFire(CurTime() + 2)
			end)
		elseif ent:IsPlayer() and ent:GetPlayerClass() == "giantpyro" then
			inf.BaseDamage = 20
			inf.Owner:EmitSound("player/spy_shield_break.wav", 80, 100)
			timer.Simple(0.04, function()
				inf:SendWeaponAnimEx(ACT_MELEE_VM_STUN)
				inf.Owner:GetViewModel():SetPlaybackRate(0.5)
				inf:SetNextPrimaryFire(CurTime() + 2)
			end)
		elseif ent:IsPlayer() and ent:GetPlayerClass() == "giantheavy" then
			inf.BaseDamage = 20
			inf.Owner:EmitSound("player/spy_shield_break.wav", 80, 100)
			timer.Simple(0.04, function()
				inf:SendWeaponAnimEx(ACT_MELEE_VM_STUN)
				inf.Owner:GetViewModel():SetPlaybackRate(0.5)
				inf:SetNextPrimaryFire(CurTime() + 2)
			end)
		elseif ent:IsPlayer() and ent:GetPlayerClass() == "giantdemoman" then
			inf.BaseDamage = 20
			inf.Owner:EmitSound("player/spy_shield_break.wav", 80, 100)
			timer.Simple(0.04, function()
				inf:SendWeaponAnimEx(ACT_MELEE_VM_STUN)
				inf.Owner:GetViewModel():SetPlaybackRate(0.5)
				inf:SetNextPrimaryFire(CurTime() + 2)
			end)
		elseif ent:IsPlayer() and ent:GetPlayerClass() == "giantsoldier" then
			inf.BaseDamage = 20
			inf.Owner:EmitSound("player/spy_shield_break.wav", 80, 100)
			timer.Simple(0.04, function()
				inf:SendWeaponAnimEx(ACT_MELEE_VM_STUN)
				inf.Owner:GetViewModel():SetPlaybackRate(0.5)
				inf:SetNextPrimaryFire(CurTime() + 2)
			end)
		elseif ent:IsPlayer() and ent:GetInfoNum("tf_sentrybuster", 0) == 1 then
			inf.BaseDamage = 20
			inf.Owner:EmitSound("player/spy_shield_break.wav", 80, 100)
			timer.Simple(0.04, function()
				inf:SendWeaponAnimEx(ACT_MELEE_VM_STUN)
				inf.Owner:GetViewModel():SetPlaybackRate(0.5)
				inf:SetNextPrimaryFire(CurTime() + 2)
			end)
		elseif ent:IsPlayer() and ent:GetInfoNum("tf_merasmus", 0) == 1 then
			inf.BaseDamage = 20
			inf.Owner:EmitSound("player/spy_shield_break.wav", 80, 100)
			timer.Simple(0.04, function()
				inf:SendWeaponAnimEx(ACT_MELEE_VM_STUN)
				inf.Owner:GetViewModel():SetPlaybackRate(0.5)
				inf:SetNextPrimaryFire(CurTime() + 2)
			end)
		elseif ent:IsPlayer() and ent:GetInfoNum("tf_giant_robot", 0) == 1 then
			inf.BaseDamage = 65
			timer.Simple(0.04, function()
				inf:SendWeaponAnimEx(ACT_MELEE_VM_STUN)
				inf.Owner:GetViewModel():SetPlaybackRate(0.5)
				inf:SetNextPrimaryFire(CurTime() + 2)
			end)
		elseif ent:IsNPC() and ent:GetClass() == "npc_antlionguard" then
			inf.BaseDamage = 25 * 1
			inf.Owner:EmitSound("physics/body/body_medium_break2.wav", 120, math.random(50,60))
			ent:EmitSound("npc/antlion_guard/antlion_guard_pain"..math.random(1,2)..".wav", 100, math.random(93, 102))
			inf.Owner:GetViewModel():SetPlaybackRate(1)
			timer.Simple(0.04, function()
				inf:SendWeaponAnimEx(ACT_MELEE_VM_STUN)	 	 
				inf:SetNextPrimaryFire(CurTime() + 2)
			end)
		else
			inf.BaseDamage = ent:Health() * 2
			ent:AddDeathFlag(DF_BACKSTAB)
		end
		inf.NameOverride = "tf_weapon_knife_backstab"
		dmginfo:SetDamage(inf.BaseDamage)
	end
end)

hook.Add("PostScaleDamage", "BackstabResetDamage", function(ent, hitgroup, dmginfo)
	local inf = dmginfo:GetInflictor()
	if inf:GetClass() == "tf_weapon_shotgun_imalreadywidowmaker" then
		
		inf.Owner:GiveTFAmmo(25, TF_METAL) 
		umsg.Start("PlayerMetalBonus", inf.Owner)
			umsg.Short(25)
		umsg.End()
	
	end
	if inf.ResetBaseDamage then
		inf.BaseDamage = inf.ResetBaseDamage
	end
end)

end
