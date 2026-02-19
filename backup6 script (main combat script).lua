local character = script.Parent         --startercharacterscripts
local humanoid = character.Humanoid     --humanoid part
local player = game.Players.LocalPlayer --the player
character.Humanoid.JumpPower = 7.2
local plr = game:GetService("Players").LocalPlayer -- still here

local statusFolder = character:WaitForChild("StatusFolder")

local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Whitelist
params.FilterDescendantsInstances = {workspace.Map}

local remote = game.ReplicatedStorage.CombatEvent
local resources = game.ReplicatedStorage.Fx
--local hitSfx = game.ReplicatedStorage.DBZ_punch_SFX

local lastTimeM1 = 0
local lastM1End = 0
local combo = 1
local lastTimeM2 = 0

local blocking = false
local canAir = true

local Stamina = 100 --just there
local Running = false
local SprintSpeed = 21 -- out of order
local WalkSpeed = 20 

local punchAnims = {
	'rbxassetid://11887048420', --punch
	'rbxassetid://11887050128', --punch
	'rbxassetid://11927606073', 
	'rbxassetid://11887050128', --11928131297 backhand, 11887050128 right punch, rbxassetid://11928006321 single fist barrage
	'rbxassetid://12092811609', --spinkick
}

local blockAnims = {
	'rbxassetid://11887044316',
}

local airAnims = {
	'rbxassetid://11904826192',
	'rbxassetid://11904848753',
}

local function hb(size, cframe, ignore, char)
	local hb = Instance.new("Part", workspace.Fx) --hb stands for hitbox
	hb.Anchored = true
	hb.CanCollide = false
	hb.Transparency = .3
	hb.Name = "hb"
	hb.Material = Enum.Material.ForceField
	hb.CanQuery = false
	hb.Size = size
	hb.CFrame = cframe

	local con
	con = hb.Touched:Connect(function()
		con:Disconnect()
	end)

	local lasttarg

	for i,v in pairs(hb:GetTouchingParts()) do --i means the order in which the item is in the table and v stands for the value
		if v.Parent:FindFirstChild("Humanoid") and table.find(ignore, v.Parent) == nil then
			if lasttarg then
				if (lasttarg.Position - char.PrimaryPart.Position).Magnitude > (v.Position - char.PrimaryPart.Position).Magnitude then
					lasttarg = v.Parent.PrimaryPart
				end
			else
				lasttarg = v.Parent.PrimaryPart
			end
		end
	end

	hb:Destroy() --hb means hitbox
	if lasttarg then
		return lasttarg.Parent
	else
		return nil
	end
end

local function crater(data) --making the downslam crater
	local currentTime = tick()
	local craterRaycastResult --to detect whether the player has been slammed down and if they should make the crater
	repeat
		craterRaycastResult = workspace:Raycast(data.Target.PrimaryPart.Position, data.Direction, params)
		print(craterRaycastResult)
		wait()
	until tick() - currentTime > 5 or craterRaycastResult ~= nil --"~=" means unequal
	if craterRaycastResult then
		for i = 0, 14 do
			local part = Instance.new("Part", workspace.Fx)
			part.Size = Vector3.new(4, math.random(10,20)/10, math.random(10,20)/10)
			part.Anchored = true
			part.CFrame = CFrame.new(craterRaycastResult.Position, craterRaycastResult.Position + craterRaycastResult.Normal)
			part.CFrame = part.CFrame * CFrame.Angles(math.rad(90), math.rad(i * 360/14),0) * CFrame.new(0,0,-4 * 2) * CFrame.Angles(math.rad(35),0,0) --crater rotation
			part.CanQuery = false
			part.CanCollide = false
			part.CanTouch = false

			local result = workspace:Raycast(part.Position + craterRaycastResult.Normal * 4, craterRaycastResult.Normal * -5, params)
			if result then
				part.Position = result.Position
				part.Material = result.Material
				part.Color = result.Instance.Color
			else
				part:Destroy()
			end

			part.Position = part.Position + craterRaycastResult.Normal * -4
			ts:Create(part, TweenInfo.new(.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false, 0), {Position = part.Position + craterRaycastResult.Normal * 4}):Play()

			spawn(function()
				game.Debris:AddItem(part, 4)
				wait(3)
				ts:Create(part, TweenInfo.new(.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false, 0), {Position = part.Position + craterRaycastResult.Normal * -4}):Play()
			end)

			if i % 3 < 2 and result then
				local rubble = part:Clone()
				rubble.Size =Vector3.new(math.random(10,20)/20, math.random(10,20)/20, math.random(10,20)/20)
				rubble.Position = result.Position * craterRaycastResult.Normal * 4
				rubble.Material = result.Material
				rubble.Color = result.Instance.color

				rubble.Parent = workspace.Fx
				rubble.Anchored = false
				rubble.CanCollide = true

				local bv = Instance.new("BodyVelocity", rubble)
				bv.Velocity = Vector3.new(math.random(-40,40), 30, math.random(-40,40))
				bv.MaxForce = Vector3.new(99999,99999,99999)
				bv.Name = "Velocity"

				game.Debris:AddItem(bv, .1)
				game.Debris:AddItem(rubble, 4)

				spawn(function()
					wait(2)

					ts:Create(rubble, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false, 0), {Transparency = 1}):Play()
				end)
				rubble.Transparency = 0
			end
		end
	end
end

local function finisher(data) --sliding rocks effect
	local cf = data.Character.PrimaryPart.CFrame
	for i = 1, 20 do
		local rock = Instance.new("Part")
		rock.Size = Vector3.new(1,1,1)
		rock.CFrame = cf * CFrame.new(3,0,-4 + (i * -1))
		rock.CanCollide = false
		rock.Anchored = true
		local result = workspace:Raycast(rock.Position, Vector3.new(0,-4,0), params)
		if result then
			rock.Position = result.Position
			rock.Material = result.Material
			rock.Color = result.Instance.Color
			rock.Rotation = Vector3.new(math.random(0,180),math.random(0,180))
			rock.Parent = workspace.Fx
			game.Debris:AddItem(rock, 2)
		else
			rock:Destroy()
		end

		local rock = Instance.new("Part")
		rock.Size = Vector3.new(1,1,1)
		rock.CFrame = cf * CFrame.new(-3,0,-4 + (i * -1))
		rock.CanCollide = false
		rock.Anchored = true
		local result = workspace:Raycast(rock.Position, Vector3.new(0,-4,0), params)
		if result then
			rock.Position = result.Position
			rock.Material = result.Material
			rock.Color = result.Instance.Color
			rock.Rotation = Vector3.new(math.random(0,180),math.random(0,180))
			rock.Parent = workspace.Fx
			game.Debris:AddItem(rock, 2)
		else
			rock:Destroy()
		end

		if i % 4 == 0 then
			wait()
		end
		if i == 20 then
			for n = 1, 4 do 
				local rock = Instance.new("Part")
				rock.Size = Vector3.new(1,1,1)
				rock.CFrame = cf * CFrame.new(3 - (n/1.5),0,-25 + (n * -.5))
				rock.CanCollide = false
				rock.Anchored = true
				local result = workspace:Raycast(rock.Position, Vector3.new(0,-4,0), params)
				if result then
					rock.Position = result.Position
					rock.Material = result.Material
					rock.Color = result.Instance.Color
					
					rock.Rotation = Vector3.new(math.random(0,180),math.random(0,180))
					rock.Parent = workspace.Fx
					game.Debris:AddItem(rock, 2)
				else
					rock:Destroy()
				end
				
				local rock = Instance.new("Part")
				rock.Size = Vector3.new(1,1,1)
				rock.CFrame = cf * CFrame.new(-3 + (n/2),0,-25 + (n * -.5))
				rock.CanCollide = false
				rock.Anchored = true
				local result = workspace:Raycast(rock.Position, Vector3.new(0,-4,0), params)
				if result then
					rock.Position = result.Position
					rock.Material = result.Material
					rock.Color = result.Instance.Color
					rock.Rotation = Vector3.new(math.random(0,180),math.random(0,180))
					rock.Parent = workspace.Fx
					game.Debris:AddItem(rock, 2)
				else
					rock:Destroy()
				end
			end
		end
	end
end

uis.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 and tick() - lastTimeM1 > .3 and tick() - lastM1End > .7 and not blocking and statusFolder:FindFirstChild("Stun") == nil then --1
		if tick() - lastTimeM1 > .7 then
			combo = 1
		end

		lastTimeM1 = tick()

		local animation = Instance.new("Animation", workspace.Fx)
		local air = nil

		if uis:IsKeyDown("Space") and combo == 4 and canAir then
			canAir = false
			animation.AnimationId = airAnims[1]
			air = "Up" 
		elseif not uis:IsKeyDown("Space") and combo == 5 and not canAir then
			animation.AnimationId = airAnims[2]
			air = "Down"
			--canAir = true
		else
			animation.AnimationId = punchAnims[combo] --punchAnims[the value of the current combo]
			--canAir = true
		end

		local load = humanoid:LoadAnimation(animation)
		load:Play()

		animation:Destroy()

		local hitTarg = hb(Vector3.new(4,8,4), character.PrimaryPart.CFrame * CFrame.new(0,0,-3),{character}, character) --the hitbox size

		if hitTarg then
			local data = {
				["Target"] = hitTarg,
				["Character"] = character,
				["Combo"] = combo,
				["Air"] = air,
				["Action"] = "m1",
			}

			remote:FireServer(data)
		end

		if combo == #punchAnims then
			combo = 1
			lastM1End = tick()
		else
			combo += 1
		end
		humanoid.WalkSpeed = 0
		wait(.4)
		humanoid.WalkSpeed = 20
	elseif input.KeyCode == Enum.KeyCode.F and tick() - lastTimeM1 > .3 and statusFolder:FindFirstChild("Stun") == nil then --2
		blocking = true
		local animation = Instance.new("Animation", workspace.Fx)
		animation.AnimationId = blockAnims[1]
		local blockAnimation = humanoid.Animator:LoadAnimation(animation)
		blockAnimation:Play()
		animation:Destroy()

		local data = {
			["Action"] = "Block",
			["Character"] = character
		}

		remote:FireServer(data)
		repeat
			wait()
		until blocking == false or statusFolder:FindFirstChild("Stun")
		blocking = false
		blockAnimation:Stop()
	--elseif input.UserInputType == Enum.UserInputType.MouseButton2 and statusFolder:FindFirstChild("Stun") == nil and not blocking  and canAir == true then --delete this if it becomes a nuisance
		
		--if tick() - lastTimeM2 > .7 then
			--combo = 1
		--end

		--lastTimeM2 = tick()
		
		--local animation = Instance.new("Animation", workspace.Fx)
		--local animation2 = Instance.new("Animation", workspace.Fx)
		--local air = nil
		--canAir = false
		--animation.AnimationId = 'rbxassetid://11904680712'
		--animation2.AnimationId = 'rbxassetid://11904848753'
		--local load = humanoid:LoadAnimation(animation)
		--local load2 = humanoid:LoadAnimation(animation2)
		--load:Play()
		--wait(.5)
		--load2:Play()
		
		--local hitTarg = hb(Vector3.new(4,8,4), character.PrimaryPart.CFrame * CFrame.new(0,0,-3),{character}, character) --the hitbox size

		--if hitTarg then
			--local data = {
				--["Target"] = hitTarg,
				--["Character"] = character,
				--["Combo"] = combo,
				--["Air"] = air,
				--["Action"] = "m2",
			--}

			--remote:FireServer(data)
		--end
	end
end)

uis.InputEnded:Connect(function(input, gpe)
	if input.KeyCode == Enum.KeyCode.F and blocking then
		blocking = not blocking --turns it to false if it somehow stays true
		local data = {
			["Action"] = "Unblock",
			["Character"] = character
		}

		remote:FireServer(data)
	end
end)

local function hitEffect(target)
	for i,particle in pairs(resources.Hit:GetChildren()) do
		local clone = particle:Clone()
		clone.Parent = target.UpperTorso.BodyFrontAttachment
		clone:Emit(clone:GetAttribute("EmitCount"))
		game.Debris:AddItem(clone, .3)
	end
end

local function blockEffect(target)
	local clone = resources.Ring:Clone()
	clone.Parent = target.UpperTorso.BodyFrontAttachment
	clone:Emit(clone:GetAttribute("EmitCount"))
	game.Debris:AddItem(clone, .3)
end

remote.OnClientEvent:Connect(function(data)
	if data.Action == "Crater" then
		crater(data) 
	elseif data.Action == "Finisher" then
		finisher(data)
	elseif data.Action == "Hit" then
		hitEffect(data.Target)
	elseif data.Action == "Block" then
		blockEffect(data.Target)
	end
end)

statusFolder.ChildAdded:Connect(function(Child)
	local Walkspeed = 20
	local JumpHeight = 7.2
	for i, status in pairs(statusFolder:GetChildren())do
		if status.Name == "Stun" then
			Walkspeed = 0
			JumpHeight = 0
			--hitSfx:Play() --out of order
		elseif status.Name == "Block" then
			Walkspeed = 3
			JumpHeight = 0
		end
	end
	humanoid.WalkSpeed = Walkspeed
	humanoid.JumpHeight = JumpHeight
end)

statusFolder.ChildRemoved:Connect(function(Child)
	local Walkspeed = 20
	local JumpHeight = 7.2
	if blocking then
		Walkspeed = 3
		JumpHeight = 0
	end
	for i, status in pairs(statusFolder:GetChildren())do
		if status.Name == "Stun" then
			Walkspeed = 0
			JumpHeight = 0
			--hitSfx:Play() --out of order
		elseif status.Name == "Block" then
			Walkspeed = 3
			JumpHeight = 0
		end
	end
	humanoid.WalkSpeed = Walkspeed
	humanoid.JumpHeight = JumpHeight
end)

humanoid.StateChanged:Connect(function(old, new)
	if new == Enum.HumanoidStateType.Landed then
		canAir = true
	end
end)


uis.JumpRequest:Connect(function() --m1
	if tick() - lastTimeM1 < 1 then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	else
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end
end)	

--uis.JumpRequest:Connect(function() --m2
	--if tick() - lastTimeM2 < 1 then
		--humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	--else
		--humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	--end
--end)	


uis.InputBegan:Connect(function(atk) --just doesnt work
	if atk.KeyCode == Enum.UserInputType.MouseButton1 and character.StatusFolder.status.Name == "Stun" then
		Instance.new("Sound", player)
		game.Players.LocalPlayer.sound.SoundId = 'rbxassetid://6968100828'
		local Sfx = player.Sound
		Sfx:Play()
		
	end
end)







--uis.InputBegan:Connect(function(key)
	--if key.KeyCode == Enum.KeyCode.LeftShift and blocking then 
		--Running = false
	--elseif key.KeyCode == Enum.KeyCode.LeftShift and not blocking then
		--Running = true
		--character.Humanoid.WalkSpeed = 21
		--character.Humanoid.JumpPower = 7.2
		--while Stamina > 0 and Running do
			--Stamina -= 1
			--print(Stamina)
			--wait()
			--if Stamina == 0 then
				--character.Humanoid.WalkSpeed = WalkSpeed
				--character.Humanoid.JumpPower = 7.2
			--end
		--end
	--else
		--Running = false
	--end 
--end)

--uis.InputEnded:Connect(function(key)
	--if key.KeyCode == Enum.KeyCode.LeftShift and blocking then
		--Running = false
		--character.Humanoid.WalkSpeed = 16
	--elseif key.KeyCode == Enum.KeyCode.LeftShift and not blocking then
		--character.Humanoid.WalkSpeed = 16
		--character.Humanoid.JumpPower = 7.2
		--while Stamina < 100 and not Running do
			--wait(1.2)
			--Stamina += 7
			--print(Stamina)
			--if Stamina == 0 then
				--character.Humanoid.WalkSpeed = 16
				--character.Humanoid.JumpPower = 7.2
			--elseif blocking then
				--humanoid.WalkSpeed = 3
			--else
				--humanoid.WalkSpeed = 16
				--humanoid.JumpPower = 7.2
			--end
		--end
	--else
		--blocking = false
		--humanoid.WalkSpeed = 16
		--humanoid.JumpPower = 7.2
	--end
--end)



