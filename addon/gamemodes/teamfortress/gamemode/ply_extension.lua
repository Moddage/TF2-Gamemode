
-- General player extensions

local meta = FindMetaTable( "Player" )
if (!meta) then return end 

local Player = FindMetaTable("Player")
local oNick = Player.Nick

function Player:Nick()
	if not self:IsValid() then
		return 
	end
	if self:IsBot() then
		if self:GetPlayerClass() == "scout" then
			return "Scout"
		elseif self:GetPlayerClass() == "soldier" then
			return "Soldier"
		elseif self:GetPlayerClass() == "pyro" then
			return "Pyro"
		elseif self:GetPlayerClass() == "demoman" then
			return "Demoman"
		elseif self:GetPlayerClass() == "heavy" then
			return "HeavyWeapons"
		elseif self:GetPlayerClass() == "engineer" then
			return "Engineer"
		elseif self:GetPlayerClass() == "medic" then
			return "Medic"
		elseif self:GetPlayerClass() == "sniper" then
			return "Sniper"
		elseif self:GetPlayerClass() == "spy" then
			return "Spy"
		elseif self:GetPlayerClass() == "giantscout" then
			return "Giant Scout"
		elseif self:GetPlayerClass() == "giantsoldier" then
			return "Giant Soldier"
		elseif self:GetPlayerClass() == "giantpyro" then
			return "Giant Pyro"
		elseif self:GetPlayerClass() == "giantdemoman" then
			return "Giant Demoman"
		elseif self:GetPlayerClass() == "giantheavy" then
			return "Giant Heavy"
		elseif self:GetPlayerClass() == "giantheavyshotgun" then
			return "Giant Shotgun Heavy"
		elseif self:GetPlayerClass() == "heavyweightchamp" then
			return "Heavyweight Champ"
		elseif self:GetPlayerClass() == "heavyshotgun" then
			return "Shotgun Heavy"
		elseif self:GetPlayerClass() == "giantsoldierrapidfire" then
			return "Giant Rapid-Fire Soldier"
		elseif self:GetPlayerClass() == "ubermedic" then 
			return "Quick-Fix Medic"
		elseif self:GetPlayerClass() == "demoknight" then 
			return "Demoknight"
		elseif self:GetPlayerClass() == "giantheavyheater" then 
			return "Giant Heavy"
		elseif self:GetPlayerClass() == "giantsoldiercharged" then 
			return "Giant Charged Soldier"
		elseif self:GetPlayerClass() == "soldierblackbox" then 
			return "Black Box Soldier"
		elseif self:GetPlayerClass() == "melee_scout" then
			return "Melee Scout"
		elseif self:GetPlayerClass() == "superscout" then
			return "Super Scout"
		elseif self:GetPlayerClass() == "soldierbuffed" then
			return "Buffed Concheror Soldier"
		elseif self:GetPlayerClass() == "sentrybuster" then
			return "Sentry Buster"
		else
			return self:GetPlayerClass() or oNick(self)
		end
	else
		return oNick(self)
	end
end
Player.Name = Player.Nick
Player.GetName = Player.Nick

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

function meta:Decap()
	self.ShouldGib = true
	if self:IsHL2() then
		umsg.Start("GibNPCHead")
			umsg.Long(self:UserID())
			umsg.Short(self.DeathFlags)
		umsg.End()
	else
		umsg.Start("GibPlayerHead")
			umsg.Long(self:UserID())
			umsg.Short(self.DeathFlags)
		umsg.End()
	end
end


function meta:SetBuilding(group, mode)
	local builder = self:GetWeapon("tf_weapon_builder")
	if self.Buildings[group] and self.Buildings[group][mode] then
		local cost = self.Buildings[group][mode].cost
		if self:GetAmmoCount(TF_METAL) < cost then
			return false
		end
		
		builder.dt.BuildGroup = group
		builder.dt.BuildMode = mode
		return true
	end
end

function meta:SetBuilding2(group, mode)
	if self.Buildings[group] and self.Buildings[group][mode] then
		self.dt.BuildGroup = group
		self.dt.BuildMode = mode
		return true
	end
end

local old_group_translate = {
	[0] = {0,0},
	[1] = {1,0},
	[2] = {1,1},
	[3] = {2,0},
	[4] = {3,0},
}

function meta:Build(number1,number2)
	local args
	local group = tonumber(number1)
	local sub = tonumber(number2)
	
	local builder = self:GetWeapon("tf_weapon_builder")

	builder:SetHoldType("BUILDING")
	
	builder.Moving = false
	
	timer.Simple(25, function()
		if ( builder.Moving != false and self:KeyPressed( IN_FORWARD ) ) then 
			self:EmitSound("vo/engineer_sentrymoving0"..math.random(1,2)..".mp3", 80, 100)
		else
			return
		end
	end)	
	
	if not IsValid(builder) then return end
	if not group then return end
	
	if not sub then
		if not old_group_translate[group] then return end
		
		group, sub = unpack(old_group_translate[group])
	end
	
	local current = self:GetActiveWeapon()
	if self:SetBuilding(group, sub) and current ~= builder then
		if current.IsPDA then
			local last = self:GetWeapon(self.LastWeapon)
			if not IsValid(last) or last.IsPDA then
				last = self:GetWeapons()[1]
			end
			builder.LastWeapon = last:GetClass()
			self:SelectWeapon(last:GetClass())
		else
			builder.LastWeapon = current:GetClass()
		end
		self:SelectWeapon("tf_weapon_builder")
	end
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
