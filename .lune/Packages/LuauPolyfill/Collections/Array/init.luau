--!native
--!optimize 2
--!strict
export type Array<T> = {T}

return table.freeze({
	concat = require("./concat");
	every = require("./every");
	filter = require("./filter");
	find = require("./find");
	findIndex = require("./findIndex");
	flat = require("./flat");
	flatMap = require("./flatMap");
	forEach = require("./forEach");
	from = require("./from");
	includes = require("./includes");
	indexOf = require("./indexOf");
	isArray = require("./isArray");
	join = require("./join");
	map = require("./map");
	reduce = require("./reduce");
	reverse = require("./reverse");
	shift = require("./shift");
	slice = require("./slice");
	some = require("./some");
	sort = require("./sort");
	splice = require("./splice");
	unshift = require("./unshift");
})
