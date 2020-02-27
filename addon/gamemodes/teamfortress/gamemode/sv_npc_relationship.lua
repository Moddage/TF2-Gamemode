
-- Those classes will keep default relationship regardless of which team concerns them
local IgnoredClasses = {
	[CLASS_FLARE] = 1,
	[CLASS_EARTH_FAUNA] = 1,
	[CLASS_BULLSEYE] = 1,
}

local function CalcRelationship(ent1, ent2)
	local t1, t2 = GAMEMODE:EntityTeam(ent1), GAMEMODE:EntityTeam(ent2)
	if t1==TEAM_FRIENDLY then
		return D_LI
	end
	if t1==t2 then
		if t1==TEAM_RED or t1==TEAM_BLU then
			return D_LI
		else
			--return D_NU
		end
	else
		return D_HT
	end
end

function GM:UpdateEntityRelationship(ent)
	-- Use default relationships in the first maps of the first chapter
	if GetGlobalBool("GordonIsPrecriminal") or self.GordonIsPrecriminal then
		return
	end
	
	for _,v in pairs(ents.GetAll()) do
		if (v:IsNPC() and v:EntityTeam()~=TEAM_HIDDEN and not IgnoredClasses[v:Classify()]) or v:IsPlayer() then
			local rel = CalcRelationship(v, ent)
			
			if rel then
				if v:IsNPC() then
					v:AddEntityRelationship(ent, rel)
				end
				
				if ent:IsNPC() then
					ent:AddEntityRelationship(v, rel)
				end
			end
		end
	end
end

hook.Add("OnEntityCreated", "TF_UpdateNPCRelationship", function(ent)
	if ent:IsNPC() and ent:EntityTeam()~=TEAM_HIDDEN and not IgnoredClasses[ent:Classify()] and not ent:HasNPCFlag(NPC_NORELATIONSHIP) then
		GAMEMODE:UpdateEntityRelationship(ent)
	end
end)
