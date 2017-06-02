if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end
local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_shutnik" )
local utils = require(GetScriptDirectory() ..  "/util")
local mutil = require(GetScriptDirectory() ..  "/Mylogic")
function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end
local castFBDesire = 0;
local castCSDesire = 0;
local castCSSDesire = 0;
local castCS2Desire = 0;
local castBLDesire = 0;
local castFGDesire = 0;
local castRCDesire = 0;
local CancelIlmDesire = 0;
local abilityFB = nil;
local abilityCS = nil;
local abilityCSS = nil;
local abilityCS2 = nil;
local abilityBL = nil;
local abilityFB = nil;
local abilityRC = nil;
local npcBot = nil;
function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	
	
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "keeper_of_the_light_mana_leak" ) end
	if abilityCS == nil then abilityCS = npcBot:GetAbilityByName( "keeper_of_the_light_illuminate" ) end
	if abilityCSS == nil then abilityCSS = npcBot:GetAbilityByName( "keeper_of_the_light_spirit_form_illuminate" ) end
	if abilityCS2 == nil then abilityCS2 = npcBot:GetAbilityByName( "keeper_of_the_light_blinding_light" ) end
	if abilityBL == nil then abilityBL = npcBot:GetAbilityByName( "keeper_of_the_light_chakra_magic" ) end
	if abilityFG == nil then abilityFG = npcBot:GetAbilityByName( "keeper_of_the_light_spirit_form" ) end
	if abilityRC == nil then abilityRC = npcBot:GetAbilityByName( "keeper_of_the_light_recall" ) end
	
	CancelIlmDesire = ConsiderCancelIlm();
	
	if CancelIlmDesire > 0 then
		npcBot:Action_MoveToLocation(npcBot:GetLocation()+RandomVector(200))
		return
	end
	
	if mutil.CanNotUseAbility(npcBot) then return end
	
	castFBDesire, castFBTarget = ConsiderFireblast();
	castCSDesire, castCSLocation = ConsiderChrono();
	castCSSDesire, castCSSLocation = ConsiderChronoS();
	castCS2Desire, castCS2Location = ConsiderChrono2();
	castBLDesire, castBLTarget = ConsiderBloodlust();
	castFGDesire, castFGTarget = ConsiderFleshGolem();
	castRCDesire, castRCTarget = ConsiderRecall();
	
	if ( castFGDesire > 0 ) 
	then
		
		npcBot:Action_UseAbility( abilityFG );
		return;
	end
	
	if ( castCS2Desire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnLocation( abilityCS2, castCS2Location );
		return;
	end	
	
	if ( castFBDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end
	
	if ( castCSDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnLocation( abilityCS, castCSLocation );
		return;
	end	
	if ( castCSSDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnLocation( abilityCSS, castCSSLocation );
		return;
	end	
	
	if ( castBLDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnEntity( abilityBL, castBLTarget );
		return;
	end
	
	if ( castRCDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnEntity( abilityRC, castRCTarget );
		return;
	end
	
	
	
end
function ConsiderFireblast()
	
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityFB:GetCastRange();
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderChrono()
	
	if ( npcBot:HasScepter() or npcBot:HasModifier("modifier_keeper_of_the_light_spirit_form") or not abilityCS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nRadius = abilityCS:GetSpecialValueInt("radius");
	local nCastRange = abilityCS:GetCastRange();
	local nCastPoint = abilityCS:GetCastPoint();
	
	if nCastRange > 1600 then
		nCastRange = 1600;
	end
	
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(1600, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderChronoS()
	
	if ( not abilityCSS:IsFullyCastable() or abilityCSS:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nRadius = abilityCS:GetSpecialValueInt("radius");
	local nCastRange = abilityCS:GetCastRange();
	local nCastPoint = abilityCS:GetCastPoint();
	if nCastRange > 1600 then
		nCastRange = 1600;
	end
	
	
	if mutil.IsRetreating(npcBot) and ( npcBot:HasModifier("modifier_keeper_of_the_light_spirit_form") or npcBot:HasScepter() ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 )
			then
				return BOT_ACTION_DESIRE_LOW, npcBot:GetXUnitsInFront(400);
			end
		end
	end
	
	
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(1600, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderBloodlust()
	
	if ( not abilityBL:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityBL:GetCastRange();
	
	if  npcBot:GetMana() / npcBot:GetMaxMana() < 0.8 then
		return BOT_ACTION_DESIRE_MODERATE, npcBot;
	else
		local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
		for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
			if ( mutil.CanCastOnNonMagicImmune(myFriend) and myFriend:GetMana() / myFriend:GetMaxMana() < 0.65  ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, myFriend;
			end
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderFleshGolem()
	
	if ( npcBot:HasScepter() or npcBot:HasModifier("modifier_keeper_of_the_light_spirit_form") or not abilityFG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = 1000;
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE  );
		if ( #tableNearbyEnemyHeroes >= 2 )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1000)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderChrono2()
	
	if ( not npcBot:HasModifier("modifier_keeper_of_the_light_spirit_form") or abilityCS2:IsHidden() or not abilityCS2:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nRadius = abilityCS2:GetSpecialValueInt("radius");
	local nCastRange = abilityCS2:GetCastRange();
	local nCastPoint = abilityCS2:GetCastPoint();
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) )
			then
				if GetUnitToUnitDistance(npcEnemy, npcBot) < nRadius then
					return BOT_ACTION_DESIRE_LOW, npcBot:GetLocation()
				else
					return BOT_ACTION_DESIRE_LOW, npcEnemy:GetExtrapolatedLocation(nCastPoint)
				end
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange - (nRadius / 2))
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderRecall()
	
	if ( not npcBot:HasModifier("modifier_keeper_of_the_light_spirit_form") or abilityRC:IsHidden() or not abilityRC:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local player = GetTeamMember(i);
		if player ~= nil and not IsPlayerBot(player:GetPlayerID()) and player:IsAlive() and GetUnitToUnitDistance(npcBot, player) > 1000 then
				local p = player:GetMostRecentPing();
				if p ~= nil and GetUnitToLocationDistance(player, p.location) < 1000 and GameTime() - p.time < 10 then
					return BOT_ACTION_DESIRE_MODERATE, player;
				end
		end
	end
	
	if  mutil.IsDefending(npcBot)
	then
		local nearbyTower = npcBot:GetNearbyTowers(1000, false) 
		if nearbyTower[1] ~= nil then
			local maxDist = 0;
			local target = nil;
			for i = 1, #numPlayer
			do
				local player = GetTeamMember(i);
				if player ~= nil and player:IsAlive() and player:GetActiveMode() ~= BOT_MODE_RETREAT then
					local dist = GetUnitToUnitDistance(nearbyTower[1], player);
					local health = player:GetHealth()/player:GetMaxHealth();
					if IsPlayerBot(player:GetPlayerID()) and dist > maxDist and dist > 2500 and health >= 0.25 then
						maxDist = dist;
						target = GetTeamMember(i);
					end
				end
			end
			if target ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, target;
			end
		end
	end
	
	if mutil.IsPushing(npcBot)
	then
		local nearbyTower = npcBot:GetNearbyTowers(1000, true) 
		if nearbyTower[1] ~= nil then
			local maxDist = 0;
			local target = nil;
			for i = 1, #numPlayer
			do
				local player = GetTeamMember(i);
				if player ~= nil and player:IsAlive() and player:GetActiveMode() ~= BOT_MODE_RETREAT then
					local dist = GetUnitToUnitDistance(nearbyTower[1], player);
					local health = player:GetHealth()/player:GetMaxHealth();
					if IsPlayerBot(player:GetPlayerID()) and dist > maxDist and dist > 2500 and health >= 0.25  then
						maxDist = dist;
						target = GetTeamMember(i);
					end
				end
			end
			if target ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, target;
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil  and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < 1000  ) 
		then	
			local maxDist = 0;
			local target = nil;
			for i = 1, #numPlayer
			do
				local player = GetTeamMember(i);
				if player ~= nil and player:IsAlive() and player:GetActiveMode() ~= BOT_MODE_RETREAT then
					local dist = GetUnitToUnitDistance(player, npcBot);
					local health = player:GetHealth()/player:GetMaxHealth();
					if IsPlayerBot(player:GetPlayerID()) and dist > maxDist and dist > 2500 and health >= 0.25 then
						maxDist = dist;
						target = GetTeamMember(i);
					end
				end
			end
			if target ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, target;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderCancelIlm()
	if not npcBot:IsChanneling() or not npcBot:HasModifier('modifier_keeper_of_the_light_illuminate')  then return BOT_MODE_NONE; end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	
	if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 and npcBot:WasRecentlyDamagedByAnyHero(2.0) then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
end