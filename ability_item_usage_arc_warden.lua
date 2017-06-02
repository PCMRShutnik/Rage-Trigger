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
local castMFDesire = 0;
local castWBDesire = 0;
local castPRDesire = 0;
local abilityWA = nil;
local abilityMF = nil;
local abilityWB = nil;
local abilityPR = nil;
local npcBot = nil;
function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	
	
	if mutil.CanNotUseAbility(npcBot) then return end
	if abilityWA == nil then abilityWA = npcBot:GetAbilityByName( "arc_warden_spark_wraith" ) end
	if abilityMF == nil then abilityMF = npcBot:GetAbilityByName( "arc_warden_magnetic_field" ) end
	if abilityWB == nil then abilityWB = npcBot:GetAbilityByName( "arc_warden_tempest_double" ) end
	if abilityPR == nil then abilityPR = npcBot:GetAbilityByName( "arc_warden_flux" ) end
	
	castPRDesire, castPRTarget = ConsiderFlux();
	castWADesire, castWALocation = ConsiderSparkWraith();
	castMFDesire, castMFLocation = ConsiderMagneticField();
	castWBDesire = ConsiderTempestDouble();
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
	
	if ( castMFDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityMF, castMFLocation );
		return;
	end
	
	if ( castWBDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityWB );
		return;
	end
end
function ConsiderSparkWraith()
	
	
	if ( not abilityWA:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	local nRadius = abilityWA:GetSpecialValueInt( "radius" );
	local nCastRange = abilityWA:GetCastRange();
	local nDamage = abilityWA:GetSpecialValueInt("spark_damage");
	local nDelay = abilityWA:GetSpecialValueInt("activation_delay");
	
	
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget)
	then
		if ( mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nDelay );
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
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), 1000, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nDelay );
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderMagneticField()
	
	
	if ( not abilityMF:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	local nRadius = abilityMF:GetSpecialValueInt( "radius" );
	local nCastRange = abilityMF:GetCastRange();
	
	
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
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcBot:GetLocation();
		end
	end
	
	 
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 600, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 and not npcBot:HasModifier("modifier_arc_warden_magnetic_field") ) then
			return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
		end
	end
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( false, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end
	
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( 800, true );
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 800, true );
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 ) or ( tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers >= 1 ) 
		then
			return BOT_ACTION_DESIRE_LOW, npcBot:GetLocation();
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and  mutil.IsInRange(npcTarget, npcBot, nCastRange)  
		then
			local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_ATTACK );
			for _,npcAlly in pairs( tableNearbyAttackingAlliedHeroes )
			do
				if ( mutil.IsInRange(npcAlly, npcBot, nCastRange) and not npcAlly:HasModifier("modifier_arc_warden_magnetic_field")  ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcAlly:GetLocation();
				end
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderFlux()
	
	if ( not abilityPR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityPR:GetCastRange();
	local nDot = abilityPR:GetSpecialValueInt( "damage_per_second" );
	local nDuration = abilityPR:GetSpecialValueInt( "duration" );
	local nDamage = nDot * nDuration;
	
	
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and  
	   mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end
	
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE  );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) )
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
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderTempestDouble()
	local npcBot = GetBot();
	
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
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if mutil.IsInRange(npcTarget, npcBot, 1000)
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1000) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
