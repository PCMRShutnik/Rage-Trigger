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
local castCH1Desire = 0;
local castSCDesire = 0;
local castOGDesire = 0;
local castWBDesire = 0;
local abilityWB = nil;
local abilityCH1 = nil;
local abilitySC = nil;
local abilityOG = nil;
local abilityOGS = nil;
local npcBot = nil;
function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	
	
	if mutil.CanNotUseAbility(npcBot) then return end
	if abilityWB == nil then abilityWB = npcBot:GetAbilityByName( "naga_siren_mirror_image" ) end
	if abilityCH1 == nil then abilityCH1 = npcBot:GetAbilityByName( "naga_siren_ensnare" ) end
	if abilitySC == nil then abilitySC = npcBot:GetAbilityByName( "naga_siren_rip_tide" ) end
	if abilityOG == nil then abilityOG = npcBot:GetAbilityByName( "naga_siren_song_of_the_siren" ) end
	if abilityOGS == nil then abilityOGS = npcBot:GetAbilityByName( "naga_siren_song_of_the_siren_cancel" ) end
	
	castWBDesire = ConsiderTempestDouble();
	castCH1Desire, castCH1Target = ConsiderCorrosiveHaze1();
	castSCDesire = ConsiderSlithereenCrush();
	castOGDesire, castOGTarget = ConsiderOvergrowth();
	castOGSDesire = ConsiderSongStop();
	
	if ( castOGSDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityOGS );
		return;
	end
	if ( castOGDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityOG );
		return;
	end
	if ( castSCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySC );
		return;
	end
	if ( castCH1Desire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityCH1, castCH1Target );
		return;
	end
	if ( castWBDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityWB );
		return;
	end
	
end
function ConsiderCorrosiveHaze1()
	
	if ( not abilityCH1:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityCH1:GetCastRange();
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
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
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
			local npcTarget = npcBot:GetTarget();
			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200)
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnMagicImmune(npcEnemy) )
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
function ConsiderSlithereenCrush()
	
	if ( not abilitySC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilitySC:GetSpecialValueInt( "radius" );
	local nCastRange = 0;
	local nDamage = abilitySC:GetAbilityDamage();
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if mutil.IsPushing(npcBot)
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nRadius, true );
		if (  tableNearbyEnemyCreeps ~= nil and # tableNearbyEnemyCreeps >= 3 and npcBot:GetMana()/npcBot:GetMaxMana() > 0.6 ) then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)
		then
			return BOT_ACTION_DESIRE_VERYHIGH;
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderOvergrowth()
	
	if ( not abilityOG:IsFullyCastable() or abilityOG:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilityOG:GetSpecialValueInt( "radius" );
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, 800) and mutil.IsInRange(npcTarget, npcBot, 1300) ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderTempestDouble()
	
	if ( not abilityWB:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	
	
	if  mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( 600, true );
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 600, true );
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 ) or ( tableNearbyEnemyTowers  ~= nil and #tableNearbyEnemyTowers >= 1 ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 )  
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 400)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderSongStop()
	
	if ( not abilityOGS:IsFullyCastable() or abilityOGS:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 400)
		then
			local allies = npcTarget:GetNearbyHeroes(350, true, BOT_MODE_NONE)
			if allies ~= nil and #allies >= 3 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;	
end