--!native
--!optimize 2
--!strict

local stdio = require("@lune/stdio")

local function GatherList(Prompt: string)
	local Array: {string} = {}
	local Length = 0

	while true do
		local Result = stdio.prompt("text", Prompt)
		if Result == "" then
			return Array
		end

		Length += 1
		Array[Length] = Result
	end
end

return GatherList
