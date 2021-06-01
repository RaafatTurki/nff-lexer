function serialize_token(token)
	local type = token[1]
	local data = token[2] or ""
	return type .. "\t" .. data
end

function serialize_tokens_line(line)
	local res = ""

	if (#line == 0) then
		res = res .. serialize_token({"EMPTY", ""}) .. "\n"
	else
		for i, token in pairs(line) do
			res = res .. serialize_token(token) .. "\n"
		end
	end

    return res
end

function serialize_tokens_lines_arr(lines_arr)
	res = ""
	for i, line in pairs(lines_arr) do
		res = res .. serialize_tokens_line(line) .. "\n"
	end
	return res
end

lex = require('lexer')

local lex_result = lex([[
#TITLE Neorg Mode Demo

- [ ] big boi
	- [ ] smol boi
]])

-- #AUTHOR Raafat Turki
-- #DATE Tue 01 Jun 2021

-- local lex_result = lex("- [ ] big boi\n")

print(serialize_tokens_lines_arr(lex_result))
print("lexed " .. #lex_result .. " lines")
