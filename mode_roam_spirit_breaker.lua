
function GetDesire()
	local npcBot = GetBot();
	if(npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness") or npcBot.SBTarget~=nil)
	then
		return 90
	end
	return 0
end
function Think()
	local npcBot = GetBot();
	local de=GetUnitToUnitDistance(npcBot,npcEnemy);
	local da=GetUnitToUnitDistance(npcBot,npcally);
	if(npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness")==false or (npcBot.SBTarget:DistanceFromFountain()<=4000 and DotaTime()<=30*60))
	then
		npcBot.SBTarget=nil
	end
	if((de>1200) and DotaTime()<=4*60)
	then
		npcBot.SBTarget=nil
	end
	if ((de>600) and (da>800) and DotaTime()<=4*60)
	then
		npcBot.SBTarget=nil
	end
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness") )
	then 
		return
	end
	local npcEnemy = npcBot:GetTarget();
	if ( npcEnemy ~= nil and npcEnemy:IsAlive()) 
	then
		local de=GetUnitToUnitDistance(npcBot,npcEnemy);
		local da=GetUnitToUnitDistance(npcBot,npcally);
		if ((de<600) and (da<800) and DotaTime()>=4*60)
		then
			npcBot:Action_AttackUnit(npcEnemy,true);
		else
			npcBot:Action_MoveToUnit(npcEnemy);
		end
	end
	return
end