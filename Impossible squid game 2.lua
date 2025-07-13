local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "TornadoScriptsGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local openButton = Instance.new("TextButton", gui)
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0, 60, 0, 60)
openButton.Position = UDim2.new(0, 20, 0.5, -30)
openButton.AnchorPoint = Vector2.new(0, 0.5)
openButton.BackgroundColor3 = Color3.new(0, 0, 0)
openButton.Text = "T"
openButton.Font = Enum.Font.GothamBold
openButton.TextScaled = true
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.BorderSizePixel = 0
openButton.AutoButtonColor = false
openButton.ClipsDescendants = true
openButton.ZIndex = 5

local corner = Instance.new("UICorner", openButton)
corner.CornerRadius = UDim.new(1, 0)

local stroke = Instance.new("UIStroke", openButton)
stroke.Thickness = 3

local gradient = Instance.new("UIGradient", stroke)
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 127, 0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 127, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(139, 0, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
}

spawn(function()
	while true do
		for h = 0, 1, 0.01 do
			gradient.Rotation = h * 360
			task.wait(0.03)
		end
	end
end)

do
	local dragging = false
	local dragStart, startPos

	openButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = openButton.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			openButton.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

local menu = Instance.new("Frame", gui)
menu.Name = "MainMenu"
menu.Size = UDim2.new(0, 360, 0, 520)
menu.Position = UDim2.new(0.1, 0, 0.1, 0)
menu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
menu.BackgroundTransparency = 0.05
menu.BorderSizePixel = 0
menu.Visible = false

local menuCorner = Instance.new("UICorner", menu)
menuCorner.CornerRadius = UDim.new(0, 10)

local menuStroke = Instance.new("UIStroke", menu)
menuStroke.Thickness = 3

local menuGradient = Instance.new("UIGradient", menuStroke)
menuGradient.Color = gradient.Color

local title = Instance.new("TextLabel", menu)
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundTransparency = 1
title.Text = "Tornado Scripts"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.new(1, 1, 1)

local function createButton(name, text, position)
	local btn = Instance.new("TextButton", menu)
	btn.Name = name
	btn.Size = UDim2.new(0.8, 0, 0, 55)
	btn.Position = position
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextScaled = true
	btn.Text = text
	btn.BorderSizePixel = 0

	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0, 8)

	local stroke = Instance.new("UIStroke", btn)
	stroke.Thickness = 1
	stroke.Color = Color3.fromRGB(100, 100, 100)

	return btn
end

local espButton = createButton("ESPButton", "ESP: OFF", UDim2.new(0.1, 0, 0.2, 0))
local espActive = false
local highlightFolder = Instance.new("Folder", workspace)
highlightFolder.Name = "ESP_Highlights"

local function clearHighlights()
	highlightFolder:ClearAllChildren()
end

local function addHighlight(part, color)
	local hl = Instance.new("Highlight")
	hl.Adornee = part
	hl.FillColor = color
	hl.OutlineColor = Color3.new(1,1,1)
	hl.FillTransparency = 0.3
	hl.OutlineTransparency = 0
	hl.Parent = highlightFolder
end

local function updateESP()
	clearHighlights()
	local segments = workspace:FindFirstChild("segmentSystem") and workspace.segmentSystem:FindFirstChild("Segments")
	if not segments then return end

	for i = 1, math.huge do
		local segment = segments:FindFirstChild("Segment" .. i)
		if not segment then break end

		local folder = segment:FindFirstChild("Folder")
		if folder then
			for _, part in pairs(folder:GetChildren()) do
				if part:IsA("BasePart") and part:FindFirstChild("breakable") then
					local value = part.breakable
					if value:IsA("BoolValue") then
						if value.Value == true then
							part.BrickColor = BrickColor.Red()
							addHighlight(part, Color3.fromRGB(255, 0, 0))
						else
							part.BrickColor = BrickColor.Green()
							addHighlight(part, Color3.fromRGB(0, 255, 0))
						end
					end
				end
			end
		end
	end
end

espButton.MouseButton1Click:Connect(function()
	espActive = not espActive
	espButton.Text = espActive and "ESP: ON" or "ESP: OFF"
	espButton.BackgroundColor3 = espActive and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(30, 30, 30)
	if espActive then
		RunService:BindToRenderStep("ESPUpdater", Enum.RenderPriority.Last.Value, updateESP)
	else
		RunService:UnbindFromRenderStep("ESPUpdater")
		clearHighlights()
	end
end)

local farmButton = createButton("FarmButton", "Farm Money: OFF", UDim2.new(0.1, 0, 0.35, 0))
local farmActive = false
local farmThread = nil

local function startFarm()
	farmThread = task.spawn(function()
		while farmActive do
			local chest = workspace:FindFirstChild("Finish") and workspace.Finish:FindFirstChild("Chest")
			if chest and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				player.Character.HumanoidRootPart.CFrame = chest.CFrame + Vector3.new(0, 5, 0)
			end
			task.wait(13)
		end
	end)
end

farmButton.MouseButton1Click:Connect(function()
	farmActive = not farmActive
	farmButton.Text = farmActive and "Farm Money: ON" or "Farm Money: OFF"
	farmButton.BackgroundColor3 = farmActive and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(30, 30, 30)
	if farmActive then
		startFarm()
	else
		if farmThread then
			task.cancel(farmThread)
		end
	end
end)

openButton.MouseButton1Click:Connect(function()
	menu.Visible = not menu.Visible
end)
