--!native
--!optimize 2
-- ROBLOX deviation: no distinction between undefined and null in Lua so we need to go around this with custom NULL like constant
local NULL = (
	setmetatable({
		__NULL_IDENTIFIER__ = "__GRAPHQL_NULL_OBJECT__";
	}, {
		__metatable = false;
		-- ROBLOX deviation: mimic behavior of Object.preventExtension
		__newindex = function(_, key)
			local message = string.format("%q (%*) is not a valid member of %*", tostring(key), typeof(key), "null")
			error(message, 2)
		end;
		__tostring = function()
			return "null"
		end;
	})
)
export type NULL = typeof(NULL)
return NULL
