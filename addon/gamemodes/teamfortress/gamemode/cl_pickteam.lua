function TeamSelection()


	local ply = LocalPlayer()
	local teamframe = vgui.Create("DFrame") --create a frame
	teamframe:SetSize(128, 128 ) --set its size
	teamframe:Center() --position it at the center of the screen
	teamframe:SetTitle("Team Menu") --set the title of the menu 
	teamframe:SetDraggable(true) --can you move it around
	teamframe:SetSizable(false) --can you resize it?
	teamframe:ShowCloseButton(true) --can you close it
	teamframe:MakePopup() --make it appear
	
	local TeamRed = vgui.Create( "DButton", teamframe )
	function TeamRed.DoClick() RunConsoleCommand( "changeteam", 1 ) teamframe:Close() end
	TeamRed:SetPos( 0, 65 )
	TeamRed:SetSize( 130, 20 )
	TeamRed:SetText( "RED Team" )
	local TeamBlu = vgui.Create( "DButton", teamframe )
	function TeamBlu.DoClick() RunConsoleCommand( "changeteam", 2 ) teamframe:Close() end
	TeamBlu:SetPos( 0, 105 )
	TeamBlu:SetSize( 130, 20 )
	TeamBlu:SetText( "BLU Team" )
	
	if !GetConVar("tf_competitive"):GetBool() then
		local TeamNeu = vgui.Create( "DButton", teamframe )
		function TeamNeu.DoClick() RunConsoleCommand( "changeteam", 4 ) teamframe:Close() end
		TeamNeu:SetPos( 0, 85 )
		TeamNeu:SetSize( 130, 20 )
		TeamNeu:SetText( "Neutral Team" )
	end
	
end


concommand.Add("tf_changeteam", TeamSelection)