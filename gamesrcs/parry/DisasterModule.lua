-- https://lua.expert/
local t = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

ReplicatedStorage:WaitForChild("Resources")
ReplicatedStorage:WaitForChild("Modules")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Sounds = ReplicatedStorage:WaitForChild("Sounds")
local LocalEvent = Remotes:WaitForChild("LocalEvent")
local PlayerFolder = workspace:WaitForChild("PlayerFolder")
local EffectsFolder = workspace:WaitForChild("EffectsFolder")

RaycastParams.new().FilterType = Enum.RaycastFilterType.Exclude
function PlaySound(p1, p2) --[[ PlaySound | Line: 25 | Upvalues: Debris (copy) ]]
	local v1 = p1:Clone()

	v1.Parent = p2
	v1:Play()
	Debris:AddItem(v1, v1.TimeLength)
end

local function WarningLabel(p1, p2) --[[ WarningLabel | Line: 33 | Upvalues: PlayerFolder (copy), Players (copy), TweenService (copy), LocalEvent (copy), Sounds (copy) ]]
	for k, v in pairs(PlayerFolder:GetChildren()) do
		task.spawn(function() --[[ Line: 35 | Upvalues: Players (ref), v (copy), TweenService (ref), p1 (copy), LocalEvent (ref), p2 (copy), Sounds (ref) ]]
			local v1 = Players:GetPlayerFromCharacter(v)
			local MainGui = v1.PlayerGui.MainGui
			local DisasterWarningBackground = MainGui.DisasterWarningBackground
			local DisasterLabel = DisasterWarningBackground.DisasterWarningMiddle.DisasterLabel
			local WhiteCover = MainGui.WhiteCover

			WhiteCover.BackgroundTransparency = 0
			TweenService:Create(WhiteCover, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
				BackgroundTransparency = 1
			}):Play()
			DisasterWarningBackground.Visible = true
			DisasterLabel.Text = p1
			LocalEvent:FireClient(v1, "Rain", { p2 })
			LocalEvent:FireClient(v1, "CameraShake", { 80, 600 })
			LocalEvent:FireClient(v1, "PlaySound", { Sounds.WARNING, nil })
			task.wait(6)

			local t = {
				Position = UDim2.fromScale(0, 1.5)
			}

			TweenService:Create(DisasterWarningBackground, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), t):Play()
			task.wait(1)
			DisasterWarningBackground.Visible = false
			DisasterWarningBackground.Position = UDim2.fromScale(0, 0.9)
		end)
	end
end

function t.OperationDisaster() --[[ Line: 70 | Upvalues: WarningLabel (copy), EffectsFolder (copy), PlayerFolder (copy), Players (copy), LocalEvent (copy), Sounds (copy), TweenService (copy) ]]
	task.spawn(function() --[[ Line: 71 | Upvalues: WarningLabel (ref), EffectsFolder (ref), PlayerFolder (ref), Players (ref), LocalEvent (ref), Sounds (ref), TweenService (ref) ]]
		WarningLabel("OMG PILLARS ARE COMING OUT THE GROUND RUN FOR YOUR LIFE", true)
		task.wait(4)

		for i = 1, 15 do
			task.spawn(function() --[[ Line: 81 | Upvalues: EffectsFolder (ref), PlayerFolder (ref), Players (ref), LocalEvent (ref), Sounds (ref), TweenService (ref) ]]
				local Pillar = Instance.new("Part", EffectsFolder)

				Pillar.Anchored = true
				Pillar.Size = Vector3.new(50, 1000, 50)
				Pillar.Name = "Pillar"

				repeat
					local v1 = math.random(-250, 250)

					Pillar.Position = Vector3.new(v1, 450, math.random(-250, 250))

					local count = 0

					for k, v in pairs((workspace:GetPartsInPart(Pillar))) do
						if v.Name == "Pillar" or v.Name == "SpawnLocation" then
							count = count + 1
						end
					end
				until count == 0

				Pillar.CanCollide = false
				Pillar.CanQuery = false
				Pillar.CanTouch = false
				Pillar.Color = Color3.fromRGB(255, 0, 0)
				Pillar.Transparency = 0.5
				Pillar.CastShadow = false
				task.wait(3)

				for k, v in pairs((workspace:GetPartsInPart(Pillar))) do
					if v.Name == "HumanoidRootPart" then
						if v.Parent:GetAttribute("CombatTag") then
							v.Parent:SetAttribute("CombatTag", nil)
						end

						v.Parent.Humanoid:TakeDamage(1000)
					end
				end

				Pillar.Material = Enum.Material.Slate
				Pillar.Color = Color3.fromRGB(86, 86, 86)
				Pillar.Transparency = 0
				Pillar.CastShadow = true

				for k, v in pairs(PlayerFolder:GetChildren()) do
					local ok, result = pcall(function() --[[ Line: 130 | Upvalues: Players (ref), v (copy), LocalEvent (ref), Sounds (ref) ]]
						local v1 = Players:GetPlayerFromCharacter(v)

						LocalEvent:FireClient(v1, "CameraShake", { 5, 50 })
						LocalEvent:FireClient(v1, "PlaySound", { Sounds.PillarAppear, nil })
					end)

					if not ok then
						warn("Error caught while a pillar was appearing, error is: " .. tostring(result))
					end
				end

				task.wait(0.3)
				Pillar.Parent = workspace
				Pillar.CanCollide = true
				Pillar.CanQuery = true
				Pillar.CanTouch = true
				task.wait(10)
				TweenService:Create(Pillar, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
					Position = Pillar.Position + Vector3.new(0, -1100, 0)
				}):Play()
				task.wait(2)
				Pillar:Destroy()
			end)
			task.wait(math.random(2, 5) / 10)
		end

		task.wait(15)

		for k, v in pairs(PlayerFolder:GetChildren()) do
			local _, result = pcall(function() --[[ Line: 163 | Upvalues: Players (ref), v (copy), LocalEvent (ref) ]]
				LocalEvent:FireClient(Players:GetPlayerFromCharacter(v), "Rain", { false })
			end)

			if result then
				warn("Error caught while starting rain, error is: " .. tostring(result))
			end
		end
	end)
end

return t