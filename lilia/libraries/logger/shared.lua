﻿--[[--
Logging helper functions.

Predefined flags:
	FLAG_NORMAL
	FLAG_SUCCESS
	FLAG_WARNING
	FLAG_DANGER
	FLAG_SERVER
	FLAG_DEV
]]
-- @libraries lia.log
lia.log = lia.log or {}
FLAG_NORMAL = 0
FLAG_SUCCESS = 1
FLAG_WARNING = 2
FLAG_DANGER = 3
FLAG_SERVER = 4
FLAG_DEV = 5
lia.log.color = {
    [FLAG_NORMAL] = Color(200, 200, 200),
    [FLAG_SUCCESS] = Color(50, 200, 50),
    [FLAG_WARNING] = Color(255, 255, 0),
    [FLAG_DANGER] = Color(255, 50, 50),
    [FLAG_SERVER] = Color(200, 200, 220),
    [FLAG_DEV] = Color(200, 200, 220),
}
