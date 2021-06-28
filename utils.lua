LOG_LVLS = {
	ERR		= 1,
	WARN	= 2,
	INFO	= 3,
	DEBUG	= 4,
}
LOG_LEVEL = LOG_LVLS.INFO
lvls = {"ERR__", "WARN_", "INFO_", "DEBUG"}

function log(lvl, msg)
	if (lvl > LOG_LEVEL) then return end
	print(lvls[lvl]..": "..msg)
end

function sub_match_against_str_arr(str, arr)
	match_count = 0
	match = nil
	for i, symbol in pairs(arr) do
		si, ei = string.find(symbol, str, 1, true)
		if (si == 1 and ei == #str) then
			local sub_match = string.sub(cache, si, ei)
			log(LOG_LVLS.DEBUG, "str '"..sub_match.."' sub matched against '"..symbol.."'")
			match_count = match_count + 1
			if (match_count == 1 and sub_match == symbol) then
				match = symbol
			end
		end
	end
	return match_count, match
end

function printq(str)
	print("'" .. str .. "'")
end

function sleep(n) 
	local sec = tonumber(os.clock() + n); 
	while (os.clock() < sec) do 
	end 
end
