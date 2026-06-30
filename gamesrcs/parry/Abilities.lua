-- https://lua.expert/
local t = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

ReplicatedStorage:WaitForChild("Animations")

local Resources = ReplicatedStorage:WaitForChild("Resources")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

ReplicatedStorage:WaitForChild("Sounds")

local LocalEvent = Remotes:WaitForChild("LocalEvent")
local GlobalFunctions = require(Modules.GlobalFunctions)

workspace:WaitForChild("PlayerFolder")

local EnemyFolder = workspace:WaitForChild("EnemyFolder")
local EffectsFolder = workspace:WaitForChild("EffectsFolder")

RaycastParams.new().FilterType = Enum.RaycastFilterType.Exclude
function t.Lunge(p1) --[[ Line: 24 | Upvalues: GlobalFunctions (copy), Resources (copy), EffectsFolder (copy), Debris (copy), EnemyFolder (copy), LocalEvent (copy) ]]
	local HumanoidRootPart = p1.Character.HumanoidRootPart
	local CurrentCamera = workspace.CurrentCamera

	GlobalFunctions.LinearVel(HumanoidRootPart.RootAttachment, HumanoidRootPart.CFrame.LookVector * Vector3.new(200, 0, 200), 0.05)
	task.spawn(function() --[[ Line: 30 | Upvalues: Resources (ref), HumanoidRootPart (copy), EffectsFolder (ref), Debris (ref), p1 (copy) ]]
		local v1 = Resources.LungePart:Clone()

		v1.CFrame = HumanoidRootPart.CFrame
		v1.Parent = EffectsFolder
		task.wait()
		v1.Particles:Emit(30)
		Debris:AddItem(v1, 0.5)
		EffectsFolder:WaitForChild(p1.Name .. "Lunge"):Destroy()
	end)

	local t = {}

	for k, v in pairs((workspace:GetPartBoundsInBox(HumanoidRootPart.CFrame + HumanoidRootPart.CFrame.LookVector * 20, Vector3.new(9, 9, 40)))) do
		GlobalFunctions.Destruct(p1, v, 1)

		if v.Parent.Parent == EnemyFolder and (v.Parent:IsA("Model") and (v.Parent.PrimaryPart == v and v.Parent:GetAttribute("Health") > 0)) then
			table.insert(t, v.Parent)
		end
	end

	LocalEvent:FireServer("Ability", { t })
end
function t.SwapSummon(p1) --[[ Line: 66 | Upvalues: LocalEvent (copy) ]]
	LocalEvent:FireServer("Ability")
end

return t