-- https://lua.expert/
local t = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

game:GetService("TweenService")
game:GetService("Players")

local Debris = game:GetService("Debris")
local Resources = ReplicatedStorage:WaitForChild("Resources")
local Modules = ReplicatedStorage:WaitForChild("Modules")

ReplicatedStorage:WaitForChild("Remotes")

local Sounds = ReplicatedStorage:WaitForChild("Sounds")
local GlobalFunctions = require(Modules:WaitForChild("GlobalFunctions"))
local Counter = require(Modules.Counter)

workspace:WaitForChild("PlayerFolder")
workspace:WaitForChild("EffectsFolder")
workspace:WaitForChild("PlayerFolder")
workspace:WaitForChild("EnemyFolder")

local EffectsFolder = workspace:WaitForChild("EffectsFolder")
local v1 = Random.new()
local v2 = RaycastParams.new()

v2.FilterType = Enum.RaycastFilterType.Include
v2.FilterDescendantsInstances = { workspace.CurrentMap, workspace.MapWalls }
function t.Melee(p1, p2, p3) --[[ Line: 35 | Upvalues: GlobalFunctions (copy), v2 (copy), Resources (copy), EffectsFolder (copy), Debris (copy), Sounds (copy), v1 (copy) ]]
	local HumanoidRootPart = p1.Character.HumanoidRootPart
	local v12 = p2[1]
	local v22 = p2[2]
	local HrpCF = p3.HrpCF
	local v3 = p1:GetAttribute("Weapon")
	local v4 = if v3 == "Staff" then 0.3 else 0.15

	if v3 == "Nothing" then
		v4 = 0.05
	end

	if v3 == "Buster" then
		v4 = 0
	end

	if p1:GetAttribute("Swiftness") == true then
		v4 = v4 / 2
	end

	local v5 = v4 - p1:GetNetworkPing()

	if v3 == "Buster" then
		if workspace:Raycast(HumanoidRootPart.Position, Vector3.new(0, -5, 0), v2) then
			GlobalFunctions.AddCooldown(p1, v5, "BusterGroundMelee", false)
		else
			GlobalFunctions.AddCooldown(p1, v5, "BusterAirMelee", false)
		end
	else
		GlobalFunctions.AddCooldown(p1, v5, "Melee", false)
	end

	if v3 == "Nothing" then
		GlobalFunctions.PlaySound(Sounds.PlayerBarrage, HumanoidRootPart, v1:NextNumber(0.9, 1.1))
	elseif v3 ~= "Buster" then
		task.spawn(function() --[[ Line: 70 | Upvalues: Resources (ref), HrpCF (copy), p1 (copy), EffectsFolder (ref), Debris (ref) ]]
			local v1 = Resources.PlayerSlashes:Clone()

			v1.CFrame = HrpCF + HrpCF.LookVector * 5
			v1.Name = p1.Name .. "Slashes"
			v1.Parent = EffectsFolder
			task.wait()
			v1.Particles:Emit(2)
			Debris:AddItem(v1, 0.5)
		end)
		GlobalFunctions.PlaySound(Sounds.MeleeSwing, HumanoidRootPart, v1:NextNumber(0.9, 1.1))
	end

	if #v12 > 0 then
		local count = 0

		for k, v in pairs(v12) do
			local v6 = v.PrimaryPart or v:FindFirstChildOfClass("BasePart")

			if v6 ~= nil and (v6.Position - HrpCF.Position).Magnitude <= 40 + v6.Size.Magnitude then
				local v7 = if v3 == "Buster" then 100 else 12

				if v3 == "Nothing" then
					v7 = 5
				end

				if p1:GetAttribute("Overcharge") then
					v7 = v7 * (1 * (p1:GetAttribute("Overcharge") / 6 + 1))
					p1:SetAttribute("Overcharge", (math.clamp(p1:GetAttribute("Overcharge") - 0.6, 0, 3)))
				end

				if v:GetAttribute("Health") > 0 then
					count = count + 1

					local v9 = if v3 == "Nothing" then 2 else 5

					if v3 == "Buster" then
						v9 = 40
					end

					p1:SetAttribute("Score", p1:GetAttribute("Score") + v9)
				end

				GlobalFunctions.DamageEnemy(p1, v, v7)
				GlobalFunctions.HitMarker(v, "Melee")

				if v3 == "Buster" then
					GlobalFunctions.StopSound(Sounds.BusterMeleeSwing, HumanoidRootPart)
					GlobalFunctions.PlaySound(Sounds.BusterMeleeHit, HumanoidRootPart, v1:NextNumber(0.9, 1.1))

					continue
				end

				GlobalFunctions.PlaySound(Sounds["MeleeHit" .. math.random(1, 3)], HumanoidRootPart, v1:NextNumber(0.9, 1.1))
			end
		end

		if v3 ~= "Nothing" then
			local t = { "", "double", "triple", "quad", "quintuple" }

			if count == 1 then
				GlobalFunctions.AddStreak(p1, 4, "melee hit")
			elseif count > 1 and count <= 4 then
				GlobalFunctions.AddStreak(p1, count * 4, t[count] .. " melee hit")
			elseif count > 5 then
				GlobalFunctions.AddStreak(p1, count * 4, "melee-ception!")
			end
		end

		GlobalFunctions.CheckScore(p1)
		GlobalFunctions.ScoreLabels(p1)
	end

	if not (#v22 > 0) then
		return
	end

	for v10, v11 in v22 do
		if v11:GetAttribute("Meleeable") == true then
			v11:SetAttribute("MeleeingPlayer", p1.Name)

			if v11:GetAttribute("MeleeId") == nil then
				v11:SetAttribute("MeleeId", 0)

				continue
			end

			v11:SetAttribute("MeleeId", v11:GetAttribute("MeleeId") + 1)
		end
	end
end
function t.HomeStrike(p1, p2, p3) --[[ Line: 177 | Upvalues: GlobalFunctions (copy) ]]
	if p1:GetAttribute("Weapon") ~= "Katana" then
		return
	end

	GlobalFunctions.AddCooldown(p1, 3 - p1:GetNetworkPing(), "HomeStrike", false)

	local HumanoidRootPart = p1.Character.HumanoidRootPart
	local v1 = p2[1]
	local HrpCF = p3.HrpCF

	if not (#v1 > 0) then
		return
	end

	local v2 = nil
	local count = 0

	for k, v in pairs(v1) do
		if k == 1 then
			v2 = v.PrimaryPart.Position
		end

		if (v.PrimaryPart.Position - v2).Magnitude <= 40 + v.PrimaryPart.Size.Magnitude then
			local v3 = 24

			if p1:GetAttribute("Overcharge") then
				v3 = v3 * (1 * (p1:GetAttribute("Overcharge") / 6 + 1))
				p1:SetAttribute("Overcharge", (math.clamp(p1:GetAttribute("Overcharge") - 0.6, 0, 3)))
			end

			GlobalFunctions.DamageEnemy(p1, v, v3)
			GlobalFunctions.HitMarker(v, "Melee")

			if v:GetAttribute("Health") > 0 then
				p1:SetAttribute("Score", p1:GetAttribute("Score") + 5)
				count = count + 1
			end

			continue
		end

		print("HOMING STRIKE CHEATER ALERRTTTTTTTTTT")
	end

	if count > 0 then
		GlobalFunctions.AddStreak(p1, 13, "homing... STRIKE!")
	end

	GlobalFunctions.CheckScore(p1)
	GlobalFunctions.ScoreLabels(p1)
end
function t.Counter(p1) --[[ Line: 234 | Upvalues: Counter (copy) ]]
	Counter[p1:GetAttribute("CounterType")](p1)
end

return t