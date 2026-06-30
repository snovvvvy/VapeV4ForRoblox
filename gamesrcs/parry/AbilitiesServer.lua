-- https://lua.expert/
local t = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Animations = ReplicatedStorage:WaitForChild("Animations")
local Resources = ReplicatedStorage:WaitForChild("Resources")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Sounds = ReplicatedStorage:WaitForChild("Sounds")
local LocalEvent = Remotes:WaitForChild("LocalEvent")
local GlobalFunctions = require(Modules.GlobalFunctions)

workspace:WaitForChild("PlayerFolder")
workspace:WaitForChild("EnemyFolder")

local EffectsFolder = workspace:WaitForChild("EffectsFolder")

RaycastParams.new().FilterType = Enum.RaycastFilterType.Exclude
function t.Ability(p1, p2, p3) --[[ Line: 24 | Upvalues: t (copy) ]]
	if not (p2:GetAttribute("AbilityCooldown") > 0) and (p2:GetAttribute("CanAttack") ~= false and (p2.Character.Humanoid.Health ~= 0 and p2:GetAttribute("Taunting") ~= true)) then
		t[p1](p2, p3)
	end
end
function t.Lunge(p1, p2) --[[ Line: 33 | Upvalues: Resources (copy), EffectsFolder (copy), Debris (copy), GlobalFunctions (copy), LocalEvent (copy), Animations (copy), Sounds (copy) ]]
	local Character = p1.Character
	local HumanoidRootPart = Character.HumanoidRootPart
	local v1 = p2[1]

	task.spawn(function() --[[ Line: 40 | Upvalues: Resources (ref), HumanoidRootPart (copy), p1 (copy), EffectsFolder (ref), Debris (ref) ]]
		local v1 = Resources.LungePart:Clone()

		v1.CFrame = HumanoidRootPart.CFrame
		v1.Name = p1.Name .. "Lunge"
		v1.Parent = EffectsFolder
		task.wait()
		v1.Particles:Emit(30)
		Debris:AddItem(v1, 0.5)
	end)
	print("BOM")

	if #v1 > 0 then
		local count = 0

		for k, v in pairs(v1) do
			if (v.PrimaryPart.Position - p1.Character.HumanoidRootPart.Position).Magnitude <= 35 + v.PrimaryPart.Size.Magnitude then
				GlobalFunctions.DamageEnemy(p1, v, 80)
				GlobalFunctions.HitMarker(v, "CounterSwing")
				count = count + 1

				continue
			end

			print("LUNGE CHEATER ALERRTTTTTTTTTT")
		end

		local t = { "", "double", "triple", "quad", "quintuple" }

		if count == 1 then
			GlobalFunctions.AddStreak(p1, 60, "lunge hit")
		elseif count > 1 and count <= 4 then
			GlobalFunctions.AddStreak(p1, count * 60, t[count] .. " lunge hit")
		elseif count > 4 then
			GlobalFunctions.AddStreak(p1, count * 60, "LINED UP!")
		end

		GlobalFunctions.CheckScore(p1)
		GlobalFunctions.ScoreLabels(p1)
	end

	p1:SetAttribute("AbilityCooldown", 7)
	LocalEvent:FireClient(p1, "AbilityUsed")

	local v2 = Character.Humanoid.Animator:LoadAnimation(Animations.AbilityLunge)

	v2:Play(0)
	GlobalFunctions.PlaySound(Sounds.Lunge, HumanoidRootPart)
	task.wait(0.35)
	v2:Stop(0)
end
function t.SwapSummon(p1) --[[ Line: 103 | Upvalues: LocalEvent (copy) ]]
	local HumanoidRootPart = p1.Character.HumanoidRootPart

	if p1:GetAttribute("AllyType") == "Linked Sword" then
		p1:SetAttribute("AllyType", "Rally")
		p1:SetAttribute("AllyCost", 10)
	elseif p1:GetAttribute("AllyType") == "Rally" then
		p1:SetAttribute("AllyType", "Pulser")
		p1:SetAttribute("AllyCost", 4)
	elseif p1:GetAttribute("AllyType") == "Pulser" then
		p1:SetAttribute("AllyType", "Linked Sword")
		p1:SetAttribute("AllyCost", 5)
	end

	LocalEvent:FireClient(p1, "AbilityUsed")
end

return t