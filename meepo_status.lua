local utils = require(GetScriptDirectory() .. "/util")
local X = {}
local tableMeepos = {}
local isFarmed = false
function X.AddMeepo ( meepo )
	table.insert(tableMeepos, meepo)
end
function X.GetMeepos ()
	return tableMeepos
end
function X.GetIsFarmed()
	return isFarmed
end
function X.SetIsFarmed( bFarmed )
	isFarmed = bFarmed
end
return X