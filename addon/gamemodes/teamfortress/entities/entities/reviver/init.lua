include("shared.lua")
AddCSLuaFile("shared.lua")

ENT.Model = "models/props_mvm/mvm_revive_tombstone.mdl"

function ENT:Think()
	self:NextThink(CurTime())
	local ply = self:GetOwner()  
	self:SetMaxHealth(95)
	self:SetNWInt("Team", ply:Team())
	if ply:Alive() then
		self:Remove()
	end
	return true
end
 
 
function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetHealth(95)
	self:SetSolid(SOLID_BBOX)
	self:EmitSound("ui/medic_alert.wav", 95, 100)
	self:SetModel(self.Model)
	
	self:SetSequence( "idle" )
	self:SetPlaybackRate( 1 )
	local ply = self:GetOwner()
	
	self:SetPos(self:GetOwner():GetPos())
	if ply:GetPlayerClass() == "soldier" then
		self:SetBodygroup(1, 2)
	elseif ply:GetPlayerClass() == "pyro" then
		self:SetBodygroup(1, 6)
	elseif ply:GetPlayerClass() == "demoman" then
		self:SetBodygroup(1, 3)
	elseif ply:GetPlayerClass() == "heavy" then
		self:SetBodygroup(1, 5)
	elseif ply:GetPlayerClass() == "engineer" then
		self:SetBodygroup(1, 8)
	elseif ply:GetPlayerClass() == "medic" then
		self:SetBodygroup(1, 4)
	elseif ply:GetPlayerClass() == "sniper" then
		self:SetBodygroup(1, 1)
	elseif ply:GetPlayerClass() == "spy" then
		self:SetBodygroup(1, 7)
	end
			
			
	self:SetNoDraw(false)
	self:SetCollisionGroup( COLLISION_GROUP_PLAYER )
end 