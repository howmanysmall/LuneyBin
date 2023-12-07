--!native
--!optimize 2
--!strict

local function Concat(...)
	local Length = select("#", ...)
	if Length == 0 then
		return ""
	elseif Length == 1 then
		return tostring(...)
	elseif Length == 2 then
		local First, Second = ...
		return tostring(First) .. " " .. tostring(Second)
	elseif Length == 3 then
		local First, Second, Third = ...
		return tostring(First) .. " " .. tostring(Second) .. " " .. tostring(Third)
	else
		local Array = table.create(Length)
		for Index = 1, Length do
			Array[Index] = tostring(select(Index, ...))
		end

		return table.concat(Array, " ")
	end
end

local function CatchFactory(FunctionName: string, logFunction: nil | (...any) -> ())
	local TrueLogFunction: (...any) -> () = if logFunction then logFunction else warn
	local Traceback = debug.traceback(nil, 2)
	return function(...)
		TrueLogFunction(string.format("Error in function %*: %*\nTraceback: %*", FunctionName, Concat(...), Traceback))
	end
end

return CatchFactory
