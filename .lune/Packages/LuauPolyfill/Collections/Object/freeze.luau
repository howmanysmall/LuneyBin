--!native
--!optimize 2
--!strict
type Array<T> = {T}
type Object = {[string]: any}

return function<T>(t: T & (Object | Array<any>)): T
	-- Luau FIXME: model freeze better so it passes through the type constraint and doesn't erase
	return (table.freeze(t :: any) :: any) :: T
end
