--!native
--!optimize 2
local LuauPolyfill = require("../../LuauPolyfill")
local String = LuauPolyfill.String

-- used in lexer.printCharCode
return function(code)
	-- convert dex to hexadex
	local hex = string.format("%x", code)
	-- prepend 4 spaces
	local pre = "0000" .. hex
	-- take rightmost 4 characters
	local val = string.upper(String.slice(pre, -4))
	-- then combine with "\\u${}"
	local out = "\"\\u" .. val .. "\""
	return out
end
