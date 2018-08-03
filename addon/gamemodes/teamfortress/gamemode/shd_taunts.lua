concommand.Add("tf_taunt_laugh", function(ply)
	if ply:GetNWBool("Taunting") == true then return end
	if ply:IsHL2() then ply:ConCommand("act laugh") return end
	if not ply:IsOnGround() then return end
	if ply:WaterLevel() ~= 0 then return end
	local time = ply:PlayScene("scenes/player/"..ply:GetPlayerClass().."/low/taunt_laugh.vcd", 0)
	ply:SetNWBool("NoWeapon", true) 
	ply:DoAnimationEvent(ACT_DOD_HS_CROUCH_KNIFE, true)
	ply:SetNWBool("Taunting", true)
	ply:ConCommand("tf_tp_taunt_toggle")
	ply:Freeze(true)
	for k, v in pairs(ply:GetWeapons()) do
		v:SetNoDraw(true) -- custom weps, tf2 weps should be handled in a gamemode function for world model drawing!
	end
	timer.Simple(time, function()
		if not ply:Alive() and ply:GetNWBool("Taunting") == false then return end
		ply:SetNWBool("Taunting", false)
		ply:SetNWBool("NoWeapon", false) 
		ply:ConCommand("tf_tp_taunt_toggle")
		ply:Freeze(false)
		for k, v in pairs(ply:GetWeapons()) do
			v:SetNoDraw(false)
		end
	end)
end)

allowedtaunts = {
"1",
"2",
"3",
}

class_hidewep = {
"scout",
"soldier",
"pyro",
"engineer",
"medic",
}

wep = {
"tf_weapon_medigun",
"tf_weapon_pistol_scout",
"tf_weapon_rocketlauncher",
"tf_weapon_shotgun_pyro",
"tf_weapon_syringegun_medic",
}

concommand.Add("tf_taunt", function(ply,cmd,args)
	if ply:GetNWBool("Taunting") == true then return end
	if ply:IsHL2() then ply:ConCommand("act cheer") return end
	if not table.HasValue(allowedtaunts, args[1]) then return end
	if table.KeyFromValue(allowedtaunts,args[1]) == 1 then
		ply:SelectWeapon(ply:GetWeapons()[1]:GetClass())
		ply:DoAnimationEvent(ACT_DOD_CROUCH_AIM_C96, true)
	elseif table.KeyFromValue(allowedtaunts,args[1]) == 2 then
		ply:SelectWeapon(ply:GetWeapons()[2]:GetClass())
		ply:DoAnimationEvent(ACT_DOD_CROUCHWALK_AIM_MP40, true)
	elseif table.KeyFromValue(allowedtaunts,args[1]) == 3 then
		ply:SelectWeapon(ply:GetWeapons()[3]:GetClass())
		ply:DoAnimationEvent(ACT_DOD_STAND_AIM_30CAL, true)
	else
		ply:DoAnimationEvent(ACT_DOD_CROUCH_AIM_C96, true)
	end
	ply:Speak("TLK_PLAYER_TAUNT")
	ply:SetNWBool("Taunting", true)
	ply:ConCommand("tf_tp_taunt_toggle")
	if table.HasValue(wep, ply:GetActiveWeapon():GetClass()) then ply:SetNWBool("NoWeapon", true) end
	ply:Freeze(true)
	print(time)
	timer.Simple(ply:GetNWBool("SpeechTime"), function()
		if not ply:Alive() and ply:GetNWBool("Taunting") == false then return end
		ply:SetNWBool("Taunting", false)
		ply:ConCommand("tf_tp_taunt_toggle")
		ply:Freeze(false)
		ply:SetNWBool("NoWeapon", false) 
	end)
end)

concommand.Add("tf_taunt1_var", function(ply,cmd,args)
	if ply:IsHL2() then return end
	if SERVER then
	ply:Speak("TLK_PLAYER_TAUNT")
	end
end)