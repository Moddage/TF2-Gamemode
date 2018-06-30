
ENT.Type = "anim"  
ENT.Base = "item_base"    

ENT.Model = "models/items/medkit_small.mdl"
ENT.HealthPercentage = 1

if SERVER then

AddCSLuaFile("shared.lua")

function ENT:CanPickup(ply)
	return ply:Health()<ply:GetMaxHealth()
end

function ENT:PlayerTouched(pl)
	local h = self.HealthPercentage
	if pl.TempAttributes and pl.TempAttributes.HealthFromPacksMultiplier then
		h = h * pl.TempAttributes.HealthFromPacksMultiplier
	end
	
	self:EmitSound("HealthKit.Touch")
	self:Hide()
	GAMEMODE:GiveHealthPercent(pl, h)
	GAMEMODE:ExtinguishEntity(pl)
	GAMEMODE:EntityStopBleeding(pl)
end

end
