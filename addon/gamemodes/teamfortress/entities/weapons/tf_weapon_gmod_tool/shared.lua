SWEP.Base				= "gmod_tool"

SWEP.ViewModel			= "models/weapons/v_models/v_revolver_spy.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_revolver.mdl"
SWEP.ShootSound = Sound("Weapon_Revolver.Single")

-- Trace a line then send the result to a mode function
function SWEP:PrimaryAttack()

	local mode = self:GetMode()
	local tr = util.GetPlayerTrace( self.Owner )
	tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
	local trace = util.TraceLine( tr )
	if ( !trace.Hit ) then return end

	local tool = self:GetToolObject()
	if ( !tool ) then return end

	tool:CheckObjects()
 
	-- Does the server setting say it's ok?
	if ( !tool:Allowed() ) then return end

	-- Ask the gamemode if it's ok to do this
	if ( !gamemode.Call( "CanTool", self.Owner, trace, mode ) ) then return end

	if ( !tool:LeftClick( trace ) ) then return end

	self:DoShootEffect( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted() )
	self:SetNextPrimaryFire(CurTime() + 0.5)

end