--!native
--!optimize 2
--!strict
type Array<T> = {T}
type Object = {[string]: any}

-- FIXME: This should be updated to be closer to the actual
-- `Object.preventExtensions` functionality in JS. This requires additional
-- support from the VM
local function preventExtensions<T>(t: T & (Object | Array<any>)): T
	local name = tostring(t)

	return (
		setmetatable(t :: any, {
			__metatable = false;
			__newindex = function(_, key)
				local message = string.format("%q (%*) is not a valid member of %*", tostring(key), typeof(key), name)

				error(message, 2)
			end;
		}) :: any
	) :: T
end

return preventExtensions
