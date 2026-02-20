
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EasySlider = require(ReplicatedStorage:WaitForChild("Slider2"))

local Container = script.Parent
local Main = Container.Parent
local Button = Container:WaitForChild("Button")
local PercentLabel = Main:WaitForChild("PercentLabel")
local brightnessLabel = Main:WaitForChild("brightnessLabel")

local Music = workspace:WaitForChild("Music")
local Wall = workspace:WaitForChild("Wall")
local Mold = workspace.Folder:WaitForChild("Model")

local bulbFolder = workspace.bulbFolder


local particleEmitter = workspace.Air:WaitForChild("ParticleEmitter")


local Slider = EasySlider.new(Button, Container, 0.5) 
Slider:SetPercent(1) -- 100%

--Slider:SetRange(5)
--Slider.RangeEnabled = true

Slider.PercentChanged:Connect(function(Percent)
	--Music.Volume = Percent * 0.5 -- 0.5 is the maximum volume
	
	
	
	
	--changing the darn color
	Wall.Color = Color3.new(Percent,Percent,Percent) --keep all 3 at positive percent
	
	--changing the mold
	for i, mold in pairs(workspace.Folder:GetChildren()) do
		mold["Grey Wall"].Color = Color3.new(Percent,Percent, Percent)
		mold["Grey Wall2"].Color = Color3.new(Percent,Percent, Percent)
		mold["Grey Wall3"].Color = Color3.new(Percent,Percent, Percent)

	end
	
	-- changing the bulb brightness
	for i, bulb in pairs(workspace.bulbFolder:GetChildren()) do
		bulb.Model.Bulb["PointLight"].Range = Slider:GetValue() - 20
	end
	
	--Mold["Grey Wall"].Color = Color3.new(Percent, Percent, Percent)

	
	
	
	
	
	local RoundedPercent = math.floor(Percent * 100)
	PercentLabel.Text = string.format(
		"Brightness: %s%%", tostring(RoundedPercent)
	)
	
	brightnessLabel.Text = string.format(
		"Brightness (EV): %s%%", tostring(RoundedPercent/25)
	)
	
	
	
	
	Slider.MinValue = -50
	Slider.MaxValue = 50
	print(Slider:GetValue())
	-- the %s means put the string there, the %% is one percent sign
	
	
	
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