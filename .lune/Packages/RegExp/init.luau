--!native
--!optimize 2
--!strict

local RegEx = require("./RegEx")
type Array<T> = {T}

type RegExpExecArray = {[number]: string, index: number?, input: string?, n: number}

export type RegExp = {
	exec: (self: RegExp, input: string) -> RegExpExecArray?,
	test: (self: RegExp, input: string) -> boolean,
}

local RegExp = {}
local RegExpMetatable = {
	__index = RegExp;
	__tostring = function(self)
		return tostring(self._innerRegEx)
	end;
}

function RegExp:exec(str: string): RegExpExecArray?
	local match = self._innerRegEx:match(str)
	if not match then
		return nil
	end

	local index = match:span()
	local groups: {[number]: string, n: number} = match:grouparr()

	local matches = {groups[0]}
	for i = 1, groups.n do
		matches[i + 1] = groups[i]
	end

	matches.n = groups.n + 1
	matches.index = index
	matches.input = str
	return matches
end

function RegExp:test(str: string): boolean
	return self:exec(str) ~= nil
end

local function new(_, pattern: RegExp | string, flags: string?)
	flags = flags or ""
	local innerRegEx = RegEx.new(pattern, flags)

	return setmetatable({
		source = pattern;
		ignoreCase = string.find(flags :: string, "i") ~= nil;
		global = string.find(flags :: string, "g") ~= nil;
		multiline = string.find(flags :: string, "m") ~= nil;
		_innerRegEx = innerRegEx;
	}, RegExpMetatable)
end

-- FIXME: Capture this as a local variable before returning, else a luau bug
-- prevents __call from being understood: https://jira.rbx.com/browse/CLI-40294
local interface = (setmetatable(RegExp, {
	__call = new;
}) :: any) :: typeof(setmetatable(
	{} :: typeof(RegExp),
	{} :: {
		__call: (_: any, pattern: RegExp | string, flags: string?) -> RegExp,
	}
))

return interface
