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
local castSSDesire = 0;
local castTSDesire = 0;
local castGMDesire = 0;
local castKFDesire = 0;
local abilityTS = nil;
local abilityGM = nil;
local abilitySS = nil;
local abilityKF = nil;
local npcBot = nil;
function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	
	
	if mutil.CanNotUseAbility(npcBot) then return end
	if abilityTS == nil then abilityTS = npcBot:GetAbilityByName( "disruptor_thunder_strike" ) end
	if abilityGM == nil then abilityGM = npcBot:GetAbilityByName( "disruptor_glimpse" ) end
	if abilitySS == nil then abilitySS = npcBot:GetAbilityByName( "disruptor_static_storm" ) end
	if abilityKF == nil then abilityKF = npcBot:GetAbilityByName( "disruptor_kinetic_field" ) end
	
	
	castSSDesire, castSSLocation = ConsiderStaticStorm();
	castKFDesire, castKFLocation = ConsiderKineticField();
	castTSDesire, castTSTarget = ConsiderThunderStorm();
	castGMDesire, castGMTarget = ConsiderGlimpse();
	
	
	if ( castTSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityTS, castTSTarget );
		return;
	end
	
	if ( castKFDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityKF, castKFLocation );
		return;
	end
	
	if ( castSSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilitySS, castSSLocation );
		return;
	end
	
	if ( castGMDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityGM, castGMTarget );
		return;
	end
end
function ConsiderThunderStorm()
	
	if ( not abilityTS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	local nCastRange = abilityTS:GetCastRange();
	local nDamage = 4 * abilityTS:GetAbilityDamage( );
	
	
	
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and 
	   mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) and mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL)
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nCastRange, true );
		for _,npcCreepTarget in pairs(tableNearbyEnemyCreeps) do
			if ( mutil.IsInRange(npcTarget, npcBot, nCastRange) and npcBot:GetMana()/npcBot:GetMaxMana() > 0.6 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcCreepTarget;
			end
		end
	end
	
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderGlimpse()
	
	if ( not abilityGM:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityGM:GetCastRange();
	if nCastRange > 1600 then
		nCastRange = 1600;
	end
	
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	
	
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
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) 
		   and not mutil.IsInRange(npcTarget, npcBot, nCastRange/2) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderStaticStorm()
	
	
	if ( not abilitySS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nRadius = abilitySS:GetSpecialValueInt( "radius" );
	local nCastRange = abilitySS:GetCastRange();
	local nCastPoint = abilitySS:GetCastPoint( );
	local nDamage = 5 * abilitySS:GetSpecialValueInt("damage_max");
	
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if  locationAoE.count >= 2  then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			local EnemyHeroes = npcTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			if ( #EnemyHeroes >= 2 )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderKineticField()
	
	if ( not abilityKF:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nRadius = abilityKF:GetSpecialValueInt( "radius" );
	local nCastRange = abilityKF:GetCastRange();
	local nCastPoint = abilityKF:GetCastPoint( );
	local nDamage = 1000
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcBot:GetLocation();
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if locationAoE.count >= 2 then
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
	return BOT_ACTION_DESIRE_NONE, 0;
end
