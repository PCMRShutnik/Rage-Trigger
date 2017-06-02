local RAD_Fountain = Vector(-7000.000000,-7000.000000, 256.000000);
local DIRE_Fountain = Vector(7000.000000,7000.000000, 256.000000);
function SPLocation()
	if (DotaTime() < 0) then
		if( GetTeam()== TEAM_RADIANT ) then
			_G.Fountain = RAD_Fountain;
			_G.EnemyFountain = DIRE_Fountain;
		end
		if( GetTeam()== TEAM_DIRE ) then
			_G.Fountain = DIRE_Fountain;
			_G.EnemyFountain = RAD_Fountain;
		end
	end
end
function IsInEnemyBase(location)
	local EnemyAncient = GetAncient(GetOpposingTeam( ));
	if (#(location - _G.EnemyFountain) < 1000 or #(location - EnemyAncient:GetLocation() ) < 500 ) then
		return true;
	end
	return false;
end
function GetModifierByName( unit, mName )
	local TableModifier = unit:GetModifierList( );
	for k, modifier in pairs (TableModifier) do
		if (modifier == mName) then
			return k;
		end
	end
	return 0;
end
function GetRemainControlTime(unit)
	local stun_time = -1;
	local root_time = -1;
	if (unit:HasModifier("modifier_stunned")) then
		stun_time = unit:GetModifierRemainingDuration( GetModifierByName( unit, "modifier_stunned" ) );
	end
	
	if (unit:HasModifier("modifier_rooted")) then
		root_time = unit:GetModifierRemainingDuration( GetModifierByName( unit, "modifier_rooted" ) );
	end
	
	local control_time = math.max(stun_time, root_time, 0);
	return control_time;
end
function GetItemByName( ItemName )
local npcBot = GetBot();
 for i=0,5 do
      local sCurItem = npcBot:GetItemInSlot( i );
      if ( sCurItem ~= nil ) then
        local iName = sCurItem:GetName();
        if ( iName == ItemName ) then
          return sCurItem;
        end
      end
 end  
end
function GetAllItemByName( ItemName )
	local npcBot = GetBot();
	for i=0,14 do
      local sCurItem = npcBot:GetItemInSlot( i );
      if ( sCurItem ~= nil ) then
        local iName = sCurItem:GetName();
        if ( iName == ItemName ) then
          return sCurItem;
        end
      end
	end  
end
function CheckItemByName ( ItemName )
local npcBot = GetBot();    
	for i= 0,5 do
      local sCurItem = npcBot:GetItemInSlot( i );
      if ( sCurItem ~= nil ) then
        local iName = sCurItem:GetName();
        if ( iName == ItemName ) then
          return true;
      	end
      end
     end      
return false;
end
function CheckBackPackItemByName ( ItemName )
local npcBot = GetBot();    
	for i= 6,8 do
      local sCurItem = npcBot:GetItemInSlot( i );
      if ( sCurItem ~= nil ) then
        local iName = sCurItem:GetName();
        if ( iName == ItemName ) then
          return true;
      	end
      end
     end      
return false;
end
function CheckCurrentItemByName ( ItemName )
local npcBot = GetBot();    
	for i= 0,8 do
      local sCurItem = npcBot:GetItemInSlot( i );
      if ( sCurItem ~= nil ) then
        local iName = sCurItem:GetName();
        if ( iName == ItemName ) then
          return true;
      	end
      end
     end      
return false;
end
function CheckAllItemByName ( ItemName )
local npcBot = GetBot();    
	for i= 0,14 do
      local sCurItem = npcBot:GetItemInSlot( i );
      if ( sCurItem ~= nil ) then
        local iName = sCurItem:GetName();
        if ( iName == ItemName ) then
          return true;
      	end
      end
     end      
return false;
end
local tablebuildings = { 
TOWER_BASE_1,
TOWER_BASE_2,
TOWER_MID_3,
TOWER_BOT_3,
TOWER_TOP_3,
TOWER_MID_2,
TOWER_MID_1,
TOWER_TOP_2,
TOWER_BOT_2,
TOWER_TOP_1,
TOWER_BOT_1,
};
function FindNearestTower(location)
	local min_distance = 99999;
	local nearest_tower = nil;
	for building_k, building in pairs(tablebuildings) do
		local current_tower = GetTower(GetTeam( ), building);
		if (current_tower~= nil and current_tower:IsAlive() and GetUnitToLocationDistance(current_tower, location) < min_distance) then
			min_distance = GetUnitToLocationDistance(current_tower, location);
			nearest_tower = current_tower;
		end
	end
	return nearest_tower;
end
function FindEnemyNearestTower(location)
	local min_distance = 99999;
	local nearest_tower = nil;
	local nearest_tower_name = nil;
	for building_k, building in pairs(tablebuildings) do
		local current_tower = GetTower(GetOpposingTeam( ), building);
		if (current_tower~= nil and current_tower:IsAlive() and (not current_tower:IsInvulnerable( )) and GetUnitToLocationDistance(current_tower, location) < min_distance) then
			min_distance = GetUnitToLocationDistance(current_tower, location);
			nearest_tower = current_tower;
			nearest_tower_name = building;
		end
	end
	return nearest_tower , nearest_tower_name;
end		
function IsInTowerRange(location, radius)
	for building_k, building in pairs(tablebuildings) do
		local current_tower = GetTower(GetOpposingTeam( ), building);
		if (current_tower~= nil and current_tower:IsAlive()) then
			if(GetUnitToLocationDistance(current_tower,location) <= radius) then

                return true;
            end
		end
	end
	if (#(location - _G.EnemyFountain) < radius) then
		return true;
	end
	return false;
end
function IsInAllyTowerRange(location, radius)
	for building_k, building in pairs(tablebuildings) do
		local current_tower = GetTower(GetTeam( ), building);
		if (current_tower ~= nil and current_tower:IsAlive()) then
			if(GetUnitToLocationDistance(current_tower,location) <= radius) then
                return true;
            end
		end
	end
	return false;
end
function GetFrontTower(team, lane)
	local towerlist = {};
	local front_tower = nil;
	if (lane == 1) then
		towerlist = {TOWER_TOP_1, TOWER_TOP_2, TOWER_TOP_3, TOWER_BASE_1,TOWER_BASE_2,}
	elseif (lane == 2) then
		towerlist = {TOWER_MID_1, TOWER_MID_2, TOWER_MID_3, TOWER_BASE_1,TOWER_BASE_2,}
	elseif (lane == 3) then
		towerlist = {TOWER_MID_1, TOWER_MID_2, TOWER_MID_3, TOWER_BASE_1,TOWER_BASE_2,}
	end
	for k, tower in pairs(towerlist) do
		front_tower = GetTower(team, tower);
		if (front_tower ~= nil and front_tower:IsAlive()) then
			return front_tower;
		end
	end
	return front_tower;
end
local TableShrines = { 
SHRINE_BASE_1,
SHRINE_BASE_2,
SHRINE_BASE_3,
SHRINE_BASE_4,
SHRINE_BASE_5,
SHRINE_JUNGLE_1,
SHRINE_JUNGLE_2,
};
function FindNearestShrine(location)
	local min_distance = 99999;
	local nearest_shrine = nil;
	local shrine_name = nil;
	for shrine_k, shrine in pairs(TableShrines) do
		local current_shrine = GetShrine(GetTeam( ), shrine);
		if (current_shrine ~= nil and current_shrine:IsAlive() and GetUnitToLocationDistance(current_shrine, location) < min_distance) then
			min_distance = GetUnitToLocationDistance(current_shrine, location);
			nearest_shrine = current_shrine;
			shrine_name = shrine;
		end
	end
	return nearest_shrine, shrine_name;
end
function IsInter(num)
	local ceil = math.ceil(num);
	local floor = math.floor(num);
	if (ceil == floor) then
		return true;
	else
		return false;
	end
end
function GetVarInTable(var, Table)
	for k, variable in pairs(Table) do
		if (variable == var) then
			return k;
		end
	end
	return 0;
end
function sidecheck(location)
local x= location[1];
local y= location[2];
	if ((x *(-0.57221109) )+ 178 > y) then
		return TEAM_RADIANT;
	else
		return TEAM_DIRE;
	end
end
function CanUseTp()
	local npcBot = GetBot();
	if (CheckItemByName("item_travel_boots_2") and GetItemByName("item_travel_boots_2"):IsFullyCastable( )) then
		return true;
	elseif (CheckItemByName("item_travel_boots") and GetItemByName("item_travel_boots"):IsFullyCastable( )) then
		return true;
	elseif (CheckItemByName("item_tpscroll") and GetItemByName("item_tpscroll"):IsFullyCastable( )) then
		return true;
	else
		return false;
	end
end
function findtploc(location)
	local distance = 99999;
	local TableAllyCreep = GetUnitList( UNIT_LIST_ALLIED_CREEPS );
	local TableAllyHero = GetUnitList( UNIT_LIST_ALLIED_HEROES );
	local target_loc = nil;
	if(CheckItemByName("item_travel_boots_2")) then
		for k, unit in pairs(TableAllyCreep) do
			if (unit~= nil and unit:IsAlive() and GetUnitToLocationDistance(unit, location) < distance and unit:GetHealth() > 500 and CreepDamageEstimate(unit) < unit:GetHealth() ) then
				distance = GetUnitToLocationDistance(unit, location);
				target_loc = unit:GetLocation();
			end
		end
		for k, unit in pairs(TableAllyHero) do
			if (unit~= nil and unit:IsAlive() and GetUnitToLocationDistance(unit, location) < distance) then
				distance = GetUnitToLocationDistance(unit, location);
				target_loc = unit:GetLocation();
			end
		end
		for k, building in pairs (tablebuildings) do
			local unit = GetTower(GetTeam( ), building);
			if (unit~= nil and unit:IsAlive() and GetUnitToLocationDistance(unit, location) < distance) then
				distance = GetUnitToLocationDistance(unit, location);
				target_loc = unit:GetLocation();
			end
		end
		for shrine_k, shrine in pairs(TableShrines) do
		local unit = GetShrine(GetTeam( ), shrine);
		if (unit~= nil and unit:IsAlive() and GetUnitToLocationDistance(unit, location) < distance) then
				distance = GetUnitToLocationDistance(unit, location);
				target_loc = unit:GetLocation();
			end
		end
	elseif (CheckItemByName("item_travel_boots")) then
		for k, unit in pairs(TableAllyCreep) do
			if (unit~= nil and unit:IsAlive() and GetUnitToLocationDistance(unit, location) < distance and unit:GetHealth() > 500 and CreepDamageEstimate(unit) < unit:GetHealth() ) then
				distance = GetUnitToLocationDistance(unit, location);
				target_loc = unit:GetLocation();
			end
		end
		for k, building in pairs (tablebuildings) do
			local unit = GetTower(GetTeam( ), building);
			if (unit~= nil and unit:IsAlive() and GetUnitToLocationDistance(unit, location) < distance) then
				distance = GetUnitToLocationDistance(unit, location);
				target_loc = unit:GetLocation();
			end
		end
		for shrine_k, shrine in pairs(TableShrines) do
		local unit = GetShrine(GetTeam( ), shrine);
		if (unit~= nil and unit:IsAlive() and GetUnitToLocationDistance(unit, location) < distance) then
				distance = GetUnitToLocationDistance(unit, location);
				target_loc = unit:GetLocation();
			end
		end
	elseif (CheckItemByName("item_tpscroll")) then
		for k, building in pairs (tablebuildings) do
			local unit = GetTower(GetTeam( ), building);
			if (unit~= nil and unit:IsAlive() and GetUnitToLocationDistance(unit, location) < distance) then
				distance = GetUnitToLocationDistance(unit, location);
				target_loc = unit:GetLocation();
			end
		end
		for shrine_k, shrine in pairs(TableShrines) do
		local unit = GetShrine(GetTeam( ), shrine);
		if (unit~= nil and unit:IsAlive() and GetUnitToLocationDistance(unit, location) < distance) then
				distance = GetUnitToLocationDistance(unit, location);
				target_loc = unit:GetLocation();
			end
		end
	end
	return target_loc, distance;
end
function TpToLocation(location)
	local npcBot = GetBot();
	if ( npcBot:IsChanneling( ) ) then
		return;
	end	
	if (CheckItemByName ( "item_travel_boots" ) and GetItemByName("item_travel_boots"):IsFullyCastable() ) then
		npcBot:Action_UseAbilityOnLocation(GetItemByName("item_travel_boots"), location);
	elseif (CheckItemByName ( "item_travel_boots_2" ) and GetItemByName("item_travel_boots2"):IsFullyCastable() ) then
		npcBot:Action_UseAbilityOnLocation(GetItemByName("item_travel_boots_2"), location);	
	elseif (CheckItemByName ( "item_tpscroll" ) and GetItemByName("item_tpscroll"):IsFullyCastable() ) then
			npcBot:Action_UseAbilityOnLocation(GetItemByName("item_tpscroll"), location);
	end
end
function CreepDamageEstimate(unit)
	local TableCreeps ={};
	local TotalDamage = 0;
	if (unit:GetTeam( ) == GetTeam( )) then
		TableCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS);
		for k, creep in pairs(TableCreeps) do
			if (creep:GetAttackTarget( ) == unit) then
				local Attack = creep:GetAttackDamage( );
				TotalDamage = TotalDamage + unit:GetActualIncomingDamage(Attack ,DAMAGE_TYPE_PHYSICAL); 
			end
		end
		for k, building in pairs (tablebuildings) do
			if ( GetTowerAttackTarget( GetOpposingTeam(), building ) == unit ) then
				local tower = GetTower( GetOpposingTeam(), building );
				local Attack = tower:GetAttackDamage( );
				TotalDamage = TotalDamage + unit:GetActualIncomingDamage(Attack ,DAMAGE_TYPE_PHYSICAL); 
			end
		end
	else
		TableCreeps = GetUnitList(UNIT_LIST_ALLIED_CREEPS);
		for k, creep in pairs(TableCreeps) do
			if (creep:GetAttackTarget( ) == unit) then
				local Attack = creep:GetAttackDamage( );
				TotalDamage = TotalDamage + unit:GetActualIncomingDamage(Attack ,DAMAGE_TYPE_PHYSICAL); 
			end
		end
		for k, building in pairs (tablebuildings) do
			if ( GetTowerAttackTarget( GetTeam(), building ) == unit ) then
				local tower = GetTower( GetTeam(), building );
				local Attack = tower:GetAttackDamage( );
				TotalDamage = TotalDamage + unit:GetActualIncomingDamage(Attack ,DAMAGE_TYPE_PHYSICAL); 
			end
		end	
	end
	return TotalDamage;
end
function EnemyDamageEstimate(location)
	local npcBot = GetBot();
	local TableEnemyHero = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	local TotalDamage = 0;
	for k, hero in pairs (TableEnemyHero) do
		if ( GetUnitToLocationDistance(hero, location) < math.max(hero:GetAttackRange() + hero:GetCurrentMovementSpeed() * 3, 900) ) then
			TotalDamage = TotalDamage + hero:GetEstimatedDamageToTarget(true, npcBot, 5, DAMAGE_TYPE_ALL) * 0.2;
		end
	end

	return TotalDamage;
end
function AverageSpeedEstimate(location)
	local npcBot = GetBot();
	local TableEnemyHero = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	local TotalSpeed = 0;
	local Counts = 0;
	local AverageSpeed = 0;
	for k, hero in pairs (TableEnemyHero) do
		if ( GetUnitToLocationDistance(hero, location) < math.max(hero:GetAttackRange() + hero:GetCurrentMovementSpeed() * 3, 900) ) then
			TotalSpeed = TotalSpeed + hero:GetCurrentMovementSpeed();
			Counts = Counts + 1;
		end
	end
	if (Counts ~= 0) then
		AverageSpeed = TotalSpeed/Counts;
	end
	return AverageSpeed;
end
function EnemyStunEstimate(location)
	local npcBot = GetBot();
	local TableEnemyHero = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	local TotalStun = 0;
	for k, hero in pairs (TableEnemyHero) do
		if ( GetUnitToLocationDistance(hero, location) < math.max(hero:GetAttackRange() + hero:GetCurrentMovementSpeed() * 3, 900)) then
			TotalStun = TotalStun + hero:GetStunDuration( true ) + hero:GetSlowDuration( true ) * 0.2;
		end
	end
	return TotalStun;
end	
function ModifierDamageEstimate(unit)
	local EstimateDamage = 0;
	if ( unit:HasModifier( "modifier_alchemist_acid_spray" ) ) then
		EstimateDamage = EstimateDamage + 30;
	end
	return EstimateDamage;
end
function GetLaneNum(location)
	local LaneNum = 0;
	local laneinfo_top = GetAmountAlongLane( LANE_TOP, location );
	local laneinfo_mid = GetAmountAlongLane( LANE_MID, location );
	local laneinfo_bot = GetAmountAlongLane( LANE_BOT, location );
	if (laneinfo_top.distance < 1500) then
		LaneNum = 1;
	elseif (laneinfo_mid.distance < 1500) then
		LaneNum = 2;
	elseif (laneinfo_bot.distance < 1500) then
		LaneNum = 3;
	end
	return LaneNum;
end
function GetNearbyAllyPower( npcBot )
	local TableAllyHero = GetUnitList(UNIT_LIST_ALLIED_HEROES);
	local NearbyAllyTowers = npcBot:GetNearbyTowers(800,false);
	local nearest_tower = NearbyAllyTowers[1];
	local AllyRawPower = npcBot:GetRawOffensivePower();
	for allyhero_k,allyhero in pairs(TableAllyHero) do
		if (allyhero:GetUnitName() ~= npcBot:GetUnitName() and GetUnitToUnitDistance(allyhero, npcBot) < math.max(allyhero:GetAttackRange() + allyhero:GetCurrentMovementSpeed() * 3, 1500)  and allyhero:GetHealth()/allyhero:GetMaxHealth() > 0.3) then
			AllyRawPower = AllyRawPower + allyhero:GetRawOffensivePower( );
		end
	end
	return AllyRawPower;
end
function GetNearbyAllyHealth( npcBot )	
	local TableAllyHero = GetUnitList(UNIT_LIST_ALLIED_HEROES);
	local AllyHealth = npcBot:GetHealth();
	for allyhero_k,allyhero in pairs(TableAllyHero) do
		if (allyhero:GetUnitName() ~= npcBot:GetUnitName() and GetUnitToUnitDistance(allyhero, npcBot) < math.max(allyhero:GetAttackRange() + allyhero:GetCurrentMovementSpeed() * 3, 1500)  and allyhero:GetHealth()/allyhero:GetMaxHealth() > 0.3) then
			AllyHealth = AllyHealth + allyhero:GetHealth();
		end
	end
	return AllyHealth;
end
function IsInAoeArea(location)
	local TableAoE = GetAvoidanceZones();
	local npcBot = GetBot();
	for k , aoe in pairs(TableAoE) do
		if (aoe.playerid~= nil and (GetTeamForPlayer(aoe.playerid)  ==  GetOpposingTeam( ) or aoe.ability == "faceless_void_chronosphere") and aoe.ability~= "tinker_march_of_the_machines" and aoe.location ~= nil and #(location - aoe.location) < aoe.radius + npcBot:GetBoundingRadius() + 150) then ---+150 to make sure not in aoe area
			return true;
		end
	end
	return false;
end
function HasSwarmStun()
	local npcBot = GetBot();
	local NearbyEnemyHeroes = npcBot:GetNearbyHeroes( 300, true, BOT_MODE_NONE );
	if (npcBot:HasModifier("modifier_invoker_cold_snap") or npcBot:HasModifier("modifier_invoker_cold_snap_freeze")) then
		return true;
	elseif (#NearbyEnemyHeroes > 0 and (not npcBot:IsMagicImmune( )) ) then
		for k, hero in pairs(NearbyEnemyHeroes) do
			if (hero:HasModifier("modifier_rattletrap_battery_assault")) then
				return true;
			end
		end
	end
	return false;
end
function IsSlowed(unit)
	
end
function GetNetWorth(hero)
	local NetWorth = 0;
    for i = 0,5 do
        if (hero:GetItemInSlot(i) ~= nil) then
            local item = hero:GetItemInSlot(i);
            local itemname = item:GetName();
            if (GetItemCost(itemname) ~= nil and GetItemCost(itemname) > 0) then
                NetWorth = NetWorth + GetItemCost(itemname);
            end
        end
    end
    return NetWorth;
end
function HeroSpecificHP(hero , health)
	local modified_health = health;

	if (hero:HasModifier( "modifier_wisp_overcharge" ) ) then
		modified_health = modified_health * 1.25;
	end
	
	if (hero:HasModifier( "modifier_wisp_overcharge" ) ) then
		modified_health = modified_health * 1.25;
	end
	
	if (hero:HasModifier( "modifier_bloodseeker_bloodrage" ) ) then
		modified_health = modified_health/1.4;
	end
	
	if (hero:HasModifier( "modifierherofilereevil_maledict") or hero:HasModifier( "modifier_maledict" ) ) then
		modified_health = modified_health/2.7;
	end
	
	if (hero:HasModifier( "modifier_shadow_demon_soul_catcher")) then
		modified_health = modified_health/1.5;
	end
	
	if (hero:HasModifier( "modifier_meepo_divided_we_stand" ) ) then
		modified_health = modified_health/3;
	end
	
	if (hero:HasModifier( "modifier_abaddon_aphotic_shield" )) then
		modified_health = modified_health + 400;
	end
	
	if (hero:HasModifier( "modifier_abaddon_borrowed_time" ) or hero:HasModifier( "modifier_abaddon_borrowed_time_damage_redirect" ) or hero:HasModifier( "modifier_abaddon_borrowed_time_passive" )) then
		modified_health = hero:GetMaxHealth( );
	end
	
	if (hero:HasModifier( "modifier_omniknightherofileuardian_angel" ) ) then
		modified_health = hero:GetMaxHealth( );
	end
	
	if (hero:HasModifier( "modifier_dazzle_shallowherofilerave" ) and hero:GetHealth() < 50 ) then
		modified_health = hero:GetMaxHealth( );
	end
	
	return modified_health;
end	

function Deidle()
	local npcBot = GetBot();
	if (npcBot:GetCurrentActionType( ) == BOT_ACTION_TYPE_IDLE) then
		local target_loc = npcBot:GetLocation() + RandomVector(100);
		npcBot:Action_MoveToLocation(target_loc);
	end
end