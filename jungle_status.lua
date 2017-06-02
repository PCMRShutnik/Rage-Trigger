local X = {}
local utils = require(GetScriptDirectory() .. "/util")
local isJungleFresh = true
local jungle = utils.deepcopy(utils.tableNeutralCamps)
function X.NewJungle ()
	if not isJungleFresh then
		jungle = utils.deepcopy(utils.tableNeutralCamps)
		isJungleFresh = true
	end
end
function X.GetJungle ( nTeam )
	if jungle[nTeam] == nil or #jungle[nTeam] == 0 then
		return nil
	end
	return jungle[nTeam]
end
function X.JungleCampClear ( nTeam, vector )
  	for i=#jungle[nTeam],1,-1 do
	    if jungle[nTeam][i][VECTOR] == vector then
	        table.remove(jungle[nTeam], i)
	    end
	end
  isJungleFresh = false
end
return X