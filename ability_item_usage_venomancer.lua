
require(GetScriptDirectory() ..  "/logic")
require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local npcBot = GetBot()
local ComboMana = 0
local debugmode=false
local Talents ={}
local Abilities ={}
for i=0,23,1 do
	local ability=npcBot:GetAbilityInSlot(i)
	if(ability~=nil)
	then
		if(ability:IsTalent()==true)
		then
			table.insert(Talents,ability:GetName())
		else
			table.insert(Abilities,ability:GetName())
		end
	end
end
local AbilitiesReal =
{
	npcBot:GetAbilityByName(Abilities[1]),
	npcBot:GetAbilityByName(Abilities[2]),
	npcBot:GetAbilityByName(Abilities[3]),
	npcBot:GetAbilityByName(Abilities[4])
}
local AbilityToLevelUp=
{
	Abilities[2],
	Abilities[1],
	Abilities[3],
	Abilities[3],
	Abilities[3],
	Abilities[2],
	Abilities[3],
	Abilities[2],
	Abilities[4],
	"talent",
	Abilities[2],
	Abilities[1],
	Abilities[4],
	Abilities[1],
	"talent",
	Abilities[1],
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
		return Talents[2]
	end,
	function()
		return Talents[4]
	end,
	function()
		return Talents[6]
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
	return true
end
function CanCast3( npcEnemy )
	return npcEnemy:CanBeSeen() and not npcEnemy:IsInvulnerable();
end
function CanCast4( npcEnemy )
	return npcEnemy:CanBeSeen() and not npcEnemy:IsMagicImmune() and not npcEnemy:IsInvulnerable();
end
local CanCast={CanCast1,CanCast2,CanCast3,CanCast4}
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
	if AbilitiesReal[4]:IsFullyCastable() or AbilitiesReal[4]:GetCooldownTimeRemaining()<=30
	then
		tempComboMana=tempComboMana+AbilitiesReal[4]:GetManaCost()
	end
	
	if AbilitiesReal[1]:GetLevel()<1 or AbilitiesReal[4]:GetLevel()<1
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
	
	
	castDesire[1], castLocation[1] = Consider1();
	castDesire[2] = 0
	castDesire[3], castLocation[3] = Consider3();
	castDesire[4] =Consider4();
	
	if(debugmode==true) then
		if(npcBot.LastSpeaktime==nil)
		then
			npcBot.LastSpeaktime=0
		end
		if(GameTime()-npcBot.LastSpeaktime>1)
		then
			for i=1,4,1
			do					
				if ( castDesire[i] > 0 ) 
				then
					if ((castType[i]==nil or castType[i]=="target") and castTarget[i]~=nil)
					then
						npcBot:ActionImmediate_Chat("try to use skill "..i.." at "..
						castTarget[i]:GetUnitName()..
						" Desire= "..
						castDesire[i],true)
						print("try to use skill "..i.." at "..castTarget[i]:GetUnitName().." Desire= "..castDesire[i])
					else
						npcBot:ActionImmediate_Chat("try to use skill "..i.." Desire= "..castDesire[i],true)
						print("try to use skill "..i.." Desire= "..castDesire[i])
					end
					npcBot.LastSpeaktime=GameTime()
				end
			end
		end
	end
	
	if ( castDesire[4] > 0 ) 
	then
		npcBot:Action_UseAbility( AbilitiesReal[4] );
		return
	end
	if ( castDesire[3] > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( AbilitiesReal[3], castLocation[3] );
		return
	end
	if ( castDesire[1] > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( AbilitiesReal[1], castLocation[1] );
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
	local Damage = 25*ability:GetLevel()+5*(-20+30*ability:GetLevel())
	local Radius = ability:GetAOERadius()
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(CastRange + 75*#allys,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(CastRange + 75*#allys,true)
	local WeakestCreep,CreepHealth=logic.GetWeakestUnit(creeps)
	
	
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			if ( CanCast[abilityNumber]( WeakestEnemy ) )
			then
				if(HeroHealth<=WeakestEnemy:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL) or (HeroHealth<=WeakestEnemy:GetActualIncomingDamage(GetComboDamage(),DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana))
				then
					local d=GetUnitToUnitDistance(npcBot,WeakestEnemy)
					if(d<=CastRange+Radius)
					then
						return BOT_ACTION_DESIRE_HIGH,logic.GetUnitsTowardsLocation(npcBot,WeakestEnemy,100); 
					else
						return BOT_ACTION_DESIRE_HIGH,logic.GetUnitsTowardsLocation(npcBot,WeakestEnemy,GetUnitToUnitDistance(npcBot,WeakestEnemy)+100); 
					end
				end
			end
		end
	end
	
	
	
	do
		local enemys2 = npcBot:GetNearbyHeroes( 300, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( enemys2 )
		do
			if ( CanCast[abilityNumber]( npcEnemy ) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation()
			end
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		for _,npcEnemy in pairs( enemys )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
			end
		end
	end
	

	if((ManaPercentage>0.4 or npcBot:GetMana()>ComboMana) and ability:GetLevel()>=2 )
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), CastRange, Radius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
		

	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), CastRange, Radius, 0, Damage );
		if ( locationAoE.count >= 3 ) then
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
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), CastRange, Radius, 0, 0 );
		if ( locationAoE.count >= 3 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), CastRange, Radius, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
		end
		
		local npcEnemy = npcBot:GetTarget();
		if ( npcEnemy ~= nil ) 
		then
			if ( enemyDisabled(npcEnemy) and GetUnitToUnitDistance(npcBot,npcEnemy)< CastRange + 75*#allys)
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation()
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
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(CastRange+300,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(CastRange+300,true)
	local WeakestCreep,CreepHealth=logic.GetWeakestUnit(creeps)
	local towers =npcBot:GetNearbyTowers(CastRange+300,true)
	local towers2 =npcBot:GetNearbyTowers(CastRange+300,false)
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT ) 
	then
		if(npcBot:WasRecentlyDamagedByAnyHero(5))
		then
			return BOT_ACTION_DESIRE_MODERATE, npcBot:GetLocation()+RandomVector(RandomInt(0,300));
		end
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
				return BOT_ACTION_DESIRE_MODERATE, logic.RandomInCastRangePoint(npcBot,npcEnemy,CastRange,300);
			end
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM )
	then
		if ( #creeps >= 2 and (ManaPercentage>0.4 or npcBot:GetMana()>ComboMana)) 
		then
			return BOT_ACTION_DESIRE_LOW, logic.RandomInCastRangePoint(npcBot,npcEnemy,CastRange,300);
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		if ( #towers >= 1 ) 
		then
			if (ManaPercentage>0.4 or npcBot:GetMana()>ComboMana)
			then
				return BOT_ACTION_DESIRE_LOW, logic.RandomInCastRangePoint(npcBot,towers[1],CastRange,300);
			end
		end
		if ( #towers2 >= 1 ) 
		then
			if (ManaPercentage>0.4 or npcBot:GetMana()>ComboMana)
			then
				return BOT_ACTION_DESIRE_LOW, logic.RandomInCastRangePoint(npcBot,towers2[1],CastRange,300);
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
	
end
function Consider4()
	local abilityNumber=4
	
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = ability:GetCastRange();
	local Damage = 0
	local Radius = ability:GetAOERadius()
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(Radius,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	
	local disabledheronum=0
	for _,temphero in pairs(enemys)
	do
		if (enemyDisabled(temphero) or temphero:GetCurrentMovementSpeed()<=200)
		then
			disabledheronum=disabledheronum+1
		end
	end
			
	if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		if ( #enemys+disabledheronum >= 3) 
		then
			return BOT_ACTION_DESIRE_HIGH
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
			if ( CanCast[abilityNumber]( npcEnemy ) and enemyDisabled(npcEnemy) and npcEnemy:GetHealth()<=npcEnemy:GetActualIncomingDamage(	npcBot:GetOffensivePower(),DAMAGE_TYPE_MAGICAL) and GetUnitToUnitDistance(npcEnemy,npcBot)<=Radius)
			then
				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
function CourierUsageThink() 
	ability_item_usage_generic.CourierUsageThink()
end