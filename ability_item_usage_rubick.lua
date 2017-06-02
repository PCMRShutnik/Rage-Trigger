if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end
local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_shutnik" )
local utils = require(GetScriptDirectory() ..  "/util")
local skills = require(GetScriptDirectory() ..  "/Skillslogic")
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
local castUFBDesire = 0;
local castIGDesire = 0;
local castTLDesire = 0;
local abilityUFB = nil;
local abilityFB = nil;
local abilityTL = nil;
local abilityIG = nil;
local ability4 = nil;
local ability5 = nil;
local setTarget = false;
local npcBot = nil;
function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	
	if mutil.CanNotUseAbility(npcBot) then return end
	if abilityUFB == nil then abilityUFB = npcBot:GetAbilityByName( "rubick_spell_steal" ) end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "rubick_telekinesis" ) end
	if abilityTL == nil then abilityTL = npcBot:GetAbilityByName( "rubick_telekinesis_land" ) end
	if abilityIG == nil then abilityIG = npcBot:GetAbilityByName( "rubick_fade_bolt" ) end
	ability4 = npcBot:GetAbilityInSlot(4) 
	ability5 = npcBot:GetAbilityInSlot(5)
	
	castFBDesire, castFBTarget = ConsiderFireblast();
	castTLDesire, castTLLocation = ConsiderTeleLand();
	castUFBDesire, castUFBTarget = ConsiderUnrefinedFireblast();
	castIGDesire, castIGTarget = ConsiderIgnite();
	
	if ( castUFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityUFB, castUFBTarget );
		return;
	end
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		setTarget = false;
		return;
	end
	
	if ( castTLDesire > 0 and not setTarget ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTL, castTLLocation );
		setTarget = true;
		return;
	end
	if ( castIGDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityIG, castIGTarget );
		return;
	end
	
	skills.CastStolenSpells(ability4);
	skills.CastStolenSpells(ability5);
end
function ConsiderFireblast()
	
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityFB:GetCastRange();
	
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
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
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) and
           not mutil.IsDisabled(true, npcTarget)		
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderTeleLand()
	
	if ( not abilityTL:IsFullyCastable() or abilityTL:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityFB:GetCastRange();
	local nRadius = abilityTL:GetSpecialValueInt("radius");
	
	if ( npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or npcBot:GetActiveMode() == BOT_MODE_RETREAT  ) 
	then
		return BOT_ACTION_DESIRE_MODERATE, npcBot:GetXUnitsInFront( nCastRange + nRadius );
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		return BOT_ACTION_DESIRE_MODERATE, npcBot:GetLocation();
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderIgnite()
	
	if ( not abilityIG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	local nCastRange = abilityIG:GetCastRange();
	local nDamage = abilityIG:GetSpecialValueInt( "damage" );
	
	
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
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	
	if ( mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) ) and npcBot:GetMana()/npcBot:GetMaxMana() > 0.8 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 and tableNearbyEnemyCreeps[1] ~= nil
		then
			return BOT_ACTION_DESIRE_MODERATE, tableNearbyEnemyCreeps[1];
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderUnrefinedFireblast()
	
	if ( not abilityUFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	if not string.find(ability4:GetName(), 'empty') and not ability4:IsToggle() and ability4:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityUFB:GetCastRange();
	
	
	
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
