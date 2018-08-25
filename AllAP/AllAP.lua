AllAP = {}
AllAP.name = "AllAP"
AllAP.version = "1.1"
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
		
		if args ~= "all" then
			r, _ = GetUnitAvARank("player") 
			CHAT_SYSTEM:AddMessage("You have earned |c44cc66"..comma_value(GetUnitAvARankPoints("player")).." |rAlliance Points on|t20:20:"..GetAvARankIcon(r).."|t"..GetUnitName("player"))
		else
			AllAP.SaveAP()

			local charNames = {}
			local totalAP = 0

			for n, a in pairs(AllAP.savedVars.ap) do
				table.insert(charNames, n)
				totalAP = totalAP + a
			end

        AllAP.DisplayAP(charNames, totalAP)
		end
    end
	
	SLASH_COMMANDS["/rl"] = function(a) ReloadUI() end

    EVENT_MANAGER:UnregisterForEvent(AllAP.name, EVENT_ADD_ON_LOADED)
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

function AllAP.SaveAP()
    AllAP.savedVars.ap[charName] = GetUnitAvARankPoints("player")
	AllAP.savedVars.ranks[charName] = GetUnitAvARank("player")
end

function AllAP.DisplayAP(names, a)
    CHAT_SYSTEM:AddMessage("You have earned |c44cc66"..comma_value(a).." |rAlliance Points on "..AllAP.FormatNames(names))
end

EVENT_MANAGER:RegisterForEvent(AllAP.name, EVENT_ADD_ON_LOADED, AllAP.OnLoaded)
EVENT_MANAGER:RegisterForEvent(AllAP.name, EVENT_LOGOUT_DEFERRED, AllAP.SaveAP)
EVENT_MANAGER:RegisterForEvent(AllAP.name, EVENT_ALLIANCE_POINT_UPDATE, AllAP.SaveAP)