local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")

-- 1. LOAD EXUNYS AIMBOT V2 CORE
local success_core, err = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V2/main/Resources/Scripts/Raw%20Main.lua"))()
end)
local Aimbot = getgenv().Aimbot
local AimSettings = Aimbot and Aimbot.Settings or {}

-- 2. STABLE TARGETING & CLEANUP
local Target = CoreGui
local success = pcall(function() CoreGui:GetChildren() end)
if not success then Target = LocalPlayer:WaitForChild("PlayerGui") end

for _, old in pairs(Target:GetChildren()) do
    if old.Name:find("ProjectCrimson") then old:Destroy() end
end

local Originals = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogEnd = Lighting.FogEnd,
    ClockTime = Lighting.ClockTime,
    Brightness = Lighting.Brightness,
    MaxZoom = LocalPlayer.CameraMaxZoomDistance
}

local Theme = {
    Background = Color3.fromRGB(12, 12, 12),
    Accent = Color3.fromRGB(230, 57, 70),
    Text = Color3.fromRGB(230, 230, 230),
    Border = Color3.fromRGB(35, 35, 35),
    Font = Enum.Font.Code
}

local Options = { 
    DisableVisuals = false, Boxes = false, Health = false, Skeletons = false, Chams = false, TeamCheck = true,
    WS_Enabled = false, WS_Value = 16, InfJump = false,
    Fly_Enabled = false, Fly_Speed = 50,
    Fullbright = false, NoFog = false, ClockTime = Originals.ClockTime,
    ThirdPerson = false, ZoomValue = 100, Crosshair = false,
    -- RAGE OPTIONS
    Spinbot = false, SpinSpeed = 50, AntiAim = false,
    KnifeAura = false, AuraRange = 15, PriorityFocus = false,
    SpeedHack = false, SpeedValue = 0.5, Bhop = false 
}

-- CROSSHAIR DRAWING
local CrosshairLines = {
    V = Drawing.new("Line"),
    H = Drawing.new("Line")
}
for _, l in pairs(CrosshairLines) do
    l.Visible = false; l.Color = Theme.Accent; l.Thickness = 1; l.Transparency = 1
end

-- 3. WATERMARK
local WM_Gui = Instance.new("ScreenGui", Target); WM_Gui.Name = "ProjectCrimson_WM"
local WM_Frame = Instance.new("Frame", WM_Gui); WM_Frame.Size = UDim2.new(0, 280, 0, 25); WM_Frame.Position = UDim2.new(0, 10, 0, 10); WM_Frame.BackgroundColor3 = Theme.Background; WM_Frame.BorderColor3 = Theme.Accent
local WM_Text = Instance.new("TextLabel", WM_Frame); WM_Text.Size = UDim2.new(1, 0, 1, 0); WM_Text.TextColor3 = Theme.Text; WM_Text.Font = Theme.Font; WM_Text.TextSize = 12; WM_Text.BackgroundTransparency = 1; WM_Text.Text = "PROJECT CRIMSON | REDLINE ACTIVE"

-- 4. UI HELPERS
local function CreateGroup(name, side, parent)
    local Group = Instance.new("Frame", parent); Group.Size = UDim2.new(0.48, 0, 0.95, 0); Group.Position = (side == "Left") and UDim2.new(0, 0, 0, 5) or UDim2.new(0.52, 0, 0, 5); Group.BackgroundColor3 = Theme.Background; Group.BorderColor3 = Theme.Border
    local Lbl = Instance.new("TextLabel", Group); Lbl.Text = " "..name:upper().." "; Lbl.Font = Theme.Font; Lbl.TextColor3 = Theme.Text; Lbl.TextSize = 12; Lbl.Position = UDim2.new(0, 10, 0, 0); Lbl.AnchorPoint = Vector2.new(0, 0.5); Lbl.BackgroundColor3 = Theme.Background; Lbl.BorderSizePixel = 0; Lbl.Size = UDim2.new(0, Lbl.TextBounds.X + 6, 0, 14); Lbl.ZIndex = 5
    local Content = Instance.new("ScrollingFrame", Group); Content.Size = UDim2.new(1, -10, 1, -20); Content.Position = UDim2.new(0, 5, 0, 15); Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 0; Content.AutomaticCanvasSize = "Y"
    Instance.new("UIListLayout", Content).Padding = UDim.new(0, 2)
    return Content
end

local function CreateToggle(name, parent, callback)
    local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(1, 0, 0, 22); btn.BackgroundTransparency = 1; btn.Text = ""
    local box = Instance.new("Frame", btn); box.Size = UDim2.new(0, 12, 0, 12); box.Position = UDim2.new(1, -15, 0.5, -6); box.BackgroundColor3 = Theme.Background; box.BorderColor3 = Theme.Border
    local lbl = Instance.new("TextLabel", btn); lbl.Size = UDim2.new(1, -20, 1, 0); lbl.Text = name; lbl.Font = Theme.Font; lbl.TextColor3 = Theme.Text; lbl.TextSize = 12; lbl.TextXAlignment = "Left"; lbl.BackgroundTransparency = 1
    local s = false
    btn.MouseButton1Click:Connect(function() s = not s; box.BackgroundColor3 = s and Theme.Accent or Theme.Background; callback(s) end)
    
    local function SetValue(val)
        s = val
        box.BackgroundColor3 = s and Theme.Accent or Theme.Background
    end
    
    return SetValue
end

local function CreateTextBox(name, parent, placeholder, callback)
    local container = Instance.new("Frame", parent); container.Size = UDim2.new(1, -5, 0, 35); container.BackgroundTransparency = 1
    local lbl = Instance.new("TextLabel", container); lbl.Size = UDim2.new(1, 0, 0, 15); lbl.Text = name; lbl.Font = Theme.Font; lbl.TextColor3 = Theme.Text; lbl.TextSize = 10; lbl.TextXAlignment = "Left"; lbl.BackgroundTransparency = 1
    local box = Instance.new("TextBox", container); box.Size = UDim2.new(1, -10, 0, 18); box.Position = UDim2.new(0, 0, 0, 16); box.BackgroundColor3 = Theme.Background; box.BorderColor3 = Theme.Border; box.Text = placeholder; box.TextColor3 = Theme.Text; box.Font = Theme.Font; box.TextSize = 11; box.ClearTextOnFocus = true
    box.FocusLost:Connect(function(enter) if enter or not box:IsFocused() then callback(box.Text) if box.Text == "" then box.Text = tostring(placeholder) end end end)
end

-- 5. MAIN MENU SETUP
local Screen = Instance.new("ScreenGui", Target); Screen.Name = "ProjectCrimson_Main"; Screen.ResetOnSpawn = false
local Main = Instance.new("Frame", Screen); Main.Size = UDim2.new(0, 500, 0, 420); Main.Position = UDim2.new(0.5, -250, 0.5, -210); Main.BackgroundColor3 = Theme.Background; Main.BorderColor3 = Theme.Border
local Header = Instance.new("TextLabel", Main); Header.Size = UDim2.new(1, -10, 0, 30); Header.Position = UDim2.new(0, 10, 0, 0); Header.Text = "PROJECT CRIMSON | REDLINE"; Header.Font = Theme.Font; Header.TextColor3 = Theme.Accent; Header.TextSize = 14; Header.BackgroundTransparency = 1; Header.TextXAlignment = "Left"

local TabContainer = Instance.new("Frame", Main); TabContainer.Size = UDim2.new(1, -20, 0, 25); TabContainer.Position = UDim2.new(0, 10, 0, 35); TabContainer.BackgroundTransparency = 1
local PageContainer = Instance.new("Frame", Main); PageContainer.Size = UDim2.new(1, -20, 1, -80); PageContainer.Position = UDim2.new(0, 10, 0, 75); PageContainer.BackgroundTransparency = 1

local Pages = {}
local function NewTab(name, isFirst)
    local btn = Instance.new("TextButton", TabContainer); btn.Size = UDim2.new(0, 85, 1, 0); btn.Position = UDim2.new(0, (#Pages * 90), 0, 0); btn.BackgroundColor3 = Theme.Background; btn.BorderColor3 = isFirst and Theme.Accent or Theme.Border; btn.Text = name:upper(); btn.Font = Theme.Font; btn.TextColor3 = Theme.Text; btn.TextSize = 11
    local Page = Instance.new("Frame", PageContainer); Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = isFirst; Pages[#Pages+1] = {Btn = btn, Page = Page}
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Page.Visible = false; p.Btn.BorderColor3 = Theme.Border end
        Page.Visible = true; btn.BorderColor3 = Theme.Accent
    end)
    return Page
end

local CombatPage      = NewTab("Combat", true)
local VisualsPage     = NewTab("Visuals", false)
local CrimsonPlusPage = NewTab("Crimson+", false)
local MiscPage        = NewTab("Misc", false)
local SettingsPage    = NewTab("Settings", false)

-- GROUPS
local WepGrp = CreateGroup("Weapon", "Left", CombatPage)
local UtilGrp = CreateGroup("Utility", "Right", CombatPage)
local EspGrp = CreateGroup("ESP", "Left", VisualsPage)
local ChmGrp = CreateGroup("Chams", "Right", VisualsPage)
local TargetGrp = CreateGroup("Targeting", "Left", CrimsonPlusPage)
local RageGrp = CreateGroup("Rage", "Right", CrimsonPlusPage)
local MovGrp = CreateGroup("Movement", "Left", MiscPage)
local EnvGrp = CreateGroup("Environment", "Right", MiscPage)
local SetGrp = CreateGroup("Menu", "Left", SettingsPage)

-- SYNC HANDLER
local setCombatTeamCheck
local setVisualTeamCheck

local function SyncTeamCheck(v)
    Options.TeamCheck = v
    if AimSettings then AimSettings.TeamCheck = v end
    if setCombatTeamCheck then setCombatTeamCheck(v) end
    if setVisualTeamCheck then setVisualTeamCheck(v) end
end

-- COMBAT TAB
CreateToggle("Enable Aimbot", WepGrp, function(v) AimSettings.Enabled = v end)
CreateTextBox("Sensitivity", WepGrp, "0.5", function(v) AimSettings.Sensitivity = tonumber(v) or 0.5 end)
CreateTextBox("Aim Part", WepGrp, "Head", function(v) AimSettings.LockPart = v end)

setCombatTeamCheck = CreateToggle("Team Check", UtilGrp, SyncTeamCheck)
CreateToggle("Draw FOV Circle", UtilGrp, function(v) if Aimbot then Aimbot.FOVCircle.Visible = v end end)
CreateTextBox("FOV Radius", UtilGrp, "100", function(v) if Aimbot then Aimbot.FOVCircle.Radius = tonumber(v) or 100 end end)

-- VISUALS TAB
CreateToggle("Box ESP", EspGrp, function(v) Options.Boxes = v end)
CreateToggle("Skeleton ESP", EspGrp, function(v) Options.Skeletons = v end)
CreateToggle("Health Bar", EspGrp, function(v) Options.Health = v end)
setVisualTeamCheck = CreateToggle("Team Check", EspGrp, SyncTeamCheck)
CreateToggle("Enable Chams", ChmGrp, function(v) Options.Chams = v end)
-- ADDED TO VISUALS AS REQUESTED
CreateToggle("Third Person", ChmGrp, function(v) 
    Options.ThirdPerson = v
    LocalPlayer.CameraMaxZoomDistance = v and Options.ZoomValue or Originals.MaxZoom
end)
CreateTextBox("Max Zoom", ChmGrp, "100", function(v) 
    Options.ZoomValue = tonumber(v) or 100 
    if Options.ThirdPerson then LocalPlayer.CameraMaxZoomDistance = Options.ZoomValue end
end)
CreateToggle("Custom Crosshair", ChmGrp, function(v) Options.Crosshair = v end)

-- Initialize Sync
SyncTeamCheck(Options.TeamCheck)

-- CRIMSON+ TARGETING
CreateToggle("Target Lock", TargetGrp, function(v) AimSettings.Enabled = v end)
CreateToggle("Silent Aim", TargetGrp, function(v) if Aimbot then AimSettings.SilentAim = v end end)
CreateToggle("Priority Focus", TargetGrp, function(v) Options.PriorityFocus = v end)

-- CRIMSON+ RAGE (RESTORED)
CreateToggle("Rage Bot", RageGrp, function(v) AimSettings.Enabled = v; AimSettings.Sensitivity = 0 end)
CreateToggle("Spinbot", RageGrp, function(v) Options.Spinbot = v end)
CreateTextBox("Spin Speed", RageGrp, "50", function(v) Options.SpinSpeed = tonumber(v) or 50 end)
CreateToggle("Anti-Aim (Jitter)", RageGrp, function(v) Options.AntiAim = v end)
CreateToggle("Knife Aura", RageGrp, function(v) Options.KnifeAura = v end)
CreateToggle("Speed Hack (CFrame)", RageGrp, function(v) Options.SpeedHack = v end)
CreateTextBox("Speed Multiplier", RageGrp, "0.5", function(v) Options.SpeedValue = tonumber(v) or 0.5 end)
CreateToggle("Bhop (Space Sim)", RageGrp, function(v) Options.Bhop = v end)

-- MISC (Movement)
local wsToggle = CreateToggle("Enable WalkSpeed", MovGrp, function(v) Options.WS_Enabled = v end)
CreateTextBox("Speed Value", MovGrp, "16", function(val) Options.WS_Value = tonumber(val) or 16; Options.WS_Enabled = true; wsToggle(true) end)

local flyToggle = CreateToggle("Enable Fly", MovGrp, function(v) Options.Fly_Enabled = v end)
CreateTextBox("Fly Speed", MovGrp, "50", function(val) Options.Fly_Speed = tonumber(val) or 50; Options.Fly_Enabled = true; flyToggle(true) end)

CreateToggle("Infinite Jump", MovGrp, function(v) Options.InfJump = v end)

-- ENVIRONMENT
CreateToggle("Fullbright", EnvGrp, function(v) Options.Fullbright = v end)
CreateTextBox("Clock Time", EnvGrp, "14", function(val) Options.ClockTime = tonumber(val) or 14 end)

-- 6. RAGE LOGIC
RunService.Heartbeat:Connect(function(dt)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if Options.Spinbot then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Options.SpinSpeed), 0)
        end
        if Options.AntiAim then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(math.random(-180, 180)), 0)
        end
        if Options.SpeedHack and hum and hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (Options.SpeedValue * 60 * dt))
        end
        if Options.Bhop and hum and hum.MoveDirection.Magnitude > 0 then
            if hum.FloorMaterial ~= Enum.Material.Air then
                VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    if Options.KnifeAura and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                if dist < Options.AuraRange then
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        firetouchinterest(plr.Character.Head, tool.Handle, 0)
                        firetouchinterest(plr.Character.Head, tool.Handle, 1)
                    end
                end
            end
        end
    end
end)

-- 7. FLIGHT LOGIC
local BG, BV = Instance.new("BodyGyro"), Instance.new("BodyVelocity")
local FlightConn = RunService.RenderStepped:Connect(function()
    if Options.Fly_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = LocalPlayer.Character.HumanoidRootPart
        BG.Parent, BV.Parent = HRP, HRP
        BG.MaxTorque, BG.CFrame = Vector3.new(9e9, 9e9, 9e9), Camera.CFrame
        BV.MaxForce, BV.Velocity = Vector3.new(9e9, 9e9, 9e9), Vector3.new(0, 0.1, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then BV.Velocity = BV.Velocity + (Camera.CFrame.LookVector * Options.Fly_Speed) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then BV.Velocity = BV.Velocity - (Camera.CFrame.LookVector * Options.Fly_Speed) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then BV.Velocity = BV.Velocity - (Camera.CFrame.RightVector * Options.Fly_Speed) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then BV.Velocity = BV.Velocity + (Camera.CFrame.RightVector * Options.Fly_Speed) end
    else BG.Parent, BV.Parent = nil, nil end
end)

-- 8. ESP & MAIN LOOP
local PlayerVisuals = {}
local function CreateVisuals(plr)
    if plr == LocalPlayer or PlayerVisuals[plr] then return end
    local v = { Box = Drawing.new("Square"), HealthBG = Drawing.new("Square"), HealthMain = Drawing.new("Square"), Skeleton = {}, Highlight = Instance.new("Highlight") }
    v.Highlight.FillColor = Theme.Accent; PlayerVisuals[plr] = v
end

local MainLoop = RunService.RenderStepped:Connect(function()
    WM_Text.Text = "PROJECT CRIMSON | FPS: " .. math.floor(1/RunService.RenderStepped:Wait())
    Lighting.ClockTime = Options.ClockTime
    Lighting.Ambient = Options.Fullbright and Color3.new(1,1,1) or Originals.Ambient

    local center = Camera.ViewportSize / 2
    CrosshairLines.V.Visible = Options.Crosshair; CrosshairLines.H.Visible = Options.Crosshair
    if Options.Crosshair then
        CrosshairLines.V.From = Vector2.new(center.X, center.Y - 10); CrosshairLines.V.To = Vector2.new(center.X, center.Y + 10)
        CrosshairLines.H.From = Vector2.new(center.X - 10, center.Y); CrosshairLines.H.To = Vector2.new(center.X + 10, center.Y)
    end

    if Options.ThirdPerson and LocalPlayer.CameraMaxZoomDistance ~= Options.ZoomValue then
        LocalPlayer.CameraMaxZoomDistance = Options.ZoomValue
    end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if not PlayerVisuals[plr] then CreateVisuals(plr) end
            local v, char = PlayerVisuals[plr], plr.Character
            local hrp, hum = char and char:FindFirstChild("HumanoidRootPart"), char and char:FindFirstChildOfClass("Humanoid")
            
            if Options.PriorityFocus and hrp and hrp.Velocity.Magnitude > 50 then
                if Aimbot then Aimbot.Settings.LockPart = "Head" end 
            end

            if hrp and hum then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local isTeam = (plr.Team == LocalPlayer.Team and plr.Team ~= nil)
                local active = onScreen and (not (Options.TeamCheck and isTeam))
                v.Box.Visible = active and Options.Boxes
                v.HealthBG.Visible = active and Options.Health
                v.HealthMain.Visible = active and Options.Health
                if active then
                    local s = 2000 / pos.Z; local x, y = pos.X - s/2, pos.Y - s*0.75
                    v.Box.Size, v.Box.Position, v.Box.Color = Vector2.new(s, s*1.5), Vector2.new(x, y), Theme.Accent
                    v.HealthBG.Size, v.HealthBG.Position = Vector2.new(4, s*1.5), Vector2.new(x-6, y)
                    v.HealthMain.Size, v.HealthMain.Position = Vector2.new(2, (s*1.5)*(hum.Health/hum.MaxHealth)), Vector2.new(x-5, y+(s*1.5)*(1-hum.Health/hum.MaxHealth))
                    v.HealthMain.Color, v.HealthMain.Filled = Color3.new(0,1,0), true
                end
                if v.Highlight then v.Highlight.Parent = char; v.Highlight.Enabled = Options.Chams and (not (Options.TeamCheck and isTeam)) end
            end
        end
    end
end)

-- UNLOAD
local UnloadBtn = Instance.new("TextButton", SetGrp)
UnloadBtn.Size = UDim2.new(1, 0, 0, 25); UnloadBtn.Text = "UNLOAD"; UnloadBtn.MouseButton1Click:Connect(function()
    LocalPlayer.CameraMaxZoomDistance = Originals.MaxZoom
    CrosshairLines.V:Remove(); CrosshairLines.H:Remove()
    MainLoop:Disconnect(); FlightConn:Disconnect(); Screen:Destroy(); WM_Gui:Destroy()
end)

-- LISTENERS
RunService.Heartbeat:Connect(function()
    if Options.WS_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Options.WS_Value
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Options.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- DRAG & TOGGLE
local drag, dStart, sPos
Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; dStart = i.Position; sPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - dStart; Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.Insert then Main.Visible = not Main.Visible end end)
