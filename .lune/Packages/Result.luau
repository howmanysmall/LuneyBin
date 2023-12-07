--!native
--!optimize 2
--!strict

-- This is taken from @rbxts/rust-classes

local Result = {}
Result.ClassName = "Result"
Result.__index = Result

local function Constructor<T, E>(OkValue: T?, ErrorValue: E?)
	return setmetatable({
		IsOk = OkValue ~= nil;
		IsError = ErrorValue ~= nil;

		OkValue = OkValue;
		ErrorValue = ErrorValue;
	}, Result)
end

function Result.Ok<T, E>(Value: T, _E: E): Result<T, E>
	local self: any = Constructor(Value, nil)
	return self
end

function Result.Error<T, E>(Value: E, _T: T): Result<T, E>
	local self: any = Constructor(nil, Value)
	return self
end

function Result.Contains<T, E>(self: Class<T, E>, Value: T)
	return self.OkValue == Value
end

function Result.ContainsError<T, E>(self: Class<T, E>, Value: E)
	return self.ErrorValue == Value
end

function Result.Map<T, E>(self: Class<T, E>, Function: (Value: T) -> T)
	return if self.IsOk
		then Result.Ok(Function(self.OkValue :: T), self.ErrorValue :: E)
		else Result.Error(self.ErrorValue, self.OkValue :: T)
end

function Result.MapOr<T, E>(self: Class<T, E>, Default: Result<T, E>, Function: (Value: T) -> Result<T, E>)
	return if self.IsOk then Function(self.OkValue :: T) else Default
end

function Result.MapOrElse<T, E>(self: Class<T, E>, Default: (Error: E) -> Result<T, E>, Function: (Value: T) -> Result<T, E>)
	return if self.IsOk then Function(self.OkValue :: T) else Default(self.ErrorValue :: E)
end

function Result.MapError<T, E>(self: Class<T, E>, Function: (Error: E) -> Result<T, E>)
	return if self.IsError
		then Result.Error(Function(self.ErrorValue :: E), self.OkValue :: T)
		else Result.Ok(self.OkValue :: T, self.ErrorValue :: E)
end

function Result.Expect<T, E>(self: Class<T, E>, Message: string): T
	if self.IsOk then
		return self.OkValue :: T
	else
		error(Message)
	end
end

function Result.Unwrap<T, E>(self: Class<T, E>): T
	return self:Expect("called `Result:Unwrap()` on an `Err` value: " .. tostring(self.ErrorValue))
end

function Result.UnwrapOr<T, E>(self: Class<T, E>, Default: T): T
	return if self.IsOk then self.OkValue :: T else Default
end

function Result.UnwrapOrElse<T, E>(self: Class<T, E>, Function: (Error: E) -> T): T
	return if self.IsOk then self.OkValue :: T else Function(self.ErrorValue :: E)
end

function Result.ExpectError<T, E>(self: Class<T, E>, Message: string): E
	if self.IsError then
		return self.ErrorValue :: E
	else
		error(Message)
	end
end

function Result.Match<T, E, U>(self: Class<T, E>, IfOk: (Value: T) -> U, IfError: (Error: E) -> U): U
	if self.IsOk then
		return IfOk(self.OkValue :: T)
	else
		return IfError(self.ErrorValue :: E)
	end
end

local function ToStringOk<T>(Value: T)
	return `Result.Ok({Value})`
end

local function ToStringError<E>(Value: E)
	return `Result.Error({Value})`
end

function Result.__eq<T, E>(self: Class<T, E>, Other: Class<T, E>)
	return self:Match(function(Value)
		return Other:Contains(Value)
	end, function(Error)
		return Other:ContainsError(Error)
	end)
end

function Result.__tostring<T, E>(self: Class<T, E>)
	return self:Match(ToStringOk, ToStringError)
end

export type Class<T, E> = typeof(Constructor((1 :: any) :: T, (1 :: any) :: E))
export type Result<T, E> = {
	IsOk: boolean,
	IsError: boolean,

	Contains: (self: Result<T, E>, Value: T) -> boolean,
	ContainsError: (self: Result<T, E>, Value: E) -> boolean,

	Map: (self: Result<T, E>, Function: (Value: T) -> T) -> Result<T, E>,
	MapOr: (self: Result<T, E>, Default: Result<T, E>, Function: (Value: T) -> Result<T, E>) -> Result<T, E>,
	MapOrElse: (
		self: Result<T, E>,
		Default: (Error: E) -> Result<T, E>,
		Function: (Value: T) -> Result<T, E>
	) -> Result<T, E>,
	MapError: (self: Result<T, E>, Function: (Error: E) -> Result<T, E>) -> Result<T, E>,

	Expect: (self: Result<T, E>, Message: string) -> T,
	Unwrap: (self: Result<T, E>) -> T,
	UnwrapOr: (self: Result<T, E>, Default: T) -> T,
	UnwrapOrElse: (self: Result<T, E>, Function: (Error: E) -> T) -> T,

	ExpectError: (self: Result<T, E>, Message: string) -> E,
	UnwrapError: (self: Result<T, E>) -> E,

	Match: <U>(self: Result<T, E>, IfOk: (Value: T) -> U, IfError: (Error: E) -> U) -> U,
}

table.freeze(Result)
return Result
