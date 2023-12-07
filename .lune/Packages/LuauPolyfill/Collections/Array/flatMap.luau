--!native
--!optimize 2
local __DEV__ = _G.__DEV__
local flat = require("./flat")
local map = require("./map")
type Array<T> = {T}
type callbackFn<T, U> = (element: T, index: number, array: Array<T>) -> U
type callbackFnWithThisArg<T, U, V> = (thisArg: V, element: T, index: number, array: Array<T>) -> U

local function flatMap<T, U, V>(
	array: Array<T>,
	callback: callbackFn<T, U> | callbackFnWithThisArg<T, U, V>,
	thisArg: V?
): Array<U>
	if __DEV__ then
		if type(array) ~= "table" then
			error(string.format("Array.flatMap called on %s", typeof(array)))
		end

		if type(callback) ~= "function" then
			error("callback is not a function")
		end
	end

	return flat(map(array, callback, thisArg))
end

return flatMap
