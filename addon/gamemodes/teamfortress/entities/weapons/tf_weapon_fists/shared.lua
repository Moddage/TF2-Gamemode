if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "Fists"
	SWEP.Slot				= 2
end

SWEP.Base				= "tf_weapon_melee_base"

SWEP.ViewModel			= "models/weapons/v_models/v_fist_heavy.mdl"
SWEP.WorldModel			= ""
SWEP.Crosshair = "tf_crosshair3"

SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Team Fortress 2"

SWEP.Swing = Sound("Weapon_Fist.Miss")
SWEP.SwingCrit = Sound("Weapon_Fist.MissCrit")
SWEP.HitFlesh = Sound("Weapon_Fist.HitFlesh")
SWEP.HitWorld = Sound("Weapon_Fist.HitWorld")

SWEP.CritEnabled = Sound("Weapon_BoxingGloves.CritEnabled")
SWEP.CritHit = Sound("Weapon_BoxingGloves.CritHit")

SWEP.DropPrimaryWeaponInstead = true

SWEP.BaseDamage = 65
SWEP.DamageRandomize = 0.1
SWEP.MaxDamageRampUp = 0
SWEP.MaxDamageFalloff = 0

SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay = 0.8
SWEP.ReloadTime = 0.8

SWEP.Secondary.Automatic		= true
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Delay          = 0.8

SWEP.CritForceAddPitch = 45

SWEP.HoldType = "MELEE"
SWEP.HoldTypeHL2 = "fist"
SWEP.HasThirdpersonCritAnimation = true
SWEP.HasSecondaryFire = true
SWEP.UsesLeftRightAnim = true

SWEP.ShouldOccurFists = true

function SWEP:OnCritBoostStarted()
	self.Owner:EmitSound(self.CritEnabled)
end

function SWEP:OnCritBoostAdded()
	self.Owner:EmitSound(self.CritHit)
end

function SWEP:Deploy() 
	if self:GetItemData().model_player == "models/weapons/c_models/c_breadmonster_gloves/c_breadmonster_gloves.mdl" then
	self.Owner:EmitSound("Weapon_bm_gloves.draw")
	end
	if self:GetItemData().image_inventory == "backpack/weapons/v_models/v_fist_heavy" then
		self.VM_IDLE = ACT_FISTS_VM_IDLE
		self.VM_DRAW = ACT_FISTS_VM_DRAW
		self.VM_HITLEFT = ACT_FISTS_VM_HITLEFT
		self.VM_HITRIGHT = ACT_FISTS_VM_HITRIGHT
		self.VM_SWINGHARD = ACT_FISTS_VM_SWINGHARD
	end
	self.BaseClass.Deploy(self) 
end

function SWEP:Think() 
	self:CallBaseFunction("Think")
	if self:GetItemData().model_player == "models/weapons/c_models/c_breadmonster_gloves/c_breadmonster_gloves.mdl" then
		self.VM_IDLE = ACT_BREADGLOVES_VM_IDLE
		self.VM_DRAW = ACT_BREADGLOVES_VM_DRAW
		self.VM_HITLEFT = ACT_BREADGLOVES_VM_HITLEFT
		self.VM_HITRIGHT = ACT_BREADGLOVES_VM_HITRIGHT
		self.VM_SWINGHARD = ACT_BREADGLOVES_VM_SWINGHARD
		self.VM_INSPECT_START = ACT_MELEE_ALT2_VM_INSPECT_START
		self.VM_INSPECT_IDLE = ACT_MELEE_ALT2_VM_INSPECT_IDLE
		self.VM_INSPECT_END = ACT_MELEE_ALT2_VM_INSPECT_END
		self.SwingCrit = Sound("Weapon_bm_gloves.attack")
	end 

	if self:GetItemData().model_player == "models/workshop/weapons/c_models/c_xms_gloves/c_xms_gloves.mdl" then
		self.SwingCrit = Sound("Weapon_mittens.CritHit")
		self.HitFlesh = Sound("Weapon_mittens.HitFlesh")
		self.HitWorld = Sound("Weapon_mittens.HitWorld")
	end

	if self:GetItemData().model_player == "models/weapons/c_models/c_breadmonster_gloves/c_breadmonster_gloves.mdl" and self.Owner:KeyDown(IN_ATTACK2) then

		self.Swing = Sound("Weapon_bm_gloves.attack")
		self.HitFlesh = Sound("Zombie.AttackHit")
	end
	if self:GetItemData().model_player == "models/weapons/c_models/c_breadmonster_gloves/c_breadmonster_gloves.mdl" and self:CriticalEffect() then

		self.Swing = Sound("Weapon_bm_gloves.attack")
		self.SwingCrit = Sound("Weapon_bm_gloves.attack")
		self.HitFlesh = Sound("Zombie.AttackHit")
	end
	if self:GetItemData().model_player == "models/weapons/c_models/c_breadmonster_gloves/c_breadmonster_gloves.mdl" and self.Owner:KeyDown(IN_ATTACK) and !self:CriticalEffect() then

		self.Swing = Sound("Weapon_BoxingGloves.Miss")
		self.HitFlesh = Sound("Weapon_BoxingGloves.HitFlesh")
	end
	if self.Owner:KeyDown(IN_ATTACK) or self.Owner:KeyDown(IN_ATTACK2) then
		if self.ShouldOccurFists == true then
			if SERVER then
				if self.Owner:GetPlayerClass() == "heavy" and self.Owner:GetInfoNum("jakey_antlionfbii", 0) != 1 and self.Owner:GetInfoNum("dylan_rageheavy", 0) != 1 and self.Owner:GetInfoNum("tf_robot", 0) != 1 then
					self.Owner:EmitSound("Heavy.Meleeing0"..math.random(1,6), 80, 100)
					self.ShouldOccurFists = false 
					timer.Simple(4, function()
						self.ShouldOccurFists = true
					end)
				elseif self.Owner:GetPlayerClass() == "heavy" and self.Owner:GetInfoNum("tf_robot", 0) == 1 then
					self.Owner:EmitSound("vo/mvm/norm/heavy_mvm_meleeing0"..math.random(1,6)..".mp3", 80, 100)
					self.ShouldOccurFists = false 
					timer.Simple(4, function()
						self.ShouldOccurFists = true
					end)
				elseif self.Owner:GetPlayerClass() == "merc_dm" then
					self.Owner:EmitSound("vo/taunts/spy_taunts1"..math.random(1,8)..".mp3", 80, 100)
					self.ShouldOccurFists = false
					timer.Simple(8, function()
						self.ShouldOccurFists = true
					end)
				elseif self.Owner:GetInfoNum("jakey_antlionfbii", 0) == 1 then
					self.Owner:EmitSound("NPC_AntlionGuard.Roar", 150, 100)
					self.ShouldOccurFists = false
					self.HitFlesh = Sound("npc/antlion_guard/shove1.wav", 120)
					self.HitWorld = Sound("npc/antlion_guard/shove1.wav", 120)
					self.BaseDamage = 180
					timer.Simple(0.8, function()
						self.ShouldOccurFists = true
					end) 
				elseif self.Owner:GetInfoNum("dylan_rageheavy", 0) == 1 then
					self.Owner:EmitSound("vo/heavy_paincrticialdeath0"..math.random(1,3)..".mp3", 150, math.random(70,150))
					self.ShouldOccurFists = false
					if self.Owner:GetInfoNum("tf_giant_robot", 0) == 1 then
						self.HitFlesh = Sound("ambient/explosions/explode_6.wav", 120)
						self.HitWorld = Sound("ambient/explosions/explode_6.wav", 120)
						self.DamageType = DMG_BLAST
					else
						self.HitFlesh = Sound("npc/antlion_guard/shove1.wav", 120)
						self.HitWorld = Sound("npc/antlion_guard/shove1.wav", 120)					
					end
					self.BaseDamage = 9999999999999999999999999999
					self.Primary.Delay          = 0.2
					timer.Simple(0.2, function()
						self.ShouldOccurFists = true
					end)
				end
			end
		end
	end
end
		


function SWEP:MeleeAttack(dummy)
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	local endpos
	
	if SERVER and not dummy and game.SinglePlayer() then
		self:CallOnClient("MeleeAttack","")
	end
	
	if CLIENT and dummy=="" then
		dummy = false
	end
	
	local scanmul = 1 + self.MeleePredictTolerancy
	
	if dummy then
		-- When doing a dummy melee attack, perform a wider scan for better prediction
		endpos = pos + self.Owner:GetAimVector() * self.MeleeRange * scanmul
	else
		endpos = pos + self.Owner:GetAimVector() * self.MeleeRange
	end
	
	local hitent, hitpos
	
	if not dummy then
		self.Owner:LagCompensation(true)
	end
	
	local tr = util.TraceLine {
		start = pos,
		endpos = endpos,
		filter = self.Owner
	}
	
	if not tr.Hit then
		local mins, maxs
		local v = self.HullAttackVector
		if dummy then
			mins, maxs = scanmul * Vector(-v.x, -v.y, -v.z), scanmul * Vector(v.x, v.y, v.z)
		else
			mins, maxs = Vector(-v.x, -v.y, -v.z), Vector(v.x, v.y, v.z)
		end
		
		tr = util.TraceHull {
			start = pos,
			endpos = endpos,
			filter = self.Owner,
		
			mins = mins,
			maxs = maxs,
		}
	end
	if self.Owner:GetPlayerClass() == "spy" then
		if self.Owner:GetModel() == "models/player/scout.mdl" or  self.Owner:GetModel() == "models/player/soldier.mdl" or  self.Owner:GetModel() == "models/player/pyro.mdl" or  self.Owner:GetModel() == "models/player/demo.mdl" or  self.Owner:GetModel() == "models/player/heavy.mdl" or  self.Owner:GetModel() == "models/player/engineer.mdl" or  self.Owner:GetModel() == "models/player/medic.mdl" or  self.Owner:GetModel() == "models/player/sniper.mdl" or  self.Owner:GetModel() == "models/player/hwm/spy.mdl" or self.Owner:GetModel() == "models/player/kleiner.mdl" then
			if self.Owner:KeyDown( IN_ATTACK ) then
				if self.Owner:GetInfoNum("tf_robot", 0) == 0 then
					self.Owner:SetModel("models/player/spy.mdl") 
				else
					self.Owner:SetModel("models/bots/spy/bot_spy.mdl")
				end
				if IsValid( button) then 
					button:Remove() 
				end
				for _,v in pairs(ents.GetAll()) do
					if v:IsNPC() and not v:IsFriendly(self.Owner) then
						v:AddEntityRelationship(self.Owner, D_HT, 99)
					end
				end
				if self.Owner:Team() == TEAM_BLU then 
					self.Owner:SetSkin(1) 
				else 
					self.Owner:SetSkin(0) 
				end 
				self.Owner:EmitSound("player/spy_disguise.wav", 65, 100) 
			end
		end
	end
	
	if not dummy then
		self.Owner:LagCompensation(false)
	end
	
	--MsgN(Format("HELLO %s",tostring(dummy)))
	if dummy then return tr end
	
	self:OnMeleeAttack(tr)
	
	local damagedself = false
	if self.MeleeHitSelfOnMiss and not tr.HitWorld and not IsValid(tr.Entity) then
		damagedself = true
		tr.Entity = self.Owner
	end
	
	if tr.Entity and tr.Entity:IsValid() then
		--local ang = (endpos - pos):GetNormal():Angle()
		local ang = self.Owner:EyeAngles()
		local dir = ang:Forward()
		hitpos = tr.Entity:NearestPoint(self.Owner:GetShootPos()) - 2 * dir
		tr.HitPos = hitpos
		
		if self.Owner:CanDamage(tr.Entity) then
			if SERVER then
				local mcrit = self:MeleeCritical(tr)
				
				local pitch, mul, dmgtype
				if self.CurrentShotIsCrit then
					dmgtype = self.CritDamageType
					pitch, mul = self.CritForceAddPitch, self.CritForceMultiplier
				else
					dmgtype = self.DamageType
					pitch, mul = self.ForceAddPitch, self.ForceMultiplier
				end
				
				if tr.Entity:ShouldReceiveDefaultMeleeType() then
					dmgtype = DMG_CLUB
				end
				
				ang.p = math.Clamp(math.NormalizeAngle(ang.p - pitch), -90, 90)
				local force_dir = ang:Forward()
				
				self:PreCalculateDamage(tr.Entity)
				local dmg = self:CalculateDamage(nil, tr.Entity)
				--dmg = self:PostCalculateDamage(dmg, tr.Entity)
				
				local dmginfo = DamageInfo()
					dmginfo:SetAttacker(self.Owner)
					dmginfo:SetInflictor(self)
					dmginfo:SetDamage(dmg)
					dmginfo:SetDamageType(dmgtype)
					dmginfo:SetDamagePosition(hitpos)
					dmginfo:SetDamageForce(dmg * force_dir * mul)
				if damagedself then
					force_dir.x = -force_dir.x
					force_dir.y = -force_dir.y
					dmginfo:SetDamageForce(dmg * force_dir * (mul * 0.5))
					tr.Entity:DispatchBloodEffect()
					tr.Entity:TakeDamageInfo(dmginfo)
				else
					if self:GetItemData().model_player == "models/workshop/weapons/c_models/c_xms_gloves/c_xms_gloves.mdl" then
						if self:CriticalEffect() then
							if tr.Entity:IsPlayer() then
								if tr.Entity:GetNWBool("Taunting") == true then return end
								if tr.Entity:IsHL2() then tr.Entity:ConCommand("act laugh") return end
								if not tr.Entity:IsOnGround() then return end
								if tr.Entity:WaterLevel() ~= 0 then return end
								if tr.Entity:GetInfoNum("tf_robot", 0) == 1 then tr.Entity:ChatPrint("You can't taunt as a robot!") return end
								if tr.Entity:GetInfoNum("tf_giantrobot", 0) == 1 then tr.Entity:ChatPrint("You can't taunt as a mighty robot!") return end	
								local time = tr.Entity:PlayScene("scenes/player/"..tr.Entity:GetPlayerClass().."/low/taunt_laugh.vcd", 0)	
								tr.Entity:DoAnimationEvent(ACT_DOD_HS_CROUCH_KNIFE, true)
								tr.Entity:SetNWBool("Taunting", true)
								tr.Entity:SetNWBool("NoWeapon", true)
								net.Start("ActivateTauntCam")
								net.Send(tr.Entity)
								if tr.Entity:GetPlayerClass() == "merc_dm" then
									tr.Entity:EmitSound("vo/mercenary_laughevil01.wav", 80, 100)
									timer.Create("Laugh", 2, 1, function()
										if not IsValid(tr.Entity) or (not tr.Entity:Alive() and not tr.Entity:GetNWBool("Taunting")) then return end
										tr.Entity:SetNWBool("Taunting", false)
										tr.Entity:SetNWBool("NoWeapon", false)
										net.Start("DeActivateTauntCam")
										net.Send(tr.Entity)
									end)
								else
									timer.Create("Laugh", time, 1, function()
										if not IsValid(tr.Entity) or (not tr.Entity:Alive() and not tr.Entity:GetNWBool("Taunting")) then return end
										tr.Entity:SetNWBool("Taunting", false)
										tr.Entity:SetNWBool("NoWeapon", false)
										net.Start("DeActivateTauntCam")
										net.Send(tr.Entity)
									end)
								end
							else
								tr.Entity:DispatchTraceAttack(dmginfo, hitpos, hitpos + 5*dir)
							end
						else
							tr.Entity:DispatchTraceAttack(dmginfo, hitpos, hitpos + 5*dir)
						end
					else
						tr.Entity:DispatchTraceAttack(dmginfo, hitpos, hitpos + 5*dir)
					end
				end
				
				local phys = tr.Entity:GetPhysicsObject()
				if phys and phys:IsValid() then
					tr.Entity:SetPhysicsAttacker(self.Owner)
				end
			elseif CLIENT then
				-- Fire a bullet clientside, just for decals and blood effects
				if util.TraceLine({start=hitpos,endpos=hitpos+4*dir}).Entity == tr.Entity then
					self:FireBullets{
						Src=hitpos,
						Dir=dir,
						Spread=Vector(0,0,0),
						Num=1,
						Damage=1,
						Tracer=0,
					}
				end
			end
		end
		
		self:MeleeHitSound(tr)
		self:OnMeleeHit(tr)
	elseif tr.HitWorld then
		local range = self.MeleeRange + 18
		local dir = self.Owner:GetAimVector()
		
		if not util.TraceLine({start=pos,endpos=pos+range*dir}).Hit then
			local ang = self.Owner:EyeAngles()
			ang.y = ang.y + 25
			local dir1 = ang:Forward()
			ang.y = ang.y - 50
			local dir2 = ang:Forward()
			
			local tr1 = util.TraceLine({start=pos,endpos=pos+range*dir1})
			local tr2 = util.TraceLine({start=pos,endpos=pos+range*dir2})
			
			if not tr1.Hit and not tr2.Hit then
				dir = nil
			elseif tr1.Fraction > tr2.Fraction then
				dir = dir2
				tr.HitPos = tr2.HitPos
			else
				dir = dir1
				tr.HitPos = tr1.HitPos
			end
		end
		
		if CLIENT then
			if dir then
				self:FireBullets{
					Src=pos,
					Dir=dir,
					Spread=Vector(0,0,0),
					Num=1,
					Damage=1,
					Tracer=0,
				}
			end
		end
		
		self:MeleeHitSound(tr)
		self:OnMeleeHit(tr)
	end
end
