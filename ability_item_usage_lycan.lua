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
local castDPDesire = 0;
local castPCDesire = 0;
local castSDDesire = 0;
local abilityDP = nil;
local abilityPC = nil;
local abilitySD = nil;
local npcBot = nil;
function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	
	
	if mutil.CanNotUseAbility(npcBot) then return end
	if abilityDP == nil then abilityDP = npcBot:GetAbilityByName( "lycan_summon_wolves" ) end
	if abilityPC == nil then abilityPC = npcBot:GetAbilityByName( "lycan_howl" ) end
	if abilitySD == nil then abilitySD = npcBot:GetAbilityByName( "lycan_shapeshift" ) end
	
	castDPDesire = ConsiderDarkPact();
	castPCDesire = ConsiderPounce();
	castSDDesire = ConsiderShadowDance();
	
	if ( castDPDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityDP );
		return;
	end
	
	if ( castPCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityPC );
		return;
	end
	
	if ( castSDDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySD );
		return;
	end
end
function ConsiderDarkPact()
	
	if ( not abilityDP:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	local wolves = 0;
	local units = GetUnitList(UNIT_LIST_ALLIES);
	for _,unit in pairs(units)
	do
		if string.find(unit:GetUnitName(), "npc_dota_lycan_wolf") then
			wolves = wolves + 1;
		end
	end
	
	 
	if mutil.IsPushing(npcBot) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 600, 300, 0, 0 );
		if ( locationAoE.count >= 3 and npcBot:GetMana()/npcBot:GetMaxMana() > 0.65 and wolves < 1 ) then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 300)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 800) and wolves < 1 ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderPounce()
	
	if ( not abilityPC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	 
	if mutil.IsPushing(npcBot) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 600, 300, 0, 0 );
		if ( locationAoE.count >= 3 and npcBot:GetMana()/npcBot:GetMaxMana() > 0.5 ) then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 300)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 800)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderShadowDance()
	
	if ( not abilitySD:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 then
			return BOT_ACTION_DESIRE_MODERATE;
		end	
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 600)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
