--!native
--!optimize 2
--!strict
type Array<T> = {T}
local indexOf = require("./indexOf")

return function<T>(array: Array<T>, searchElement: T, fromIndex: number?): boolean
	return indexOf(array, searchElement, fromIndex) ~= -1
end
