-- https://lua.expert/
local t = {}
local ContextActionService = game:GetService("ContextActionService")

game:GetService("ContentProvider")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

game:GetService("SoundService")

local BadgeService = game:GetService("BadgeService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ModifiersActive = ReplicatedStorage:WaitForChild("ModifiersActive")

ReplicatedStorage:WaitForChild("BossIntros")

local Animations = ReplicatedStorage:WaitForChild("Animations")
local Resources = ReplicatedStorage:WaitForChild("Resources")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Sounds = ReplicatedStorage:WaitForChild("Sounds")
local Stages = ReplicatedStorage:WaitForChild("Stages")
local Bosses = ReplicatedStorage:WaitForChild("Bosses")

ReplicatedStorage:WaitForChild("Jungle"):WaitForChild("SpecialWaves")

local LocalEvent = Remotes:WaitForChild("LocalEvent")
local CherryGarcia = Remotes:WaitForChild("CherryGarcia")
local ServerToServer = Remotes:WaitForChild("ServerToServer")
local v1 = nil
local v2 = nil
local v3 = nil
local v4 = nil
local GifPlayer = require(Modules.GifPlayer)
local PlayerFolder = workspace:WaitForChild("PlayerFolder")
local EnemyFolder = workspace:WaitForChild("EnemyFolder")
local EffectsFolder = workspace:WaitForChild("EffectsFolder")
local Songs = workspace:WaitForChild("Songs")
local v5 = Random.new()
local v6 = RaycastParams.new()

v6.FilterType = Enum.RaycastFilterType.Include
v6.FilterDescendantsInstances = { workspace.CurrentMap }

local t2 = {}
local t3 = {}
local t4 = {}

function qb(p1, p2, p3, p4) --[[ qb | Line: 63 ]]
	return (1 - p1) ^ 2 * p2 + 2 * (1 - p1) * p1 * p3 + p1 ^ 2 * p4
end
function t.Setup() --[[ Line: 69 | Upvalues: v1 (ref), Modules (copy), v2 (ref), v3 (ref), v4 (ref) ]]
	v1 = require(Modules.AnimateModule)
	v2 = require(Modules.Movement)
	v3 = require(Modules.DeathEffects)
	v4 = require(Modules.BadgePopupModule)
end
function t.PlaySound(p1, p2, p3, p4) --[[ Line: 94 | Upvalues: RunService (copy), LocalEvent (copy) ]]
	if RunService:IsServer() then
		LocalEvent:FireAllClients("PlaySound", { p1, p2, p3, p4 })
	end

	if not RunService:IsClient() then
		return
	end

	local v1 = p1:Clone()

	v1.Parent = p2

	if p3 then
		v1.PlaybackSpeed = math.clamp(v1.PlaybackSpeed * math.clamp(p3, 0.01, 20), 0.01, 20)
	end

	local PlaybackSpeed = v1.PlaybackSpeed

	if p4 ~= false then
		task.spawn(function() --[[ Line: 130 | Upvalues: v1 (copy), PlaybackSpeed (copy) ]]
			while v1.Parent ~= nil do
				if v1:GetAttribute("Updating") == true then
					break
				end

				local v2 = math.clamp(workspace:GetAttribute("TimeScale"), 0.2, 1)

				v1.PlaybackSpeed = math.clamp((v1:GetAttribute("Speed") or PlaybackSpeed) * v2, 0.01, 20)
				task.wait(0.01)
			end
		end)
	end

	v1:Play()

	local v4 = nil

	v1.Ended:Once(function() --[[ Line: 159 | Upvalues: v4 (ref), v1 (copy) ]]
		v4:Disconnect()
		v1:Destroy()
	end)
	v4 = p2.Destroying:Once(function() --[[ Line: 167 | Upvalues: v1 (copy) ]]
		v1:Destroy()
	end)

	return v1
end
function t.UpdateSound(p1, p2, p3, p4, p5, p6) --[[ Line: 181 | Upvalues: RunService (copy), LocalEvent (copy), Players (copy), Sounds (copy), t (copy) ]]
	if RunService:IsServer() then
		LocalEvent:FireAllClients("UpdateSound", { p1, p2, p3, p4, p5, p6 })
	end

	if not RunService:IsClient() then
		return
	end

	local LocalPlayer = Players.LocalPlayer
	local v1 = p2:FindFirstChild(p1.Name)

	if not v1 then
		return
	end

	local v2 = workspace:GetAttribute("TimeScale")
	local v3 = Sounds:FindFirstChild(p1.Name)
	local v4, v5

	if v3 then
		v4 = v3.Volume
		v5 = v3.PlaybackSpeed
	else
		v4 = 1
		v5 = 1
	end

	if p6 == false then
		if p5 > 0 then
			local v6 = math.random(1000000, 9999999)

			v1:SetAttribute("Updating", true)
			v1:SetAttribute("UpdateId", v6)
			t.Tween(v1, {
				Volume = v4 * p3 * LocalPlayer:GetAttribute("SoundEffectsVolume"),
				PlaybackSpeed = v5 * p4 * workspace:GetAttribute("TimeScale")
			}, TweenInfo.new(p5, Enum.EasingStyle.Linear, Enum.EasingDirection.In))

			local v7 = time()
			local v8 = nil

			v8 = RunService.Heartbeat:Connect(function() --[[ Line: 238 | Upvalues: v7 (copy), p5 (copy), v1 (copy), v6 (copy), v8 (ref) ]]
				if not (v7 + p5 < time()) and v1:GetAttribute("UpdateId") == v6 then
					v1:SetAttribute("Volume", v1.Volume)
					v1:SetAttribute("Speed", v1.PlaybackSpeed)

					return
				end

				v8:Disconnect()

				if v1:GetAttribute("UpdateId") ~= v6 then
					return
				end

				v1:SetAttribute("Updating", false)
			end)
		else
			v1.Volume = v4 * p3 * LocalPlayer:GetAttribute("SoundEffectsVolume")
			v1.PlaybackSpeed = v5 * p4
		end
	elseif p5 > 0 then
		local v9 = math.random(1000000, 9999999)

		v1:SetAttribute("Updating", true)
		v1:SetAttribute("UpdateId", v9)
		t.Tween(v1, {
			Volume = v4 * p3 * LocalPlayer:GetAttribute("SoundEffectsVolume") * v2,
			PlaybackSpeed = v5 * p4 * workspace:GetAttribute("TimeScale") * v2
		}, TweenInfo.new(p5, Enum.EasingStyle.Linear, Enum.EasingDirection.In))

		local v10 = time()
		local v11 = nil

		v11 = RunService.Heartbeat:Connect(function() --[[ Line: 214 | Upvalues: v10 (copy), p5 (copy), v1 (copy), v9 (copy), v11 (ref) ]]
			if not (v10 + p5 < time()) and v1:GetAttribute("UpdateId") == v9 then
				v1:SetAttribute("Volume", v1.Volume)
				v1:SetAttribute("Speed", v1.PlaybackSpeed)

				return
			end

			v11:Disconnect()

			if v1:GetAttribute("UpdateId") ~= v9 then
				return
			end

			v1:SetAttribute("Updating", false)
		end)
	else
		v1.Volume = v4 * p3 * LocalPlayer:GetAttribute("SoundEffectsVolume") * v2
		v1.PlaybackSpeed = v5 * p4 * v2
	end

	v1:SetAttribute("Volume", v1.Volume)
	v1:SetAttribute("Speed", v1.PlaybackSpeed)
end
function t.StopSound(p1, p2) --[[ Line: 262 | Upvalues: RunService (copy), LocalEvent (copy) ]]
	if RunService:IsServer() then
		LocalEvent:FireAllClients("StopSound", { p1, p2 })
	end

	if not (RunService:IsClient() and p2:FindFirstChild(p1.Name)) then
		return
	end

	p2[p1.Name]:Destroy()
end
function t.RoundToNearest(p1, p2) --[[ Line: 278 ]]
	return math.floor((p1 + p2 / 2) / p2) * p2
end
function t.Wait(p1) --[[ Line: 307 | Upvalues: RunService (copy) ]]
	local sum, v2 = 0, if typeof(p1) == "number" and p1 then p1 else 0.01

	repeat
		sum = sum + RunService.Heartbeat:Wait() * workspace:GetAttribute("TimeScale")
	until v2 <= sum
end
function t.Debris(p1, p2) --[[ Line: 318 | Upvalues: RunService (copy) ]]
	local v1 = 0
	local v2 = nil

	v2 = RunService.Heartbeat:Connect(function(p12) --[[ Line: 321 | Upvalues: v1 (ref), p2 (copy), v2 (ref), p1 (copy) ]]
		v1 = v1 + p12 * workspace:GetAttribute("TimeScale")

		if not (p2 <= v1) then
			return
		end

		v2:Disconnect()
		p1:Destroy()
	end)
end

local t5 = {}

setmetatable(t5, {
	__mode = "k"
})
function t.Tween(p1, p2, p3, p4) --[[ Line: 459 | Upvalues: TweenService (copy), t5 (copy), RunService (copy) ]]
	local v2 = TweenService:Create(p1, p4 and TweenInfo.new(p3.Time / workspace:GetAttribute("TimeScale"), p3.EasingStyle, p3.EasingDirection) or p3, p2)

	v2:Play()

	if not t5[p1] then
		t5[p1] = {}
	end

	local tbl = {}

	for k, v in pairs(p2) do
		tbl[k] = true

		if t5[p1][k] then
			t5[p1][k].Tween:Pause()
		end

		local t = {}

		t.Id = (t5[p1][k] and t5[p1][k].Id or 0) + 1
		t.Tween = v2
		t5[p1][k] = t
	end

	local t = {}

	for k in pairs(tbl) do
		t[k] = t5[p1][k].Id
	end

	if p4 == true then
		local v5 = 0
		local v6 = workspace:GetAttribute("TimeScale")
		local v7 = false
		local v8 = nil

		v8 = RunService.Heartbeat:Connect(function(p12) --[[ Line: 505 | Upvalues: v5 (ref), v6 (ref), p3 (copy), v2 (ref), v8 (ref), tbl (copy), t5 (ref), p1 (copy), t (copy), v7 (ref), TweenService (ref), p2 (copy) ]]
			local v1 = workspace:GetAttribute("TimeScale")

			v5 = v5 + p12 * v6

			if v5 >= p3.Time or v2.PlaybackState == Enum.PlaybackState.Cancelled then
				v8:Disconnect()

				for k in pairs(tbl) do
					if t5[p1] and (t5[p1][k] and t5[p1][k].Id == t[k]) then
						t5[p1][k] = nil
					end
				end
			else
				if v7 then
					return
				end

				if v1 == v6 then
					return
				end

				v7 = true
				v6 = v1
				v2 = TweenService:Create(p1, TweenInfo.new((p3.Time - v5) / v1, p3.EasingStyle, p3.EasingDirection), p2)
				v2:Play()

				for k in pairs(tbl) do
					if t5[p1] and (t5[p1][k] and t5[p1][k].Id == t[k]) then
						t5[p1][k].Tween = v2
					end
				end

				task.wait()
				v7 = false
			end
		end)
	else
		task.delay(p3.Time + 0.1, function() --[[ Line: 566 | Upvalues: tbl (copy), t5 (ref), p1 (copy), t (copy) ]]
			for k in pairs(tbl) do
				if t5[p1] and (t5[p1][k] and t5[p1][k].Id == t[k]) then
					t5[p1][k] = nil
				end
			end
		end)
	end
end
function t.CancelTweens(p1) --[[ Line: 589 | Upvalues: t5 (copy) ]]
	if not t5[p1] then
		return
	end

	for k, v in pairs(t5[p1]) do
		if v.Tween then
			v.Tween:Pause()
			v.Tween:Destroy()
		end
	end

	t5[p1] = nil
end

local t6 = {}

setmetatable(t6, {
	__mode = "k"
})
function t.BezierCurve(p1, p2, p3, p4, p5, p6, p7, p8) --[[ Line: 607 | Upvalues: t6 (copy), RunService (copy) ]]
	local v1 = nil
	local v2 = 0

	if t6[p1] then
		local v3 = t6[p1]

		v3.Id = v3.Id + 1
	else
		t6[p1] = {}
		t6[p1].Id = 1
	end

	local Id = t6[p1].Id
	local v4 = nil

	v4 = RunService.Stepped:Connect(function(p12, p22) --[[ Line: 629 | Upvalues: p1 (copy), v4 (ref), t6 (ref), Id (copy), p8 (copy), v2 (ref), p2 (copy), p5 (copy), p3 (copy), p4 (copy), v1 (ref), p6 (copy), p7 (copy) ]]
		if p1.Parent == nil then
			v4:Disconnect()

			return
		end

		if not t6[p1] or t6[p1].Id ~= Id then
			v4:Disconnect()

			return
		end

		if p8 and p8 == true then
			p22 = p22 * workspace:GetAttribute("TimeScale")
		end

		v2 = v2 + p22

		local v12 = v2 / p2
		local v22

		if v12 >= 1 then
			local v3 = p5

			if typeof(p5) ~= "Vector3" and p5:IsA("BasePart") then
				v3 = p5.Position
			end

			local v5 = qb(1, p3, p4, v3)

			v4:Disconnect()
			v22 = v5
		else
			local v6 = p5

			if typeof(p5) ~= "Vector3" and p5:IsA("BasePart") then
				v6 = p5.Position
			end

			v22 = qb(v12, p3, p4, v6)
		end

		if not t6[p1] or t6[p1].Id ~= Id then
			v4:Disconnect()
		end

		if v22 == nil then
			return
		end

		v1 = p1.Position

		if p6 and p6 == true then
			if p7 and (p7 == true and v1 ~= nil) then
				p1:PivotTo(CFrame.lookAt(v22, v1) * CFrame.Angles(0, math.pi, 0))
			else
				p1.CFrame = CFrame.lookAt(v22, v22 + p1.CFrame.LookVector)
			end
		else
			p1.Position = v22
		end
	end)
end
function t.CancelBezierCurve(p1) --[[ Line: 685 | Upvalues: t6 (copy) ]]
	if not t6[p1] then
		return
	end

	t6[p1] = nil
end
function t.GetWorldSize(p1) --[[ Line: 695 ]]
	local v1 = p1.CFrame:VectorToWorldSpace(p1.Size)

	return Vector3.new(math.abs(v1.X), math.abs(v1.Y), (math.abs(v1.Z)))
end
function t.InputTable(p1, p2) --[[ Line: 701 ]]
	local t = { "F", "E", "Q", "CTRL", "T", "Z" }
	local t2 = { "Y", "L2", "B", "DPadDown", "DPadUp", "DPadLeft" }
	local t3 = { "TAP", "TAP", "TAP", "TAP", "TAP", "TAP" }

	if table.find(t, p2) and p1:GetAttribute("Device") == "Computer" then
		if t[table.find(t, p2)] == "F" then
			return p1:GetAttribute("ParryKeybind")
		end

		return t[table.find(t, p2)]
	end

	if table.find(t, p2) and p1:GetAttribute("Device") == "Controller" then
		return t2[table.find(t, p2)]
	end

	if table.find(t, p2) and p1:GetAttribute("Device") == "Mobile" then
		return t3[table.find(t, p2)]
	end
end
function t.GetPlayerKeybind(p1) --[[ Line: 732 | Upvalues: Players (copy) ]]
	local t = {}

	for v1, v2 in Enum.KeyCode:GetEnumItems() do
		t[v2.Name] = true
	end

	local v3 = Players.LocalPlayer:GetAttribute(p1 .. "Keybind")

	if v3 == nil then
		return nil
	end

	if t[v3] == nil then
		return Enum.UserInputType[v3]
	end

	return Enum.KeyCode[v3]
end
function t.BindAction(p1, p2, p3, p4) --[[ Line: 749 | Upvalues: t (copy), ContextActionService (copy) ]]
	local v1 = t.GetPlayerKeybind(p2)
	local v4 = if p4[1] then p4[1] else ""
	local v5, v6, v7, v8

	if p4[2] then
		v5 = p4[2]
		v6 = p1
		v7 = p3
		v8 = v1
	else
		v6 = p1
		v7 = p3
		v8 = v1
		v5 = ""
	end

	ContextActionService:BindAction(v6, v7, false, v8, v4, v5, if p4[3] then p4[3] else "")
end
function t.GetKeybindDown(p1) --[[ Line: 762 | Upvalues: t (copy), UserInputService (copy) ]]
	local v1 = t.GetPlayerKeybind(p1)

	if v1 == nil then
		return false
	end

	if tostring(v1.EnumType) == "KeyCode" then
		return UserInputService:IsKeyDown(v1)
	end

	return UserInputService:IsMouseButtonPressed(v1)
end
function t.AddCooldown(p1, p2, p3, p4) --[[ Line: 776 | Upvalues: t2 (copy), RunService (copy), ReplicatedStorage (copy), LocalEvent (copy) ]]
	if p2 <= 0 then
		return
	end

	if not t2[p1] then
		t2[p1] = {}
	end

	if t2[p1][p3] then
		t2[p1][p3] = p2
	else
		t2[p1][p3] = p2

		local v1 = nil

		v1 = RunService.Heartbeat:Connect(function(p12) --[[ Line: 785 | Upvalues: p4 (copy), ReplicatedStorage (ref), t2 (ref), p1 (copy), p3 (copy), v1 (ref) ]]
			if p4 and p4 == true then
				p12 = p12 * workspace:GetAttribute("TimeScale")
			end

			if ReplicatedStorage.ChaosData:FindFirstChild("HalvedCooldowns") then
				p12 = p12 * 2
			end

			local v12 = t2[p1]
			local v2 = p3

			v12[v2] = v12[v2] - p12

			if not (t2[p1][p3] <= 0) then
				return
			end

			t2[p1][p3] = nil
			v1:Disconnect()
		end)
	end

	if not RunService:IsServer() then
		return
	end

	LocalEvent:FireClient(p1, "SetCooldown", {
		p2,
		p3,
		p4,
		p1:GetNetworkPing() / 2
	})
end
function t.GetCooldown(p1, p2) --[[ Line: 813 | Upvalues: t2 (copy) ]]
	if t2[p1] then
		return t2[p1][p2]
	end

	return nil
end
function t.FloatingPointDemolisher(p1) --[[ Line: 826 ]]
	return string.format("%.3f", p1):gsub("%.?0+$", "")
end
function t.NumberToWord(p1, p2) --[[ Line: 838 ]]
	local t = {
		"One",
		"Two",
		"Three",
		"Four",
		"Five",
		"Six",
		"Seven",
		"Eight",
		"Nine",
		"Ten"
	}

	if p2 == true then
		return t[p1]
	end

	return ({
		"one",
		"two",
		"three",
		"four",
		"five",
		"six",
		"seven",
		"eight",
		"nine",
		"ten"
	})[p1]
end
function t.NetworkToServer(p1) --[[ Line: 845 ]]
	local _, _2 = pcall(function() --[[ Line: 846 | Upvalues: p1 (copy) ]]
		if p1:IsA("Model") then
			for k, v in pairs(p1:GetDescendants()) do
				if v:IsA("BasePart") and v.Anchored == false then
					v:SetNetworkOwner(nil)
				end
			end
		end

		if not p1:IsA("BasePart") or p1.Anchored ~= false then
			return
		end

		p1:SetNetworkOwner(nil)
	end)
end
function t.Timescaleify(p1) --[[ Line: 875 | Upvalues: RunService (copy) ]]
	local AssemblyLinearVelocity = p1.AssemblyLinearVelocity
	local AssemblyAngularVelocity = p1.AssemblyAngularVelocity
	local GravityAttachment = Instance.new("Attachment")

	GravityAttachment.Name = "GravityAttachment"
	GravityAttachment.Parent = p1

	local VectorForce = Instance.new("VectorForce")

	VectorForce.ApplyAtCenterOfMass = true
	VectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	VectorForce.Attachment0 = GravityAttachment
	VectorForce.Force = Vector3.new(0, 0, 0)
	VectorForce.Parent = p1

	local v1 = nil

	v1 = RunService.Stepped:Connect(function() --[[ Line: 891 | Upvalues: p1 (copy), v1 (ref), AssemblyLinearVelocity (ref), AssemblyAngularVelocity (ref), VectorForce (copy) ]]
		if p1.Parent == nil then
			v1:Disconnect()

			return
		end

		local v12 = workspace:GetAttribute("TimeScale")

		if v12 < 1 then
			AssemblyLinearVelocity = p1.AssemblyLinearVelocity / v12
			p1.AssemblyLinearVelocity = AssemblyLinearVelocity * v12
		end

		AssemblyAngularVelocity = p1.AssemblyAngularVelocity / v12
		p1.AssemblyAngularVelocity = AssemblyAngularVelocity * v12

		if v12 < 1 then
			VectorForce.Force = Vector3.new(0, p1.Mass * (workspace.Gravity / (1 + v12)), 0)

			return
		end

		if not (v12 > 1) then
			return
		end

		VectorForce.Force = Vector3.new(0, p1.Mass * -(workspace.Gravity * v12) / 2, 0)
	end)
end
function t.ConnectParticlesToTimescale(p1) --[[ Line: 913 ]]
	p1.TimeScale = workspace:GetAttribute("TimeScale")

	local v1 = nil

	v1 = workspace:GetAttributeChangedSignal("TimeScale"):Connect(function() --[[ Line: 926 | Upvalues: p1 (copy), v1 (ref) ]]
		if p1.Parent then
			p1.TimeScale = workspace:GetAttribute("TimeScale")
		else
			v1:Disconnect()
		end
	end)
	p1.Destroying:Connect(function() --[[ Line: 934 | Upvalues: v1 (ref) ]]
		v1:Disconnect()
	end)
end
function t.ConnectTrailToTimescale(p1) --[[ Line: 940 ]]
	local Lifetime = p1.Lifetime

	p1.Lifetime = Lifetime / workspace:GetAttribute("TimeScale")

	local v1 = nil

	v1 = workspace:GetAttributeChangedSignal("TimeScale"):Connect(function() --[[ Line: 957 | Upvalues: p1 (copy), Lifetime (copy), v1 (ref) ]]
		if p1.Parent then
			p1.Lifetime = Lifetime / workspace:GetAttribute("TimeScale")
		else
			v1:Disconnect()
		end
	end)
	p1.Destroying:Connect(function() --[[ Line: 965 | Upvalues: v1 (ref) ]]
		v1:Disconnect()
	end)
end
function t.ConnectAnimationToTimescale(p1) --[[ Line: 976 | Upvalues: RunService (copy) ]]
	if RunService:IsServer() then
		local v1 = false

		p1.Changed:Connect(function() --[[ Line: 980 | Upvalues: p1 (copy), v1 (ref) ]]
			if p1.IsPlaying ~= true or v1 ~= false then
				v1 = p1.IsPlaying

				return
			end

			p1:AdjustSpeed(workspace:GetAttribute("TimeScale"))
			v1 = p1.IsPlaying
		end)
	end

	local v2 = nil

	v2 = RunService.Heartbeat:Connect(function() --[[ Line: 991 | Upvalues: p1 (copy), v2 (ref) ]]
		if p1 == nil or p1.Parent == nil then
			v2:Disconnect()

			return
		end

		if p1.IsPlaying ~= true then
			return
		end

		p1:AdjustSpeed(workspace:GetAttribute("TimeScale"))
	end)
end
function t.CreateTempPart(p1, p2, p3) --[[ Line: 1004 | Upvalues: EffectsFolder (copy), Debris (copy) ]]
	local Part = Instance.new("Part", EffectsFolder)

	Part.Anchored = true
	Part.CanCollide = false
	Part.CFrame = p1
	Part.Size = p2
	Part.Color = Color3.fromRGB(255, 0, 0)
	Part.Transparency = 0.5
	Debris:AddItem(Part, p3)
end
function t.IntroText(p1, p2) --[[ Line: 1016 | Upvalues: Resources (copy) ]]
	local v1 = Resources.IntroGui:Clone()

	v1.Label.Text = p2

	if p1:IsA("Model") then
		if p1.PrimaryPart == nil then
			warn("cant add intro text to a model without a primary part bro")
		else
			v1.Parent = p1.PrimaryPart
		end

		if p1:GetAttribute("Health") ~= nil then
			local v2 = nil

			v2 = p1:GetAttributeChangedSignal("Health"):Connect(function() --[[ Line: 1029 | Upvalues: p1 (copy), v2 (ref), v1 (copy) ]]
				if not (p1:GetAttribute("Health") <= 0) then
					return
				end

				v2:Disconnect()
				v1:Destroy()
			end)
		end
	else
		v1.Parent = p1
	end
end
function t.SetBounds(p1, p2) --[[ Line: 1042 | Upvalues: t (copy), Resources (copy), RunService (copy), PlayerFolder (copy) ]]
	if workspace:FindFirstChild("Bounds") then
		local Bounds = workspace.Bounds
		local BoundsOutline = workspace.BoundsOutline

		t.Tween(Bounds, {
			Size = Vector3.new(500, p1 * 5, p1 * 5)
		}, TweenInfo.new(p2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), true)
		t.Tween(BoundsOutline, {
			Size = Vector3.new(1, p1, p1)
		}, TweenInfo.new(p2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), true)
	else
		local v1 = Resources.Bounds:Clone()

		v1.Size = Vector3.new(500, 1500, 1500)
		v1.Parent = workspace

		local v2 = Resources.BoundsOutline:Clone()

		v2.Size = Vector3.new(1, 300, 300)
		v2.Parent = workspace
		t.Tween(v1, {
			Size = Vector3.new(500, p1 * 5, p1 * 5)
		}, TweenInfo.new(p2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), true)
		t.Tween(v2, {
			Transparency = 0,
			Size = Vector3.new(1, p1, p1)
		}, TweenInfo.new(p2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), true)
	end

	local v3 = 0
	local v4 = nil

	v4 = RunService.Heartbeat:Connect(function(p12) --[[ Line: 1067 | Upvalues: v3 (ref), p2 (copy), v4 (ref), PlayerFolder (ref), p1 (copy) ]]
		v3 = v3 + p12

		if p2 <= v3 then
			v4:Disconnect()

			return
		end

		for k, v in pairs(PlayerFolder:GetChildren()) do
			if p1 * 5 < v.PrimaryPart.Position.Magnitude then
				v:PivotTo(CFrame.new(0, 3, 0))
			end
		end
	end)
end
function t.RemoveBounds() --[[ Line: 1081 | Upvalues: t (copy) ]]
	if not workspace:FindFirstChild("Bounds") then
		return
	end

	local Bounds = workspace.Bounds
	local BoundsOutline = workspace.BoundsOutline

	t.Tween(Bounds, {
		Size = Vector3.new(500, 2000, 2000)
	}, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), true)
	t.Tween(BoundsOutline, {
		Size = Vector3.new(1, 3000, 3000),
		Transparency = 1
	}, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), true)
	t.Debris(Bounds, 2)
	t.Debris(BoundsOutline, 2)
end
function t.StopAnimations(p1, p2) --[[ Line: 1094 ]]
	if p2 then
		for k, v in pairs(p1.Humanoid.Animator:GetPlayingAnimationTracks()) do
			if table.find(p2, v.Name) then
				v:Stop(0)
			end
		end
	else
		for k, v in pairs(p1.Humanoid.Animator:GetPlayingAnimationTracks()) do
			v:Stop(0)
		end
	end
end
function t.GetUpdatedPlayerPos(p1) --[[ Line: 1112 ]]
	if not p1 then
		warn("ya called GetUpdatedPlayerPos but didnt give a proper player.")

		return nil
	end

	local v1 = workspace:FindFirstChild(p1.Name .. "UpdatedPlayerPos")

	if v1 then
		return v1
	end

	warn("updated player pos for " .. p1.Name .. " could not be found.")

	return nil
end
function t.CFrameWithoutUpDown(p1) --[[ Line: 1126 ]]
	local Unit = Vector3.new(p1.LookVector.X, 0, p1.LookVector.Z).Unit

	if Unit.Magnitude == 0 then
		local v1 = p1 * CFrame.Angles(-0.017453292519943295, 0, 0)

		Unit = Vector3.new(v1.LookVector.X, 0, v1.LookVector.Z).Unit
	end

	return CFrame.lookAt(p1.Position, p1.Position + Unit)
end
function t.PosAtNewY(p1, p2) --[[ Line: 1142 ]]
	return Vector3.new(p1.X, p2.Y, p1.Z)
end
function t.PositiveOrNegative() --[[ Line: 1150 | Upvalues: v5 (copy) ]]
	if v5:NextInteger(1, 2) == 1 then
		return 1
	end

	return -1
end
function t.TurnTowardsTarget(p1, p2, p3, p4) --[[ Line: 1162 ]]
	local v1 = nil

	if typeof(p1) == "Instance" then
		v1 = p1:GetPivot()
	elseif typeof(p1) == "CFrame" then
		v1 = p1
	else
		warn("why are you using TurnTowardsTarget but not giving any part or cframe??")
	end

	local LookVector = v1.LookVector
	local Unit = (Vector3.new(p2.X, v1.Position.Y, p2.Z) - v1.Position).Unit

	if Unit ~= Unit then
		print("NAAAAAAAAAN")
		Unit = (Vector3.new(p2.X, v1.Position.Y, p2.Z + 0.1) - v1.Position).Unit
	end

	local v6 = math.acos((math.clamp(LookVector:Dot(Unit), -1, 1)))
	local v7 = math.rad(p3) * p4
	local v8

	if v6 <= v7 then
		v8 = Unit
	else
		local Unit2 = LookVector:Cross(Unit).Unit

		if Unit2.Magnitude == 0 then
			Unit2 = Vector3.new(0, 1, 0)
		end

		v8 = CFrame.fromAxisAngle(Unit2, v7) * LookVector
	end

	local Magnitude = (v1.Position - (v1.Position + v8)).Magnitude

	if Magnitude ~= Magnitude then
		print("NAN TWO!")

		return
	end

	if typeof(p1) == "Instance" then
		p1:PivotTo(CFrame.lookAt(v1.Position, v1.Position + v8))

		return
	end

	return CFrame.lookAt(v1.Position, v1.Position + v8)
end
function t.EnablePlaneConstraint(p1, p2) --[[ Line: 1216 | Upvalues: Resources (copy), Players (copy) ]]
	local v1 = p2 or 0

	if p1.PrimaryPart == nil then
		warn("NO PRIMARY FOR PLANE CONSTRAINT!!")

		return
	end

	if p1.PrimaryPart:FindFirstChild("PlaneConstraint") then
		return
	end

	if workspace:FindFirstChild("PlaneConstrainter" .. p1.Name) then
		workspace:FindFirstChild("PlaneConstrainter" .. p1.Name):Destroy()
	end

	local v2 = Resources.PlaneConstrainter:Clone()

	v2.Position = v2.Position + Vector3.new(0, 0, v1)
	v2.Name = "PlaneConstrainter" .. p1.Name
	v2.Parent = workspace

	local PlaneConstraintAttach = Instance.new("Attachment")

	PlaneConstraintAttach.Name = "PlaneConstraintAttach"
	PlaneConstraintAttach.Parent = p1.PrimaryPart

	local PlaneConstraint = Instance.new("PlaneConstraint")

	PlaneConstraint.Attachment0 = v2.Attachment
	PlaneConstraint.Attachment1 = PlaneConstraintAttach
	PlaneConstraint.Parent = p1.PrimaryPart

	local v3 = Players:GetPlayerFromCharacter(p1)

	if not v3 then
		return
	end

	v3:SetAttribute("PlaneConstrainted", v1)
end
function t.DisablePlaneConstraint(p1) --[[ Line: 1248 | Upvalues: Players (copy) ]]
	local isPrimaryPart = p1.PrimaryPart == nil
	local PlaneConstraint = p1.PrimaryPart:FindFirstChild("PlaneConstraint")

	if PlaneConstraint then
		PlaneConstraint.Attachment0.Parent:Destroy()
		PlaneConstraint:Destroy()
	end

	local PlaneConstraintAttach = p1.PrimaryPart:FindFirstChild("PlaneConstraintAttach")

	if PlaneConstraintAttach then
		PlaneConstraintAttach:Destroy()
	end

	local v1 = Players:GetPlayerFromCharacter(p1)

	if not v1 then
		return
	end

	v1:SetAttribute("PlaneConstrainted", nil)
end
function t.SpawnBeam(p1, p2, p3) --[[ Line: 1268 | Upvalues: Resources (copy), EffectsFolder (copy), t (copy) ]]
	local v1 = if p3 then p3 else Color3.fromRGB(248, 248, 248)
	local v2 = Resources.SpawnBeam:Clone()

	v2.Position = p1 + Vector3.new(0, 1000, 0)
	v2.Size = Vector3.new(p2, 2048, p2)
	v2.Color = v1
	v2.Parent = EffectsFolder

	local GuiseShip = workspace:FindFirstChild("GuiseShip")

	if GuiseShip then
		v2.Beam1.Attachment1 = GuiseShip.PortHole.Attach
		v2.Beam2.Attachment1 = GuiseShip.PortHole.Attach
	end

	t.Tween(v2, {
		Size = Vector3.new(0, 2048, 0),
		Transparency = 1
	}, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), true)
	t.Tween(v2.Beam1, {
		Width0 = 0,
		Width1 = 0
	}, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), true)
	t.Tween(v2.Beam2, {
		Width0 = 0,
		Width1 = 0
	}, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), true)
	t.Debris(v2, 0.5)
end
function t.HurtEffect(p1) --[[ Line: 1290 | Upvalues: Resources (copy), EffectsFolder (copy), Debris (copy) ]]
	local v1 = Resources.HurtEffect:Clone()

	v1.Position = p1
	v1.Parent = EffectsFolder
	task.wait(0.05)
	v1.Particles:Emit(50)
	Debris:AddItem(v1, 1)
end
function t.IsHitStopAllowed(p1, p2) --[[ Line: 1303 | Upvalues: t (copy), Players (copy) ]]
	if p1 == true then
		return not workspace:FindFirstChild("PersistentHitstopValue")
	end

	if t.GetPlayersStillAlive() > 1 then
		return false
	end

	local v1 = nil

	for k, v in pairs(Players:GetPlayers()) do
		if v:GetAttribute("Dead") == false then
			v1 = v
		end
	end

	if v1:GetAttribute("Hitstop") == false and p2 ~= false then
		return false
	end

	return not workspace:FindFirstChild("PersistentHitstopValue")
end

local v7 = 0

function t.HitStop(p1, p2, p3, p4) --[[ Line: 1339 | Upvalues: t (copy), Players (copy), v7 (ref) ]]
	if p3 ~= true then
		if t.GetPlayersStillAlive() > 1 then
			return false
		end

		local v1 = nil

		for k, v in pairs(Players:GetPlayers()) do
			if v:GetAttribute("Dead") == false then
				v1 = v
			end
		end

		if v1:GetAttribute("Hitstop") == false and p4 ~= false then
			return false
		end
	end

	if workspace:FindFirstChild("PersistentHitstopValue") then
		return false
	end

	task.spawn(function() --[[ Line: 1368 | Upvalues: v7 (ref), p3 (copy), p1 (copy), p2 (copy), t (ref) ]]
		if workspace:FindFirstChild("HitstopValue") then
			workspace.HitstopValue:Destroy()
		end

		workspace:SetAttribute("Hitstopped", true)
		v7 = v7 + 1
		workspace:SetAttribute("TimeScale", 0.02)

		local v1 = Instance.new("NumberValue")

		v1.Value = workspace:GetAttribute("TimeScale")
		v1.Name = if p3 == true then "PersistentHitstopValue" else "HitstopValue"
		v1.Parent = workspace
		task.wait(p1)

		if p2 > 0 then
			t.Tween(v1, {
				Value = workspace:GetAttribute("BaseTimeScale")
			}, TweenInfo.new(p2, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
			v1.Changed:Connect(function() --[[ Line: 1395 | Upvalues: v1 (copy) ]]
				workspace:SetAttribute("TimeScale", v1.Value)
			end)
			task.wait(p2)
		end

		workspace:SetAttribute("TimeScale", workspace:GetAttribute("BaseTimeScale"))
		task.wait()
		v1:Destroy()
		v7 = v7 - 1

		if v7 ~= 0 then
			return
		end

		workspace:SetAttribute("Hitstopped", false)
	end)

	return true
end
function t.FreezePlayers(p1, p2) --[[ Line: 1432 | Upvalues: Players (copy), t (copy), Debris (copy) ]]
	for k, v in pairs(Players:GetPlayers()) do
		if v.Character and v.Character.PrimaryPart then
			local ShoveAttach = Instance.new("Attachment")

			ShoveAttach.Name = "ShoveAttach"
			ShoveAttach.Parent = v.Character.PrimaryPart
			t.LinearVel(ShoveAttach, Vector3.new(0, 0, 0), p1, true, "TimeFreezeVel")

			if p2 == false then
				Debris:AddItem(ShoveAttach, p1 + 0.1)

				continue
			end

			t.Debris(ShoveAttach, p1 + 0.1)
		end
	end
end
function t.AwardBadge(p1, p2) --[[ Line: 1456 | Upvalues: BadgeService (copy), v4 (ref) ]]
	if p1 == nil then
		warn("no player... what the hell are you doing?")

		return
	end

	if p2 == nil then
		warn("no badgeid... what the hell are you doing?")
	else
		task.spawn(function() --[[ Line: 1465 | Upvalues: BadgeService (ref), p1 (copy), p2 (copy), v4 (ref) ]]
			if BadgeService:UserHasBadgeAsync(p1.UserId, p2) then
				print("would have given this person a badge just now, but they already have it. tough crowd.")

				return
			end

			BadgeService:AwardBadge(p1.UserId, p2)

			local v1 = nil
			local _, result = pcall(function() --[[ Line: 1471 | Upvalues: v1 (ref), BadgeService (ref), p2 (ref) ]]
				v1 = BadgeService:GetBadgeInfoAsync(p2)
			end)

			if result then
				warn(result)
			end

			if v1 then
				local _2 = v1.Name

				v4.Notify(p1, v1)
			end
		end)
	end
end
function t.SpawnEnemy(p1, p2, p3) --[[ Line: 1489 | Upvalues: v6 (copy), EnemyFolder (copy), t (copy), RunService (copy), v2 (ref), ReplicatedStorage (copy), Sounds (copy), v3 (ref) ]]
	local v1 = p1:Clone()
	local PrimaryPart = v1.PrimaryPart
	local v22 = v1.Name

	for k, v in pairs(v1:GetDescendants()) do
		if v:IsA("BasePart") then
			local PathfindingModifier = Instance.new("PathfindingModifier")

			PathfindingModifier.PassThrough = false
			PathfindingModifier.Parent = v
		end
	end

	if p2 then
		v1:PivotTo(p2)
	else
		local v5 = workspace:Raycast(Vector3.new(math.random(-100, 100), 200, math.random(-100, 100)), Vector3.new(0, -400, 0), v6)

		if v5 then
			local v62 = CFrame.new(v5.Position)

			v1:PivotTo(v62 + Vector3.new(0, 3 * v1:GetScale(), 0))
		else
			v1:PivotTo(CFrame.new(0, 0, 0))
		end
	end

	v1.Name = v1.Name .. math.random(1, 999999)
	v1.Parent = EnemyFolder
	t.NetworkToServer(v1)

	if p3 ~= false then
		t.SpawnBeam(PrimaryPart.Position, 8, Color3.fromRGB(248, 248, 248))
	end

	if v1:FindFirstChild("Humanoid") then
		local v8 = nil

		v8 = RunService.Heartbeat:Connect(function() --[[ Line: 1525 | Upvalues: v1 (copy), v8 (ref) ]]
			if v1 == nil or (v1.Parent == nil or v1:FindFirstChild("Humanoid") == nil) then
				v8:Disconnect()

				return
			end

			if v1.Humanoid:GetState() ~= Enum.HumanoidStateType.FallingDown then
				return
			end

			v1.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end)
	end

	if v1:FindFirstChild("MovementConfig") then
		v2[v1.MovementConfig:GetAttribute("MovementType")](v1)
	end

	task.spawn(function() --[[ Line: 1543 | Upvalues: t (ref), v1 (copy) ]]
		t.TargetChatSystem(v1)
	end)

	local v10 = math.max(0, (120 - (120 - ReplicatedStorage.Wave.Value)) / 120)

	if ReplicatedStorage.Gamemode.Value == "infinite" and math.random() <= v10 then
		v1:SetAttribute("EvilRedMode", true)
		v1:SetAttribute("MaxHealth", v1:GetAttribute("MaxHealth") * 1.5)
		v1:SetAttribute("Health", v1:GetAttribute("Health") * 1.5)

		for k, v in pairs(v1:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Color = Color3.fromRGB(v.Color.R * 255 * 2, v.Color.G * 255 * 0.7, v.Color.B * 255 * 0.7)
			end

			if v:IsA("BodyColors") then
				local fromRGB = Color3.fromRGB

				v.HeadColor3 = fromRGB(math.min(v.HeadColor3.R * 255 * 2, 255), v.HeadColor3.G * 255 * 0.7, v.HeadColor3.B * 255 * 0.7)

				local fromRGB2 = Color3.fromRGB

				v.LeftArmColor3 = fromRGB2(math.min(v.LeftArmColor3.R * 255 * 2, 255), v.LeftArmColor3.G * 255 * 0.7, v.LeftArmColor3.B * 255 * 0.7)

				local fromRGB3 = Color3.fromRGB

				v.LeftLegColor3 = fromRGB3(math.min(v.LeftLegColor3.R * 255 * 2, 255), v.LeftLegColor3.G * 255 * 0.7, v.LeftLegColor3.B * 255 * 0.7)

				local fromRGB4 = Color3.fromRGB

				v.RightArmColor3 = fromRGB4(math.min(v.RightArmColor3.R * 255 * 2, 255), v.RightArmColor3.G * 255 * 0.7, v.RightArmColor3.B * 255 * 0.7)

				local fromRGB5 = Color3.fromRGB

				v.RightLegColor3 = fromRGB5(math.min(v.RightLegColor3.R * 255 * 2, 255), v.RightLegColor3.G * 255 * 0.7, v.RightLegColor3.B * 255 * 0.7)

				local fromRGB6 = Color3.fromRGB

				v.TorsoColor3 = fromRGB6(math.min(v.TorsoColor3.R * 255 * 2, 255), v.TorsoColor3.G * 255 * 0.7, v.TorsoColor3.B * 255 * 0.7)
			end

			if v:IsA("SpecialMesh") or v:IsA("FileMesh") then
				v.VertexColor = Vector3.new(v.VertexColor.X, v.VertexColor.Y / 4, v.VertexColor.Z / 4)
			end

			if v:IsA("Frame") then
				v.BackgroundColor3 = Color3.fromRGB(v.BackgroundColor3.R * 255 * 2, v.BackgroundColor3.G * 255 * 0.7, v.BackgroundColor3.B * 255 * 0.7)
			end
		end
	end

	if ReplicatedStorage.GameType.Value == "flat" then
		t.EnablePlaneConstraint(v1)
	end

	v1.ChildRemoved:Connect(function() --[[ Line: 1591 | Upvalues: PrimaryPart (copy), v1 (copy) ]]
		if PrimaryPart ~= nil and PrimaryPart.Parent ~= nil then
			return
		end

		v1:Destroy()
	end)
	task.spawn(function() --[[ Line: 1598 | Upvalues: t (ref), v1 (copy) ]]
		t.Wait(5)

		if v1.Parent ~= nil and (v1.PrimaryPart ~= nil and v1:GetAttribute("Alive") ~= false) then
			v1.PrimaryPart:GetPropertyChangedSignal("CFrame"):Connect(function() --[[ Line: 1601 | Upvalues: v1 (ref) ]]
				if v1.PrimaryPart ~= nil and (v1.PrimaryPart.Position.Magnitude > 350 or v1.PrimaryPart.Position.Y > 300) and v1:GetAttribute("Alive") == true then
					v1:PivotTo(CFrame.new(0, 3, 0))
				end

				if v1:GetPivot().Position == v1:GetPivot().Position then
					return
				end

				warn(v1.Name .. " JUST GOT NAN-ED")
				v1:Destroy()
			end)
		end
	end)
	v1:GetAttributeChangedSignal("Health"):Connect(function() --[[ Line: 1613 | Upvalues: v1 (copy), t (ref), PrimaryPart (copy), Sounds (ref), v3 (ref), v22 (copy) ]]
		if v1:GetAttribute("Alive") ~= true then
			return
		end

		t.HurtEffect(PrimaryPart.Position)
		t.PlaySound(Sounds.EnemyHurt, PrimaryPart)

		if not (v1:GetAttribute("Health") <= 0) then
			return
		end

		if v1:GetAttribute("CanDie") == false then
			repeat
				task.wait()
			until v1:GetAttribute("CanDie") == true
		end

		v3[v22](v1)
	end)

	return v1
end
function t.BanEnemy(p1) --[[ Line: 1638 | Upvalues: ReplicatedStorage (copy) ]]
	if not ReplicatedStorage.BannedEnemies:FindFirstChild(p1) then
		local v1 = Instance.new("BoolValue")

		v1.Name = p1
		v1.Parent = ReplicatedStorage.BannedEnemies
	end
end
function t.UnbanEnemy(p1) --[[ Line: 1651 | Upvalues: ReplicatedStorage (copy) ]]
	local v1 = ReplicatedStorage.BannedEnemies:FindFirstChild(p1)

	if not v1 then
		return
	end

	v1:Destroy()
end
function t.ParryServer(p1, p2, p3, p4) --[[ Line: 1781 | Upvalues: Players (copy), ReplicatedStorage (copy), t (copy), Sounds (copy), LocalEvent (copy) ]]
	local v1 = Players:GetPlayerFromCharacter(p2)
	local Humanoid = p2.Humanoid

	if v1 then
		v1:SetAttribute("ParryCooldown", 0)

		if ReplicatedStorage.Gamemode.Value ~= "tutorial" then
			if v1:GetAttribute("AutoparryMeter") > 0 then
				if v1:GetAttribute("ManualParry") == nil then
					v1:SetAttribute("AutoparryMeter", (math.max(v1:GetAttribute("AutoparryMeter") - 1, 0)))
					v1:SetAttribute("AutoparryLastUseTime", time())
				end

				v1:SetAttribute("ParryActiveTime", 0.3)
			else
				v1:SetAttribute("ParryActiveTime", 0)
			end
		end

		v1:SetAttribute("JustTriedParry", false)
		v1:SetAttribute("ManualParry", nil)

		local v3 = 0
		local v4 = 1

		if v1:GetAttribute("Basics") then
			v3 = v3 * 1.5
			v4 = v4 * 1.5
		end

		if v1:GetAttribute("DeathwishingRn") then
			v3 = v3 * 2
			v4 = v4 * 2
		end

		if v1:GetAttribute("LastStand") and (Humanoid.Health < 20 and Humanoid.Health > 0) then
			t.Distortion(p2.HumanoidRootPart.CFrame, Vector3.new(0.1, 0.1, 0.1), 2, Vector3.new(100, 100, 100), 0.5, false)
			t.Shockwave(p2.HumanoidRootPart.Position + Vector3.new(0, -2.9, 0), Vector3.new(25, 1, 25), 0.8, true)
			t.Shockwave(p2.HumanoidRootPart.Position + Vector3.new(0, -2.9, 0), Vector3.new(40, 1, 40), 1.2, true)
			t.PlaySound(Sounds.LowBoom, p2.HumanoidRootPart)
			t.PlaySound(Sounds.LastStandParry, p2.HumanoidRootPart)
			v3 = v3 * 2
			v4 = v4 * 2
		end

		local sum

		if p4 == true then
			sum = v3 + 60

			if ReplicatedStorage.Intro.Value == false then
				if v1:GetAttribute("NoParryHealing") == nil and v1:GetAttribute("DeathwishingRn") == nil then
					Humanoid.Health = Humanoid.Health + p3
				end

				v1:SetAttribute("CounterMeter", (math.clamp(v1:GetAttribute("CounterMeter") + 2, 0, v1:GetAttribute("CounterLimit"))))
			end

			if p1 ~= nil then
				t.AddStreak(v1, math.round(v4 * 80), "PERFECT PARRY")

				for v6, v7 in Players:GetPlayers() do
					if v7:GetAttribute("Dead") == false and v7:GetAttribute("StreakTime") > 0 then
						t.StreakMultiplier(v7, 0.1, "forever and ever!", if v7 == v1 then "for the perfect parry" else v1.Name .. " perfect parried")
					end
				end

				v1:SetAttribute("PerfectParries", v1:GetAttribute("PerfectParries") + 1)
			end
		else
			sum = v3 + 30

			if ReplicatedStorage.Intro.Value == false then
				if v1:GetAttribute("NoParryHealing") == nil and v1:GetAttribute("DeathwishingRn") == nil then
					Humanoid.Health = Humanoid.Health + p3 / 3
				end

				v1:SetAttribute("CounterMeter", (math.clamp(v1:GetAttribute("CounterMeter") + 1, 0, v1:GetAttribute("CounterLimit"))))
			end

			if p1 ~= nil then
				t.AddStreak(v1, math.round(v4 * 20), "PARRY")
				v1:SetAttribute("Parries", v1:GetAttribute("Parries") + 1)
			end
		end

		if v1:GetAttribute("Kinetics") then
			sum = sum + math.round(p2.HumanoidRootPart.AssemblyLinearVelocity.Magnitude / 2)
		end

		if v1:GetAttribute("Overcharge") then
			sum = sum * (1 * (v1:GetAttribute("Overcharge") / 6 + 1))

			if p1 ~= nil and v1:GetAttribute("Overcharge") == 3 then
				t.AddStreak(v1, 30, "FULL OVERCHARGE")
			elseif p1 ~= nil and v1:GetAttribute("Overcharge") > 0 then
				t.AddStreak(v1, 15, "PARTIAL OVERCHARGE")
			end

			v1:SetAttribute("Overcharge", (math.clamp(v1:GetAttribute("Overcharge") - 0.6, 0, 3)))
		end

		if v1:GetAttribute("SupremeAdminDamage") ~= nil then
			sum = sum + v1:GetAttribute("SupremeAdminDamage")
		end

		local v12 = math.round(sum)

		if p1 ~= nil then
			t.DamageEnemy(v1, p1, v12)
			t.HitMarker(p1, "Parry")
		end

		t.CheckScore(v1)
		t.ScoreLabels(v1)

		if p4 == true then
			if ReplicatedStorage.Gamemode.Value ~= "tutorial" then
				v1:SetAttribute("ParryActiveTime", 0.6)
			end

			t.HitStop(0.3, 0.5)
			task.delay(0.3, function() --[[ Line: 1944 | Upvalues: v1 (copy) ]]
				v1:SetAttribute("ParryCooldown", 0)
			end)
		else
			t.HitStop(0.05, 0)
		end

		for v13, v14 in Players:GetPlayers() do
			if v1:GetAttribute("ParrySound") ~= 0 and (v14 ~= v1 and (v14:GetAttribute("HearParrySound") ~= "nobody" and (v14:GetAttribute("HearParrySound") ~= "friends" or v14.FriendsFolder:FindFirstChild(v1.Name) ~= nil))) then
				if p4 == true then
					local v15 = v1:GetAttribute("ParrySound")
					local v16 = v1:GetAttribute("PerfectParrySound")

					if v15 ~= 0 and v16 == v15 then
						LocalEvent:FireClient(v14, "PlaySound", {
							Sounds["CustomParrySuccess" .. v1.Name],
							p2.HumanoidRootPart,
							1,
							false
						})
					end

					if v16 ~= 0 then
						LocalEvent:FireClient(v14, "PlaySound", {
							Sounds["CustomPerfectParrySuccess" .. v1.Name],
							p2.HumanoidRootPart,
							1,
							false
						})
					end

					continue
				end

				LocalEvent:FireClient(v14, "PlaySound", {
					Sounds["CustomParrySuccess" .. v1.Name],
					p2.HumanoidRootPart,
					1,
					false
				})
			end
		end
	else
		p2:SetAttribute("ParryCooldown", 0)
		p2:SetAttribute("ParryActiveTime", 0.3)

		local v17 = if p2:FindFirstChild("MechSeat") then Players:GetPlayerFromCharacter(p2.MechSeat.Occupant.Parent) else nil

		if not v17 then
			t.DamageEnemy(p2, p1, 30)

			return
		end

		local v19 = 0
		local sum

		if t.GPP(p2) == true then
			sum = v19 + 120
			LocalEvent:FireClient(v17, "ParrySuccess", { true })

			if p1 ~= nil then
				t.AddStreak(v17, 80, "PERFECT PARRY")

				for v20, v21 in Players:GetPlayers() do
					if v21:GetAttribute("Dead") == false and v21:GetAttribute("StreakTime") > 0 then
						t.StreakMultiplier(v21, 0.1, "forever and ever!", if v21 == v17 then "for the perfect parry" else v17.Name .. " perfect parried")
					end
				end

				v17:SetAttribute("MechPerfectParries", v17:GetAttribute("MechPerfectParries") + 1)
			end

			t.HitStop(1, 0.5, false, true)
			task.spawn(function() --[[ Line: 2052 | Upvalues: p2 (copy) ]]
				task.wait(0.5)
				p2:SetAttribute("ParryCooldown", 0)
			end)
		else
			sum = v19 + 60
			LocalEvent:FireClient(v17, "ParrySuccess", { false })

			if p1 ~= nil then
				t.AddStreak(v17, 20, "PARRY")
				v17:SetAttribute("MechParries", v17:GetAttribute("MechParries") + 1)
			end

			t.HitStop(0.3, 0, false, true)
		end

		if v17:GetAttribute("SupremeAdminDamage") ~= nil then
			sum = sum + v17:GetAttribute("SupremeAdminDamage")
		end

		if p1 ~= nil then
			t.DamageEnemy(v17, p1, sum)
			t.HitMarker(p1, "Parry")
		end

		t.CheckScore(v17)
		t.ScoreLabels(v17)
	end
end
function t.ParryClient(p1) --[[ Line: 2098 | Upvalues: Players (copy), Resources (copy), EffectsFolder (copy), t (copy), CherryGarcia (copy), Sounds (copy), v5 (copy), ModifiersActive (copy), RunService (copy), Animations (copy) ]]
	local v1 = Players:GetPlayerFromCharacter(p1)
	local Humanoid = p1.Humanoid

	if v1 then
		task.spawn(function() --[[ Line: 2103 | Upvalues: Resources (ref), p1 (copy), EffectsFolder (ref), v1 (copy), t (ref) ]]
			local v12 = Resources.ParryEffectPart:Clone()

			v12.CFrame = p1.HumanoidRootPart.CFrame + p1.HumanoidRootPart.CFrame.LookVector + p1.HumanoidRootPart.AssemblyLinearVelocity / 7
			v12.Parent = EffectsFolder
			task.wait()

			if v1:GetAttribute("Overcharge") and v1:GetAttribute("Overcharge") == 3 then
				v12.Particles.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
			end

			v12.Particles:Emit(20)
			t.Debris(v12, 1)
			t.ConnectParticlesToTimescale(v12.Particles)
		end)

		if t.GPP(p1) == true then
			CherryGarcia:Fire(v1, true)

			local v2 = v1:GetAttribute("ParrySound")
			local v3 = v1:GetAttribute("PerfectParrySound")

			if v2 == 0 or v3 ~= v2 then
				t.PlaySound(Sounds["ParrySuccess" .. v1:GetAttribute("Weapon")], p1.HumanoidRootPart, v5:NextNumber(1.2, 1.25), false)
			else
				t.PlaySound(Sounds["CustomParrySuccess" .. v1.Name], p1.HumanoidRootPart, 1, false)

				if v1:GetAttribute("ParryAddOnTop") ~= false then
					t.PlaySound(Sounds["ParrySuccess" .. v1:GetAttribute("Weapon")], p1.HumanoidRootPart, v5:NextNumber(1.2, 1.25), false)
				end
			end

			if v3 == 0 then
				t.PlaySound(Sounds.PerfectParry, p1.HumanoidRootPart, v5:NextNumber(1.2, 1.25), false)
			else
				t.PlaySound(Sounds["CustomPerfectParrySuccess" .. v1.Name], p1.HumanoidRootPart, 1, false)

				if v1:GetAttribute("ParryAddOnTop") ~= false then
					t.PlaySound(Sounds.PerfectParry, p1.HumanoidRootPart, v5:NextNumber(1.2, 1.25), false)
				end
			end

			task.delay(0.3, function() --[[ Line: 2176 | Upvalues: t (ref), v1 (copy), CherryGarcia (ref), Sounds (ref), p1 (copy), v5 (ref) ]]
				if t.GetPlayersStillAlive() ~= 1 or v1:GetAttribute("Hitstop") ~= true then
					return
				end

				CherryGarcia:Fire(v1, true)
				t.PlaySound(Sounds["ParrySuccess" .. v1:GetAttribute("Weapon")], p1.HumanoidRootPart, v5:NextNumber(0.95, 1.05), false)
			end)
		else
			CherryGarcia:Fire(v1, false)

			if v1:GetAttribute("ParrySound") == 0 then
				t.PlaySound(Sounds["ParrySuccess" .. v1:GetAttribute("Weapon")], p1.HumanoidRootPart, v5:NextNumber(0.95, 1.05), false)
			else
				t.PlaySound(Sounds["CustomParrySuccess" .. v1.Name], p1.HumanoidRootPart, 1, false)
			end
		end

		if ModifiersActive:FindFirstChild("taste the rainbow") then
			if t.GPP(p1) == false then
				t.PlaySound(Sounds.ImpactParry, workspace, v5:NextNumber(0.95, 1.05), false)
			else
				t.PlaySound(Sounds.ImpactPerfectParry, workspace, v5:NextNumber(0.95, 1.05), false)
				task.defer(function() --[[ Line: 2202 | Upvalues: t (ref), Sounds (ref) ]]
					local v1 = t.PlaySound(Sounds.ImpactPerfectParry2, workspace, 1, false)

					task.wait(0.1)
					v1:Destroy()
				end)
			end
		end

		if v1:GetAttribute("Overcharge") and v1:GetAttribute("Overcharge") == 3 then
			task.defer(function() --[[ Line: 2212 | Upvalues: t (ref), Sounds (ref), p1 (copy), Resources (ref), EffectsFolder (ref) ]]
				t.PlaySound(Sounds.ChargedParry, p1.HumanoidRootPart)

				local v1 = Resources.Sparks:Clone()

				v1.CFrame = p1.HumanoidRootPart.CFrame * CFrame.Angles(-1.2217304763960306, 0, 0)
				v1.Parent = EffectsFolder
				task.wait()
				v1.Particles:Emit(40)
				t.Debris(v1, 1)
				t.ConnectParticlesToTimescale(v1.Particles)
			end)
		end

		if not v1:GetAttribute("DeathwishingRn") then
			Humanoid.Animator:LoadAnimation(Animations.ParrySuccesses[v1:GetAttribute("Weapon") .. "ParrySuccess"]):Play(0)

			return
		end

		task.defer(function() --[[ Line: 2226 | Upvalues: t (ref), Sounds (ref), p1 (copy), v5 (ref), Resources (ref), EffectsFolder (ref), RunService (ref) ]]
			t.PlaySound(Sounds.DeathwishParry, p1.HumanoidRootPart, v5:NextNumber(0.5, 1.3))

			local v1 = Resources.DeathwishParryPart:Clone()

			v1.Position = p1.HumanoidRootPart.Position + Vector3.new(0, -2.9, 0)
			v1.Parent = EffectsFolder
			task.wait()
			v1.Particles:Emit(3)
			t.Debris(v1, 1)

			local v2 = nil

			v2 = RunService.Heartbeat:Connect(function() --[[ Line: 2237 | Upvalues: v1 (copy), v2 (ref), p1 (ref) ]]
				if v1.Parent == nil then
					v2:Disconnect()
				else
					v1.Position = p1.HumanoidRootPart.Position + Vector3.new(0, -2.9, 0)
				end
			end)
		end)
		Humanoid.Animator:LoadAnimation(Animations.ParrySuccesses[v1:GetAttribute("Weapon") .. "ParrySuccess"]):Play(0)
	else
		Players:GetPlayerFromCharacter(p1.MechSeat.Occupant.Parent)
		task.spawn(function() --[[ Line: 2252 | Upvalues: Resources (ref), p1 (copy), EffectsFolder (ref), t (ref) ]]
			for i = 1, 3 do
				local v3 = Vector3.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
				local v4 = Resources.ParryEffectPart:Clone()

				v4.CFrame = p1.HumanoidRootPart.CFrame + p1.HumanoidRootPart.CFrame.LookVector * 3 + p1.HumanoidRootPart.AssemblyLinearVelocity / 5 + v3
				v4.Parent = EffectsFolder
				task.wait()
				v4.Particles:Emit(20)
				t.Debris(v4, 1)
				t.ConnectParticlesToTimescale(v4.Particles)
			end
		end)

		local v4 = t.IsHitStopAllowed(false, true)

		t.StopAnimations(p1, { "MechParryStart", "MechParrySuccess" })

		local v52 = Humanoid.Animator:LoadAnimation(Animations.MechParrySuccess)

		v52:Play(0)

		if v4 == true then
			v52:AdjustSpeed(0)
		end

		task.spawn(function() --[[ Line: 2273 | Upvalues: t (ref), p1 (copy), Sounds (ref), v4 (copy), v5 (ref), v52 (copy) ]]
			t.Shockwave(p1.HumanoidRootPart.Position, Vector3.new(100, 1, 100), 0.1, false)

			local v1 = t.PlaySound(Sounds.MechParryHitstopped, p1.HumanoidRootPart, 0.7, false)

			if v4 == true then
				task.wait(0.3)
			end

			for i = 1, 2 do
				t.Shockwave(p1.HumanoidRootPart.Position, Vector3.new(300, math.random(1, 5), 300), 0.3, true)
			end

			v1:Destroy()
			t.PlaySound(Sounds.ParrySuccessMech, p1.HumanoidRootPart, v5:NextNumber(0.95, 1.05), false)

			if v4 ~= true then
				return
			end

			v52:AdjustSpeed(1)
		end)
	end
end

local t7 = {}

function t.DamagePlayer(p1, p2, p3, p4, p5) --[[ Line: 2319 | Upvalues: Players (copy), RunService (copy), Remotes (copy), CherryGarcia (copy), ReplicatedStorage (copy), Stages (copy), t (copy), Sounds (copy), ServerToServer (copy), ModifiersActive (copy), t7 (copy) ]]
	Players:GetPlayerFromCharacter(p2)

	if p2:FindFirstChild("Humanoid") == nil then
		return true
	end

	if p2.Humanoid.Sit == true and p2.Humanoid.SeatPart.Name == "MechSeat" then
		p2 = p2.Humanoid.SeatPart.Parent
	end

	local v1 = Players:GetPlayerFromCharacter(p2)

	if p2:FindFirstChild("MechSeat") and p2.MechSeat.Occupant ~= nil then
		v1 = Players:GetPlayerFromCharacter(p2.MechSeat.Occupant.Parent)
	end

	if RunService:IsServer() then
		if v1 then
			local v2 = nil
			local v3 = nil
			local _, result = pcall(function() --[[ Line: 2444 | Upvalues: v2 (ref), v3 (ref), Remotes (ref), v1 (ref), p1 (copy), p2 (ref), p3 (copy), p4 (copy), p5 (copy) ]]
				local v12, v22 = Remotes.DamageConfirm:InvokeClient(v1, { p1, p2, p3, p4, p5 })

				v2 = v12
				v3 = v22
			end)

			if result then
				warn(result)

				return true
			end

			if v2 == false then
				CherryGarcia:Fire(p1, p2, p3, v3)
			elseif v2 == true then
				if p3 == 0 then
					return true
				end

				if p2:FindFirstChildOfClass("ForceField") and p2:FindFirstChildOfClass("ForceField").Name ~= "ParryForcefield" then
					return true
				end

				local v4

				if v1 then
					if v1:GetAttribute("Dead") == true then
						return true
					end

					if ReplicatedStorage.Intro.Value == false then
						v1:SetAttribute("StreakTime", 0)
					end

					v4 = if v1:GetAttribute("Resistance") then p3 * (1 - math.clamp(v1:GetAttribute("Resistance"), 0, 100) / 100) else p3

					if v1:GetAttribute("Curse") == true then
						v4 = v4 * 3
					end

					if v1:GetAttribute("DeathwishingRn") == true then
						v4 = v4 * 1.5
					end

					if ReplicatedStorage.Difficulty.Value == "Easy" then
						v4 = v4 * 0.7
					end

					if ReplicatedStorage.Difficulty.Value == "HARD" then
						v4 = v4 * 2
					end

					if ReplicatedStorage.HellModeActive.Value == true then
						v4 = v4 * 3
					end

					if p1 ~= nil and p1:GetAttribute("EvilRedMode") == true then
						v4 = v4 * 1.5
					end

					if ReplicatedStorage.CurrentStage.Value == Stages.Infinity then
						v4 = v4 * (1 + ReplicatedStorage.Wave.Value / 60)
					end
				else
					v4 = p3
				end

				t.PlaySound(Sounds.PlayerHurt, p2.HumanoidRootPart)
				ServerToServer:Fire("PlayerIFrames", { p2 })

				if ReplicatedStorage.Intro.Value == true then
					local Humanoid = p2.Humanoid

					Humanoid.Health = Humanoid.Health - 1
					task.wait(0.1)

					local Humanoid2 = p2.Humanoid

					Humanoid2.Health = Humanoid2.Health + 1
				else
					local Humanoid = p2.Humanoid

					Humanoid.Health = Humanoid.Health - v4

					if ModifiersActive:FindFirstChild("unstable fate") and not table.find(t7, v1) then
						local v6 = t7

						table.insert(v6, v1)

						local v7 = v1:GetAttribute("UnstableChance") / 2

						v1:SetAttribute("UnstableChance", (math.max(math.round(v7), 5)))
						task.delay(0.5, function() --[[ Line: 2528 | Upvalues: t7 (ref), v1 (ref) ]]
							table.remove(t7, table.find(t7, v1))
						end)
					end
				end
			end

			return v2
		end

		local v9 = false

		if p2:GetAttribute("Parrying") == true then
			CherryGarcia:Fire(p1, p2, p3, false)
		else
			v9 = true

			if p3 == 0 then
				print("damage is 0 soo just doing nothing")

				return true
			end

			local v10 = p3

			for v11, v12 in p2:GetChildren() do
				if v12:IsA("ForceField") and v12.Name ~= "ParryForcefield" then
					return true
				end
			end

			if p2:GetAttribute("Resistance") then
				v10 = v10 * (1 - math.clamp(p2:GetAttribute("Resistance"), 0, 100) / 100)
			end

			t.PlaySound(Sounds.PlayerHurt, p2.HumanoidRootPart)
			ServerToServer:Fire("PlayerIFrames", { p2 })

			if ReplicatedStorage.Intro.Value == true then
				local Humanoid = p2.Humanoid

				Humanoid.Health = Humanoid.Health - 1
				task.wait(0.1)

				local Humanoid2 = p2.Humanoid

				Humanoid2.Health = Humanoid2.Health + 1
			else
				local Humanoid = p2.Humanoid

				Humanoid.Health = Humanoid.Health - v10
			end
		end

		return v9
	end

	if p2:GetAttribute("Parrying") == true and p4 == true then
		t.ParryClient(p2)

		return false
	end

	if v1 and (v1:GetAttribute("JustTriedParry") == true and p4 == true) then
		task.spawn(function() --[[ Line: 2599 | Upvalues: p2 (ref), t (ref) ]]
			local TimingGui = p2.HumanoidRootPart.TimingGui

			TimingGui.Enabled = true
			TimingGui.Label.TextTransparency = 0
			TimingGui.Label.UIStroke.Transparency = 0
			t.Tween(TimingGui.Label, {
				TextTransparency = 1
			}, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
			t.Tween(TimingGui.Label.UIStroke, {
				Transparency = 1
			}, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
			task.wait(0.5)
			TimingGui.Enabled = false
		end)
	end

	local _ = p2:FindFirstChild("Forcefield")

	return true
end

local function DEfunc(p1, p2, p3) --[[ DEfunc | Line: 2626 ]]
	if p2:GetAttribute("Health") == nil then
		return
	end

	if p2:FindFirstChildOfClass("ForceField") then
		return
	end

	local v1 = p2:GetAttribute("Health")

	if p2:GetAttribute("Resistance") then
		p3 = p3 * (1 - math.clamp(p2:GetAttribute("Resistance"), 0, 100) / 100)
	end

	p2:SetAttribute("Health", (math.max(p2:GetAttribute("Health") - p3, 0)))

	if p1 == nil then
		return
	end

	if p1:GetAttribute("DamageDealt") ~= nil then
		local v4 = v1 - p2:GetAttribute("Health")

		p1:SetAttribute("DamageDealt", p1:GetAttribute("DamageDealt") + v4)
	end

	if p1:GetAttribute("EnemiesKilled") ~= nil and (p2:GetAttribute("Health") <= 0 and v1 > 0) then
		p1:SetAttribute("EnemiesKilled", p1:GetAttribute("EnemiesKilled") + 1)
	end

	if p2:FindFirstChild("HitTag") then
		p2.HitTag.Value = p1

		return
	end

	local HitTag = Instance.new("ObjectValue")

	HitTag.Value = p1
	HitTag.Name = "HitTag"
	HitTag.Parent = p2
end

function t.DamageEnemy(p1, p2, p3) --[[ Line: 2663 | Upvalues: DEfunc (copy) ]]
	DEfunc(p1, p2, p3)
end
function t.HitMarker(p1, p2) --[[ Line: 2677 ]]
	p1:SetAttribute("HitBy", p2 .. " " .. tostring(math.random(1, 999999)))
end
function t.GetPlayerFromHitTag(p1) --[[ Line: 2682 ]]
	local HitTag = p1:FindFirstChild("HitTag")

	if HitTag then
		return HitTag.Value
	end

	return nil
end
function t.GetPlayerFromModel(p1) --[[ Line: 2697 | Upvalues: Players (copy) ]]
	if not p1:FindFirstChild("Humanoid") then
		warn("Model doesnt have a humanoid, cant get the player from it.")
	end

	local v1 = Players:GetPlayerFromCharacter(p1)

	if v1 == nil and (p1:FindFirstChild("MechSeat") and p1.MechSeat.Occupant ~= nil) then
		v1 = Players:GetPlayerFromCharacter(p1.MechSeat.Occupant.Parent)
	end

	return v1
end
function t.GetModelFromPlayer(p1) --[[ Line: 2718 ]]
	local Character = p1.Character

	if Character.Humanoid.SeatPart ~= nil then
		Character = Character.Humanoid.SeatPart.Parent
	end

	return Character
end
function t.TargetJuggleSystem(p1) --[[ Line: 2729 | Upvalues: RunService (copy), PlayerFolder (copy), EnemyFolder (copy), EffectsFolder (copy), t (copy), Sounds (copy) ]]
	local PrimaryPart = p1.PrimaryPart

	p1:FindFirstChild("Humanoid")

	if PrimaryPart then
		local v1 = RaycastParams.new()

		v1.FilterType = Enum.RaycastFilterType.Exclude

		local v2 = false
		local v3 = false
		local v4 = nil

		v4 = RunService.Heartbeat:Connect(function(p12) --[[ Line: 2755 | Upvalues: p1 (copy), v4 (ref), v3 (ref), v1 (copy), PlayerFolder (ref), EnemyFolder (ref), EffectsFolder (ref), PrimaryPart (copy), v2 (ref), t (ref), Sounds (ref) ]]
			if p1.Parent == nil then
				v4:Disconnect()
			end

			if v3 then
				return
			end

			local v12 = p1:GetAttribute("JuggleVelocity")

			if v12 == nil then
				return
			end

			if (nil).IsPlaying == false then
				(nil):Play(0)
			end

			v1.FilterDescendantsInstances = { PlayerFolder, EnemyFolder, EffectsFolder }

			local v22 = workspace:Raycast(PrimaryPart.Position, v12 * p12 * 1.1, v1)

			if v22 then
				v3 = true
				print((v12 * Vector3.new(1, 0, 1)).Magnitude)

				if v2 == false and (v12.Magnitude >= 200 and (v12 * Vector3.new(1, 0, 1)).Magnitude < 50) then
					print("THEY LANDED CLOSE!")
					v2 = true

					local Position = v22.Position
					local Position2 = v22.Position

					t.BezierCurve(PrimaryPart, 1.3, Position, Position:Lerp(Position2, 0.5) + Vector3.new(0, 20, 0), Position2, true, true, true)
					t.PlaySound(Sounds.Spinning, PrimaryPart)

					local v42 = nil

					v42 = p1:GetAttributeChangedSignal("HitBy"):Connect(function() --[[ Line: 2788 | Upvalues: p1 (ref), v42 (ref), v3 (ref), t (ref), PrimaryPart (ref), Sounds (ref) ]]
						p1:SetAttribute("FallSpeed", 100)
						v42:Disconnect()
						v3 = false
						t.CancelBezierCurve(PrimaryPart)
						t.StopSound(Sounds.Spinning, PrimaryPart)
						t.AddStreak(p1:FindFirstChild("HitTag").Value, 50, "STRAIGHT DOWN")
						t.StreakMultiplier(p1:FindFirstChild("HitTag").Value, 0.1, 5, "for slamming down")
					end)

					for i = 1, 26 do
						if v3 ~= false then
							t.Wait(0.05)
						end
					end

					if v3 == true then
						v42:Disconnect()
						v3 = false
						t.CancelBezierCurve(PrimaryPart)
						t.StopSound(Sounds.Spinning, PrimaryPart)
					end
				else
					if v12.Magnitude >= 200 then
						t.AddStreak(p1:FindFirstChild("HitTag").Value, 50, "POWER LAUNCH")
						t.StreakMultiplier(p1:FindFirstChild("HitTag").Value, 0.1, 5, "for that launch");
						(nil):Stop(0)

						if workspace:Raycast(PrimaryPart.Position, Vector3.new(0, -3.1, 0), v1) and (v12 * Vector3.new(1, 0, 1)).Magnitude > 2 then
							print("SLIDINGGGGG")

							local v5 = CFrame.lookAt(Vector3.new(0, 0, 0), v12 * Vector3.new(1, 0, 1))

							t.Tween(PrimaryPart, {
								CFrame = PrimaryPart.CFrame + v5.LookVector * 70
							}, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), true)

							if v22.Position.Y < PrimaryPart.Position.Y then
								t.Shockwave(v22.Position, Vector3.new(20, 1, 20), 0.3, true)
							end

							for j = 1, 10 do
								t.PlaySound(Sounds.LaunchedHit, PrimaryPart)
								v1.FilterDescendantsInstances = { PlayerFolder, EnemyFolder, EffectsFolder }

								local v6 = workspace:Raycast(PrimaryPart.Position, v5.LookVector * 3, v1)

								if v6 then
									print("HE SLID INTO A WALL")
									t.Destruct(nil, v6.Instance, 1)
									t.Tween(PrimaryPart, {
										CFrame = PrimaryPart.CFrame + v5.LookVector * -10
									}, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), true)
									task.wait(0.3)

									break
								end

								local v7 = workspace:Raycast(PrimaryPart.Position, Vector3.new(0, -3.1, 0), v1)

								if v7 then
									print("WOOO LOTS OF GROUND")

									for k, v in pairs((workspace:GetPartBoundsInRadius(PrimaryPart.Position, 8))) do
										if v:IsDescendantOf(EnemyFolder) and (v.Parent:IsA("Model") and v == v.Parent.PrimaryPart) then
											t.DamageEnemy(p1:FindFirstChild("HitTag").Value, v.Parent, 3)
										end
									end

									t.Rubble(v7, false, Vector3.new(0, 25, 0), p1:FindFirstChild("HitTag").Value)
									t.Rubble(v7, false, Vector3.new(0, 25, 0), p1:FindFirstChild("HitTag").Value)

									if j ~= 10 then
										task.wait(0.1)
									end
								else
									print("NO MORE GROUND, BREAK")

									break
								end
							end
						else
							print("AIR DEMOLISHINGGG")
							t.PlaySound(Sounds.LaunchedHit, PrimaryPart)

							for k, v in pairs((workspace:GetPartBoundsInRadius(PrimaryPart.Position, 13))) do
								local v11 = math.random(-50, 50)

								t.Destruct(nil, v, 1, (Vector3.new(v11, 200, math.random(-50, 50))))

								if v:IsDescendantOf(EnemyFolder) and (v.Parent:IsA("Model") and v == v.Parent.PrimaryPart) then
									t.DamageEnemy(p1:FindFirstChild("HitTag").Value, v.Parent, 30)
								end
							end
						end
					else
						for k, v in pairs((workspace:GetPartBoundsInRadius(PrimaryPart.Position, 5))) do
							local v14 = math.random(-5, 5)

							t.Destruct(nil, v, 1, (Vector3.new(v14, 20, math.random(-5, 5))))

							if v:IsDescendantOf(EnemyFolder) and (v.Parent:IsA("Model") and v == v.Parent.PrimaryPart) then
								t.DamageEnemy(p1:FindFirstChild("HitTag").Value, v.Parent, 20)
							end
						end

						(nil):Stop(0)
					end

					print("END")

					local v16 = PrimaryPart

					v16.CFrame = v16.CFrame + Vector3.new(0, 2, 0)
					p1:SetAttribute("CanDie", true)
					p1:SetAttribute("Stunned", false)
					p1:SetAttribute("Juggled", false)
					p1:SetAttribute("JuggleVelocity", nil)
					p1:SetAttribute("FallSpeed", nil)
					v3 = false
					v2 = false
				end
			else
				if p1:GetAttribute("FallSpeed") == nil then
					p1:SetAttribute("FallSpeed", 100)
				end

				PrimaryPart.CFrame = CFrame.lookAt(PrimaryPart.Position + v12 * p12, PrimaryPart.Position) * CFrame.Angles(0, math.pi, 0)
				p1:SetAttribute("JuggleVelocity", v12 + Vector3.new(0, -p1:GetAttribute("FallSpeed") * p12, 0))
				p1:SetAttribute("FallSpeed", p1:GetAttribute("FallSpeed") + 0.8)
			end
		end)
		p1:GetAttributeChangedSignal("HitBy"):Connect(function() --[[ Line: 2961 | Upvalues: p1 (copy), t (ref) ]]
			if p1:GetAttribute("JuggleVelocity") == nil then
				return
			end

			local v1 = t.GetUpdatedPlayerPos(p1:FindFirstChild("HitTag").Value)
			local v2 = string.split(p1:GetAttribute("HitBy"), " ")[1]

			if v2 == "Uppercut" then
				p1:SetAttribute("JuggleVelocity", Vector3.new(0, 60, 0))

				return
			end

			if v2 == "Melee" then
				p1:SetAttribute("JuggleVelocity", v1.CFrame.LookVector * 60)

				return
			end

			if v2 ~= "CounterSwing" then
				return
			end

			p1:SetAttribute("JuggleVelocity", v1.CFrame.LookVector * 250)
		end)
	else
		warn("no primary part, cant connect to juggle system")
	end
end
function t.TablePicker(p1) --[[ Line: 2980 ]]
	return p1[math.random(1, #p1)]
end
function t.TextBubble(p1, p2) --[[ Line: 2983 | Upvalues: Sounds (copy), t (copy), Resources (copy), v5 (copy), LocalEvent (copy) ]]
	if p1:FindFirstChild("TextBubble") then
		p1.TextBubble:Destroy()
	end

	local Chat = Sounds.Chat

	if p1.Parent ~= nil then
		if p1.Parent:FindFirstChild("Wingedhelm") then
			task.wait()

			local v2 = t.TablePicker(if p1.Parent:GetAttribute("Health") == 0 then { "DryBones.mp3", "Shatter.mp3" } else { "*bone noises*", "*clatter*" })

			Chat = Sounds.BoneChat
			p2 = v2
		end

		if p1.Parent:GetAttribute("Type") == "Robot" then
			task.wait()

			local v4 = t.TablePicker(if p1.Parent:GetAttribute("Health") == 0 then { "ERROR: IM TOTALLY DEAD", "ERROR: JUST GOT ANNIHILATED", "SYSTEMS INOPERABLE, GOT GOT TOO HARD" } else { "beep", "borp", "zZZt." })

			Chat = Sounds.RobotChat
			p2 = v4
		end
	end

	local v52 = Resources.TextBubble:Clone()

	v52.Bubble.TextLabel.Text = p2
	v52.Parent = p1
	t.Debris(v52, 4)

	local Size = v52.Size
	local StudsOffset = v52.StudsOffset

	v52.Size = UDim2.fromScale(0, 0)
	v52.StudsOffset = Vector3.new(0, 0, 0)
	t.Tween(v52, {
		Size = Size,
		StudsOffset = StudsOffset
	}, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), true)
	t.PlaySound(Chat, p1, v5:NextNumber(0.9, 1.1), true)
	LocalEvent:FireAllClients("SystemMessage", { p2, p1.Parent:GetAttribute("ChatColor") or Color3.fromRGB(255, 255, 255) })
end
function t.TargetChatSystem(p1) --[[ Line: 3025 | Upvalues: ModifiersActive (copy), t (copy), v5 (copy) ]]
	if ModifiersActive:FindFirstChild("incessant chatter") == nil then
		return
	end

	local PrimaryPart = p1.PrimaryPart

	if not PrimaryPart then
		warn("no primary part, cant connect to chat system")

		return
	end

	local v1 = if p1:FindFirstChild("Head") then p1.Head else PrimaryPart

	p1:SetAttribute("ChatColor", if p1:FindFirstChild("Torso") then p1.Torso.Color elseif p1:FindFirstChild("Head") then p1.Head.Color else PrimaryPart.Color)

	local v3 = p1:GetAttribute("Health")
	local v4 = t.GetEnemiesStillAlive()
	local v52 = false
	local v6 = false

	local function JustSpoke() --[[ JustSpoke | Line: 3061 | Upvalues: v52 (ref), t (ref) ]]
		v52 = true
		task.spawn(function() --[[ Line: 3063 | Upvalues: t (ref), v52 (ref) ]]
			t.Wait(0.8)
			v52 = false
		end)
	end

	if math.random(1, 2) == 1 then
		local t2 = { "fear not, for i have arrived!", "your going down bruddah!", "prepare to be pwned.", "abc to get wrecked", "face my wrath!!" }
		local v7 = t.GetEnemiesStillAlive()
		local v8 = t.GetPlayersStillAlive()

		if v8 < v7 then
			table.insert(t2, "its a " .. v7 .. "v" .. v8 .. "! we have the advantage!")
		elseif v7 < v8 then
			table.insert(t2, "its a " .. v7 .. "v" .. v8 .. "! we\'re outnumbered!")
		else
			table.insert(t2, "its a " .. v7 .. "v" .. v8 .. "! we\'re even!")
		end

		t.TextBubble(v1, t.TablePicker(t2))
	end

	p1:GetAttributeChangedSignal("Health"):Connect(function() --[[ Line: 3087 | Upvalues: p1 (copy), t (ref), v1 (ref), v3 (ref), v52 (ref) ]]
		if p1:GetAttribute("Health") == 0 then
			t.TextBubble(v1, t.TablePicker({ "AARRGGH!!", "TELL MY COMRADES GOODBYE!!", "I GOT GOT!!", "X_X", "IVE BEEN PWNED!!" }))
		elseif p1:GetAttribute("Health") < v3 and v52 == false then
			v52 = true
			task.spawn(function() --[[ Line: 3063 | Upvalues: t (ref), v52 (ref) ]]
				t.Wait(0.8)
				v52 = false
			end)
			task.wait()

			local t2 = {
				"OWW.. that smarts...",
				"wth man stop being a bully!",
				"GAH! its gonna take more than that!",
				"EEEYYYEEOOWW!!",
				"pls stop attacking me thx",
				"why you do this?! why?!?",
				" 999 tokens if you let me win trust",
				"oh man now im peeved",
				"*discombobulated*"
			}

			if p1:GetAttribute("HitBy") == nil or string.split(p1:GetAttribute("HitBy"), " ")[1] ~= "Parry" then
				table.insert(t2, "OW OW OW IM NOT READY")
			else
				table.insert(t2, "OW ur so lame you gotta PARRY!! me!")
				table.insert(t2, "did i just get PARRIED?!")
			end

			t.TextBubble(v1, t.TablePicker(t2))
		end

		v3 = p1:GetAttribute("Health")
	end)
	task.spawn(function() --[[ Line: 3109 | Upvalues: p1 (copy), t (ref), v4 (ref), v6 (ref), v52 (ref), v1 (ref), v5 (ref) ]]
		while p1.Parent ~= nil do
			local v12 = t.GetEnemiesStillAlive()

			if p1:GetAttribute("Health") > 0 and (v12 == 1 and (v4 > 1 and v6 == false)) then
				v6 = true
				v52 = true
				t.TextBubble(v1, t.TablePicker({ "IM THE LAST ONE ALIVE?!", "JUST ME AND YOU NOW BRO", "1v1 ME BRO" }))
			elseif v12 < v4 then
				v4 = v12

				if math.random(1, 2) == 1 and v52 == false then
					v52 = true
					task.spawn(function() --[[ Line: 3063 | Upvalues: t (ref), v52 (ref) ]]
						t.Wait(0.8)
						v52 = false
					end)
					task.wait(v5:NextNumber(0.05, 0.2))
					t.TextBubble(v1, t.TablePicker({ "ally down!", "not good!", "im gonna be next!!", "im not getting paid enough for this!!", "can my teammates stop dying?!" }))
				end
			end

			task.wait()
		end
	end)
end
function t.WeldInPlace(p1, p2) --[[ Line: 3145 ]]
	local Weld = Instance.new("Weld")

	Weld.Part0 = p1
	Weld.Part1 = p2
	Weld.C1 = p2.CFrame:ToObjectSpace(p1.CFrame)
	Weld.Parent = p1
end

local function DestructFunc(p1, p2, p3) --[[ DestructFunc | Line: 3162 | Upvalues: EffectsFolder (copy), RunService (copy), t (copy), Sounds (copy), v5 (copy) ]]
	task.spawn(function() --[[ Line: 3164 | Upvalues: p2 (copy), EffectsFolder (ref), p3 (copy), RunService (ref), p1 (copy), t (ref), Sounds (ref), v5 (ref) ]]
		if not (p2:HasTag("Destructable") or p2:HasTag("Terrain")) then
			return
		end

		p2:RemoveTag("Destructable")
		p2:RemoveTag("Terrain")
		p2:ClearAllChildren()

		for k2, v in pairs(p2:GetConnectedParts()) do
			for k22, v2 in pairs(v:GetChildren()) do
				if (v2:IsA("WeldConstraint") or (v2:IsA("Weld") or v2:IsA("Snap"))) and (v2.Part0 == p2 or v2.Part1 == p2) then
					v2:Destroy()
				end
			end
		end

		p2.Parent = EffectsFolder
		p2.CollisionGroup = "Debris"

		if p3 then
			p2.AssemblyLinearVelocity = p3
		else
			local v2 = math.random(-50, 50)

			p2.AssemblyLinearVelocity = Vector3.new(v2, 20, math.random(-50, 50))
		end

		local v4 = math.random(-50, 50)
		local v52 = math.random(-50, 50)

		p2.AssemblyAngularVelocity = Vector3.new(v4, v52, math.random(-50, 50))
		p2.Anchored = false

		if RunService:IsServer() then
			if p1 == nil then
				p2:SetNetworkOwner(nil)
			else
				p2:SetNetworkOwner(p1)
			end
		end

		t.Timescaleify(p2)
		t.PlaySound(Sounds.DestructableDestructed, p2, v5:NextNumber(0.8, 1.2))
		t.Wait(4)
		p2.Anchored = true
		t.Tween(p2, {
			Position = p2.Position + Vector3.new(0, -20, 0)
		}, TweenInfo.new(6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), true)
		t.Debris(p2, 6)
	end)
end

function t.Destruct(p1, p2, p3, p4) --[[ Line: 3276 | Upvalues: RunService (copy), Remotes (copy), EffectsFolder (copy), t (copy), Sounds (copy), v5 (copy) ]]
	if not (p2:HasTag("Destructable") or p2:HasTag("Terrain")) then
		return
	end

	if RunService:IsClient() then
		if p1 ~= nil and p1:GetAttribute("CameraShake") == true then
			local v4 = Vector3.new(math.random(-1, 1) / 3, math.random(-1, 1) / 3, math.random(-1, 1) / 3)

			workspace.CamGroup:PivotTo(workspace.CamGroup:GetPivot() + v4)
		end

		Remotes.GFTransformEvent:FireServer("Destruct", { p1, p2, p3, p4 })
	elseif p3 == 1 then
		if p2:HasTag("Destructable") then
			task.spawn(function() --[[ Line: 3164 | Upvalues: p2 (copy), EffectsFolder (ref), p4 (copy), RunService (ref), p1 (copy), t (ref), Sounds (ref), v5 (ref) ]]
				if not (p2:HasTag("Destructable") or p2:HasTag("Terrain")) then
					return
				end

				p2:RemoveTag("Destructable")
				p2:RemoveTag("Terrain")
				p2:ClearAllChildren()

				for k2, v in pairs(p2:GetConnectedParts()) do
					for k22, v2 in pairs(v:GetChildren()) do
						if (v2:IsA("WeldConstraint") or (v2:IsA("Weld") or v2:IsA("Snap"))) and (v2.Part0 == p2 or v2.Part1 == p2) then
							v2:Destroy()
						end
					end
				end

				p2.Parent = EffectsFolder
				p2.CollisionGroup = "Debris"

				if p4 then
					p2.AssemblyLinearVelocity = p4
				else
					local v2 = math.random(-50, 50)

					p2.AssemblyLinearVelocity = Vector3.new(v2, 20, math.random(-50, 50))
				end

				local v4 = math.random(-50, 50)
				local v52 = math.random(-50, 50)

				p2.AssemblyAngularVelocity = Vector3.new(v4, v52, math.random(-50, 50))
				p2.Anchored = false

				if RunService:IsServer() then
					if p1 == nil then
						p2:SetNetworkOwner(nil)
					else
						p2:SetNetworkOwner(p1)
					end
				end

				t.Timescaleify(p2)
				t.PlaySound(Sounds.DestructableDestructed, p2, v5:NextNumber(0.8, 1.2))
				t.Wait(4)
				p2.Anchored = true
				t.Tween(p2, {
					Position = p2.Position + Vector3.new(0, -20, 0)
				}, TweenInfo.new(6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), true)
				t.Debris(p2, 6)
			end)
		end
	else
		if not (p3 >= 2 and (p2:HasTag("Destructable") or p2:HasTag("Terrain"))) then
			return
		end

		task.spawn(function() --[[ Line: 3164 | Upvalues: p2 (copy), EffectsFolder (ref), p4 (copy), RunService (ref), p1 (copy), t (ref), Sounds (ref), v5 (ref) ]]
			if not (p2:HasTag("Destructable") or p2:HasTag("Terrain")) then
				return
			end

			p2:RemoveTag("Destructable")
			p2:RemoveTag("Terrain")
			p2:ClearAllChildren()

			for k2, v in pairs(p2:GetConnectedParts()) do
				for k22, v2 in pairs(v:GetChildren()) do
					if (v2:IsA("WeldConstraint") or (v2:IsA("Weld") or v2:IsA("Snap"))) and (v2.Part0 == p2 or v2.Part1 == p2) then
						v2:Destroy()
					end
				end
			end

			p2.Parent = EffectsFolder
			p2.CollisionGroup = "Debris"

			if p4 then
				p2.AssemblyLinearVelocity = p4
			else
				local v2 = math.random(-50, 50)

				p2.AssemblyLinearVelocity = Vector3.new(v2, 20, math.random(-50, 50))
			end

			local v4 = math.random(-50, 50)
			local v52 = math.random(-50, 50)

			p2.AssemblyAngularVelocity = Vector3.new(v4, v52, math.random(-50, 50))
			p2.Anchored = false

			if RunService:IsServer() then
				if p1 == nil then
					p2:SetNetworkOwner(nil)
				else
					p2:SetNetworkOwner(p1)
				end
			end

			t.Timescaleify(p2)
			t.PlaySound(Sounds.DestructableDestructed, p2, v5:NextNumber(0.8, 1.2))
			t.Wait(4)
			p2.Anchored = true
			t.Tween(p2, {
				Position = p2.Position + Vector3.new(0, -20, 0)
			}, TweenInfo.new(6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), true)
			t.Debris(p2, 6)
		end)
	end
end
function t.IsEitherTargetValid(p1) --[[ Line: 3301 | Upvalues: PlayerFolder (copy), EnemyFolder (copy), Players (copy) ]]
	if p1 == nil then
		return false
	end

	if p1.Parent == nil then
		return false
	end

	if p1.Parent ~= PlayerFolder and p1.Parent ~= EnemyFolder then
		return false
	end

	if p1:FindFirstChild("Humanoid") ~= nil and p1.Humanoid.Health == 0 then
		return false
	end

	local v1 = Players:GetPlayerFromCharacter(p1)

	if v1 and v1:GetAttribute("Dead") == true then
		return false
	end

	return p1:GetAttribute("Alive") ~= false
end
function t.IsTargetValid(p1) --[[ Line: 3321 | Upvalues: PlayerFolder (copy), Players (copy) ]]
	if p1 == nil then
		return false
	end

	if p1.Parent == nil then
		return false
	end

	if p1.Parent ~= PlayerFolder then
		return false
	end

	if p1:FindFirstChild("Humanoid") ~= nil and p1.Humanoid.Health == 0 then
		return false
	end

	local v1 = Players:GetPlayerFromCharacter(p1)

	return (not v1 or v1:GetAttribute("Dead") ~= true) and true or false
end
function t.IsEnemyTargetValid(p1) --[[ Line: 3334 | Upvalues: EnemyFolder (copy) ]]
	if p1 == nil then
		return false
	end

	if p1.Parent == nil then
		return false
	end

	if p1.Parent == EnemyFolder then
		return p1:GetAttribute("Alive") ~= false
	end

	return false
end
function t.GetClosestTarget(p1, p2, p3) --[[ Line: 3344 | Upvalues: EnemyFolder (copy), t (copy) ]]
	if p1.Parent == EnemyFolder then
		return t.GetClosestPlayer(p2, p3)
	end

	return t.GetClosestEnemy(p2, p3)
end
function t.GetClosestPlayer(p1, p2) --[[ Line: 3353 | Upvalues: PlayerFolder (copy), Players (copy) ]]
	if p1.Magnitude == (1 / 0) then
		p1 = Vector3.new(0, 0, 0)
	end

	if p2 == nil then
		p2 = false
	end

	local v1 = nil

	repeat
		local v2 = (1 / 0)
		local v3 = nil

		for k, v in pairs(PlayerFolder:GetChildren()) do
			if v:FindFirstChild("Humanoid") and (v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0) then
				local v4 = Players:GetPlayerFromCharacter(v)

				if ((not v4 or v4:GetAttribute("Dead") ~= true) and true or false) == true then
					local Magnitude = (p1 - v.HumanoidRootPart.Position).Magnitude

					if Magnitude < v2 and Magnitude > 0.1 then
						v2 = Magnitude
						v3 = v
					end
				end
			end
		end

		if v3 then
			local Humanoid = v3.Humanoid

			v1 = if Humanoid.Sit == true and Humanoid.SeatPart.Name == "MechSeat" then Humanoid.SeatPart.Parent else v3
			p2 = false

			continue
		end

		task.wait()
	until p2 == false

	return v1
end
function t.GetRandomPlayer() --[[ Line: 3398 | Upvalues: PlayerFolder (copy), Players (copy) ]]
	local v1 = nil

	while true do
		if #PlayerFolder:GetChildren() > 0 then
			v1 = PlayerFolder:GetChildren()[math.random(1, #PlayerFolder:GetChildren())]

			local v2 = Players:GetPlayerFromCharacter(v1)
			local Humanoid = v1.Humanoid

			if v2 and (v2:GetAttribute("Dead") == false and (Humanoid.Sit == true and Humanoid.SeatPart.Name == "MechSeat")) then
				v1 = Humanoid.SeatPart.Parent
			end
		end

		if v1 then
			break
		end

		task.wait()
	end

	return v1
end
function t.GetClosestEnemy(p1, p2) --[[ Line: 3426 | Upvalues: EnemyFolder (copy), t (copy) ]]
	if p2 == nil then
		p2 = false
	end

	local v1 = nil

	repeat
		local v2 = (1 / 0)
		local v3 = nil

		for k, v in pairs(EnemyFolder:GetChildren()) do
			if t.IsEnemyTargetValid(v) then
				local Magnitude = (p1 - v.PrimaryPart.Position).Magnitude

				if Magnitude < v2 then
					v2 = Magnitude
					v3 = v
				end
			end
		end

		if v3 then
			p2 = false
			v1 = v3

			continue
		end

		task.wait()
	until p2 == false

	return v1
end
function t.GetClosestFromList(p1, p2) --[[ Line: 3459 ]]
	local v1 = (1 / 0)
	local v2 = nil

	for v3, v4 in p2 do
		local Magnitude = (p1 - v4.Position).Magnitude

		if Magnitude < v1 then
			v1 = Magnitude
			v2 = v4
		end
	end

	return v2
end
function t.IsInsideMap(p1) --[[ Line: 3476 ]]
	return not (p1.X < -260 or (p1.X > 260 or (p1.Z < -260 or (p1.Z > 260 or (p1.Y < -5 or p1.Y > 300)))))
end
function t.CancelStreakMultiplier(p1) --[[ Line: 3486 ]]
	for k, v in pairs(p1:GetChildren()) do
		if v.Name == "StreakMultiplier" then
			v:Destroy()
		end
	end
end
function t.streakmultfunc(p1, p2, p3, p4) --[[ Line: 3498 | Upvalues: ReplicatedStorage (copy), t (copy), Debris (copy), RunService (copy) ]]
	if p2 == 0 then
		return
	end

	if ReplicatedStorage.Intro.Value ~= true then
		task.spawn(function() --[[ Line: 3502 | Upvalues: p1 (copy), p2 (ref), t (ref), p4 (copy), Debris (ref), p3 (copy), RunService (ref), ReplicatedStorage (ref) ]]
			local v1 = 10
			local StreakMultiplier = Instance.new("BoolValue")

			StreakMultiplier.Name = "StreakMultiplier"
			StreakMultiplier.Parent = p1

			if p1:GetAttribute("Curse") then
				p2 = p2 * 2
				v1 = v1 * 2
			end

			local StreakFrame = p1.PlayerGui.MainGui.StreakFrame
			local MultiplierLabel = StreakFrame.MultiplierLabel
			local MultiplierAdded = StreakFrame.MultiplierAddedFrame.MultiplierAddedTemplate:Clone()
			local v2 = p1:GetAttribute("StreakMultiplier")
			local v4 = math.min(v2 + p2, v1) - v2

			p1:SetAttribute("StreakMultiplier", v2 + v4)
			MultiplierLabel.Text = t.FloatingPointDemolisher(p1:GetAttribute("StreakMultiplier")) .. "X"
			MultiplierAdded.Visible = true

			local v5 = t.FloatingPointDemolisher(p2)

			if p4 == nil then
				MultiplierAdded.Text = v5
			elseif p4 == false then
				MultiplierAdded.Visible = false
			else
				MultiplierAdded.Text = "+" .. v5 .. " " .. p4
			end

			MultiplierAdded.Name = "MultiplierAdded"
			MultiplierAdded.Parent = StreakFrame.MultiplierAddedFrame
			Debris:AddItem(MultiplierAdded, 1.5)
			task.wait(1)

			if MultiplierAdded.Parent then
				t.Tween(MultiplierAdded, {
					TextTransparency = 1
				}, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
				t.Tween(MultiplierAdded.UIStroke, {
					Transparency = 1
				}, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
			end

			local v6 = p3

			if type(v6) == "number" then
				local v7 = 0
				local v9 = RunService.Heartbeat:Connect(function(p1) --[[ Line: 3551 | Upvalues: ReplicatedStorage (ref), StreakMultiplier (copy), v7 (ref), p3 (ref) ]]
					if ReplicatedStorage.Intro.Value ~= false then
						return
					end

					if StreakMultiplier.Parent then
						v7 = v7 + p1

						return
					end

					v7 = p3
				end)

				repeat
					task.wait()
				until p3 <= v7

				v9:Disconnect()
			else
				task.wait(0.1)

				repeat
					task.wait()
				until p1:GetAttribute("StreakTime") == 0
			end

			p1:SetAttribute("StreakMultiplier", p1:GetAttribute("StreakMultiplier") - v4)
			MultiplierLabel.Text = t.FloatingPointDemolisher(p1:GetAttribute("StreakMultiplier")) .. "X"
			StreakMultiplier:Destroy()
		end)
	end
end
function t.StreakMultiplier(p1, p2, p3, p4) --[[ Line: 3594 | Upvalues: ServerToServer (copy) ]]
	ServerToServer:Fire("StreakMultiplier", { p1, p2, p3, p4 })
end
function t.AddStreak(p1, p2, p3) --[[ Line: 3599 | Upvalues: ReplicatedStorage (copy), LocalEvent (copy), Debris (copy), t (copy) ]]
	if ReplicatedStorage.Intro.Value ~= false then
		return
	end

	p1:SetAttribute("StreakTime", 5)

	if p1:GetAttribute("PureStreak") == nil then
		p1:SetAttribute("PureStreak", p2)
	else
		p1:SetAttribute("PureStreak", p1:GetAttribute("PureStreak") + p2)
	end

	LocalEvent:FireClient(p1, "AddDrums")
	task.spawn(function() --[[ Line: 3614 | Upvalues: p1 (copy), p2 (ref), ReplicatedStorage (ref), p3 (copy), Debris (ref), t (ref) ]]
		local StreakFrame = p1.PlayerGui.MainGui.StreakFrame
		local StreakAdded = StreakFrame.AddedFrame.StreakAddedTemplate:Clone()

		if p2 >= 100 then
			StreakAdded.Size = StreakAdded.Size + UDim2.fromScale(0, 0.04)
		end

		p2 = p2 * p1:GetAttribute("StreakMultiplier")
		p2 = p2 * ReplicatedStorage.GlobalScoreMultiplier.Value

		if p2 > 0 then
			StreakAdded.Text = p3 .. ": " .. math.round(p2)
		else
			StreakAdded.Text = p3
		end

		StreakAdded.Visible = true
		StreakAdded.Name = "StreakAdded"
		StreakAdded.Parent = StreakFrame.AddedFrame
		Debris:AddItem(StreakAdded, 1.5)

		local v2 = p1:GetAttribute("Streak") + p2

		p1:SetAttribute("Streak", v2)
		StreakFrame.ScoreLabel.Text = "STREAK: " .. math.round(v2)

		if v2 >= 9000 then
			StreakFrame.StyleLabel.Text = "PARRION OVER 9000"
		elseif v2 >= 3000 then
			StreakFrame.StyleLabel.Text = "< ELITE PARRION >"
		elseif v2 >= 2000 then
			StreakFrame.StyleLabel.Text = "FLOW STATE"
		elseif v2 >= 1000 then
			StreakFrame.StyleLabel.Text = "GOLDEN WRAPPER 1K"
		elseif v2 >= 800 then
			StreakFrame.StyleLabel.Text = "FLAMIN DORITO"
		elseif v2 >= 600 then
			StreakFrame.StyleLabel.Text = "getting SPICY"
		elseif v2 >= 400 then
			StreakFrame.StyleLabel.Text = "move on up!"
		elseif v2 >= 200 then
			StreakFrame.StyleLabel.Text = "advancing..."
		else
			StreakFrame.StyleLabel.Text = "struggling"
		end

		task.wait(1)

		if not StreakAdded.Parent then
			return
		end

		t.Tween(StreakAdded, {
			TextTransparency = 1
		}, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
		t.Tween(StreakAdded.UIStroke, {
			Transparency = 1
		}, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
	end)
end
function t.StreakOver(p1) --[[ Line: 3678 | Upvalues: Players (copy), LocalEvent (copy), Sounds (copy), t (copy) ]]
	if p1:GetAttribute("Streak") == 0 then
		return
	end

	p1:SetAttribute("PureStreak", nil)

	for k, v in pairs(p1.PlayerGui.MainGui.StreakFrame.AddedFrame:GetChildren()) do
		if v.Name == "AddedFrame" then
			v:Destroy()
		end
	end

	for k, v in pairs(Players:GetPlayers()) do
		task.spawn(function() --[[ Line: 3690 | Upvalues: p1 (copy), LocalEvent (ref), Sounds (ref) ]]
			local v1 = p1.PlayerGui.MainGui.PlayerBars:FindFirstChild(p1.Name)

			if not v1 then
				return
			end

			local v3 = math.round((p1:GetAttribute("Streak")))
			local StreakScore = v1.StreakScore

			if StreakScore.Visible ~= false then
				return
			end

			StreakScore.Visible = true
			LocalEvent:FireClient(p1, "PlaySound", { Sounds.StreakOver, workspace })

			for i = 1, 15 do
				StreakScore.Text = "*" .. v3 .. "*"
				task.wait(0.1)
				StreakScore.Text = v3
				task.wait(0.1)
			end

			if v3 >= 2000 then
				StreakScore.Text = "EXTREME!!"
			elseif v3 >= 1000 then
				StreakScore.Text = "NICE!"
			elseif v3 >= 50 then
				StreakScore.Text = "OK"
			else
				StreakScore.Text = "ew..."
			end

			task.wait(1)
			StreakScore.Visible = false
		end)
	end

	p1:SetAttribute("Score", p1:GetAttribute("Score") + p1:GetAttribute("Streak"))
	p1:SetAttribute("Streak", 0)
	t.CheckScore(p1)
	t.ScoreLabels(p1)
end
function t.AddGlobalMultiplier(p1, p2) --[[ Line: 3737 | Upvalues: ReplicatedStorage (copy), Remotes (copy) ]]
	ReplicatedStorage.GlobalScoreMultiplier.Value = math.max(ReplicatedStorage.GlobalScoreMultiplier.Value + p1, 0.5)
	Remotes.GlobalMultChanged:FireAllClients(ReplicatedStorage.GlobalScoreMultiplier.Value, p2 or "")
end
function t.Invincible(p1, p2, p3, p4) --[[ Line: 3746 | Upvalues: Resources (copy), t (copy) ]]
	if p2 > 0 then
		task.spawn(function() --[[ Line: 3748 | Upvalues: p3 (copy), p1 (copy), Resources (ref), p4 (copy), t (ref), p2 (copy) ]]
			local Forcefield = Instance.new("ForceField")

			Forcefield.Name = "Forcefield"
			Forcefield.Visible = p3
			Forcefield.Parent = p1

			local v1 = Resources.InvincibleHighlight:Clone()

			v1.Parent = p1

			if p4 and p4 == true then
				t.Wait(p2)
			else
				task.wait(p2)
			end

			Forcefield:Destroy()
			v1:Destroy()
		end)
	else
		warn("why would you call invincible with 0 time?? might as well just not call it at all...")
	end
end
function t.AddResistance(p1, p2, p3, p4) --[[ Line: 3779 | Upvalues: Players (copy), t (copy), Debris (copy) ]]
	local v1

	if p1:FindFirstChild("MechSeat") or p1.Parent == Players then
		v1 = p1.ResistanceFolder
	else
		if t.GetPlayerFromModel(p1) == nil then
			return
		end

		v1 = t.GetPlayerFromModel(p1).ResistanceFolder
	end

	local v2 = v1:FindFirstChild(p4 .. "Resistance")

	if v2 then
		if v2.Value == p2 then
			return
		end

		v2:Destroy()
	end

	local v3 = Instance.new("NumberValue")

	v3.Value = p2
	v3.Name = p4 .. "Resistance"
	v3.Parent = v1

	if not (p3 > 0) then
		return
	end

	Debris:AddItem(v3, p3)
end
function t.RemoveResistance(p1, p2) --[[ Line: 3810 | Upvalues: Players (copy), t (copy) ]]
	local v1

	if p1.Parent == Players then
		v1 = p1.ResistanceFolder
	else
		if t.GetPlayerFromModel(p1) == nil then
			return
		end

		v1 = t.GetPlayerFromModel(p1).ResistanceFolder
	end

	if not v1:FindFirstChild(p2 .. "Resistance") then
		return
	end

	v1:FindFirstChild(p2 .. "Resistance"):Destroy()
end
function t.AttackWarning(p1, p2, p3, p4, p5) --[[ Line: 3830 | Upvalues: Resources (copy), EffectsFolder (copy), t (copy), Debris (copy) ]]
	local v1 = Resources.AttackWarning:Clone()

	v1.CFrame = p1
	v1.Size = p2
	v1.Shape = p3
	v1.Parent = EffectsFolder

	if p5 == true then
		t.Debris(v1, p4)
	else
		Debris:AddItem(v1, p4)
	end

	return v1
end
function t.AttackHighlight(p1, p2, p3) --[[ Line: 3851 | Upvalues: Resources (copy), HttpService (copy), t (copy) ]]
	task.spawn(function() --[[ Line: 3852 | Upvalues: Resources (ref), p1 (copy), HttpService (ref), p3 (copy), p2 (copy), t (ref) ]]
		local v1 = Resources.PreAttackHighlight:Clone()

		v1.FillColor = Color3.fromRGB(v1.FillColor.R * 255 + math.random(-1, 1), v1.FillColor.G * 255 + math.random(-1, 1), v1.FillColor.B * 255 + math.random(-1, 1))
		v1.Adornee = p1
		v1.Name = HttpService:GenerateGUID()
		v1.Parent = game.TweenService

		if p3 == false then
			task.wait(p2 - 0.3)
		else
			t.Wait(p2 - 0.3)
		end

		v1.FillColor = Color3.fromRGB(math.random(250, 255), math.random(250, 255), math.random(250, 255))
		v1.FillTransparency = 0.5

		if p3 == false then
			task.wait(0.3)
		else
			t.Wait(0.3)
		end

		v1:Destroy()
	end)
end
function t.DeadlyAttackColors(p1, p2, p3) --[[ Line: 3888 | Upvalues: t (copy) ]]
	task.spawn(function() --[[ Line: 3889 | Upvalues: p1 (copy), p2 (copy), p3 (copy), t (ref) ]]
		local Color = p1.Color

		for i = 1, p2 * 10 do
			if p1.Parent == nil then
				return
			end

			if p3 == true then
				p1.Color = Color3.fromRGB(154, 0, 0)
			else
				p1.Color = Color3.fromRGB(255, 0, 0)
			end

			t.Wait(0.05)

			if p1.Parent == nil then
				return
			end

			if p3 == true then
				p1.Color = Color3.fromRGB(162, 135, 0)
			else
				p1.Color = Color3.fromRGB(255, 213, 0)
			end

			t.Wait(0.05)
		end

		p1.Color = Color
	end)
end
function t.DeadlyAttackHighlight(p1, p2) --[[ Line: 3917 | Upvalues: t (copy) ]]
	task.spawn(function() --[[ Line: 3918 | Upvalues: p1 (copy), p2 (copy), t (ref) ]]
		local Highlight = Instance.new("Highlight")

		Highlight.OutlineTransparency = 1
		Highlight.FillColor = Color3.fromRGB(255, 213, 0)
		Highlight.Parent = p1

		for i = 1, p2 * 10 do
			if Highlight.Parent == nil then
				return
			end

			Highlight.FillColor = Color3.fromRGB(255, 0, 0)
			t.Wait(0.05)

			if Highlight.Parent == nil then
				return
			end

			Highlight.FillColor = Color3.fromRGB(255, 213, 0)
			t.Wait(0.05)
		end

		Highlight:Destroy()
	end)
end
function t.DeadlyAttackSound(p1) --[[ Line: 3941 | Upvalues: t (copy), Sounds (copy) ]]
	task.spawn(function() --[[ Line: 3942 | Upvalues: t (ref), Sounds (ref), p1 (copy) ]]
		for i = 1, 3 do
			t.PlaySound(Sounds.DeadlyAttackWarning, p1)
			t.Wait(0.2)
		end
	end)
end
function t.Shockwave(p1, p2, p3, p4) --[[ Line: 3951 | Upvalues: Resources (copy), v5 (copy), EffectsFolder (copy), t (copy), Debris (copy) ]]
	if p4 == nil then
		p4 = true
	end

	local v1 = Resources.Shockwave:Clone()

	v1.Position = p1
	v1.Orientation = Vector3.new(0, v5:NextNumber(-180, 180), 0)
	v1.Parent = EffectsFolder

	if p4 == true then
		t.Tween(v1, {
			Transparency = 1,
			CFrame = v1.CFrame * CFrame.Angles(0, math.pi, 0),
			Size = p2
		}, TweenInfo.new(p3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), true)
		t.Debris(v1, p3)
	else
		t.Tween(v1, {
			Transparency = 1,
			CFrame = v1.CFrame * CFrame.Angles(0, math.pi, 0),
			Size = p2
		}, TweenInfo.new(p3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
		Debris:AddItem(v1, p3)
	end

	return v1
end
function t.Shockwave2(p1, p2, p3, p4) --[[ Line: 3969 | Upvalues: Resources (copy), EffectsFolder (copy), t (copy), Debris (copy) ]]
	if p4 == nil then
		p4 = true
	end

	local v1 = Resources.Ring:Clone()

	v1.CFrame = p1
	v1.Parent = EffectsFolder

	if p4 == true then
		t.Tween(v1, {
			Transparency = 1,
			CFrame = v1.CFrame,
			Size = p2
		}, TweenInfo.new(p3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), true)
		t.Debris(v1, p3)
	else
		t.Tween(v1, {
			Transparency = 1,
			CFrame = v1.CFrame,
			Size = p2
		}, TweenInfo.new(p3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
		Debris:AddItem(v1, p3)
	end

	return v1
end
function t.Distortion(p1, p2, p3, p4, p5, p6) --[[ Line: 3988 | Upvalues: Resources (copy), EffectsFolder (copy), t (copy), Debris (copy) ]]
	local v1 = Resources.Distortion:Clone()

	v1.CFrame = p1
	v1.Size = p2
	v1.Transparency = p3
	v1.Parent = EffectsFolder

	if p6 == true then
		t.Tween(v1, {
			Transparency = 1,
			Size = p4
		}, TweenInfo.new(p5, Enum.EasingStyle.Linear, Enum.EasingDirection.In), true)
		t.Debris(v1, p5)
	else
		t.Tween(v1, {
			Transparency = 1,
			Size = p4
		}, TweenInfo.new(p5, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
		Debris:AddItem(v1, p5)
	end
end
function t.TexturePart(p1, p2) --[[ Line: 4009 ]]
	if not p2 then
		return
	end

	p1.Color = p2.Instance.Color
	p1.Material = p2.Material

	for k, v in pairs(p2.Instance:GetChildren()) do
		if v:IsA("Texture") and v.Face == "Top" then
			local v1 = v:Clone()

			v1.Face = "Top"
			v1.Parent = p1

			local v2 = v:Clone()

			v2.Face = "Bottom"
			v2.Parent = p1

			local v3 = v:Clone()

			v3.Face = "Front"
			v3.Parent = p1

			local v4 = v:Clone()

			v4.Face = "Right"
			v4.Parent = p1

			local v5 = v:Clone()

			v5.Face = "Back"
			v5.Parent = p1

			local v6 = v:Clone()

			v6.Face = "Left"
			v6.Parent = p1
		end
	end
end
function t.Rubble(p1, p2, p3, p4) --[[ Line: 4045 | Upvalues: t (copy), EffectsFolder (copy) ]]
	task.spawn(function() --[[ Line: 4046 | Upvalues: p1 (copy), t (ref), EffectsFolder (ref), p2 (copy), p3 (copy), p4 (copy) ]]
		local Part = Instance.new("Part")
		local v1 = CFrame.new(p1.Position)
		local v2 = math.random(-2, 2)

		Part.CFrame = v1 + Vector3.new(v2, 0, math.random(-2, 2))

		local v3 = math.random(-360, 360)
		local v4 = math.random(-360, 360)

		Part.Orientation = Vector3.new(v3, v4, math.random(-360, 360))

		local v5 = math.random(1, 2)
		local v6 = math.random(1, 2)

		Part.Size = Vector3.new(v5, v6, math.random(1, 2))
		Part.CollisionGroup = "Debris"
		t.TexturePart(Part, p1)
		Part.Parent = EffectsFolder

		if p2 == false then
			Part.AssemblyLinearVelocity = p3

			local v7 = math.random(-50, 50)
			local v8 = math.random(-50, 50)

			Part.AssemblyAngularVelocity = Vector3.new(v7, v8, math.random(-50, 50))
			t.Timescaleify(Part)

			if p4 then
				Part:SetNetworkOwner(p4)
			end
		end

		t.Wait(4)
		Part.Anchored = true
		t.Tween(Part, {
			Size = Vector3.new(0, 0, 0)
		}, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), true)
		t.Debris(Part, 3)
	end)
end
function t.QuicktimeEvent(p1, p2) --[[ Line: 4082 | Upvalues: Resources (copy), LocalEvent (copy), RunService (copy), t (copy), Debris (copy) ]]
	local v1 = nil
	local v2 = p2 / workspace:GetAttribute("TimeScale")
	local v3 = 0.5 / workspace:GetAttribute("TimeScale")
	local v4 = 0
	local v5 = math.random(100000, 999999)
	local v6 = Resources.QuicktimeGui:Clone()

	v6.Parent = p1.PlayerGui
	LocalEvent:FireClient(p1, "QuicktimeEvent", { v6, v2, v3, v5 })

	local v7 = p1:GetNetworkPing()
	local v8 = RunService.Heartbeat:Connect(function(p1) --[[ Line: 4102 | Upvalues: v4 (ref), v2 (ref), v3 (copy), v6 (copy), v7 (copy), v1 (ref) ]]
		v4 = v4 + p1 * workspace:GetAttribute("TimeScale")

		if v2 - v3 < v4 and v4 < v2 then
			v6:SetAttribute("WindowActive", true)
		else
			v6:SetAttribute("WindowActive", false)
		end

		if not (v2 + v7 < v4) then
			return
		end

		v1 = false
		v6:Destroy()
		print("quicktime failed, never pressed")
	end)

	t.Wait(v2 / 2)
	print("quicktime now live")

	local v9 = LocalEvent.OnServerEvent:Connect(function(p1, p2, p3) --[[ Line: 4123 | Upvalues: v5 (copy), v1 (ref) ]]
		if p2 ~= "QuicktimeEvent" or p3[1] ~= v5 then
			return
		end

		if p3[2] == true then
			v1 = true
			print("quicktime success")

			return
		end

		v1 = false
		print("quicktime failed, bad timing")
	end)
	local v10, v11 = v8, v9

	repeat
		task.wait()
	until v1 == false or v1 == true

	v10:Disconnect()
	v11:Disconnect()
	Debris:AddItem(v6, 5)

	return v1
end
function t.SpamEvent(p1, p2, p3) --[[ Line: 4151 | Upvalues: Resources (copy), LocalEvent (copy), t (copy), Debris (copy) ]]
	local v1 = 0
	local v2 = math.random(100000, 999999)
	local v3 = Resources.SpamGui:Clone()

	v3.Parent = p1.PlayerGui
	LocalEvent:FireClient(p1, "SpamEvent", { v3, p2, p3, v2 })

	local v4 = p1:GetNetworkPing()
	local v5 = LocalEvent.OnServerEvent:Connect(function(p1, p2, p3) --[[ Line: 4163 | Upvalues: v2 (copy), v1 (ref) ]]
		if p2 ~= "SpamEvent" or p3[1] ~= v2 then
			return
		end

		v1 = v1 + 1
	end)

	t.Wait(p2)
	task.wait(v4)
	v5:Disconnect()
	Debris:AddItem(v3, 5)

	local v6 = p3 <= v1

	return v6
end
function t.ShowDisasterWarnings(p1, p2, p3, p4) --[[ Line: 4184 | Upvalues: LocalEvent (copy) ]]
	LocalEvent:FireAllClients("ShowDisasterWarnings", { p1, p2, p3, p4 })
end
function t.HideDisasterWarnings() --[[ Line: 4191 | Upvalues: LocalEvent (copy) ]]
	LocalEvent:FireAllClients("HideDisasterWarnings")
end
function t.LinearVel(p1, p2, p3, p4, p5) --[[ Line: 4199 | Upvalues: t (copy), RunService (copy), Debris (copy) ]]
	local LinearVel = Instance.new("LinearVelocity")

	LinearVel.Attachment0 = p1
	LinearVel.ForceLimitsEnabled = false
	LinearVel.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector

	if p5 then
		LinearVel.Name = p5
	else
		LinearVel.Name = "LinearVel"
	end

	LinearVel.Parent = p1

	if p4 and p4 == true then
		t.Debris(LinearVel, p3)

		local v1 = nil

		v1 = RunService.Heartbeat:Connect(function(p1) --[[ Line: 4211 | Upvalues: LinearVel (copy), p2 (copy), v1 (ref) ]]
			LinearVel.VectorVelocity = p2

			if LinearVel.Parent == nil then
				v1:Disconnect()
			end
		end)
	else
		LinearVel.VectorVelocity = p2
		Debris:AddItem(LinearVel, p3)
	end

	return LinearVel
end
function t.AddAbility(p1, p2) --[[ Line: 4230 | Upvalues: Resources (copy), t (copy), LocalEvent (copy), Sounds (copy) ]]
	task.spawn(function() --[[ Line: 4231 | Upvalues: p1 (copy), p2 (copy), Resources (ref), t (ref), LocalEvent (ref), Sounds (ref) ]]
		if p1:GetAttribute("Ability") ~= p2 or p1.PlayerGui.MainGui.AbilityFrame:FindFirstChild(p2) ~= nil then
			return
		end

		local v1 = Resources.AbilityTemplate:Clone()
		local PositionLabel = v1.PositionLabel
		local v2 = if p1:GetAttribute("Device") == "Computer" then p1:GetAttribute("AbilityKeybind") else t.InputTable(p1, "Z")
		local v5 = p2

		if v5 == "SwapSummon" then
			v5 = "cycle tool"
		end

		v1.MainFrame.ButtonLabel.Text = v2
		v1.MainFrame.TitleLabel.Text = v5
		v1.Name = p2
		v1.Parent = p1.PlayerGui.MainGui.AbilityFrame

		for i = 1, 3 do
			PositionLabel.Visible = true
			LocalEvent:FireClient(p1, "PlaySound", { Sounds.Notice, workspace })
			task.wait(0.3)
			PositionLabel.Visible = false
			task.wait(0.3)
		end
	end)
end
function t.Boomsplotion(p1, p2, p3, p4) --[[ Line: 4270 | Upvalues: Resources (copy), EffectsFolder (copy), RunService (copy), LocalEvent (copy), t (copy) ]]
	local v1 = Resources.Explosion:Clone()

	v1.Position = p1
	v1.Parent = EffectsFolder

	if p2 then
		v1.Size = Vector3.new(p2, p2, p2)
		v1.Gui.Size = UDim2.fromScale(p2 + 3, p2 + 3)
	end

	if p4 then
		v1.Color = p4
		v1.Gui.Label.ImageColor3 = p4
	end

	if RunService:IsServer() then
		if not p3 then
			p3 = 1.5
		end

		LocalEvent:FireAllClients("CameraShake", { p3, 60, v1.Position })
	end

	t.Tween(v1, {
		Size = Vector3.new(0, 0, 0)
	}, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In), true)
	t.Tween(v1.Gui, {
		Size = UDim2.fromScale(0, 0)
	}, TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.In), true)
	t.Debris(v1, 0.6)
end
function t.NewSong(p1, p2) --[[ Line: 4305 | Upvalues: RunService (copy), LocalEvent (copy), ModifiersActive (copy), Songs (copy), Players (copy), ReplicatedStorage (copy), t (copy) ]]
	if RunService:IsServer() then
		LocalEvent:FireAllClients("NewSong", { p1, p2 })
	end

	if not RunService:IsClient() then
		return
	end

	if ModifiersActive:FindFirstChild("taste the rainbow") and p1:GetAttribute("ReplaceableByMetal") == true then
		p1 = Songs.METAL
	end

	if workspace:FindFirstChild("CurrentSong") then
		if workspace.CurrentSong.SoundId == p1.SoundId and (not string.find(p1.Name, "Pong") and (not string.find(p1.Name, "Gameshow") and p1.SoundId ~= Songs.METAL.SoundId)) then
			return
		end

		workspace.CurrentSong:Destroy()
	end

	local v1 = nil

	for k, v in pairs(Players.LocalPlayer.EquippedItems:GetChildren()) do
		if v:GetAttribute("Type") == ReplicatedStorage.CurrentStage.Value.Name .. "Song" and string.find(p1.Name, "Default") ~= nil then
			v1 = Songs:FindFirstChild(v.Name)
		end
	end

	local CurrentSong = if v1 == nil then p1:Clone() else v1:Clone()

	CurrentSong.Name = "CurrentSong"
	CurrentSong.Parent = workspace
	CurrentSong.PlaybackSpeed = workspace:GetAttribute("TimeScale")
	CurrentSong:Play()

	if CurrentSong:FindFirstChild("Drums") then
		CurrentSong.Drums.PlaybackSpeed = workspace:GetAttribute("TimeScale")

		if workspace:GetAttribute("TimeScale") >= 1.5 then
			local Drums = CurrentSong.Drums

			Drums.PlaybackSpeed = Drums.PlaybackSpeed / 2
		end

		CurrentSong.Drums:Play()
	end

	if p2 == true then
		task.spawn(function() --[[ Line: 4368 | Upvalues: Players (ref), CurrentSong (ref), t (ref) ]]
			local PopupFrame = Players.LocalPlayer.PlayerGui.SongPlayingGui.PopupFrame

			PopupFrame.Stuff.Title.Text = CurrentSong:GetAttribute("Name")
			PopupFrame.Stuff.Creator.Text = CurrentSong:GetAttribute("Creator")
			PopupFrame.Stuff.Description.Text = CurrentSong:GetAttribute("Description")
			t.Tween(PopupFrame, {
				Position = UDim2.fromScale(1.1, 0.95)
			}, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
			task.wait(4)
			t.Tween(PopupFrame, {
				Position = UDim2.fromScale(1.4, 0.95)
			}, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In))
		end)
	else
		return
	end
end
function t.UpdateSong(p1, p2, p3) --[[ Line: 4388 | Upvalues: RunService (copy), LocalEvent (copy), Players (copy), t (copy) ]]
	if RunService:IsServer() then
		LocalEvent:FireAllClients("UpdateSong", { p1, p2, p3 })
	end

	if not RunService:IsClient() then
		return
	end

	local LocalPlayer = Players.LocalPlayer
	local CurrentSong = workspace:FindFirstChild("CurrentSong")

	if not CurrentSong then
		return
	end

	local v2 = math.clamp(workspace:GetAttribute("TimeScale"), 0.2, 5)

	for k, v in pairs(workspace.Songs:GetDescendants()) do
		if v:IsA("Sound") and v.SoundId == CurrentSong.SoundId then
			p1 = p1 * v.Volume
		end
	end

	if p3 > 0 then
		t.Tween(CurrentSong, {
			Volume = p1 * LocalPlayer:GetAttribute("MusicVolume"),
			PlaybackSpeed = p2 * v2
		}, TweenInfo.new(p3, Enum.EasingStyle.Linear, Enum.EasingDirection.In))

		if not CurrentSong:FindFirstChild("Drums") then
			return
		end

		local v3 = p2 * v2

		if v2 >= 1.5 then
			v3 = v3 / 2
		end

		t.Tween(CurrentSong.Drums, {
			Volume = p1 * LocalPlayer:GetAttribute("MusicVolume"),
			PlaybackSpeed = v3
		}, TweenInfo.new(p3, Enum.EasingStyle.Linear, Enum.EasingDirection.In))

		return
	end

	CurrentSong.Volume = p1 * LocalPlayer:GetAttribute("MusicVolume")
	CurrentSong.PlaybackSpeed = p2 * LocalPlayer:GetAttribute("MusicVolume")

	if not CurrentSong:FindFirstChild("Drums") then
		return
	end

	local v4 = p2 * v2

	if v2 >= 1.5 then
		v4 = v4 / 2
	end

	CurrentSong.Drums.Volume = p1 * LocalPlayer:GetAttribute("MusicVolume")
	CurrentSong.Drums.PlaybackSpeed = v4
end
function t.DeleteSong() --[[ Line: 4441 | Upvalues: RunService (copy), LocalEvent (copy) ]]
	if RunService:IsServer() then
		LocalEvent:FireAllClients("DeleteSong")
	end

	if not RunService:IsClient() then
		return
	end

	local CurrentSong = workspace:FindFirstChild("CurrentSong")

	if not CurrentSong then
		return
	end

	CurrentSong:Destroy()
end
function t.GetPlayersStillAlive() --[[ Line: 4456 | Upvalues: Players (copy) ]]
	local count = 0

	for k, v in pairs(Players:GetPlayers()) do
		if v:GetAttribute("Dead") == false then
			count = count + 1
		end
	end

	return count
end
function t.GetPlayersThatAreDead() --[[ Line: 4471 | Upvalues: Players (copy) ]]
	local t = {}

	for k, v in pairs(Players:GetPlayers()) do
		if v:GetAttribute("Dead") == true then
			table.insert(t, v)
		end
	end

	return t
end
function t.GetEnemiesStillAlive() --[[ Line: 4482 | Upvalues: EnemyFolder (copy) ]]
	local count = 0

	for k, v in pairs(EnemyFolder:GetChildren()) do
		if v:GetAttribute("Alive") == true then
			count = count + 1
		end
	end

	return count
end
function t.GetBossesStillAlive() --[[ Line: 4494 | Upvalues: EnemyFolder (copy), Bosses (copy) ]]
	local count = 0

	for k, v in pairs(EnemyFolder:GetChildren()) do
		if Bosses:FindFirstChild(v.Name) then
			count = count + 1
		end
	end

	return count
end
function t.WaitUntilAllAlive() --[[ Line: 4505 | Upvalues: Players (copy) ]]
	repeat
		task.wait()

		local count = 0
		local count2 = 0

		for k, v in pairs(Players:GetPlayers()) do
			if v.Character and (v.Character.Humanoid.Health > 0 and v:GetAttribute("Dead") == false) then
				count = count + 1
			end

			if v:GetAttribute("Dead") == false then
				count2 = count2 + 1
			end
		end
	until count == count2 and count2 ~= 0
end
function t.WaitUntilNoEnemies() --[[ Line: 4517 | Upvalues: t (copy) ]]
	if t.GetEnemiesStillAlive() == 0 then
		return
	end

	repeat
		task.wait()

		local v1 = false

		if t.GetEnemiesStillAlive() == 0 then
			task.wait(1.5)

			if t.GetEnemiesStillAlive() == 0 then
				v1 = true
			end
		end
	until v1 == true
end
function t.AddHealthbar(p1, p2, p3, p4) --[[ Line: 4536 | Upvalues: RunService (copy), LocalEvent (copy), Resources (copy), TweenService (copy) ]]
	if RunService:IsServer() then
		p1:SetAttribute("HealthbarBopCount", 0)
		LocalEvent:FireAllClients("AddHealthbar", { p1, p2, p3, p4 })

		if p3 ~= true then
			return
		end

		local BossHealthbar = Instance.new("ObjectValue")

		BossHealthbar.Value = p2
		BossHealthbar.Name = "BossHealthbar"
		BossHealthbar:SetAttribute("Color", p4)
		BossHealthbar.Parent = p1

		local v1 = false
		local v2 = nil

		v2 = p2:GetAttributeChangedSignal("Health"):Connect(function() --[[ Line: 4551 | Upvalues: v1 (ref), p2 (copy), BossHealthbar (copy), v2 (ref) ]]
			if v1 ~= false or not (p2:GetAttribute("Health") <= 0) then
				return
			end

			v1 = true
			task.wait(0.1)

			if p2:GetAttribute("Health") <= 0 then
				BossHealthbar:Destroy()
				v2:Disconnect()

				return
			end

			v1 = false
		end)
		p2.Destroying:Connect(function() --[[ Line: 4564 | Upvalues: BossHealthbar (copy), v2 (ref) ]]
			BossHealthbar:Destroy()
			v2:Disconnect()
		end)
	else
		local v3 = Resources.BossHealthGui:Clone()
		local HealthFrame = v3.MainFrame.HealthFrame
		local HealthText = v3.MainFrame.HealthText
		local Title = v3.MainFrame.Title

		v3.Parent = p1.PlayerGui.BossHealthGuiHolder

		if p4 then
			local v4 = Color3.fromRGB(p4.R * 255 * 0.2, p4.G * 255 * 0.2, p4.B * 255 * 0.2)

			HealthFrame.BackgroundColor3 = p4
			Title.UIStroke.Color = v4
			v3.MainFrame.Cover.UIStroke.Color = v4
			v3.MainFrame.HealthText.UIStroke.Color = v4
		end

		local v5 = if p2:GetAttribute("Name") == nil then p2.Name else p2:GetAttribute("Name")

		v3.ConnectedTo.Value = p2
		Title.Text = v5

		local v6 = p2:GetAttribute("Health")

		HealthText.Text = math.round(v6) .. " / " .. p2:GetAttribute("MaxHealth")
		HealthFrame.Size = UDim2.fromScale(p2:GetAttribute("Health") / p2:GetAttribute("MaxHealth"), 1)

		local t = {
			Position = UDim2.fromScale(0.5, 0.1)
		}

		TweenService:Create(v3.MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), t):Play()
	end
end
function t.DeltaruneExplosion(p1, p2) --[[ Line: 4599 | Upvalues: RunService (copy), Players (copy), GifPlayer (copy) ]]
	if RunService:IsClient() and p1 ~= Players.LocalPlayer then
		warn("???")

		return
	end

	local DeltaruneExplosionGui = p1.PlayerGui.DeltaruneExplosionGui
	local BOOOOOOOM = DeltaruneExplosionGui.Sample:Clone()

	BOOOOOOOM.Position = p2
	BOOOOOOOM.Name = "BOOOOOOOM"
	BOOOOOOOM.Visible = true
	BOOOOOOOM.Parent = DeltaruneExplosionGui

	local v1 = GifPlayer({
		Loops = 5,
		Screen = BOOOOOOOM,
		Frames = {
			{
				Asset = "rbxassetid://105223553319593",
				Cols = 4,
				Count = 16,
				FPS = 16,
				Resolution = Vector2.new(256, 256)
			}
		}
	})

	v1:Play(1)
	v1.Loop:Connect(function(p1) --[[ Line: 4626 | Upvalues: BOOOOOOOM (copy) ]]
		if not (p1 >= 1) then
			return
		end

		BOOOOOOOM:Destroy()
	end)
end
function t.BossIntro(p1, p2, p3) --[[ Line: 4635 | Upvalues: LocalEvent (copy) ]]
	LocalEvent:FireAllClients("BossIntro", { p1, p2, p3 })
end
function t.BossDead(p1) --[[ Line: 4644 | Upvalues: Players (copy), Sounds (copy), t (copy) ]]
	for k, v in pairs(Players:GetPlayers()) do
		task.spawn(function() --[[ Line: 4646 | Upvalues: v (copy), p1 (copy), Sounds (ref), t (ref) ]]
			local BigText = v.PlayerGui.BigTextGui.BigText

			BigText.Text = p1
			BigText.Visible = true
			Sounds.BossDefeated:Play()
			task.wait(2)

			local t2 = { ", ENJOY!", " WOO!", "!!" }

			BigText.Text = " 5000 POINTS FOR ALL" .. t2[math.random(1, #t2)]
			v:SetAttribute("Score", v:GetAttribute("Score") + 5000)
			t.CheckScore(v)
			t.ScoreLabels(v)
			Sounds.Money:Play()
			t.RevivePlayer(v)
			v:SetAttribute("BossesKilled", v:GetAttribute("BossesKilled") + 1)
			task.wait(2)
			BigText.Visible = false
		end)
	end
end
function t.NewSky(p1) --[[ Line: 4672 | Upvalues: Lighting (copy) ]]
	local Sky

	if not Lighting:FindFirstChildOfClass("Sky") then
		Sky = p1:Clone()
		Sky.Name = "Sky"
		Sky.Parent = Lighting

		return
	end

	Lighting:FindFirstChildOfClass("Sky"):Destroy()
	Sky = p1:Clone()
	Sky.Name = "Sky"
	Sky.Parent = Lighting
end
function t.SetSkyConfig(p1) --[[ Line: 4687 | Upvalues: Lighting (copy) ]]
	Lighting.ClockTime = p1:GetAttribute("ClockTime")
	Lighting.GeographicLatitude = p1:GetAttribute("Latitude")
end
function t.Rain(p1) --[[ Line: 4693 | Upvalues: RunService (copy), LocalEvent (copy) ]]
	if not RunService:IsServer() then
		return
	end

	LocalEvent:FireAllClients("Rain", { p1 })
end
function t.SummonAlly(p1, p2) --[[ Line: 4700 | Upvalues: t (copy), Sounds (copy), PlayerFolder (copy), EnemyFolder (copy), EffectsFolder (copy), LocalEvent (copy), Debris (copy) ]]
	if p2.Name == "Pulser" and p1:FindFirstChild("Pulser") then
		local Character = p1.Character
		local Pulser = p1.Pulser.Value

		p1.Pulser:Destroy()

		if Pulser:FindFirstChild("Weld") then
			local Part1 = Pulser.Weld.Part1

			Pulser.Weld:Destroy()
			Pulser.Anchored = true

			if t.IsEnemyTargetValid(Part1.Parent) then
				local v1 = CFrame.lookAt(Character.PrimaryPart.Position, Part1.Position).LookVector * (Character.PrimaryPart.Position - Part1.Position).Magnitude / 30 * (Character.PrimaryPart.AssemblyLinearVelocity.Magnitude / 3)

				t.LinearVel(Character.PrimaryPart.RootAttachment, v1, 0.1, false, "YankVel")
				print(v1 + Vector3.new(0, 20, 0))
			elseif Part1.Name == "Rally" then
				Part1.Anchored = false

				local FlagMotor = Instance.new("Motor6D", Part1)

				FlagMotor.Part0 = Character.Torso
				FlagMotor.Part1 = Part1
				FlagMotor.C0 = CFrame.new(0, 0, 0.6) * CFrame.Angles(0, 0, 0.5235987755982988)
				FlagMotor.Name = "FlagMotor"
			end
		end

		t.PlaySound(Sounds.Yank, Character.PrimaryPart)

		local Position = Pulser.Position
		local Orb = Character.Staff.Parts.Orb

		t.BezierCurve(Pulser, 0.3, Position, Position:Lerp(Orb.Position, 0.5) + Vector3.new(0, 10, 0) + Character.PrimaryPart.CFrame.RightVector * -20, Orb, true, true, false)
		task.wait(0.3)
		Pulser:Destroy()
	else
		local v3 = RaycastParams.new()

		v3.FilterType = Enum.RaycastFilterType.Exclude
		v3.FilterDescendantsInstances = { PlayerFolder, EnemyFolder, EffectsFolder }

		local v4 = nil

		if p2:GetAttribute("SummonType") == "Direct" then
			v4 = p1.Character.PrimaryPart.CFrame
		elseif p2:GetAttribute("SummonType") == "Front" then
			v4 = p1.Character.PrimaryPart.CFrame + p1.Character.PrimaryPart.CFrame.LookVector * 8

			local v5 = workspace:Raycast(v4.Position + Vector3.new(0, 200, 0), Vector3.new(0, -400, 0), v3)

			if v5 then
				local Magnitude = (v5.Position - v4.Position).Magnitude

				v4 = if v5.Position.Y > v4.Position.Y then v4 + Vector3.new(0, Magnitude, 0) else v4 - Vector3.new(0, Magnitude, 0)
			end
		end

		local v6 = p2:Clone()

		v6:PivotTo(v4)

		local Summoner = Instance.new("ObjectValue")

		Summoner.Value = p1
		Summoner.Name = "Summoner"
		Summoner.Parent = v6
		v6:SetAttribute("AllyId", math.random(1, 999999999))

		if v6:FindFirstChild("Summoner") then
			v6.Summoner.Value = p1
		end

		if v6.Name == "Pulser" then
			local v7 = false
			local v8 = nil

			v8 = LocalEvent.OnServerEvent:Connect(function(p12, p2, p3) --[[ Line: 4825 | Upvalues: p1 (copy), v8 (ref), v6 (copy), Debris (ref), v7 (ref) ]]
				if p12 ~= p1 then
					return
				end

				if p2 ~= "ThrowMagnet" then
					return
				end

				v8:Disconnect()

				local v1 = p3[1]
				local Weld = Instance.new("Weld")

				Weld.Parent = v6
				Weld.Part0 = v6
				Weld.Part1 = v1
				Weld.C0 = p3[2]
				v1.Destroying:Connect(function() --[[ Line: 4840 | Upvalues: Debris (ref), v6 (ref) ]]
					Debris:AddItem(v6, 0.1)
				end)
				v7 = true
			end)

			repeat
				task.wait()
			until v7 == true

			local Pulser = Instance.new("ObjectValue")

			Pulser.Value = v6
			Pulser.Name = "Pulser"
			Pulser.Parent = p1
			v6.Beam.Attachment1 = p1.Character.Staff.Parts.Orb.Attachment
			v6.Destroying:Connect(function() --[[ Line: 4859 | Upvalues: Pulser (copy) ]]
				Pulser:Destroy()
			end)
		end

		v6.Parent = EffectsFolder
		t.NetworkToServer(v6)

		for k, v in pairs(v6:GetDescendants()) do
			if v:IsA("Script") then
				v.Enabled = true
			end
		end
	end
end
function t.EnableSidewaysMovement(p1) --[[ Line: 4881 | Upvalues: ReplicatedStorage (copy) ]]
	if p1.PrimaryPart:FindFirstChild("SidewaysMovement") then
		return
	end

	local SidewaysMovement = Instance.new("LinearVelocity")

	SidewaysMovement.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	SidewaysMovement.MaxAxesForce = Vector3.new(0, 0, 2000000)
	SidewaysMovement.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	SidewaysMovement.Name = "SidewaysMovement"
	SidewaysMovement.Parent = p1.PrimaryPart
	SidewaysMovement.Attachment0 = p1.PrimaryPart.RootAttachment

	if ReplicatedStorage.GameType.Value == "flat" then
		SidewaysMovement.Enabled = false
	end

	local v1 = ReplicatedStorage.GameType.Changed:Connect(function() --[[ Line: 4898 | Upvalues: ReplicatedStorage (ref), SidewaysMovement (copy) ]]
		if ReplicatedStorage.GameType.Value == "flat" then
			SidewaysMovement.Enabled = false
		else
			SidewaysMovement.Enabled = true
		end
	end)

	SidewaysMovement.Destroying:Once(function() --[[ Line: 4906 | Upvalues: v1 (ref) ]]
		v1:Disconnect()
	end)
end
function t.DisableSidewaysMovement(p1) --[[ Line: 4909 ]]
	local SidewaysMovement = p1.PrimaryPart:FindFirstChild("SidewaysMovement")

	if not SidewaysMovement then
		return
	end

	SidewaysMovement:Destroy()
end
function t.CreateShadowClone(p1, p2) --[[ Line: 4915 | Upvalues: Players (copy), RunService (copy) ]]
	local v1 = Players:GetPlayerFromCharacter(p1)

	if not v1 then
		warn("SHADOW CLONE BUT NO PLAYER?! WHAT IS THIS GARBAGE?!")

		return
	end

	local v2 = v1:GetAttribute("ShadowClones")

	if v2 == nil then
		v1:SetAttribute("ShadowClones", 1)
	else
		v1:SetAttribute("ShadowClones", v2 + 1)
	end

	local v3 = p1:Clone()

	for v4, v5 in v3:GetDescendants() do
		if v5:IsA("BasePart") then
			if not v5.Parent:IsA("Accessory") then
				v5.Anchored = true
			end

			v5.CanCollide = false
			v5.CanTouch = false
			v5.CanQuery = false

			if v5.Transparency < 0.5 then
				v5.Transparency = 0.5
			end
		end
	end

	v3.Parent = workspace

	local t = {}

	RunService.Heartbeat:Connect(function() --[[ Line: 4944 | Upvalues: t (copy), p2 (copy), v3 (copy), p1 (copy) ]]
		for v1, v2 in t do
			if v1 + p2 <= time() then
				for v32, v4 in v2.CFrames do
					local v5 = v3:FindFirstChild(v32.Name, true)

					if v5 then
						v5.CFrame = v4
					end
				end

				t[v1] = nil
			end
		end

		local t2 = {}
		local count = 0

		for v6, v7 in p1:GetDescendants() do
			if v7:IsA("BasePart") and v7.Transparency < 1 then
				t2[v7] = v7.CFrame
				count = count + 1
			end
		end

		if not (count > 0) then
			return
		end

		t[time()] = {}
		t[time()].CFrames = t2
	end)
end

local function v8(p1) --[[ FastWait | Line: 4978 | Upvalues: v8 (copy) ]]
	local v1 = os.clock()
	local count = 0

	repeat
		if not (os.clock() - v1 < p1) then
			print("FINAL TIME: " .. os.clock() - v1)

			return
		end

		count = count + 1
	until count >= 1000

	task.defer(function() --[[ Line: 4991 | Upvalues: v8 (ref), v1 (copy) ]]
		v8(os.clock() - v1)
	end)
	print("FINAL TIME: " .. os.clock() - v1)
end

function t.Typewrite(p1, p2, p3, p4) --[[ Line: 4999 | Upvalues: t3 (copy), TweenService (copy), t (copy), Sounds (copy) ]]
	local v1 = p4 or false

	if not t3[p1.Name] then
		t3[p1.Name] = {}
		t3[p1.Name].TypewritingId = 0
		t3[p1.Name].Name = p1.Name
	end

	local t2 = {
		talkFunc = function() --[[ Line: 5012 ]] end,
		pauseFunc = function() --[[ Line: 5014 ]] end,
		endFunc = function() --[[ Line: 5016 ]] end
	}
	local t4 = { ",", ".", "!", "?" }
	local v2 = math.random(100000000, 999999999)
	local v3 = nil
	local v4 = false

	t3[p1.Name].TypewritingId = v2
	task.spawn(function() --[[ Line: 5033 | Upvalues: p2 (copy), p3 (copy), t3 (ref), p1 (copy), v2 (copy), TweenService (ref), v1 (ref), t4 (copy), t2 (copy), v3 (ref), v4 (ref), t (ref), Sounds (ref) ]]
		local v12 = UDim2.fromScale(p2.Position.X.Scale, p2.Position.Y.Scale)

		p2.MaxVisibleGraphemes = 0
		p2.Text = p3

		for i = 1, string.len(p3) do
			if t3[p1.Name].TypewritingId ~= v2 then
				p2.Position = v12
				p2.Rotation = 0

				return
			end

			p2.Position = v12 + UDim2.fromOffset(0, math.random(4, 6))
			p2.Rotation = math.random(-1, 1) / 2
			p2.MaxVisibleGraphemes = i
			TweenService:Create(p2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Rotation = 0,
				Position = v12
			}):Play()

			if v1 ~= true then
				local v42 = string.sub(p3, i, i)
				local v6 = string.sub(p3, i + 1, i + 1) or ""

				if table.find(t4, v42) then
					if i == string.len(p3) or (v42 == "!" and (v6 == "!" or v6 == "?") or v42 == "?" and (v6 == "!" or v6 == "?")) then
						t2.talkFunc()
						task.wait(0.03)
					else
						t2.pauseFunc()
						task.wait(0.4)
					end
				else
					t2.talkFunc()
					task.wait(0.03)
				end

				v3 = v42
			end
		end

		if v4 == true then
			v4 = false
			t.UpdateSound(Sounds.Talk, workspace, 0, 0.5, 1, false)
		end

		t2.endFunc()
		p2.MaxVisibleGraphemes = -1
		t3[p1.Name].TypewritingId = 0
	end)

	local count = 0

	for i = 1, string.len(p3) do
		local v5 = string.sub(p3, i, i)

		if table.find(t4, v5) and (v5 ~= v3 and (i ~= string.len(p3) and (v5 ~= "!" or v3 ~= "!" and v3 ~= "?"))) then
			if v5 == "?" then
				if v3 ~= "!" and v3 ~= "?" then
					count = count + 1
				end
			else
				count = count + 1
			end
		end
	end

	return string.len(p3) * 0.03 + count * 0.4, t2
end
function t.SPP(p1, p2) --[[ Line: 5144 | Upvalues: ReplicatedStorage (copy), t4 (copy) ]]
	if type(p2) == "boolean" then
		t4[p1] = p2
	else
		ReplicatedStorage.GoofinatorActivationSequence:FireServer("bspp")
	end
end
function t.GPP(p1) --[[ Line: 5148 | Upvalues: t4 (copy) ]]
	if t4[p1] == nil then
		return false
	end

	return t4[p1]
end
function t.SummonGuiseShip() --[[ Line: 5154 | Upvalues: Resources (copy), RunService (copy), LocalEvent (copy), t (copy) ]]
	local v1 = Resources.GuiseShip:Clone()

	v1.Parent = workspace

	if RunService:IsServer() then
		LocalEvent:FireAllClients("SummonGuiseShip")
	else
		v1.LeftThruster.Trail.Transparency = 0
		v1.RightThruster.Trail.Transparency = 0
		v1.Flash.Gui.ImageLabel.ImageTransparency = 0
		t.Tween(v1.LeftThruster.Trail, {
			Transparency = 1
		}, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
		t.Tween(v1.RightThruster.Trail, {
			Transparency = 1
		}, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
		t.Tween(v1.Flash.Gui.ImageLabel, {
			ImageTransparency = 1
		}, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
	end
end
function t.DestroyGuiseShip() --[[ Line: 5177 ]]
	local GuiseShip = workspace:FindFirstChild("GuiseShip")

	if not GuiseShip then
		return
	end

	GuiseShip:Destroy()
end
function t.GodlyAdminSword(p1) --[[ Line: 5183 | Upvalues: Resources (copy), t (copy), RunService (copy), EffectsFolder (copy), Debris (copy), Sounds (copy), Lighting (copy), LocalEvent (copy), EnemyFolder (copy) ]]
	local PrimaryPart = p1.Character.PrimaryPart
	local v1 = Resources.GodlyAdminSword:Clone()
	local v2 = Vector3.new(PrimaryPart.Position.X, v1.Position.Y, PrimaryPart.Position.Z)

	v1.CFrame = CFrame.lookAt(v2, v2 + PrimaryPart.CFrame.LookVector)
	v1.Parent = workspace

	local CFrameValue = Instance.new("CFrameValue")

	CFrameValue.Value = v1:GetPivot()
	t.Tween(CFrameValue, {
		Value = v1:GetPivot() * CFrame.Angles(-1.5707963267948966, 0, 0)
	}, TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.In))

	local v3 = nil

	v3 = RunService.Heartbeat:Connect(function() --[[ Line: 5199 | Upvalues: CFrameValue (copy), v3 (ref), v1 (copy) ]]
		if CFrameValue == nil then
			v3:Disconnect()
		else
			v1:PivotTo(CFrameValue.Value)
		end
	end)
	task.wait(4)
	CFrameValue:Destroy()
	t.HitStop(3, 5, true, false)

	local v4 = Resources.AirShockwave:Clone()

	v4.Position = v1.Position
	v4.Parent = EffectsFolder
	t.Tween(v4, {
		Size = Vector3.new(2048, 2048, 2048),
		Transparency = 1
	}, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
	Debris:AddItem(v4, 1)
	t.PlaySound(Sounds.SwordGusts, workspace, 1, false)
	task.wait(0.2)
	Lighting.ExposureCompensation = -0.5
	t.Tween(Lighting, {
		ExposureCompensation = 0
	}, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In))

	local v5 = Resources.Ring:Clone()
	local v6 = CFrame.new

	v5.CFrame = v6(v1.Position - Vector3.new(0, v1.Size.Z / 2, 0)) * CFrame.Angles(-1.5707963267948966, 0, 0)
	v5.Parent = EffectsFolder
	t.Tween(v5, {
		Size = Vector3.new(2048, 2048, 30)
	}, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
	t.PlaySound(Sounds.Explosion3, workspace, 0.5, false)
	t.Distortion(v1.CFrame, Vector3.new(0.1, 0.1, 0.1), 2, Vector3.new(2048, 2048, 2048), 0.3, false)
	LocalEvent:FireAllClients("CameraShake", { 2, 30 })
	task.wait(1)
	t.Tween(v5, {
		Size = Vector3.new(0, 0, 30)
	}, TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.In))
	t.UpdateSound(Sounds.SwordGusts, workspace, 8, 10, 1.5, false)
	task.wait(2)

	local v8 = Resources.AirShockwave:Clone()

	v8.Position = v1.Position
	v8.Parent = EffectsFolder
	t.Tween(v8, {
		Size = Vector3.new(2048, 2048, 2048),
		Transparency = 1
	}, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
	Debris:AddItem(v8, 1)
	task.wait(0.05)
	Lighting.ExposureCompensation = 3
	Lighting.Blur.Size = 40
	t.Tween(Lighting, {
		ExposureCompensation = 0
	}, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
	t.Tween(Lighting.Blur, {
		Size = 0
	}, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
	t.Distortion(v1.CFrame, Vector3.new(0.1, 0.1, 0.1), 2, Vector3.new(2048, 2048, 2048), 0.3, false)
	t.StopSound(Sounds.SwordGusts, workspace)
	t.PlaySound(Sounds.SWORDAAAAAAIMPACTOOOOO, workspace, 1, false)

	local v9 = 0
	local v10 = RunService.Heartbeat:Connect(function(p1) --[[ Line: 5259 | Upvalues: v9 (ref), EnemyFolder (ref), t (ref), v1 (copy), LocalEvent (ref) ]]
		v9 = v9 + p1

		if not (v9 > 0.05) then
			return
		end

		v9 = 0

		for v12, v2 in EnemyFolder:GetChildren() do
			t.DamageEnemy(nil, v2, 100)
		end

		t.Shockwave(v1.Position - Vector3.new(0, v1.Size.Z / 2, 0), Vector3.new(2048, 5, 2048), 0.3, true)
		LocalEvent:FireAllClients("CameraShake", { 2, 10 })
	end)

	task.wait(6)
	v10:Disconnect()
	t.Tween(v1, {
		Transparency = 1
	}, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
	Debris:AddItem(v1, 1)
	print("SWORD END")
end
function t.ActivateHellMode(p1) --[[ Line: 5286 | Upvalues: ReplicatedStorage (copy), t (copy), Sounds (copy), Songs (copy), LocalEvent (copy), Resources (copy) ]]
	for k, v in pairs(ReplicatedStorage.CurrentStage.Value.SpecialWaves:GetChildren()) do
		if v:FindFirstChild("Type") and v.Type.Value == "Intro" then
			v:Destroy()
		end
	end

	ReplicatedStorage.HellModeActive.Value = true
	t.HitStop(9, 5, true)
	t.Distortion(CFrame.new(p1), Vector3.new(400, 400, 400), 30, Vector3.new(0, 0, 0), 8, false)
	Sounds.HellModeActivate:Play()
	task.spawn(function() --[[ Line: 5301 | Upvalues: t (ref), Sounds (ref) ]]
		for i = 1, 40 do
			t.PlaySound(Sounds.GrittyBoom, workspace, i / 12 + 0.6, false)
			task.wait((1 - ((40 - i) / 40) ^ 3 - (1 - ((40 - (i - 1)) / 40) ^ 3)) * 7.5)
		end
	end)
	task.wait(8)
	t.DeleteSong()
	task.wait(1)
	t.NewSong(Songs.HellMode)
	LocalEvent:FireAllClients("HellMode", { true })
	t.NewSky(Resources.StormySky)
	Sounds.SpongebobScreaming:Play()
	t.Tween(Sounds.SpongebobScreaming, {
		PlaybackSpeed = 1.2
	}, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
	Sounds.HellModeImpact:Play()
	task.delay(5, function() --[[ Line: 5347 | Upvalues: t (ref), Sounds (ref) ]]
		t.Tween(Sounds.HellModeImpact, {
			PlaybackSpeed = 0
		}, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
		task.wait(4)
		Sounds.HellModeImpact:Stop()
		print("IMPAAAAAAAACT STOP")
	end)
	task.spawn(function() --[[ Line: 5354 | Upvalues: t (ref), p1 (copy) ]]
		for i = 1, 20 do
			t.Distortion(CFrame.new(p1), Vector3.new(0, 0, 0), 10, Vector3.new(400, 400, 400), 2, true)
			t.Wait(0.1)
		end
	end)

	local Shockwave = t.Shockwave

	Shockwave(Vector3.new(p1.X, 0, p1.Z), Vector3.new(500, 0.2, 500), 2, false)
end
function t.Detain1x() --[[ Line: 5365 | Upvalues: EffectsFolder (copy), t (copy), Sounds (copy), Resources (copy), RunService (copy), LocalEvent (copy) ]]
	local tbl = {}

	for k, v in pairs(EffectsFolder:GetChildren()) do
		if v.Name == "x1" then
			table.insert(tbl, v)
			v:SetAttribute("Detained", true)
		end
	end

	for k, v in pairs(EffectsFolder:GetChildren()) do
		if v.Name == "x1SlashWarning" then
			v:Destroy()
		end

		if v.Name == "x1Slash" then
			v:Destroy()
		end
	end

	if not (#tbl > 0) then
		return
	end

	for k, v in pairs(tbl) do
		task.spawn(function() --[[ Line: 5377 | Upvalues: v (copy), t (ref), Sounds (ref), Resources (ref), EffectsFolder (ref), RunService (ref), LocalEvent (ref) ]]
			v.X1Local.TargetMode.Value = "Idle"
			task.wait(0.3)
			t.PlaySound(Sounds.x1PulledUp, workspace, 1, false)

			local v1 = Resources.x1TractorBeam:Clone()

			v1.Position = Vector3.new(0, 900, 0)
			v1.Parent = EffectsFolder

			local v2 = nil

			v2 = RunService.Heartbeat:Connect(function() --[[ Line: 5390 | Upvalues: v1 (copy), v2 (ref) ]]
				if v1.Parent == nil then
					v2:Disconnect()
				else
					v1.Outline.Width0 = v1.Size.Z * 1.5
					v1.Outline.Width1 = v1.Size.Z * 1.5
				end
			end)
			t.Tween(v1, {
				Size = Vector3.new(2048, 7, 7)
			}, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
			task.wait(0.3)
			t.Tween(v1, {
				Size = Vector3.new(2048, 20, 20)
			}, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut))
			task.wait(1)
			t.Tween(v1, {
				Size = Vector3.new(2048, 0, 0)
			}, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In))
			v:Destroy()
			t.UpdateSound(Sounds.x1PulledUp, workspace, 1, 1.6, 1, false)
			task.wait(1)
			v1:Destroy()
			t.StopSound(Sounds.x1PulledUp, workspace)
			t.PlaySound(Sounds.x1Detained, workspace, 1, false)
			LocalEvent:FireAllClients("CameraShake", { 2, 60 })
		end)
	end
end
function t.Unleash1x() --[[ Line: 5416 | Upvalues: EffectsFolder (copy), Resources (copy), Animations (copy), t (copy), Players (copy), Sounds (copy), v5 (copy), Debris (copy), PlayerFolder (copy) ]]
	if not EffectsFolder:FindFirstChild("x1") then
		local v1 = Resources.x1:Clone()

		v1.Parent = EffectsFolder

		local HumanoidRootPart = v1.HumanoidRootPart
		local Torso = v1.Torso
		local Animator = v1.Humanoid.Animator
		local v2 = Animator:LoadAnimation(Animations.x1.Idle)
		local v3 = Animator:LoadAnimation(Animations.x1.Slash)
		local v4 = Animator:LoadAnimation(Animations.x1.Laugh)
		local v52 = Animator:LoadAnimation(Animations.x1.Stunned)
		local v6 = t.GetRandomPlayer()
		local v7 = v6
		local v8 = script.X1Local:Clone()

		v8.Target.Value = v6
		v8.Parent = v1
		v8.Enabled = true

		local t2 = { 1, 1, 1, 2 }
		local v9 = 1

		local function StopAnims() --[[ StopAnims | Line: 5443 | Upvalues: Animator (copy) ]]
			for k, v in pairs(Animator:GetPlayingAnimationTracks()) do
				v:Stop(0)
			end
		end

		task.spawn(function() --[[ Line: 5449 | Upvalues: v2 (copy), v1 (copy), v6 (ref), t (ref), Players (ref), t2 (copy), v9 (ref), v8 (copy), v7 (ref), Sounds (ref), HumanoidRootPart (copy), v5 (ref), Animator (copy), v3 (copy), Resources (ref), Torso (copy), v4 (copy), v52 (copy), EffectsFolder (ref), Debris (ref), PlayerFolder (ref) ]]
			v2:Play(0)
			task.wait(2)

			while v1.Parent ~= nil and v1:GetAttribute("Detained") ~= true do
				local v12

				repeat
					v12 = true
					v6 = t.GetRandomPlayer()

					local v22 = Players:GetPlayerFromCharacter(v6)

					if v22 and v22:GetAttribute("CanAttack") == false then
						task.wait()
						v12 = false
					end
				until v12 == true

				local v32 = t2[v9]

				v9 = v9 + 1

				if #t2 < v9 then
					v9 = 1
				end

				if v32 == 1 then
					v8.Target.Value = v6
					v8.TargetMode.Value = "Melee"

					if v8.TargetMode.Value == "Melee" and v7 == v6 then
						task.wait(v5:NextNumber(0.1, 0.5))
					else
						t.PlaySound(Sounds.x1NewTarget, HumanoidRootPart, 1, false)
						task.wait(2)
					end

					v7 = v6

					if v1.Parent == nil or v1:GetAttribute("Detained") == true then
						break
					end

					for k, v in pairs(Animator:GetPlayingAnimationTracks()) do
						v:Stop(0)
					end

					v3:Play(0)
					t.PlaySound(Sounds.x1SlashWindup, HumanoidRootPart, 1, false)

					local v42 = Resources.PreAttackHighlight:Clone()

					v42.Parent = v1
					task.wait(0.2)
					v42.FillColor = Color3.fromRGB(255, 255, 255)
					v42.FillTransparency = 0.5
					task.wait(0.3)
					v42:Destroy()
					Torso.SlashAttach.Particles:Emit(5)

					if v6:GetAttribute("Dashing") == false then
						if t.DamagePlayer(nil, v6, 22, true) == true then
							t.PlaySound(Sounds.x1Hit, HumanoidRootPart, 1, false)
							task.wait(0.4)

							for k, v in pairs(Animator:GetPlayingAnimationTracks()) do
								v:Stop(0)
							end

							v4:Play(0)
							t.PlaySound(Sounds.x1Laugh, HumanoidRootPart, 1, false)
							task.wait(1.6)
							v4:Stop(0)
						else
							for k, v in pairs(Animator:GetPlayingAnimationTracks()) do
								v:Stop(0)
							end

							v52:Play(0)
							t.PlaySound(Sounds.x1Hurt, HumanoidRootPart, 1, false)
							task.wait(1)
							v52:Stop(0)
						end

						v2:Play(0)
					end

					task.wait(0.5)
				end

				if v32 ~= 2 then
					continue
				end

				local t3 = {
					Vector3.new(300, 4, 300),
					Vector3.new(-300, 4, 300),
					Vector3.new(300, 4, -300),
					Vector3.new(-300, 4, -300)
				}

				for i = 1, 4 do
					if v1.Parent == nil or v1:GetAttribute("Detained") == true then
						break
					end

					v8.TargetMode.Value = "Corner" .. i
					task.wait(0.2)

					local v53 = false

					for j = 1, 5 do
						local v62

						if v1.Parent == nil or v1:GetAttribute("Detained") == true then
							break
						end

						v62 = if v6 and (v6.Parent and v6.PrimaryPart) then v6.PrimaryPart.Position else Vector3.new(0, 0, 0)

						if v53 == false then
							HumanoidRootPart.CFrame = CFrame.lookAt(t3[i], (Vector3.new(v62.X, 4, v62.Z)))
							v53 = true
						else
							local v10 = Vector3.new(math.random(-150, 150), 0, math.random(-150, 150))

							HumanoidRootPart.CFrame = CFrame.lookAt(t3[i], Vector3.new(v62.X, 4, v62.Z) + v10)
						end

						task.spawn(function() --[[ Line: 5565 | Upvalues: HumanoidRootPart (ref), t (ref), Resources (ref), EffectsFolder (ref), Debris (ref), PlayerFolder (ref) ]]
							local v1 = HumanoidRootPart.CFrame + HumanoidRootPart.CFrame.LookVector * 500
							local x1SlashWarning = t.AttackWarning(v1, Vector3.new(2, 9, 1000), Enum.PartType.Block, 1, true)

							x1SlashWarning.Name = "x1SlashWarning"

							for i = 1, 100 do
								if x1SlashWarning.Parent ~= nil then
									x1SlashWarning.Color = Color3.fromRGB(255, 0, 0)
									t.Wait(0.05)
								end

								if x1SlashWarning.Parent ~= nil then
									x1SlashWarning.Color = Color3.fromRGB(255, 213, 0)
									t.Wait(0.05)
								end
							end

							local v2 = Resources.x1HitscanSlash:Clone()

							v2.CFrame = v1
							v2.Size = Vector3.new(2, 9, 1000)
							v2.Parent = EffectsFolder
							t.Tween(v2, {
								Position = v2.Position + Vector3.new(0, -20, 0)
							}, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In), true)
							Debris:AddItem(v2, 0.3)

							local v3 = OverlapParams.new()

							v3.FilterType = Enum.RaycastFilterType.Include
							v3.FilterDescendantsInstances = { PlayerFolder }

							for k, v in pairs((workspace:GetPartBoundsInBox(v1, Vector3.new(2, 9, 1000), v3))) do
								if v.Name == "HumanoidRootPart" and v.Parent:GetAttribute("Dashing") == false then
									t.DamagePlayer(nil, v.Parent, 22, false)
								end
							end
						end)
					end

					task.wait(0.7)
					t.PlaySound(Sounds.x1HitscanSlash, workspace, 1, false)
					task.wait(0.2)
				end

				task.wait(1)
			end
		end)
	end
end
function t.RevivePlayer(p1) --[[ Line: 5633 ]]
	if p1:GetAttribute("Dead") ~= true then
		return
	end

	p1:SetAttribute("Lives", (math.clamp(p1:GetAttribute("Lives") + 1, 0, 99)))
	p1:SetAttribute("Dead", false)
	p1:SetAttribute("CanAttack", true)
	p1:SetAttribute("CanDash", true)
	p1:SetAttribute("CanFaceCamera", true)
	p1:SetAttribute("CanTaunt", true)
	p1:LoadCharacter()
end
function t.CheckScore(p1) --[[ Line: 5648 | Upvalues: ReplicatedStorage (copy), LocalEvent (copy), Sounds (copy), t (copy) ]]
	if not (p1:GetAttribute("Score") >= p1:GetAttribute("NextLifeRequirement")) or ReplicatedStorage.Difficulty.Value == "HARD" then
		return
	end

	p1:SetAttribute("Lives", (math.clamp(p1:GetAttribute("Lives") + 1, 0, 99)))
	p1:SetAttribute("NextLifeRequirement", if ReplicatedStorage.Gamemode.Value == "infinite" then p1:GetAttribute("NextLifeRequirement") * 7 else p1:GetAttribute("NextLifeRequirement") * 3)
	LocalEvent:FireClient(p1, "PlaySound", { Sounds.LifeUp, workspace })
	t.RevivePlayer(p1)
	print(p1.Name .. " is now at " .. p1:GetAttribute("Lives") .. " lives. new life requirement: " .. p1:GetAttribute("NextLifeRequirement"))
end
function t.ScoreLabels(p1) --[[ Line: 5679 | Upvalues: Players (copy), t (copy), ReplicatedStorage (copy) ]]
	local v2, v3 = string.match(string.format("%06d", p1:GetAttribute("Score")), "^(0*)(%d+)$")

	for v4, v5 in Players:GetPlayers() do
		local _, result = pcall(function() --[[ Line: 5684 | Upvalues: v5 (copy), p1 (copy), v2 (copy), v3 (copy), t (ref), ReplicatedStorage (ref) ]]
			if not v5.PlayerGui.MainGui.PlayerBars:FindFirstChild(p1.Name) then
				return
			end

			local v1 = v5.PlayerGui.MainGui.PlayerBars:FindFirstChild(p1.Name)

			if p1:GetAttribute("Score") > 0 then
				v1.Score.Text = "<font color=\"rgb(0, 0, 80)\">" .. v2 .. "</font>" .. v3
				v1.Size = UDim2.fromScale(1.05, v1.Size.Y.Scale)
				t.Tween(v1, {
					Size = UDim2.fromScale(1, v1.Size.Y.Scale)
				}, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
			else
				v1.Score.Text = "<font color=\"rgb(0, 0, 80)\">000000</font>"
			end

			if p1:GetAttribute("Dead") == true then
				v1.DeadLabel.Visible = true
			else
				v1.DeadLabel.Visible = false
			end

			v1.Lives.Text = p1:GetAttribute("Lives")
			v1.NextLifeScore.Text = "next life: " .. p1:GetAttribute("NextLifeRequirement")

			if ReplicatedStorage.Difficulty.Value ~= "HARD" then
				return
			end

			v1.NextLifeScore.Text = "next life: NEVER"
		end)

		if result then
			warn(result)
		end
	end
end
function t.StageBeat(p1) --[[ Line: 5718 | Upvalues: ReplicatedStorage (copy), t (copy) ]]
	local StagesBeat = p1:FindFirstChild("StagesBeat")

	if not StagesBeat then
		return
	end

	local v1 = ReplicatedStorage.CurrentStage.Value.Name

	if StagesBeat:FindFirstChild(v1) == nil then
		local v2 = Instance.new("BoolValue")

		v2.Name = v1
		v2.Parent = StagesBeat
		print(p1.Name .. " has just beat " .. v1 .. " for the first time!")
	end

	if v1 == "Grasslands" then
		if t.GetScoreMultipliers() >= 1 then
			t.AwardBadge(p1, 2250961894741221)
		end

		local v3 = p1:GetAttribute("FastestGrasslandsCompletion")

		if v3 == 0 or ReplicatedStorage.StageTime.Value < v3 then
			p1:SetAttribute("FastestGrasslandsCompletion", ReplicatedStorage.StageTime.Value)
		end
	elseif v1 == "Violet" then
		if t.GetScoreMultipliers() >= 1 then
			t.AwardBadge(p1, 4042337986430107)
		end

		local v4 = p1:GetAttribute("FastestVioletCompletion")

		if v4 == 0 or ReplicatedStorage.StageTime.Value < v4 then
			p1:SetAttribute("FastestVioletCompletion", ReplicatedStorage.StageTime.Value)
		end
	else
		if v1 ~= "Techno" then
			return
		end

		if t.GetScoreMultipliers() >= 1 then
			t.AwardBadge(p1, 2014903383023596)
		end

		local v5 = p1:GetAttribute("FastestTechnoCompletion")

		if v5 ~= 0 and not (ReplicatedStorage.StageTime.Value < v5) then
			return
		end

		p1:SetAttribute("FastestTechnoCompletion", ReplicatedStorage.StageTime.Value)
	end
end
function t.BanPlayer(p1, p2) --[[ Line: 5772 | Upvalues: RunService (copy), ReplicatedStorage (copy), Players (copy) ]]
	if RunService:IsClient() then
		ReplicatedStorage.GoofinatorActivationSequence:FireServer("BANPLAYER")
	end

	Players:BanAsync({
		ApplyToUniverse = true,
		Duration = -1,
		ExcludeAltAccounts = false,
		UserIds = { p1.UserId },
		DisplayReason = p2,
		PrivateReason = p2
	})
end
function t.SavePlayerData(p1, p2) --[[ Line: 5792 | Upvalues: RunService (copy), DataStoreService (copy), HttpService (copy), ReplicatedStorage (copy), t (copy) ]]
	if RunService:IsServer() == false then
		return
	end

	if p1:GetAttribute("DataSaved") == true then
		warn("data already saved for " .. p1.Name .. " soo ill just cancel this one")
	else
		p1:SetAttribute("DataSaved", true)

		local v1 = DataStoreService:GetDataStore("PlayerData")

		print("ok here we go")
		v1:UpdateAsync(p1.UserId, function(p12) --[[ Line: 5822 | Upvalues: HttpService (ref), p1 (copy), ReplicatedStorage (ref), t (ref) ]]
			if type(p12) == "string" then
				p12 = HttpService:JSONDecode(p12)
			end

			print("old data:")

			if p12 then
				if p12.DataVersion ~= p1:GetAttribute("DataVersion") then
					warn("BAD DATAVERSION, RETURNING NIL")

					return nil
				end

				if p12.SessionLock and (p12.SessionLock ~= game.JobId and os.time() - p12.LastUpdate < 300) then
					warn("session locked (saveplayerdata) (" .. p1.Name .. ")")
				end
			end

			p12.DataVersion = p1:GetAttribute("DataVersion") + 1
			p12.SessionLock = nil
			p12.LastLockUpdate = os.time()

			local t2 = {}

			for k, v in pairs(p1.StagesBeat:GetChildren()) do
				table.insert(t2, v.Name)
			end

			local v3 = nil

			if ReplicatedStorage.Gamemode.Value == "campaign" then
				v3 = math.ceil(p1:GetAttribute("Score") / 100 * t.GetScoreMultipliers())
			elseif ReplicatedStorage.Gamemode.Value == "infinite" then
				v3 = math.ceil(ReplicatedStorage.Wave.Value * 10 * t.GetScoreMultipliers())
			end

			local General = p12.General

			General.Money = General.Money + v3
			p12.StagesBeat = t2
			p12.Statistics.Parries = p1:GetAttribute("Parries") or p12.Statistics.Parries
			p12.Statistics.PerfectParries = p1:GetAttribute("PerfectParries") or p12.Statistics.PerfectParries
			p12.Statistics.MechParries = p1:GetAttribute("MechParries") or p12.Statistics.MechParries
			p12.Statistics.MechPerfectParries = p1:GetAttribute("MechPerfectParries") or p12.Statistics.MechPerfectParries
			p12.Statistics.EnemiesKilled = p1:GetAttribute("EnemiesKilled") or p12.Statistics.EnemiesKilled
			p12.Statistics.BossesKilled = p1:GetAttribute("BossesKilled") or p12.Statistics.BossesKilled
			p12.Statistics.FastestGrasslandsCompletion = p1:GetAttribute("FastestGrasslandsCompletion") or p12.Statistics.FastestGrasslandsCompletion
			p12.Statistics.FastestVioletCompletion = p1:GetAttribute("FastestVioletCompletion") or p12.Statistics.FastestVioletCompletion
			p12.Statistics.FastestTechnoCompletion = p1:GetAttribute("FastestTechnoCompletion") or p12.Statistics.FastestTechnoCompletion

			local Statistics10 = p12.Statistics

			Statistics10.PlayTime = Statistics10.PlayTime + time()

			local Statistics11 = p12.Statistics

			Statistics11.TokensEarned = Statistics11.TokensEarned + v3
			p12.Statistics.StudsTravelled = p1:GetAttribute("StudsTravelled") or p12.Statistics.StudsTravelled
			p12.Statistics.JumpsJumped = p1:GetAttribute("JumpsJumped") or p12.Statistics.JumpsJumped
			p12.Statistics.DegreesRotated = p1:GetAttribute("DegreesRotated") or p12.Statistics.DegreesRotated
			p12.Statistics.TauntsTaunted = p1:GetAttribute("TauntsTaunted") or p12.Statistics.TauntsTaunted
			p12.Statistics.TauntsActuallyCompleted = p1:GetAttribute("TauntsActuallyCompleted") or p12.Statistics.TauntsActuallyCompleted
			print("encoding and saving the below table:")

			return HttpService:JSONEncode(p12)
		end)
	end
end
function t.TeleportToLobby(p1) --[[ Line: 5904 | Upvalues: TeleportService (copy) ]]
	TeleportService:TeleportAsync(77783763309884, { p1 })
end

local v9 = false

function t.RestartGame() --[[ Line: 5910 | Upvalues: v9 (ref), ServerStorage (copy), TeleportService (copy), Players (copy) ]]
	if v9 == true then
		return
	end

	v9 = true

	local TeleportData = ServerStorage.TeleportData
	local t = {}

	for k, v in pairs(TeleportData.Modifiers:GetChildren()) do
		table.insert(t, { v.Name, v.Value })
	end

	local TeleportOptions = Instance.new("TeleportOptions")

	TeleportOptions.ShouldReserveServer = true
	TeleportOptions:SetTeleportData({ TeleportData.Gamemode.Value, TeleportData.Difficulty.Value, t })
	TeleportService:TeleportAsync(118188635016161, Players:GetPlayers(), TeleportOptions)
end
function t.GetScoreMultipliers() --[[ Line: 5929 | Upvalues: ReplicatedStorage (copy), ModifiersActive (copy) ]]
	local sum = 1
	local v1 = 1

	if ReplicatedStorage.Difficulty.Value == "Easy" then
		v1 = 0.1
	elseif ReplicatedStorage.Difficulty.Value == "HARD" then
		v1 = 2
	end

	if v1 > 1 then
		sum = sum * v1
	end

	for k, v in pairs(ModifiersActive:GetChildren()) do
		if v.Value >= 1 then
			sum = sum + (v.Value - 1)
		end
	end

	if v1 < 1 then
		sum = sum * v1
	end

	for k, v in pairs(ModifiersActive:GetChildren()) do
		if v.Value < 1 then
			sum = sum * v.Value
		end
	end

	return sum
end
function t.GameOver(p1) --[[ Line: 5967 | Upvalues: ReplicatedStorage (copy), EnemyFolder (copy), EffectsFolder (copy), t (copy), Players (copy), DataStoreService (copy), LocalEvent (copy) ]]
	ReplicatedStorage.EventsAllowed.Value = false
	EnemyFolder:Destroy()
	EffectsFolder:Destroy()
	workspace.ExtrasFolder:Destroy()
	t.RemoveBounds()
	game:GetService("SoundService").SoundEffects.Reverb.Enabled = false

	for v1, v2 in Players:GetPlayers() do
		t.StreakOver(v2)
	end

	if #p1 <= 4 then
		local sum = 0

		for k, v in pairs(p1) do
			local v3 = Players:GetPlayerByUserId(v)

			if v3 then
				print("player still in game, using their player score")
				sum = sum + v3:GetAttribute("Score")

				continue
			end

			print("player left, using their leaving score")

			local v4 = ReplicatedStorage.LeavingScores:FindFirstChild(v)

			if v4 then
				sum = sum + v4.Value

				continue
			end

			warn("no leaving score found")
		end

		local v6 = math.round(sum * t.GetScoreMultipliers())
		local v7 = nil
		local v8

		if ReplicatedStorage.Gamemode.Value == "campaign" or ReplicatedStorage.Gamemode.Value == "tutorial" then
			local v9 = DataStoreService:GetOrderedDataStore(#p1 .. "CampaignPlayerData")

			print(#p1 .. " player(s), CAMPAIGN, saving into the " .. #p1 .. "CampaignPlayerData")
			v8 = v6
			v7 = v9
		elseif ReplicatedStorage.Gamemode.Value == "infinite" then
			local v10 = DataStoreService:GetOrderedDataStore(#p1 .. "PlayerData")

			print(#p1 .. " player(s), INFINITY, saving into the " .. #p1 .. "PlayerData")
			v8 = v6
			v7 = v10
		else
			v8 = v6
		end

		print("score to save: " .. tostring(v8))
		table.sort(p1)

		local v11 = table.concat(p1, "-")
		local v12 = false
		local v13 = v7:GetAsync(v11)

		if (v13 == nil and v8 > 5 or v13 ~= nil and (v13 < v8 and v8 > 5)) and ReplicatedStorage.Gamemode.Value ~= "tutorial" then
			print("SAVING SCORE")
			v7:SetAsync(v11, v8)
			v12 = true
		end

		LocalEvent:FireAllClients("GameOver", { v8, p1, v12 })
	else
		print("NOT SAVING SCORE BECAUSE THERE ARE MORE THAN 4 PLAYERS")
		LocalEvent:FireAllClients("GameOver", { 0, p1, false })
	end

	for k, v in pairs(Players:GetPlayers()) do
		t.SavePlayerData(v, p1)
	end
end

return t