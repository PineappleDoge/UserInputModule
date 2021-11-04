--[[
---------------------------------------------------------------
-- PineappleDoge | Mouse Input Module
-- Handles mouse-related inputs
-------------------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
--------------------------- START OF DOCUMENTATION ---------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
	Mouse:Init()
		> Starts the module and all it's connections
	
	Mouse:Destroy()
		> Cleans all module connections
		
	Mouse:GetMouseLocation(): Vector2
		> Return: A Vector2 containing the current mouse's X/Y 
	
	Mouse:VectorToWorldRaycast(Packet: Packet)
		> Return: The result of a raycast
		
	Mouse:BindFuncToInput(mouseInput: Enum.UserInputType | string, callback) 
		> Binds an input to a certain mouse input
		> Return: A table with a :Disconnect() method
		
		
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
local Mouse = {
	InputStack = {}; -- We add inputs, enuff said
	Enabled = false;
}

local MouseInputs = {
	MouseButton1 = Enum.UserInputType.MouseButton1,
	MouseButton2 = Enum.UserInputType.MouseButton2,
	MouseButton3 = Enum.UserInputType.MouseButton3,
	MouseMovement = Enum.UserInputType.MouseMovement,
	MouseWheel = Enum.UserInputType.MouseWheel
}

local HeldKeys = {}
local MouseInputsReversed = {}

for name, value in pairs(MouseInputs) do
	MouseInputsReversed[value] = name
end

type Packet = {
	XPos: number, 
	YPos: number,
	Depth: number?,
	Blacklist: {}?,
	RaycastParams: RaycastParams?, 
}


---------------------------------------------------------------
-- Functions
local function SafeAssert(condition, msg)
	if condition == false then
		warn(msg)
	end
end

---

function Mouse:Init()
	SafeAssert(Mouse.Enabled == false, "Mouse is already enabled")
	Mouse.Enabled = true
	Mouse._Janitor = Janitor.new()
	Mouse.InputBegan = Signal.new(Mouse._Janitor)
	Mouse.InputEnded = Signal.new(Mouse._Janitor)
	Mouse.InputHeld = Signal.new(Mouse._Janitor)
	Mouse.MouseMovementBegan = Signal.new(Mouse._Janitor)
	Mouse.MouseMovementEnded = Signal.new(Mouse._Janitor)
	Mouse.NewMouseLocation = Signal.new(Mouse._Janitor)
	
	local function InputBegan(input: InputObject, gameProcessed: boolean)
		if MouseInputs[input.UserInputType.Name] then 
			HeldKeys[input.UserInputType] = true
			Mouse.InputBegan:Fire(input.UserInputType.Name)
			Mouse.InputHeld:Fire(input.UserInputType.Name, "Began")
		end
		
		if input.UserInputType == Enum.UserInputType.MouseMovement then 
			Mouse.MouseMovementBegan:Fire(input.Position.X, input.Position.Y)
			Mouse.NewMouseLocation:Fire(input.Position.X, input.Position.Y)
		end
		
		if Mouse.InputStack[input.UserInputType] ~= nil then 
			for i = 1, #Mouse.InputStack[input.UserInputType] do 
				task.spawn(Mouse.InputStack[input.UserInputType][i].func)
			end
		end
	end
	
	local function InputEnded(input: InputObject, gameProcessed: boolean)
		if MouseInputs[input.UserInputType.Name] then 
			HeldKeys[input.UserInputType] = nil
			Mouse.InputEnded:Fire(input.UserInputType.Name)
			Mouse.InputHeld:Fire(input.UserInputType.Name, "Ended")
		end
		
		if input.UserInputType == Enum.UserInputType.MouseMovement then 
			Mouse.MouseMovementEnded:Fire(input.Position.X, input.Position.Y)
			Mouse.NewMouseLocation:Fire(input.Position.X, input.Position.Y)
		end
	end
	
	local function InputChanged(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseMovement then 
			Mouse.NewMouseLocation:Fire(input.Position.X, input.Position.Y)
		end
	end
	
	Mouse['Connections'] = {}
	Mouse['Connections']['InputBegan'] = USER_INPUT_SERVICE.InputBegan:Connect(InputBegan)
	Mouse['Connections']['InputChanged'] = USER_INPUT_SERVICE.InputChanged:Connect(InputChanged) 
	Mouse['Connections']['InputEnded'] = USER_INPUT_SERVICE.InputEnded:Connect(InputEnded)
	Mouse['Connections']['Destroy'] = function()
		for i, conn in pairs(Mouse['Connections'] ) do 
			if type(conn) ~= "function" and conn.Disconnect ~= nil then conn:Disconnect() end
			Mouse['Connections'][i] = nil
		end

		Mouse['Connections'] = nil
	end

	Mouse._Janitor:Add(Mouse.Connections)
end

function Mouse:Destroy()
	SafeAssert(Mouse.Enabled == false, "Mouse isn't enabled")
	Mouse._Janitor:Destroy()
	Mouse.Enabled = false
end

function Mouse:IsInputDown(mouseInput: Enum.UserInputType | string): boolean
	if type(mouseInput) == "string" then 
		mouseInput = MouseInputs[mouseInput]
	end
	
	if (HeldKeys[mouseInput] ~= nil and HeldKeys[mouseInput] == true) == true then 
		return true
	end
	
	return false
end

function Mouse:AreInputsDown(inputs): boolean
	for _, input in ipairs(inputs) do 
		if Mouse:IsInputDown(input) == false then 
			return false 
		end
	end
	
	return true
end

function Mouse:BindFuncToInput(mouseInput: Enum.UserInputType | string, callback) -- NOTE: INPUT BEGAN ONLY FUNCTIONS 
	assert(Mouse.Enabled == true, "Mouse module has not been enabled!")
	
	if type(mouseInput) == "string" then 
		mouseInput = MouseInputs[mouseInput]
	end
	
	if Mouse.InputStack[mouseInput] == nil then
		Mouse.InputStack[mouseInput] = {}
	end
	
	local ID = #Mouse.InputStack[mouseInput] + 1 
	local CallbackTable = {
		Disconnect = function()
			Mouse.InputStack[mouseInput][ID] = nil
			if #Mouse.InputStack[mouseInput] <= 0 then 
				Mouse.InputStack[mouseInput] = nil -- Table isn't needed anymore
				print("Emptied stack for table:", mouseInput)
			end
		end,
		
		func = callback;
	}
	
	CallbackTable.Destroy = CallbackTable.Destroy
	table.insert(Mouse.InputStack[mouseInput], ID, CallbackTable)
	print("Added an item:", Mouse.InputStack[mouseInput])
	return CallbackTable
end

function Mouse:GetMouseLocation(): Vector2
	return USER_INPUT_SERVICE:GetMouseLocation()
end

function Mouse:VectorToWorldRaycast(Packet: Packet)
	local Camera = workspace.CurrentCamera
	local UnitRay = Camera:ViewportPointToRay(Packet.XPos, Packet.YPos, 0)

	local RaycastDetails = RaycastParams.new()
	local RaycastBlacklist = Packet.Blacklist or {}
	RaycastDetails.FilterType = Enum.RaycastFilterType.Blacklist
	RaycastDetails.FilterDescendantsInstances = RaycastBlacklist
	
	return workspace:Raycast(UnitRay.Origin, UnitRay.Direction * (Packet.Depth or 1000), Packet.RaycastParams or RaycastDetails)
end


---------------------------------------------------------------
return Mouse