-- https://lua.expert/
local t = {}
local t2 = {}
local t3 = {}

setmetatable(t2, {
	__mode = "k"
})
setmetatable(t3, {
	__mode = "k"
})

local function BuildCache(p1) --[[ BuildCache | Line: 11 | Upvalues: t3 (copy) ]]
	for v1, v2 in p1:GetDescendants() do
		if v2:IsA("Motor6D") and v2:GetAttribute("DefaultC0") == nil then
			v2:SetAttribute("DefaultC0", v2.C0)
		end
	end

	table.insert(t3, p1)
end

local function DisplayFrame(p1, p2, p3) --[[ DisplayFrame | Line: 30 ]]
	local Torso = p1.Torso
	local RootJoint = p1.HumanoidRootPart.RootJoint
	local v1 = Torso:FindFirstChild("Right Shoulder")
	local v2 = Torso:FindFirstChild("Left Shoulder")
	local v3 = Torso:FindFirstChild("Right Hip")
	local v4 = Torso:FindFirstChild("Left Hip")
	local Neck = Torso.Neck

	for k, v in pairs(p2:GetKeyframes()) do
		if v.Time == p3 then
			if v.HumanoidRootPart.Torso.CFrame.Position.Magnitude > 0.01 or Vector3.new(v.HumanoidRootPart.Torso.CFrame:ToEulerAnglesXYZ()).Magnitude > 0.01 then
				RootJoint.C0 = CFrame.Angles(1.5707963267948966, math.pi, 0) * v.HumanoidRootPart.Torso.CFrame
			end

			if v.HumanoidRootPart.Torso:FindFirstChild("Right Arm") then
				v1.C0 = v1:GetAttribute("DefaultC0") * v.HumanoidRootPart.Torso["Right Arm"].CFrame
			end

			if v.HumanoidRootPart.Torso:FindFirstChild("Left Arm") then
				v2.C0 = v2:GetAttribute("DefaultC0") * v.HumanoidRootPart.Torso["Left Arm"].CFrame
			end

			if v.HumanoidRootPart.Torso:FindFirstChild("Right Leg") then
				v3.C0 = v3:GetAttribute("DefaultC0") * v.HumanoidRootPart.Torso["Right Leg"].CFrame
			end

			if v.HumanoidRootPart.Torso:FindFirstChild("Left Leg") then
				v4.C0 = v4:GetAttribute("DefaultC0") * v.HumanoidRootPart.Torso["Left Leg"].CFrame
			end

			if v.HumanoidRootPart.Torso:FindFirstChild("Head") then
				Neck.C0 = Neck:GetAttribute("DefaultC0") * v.HumanoidRootPart.Torso.Head.CFrame
			end

			local t = { "HumanoidRootPart", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg", "Head" }

			for v9, v10 in v:GetDescendants() do
				local v6, v7, v8

				if v10:IsA("Pose") and not table.find(t, v10.Name) then
					local v11 = nil

					for v12, v13 in p1:GetDescendants() do
						if v13:IsA("Motor6D") and v13.Name == v10.Name then
							v11 = v13
						end
					end

					if v11 then
						local v14, v15, v16 = v10.CFrame:ToEulerAngles()

						v6 = v14
						v7 = v15
						v8 = v16
					else
						v6 = nil
						v7 = nil
						v8 = nil
					end

					if v11 and (v10.CFrame.Position.Magnitude > 0.01 or (v6 ~= 0 or (v7 ~= 0 or v8 ~= 0))) then
						local identity = CFrame.identity

						if v11:GetAttribute("DefaultC0") ~= nil then
							identity = v11:GetAttribute("DefaultC0")
						end

						v11.C0 = identity * v10.CFrame
					end
				end
			end
		end
	end
end

function t.Animate(p1, p2, p3) --[[ Line: 112 | Upvalues: t3 (copy), BuildCache (copy), t2 (copy), DisplayFrame (copy) ]]
	task.spawn(function() --[[ Line: 115 | Upvalues: t3 (ref), p1 (copy), BuildCache (ref), t2 (ref), DisplayFrame (ref), p2 (copy), p3 (copy) ]]
		if not table.find(t3, p1) then
			BuildCache(p1)
		end

		for k, v in pairs(t2) do

		end

		local v1 = math.random(10000000, 99999999)

		t2[p1] = v1

		local v2 = 0

		DisplayFrame(p1, p2, v2)

		for k, v in pairs(p2:GetKeyframes()) do
			if t2[p1] ~= v1 then
				return
			end

			local v3 = (1 / 0)

			for k2, v4 in pairs(p2:GetKeyframes()) do
				if v2 < v4.Time and v4.Time < v3 then
					v3 = v4.Time
				end
			end

			if v3 - v2 < (1 / 0) and (p3 and p3 == true) then
				task.wait((v3 - v2) / workspace:GetAttribute("TimeScale"))
			elseif v3 - v2 < (1 / 0) then
				task.wait(v3 - v2)
			end

			DisplayFrame(p1, p2, v3)
			v2 = v3
		end

		if not table.find(t2, v1) then
			return
		end

		table.remove(t2, table.find(t2, v1))
	end)
end

return t