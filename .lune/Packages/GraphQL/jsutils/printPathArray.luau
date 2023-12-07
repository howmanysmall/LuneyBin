--!native
--!optimize 2
--[[
 * Copyright (c) GraphQL Contributors
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
]]
-- ROBLOX upstream: https://github.com/graphql/graphql-js/blob/1951bce42092123e844763b6a8e985a8a3327511/src/jsutils/printPathArray.js
--[[
 * Build a string describing the path.
 ]]
local function printPathArray(path: {string | number}): string
	-- was a numeric loop
	local keys = table.clone(path)
	for i, key in path do
		keys[i] = type(key) == "number" and "[" .. tostring(key) .. "]" or "." .. key
	end

	return table.concat(keys)
end

return {
	printPathArray = printPathArray;
}
