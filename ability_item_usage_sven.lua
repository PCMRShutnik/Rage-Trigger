
require(GetScriptDirectory() ..  "/logic")
require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local debugmode=false
local npcBot = GetBot()
local Talents ={}
local Abilities ={}
local AbilitiesReal ={}
ability_item_usage_generic.InitAbility(Abilities,AbilitiesReal,Talents) 
local AbilityToLevelUp=
{
	Abilities[1],
	Abilities[2],
	Abilities[1],
	Abilities[3],
	Abilities[1],
	Abilities[4],
	Abilities[2],
	Abilities[1],
	Abilities[2],
	"talent",
	Abilities[2],
	Abilities[4],
	Abilities[3],
	Abilities[3],
	"talent",
	Abilities[3],
	"nil",
	Abilities[4],
	"nil",
	"talent",
	"nil",
	"nil",
	"nil",
	"nil",
	"talent",
}
local TalentTree={
	function()
		return Talents[1]
	end,
	function()
		return Talents[4]
	end,
	function()
		return Talents[5]
	end,
	function()
		return Talents[7]
	end
}
logic.CheckAbilityBuild(AbilityToLevelUp)
function AbilityLevelUpThink()
	ability_item_usage_generic.AbilityLevelUpThink2(AbilityToLevelUp,TalentTree)
end
local cast={} cast.Desire={} cast.Target={} cast.Type={}
local Consider ={}
local CanCast={logic.NCanCast,logic.NCanCast,logic.NCanCast,logic.UCanCast}
local enemyDisabled=logic.enemyDisabled
function GetComboDamage()
	return ability_item_usage_generic.GetComboDamage(AbilitiesReal)
end
function GetComboMana()
	return ability_item_usage_generic.GetComboMana(AbilitiesReal)
end
Consider[1]=function()
	local abilityNumber=1
	
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = ability:GetCastRange();
	local Damage = ability:GetAbilityDamage();
	local CastPoint = ability:GetCastPoint();
	
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(CastRange+300,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(CastRange+300,true)
	local WeakestCreep,CreepHealth=logic.GetWeakestUnit(creeps)
	
	
	for _,npcEnemy in pairs( enemys )
	do
		if ( npcEnemy:IsChanneling() and CanCast[abilityNumber]( npcEnemy )) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy
		end
	end
	
	
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			if ( CanCast[abilityNumber]( WeakestEnemy ) )
			then
				if(HeroHealth<=WeakestEnemy:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL) or (HeroHealth<=WeakestEnemy:GetActualIncomingDamage(GetComboDamage(),DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana))
				then
					return BOT_ACTION_DESIRE_HIGH,WeakestEnemy; 
				end
			end
		end
	end
	
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;
		for _,npcEnemy in pairs( enemys )
		do
			if ( CanCast[abilityNumber]( npcEnemy ) and not enemyDisabled(npcEnemy))
			then
				local Damage2 = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( Damage2 > nMostDangerousDamage )
				then
					nMostDangerousDamage = Damage2;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end
		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		for _,npcEnemy in pairs( enemys )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCast[abilityNumber]( npcEnemy ) and not enemyDisabled(npcEnemy)) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end
		end
	end
	

	if ( npcBot:GetActiveMode() == BOT_MODE_LANING ) 
	then
		if((ManaPercentage>0.6 or npcBot:GetMana()>ComboMana) and ability:GetLevel()>=2 )
		then
			if (WeakestEnemy~=nil)
			then
				if ( CanCast[abilityNumber]( WeakestEnemy ) )
				then
					return BOT_ACTION_DESIRE_LOW,WeakestEnemy;
				end
			end
		end
	end
	  
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM )
	then
		if ( #creeps >= 2 ) 
		then
			if(CreepHealth<=WeakestCreep:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana)
			then
				return BOT_ACTION_DESIRE_LOW, WeakestCreep;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		if ( #enemys>=1) 
		then
			if (ManaPercentage>0.5 or npcBot:GetMana()>ComboMana and AbilitiesReal[abilityNumber]:GetLevel()>=1)
			then
				if (WeakestEnemy~=nil)
				then
					if ( CanCast[abilityNumber]( WeakestEnemy )and GetUnitToUnitDistance(npcBot,WeakestEnemy)< CastRange + 75*#allys )
					then
						return BOT_ACTION_DESIRE_LOW, WeakestEnemy;
					end
				end
			end
		end
		
		if (#creeps >= 6 ) 
		then
			if (ManaPercentage>0.9 or npcBot:GetMana()>ComboMana and AbilitiesReal[abilityNumber]:GetLevel()>=1)
			then
					if ( CanCast[abilityNumber]( creeps[1] )and GetUnitToUnitDistance(npcBot,creeps[1])< CastRange + 75*#allys )
					then
						return BOT_ACTION_DESIRE_LOW, creeps[1];
					end
			end
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local npcEnemy = npcBot:GetTarget();
		if ( npcEnemy ~= nil ) 
		then
			if ( CanCast[abilityNumber]( npcEnemy ) and not enemyDisabled(npcEnemy) and GetUnitToUnitDistance(npcBot,npcEnemy)< CastRange + 75*#allys)
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
	
end
Consider[3]=function() 
	
	local abilityNumber=3
	
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = 0;
	local Damage = ability:GetAbilityDamage();
	local Radius = ability:GetAOERadius()
	local CastPoint = ability:GetCastPoint();
	
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(Radius,true,BOT_MODE_NONE)
	local enemys2 = npcBot:GetNearbyHeroes(Radius,false,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local creeps2 = npcBot:GetNearbyCreeps(Radius,false)
	local tower = npcBot:GetNearbyTowers(Radius,true)
	
	 
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) 
	then
		return BOT_ACTION_DESIRE_LOW
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT  ) 
	then
		if ( #creeps2 >= 6 and #tower>=1) 
		then
			return BOT_ACTION_DESIRE_LOW
		end
		if (#creeps2 <= 5) 
		then
			return BOT_ACTION_DESIRE_NONE
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		if ( npcBot:WasRecentlyDamagedByAnyHero( 2.0 ) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK) 
	then
		local npcEnemy = npcBot:GetTarget();
		if ( npcEnemy ~= nil ) 
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
	
end
Consider[4]=function()
	local abilityNumber=4
	
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = 0;
	local Damage = ability:GetAbilityDamage();
	local Radius = ability:GetAOERadius()
	local CastPoint = ability:GetCastPoint();
	
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(Radius,true,BOT_MODE_NONE)
	local enemys2 = npcBot:GetNearbyHeroes(Radius,false,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local creeps2 = npcBot:GetNearbyCreeps(Radius,false)
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			if(HeroHealth<=WeakestEnemy:GetActualIncomingDamage(GetComboDamage(),DAMAGE_TYPE_PHYSICAL))
			then
				return BOT_ACTION_DESIRE_HIGH,WeakestEnemy; 
			end
		end
	end
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local npcEnemy = npcBot:GetTarget();
		if ( npcEnemy ~= nil ) 
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end
function AbilityUsageThink()
	
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() )
	then 
		return
	end
	
	ComboMana=GetComboMana()
	AttackRange=npcBot:GetAttackRange()
	ManaPercentage=npcBot:GetMana()/npcBot:GetMaxMana()
	HealthPercentage=npcBot:GetHealth()/npcBot:GetMaxHealth()
	
	cast=ability_item_usage_generic.ConsiderAbility(AbilitiesReal,Consider)
	
	if(debugmode==true)
	then
		ability_item_usage_generic.PrintDebugInfo(AbilitiesReal,cast)
	end
	ability_item_usage_generic.UseAbility(AbilitiesReal,cast)
end
function CourierUsageThink() 
	ability_item_usage_generic.CourierUsageThink()
end