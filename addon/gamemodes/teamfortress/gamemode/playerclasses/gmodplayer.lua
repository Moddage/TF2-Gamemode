-- Regular GMod player, as if you were playing sandbox

if CLIENT then
	CLASS.ScoreboardImage = {
		surface.GetTextureID("vgui/modicon.vmt"),
	}
end

CLASS.Name = "GMod Player"
CLASS.Speed = 20
CLASS.Health = 100

CLASS.AdditionalAmmo = {
	Pistol = 256,
	SMG1 = 256,
	grenade = 5,
	Buckshot = 64,
	["357"] = 32,
	XBowBolt = 32,
	AR2AltFire = 6,
	AR2 = 100,
	SMG1_Grenade = 6,
}

CLASS.Gibs = {
	[GIB_LEFTLEG]		= GIBS_LAST+1,
	[GIB_RIGHTLEG]		= GIBS_LAST+1, 
	[GIB_RIGHTARM]		= GIBS_LAST+1,
	[GIB_TORSO]			= GIBS_LAST+1,
	[GIB_TORSO2]		= GIBS_LAST+1,
	[GIB_EQUIPMENT1]	= GIBS_LAST+1,
	[GIB_EQUIPMENT2]	= GIBS_LAST+1,
	[GIB_HEAD]			= GIBS_LAST+1,
	[GIB_ORGAN]			= GIBS_ORGANS_START,
}

CLASS.Loadout = {
	"weapon_crowbar",
	"weapon_pistol",
	"weapon_smg1",
	"weapon_frag",
	"weapon_physcannon",
	"weapon_crossbow",
	"weapon_shotgun",
	"weapon_357",
	"weapon_rpg",
	"weapon_ar2",
	
	"gmod_tool",
	"gmod_camera",
	"weapon_physgun",
}

CLASS.ModelName = "scout"

CLASS.IsHL2 = true

CLASS.Gibs = {
	[GIB_LEFTLEG]		= GIBS_HEAVY_START,
	[GIB_RIGHTLEG]		= GIBS_HEAVY_START+1,
	[GIB_RIGHTARM]		= GIBS_HEAVY_START+4,
	[GIB_TORSO]			= GIBS_HEAVY_START+5,
	[GIB_TORSO2]		= GIBS_HEAVY_START+3,
	[GIB_EQUIPMENT1]	= GIBS_HEAVY_START+2,
	[GIB_EQUIPMENT2]	= GIBS_HEAVY_START+2,
	[GIB_HEAD]			= GIBS_HEAVY_START+6,
	[GIB_ORGAN]			= GIBS_ORGANS_START,
}

if SERVER then

function CLASS:Initialize()
	local cl_playermodel = self:GetInfo("cl_playermodel")
	local modelname = player_manager.TranslatePlayerModel(cl_playermodel)
	util.PrecacheModel(modelname)
	self:SetModel(modelname)
	
	local cl_defaultweapon = self:GetInfo("cl_defaultweapon")

	if self:HasWeapon(cl_defaultweapon) then
		self:SelectWeapon(cl_defaultweapon) 
	end
end

end


CLASS.AmmoMax = {
	[TF_PRIMARY]	= 1000000,		-- primary
	[TF_SECONDARY]	= 1000000,		-- secondary
	[TF_METAL]		= 1000000,		-- metal
	[TF_GRENADES1]	= 1000000,		-- grenades1
	[TF_GRENADES2]	= 1000000,		-- grenades2
}