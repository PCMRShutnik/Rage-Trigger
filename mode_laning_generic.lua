
function GetDesire()
	
	local npcBot = GetBot();
	
	if(DotaTime()<=10*60)
	then
		return 0.25
	elseif(npcBot:GetLevel()<7)
	then
		return 0.4
	else
		return 0.25
	end
end
