--[[
---------------------------------------------------------------
-- PineappleDoge | UserInputModule
-- Handles Cross-Platform inputs
-------------------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
--------------------------- START OF DOCUMENTATION ---------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
	Mouse:Init()
		> Starts the module and all it's connections
	
	Mouse:Destroy()
		> Cleans all module connections
		
		
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
---------------------------- END OF DOCUMENTATION ----------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
]]
---------------------------------------------------------------
-- Services
local USER_INPUT_SERVICE = game:GetService("UserInputService")


---------------------------------------------------------------
-- Modules / Module Setup
local MouseModule = require(script.Mouse)
local MobileModule = require(script.Mobile)
local GamepadModule = require(script.Gamepad)
local KeyboardModule = require(script.Keyboard)

local UserInputModule = {
	Enabled = true;
	ModuleObjects = {
		Mouse = script.Mouse;
		Mobile = script.Mouse;
		Gamepad = script.Gamepad;
		Keyboard = script.Keyboard;
	};
	
	Modules = {
		Mouse = MouseModule;
		Mobile = MobileModule;
		Gamepad = GamepadModule;
		Keyboard = KeyboardModule;
	}
}


---------------------------------------------------------------
-- Functions
function UserInputModule:Init()
	self.Enabled = true; 
	
	for _, module in pairs(UserInputModule.Modules) do 
		if module.Init then module:Init() end -- Startup all modules
		
	end
end

function UserInputModule:GetMostRecentPlatform()
	
end


return UserInputModule
