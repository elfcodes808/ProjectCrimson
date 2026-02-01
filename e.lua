-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local BallsFolder = Workspace:WaitForChild("Balls", 10)
local Mouse = LocalPlayer:GetMouse()
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ESP Settings
local ESPSettings = {
BallESP = false,
StrikeZoneESP = false,
ShowDistance = true,
ShowVelocity = true,
ShowTracers = false,
HighlightBalls = true,
BoxESP = true,
Color = Color3.fromRGB(100, 150, 255),
TracerColor = Color3.fromRGB(0, 255, 0),
StrikeZoneColor = Color3.fromRGB(0, 255, 255),
Transparency = 0.3,
TextSize = 14
}

-- Auto Aim Settings
local AutoAimSettings = {
Enabled = false,
Smoothness = 0.3,
PredictMovement = true,
PredictionMultiplier = 1.0,
TargetPart = "PitchedBall",
FOV = 500,
ShowFOV = false,
FOVColor = Color3.fromRGB(255, 255, 255),
LockOnKey = Enum.KeyCode.Q,
ToggleMode = false,
AutoHit = false,
HitDistance = 12,
SwingTiming = 0.15,
BallCheck = true,
LegitMode = false,
LegitSmooth = 0.25,
SilentHit = false,
TrackInWindup = true,
ShowBallType = true
}

-- ESP Storage
local ESPObjects = {}
local Connections = {}
local StrikeZoneESP = {}
local FOVCircle = nil
local IsLockedOn = false
local CurrentTarget = nil
local LastSwingTime = 0
local SwingCooldown = 0.5
local LastAimPosition = nil
local WindupTarget = nil
local BallTypeIndicator = nil

-- Create Rayfield Window
local Window = Rayfield:CreateWindow({
Name = "silent.fr",
LoadingTitle = "silent.fr Loading",
LoadingSubtitle = "by Silent.fr",
ConfigurationSaving = {
Enabled = true,
FolderName = "SilentFR_Config",
FileName = "Config"
},
Discord = {
Enabled = false,
Invite = "noinvite",
RememberJoins = true
},
KeySystem = false
})

-- Create Tabs
local MainTab = Window:CreateTab("Ball ESP", 4483362458)
local AutoAimTab = Window:CreateTab("Silent Aim", 4483362458)
local StrikeZoneTab = Window:CreateTab("Strike Zone", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)
local InfoTab = Window:CreateTab("Info", 4483362458)

-- ============================================
-- BALL ESP TAB
-- ============================================

local BallESPToggle = MainTab:CreateToggle({
Name = "Enable Ball ESP",
CurrentValue = false,
Flag = "BallESPToggle",
Callback = function(Value)
ESPSettings.BallESP = Value
if not Value then
ClearAllBallESP()
end
end
})

local HighlightToggle = MainTab:CreateToggle({
Name = "Highlight Balls",
CurrentValue = true,
Flag = "HighlightToggle",
Callback = function(Value)
ESPSettings.HighlightBalls = Value
end
})

local BoxToggle = MainTab:CreateToggle({
Name = "Box ESP (Sphere)",
CurrentValue = true,
Flag = "BoxToggle",
Callback = function(Value)
ESPSettings.BoxESP = Value
end
})

local DistanceToggle = MainTab:CreateToggle({
Name = "Show Distance",
CurrentValue = true,
Flag = "DistanceToggle",
Callback = function(Value)
ESPSettings.ShowDistance = Value
end
})

local VelocityToggle = MainTab:CreateToggle({
Name = "Show Velocity",
CurrentValue = true,
Flag = "VelocityToggle",
Callback = function(Value)
ESPSettings.ShowVelocity = Value
end
})

local TracerToggle = MainTab:CreateToggle({
Name = "Show Tracers",
CurrentValue = false,
Flag = "TracerToggle",
Callback = function(Value)
ESPSettings.ShowTracers = Value
end
})

-- ============================================
-- SILENT AIM TAB
-- ============================================

local AutoAimToggle = AutoAimTab:CreateToggle({
Name = "Enable Silent Aim",
CurrentValue = false,
Flag = "AutoAimToggle",
Callback = function(Value)
AutoAimSettings.Enabled = Value
if not Value then
IsLockedOn = false
CurrentTarget = nil
LastAimPosition = nil
end
end
})

AutoAimTab:CreateSection("Aim Mode")

local LegitModeToggle = AutoAimTab:CreateToggle({
Name = "Legit Mode (Smooth Aim)",
CurrentValue = false,
Flag = "LegitMode",
Callback = function(Value)
AutoAimSettings.LegitMode = Value
end
})

local LegitSmoothSlider = AutoAimTab:CreateSlider({
Name = "Legit Smoothness",
Range = {0.1, 1},
Increment = 0.05,
CurrentValue = 0.25,
Flag = "LegitSmooth",
Callback = function(Value)
AutoAimSettings.LegitSmooth = Value
end
})

AutoAimTab:CreateSection("Silent Aim moves your MOUSE to the ball!")

local ToggleModeToggle = AutoAimTab:CreateToggle({
Name = "Toggle Mode (Press to Lock/Unlock)",
CurrentValue = false,
Flag = "ToggleMode",
Callback = function(Value)
AutoAimSettings.ToggleMode = Value
end
})

local PredictToggle = AutoAimTab:CreateToggle({
Name = "Predict Ball Movement",
CurrentValue = true,
Flag = "PredictToggle",
Callback = function(Value)
AutoAimSettings.PredictMovement = Value
end
})

local SmoothnessSlider = AutoAimTab:CreateSlider({
Name = "Aim Smoothness",
Range = {0.1, 1},
Increment = 0.05,
CurrentValue = 0.3,
Flag = "Smoothness",
Callback = function(Value)
AutoAimSettings.Smoothness = Value
end
})

local PredictionSlider = AutoAimTab:CreateSlider({
Name = "Prediction Strength",
Range = {0.5, 3},
Increment = 0.1,
CurrentValue = 1.0,
Flag = "Prediction",
Callback = function(Value)
AutoAimSettings.PredictionMultiplier = Value
end
})

local FOVSlider = AutoAimTab:CreateSlider({
Name = "FOV Radius",
Range = {50, 1000},
Increment = 10,
CurrentValue = 500,
Flag = "FOV",
Callback = function(Value)
AutoAimSettings.FOV = Value
if FOVCircle then
FOVCircle.Radius = Value
end
end
})

local ShowFOVToggle = AutoAimTab:CreateToggle({
Name = "Show FOV Circle",
CurrentValue = false,
Flag = "ShowFOV",
Callback = function(Value)
AutoAimSettings.ShowFOV = Value
if FOVCircle then
FOVCircle.Visible = Value
end
end
})

local KeybindInput = AutoAimTab:CreateKeybind({
Name = "Lock-On Key",
CurrentKeybind = "Q",
HoldToInteract = false,
Flag = "LockKey",
Callback = function(Key)
AutoAimSettings.LockOnKey = Key
end
})

AutoAimTab:CreateSection("Auto Hit Settings")

local TrackWindupToggle = AutoAimTab:CreateToggle({
Name = "Track Ball in Windup",
CurrentValue = true,
Flag = "TrackWindup",
Callback = function(Value)
AutoAimSettings.TrackInWindup = Value
end
})

local ShowBallTypeToggle = AutoAimTab:CreateToggle({
Name = "Show Ball/Strike Indicator",
CurrentValue = true,
Flag = "ShowBallType",
Callback = function(Value)
AutoAimSettings.ShowBallType = Value
end
})

local AutoHitToggle = AutoAimTab:CreateToggle({
Name = "Enable Auto Hit",
CurrentValue = false,
Flag = "AutoHit",
Callback = function(Value)
AutoAimSettings.AutoHit = Value
end
})

local SilentHitToggle = AutoAimTab:CreateToggle({
Name = "Silent Hit (Hit Without PCI)",
CurrentValue = false,
Flag = "SilentHit",
Callback = function(Value)
AutoAimSettings.SilentHit = Value
end
})

local BallCheckToggle = AutoAimTab:CreateToggle({
Name = "Ball Check (Don't Swing at Balls)",
CurrentValue = true,
Flag = "BallCheck",
Callback = function(Value)
AutoAimSettings.BallCheck = Value
end
})

local HitDistanceSlider = AutoAimTab:CreateSlider({
Name = "Auto Hit Distance",
Range = {5, 30},
Increment = 1,
CurrentValue = 12,
Flag = "HitDistance",
Callback = function(Value)
AutoAimSettings.HitDistance = Value
end
})

local SwingTimingSlider = AutoAimTab:CreateSlider({
Name = "Swing Timing Adjustment",
Range = {0, 0.5},
Increment = 0.01,
CurrentValue = 0.15,
Flag = "SwingTiming",
Callback = function(Value)
AutoAimSettings.SwingTiming = Value
end
})

AutoAimTab:CreateParagraph({
Title = "Swing Timing Help",
Content = "Adjust timing to hit perfectly\n0.15 = Default (recommended)\nLower = Swing earlier | Higher = Swing later"
})

-- ============================================
-- MISC TAB
-- ============================================

MiscTab:CreateSection("Pitcher Features")

local InfStaminaToggle = MiscTab:CreateToggle({
Name = "Infinite Stamina (Pitcher)",
CurrentValue = false,
Flag = "InfStamina",
Callback = function(Value)
if Value then
task.spawn(function()
while Value and wait(0.1) do
pcall(function()
local staminaBar = LocalPlayer.PlayerGui:FindFirstChild("Carnavas")
if staminaBar then
staminaBar = staminaBar:FindFirstChild("Pitching")
if staminaBar then
staminaBar = staminaBar:FindFirstChild("Main")
if staminaBar then
staminaBar = staminaBar:FindFirstChild("Stamina")
if staminaBar then
staminaBar = staminaBar:FindFirstChild("Inset")
if staminaBar then
staminaBar = staminaBar:FindFirstChild("Bar")
if staminaBar then
staminaBar.Size = UDim2.new(1, -10, 1, -10)
end
end
end
end
end
end
end)
end
end)
end
end
})

MiscTab:CreateParagraph({
Title = "Infinite Stamina Info",
Content = "Keeps your stamina bar full when pitching. Enable before stepping on the mound."
})

-- ============================================
-- STRIKE ZONE ESP TAB
-- ============================================

local StrikeZoneToggle = StrikeZoneTab:CreateToggle({
Name = "Enable Strike Zone ESP",
CurrentValue = false,
Flag = "StrikeZoneESP",
Callback = function(Value)
ESPSettings.StrikeZoneESP = Value
if not Value then
RemoveStrikeZoneESP()
end
end
})

StrikeZoneTab:CreateSection("Strike Zone Info")

StrikeZoneTab:CreateParagraph({
Title = "What is Strike Zone ESP?",
Content = "Highlights the strike zone in 3D world space. Shows you exactly where strikes will be called in the actual game world."
})

StrikeZoneTab:CreateButton({
Name = "Manually Refresh Strike Zone",
Callback = function()
RemoveStrikeZoneESP()
if ESPSettings.StrikeZoneESP then
CreateStrikeZoneESP()
end
end
})

-- ============================================
-- SETTINGS TAB
-- ============================================

local BallColorPicker = SettingsTab:CreateColorPicker({
Name = "Ball ESP Color",
Color = Color3.fromRGB(100, 150, 255),
Flag = "BallColor",
Callback = function(Value)
ESPSettings.Color = Value
UpdateAllESPColors()
end
})

local TracerColorPicker = SettingsTab:CreateColorPicker({
Name = "Tracer Color",
Color = Color3.fromRGB(0, 255, 0),
Flag = "TracerColor",
Callback = function(Value)
ESPSettings.TracerColor = Value
end
})

local StrikeZoneColorPicker = SettingsTab:CreateColorPicker({
Name = "Strike Zone Color",
Color = Color3.fromRGB(0, 255, 255),
Flag = "StrikeZoneColor",
Callback = function(Value)
ESPSettings.StrikeZoneColor = Value
UpdateStrikeZoneColor()
end
})

local FOVColorPicker = SettingsTab:CreateColorPicker({
Name = "FOV Circle Color",
Color = Color3.fromRGB(255, 255, 255),
Flag = "FOVColor",
Callback = function(Value)
AutoAimSettings.FOVColor = Value
if FOVCircle then
FOVCircle.Color = Value
end
end
})

local TransparencySlider = SettingsTab:CreateSlider({
Name = "ESP Transparency",
Range = {0, 1},
Increment = 0.1,
CurrentValue = 0.3,
Flag = "ESPTransparency",
Callback = function(Value)
ESPSettings.Transparency = Value
UpdateAllESPTransparency()
end
})

local TextSizeSlider = SettingsTab:CreateSlider({
Name = "Text Size",
Range = {10, 30},
Increment = 1,
CurrentValue = 14,
Flag = "TextSize",
Callback = function(Value)
ESPSettings.TextSize = Value
end
})

-- ============================================
-- ESP FUNCTIONS
-- ============================================

function CreateBallESP(ball)
if ESPObjects[ball] then return end

local ESPContainer = {
Ball = ball,
Highlight = nil,
BillboardGui = nil,
Box = nil,
Tracer = nil
}

if ESPSettings.HighlightBalls then
local highlight = Instance.new("Highlight")
highlight.Name = "BallHighlight"
highlight.Adornee = ball
highlight.FillColor = ESPSettings.Color
highlight.OutlineColor = ESPSettings.Color
highlight.FillTransparency = ESPSettings.Transparency
highlight.OutlineTransparency = 0
highlight.Parent = ball
ESPContainer.Highlight = highlight
end

local billboard = Instance.new("BillboardGui")
billboard.Name = "BallESP"
billboard.Adornee = ball
billboard.Size = UDim2.new(0, 200, 0, 100)
billboard.StudsOffset = Vector3.new(0, 2, 0)
billboard.AlwaysOnTop = true
billboard.Parent = ball

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = ESPSettings.Color
textLabel.TextStrokeTransparency = 0.5
textLabel.TextSize = ESPSettings.TextSize
textLabel.Font = Enum.Font.GothamBold
textLabel.Parent = billboard

ESPContainer.BillboardGui = billboard
ESPContainer.TextLabel = textLabel

if ESPSettings.BoxESP then
local box = Instance.new("SphereHandleAdornment")
box.Name = "BallBox"
box.Adornee = ball
box.Radius = ball.Size.X / 2
box.Color3 = ESPSettings.Color
box.Transparency = ESPSettings.Transparency
box.AlwaysOnTop = true
box.ZIndex = 1
box.Parent = ball
ESPContainer.Box = box
end

ESPObjects[ball] = ESPContainer
end

function UpdateBallESP(ball, espData)
if not ball or not ball.Parent or not espData then return end

local distance = (ball.Position - Camera.CFrame.Position).Magnitude
local velocity = ball.AssemblyLinearVelocity.Magnitude

local text = ball.Name .. "\n"

if ESPSettings.ShowDistance then
text = text .. string.format("Distance: %.1f studs\n", distance)
end

if ESPSettings.ShowVelocity then
text = text .. string.format("Velocity: %.1f\n", velocity)
end

if ball:GetAttribute("MPH") then
text = text .. string.format("MPH: %d\n", ball:GetAttribute("MPH"))
end

if ball:GetAttribute("Type") then
text = text .. string.format("Type: %s", ball:GetAttribute("Type"))
end

if espData.TextLabel then
espData.TextLabel.Text = text
espData.TextLabel.TextColor3 = ESPSettings.Color
espData.TextLabel.TextSize = ESPSettings.TextSize
end

if espData.Highlight then
espData.Highlight.FillColor = ESPSettings.Color
espData.Highlight.OutlineColor = ESPSettings.Color
espData.Highlight.FillTransparency = ESPSettings.Transparency
end

if espData.Box then
espData.Box.Color3 = ESPSettings.Color
espData.Box.Transparency = ESPSettings.Transparency
espData.Box.Radius = ball.Size.X / 2
end
end

function RemoveBallESP(ball)
if ESPObjects[ball] then
local espData = ESPObjects[ball]

if espData.Highlight then espData.Highlight:Destroy() end
if espData.BillboardGui then espData.BillboardGui:Destroy() end
if espData.Box then espData.Box:Destroy() end
if espData.Tracer then espData.Tracer:Destroy() end

ESPObjects[ball] = nil
end
end

function ClearAllBallESP()
for ball, espData in pairs(ESPObjects) do
RemoveBallESP(ball)
end
ESPObjects = {}
end

function UpdateAllESPColors()
for ball, espData in pairs(ESPObjects) do
if espData.Highlight then
espData.Highlight.FillColor = ESPSettings.Color
espData.Highlight.OutlineColor = ESPSettings.Color
end
if espData.Box then
espData.Box.Color3 = ESPSettings.Color
end
if espData.TextLabel then
espData.TextLabel.TextColor3 = ESPSettings.Color
end
end
end

function UpdateAllESPTransparency()
for ball, espData in pairs(ESPObjects) do
if espData.Highlight then
espData.Highlight.FillTransparency = ESPSettings.Transparency
end
if espData.Box then
espData.Box.Transparency = ESPSettings.Transparency
end
end
end

-- ============================================
-- STRIKE ZONE ESP FUNCTIONS
-- ============================================

function CreateStrikeZoneESP()
RemoveStrikeZoneESP()

local strikeZone = Workspace:FindFirstChild("Carnavas")
if strikeZone then
strikeZone = strikeZone:FindFirstChild("Batting")
if strikeZone then
strikeZone = strikeZone:FindFirstChild("StrikeZone")
end
end

if not strikeZone then
strikeZone = Workspace:FindFirstChild("StrikeZone", true)
end

if not strikeZone then
Rayfield:Notify({
Title = "Strike Zone Not Found",
Content = "StrikeZone not found in Workspace. Make sure you're batting!",
Duration = 5,
Image = 4483362458
})
return
end

local highlight = Instance.new("SelectionBox")
highlight.Name = "StrikeZoneHighlight"
highlight.Adornee = strikeZone
highlight.LineThickness = 0.05
highlight.Color3 = ESPSettings.StrikeZoneColor
highlight.SurfaceTransparency = 1
highlight.Parent = strikeZone

StrikeZoneESP = {
Zone = strikeZone,
Highlight = highlight
}

Rayfield:Notify({
Title = "Strike Zone ESP",
Content = "Strike Zone ESP enabled successfully!",
Duration = 3,
Image = 4483362458
})
end

function RemoveStrikeZoneESP()
if StrikeZoneESP.Highlight then
StrikeZoneESP.Highlight:Destroy()
end
StrikeZoneESP = {}
end

function UpdateStrikeZoneColor()
if StrikeZoneESP.Highlight then
StrikeZoneESP.Highlight.Color3 = ESPSettings.StrikeZoneColor
end
end

-- ============================================
-- IMPROVED BALL CHECK FUNCTION
-- ============================================

function IsBallInStrikeZone(ballPosition)
local strikeZone = _G.StrikeZone

if not strikeZone then
local carnavas = Workspace:FindFirstChild("Carnavas")
if carnavas then
local batting = carnavas:FindFirstChild("Batting")
if batting then
strikeZone = batting:FindFirstChild("StrikeZone")
if strikeZone then
_G.StrikeZone = strikeZone
end
end
end
end

if not strikeZone then
strikeZone = Workspace:FindFirstChild("StrikeZone", true)
if strikeZone then
_G.StrikeZone = strikeZone
end
end

if not strikeZone or not strikeZone.Parent then
return false
end

local strikeZonePos = strikeZone.Position
local strikeZoneSize = strikeZone.Size

-- Use tighter boundaries - exactly match strike zone with NO buffer
local minX = strikeZonePos.X - (strikeZoneSize.X / 2)
local maxX = strikeZonePos.X + (strikeZoneSize.X / 2)
local minY = strikeZonePos.Y - (strikeZoneSize.Y / 2)
local maxY = strikeZonePos.Y + (strikeZoneSize.Y / 2)

-- Strict check - ball must be fully inside zone
return ballPosition.X > minX and ballPosition.X < maxX and
ballPosition.Y > minY and ballPosition.Y < maxY
end

-- ============================================
-- BALL/STRIKE INDICATOR
-- ============================================

function CreateBallTypeIndicator()
if BallTypeIndicator then return end

local indicator = Instance.new("ScreenGui")
indicator.Name = "BallTypeIndicator"
indicator.ResetOnSpawn = false
indicator.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 60)
frame.Position = UDim2.new(0.5, -100, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.3
frame.Parent = indicator

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.2, 0)
corner.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.TextSize = 24
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Text = ""
label.Parent = frame

indicator.Parent = LocalPlayer.PlayerGui
BallTypeIndicator = {Gui = indicator, Label = label, Frame = frame}
end

function UpdateBallTypeIndicator(isBall)
if not AutoAimSettings.ShowBallType then
if BallTypeIndicator then
BallTypeIndicator.Gui.Enabled = false
end
return
end

if not BallTypeIndicator then
CreateBallTypeIndicator()
end

BallTypeIndicator.Gui.Enabled = true

if isBall == nil then
BallTypeIndicator.Label.Text = "WAITING..."
BallTypeIndicator.Frame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
elseif isBall then
BallTypeIndicator.Label.Text = "⚾ BALL"
BallTypeIndicator.Frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
else
BallTypeIndicator.Label.Text = "✓ STRIKE"
BallTypeIndicator.Frame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
end
end

-- ============================================
-- SILENT AIM FUNCTIONS (NO SHAKE FIX)
-- ============================================

function CreateFOVCircle()
if FOVCircle then return end

local circle = Drawing.new("Circle")
circle.Thickness = 2
circle.NumSides = 64
circle.Radius = AutoAimSettings.FOV
circle.Color = AutoAimSettings.FOVColor
circle.Visible = AutoAimSettings.ShowFOV
circle.Filled = false
circle.Transparency = 1

FOVCircle = circle
end

function GetClosestBall()
local closestBall = nil
local shortestDistance = math.huge

if not BallsFolder then return nil end

-- First check for pitched balls
for _, ball in pairs(BallsFolder:GetChildren()) do
if ball:IsA("BasePart") and ball.Parent and (ball.Name == "PitchedBall" or ball.Name == "Ball_Hitbox") then
local distance = (ball.Position - Camera.CFrame.Position).Magnitude

if distance < shortestDistance then
closestBall = ball
shortestDistance = distance
end
end
end

-- If no pitched ball found and windup tracking enabled, check for windup target
if not closestBall and AutoAimSettings.TrackInWindup and WindupTarget then
return WindupTarget
end

return closestBall
end

function GetPredictedPosition(ball)
if not AutoAimSettings.PredictMovement or not ball or not ball.Parent then
return ball and ball.Position or Vector3.new(0, 0, 0)
end

local velocity = ball.AssemblyLinearVelocity
local predictionTime = 0.1 * AutoAimSettings.PredictionMultiplier

return ball.Position + (velocity * predictionTime)
end

local CurrentMousePos = nil
local LastTargetPos = nil
local MobileTouchPosition = nil

function SmoothMoveMouseToTarget(targetScreenPos)
if IsMobile then
-- Mobile uses touch position
MobileTouchPosition = targetScreenPos
return
end

local currentX, currentY = Mouse.X, Mouse.Y
local targetX, targetY = targetScreenPos.X, targetScreenPos.Y

local deltaX = targetX - currentX
local deltaY = targetY - currentY

local smoothness = AutoAimSettings.LegitSmooth
local moveX = deltaX * smoothness
local moveY = deltaY * smoothness

-- Use relative movement for smooth aim
pcall(function()
mousemoverel(moveX, moveY)
end)
end

function MoveMouseToTarget(target)
if not target or not target.Parent then
IsLockedOn = false
CurrentTarget = nil
CurrentMousePos = nil
LastAimPosition = nil
MobileTouchPosition = nil
return
end

local predictedPos = GetPredictedPosition(target)
local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)

if onScreen then
local targetPos = Vector2.new(screenPos.X, screenPos.Y)

-- ANTI-SHAKE: Only move if position changed significantly
if LastAimPosition then
local distance = (targetPos - LastAimPosition).Magnitude
if distance < 2 then
return -- Too small movement, ignore to prevent shake
end
end

if IsMobile then
-- Mobile: Store position for virtual cursor
MobileTouchPosition = targetPos
else
-- PC: Move mouse
if AutoAimSettings.LegitMode then
SmoothMoveMouseToTarget(targetPos)
else
-- Single precise movement - NO SPAM
pcall(function()
mousemoveabs(math.floor(screenPos.X), math.floor(screenPos.Y))
end)
end
end

LastAimPosition = targetPos
LastTargetPos = targetPos
end
end

-- ============================================
-- ENHANCED AUTO HIT WITH PERFECT TIMING
-- ============================================

function CalculatePerfectSwingTiming(ball)
if not ball or not ball.Parent or not LocalPlayer.Character then return 0.15 end

local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if not rootPart then return 0.15 end

local distance = (ball.Position - rootPart.Position).Magnitude
local velocity = ball.AssemblyLinearVelocity.Magnitude

-- Base timing from user settings
local baseTiming = AutoAimSettings.SwingTiming

-- Calculate time for ball to reach plate
local timeToPlate = distance / math.max(velocity, 1)

-- Adjust timing based on velocity (from game code analysis)
if velocity > 100 then
baseTiming = baseTiming + (timeToPlate * 0.15)
elseif velocity > 80 then
baseTiming = baseTiming + (timeToPlate * 0.18)
elseif velocity > 60 then
baseTiming = baseTiming + (timeToPlate * 0.20)
else
baseTiming = baseTiming + (timeToPlate * 0.25)
end

return baseTiming
end

function ShouldSwingNow(ball)
if not ball or not ball.Parent or not LocalPlayer.Character then
return false
end

local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if not rootPart then return false end

local distance = (ball.Position - rootPart.Position).Magnitude

if distance > AutoAimSettings.HitDistance or distance < 4 then
return false
end

if tick() - LastSwingTime < SwingCooldown then
return false
end

return true
end

-- ============================================
-- CONNECTIONS
-- ============================================

-- Mobile Touch Support for Auto Aim
if IsMobile then
local MobileAimIndicator = Instance.new("Frame")
MobileAimIndicator.Name = "MobileAimIndicator"
MobileAimIndicator.Size = UDim2.new(0, 20, 0, 20)
MobileAimIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
MobileAimIndicator.BorderSizePixel = 0
MobileAimIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
MobileAimIndicator.ZIndex = 10
MobileAimIndicator.Visible = false

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(1, 0)
Corner.Parent = MobileAimIndicator

MobileAimIndicator.Parent = LocalPlayer.PlayerGui:WaitForChild("Carnavas"):WaitForChild("Batting")

-- Update mobile indicator position
RunService.RenderStepped:Connect(function()
if AutoAimSettings.Enabled and MobileTouchPosition then
MobileAimIndicator.Visible = true
MobileAimIndicator.Position = UDim2.fromOffset(MobileTouchPosition.X, MobileTouchPosition.Y)
else
MobileAimIndicator.Visible = false
end
end)
end

-- Ball Detection with Instant Lock
Connections.BallAdded = BallsFolder.ChildAdded:Connect(function(ball)
if ESPSettings.BallESP then
task.wait(0.1)
if ball and ball.Parent then
CreateBallESP(ball)
end
end

-- Check ball type and update indicator - WAIT FOR ATTRIBUTES
if ball.Name == "PitchedBall" or ball.Name == "Ball_Hitbox" then
task.spawn(function()
task.wait(0.2) -- Wait longer for attributes to load
if ball and ball.Parent then
-- Priority 1: Use Strike attribute (most reliable)
local strikeAttr = ball:GetAttribute("Strike")
if strikeAttr ~= nil then
UpdateBallTypeIndicator(not strikeAttr)
else
-- Priority 2: Check EndPosition if available
local endPos = ball:GetAttribute("EndPosition")
if endPos then
local inZone = IsBallInStrikeZone(endPos)
UpdateBallTypeIndicator(not inZone)
else
-- Priority 3: Use current position as fallback
task.wait(0.1)
if ball and ball.Parent then
local inZone = IsBallInStrikeZone(ball.Position)
UpdateBallTypeIndicator(not inZone)
end
end
end
end
end)
end

-- INSTANT LOCK ON BALL SPAWN (PC & MOBILE)
if AutoAimSettings.Enabled and not AutoAimSettings.ToggleMode then
if ball:IsA("BasePart") and (ball.Name == "PitchedBall" or ball.Name == "Ball_Hitbox") then
WindupTarget = nil -- Clear windup target when real ball appears
task.wait(0.01)
if ball and ball.Parent and AutoAimSettings.Enabled then
MoveMouseToTarget(ball)
end
end
end
end)

Connections.BallRemoved = BallsFolder.ChildRemoved:Connect(function(ball)
RemoveBallESP(ball)
if CurrentTarget == ball then
IsLockedOn = false
CurrentTarget = nil
LastAimPosition = nil
MobileTouchPosition = nil
end

-- Reset ball type indicator when ball is removed
if ball.Name == "PitchedBall" or ball.Name == "Ball_Hitbox" then
UpdateBallTypeIndicator(nil)
end
end)

-- Strike Zone Monitor
Connections.StrikeZoneMonitor = RunService.Heartbeat:Connect(function()
if ESPSettings.StrikeZoneESP then
if not StrikeZoneESP.Zone or not StrikeZoneESP.Zone.Parent then
CreateStrikeZoneESP()
end
end

-- Track windup position for early aim - ONLY WHEN BATTING
if AutoAimSettings.Enabled and AutoAimSettings.TrackInWindup and _G.Batting and _G.StrikeZone then
local hasBall = false
for _, ball in pairs(BallsFolder:GetChildren()) do
if ball.Name == "PitchedBall" or ball.Name == "Ball_Hitbox" then
hasBall = true
break
end
end

-- Only create windup target if no real ball exists
if not hasBall then
if not WindupTarget or not WindupTarget.Parent then
WindupTarget = Instance.new("Part")
WindupTarget.Name = "WindupTarget"
WindupTarget.Anchored = true
WindupTarget.CanCollide = false
WindupTarget.CanTouch = false
WindupTarget.CanQuery = false
WindupTarget.Transparency = 1
WindupTarget.Size = Vector3.new(0.5, 0.5, 0.5)
WindupTarget.Parent = Workspace
end
WindupTarget.Position = _G.StrikeZone.Position
else
-- Clear windup target when real ball exists
if WindupTarget and WindupTarget.Parent then
WindupTarget:Destroy()
WindupTarget = nil
end
end
else
-- Clear windup target when not batting or tracking disabled
if WindupTarget and WindupTarget.Parent then
WindupTarget:Destroy()
WindupTarget = nil
end
end
end)

-- Main Update Loop - OPTIMIZED NO SHAKE
local HasSwung = false
local LastBallCheck = 0

Connections.UpdateLoop = RunService.RenderStepped:Connect(function()
-- Update Ball ESP
if ESPSettings.BallESP then
for ball, espData in pairs(ESPObjects) do
if ball and ball.Parent then
UpdateBallESP(ball, espData)
else
RemoveBallESP(ball)
end
end
end

-- Update FOV Circle
if FOVCircle then
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Radius = AutoAimSettings.FOV
FOVCircle.Visible = AutoAimSettings.ShowFOV
FOVCircle.Color = AutoAimSettings.FOVColor
end

-- Silent/Legit Aim - SMOOTH NO SHAKE
if AutoAimSettings.Enabled then
local target = GetClosestBall()

if target and target.Parent then
if AutoAimSettings.ToggleMode then
if IsLockedOn and CurrentTarget and CurrentTarget.Parent then
MoveMouseToTarget(CurrentTarget)
end
else
-- Only update aim every few frames to prevent shake
local currentTime = tick()
if not LastBallCheck or (currentTime - LastBallCheck) >= 0.016 then -- ~60 FPS
MoveMouseToTarget(target)
LastBallCheck = currentTime
end
end

-- ENHANCED AUTO HIT - FIXED WITH DISTANCE CHECKS
if AutoAimSettings.AutoHit and not HasSwung then
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
local rootPart = LocalPlayer.Character.HumanoidRootPart
local distance = (target.Position - rootPart.Position).Magnitude

-- Debug: Check if ball is in range
local minDistance = 4
local maxDistance = AutoAimSettings.HitDistance

-- Ball must be within optimal swing range
if distance <= maxDistance and distance >= minDistance then

-- BALL CHECK - Use current position or end position
local shouldSwing = true
if AutoAimSettings.BallCheck then
local ballCheckPos = target.Position

-- Try to get end position attribute
local endPos = target:GetAttribute("EndPosition")
if endPos then
ballCheckPos = endPos
end

shouldSwing = IsBallInStrikeZone(ballCheckPos)
end

-- Check cooldown
local canSwing = (tick() - LastSwingTime) > SwingCooldown

if shouldSwing and canSwing then
HasSwung = true

-- Calculate perfect timing
local velocity = target.AssemblyLinearVelocity.Magnitude
local baseTiming = AutoAimSettings.SwingTiming

-- Velocity-based timing adjustment
if velocity > 100 then
baseTiming = baseTiming * 1.0
elseif velocity > 80 then
baseTiming = baseTiming * 1.05
elseif velocity > 60 then
baseTiming = baseTiming * 1.1
else
baseTiming = baseTiming * 1.15
end

task.spawn(function()
-- Wait for perfect moment
task.wait(baseTiming)

-- Verify ball still exists and valid
if target and target.Parent and LocalPlayer.Character then
local newRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if newRootPart then
local newDistance = (target.Position - newRootPart.Position).Magnitude

-- Verify still in range (with buffer)
if newDistance <= maxDistance + 3 and newDistance >= minDistance - 1 then

-- Final ball check
local finalCheck = true
if AutoAimSettings.BallCheck then
local finalCheckPos = target.Position
local finalEndPos = target:GetAttribute("EndPosition")
if finalEndPos then
finalCheckPos = finalEndPos
end
finalCheck = IsBallInStrikeZone(finalCheckPos)
end

if finalCheck then
-- SILENT HIT MODE
if AutoAimSettings.SilentHit then
-- Snap PCI to exact ball position for guaranteed hit
local predictedPos = GetPredictedPosition(target)
local ballScreenPos = Camera:WorldToViewportPoint(predictedPos)

if not IsMobile then
-- Force instant snap to ball
pcall(function()
mousemoveabs(math.floor(ballScreenPos.X), math.floor(ballScreenPos.Y))
end)
task.wait(0.02) -- Small delay for snap to register
else
-- Mobile: update touch position
MobileTouchPosition = Vector2.new(ballScreenPos.X, ballScreenPos.Y)
task.wait(0.02)
end
end

mouse1click()
LastSwingTime = tick()
end
end
end
end

-- Reset swing flag
task.wait(0.3)
HasSwung = false
end)
end
end
end
end
else
-- Reset tracking when no target
CurrentMousePos = nil
LastAimPosition = nil
MobileTouchPosition = nil
end
end
end)

-- Lock-On Key Handler (PC & Mobile)
if IsMobile then
-- Mobile: Add toggle button
local MobileToggleButton = Instance.new("TextButton")
MobileToggleButton.Name = "SilentAimToggle"
MobileToggleButton.Size = UDim2.new(0, 80, 0, 80)
MobileToggleButton.Position = UDim2.new(1, -90, 0.5, -40)
MobileToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MobileToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MobileToggleButton.Text = "SA"
MobileToggleButton.Font = Enum.Font.GothamBold
MobileToggleButton.TextSize = 24
MobileToggleButton.ZIndex = 10

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0.2, 0)
Corner.Parent = MobileToggleButton

MobileToggleButton.Parent = LocalPlayer.PlayerGui:WaitForChild("Carnavas"):WaitForChild("Batting")

MobileToggleButton.MouseButton1Click:Connect(function()
AutoAimSettings.Enabled = not AutoAimSettings.Enabled
if AutoAimSettings.Enabled then
MobileToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
Rayfield:Notify({
Title = "Silent Aim",
Content = "Enabled",
Duration = 2,
Image = 4483362458
})
else
MobileToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
IsLockedOn = false
CurrentTarget = nil
LastAimPosition = nil
MobileTouchPosition = nil
Rayfield:Notify({
Title = "Silent Aim",
Content = "Disabled",
Duration = 2,
Image = 4483362458
})
end
end)
end

Connections.KeyPress = UserInputService.InputBegan:Connect(function(input, gameProcessed)
if gameProcessed then return end

if input.KeyCode == AutoAimSettings.LockOnKey and AutoAimSettings.Enabled then
if AutoAimSettings.ToggleMode then
if IsLockedOn then
IsLockedOn = false
CurrentTarget = nil
LastAimPosition = nil
MobileTouchPosition = nil
Rayfield:Notify({
Title = "Silent Aim",
Content = "Unlocked from target",
Duration = 2,
Image = 4483362458
})
else
local target = GetClosestBall()
if target then
IsLockedOn = true
CurrentTarget = target
Rayfield:Notify({
Title = "Silent Aim",
Content = "Locked onto: " .. target.Name,
Duration = 2,
Image = 4483362458
})
end
end
end
end
end)

-- ============================================
-- INFO TAB
-- ============================================

InfoTab:CreateSection("Ball ESP Info")

InfoTab:CreateParagraph({
Title = "How to Use Ball ESP",
Content = "Toggle 'Enable Ball ESP' to see all balls. Customize colors, transparency, and information displayed in the Settings tab."
})

InfoTab:CreateSection("Silent Aim Info")

InfoTab:CreateParagraph({
Title = "How Silent Aim Works",
Content = "Silent Aim moves your MOUSE (not camera) to the ball's predicted position. Choose between:\n• Hold Mode: Continuous tracking\n• Toggle Mode: Press Q to lock/unlock\n• Legit Mode: Smooth aim"
})

InfoTab:CreateParagraph({
Title = "Silent Aim Features",
Content = "• No Shake Aim (Fixed)\n• Windup Tracking\n• Ball/Strike Indicator\n• Silent Hit Mode\n• Enhanced Ball Check\n• Perfect Auto Hit\n• Smooth Aim Fixed"
})

InfoTab:CreateSection("Strike Zone ESP Info")

InfoTab:CreateParagraph({
Title = "Strike Zone Location",
Content = "Searches for StrikeZone in:\n• Workspace.Carnavas.Batting.StrikeZone\n• Workspace (recursive search)\n\nMake sure you're at bat!"
})

InfoTab:CreateParagraph({
Title = "Mobile Support",
Content = "Mobile Features:\n• Red indicator shows aim position\n• SA button on right to toggle aim\n• Auto-hit works on mobile\n• All features fully compatible"
})

InfoTab:CreateSection("Controls")

InfoTab:CreateButton({
Name = "Clear All ESP",
Callback = function()
ClearAllBallESP()
RemoveStrikeZoneESP()
Rayfield:Notify({
Title = "ESP Cleared",
Content = "All ESP objects removed",
Duration = 3,
Image = 4483362458
})
end
})

InfoTab:CreateButton({
Name = "Refresh All ESP",
Callback = function()
ClearAllBallESP()
RemoveStrikeZoneESP()

if ESPSettings.BallESP then
for _, ball in pairs(BallsFolder:GetChildren()) do
CreateBallESP(ball)
end
end

if ESPSettings.StrikeZoneESP then
CreateStrikeZoneESP()
end

Rayfield:Notify({
Title = "ESP Refreshed",
Content = "All ESP refreshed successfully",
Duration = 3,
Image = 4483362458
})
end
})

-- ============================================
-- INITIALIZATION
-- ============================================

-- Create FOV Circle
CreateFOVCircle()

-- Initial ESP for existing balls
for _, ball in pairs(BallsFolder:GetChildren()) do
if ESPSettings.BallESP then
CreateBallESP(ball)
end
end

-- Cleanup Function
local function Cleanup()
ClearAllBallESP()
RemoveStrikeZoneESP()

if FOVCircle then
FOVCircle:Remove()
FOVCircle = nil
end

if WindupTarget then
WindupTarget:Destroy()
WindupTarget = nil
end

if BallTypeIndicator then
BallTypeIndicator.Gui:Destroy()
BallTypeIndicator = nil
end

for _, connection in pairs(Connections) do
if connection then
connection:Disconnect()
end
end
end

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
if player == LocalPlayer then
Cleanup()
end
end)

-- Initial notification
Rayfield:Notify({
Title = "silent.fr Loaded",
Content = IsMobile and "Mobile + PC Support Ready!" or "No Shake + Enhanced Auto Hit Ready!",
Duration = 5,
Image = 4483362458
})

print(IsMobile and "Enhanced Silent Aim Loaded - Mobile & PC Support" or "Enhanced Silent Aim Loaded - No Shake + Perfect Auto Hit")
print(IsMobile and "gyat")
