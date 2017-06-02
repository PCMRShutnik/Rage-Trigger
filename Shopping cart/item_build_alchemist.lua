X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildlogic");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_poor_mans_shield",
	"item_boots",
	"item_magic_wand",
	"item_armlet",
	"item_radiance",
	"item_travel_boots",
	"item_assault",
	"item_octarine_core",
	"item_heart"
};

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,1,3,2,3,4,3,1,1,1,4,2,2,2,4}, skills, 
	  {1,4,6,7}, talents
);			

return X