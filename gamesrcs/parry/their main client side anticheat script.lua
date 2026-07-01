-- https://lua.expert/

-- Hey everyone, it's me, You + 8 Others (snovvvvy) from Discord.
-- I left this here to explain what this anticheat script does.

-- First, it sets its parent to nil in an attempt to hide itself.

-- Second, it checks if you're perfect parrying continuously for over 30 seconds.
-- If that happens, it reports you to the anticheat with the code "HPPTL".
-- HPPTL most likely means something along the lines of
-- "Has Player Passed Time Limit".

-- Third, it listens for changes to the ParryActiveTime attribute.
-- If ParryActiveTime ever goes above 9, it reports you with the code "PATTL".
-- PATTL most likely stands for "Parry Active Time Too Long".

-- Lastly, every 0.1 seconds it checks whether the PerfectParrying attribute exists.
-- If it does, it reports you with the code "SPPA".
-- SPPA likely means one of the following:
-- "Set Perfect Parry Attribute"
-- "Suspicious Perfect Parry Active"

script.Parent = nil

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local v1 = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Modules = ReplicatedStorage:WaitForChild("Modules")

ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DamageConfirm")

local GlobalFunctions = require(Modules:WaitForChild("GlobalFunctions"))
local v2 = nil
local v3 = 0

v2 = RunService.Heartbeat:Connect(function(p1) --[[ Line: 102 | Upvalues: GlobalFunctions (copy), v1 (copy), v3 (ref), v2 (ref), ReplicatedStorage (copy) ]]
	if GlobalFunctions.GPP(v1) == false then
		v3 = 0

		return
	end

	v3 = v3 + p1

	if not (v3 > 30) then
		return
	end

	v2:Disconnect()
	ReplicatedStorage.GoofinatorActivationSequence:FireServer("HPPTL")
end)
LocalPlayer:GetAttributeChangedSignal("ParryActiveTime"):Connect(function() --[[ Line: 116 | Upvalues: LocalPlayer (copy), ReplicatedStorage (copy) ]]
	if not (LocalPlayer:GetAttribute("ParryActiveTime") > 9) then
		return
	end

	ReplicatedStorage.GoofinatorActivationSequence:FireServer("PATTL")
end)

while true do
	if LocalPlayer:GetAttribute("PerfectParrying") ~= nil then
		ReplicatedStorage.GoofinatorActivationSequence:FireServer("SPPA")
	end

	task.wait(0.1)
end