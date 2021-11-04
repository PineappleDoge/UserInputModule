script:WaitForChild("UserInputModule"):WaitForChild("Mouse")

local MouseModule = require(script.UserInputModule.Mouse)
local MobileModule = require(script.UserInputModule.Mobile)
local GamepadModule = require(script.UserInputModule.Gamepad)
local KeyboardModule = require(script.UserInputModule.Keyboard)
MouseModule:Init() 
KeyboardModule:Init()
KeyboardModule:Destroy()