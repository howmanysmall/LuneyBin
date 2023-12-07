--!native
--!optimize 2
--[[
	A utility used to assert that two objects are value-equal recursively. It
	outputs fairly nicely formatted messages to help diagnose why two objects
	would be different.

	This should only be used in tests.
]]
-- FIXME: Replace this with jest-roblox builtins

local Number = require("../../LuauPolyfill").Number
local NULL = require("./null")

local function deepEqual(a: any, b: any): (boolean, string?)
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

	local visitedKeys = {}

	for key, value in next, a do
		visitedKeys[key] = true

		local success, innerMessage = deepEqual(value, b[key])
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

	for key, value in next, b do
		if not visitedKeys[key] then
			local success, innerMessage = deepEqual(a[key], value)

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
	end

	return true
end

return deepEqual
