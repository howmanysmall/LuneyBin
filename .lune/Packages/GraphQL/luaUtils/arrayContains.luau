--!native
--!optimize 2
local deepContains = require("./deepContains")
local deepEqual = require("./deepEqual")

return function(tbl, item, looseEquals)
	-- see if item exists in table
	for _, value in ipairs(tbl) do
		if looseEquals then
			if deepContains(value, item) then
				return true
			end
		else
			if deepEqual(value, item) then
				return true
			end
		end
	end

	return false
end
