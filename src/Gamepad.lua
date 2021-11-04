--[[
---------------------------------------------------------------
-- PineappleDoge | Gamepad Input Module
-- Handles Gamepad-related inputs
-------------------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
--------------------------- START OF DOCUMENTATION ---------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
	Gamepad:Init()
		> Starts the module and all it's connections
	
	Gamepad:Destroy()
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
local Gamepad = {
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

function Gamepad:Init()
	SafeAssert(Gamepad.Enabled == false, "Gamepad is already enabled")
	Gamepad.Enabled = true
end

function Gamepad:Destroy()
	SafeAssert(Gamepad.Enabled == true, "Gamepad isn't enabled")
	Gamepad.Enabled = false
end


---------------------------------------------------------------
return Gamepad