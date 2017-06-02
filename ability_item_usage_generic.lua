require( GetScriptDirectory().."/utilities" )
require( GetScriptDirectory().."/buildings_status" )
require( GetScriptDirectory().."/herofile_utilities" )
_G._savedEnv = getfenv()
module( "ability_item_usage_generic", package.seeall )
require( GetScriptDirectory().."/logic" ) 
local RAD_Fountain = Vector(-7000.000000,-7000.000000, 256.000000);
local DIRE_Fountain = Vector(7000.000000,7000.000000, 256.000000);
require( GetScriptDirectory().."/utilities" )
require( GetScriptDirectory().."/herofile_utilities" )
if string.find(GetBot():GetUnitName(), "hero") and build == "NOT IMPLEMENTED" then
	build = require(GetScriptDirectory() .. "/Shopping cart/item_build_" .. string.gsub(GetBot():GetUnitName(), "npc_dota_hero_", ""))
end
if build == "NOT IMPLEMENTED" then 
	return 
end
function whichlane(Time, Num , camp_distance, camp_loc, bonus_hp)
	local LanePickTimer = Time;
	local LaneNum = Num;
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	if (DotaTime() - LanePickTimer > 5) then
		LanePickTimer = DotaTime();		
		if ( npcBot:GetLevel() >= 6) then
			local toplane_loc = GetLaneFrontLocation(GetOpposingTeam( ) , LANE_TOP, 0) * 0.5 + GetLaneFrontLocation(GetTeam( ) , LANE_TOP, 0) * 0.5;
			local midlane_loc = GetLaneFrontLocation(GetOpposingTeam( ) , LANE_MID, 0) * 0.5 + GetLaneFrontLocation(GetTeam( ) , LANE_MID, 0) * 0.5;
			local botlane_loc = GetLaneFrontLocation(GetOpposingTeam( ) , LANE_BOT, 0) * 0.5 + GetLaneFrontLocation(GetTeam( ) , LANE_BOT, 0) * 0.5;
			local lanedistance_top = GetUnitToLocationDistance( npcBot, toplane_loc);
			local lanedistance_mid = GetUnitToLocationDistance( npcBot, midlane_loc);
			local lanedistance_bot = GetUnitToLocationDistance( npcBot, botlane_loc);
			local timetobekill = 10;
			local radius = npcBot:GetCurrentMovementSpeed( ) * timetobekill;
			local toplane_herocounts = 0;
			local midlane_herocounts = 0;
			local botlane_herocounts = 0;
			local camp_herocounts = 0;
			local toplane_allyfactor = 0;
			local midlane_allyfactor = 0;
			local botlane_allyfactor = 0;
			local jungle_allyfactor = 0;	
			for k, lane in pairs(herofile.TableEnemyPlayerLaneNum) do
				if (IsHeroAlive(herofile.TableEnemyPlayerID[k]) and lane~= nil and lane == 1) then
					toplane_herocounts = toplane_herocounts + 1;
				elseif (IsHeroAlive(herofile.TableEnemyPlayerID[k]) and lane~= nil and lane == 2) then
					midlane_herocounts = midlane_herocounts + 1;
				elseif (IsHeroAlive(herofile.TableEnemyPlayerID[k]) and lane~= nil and lane == 3) then
					botlane_herocounts = botlane_herocounts + 1;
				end
			end
			if (camp_loc~= nil and LocHeroNum(camp_loc, 800) > 0) then
				camp_herocounts = LocHeroNum(camp_loc, 800);
			end
			for k, lane in pairs(herofile.TableAllyHeroLaneNum) do
				if (npcBot:GetPlayerID() ~= herofile.TableAllyPlayerID[k]) then
					if (IsHeroAlive(herofile.TableAllyPlayerID[k]) and herofile.TableAllyHeroPriority[k]~=nil and herofile.TableAllyHeroPriority[k] > GetPriority() and herofile.TableAllyHeroState[k]~= nil and herofile.TableAllyHeroState[k] == "gofarmjungle") then
						jungle_allyfactor = jungle_allyfactor + 12500;
					elseif (IsHeroAlive(herofile.TableAllyPlayerID[k]) and lane~= nil and lane == 1 and herofile.TableAllyHeroRole[k]~= nil and herofile.TableAllyHeroRole[k] < 4 and herofile.TableAllyHeroState[k]~= nil and herofile.TableAllyHeroState[k] == "gofarmlane") then
						toplane_allyfactor = 25000;
					elseif (IsHeroAlive(herofile.TableAllyPlayerID[k]) and lane~= nil and lane == 2 and herofile.TableAllyHeroRole[k]~= nil and herofile.TableAllyHeroRole[k] < 4 and herofile.TableAllyHeroState[k]~= nil and herofile.TableAllyHeroState[k] == "gofarmlane") then
						midlane_allyfactor = 25000;
					elseif (IsHeroAlive(herofile.TableAllyPlayerID[k]) and lane~= nil and lane == 3  and herofile.TableAllyHeroRole[k]~= nil and herofile.TableAllyHeroRole[k] < 4 and herofile.TableAllyHeroState[k]~= nil and herofile.TableAllyHeroState[k] == "gofarmlane") then
						botlane_allyfactor = 25000;
					end
				end
			end	
			local toplane_risk = toplane_herocounts * toplane_herocounts * 2000;
			local midlane_risk = midlane_herocounts * midlane_herocounts * 2000; 
			local botlane_risk = botlane_herocounts * botlane_herocounts * 2000;
			local camp_risk =  camp_herocounts * camp_herocounts * 2000;
			if (not IsInAllyTowerRange(toplane_loc, radius)) then
				toplane_risk = 25000;
			end
			if (not IsInAllyTowerRange(midlane_loc, radius)) then
				midlane_risk = 25000;
			end
			if (not IsInAllyTowerRange(botlane_loc, radius)) then
				botlane_risk = 25000;
			end
			local lanedistance_index = 1;
			local lanepick_top = (lanedistance_top * lanedistance_index) + toplane_risk + toplane_allyfactor; 
			local lanepick_mid = (lanedistance_mid * lanedistance_index) + midlane_risk + midlane_allyfactor; 
			local lanepick_bot = (lanedistance_bot * lanedistance_index) + botlane_risk + botlane_allyfactor; 
			local lanepick_jungle = (camp_distance * lanedistance_index) + camp_risk + jungle_allyfactor;
			local lanepick_roam = 25000;
			if ( lanepick_jungle == math.min(lanepick_top, lanepick_mid, lanepick_bot, lanepick_jungle, lanepick_roam) ) then
				LaneNum = 0;
			elseif ( lanepick_top == math.min(lanepick_top, lanepick_mid, lanepick_bot, lanepick_jungle, lanepick_roam) )then
				LaneNum = 1;		
			elseif ( lanepick_mid == math.min(lanepick_top, lanepick_mid, lanepick_bot, lanepick_jungle, lanepick_roam) ) then   
				LaneNum = 2;
			elseif ( lanepick_bot == math.min(lanepick_top, lanepick_mid, lanepick_bot, lanepick_jungle, lanepick_roam) ) then  
				LaneNum = 3;
			elseif ( lanepick_roam == math.min(lanepick_top, lanepick_mid, lanepick_bot, lanepick_jungle, lanepick_roam) ) then  
				LaneNum = 4;
			end
		else
			LaneNum = npcBot:GetAssignedLane();
		end
	end
	return LanePickTimer, LaneNum;
end
function roam(LaneNum, SwitchTimer, Strategy)
	local roam_p = 0;
	local RoamStrategy = Strategy;
	local RoamSwitchTimer = SwitchTimer;
	if (LaneNum == 4) then
		roam_p = 7.5; 
		if (DotaTime() - RoamSwitchTimer > 90 or ( not npcBot:IsAlive() ) ) then		 
			RoamStrategy = RandomInt(1, 50); 
			RoamSwitchTimer = DotaTime();
		end
	end	
	return roam_p, RoamSwitchTimer, RoamStrategy;
end
function goroam(RoamStrategy)
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local MainCarry = nil;
	local AllyHighestPriority = -1;
	local EnemyMainCarry =nil;
	local EnemyHighestPriority = 0;
	local Weakest_Hero = nil;
	local Lowest_hp = 99999;
	local com_state = nil;
	local com_target = nil;
	for k, AllyHeroPriority in pairs(herofile.TableAllyHeroPriority) do
		if (AllyHeroPriority~=nil and AllyHeroPriority > AllyHighestPriority and IsHeroAlive( herofile.TableAllyPlayerID[k] ) and herofile.TableAllyHeroState[k]~= nil and herofile.TableAllyHeroState[k]== "gofarmlane") then
			MainCarry = herofile.TableAllyPlayerID[k];
			AllyHighestPriority = AllyHeroPriority;
		end
	end
	for k, EnemyPlayerPriority in pairs(herofile.TableEnemyPlayerPriority) do
		if (EnemyPlayerPriority~=nil and EnemyPlayerPriority > EnemyHighestPriority and IsHeroAlive( herofile.TableEnemyPlayerID[k] )) then
			EnemyMainCarry = herofile.TableEnemyPlayerID[k];
			EnemyHighestPriority = EnemyPlayerPriority;
		end
	end
	for k, EnemyHeroHP in pairs(herofile.TableEnemyHeroHP) do
		if (EnemyHeroHP~=nil and EnemyHeroHP < Lowest_hp and IsHeroAlive( herofile.TableEnemyPlayerID[k] )) then
			Weakest_Hero = herofile.TableEnemyPlayerID[k];
			Lowest_hp = EnemyHeroHP;
		end
	end
	if (MainCarry~= nil and npcBot:GetUnitName() == GetSelectedHeroName(MainCarry) and RoamStrategy < 51) then 
		RoamStrategy = RoamStrategy + 50;
	end
	if (RoamStrategy >= 51 and RoamStrategy < 81 and EnemyMainCarry ~= nil) then 
		local LastSeenInfo = GetHeroLastSeenInfo( EnemyMainCarry );
		npcBot:Action_MoveToLocation( LastSeenInfo.location );
		com_state = "gogankenemy";
		com_target = EnemyMainCarry;
		
	elseif (RoamStrategy >= 81 and  RoamStrategy < 101 and Weakest_Hero ~= nil) then
		local LastSeenInfo = GetHeroLastSeenInfo( Weakest_Hero );
		npcBot:Action_MoveToLocation( LastSeenInfo.location );
		com_state = "gogankenemy";
		com_target = Weakest_Hero;
	elseif ( MainCarry~= nil ) then
		local LastSeenInfo = GetHeroLastSeenInfo( MainCarry );
		if (GetUnitToLocationDistance(npcBot, LastSeenInfo.location) > 600) then
			local target_loc = LastSeenInfo.location + RandomVector( 400 );
			npcBot:Action_MoveToLocation( target_loc );
			com_state = "gosupportcarry";
		end
	end
	return com_state, com_target;
end	
function farmlane(LaneNum)
	local farmlane_p = 0;
	if( LaneNum == 1 or LaneNum == 2 or LaneNum == 3 ) then
		farmlane_p = 7.1;
	end
	return farmlane_p;
end
function gofarmlane(LaneNum)
	local npcBot = GetBot();
	local com_state = "gofarmlane";
	local lanefront_index = GetLaneFrontAmount( GetTeam() ,  LaneNum , false)*0.5 + GetLaneFrontAmount( GetOpposingTeam() ,  LaneNum , false)*0.5;
	local lanefront_location =  GetLocationAlongLane( LaneNum, lanefront_index);
	local target_location = GetLaneFrontLocation( GetTeam(), LaneNum, -npcBot:GetAttackRange());
	local enemy_front_tower = GetFrontTower(GetOpposingTeam(), LaneNum);
	if ( IsInTowerRange(target_location ,900 - npcBot:GetAttackRange() ) or #(_G.EnemyFountain - target_location ) < #(_G.EnemyFountain - enemy_front_tower:GetLocation() )) then	
		local lanefront_amount = GetAmountAlongLane( LaneNum , enemy_front_tower:GetLocation() ).amount - 90/1764;
		target_location = GetLocationAlongLane( LaneNum, lanefront_amount ) ;
	end
	local current_lane = GetLaneNum( npcBot:GetLocation() );
	if (npcBot:IsChanneling( ) or npcBot:IsUsingAbility() or DotaTime()	< -1.5 ) then
		return com_state;
	end	
	if ( current_lane ~= LaneNum ) then
		if (GetUnitToLocationDistance(npcBot, lanefront_location) > math.min(npcBot:GetCurrentMovementSpeed() * 15, 4500) ) then
			if (CanUseTp()) then
				TpToLocation(target_location);
			else
				npcBot:Action_MoveToLocation(target_location);
			end
		else
			npcBot:Action_MoveToLocation(target_location);
		end
	elseif ( current_lane == LaneNum ) then
		local front_tower = GetFrontTower(GetTeam(), LaneNum);
		if (front_tower~= nil and #(_G.Fountain - lanefront_location ) < #(_G.Fountain - front_tower:GetLocation() ) ) then
			lanefront_location = front_tower:GetLocation();
		end
		if (GetUnitToLocationDistance(npcBot, lanefront_location) > math.min(npcBot:GetCurrentMovementSpeed() * 15, 4500) ) then
			if (CanUseTp()) then
				TpToLocation(target_location);
			else
				npcBot:Action_MoveToLocation(target_location);
			end
		else
			npcBot:Action_MoveToLocation(target_location);
		end
	end
	return com_state;
end
function lasthit(com_state)
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local lasthit_p = 0;
	local weakest_creep = nil;
	if (com_state == "gofarmlane") then
		local EnemyCreeps = npcBot:GetNearbyLaneCreeps(1200,true);
		local lowest_hp = 10000;
		local highest_hp = 0;
		local strongest_creep = nil;
		local creep_pos = nil;
		local itemdamage = 0;
		local extradamage = 0;
		if(CheckItemByName("item_quelling_blade")) then
			itemdamage = 24;
		end
		for creep_k,creep in pairs(EnemyCreeps) do 
			if(creep:IsAlive() and (((not IsInTowerRange(creep:GetLocation() ,(900 - npcBot:GetAttackRange()))))  )) then
				local creep_hp = creep:GetHealth();
				if(lowest_hp > creep_hp and creep_hp > 0 ) then
					lowest_hp = creep_hp;
					weakest_creep = creep;
					creep_pos = weakest_creep:GetLocation();	  		
				end
			end
		end	
		if(weakest_creep ~= nil) then 
			local rightClick =weakest_creep:GetActualIncomingDamage(npcBot:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL); 
			local CreepDamage = CreepDamageEstimate(weakest_creep);
			local ModifierDamage = ModifierDamageEstimate(weakest_creep);
			if (string.find(weakest_creep:GetUnitName( ), "siege")  ~= nil) then 
				rightClick = rightClick * 0.9;
				itemdamage = 0;
				CreepDamage = CreepDamage * 0.5;
				ModifierDamage = ModifierDamage * 0.2;
			end
			if (GetUnitToLocationDistance(npcBot, creep_pos) > npcBot:GetAttackRange()) then
				extradamage = (((GetUnitToLocationDistance(npcBot, creep_pos)-npcBot:GetAttackRange()) * 1.5 / npcBot:GetCurrentMovementSpeed( )) + npcBot:GetAttackPoint() + 1)* (CreepDamage + ModifierDamage);
			else 
				extradamage = npcBot:GetAttackPoint() * CreepDamage;
			end
			if(lowest_hp > 0 and lowest_hp <= ( rightClick + itemdamage  + extradamage) ) then
				lasthit_p = 15;
			elseif(lowest_hp > ( rightClick  + itemdamage +  extradamage) ) then 
				lasthit_p = 0;
			end
			if (lasthit_p == 15) then
				local nearesthero, HeroNum, MinDistance = FindNearestEnemyHero(npcBot:GetLocation());	
				if ( nearesthero~= nil and  MinDistance < herofile.TableEnemyPlayerAttackRange[HeroNum] + herofile.TableEnemyPlayerSpeed[HeroNum] * 0.5 and GetHeroLastSeenInfo( nearesthero ).time < 3) then
					local ExpoTime = GetUnitToLocationDistance(npcBot, creep_pos) * 2 / npcBot:GetCurrentMovementSpeed();
					if (npcBot:GetActualIncomingDamage( herofile.TableEnemyPlayerAttack[HeroNum], DAMAGE_TYPE_PHYSICAL ) *  ExpoTime > npcBot:GetMaxHealth() * 0.3 ) then
						lasthit_p = 0;	
					end
				end
			end
		end
	end
	return lasthit_p, weakest_creep;
end
function golasthit(AttackPointTimer, com_state)	
	local npcBot = GetBot();
	local lasthit_p, weakest_creep = lasthit(com_state);
	local creep_pos = weakest_creep:GetLocation();
	local lowest_hp = weakest_creep:GetHealth();
	local itemdamage = 0;
	local extradamage =0;
	local timer = AttackPointTimer;
	if (npcBot:IsChanneling( ) or npcBot:IsUsingAbility()) then
		return timer;
	end
	if(CheckItemByName("item_quelling_blade")) then
		itemdamage = 24;
	end	
	if(weakest_creep ~= nil) then 
		local rightClick = weakest_creep:GetActualIncomingDamage(npcBot:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL); 
		if (string.find(weakest_creep:GetUnitName( ), "siege")  ~= nil) then 
			rightClick = rightClick*0.9;
			itemdamage = 0;
		end
		
		if (GetUnitToUnitDistance(npcBot, weakest_creep) > npcBot:GetAttackRange()) then

			npcBot:Action_MoveToLocation(creep_pos);
		else
			if ( lowest_hp > rightClick + itemdamage and DotaTime() - AttackPointTimer < npcBot:GetAttackPoint() * 0.9) then
				npcBot:Action_AttackUnit(weakest_creep,true);
			elseif ( lowest_hp > rightClick + itemdamage and DotaTime() - AttackPointTimer >= npcBot:GetAttackPoint() * 0.9) then
				npcBot:Action_ClearActions( true ) ;
				timer = DotaTime(); 	
			elseif (lowest_hp <= rightClick + itemdamage) then
				npcBot:Action_AttackUnit(weakest_creep,true);
			end
		end
	end
	return timer;
end
function pullcreep(com_state)  
	local npcBot = GetBot();
	local EnemyCreeps = npcBot:GetNearbyLaneCreeps(1200,true);
	local nearestcreep = EnemyCreeps[1];
	local NearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1500, true, BOT_MODE_NONE ); 
	local pullcreep_p = 0;
	if (com_state == "gofarmlane") then
		if (#NearbyEnemyHeroes > 0 and nearestcreep ~= nil and GetUnitToUnitDistance(npcBot, nearestcreep) > npcBot:GetAttackRange() + npcBot:GetCurrentMovementSpeed() * 0.5 and (not IsInTowerRange(nearestcreep:GetLocation(), (975 - nearestcreep:GetAcquisitionRange()) ))) then
			for k, hero in pairs(NearbyEnemyHeroes) do
				if ( (hero:GetAttackRange() > npcBot:GetAttackRange() or IsInTowerRange(nearestcreep:GetLocation(), 900) ) and GetUnitToUnitDistance(npcBot, hero) > hero:GetAttackRange() + hero:GetCurrentMovementSpeed() * 0.5) then
					pullcreep_p = 7.38; 
				end
			end
		end
	end
	return pullcreep_p;
end
function gopullcreep(PullCreepTimer)
	local npcBot = GetBot();
	local timer = PullCreepTimer
	local EnemyCreeps = npcBot:GetNearbyLaneCreeps(1200,true);
	local NearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1500, true, BOT_MODE_NONE );
	local nearesthero = NearbyEnemyHeroes[1];
	local nearestcreep = EnemyCreeps[1];
	if (npcBot:IsChanneling( )) then
		return timer;
	end
	if (nearesthero ~= nil and nearestcreep~= nil) then
		if ( GetUnitToUnitDistance(npcBot, nearestcreep) > nearestcreep:GetAcquisitionRange() - 75 ) then
			npcBot:Action_MoveToLocation( nearestcreep:GetLocation() );
		else	
			if (DotaTime() - PullCreepTimer > 2) then 
				npcBot:Action_AttackUnit(nearesthero,true);
				timer = DotaTime();
			elseif ( DotaTime() - PullCreepTimer <= 2) then
				npcBot:Action_ClearActions(true);
			end
		end
	end
	return timer;
end
    		
function deny(com_state)
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local deny_p =0;
	local weakest_creep = nil;
	if (com_state == "gofarmlane") then
		local AllyCreeps = npcBot:GetNearbyLaneCreeps(1000,false);
		local lowest_hp = 10000;
		local creep_pos = nil;
		for creep_k,creep in pairs(AllyCreeps) do
			if(creep:IsAlive() and ((not IsInTowerRange(creep:GetLocation() ,(900-npcBot:GetAttackRange()))))) then
			   local creep_hp = creep:GetHealth();
				if(lowest_hp > creep_hp and creep_hp > 0 ) then
					lowest_hp = creep_hp;
					weakest_creep = creep;
					creep_pos = weakest_creep:GetLocation();	  		
				 end
			 end
		end
		if(weakest_creep ~= nil) then 
			local rightClick =weakest_creep:GetActualIncomingDamage(npcBot:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL); 
			local CreepDamage = CreepDamageEstimate(weakest_creep);
			if (string.find(weakest_creep:GetUnitName( ), "siege")  ~= nil) then 
				rightClick = rightClick * 0.5;
				CreepDamage = CreepDamage * 0.5;
			end
			extradamage = (((GetUnitToLocationDistance(npcBot, creep_pos)-npcBot:GetAttackRange()) / npcBot:GetCurrentMovementSpeed( )) * 1.5 + npcBot:GetAttackPoint() + 1 )* CreepDamage;
			
			if(lowest_hp > 0 and lowest_hp/weakest_creep:GetMaxHealth() < 0.5 and lowest_hp <= ( rightClick + extradamage)) then
				deny_p = 15.95, weakest_creep;
			elseif(lowest_hp >  rightClick ) then   
				deny_p = 15.95;
			end
			if (deny_p == 15.95) then
				local nearesthero, HeroNum, MinDistance = FindNearestEnemyHero(npcBot:GetLocation());	
				if ( nearesthero~= nil and  MinDistance < herofile.TableEnemyPlayerAttackRange[HeroNum] + herofile.TableEnemyPlayerSpeed[HeroNum] * 0.5 and GetHeroLastSeenInfo( nearesthero ).time < 3) then
					local ExpoTime = GetUnitToLocationDistance(npcBot, creep_pos) * 2 / npcBot:GetCurrentMovementSpeed();
					if (npcBot:GetActualIncomingDamage( herofile.TableEnemyPlayerAttack[HeroNum], DAMAGE_TYPE_PHYSICAL ) *  ExpoTime > npcBot:GetMaxHealth() * 0.2 ) then
						deny_p = 0; 
					end
				end
			end
		end
	end
	return deny_p, weakest_creep;
end
function godeny(AttackPointTimer, com_state)
	local npcBot = GetBot();
	local timer = AttackPointTimer;
	local deny_p, weakest_creep = deny(com_state);
	local creep_pos = weakest_creep:GetLocation();
	local lowest_hp = weakest_creep:GetHealth();
	local NearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_HIGH );		

	if (npcBot:IsChanneling( )) then
		return timer;
	end
	if(weakest_creep ~= nil) then 
		local rightClick =weakest_creep:GetActualIncomingDamage(npcBot:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL); 
		if (string.find(weakest_creep:GetUnitName( ), "siege")  ~= nil) then 
			rightClick = rightClick * 0.9;
		end	
		
		if (GetUnitToUnitDistance(npcBot, weakest_creep) > npcBot:GetAttackRange()) then
			npcBot:Action_MoveToLocation(creep_pos);
		else
			if (lowest_hp > rightClick and DotaTime() - AttackPointTimer < npcBot:GetAttackPoint() * 3) then 
				npcBot:Action_AttackUnit(weakest_creep,true);
			elseif (lowest_hp > rightClick and DotaTime() - AttackPointTimer >= npcBot:GetAttackPoint() * 3) then
				npcBot:Action_ClearActions( true ) ;
				timer = DotaTime(); 	
			elseif (lowest_hp <= rightClick ) then
				npcBot:Action_AttackUnit(weakest_creep,true);
			end
		end		
	end
	return timer;
end

function farmjungle(LaneNum, com_state) 
	local farmjungle_p = 0;	
	local npcBot = GetBot();
	if(LaneNum == 0 and DotaTime() > 30) then
		farmjungle_p = 7.49;
	else
		farmjungle_p = 0;
	end
	return farmjungle_p;
end

function gofarmjungle(camp_distance, camp_loc)
	local npcBot = GetBot();
	local com_state = "gofarmjungle";
	if (npcBot:IsChanneling( )) then
		return com_state;
	end
	local NearbyNeutralCreeps = npcBot:GetNearbyNeutralCreeps( 800 );
	local highest_priority = -999;
	local target_creep = nil;
	
	if (camp_loc ~= nil and GetUnitToLocationDistance(npcBot, camp_loc) <= 400 and #NearbyNeutralCreeps > 0) then

		for creep_k, creep in pairs( NearbyNeutralCreeps ) do 
			local creep_priority = creep:GetHealth() + (1 - GetUnitToUnitDistance(npcBot, creep)/1500);

			if (creep:GetUnitName() == "npc_dota_neutral_dark_troll_warlord") then
				creep_priority = 1;
			elseif (creep:GetUnitName() == "npc_dota_neutral_ghost" or creep:GetUnitName() == "npc_dota_neutral_prowler_shaman" or creep:GetUnitName() == "npc_dota_neutral_enraged_wildkin") then
				creep_priority = 9999;
			elseif (creep:GetUnitName() == "npc_dota_neutral_prowler_acolyte") then
				creep_priority = 9997;
			elseif (creep:GetUnitName() == "npc_dota_neutral_granite_golem") then
				creep_priority = 9996;
			end
			
			if(creep:IsAlive() and highest_priority < creep_priority) then
				highest_priority = creep_priority;
				target_creep = creep;

			end
		end
		npcBot:Action_AttackUnit(target_creep, false); 
	elseif (camp_loc ~= nil and (GetUnitToLocationDistance(npcBot, camp_loc) > 400 or (not IsLocationVisible(camp_loc)) ) ) then
		npcBot:Action_MoveToLocation(camp_loc);	
	elseif (camp_loc == nil) then
		print('recalculating');
	end
	return com_state;
end

function pullcamp() 
	local pullcamp_p = 0;
	if (DotaTime() < math.ceil(DotaTime()/60) * 60) then
		pullcamp_p = 7.50;
	end
	return pullcamp_p;
end

function gopullcamp()

end

function gopullcamp_fallback()

end

function attackhero(com_state)
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local NearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
	local nearesthero = NearbyEnemyHeroes[1];
	local nearesttower = FindNearestTower( npcBot:GetLocation( ) );
	local attackhero_p = 0;
	local lasthit_p, weakest_creep = lasthit(com_state);
	local HighestPriority = 0;

	if (nearesthero ~= nil and (not IsInTowerRange(nearesthero:GetLocation(), 900 - npcBot:GetAttackRange()) ) and (not IsInTowerRange(npcBot:GetLocation(), 900) ) ) then
		local EnemyRawPower = GetNearbyEnemyPower( nearesthero:GetLocation() );
		local EnemyHealth = GetNearbyEnemyHealth( nearesthero:GetLocation() ) ;
		local AllyRawPower = GetNearbyAllyPower( npcBot ); 
		local AllyHealth = GetNearbyAllyHealth( npcBot );	
				
		local EnemyDamageEstimate = EnemyDamageEstimate(nearesthero:GetLocation()); 
		local EnemySpeedEstimate = AverageSpeedEstimate(nearesthero:GetLocation());
		local ExpoTime = EnemyStunEstimate( npcBot:GetLocation() );
		if (nearest_tower~= nil and EnemySpeedEstimate~= 0) then
			ExpoTime = math.max(ExpoTime + (GetUnitToUnitDistance(npcBot, nearest_tower)/npcBot:GetCurrentMovementSpeed() - GetUnitToUnitDistance(npcBot, nearest_tower)/EnemySpeedEstimate), 3);
		else
			ExpoTime = math.max(ExpoTime + (npcBot:DistanceFromFountain() / npcBot:GetCurrentMovementSpeed() -  npcBot:DistanceFromFountain()/EnemySpeedEstimate), 3);
		end
		
		if ( EnemyDamageEstimate * ExpoTime > npcBot:GetHealth() and GetUnitToUnitDistance(npcBot, nearesthero) < nearesthero:GetAttackRange() + nearesthero:GetCurrentMovementSpeed() ) then
			return attackhero_p, nearesthero;
		end
		
		if ( EnemyRawPower + EnemyHealth > (AllyRawPower + AllyHealth) * 2 ) then
			return attackhero_p, nearesthero;
		end
	
		local NearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps(1200,true);
		local NearbyAllyCreep = npcBot:GetNearbyLaneCreeps(1200,false);
		local allycreepdamage = 0;
		local enemycreepdamage = 0;
		for k, creep in pairs(NearbyEnemyCreeps) do
			if ( GetUnitToUnitDistance(npcBot, creep) < creep:GetAcquisitionRange() + 100) then
				enemycreepdamage = enemycreepdamage + npcBot:GetActualIncomingDamage(creep:GetAttackDamage() ,DAMAGE_TYPE_PHYSICAL);
			end
		end		
		for k, creep in pairs(NearbyAllyCreep) do
			if ( GetUnitToUnitDistance(nearesthero, creep) < creep:GetAcquisitionRange() + 100) then
				allycreepdamage = allycreepdamage + nearesthero:GetActualIncomingDamage(creep:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL);
			end
		end
		
		if ( nearesttower~= nil and GetUnitToUnitDistance(nearesthero, nearesttower) < 800 or (IsInAllyTowerRange(npcBot:GetLocation(), 800) and (800 - GetUnitToUnitDistance(npcBot, nearesttower)) > nearesthero:GetAttackRange()) )then
			allycreepdamage = allycreepdamage + nearesthero:GetActualIncomingDamage(nearesttower:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL);
		end	

		local extradamage = 0;
		if (npcBot:GetAttackRange() < nearesthero:GetAttackRange() ) then
			extradamage = (GetUnitToUnitDistance(npcBot, nearesthero) - npcBot:GetAttackRange())/npcBot:GetCurrentMovementSpeed() * nearesthero:GetEstimatedDamageToTarget( true, npcBot, 5, DAMAGE_TYPE_PHYSICAL) * 0.2;
		elseif (nearesthero:GetAttackRange() < npcBot:GetAttackRange() ) then
			extradamage = (GetUnitToUnitDistance(npcBot, nearesthero) - nearesthero:GetAttackRange() )/nearesthero:GetCurrentMovementSpeed() * npcBot:GetEstimatedDamageToTarget( true, nearesthero, 5, DAMAGE_TYPE_PHYSICAL) * 0.2;	
		end	

		if (npcBot:GetAttackRange() > nearesthero:GetAttackRange()) then
			if ( GetUnitToUnitDistance( npcBot, nearesthero) < nearesthero:GetAttackRange() + nearesthero:GetCurrentMovementSpeed() * 0.5 ) then
				attackhero_p = 7.38;
			elseif ( nearesthero:IsStunned( ) or nearesthero:IsDisarmed( ) ) then
				attackhero_p = 11;
			elseif (( npcBot:GetHealth() )/(nearesthero:GetEstimatedDamageToTarget( true, npcBot, 3, DAMAGE_TYPE_PHYSICAL) + enemycreepdamage * 3) > (nearesthero:GetHealth() - extradamage)/(npcBot:GetEstimatedDamageToTarget( true, nearesthero, 3, DAMAGE_TYPE_PHYSICAL) + allycreepdamage * 3)  and npcBot:GetEstimatedDamageToTarget( true, nearesthero, 3, DAMAGE_TYPE_PHYSICAL) + allycreepdamage * 3 > nearesthero:GetEstimatedDamageToTarget( true, npcBot, 3, DAMAGE_TYPE_PHYSICAL) + enemycreepdamage * 3 and npcBot:GetEstimatedDamageToTarget( true, nearesthero, 3, DAMAGE_TYPE_PHYSICAL) > enemycreepdamage * 3 * 2) then
				attackhero_p = 11;
			end
		elseif (npcBot:GetAttackRange() <= nearesthero:GetAttackRange()) then 
			if ( nearesthero:IsStunned( ) or nearesthero:IsDisarmed( ) ) then
				attackhero_p = 15.299;
			elseif (( npcBot:GetHealth() - - extradamage)/(nearesthero:GetEstimatedDamageToTarget( true, npcBot, 3, DAMAGE_TYPE_PHYSICAL) + enemycreepdamage * 3) > nearesthero:GetHealth() /(npcBot:GetEstimatedDamageToTarget( true, nearesthero, 3, DAMAGE_TYPE_PHYSICAL) + allycreepdamage * 3)  and npcBot:GetEstimatedDamageToTarget( true, nearesthero, 3, DAMAGE_TYPE_PHYSICAL) + allycreepdamage * 3 > nearesthero:GetEstimatedDamageToTarget( true, npcBot, 3, DAMAGE_TYPE_PHYSICAL) + enemycreepdamage * 3 and npcBot:GetEstimatedDamageToTarget( true, nearesthero, 3, DAMAGE_TYPE_PHYSICAL) > enemycreepdamage * 3 * 2)then
				attackhero_p = 11;
			end
		end
		
		if (attackhero_p == 11 and lasthit_p == 0) then
			attackhero_p = 11.5;
		end
	end
	
	if (attackhero_p == 0) then
		for k, AllyHeroState in pairs (herofile.TableAllyHeroState) do
			if (AllyHeroState~= nil and AllyHeroState == "goretreat" and herofile.TableAllyHeroCom[k] ~= nil and herofile.TableAllyHeroCom[k] == "helpme" and herofile.TableAllyHeroHandle[k]~= nil and GetUnitToLocationDistance(npcBot, herofile.TableAllyHeroHandle[k]:GetLocation()) < npcBot:GetCurrentMovementSpeed() * 10 and herofile.TableAllyHeroPriority[k] > HighestPriority) then
				local AllyNearbyEnemyHeroes = herofile.TableAllyHeroHandle[k]:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
				local AllyNearestHero = AllyNearbyEnemyHeroes[1];
				if ( AllyNearestHero ~= nil ) then
					attackhero_p = 11.5;
					nearesthero = AllyNearestHero;
					HighestPriority = herofile.TableAllyHeroPriority[k]; 
				end					
			end
		end
	end
    return attackhero_p, nearesthero;
end

function goattackhero()
	local npcBot = GetBot();
	local attackhero_p, attackhero = attackhero();
	if (npcBot:IsChanneling( ) or npcBot:IsUsingAbility()	) then
		return;
	end	
	if (attackhero ~= nil) then
		npcBot:Action_AttackUnit(attackhero, false);
	end
end

function fallback( bonus_hp )
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local tableEnemyHero = GetUnitList( UNIT_LIST_ENEMY_HEROES ) ;
	local NearbyAllyHeroes = npcBot:GetNearbyHeroes( 900, false, BOT_MODE_NONE );
	local nearesthero, HeroNum, MinDistance = FindNearestEnemyHero(npcBot:GetLocation());
	local tableNearbyCreeps = npcBot:GetNearbyLaneCreeps(900,true);
	local nearestcreep = tableNearbyCreeps[1];
	local NearbyTowers = npcBot:GetNearbyTowers( 1200, true );
	local fallback_p = 0;
	local dangerunit = nil;
	local fallbackrange = 0;
	local highest_range = 0;
	
	if (not npcBot:IsAlive() ) then
		return fallback_p, danger_loc, fallbackrange;
	end
	for k, PlayerID in pairs(herofile.TableEnemyPlayerID) do
		local LastSeenLocation = GetHeroLastSeenInfo( PlayerID ).location; 
		local LastSeenTime = GetHeroLastSeenInfo( PlayerID ).time;
		if (IsHeroAlive( PlayerID ) and LastSeenTime > -1 and LastSeenTime < 3 and GetUnitToLocationDistance(npcBot, LastSeenLocation) < 1300 and GetUnitToLocationDistance(npcBot, LastSeenLocation) < herofile.TableEnemyPlayerAttackRange[k] + 0.5 * herofile.TableEnemyPlayerSpeed[k] and herofile.TableEnemyPlayerAttackRange[k] > npcBot:GetAttackRange() + npcBot:GetCurrentMovementSpeed() * 0.5 ) then
			fallback_p = 7.37;
			danger_loc = LastSeenLocation;
			fallbackrange = math.min(herofile.TableEnemyPlayerAttackRange[k] + herofile.TableEnemyPlayerSpeed[k] * 0.5, 1300) ;
		end
	end
	local EnemySpeedEstimate = math.max(AverageSpeedEstimate(npcBot:GetLocation()), 1);
	local ExpoTime = EnemyStunEstimate( npcBot:GetLocation() );
	
	if (nearest_tower~= nil) then
		ExpoTime = math.max(ExpoTime + (GetUnitToUnitDistance(npcBot, nearest_tower)/npcBot:GetCurrentMovementSpeed() - GetUnitToUnitDistance(npcBot, nearest_tower)/EnemySpeedEstimate), 3);
	else
		ExpoTime = math.max(ExpoTime + (npcBot:DistanceFromFountain() / npcBot:GetCurrentMovementSpeed() -  npcBot:DistanceFromFountain()/EnemySpeedEstimate), 3);
	end
	local TotalEstimateEnemyDamage = 0;
	for j, hero in pairs (tableEnemyHero) do
		if (GetUnitToUnitDistance(hero, npcBot) < math.max(hero:GetCurrentMovementSpeed() * ExpoTime + hero:GetAttackRange(), 1500) ) then					
			TotalEstimateEnemyDamage = TotalEstimateEnemyDamage + (ExpoTime) * hero:GetEstimatedDamageToTarget(true, npcBot, 5, DAMAGE_TYPE_ALL) * 0.2; 
		end
	end
	if( (npcBot:WasRecentlyDamagedByCreep( 1.5 ) or npcBot:WasRecentlyDamagedByTower(1.5)) and nearestcreep~= nil and (npcBot:HasModifier("modifier_flask_healing") or npcBot:HasModifier("modifier_clarity_potion") )) then
		danger_loc = npcBot:GetLocation();
		fallbackrange = npcBot:GetCurrentMovementSpeed() * 1.5;
		fallback_p = 14.01; 
	elseif (nearesthero~= nil and MinDistance < 1200 and GetHeroLastSeenInfo( nearesthero ).time < 3 and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.9 and npcBot:HasModifier("modifier_flask_healing") ) then

		fallback_p = 14.01;
		danger_loc = GetHeroLastSeenInfo( nearesthero ).location; 
		fallbackrange = herofile.TableEnemyPlayerAttackRange[HeroNum] + herofile.TableEnemyPlayerSpeed[HeroNum];
	elseif (nearesthero~= nil and MinDistance < 1200 and GetHeroLastSeenInfo( nearesthero ).time < 3 and npcBot:GetMana()/npcBot:GetMaxMana() < 0.9 and npcBot:HasModifier("modifier_clarity_potion")) then

		fallback_p = 14.01;
		danger_loc = GetHeroLastSeenInfo( nearesthero ).location;  
		fallbackrange = herofile.TableEnemyPlayerAttackRange[HeroNum] + herofile.TableEnemyPlayerSpeed[HeroNum];	
	elseif (nearesthero~= nil and TotalEstimateEnemyDamage >= npcBot:GetHealth() and MinDistance < 1300) then
		fallback_p = 13.99;
		danger_loc = GetHeroLastSeenInfo( nearesthero ).location;
		fallbackrange = 1300;
	elseif(npcBot:WasRecentlyDamagedByTower( 1 ) and #NearbyTowers > 0) then

		fallback_p = 11.61;
		danger_loc = NearbyTowers[1]:GetLocation() ; 
		fallbackrange = 900;	
	elseif(IsInTowerRange( npcBot:GetLocation(), 900) and #NearbyTowers > 0 and (npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.8 or npcBot:GetHealth() < 1000) and nearesthero ~= nil and MinDistance < 1500) then 

		fallback_p = 11.60;
		danger_loc = NearbyTowers[1]:GetLocation(); 
		fallbackrange = 900;	
		
	elseif( npcBot:WasRecentlyDamagedByCreep( 1.5 ) and nearestcreep~= nil ) then	

		danger_loc = npcBot:GetLocation();  
		fallbackrange = npcBot:GetCurrentMovementSpeed() * 1.5;
		fallback_p = 10.5; 
	elseif(IsInTowerRange(npcBot:GetLocation(), 900) and #NearbyTowers > 0) then
		danger_loc = NearbyTowers[1]:GetLocation(); 
		fallbackrange = 900;
		fallback_p = 7.4;
	end
	
	if (fallback_p < 10.9 and nearesthero ~= nil and npcBot:WasRecentlyDamagedByAnyHero( 1.5 ) ) then
		for k, PlayerID in pairs(herofile.TableEnemyPlayerID) do
			if (IsHeroAlive( PlayerID )  and npcBot:WasRecentlyDamagedByPlayer(PlayerID , 1.5) and GetHeroLastSeenInfo( PlayerID ).time < 3 and GetUnitToLocationDistance(npcBot, GetHeroLastSeenInfo( PlayerID ).location)  < math.max(herofile.TableEnemyPlayerAttackRange[k] + herofile.TableEnemyPlayerSpeed[k],1250) ) then
				fallback_p = 10.9;
				danger_loc = GetHeroLastSeenInfo( PlayerID ).location; 
				fallbackrange = math.max(herofile.TableEnemyPlayerAttackRange[k] + herofile.TableEnemyPlayerSpeed[k],1250);
			end
		end
	end
	return fallback_p, danger_loc, fallbackrange;    	
end
function gofallback(danger_loc, fallbackrange)
	local npcBot = GetBot();
	if (npcBot:IsChanneling()) then
		return;
	end
	local target_loc = nil;
	local nearest_tower = FindNearestTower(npcBot:GetLocation());
	if (danger_loc ~= nil and GetUnitToLocationDistance(npcBot,danger_loc) < fallbackrange) then
		if (nearest_tower ~= nil and #(danger_loc - _G.Fountain) >=  #(npcBot:GetLocation() - _G.Fountain) and  #(npcBot:GetLocation() - _G.Fountain) > #(nearest_tower:GetLocation() - _G.Fountain) + 700) then
			target_loc = nearest_tower:GetLocation();
		elseif (nearest_tower ~= nil and #(danger_loc - _G.Fountain) >=  #(npcBot:GetLocation() - _G.Fountain) and  #(npcBot:GetLocation() - _G.Fountain) <= #(nearest_tower:GetLocation() - _G.Fountain) + 700 ) then
			target_loc = _G.Fountain;
		elseif (nearest_tower ~= nil and #(danger_loc - _G.Fountain) <  #(npcBot:GetLocation() - _G.Fountain) and  (not IsInAllyTowerRange(npcBot:GetLocation(), 700)) ) then
			target_loc = nearest_tower:GetLocation();
		elseif (nearest_tower ~= nil and #(danger_loc - _G.Fountain) <  #(npcBot:GetLocation() - _G.Fountain) and  (IsInAllyTowerRange(npcBot:GetLocation(), 700)) ) then
			if ( (math.floor(math.floor(DotaTime())/2) %2 == 0) ) then
				target_loc = nearest_tower:GetLocation() + Vector(150, 150);
			else
				target_loc = nearest_tower:GetLocation() + Vector(-150, -150);
			end
		else
			target_loc = _G.Fountain;	
		end
		npcBot:Action_MoveToLocation(target_loc);
	else
		npcBot:Action_ClearActions(true);
	end
end
function killhero()
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local killhero_p = 0;
	local TargetPlayer = nil;
	local HighestPriority = -99999;
	local tableAllyHero = GetUnitList( UNIT_LIST_ALLIED_HEROES ) ;
	local TableEnemyHero = GetUnitList( UNIT_LIST_ENEMY_HEROES ) ;
	local Distance = 0;
	if (npcBot:IsAlive()) then
		local NearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps(1200,true);
		local enemycreepdamage = 0;
		local allycreepdamage = 0;
		for k, creep in pairs(NearbyEnemyCreeps) do
			if ( GetUnitToUnitDistance(npcBot, creep) < creep:GetAcquisitionRange() + 100) then
				enemycreepdamage = enemycreepdamage + npcBot:GetActualIncomingDamage(creep:GetAttackDamage() ,DAMAGE_TYPE_PHYSICAL);
			end
		end		
		for k, PlayerID in pairs(herofile.TableEnemyPlayerID) do
			local nearest_enemy_tower , nearest_tower_name = FindEnemyNearestTower(npcBot:GetLocation());
			local BehindTower = 0;
			if (IsInTowerRange(npcBot:GetLocation(), 900) and herofile.TableLastSeenInfo[k].location ~=nil and #(herofile.TableLastSeenInfo[k].location - _G.EnemyFountain) + 450 < #(nearest_enemy_tower:GetLocation() - _G.EnemyFountain) )then
				BehindTower = 1;
			end
			if (BehindTower == 0 and IsHeroAlive( PlayerID ) and herofile.TableLastSeenInfo[k].time < 5 and herofile.TableLastSeenInfo[k].location ~=nil and (not IsInEnemyBase(herofile.TableLastSeenInfo[k].location)) and GetUnitToLocationDistance(npcBot, herofile.TableLastSeenInfo[k].location) < math.max(npcBot:GetCurrentMovementSpeed() * 10 + npcBot:GetAttackRange(), 1500) ) then
				if (IsInTowerRange(npcBot:GetLocation(), 900) or IsInTowerRange(herofile.TableLastSeenInfo[k].location, 900 - npcBot:GetAttackRange())) then
					enemycreepdamage = enemycreepdamage + npcBot:GetActualIncomingDamage(nearest_enemy_tower:GetAttackDamage() ,DAMAGE_TYPE_PHYSICAL);
				end
					if ( herofile.TableEnemyPlayerHandle[k]~= nil ) then
						local NearByAllyStun = npcBot:GetStunDuration( true ) + npcBot:GetSlowDuration( true ) * 0.2;
						local NearByAllyDamage = npcBot:GetEstimatedDamageToTarget(true, herofile.TableEnemyPlayerHandle[k], 5, DAMAGE_TYPE_ALL) * 0.2;
						for j, hero in pairs (tableAllyHero) do
							if (hero:GetUnitName() ~= npcBot:GetUnitName() and GetUnitToUnitDistance(hero, herofile.TableEnemyPlayerHandle[k]) < math.max(hero:GetAttackRange() + hero:GetCurrentMovementSpeed() * 3, 1500)  and hero:GetHealth()/hero:GetMaxHealth() > 0.3) then					
								NearByAllyStun = NearByAllyStun + hero:GetStunDuration( true ) + hero:GetSlowDuration( true ) * 0.2;
								NearByAllyDamage = NearByAllyDamage + hero:GetEstimatedDamageToTarget(true, herofile.TableEnemyPlayerHandle[k], 5, DAMAGE_TYPE_ALL) * 0.2;
							end
						end
						if (IsInAllyTowerRange(herofile.TableEnemyPlayerHandle[k]:GetLocation(), 800)) then
							local  nearest_ally_tower = FindNearestTower(herofile.TableEnemyPlayerHandle[k]:GetLocation());
							allycreepdamage = allycreepdamage + herofile.TableEnemyPlayerHandle[k]:GetActualIncomingDamage(nearest_ally_tower:GetAttackDamage() ,DAMAGE_TYPE_PHYSICAL);
						end
						local ExpoTime = NearByAllyStun + GetRemainControlTime(herofile.TableEnemyPlayerHandle[k]);
						local nearest_tower , nearest_tower_name = FindEnemyNearestTower(herofile.TableEnemyPlayerHandle[k]:GetLocation());
						if (nearest_tower~= nil) then
							ExpoTime = math.max(ExpoTime + (GetUnitToUnitDistance(herofile.TableEnemyPlayerHandle[k], nearest_tower)/herofile.TableEnemyPlayerHandle[k]:GetCurrentMovementSpeed()), 3);
						else
							ExpoTime = math.max(ExpoTime + (#(herofile.TableEnemyPlayerHandle[k]:GetLocation() - _G.EnemyFountain)/herofile.TableEnemyPlayerHandle[k]:GetCurrentMovementSpeed()), 3);
						end
						if (GetUnitToUnitDistance(npcBot, herofile.TableEnemyPlayerHandle[k]) < math.max(npcBot:GetAttackRange() + npcBot:GetCurrentMovementSpeed() * ExpoTime, 1500) ) then
							local TotalEstimateAllyDamage = (ExpoTime - (GetUnitToUnitDistance(npcBot, herofile.TableEnemyPlayerHandle[k]) - npcBot:GetAttackRange())/npcBot:GetCurrentMovementSpeed()) * npcBot:GetEstimatedDamageToTarget(true, herofile.TableEnemyPlayerHandle[k], 5, DAMAGE_TYPE_ALL) * 0.2 + allycreepdamage * ExpoTime;
							for j, hero in pairs (tableAllyHero) do
								if (hero:GetUnitName() ~= npcBot:GetUnitName() and GetUnitToUnitDistance(hero, herofile.TableEnemyPlayerHandle[k]) < math.max(hero:GetCurrentMovementSpeed() * ExpoTime + hero:GetAttackRange(), 1500) and hero:GetHealth()/hero:GetMaxHealth() > 0.3) then					
									TotalEstimateAllyDamage = TotalEstimateAllyDamage + (ExpoTime - (GetUnitToUnitDistance(hero, herofile.TableEnemyPlayerHandle[k]) - hero:GetAttackRange())/hero:GetCurrentMovementSpeed()) * hero:GetEstimatedDamageToTarget(true, herofile.TableEnemyPlayerHandle[k], 5, DAMAGE_TYPE_ALL) * 0.2;
								end
							end
							local NearByEnemyDamage = herofile.TableEnemyPlayerHandle[k]:GetEstimatedDamageToTarget(true, npcBot, 5, DAMAGE_TYPE_ALL) * 0.2;
							for hero_k, hero in pairs (herofile.TableEnemyPlayerHandle) do
								if (hero:GetUnitName() ~= herofile.TableEnemyPlayerHandle[k]:GetUnitName() and GetUnitToUnitDistance(hero, herofile.TableEnemyPlayerHandle[k]) < math.max(hero:GetAttackRange() + hero:GetCurrentMovementSpeed() * 3, 1500) or GetUnitToUnitDistance(hero, npcBot) < math.max(hero:GetAttackRange() + hero:GetCurrentMovementSpeed() * 3, 1500)) then
									NearByEnemyDamage = NearByEnemyDamage + hero:GetEstimatedDamageToTarget(true, npcBot, 5, DAMAGE_TYPE_ALL) * 0.2;
								end
							end
							if (TotalEstimateAllyDamage >= herofile.TableEnemyPlayerHandle[k]:GetHealth() and herofile.TableEnemyPlayerHandle[k]:GetHealth()/(NearByAllyDamage + allycreepdamage) < (npcBot:GetHealth() - npcBot:GetMaxHealth() * 0.3)/(NearByEnemyDamage + enemycreepdamage) ) then
								TargetPlayer = k;
								killhero_p = 15.302;
								HighestPriority = herofile.TableEnemyPlayerPriority[k];
							end
						end
					else
						local HeroNum = GetVarInTable(npcBot:GetPlayerID(), herofile.TableAllyPlayerID);
						if (herofile.TableAllyHeroState[HeroNum] == "gokillhero" and herofile.TableAllyHeroTarget[HeroNum] == k and (not IsInTowerRange(npcBot:GetLocation(), 900))) then
							local NearByAllyDamage = npcBot:GetRawOffensivePower();
							for j, hero in pairs (tableAllyHero) do
								if (hero:GetUnitName() ~= npcBot:GetUnitName() and GetUnitToLocationDistance(hero, herofile.TableLastSeenInfo[k].location) < math.max(hero:GetAttackRange() + hero:GetCurrentMovementSpeed()*3, 1500) and hero:GetHealth()/hero:GetMaxHealth() > 0.3) then					
									NearByAllyDamage = NearByAllyDamage + hero:GetRawOffensivePower();
								end
							end
							if (herofile.TableEnemyHeroHP[k]/NearByAllyDamage < (npcBot:GetHealth() - npcBot:GetMaxHealth() * 0.3)/(GetNearbyEnemyPower( npcBot:GetLocation() ) * 0.2  + enemycreepdamage) ) then
							TargetPlayer = k;
							killhero_p = 15.301;
							HighestPriority = herofile.TableEnemyPlayerPriority[k];
							end
						end
					end
			else
				local HeroNum = GetVarInTable(npcBot:GetPlayerID(), herofile.TableAllyPlayerID);
				if (herofile.TableAllyHeroState[HeroNum] == "gokillhero" and herofile.TableAllyHeroTarget[HeroNum] == k) then
					herofile.TableAllyHeroState[HeroNum] = nil;
					herofile.TableAllyHeroTarget[HeroNum] = nil;
				end
			end
		end
	end
	return killhero_p, TargetPlayer;
end			
function gokillhero()
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local killhero_p, killhero = killhero();
	local com_state = "gokillhero";
	local com_target = killhero;
	if (npcBot:IsChanneling( )) then
		return com_state, com_target;
	end
	if (killhero~= nil) then
		if (herofile.TableEnemyPlayerHandle[killhero] ~= nil) then
			npcBot:Action_AttackUnit(herofile.TableEnemyPlayerHandle[killhero], false);
		elseif( herofile.TableLastSeenInfo[killhero].location ~= nil ) then
			npcBot:Action_MoveToLocation(herofile.TableLastSeenInfo[killhero].location);
		end
	end
	return com_state, com_target;
end
function dodgelinear()
	local npcBot = GetBot();
	local angle = npcBot:GetFacing( );
	local speed = npcBot:GetCurrentMovementSpeed();
	local radians = angle * math.pi / 180;
	local TableProjectiles = GetLinearProjectiles( );
	local min_distance = 99999;
	local nearestprojectile = nil;
	local nearestprojectile_name = nil;
	local radius = 0;
	local velocity = nil;
	local location = nil;
	local future_loc = nil;
	local dodgelinear_p = 0;
	local target_loc = nil;
	for k, LinearProjectiles in pairs(TableProjectiles) do
		if ( GetTeamForPlayer(LinearProjectiles.playerid) == GetOpposingTeam( ) and GetUnitToLocationDistance(npcBot, LinearProjectiles.location) < min_distance) then
			min_distance = GetUnitToLocationDistance(npcBot, LinearProjectiles.location);
			nearestprojectile_name = LinearProjectiles.ability;
			radius = LinearProjectiles.radius;
			velocity = LinearProjectiles.velocity;
			location = LinearProjectiles.location;
		end
	end
	if (min_distance < 2500) then
		local a = velocity.y/velocity.x;
		local b = location.y - a * location.x;
		local c = npcBot:GetLocation().x;
		local d = npcBot:GetLocation().y;
		local h = math.sqrt(c * c + (b - d) * (b - d) - (a * (b - d) - c) * (a * (b - d) -c )/(a * a + 1));
		local arrowspeed = math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y);
		if ( h <= radius + 150 ) then
			for i = 1, 30 do
				radians = (angle + i * 3 ) * math.pi / 180;
				c = npcBot:GetLocation().x + math.cos(radians) * speed * min_distance/arrowspeed;
				d = npcBot:GetLocation().y + math.sin(radians) * speed * min_distance/arrowspeed;
				h = math.sqrt(c*c + (b - d) * (b - d) - (a*(b-d) -c)*(a*(b-d) -c)/(a*a +1));
				if (h > radius + 150 ) then
					dodgelinear_p = 20.1;
					target_loc = Vector(c, d);
					return dodgelinear_p, target_loc;
				end
				radians = (angle - i * 3) * math.pi / 180;
				c = npcBot:GetLocation().x + math.cos(radians) * speed * min_distance/arrowspeed;
				d = npcBot:GetLocation().y + math.sin(radians) * speed * min_distance/arrowspeed;
				h = math.sqrt(c*c + (b - d) * (b - d) - (a*(b-d) -c)*(a*(b-d) -c)/(a*a +1));
				if (h > radius + 150 ) then
					dodgelinear_p = 20.1;
					target_loc = Vector(c, d);
					return dodgelinear_p, target_loc;
				end
			end
		end
	end
	return dodgelinear_p, target_loc;
end
function gododgelinear()
	local dodgelinear_p, target_loc = dodgelinear();
	local npcBot = GetBot();
	if (target_loc ~= nil) then
		npcBot:Action_MoveToLocation(target_loc);
	end
end
function dodgeaoe( com_state )
	local dodgeaoe_p = 0;
	local npcBot = GetBot();
	if (com_state ~= "gokillhero" and IsInAoeArea( npcBot:GetLocation() )) then	
		dodgeaoe_p = 15.1;		
	end
	return dodgeaoe_p;
end
function gododgeaoe()
	local npcBot = GetBot();
	local speed = npcBot:GetCurrentMovementSpeed();
	local angle = npcBot:GetFacing( );
	local radians = angle * math.pi / 180;
	local target_loc = nil;
	local cor_x = nil;
	local cor_y = nil;
	for j = 1, 5 do
		speed = npcBot:GetCurrentMovementSpeed() * j;
		for i = 0, 6 do	
			radians = (angle + i * 30) * math.pi / 180;
			cor_x = math.cos(radians) * speed;
			cor_y = math.sin(radians) * speed;
			target_loc = npcBot:GetLocation() + Vector(cor_x, cor_y);		
			if ( not IsInAoeArea(target_loc) ) then
				npcBot:Action_MoveToLocation(target_loc);
				return;
			end
			radians = (angle - i * 30) * math.pi / 180;
			cor_x = math.cos(radians) * speed;
			cor_y = math.sin(radians) * speed;
			target_loc = npcBot:GetLocation() + Vector(cor_x, cor_y);		
			if ( not IsInAoeArea(target_loc) ) then
				npcBot:Action_MoveToLocation(target_loc);
				return;
			end
		end
	end		
end 
function TeamFightState()
	local npcBot = GetBot();
	local teamfight_state = 0;
	local NearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	if (LocHeroNum(npcBot:GetLocation(), 1500) > 3 and  #NearbyAllyHeroes > 2 ) then 
		teamfight_state = 1;
	end
	return teamfight_state;
end
function teamfight()
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local teamfight_p = 0;
	local target_loc = nil;
	local priority = -99999;
	if ( TeamFightState() == 0 and npcBot:GetLevel() > 6) then 
		for k, state in pairs (herofile.TableAllyTeamFightState) do
			if (herofile.TableAllyHeroHandle[k] ~= nil and herofile.TableAllyPlayerID[k]~= npcBot:GetPlayerID() and herofile.TableAllyHeroHandle[k]:IsAlive() and state~=nil and state == 1) then
				local allyhero = herofile.TableAllyHeroHandle[k];
				local tp_loc, distance = findtploc(allyhero:GetLocation());
				if ( herofile.TableAllyHeroPriority[k] >  priority and GetUnitToUnitDistance (npcBot, allyhero) <= npcBot:GetCurrentMovementSpeed() * 8 + npcBot:GetAttackRange()) then
					teamfight_p = 11.41;
					priority =  herofile.TableAllyHeroPriority[k];
					target_loc = allyhero:GetLocation();
				elseif ( herofile.TableAllyHeroPriority[k] >  priority and GetUnitToUnitDistance (npcBot, allyhero) > npcBot:GetCurrentMovementSpeed() * 8 + npcBot:GetAttackRange() and CanUseTp() and GetUnitToLocationDistance (allyhero, tp_loc) <  GetUnitToUnitDistance (npcBot, allyhero) + npcBot:GetCurrentMovementSpeed() * 3 ) then
					teamfight_p = 11.42;
					priority =  herofile.TableAllyHeroPriority[k];
					target_loc = tp_loc;
				elseif (herofile.TableAllyHeroPriority[k] >  priority and GetUnitToUnitDistance (npcBot, allyhero) > npcBot:GetCurrentMovementSpeed() * 8 + npcBot:GetAttackRange() and CanUseTp() and GetUnitToLocationDistance (allyhero, tp_loc) >=  GetUnitToUnitDistance (npcBot, allyhero) + npcBot:GetCurrentMovementSpeed() * 3 ) then
					teamfight_p = 11.41;
					priority =  herofile.TableAllyHeroPriority[k];
					target_loc = tp_loc;
				end
			end
		end
	end
	return 	teamfight_p, target_loc;
end
function goteamfight() 
	local npcBot = GetBot();
	local teamfight_p, target_loc = teamfight();
	if (npcBot:IsChanneling() or target_loc == nil) then
		return;
	end
	
	if (teamfight_p == 11.41) then
		npcBot:Action_MoveToLocation(target_loc);
	elseif (teamfight_p == 11.42) then
		if (CanUseTp()) then
			TpToLocation(target_loc);
			print('tp to teamfight');
		end
	end
end
function push()
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local push_p = 0;
	local push_loc = nil;
	local NearbyEnemyTowers = npcBot:GetNearbyTowers(1300,true);
	local nearest_tower = NearbyEnemyTowers[1];
	local toprack = 0; 
	local midrack = 0; 
	local botrack = 0;
	local HighestPriority = -9999;
	local Sum_EnemyNetWorth = 0;
	local Sum_AllyNetWorth = 0;
	local TableAllyHero = GetUnitList(UNIT_LIST_ALLIED_HEROES);
	local NearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	local TableEnemyCreeps = npcBot:GetNearbyCreeps( 1000, true ); 
	local TableEenmyBarracks = npcBot:GetNearbyBarracks(1200,true);
	local nearest_barrack = TableEenmyBarracks[1];
	for k, EnemyNetWorth in pairs(herofile.TableEnemyHeroNetWorth) do
		if (herofile.TableEnemyPlayerID[k] ~= nil and IsHeroAlive( herofile.TableEnemyPlayerID[k] ) ) then
			Sum_EnemyNetWorth = Sum_EnemyNetWorth + EnemyNetWorth;
		end
	end
	for k, hero in pairs(TableAllyHero) do
		if ( hero:IsAlive() and hero:GetHealth()/ hero:GetMaxHealth() > 0.3 ) then
			Sum_AllyNetWorth = Sum_AllyNetWorth + GetNetWorth(hero);
		end
	end
	if(  nearest_tower ~= nil and (not nearest_tower:IsInvulnerable( )) and LocHeroNum(nearest_tower:GetLocation(), 1500) == 0 and npcBot:GetHealth()/npcBot:GetMaxHealth() > 0.8 and npcBot:GetHealth() > 2000) then
		push_p = 11.7;
		push_loc = nearest_tower:GetLocation();	
	elseif(  nearest_tower ~= nil and (not nearest_tower:IsInvulnerable( )) and LocHeroNum(nearest_tower:GetLocation(), 1500) == 0 and npcBot:GetHealth()/npcBot:GetMaxHealth() > 0.8 and npcBot:GetHealth() > 1000) then
		push_p = 7.53;
		push_loc = nearest_tower:GetLocation();
	elseif(  nearest_barrack~= nil and (not nearest_barrack:IsInvulnerable( )) and LocHeroNum(nearest_barrack:GetLocation(), 1500) == 0) then
		push_p = 9.8;
		push_loc = nearest_barrack:GetLocation();
	elseif(Sum_EnemyNetWorth == 0 or (Sum_AllyNetWorth > 30000 and Sum_AllyNetWorth > Sum_EnemyNetWorth * 3) or (Sum_AllyNetWorth > 40000 and Sum_AllyNetWorth > Sum_EnemyNetWorth * 2) or (Sum_AllyNetWorth > 45000 and Sum_AllyNetWorth > Sum_EnemyNetWorth * 1.5) or (Sum_AllyNetWorth > 50000 and Sum_AllyNetWorth > Sum_EnemyNetWorth * 1.2)) then
		if (GetBarracks( GetOpposingTeam( ), BARRACKS_TOP_MELEE )~= nil and GetBarracks( GetOpposingTeam( ), BARRACKS_TOP_MELEE ): IsAlive( ) ) then
			toprack = toprack + 2;
		end
		if (GetBarracks( GetOpposingTeam( ), BARRACKS_TOP_RANGED)~= nil and GetBarracks( GetOpposingTeam( ), BARRACKS_TOP_RANGED ): IsAlive( ) ) then
			toprack = toprack + 1;
		end
		if (GetBarracks( GetOpposingTeam( ), BARRACKS_MID_MELEE )~= nil and GetBarracks( GetOpposingTeam( ), BARRACKS_MID_MELEE ): IsAlive( ) ) then
			midrack = midrack + 2;
		end
		if (GetBarracks( GetOpposingTeam( ), BARRACKS_MID_RANGED)~= nil and GetBarracks( GetOpposingTeam( ), BARRACKS_MID_RANGED ): IsAlive( ) ) then
			midrack = midrack + 1;
		end
		if (GetBarracks( GetOpposingTeam( ), BARRACKS_BOT_MELEE )~= nil and GetBarracks( GetOpposingTeam( ), BARRACKS_BOT_MELEE ): IsAlive( ) ) then
			botrack = botrack + 2;
		end
		if (GetBarracks( GetOpposingTeam( ), BARRACKS_BOT_RANGED)~= nil and GetBarracks( GetOpposingTeam( ), BARRACKS_BOT_RANGED ): IsAlive( ) ) then
			botrack = botrack + 1;
		end
		local lanefront_top = (GetLaneFrontAmount( GetTeam() ,  LANE_TOP , false) + toprack);
		local lanefront_mid = (GetLaneFrontAmount( GetTeam() ,  LANE_MID , false) + midrack);
		local lanefront_bot = (GetLaneFrontAmount( GetTeam() ,  LANE_BOT , false) + botrack);
	
		if ( lanefront_top == math.max(lanefront_top, lanefront_mid, lanefront_bot)) then
			push_loc = GetLaneFrontLocation( GetTeam(), LANE_TOP, 0 );
			push_p = 9.6;
		elseif ( lanefront_mid == math.max(lanefront_top, lanefront_mid, lanefront_bot)) then
			push_loc = GetLaneFrontLocation( GetTeam(), LANE_MID, 0);
			push_p = 9.6;
		else
			push_loc = GetLaneFrontLocation( GetTeam(), LANE_BOT, 0);
			push_p = 9.6;
		end
	end
	return push_p, push_loc;
end
function gopush(push_loc)
	local npcBot = GetBot();
	local push_p, default_push_loc = push();
	local com_state = "gopush";
	if (npcBot:IsChanneling()) then
		return com_state;
	end
	if (push_p == 9.6 and push_loc ~= nil) then
		if (GetAmountAlongLane( LANE_MID, npcBot:GetLocation() ).amount < GetAmountAlongLane( LANE_MID, push_loc ).amount ) then
			if (GetUnitToLocationDistance(npcBot, push_loc) <= 1500) then					
				npcBot:Action_AttackMove(push_loc);		
			elseif (GetUnitToLocationDistance(npcBot, push_loc) > 1500) then	
					npcBot:Action_MoveToLocation(push_loc);		
			end
		else
			npcBot:Action_MoveToLocation(push_loc);
		end
	end
	if (push_p ~= 9.6) then
		npcBot:Action_AttackMove(push_loc);
	end
	return com_state;
end
local tabletowers = { 
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
local tableracks = {							
BARRACKS_TOP_MELEE,
BARRACKS_TOP_RANGED,
BARRACKS_MID_MELEE,
BARRACKS_MID_RANGED,
BARRACKS_BOT_MELEE,
BARRACKS_BOT_RANGED,
};
function defend()
	local npcBot = GetBot();
	local team = GetTeam( ) ;
	local defend_p = 0;
	local defend_loc = nil;
	local TableCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS);
	for tower_k, tower in pairs(tabletowers) do
		local current_tower = GetTower(team, tower);
		if (current_tower ~= nil and (not current_tower:IsInvulnerable())) then
			local tower_loc = current_tower:GetLocation();
			local distance = GetUnitToLocationDistance(npcBot, tower_loc);
			local counts = LocHeroNum(tower_loc, 1500);
			if ( tower_k <= 5 ) then
				local creep_counts = 0;
				for creep_k, creep in pairs (TableCreeps) do
					if (GetUnitToUnitDistance(creep, current_tower) < creep:GetAttackRange() + 100) then
						creep_counts = creep_counts +1;
					end
				end
				if (counts > 0 or creep_counts > 4) then
					defend_p = 13.5; 
					defend_loc = tower_loc;
					print('tower is being attacked!'..'counts = '..counts..'creep_counts = '..creep_counts);
				end
			elseif (counts > 1 and tower_k > 5 and tower_k <= 9) then
				defend_p = 8.5;
				defend_loc = tower_loc;
				print('tower is being attacked!'..'counts = '..counts);
			elseif (counts > 2 and tower_k > 9) then
				defend_p = 7.6; 
				defend_loc = tower_loc;
				print('tower is being attacked!'..'counts = '..counts);
			end
			if ((current_tower ~=nil) and counts > 2 and GetGlyphCooldown() == 0 and current_tower:GetHealth()/current_tower:GetMaxHealth() < 0.8) then
				npcBot:ActionImmediate_Glyph();
			end
		end
	end
	if (defend_loc == nil) then
		for rack_k, rack in pairs(tableracks) do
			local current_rack = GetBarracks( team, rack );
			if (current_rack ~= nil and (not current_rack:IsInvulnerable()) ) then
				local rack_loc = current_rack:GetLocation();
				local counts = LocHeroNum(rack_loc, 1500);
				local creep_counts = 0;
				for creep_k, creep in pairs (TableCreeps) do
					if (GetUnitToUnitDistance(creep, current_rack) < creep:GetAttackRange() + 100) then
						creep_counts = creep_counts + 1;
					end
				end
				if ((current_rack ~=nil) and (counts > 0 or creep_counts > 4) and current_rack:GetHealth() < current_rack:GetMaxHealth() ) then
					print('rack is being attacked!'..'counts = '..counts..'creep_counts = '..creep_counts);		
					defend_p = 15;
					defend_loc = rack_loc;
				end
			end
		end
	end
	if (defend_loc == nil) then
		local Ancient = GetAncient(GetTeam( ));
		local base_loc = Ancient:GetLocation();
		local counts = LocHeroNum(base_loc, 1500);
		local creep_counts = 0;
		for creep_k, creep in pairs (TableCreeps) do
			if (GetUnitToUnitDistance(creep, Ancient) < creep:GetAttackRange() + 100) then
				creep_counts = creep_counts + 1;
			end
		end
		if (counts > 0 or creep_counts > 0 ) then
		print('base is being attacked!'..'counts = '..counts..'creep_counts = '..creep_counts);		
			defend_p = 15;
			defend_loc = base_loc
		end
	end
	return defend_p,defend_loc;
end
function godefend()
	local npcBot = GetBot();
	local com_state = "godefend";
	if (npcBot:IsChanneling()) then
		return;
	end
	local defend_p, defend_loc = defend();
	if (defend_loc~= nil) then
		local arrow = _G.Fountain - defend_loc;
		local distance = #(_G.Fountain - defend_loc);
		local tp_loc = defend_loc + (arrow/distance) * 550;	
		if ( GetUnitToLocationDistance( npcBot, defend_loc) > 900 ) then 
			if (GetUnitToLocationDistance( npcBot, defend_loc) > math.max(npcBot:GetCurrentMovementSpeed() * 10 , 3000)) then
				if ( CanUseTp() ) then
					TpToLocation(tp_loc);
					print('tp to defend')
				else
					npcBot:Action_MoveToLocation(tp_loc);
				end
			else					
				npcBot:Action_MoveToLocation(tp_loc);
			end
		else
			local radius = math.max(npcBot:GetAttackRange() + npcBot:GetCurrentMovementSpeed(), 1500);
			local NearbyEnemyHero = npcBot:GetNearbyHeroes(radius , true, BOT_MODE_MODERATE );
			local nearest_hero = NearbyEnemyHero[1];
			local NearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps(radius , true);
			local nearest_creep = NearbyEnemyCreeps[1];
			if (nearest_hero ~= nil) then
				npcBot:Action_AttackUnit(nearest_hero, false);
			elseif (nearest_creep ~= nil ) then
				npcBot:Action_AttackUnit(nearest_creep, false);
			end
		end
	end
	return com_state;
end
function BuyBack()
	local npcBot = GetBot();
	local defend_p,defend_loc = defend();
	if ( (not npcBot:IsAlive()) and npcBot:GetGold() > npcBot:GetBuybackCost( ) and npcBot:GetBuybackCooldown( ) == 0 and defend_p >= 13.7) then
		npcBot:ActionImmediate_Buyback( );
	end
end
function tango(com_state)
local npcBot = GetBot();
local tableTrees = npcBot:GetNearbyTrees(1500);
local usetango_p = 0;
local nearesttree = nil;
	if (#tableTrees > 0) then
		for tree_k,tree in pairs(tableTrees) do
			if (not IsInTowerRange(GetTreeLocation(tree), 900) and #(_G.Fountain - GetTreeLocation(tree)) <= #(_G.Fountain - npcBot:GetLocation()) + 100 ) then
		 		nearesttree = tree;
		 		break;
		 	end
		end
	end
	if ( com_state == "gofarmlane" and (not npcBot:IsChanneling( )) and (npcBot:GetMaxHealth()- npcBot:GetHealth()) > 120 and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.8 and CheckItemByName ( "item_tango" ) and ( (not npcBot:HasModifier("modifier_flask_healing"))) and (nearesttree ~= nil)
	and (not npcBot:HasModifier("modifier_tango_heal")) and (not (npcBot:GetHealthRegen() > 15)) and GetItemByName("item_tango"):IsFullyCastable()) then
		usetango_p = 10.3;
	end
	return usetango_p;
end
function gotango()
	local npcBot = GetBot();
	local tableTrees = npcBot:GetNearbyTrees(1500);
	local nearesttree = nil;
	if (npcBot:IsUsingAbility() )then
		return;
	end
	if (#tableTrees > 0) then
		for k,tree in pairs(tableTrees) do
			if (not IsInTowerRange(GetTreeLocation(tree), 900) and  #(_G.Fountain - GetTreeLocation(tree)) <= #(_G.Fountain - npcBot:GetLocation()) + 100) then
				nearesttree =  tree;
				break;
			end
		end
		if (nearesttree ~= nil and (not npcBot:HasModifier("modifier_tango_heal"))  and GetUnitToLocationDistance(npcBot, GetTreeLocation(nearesttree)) > 140 ) then
			npcBot:Action_MoveToLocation(GetTreeLocation(nearesttree));
		elseif (nearesttree ~= nil and (not npcBot:HasModifier("modifier_tango_heal"))  and GetUnitToLocationDistance(npcBot, GetTreeLocation(nearesttree)) < 140 ) then
			npcBot:Action_UseAbilityOnTree(GetItemByName("item_tango"), nearesttree);
		end
	end
end
function flask()
	local npcBot = GetBot();
	local useflask_p = 0;
	local NearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	if ((not npcBot:IsChanneling( )) and #NearbyEnemyHeroes == 0 and (npcBot:GetMaxHealth()- npcBot:GetHealth()) > 375 and CheckItemByName ( "item_flask" ) and GetItemByName("item_flask"):IsFullyCastable() and (not npcBot:HasModifier("modifier_flask_healing")) and (not npcBot:HasModifier("modifier_tango_heal")) and (not npcBot:WasRecentlyDamagedByAnyHero( 1.1 ))  and npcBot:DistanceFromFountain() > 3500 and npcBot:GetHealthRegen() < 50) then	
		useflask_p = 21.1;
	end	
	return  useflask_p;
end
function goflask()
	local npcBot = GetBot();
	npcBot:Action_UseAbilityOnEntity(GetItemByName("item_flask"), npcBot);
end
function clarity()
	local npcBot = GetBot();
	local useclarity_p = 0;
	local NearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	if ((not npcBot:IsChanneling( )) and #NearbyEnemyHeroes == 0 and (npcBot:GetMaxMana()- npcBot:GetMana()) > 150 and CheckItemByName ( "item_clarity" ) and GetItemByName("item_clarity"):IsFullyCastable() and (not npcBot:HasModifier("modifier_clarity_potion")) ) then	
		useclarity_p = 21.1;
	end	
	return  useclarity_p;
end
function goclarity()
	local npcBot = GetBot();
	npcBot:Action_UseAbilityOnEntity(GetItemByName("item_clarity"), npcBot);
end
function irontalon(com_state)
	local npcBot = GetBot();
	local NearbyNeutralCreeps = npcBot:GetNearbyNeutralCreeps( 600 );
	local highest_hp = -999;
	local target_creep = nil;
	local irontalon_p = 0;
	if (com_state =="gofarmjungle" and #NearbyNeutralCreeps > 0 and CheckItemByName ( "item_iron_talon" ) and GetItemByName("item_iron_talon"):IsFullyCastable()) then	
		for creep_k,creep in pairs( NearbyNeutralCreeps) do
			local creep_hp = creep:GetHealth();
     		if((not creep:IsAncientCreep()) and highest_hp < creep_hp) then 	
     			highest_hp = creep_hp;
          		target_creep = creep;
		  	end
    	end
		if (target_creep~=nil and (highest_hp > 400 or GetTeam() == TEAM_DIRE) ) then
			irontalon_p = 7.52 
    	end		
	end
	return irontalon_p,target_creep;
end		
function goirontalon(com_state)
	local npcBot = GetBot();
	local irontalon_p,target_creep = irontalon(com_state);
	if (npcBot:IsUsingAbility() or npcBot:IsChanneling() )then
		return;
	end
	if (target_creep ~= nil ) then 
		npcBot:Action_UseAbilityOnEntity(GetItemByName("item_iron_talon"), target_creep);
	end
end	
function forcestaff(com_state, com_target)
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local forcestaff_p = 0;
	local forcestaff_target = nil;
	local length = 600;
	if (CheckItemByName("item_force_staff") and GetItemByName("item_force_staff"):IsFullyCastable() ) then
		if (com_state == "goretreat" and npcBot:DistanceFromFountain() > 600 ) then
			local angle = npcBot:GetFacing( );
			local radians = angle * math.pi / 180;
			local cor_x = math.cos(radians) * length;
			local cor_y = math.sin(radians) * length;
			local force_loc = npcBot:GetLocation() + Vector(cor_x, cor_y);
			if ( IsLocationPassable( force_loc ) and #(_G.Fountain - force_loc) + length * 0.8 < #(_G.Fountain - npcBot:GetLocation()) ) then
				forcestaff_p = 21.1;
				forcestaff_target = npcBot;
			end
		end
		if (com_state == "gokillhero" and com_target ~= nil ) then
			local angle = npcBot:GetFacing( );
			local radians = angle * math.pi / 180;
			local cor_x = math.cos(radians) * length;
			local cor_y = math.sin(radians) * length;
			local force_loc = npcBot:GetLocation() + Vector(cor_x, cor_y);
			if ( IsLocationPassable( force_loc ) and LocHeroNum(force_loc, 1500) < 2 and (not IsInTowerRange(force_loc, 900)) and herofile.TableLastSeenInfo[com_target].location ~= nil and LocHeroNum(herofile.TableLastSeenInfo[com_target].location, 1500) < 2 and #(herofile.TableLastSeenInfo[com_target].location - force_loc) + length * 0.8 < #(herofile.TableLastSeenInfo[com_target].location - npcBot:GetLocation()) ) then
				forcestaff_p = 21.1;
				forcestaff_target = npcBot;
			end
		end
	end
	return forcestaff_p, forcestaff_target;
end
function goforcestaff(forcestaff_target)
	local npcBot = GetBot();
	if (npcBot:IsUsingAbility () ) then
		return;
	else
		npcBot:Action_UseAbilityOnEntity( GetItemByName("item_force_staff") , forcestaff_target);
	end
end
function hurricanepike(com_state, com_target)
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local hurricanepike_p = 0;
	local hurricanepike_target = nil;
	local length = 600;
	if (CheckItemByName("item_hurricane_pike") and GetItemByName("item_hurricane_pike"):IsFullyCastable() ) then
		if (com_state == "goretreat" and npcBot:DistanceFromFountain() > 600 ) then
			local angle = npcBot:GetFacing( );
			local radians = angle * math.pi / 180;
			local cor_x = math.cos(radians) * length;
			local cor_y = math.sin(radians) * length;
			local hurricane_loc = npcBot:GetLocation() + Vector(cor_x, cor_y);
			if ( IsLocationPassable( hurricane_loc ) and (not IsInTowerRange(hurricane_loc, 900)) and #(_G.Fountain - hurricane_loc) + length * 0.8 < #(_G.Fountain - npcBot:GetLocation()) ) then
				hurricanepike_p = 21.11;
				hurricanepike_target = npcBot;
			end
		end
		if (com_state == "gokillhero" and com_target ~= nil ) then
			local angle = npcBot:GetFacing( );
			local radians = angle * math.pi / 180;
			local cor_x = math.cos(radians) * length;
			local cor_y = math.sin(radians) * length;
			local hurricane_loc = npcBot:GetLocation() + Vector(cor_x, cor_y);
			if ( IsLocationPassable( hurricane_loc ) and LocHeroNum(hurricane_loc, 1500) < 2 and herofile.TableLastSeenInfo[com_target].location ~= nil and LocHeroNum(herofile.TableLastSeenInfo[com_target].location, 1500) < 2 and #(herofile.TableLastSeenInfo[com_target].location - hurricane_loc) + length * 0.8 < #(herofile.TableLastSeenInfo[com_target].location - npcBot:GetLocation()) ) then
				hurricanepike_p = 21.11;
				hurricanepike_target = npcBot;
			end
		end
	end
	return hurricanepike_p, hurricanepike_target;
end
function gohurricanepike(hurricanepike_target)
	local npcBot = GetBot();
	if (npcBot:IsUsingAbility () ) then
		return;
	else
		npcBot:Action_UseAbilityOnEntity( GetItemByName("item_hurricane_pike") , hurricanepike_target);
	end
end
function blinkdagger(com_state, com_target)
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local blinkdagger_p = 0;
	local blinkdagger_loc = nil;
	local length = 1200;
	if (CheckItemByName("item_blink") and GetItemByName("item_blink"):IsFullyCastable() ) then
		if (com_state == "goretreat" and npcBot:DistanceFromFountain() > 1200 ) then
			local estimate_loc = npcBot:GetLocation() + (_G.Fountain - npcBot:GetLocation())/ GetUnitToLocationDistance(npcBot, _G.Fountain) * length;
			if ( IsLocationPassable( estimate_loc ) ) then
				blinkdagger_p = 21.2;
				blinkdagger_loc = estimate_loc;
			end
		end
		if (com_state == "gokillhero" and com_target ~= nil and TableLastSeenInfo[com_target].location ~= nil) then
			local estimate_loc = npcBot:GetLocation() + (herofile.TableLastSeenInfo[com_target].location - npcBot:GetLocation())/ GetUnitToLocationDistance(npcBot, herofile.TableLastSeenInfo[com_target].location) * length;
			if ( IsLocationPassable( estimate_loc ) and #(herofile.TableLastSeenInfo[com_target].location - estimate_loc) + length * 0.8 < #(herofile.TableLastSeenInfo[com_target].location - npcBot:GetLocation()) ) then
				blinkdagger_p = 21.2;
				blinkdagger_loc = estimate_loc;
			end
		end
	end
	return blinkdagger_p, blinkdagger_loc;
end
function goblinkdagger(blinkdagger_loc)
	local npcBot = GetBot();
	if (npcBot:IsUsingAbility () ) then
		return;
	else
		npcBot:Action_UseAbilityOnLocation( GetItemByName("item_blink") , blinkdagger_loc);
	end
end
function cape()
	local npcBot = GetBot();
	local cape_p = 0;
	local cape_target = nil;
	if (CheckItemByName ( "item_glimmer_cape" ) and GetItemByName("item_glimmer_cape"):IsFullyCastable() ) then
		local CastRange = GetItemByName("item_glimmer_cape"):GetCastRange( );
		local NearbyAllyHeroes = npcBot:GetNearbyHeroes( CastRange + npcBot:GetCurrentMovementSpeed(), false, BOT_MODE_NONE );
		local lowest_distance = CastRange + npcBot:GetCurrentMovementSpeed();
		if (npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.5 and (not npcBot:IsInvisible( )) and (not npcBot:IsMagicImmune( )) ) then	
			cape_p = 21.1318;
			cape_target = npcBot;
		end
		if (cape_p == 0) then
			for k, hero in pairs(NearbyAllyHeroes) do
				if ( hero:GetHealth()/hero:GetMaxHealth() < 0.5 and (not hero:IsInvisible( )) and (not hero:IsMagicImmune( )) and GetUnitToUnitDistance(npcBot, hero) < lowest_distance ) then
					lowest_distance = GetUnitToUnitDistance(npcBot, hero);
					cape_p = 21.1318; 
					cape_target = hero;
				end
			end
		end
	end		
	return  cape_p, cape_target;
end
function gocape()
	local npcBot = GetBot();
	local cape_p, cape_target = cape();
	npcBot:Action_UseAbilityOnEntity(GetItemByName("item_glimmer_cape"), cape_target);
end
function manta()
	local npcBot = GetBot();
	local manta_p = 0;
	local TableProjectiles = npcBot:GetIncomingTrackingProjectiles();
	local nearestprojectile = nil;
	local lowest_distance = 9999;
	if (CheckItemByName ( "item_manta" ) and GetItemByName("item_manta"):IsFullyCastable( ) ) then
		for k, Projectile in pairs(TableProjectiles) do
			if (Projectile.location~= nil and GetUnitToLocationDistance( npcBot, Projectile.location) < lowest_distance and (not Projectile.is_attack) and Projectile.playerid ~= nil and GetTeamForPlayer( Projectile.playerid ) ~= GetTeam() ) then
				lowest_distance = GetUnitToLocationDistance( npcBot, Projectile.location);
				nearestprojectile = Projectile.ability;
			end
		end	
		if (npcBot:IsSilenced( ) or npcBot:IsRooted( )) then
			manta_p = 25.3;				
		elseif(npcBot:GetCurrentMovementSpeed( ) * 2 < (npcBot:GetBaseMovementSpeed( ) + 60)) then
			manta_p = 25.3;
		elseif (nearestprojectile ~= nil and lowest_distance < npcBot:GetBoundingRadius( ) + 150 and nearestprojectile~= "lich_chain_frost") then
			manta_p = 25.3;
			print('use manta to avoid projectiles stun');
		end
	end
	return manta_p;
end
function gomanta()
	local npcBot = GetBot();
	if (npcBot:IsUsingAbility () ) then
		return;
	else
		npcBot:Action_UseAbility(GetItemByName("item_manta"));
	end
end

function moonshard()
	local npcBot = GetBot();
	if (CheckItemByName ( "item_moon_shard" ) and GetItemByName("item_moon_shard"):IsFullyCastable( ) and npcBot:GetNetWorth() > 25000) then
		if (npcBot:IsUsingAbility() )then
			return;
		else
			npcBot:Action_UseAbilityOnEntity(GetItemByName("item_moon_shard"), npcBot);
		end
	end
end
function arcane()
	local npcBot = GetBot();
	local arcane_p = 0;
	if (CheckItemByName ( "item_arcane_boots" ) and GetItemByName("item_arcane_boots"):IsFullyCastable() ) then
		local NearbyAllyHeroes = npcBot:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
		local ManaDelta = npcBot:GetMaxMana() - npcBot:GetMana();
		for k, hero in pairs(NearbyAllyHeroes) do
			ManaDelta = ManaDelta + hero:GetMaxMana() - hero:GetMana();
		end
		if (ManaDelta > 250) then
			arcane_p = 25.16;
		end
	end
	return arcane_p;
end
function goarcane()
	local npcBot = GetBot();
	if (npcBot:IsUsingAbility() )then
		return;
	else
		npcBot:Action_UseAbility(GetItemByName("item_arcane_boots"));
	end
end
function midas()
	local npcBot = GetBot();
	local midas_p = 0;
	local NearByNeutralCreep = npcBot:GetNearbyNeutralCreeps( 600 );
	local NearByLaneCreep = npcBot:GetNearbyLaneCreeps( 600, true );
	if (CheckItemByName ( "item_hand_of_midas" ) and GetItemByName("item_hand_of_midas"):IsFullyCastable() and (#NearByNeutralCreep > 0 or #NearByLaneCreep > 0) ) then
		midas_p = 25.15;
	end
	return midas_p;
end
function gomidas()
	local npcBot = GetBot();
	if (npcBot:IsUsingAbility() )then
		return;
	else
		local NearByNeutralCreep = npcBot:GetNearbyNeutralCreeps( 600 );
		local NearByLaneCreep =  npcBot:GetNearbyLaneCreeps( 600, true );
		local nearset_neutralcreep = NearByNeutralCreep[1];
		local nearset_lanecreep = NearByLaneCreep[1];
		if (nearset_neutralcreep ~= nil) then
			npcBot:Action_UseAbilityOnEntity(GetItemByName("item_hand_of_midas"), nearset_neutralcreep);
		elseif (nearset_lanecreep ~= nil) then
			npcBot:Action_UseAbilityOnEntity(GetItemByName("item_hand_of_midas"), nearset_lanecreep);
		end
	end
end
function shivas()
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local NearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
	local shivas_p = 0;
	if (CheckItemByName ( "item_shivas_guard" ) and GetItemByName("item_shivas_guard"):IsFullyCastable() ) then
		if (#NearbyEnemyHeroes > 1) then
		shivas_p = 25.1;
		elseif (com_state~= nil and com_state == "gokillhero" and com_target~= nil and GetUnitToLocationDistance(npcBot, herofile.TableLastSeenInfo[com_target].location) < 800 ) then
		shivas_p = 25.1;
		elseif (com_state~= nil and com_state == "goretreat" and #NearbyEnemyHeroes > 0) then
		shivas_p = 25.1;
		end
	end
	return shivas_p;
end
function goshivas()
	local npcBot = GetBot();
	if (npcBot:IsUsingAbility() )then
		return;
	else
		npcBot:Action_UseAbility(GetItemByName("item_shivas_guard"));
	end
end
function lotus()
	local npcBot = GetBot();
	local lotus_p = 0;
	local lotus_target = nil;
	if (CheckItemByName ( "item_lotus_orb" ) and GetItemByName("item_lotus_orb"):IsFullyCastable() ) then
		local CastRange = GetItemByName("item_lotus_orb"):GetCastRange( ) ;
		local NearbyAllyHeroes = npcBot:GetNearbyHeroes( 1500, false, BOT_MODE_NONE );
		local lowest_distance = 9999;
		if ( npcBot:GetHealth()/npcBot:GetMaxHealth() > 0.3 ) then
			for k, hero in pairs(NearbyAllyHeroes) do
				if ((hero:IsStunned() or hero:IsRooted() or hero:IsSilenced() or hero:IsHexed( )) and GetUnitToUnitDistance(npcBot, hero) < npcBot:GetCurrentMovementSpeed() + CastRange and GetUnitToUnitDistance(npcBot, hero) < lowest_distance) then
					lotus_p = 25.01;
					lotus_target = hero;
					lowest_distance = GetUnitToUnitDistance(npcBot, hero);
				end
			end
			if (lotus_p == 0 and TeamFightState() == 1) then
				local Highest_OffensivePower = 0;
				for k, hero in pairs(NearbyAllyHeroes) do
					if (GetUnitToUnitDistance(npcBot, hero) < npcBot:GetCurrentMovementSpeed() + CastRange and hero:GetRawOffensivePower() > Highest_OffensivePower) then
						lotus_p = 25.01;
						lotus_target = hero;
						Highest_OffensivePower = hero:GetRawOffensivePower();
					end
				end
				
				if (npcBot:GetRawOffensivePower() > Highest_OffensivePower) then
					lotus_p = 25.01;
					lotus_target = npcBot;
				end
			end
			if (lotus_p == 0 and #NearbyAllyHeroes == 0 and LocHeroNum(npcBot:GetLocation(), 1500) > 0) then
				lotus_p = 25.01;
				lotus_target = npcBot;
			end
		else
			for k, hero in pairs(NearbyAllyHeroes) do
				if ((hero:IsStunned() or hero:IsRooted() or hero:IsSilenced() or hero:IsHexed( )) and GetUnitToUnitDistance(npcBot, hero) < CastRange and GetUnitToUnitDistance(npcBot, hero) < lowest_distance) then
					lotus_p = 25.01;
					lotus_target = hero;
					lowest_distance = GetUnitToUnitDistance(npcBot, hero);
				end
			end
			if (lotus_p == 0) then
				lotus_p = 25.01;
				lotus_target = npcBot;
			end
		end
	end
	return lotus_p, lotus_target;
end
function golotus()
	local npcBot = GetBot();
	local lotus_p, lotus_target = lotus();
	if (npcBot:IsUsingAbility() )then
		return;
	else
		if (lotus_target ~= nil) then
			npcBot:Action_UseAbilityOnEntity(GetItemByName("item_lotus_orb"), lotus_target);
		end
	end
end
function abyssal(com_state, com_target)
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local abyssal_p = 0;
	local abyssal_target = nil;
	if (CheckItemByName ( "item_abyssal_blade" ) and GetItemByName("item_abyssal_blade"):IsFullyCastable() ) then
		local CastRange =  GetItemByName("item_abyssal_blade"):GetCastRange( ) ;
		local NearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		local nearest_hero = NearbyEnemyHeroes[1];
		if (com_state~= nil and com_state == "gokillhero" and com_target~= nil ) then
			if (herofile.TableEnemyPlayerHandle[com_target] ~= nil and GetUnitToUnitDistance(npcBot, herofile.TableEnemyPlayerHandle[com_target]) < npcBot:GetCurrentMovementSpeed() + CastRange) then
				abyssal_p = 25.11;
				abyssal_target = herofile.TableEnemyPlayerHandle[com_target];
			end
		end
	end
	
	if ( com_state~= nil and com_state == "goretreat" and nearest_hero~= nil and GetUnitToUnitDistance(npcBot, nearest_hero) < CastRange ) then
		abyssal_p = 25.11;
		abyssal_target = nearest_hero;
	end
	return abyssal_p, abyssal_target;
end
function goabyssal(abyssal_target)
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	if (npcBot:IsUsingAbility() )then
		return;
	else
		if (abyssal_target ~= nil) then
			npcBot:Action_UseAbilityOnEntity(GetItemByName("item_abyssal_blade"), abyssal_target);
		end
	end
end
function scythe(com_state, com_target)
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local scythe_p = 0;
	local scythe_target = nil;
	if (CheckItemByName ( "item_sheepstick" ) and GetItemByName("item_sheepstick"):IsFullyCastable()) then
		local CastRange =  GetItemByName("item_sheepstick"):GetCastRange( ) ;
		local NearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1500, true, BOT_MODE_NONE );
		local nearest_hero = NearbyEnemyHeroes[1];
		local lowest_distance = 9999;
		for k, hero in pairs(NearbyEnemyHeroes) do
			if (hero:IsChanneling() and (not hero:IsMagicImmune()) and GetUnitToUnitDistance(npcBot, hero) < CastRange + npcBot:GetCurrentMovementSpeed() and GetUnitToUnitDistance(npcBot, hero) < lowest_distance) then
				scythe_p = 15.55;
				scythe_target = hero;
				lowest_distance = GetUnitToUnitDistance(npcBot, hero);
			end
		end
		
		if (scythe_p == 0 and com_state~= nil and com_state == "gokillhero" and com_target~= nil) then
			if (herofile.TableEnemyPlayerHandle[com_target] ~= nil and GetUnitToUnitDistance(npcBot, herofile.TableEnemyPlayerHandle[com_target]) < CastRange + npcBot:GetCurrentMovementSpeed() ) then
				scythe_p = 25.12;
				scythe_target = herofile.TableEnemyPlayerHandle[com_target];
			end
		end
		
		if ( com_state~= nil and com_state == "goretreat" and nearest_hero~= nil and GetUnitToUnitDistance(npcBot, nearest_hero) < CastRange ) then
			scythe_p = 25.12;
			scythe_target = nearest_hero;
		end
	end
	return scythe_p, scythe_target;
end


function goscythe(scythe_target)
	local npcBot = GetBot();
	if (npcBot:IsUsingAbility() )then
		return;
	else
		if (scythe_target~= nil) then	
			npcBot:Action_UseAbilityOnEntity(GetItemByName("item_sheepstick"), scythe_target);
		end
	end
end
function retreat()
	local npcBot = GetBot();
	local retreat_p = 0;
	local NearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE )
	if (TeamFightState() == 0) then
		if (npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.3 ) then
			retreat_p = 20;	
		elseif (npcBot:GetHealth()/npcBot:GetMaxHealth() > 0.3 and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.5 and com_state == "goretreat" ) then
			retreat_p = 20; 
		elseif ( (npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.90 or npcBot:GetMana()/npcBot:GetMaxMana() < 0.90) and npcBot:DistanceFromFountain() < 800 ) then
			retreat_p = 14.97; 
		elseif (npcBot:GetHealth()/npcBot:GetMaxHealth() > 0.5 and npcBot:GetHealth() > 500 and npcBot:DistanceFromFountain() > 800 ) then
			retreat_p = 0; 
		elseif (npcBot:GetHealth()/npcBot:GetMaxHealth() > 0.90 ) then
			retreat_p = 0;
		else
			retreat_p = 0;
		end
	elseif (TeamFightState() == 1) then
		if (npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.2 ) then
			retreat_p = 20;
		elseif (npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.90 and npcBot:GetMana()/npcBot:GetMaxMana() < 0.90 and npcBot:DistanceFromFountain() < 800 ) then
			retreat_p = 20; 
		elseif (npcBot:GetHealth()/npcBot:GetMaxHealth() > 0.2 and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.35 and com_state == "goretreat" ) then
			retreat_p = 20; 
		elseif (npcBot:GetHealth()/npcBot:GetMaxHealth() > 0.35 and npcBot:GetHealth() > 500 and npcBot:DistanceFromFountain() > 800 ) then
			retreat_p = 0;   
		elseif (npcBot:GetHealth()/npcBot:GetMaxHealth() > 0.80 ) then
			retreat_p = 0; 
		else
			retreat_p = 0; 
		end
	end
	return retreat_p;
end
function goretreat()
	local npcBot = GetBot();
	local com_state = "goretreat";
	local com_text = nil;
	if (npcBot:IsChanneling() or npcBot:IsUsingAbility() ) then
		return com_state, com_text;
	end
	npcBot:Action_MoveToLocation(_G.Fountain);
	if (LocHeroNum (npcBot:GetLocation(), 600) > 0 ) then
		com_text = "helpme";
	end
	return com_state, com_text;
end
local burst_timer = 0;
function usecourier()
	local npcBot = GetBot();
	local courier = GetCourier(0);
	if (courier == nil) then
		return;
	end
	local courier_loc = courier:GetLocation();
	local NearbyEnemyHero = LocHeroNum(courier_loc, 1000);
	if ( (IsInTowerRange(courier_loc, 1000) or  NearbyEnemyHero > 0 or courier:GetHealth() < courier:GetMaxHealth()) and GetCourierState(courier) ~= COURIER_STATE_RETURNING_TO_BASE) then
		npcBot:ActionImmediate_Courier(courier , COURIER_ACTION_RETURN);
	elseif((IsInTowerRange(courier_loc, 1000) or  NearbyEnemyHero > 0 or courier:GetHealth() < courier:GetMaxHealth()) and GetCourierState(courier) == COURIER_STATE_RETURNING_TO_BASE and IsFlyingCourier( courier ) and DotaTime() - burst_timer >= 90) then
		npcBot:ActionImmediate_Courier(courier , COURIER_ACTION_BURST);
		burst_timer = DotaTime();
	elseif (npcBot:IsAlive( ) and npcBot:GetStashValue( ) > 50 and (GetCourierState(courier) ~= COURIER_STATE_DELIVERING_ITEMS ) and (npcBot:DistanceFromFountain( ) < 15000 or npcBot:GetStashValue( ) > 2000) ) then
		npcBot:ActionImmediate_Courier(courier , COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS); 		
	elseif (npcBot:IsAlive( ) and npcBot:GetCourierValue( ) > 50 and (GetCourierState(courier) ~= COURIER_STATE_RETURNING_TO_BASE ) and (npcBot:DistanceFromFountain( ) < 15000 or npcBot:GetCourierValue( ) > 2000) ) then
		npcBot:ActionImmediate_Courier(courier , COURIER_ACTION_TRANSFER_ITEMS); 		
	elseif (courier:DistanceFromFountain() > 2500 and GetCourierState(courier) == COURIER_STATE_IDLE) then
		npcBot:ActionImmediate_Courier(courier , COURIER_ACTION_RETURN); 
	end
end
function gosideshop()
	local npcBot = GetBot();
	if (npcBot:IsChanneling()) then
		return;
	end
	if (GetUnitToLocationDistance(npcBot, GetShopLocation( GetTeam( ) , SHOP_SIDE ) ) < GetUnitToLocationDistance(npcBot, GetShopLocation( GetTeam( ) , SHOP_SIDE2 ) ) ) then
		npcBot:Action_MoveToLocation(  GetShopLocation( GetTeam( ) , SHOP_SIDE ) );
	else
		npcBot:Action_MoveToLocation(  GetShopLocation( GetTeam( ) , SHOP_SIDE2 ) );
	end
end
function changeslot()
	local npcBot = GetBot();
	if (npcBot:IsChanneling( ) or npcBot:IsUsingAbility()	) then
		return;
	end	
	for i=0,7 do
		local j = i + 1;
		local CurrentItem = npcBot:GetItemInSlot( i );
		local NextItem =  npcBot:GetItemInSlot( j );
		if ( NextItem ~= nil and CurrentItem~= nil ) then
			local CurrentItemValue = GetItemCost(CurrentItem:GetName());
			local NextItemValue = GetItemCost(NextItem:GetName());
			if (CurrentItem:GetName() == "item_boots" or CurrentItem:GetName() == "item_phase_boots" or CurrentItem:GetName() == "item_power_treads"  or CurrentItem:GetName() == "item_tranquil_boots" or CurrentItem:GetName() == "item_arcane_boots" or CurrentItem:GetName() == "item_travel_boots" or CurrentItem:GetName() =="item_travel_boots_2") then
				CurrentItemValue = CurrentItemValue + 5500;
			end
			if (NextItem:GetName() == "item_boots" or NextItem:GetName() == "item_phase_boots" or NextItem:GetName() == "item_power_treads" or NextItem:GetName() == "item_tranquil_boots" or NextItem:GetName() == "item_arcane_boots" or  NextItem:GetName() == "item_travel_boots" or NextItem:GetName() == "item_travel_boots_2") then
				NextItemValue = NextItemValue + 5500;
			end
			if(CurrentItem:GetName() == "item_tpscroll" ) then
				CurrentItemValue = CurrentItemValue + 2000;
			end
			if(NextItem:GetName() == "item_tpscroll" ) then
				NextItemValue = NextItemValue + 2000;
			end
			if(CurrentItem:GetName() == "item_moon_shard" ) then
				CurrentItemValue = CurrentItemValue + 2000;
			end
			if(NextItem:GetName() == "item_moon_shard" ) then
				NextItemValue = NextItemValue + 2000;
			end
			if (NextItemValue >  CurrentItemValue) then
				npcBot:ActionImmediate_SwapItems( i, j );
			end
		elseif (( NextItem ~= nil and CurrentItem == nil )) then
			npcBot:ActionImmediate_SwapItems( i, j );
		end
	end
end
function dropitem(tableItemsToDrop)
	local npcBot = GetBot();
	local counts = 0;
	local dropitem_p = 0;
	local dropitem = nil;
	local pickitem_p, pickitem_target = pickitem();
	if (pickitem_p ~= 0) then
		return dropitem_p, dropitem;
	end
	for i= 0,8 do
		local sCurItem = npcBot:GetItemInSlot( i );
		if ( sCurItem ~= nil ) then
			counts = counts + 1;
		end
	end	
	if ( counts == 9 ) then
		for item_p, item in pairs(tableItemsToDrop) do
			if( CheckAllItemByName( item ) and counts == 9) then
				local SlotNum = npcBot:FindItemSlot(item);
				if(npcBot:GetItemSlotType(SlotNum)== ITEM_SLOT_TYPE_BACKPACK) then

					dropitem_p = 19.8 
					dropitem = item;
					counts = 0;
				end
			end
		end	
	end
	return dropitem_p, dropitem;
end
function godropitem(dropitem)					
	local npcBot = GetBot();
	if (npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:GetCurrentActionType () == BOT_ACTION_TYPE_DROP_ITEM )then
		return;
	else
		print("bot start drop item"..dropitem);
		npcBot:Action_DropItem( GetAllItemByName( dropitem ) , npcBot:GetLocation()) ;
		print("bot finish drop item"..dropitem);
	end
end
function pickitem()
	local npcBot = GetBot();
	local TableItems = GetDroppedItemList();
	local Highest_Value = 0;
	local pickitem_p = 0;
	local pickitem_target = nil;
	local counts = 0;
	for i= 0,8 do
		local sCurItem = npcBot:GetItemInSlot( i );
		if ( sCurItem ~= nil ) then
			counts = counts + 1;
		end
	end
	for k, dropitem in pairs(TableItems) do
		if (counts < 9 and dropitem.item:GetName() == "item_rapier" and Highest_Value < GetItemCost("item_rapier")) then
			pickitem_p = 13.98;
			pickitem_loc = dropitem.location;
			pickitem_target = dropitem.item;
			Highest_Value = GetItemCost("item_rapier");
		elseif (counts < 9 and dropitem.item:GetName()== "item_gem" and Highest_Value < GetItemCost("item_gem")) then
			pickitem_p = 13.97;
			pickitem_loc = dropitem.location;
			pickitem_target = dropitem.item;
			Highest_Value = GetItemCost("item_gem");
		elseif (counts < 8 and dropitem.player == npcBot:GetPlayerID() and GetUnitToLocationDistance(npcBot,dropitem.location) < npcBot:GetCurrentMovementSpeed() * 3 and Highest_Value < GetItemCost(dropitem.item:GetName())) then
			pickitem_p = 11.71;
			pickitem_loc = dropitem.location;
			pickitem_target = dropitem.item;
			Highest_Value = GetItemCost(dropitem.item:GetName());
		end
	end
	if (pickitem_p == 0 and npcBot:GetCurrentActionType( ) == BOT_ACTION_TYPE_PICK_UP_ITEM) then
		pickitem_p = 11.701;
	end	
	return pickitem_p, pickitem_target;
end
function gopickitem()
	local npcBot = GetBot();
	local pickitem_p, pickitem_target = pickitem();
	local counts = 0;
	for i= 0,5 do
		local sCurItem = npcBot:GetItemInSlot( i );
		if ( sCurItem ~= nil ) then
			counts = counts + 1;
		end
	end
	if (counts == 6) then
		npcBot:ActionImmediate_SwapItems( 5, 8 );
	end
	if (counts < 6 and pickitem_target~= nil) then
		npcBot:Action_PickUpItem( pickitem_target );
	end
end
function Communication( com_text, com_target, com_time, com_loc, com_string, com_state)
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local HeroNum = GetVarInTable(npcBot:GetPlayerID( ), herofile.TableAllyPlayerID);
	if (HeroNum ~= 0) then
		herofile.TableAllyHeroCom[HeroNum] = com_text;
		herofile.TableAllyHeroLaneNum[HeroNum] = GetLaneNum( npcBot:GetLocation() );
		herofile.TableAllyHeroTarget[HeroNum] = com_target;
		herofile.TableAllyHeroTime[HeroNum] = com_time;
		herofile.TableAllyHeroLoc[HeroNum] = com_loc;
		herofile.TableAllyHeroString[HeroNum] = com_string;
		herofile.TableAllyHeroState[HeroNum] = com_state;
		herofile.TableAllyTeamFightState[HeroNum] = TeamFightState();
		herofile.TableAllyHeroHandle[HeroNum] = npcBot;
		if (DotaTime() < 0 and herofile.TableAllyHeroPriority[HeroNum] == 0 ) then
			herofile.TableAllyHeroPriority[HeroNum] = GetPriority();
			herofile.TableAllyHeroRole[HeroNum] = GetRole();
		end
	end
end
function ConsiderGlyph()
    for i, building_id in pairs(Towers) do
        local tower = GetTower(GetTeam(), building_id)
		if tower~=nil
		then	
			if tower:GetHealth() <=500 and tower:GetHealth() >=200 and tower:TimeSinceDamagedByAnyHero()+tower:TimeSinceDamagedByCreep() <= 5
			then
				if GetGlyphCooldown() == 0  
				then
					GetBot():ActionImmediate_Glyph()
					break
				end
			end
		end
    end
end
function CourierUsageThink()
	ConsiderGlyph()
	UnImplementedItemUsage()
	local npcBot=GetBot()
	local courier=GetCourier(0)
	local state=GetCourierState(courier)
	if(npcBot:IsAlive()==false or npcBot:GetHealth()<=100 or courier==nil or npcBot:IsHero()==false)
	then
		return
	end
	if(courier:WasRecentlyDamagedByAnyHero(2) or courier:WasRecentlyDamagedByTower(2))
	then
		if(courier:GetMaxHealth()==150)
		then
			npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_BURST)
		end
		npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_RETURN)
		return
	end
	if(state ~= COURIER_STATE_DELIVERING_ITEMS and courier:DistanceFromFountain()<=1000 and npcBot:GetCourierValue()>0)
	then
		npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_TRANSFER_ITEMS)
		return
	end
    if (state == COURIER_STATE_AT_BASE and npcBot:GetStashValue() >= 400 and courier:DistanceFromSecretShop()>=100) 
	then
		if(courier:GetMaxHealth()==150)
		then
			npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_BURST)
		end
	
		if(courier.time==nil)
		then
			courier.time=DotaTime()
		end
		if(courier.time+1<DotaTime())
		then
			npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS)
			courier.time=nil
		end
        return
    end
	if(state == COURIER_STATE_AT_BASE and npcBot.secretShopMode == true and npcBot:GetActiveMode() ~= BOT_MODE_SECRET_SHOP)
	then
		npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_SECRET_SHOP)
        return
	end
	if(state == COURIER_STATE_DELIVERING_ITEMS and npcBot:GetCourierValue()==0 and GetUnitToUnitDistance(npcBot,courier)<=300)
	then
		npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_RETURN)
		return
	end
	if(state==COURIER_STATE_IDLE)
	then
		if(courier.idletime==nil)
		then
			courier.idletime=GameTime()
		else
			if(GameTime()-courier.idletime>10)
			then
				npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_RETURN)
				courier.idletime=nil
				return
			end
		end
	end
end
Towers={
    TOWER_TOP_1,
    TOWER_TOP_2,
    TOWER_TOP_3,
    TOWER_MID_1,
    TOWER_MID_2,
    TOWER_MID_3,
    TOWER_BOT_1,
    TOWER_BOT_2,
    TOWER_BOT_3,
    TOWER_BASE_1,
    TOWER_BASE_2
}
function AbilityLevelUpThink2(AbilityToLevelUp,TalentTree)
	local npcBot=GetBot()
	if (npcBot:GetAbilityPoints()<1 or #AbilityToLevelUp==0 or  (GetGameState()~=GAME_STATE_PRE_GAME and GetGameState()~= GAME_STATE_GAME_IN_PROGRESS))
	then
		return
	end
	
	local abilityname=AbilityToLevelUp[1]
	if abilityname=="nil"
	then
		table.remove( AbilityToLevelUp, 1 );
		return
	end
	if abilityname=="talent" 
	then
		local level=npcBot:GetLevel()
		for i,temp in pairs(AbilityToLevelUp)
		do
			if temp=="talent"
			then
				table.remove(AbilityToLevelUp,i)
				table.insert(AbilityToLevelUp,i,TalentTree[1]())
				table.remove(TalentTree,1)
				break
			end
		end
	end
	
	local ability=npcBot:GetAbilityByName(abilityname)
	if ability~=nil and ability:CanAbilityBeUpgraded()
	then
		npcBot:ActionImmediate_LevelAbility(abilityname);
		table.remove( AbilityToLevelUp, 1 );
	end
	
end
Towers={
    TOWER_TOP_1,
    TOWER_TOP_2,
    TOWER_TOP_3,
    TOWER_MID_1,
    TOWER_MID_2,
    TOWER_MID_3,
    TOWER_BOT_1,
    TOWER_BOT_2,
    TOWER_BOT_3,
    TOWER_BASE_1,
    TOWER_BASE_2
}
local glyphTimer = -1000
function UseGlyph()
    local vulnerableTowers = buildings_status.GetDestroyableTowers(GetTeam())
    for i, building_id in pairs(vulnerableTowers) do
        local tower = buildings_status.GetHandle(GetTeam(), building_id)
        if tower:GetHealth() < math.max(tower:GetMaxHealth()*0.15, 165) and tower:TimeSinceDamagedByAnyHero() < 3
            and tower:TimeSinceDamagedByCreep() < 3 then
            if GetGlyphCooldown() == 0 and (GameTime() - glyphTimer > 1.0) then
                GetBot():ActionImmediate_Glyph()
                glyphTimer = GameTime() + 5.0
            end
        end
    end
end
function ConsiderTeamLaneDefense()
    local lane, building, numEnemies = global_game_state.DetectEnemyPush()
    local listAlly = GetUnitList(UNIT_LIST_ALLIED_HEROES)
    for _, ally in pairs(listAlly) do
        if not ally:IsIllusion() and ally:IsBot() and gHeroVar.HasID(ally:GetPlayerID()) then
            gHeroVar.SetVar(ally:GetPlayerID(), "DoDefendLane", {})
        end
    end
    global_game_state.LaneState(LANE_TOP).dontdefend = false
    global_game_state.LaneState(LANE_MID).dontdefend = false
    global_game_state.LaneState(LANE_BOT).dontdefend = false
    if lane == nil or building == nil or numEnemies == nil then return end
    local hBuilding = buildings_status.GetHandle(GetTeam(), building)
    if hBuilding == nil then return end
    local listAlliesAtBuilding = {}
    local listAlliesCanReachBuilding = {}
    local listAlliesCanTPToBuildling = {}
    local defending = {}
    for _, ally in pairs(listAlly) do
        if not ally:IsIllusion() and ally:IsBot() and ally:IsAlive() then
            if gHeroVar.GetVar(ally:GetPlayerID(), "Self"):getCurrentMode():GetName() == "defendlane" then
                table.insert(defending, ally)
            else
                if ally:GetHealth()/ally:GetMaxHealth() >= 0.5 then
                    local distFromBuilding = GetUnitToUnitDistance(ally, hBuilding)
                    local timeToReachBuilding = distFromBuilding/ally:GetCurrentMovementSpeed()

                    if timeToReachBuilding <= 3.0 then
                        table.insert(listAlliesAtBuilding, ally)
                    elseif timeToReachBuilding <= 10.0 then
                        table.insert(listAlliesCanReachBuilding, ally)
                    else
                        local haveTP = utils.HaveItem(ally, "item_tpscroll")
                        if haveTP and haveTP:IsFullyCastable() then
                            table.insert(listAlliesCanTPToBuildling, ally)
                        end
                    end
                end
            end
        end
    end
    local numNeeded = Max(Max(numEnemies - 1, 1) - #defending, 0)
    if (#listAlliesAtBuilding + #listAlliesCanReachBuilding + #listAlliesCanTPToBuildling) >= numNeeded then
        local numGoing = 0
        for _, ally in pairs(defending) do
            gHeroVar.SetVar(ally:GetPlayerID(), "DoDefendLane", {lane, building, numEnemies})
        end
        for _, ally in pairs(listAlliesAtBuilding) do
            gHeroVar.SetVar(ally:GetPlayerID(), "DoDefendLane", {lane, building, numEnemies})
            numGoing = numGoing + 1
        end
        if numGoing < numNeeded then
            for _, ally in pairs(listAlliesCanReachBuilding) do
                gHeroVar.SetVar(ally:GetPlayerID(), "DoDefendLane", {lane, building, numEnemies})
                numGoing = numGoing + 1
                if numGoing >= numNeeded then break end
            end
        end
        if numGoing < numNeeded then
            for _, ally in pairs(listAlliesCanTPToBuildling) do
                gHeroVar.SetVar(ally:GetPlayerID(), "DoDefendLane", {lane, building, numEnemies})
                numGoing = numGoing + 1
                if numGoing >= numNeeded then break end
            end
        end
    else
        global_game_state.LaneState(lane).dontdefend = true
    end
end
function CanBuybackUpperRespawnTime( respawnTime )
	local npcBot=GetBot()
	if ( not npcBot:IsAlive() and respawnTime ~= nil and npcBot:GetRespawnTime() >= respawnTime
		and npcBot:GetBuybackCooldown() <= 0 and npcBot:GetGold() > npcBot:GetBuybackCost() ) then
		return true;
	end
	return false;
end
function BuybackUsageThink() 
	local npcBot=GetBot()
	if npcBot:IsIllusion() then
		return;
	end	
	if ( not CanBuybackUpperRespawnTime(10) ) then
		return;
	end
	local tower_top_3 = GetTower( GetTeam(), TOWER_TOP_3 );
	local tower_mid_3 = GetTower( GetTeam(), TOWER_MID_3 );
	local tower_bot_3 = GetTower( GetTeam(), TOWER_BOT_3 );
	local tower_base_1 = GetTower( GetTeam(), TOWER_BASE_1 );
	local tower_base_2 = GetTower( GetTeam(), TOWER_BASE_2 );
	local barracks_top_melee = GetBarracks( GetTeam(), BARRACKS_TOP_MELEE );
	local barracks_mid_melee = GetBarracks( GetTeam(), BARRACKS_MID_MELEE );
	local barracks_bot_melee = GetBarracks( GetTeam(), BARRACKS_BOT_MELEE );
	local ancient = GetAncient( GetTeam() );
	local buildList = {
		tower_top_3, tower_mid_3, tower_bot_3, tower_base_1, tower_base_2,
		barracks_top_melee, 
		barracks_mid_melee,
		barracks_bot_melee, 
		ancient
	};
	for _, build in pairs(buildList) do
		local tableNearbyEnemyHeroes = build:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 ) then
			if ( build:GetHealth() / build:GetMaxHealth() < 0.5
				and build:WasRecentlyDamagedByAnyHero(2.0) and CanBuybackUpperRespawnTime(30) ) then
				npcBot:ActionImmediate_Buyback();
				return;
			end
		end
	end
	if ( DotaTime() > 60 * 60 and CanBuybackUpperRespawnTime(30) ) then
		npcBot:ActionImmediate_Buyback();
	end
	
end
function InitAbility(Abilities,AbilitiesReal,Talents) 
	local npcBot=GetBot()
	for i=0,23,1 do
		local ability=npcBot:GetAbilityInSlot(i)
		if(ability~=nil)
		then
			if(ability:IsTalent()==true)
			then
				table.insert(Talents,ability:GetName())
			else
				table.insert(Abilities,ability:GetName())
				table.insert(AbilitiesReal,ability)
			end
		end
	end
end
function GetComboMana(AbilitiesReal)
	local npcBot=GetBot()
	local tempComboMana=0
	for i,ability in pairs(AbilitiesReal)
	do
		if ability:IsPassive()==false
		then
			if ability:IsUltimate()==false or ability:GetCooldownTimeRemaining()<=30
			then
				tempComboMana=tempComboMana+ability:GetManaCost()
			end
		end
	end
	return math.max(tempComboMana,300)
end
function GetComboDamage(AbilitiesReal)
	local npcBot=GetBot()
	local tempComboDamage=0
	for i,ability in pairs(AbilitiesReal)
	do
		if ability:IsPassive()==false
		then
			tempComboDamage=tempComboDamage+ability:GetAbilityDamage()
		end
	end
	return math.max(tempComboDamage,GetBot():GetOffensivePower())
end
function PrintDebugInfo(AbilitiesReal,cast)
	local npcBot=GetBot()
	for i=1,#AbilitiesReal
	do	
		if ( cast.Desire[i]~=nil and cast.Desire[i] > 0 ) 
		then
			if (cast.Type[i]==nil or cast.Type[i]=="target") and cast.Target[i]~=nil
			then
				logic.DebugTalk("try to use skill "..i.." at "..cast.Target[i]:GetUnitName().." Desire= "..cast.Desire[i])
			else
				logic.DebugTalk("try to use skill "..i.." Desire= "..cast.Desire[i])
			end
		end
	end		
end
function ConsiderAbility(AbilitiesReal,Consider)
	local npcBot=GetBot()
	local cast={} cast.Desire={} cast.Target={} cast.Type={}
	for i,ability in pairs(AbilitiesReal)
	do
		if ability:IsPassive()==false and Consider[i]~=nil
		then
			cast.Desire[i], cast.Target[i], cast.Type[i] = Consider[i]();
		end
	end
	return cast
end
function UseAbility(AbilitiesReal,cast)
	local npcBot=GetBot()
	
	local HighestDesire=0
	local HighestDesireAbility=0
	local HighestDesireAbilityBumber=0
	for i,ability in pairs(AbilitiesReal)
	do
		if (cast.Desire[i]~=nil and cast.Desire[i]>HighestDesire)
		then
			HighestDesire=cast.Desire[i]
			HighestDesireAbilityBumber=i
		end
	end
	if( HighestDesire>0)
	then
		local j=HighestDesireAbilityBumber
		local ability=AbilitiesReal[j]
		if(cast.Type[j]==nil)
		then
			if(logic.CheckFlag(ability:GetBehavior(),ABILITY_BEHAVIOR_NO_TARGET))
			then
				npcBot:Action_UseAbility( ability )
				return
			elseif(logic.CheckFlag(ability:GetBehavior(),ABILITY_BEHAVIOR_POINT))
			then
				npcBot:Action_UseAbilityOnLocation( ability , cast.Target[j])
				return
			else
				npcBot:Action_UseAbilityOnEntity( ability , cast.Target[j])
				return
			end
		else
			if(cast.Type[j]=="Target")
			then
				npcBot:Action_UseAbilityOnEntity( ability , cast.Target[j])
				return
			elseif(cast.Type[j]=="Location")
			then
				npcBot:Action_UseAbilityOnLocation( ability , cast.Target[j])
				return
			else
				npcBot:Action_UseAbility( ability )
				return
			end
		end
	end
end
function UnImplementedItemUsage()
	local npcBot=GetBot()
	if npcBot:IsChanneling() or npcBot:IsUsingAbility() or npcBot:IsInvisible() or npcBot:IsMuted( )  then
		return;
	end
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
	
	local npcTarget = npcBot:GetTarget();
	
	local arm=IsItemAvailable("item_armlet");
	if arm~=nil and arm:IsFullyCastable() then
		if #tableNearbyEnemyHeroes == 0 and arm:GetToggleState( ) then
			npcBot:Action_UseAbility(arm);
			return;
		end
	end
	
	local mg=IsItemAvailable("item_enchanted_mango");
	if mg~=nil and mg:IsFullyCastable() then
		if npcBot:GetMana() < 100 
		then
			npcBot:Action_UseAbility(mg);
			return;
		end
	end
	
	local tok=IsItemAvailable("item_tome_of_knowledge");
	if tok~=nil and tok:IsFullyCastable() then
		npcBot:Action_UseAbility(tok);
		return;
	end
	
	local ff=IsItemAvailable("item_faerie_fire");
	if ff~=nil and ff:IsFullyCastable() then
		if  npcBot:GetActiveMode() == BOT_MODE_RETREAT and 
			npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH and 
			( npcBot:GetHealth() / npcBot:GetMaxHealth() ) < 0.15 
		then
			npcBot:Action_UseAbility(ff);
			return;
		end
	end
	local bst=IsItemAvailable("item_bloodstone");
	local dangerdistance=GetUnitToUnitDistance(npcBot,npcEnemy);
	if bst ~= nil and bst:IsFullyCastable() then
		if  mode == BOT_MODE_RETREAT and 
			npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH and 
			( npcBot:GetHealth() / npcBot:GetMaxHealth() ) < 0.10 and
			dangerdistance<=1000
		then
			npcBot:Action_UseAbilityOnLocation(bst, npcBot:GetLocation());
			return;
		end
	end
	local pb=IsItemAvailable("item_phase_boots");
	if pb~=nil and pb:IsFullyCastable() 
	then
		if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK or
			 npcBot:GetActiveMode() == BOT_MODE_RETREAT or
			 npcBot:GetActiveMode() == BOT_MODE_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_GANK or
			 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY )
		then
			npcBot:Action_UseAbility(pb);
			return;
		end	
	end
	
	local bt=IsItemAvailable("item_bloodthorn");
	if bt~=nil and bt:IsFullyCastable() 
	then
		if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK or
			 npcBot:GetActiveMode() == BOT_MODE_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_GANK or
			 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY )
		then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastOnTarget(npcTarget) and GetUnitToUnitDistance(npcTarget, npcBot) < 900 )
			then
			    npcBot:Action_UseAbilityOnEntity(bt,npcTarget);
				return
			end
		end
	end
	
	local sc=IsItemAvailable("item_solar_crest");
	if sc~=nil and sc:IsFullyCastable() 
	then
		if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK or
			 npcBot:GetActiveMode() == BOT_MODE_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_GANK or
			 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY )
		then
			if ( npcTarget ~= nil and npcTarget:IsHero() and npcTarget:IsHero() and GetUnitToUnitDistance(npcTarget, npcBot) < 900 )
			then
			    npcBot:Action_UseAbilityOnEntity(sc,npcTarget);
				return
			end
		end
	end
	
	if sc~=nil and sc:IsFullyCastable() then
		local Allies=npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,Ally in pairs(Allies) do
			if ( Ally:GetHealth()/Ally:GetMaxHealth() < 0.35 and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and CanCastOnTarget(Ally) ) or 
			   ( IsDisabled(Ally) and CanCastOnTarget(Ally) )
			then
				npcBot:Action_UseAbilityOnEntity(sc,Ally);
				return;
			end
		end
	end
	
	local se=IsItemAvailable("item_silver_edge");
    if se ~= nil and se:IsFullyCastable() then
		if npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH and 
			tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0
		then
			npcBot:Action_UseAbility(se);
			return;
	    end
		if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_GANK )
		then
			if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance(npcTarget, npcBot) > 1000 and  GetUnitToUnitDistance(npcTarget, npcBot) < 2500 )
			then
			    npcBot:Action_UseAbility(se);
				return;
			end
		end
	end
	
	local hood=IsItemAvailable("item_hood_of_defiance");
    if hood~=nil and hood:IsFullyCastable() and npcBot:GetHealth()/npcBot:GetMaxHealth()<0.8 
	then
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 then
			npcBot:Action_UseAbility(hood);
			return;
		end
	end
	
	local lotus=IsItemAvailable("item_lotus_orb");
	if lotus~=nil and lotus:IsFullyCastable() 
	then
		if  ( npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.45 and tableNearbyEnemyHeroes ~=nil and #tableNearbyEnemyHeroes > 0 ) or
			 npcBot:IsSilenced() or
		    ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 3 and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.8 )
	    then
			npcBot:Action_UseAbilityOnEntity(lotus,npcBot);
			return;
		end
	end
	
	if lotus~=nil and lotus:IsFullyCastable() 
	then
		local Allies=npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,Ally in pairs(Allies) do
			if ( Ally:GetHealth()/Ally:GetMaxHealth() < 0.35 and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 )  or 
				 IsDisabled(Ally)
			then
				npcBot:Action_UseAbilityOnEntity(lotus,Ally);
				return;
			end
		end
	end
	
	local hurricanpike = IsItemAvailable("item_hurricane_pike");
	if hurricanpike~=nil and hurricanpike:IsFullyCastable() 
	then
		if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
		then
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( GetUnitToUnitDistance( npcEnemy, npcBot ) < 400 and CanCastOnTarget(npcEnemy) )
				then
					npcBot:Action_UseAbilityOnEntity(hurricanpike,npcEnemy);
					return
				end
			end
			if npcBot:IsFacingLocation(GetAncient(GetTeam()):GetLocation(),10) and npcBot:DistanceFromFountain() > 0 
			then
				npcBot:Action_UseAbilityOnEntity(hurricanpike,npcBot);
				return;
			end
		end
	end
	
	local glimer=IsItemAvailable("item_glimmer_cape");
	if glimer~=nil and glimer:IsFullyCastable() then
		if ( npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.45 and ( tableNearbyEnemyHeroes~=nil and #tableNearbyEnemyHeroes>0) ) or 
		   ( tableNearbyEnemyHeroes~=nil and #tableNearbyEnemyHeroes >= 3 and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.65 )  	
		then	
			npcBot:Action_UseAbilityOnEntity(glimer,npcBot);
			return;
		end
	end
	
	local hod=IsItemAvailable("item_helm_of_the_dominator");
	if hod~=nil and hod:IsFullyCastable() 
	then
		local maxHP = 0;
		local NCreep = nil;
		local tableNearbyCreeps = npcBot:GetNearbyCreeps( 1000, true );
		if #tableNearbyCreeps >= 2 
		then
			for _,creeps in pairs(tableNearbyCreeps)
			do
				local CreepHP = creeps:GetHealth();
				if CreepHP > maxHP and ( creeps:GetHealth() / creeps:GetMaxHealth() ) > .75  and not creeps:IsAncientCreep()
				then
					NCreep = creeps;
					maxHP = CreepHP;
				end
			end
		end
		if NCreep ~= nil then
			npcBot:Action_UseAbilityOnEntity(hod,NCreep);
			return
		end	
	end
	
	if glimer~=nil and glimer:IsFullyCastable() then
		local Allies=npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,Ally in pairs(Allies) do
			if ( Ally:GetHealth()/Ally:GetMaxHealth() < 0.35 and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and CanCastOnTarget(Ally) ) or 
			   ( IsDisabled(Ally) and CanCastOnTarget(Ally) )
			then
				npcBot:Action_UseAbilityOnEntity(glimer,Ally);
				return;
			end
		end
	end
	
	local guardian=IsItemAvailable("item_guardian_greaves");
	if guardian~=nil and guardian:IsFullyCastable() then
		local Allies=npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,Ally in pairs(Allies) do
			if  Ally:GetHealth()/Ally:GetMaxHealth() < 0.35 and tableNearbyEnemyHeroes~=nil and #tableNearbyEnemyHeroes > 0 
			then
				npcBot:Action_UseAbility(guardian);
				return;
			end
		end
	end
	
	local satanic=IsItemAvailable("item_satanic");
	if satanic~=nil and satanic:IsFullyCastable() then
		if  npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.50 and 
			tableNearbyEnemyHeroes~=nil and #tableNearbyEnemyHeroes > 0 and 
			npcBot:GetActiveMode() == BOT_MODE_ATTACK
		then
			npcBot:Action_UseAbility(satanic);
			return;
		end
	end
	local WardList=GetUnitList(UNIT_LIST_ALLIED_WARDS)
	local HaveWard=false
	
	for _,ward in pairs(WardList)
	do
		if(GetUnitToUnitDistance(ward,npcBot)<=1500)
		then
			HaveWard=true
		end
	end
	
	local sentry=IsItemAvailable("item_ward_sentry");
	if sentry~=nil and sentry:IsFullyCastable() then
		
		local NearbyTowers = npcBot:GetNearbyTowers(1600,true)
		local NearbyTowers2 = npcBot:GetNearbyTowers(800,true)
		local NearbyTowers3 = npcBot:GetNearbyTowers(800,false)
		
		if  HaveWard==false
		then
			if (npcBot:GetActiveMode() == BOT_MODE_ATTACK)
			then
				npcBot:Action_UseAbilityOnLocation( sentry, npcBot:GetLocation() );
			end
			
			if npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or 
			 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or 
			 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT and #NearbyTowers2==0 and #NearbyTowers>0
			then
				npcBot:Action_UseAbilityOnLocation( sentry, npcBot:GetXUnitsInBehind(300) );
			end	 
			
			if npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
			 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
			 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT and #NearbyTowers3==0 
			then
				npcBot:Action_UseAbilityOnLocation( sentry, npcBot:GetXUnitsInFront(300) );
			end
			
		end
	end
	
end
function IsItemAvailable(item_name)
	local npcBot=GetBot()
    for i = 0, 5 do
        local item = npcBot:GetItemInSlot(i);
		if (item~=nil) then
			if(item:GetName() == item_name) then
				return item;
			end
		end
    end
    return nil;
end
function IsXItemAvailable(npcBot,item_name)
    for i = 0, 5 do
        local item = npcBot:GetItemInSlot(i);
		if (item~=nil) then
			if(item:GetName() == item_name) then
				return item;
			end
		end
    end
    return nil;
end
function CanCastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastOnMagicImmuneTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end
function IsDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) or npcTarget:IsSilenced() or npcTarget:IsNightmared() then
		return true;
	end
	return false;
end
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
	if (CheckItemByName ( "item_travel_boots" ) and GetItemByName("item_travel_boots"):IsFullyCastable() ) then   --check if has boot of travel
		npcBot:Action_UseAbilityOnLocation(GetItemByName("item_travel_boots"), location);
	elseif (CheckItemByName ( "item_travel_boots_2" ) and GetItemByName("item_travel_boots2"):IsFullyCastable() ) then   --check if has boot of travel
		npcBot:Action_UseAbilityOnLocation(GetItemByName("item_travel_boots_2"), location);	
	elseif (CheckItemByName ( "item_tpscroll" ) and GetItemByName("item_tpscroll"):IsFullyCastable() ) then   --check if has tp scroll and npchero it's at a far away place
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
	
	if (hero:HasModifier( "modifier_omniknightherofileuardian_angel" ) ) then ----since this modified health won't affect spell use, but will be calculated in team power, and kill priority, maybe +2000 is good
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
local tabletowers = { 
TOWER_BASE_1,
TOWER_BASE_2,
TOWER_MID_3,
TOWER_MID_2,
TOWER_MID_1,
TOWER_BOT_3,
TOWER_BOT_2,
TOWER_BOT_1,
TOWER_TOP_3,
TOWER_TOP_2,
TOWER_TOP_1,
};		
local tableracks = {							
BARRACKS_MID_MELEE,
BARRACKS_MID_RANGED,
BARRACKS_BOT_MELEE,
BARRACKS_BOT_RANGED,
BARRACKS_TOP_MELEE,
BARRACKS_TOP_RANGED,
}
function GetDesire()
	local team = GetTeam( ) ;
	local TableCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS);
	for tower_k, tower in pairs(tabletowers) do
		local current_tower = GetTower(team, tower);
		if (current_tower ~= nil) then
			local tower_loc = current_tower:GetLocation();
			local distance = GetUnitToLocationDistance(npcBot, tower_loc);
			local counts = LocHeroNum(tower_loc, 1500);
			if ((current_tower ~=nil ) and (not current_tower:IsInvulnerable()) and tower_k == 1 ) then
				local creep_counts = 0;
				for creep_k, creep in pairs (TableCreeps) do
					if (GetUnitToUnitDistance(creep, current_tower) < creep:GetAttackRange() + 100) then
						creep_counts = creep_counts +1;
					end
				end
				if (counts > 0 or creep_counts > 4) then	
					return 0.95;
				end
			elseif ((current_tower ~= nil) and (not current_tower:IsInvulnerable()) and counts >= 1 and tower_k == 2) then
				return 0.85;
			elseif ((current_tower ~= nil) and (not current_tower:IsInvulnerable()) and counts >= 2 and tower_k == 3) then		
				return 0.95;
			end	
		end
	end
	for rack_k, rack in pairs(tableracks) do
		local current_rack = GetBarracks( team, rack );
		if (current_rack ~= nil) then
			local rack_loc = current_rack:GetLocation();
			local counts = LocHeroNum(rack_loc, 2500);
			local creep_counts = 0;
			for creep_k, creep in pairs (TableCreeps) do
				if (GetUnitToUnitDistance(creep, current_rack) < creep:GetAttackRange() + 100) then
					creep_counts = creep_counts +1;
				end
			end
			if ((current_rack ~=nil) and (counts > 0 or creep_counts > 4) and current_rack:GetHealth() < current_rack:GetMaxHealth() ) then		
				return 0.95;
			end
		end
	end
	local Ancient = GetAncient(GetTeam( ));
	local base_loc = Ancient:GetLocation();
	local counts = LocHeroNum(base_loc, 3500);
	local creep_counts = 0;
	for creep_k, creep in pairs (TableCreeps) do
		if (GetUnitToUnitDistance(creep, Ancient) < creep:GetAttackRange() + 100) then
			creep_counts = creep_counts +1;
		end
	end
	if (counts > 0 or creep_counts > 0 ) then		
		return 0.95;
	end
	return 0;
end
function ConsiderTeamLaneDefense()
    local lane, building, numEnemies = global_game_state.DetectEnemyPush()
    local listAlly = GetUnitList(UNIT_LIST_ALLIED_HEROES)
    for _, ally in pairs(listAlly) do
        if not ally:IsIllusion() and ally:IsBot() and gHeroVar.HasID(ally:GetPlayerID()) then
            gHeroVar.SetVar(ally:GetPlayerID(), "DoDefendLane", {})
        end
    end
    global_game_state.LaneState(LANE_TOP).dontdefend = false
    global_game_state.LaneState(LANE_MID).dontdefend = false
    global_game_state.LaneState(LANE_BOT).dontdefend = false
    if lane == nil or building == nil or numEnemies == nil then return end
    local hBuilding = buildings_status.GetHandle(GetTeam(), building)
    if hBuilding == nil then return end
    local listAlliesAtBuilding = {}
    local listAlliesCanReachBuilding = {}
    local listAlliesCanTPToBuildling = {}
    local defending = {}
    for _, ally in pairs(listAlly) do
        if not ally:IsIllusion() and ally:IsBot() and ally:IsAlive() then
            if gHeroVar.GetVar(ally:GetPlayerID(), "Self"):getCurrentMode():GetName() == "defendlane" then
                table.insert(defending, ally)
            else
                if ally:GetHealth()/ally:GetMaxHealth() >= 0.5 then
                    local distFromBuilding = GetUnitToUnitDistance(ally, hBuilding)
                    local timeToReachBuilding = distFromBuilding/ally:GetCurrentMovementSpeed()

                    if timeToReachBuilding <= 3.0 then
                        table.insert(listAlliesAtBuilding, ally)
                    elseif timeToReachBuilding <= 10.0 then
                        table.insert(listAlliesCanReachBuilding, ally)
                    else
                        local haveTP = utils.HaveItem(ally, "item_tpscroll")
                        if haveTP and haveTP:IsFullyCastable() then
                            table.insert(listAlliesCanTPToBuildling, ally)
                        end
                    end
                end
            end
        end
    end
    local numNeeded = Max(Max(numEnemies - 1, 1) - #defending, 0)
    if (#listAlliesAtBuilding + #listAlliesCanReachBuilding + #listAlliesCanTPToBuildling) >= numNeeded then
        local numGoing = 0
        for _, ally in pairs(defending) do
            gHeroVar.SetVar(ally:GetPlayerID(), "DoDefendLane", {lane, building, numEnemies})
        end
        for _, ally in pairs(listAlliesAtBuilding) do
            gHeroVar.SetVar(ally:GetPlayerID(), "DoDefendLane", {lane, building, numEnemies})
            numGoing = numGoing + 1
        end
        if numGoing < numNeeded then
            for _, ally in pairs(listAlliesCanReachBuilding) do
                gHeroVar.SetVar(ally:GetPlayerID(), "DoDefendLane", {lane, building, numEnemies})
                numGoing = numGoing + 1
                if numGoing >= numNeeded then break end
            end
        end
        if numGoing < numNeeded then
            for _, ally in pairs(listAlliesCanTPToBuildling) do
                gHeroVar.SetVar(ally:GetPlayerID(), "DoDefendLane", {lane, building, numEnemies})
                numGoing = numGoing + 1
                if numGoing >= numNeeded then break end
            end
        end
    else
        global_game_state.LaneState(lane).dontdefend = true
    end
end

local function DenyNearbyCreeps(bot)
    local listAlliedCreep = gHeroVar.GetNearbyAlliedCreep(bot, 1200)
    if #listAlliedCreep == 0 then
        return false
    end
    local WeakestCreep, WeakestCreepHealth = utils.GetWeakestCreep(listAlliedCreep)
    if not utils.ValidTarget(WeakestCreep) then
        return false
    end
    AttackRange = bot:GetAttackRange() + bot:GetBoundingRadius()
    local damage = 0
    local eDamage = bot:GetEstimatedDamageToTarget(true, WeakestCreep, bot:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL)
    if utils.IsMelee(bot) then
        damage = eDamage + utils.GetCreepHealthDeltaPerSec(WeakestCreep) * (bot:GetAttackPoint() / (1 + bot:GetAttackSpeed()))
    else
        damage = eDamage + utils.GetCreepHealthDeltaPerSec(WeakestCreep) * (bot:GetAttackPoint() / (1 + bot:GetAttackSpeed()) + GetUnitToUnitDistance(bot, WeakestCreep) / 1100)
    end
    if utils.ValidTarget(WeakestCreep) and damage > WeakestCreep:GetMaxHealth() then
        damage = eDamage
    end
    if damage > WeakestCreep:GetHealth() and utils.GetDistance(bot:GetLocation(),WeakestCreep:GetLocation()) < AttackRange then
        utils.TreadCycle(bot, constants.AGILITY)
        gHeroVar.HeroAttackUnit(bot, WeakestCreep, true)
        return true
    end
    local approachScalar = 2.0
    if utils.IsMelee(bot) then
        approachScalar = 2.5
    end
    if WeakestCreepHealth < approachScalar*damage and utils.GetDistance(bot:GetLocation(), WeakestCreep:GetLocation()) > AttackRange then
        local dest = utils.VectorTowards(WeakestCreep:GetLocation(),GetLocationAlongLane(CurLane, LanePos-0.03), AttackRange - 20 )
        gHeroVar.HeroMoveToLocation(bot, dest)
        return true
    end
    if utils.ValidTarget(WeakestCreep) then
        local healthRatio = WeakestCreep:GetHealth()/WeakestCreep:GetMaxHealth()
        if healthRatio < 0.5 and WeakestCreepHealth > 2.5*damage and #listAlliedCreep >= #gHeroVar.GetNearbyEnemyCreep(bot, 1200) then
            gHeroVar.HeroAttackUnit(bot, WeakestCreep, true)
        end
    end
    return false
end
local function CSing(bot)
    local listAlliedCreep = gHeroVar.GetNearbyAlliedCreep(bot, 1200)
    if #listAlliedCreep == 0 then
        LaningState = LaningStates.Moving
        return
    end
    local listEnemyCreep = gHeroVar.GetNearbyEnemyCreep(bot, 1200)
    if #listEnemyCreep == 0 then
        LaningState = LaningStates.Moving
        return
    end
    local listEnemyTowers = gHeroVar.GetNearbyEnemyTowers(bot, 1200)
    if #listEnemyTowers > 0 then
        if utils.ValidTarget(listEnemyTowers[1]) then
            local dist = GetUnitToUnitDistance(bot, listEnemyTowers[1])
            if dist < 750 then
                gHeroVar.HeroMoveToLocation(bot, utils.VectorAway(bot:GetLocation(), listEnemyTowers[1]:GetLocation(), 750-dist))
                return
            end
        end
    end
    AttackRange = bot:GetAttackRange() + bot:GetBoundingRadius()
    AttackSpeed = bot:GetAttackPoint()
    local NoCoreAround = true
    local listAllies  = gHeroVar.GetNearbyAllies(bot, 1200)
    for _, hero in pairs(listAllies) do
        if not hero:IsIllusion() and utils.IsCore(hero) then
            NoCoreAround = false
        end
    end
    local listEnemies = gHeroVar.GetNearbyEnemies(bot, 1200)
    if utils.IsCore(bot) or (NoCoreAround and #listEnemies < 2) then
        local WeakestCreep, WeakestCreepHealth = utils.GetWeakestCreep(listEnemyCreep)

        if not utils.ValidTarget(WeakestCreep) then
            LaningState = LaningStates.Moving
            return
        end
        local nAc = 0
        if utils.ValidTarget(WeakestCreep) then
            for _,acreep in pairs(listAlliedCreep) do
                if utils.ValidTarget(acreep) and GetUnitToUnitDistance(acreep, WeakestCreep) < 120 then
                    nAc = nAc + 1
                end
            end
        end
        local eDamage = bot:GetEstimatedDamageToTarget(true, WeakestCreep, bot:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL)
        if utils.IsMelee(bot) then
            damage = eDamage + utils.GetCreepHealthDeltaPerSec(WeakestCreep) * (bot:GetAttackPoint() / (1 + bot:GetAttackSpeed()))
        else
            damage = eDamage + utils.GetCreepHealthDeltaPerSec(WeakestCreep) * (bot:GetAttackPoint() / (1 + bot:GetAttackSpeed()) + GetUnitToUnitDistance(bot, WeakestCreep) / 1100)
        end
        if utils.ValidTarget(WeakestCreep) and damage > WeakestCreep:GetMaxHealth() then
            damage = eDamage
        end
        if utils.ValidTarget(WeakestCreep) and WeakestCreepHealth < damage then
            if utils.TreadCycle(bot, constants.AGILITY) then return end
            gHeroVar.HeroAttackUnit(bot, WeakestCreep, true)
            return
        end
        if #listEnemies > 0 and #listEnemies <= #listAllies then
            local breakableEnemy = nil
            for _, enemy in pairs(listEnemies) do
                if utils.ValidTarget(enemy) and utils.EnemyHasBreakableBuff(enemy) then
                    breakableEnemy = enemy
                    break
                end
            end
            if breakableEnemy then
                setHeroVar("Target", breakableEnemy)
                if not utils.UseOrbEffect(bot) then
                    if GetUnitToUnitDistance(bot, breakableEnemy) < (AttackRange+breakableEnemy:GetBoundingRadius()) then
                        if utils.TreadCycle(bot, constants.AGILITY) then return end
                        gHeroVar.HeroAttackUnit(bot, breakableEnemy, true)
                        return
                    end
                end
            end
        end
        local approachScalar = 2.0
        if utils.IsMelee(bot) then
            approachScalar = 2.5
        end
        if utils.ValidTarget(WeakestCreep) and WeakestCreepHealth < damage*approachScalar and 
            GetUnitToUnitDistance(bot, WeakestCreep) > AttackRange and #listEnemyTowers == 0 then
            local dest = utils.VectorTowards(WeakestCreep:GetLocation(),GetLocationAlongLane(CurLane, LanePos-0.03), AttackRange-20)
            gHeroVar.HeroMoveToLocation(bot, dest)
            return
        end
        if DenyNearbyCreeps(bot) then
            return
        end
    elseif not NoCoreAround then
        if DenyNearbyCreeps(bot) then
            return
        end
    end
    LaningState = LaningStates.MovingToPos
end

function X:DoDefendLane(bot)
    debugging.SetBotState(utils.GetHeroName(bot), 2, "DO DEFEND LANE")
    local defendInfo = self:getHeroVar("DoDefendLane")
    local lane = defendInfo[1]
    local building = defendInfo[2]
    local numEnemies = defendInfo[3]
    local hBuilding = buildings_status.GetHandle(GetTeam(), building)
    if lane and hBuilding and numEnemiesNearBuilding(building) > 0 then
        utils.myPrint("Defending lane '"..lane.."' building: ", hBuilding:GetUnitName())
        local distFromBuilding = GetUnitToUnitDistance(bot, hBuilding)
        local timeToReachBuilding = distFromBuilding/bot:GetCurrentMovementSpeed()

        if timeToReachBuilding <= 5.0 then
            gHeroVar.HeroMoveToLocation(bot, hBuilding:GetLocation())
            return true
        else
            print("TPing")
            item_usage.UseTP(bot, hBuilding:GetLocation())
            return true
        end
    else
        print("Mission accomplished, the tower is safe!")
        self:RemoveMode(constants.MODE_DEFENDLANE)
        self:setHeroVar("DoDefendLane", {})
    end
    return false
end

function X:AnalyzeLanes(nLane)
    if utils.InTable(nLane, self:getHeroVar("CurLane")) then
        return
    end
    local currLane = self:getHeroVar("CurLane")
    local frontier = GetLaneFrontAmount(GetTeam(), currLane, false)
    if frontier < 0.55 then
        return
    end
    if #nLane > 1 then
        local newLane = nLane[RandomInt(1, #nLane)]
        utils.myPrint("Randomly switching to lane: ", newLane)
        self:setHeroVar("CurLane", newLane)
    elseif #nLane == 1 then
        utils.myPrint("Switching to lane: ", nLane[1])
        self:setHeroVar("CurLane", nLane[1])
    else
        utils.myPrint("Switching to lane: ", LANE_MID)
        self:setHeroVar("CurLane", LANE_MID)
    end
    self:setHeroVar("LaningState", 1)
    return
end

function X:DoChangeLane(bot)
    local listBuildings = buildings_status.GetStandingBuildingIDs(utils.GetOtherTeam())
    local nLane = {}
    if utils.InTable(listBuildings, 1) then table.insert(nLane, LANE_TOP) end
    if utils.InTable(listBuildings, 4) then table.insert(nLane, LANE_MID) end
    if utils.InTable(listBuildings, 7) then table.insert(nLane, LANE_BOT) end
    if #nLane > 0 then
        return self:AnalyzeLanes(nLane)
    end
    if utils.InTable(listBuildings, 2) then table.insert(nLane, LANE_TOP) end
    if utils.InTable(listBuildings, 5) then table.insert(nLane, LANE_MID) end
    if utils.InTable(listBuildings, 8) then table.insert(nLane, LANE_BOT) end
    if #nLane > 0 then
        return self:AnalyzeLanes(nLane)
    end
    if utils.InTable(listBuildings, 3) or utils.InTable(listBuildings, 12) or utils.InTable(listBuildings, 13) then table.insert(nLane, LANE_TOP) end
    if utils.InTable(listBuildings, 6) or utils.InTable(listBuildings, 14) or utils.InTable(listBuildings, 15) then table.insert(nLane, LANE_MID) end
    if utils.InTable(listBuildings, 9) or utils.InTable(listBuildings, 16) or utils.InTable(listBuildings, 17) then table.insert(nLane, LANE_BOT) end
    if #nLane > 0 then
        return self:AnalyzeLanes(nLane)
    end
    return
end

function ConsiderGlyph()
    for i, building_id in pairs(Towers) do
        local tower = GetTower(GetTeam(), building_id)
		if tower~=nil
		then	
			if tower:GetHealth() <=200 and tower:GetHealth() >=50 and tower:TimeSinceDamagedByAnyHero()+tower:TimeSinceDamagedByCreep() <= 5
			then
				if GetGlyphCooldown() == 0  
				then
					GetBot():ActionImmediate_Glyph()
					break
				end
			end
		end
    end
end
Towers={
    TOWER_TOP_1,
    TOWER_TOP_2,
    TOWER_TOP_3,
    TOWER_MID_1,
    TOWER_MID_2,
    TOWER_MID_3,
    TOWER_BOT_1,
    TOWER_BOT_2,
    TOWER_BOT_3,
    TOWER_BASE_1,
    TOWER_BASE_2
}

for k,v in pairs( ability_item_usage_generic ) do	_G._savedEnv[k] = v end

--------------------------------------------------------------------------------
--NEED REWORK--
--------------------------------------------------------------------------------
--[[function armlet()
	local npcBot = GetBot();
	local NearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	local nearesthero = NearbyEnemyHeroes[1];
	local armlet_p = 0;
	local armlet_switch = 0;
	local attack_target = npcBot:GetAttackTarget();
	local TableProjectiles = npcBot:GetIncomingTrackingProjectiles();
	local nearestprojectile = nil;
	local lowest_distance = 9999;
	for k, Projectile in pairs(TableProjectiles) do
		if (GetUnitToLocationDistance( npcBot, Projectile.location) < lowest_distance and Projectile.caster ~= nil and Projectile.playerid ~= nil and GetTeamForPlayer( Projectile.playerid ) ~= GetTeam() ) then
			lowest_distance = GetUnitToLocationDistance( npcBot, Projectile.location);
			nearestprojectile = Projectile.ability;
		end
	end
	if (CheckItemByName ( "item_armlet" ) and GetItemByName("item_armlet"):IsFullyCastable( )) then	 		
		if ((not npcBot:HasModifier("modifier_item_armlet_unholy_strength"))  and npcBot:GetHealthRegen( ) > 40 and (npcBot:GetHealth()/npcBot:GetMaxHealth()) > 0.70 and attack_target ~= nil and npcBot:GetCurrentActionType( ) ~= BOT_ACTION_TYPE_ATTACKMOVE ) then
			armlet_p = 25;
			armlet_switch = 1;		
		elseif ((not npcBot:HasModifier("modifier_item_armlet_unholy_strength"))  and (npcBot:GetHealth()/npcBot:GetMaxHealth()) > 0.85 and attack_target ~= nil and npcBot:GetCurrentActionType( ) ~= BOT_ACTION_TYPE_ATTACKMOVE) then
			armlet_p = 25;
			armlet_switch = 1;
		elseif ((not npcBot:HasModifier("modifier_item_armlet_unholy_strength"))  and (nearesthero ~= nil or npcBot:WasRecentlyDamagedByAnyHero(1) or lowest_distance < 300) and npcBot:GetHealth( ) < 300) then
			armlet_p = 25;
			armlet_switch = 1;
		elseif ((npcBot:HasModifier("modifier_item_armlet_unholy_strength"))  and (npcBot:GetHealth()/npcBot:GetMaxHealth()) > 0.85 and npcBot:GetAttackTarget() ~= nil and npcBot:GetCurrentActionType( ) ~= BOT_ACTION_TYPE_ATTACKMOVE) then
			armlet_p = 0;
			armlet_switch = 1;	
		elseif (npcBot:HasModifier("modifier_item_armlet_unholy_strength")  and (nearesthero ~= nil or npcBot:WasRecentlyDamagedByAnyHero(1) or lowest_distance < 300) and npcBot:GetHealth( ) < 800 ) then
			armlet_p = 0;
			armlet_switch = 1;
		elseif ((npcBot:HasModifier("modifier_item_armlet_unholy_strength")) and (npcBot:GetHealthRegen( ) < 40 or (npcBot:GetHealth()/npcBot:GetMaxHealth()) < 0.70 or npcBot:GetAttackTarget() == nil or npcBot:GetCurrentActionType( ) == BOT_ACTION_TYPE_ATTACKMOVE)) then
			armlet_p = 25;
			armlet_switch = 0;
		end
	end
	return armlet_p, armlet_switch;
end
function goarmlet()
	local npcBot = GetBot();
	if (npcBot:IsUsingAbility() )then
		return;
	else
		local armlet_p, armlet_switch = armlet();
		if ( (not npcBot:HasModifier("modifier_item_armlet_unholy_strength")) and armlet_switch == 1 ) then 
			npcBot:ActionPush_UseAbility(GetItemByName("item_armlet"));
		elseif ((npcBot:HasModifier("modifier_item_armlet_unholy_strength")) and armlet_switch == 0) then
			npcBot:ActionPush_UseAbility(GetItemByName("item_armlet"));
		end
	end
end]]--