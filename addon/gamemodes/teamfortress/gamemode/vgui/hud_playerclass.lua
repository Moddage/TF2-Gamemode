local PANEL = {}

local W = ScrW()
local H = ScrH()
local Scale = H/480

local character_bg = {
	surface.GetTextureID("hud/character_red_bg"),
	surface.GetTextureID("hud/character_blue_bg"),
}
local character_default = surface.GetTextureID("hud/class_scoutred")
local character3d_default = "models/player/spy.mdl"

function PANEL:Init()
	self:SetPaintBackgroundEnabled(false)
	self:ParentToHUD()
	self:SetVisible(true)
end

function PANEL:PerformLayout()
	self:SetPos(0,0)
	self:SetSize(W,H)
end

function PANEL:Paint()
	if not LocalPlayer():Alive() or LocalPlayer():IsHL2() or GetConVar("hud_forcehl2hud"):GetBool() or GAMEMODE.ShowScoreboard or GetConVarNumber("cl_drawhud")==0 or LocalPlayer():Team() == TEAM_SPECTATOR or LocalPlayer():GetPlayerClass()=="" then if self.ClassPanel then self.ClassPanel:Remove() self.ClassPanel = nil end return end
	
	local t = LocalPlayer():Team()
	local tbl = LocalPlayer():GetPlayerClassTable()

	if LocalPlayer():GetObserverTarget() and LocalPlayer():GetObserverTarget():IsPlayer() then
		t = LocalPlayer():GetObserverTarget():Team()
		tbl = LocalPlayer():GetObserverTarget():GetPlayerClassTable()
	end

	--ht = ACT_MP_STAND_..LocalPlayer():GetActiveWeapon().HoldType
	--[[model = LocalPlayer():GetPlayerClass()

	if not self.ClassPanel then
		p = vgui.Create("ClassModelPanel")

		p:SetParent(self)
		p:SetPos(W/2-100*Scale, 20*Scale)
		p:SetSize(200*Scale, 360*Scale)
		p.FOV = 50
		p.spotlight = true

		--t:AddModel(3,"models/player/items/all_class/all_halo.mdl",{
			--Parent = 1,
		--})
	end

	if not LocalPlayer():GetPlayerClass() == model then
		self.ModelSet = false
	end

	if self.ClassPanel and not self.ModelSet then
		p:SetSkin( LocalPlayer():GetSkin() )

		if LocalPlayer():GetPlayerClass() == "demoman" then
			model = "demo"
		end
		
		p:AddModel(1, "models/player/"..model..".mdl",{
			Pos = Vector(220, 0, -36),
			Ang = Angle(0, 220, 0),
		})

		if model == LocalPlayer():GetPlayerClass() then
			self.ModelSet = true
		end
	end

		p:StartAnimation(1, LocalPlayer():GetSequenceActivity( LocalPlayer():GetSequence() ))

		--t:GetModelEntity(1):SetPoseParameter("move_x",1)
		--t:GetModelEntity(1):SetPoseParameter("body_pitch",90)
		self.ClassPanel = p

		--print("ACT_MP_STAND_"..LocalPlayer():GetActiveWeapon().HoldType)]]
	
	local tex = character_bg[t] or character_bg[1]
	surface.SetTexture(tex)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(9*Scale, (480-60)*Scale, 100*Scale, 50*Scale)
	
	tex = character_default
	if tbl and tbl.CharacterImage and tbl.CharacterImage[1] then
		tex = tbl.CharacterImage[t] or tbl.CharacterImage[1]
	end
	surface.SetTexture(tex)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(25*Scale, (480-88)*Scale, 75*Scale, 75*Scale)
end

if HudPlayerClass then HudPlayerClass:Remove() end
HudPlayerClass = vgui.CreateFromTable(vgui.RegisterTable(PANEL, "DPanel"))
