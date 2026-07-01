-- https://lua.expert/

-- Hey everyone, it's me, You + 8 Others (snovvvvy) from Discord.
-- I left this here to explain what this anticheat script does.

-- First, it immediately detaches itself by setting script.Parent to nil,
-- which is an attempt to make it harder to find in the hierarchy.

-- Then it starts monitoring the player's UI state every second.
-- It checks whether PlayerGui exists, and whether "MainGui" and "MainLocal"
-- are properly present inside it.

-- If any of those UI elements are missing, it treats it as suspicious.
-- It doesn't instantly flag it though, instead it builds up a counter.

-- Every second the issue persists, the counter increases by 1.
-- If everything looks normal again, the counter resets back to 0.

-- If the problem continues for 10 consecutive seconds,
-- it assumes something is wrong and stops checking.

-- After that, it reports the situation to the server using:
-- "DA" via GoofinatorActivationSequence:FireServer()

-- "DA" likely stands for something like: "Deleted Assets".

script.Parent = nil

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer
local count = 0

while true do
	local isPlayerGui = LocalPlayer.PlayerGui == nil

	if not LocalPlayer.PlayerGui:FindFirstChild("MainGui") then
		isPlayerGui = true
	end

	if not LocalPlayer.PlayerGui.MainGui:FindFirstChild("MainLocal") then
		isPlayerGui = true
	end

	if isPlayerGui == true then
		count = count + 1

		if count >= 10 then
			break
		end
	else
		count = 0
	end

	task.wait(1)
end

ReplicatedStorage.GoofinatorActivationSequence:FireServer("DA")