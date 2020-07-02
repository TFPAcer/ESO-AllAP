AllAP = AllAP or {}
AllAP.name = "AllAP"
AllAP.version = "1.3"
AllAP.savedVars = {}
AllAP.default = {
	["chars"] = {}
}

local function comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

local function round(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function AllAP.OnLoaded(_, addonName)
    if addonName ~= AllAP.name then return end
	AllAP.savedVars = ZO_SavedVars:NewAccountWide("AllAPVars", 4, nil, AllAP.default)
    AllAP:Init()
end

function AllAP:Init()
    AllAP.SaveAP()
	
    SLASH_COMMANDS["/ap"] = function (args)
		
		AllAP.SaveAP()
		
		if args == "all" then
			AllAP.DisplayAllAP(false)
		elseif args == "all+" then
			AllAP.DisplayAllAP(true)
		elseif args == "class" then
			AllAP.DisplayClassAP(false)
		elseif args == "class+" then
			AllAP.DisplayClassAP(true)
		else
			AllAP.DisplayAP()
		end
    end
	
	SLASH_COMMANDS["/rl"] = function(a) ReloadUI() end

    EVENT_MANAGER:UnregisterForEvent(AllAP.name, EVENT_ADD_ON_LOADED)
end

function AllAP.SaveAP()
    AllAP.savedVars.chars[GetCurrentCharacterId()] = { ap = GetUnitAvARankPoints("player"), rank = GetUnitAvARank("player"), class = GetUnitClassId("player"), name = GetUnitName("player") }
end

function AllAP.DisplayAP()
	
	local _char = AllAP.savedVars.chars[GetCurrentCharacterId()]
	local _,progress = GetAvARankProgress(_char.ap)
	local rankup = progress-_char.ap
	local aph = 3600*_char.ap/GetSecondsPlayed()

	CHAT_SYSTEM:AddMessage(table.concat({"You have earned",AllAP.FormatAPText(_char.ap),"on",AllAP.FormatRankIcon(_char.rank),_char.name,"." }))
	if _char.rank < 50 then
		CHAT_SYSTEM:AddMessage(table.concat({"You need",AllAP.FormatAPText(rankup),"to reach",AllAP.FormatRankText(_char.rank+1),"." }))
	else
		CHAT_SYSTEM:AddMessage(table.concat({"You cannot rank up beyond",AllAP.FormatRankText(50),"." }))
	end
	CHAT_SYSTEM:AddMessage(table.concat({"You have gained",AllAP.FormatAPText(aph),"per hour of playtime on",AllAP.FormatRankIcon(_char.rank),_char.name,"."}))
	
end

function AllAP.DisplayClassAP(ext)
	
	local totalAP = {}
	local chars = {}
	
	for i=1,GetNumClasses() do
		totalAP[i] = 0
		chars[i] = {}
	end
	
	for k,v in pairs(AllAP.savedVars.chars) do
		totalAP[v.class] = totalAP[v.class] + v.ap
		chars[v.class][k] = v
	end
	
	for i=1,#chars do
		CHAT_SYSTEM:AddMessage(table.concat({"You have earned",AllAP.FormatAPText(totalAP[i]),"on",AllAP.FormatClassText(i)}))
		if ext then
			for k,v in pairs(chars[i]) do
				CHAT_SYSTEM:AddMessage(table.concat({AllAP.FormatRankIcon(v.rank),v.name," has earned ",AllAP.FormatAPText(v.ap)}))
			end
		end
	end
	
end

function AllAP.DisplayAllAP(ext)
	
	local totalAP = 0
	local chars = AllAP.savedVars.chars
	
	for k,v in pairs(AllAP.savedVars.chars) do
		totalAP = totalAP + v.ap
	end
	
    CHAT_SYSTEM:AddMessage(table.concat({"You have earned",AllAP.FormatAPText(totalAP),"in total"}))
	if ext then
		for k,v in pairs(chars) do
			CHAT_SYSTEM:AddMessage(table.concat({AllAP.FormatRankIcon(v.rank),v.name," has earned",AllAP.FormatAPText(v.ap)}))
		end
	end
	
end


function AllAP.FormatAPText(ap)
	return table.concat({" |c44cc66",comma_value(round(ap,1)),"|r|t16:16:",GetCurrencyKeyboardIcon(2),"|t "})
end

function AllAP.FormatRankIcon(rank)
	return table.concat({"|t20:20:",GetAvARankIcon(rank),"|t"})
end

function AllAP.FormatRankText(rank)
	return table.concat({"|t20:20:",GetAvARankIcon(rank),"|t|c4abdcf",GetAvARankName(0,rank),"|r"})
end

function AllAP.FormatClassText(class)
	local _,_,_,_,_,_,i = GetClassInfo(class)
	return table.concat({"|t20:20:",i,"|t|ced2f2f",GetClassName(0,class),"|r"})
end

EVENT_MANAGER:RegisterForEvent(AllAP.name, EVENT_ADD_ON_LOADED, AllAP.OnLoaded)
EVENT_MANAGER:RegisterForEvent(AllAP.name, EVENT_LOGOUT_DEFERRED, AllAP.SaveAP)
EVENT_MANAGER:RegisterForEvent(AllAP.name, EVENT_ALLIANCE_POINT_UPDATE, AllAP.SaveAP)