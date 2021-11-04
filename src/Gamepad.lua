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
	Gamepad._Janitor = Janitor.new() 
	Gamepad.ThumbstickBegan = Signal.new(Gamepad._Janitor)
	Gamepad.ThumbstickChanged = Signal.new(Gamepad._Janitor)
	Gamepad.ThumbstickEnded = Signal.new(Gamepad._Janitor)
	Gamepad.InputBegan = Signal.new(Gamepad._Janitor)
	Gamepad.InputEnded = Signal.new(Gamepad._Janitor)
	
	local function InputBegan(input: InputObject, gameProcessed: boolean)
		
	end
	
	local function InputChanged(input: InputObject, gameProcessed: boolean)
		
	end
	
	local function InputEnded(input: InputObject)
		
	end
	
	Gamepad['Connections'] = {}
	Gamepad['Connections']['InputBegan'] = USER_INPUT_SERVICE.InputBegan:Connect(InputBegan)
	Gamepad['Connections']['InputChanged'] = USER_INPUT_SERVICE.InputChanged:Connect(InputChanged)
	Gamepad['Connections']['InputEnded'] = USER_INPUT_SERVICE.InputEnded:Connect(InputEnded)
	Gamepad['Connections']['Destroy'] = function()
		for i, conn in pairs(Gamepad['Connections'] ) do 
			if type(conn) ~= "function" and conn.Disconnect ~= nil then conn:Disconnect() end
			Gamepad['Connections'][i] = nil
		end

		Gamepad['Connections'] = nil
	end

	Gamepad._Janitor:Add(Gamepad.Connections)
end

function Gamepad:Destroy()
	SafeAssert(Gamepad.Enabled == true, "Gamepad isn't enabled")
	Gamepad.Enabled = false
end


---------------------------------------------------------------
return Gamepad