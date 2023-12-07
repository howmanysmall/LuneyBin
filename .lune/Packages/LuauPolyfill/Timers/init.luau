--!native
--!optimize 2
--!strict
local Collections = require("../Collections")
local makeIntervalImpl = require("./makeIntervalImpl")
local makeTimerImpl = require("./makeTimerImpl")
local task = require("@lune/task")

export type Timeout = makeTimerImpl.Timeout
export type Interval = makeIntervalImpl.Interval

return Collections.Object.assign({}, makeTimerImpl(task.delay), makeIntervalImpl(task.delay))
