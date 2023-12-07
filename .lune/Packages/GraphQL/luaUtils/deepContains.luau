--!native
--!optimize 2
local Number = require("../../LuauPolyfill").Number
local NULL = require("./null")

local function deepContains(a: any, b: any): (boolean, string?)
	if typeof(a) ~= typeof(b) then
		local message = string.format("{1}: value of type '%*'\n{2}: value of type '%*'", typeof(a), typeof(b))
		return false, message
	end

	if Number.isNaN(a) and Number.isNaN(b) then
		return true
	end

	if a == b then
		return true
	end

	if a == NULL or b == NULL or type(a) ~= "table" then
		return false, string.format("{1} (%*) ~= {2} (%*)", tostring(a), tostring(b))
	end

	for key, value in next, b do
		local success, innerMessage = deepContains(a[key], value)
		if not success then
			-- ROBLOX FIXME Luau: Luau should infer the return as (false, string) | (true, nil), and then know `not success` means innerMessage is string
			local message = string.gsub(
				string.gsub(innerMessage, "{1}", string.format("{1}[%*]", tostring(key))),
				"{2}",
				string.format("{2}[%*]", tostring(key))
			)

			return false, message
		end
	end
	return true
end

return deepContains
