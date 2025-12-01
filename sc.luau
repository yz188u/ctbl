local function SafeHUI()
	if gethui then return gethui()
	elseif game.CoreGui then return game.CoreGui end

	local ui = Instance.new("ScreenGui")
	ui.Name="BLUE_LOCK_UI_"..math.random(9999)
	ui.IgnoreGuiInset = true
	ui.ResetOnSpawn = false
	ui.Parent = game.CoreGui
	return ui
end
local HUI = SafeHUI()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera
local Ball = workspace:FindFirstChild("Football")

local controlling=false
local speed=100
local runningScript=false

local function MakeFrame(size,pos,glow)
	local fr = Instance.new("Frame")
	fr.AnchorPoint = Vector2.new(.5,.5)
	fr.Size = size
	fr.Position = pos
	fr.Parent = HUI
	fr.BackgroundColor3 = Color3.fromRGB(15,10,25)

	Instance.new("UICorner",fr).CornerRadius = UDim.new(0,15)

	local grad = Instance.new("UIGradient",fr)
	grad.Rotation=70
	grad.Color = ColorSequence.new(Color3.fromRGB(160,0,255), Color3.fromRGB(40,0,80))
	grad.Transparency = NumberSequence.new(.22)

	local stroke = Instance.new("UIStroke",fr)
	stroke.Thickness=2.6
	stroke.Color=Color3.fromRGB(220,0,255)
	stroke.Transparency=.45

	if glow then
		stroke.Thickness=3.9
		stroke.Color=Color3.fromRGB(255,80,255)
	end

	return fr
end

local function MakeBtn(par,text)
	local b=Instance.new("TextButton",par)
	b.Size=UDim2.new(1,0,1,0)
	b.BackgroundTransparency=1
	b.Font=Enum.Font.GothamBold
	b.Text=text
	b.TextScaled=true
	b.TextColor3=Color3.fromRGB(255,255,255)
	return b
end

local InfoFrame=MakeFrame(UDim2.new(.11,0,.11,0),UDim2.new(.5,0,.08,0),true)
InfoFrame.Visible=false
local W1=Instance.new("TextLabel",InfoFrame)
W1.Size=UDim2.new(1,0,.55,0)
W1.BackgroundTransparency=1
W1.Font=Enum.Font.GothamBlack
W1.Text="— XZuyaX —"
W1.TextScaled=true
W1.TextColor3=Color3.fromRGB(255,230,255)

local ControlFrame=MakeFrame(UDim2.new(.15,0,.07,0),UDim2.new(.88,0,.8,0),true)
local ControlBtn=MakeBtn(ControlFrame,"Control (F)")

local function makeDrag(obj)
	local drag=false
	local pos,mousePos

	obj.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then
			drag=true
			mousePos=i.Position
			pos=obj.Position
		end
	end)
	obj.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
	end)
	UIS.InputChanged:Connect(function(i)
		if drag and (i.UserInputType==Enum.UserInputType.MouseMovement) then
			local diff=(i.Position-mousePos)
			obj.Position=UDim2.new(pos.X.Scale, pos.X.Offset+diff.X, pos.Y.Scale, pos.Y.Offset+diff.Y)
		end
	end)
end
makeDrag(ControlFrame)

local SpeedFrame=MakeFrame(UDim2.new(.22,0,.10,0),UDim2.new(.15,0,.88,0),true)
SpeedFrame.Visible=false
local SpeedLabel=Instance.new("TextLabel",SpeedFrame)
SpeedLabel.Size=UDim2.new(1,0,.45,0)
SpeedLabel.BackgroundTransparency=1
SpeedLabel.Font=Enum.Font.GothamBold
SpeedLabel.Text="Speed: 100"
SpeedLabel.TextScaled=true
SpeedLabel.TextColor3=Color3.fromRGB(255,240,255)
local SpeedBtn=Instance.new("TextButton",SpeedFrame)
SpeedBtn.Size=UDim2.new(1,0,.48,0)
SpeedBtn.Position=UDim2.new(0,0,.50,0)
SpeedBtn.Text="Change ▲"
SpeedBtn.Font=Enum.Font.GothamBold
SpeedBtn.TextScaled=true
SpeedBtn.BackgroundTransparency=1
SpeedBtn.TextColor3=Color3.fromRGB(255,255,255)

local TeleFrame=MakeFrame(UDim2.new(.18,0,.075,0),UDim2.new(.15,0,.30,0),true)
local TeleBtn=MakeBtn(TeleFrame,"Teleport (T)")

local MoveFrame=MakeFrame(UDim2.new(.09,0,.16,0),UDim2.new(.20,0,.55,0),true)
MoveFrame.Visible=false
local MoveBtn=MakeBtn(MoveFrame,"▲")
makeDrag(MoveFrame)

local function toggleControl()
	if controlling then
		controlling=false runningScript=false
		ControlBtn.Text="Control (F)"
		MoveFrame.Visible=false SpeedFrame.Visible=false InfoFrame.Visible=false
		Camera.CameraSubject=LP.Character:FindFirstChild("Humanoid")
		if Ball then Ball.Anchored=false Ball.AssemblyLinearVelocity=Vector3.zero end
	else
		Ball=workspace:FindFirstChild("Football")
		if Ball then
			controlling=true runningScript=true
			ControlBtn.Text="Exit (F)"
			MoveFrame.Visible=true SpeedFrame.Visible=true InfoFrame.Visible=true
			Camera.CameraSubject=Ball Ball.Anchored=false
			ReplicatedStorage.Packages.Knit.Services.AbilityService.RE.Ability:FireServer("OneTwo",LP.Character)

			task.spawn(function()
				while controlling and runningScript do
					Ball.AssemblyLinearVelocity=Camera.CFrame.LookVector*speed
					task.wait(.1)
				end
			end)
		end
	end
end

ControlBtn.MouseButton1Click:Connect(toggleControl)
UIS.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.F then toggleControl() end end)

TeleBtn.MouseButton1Click:Connect(function() Ball=workspace:FindFirstChild("Football") if Ball then HRP.CFrame=Ball.CFrame+Vector3.new(0,3,0) end end)
UIS.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.T then TeleBtn.MouseButton1Click() end end)

SpeedBtn.MouseButton1Click:Connect(function()
	speed=(speed>=500) and 50 or speed+50
	SpeedLabel.Text="Speed: "..speed
end)

MoveBtn.MouseButton1Down:Connect(function()
	if controlling and Ball then
		Ball.Anchored=false
		while runningScript do
			Ball.AssemblyLinearVelocity=Camera.CFrame.LookVector*speed
			task.wait(.1)
		end
	end
end)
MoveBtn.MouseButton1Up:Connect(function() if Ball then Ball.Anchored=true end end)
