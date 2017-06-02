X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildlogic");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_poor_mans_shield",
	"item_power_treads",
	"item_ultimate_scepter",
	"item_sheepstick",
	"item_blink",
	"item_eye_of_skadi",
	"item_heart",
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "meepo", 
	  {2,1,4,2,2,3,2,3,3,4,3,1,1,1,4}, skills, 
	  {1,4,5,7}, talents
);

return X