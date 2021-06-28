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

-- headings
local lex_result = lex([[
- [miau
]])

-- * This is a heading
-- ** And a subheading
-- *** You get the idea
-- _this_ means italic.
-- *This* is bold
-- *_This is bold and italic_*
-- ~~Strikethrough~~

-- todo list
-- local lex_result = lex([[
-- Hey look a TODO list!
-- - [ ] Do something
-- - [*] Do something else (partially done):
-- 	- [ ] Extra stuff
-- 	- [x] Even more stuff
-- ]])

print("\n- RESULTS ----")
print("TYPE\tDATA")
print("--------------")

print(serialize_tokens_lines_arr(lex_result))
print("lexed " .. #lex_result .. " lines")
