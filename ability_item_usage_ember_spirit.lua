
require(GetScriptDirectory() ..  "/logic")
require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local npcBot = GetBot()
local ComboMana = 0
local debugmode=true
local Talents ={}
for i=0,23,1 do
	local ability=npcBot:GetAbilityInSlot(i)
	if(ability~=nil and ability:IsTalent()==true)
	then
		table.insert(Talents,ability:GetName())
	end
end
local Abilities =
{
	"ember_spirit_searing_chains",
	"ember_spirit_sleight_of_fist",
	"ember_spirit_flame_guard",
	"ember_spirit_fire_remnant",
	"ember_spirit_activate_fire_remnant",
}
local AbilitiesReal =
{
	npcBot:GetAbilityByName(Abilities[1]),
	npcBot:GetAbilityByName(Abilities[2]),
	npcBot:GetAbilityByName(Abilities[3]),
	npcBot:GetAbilityByName(Abilities[4]),
	npcBot:GetAbilityByName(Abilities[5])
}
local AbilityToLevelUp=
{
	Abilities[1],
	Abilities[3],
	Abilities[3],
	Abilities[1],
	Abilities[3],
	Abilities[4],
	Abilities[3],
	Abilities[1],
	Abilities[1],
	"talent",
	Abilities[2],
	Abilities[4],
	Abilities[2],
	Abilities[2],
	"talent",
	Abilities[2],
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
		return Talents[8]
	end
}
logic.CheckAbilityBuild(AbilityToLevelUp)
function AbilityLevelUpThink()
	ability_item_usage_generic.AbilityLevelUpThink2(AbilityToLevelUp,TalentTree)
end
local castDesire = {}
local castTarget = {}
local castLocation = {}
local castType = {}
function CanCast1( npcEnemy )
	return npcEnemy:CanBeSeen() and not npcEnemy:IsMagicImmune() and not npcEnemy:IsInvulnerable();
end
function CanCast2( npcEnemy )
	return npcEnemy:CanBeSeen() and not npcEnemy:IsInvulnerable();
end
function CanCast3( npcEnemy )
	return
end
function CanCast4( npcEnemy )
	return npcEnemy:CanBeSeen() and not npcEnemy:IsMagicImmune() and not npcEnemy:IsInvulnerable();
end
function CanCast5( npcEnemy )
	return npcEnemy:CanBeSeen() and not npcEnemy:IsMagicImmune() and not npcEnemy:IsInvulnerable();
end
local CanCast={CanCast1,CanCast2,CanCast3,CanCast4,CanCast5}
function enemyDisabled(npcEnemy)
	if npcEnemy:IsRooted( ) or npcEnemy:IsStunned( ) or npcEnemy:IsHexed( ) then
		return true;
	end
	return false;
end
local function GetComboDamage()
	return npcBot:GetOffensivePower()
end
local function GetComboMana()
	
	local tempComboMana=0
	if AbilitiesReal[1]:IsFullyCastable()
	then
		tempComboMana=tempComboMana+AbilitiesReal[1]:GetManaCost()
	end
	if AbilitiesReal[2]:IsFullyCastable()
	then
		tempComboMana=tempComboMana+AbilitiesReal[2]:GetManaCost()
	end
	if AbilitiesReal[3]:IsFullyCastable()
	then
		tempComboMana=tempComboMana+AbilitiesReal[3]:GetManaCost()
	end	
	if AbilitiesReal[5]:IsFullyCastable()
	then
		tempComboMana=tempComboMana+AbilitiesReal[5]:GetManaCost()
	end
	
	if AbilitiesReal[1]:GetLevel()<1 or AbilitiesReal[2]:GetLevel()<1 or AbilitiesReal[3]:GetLevel()<1 or AbilitiesReal[5]:GetLevel()<1
	then
		tempComboMana=300;
	end
	
	ComboMana=tempComboMana
	return
end
function AbilityUsageThink()
	
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() )
	then 
		return
	end
	
	GetComboMana()
	AttackRange=npcBot:GetAttackRange()
	ManaPercentage=npcBot:GetMana()/npcBot:GetMaxMana()
	
	
	castDesire[1]=Consider1();
	castType[1]="no"
	castDesire[2], castLocation[2] = Consider2();
	castDesire[3] = Consider3();
	castDesire[4], castLocation[4] = Consider4();
	castDesire[5], castLocation[5] = Consider5();
	
	if(debugmode==true) then
		if(npcBot.LastSpeaktime==nil)
		then
			npcBot.LastSpeaktime=0
		end
		if(GameTime()-npcBot.LastSpeaktime>1)
		then
			for i=1,5,1
			do					
				if ( castDesire[i] > 0 ) 
				then
					npcBot.LastSpeaktime=GameTime()
				end
			end
		end
	end
	
	if ( castDesire[4] > 0 ) 
	then
		table.insert(npcBot.ult,{DotaTime(),castLocation[4],GetUnitToLocationDistance(npcBot,castLocation[4])/(2.5*npcBot:GetCurrentMovementSpeed())})
		print("insert"..DotaTime().." "..GetUnitToLocationDistance(npcBot,castLocation[4])/(2.5*npcBot:GetCurrentMovementSpeed()).." "..#npcBot.ult)
		npcBot:Action_UseAbilityOnLocation( AbilitiesReal[4], castLocation[4] );
		return
	end
	
	if ( castDesire[5] > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( AbilitiesReal[5], castLocation[5] );
		return
	end
	if ( castDesire[3] > 0 ) 
	then
		npcBot:Action_UseAbility( AbilitiesReal[3] );
		return
	end
	
	if ( castDesire[2] > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( AbilitiesReal[2], castLocation[2] );
		return
	end
	if ( castDesire[1] > 0 ) 
	then
		npcBot:Action_UseAbility( AbilitiesReal[1] );
		return
	end
end
function Consider1()	
	local abilityNumber=1
	
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = ability:GetCastRange();
	local Damage = ability:GetAbilityDamage();
	local Radius = ability:GetAOERadius()
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(CastRange,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(CastRange,true)
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
	
	if ( #enemys>=1 and #creeps<=1 ) 
	then
		if ( CanCast[abilityNumber]( enemys[1] ) )
			then
				return BOT_ACTION_DESIRE_MODERATE,WeakestEnemy;
			end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		for _,npcEnemy in pairs( enemys )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCast[abilityNumber]( npcEnemy ) and not enemyDisabled(npcEnemy) and GetUnitToUnitDistance(npcBot,npcEnemy)< CastRange) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end
		end
	end
	

	if ( npcBot:GetActiveMode() == BOT_MODE_LANING ) 
	then
		if(ManaPercentage>0.4 or npcBot:GetMana()>ComboMana)
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
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local npcEnemy = npcBot:GetTarget();
		if ( npcEnemy ~= nil ) 
		then
			if ( CanCast[abilityNumber]( npcEnemy ) and not enemyDisabled(npcEnemy) and GetUnitToUnitDistance(npcBot,npcEnemy)< CastRange)
			then
				return BOT_ACTION_DESIRE_MODERATE,npcEnemy
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
	
end
function Consider2()		
	local abilityNumber=2
	
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = ability:GetCastRange();
	local Damage =  npcBot:GetAttackDamage()+ability:GetSpecialValueInt("bonus_hero_damage")
	local Radius = ability:GetAOERadius()
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(1200,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(1200,true)
	local WeakestCreep,CreepHealth=logic.GetWeakestUnit(creeps)
	
	
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			if ( CanCast[abilityNumber]( WeakestEnemy ) )
			then
				if(HeroHealth<=WeakestEnemy:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL) or (HeroHealth<=WeakestEnemy:GetActualIncomingDamage(GetComboDamage(),DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana))
				then
					return BOT_ACTION_DESIRE_HIGH,WeakestEnemy:GetLocation()+GetSafeVector(npcBot,Radius); 
				end
			end
		end
	end
	if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), CastRange+500, Radius, 0, 0 );
		if ( locationAoE.count >= 2) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING ) 
	then
		if((ManaPercentage>0.4 or npcBot:GetMana()>ComboMana))
		then
			local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), CastRange+500, Radius, 0, 0 );
			if ( locationAoE.count >= 2) then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		end
	end
	
	 
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), CastRange+500, Radius, 0, 0 );
		if ( locationAoE.count >= 2) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), CastRange+500, Radius, 0, 0 );
		if ( locationAoE.count >= 3) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
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
			if ( CanCast[abilityNumber]( npcEnemy ) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation()+GetSafeVector(npcBot,Radius);
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
	
end
function Consider3()
	
	local abilityNumber=3
	
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = ability:GetCastRange();
	local Damage = ability:GetAbilityDamage();
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(CastRange+300,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(CastRange+300,true)
	local WeakestCreep,CreepHealth=logic.GetWeakestUnit(creeps)
	
	
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			if ( CanCast[abilityNumber]( WeakestEnemy ) )
			then
				if(HeroHealth<=WeakestEnemy:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL) or (HeroHealth<=WeakestEnemy:GetActualIncomingDamage(GetComboDamage(),DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana))
				then
					return BOT_ACTION_DESIRE_HIGH; 
				end
			end
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING ) 
	then
		if((ManaPercentage>0.4 or npcBot:GetMana()>ComboMana) and #enemys >=2)
		then				
			return BOT_ACTION_DESIRE_LOW; 
		end		
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_FARM ) 
	then
		if ( #enemys==0 and #creeps>=2 and (ManaPercentage>0.4 or npcBot:GetMana()>ComboMana)) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	if (  npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local npcEnemy = npcBot:GetTarget();
		if ( npcEnemy ~= nil ) 
		then
			if ( CanCast[abilityNumber]( npcEnemy ) )
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE;
	
end
function Consider4()
	local abilityNumber=4
	
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = ability:GetCastRange();
	local Damage = ability:GetAbilityDamage();
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(1600,true)
	local WeakestCreep,CreepHealth=logic.GetWeakestUnit(creeps)
	
	if(npcBot.ult==nil)
	then
		npcBot.ult={}
	end
	for _,i in pairs(npcBot.ult)
	do
		if(DotaTime()>=i[1]+45)
		then
			table.remove(npcBot.ult,_)
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
					local d=GetUnitToUnitDistance(npcBot,WeakestEnemy)
					return BOT_ACTION_DESIRE_HIGH,GetUnitsTowardsLocation(npcBot,WeakestEnemy,d+300) 
				end
			end
		end
	end
	
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= 0.8 and #npcBot.ult==0) 
	then
		if ( npcBot:WasRecentlyDamagedByAnyHero(2) or #enemys >=1) 
		then
			return BOT_ACTION_DESIRE_HIGH, GetUnitsTowardsLocation(enemys[1],npcBot,CastRange);
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_LANING	or
		 npcBot:GetActiveMode() == BOT_MODE_FARM) 
	then
		if(#npcBot.ult<1 and (npcBot.ult_time==nil or DotaTime()-npcBot.ult_time>=2))
		then
			npcBot.ult_time=DotaTime()
			return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation()+logic.GetSafeVector(npcBot,1500)
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
			local d=GetUnitToUnitDistance(npcBot,npcEnemy)
			if ( CanCast[abilityNumber]( npcEnemy ) and not enemyDisabled(npcEnemy) and d< CastRange + 75*#allys)
			then
				return BOT_ACTION_DESIRE_MODERATE, GetUnitsTowardsLocation(npcBot,npcEnemy,d+300)
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
	
end
function Consider5_r()
	local abilityNumber=5
	
	local ability=AbilitiesReal[abilityNumber];
	
	if (not ability:IsFullyCastable()) then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = ability:GetCastRange();
	local Damage = ability:GetAbilityDamage();
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(1600,true)
	local WeakestCreep,CreepHealth=logic.GetWeakestUnit(creeps)
	
	
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			if ( CanCast[abilityNumber]( WeakestEnemy ) )
			then
				if(HeroHealth<=WeakestEnemy:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL) or (HeroHealth<=WeakestEnemy:GetActualIncomingDamage(GetComboDamage(),DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana))
				then
					return BOT_ACTION_DESIRE_HIGH,WeakestEnemy:GetLocation()
				end
			end
		end
	end
	
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= 0.5) 
	then
		if ( npcBot:WasRecentlyDamagedByAnyHero(2) or #enemys >=1) 
		then
			return BOT_ACTION_DESIRE_HIGH,logic.Fountain(GetTeam())
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
			local d=GetUnitToUnitDistance(npcBot,npcEnemy)
			if ( CanCast[abilityNumber]( npcEnemy ) and not enemyDisabled(npcEnemy) and d< CastRange + 75*#allys)
			then
				return BOT_ACTION_DESIRE_MODERATE, GetUnitsTowardsLocation(npcBot,npcEnemy,d+300)
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
	
end
function Consider5()
	if(npcBot:HasModifier("modifier_ember_spirit_fire_remnant_timer")==false and npcBot.ult~=nil)
	then
		npcBot.ult={}
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if(npcBot.ult==nil or #npcBot.ult==0)
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local desire,location=Consider5_r()
	if(desire==0) 
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local min_distance =10000
	local q=-1
	for _,i in pairs(npcBot.ult)
	do
		if(DotaTime()>i[1]+i[3])
		then
			d=logic.PointToPointDistance(i[2],location)
			if(d<min_distance)
			then
				min_distance=d
				q=_
			end
		end
	end
	
	if(q~=-1)
	then
		return desire,location
	else
		return BOT_ACTION_DESIRE_NONE, 0;
	end
end
function CourierUsageThink() 
	ability_item_usage_generic.CourierUsageThink()
end