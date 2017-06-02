
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
	Abilities[3],
	Abilities[1],
	Abilities[3],
	Abilities[1],
	Abilities[3],
	Abilities[4],
	Abilities[2],
	Abilities[1],
	Abilities[1],
	"talent",
	Abilities[1],
	Abilities[4],
	Abilities[2],
	Abilities[2],
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
		return Talents[2]
	end,
	function()
		return Talents[3]
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
function CourierUsageThink() 
	ability_item_usage_generic.CourierUsageThink()
end