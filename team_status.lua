local utils = require(GetScriptDirectory() .. "/util")
local enemyStatus = require( GetScriptDirectory() .."/enemy_status" )
local X = {}
local tableFriendlyHeroes = {}
local tableRunes = {}
X.TeamFight = false
X.CallForGlobal = false
X.GlobalTarget = nil
function X.FillHeroesTable ()
	if next(tableFriendlyHeroes) == nil then
		for i=1,5 do
			tableFriendlyHeroes[GetTeamMember( i ):GetUnitName()] = GetTeamMember( i )
		end
		for _,v in pairs(tableFriendlyHeroes) do			
			if (v:GetUnitName() == "npc_dota_hero_ancient_apparition" or
				v:GetUnitName() == "npc_dota_hero_spirit_breaker" or
				v:GetUnitName() == "npc_dota_hero_wisp" or
				v:GetUnitName() == "npc_dota_hero_treant" or
				v:GetUnitName() == "npc_dota_hero_abyssal_underlord" or
				v:GetUnitName() == "npc_dota_hero_bloodseeker" or
				v:GetUnitName() == "npc_dota_hero_ember_spirit" or
				v:GetUnitName() == "npc_dota_hero_meepo" or
				v:GetUnitName() == "npc_dota_hero_spectre" or
				v:GetUnitName() == "npc_dota_hero_invoker" or
				v:GetUnitName() == "npc_dota_hero_furion" or
				v:GetUnitName() == "npc_dota_hero_silencer" or
				v:GetUnitName() == "npc_dota_hero_storm_spirit" or
				v:GetUnitName() == "npc_dota_hero_zuus")
			then
			v.hasGlobal = true
			end
		end
	end
end
function X.UpdateTeamStatus()
	local npcBot = GetBot()
	if next(tableFriendlyHeroes) == nil then
		X.FillHeroesTable()
	end
	if 	next(tableFriendlyHeroes) == npcBot:GetUnitName() and 
		tableFriendlyHeroes[next(tableFriendlyHeroes)]:IsBot() 
	then
		enemyStatus.UpdateEnemyStatus()
		for _,v in pairs(tableFriendlyHeroes) do
			if not v:IsBot() then
				X.UpdateTeamStatus( v:GetUnitName() )
			end
		end
	end
	local dummyArmor = GetTeamMember( 1 ):GetArmor()
	local dummyPhysResist = 1 - 0.06 * dummyArmor / (1 + (0.06 * math.abs(dummyArmor)))
	local dummyMagResist = GetTeamMember( 1 ): GetMagicResist()
	local pow = npcBot:GetEstimatedDamageToTarget( true, GetTeamMember( 1 ), 10.0, DAMAGE_TYPE_PHYSICAL ) / dummyPhysResist
	if npcBot.attackPower == nil or pow > npcBot.attackPower then
		npcBot.attackPower = pow
	end
	pow = npcBot:GetEstimatedDamageToTarget( true, GetTeamMember( 1 ), 10.0, DAMAGE_TYPE_MAGICAL ) / dummyMagResist
	if npcBot.magicPower == nil or pow > npcBot.magicPower then
		npcBot.magicPower = pow
	end
	if not npcBot:IsBot() then
		if npcBot:GetHealth() < npcBot:GetMaxHealth() * .5 then
			npcBot.NeedsHelp = true
			npcBot.CanHelp = false
		else
			npcBot.NeedsHelp = false
			npcBot.CanHelp = true
		end
	end
	npcBot.NearbyFriends = {}
	for _,w in pairs(tableFriendlyHeroes) do
		if #(w:GetLocation() - npcBot:GetLocation()) < 1300 then
			table.insert(npcBot.NearbyFriends, w)
		end
	end
	npcBot.NearbyEnemies = {}
	for _,w in pairs(enemyStatus.GetHeroes()) do
		if #(w:GetLocation() - npcBot:GetLocation()) < 1300 then
			table.insert(npcBot.NearbyEnemies, w)
		end
	end
	if #npcBot.NearbyFriends + #npcBot.NearbyEnemies >= 5 then
		npcBot.IsFighting = true
	else
		npcBot.IsFighting = false
	end
	local fightingCount = 0
	for _,v in pairs(tableFriendlyHeroes) do
		if v.IsFighting then fightingCount = fightingCount + 1 end
	end
	if fightingCount >=3 then
		TeamFight = true
	else
		TeamFight = false
	end
end
function X.GetHeroes ()
	if next(tableFriendlyHeroes) == nil then
		X.FillHeroesTable()
	end
	return tableFriendlyHeroes
end
function X.AddHero ( hHero )
	if next(tableFriendlyHeroes) == nil then
	else
		table.insert(tableFriendlyHeroes, hHero )
		print(hHero:GetUnitName() .. " added!")
	end
end
function X.CallRune (rune)
	table.insert(tableRunes, rune)
end
function X.GetCalledRunes ()
	return tableRunes
end
function X.ClearCalledRunes ()
	for k in pairs (tableRunes) do
    	tableRunes[k] = nil
	end
end
return X