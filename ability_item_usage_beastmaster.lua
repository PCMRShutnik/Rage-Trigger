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
local castWADesire = 0;
local castWBDesire = 0;
local castPRDesire = 0;
local abilityWA = nil;
local abilityWB = nil;
local abilityPR = nil;
local npcBot = nil;
function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	
	
	if mutil.CanNotUseAbility(npcBot) then return end
	if abilityWA == nil then abilityWA = npcBot:GetAbilityByName( "beastmaster_wild_axes" ) end
	if abilityWB == nil then abilityWB = npcBot:GetAbilityByName( "beastmaster_call_of_the_wild_boar" ) end
	if abilityPR == nil then abilityPR = npcBot:GetAbilityByName( "beastmaster_primal_roar" ) end
	
	castPRDesire, castPRTarget = ConsiderPrimalRoar();
	castWADesire, castWALocation = ConsiderWildAxes();
	castWBDesire = ConsiderWildBoar();
	if ( castPRDesire > castWADesire ) 
	then
		
		npcBot:Action_UseAbilityOnEntity( abilityPR, castPRTarget );
		return;
	end
	if ( castWADesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityWA, castWALocation );
		return;
	end
	
	if ( castWBDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityWB );
		return;
	end
end
function ConsiderWildAxes()
	
	if ( not abilityWA:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nRadius = abilityWA:GetSpecialValueInt( "radius" );
	local nCastRange = abilityWA:GetCastRange();
	local nCastPoint = abilityWA:GetCastPoint( );
	local nDamage = abilityWA:GetSpecialValueInt("axe_damage");
	if nCastRange > 1600 then nCastRange = 1600 end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING and 
		npcBot:GetMana() == npcBot:GetMaxMana() ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		if(tableNearbyEnemyHeroes[1] ~= nil) then
			return BOT_ACTION_DESIRE_MODERATE, tableNearbyEnemyHeroes[1]:GetExtrapolatedLocation( (GetUnitToUnitDistance( tableNearbyEnemyHeroes[1], npcBot )/800) + nCastPoint );
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
	
	
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and
	   mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_PHYSICAL) and mutil.IsInRange(npcTarget, npcBot, nCastRange) 
	then
		return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( (GetUnitToUnitDistance(npcTarget, npcBot )/800) + nCastPoint );
	end
	
	 
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 ) then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end
	
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) 
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and  mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( (GetUnitToUnitDistance(npcTarget, npcBot )/800) + nCastPoint );
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderPrimalRoar()
	
	if ( not abilityPR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityPR:GetCastRange();
	local nDamage = abilityPR:GetSpecialValueInt( "damage" );
	
	
    local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for	_,enemy in pairs(tableNearbyEnemyHeroes)
	do
		if enemy:IsChanneling() and mutil.CanCastOnMagicImmune(enemy) then
			return BOT_ACTION_DESIRE_HIGH, enemy;
		end
	end
	
	
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end
	
    if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and mutil.CanCastOnMagicImmune(npcEnemy) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE  );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if mutil.CanCastOnMagicImmune(npcEnemy) 
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end
		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderWildBoar()
	
	if ( not abilityWB:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 800)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	
	if  mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( 800, true );
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 800, true );
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 ) or ( tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers >= 1 ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 800)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
