_G._savedEnv = getfenv()
module( "buildings_status", package.seeall )
 TYPE_TOWER = "tower"
 TYPE_MELEE = "melee"
 TYPE_RANGED = "ranged"
 TYPE_SHRINE = "shrine"
 TYPE_ANCIENT = "ancient"
local buildings = {
    {["ApiID"]=TOWER_TOP_1, ["Type"]=TYPE_TOWER},
    {["ApiID"]=TOWER_TOP_2, ["Type"]=TYPE_TOWER},
    {["ApiID"]=TOWER_TOP_3, ["Type"]=TYPE_TOWER},
    {["ApiID"]=TOWER_MID_1, ["Type"]=TYPE_TOWER},
    {["ApiID"]=TOWER_MID_2, ["Type"]=TYPE_TOWER},
    {["ApiID"]=TOWER_MID_3, ["Type"]=TYPE_TOWER},
    {["ApiID"]=TOWER_BOT_1, ["Type"]=TYPE_TOWER},
    {["ApiID"]=TOWER_BOT_2, ["Type"]=TYPE_TOWER},
    {["ApiID"]=TOWER_BOT_3, ["Type"]=TYPE_TOWER},
    {["ApiID"]=TOWER_BASE_1, ["Type"]=TYPE_TOWER},
    {["ApiID"]=TOWER_BASE_2, ["Type"]=TYPE_TOWER},
    {["ApiID"]=BARRACKS_TOP_MELEE, ["Type"]=TYPE_MELEE},
    {["ApiID"]=BARRACKS_TOP_RANGED, ["Type"]=TYPE_RANGED},
    {["ApiID"]=BARRACKS_MID_MELEE, ["Type"]=TYPE_MELEE},
    {["ApiID"]=BARRACKS_MID_RANGED, ["Type"]=TYPE_RANGED},
    {["ApiID"]=BARRACKS_BOT_MELEE, ["Type"]=TYPE_MELEE},
    {["ApiID"]=BARRACKS_BOT_RANGED, ["Type"]=TYPE_RANGED},
    {["ApiID"]=0, ["Type"]=TYPE_ANCIENT},
    {["ApiID"]=SHRINE_JUNGLE_1, ["Type"]=TYPE_SHRINE},
    {["ApiID"]=SHRINE_JUNGLE_2, ["Type"]=TYPE_SHRINE},
    {["ApiID"]=SHRINE_BASE_1, ["Type"]=TYPE_SHRINE},
    {["ApiID"]=SHRINE_BASE_2, ["Type"]=TYPE_SHRINE},
    {["ApiID"]=SHRINE_BASE_3, ["Type"]=TYPE_SHRINE}
}
local offsetByLane = {[LANE_TOP] = 0, [LANE_MID] = 3, [LANE_BOT] = 6}
local tableBuildings = {}
local towers = {}
local barracks = {}
local shrines = {}
local lastUpdate = -9999
local function Initialize()
    tableBuildings[TEAM_RADIANT] = {}
    tableBuildings[TEAM_DIRE] = {}
    local team = GetTeam()
    for i, building in ipairs(buildings) do
        tableBuildings[TEAM_RADIANT][i] = {}
        tableBuildings[TEAM_DIRE][i] = {}
        local health = 0
        local pos_radiant = nil
        local pos_dire = nil
        if building.Type == TYPE_TOWER then
            health = GetTower(team, building.ApiID):GetMaxHealth()
            pos_radiant = GetTower(TEAM_RADIANT, building.ApiID):GetLocation()
            pos_dire = GetTower(TEAM_DIRE, building.ApiID):GetLocation()
            towers[#towers+1] = i
        elseif building.Type == TYPE_MELEE then
            health = GetBarracks(team, building.ApiID):GetMaxHealth()
            pos_radiant = GetBarracks(TEAM_RADIANT, building.ApiID):GetLocation()
            pos_dire = GetBarracks(TEAM_DIRE, building.ApiID):GetLocation()
            barracks[#barracks+1] = i
        elseif building.Type == TYPE_RANGED then
            health = GetBarracks(team, building.ApiID):GetMaxHealth()
            pos_radiant = GetBarracks(TEAM_RADIANT, building.ApiID):GetLocation()
            pos_dire = GetBarracks(TEAM_DIRE, building.ApiID):GetLocation()
            barracks[#barracks+1] = i
        elseif building.Type == TYPE_SHRINE then
            health = GetShrine(team, building.ApiID):GetMaxHealth()
            pos_radiant = GetShrine(TEAM_RADIANT, building.ApiID):GetLocation()
            pos_dire = GetShrine(TEAM_DIRE, building.ApiID):GetLocation()
            shrines[#shrines+1] = i
        elseif building.Type == TYPE_ANCIENT then
            health = GetAncient(team):GetMaxHealth()
            pos_radiant = GetAncient(TEAM_RADIANT):GetLocation()
            pos_dire = GetAncient(TEAM_DIRE):GetLocation()
        end
        tableBuildings[TEAM_RADIANT][i].ApiID = building.ApiID
        tableBuildings[TEAM_RADIANT][i].Type = building.Type
        tableBuildings[TEAM_RADIANT][i].MaxHealth = health
        tableBuildings[TEAM_RADIANT][i].LastSeenHealth = health
        tableBuildings[TEAM_RADIANT][i].Vector = pos_radiant
        tableBuildings[TEAM_DIRE][i].ApiID = building.ApiID
        tableBuildings[TEAM_DIRE][i].Type = building.Type
        tableBuildings[TEAM_DIRE][i].MaxHealth = health
        tableBuildings[TEAM_DIRE][i].LastSeenHealth = health
        tableBuildings[TEAM_DIRE][i].Vector = pos_dire
    end
end
function Update(forceUpdate)
    if lastUpdate < -1000 then
        Initialize()
    end
    if DotaTime() - lastUpdate < 0.5 then
        if (not forceUpdate) then return end
    end
    lastUpdate = DotaTime()
    for i, _ in ipairs(tableBuildings[TEAM_RADIANT]) do
        GetHealth(TEAM_RADIANT, i, false)
    end
    for i, _ in ipairs(tableBuildings[TEAM_DIRE]) do
        GetHealth(TEAM_DIRE, i, false)
    end
end
function GetHealth(team, id, cacheOnly)
    if cacheOnly == nil then cacheOnly = true end
    local seen = tableBuildings[team][id].LastSeenHealth
    if cacheOnly then return seen end
    if seen <= 0 then return -1 end
    local building = GetHandle(team, id)
    if building == nil then
        tableBuildings[team][id].LastSeenHealth = -1
        return -1
    end
    local health = building:GetHealth()
    if health > -1 then
        tableBuildings[team][id].LastSeenHealth = health
        return health
    else
        return seen
    end
end
function GetLocation(team, id)
    local result = tableBuildings[team][id].Vector
    return result
end
function GetHandle(team, id)
    local building = tableBuildings[team][id]
    if building == nil then return nil end
    if building.Type == TYPE_TOWER then
        return GetTower(team, building.ApiID)
    elseif building.Type == TYPE_MELEE then
        return GetBarracks(team, building.ApiID)
    elseif building.Type == TYPE_RANGED then
        return GetBarracks(team, building.ApiID)
    elseif building.Type == TYPE_SHRINE then
        return GetShrine(team, building.ApiID)
    elseif building.Type == TYPE_ANCIENT then
        return GetAncient(team)
    end
    return nil
end
function GetStandingBuildingIDs(team)
    local ids = {}
    for i, _ in ipairs(tableBuildings[team]) do
        if GetHealth(team, i) > 0 then
            ids[#ids+1] = i
        end
    end
    return ids
end
function GetType(team, id)
    return tableBuildings[team][id].Type
end
function GetApiID(team, id)
    return tableBuildings[team][id].ApiID
end
function GetDestroyableTowers(team)
    local ids = {}
    for _, id in pairs(towers) do
        if GetHealth(team, id) > 0 and GetHandle(team, id) ~= nil and (not GetHandle(team, id):IsInvulnerable()) then
            ids[#ids+1] = id
        end
    end
    return ids
end
function printBuildings()
    print("Buildings Radiant")
    for i, building in pairs(tableBuildings[TEAM_RADIANT]) do
        print(i, building.LastSeenHealth, building.Vector)
    end
    print("Buildings Dire")
    for i, building in pairs(tableBuildings[TEAM_DIRE]) do
        print(i, building.LastSeenHealth, building.Vector)
    end
end
function GetVulnerableBuildingIDs(team, lane)
    local ids = {}
    for j = 0,6,3 do
        if lane == nil or j == offsetByLane[lane] then
            for i = 1,3,1 do
                if GetHealth(team, i+j) > 0 then
                    ids[#ids+1] = i+j
                    break
                end
            end
        end
    end
    if GetHealth(team, 3) <= 0 and lane == nil or lane == LANE_TOP then
        if GetHealth(team, 12) > 0 then ids[#ids+1] = 12 end
        if GetHealth(team, 13) > 0 then ids[#ids+1] = 13 end
    end
    if GetHealth(team, 6) <= 0 and lane == nil or lane == LANE_MID then
        if GetHealth(team, 14) > 0 then ids[#ids+1] = 14 end
        if GetHealth(team, 15) > 0 then ids[#ids+1] = 15 end
    end
    if GetHealth(team, 9) <= 0 and lane == nil or lane == LANE_BOT then
        if GetHealth(team, 16) > 0 then ids[#ids+1] = 16 end
        if GetHealth(team, 17) > 0 then ids[#ids+1] = 17 end
    end
    if GetHealth(team, 3) <= 0 or GetHealth(team, 6) <= 0 or GetHealth(team, 9) <= 0 and lane == nil or lane == LANE_MID then
        if GetHealth(team, 10) > 0 then ids[#ids+1] = 10 end
        if GetHealth(team, 11) > 0 then ids[#ids+1] = 11 end
    end
    if GetHealth(team, 10) <= 0 or GetHealth(team, 11) <= 0 and lane == nil or lane == LANE_MID then
        ids[#ids+1] = 18
    end
    return ids
end
for k,v in pairs( buildings_status ) do _G._savedEnv[k] = v end
