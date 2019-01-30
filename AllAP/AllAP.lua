AllAP = {}
AllAP.name = "AllAP"
AllAP.version = "1.2"
AllAP.savedVars = {}
AllAP.default = {
	["ap"] = {},
	["ranks"] = {}
}

local charName = GetUnitName("player")

local function comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function AllAP.OnLoaded(_, addonName)
    if addonName ~= AllAP.name then return end
	AllAP.savedVars = ZO_SavedVars:NewAccountWide("AllAPVars", 3, nil, AllAP.default)
    AllAP:Init()
end

function AllAP:Init()
    AllAP.SaveAP()
	
    SLASH_COMMANDS["/ap"] = function (args)
		
		AllAP.SaveAP()
		
		if args ~= "all" then
		    local ap = GetUnitAvARankPoints("player")
			local _, n = GetAvARankProgress(ap)
			local r, _ = GetUnitAvARank("player")
			local hp = GetSecondsPlayed() / 3600
			AllAP.DisplayAPInfo(r, ap, n - ap, hp)
		else
			local charNames = {}
			local totalAP = 0

			for n, a in pairs(AllAP.savedVars.ap) do
				table.insert(charNames, n)
				totalAP = totalAP + a
			end

        AllAP.DisplayAllAP(charNames, totalAP)
		end
    end
	
	SLASH_COMMANDS["/rl"] = function(a) ReloadUI() end

    EVENT_MANAGER:UnregisterForEvent(AllAP.name, EVENT_ADD_ON_LOADED)
end

function AllAP.SaveAP()
    AllAP.savedVars.ap[charName] = GetUnitAvARankPoints("player")
	AllAP.savedVars.ranks[charName] = GetUnitAvARank("player")
end

function AllAP.DisplayAPInfo(rank, points, rankup, _time)
	local nextRankName = GetAvARankName(GetUnitGender("player"),rank+1)
	local aph = points/_time
	CHAT_SYSTEM:AddMessage("You have earned |c44cc66"..comma_value(points).." |rAlliance Points on|t20:20:"..GetAvARankIcon(rank).."|t"..GetUnitName("player")..".")
	if rank < 50 then
		CHAT_SYSTEM:AddMessage("You need |c44cc66"..comma_value(rankup).." |rAlliance Points to reach|t20:20:"..GetAvARankIcon(rank+1).."|t"..nextRankName..".")
	else
		CHAT_SYSTEM:AddMessage("You cannot rank up beyond |t20:20:"..GetAvARankIcon(50).."|t|c6e70d8"..GetAvARankName(GetUnitGender("player"),50).."|r.")
	end
	CHAT_SYSTEM:AddMessage("You have gained |c44cc66"..string.format("%.1f", aph).." |rAlliance Points per hour of playtime on this character.")
end

function AllAP.DisplayAllAP(names, a)
    CHAT_SYSTEM:AddMessage("You have earned |c44cc66"..comma_value(a).." |rAlliance Points on"..AllAP.FormatNames(names))
end

function AllAP.FormatNames(names)
    local allNames = ""
    local index, name = next(names, nil)
    while index do
        local nextIndex, nextName = next(names, index)
        local isFirst = string.len(allNames) == 0
        if not isFirst then
            allNames = allNames .. (nextIndex and ", " or " and ")
        end
        allNames = allNames.."|t20:20:"..GetAvARankIcon(AllAP.savedVars.ranks[name]).."|t"..name
        index, name = nextIndex, nextName
    end
    return allNames
end

EVENT_MANAGER:RegisterForEvent(AllAP.name, EVENT_ADD_ON_LOADED, AllAP.OnLoaded)
EVENT_MANAGER:RegisterForEvent(AllAP.name, EVENT_LOGOUT_DEFERRED, AllAP.SaveAP)
EVENT_MANAGER:RegisterForEvent(AllAP.name, EVENT_ALLIANCE_POINT_UPDATE, AllAP.SaveAP)