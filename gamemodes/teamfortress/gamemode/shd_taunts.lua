local allowedtaunts = {
"1",
"2",
"3",
}

local class_hidewep = {
"scout",
"soldier",
"pyro",
"engineer",
"medic",
}

local wep = {
"tf_weapon_medigun",
"tf_weapon_pistol_scout",
"tf_weapon_rocketlauncher",
"tf_weapon_shotgun_pyro",
"tf_weapon_shotgun_primary",
"tf_weapon_syringegun_medic",
}

concommand.Add("tf_taunt_laugh", function(ply)
	if ply:GetNWBool("Taunting") == true then return end
	if ply:IsHL2() then ply:ConCommand("act laugh") return end
	if not ply:IsOnGround() then return end
	if ply:WaterLevel() ~= 0 then return end
	if ply:GetInfoNum("tf_robot", 0) == 1 then ply:ChatPrint("You can't taunt as a robot!") return end
	local time = ply:PlayScene("scenes/player/"..ply:GetPlayerClass().."/low/taunt_laugh.vcd", 0)
	ply:DoAnimationEvent(ACT_DOD_HS_CROUCH_KNIFE, true)
	ply:SetNWBool("Taunting", true)
	ply:SetNWBool("NoWeapon", true)
	net.Start("ActivateTauntCam")
	net.Send(ply)
	timer.Simple(time, function()
		if not IsValid(ply) or (not ply:Alive() and not ply:GetNWBool("Taunting")) then return end
		ply:SetNWBool("Taunting", false)
		ply:SetNWBool("NoWeapon", false)
		net.Start("DeActivateTauntCam")
		net.Send(ply)
	end)
end)

concommand.Add("tf_taunt", function(ply,cmd,args)
	if ply:GetNWBool("Taunting") == true then return end
	if ply:IsHL2() then ply:ConCommand("act laugh") return end
	if not ply:IsOnGround() then return end
	if ply:WaterLevel() ~= 0 then return end
	if ply:GetInfoNum("tf_robot", 0) == 1 then ply:ChatPrint("You can't taunt as a robot!") return end
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
		ply:DoAnimationEvent(ACT_DOD_STAND_AIM_30CAL, true)
	end
	ply:Speak("TLK_PLAYER_TAUNT")
	ply:SetNWBool("Taunting", true)
	if IsValid(ply:GetActiveWeapon()) and table.HasValue(wep, ply:GetActiveWeapon():GetClass()) then ply:SetNWBool("NoWeapon", true) end
	net.Start("ActivateTauntCam")
	net.Send(ply)

	timer.Simple(ply:GetNWBool("SpeechTime"), function()
		if not IsValid(ply) or (not ply:Alive() and not ply:GetNWBool("Taunting")) then return end
		ply:SetNWBool("Taunting", false)
		ply:SetNWBool("NoWeapon", false)

		net.Start("DeActivateTauntCam")
		net.Send(ply)
	end)
end)

concommand.Add("tf_taunt1_var", function(ply,cmd,args)
	if ply:IsHL2() then return end
	if SERVER and ply:IsSuperAdmin() then
	ply:Speak("TLK_PLAYER_TAUNT")
	end
end)