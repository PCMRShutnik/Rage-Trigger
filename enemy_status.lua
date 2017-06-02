local utils = require(GetScriptDirectory() .. "/util")
local X = {}
local tableEnemyHeroes = {}
local rawEnemyPower = 0
function X.FillHeroesTable ()
	if next(tableEnemyHeroes) == nil then
		local us = GetTeamPlayers( GetTeam() )
		local them
		if math.abs(GetTeam() - 3) == 1 then
			them = 3
		else
			them = 2
		end
		for i=1,5 do
			tableEnemyHeroes[GetTeamMember( i ):GetUnitName()] = GetTeamMember( i )
		end
		for _,v in pairs(tableEnemyHeroes) do
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
function X.UpdateEnemyStatus ()
	if next(tableEnemyHeroes) == nil then
		X.FillHeroesTable()
	end
	local dummyArmor = GetTeamMember( 1 ):GetArmor()
	local dummyPhysResist = 1 - 0.06 * dummyArmor / (1 + (0.06 * math.abs(dummyArmor)))
	local dummyMagResist = GetTeamMember( 1 ): GetMagicResist()
	for _,v in pairs(tableEnemyHeroes) do
		if v:CanBeSeen() then
			v.missing = false
			local pow = v:GetEstimatedDamageToTarget( true, GetTeamMember( 1 ), 10.0, DAMAGE_TYPE_PHYSICAL ) / dummyPhysResist
			if v.attackPower and pow > v.attackPower then
				v.attackPower = pow
			end
			pow = v:GetEstimatedDamageToTarget( true, GetTeamMember( 1 ), 10.0, DAMAGE_TYPE_MAGICAL ) / dummyMagResist
			if v.magicPower and pow > v.magicPower then
				v.magicPower = pow
			end
		else
			v.missing = true
		end
	end
end
function X.GetHeroes ()
	if next(tableEnemyHeroes) == nil then
		X.FillHeroesTable()
	end
	return tableEnemyHeroes
end
function X.GetAttackPower (sHeroName)
	return tableEnemyHeroes[sHeroName].attackPower
end
return X