--!native
--!optimize 2
--!strict
type Array<T> = {T}
type PredicateFunction<T> = (value: T, index: number, array: Array<T>) -> boolean

return function<T>(array: Array<T>, predicate: PredicateFunction<T>): T?
	for i = 1, #array do
		local element = array[i]
		if predicate(element, i, array) then
			return element
		end
	end

	return nil
end
