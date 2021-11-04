--[[
---------------------------------------------------------------
-- PineappleDoge | Keyboard Input Module
-- Handles Keyboard-related inputs
-------------------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
--------------------------- START OF DOCUMENTATION ---------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
	Keyboard:Init()
		> Starts the module and all it's connections
	
	Keyboard:Destroy()
		> Cleans all module connections
		
	Keyboard:IsKeyDown(key)
		> Checks if the key is pressed
		> Return: IsKeyDown: boolean
		
	Keyboard:AreKeysDown(keys)
		> Checks if all keys in the array are pressed
		> Return: AreKeysDown: boolean
	
	Keyboard:GetPressedKeys()
		> Return: Held Keys: array
		
		
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
local KeyboardModule = nil 
task.spawn(function() -- task.spawn() so it doesn't yield the other stuff, we can check for existence latr
	local PlayerScripts = game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts")
	local KeyModule = PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"):WaitForChild("Keyboard")
	KeyboardModule = KeyModule
end)


---------------------------------------------------------------
-- Module Setup
local Keyboard = {
	InputStack = {}; -- We add inputs, enuff said
	Enabled = false;
}

local Keys = {}
local HeldKeys = {}
local KeysIndex = {}
local ReverseKeys = {}
local SupportedInputs = {
	Forward = true, Left = true, Backward = true, Right = true, Jump = true
}

for i, v in ipairs(Enum.KeyCode:GetEnumItems()) do
	Keys[v.Name] = v
	KeysIndex[v.Value] = v 
	ReverseKeys[v] = v.Name
end


---------------------------------------------------------------
-- Functions
local function SafeAssert(condition, msg)
	if condition == false then
		warn(msg)
	end
end

---

function Keyboard:Init()
	SafeAssert(Keyboard.Enabled == false, "Keyboard is already enabled")
	Keyboard.Enabled = true
	Keyboard._Janitor = Janitor.new() 
	Keyboard.InputBegan = Signal.new(Keyboard._Janitor)
	Keyboard.InputEnded = Signal.new(Keyboard._Janitor)
	Keyboard.InputHeld = Signal.new(Keyboard._Janitor)
	
	local function InputBegan(input: InputObject, gameProcessed: boolean)
		if gameProcessed then return end
		
		if (input.UserInputType == Enum.UserInputType.Keyboard and Keys[input.KeyCode.Name] ~= nil) then 
			Keyboard.InputBegan:Fire(input.KeyCode.Name)
			Keyboard.InputHeld:Fire(input.KeyCode.Name, "Began")
			HeldKeys[input.KeyCode.Name] = true 
		end
	end
	
	local function InputEnded(input: InputObject)
		if (input.UserInputType == Enum.UserInputType.Keyboard and Keys[input.KeyCode.Name] ~= nil) then 
			Keyboard.InputEnded:Fire(input.KeyCode.Name)
			Keyboard.InputHeld:Fire(input.KeyCode.Name, "Ended")
			HeldKeys[input.KeyCode.Name] = nil
		end
	end
	
	Keyboard['Connections'] = {}
	Keyboard['Connections']['InputBegan'] = USER_INPUT_SERVICE.InputBegan:Connect(InputBegan)
	Keyboard['Connections']['InputEnded'] = USER_INPUT_SERVICE.InputEnded:Connect(InputEnded)
	Keyboard['Connections']['Destroy'] = function()
		for i, conn in pairs(Keyboard['Connections'] ) do 
			if type(conn) ~= "function" and conn.Disconnect ~= nil then conn:Disconnect() end
			Keyboard['Connections'][i] = nil
		end
		
		Keyboard['Connections'] = nil
	end
	
	Keyboard._Janitor:Add(Keyboard.Connections)
end

function Keyboard:Destroy()
	SafeAssert(Keyboard.Enabled == true, "Keyboard isn't enabled")
	Keyboard._Janitor:Destroy()
	Keyboard.Enabled = false
end

function Keyboard:IsKeyDown(key: Enum.KeyCode | string): boolean
	if type(key) == "string" then 
		key = Keys[key]
	end
	
	if HeldKeys[key] ~= nil and HeldKeys[key] == true then 
		return true
	end
	
	return false 
end

function Keyboard:AreKeysDown(keys)
	for _, key in ipairs(keys) do
		if Keyboard:IsKeyDown(key) == false then
			return false 
		end
	end
	
	return true
end

function Keyboard:AreAnyDown(keys)
	for _, key in ipairs(keys) do
		if Keyboard:IsKeyDown(key) == true then
			return true 
		end
	end

	return false
end

function Keyboard:ChangeDefaultKeybind(inputMethod: string, key: Enum.KeyCode | string)
	if typeof(key) == Enum.KeyCode then 
		key = ReverseKeys[key]
	elseif type(key) == "string" then 
		-- verify 
		if Keys[key] == nil then 
			warn("Keyboard module received an invalid string for Keyboard:ChangeDefaultKeybind()")
			return false 
		end
	end
	
	
	if SupportedInputs[inputMethod] == nil then 
		warn(("inputMethod isn't a default keybind, you inputted %s, here's a list of supported keybinds"):format(inputMethod), SupportedInputs)
		return false
	end
	
	KeyboardModule:SetAttribute(inputMethod, string.upper(tostring(key))) 
	return true
end

function Keyboard:GetKeysPressed()
	return USER_INPUT_SERVICE:GetKeysPressed()
end


---------------------------------------------------------------
return Keyboard