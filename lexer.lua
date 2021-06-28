require('utils')

return function (source)
	_result = {}
	_curr_line = {}

	function end_line()
		table.insert(_result, _curr_line)
		_curr_line = {}
	end

	function insert_token(type, c)
		table.insert(_curr_line, {type, c})
	end

	PATTERNS = {
		-- patterns that are used in the search of a single character
		EOLS = "\n",		-- TODO: change according to OS
		INDENTS = "\t",		-- TODO: change according to expandtab
		SPACES = " ",
		MODIFIER_TERMINATORS = "[ %%%?%!%:%;%,%.%>%)%]%}%/%$%'%\"\n]",

		-- strings that always come at the begining of a line
		SYMBOLS = { "@", "- ", "- [", "* ", "** ", "*** " }, -- 1) 2.

		-- strings that represent the left hand side of a modifier (right hand side is the reverse)
		MODIFIERS = { " *", " _", " *_", " ~~" },
	}

	MODES = { NORMAL = 1, SYMBOL = 2, MODIFIER = 3, TEXT = 4}
	mode = MODES.NORMAL
	cache = ""
	pos = 1
	is_eol = false
	prev_exact_match = nil

	function move_pos(n) pos = pos + (n or 1) end
	function cache_char(c) cache = cache..c end
	function cache_flush() cache = "" end
	function is_line_empty() return (#_curr_line == 0) end -- TODO: a boolean is faster


	print("\n- INFO -------")
	while(pos <= #source) do
		-- sleep(0.1)
		local c = source:sub(pos, pos)
		log(LOG_LVLS.DEBUG, "m:"..mode .. "\tc:`"..c .. "`\tcache:"..cache) -- XXX: DEBUG
		if (string.match(c, PATTERNS.EOLS)) then is_eol = true end



		-- NORMAL MODE
		if (mode == MODES.NORMAL) then
			if (string.match(c, PATTERNS.INDENTS)) then
				insert_token("IND", "")
				move_pos()

			elseif (is_line_empty()) then
				if (is_eol) then goto lex_loop_continue end
				mode = MODES.SYMBOL

			else
				mode = MODES.TEXT

			end



		-- SYMBOL MODE
		elseif (mode == MODES.SYMBOL) then
			-- print(cache)
			if (is_eol) then goto lex_loop_continue end
			cache_char(c)
			local match_count, match = sub_match_against_str_arr(cache, PATTERNS.SYMBOLS)

			if (match_count == 1 and match ~= nil) then
				insert_token("SYM", match)
				log(LOG_LVLS.DEBUG, "found one exact match '"..cache.."' against '"..match.."' added as a SYM token")
				cache_flush()
				move_pos()
				mode = MODES.NORMAL

			elseif (match_count == 1 and match == nil) then
				log(LOG_LVLS.DEBUG, "found one possible match but it's not confirmed yet '"..cache.."'")
				move_pos()
				goto lex_loop_continue

			elseif (match_count > 1 and match ~= nil) then
				log(LOG_LVLS.DEBUG, "found more than one possible match but there is an exact match '"..cache.."'")
				prev_exact_match = cache

			elseif (match_count > 1) then
				log(LOG_LVLS.DEBUG, "found more than one possible match '"..cache.."'")
				move_pos()
				goto lex_loop_continue

			elseif (match_count == 0) then
				log(LOG_LVLS.DEBUG, "no possible match'"..cache.."'")

				if (prev_exact_match ~= nil) then
					insert_token("SYM", prev_exact_match)
					log(LOG_LVLS.DEBUG, "used prev exact match '"..prev_exact_match.."' added as a SYM token")
					cache_flush()
					prev_exact_match = nil
					move_pos()
					mode = MODES.NORMAL
				else
					move_pos()
					mode = MODES.NORMAL
				end

			end



		-- TEXT MODE
		elseif (mode == MODES.TEXT) then
			if (not is_eol) then
				cache_char(c)
				move_pos()
			else
				insert_token("TEXT", cache)
				cache_flush()
				mode = MODES.NORMAL
			end
		end



		::lex_loop_continue::

		-- end line if c is an EOL char
		if (is_eol) then
			end_line()
			move_pos()
			mode = MODES.NORMAL
			is_eol = false
		end
	end

	return _result
end









-- 			placeholder_symbol = placeholder_symbol .. c
-- 			
-- 			for i, sym in pairs(held_symbols) do
-- 
-- 				if (placeholder_symbol == sym["string"]) then
-- 					-- print(placeholder_symbol)
-- 					for i=1, #placeholder_symbol do
-- 						local pla_c = placeholder_symbol:sub(i,i)
-- 						local sym_c = sym["string"]:sub(i,i)
-- 						if (pla_c ~= sym_c) then
-- 							-- held_symbols.remove()
-- 						end
-- 					end
-- 
-- 				end
-- 			end
-- 
-- 			if (#held_symbols == 1) then
-- 				insert_token("MOD", placeholder_symbol)
-- 				held_symbols = tokens.symbol
-- 				placeholder_symbol = ""
-- 			end
-- 
-- 			-- if (string.match(c, tokens.chars.symbol)) then
-- 			-- end
-- 
-- 			-- elseif (string.match(c, tokens.chars.indent)) then
-- 				-- insert_token("IND", "")
-- 
-- 			-- elseif (string.match(c, tokens.chars.space)) then
-- 				-- insert_token("SP", "")

-- print(string.match("%", tokens.chars.modifier_terminators))
