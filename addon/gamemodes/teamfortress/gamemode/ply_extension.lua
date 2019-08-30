
-- General player extensions

local meta = FindMetaTable( "Player" )
if (!meta) then return end 

function RegisterStatType(obj, name)
	local name_get = name
	local name_set = "Set"..name
	local name_add = "Add"..name
	local name_umsg = "__playerSet"..name
	
	obj[name_get] = function(self)
		if not self.Stats then self.Stats = {} end
		return self.Stats[name] or 0
	end
	
	if SERVER then
		obj[name_set] = function(self, val)
			if not self.Stats then self.Stats = {} end
			self.Stats[name] = val
			umsg.Start(name_umsg)
				umsg.Entity(self)
				umsg.Long(val)
			umsg.End()
		end
		
		obj[name_add] = function(self, val)
			self[name_set](self, self[name_get](self) + val)
		end
	else
		usermessage.Hook(name_umsg, function(msg)
			local self = msg:ReadEntity()
			if not IsValid(self) or not self:IsPlayer() then return end
			if not self.Stats then self.Stats = {} end
			self.Stats[name] = msg:ReadLong()
		end)
	end
end

RegisterStatType(meta, "Kills")
RegisterStatType(meta, "Assists")
RegisterStatType(meta, "Destructions")

RegisterStatType(meta, "Captures")
RegisterStatType(meta, "Defenses")
RegisterStatType(meta, "Dominations")
RegisterStatType(meta, "Revenges")

RegisterStatType(meta, "Healing")
RegisterStatType(meta, "Invulns")
RegisterStatType(meta, "Teleports")
RegisterStatType(meta, "Headshots")

RegisterStatType(meta, "Backstabs")
RegisterStatType(meta, "Bonus")

-- Serverside

if SERVER then

if not meta.SetFrags0 then
	meta.SetFrags0 = meta.SetFrags
end
function meta:SetFrags(n)
	if not self.Stats then self.Stats = {} end
	self.Stats.Points = n
	self:SetFrags0(math.floor(self.Stats.Points))
end

function meta:AddFrags(n)
	if not self.Stats then self.Stats = {} end
	self.Stats.Points = (self.Stats.Points or self:Frags()) + n
	self:SetFrags0(math.floor(self.Stats.Points))
end

function meta:Explode()
	self.ShouldGib = true
	umsg.Start("GibPlayer")
		umsg.Long(self:UserID())
		umsg.Short(self.DeathFlags)
	umsg.End()
end

function meta:EnablePhonemes( ent, on )

	if ( !IsValid( ent ) ) then return end

	if ( !on ) then
		-- Disable mouth movement
		self:SetupPhonemeMappings( "" )
	else
		-- Enable mouth movement
		self:SetupPhonemeMappings( "heavy/phonemes" )
	end

end

function meta:RandomSentence(group)
	if self:IsHL2() then return end
	
	local class = self:GetPlayerClassTable()
	if not class then return end
	
	--[[local tbl = class.Sounds[group]
	self:EmitSound(tbl[math.random(1,#tbl)])]]
	
	self:EmitSound(Format("%s.%s", class.Name, group))
end

function meta:StripTFItems()
	self:StripWeapons()
	self:StripAmmo()
	
	if self.PlayerItemList then
		for _,v in ipairs(self.PlayerItemList) do
			v:Remove()
		end
	end
end

function meta:StripHats()
	for _,v in pairs(ents.FindByClass("tf_hat")) do
		if v:GetOwner() == self then
			v:Remove()
		end
	end
	
	for i=1,10 do
		self:SetBodygroup(i,0)
	end
end

function meta:GiveTFAmmo(c, am, is_fraction)
	if c==0 then return end
	
	if not self.AmmoMax then
		if c>0 then
			return self:GiveAmmo(c, am)
		else
			return self:RemoveAmmo(-c, am)
		end
	end
	
	local a = self:GetAmmoCount(am)
	
	if is_fraction then
		if c ~= nil and not self:IsHL2() then
			c = math.ceil(c * self.AmmoMax[am])
		else
			c = 0
		end
	end
	
	if c>0 then
		c = math.min(self.AmmoMax[am] - a, c)
		if c>0 then
			self:GiveAmmo(c, am)
			if am == TF_METAL then
				umsg.Start("PlayerMetalBonus", self)
					umsg.Short(c)
				umsg.End()
			end
			return true
		end
	else
		self:RemoveAmmo(-c, am)
		if am == TF_METAL then
			umsg.Start("PlayerMetalBonus", self)
				umsg.Short(-c)
			umsg.End()
		end
	end
	
	return false
end

function meta:SetAmmoCount(c, am)
	local a = self:GetAmmoCount(am)
	
	if c > a then
		self:GiveAmmo(c - a, am)
	elseif c < a then
		self:RemoveAmmo(a - c, am)
	end
end

function meta:HasFullAmmo()
	for k,v in pairs(self.AmmoMax or {}) do
		if self:GetAmmoCount(k) < v then
			return false
		end
	end
	return true
end

function meta:ResetAttributes()
	local c = self:GetPlayerClassTable()
	
	self.TempAttributes = {}
	self:ResetClassSpeed(c.Speed or 100)
	self:ResetMaxHealth()
	self.AmmoMax = table.Copy(c.AmmoMax or {})
end

end

-- Shared

function meta:GetCrouchedWalkSpeed()
	return self:GetNWFloat("CrouchedWalkSpeed")
end

function meta:GetWalkSpeed()
	return 1
end

function meta:GetRunSpeed()
	return 1
end

function meta:GetDuckSpeed()
	return self:GetNWFloat("TimeToDuck")
end

function meta:GetUnDuckSpeed()
	return self:GetNWFloat("TimeToUnDuck")
end

function meta:IsHL2()
	return self:GetNWBool("IsHL2")
end

function meta:ShouldUseDefaultHull()
	if self ~= nil then
		if GetConVar("tf_use_hl_hull_size") then
			return self:GetNWBool("IsHL2") or GetMapType(game.GetMap())=="hl2" or GetConVar("tf_use_hl_hull_size"):GetInt() == 1
		end
	end
end

function meta:GetTFItems()
	local t = self:GetWeapons()
	if self.PlayerItemList then
		table.Add(t, self.PlayerItemList)
	end
	return t
end

function meta:HasTFItem(name)
	if not name then return false end
	
	for _,v in ipairs(self:GetTFItems()) do
		if v.IsTFItem and v:GetItemData().name == name then
			return true
		end
	end
	
	return false
end

--[[
if CLIENT then

usermessage.Hook("SendWeaponAnim", function(msg)
	local act = msg:ReadShort()
	local seq = GAMEMODE.Viewmodels[1][2]:SelectWeightedSequence(act)
	if seq>=0 then
		GAMEMODE.Viewmodels[1][2]:ResetSequence(seq)
		GAMEMODE.Viewmodels[1][2]:SetCycle(0)
	end
end)

end

meta.SendWeaponAnim0 = meta.SendWeaponAnim

function meta:SendWeaponAnim(act)
	self:SendWeaponAnim0(act)
	
	if SERVER then
		umsg.Start("SendWeaponAnim", self)
			umsg.Short(act)
		umsg.End()
	else
		local seq = GAMEMODE.Viewmodels[1][2]:SelectWeightedSequence(act)
		if seq>=0 then
			GAMEMODE.Viewmodels[1][2]:ResetSequence(seq)
			GAMEMODE.Viewmodels[1][2]:ResetSequenceInfo()
		end
	end
end
]]
