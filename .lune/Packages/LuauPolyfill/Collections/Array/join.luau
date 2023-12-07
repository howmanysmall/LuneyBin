--!native
--!optimize 2
--!strict
local map = require("./map")

return function<T>(arr: {T}, separator: string?): string
	if #arr == 0 then
		return ""
	end

	-- JS does tostring conversion implicitely but in Lua we need to do that explicitely
	local stringifiedArray = map(arr, tostring)
	return table.concat(stringifiedArray, separator or ",")
end
