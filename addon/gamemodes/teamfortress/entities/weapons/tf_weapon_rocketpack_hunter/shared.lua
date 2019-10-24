if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then

SWEP.PrintName			= "Thermal Thruster"
SWEP.HasCModel = true
SWEP.Slot				= 1

end

SWEP.Base				= "tf_weapon_base"

SWEP.ViewModel			= "models/weapons/arms/v_jockey_arms.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_flaregun_shell.mdl"
SWEP.Crosshair = "tf_crosshair3"

SWEP.MuzzleEffect = ""

SWEP.ShootSound = ""
SWEP.ShootCritSound = ""

SWEP.Primary.Ammo			= TF_PRIMARY
SWEP.Primary.Delay          = 1.5

SWEP.ReloadSingle = true

SWEP.ReloadTime = 0.1

SWEP.ReloadSound = ""

SWEP.HasCustomMeleeBehaviour = true

SWEP.ProjectileShootOffset = Vector(0, 0, 0)

SWEP.Force = 800
SWEP.AddPitch = -4

function SWEP:Think()
	self:CallBaseFunction("Think")
end

function SWEP:PredictCriticalHit()
end

function SWEP:PrimaryAttack()	
	if not self:CallBaseFunction("PrimaryAttack") then return false end
	self:SetNextPrimaryFire(CurTime() + 1.5)
	if self.Owner:GetAmmoCount( self.Weapon:GetPrimaryAmmoType() ) == 0 then
		return
	end

		self.Owner:SetLocalVelocity( Vector( 0, 0, 500 ) + self.Owner:GetVelocity() )
		if self.Owner:GetPlayerClass() == "hunter" then
			self.Owner:EmitSound( "hunter/voice/attack/hunter_attackmix_0"..math.random(1,4)..".wav", 85 )
		elseif self.Owner:GetPlayerClass() == "jockey" then
			self.Owner:EmitSound("jockey/voice/attack/jockey_loudattack01.wav", 85)
		end
		
 		self:TakePrimaryAmmo(1)
		
		self.NextIdle = CurTime() + self:SequenceDuration()
		self.Owner:DoAnimationEvent(ACT_DOD_PRONE_ZOOMED, true)	 
		
		timer.Simple(0.55, function()
			timer.Create("CheckIfOnGround", 0.001, 0, function()
				if self.Owner:OnGround() then
					if SERVER then 
						if self.Owner:GetPlayerClass() == "hunter" then
							for k,v in pairs(ents.FindInSphere(self.Owner:GetPos(), 110)) do
								if v:Health() >= 0 then
									if v:IsPlayer() and v:Nick() != self.Owner:Nick() and not v:IsFriendly(self.Owner) then
										v:TakeDamage(5, self.Owner, self)
										self.Owner:DoAnimationEvent(ACT_DOD_PRONE_DEPLOYED)
										if not self.Owner:IsOnGround() then return end
										if self.Owner:WaterLevel() ~= 0 then return end
										self.Owner:DoAnimationEvent(ACT_DOD_HS_CROUCH_KNIFE, true)
										self.Owner:SetNWBool("Taunting", true)
										self.Owner:SetNWBool("NoWeapon", true)
										net.Start("ActivateTauntCam")
										net.Send(self.Owner)
										self.Owner:SetParent(v)
										v:EmitSound("hunter/hit/tackled_1.wav")
										v:EmitSound("hit/claw_hit_flesh_"..math.random(1,4)..".wav", 85, 100)
										v:EmitSound("Hunter.Music")
										if SERVER then
											v:EmitSound("music/tags/exenterationhit.wav", 100, 150)
										end
										v:EmitSound("music/tags/exenterationhit.wav")
										timer.Create("RIPTHATASSHOLEAPART", math.random(0.25, 0.3), 0, function()
											if v:Health() <= 1 then 
												timer.Stop("RIPTHATASSHOLEAPART") 
												v:StopSound("Hunter.Music")
												self.Owner:SetNWBool("Taunting", false)
												self.Owner:SetNWBool("NoWeapon", false)
												self.Owner:SetParent()
												self.Owner:SetPos(self.Owner:GetPos() + Vector(40, 40, 40))
												net.Start("DeActivateTauntCam")
												net.Send(self.Owner)
												return 
											end
											if !self.Owner:Alive() then 
												timer.Stop("RIPTHATASSHOLEAPART") 
												v:StopSound("Hunter.Music")
												self.Owner:SetNWBool("Taunting", false)
												self.Owner:SetNWBool("NoWeapon", false)
												self.Owner:SetParent()
												self.Owner:SetPos(self.Owner:GetPos() + Vector(40, 40, 40))
												net.Start("DeActivateTauntCam")
												net.Send(self.Owner)
												return 
											end
											v:TakeDamage(5, self.Owner, self)
											v:EmitSound("hit/claw_hit_flesh_"..math.random(1,4)..".wav", 85, 100)
										end)
									end  
									if v:IsNPC() and not v:IsFriendly(self.Owner) then
										v:TakeDamage(5, self.Owner, self)
										self.Owner:DoAnimationEvent(ACT_DOD_PRONE_DEPLOYED)
										if not self.Owner:IsOnGround() then return end
										if self.Owner:WaterLevel() ~= 0 then return end
										self.Owner:DoAnimationEvent(ACT_DOD_HS_CROUCH_KNIFE, true)
										self.Owner:SetNWBool("Taunting", true)
										self.Owner:SetNWBool("NoWeapon", true)
										net.Start("ActivateTauntCam")
										net.Send(self.Owner)
										self.Owner:SetParent(v)
										v:EmitSound("hit/claw_hit_flesh_"..math.random(1,4)..".wav", 85, 100)
										if SERVER then
											v:EmitSound("music/tags/exenterationhit.wav")
										end
										timer.Create("RIPTHATASSHOLEAPART", math.random(0.25, 0.3), 0, function()
											if v:Health() <= 1 then 
												timer.Stop("RIPTHATASSHOLEAPART") 
												
												self.Owner:SetNWBool("Taunting", false)
												self.Owner:SetNWBool("NoWeapon", false)
												self.Owner:SetParent()
												self.Owner:SetPos(self.Owner:GetPos() + Vector(40, 40, 40))
												net.Start("DeActivateTauntCam")
												net.Send(self.Owner)
												return 
											end
											if !self.Owner:Alive() then 
												timer.Stop("RIPTHATASSHOLEAPART") 
												v:StopSound("Hunter.Music")
												self.Owner:SetNWBool("Taunting", false)
												self.Owner:SetNWBool("NoWeapon", false)
												self.Owner:SetParent()
												self.Owner:SetPos(self.Owner:GetPos() + Vector(40, 40, 40))
												net.Start("DeActivateTauntCam")
												net.Send(self.Owner)
												return 
											end
											v:TakeDamage(5, self.Owner, self)
											v:EmitSound("hit/claw_hit_flesh_"..math.random(1,4)..".wav", 85, 100)
										end)
									end
								end
							end
							elseif self.Owner:GetPlayerClass() == "jockey" then

								for k,v in pairs(ents.FindInSphere(self.Owner:GetPos(), 110)) do
									if v:Health() >= 0 then
										if v:IsPlayer() and v:Nick() != self.Owner:Nick() and not v:IsFriendly(self.Owner) then
											v:TakeDamage(15, self.Owner, self)
											self.Owner:DoAnimationEvent(ACT_DOD_PRONE_DEPLOYED)
											if not self.Owner:IsOnGround() then return end
											if self.Owner:WaterLevel() ~= 0 then return end
											self.Owner:DoAnimationEvent(ACT_DOD_HS_CROUCH_KNIFE, true)
											self.Owner:SetNWBool("Taunting", true)
											self.Owner:SetNWBool("NoWeapon", true)
											net.Start("ActivateTauntCam")
											net.Send(self.Owner)
											self.Owner:SetParent(v, v:LookupAttachment("head"))
											v:EmitSound("charger/hit/charger_punch"..math.random(1,4)..".wav", 85, 100)
											v:EmitSound("Jockey.Music")
											v:EmitSound("music/tags/exenterationhit.wav")
											self.Owner:EmitSound("jockey/voice/attack/jockey_attackloop01.wav")
											timer.Create("RIPTHATASSHOLEAPART", 1, 0, function()
												if v:Health() <= 1 then 
													timer.Stop("RIPTHATASSHOLEAPART") 
													v:StopSound("Jockey.Music")
													self.Owner:SetNWBool("Taunting", false)
													self.Owner:SetNWBool("NoWeapon", false)
													self.Owner:SetParent()
													self.Owner:SetPos(self.Owner:GetPos() + Vector(40, 40, 40))
													net.Start("DeActivateTauntCam")
													net.Send(self.Owner)
													return 
												end
												if !self.Owner:Alive() then 
													timer.Stop("RIPTHATASSHOLEAPART") 
													v:StopSound("Jockey.Music")
													self.Owner:SetNWBool("Taunting", false)
													self.Owner:SetNWBool("NoWeapon", false)
													self.Owner:SetParent()
													self.Owner:SetPos(self.Owner:GetPos() + Vector(40, 40, 40))
													net.Start("DeActivateTauntCam")
													net.Send(self.Owner)
													return 
												end
												v:TakeDamage(15, self.Owner, self)
												v:EmitSound("charger/hit/charger_punch"..math.random(1,4)..".wav", 85, 100)
											end)
										end
										if v:IsNPC() and not v:IsFriendly(self.Owner) then
											v:TakeDamage(15, self.Owner, self)
											self.Owner:DoAnimationEvent(ACT_DOD_PRONE_DEPLOYED)
											if not self.Owner:IsOnGround() then return end
											if self.Owner:WaterLevel() ~= 0 then return end
											self.Owner:DoAnimationEvent(ACT_DOD_HS_CROUCH_KNIFE, true)
											self.Owner:SetNWBool("Taunting", true)
											self.Owner:SetNWBool("NoWeapon", true)
											net.Start("ActivateTauntCam")
											net.Send(self.Owner)
											self.Owner:SetParent(v)
											v:EmitSound("charger/hit/charger_punch"..math.random(1,4)..".wav", 85, 100)
											v:EmitSound("music/tags/exenterationhit.wav")
											self.Owner:EmitSound("jockey/voice/attack/jockey_attackloop01.wav")
											timer.Create("RIPTHATASSHOLEAPART", 1, 0, function()
												if v:Health() <= 1 then 
													timer.Stop("RIPTHATASSHOLEAPART") 
													self.Owner:SetNWBool("Taunting", false)
													self.Owner:SetNWBool("NoWeapon", false)
													self.Owner:SetParent()
													self.Owner:SetPos(self.Owner:GetPos() + Vector(40, 40, 40))
													net.Start("DeActivateTauntCam")
													net.Send(self.Owner)
													return 
												end
												if !self.Owner:Alive() then 
													timer.Stop("RIPTHATASSHOLEAPART") 
													self.Owner:SetNWBool("Taunting", false)
													self.Owner:SetNWBool("NoWeapon", false)
													self.Owner:SetParent()
													self.Owner:SetPos(self.Owner:GetPos() + Vector(40, 40, 40))
													net.Start("DeActivateTauntCam")
													net.Send(self.Owner)
													return 
												end
												v:TakeDamage(15, self.Owner, self)
												v:EmitSound("charger/hit/charger_punch"..math.random(1,4)..".wav", 85, 100)
											end)
										end
									end
							end
						end
					end
					timer.Stop("CheckIfOnGround")
				end
			end)
		end) 
end
