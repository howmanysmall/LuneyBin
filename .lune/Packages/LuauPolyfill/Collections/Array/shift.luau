--!native
--!optimize 2
--!strict
local __DEV__ = _G.__DEV__
local isArray = require("./isArray")
type Array<T> = {T}

return function<T>(value: Array<T>): T?
	if __DEV__ then
		if not isArray(value) then
			error(string.format("Array.shift called on non-array %s", typeof(value)))
		end
	end

	if #value > 0 then
		return table.remove(value, 1)
	else
		return nil
	end
end
