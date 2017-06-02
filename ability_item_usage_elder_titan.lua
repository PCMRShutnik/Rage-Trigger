require(GetScriptDirectory() ..  "/logic")
require(GetScriptDirectory() ..  "/ability_item_usage_generic")
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
local castASDesire = 0;
local castSCDesire = 0;
local castSPDesire = 0;
local abilitySC = nil;
local abilityAS = nil;
local abilitySP = nil;
local npcBot = nil;
function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	if mutil.CanNotUseAbility(npcBot) then return end
	if abilitySC == nil then abilitySC = npcBot:GetAbilityByName( "elder_titan_echo_stomp" ) end
	if abilityAS == nil then abilityAS = npcBot:GetAbilityByName( "elder_titan_ancestral_spirit" ) end
	if abilitySP == nil then abilitySP = npcBot:GetAbilityByName( "elder_titan_earth_splitter" ) end
	castSCDesire = ConsiderCrush();
	castASDesire, castASLocation = ConsiderAncestralSpirit();
	castSPDesire, castSPLocation = ConsiderShadowPoison();
	if ( castSPDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilitySP, castSPLocation );
		return;
	end
	if ( castASDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityAS, castASLocation );
		return;
	end
	if ( castSCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySC );
		return;
	end
end
function ConsiderCrush()
	if ( not abilitySC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	local nRadius = abilitySC:GetSpecialValueInt( "radius" );
	local nCastRange = 0;
	local nDamage = abilitySC:GetSpecialValueInt( "stomp_damage" );
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	if mutil.IsPushing(npcBot)
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nRadius, true );
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 and  npcBot:GetMana()/npcBot:GetMaxMana() > 0.6 ) then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange - 150)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderAncestralSpirit()
	if ( not abilityAS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	local nRadius = abilityAS:GetSpecialValueInt( "radius" );
	local nCastRange = abilityAS:GetCastRange();
	local nCastPoint = abilityAS:GetCastPoint( );
	local nDamage = abilityAS:GetSpecialValueInt("pass_damage");
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
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	if ( mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) ) and npcBot:GetMana() / npcBot:GetMaxMana() > 0.6
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange+200, true);
		local locationHAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationHAoE.count >= 2  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationHAoE.targetloc;
		end
		local locationCAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationCAoE.count >= 3 and #lanecreeps >= 3  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationCAoE.targetloc;
		end
	end
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-200)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( 2*nCastPoint );
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderShadowPoison()
	if ( not abilitySP:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	local nRadius = abilitySP:GetSpecialValueInt("crack_width");
	local nCastRange = abilitySP:GetCastRange();
	local nCastPoint = abilitySP:GetCastPoint();
	local nPercentageHP = abilitySP:GetSpecialValueInt("damage_pct");
	local nCrackTime = abilitySP:GetSpecialValueInt("crack_time");
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation( nCastPoint + nCrackTime - 1.5 );
			end
		end
	end
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), 1000, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1000) and 
		   tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint + nCrackTime - 1.5 );
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end
