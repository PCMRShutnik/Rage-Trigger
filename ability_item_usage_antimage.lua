
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
	Abilities[2],
	Abilities[3],
	Abilities[2],
	Abilities[4],
	Abilities[2],
	Abilities[1],
	Abilities[1],
	"talent",
	Abilities[1],
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
		return Talents[3]
	end,
	function()
		return Talents[6]
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
Consider[2]=function()
		local abilityNumber=2
	local ability=AbilitiesReal[abilityNumber];
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	local CastRange = ability:GetSpecialValueInt( "blink_range" );
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(CastRange+200,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local trees= npcBot:GetNearbyTrees(200)
	if(npcBot.Blink==nil or DotaTime()-npcBot.Blink.Timer>=10)
	then
		npcBot.Blink={Point=npcBot:GetLocation(),Timer=DotaTime()}
	end
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			local enemys2= WeakestEnemy:GetNearbyHeroes(900,true,BOT_MODE_NONE)
			if ( CanCast[abilityNumber]( WeakestEnemy ) and #enemys2<=2)
			then
				if(HeroHealth<=WeakestEnemy:GetActualIncomingDamage(GetComboDamage(),DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana)
				then
					return BOT_ACTION_DESIRE_HIGH,GetUnitsTowardsLocation(npcBot,WeakestEnemy,150); 
				end
			end
		end
	end
	if(trees~=nil and #trees>=10 or (logic.PointToPointDistance(npcBot:GetLocation(),npcBot.Blink.Point)<=100 and DotaTime()-npcBot.Blink.Timer<10 and DotaTime()-npcBot.Blink.Timer>8))
	then
		return BOT_ACTION_DESIRE_HIGH, GetUnitsTowardsLocation(npcBot,GetAncient(GetTeam()),CastRange)
	end
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:DistanceFromFountain()>=2000 and (ManaPercentage>=0.6 or npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH)) 
	then
		return BOT_ACTION_DESIRE_HIGH, GetUnitsTowardsLocation(npcBot,GetAncient(GetTeam()),CastRange)
	end
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local npcEnemy = npcBot:GetTarget();
		if(ManaPercentage>0.4 or npcBot:GetMana()>ComboMana)
		then
			if ( npcEnemy ~= nil ) 
			then
				local enemys2= npcEnemy:GetNearbyHeroes(900,false,BOT_MODE_NONE)
				if (enemys2~=nil and #enemys2<=2)
				then
					if ( CanCast[abilityNumber]( npcEnemy )  and GetUnitToUnitDistance(npcBot,npcEnemy)< CastRange + 75*#allys)
					then
						return BOT_ACTION_DESIRE_MODERATE, GetUnitsTowardsLocation(npcBot,npcEnemy,200);
					end
				end
			end
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
	
	local CastRange = ability:GetCastRange();
	local DamagePercent = ability:GetSpecialValueFloat("mana_void_damage_per_mana")
	local Radius = ability:GetAOERadius();
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(CastRange+300,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	
	
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		for i,npcEnemy in pairs(enemys)
		do
			if ( CanCast[abilityNumber]( npcEnemy ) )
			then
				local enemys = npcEnemy:GetNearbyHeroes(Radius,false,BOT_MODE_NONE)
				local Damage=(npcEnemy:GetMaxMana()-npcEnemy:GetMana())*DamagePercent
				local ManaPercentageEnemy=npcEnemy:GetMana()/npcEnemy:GetMaxMana()
				if(enemys~=nil)
				then
					Damage=Damage*(1+0.2*#enemys)
				end
				
				if(npcEnemy:GetHealth()<=npcEnemy:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL))
				then
					return BOT_ACTION_DESIRE_HIGH,npcEnemy; 
				end
			end
		end
	end
	
	
	for _,npcEnemy in pairs( enemys )
	do
		if ( npcEnemy:IsChanneling() and CanCast[abilityNumber]( npcEnemy )) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy
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