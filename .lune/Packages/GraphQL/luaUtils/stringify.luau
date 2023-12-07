--!native
--!optimize 2
local NULL = require("./null")
local serde = require("@lune/serde")
local encodedNull = serde.encode("json", NULL)

local function stringify(obj: any): string
	local encodedObj = serde.encode("json", obj)
	local nullReplacedString = string.gsub(encodedObj, encodedNull, "null")

	return nullReplacedString
end

return stringify
