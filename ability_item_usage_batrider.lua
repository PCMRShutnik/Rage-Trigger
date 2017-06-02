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
local castSNDesire = 0;
local castFFDesire = 0;
local castFBDesire = 0;
local castFLDesire = 0;
local abilitySN = nil;
local abilityFB = nil;
local abilityFF = nil;
local abilityFL = nil;
local npcBot = nil;
function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	
	
	if mutil.CanNotUseAbility(npcBot) then return end
	if abilitySN == nil then abilitySN = npcBot:GetAbilityByName( "batrider_sticky_napalm" ); end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "batrider_flamebreak" ); end
	if abilityFF == nil then abilityFF = npcBot:GetAbilityByName( "batrider_firefly" ); end
	if abilityFL == nil then abilityFL = npcBot:GetAbilityByName( "batrider_flaming_lasso" ); end
	
	castSNDesire, castDCLocation = ConsiderStickyNapalm();
	castFBDesire, castFBLocation = ConsiderFlameBreak();
	castFFDesire = ConsiderFireFly();
	castFLDesire, castFLTarget = ConsiderFlamingLasso();
	
	if ( castFLDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFL, castFLTarget );
		return;
	end
	
	if ( castFFDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityFF );
		return;
	end
	if ( castSNDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilitySN, castDCLocation );
		return;
	end
	
	if ( castFBDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnLocation( abilityFB, castFBLocation );
		return;
	end	
	
end
function ConsiderStickyNapalm()
	
	
	if ( not abilitySN:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nRadius = abilitySN:GetSpecialValueInt( "radius" );
	local nCastRange = abilitySN:GetCastRange();
	local nCastPoint = abilitySN:GetCastPoint( );
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	
	if  ( npcBot:GetActiveMode() == BOT_MODE_LANING or
		mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) ) and npcBot:GetMana() / npcBot:GetMaxMana() > 0.8
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange+200, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4   ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderFlameBreak()
	
	if ( not abilityFB:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nRadius = abilityFB:GetSpecialValueInt("explosion_radius");
	local nSpeed = abilityFB:GetSpecialValueInt("speed");
	local nCastRange = abilityFB:GetCastRange();
	local nCastPoint = abilityFB:GetCastPoint();
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) )
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
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1000) ) 
		then
			local nDelay = ( GetUnitToUnitDistance( npcTarget, npcBot ) / nSpeed ) + nCastPoint
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nDelay);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderFireFly()
	
	if ( not abilityFF:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilityFF:GetSpecialValueInt( "radius" );
	
	if mutil.IsStuck(npcBot)
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE  );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1000)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderFlamingLasso()
	
	if ( not abilityFL:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityFL:GetCastRange();
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local npcToKill = nil;
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if mutil.CanCastOnMagicImmune(npcEnemy) and mutil.IsInRange(npcEnemy, npcBot, nCastRange+200)
			then
				npcToKill = npcEnemy;
			end
		end
		if ( npcToKill ~= nil  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcToKill;
		end
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if mutil.CanCastOnMagicImmune(npcEnemy)
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end
