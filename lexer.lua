return function (source)
	local result = {}
	local curr_line = {}
	local lex_mode = "char"
	local string_token = ""

	local tokens = {
		-- chars are pattern matched
		chars = {
			symbol = "[#-]",
			punctuation = "[%[%]]",
			indent = "\t",
			space = " ",
			eol = "\n"
		},

		-- strings are iterated
		strings = {
			keys = {"TITLE", "AUTHOR", "DATE"},
		},
	}

	local function insert_token(type, c)
		table.insert(curr_line, {type, c})
	end

	local function capture_char(c)
		string_token = string_token .. c
	end

	local function insert_string_token(type)
		insert_token(type, string_token)
		string_token = ""
	end

	local function end_line()
		table.insert(result, curr_line)
		curr_line = {}
	end

	source:gsub(".", function(c)

		if (lex_mode == "char") then
	
			-- since char mode can only read a \n if it was at the begining of the line this means it's an empty line
			if (string.match(c, tokens.chars.eol)) then
				end_line()

			elseif (string.match(c, tokens.chars.indent)) then -- TODO: change if expandtab is enabled
				insert_token("IND", "")

			elseif (string.match(c, tokens.chars.space)) then
				insert_token("SP", "")
				-- return

			elseif (string.match(c, tokens.chars.symbol)) then
				insert_token("SYM", c)

			elseif (string.match(c, tokens.chars.punctuation)) then
				insert_token("PUNC", c)

			-- if no char matches switch to string mode
			else
				capture_char(c)
				lex_mode = "string"

			end


		elseif (lex_mode == "string") then

			if (c ~= "\n") then
				capture_char(c)

				-- key (2 or more chars in a row)
				for _, key in pairs(tokens.strings.keys) do
					if (string_token == key) then
						insert_string_token("KEY")
						lex_mode = "char"
					end
				end

			else
				insert_string_token("TEXT")
				end_line()
				lex_mode = "char"
			end

		end
	end)

	return result
end
