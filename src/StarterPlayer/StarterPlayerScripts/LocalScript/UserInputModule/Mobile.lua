--[[
---------------------------------------------------------------
-- PineappleDoge | Mobile Input Module
-- Handles Mobile-related inputs
-------------------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
--------------------------- START OF DOCUMENTATION ---------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
	Mobile:Init()
		> Starts the module and all it's connections
	
	Mobile:Destroy()
		> Cleans all module connections
		
		
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
---------------------------- END OF DOCUMENTATION ----------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
]]
---------------------------------------------------------------
-- Services
local USER_INPUT_SERVICE = game:GetService("UserInputService")


---------------------------------------------------------------
-- Modules
local Janitor = require(script.Parent.Modules.Janitor)
local Signal = require(script.Parent.Modules.Signal)


---------------------------------------------------------------
-- Module Setup
local Mobile = {
	InputStack = {}; -- We add inputs, enuff said
	Enabled = false;
}

local Keys = {}


---------------------------------------------------------------
-- Functions
local function SafeAssert(condition, msg)
	if condition == false then
		warn(msg)
	end
end

---

function Mobile:Init()
	SafeAssert(Mobile.Enabled == false, "Mobile is already enabled")
	Mobile.Enabled = true
end

function Mobile:Destroy()
	SafeAssert(Mobile.Enabled == true, "Mobile isn't enabled")
	Mobile.Enabled = false
end


---------------------------------------------------------------
return Mobile