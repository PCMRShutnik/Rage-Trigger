X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildlogic");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_boots",
	"item_magic_wand",
	"item_arcane_boots",
	"item_force_staff",
	"item_solar_crest",
	"item_glimmer_cape",
	"item_hurricane_pike",
	"item_ultimate_scepter",
	"item_linken_sphere",
	"item_monkey_king_bar",
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,2,2,1,2,4,2,1,1,1,4,3,3,3,4}, skills, 
	  {2,4,5,8}, talents
);

return X