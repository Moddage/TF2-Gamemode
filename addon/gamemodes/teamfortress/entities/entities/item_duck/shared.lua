ENT.PrintName		= "Duck"
ENT.Author			= "Agent Agrimar, _Kilburn"
ENT.Information		= "It's a duck! Quack."
ENT.Category		= "Team Fortress 2"

ENT.Spawnable			= true
ENT.AdminOnly		= true

ENT.Type = "anim"
ENT.Base = "item_base"

ENT.Model = "models/items/target_duck.mdl"
ENT.HealthPercentage = 1

if SERVER then

AddCSLuaFile("shared.lua")

function ENT:CanPickup(ply)
	return true
end

function ENT:PlayerTouched(pl)
	local effect = EffectData()
	local color = ColorRand(false)
	effect:SetOrigin(self:GetPos())
	effect:SetStart(Vector(color.r, color.g, color.b))
	util.Effect("balloon_pop", effect)
	self:EmitSound("misc/halloween/duck_pickup_pos_01.wav")
	self:Remove()
	pl:AddFrags(1)
end

end
