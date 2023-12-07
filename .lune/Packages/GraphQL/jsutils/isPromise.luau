--!native
--!optimize 2
--[[
 * Copyright (c) GraphQL Contributors
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
]]
-- ROBLOX upstream: https://github.com/graphql/graphql-js/blob/1951bce42092123e844763b6a8e985a8a3327511/src/jsutils/isPromise.js
local Promise = require("../../Promise")

--[[
 * Returns true if the value acts like a Promise, i.e. has a "then" function,
 * otherwise returns false.
 ]]

return {
	isPromise = Promise.Is;
}
