function LocHeroNum(location, radius)
	local counts = 0;
	local TableEnemyHero = GetUnitList( UNIT_LIST_ENEMY_HEROES );
	for k, hero in pairs(TableEnemyHero) do
		if ( #(location - hero:GetLocation()) < radius) then
			counts = counts + 1;
		end	
	end	
	return counts;
end
function Power(hero)
	local ID = hero:GetPlayerID( );
	local kills = GetHeroKills( ID );
	local assist = GetHeroAssists( ID );
	local death = GetHeroDeaths( ID );
	local power = 0;
	if ( hero:GetTeam( )== GetOpposingTeam() ) then
		power = hero:GetRawOffensivePower( ) + hero:GetHealth() + (hero:GetHealthRegen( ) * 2.5) + ((kills - death + 0.3 * assist) * 100);
	elseif ( hero:GetTeam( )== GetTeam() ) then
		power = hero:GetRawOffensivePower( ) + hero:GetHealth() + (hero:GetHealthRegen( ) * 2.5) + ((kills - death + 0.3 * assist) * 100);
	end
	return power;	
end
local TableHeroPriorityAsAlly = {
"npc_dota_hero_antimage",
"npc_dota_hero_spectre",
"npc_dota_hero_terrorblade",
"npc_dota_hero_medusa",
"npc_dota_hero_morphling",
"npc_dota_hero_chaos_knight",
"npc_dota_hero_alchemist",
"npc_dota_hero_naga_siren",
"npc_dota_hero_phantom_lancer",
"npc_dota_hero_phantom_assassin",
"npc_dota_hero_slark",
"npc_dota_hero_juggernaut",
"npc_dota_hero_sven",
"npc_dota_hero_lycan",
"npc_dota_hero_skeleton_king",
"npc_dota_hero_ursa",
"npc_dota_hero_meepo",
"npc_dota_hero_sniper",
"npc_dota_hero_drow_ranger",
"npc_dota_hero_clinkz",
"npc_dota_hero_troll_warlord",
"npc_dota_hero_luna",
"npc_dota_gyrocopter",
"npc_dota_hero_tiny",
"npc_dota_hero_nevermore",
"npc_dota_hero_tinker",
"npc_dota_hero_invoker",
"npc_dota_hero_templar_assassin",
"npc_dota_hero_ember_spirit",
"npc_dota_hero_slardar",
"npc_dota_hero_obsidian_destroyer",
"npc_dota_hero_storm_spirit",
"npc_dota_hero_razor",
"npc_dota_hero_bloodseeker",
"npc_dota_hero_arc_warden",
"npc_dota_hero_dragon_knight",
"npc_dota_hero_monkey_king",
"npc_dota_hero_queenofpain",
"npc_dota_hero_windrunner",
"npc_dota_hero_death_prophet",
"npc_dota_hero_life_stealer",
"npc_dota_hero_weaver",
"npc_dota_hero_faceless_void",
"npc_dota_hero_lone_druid",
"npc_dota_hero_necrolyte",
"npc_dota_hero_zuus",
"npc_dota_hero_leshrac",
"npc_dota_hero_bristleback",
"npc_dota_hero_huskar",
"npc_dota_hero_shredder",
"npc_dota_hero_legion_commander",
"npc_dota_hero_broodmother",
"npc_dota_hero_riki",
"npc_dota_hero_viper",
"npc_dota_hero_furion",
"npc_dota_hero_pugna",
"npc_dota_hero_puck",
"npc_dota_hero_magnataur",
"npc_dota_hero_doom_bringer",
"npc_dota_hero_centaur",
"npc_dota_hero_brewmaster",
"npc_dota_hero_tidehunter",
"npc_dota_hero_axe",
"npc_dota_hero_batrider",
"npc_dota_hero_dark_seer",
"npc_dota_hero_beastmaster",
"npc_dota_hero_sand_king",
"npc_dota_hero_abaddon",
"npc_dota_hero_mirana",
"npc_dota_hero_lina",
"npc_dota_hero_night_stalker",
"npc_dota_hero_nyx_assassin",
"npc_dota_hero_earthshaker",
"npc_dota_hero_visage",
"npc_dota_hero_rattletrap",
"npc_dota_hero_undying",
"npc_dota_hero_phoenix",
"npc_dota_hero_spirit_breaker",
"npc_dota_hero_pudge",
"npc_dota_hero_omniknight",
"npc_dota_hero_abyssal_underlord",
"npc_dota_hero_lion",
"npc_dota_hero_enigma",
"npc_dota_hero_silencer",
"npc_dota_hero_enchantress",
"npc_dota_hero_elder_titan",
"npc_dota_hero_vengefulspirit",
"npc_dota_hero_chen",
"npc_dota_hero_tusk",
"npc_dota_hero_earth_spirit",
"npc_dota_hero_bane",
"npc_dota_hero_shadow_shaman",
"npc_dota_hero_dazzle",
"npc_dota_hero_wisp",
"npc_dota_hero_disruptor",
"npc_dota_hero_rubick",
"npc_dota_hero_bounty_hunter",
"npc_dota_hero_treant",
"npc_dota_hero_venomancer",
"npc_dota_hero_jakiro",
"npc_dota_hero_techies",
"npc_dota_hero_warlock",
"npc_dota_hero_witch_doctor",
"npc_dota_hero_skywrath_mage",
"npc_dota_hero_crystal_maiden",
"npc_dota_hero_ancient_apparition",
"npc_dota_hero_shadow_demon",
"npc_dota_hero_lich",
"npc_dota_hero_winter_wyvern",
"npc_dota_hero_keeper_of_the_light",
"npc_dota_hero_oracle",
};
function GetPriority()
	local npcBot = GetBot();
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local priority = 0;
	local name = npcBot:GetUnitName();
	for k, heroname in pairs(TableHeroPriorityAsAlly) do
		if(heroname == name) then
			priority = 999 - k;
			return priority;
		end
	end
	return priority;
end
function GetRole()
	local counts = 1;
	local herofile = require(GetScriptDirectory() .. "/herofile");
	for k , AllyHeroPriority in pairs (herofile.TableAllyHeroPriority) do
		if (GetPriority() < AllyHeroPriority) then
			counts = counts + 1;
		end
	end
	return counts;
end
function FindNearestEnemyHero(location)
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local MinDistance = 99999;
	local NearestEnemyHero = nil;
	local HeroNum = nil;
	for k, PlayerID in pairs(herofile.TableEnemyPlayerID) do
		local LastSeenLocation = GetHeroLastSeenInfo( PlayerID ).location; 
		if (IsHeroAlive( PlayerID ) and #(location - LastSeenLocation) < MinDistance) then
			NearestEnemyHero = PlayerID;
			MinDistance = #(location - LastSeenLocation);
			HeroNum = k;
		end
	end
	return NearestEnemyHero, HeroNum, MinDistance;
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
function GetNearbyEnemyPower( location ) 
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local EnemyRawPower = 0;
	local TowerPower = 0;
	for k, PlayerID in pairs(herofile.TableEnemyPlayerID) do
		if (IsHeroAlive( PlayerID ) and #(location - herofile.TableLastSeenInfo[k].location) < math.max(herofile.TableEnemyPlayerSpeed[k] * 3 + herofile.TableEnemyPlayerAttackRange[k], 1500) ) then
			EnemyRawPower = EnemyRawPower + herofile.TableEnemyHeroPower[k];
		end
	end
	return EnemyRawPower;
end
function GetNearbyEnemyHealth( location ) 
	local herofile = require(GetScriptDirectory() .. "/herofile");
	local EnemyHealth = 0;
	for k, PlayerID in pairs(herofile.TableEnemyPlayerID) do
		if (IsHeroAlive( PlayerID ) and #(location - herofile.TableLastSeenInfo[k].location) < math.max(herofile.TableEnemyPlayerSpeed[k] * 3 + herofile.TableEnemyPlayerAttackRange[k], 1500) ) then
			EnemyHealth = EnemyHealth + herofile.TableEnemyHeroHP[k] ;
		end
	end
	return EnemyHealth;
end