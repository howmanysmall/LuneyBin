--!native
--!optimize 2
--!strict

local Boolean = require("./Boolean")
local Collections = require("./Collections")
local Console = require("./Console")
local Math = require("./Math")
local Number = require("./Number")
local String = require("./String")
local Symbol = require("../Symbol")
local Timers = require("./Timers")
local types = require("./ES7Types")

local AssertionError = require("./AssertionError")
local Error = require("./Error")
local PromiseModule = require("./Promise")
local extends = require("./extends")
local instanceof = require("./InstanceOf")

export type Array<T> = types.Array<T>
export type AssertionError = AssertionError.AssertionError
export type Error = Error.Error
export type Map<T, V> = types.Map<T, V>
export type Object = types.Object

export type PromiseLike<T> = PromiseModule.PromiseLike<T>
export type Promise<T> = PromiseModule.Promise<T>

export type Set<T> = types.Set<T>
export type Symbol = Symbol.Symbol
export type Timeout = Timers.Timeout
export type Interval = Timers.Interval
export type WeakMap<T, V> = Collections.WeakMap<T, V>

return table.freeze({
	Array = Collections.Array;
	AssertionError = AssertionError;
	Boolean = Boolean;
	console = Console;
	Error = Error;
	extends = extends;
	instanceof = instanceof;
	Math = Math;
	Number = Number;
	Object = Collections.Object;
	Map = Collections.Map;
	coerceToMap = Collections.coerceToMap;
	coerceToTable = Collections.coerceToTable;
	Set = Collections.Set;
	WeakMap = Collections.WeakMap;
	String = String;
	Symbol = Symbol;
	setTimeout = Timers.setTimeout;
	clearTimeout = Timers.clearTimeout;
	setInterval = Timers.setInterval;
	clearInterval = Timers.clearInterval;
	util = {
		inspect = Collections.inspect;
	};
})
