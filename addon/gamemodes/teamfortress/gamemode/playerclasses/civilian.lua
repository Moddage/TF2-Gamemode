CLASS.Name = "Civilian"
CLASS.Speed = 100
CLASS.Health = 100

if CLIENT then
	CLASS.CharacterImage = {
		surface.GetTextureID("hud/class_scoutred"),
		surface.GetTextureID("hud/class_scoutblue")
	}
	CLASS.ScoreboardImage = {
		surface.GetTextureID("hud/leaderboard_class_dead"),
		surface.GetTextureID("hud/leaderboard_class_dead")
	}
end

CLASS.Loadout = {""}
CLASS.DefaultLoadout = {""}
CLASS.ModelName = "scout"

CLASS.Gibs = {
	[GIB_LEFTLEG]		= GIBS_SCOUT_START,
	[GIB_RIGHTLEG]		= GIBS_SCOUT_START+1,
	[GIB_LEFTARM]		= GIBS_SCOUT_START+3,
	[GIB_RIGHTARM]		= GIBS_SCOUT_START+4,
	[GIB_TORSO]			= GIBS_SCOUT_START+5,
	[GIB_TORSO2]		= GIBS_SCOUT_START+2,
	[GIB_HEAD]			= GIBS_SCOUT_START+6,
	[GIB_HEADGEAR1]		= GIBS_SCOUT_START+7,
	[GIB_HEADGEAR2]		= GIBS_SCOUT_START+8,
	[GIB_ORGAN]			= GIBS_ORGANS_START,
}

CLASS.Sounds = {
	paincrticialdeath = {
	},
	painsevere = {
	},
	painsharp = {
	},
}

CLASS.AmmoMax = {
	[TF_PRIMARY]	= 0,		-- primary
	[TF_SECONDARY]	= 0,		-- secondary
	[TF_METAL]		= 0,		-- metal
	[TF_GRENADES1]	= 0,		-- grenades1
	[TF_GRENADES2]	= 0,		-- grenades2
}
