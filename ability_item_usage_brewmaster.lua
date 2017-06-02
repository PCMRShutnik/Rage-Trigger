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
local castPSDesire = 0;
local castTCDesire = 0;
local abilityTC = nil;
local abilityDH = nil;
local abilityPS = nil;
local npcBot = nil;
function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	
	
	if mutil.CanNotUseAbility(npcBot) then return end
	if abilityTC == nil then abilityTC = npcBot:GetAbilityByName( "brewmaster_thunder_clap" ) end
	if abilityDH == nil then abilityDH = npcBot:GetAbilityByName( "brewmaster_drunken_haze" ) end
	if abilityPS == nil then abilityPS = npcBot:GetAbilityByName( "brewmaster_primal_split" ) end
	
	
	castTCDesire = ConsiderThunderClap();
	castDHDesire, castDHTarget = ConsiderDrunkenHaze();
	castPSDesire = ConsiderPrimalSplit();
	if ( castDHDesire > castPSDesire and castDHDesire > castTCDesire ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityDH, castDHTarget );
		return;
	end
		
	if ( castTCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityTC );
		return;
	end
	if ( castPSDesire > 0  ) 
	then
		npcBot:Action_UseAbility( abilityPS );
		return;
	end
end
function ConsiderThunderClap()
	
	if ( not abilityTC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilityTC:GetSpecialValueInt( "radius" );
	local nCastRange = 0;
	local nDamage = abilityTC:GetSpecialValueInt("damage");
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)  )
		then
			return BOT_ACTION_DESIRE_LOW;
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
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius - 50)
		then
			return BOT_ACTION_DESIRE_VERYHIGH;
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderPrimalSplit()
	
	if ( not abilityPS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	if #tableNearbyAllyHeroes == 0 then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local distance = 300;
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 and tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 3 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 400) 
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			local tableNearbyAlly = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_ATTACK );
			if tableNearbyEnemyHeroes ~= nil and tableNearbyAlly ~= nil and #tableNearbyEnemyHeroes >= 2 and #tableNearbyAlly >= 2 then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderDrunkenHaze()
	
	if ( not abilityDH:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityDH:GetCastRange();
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
			local npcTarget = npcBot:GetTarget();
			if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and
			     mutil.IsInRange(npcTarget, npcBot, nCastRange) and not npcTarget:HasModifier("modifier_brewmaster_drunken_haze") )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
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
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if mutil.CanCastOnNonMagicImmune(npcEnemy) and not npcEnemy:HasModifier("modifier_brewmaster_drunken_haze") 
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
	return BOT_ACTION_DESIRE_NONE, 0;
end
