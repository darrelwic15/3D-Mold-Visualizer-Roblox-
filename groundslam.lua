local player = game.Players.LocalPlayer
local character = script.Parent
local humanoid = character.Humanoid

local uis = game:GetService("UserInputService")
local rs = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")
local ts = game:GetService("TweenService")


local debounce = false
local charging = false

local remote = rs.Modules.AOERemote

local CD = 25
local KEY = Enum.KeyCode.Z

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Whitelist
params.FilterDescendantsInstances = {workspace.Map}

local camera = workspace.CurrentCamera
local CameraShaker = require(rs.Modules.CameraShaker)

local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	camera.CFrame = camera.CFrame * shakeCFrame
end)
camShake:Start()

local function effect(CF, Mod)
	local sphere = rs.Fx_groundslam.Sphere:Clone()
	sphere.CFrame = CF
	sphere.Size = Vector3.new(0,0,0)
	sphere.Parent = workspace.Fx
	ts:Create(sphere, TweenInfo.new(.4), {Size = Vector3.new(40,40,40) * Mod, Transparency = 1}):Play()
	for i, particle in pairs(sphere.Attachment:GetChildren()) do
		particle.Speed = NumberRange.new(particle.Speed.Min * Mod, particle.Speed.Max * Mod)
		particle:Emit(particle:GetAttribute("EmitCount") * Mod)
	end
	debris:AddItem(sphere, 1.5)
	for i = 1, (20 * Mod)/10 do  --number of rings formed
		local segments = math.random(8,12)
		for i2 = 0, segments - 1 do  --
			local potCf = CF * CFrame.Angles(0,math.rad(360/segments) * i2, 0) * CFrame.new(0,0,(i * -(20 * Mod)/3) - 5)
			local result = workspace:Raycast(potCf.Position + Vector3.new(0,3,0), Vector3.new(0,-10,0), params)
			if result then
				local hb =Instance.new("Part", workspace.Fx)
				hb.Anchored = true
				hb.CanCollide = false
				hb.Transparency = result.Instance.Transparency
				hb.Color = result.Instance.Color
				hb.Material = result.Material
				hb.Name = "hb"
				hb.CanQuery = false
				hb.Size = Vector3.new(math.random(8,14) * 10 * Mod/segments,math.random(5,6), math.random(5,10))
				hb.CFrame = potCf
				hb.Position = result.Position - Vector3.new(0,5,0)
				hb.CFrame *= CFrame.Angles(math.rad(math.random(10,45)),0,0)
				ts:Create(
					hb,
					TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{Position = hb.Position + Vector3.new(0,3,0)}
				):Play()
				task.delay(.3, function()
					ts:Create(
						hb,
						TweenInfo.new(.6, Enum.EasingStyle.Back, Enum.EasingDirection.In),
						{Position = hb.Position - Vector3.new(0,6 * Mod,0)}
					):Play()
				end)
				game.Debris:AddItem(hb, 1.5)
			end
		end
		wait()
	end
end

uis.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == KEY and not debounce then
		humanoid.WalkSpeed = 6
		debounce = true
		charging = true

		local data = {
			character = character,
			action = "Charge",
		}
		remote:FireServer(data)

		local mod = 1 --gives remainder of the division
		repeat
			task.wait(.1)
			mod += .05
		until charging == false or mod > 1.5 or humanoid.Health <= 0
		if humanoid.Health <= 0 then
			return
		end
		humanoid.Animator:LoadAnimation(rs.Fx_groundslam.Animation):Play()
		wait(.6)
		camShake:ShakeOnce(2, 5, .2, .4)
		data = nil
		data = {
			character = character,
			action = "Release",
			cframe = character.HumanoidRootPart.CFrame,
			charge = mod,
		}
		effect(data.cframe, mod)
		remote:FireServer(data)
		data = nil
	end
end)

uis.InputEnded:Connect(function(input)
	if input.KeyCode == KEY and charging then
		charging = false
		humanoid.WalkSpeed = 16
		task.wait(CD)
		debounce = false
	end
end)

remote.OnClientEvent:Connect(function(data)
	if data.action == "Release" then
		effect(data.cframe, data.charge)
		
	end
end)
