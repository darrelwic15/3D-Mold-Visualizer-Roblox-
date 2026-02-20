
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EasySlider = require(ReplicatedStorage:WaitForChild("Slider"))

local Container = script.Parent
local Main = Container.Parent
local Button = Container:WaitForChild("Button")
local PercentLabel = Main:WaitForChild("PercentLabel")
local humidityLabel = Main:WaitForChild("humidityLabel")
local airFlowLabel = Main:WaitForChild("airFlowLabel")

local Music = workspace:WaitForChild("Music")
local Wall = workspace:WaitForChild("Wall")
local Mold = workspace.Folder:WaitForChild("Model")
local Air = workspace:WaitForChild("Air")
local artAir = workspace:WaitForChild("artair")
local artAir2 = workspace:WaitForChild("artair2")

local particleEmitter = workspace.Air:WaitForChild("ParticleEmitter")
local particleEmitter1 = workspace.artair:WaitForChild("ParticleEmitter")


local Slider = EasySlider.new(Button, Container, 0.5) 
Slider:SetPercent(1) -- 100%



--for raining thingy
local Framesmall = script.Parent
local Framebig = Framesmall.Parent
local SGUI = Framebig.Parent
local ButtonRainYes = SGUI:WaitForChild("Yes")
local ButtonRainNo = SGUI:WaitForChild("No")


local isRaining = false
local rain = game.Workspace.rainFolder

-----------------------------------------------------------------


--Slider:SetRange(5)
--Slider.RangeEnabled = true

Slider.PercentChanged:Connect(function(Percent)
	--Music.Volume = Percent * 0.5 -- 0.5 is the maximum volume
	
	
	
	
	--changing the darn color
	Wall.Color = Color3.new(Percent,Percent,Percent) --keep all 3 at positive percent
	Air.Color = Color3.new(-Percent+1,0,0)
	artAir.Color = Color3.new(-Percent +1,0,0)
	artAir2.Color = Color3.new(-Percent +1,0,0)
	
	
	for i, mold in pairs(workspace.Folder:GetChildren()) do
		mold["Grey Wall"].Color = Color3.new(Percent,Percent, Percent)
		mold["Grey Wall2"].Color = Color3.new(Percent,Percent, Percent)
		mold["Grey Wall3"].Color = Color3.new(Percent,Percent, Percent)
		
	end
	
	--Mold["Grey Wall"].Color = Color3.new(Percent, Percent, Percent)

	
	
	
	
	
	local RoundedPercent = math.floor(Percent * 100)
	PercentLabel.Text = string.format(
		"Humidity and AC flow: %s%%", tostring(RoundedPercent)
	)
	
	humidityLabel.Text = string.format(
		"Humidity Cleansed: %s%%", tostring(RoundedPercent)
	)
	
	airFlowLabel.Text = string.format(
		"Air Flow (M/S): %s%%", tostring(RoundedPercent/40)
	)
	
	Slider.MinValue = -50
	Slider.MaxValue = 50
	print(Slider:GetValue())
	-- the %s means put the string there, the %% is one percent sign
	
	
	
	if Slider:GetValue() < 0 then
		particleEmitter.Brightness = 1  --change into transparency
		particleEmitter1.Brightness = 1
	else
		particleEmitter.Brightness = 0
		particleEmitter1.Brightness = 0
	end

	
	
	
	
	
	if  Slider:GetValue() < 50 then
		for i, mold in pairs(workspace.Folder:GetChildren()) do
			mold["Grey Wall"].Material = Enum.Material.Rock
			mold["Grey Wall2"].Material = Enum.Material.Rock
			mold["Grey Wall3"].Material = Enum.Material.Rock
			
			mold["Grey Wall"].Transparency = 0
			mold["Grey Wall2"].Transparency = 0
			mold["Grey Wall3"].Transparency = 0
		end
		
	else
		for i, mold in pairs(workspace.Folder:GetChildren()) do
			
			
			--mold["Grey Wall"].Color = Color3.new(163,162,165)
			--mold["Grey Wall2"].Color = Color3.new(163,162,165)
			--mold["Grey Wall3"].Color = Color3.new(163,162,165)
			
			mold["Grey Wall"].Material = Enum.Material.Plastic
			mold["Grey Wall2"].Material = Enum.Material.Plastic
			mold["Grey Wall3"].Material = Enum.Material.Plastic
			
			mold["Grey Wall"].Transparency = 1
			mold["Grey Wall2"].Transparency = 1
			mold["Grey Wall3"].Transparency = 1
		
			
		end
	end



end)

--very bad code
ButtonRainYes.MouseButton1Up:Connect(function()
	isRaining = true
	
	
		workspace:WaitForChild("rainFolder"):WaitForChild("RainEffect1").RainParticle.Transparency = NumberSequence.new(0)
		workspace:WaitForChild("rainFolder"):WaitForChild("RainEffect2").RainParticle.Transparency = NumberSequence.new(0)
		workspace:WaitForChild("rainFolder"):WaitForChild("RainEffect3").RainParticle.Transparency = NumberSequence.new(0)
		workspace:WaitForChild("rainFolder"):WaitForChild("RainEffect4").RainParticle.Transparency = NumberSequence.new(0)
		
		workspace:WaitForChild("puddleFolder"):WaitForChild("Puddle1").Transparency = 0.2
		workspace:WaitForChild("puddleFolder"):WaitForChild("Puddle2").Transparency = 0.2
		workspace:WaitForChild("puddleFolder"):WaitForChild("Puddle3").Transparency = 0.2
		workspace:WaitForChild("puddleFolder"):WaitForChild("Puddle4").Transparency = 0.2
		workspace:WaitForChild("puddleFolder"):WaitForChild("Puddle5").Transparency = 0.2
		workspace:WaitForChild("puddleFolder"):WaitForChild("Puddle6").Transparency = 0.2
		workspace:WaitForChild("puddleFolder"):WaitForChild("Puddle7").Transparency = 0.2
		
		workspace:WaitForChild("puddleFolder"):WaitForChild("PuddleWall1").Transparency = 0.2
		workspace:WaitForChild("puddleFolder"):WaitForChild("PuddleWall2").Transparency = 0.2
		workspace:WaitForChild("puddleFolder"):WaitForChild("PuddleWall3").Transparency = 0.2
		workspace:WaitForChild("puddleFolder"):WaitForChild("PuddleWall4").Transparency = 0.2
		

end)


ButtonRainNo.MouseButton1Up:Connect(function()
	isRaining = false
	
	workspace:WaitForChild("rainFolder"):WaitForChild("RainEffect1").RainParticle.Transparency = NumberSequence.new(1)
	workspace:WaitForChild("rainFolder"):WaitForChild("RainEffect2").RainParticle.Transparency = NumberSequence.new(1)
	workspace:WaitForChild("rainFolder"):WaitForChild("RainEffect3").RainParticle.Transparency = NumberSequence.new(1)
	workspace:WaitForChild("rainFolder"):WaitForChild("RainEffect4").RainParticle.Transparency = NumberSequence.new(1)
	
	workspace:WaitForChild("puddleFolder"):WaitForChild("Puddle1").Transparency = 1
	workspace:WaitForChild("puddleFolder"):WaitForChild("Puddle2").Transparency = 1
	workspace:WaitForChild("puddleFolder"):WaitForChild("Puddle3").Transparency = 1
	workspace:WaitForChild("puddleFolder"):WaitForChild("Puddle4").Transparency = 1
	workspace:WaitForChild("puddleFolder"):WaitForChild("Puddle5").Transparency = 1
	workspace:WaitForChild("puddleFolder"):WaitForChild("Puddle6").Transparency = 1
	workspace:WaitForChild("puddleFolder"):WaitForChild("Puddle7").Transparency = 1
	
	workspace:WaitForChild("puddleFolder"):WaitForChild("PuddleWall1").Transparency = 1
	workspace:WaitForChild("puddleFolder"):WaitForChild("PuddleWall2").Transparency = 1
	workspace:WaitForChild("puddleFolder"):WaitForChild("PuddleWall3").Transparency = 1
	workspace:WaitForChild("puddleFolder"):WaitForChild("PuddleWall4").Transparency = 1

end)







