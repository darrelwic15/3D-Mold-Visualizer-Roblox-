local player = game.Players.LocalPlayer
local character = script.Parent --character
local humanoid = character.Humanoid
local root = character.PrimaryPart --given to characters primary part

local uis = game:GetService("UserInputService")
local rs = game:GetService("ReplicatedStorage")
local ts = game:GetService("TweenService")

local remote = rs.Flashstep.Remote
local fx = rs.Flashstep.Fx

local gui = player.PlayerGui.flashstep_gui

local BASESPEED = 16
local TOTALFLASHSTEPS = 4

local cd = false
local flashsteps = TOTALFLASHSTEPS
local lastFlash = 0

local function flashStep(position, hrp) --humanoid root part = hrp
	hrp.Parent.Head.Transparency = 1 --the problem
	for i, part in pairs(hrp.Parent:GetChildren()) do
		if part:IsA("BasePart") then
			local clone = part:Clone()
			clone:ClearAllChildren()
			clone.Anchored = true
			clone.CanCollide = false
			clone.Parent = workspace.Fx
			clone.Color = Color3.fromRGB(0,0,0)
			clone.Material = Enum.Material.Neon
			clone.Transparency = .5
			game.Debris:AddItem(clone, .3)
			ts:Create(clone, TweenInfo.new(.3), {Transparency = 1}):Play()
			part.Transparency = part.Transparency + 1
		end
	end
	
	local flashStep = fx.Flashstep:Clone()
	flashStep.Parent = hrp.RootRigAttachment
	flashStep.Enabled = true
	local smoke = fx.Smoke:Clone()
	smoke.Position = position - Vector3.new(0,2,0)
	smoke.Parent = workspace.Fx
	smoke.Attachment.Smoke.Enabled = true
	
	
	task.delay(.2, function()
		hrp.Parent.Head.Transparency = 0  --.Head.face
		for i, part in pairs(hrp.Parent:GetChildren()) do
			if part:IsA("BasePart") then
				local clone = part:Clone()
				clone:ClearAllChildren()
				clone.Anchored = true
				clone.CanCollide = false
				clone.Parent = workspace.Fx
				clone.Color = Color3.fromRGB(0,0,0)
				clone.Material = Enum.Material.Neon
				clone.Transparency = .5
				game.Debris:AddItem(clone, .3)
				ts:Create(clone, TweenInfo.new(.3), {Transparency = 1}):Play()
				part.Transparency = part.Transparency - 1
			end
		end
		local smoke2 = fx.Smoke:Clone()
		smoke2.Position = hrp.position - Vector3.new(0,2,0) --x y z
		smoke2.Parent = workspace.Fx
		smoke2.Attachment.Smoke.Enabled = true
		task.delay(.2, function()
			smoke.Attachment.Smoke.Enabled = false
			flashStep.Enabled = false
			smoke2.Attachment.Smoke.Enabled = false
			wait(.6)
			smoke2:Destroy()
			smoke:Destroy()
			flashStep:Destroy()
		end)
	end)
end

uis.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.Q and cd == false and flashsteps > 0 then
		cd = true
		flashsteps -= 1
		lastFlash = tick()
		gui.Frame.Flashsteps.Text = "Flash steps: ".. flashsteps
		humanoid.WalkSpeed = 100
		flashStep(root.Position, root)
		remote:FireServer(root.Position, root)
		task.wait(.2)
		humanoid.WalkSpeed = 16
		cd = false
		humanoid.WalkSpeed = 16
	end
end)

remote.OnClientEvent:Connect(function(position, hrp)
	flashStep(position, hrp)
end)

while wait(1) do 
	if tick() - lastFlash > 1 then --if more than 1 second has passed, tick() - lastFlash
		if flashsteps + 1 < TOTALFLASHSTEPS then
			flashsteps += 1 --then flashstep counter plus 1
			gui.Frame.Flashsteps.Text = "Flashsteps: ".. flashsteps
		else
			flashsteps = TOTALFLASHSTEPS
			gui.Frame.Flashsteps.Text = "Flashsteps: ".. flashsteps
		end
	end
end