--!native
--!optimize 2

local Promise = require("../../PromiseTyped")
type Promise<T> = Promise.TypedPromise<T>
local PromiseOrValueModule = require("../jsutils/PromiseOrValue")
type PromiseOrValue<T> = PromiseOrValueModule.PromiseOrValue<T>

local function coerceToPromise<T>(value: PromiseOrValue<T>): Promise<T>
	if Promise.Is(value) then
		return value :: Promise<T>
	else
		return Promise.Resolve(value) :: Promise<T>
	end
end

return {
	coerceToPromise = coerceToPromise;
}
