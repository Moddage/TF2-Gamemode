include("shared.lua")
AddCSLuaFile("shared.lua")

ENT.Model = "models/props_mvm/mvm_revive_tombstone.mdl"

function ENT:Think()
	self:NextThink(CurTime())
	if self:GetOwner():IsValid() then
		self:SetPos(self:GetOwner():GetPos())
	end
	return true
end
 
 
function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetNotSolid(true)	
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetSolid(SOLID_BBOX)
	self:SetMaxHealth(70)
	self:SetHealth(1)
	self:SetModel(self.Model)
	local ply = self:GetVictim()
	if ply:IsPlayer() and ply:GetPlayerClass() == "soldier" then
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
			
			
	self:SetSolid( SOLID_OBB ) -- This stuff isn't really needed, but just for physics
	self:PhysicsInit( SOLID_OBB )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	self:SetSequence( "idle" )
	self:SetPlaybackRate( 1 )
end 