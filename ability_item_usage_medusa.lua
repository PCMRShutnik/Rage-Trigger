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
local castHMDesire = 0;
local castFCDesire = 0;
local abilitySS = nil;
local abilityHM = nil;
local abilityMS = nil;
local abilityFC = nil;
local npcBot = nil;
function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	
	
	if mutil.CanNotUseAbility(npcBot) then return end
	if abilitySS == nil then abilitySS = npcBot:GetAbilityByName( "medusa_split_shot" ) end
	if abilityHM == nil then abilityHM = npcBot:GetAbilityByName( "medusa_mystic_snake" ) end
	if abilityMS == nil then abilityMS = npcBot:GetAbilityByName( "medusa_mana_shield" ) end
	if abilityFC == nil then abilityFC = npcBot:GetAbilityByName( "medusa_stone_gaze" ) end
	
	castHMDesire, castHMTarget = ConsiderHomingMissile();
	castFCDesire  = ConsiderFlakCannon();
	
	if abilitySS:IsTrained() and not abilitySS:GetToggleState() then
		npcBot:Action_UseAbility ( abilitySS );
		return;
	end
	
	if abilityMS:IsTrained() and not abilityMS:GetToggleState() then
		npcBot:Action_UseAbility ( abilityMS );
		return;
	end
	
	if ( castFCDesire > 0 ) 
	then
		npcBot:Action_UseAbility ( abilityFC );
		return;
	end
	
	if ( castHMDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityHM, castHMTarget );
		return;
	end
end
function CanCastHomingMissileOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function ConsiderHomingMissile()
	
	if ( not abilityHM:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityHM:GetCastRange();
	local nDamage = 2*abilityHM:GetSpecialValueInt('snake_damage');
		
	
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
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 100000;
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy ) )
			then
				local nDamage = GetUnitToUnitDistance(npcEnemy, npcBot);
				if ( nDamage < nMostDangerousDamage )
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
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderFlakCannon()
	
	if ( not abilityFC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastRange = abilityFC:GetSpecialValueInt("radius");
	local nAttackRange = npcBot:GetAttackRange();
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nAttackRange, 400, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
		
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
