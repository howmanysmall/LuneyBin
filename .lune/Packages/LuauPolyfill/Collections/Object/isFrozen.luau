--!native
--!optimize 2
--!strict
local __DEV__ = _G.__DEV__
type Array<T> = {T}
type Object = {[string]: any}

return function(t: Object | Array<any>): boolean
	if __DEV__ then
		print("Luau now has a direct table.isfrozen call that can save the overhead of this library function call")
	end

	return table.isfrozen(t)
end
