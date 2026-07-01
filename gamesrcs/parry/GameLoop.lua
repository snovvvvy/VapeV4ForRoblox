-- https://lua.expert/
local ReplicatedStorage = game:GetService("ReplicatedStorage")

game:GetService("AnalyticsService")
game:GetService("DataStoreService")

local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

game:GetService("Lighting")

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ModifiersActive = ReplicatedStorage:WaitForChild("ModifiersActive")
local Animations = ReplicatedStorage:WaitForChild("Animations")
local Resources = ReplicatedStorage:WaitForChild("Resources")
local Cutscenes = ReplicatedStorage:WaitForChild("Cutscenes")
local Upgrades = ReplicatedStorage:WaitForChild("Upgrades")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Enemies = ReplicatedStorage:WaitForChild("Enemies")
local Stages = ReplicatedStorage:WaitForChild("Stages")
local Sounds = ReplicatedStorage:WaitForChild("Sounds")
local LocalEvent = Remotes:WaitForChild("LocalEvent")
local BetEvent = Remotes:WaitForChild("BetEvent")
local GlobalFunctions = require(Modules.GlobalFunctions)
local EquipmentAppearances = require(Modules.EquipmentAppearances)
local DeathEffects = require(Modules.DeathEffects)

require(Modules.Movement)

local BetsModule = require(script.BetsModule)
local TaskModule = require(script.TaskModule)
local PlayerFolder = workspace:WaitForChild("PlayerFolder")
local EnemyFolder = workspace:WaitForChild("EnemyFolder")
local EffectsFolder = workspace:WaitForChild("EffectsFolder")
local CurrentMap = workspace:WaitForChild("CurrentMap")
local Songs = workspace:WaitForChild("Songs")
local InfinityMix = Songs:WaitForChild("InfinityMix")
local Reverb = SoundService.SoundEffects.Reverb
local CurrentStage = ReplicatedStorage.CurrentStage
local v1 = RaycastParams.new()

v1.FilterType = Enum.RaycastFilterType.Include
v1.FilterDescendantsInstances = { workspace.CurrentMap }

local t = {}
local v2 = 2
local v3 = 1
local v4 = 1
local t2 = {}
local v5 = 1
local v6 = nil
local v7 = nil

for v8, v9 in Stages.MiniStages:GetChildren() do
	if v9.Name ~= "WaitingRoom" then
		table.insert(t, v9)
	end
end

local v10 = Random.new()

local function GetSpawnProbability(p1) --[[ GetSpawnProbability | Line: 73 | Upvalues: v3 (ref) ]]
	return math.max(0.05, p1:GetAttribute("WaveAppearance") + 1 - v3 * 0.04)
end

local function Format(p1) --[[ Format | Line: 173 ]]
	return string.format("%02i", p1)
end

local function convertToHMS(p1) --[[ convertToHMS | Line: 176 | Upvalues: GlobalFunctions (copy) ]]
	local v2 = string.sub(GlobalFunctions.FloatingPointDemolisher(p1 % 1), 3)
	local v3 = (p1 - p1 % 60) / 60
	local v4 = (v3 - v3 % 60) / 60

	return string.format("%02i", v4) .. ":" .. string.format("%02i", v3 - v4 * 60) .. ":" .. string.format("%02i", p1 - v3 * 60) .. "." .. v2
end

local function StageTimeFinish() --[[ StageTimeFinish | Line: 186 | Upvalues: GlobalFunctions (copy), Players (copy), Sounds (copy), convertToHMS (copy), ReplicatedStorage (copy) ]]
	if not (GlobalFunctions.GetPlayersStillAlive() > 0) then
		return
	end

	for k, v in pairs(Players:GetPlayers()) do
		task.spawn(function() --[[ Line: 189 | Upvalues: v (copy), Sounds (ref), convertToHMS (ref), ReplicatedStorage (ref), GlobalFunctions (ref) ]]
			local BigText = v.PlayerGui.BigTextGui.BigText

			BigText.Text = "time to finish stage..."
			BigText.Visible = true
			Sounds.Drumroll:Play()
			task.wait(1)
			BigText.Text = convertToHMS(ReplicatedStorage.StageTime.Value)
			Sounds.StageTimeReveal:Play()
			task.wait(5)

			local Position = BigText.Position
			local Size = BigText.Size

			GlobalFunctions.Tween(BigText, {
				Position = UDim2.fromScale(0.5, 0.05),
				Size = UDim2.fromScale(0.9, 0.06)
			}, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut))
			task.wait(10)
			BigText.Visible = false
			BigText.Position = Position
			BigText.Size = Size
		end)
	end

	task.wait(5)
end

local v11 = true

local function NewWave() --[[ NewWave | Line: 219 | Upvalues: LocalEvent (copy), v3 (ref), Players (copy), v5 (ref), GlobalFunctions (copy), ReplicatedStorage (copy), CurrentStage (copy), Sounds (copy), ModifiersActive (copy), Enemies (copy), EnemyFolder (copy), DeathEffects (copy), EffectsFolder (copy), v2 (ref), v11 (ref) ]]
	LocalEvent:FireAllClients("NewWave", { v3 })

	for v1, v22 in Players:GetPlayers() do
		v22:SetAttribute("TauntFreshness", (math.min(v22:GetAttribute("TauntFreshness") + 0.2, 1)))
		v22:SetAttribute("CanBopWaveText", true)
		task.spawn(function() --[[ Line: 236 | Upvalues: v22 (copy) ]]
			task.wait(5)
			v22:SetAttribute("CanBopWaveText", false)
		end)
	end

	if v3 % 2 == 0 then
		task.spawn(function() --[[ Line: 244 | Upvalues: v5 (ref), GlobalFunctions (ref) ]]
			repeat
				task.wait()
			until workspace:GetAttribute("Hitstopped") == false

			v5 = math.clamp(v5 + 0.029, 1, 1.15)
			GlobalFunctions.UpdateSong(1, v5, 0.5)
		end)
	end

	local v4 = if #Players:GetPlayers() > 1 then math.round(#Players:GetPlayers() / 2) else 1

	if ReplicatedStorage.HellModeActive.Value == true then
		v4 = math.round(v4 + #Players:GetPlayers() * 3)
	end

	local v9 = false
	local v10 = false
	local v112

	if CurrentStage.Value.SpecialWaves:FindFirstChild("Wave" .. v3) then
		local v12 = CurrentStage.Value.SpecialWaves:FindFirstChild("Wave" .. v3)

		if v12.Type.Value == "Intro" then
			ReplicatedStorage.Intro.Value = true
			v12.Type.Value = "Enemies"
			GlobalFunctions.PlaySound(Sounds.IntroStart, workspace.CenterSoundPart, 1)
			v9 = true
			v112 = true
		else
			v112 = false
		end

		if v12.Type.Value == "Boss" then
			task.wait(0.5)
			require(script.Bosses:FindFirstChild(v12.Enemies.Value)).COMMENCE()
		end

		if v12.Type.Value == "Enemies" then
			local v13 = string.split(v12.Enemies.Value, ",")
			local SpawnLimit = v12.SpawnLimit.Value

			if SpawnLimit > 1 and ReplicatedStorage.Difficulty.Value == "Easy" then
				SpawnLimit = SpawnLimit / 2
			end

			if ReplicatedStorage.HellModeActive.Value == true then
				SpawnLimit = 0
			end

			for k, v in pairs(v13) do
				local v14 = string.gsub(v, "%d+", "")
				local v15 = string.gsub(v, "%D+", "")

				if ReplicatedStorage.Difficulty.Value == "Easy" and v9 == false then
					v15 = math.round(v15 / 2)
				end

				task.spawn(function() --[[ Line: 303 | Upvalues: v15 (ref), SpawnLimit (ref), GlobalFunctions (ref), v10 (ref), ModifiersActive (ref), v9 (ref), Enemies (ref), v14 (copy), v12 (copy) ]]
					for i = 1, v15 do
						local v1

						if SpawnLimit > 0 then
							repeat
								task.wait()
							until GlobalFunctions.GetEnemiesStillAlive() < SpawnLimit
						end

						if v10 == true then
							break
						end

						if GlobalFunctions.GetPlayersStillAlive() == 0 then
							break
						end

						v1 = if ModifiersActive:FindFirstChild("double enemies") and v9 == false then 2 else 1

						for j = 1, v1 do
							local v3 = GlobalFunctions.SpawnEnemy(Enemies:FindFirstChild(v14, true))

							if v9 == true then
								v3:SetAttribute("Intro", true)
								GlobalFunctions.IntroText(v3, v12.IntroText.Value)
							end
						end

						GlobalFunctions.Wait(v12.SpawnSpeed.Value)
					end
				end)
			end
		end
	else
		v112 = true
	end

	if v9 == true then
		ReplicatedStorage.TrackStageTime.Value = false

		local v16 = 0

		for k, v in pairs(Players:GetPlayers()) do
			if v:GetAttribute("Dead") == false then
				local SkipButton = v.PlayerGui.IntroGui.SkipButton

				if v:GetAttribute("Device") == "Controller" then
					SkipButton.Text = "skip introduction? (view button to select)"
				else
					SkipButton.Text = "skip introduction?"
				end

				SkipButton.Votes.Text = v16 .. "/" .. GlobalFunctions.GetPlayersStillAlive()
				SkipButton.Visible = true
				SkipButton.MouseButton1Click:Once(function() --[[ Line: 348 | Upvalues: v16 (ref), LocalEvent (ref), v (copy), Sounds (ref), SkipButton (copy), Players (ref), GlobalFunctions (ref) ]]
					v16 = v16 + 1
					LocalEvent:FireClient(v, "PlaySound", { Sounds.GuiClick, workspace.CenterSoundPart })
					task.wait()
					SkipButton.Text = "ok but the others gotta vote too"

					for k, v2 in pairs(Players:GetPlayers()) do
						v2.PlayerGui.IntroGui.SkipButton.Votes.Text = v16 .. "/" .. GlobalFunctions.GetPlayersStillAlive()
					end
				end)
			end
		end

		repeat
			task.wait()

			local v17 = false

			if GlobalFunctions.GetEnemiesStillAlive() == 0 then
				task.wait(0.1)

				if GlobalFunctions.GetEnemiesStillAlive() == 0 then
					v17 = true
				end
			end
		until v17 or GlobalFunctions.GetPlayersStillAlive() <= v16

		for k, v in pairs(Players:GetPlayers()) do
			v.PlayerGui.IntroGui.SkipButton.Visible = false
		end

		GlobalFunctions.PlaySound(Sounds.IntroStart, workspace, 0.9)

		if GlobalFunctions.GetPlayersStillAlive() <= v16 then
			for k, v in pairs(EnemyFolder:GetChildren()) do
				task.spawn(function() --[[ Line: 390 | Upvalues: v (copy), DeathEffects (ref) ]]
					for k, v2 in pairs(v:GetDescendants()) do
						if v2:IsA("BillboardGui") and v2.Name == "IntroGui" then
							v2:Destroy()
						end
					end

					DeathEffects[({ v.Name:gsub("%d", "") })[1]](v)
				end)
			end

			for k, v in pairs(EffectsFolder:GetChildren()) do
				if v.Name == "Missile" or v.Name == "MissileWarning" then
					v:Destroy()
				end
			end
		end

		ReplicatedStorage.TrackStageTime.Value = true
	end

	ReplicatedStorage.Intro.Value = false

	if v112 == true then
		if GlobalFunctions.GetPlayersStillAlive() == 0 then
			return
		end

		local tbl = {}
		local t = {}
		local v18 = 0
		local v19 = v2 * v4 - 0.5

		if ReplicatedStorage.Gamemode.Value == "infinite" then
			v19 = math.min(v19, 10)
		end

		local count = 0

		repeat
			for k, v in pairs(Enemies:GetChildren()) do
				local v21 = v:GetChildren()[math.random(1, #v:GetChildren())]

				if v21.CanAppearIn:FindFirstChild(CurrentStage.Value.Name) and not ReplicatedStorage.BannedEnemies:FindFirstChild(v21.Name) then
					local v23 = math.max(0.05, v21:GetAttribute("WaveAppearance") + 1 - v3 * 0.04)
					local v24 = math.random()

					if v21:GetAttribute("SpawnLimit") == nil or not (t[v21] and t[v21] >= v21:GetAttribute("SpawnLimit")) then
						if v18 + v21:GetAttribute("Difficulty") <= v2 * v4 and (v21:GetAttribute("WaveAppearance") <= v3 and v24 <= v23) then
							table.insert(tbl, v21)

							if t[v21] == nil then
								t[v21] = 1
							else
								t[v21] = t[v21] + 1
							end

							v18 = if ReplicatedStorage.Gamemode.Value == "infinite" then v18 + 1 else v18 + v21:GetAttribute("Difficulty")

							continue
						end

						count = count + 1

						continue
					end

					count = count + 1
				end
			end
		until v19 <= v18 or count >= 500

		if count >= 500 then
			warn("ENEMY CHOOSER THING ATTEMPTS EXHAUSTED")
		end

		local v26 = math.clamp(1 - v3 / 5, 0.4, (1 / 0))
		local sum = math.clamp(v3 * v4, 0, 10)

		if ModifiersActive:FindFirstChild("double enemies") then
			sum = sum * 2
		end

		if sum > 2 and ReplicatedStorage.Difficulty.Value == "Easy" then
			sum = sum / 2
		end

		if ModifiersActive:FindFirstChild("got school in 5!") then
			sum = sum + 5
		end

		for k, v in pairs(tbl) do
			repeat
				task.wait()
			until GlobalFunctions.GetEnemiesStillAlive() < sum

			local v28, v29, v30

			if v:GetAttribute("SpawnLimit") == nil then
				v28 = 1
				v29 = if ModifiersActive:FindFirstChild("double enemies") then 2 else 1

				for i = v28, v29 do
					if GlobalFunctions.GetEnemiesStillAlive() < sum then
						if v11 == true then
							v11 = false
							v30 = CFrame.new(0, 3, -40) * CFrame.Angles(0, math.pi, 0)
						else
							v30 = nil
						end

						GlobalFunctions.SpawnEnemy(v, v30)
					end
				end

				GlobalFunctions.Wait(v26)
			else
				local count2 = 0

				for v31, v32 in EnemyFolder:GetChildren() do
					if string.find(v.Name, v32.Name) then
						count2 = count2 + 1
					end
				end

				if not (v:GetAttribute("SpawnLimit") <= count2) then
					v28 = 1
					v29 = if ModifiersActive:FindFirstChild("double enemies") then 2 else 1

					for i = v28, v29 do
						if GlobalFunctions.GetEnemiesStillAlive() < sum then
							if v11 == true then
								v11 = false
								v30 = CFrame.new(0, 3, -40) * CFrame.Angles(0, math.pi, 0)
							else
								v30 = nil
							end

							GlobalFunctions.SpawnEnemy(v, v30)
						end
					end

					GlobalFunctions.Wait(v26)
				end
			end
		end
	end

	if not ModifiersActive:FindFirstChild("got school in 5!") then
		repeat
			task.wait(0.1)

			local count = 0

			for k, v in pairs(EnemyFolder:GetChildren()) do
				if v:GetAttribute("Alive") == true then
					count = count + 1
				end
			end
		until count == 0
	end

	v3 = v3 + 1
	v2 = v2 + (if ReplicatedStorage.Difficulty.Value == "Easy" then 1 else 3)

	if not (v2 > 99) then
		ReplicatedStorage.Wave.Value = v3

		return
	end

	v2 = 99
	ReplicatedStorage.Wave.Value = v3
end

local function ClearStageVotes() --[[ ClearStageVotes | Line: 527 | Upvalues: Players (copy) ]]
	for k, v in pairs(Players:GetPlayers()) do
		local MainFrame = v.PlayerGui.StageGui.MainFrame

		for k2, v2 in pairs(MainFrame.Stages:GetChildren()) do
			if v2:IsA("Frame") then
				for k3, v3 in pairs(v2.MainFrame.Votes:GetChildren()) do
					if v3:IsA("ImageLabel") then
						v3:Destroy()
					end
				end
			end
		end

		for k2, v2 in pairs(MainFrame.MiniStages:GetChildren()) do
			if v2:IsA("Frame") then
				for k3, v3 in pairs(v2.MainFrame.Votes:GetChildren()) do
					if v3:IsA("ImageLabel") then
						v3:Destroy()
					end
				end
			end
		end
	end
end

local function UpdateStageVotes(p1) --[[ UpdateStageVotes | Line: 549 | Upvalues: Players (copy) ]]
	print("START-------------------------")
	print(p1)

	for k, v in pairs(Players:GetPlayers()) do
		local MainFrame = v.PlayerGui.StageGui.MainFrame
		local Stages = MainFrame.Stages
		local MiniStages = MainFrame.MiniStages

		for k2, v2 in pairs(p1) do
			local v1 = if v2.StageHolder.Parent.Name == "Stages" then MainFrame.Stages else MainFrame.MiniStages
			local BackgroundColor3 = v2.StageHolder.MainFrame.BackgroundColor3
			local v22 = Stages:FindFirstChild(v2.Player.Name, true) or MiniStages:FindFirstChild(v2.Player.Name, true)

			print(v2.StageHolder.Name)

			if v22 then
				print("old vote found")
				print(v22)
				print(v)
				v22.BackgroundColor3 = BackgroundColor3
				v22.UIStroke.Color = BackgroundColor3
				v22.Parent = v1:FindFirstChild(v2.StageHolder.Name).MainFrame.Votes

				continue
			end

			print("no old vote")
			print(v)

			local v3 = script.StageVoteSample:Clone()

			v3.BackgroundColor3 = BackgroundColor3
			v3.UIStroke.Color = BackgroundColor3
			v3.Name = v2.Player.Name
			v3.Parent = v1:FindFirstChild(v2.StageHolder.Name).MainFrame.Votes
			task.spawn(function() --[[ Line: 590 | Upvalues: Players (ref), v2 (copy), v3 (copy) ]]
				local v1, v22 = Players:GetUserThumbnailAsync(v2.Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)

				repeat
					task.wait()
				until v22

				v3.Image = v1
			end)
		end
	end

	print("END-------------------------")
end

local v12 = false
local v13 = true

local function NewStage(p1) --[[ NewStage | Line: 611 | Upvalues: EffectsFolder (copy), CurrentStage (copy), Sounds (copy), Players (copy), GlobalFunctions (copy), Animations (copy), LocalEvent (copy), CurrentMap (copy), Stages (copy), v4 (ref), v3 (ref), v2 (ref), v5 (ref), v13 (ref), t (copy), v6 (ref), v12 (ref), UpdateStageVotes (copy), RunService (copy), PlayerFolder (copy), ClearStageVotes (copy), Cutscenes (copy), Songs (copy) ]]
	if p1 ~= nil then
		workspace:SetAttribute("TimeScale", workspace:GetAttribute("TimeScale") + 3)
	end

	for k, v in pairs(EffectsFolder:GetChildren()) do
		if v.Name == "Piano" then
			v:Destroy()
		end
	end

	if not CurrentStage.Value:FindFirstChild("SkipExitSequence") then
		Sounds.StageChange:Play()
	end

	for k, v in pairs(Players:GetPlayers()) do
		task.spawn(function() --[[ Line: 628 | Upvalues: v (copy), CurrentStage (ref), GlobalFunctions (ref), Animations (ref) ]]
			v.Character.HumanoidRootPart.Anchored = true
			v.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			v:SetAttribute("CanAttack", false)
			v:SetAttribute("CanDash", false)
			v:SetAttribute("CanFaceCamera", false)
			v:SetAttribute("CanTaunt", false)
			v:SetAttribute("TauntFreshness", 1)

			if CurrentStage.Value:FindFirstChild("SkipExitSequence") then
				return
			end

			GlobalFunctions.Tween(v.PlayerGui.StageGui.WhiteCover, {
				BackgroundTransparency = 0
			}, TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), true)

			local v1 = v.Character.Humanoid.Animator:LoadAnimation(Animations.StageChange)

			v1:Play(0)

			if workspace:GetAttribute("TimeScale") ~= 1 then
				v1:AdjustSpeed(workspace:GetAttribute("TimeScale"))
			end

			GlobalFunctions.Wait(6)
			v1:Stop(0)
		end)
	end

	if not CurrentStage.Value:FindFirstChild("SkipExitSequence") then
		GlobalFunctions.Wait(1)
		LocalEvent:FireAllClients("NewStage")
		GlobalFunctions.UpdateSong(0, 1, 4)
		GlobalFunctions.Wait(4)
	end

	CurrentMap:ClearAllChildren()
	GlobalFunctions.DestroyGuiseShip()

	for v1, v22 in EffectsFolder:GetDescendants() do
		if v22 ~= EffectsFolder.Debris then
			v22:Destroy()
		end
	end

	GlobalFunctions.DeleteSong()

	if CurrentStage.Value.Parent == Stages.MiddleStages then
		v4 = v4 + 1
	end

	v3 = 1
	v2 = v4 * 3
	v5 = 1

	if not CurrentStage.Value:FindFirstChild("SkipExitSequence") then
		GlobalFunctions.Wait(3)
	end

	local v32

	if CurrentStage.Value.Parent == Stages.MiddleStages or CurrentStage.Value.Parent == Stages then
		v32 = true
		v13 = true
	else
		v32 = false
	end

	if (CurrentStage.Value.Parent == Stages.MiddleStages or CurrentStage.Value.Parent == Stages.MiniStages) and CurrentStage.Value ~= Stages.MiniStages.WaitingRoom then
		CurrentStage.Value:Destroy()
	end

	warn(v32)

	local v42

	if #Stages.MiddleStages:GetChildren() > 0 then
		local count = if p1 == nil then 30 else 1
		local tbl = {}
		local tbl2 = {}

		if v32 == true then
			print(t)

			if #t > 0 then
				v6 = t[math.random(1, #t)]
				table.remove(t, table.find(t, v6))
			else
				v6 = ""
			end

			print(v6)
		else
			print("didnt cycle mini stage cause the last stage was already a mini")
		end

		for k, v in pairs(Players:GetPlayers()) do
			v.PlayerGui.MainGui.WhiteCover.BackgroundTransparency = 1

			local StageGui = v.PlayerGui.StageGui
			local MainFrame = StageGui.MainFrame
			local Stages2 = MainFrame.Stages
			local MiniStages = MainFrame.MiniStages
			local Timer = MainFrame.Timer

			StageGui.WhiteCover.BackgroundTransparency = 0

			if #Stages.MiddleStages:GetChildren() == 1 then
				warn("MIDDLE STAGES LEFT: " .. tostring(#Stages.MiddleStages:GetChildren()))
				warn("MINI STAGES LEFT: " .. tostring(#Stages.MiniStages:GetChildren()))
				warn("ALREADY BEEN AT 1 STAGE VARIABLE: " .. tostring(v12))

				if v12 == true then
					MainFrame.StagesLeftText.Text = "ACTUALLY 1 STAGE LEFT"
					MainFrame.ChooseText.Text = "GO FORTH PLEASE."
				else
					v12 = true
					MainFrame.StagesLeftText.Text = "1 STAGE LEFT"
					MainFrame.ChooseText.Text = "GO FORTH."
				end
			else
				MainFrame.StagesLeftText.Text = #Stages.MiddleStages:GetChildren() .. " STAGES LEFT"
				MainFrame.ChooseText.Visible = true
			end

			MainFrame.Visible = true
			GlobalFunctions.Tween(StageGui.WhiteCover, {
				BackgroundTransparency = 1
			}, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In))

			for k2, v7 in pairs(Stages2:GetChildren()) do
				if v7:IsA("Frame") then
					if Stages.MiddleStages:FindFirstChild(v7.Name) then
						tbl2[v7.MainFrame] = v7.MainFrame.MouseButton1Click:Connect(function() --[[ Line: 772 | Upvalues: tbl (copy), v (copy), Stages (ref), v7 (copy), UpdateStageVotes (ref) ]]
							if tbl[v.Name] then
								tbl[v.Name].Stage = Stages.MiddleStages:FindFirstChild(v7.Name)
								tbl[v.Name].VoteHolder = v7.MainFrame.Votes
							else
								tbl[v.Name] = {}
								tbl[v.Name].Player = v
								tbl[v.Name].Stage = Stages.MiddleStages:FindFirstChild(v7.Name)
							end

							tbl[v.Name].StageHolder = v7
							UpdateStageVotes(tbl)
						end)

						continue
					end

					v7.Visible = false
				end
			end

			local count2 = 0

			for k2, v7 in pairs(MiniStages:GetChildren()) do
				if v7:IsA("Frame") then
					if v7.Name == "WaitingRoom" and v13 == false then
						v7.Visible = false

						continue
					end

					if v7.Name == "WaitingRoom" or v7.Name == v6.Name then
						if Stages.MiniStages:FindFirstChild(v7.Name) then
							v7.Visible = true
							tbl2[v7.MainFrame] = v7.MainFrame.MouseButton1Click:Connect(function() --[[ Line: 815 | Upvalues: tbl (copy), v (copy), Stages (ref), v7 (copy), UpdateStageVotes (ref) ]]
								if tbl[v.Name] then
									tbl[v.Name].Stage = Stages.MiniStages:FindFirstChild(v7.Name)
									tbl[v.Name].VoteHolder = v7.MainFrame.Votes
								else
									tbl[v.Name] = {}
									tbl[v.Name].Player = v
									tbl[v.Name].Stage = Stages.MiniStages:FindFirstChild(v7.Name)
								end

								tbl[v.Name].StageHolder = v7
								UpdateStageVotes(tbl)
							end)
							count2 = count2 + 1

							continue
						end

						v7.Visible = false

						continue
					end

					print("NUHUH YOUR " .. v7.Name)
					v7.Visible = false
				end
			end

			if count2 > 0 then
				MainFrame.Optional.Visible = true

				continue
			end

			MainFrame.Optional.Visible = false
		end

		local v10 = false
		local t2 = {}
		local v11 = RunService.Heartbeat:Connect(function() --[[ Line: 854 | Upvalues: v10 (ref), PlayerFolder (ref), Players (ref), t2 (copy), GlobalFunctions (ref), count (ref) ]]
			if v10 ~= true then
				return
			end

			for v1, v2 in PlayerFolder:GetChildren() do
				local v3 = Players:GetPlayerFromCharacter(v2)

				if v3 and not table.find(t2, v3) then
					table.insert(t2, v3)

					if GlobalFunctions.DamagePlayer(nil, v2, 0, true) == false then
						count = count - 5
						task.wait(0.2)
						v3:SetAttribute("ParryCooldown", 0)
						v3:SetAttribute("ParryActiveTime", 0)
						v2:SetAttribute("Parrying", false)
					end

					table.remove(t2, table.find(t2, v3))
				end
			end
		end)
		local v122 = false

		repeat
			count = count - 1

			for k, v in pairs(Players:GetPlayers()) do
				local _, result = pcall(function() --[[ Line: 888 | Upvalues: v (copy), count (ref) ]]
					v.PlayerGui.StageGui.MainFrame.Timer.Text = count
				end)

				if result then
					warn(result)
				end
			end

			local v132 = 3 / count + 1

			if v122 == false then
				GlobalFunctions.PlaySound(Sounds.Tick, workspace, v132, false)
			else
				GlobalFunctions.PlaySound(Sounds.Tock, workspace, v132, false)
			end

			v122 = not v122

			if v10 == false then
				local count2 = 0

				for k, v in pairs(tbl) do
					count2 = count2 + 1
				end

				if #Players:GetPlayers() <= count2 or p1 ~= nil then
					v10 = true

					for v14, v15 in Players:GetPlayers() do
						v15:SetAttribute("ExplicitParryPermission", true)
					end
				end
			end

			if v10 == true then
				task.wait(0.15)

				continue
			end

			task.wait(1)
		until count <= 0

		for v16, v17 in Players:GetPlayers() do
			v17:SetAttribute("ExplicitParryPermission", nil)
		end

		v11:Disconnect()

		for k, v in pairs(tbl2) do
			v:Disconnect()
		end

		ClearStageVotes()

		for k, v in pairs(Players:GetPlayers()) do
			local StageGui = v.PlayerGui.StageGui

			StageGui.MainFrame.Visible = false
			StageGui.WhiteCover.BackgroundTransparency = 0
		end

		Sounds.StageChosen:Play()

		local count2 = 0

		for k, v in pairs(tbl) do
			count2 = count2 + 1
		end

		if p1 == nil then
			if count2 > 0 then
				print("AT LEAST ONE PERSON VOTED, GETTING TOP VOTED STAGE")

				local tbl3 = {}

				for k, v in pairs(tbl) do
					if tbl3[v.Stage.Name] then
						local v18 = tbl3[v.Stage.Name]

						v18.Votes = v18.Votes + 1

						continue
					end

					tbl3[v.Stage.Name] = {}
					tbl3[v.Stage.Name].Votes = 1
					tbl3[v.Stage.Name].Stage = v.Stage
				end

				print(tbl3)

				local v19 = 0

				for k, v in pairs(tbl3) do
					if v19 < v.Votes then
						v19 = v.Votes
						CurrentStage.Value = v.Stage
						print(CurrentStage.Name .. " WINS")
					end
				end

				if CurrentStage.Value == Stages.MiniStages.WaitingRoom then
					v13 = false
				end

				v42 = CurrentStage.Value.Map:Clone()
				v42.Parent = CurrentMap
				GlobalFunctions.NewSky(v42.Sky)

				if v42:FindFirstChild("SkyConfig") then
					GlobalFunctions.SetSkyConfig(v42.SkyConfig)
				end

				if p1 == nil and CurrentStage.Value == Stages.CampaignDeathZone then
					task.wait(2)
				elseif p1 == nil then
					task.wait(4)
				end

				for k2, v in pairs(Players:GetPlayers()) do
					task.spawn(function() --[[ Line: 1018 | Upvalues: v (copy), CurrentStage (ref), Stages (ref), GlobalFunctions (ref), LocalEvent (ref), Cutscenes (ref) ]]
						local Character = v.Character

						if CurrentStage.Value == Stages.CampaignDeathZone or CurrentStage.Value:FindFirstChild("SkipOpeningSequence") ~= nil then
							v.PlayerGui.StageGui.WhiteCover.BackgroundTransparency = 1
						else
							Character:PivotTo(CFrame.new(0, 3, 0))
							GlobalFunctions.Tween(v.PlayerGui.StageGui.WhiteCover, {
								BackgroundTransparency = 1
							}, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
							LocalEvent:FireClient(v, "Cutscene", { Cutscenes.Camera_NewStage })
						end

						Character.HumanoidRootPart.Anchored = false
						GlobalFunctions.Tween(Character.Humanoid, {
							Health = Character.Humanoid.MaxHealth
						}, TweenInfo.new(3.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In), true)
						GlobalFunctions.Wait(3.5)

						if v:GetAttribute("Dead") == false and not CurrentStage.Value:FindFirstChild("SkipOpeningSequence") then
							v:SetAttribute("CanAttack", true)
							v:SetAttribute("CanDash", true)
							v:SetAttribute("CanFaceCamera", true)
						end

						if CurrentStage.Value:FindFirstChild("SkipOpeningSequence") then
							return
						end

						v:SetAttribute("CanTaunt", true)
					end)
				end

				if CurrentStage.Value == Stages.CampaignDeathZone then
					Sounds.DeathZoneAmbience:Play()
				elseif not CurrentStage.Value:FindFirstChild("SkipOpeningSequence") then
					workspace.MapRevealer1.Position = Vector3.new(-1.25, 1000, 0)
					workspace.MapRevealer2.Position = Vector3.new(1.25, 1000, 0)
					workspace.MapRevealer1.Transparency = 0
					workspace.MapRevealer2.Transparency = 0
					workspace.MapRevealer1.Highlight.FillTransparency = 0
					workspace.MapRevealer2.Highlight.FillTransparency = 0
					GlobalFunctions.Tween(workspace.MapRevealer1, {
						Position = Vector3.new(-600, -1050, 0)
					}, TweenInfo.new(7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), true)
					GlobalFunctions.Tween(workspace.MapRevealer2, {
						Position = Vector3.new(600, -1050, 0)
					}, TweenInfo.new(7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), true)
					GlobalFunctions.PlaySound(Sounds.MapReveal, workspace)
					GlobalFunctions.NewSong(Songs[CurrentStage.Value.Name .. "Default"])
					GlobalFunctions.UpdateSong(1, 0, 0)
					task.wait()
					GlobalFunctions.UpdateSong(1, 1, 7)
					GlobalFunctions.Wait(7)
				end

				if not CurrentStage.Value:FindFirstChild("SkipOpeningSequence") then
					for k2, v in pairs(Players:GetPlayers()) do
						task.spawn(function() --[[ Line: 1077 | Upvalues: v (copy), CurrentStage (ref), GlobalFunctions (ref) ]]
							local MainGui = v.PlayerGui:WaitForChild("MainGui")

							MainGui.LevelName.Position = UDim2.fromScale(0.5, 0.1)

							if CurrentStage.Value:FindFirstChild("Name") then
								MainGui.LevelName.Text = CurrentStage.Value:FindFirstChild("Name").Value
							else
								MainGui.LevelName.Text = CurrentStage.Value.Name
							end

							MainGui.LevelName.Visible = true
							GlobalFunctions.Wait(5)
							GlobalFunctions.Tween(MainGui.LevelName, {
								Position = UDim2.fromScale(0.5, -0.1)
							}, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), true)
							GlobalFunctions.Wait(3)
							MainGui.LevelName.Visible = false
						end)
					end
				end

				workspace.MapRevealer1.Transparency = 1
				workspace.MapRevealer2.Transparency = 1
				workspace.MapRevealer1.Highlight.FillTransparency = 1
				workspace.MapRevealer2.Highlight.FillTransparency = 1

				for k2, v in pairs(PlayerFolder:GetChildren()) do
					if v:FindFirstChild("Forcefield") then
						v.Forcefield:Destroy()
					end
				end

				if p1 == nil then
					return
				end

				workspace:SetAttribute("TimeScale", workspace:GetAttribute("TimeScale") - 3)

				return
			end

			print("RANDOM STAGE CHOSEN CUZ NOBODY VOTED")
			CurrentStage.Value = Stages.MiddleStages:GetChildren()[math.random(1, #Stages.MiddleStages:GetChildren())]
		else
			CurrentStage.Value = p1
		end
	else
		print("DEATH ZONE CHOSEN")
		CurrentStage.Value = Stages.CampaignDeathZone
	end

	if CurrentStage.Value == Stages.MiniStages.WaitingRoom then
		v13 = false
	end

	v42 = CurrentStage.Value.Map:Clone()
	v42.Parent = CurrentMap
	GlobalFunctions.NewSky(v42.Sky)

	if v42:FindFirstChild("SkyConfig") then
		GlobalFunctions.SetSkyConfig(v42.SkyConfig)
	end

	if p1 == nil and CurrentStage.Value == Stages.CampaignDeathZone then
		task.wait(2)
	elseif p1 == nil then
		task.wait(4)
	end

	for k2, v in pairs(Players:GetPlayers()) do
		task.spawn(function() --[[ Line: 1018 | Upvalues: v (copy), CurrentStage (ref), Stages (ref), GlobalFunctions (ref), LocalEvent (ref), Cutscenes (ref) ]]
			local Character = v.Character

			if CurrentStage.Value == Stages.CampaignDeathZone or CurrentStage.Value:FindFirstChild("SkipOpeningSequence") ~= nil then
				v.PlayerGui.StageGui.WhiteCover.BackgroundTransparency = 1
			else
				Character:PivotTo(CFrame.new(0, 3, 0))
				GlobalFunctions.Tween(v.PlayerGui.StageGui.WhiteCover, {
					BackgroundTransparency = 1
				}, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
				LocalEvent:FireClient(v, "Cutscene", { Cutscenes.Camera_NewStage })
			end

			Character.HumanoidRootPart.Anchored = false
			GlobalFunctions.Tween(Character.Humanoid, {
				Health = Character.Humanoid.MaxHealth
			}, TweenInfo.new(3.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In), true)
			GlobalFunctions.Wait(3.5)

			if v:GetAttribute("Dead") == false and not CurrentStage.Value:FindFirstChild("SkipOpeningSequence") then
				v:SetAttribute("CanAttack", true)
				v:SetAttribute("CanDash", true)
				v:SetAttribute("CanFaceCamera", true)
			end

			if CurrentStage.Value:FindFirstChild("SkipOpeningSequence") then
				return
			end

			v:SetAttribute("CanTaunt", true)
		end)
	end

	if CurrentStage.Value == Stages.CampaignDeathZone then
		Sounds.DeathZoneAmbience:Play()
	elseif not CurrentStage.Value:FindFirstChild("SkipOpeningSequence") then
		workspace.MapRevealer1.Position = Vector3.new(-1.25, 1000, 0)
		workspace.MapRevealer2.Position = Vector3.new(1.25, 1000, 0)
		workspace.MapRevealer1.Transparency = 0
		workspace.MapRevealer2.Transparency = 0
		workspace.MapRevealer1.Highlight.FillTransparency = 0
		workspace.MapRevealer2.Highlight.FillTransparency = 0
		GlobalFunctions.Tween(workspace.MapRevealer1, {
			Position = Vector3.new(-600, -1050, 0)
		}, TweenInfo.new(7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), true)
		GlobalFunctions.Tween(workspace.MapRevealer2, {
			Position = Vector3.new(600, -1050, 0)
		}, TweenInfo.new(7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), true)
		GlobalFunctions.PlaySound(Sounds.MapReveal, workspace)
		GlobalFunctions.NewSong(Songs[CurrentStage.Value.Name .. "Default"])
		GlobalFunctions.UpdateSong(1, 0, 0)
		task.wait()
		GlobalFunctions.UpdateSong(1, 1, 7)
		GlobalFunctions.Wait(7)
	end

	if not CurrentStage.Value:FindFirstChild("SkipOpeningSequence") then
		for k2, v in pairs(Players:GetPlayers()) do
			task.spawn(function() --[[ Line: 1077 | Upvalues: v (copy), CurrentStage (ref), GlobalFunctions (ref) ]]
				local MainGui = v.PlayerGui:WaitForChild("MainGui")

				MainGui.LevelName.Position = UDim2.fromScale(0.5, 0.1)

				if CurrentStage.Value:FindFirstChild("Name") then
					MainGui.LevelName.Text = CurrentStage.Value:FindFirstChild("Name").Value
				else
					MainGui.LevelName.Text = CurrentStage.Value.Name
				end

				MainGui.LevelName.Visible = true
				GlobalFunctions.Wait(5)
				GlobalFunctions.Tween(MainGui.LevelName, {
					Position = UDim2.fromScale(0.5, -0.1)
				}, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), true)
				GlobalFunctions.Wait(3)
				MainGui.LevelName.Visible = false
			end)
		end
	end

	workspace.MapRevealer1.Transparency = 1
	workspace.MapRevealer2.Transparency = 1
	workspace.MapRevealer1.Highlight.FillTransparency = 1
	workspace.MapRevealer2.Highlight.FillTransparency = 1

	for k2, v in pairs(PlayerFolder:GetChildren()) do
		if v:FindFirstChild("Forcefield") then
			v.Forcefield:Destroy()
		end
	end

	if p1 == nil then
		return
	end

	workspace:SetAttribute("TimeScale", workspace:GetAttribute("TimeScale") - 3)
end

local function PlayerUpgrades() --[[ PlayerUpgrades | Line: 1116 | Upvalues: EffectsFolder (copy), ReplicatedStorage (copy), GlobalFunctions (copy), Songs (copy), Players (copy), RunService (copy), LocalEvent (copy), Sounds (copy), Upgrades (copy), EquipmentAppearances (copy), PlayerFolder (copy) ]]
	for k, v in pairs(EffectsFolder:GetChildren()) do
		if v.Name == "Piano" then
			v:Destroy()
		end
	end

	local v1 = 0

	if ReplicatedStorage.Gamemode.Value ~= "infinite" then
		GlobalFunctions.UpdateSong(0, 1, 0.5)
	end

	GlobalFunctions.Wait(0.5)

	if ReplicatedStorage.Gamemode.Value == "infinite" then
		GlobalFunctions.NewSong(Songs.InfiniteIntermission)
	else
		GlobalFunctions.NewSong(Songs.Upgrading)
	end

	for k, v in pairs(Players:GetChildren()) do
		if v:GetAttribute("Dead") == false then
			task.spawn(function() --[[ Line: 1139 | Upvalues: v (copy), RunService (ref), GlobalFunctions (ref), LocalEvent (ref), Sounds (ref), v1 (ref), Upgrades (ref), EquipmentAppearances (ref) ]]
				v:SetAttribute("Upgrading", true)
				v:SetAttribute("ExplicitParryPermission", true)

				local t = {}
				local v12 = false
				local v2 = false
				local v3 = false
				local v4 = false
				local UpgradeGui = v.PlayerGui.UpgradeGui
				local MainFrame = UpgradeGui.MainFrame
				local v5 = v:GetAttribute("HasRerolled") ~= true
				local v6 = nil
				local v7 = RunService.Heartbeat:Connect(function() --[[ Line: 1159 | Upvalues: v3 (ref), GlobalFunctions (ref), v (ref), v4 (ref), LocalEvent (ref), Sounds (ref) ]]
					if v3 ~= false then
						return
					end

					task.defer(function() --[[ Line: 1162 | Upvalues: GlobalFunctions (ref), v (ref), v3 (ref), v4 (ref), LocalEvent (ref), Sounds (ref) ]]
						if GlobalFunctions.DamagePlayer(nil, v.Character, 0, true) ~= false then
							return
						end

						if v3 == true then
							return
						end

						v3 = true
						print("CARDS PARRY!!!!!!!!!!")
						v4 = true
						GlobalFunctions.AddStreak(v, 0, "HURRY UP!")
						LocalEvent:FireClient(v, "PlaySound", { Sounds.UpgradeCardsParried, workspace })
					end)
				end)

				local function ShowCards(p1) --[[ ShowCards | Line: 1187 | Upvalues: v (ref), MainFrame (copy), LocalEvent (ref), Sounds (ref), GlobalFunctions (ref), v2 (ref), v1 (ref), Upgrades (ref), t (copy), v12 (ref), v6 (ref), EquipmentAppearances (ref), UpgradeGui (copy), v4 (ref) ]]
					local v13 = if p1 == true then 2 else 1
					local v22 = false
					local v3

					for i = 1, 4 do
						local v42

						if v22 ~= true then
							if i == 3 and v:GetAttribute("NoUpgrades") then
								v:SetAttribute("NoUpgrades", nil)

								for k, v5 in pairs(MainFrame:GetChildren()) do
									if string.find(v5.Name, "Card") and v5.Name ~= "SampleCard" then
										v5:Destroy()
									end
								end

								MainFrame.PsychiMessage.Visible = true
								MainFrame.PsychiMessage.TextLabel.Text = "\"no.\""
								LocalEvent:FireClient(v, "PlaySound", { Sounds.UpgradesDenied, workspace })
								LocalEvent:FireClient(v, "UpdateSong", { 1, 0, 2 })

								local t2 = {}

								for v5, v62 in MainFrame.PsychiMessage:GetDescendants() do
									if v62:IsA("TextLabel") then
										t2[v62] = {}
										t2[v62].TextTransparency = v62.TextTransparency
										GlobalFunctions.Tween(v62, {
											TextTransparency = 1
										}, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In))

										continue
									end

									if v62:IsA("ImageLabel") then
										t2[v62] = {}
										t2[v62].BackgroundTransparency = v62.BackgroundTransparency
										t2[v62].ImageTransparency = v62.ImageTransparency
										GlobalFunctions.Tween(v62, {
											BackgroundTransparency = 1
										}, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
										GlobalFunctions.Tween(v62, {
											ImageTransparency = 1
										}, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In))

										continue
									end

									if v62:IsA("UIStroke") then
										t2[v62] = {}
										t2[v62].Transparency = v62.Transparency
										GlobalFunctions.Tween(v62, {
											Transparency = 1
										}, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
									end
								end

								task.wait(3)
								MainFrame.PsychiMessage.Visible = false
								task.spawn(function() --[[ Line: 1238 | Upvalues: LocalEvent (ref), v (ref) ]]
									task.wait(1)
									LocalEvent:FireClient(v, "UpdateSong", { 1, 1, 1 })
								end)

								for v7, v8 in MainFrame.PsychiMessage:GetDescendants() do
									if v8:IsA("TextLabel") then
										v8.TextTransparency = t2[v8].TextTransparency

										continue
									end

									if v8:IsA("ImageLabel") then
										v8.BackgroundTransparency = t2[v8].BackgroundTransparency
										v8.ImageTransparency = t2[v8].ImageTransparency

										continue
									end

									if v8:IsA("UIStroke") then
										v8.Transparency = t2[v8].Transparency
									end
								end

								v:SetAttribute("Upgrading", false)
								v2 = true
								v1 = v1 + 1
								v22 = true

								continue
							end

							local count = 0

							if i == 4 then
								v3 = Upgrades.Points
							else
								repeat
									v3 = Upgrades:GetChildren()[math.random(1, #Upgrades:GetChildren())]
									v42 = v3 ~= Upgrades.Points

									if table.find(t, v3) or v:GetAttribute(v3.Name) ~= nil then
										v42 = false
									end

									for k, v5 in pairs(v3:GetChildren()) do
										if v5.Name == "Attribute" then
											local v9 = string.split(v5.Value, ",")

											if v9[1] == "CounterType" and v:GetAttribute("Basics") == true then
												v42 = false
											end

											if v9[1] == "CounterType" and v:GetAttribute("CounterType") == v9[2] then
												v42 = false
											end

											if v9[1] == "Ability" and v:GetAttribute("Ability") ~= nil then
												v42 = false
											end
										end

										if v5.Name == "BlacklistedWeapon" and v5.Value == v:GetAttribute("Weapon") then
											v42 = false
										end

										if v5.Name == "WhitelistedWeapon" and v5.Value ~= v:GetAttribute("Weapon") then
											v42 = false
										end
									end

									count = count + 1
								until v42 == true or count > 50
							end

							if count <= 50 then
								table.insert(t, v3)

								local v11 = MainFrame.SampleCard:Clone()
								local MainFrame2 = v11.MainFrame
								local InnerFrame = MainFrame2.InnerFrame

								v11.Parent = MainFrame
								v11.Name = "Card" .. i
								v11.Selectable = true
								InnerFrame.UpgradeTitle.Text = v3.UpgradeName.Value
								InnerFrame.UpgradeDescription.Text = v3.UpgradeDescription.Value
								v3.Icon:Clone().Parent = InnerFrame.ViewportFrame.WorldModel
								v11.Visible = true
								LocalEvent:FireClient(v, "PlaySound", { Sounds.CardAppear, workspace })
								v11.MouseButton1Click:Connect(function() --[[ Line: 1332 | Upvalues: v12 (ref), MainFrame (ref), v3 (ref), v (ref), GlobalFunctions (ref), v6 (ref), EquipmentAppearances (ref), v11 (copy), v1 (ref), v2 (ref), UpgradeGui (ref), LocalEvent (ref), Sounds (ref) ]]
									if v12 ~= true then
										return
									end

									for k, v4 in pairs(MainFrame:GetChildren()) do
										if string.find(v4.Name, "Card") and v4.Name ~= "SampleCard" then
											v4:Destroy()
										end
									end

									for k, v4 in pairs(v3:GetChildren()) do
										if v4.Name == "Attribute" then
											local v13 = string.split(v4.Value, ",")

											if string.match(v13[2], "%d+") ~= nil then
												v13[2] = tonumber(v13[2])
											end

											if v13[2] == "true" then
												v13[2] = true
											end

											if v13[3] and v13[3] == "+" then
												v:SetAttribute(v13[1], v:GetAttribute(v13[1]) + v13[2])
											else
												v:SetAttribute(v13[1], v13[2])
											end

											if v3.Name == "Points" then
												GlobalFunctions.CheckScore(v)
												GlobalFunctions.ScoreLabels(v)
											end
										end
									end

									if v6 then
										v6:Disconnect()
									end

									v:SetAttribute("Upgrading", false)
									v:SetAttribute("JustUpgraded", true)
									EquipmentAppearances.AddAppearances(v)
									v11:Destroy()
									v1 = v1 + 1
									v2 = true
									UpgradeGui.RerollButton.Visible = false
									UpgradeGui.TimeLeftLabel.Visible = false
									LocalEvent:FireClient(v, "PlaySound", { Sounds.UpgradeChosen, workspace })
									task.wait(0.1)
									v:SetAttribute("JustUpgraded", false)
								end)
								v11.MouseEnter:Connect(function() --[[ Line: 1388 | Upvalues: GlobalFunctions (ref), MainFrame2 (copy), LocalEvent (ref), v (ref), Sounds (ref) ]]
									GlobalFunctions.Tween(MainFrame2, {
										Position = UDim2.fromScale(0, -0.05)
									}, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
									LocalEvent:FireClient(v, "PlaySound", { Sounds.UiHover, workspace })
								end)
								v11.MouseLeave:Connect(function() --[[ Line: 1393 | Upvalues: GlobalFunctions (ref), MainFrame2 (copy) ]]
									GlobalFunctions.Tween(MainFrame2, {
										Position = UDim2.fromScale(0, 0)
									}, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
								end)

								if v4 == false then
									GlobalFunctions.Wait(0.2 / v13)
								end

								LocalEvent:FireClient(v, "PlaySound", { Sounds.CardAppearReload, workspace })

								if v4 == false then
									GlobalFunctions.Wait(0.2 / v13)
								else
									continue
								end
							end
						end
					end
				end

				ShowCards(false)

				local v8 = true

				LocalEvent:FireClient(v, "Upgrading", { UpgradeGui })
				UpgradeGui.TimeLeftLabel.Visible = true

				if v.EquippedItems:FindFirstChild("Rollback") and v:GetAttribute("HasRerolled") ~= true then
					UpgradeGui.RerollButton.Visible = true
					v6 = UpgradeGui.RerollButton.MouseButton1Click:Once(function() --[[ Line: 1415 | Upvalues: v5 (ref), v (ref), UpgradeGui (copy), v6 (ref), MainFrame (copy), LocalEvent (ref), Sounds (ref), v8 (ref), t (copy), ShowCards (copy) ]]
						if v5 ~= true then
							return
						end

						v5 = false
						v:SetAttribute("HasRerolled", true)
						UpgradeGui.RerollButton.Visible = false
						v6:Disconnect()

						for k, v2 in pairs(MainFrame:GetChildren()) do
							if string.find(v2.Name, "Card") and v2.Name ~= "SampleCard" then
								v2:Destroy()
							end
						end

						LocalEvent:FireClient(v, "PlaySound", { Sounds.GETOUT, workspace })
						v8 = false
						table.clear(t)
						ShowCards(true)
						v8 = true
					end)
				end

				for i = 20, 0, -1 do
					if v2 == false then
						if i <= 5 then
							UpgradeGui.RerollButton.Visible = false

							if v6 then
								v6:Disconnect()
							end
						end

						UpgradeGui.TimeLeftLabel.Text = "time left: " .. i
						task.wait(1)
					end
				end

				UpgradeGui.TimeLeftLabel.Visible = false
				UpgradeGui.RerollButton.Visible = false

				if v6 then
					v6:Disconnect()
				end

				if v2 == false then
					v:SetAttribute("Upgrading", false)

					for k, v10 in pairs(MainFrame:GetChildren()) do
						if string.find(v10.Name, "Card") and v10.Name ~= "SampleCard" then
							v10:Destroy()
						end
					end

					v1 = v1 + 1
					LocalEvent:FireClient(v, "PlaySound", { Sounds.Huh, workspace })
				end

				v7:Disconnect()
			end)
		end
	end

	repeat
		task.wait(0.1)

		local count = 0

		for k, v in pairs(Players:GetChildren()) do
			if v:GetAttribute("Dead") == false then
				count = count + 1
			end
		end
	until count <= v1

	for k, v in pairs(PlayerFolder:GetChildren()) do
		if v:FindFirstChild("Forcefield") then
			v.Forcefield:Destroy()
		end
	end

	if ReplicatedStorage.Gamemode.Value == "infinite" then
		return
	end

	GlobalFunctions.UpdateSong(0, 1, 0.5)
end

local function ChooseChaos() --[[ ChooseChaos | Line: 1494 | Upvalues: v7 (ref) ]]
	if math.random(1, 50) == 1 then
		return require(script.EverythingModule.Everything)
	end

	local t = {}

	for v1, v2 in script.ChaosWaves:GetChildren() do
		if v7 ~= v2 then
			table.insert(t, v2)
		end
	end

	local v3 = require(t[math.random(1, #t)])

	v7 = v3

	return v3
end

local function DomainExpansion_Infinity_MapChange(p1) --[[ DomainExpansion_Infinity_MapChange | Line: 1519 | Upvalues: GlobalFunctions (copy), v10 (copy) ]]
	local v1 = p1:Clone()
	local Sky = v1.Sky
	local Map, v2, v3, v4

	if not workspace.CurrentMap:FindFirstChild("Map") then
		task.spawn(function() --[[ Line: 1531 | Upvalues: GlobalFunctions (ref), Sky (copy) ]]
			for i = 1, 100 do
				workspace:SetAttribute("SkyTurnSpeed", workspace:GetAttribute("SkyTurnSpeed") + 10)
				task.wait(0.01)
			end

			GlobalFunctions.NewSky(Sky)

			for j = 1, 200 do
				workspace:SetAttribute("SkyTurnSpeed", workspace:GetAttribute("SkyTurnSpeed") - 5)
				task.wait(0.01)
			end
		end)
		Map = Instance.new("Model")
		Map.Name = "Map"
		Map.Parent = workspace.CurrentMap
		v2 = {}
		v3 = function(p13) --[[ PutIntoPlace | Line: 1557 | Upvalues: v2 (copy), GlobalFunctions (ref), v10 (ref) ]]
			if p13:IsA("UnionOperation") then
				if table.find(v2, p13) then
					return
				end

				table.insert(v2, p13)

				local v22 = p13:GetPivot()

				if p13.Size.Magnitude > 500 then
					local v3 = p13.CFrame
					local v4 = GlobalFunctions.GetWorldSize(p13)
					local v5 = v10:NextNumber(3, 5)

					p13.Position = p13.Position - Vector3.new(0, v4.Y / 1.5, 0)
					p13.Orientation = p13.Orientation + Vector3.new(0, math.random(-5, 5), math.random(-5, 5))
					GlobalFunctions.Tween(p13, {
						CFrame = v3
					}, TweenInfo.new(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut))
					task.wait(v5)
				else
					local v11 = v22 + Vector3.new(v10:NextNumber(-5, 5), v10:NextNumber(-5, 5), v10:NextNumber(-5, 5))
					local v13 = v11 * CFrame.Angles(0, math.rad((v10:NextNumber(-50, 50))), 0)

					p13:PivotTo(v13)

					for i = 1, 10 do
						p13:PivotTo(v13:Lerp(v22, i / 10))
						task.wait(v10:NextNumber(0.1, 0.3))
					end
				end

				table.remove(v2, table.find(v2, p13))
			else
				local v17 = Vector3.new(v10:NextNumber(-5, 5), v10:NextNumber(-5, 5), v10:NextNumber(-5, 5))
				local OffsetMesh = Instance.new("BlockMesh")

				OffsetMesh.Name = "OffsetMesh"
				OffsetMesh.Offset = v17
				OffsetMesh.Parent = p13

				for j = 1, 10 do
					OffsetMesh.Offset = OffsetMesh.Offset:Lerp(Vector3.new(0, 0, 0), j / 10)
					task.wait(v10:NextNumber(0.2, 0.4))
				end

				OffsetMesh:Destroy()
			end
		end
		v4 = function(p13, p23) --[[ Recurse | Line: 1612 | Upvalues: GlobalFunctions (ref), v3 (copy), v4 (copy) ]]
			for v1, v2 in p13:GetChildren() do
				if v2:IsA("BasePart") then
					task.spawn(function() --[[ Line: 1615 | Upvalues: v2 (copy), GlobalFunctions (ref), v3 (ref), p23 (copy) ]]
						if v2.Size.Magnitude > 100 and (not v2:IsA("UnionOperation") and (v2.Transparency < 1 and v2.Name ~= "OuterLand")) then
							local v1 = if v2.Size.Magnitude > 2000 then 500 else 8
							local v22 = GlobalFunctions.GetWorldSize(v2)
							local v32 = v22.X / v1
							local v4 = math.round(v32)
							local v5 = v22.Z / v1
							local v6 = math.round(v5)
							local v7 = v2.Position.X - v22.X / 2 - v1 / 2
							local v8 = v2.Position.Z - v22.Z / 2 - v1 / 2
							local Model = Instance.new("Model", workspace)
							local t2 = {}
							local v9 = 0

							for i = 1, v4 do
								local v10 = v7 + i * v1

								for j = 1, v6 do
									task.spawn(function() --[[ Line: 1644 | Upvalues: v9 (ref), v8 (copy), j (copy), v1 (ref), v2 (ref), v10 (copy), Model (copy), t2 (copy), GlobalFunctions (ref), v3 (ref) ]]
										v9 = v9 + 1

										local v22 = v2:Clone()

										v22.Anchored = true
										v22.CanCollide = false
										v22.CanTouch = false
										v22.CanQuery = false
										v22.Position = Vector3.new(v10, v2.Position.Y, v8 + j * v1)
										v22.Size = Vector3.new(v1, v2.Size.Y, v1)

										local BlockMesh = v22:FindFirstChildOfClass("BlockMesh")
										local v6

										if BlockMesh then
											v6 = BlockMesh.Scale
											BlockMesh.Scale = Vector3.new(1, 1, 1)
										else
											v6 = nil
										end

										v22.Parent = Model
										table.insert(t2, v22)

										if not BlockMesh then
											v3(v22)
											v9 = v9 - 1

											return
										end

										GlobalFunctions.Tween(BlockMesh, {
											Scale = Vector3.new(v6.X * (v2.Size.X / v1), v6.Y, v6.Z * (v2.Size.Z / v1))
										}, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
										v3(v22)
										v9 = v9 - 1
									end)
								end

								task.wait(0.02)
							end

							repeat
								task.wait()
							until v9 == 0

							os.clock()
							Model:Destroy()
							v2.Parent = p23
						else
							if v2.Name ~= "OuterLand" then
								v2.Parent = p23
								v3(v2)

								return
							end

							local BlockMesh = v2:FindFirstChildOfClass("BlockMesh")

							if BlockMesh then
								local Scale = BlockMesh.Scale

								BlockMesh.Scale = Vector3.new(0, 1, 0)
								task.spawn(function() --[[ Line: 1726 | Upvalues: GlobalFunctions (ref), BlockMesh (copy), Scale (ref) ]]
									task.wait(1)
									GlobalFunctions.Tween(BlockMesh, {
										Scale = Scale
									}, TweenInfo.new(8, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut))
								end)
							end

							v2.Parent = p23
						end
					end)

					continue
				end

				if v2:IsA("Model") then
					local Model = Instance.new("Model")

					Model.Name = v2.Name
					Model.Parent = p23
					v4(v2, Model)

					continue
				end

				if v2:IsA("Folder") then
					local v32 = Instance.new("Folder")

					v32.Name = v2.Name
					v32.Parent = p23
					v4(v2, v32)

					continue
				end

				v2.Parent = p23
			end
		end
		v4(v1, Map)

		return
	end

	workspace.CurrentMap.Map:Destroy()
	task.spawn(function() --[[ Line: 1531 | Upvalues: GlobalFunctions (ref), Sky (copy) ]]
		for i = 1, 100 do
			workspace:SetAttribute("SkyTurnSpeed", workspace:GetAttribute("SkyTurnSpeed") + 10)
			task.wait(0.01)
		end

		GlobalFunctions.NewSky(Sky)

		for j = 1, 200 do
			workspace:SetAttribute("SkyTurnSpeed", workspace:GetAttribute("SkyTurnSpeed") - 5)
			task.wait(0.01)
		end
	end)
	Map = Instance.new("Model")
	Map.Name = "Map"
	Map.Parent = workspace.CurrentMap
	v2 = {}
	v3 = function(p13) --[[ PutIntoPlace | Line: 1557 | Upvalues: v2 (copy), GlobalFunctions (ref), v10 (ref) ]]
		if p13:IsA("UnionOperation") then
			if table.find(v2, p13) then
				return
			end

			table.insert(v2, p13)

			local v22 = p13:GetPivot()

			if p13.Size.Magnitude > 500 then
				local v3 = p13.CFrame
				local v4 = GlobalFunctions.GetWorldSize(p13)
				local v5 = v10:NextNumber(3, 5)

				p13.Position = p13.Position - Vector3.new(0, v4.Y / 1.5, 0)
				p13.Orientation = p13.Orientation + Vector3.new(0, math.random(-5, 5), math.random(-5, 5))
				GlobalFunctions.Tween(p13, {
					CFrame = v3
				}, TweenInfo.new(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut))
				task.wait(v5)
			else
				local v11 = v22 + Vector3.new(v10:NextNumber(-5, 5), v10:NextNumber(-5, 5), v10:NextNumber(-5, 5))
				local v13 = v11 * CFrame.Angles(0, math.rad((v10:NextNumber(-50, 50))), 0)

				p13:PivotTo(v13)

				for i = 1, 10 do
					p13:PivotTo(v13:Lerp(v22, i / 10))
					task.wait(v10:NextNumber(0.1, 0.3))
				end
			end

			table.remove(v2, table.find(v2, p13))
		else
			local v17 = Vector3.new(v10:NextNumber(-5, 5), v10:NextNumber(-5, 5), v10:NextNumber(-5, 5))
			local OffsetMesh = Instance.new("BlockMesh")

			OffsetMesh.Name = "OffsetMesh"
			OffsetMesh.Offset = v17
			OffsetMesh.Parent = p13

			for j = 1, 10 do
				OffsetMesh.Offset = OffsetMesh.Offset:Lerp(Vector3.new(0, 0, 0), j / 10)
				task.wait(v10:NextNumber(0.2, 0.4))
			end

			OffsetMesh:Destroy()
		end
	end
	v4 = function(p13, p23) --[[ Recurse | Line: 1612 | Upvalues: GlobalFunctions (ref), v3 (copy), v4 (copy) ]]
		for v1, v2 in p13:GetChildren() do
			if v2:IsA("BasePart") then
				task.spawn(function() --[[ Line: 1615 | Upvalues: v2 (copy), GlobalFunctions (ref), v3 (ref), p23 (copy) ]]
					if v2.Size.Magnitude > 100 and (not v2:IsA("UnionOperation") and (v2.Transparency < 1 and v2.Name ~= "OuterLand")) then
						local v1 = if v2.Size.Magnitude > 2000 then 500 else 8
						local v22 = GlobalFunctions.GetWorldSize(v2)
						local v32 = v22.X / v1
						local v4 = math.round(v32)
						local v5 = v22.Z / v1
						local v6 = math.round(v5)
						local v7 = v2.Position.X - v22.X / 2 - v1 / 2
						local v8 = v2.Position.Z - v22.Z / 2 - v1 / 2
						local Model = Instance.new("Model", workspace)
						local t2 = {}
						local v9 = 0

						for i = 1, v4 do
							local v10 = v7 + i * v1

							for j = 1, v6 do
								task.spawn(function() --[[ Line: 1644 | Upvalues: v9 (ref), v8 (copy), j (copy), v1 (ref), v2 (ref), v10 (copy), Model (copy), t2 (copy), GlobalFunctions (ref), v3 (ref) ]]
									v9 = v9 + 1

									local v22 = v2:Clone()

									v22.Anchored = true
									v22.CanCollide = false
									v22.CanTouch = false
									v22.CanQuery = false
									v22.Position = Vector3.new(v10, v2.Position.Y, v8 + j * v1)
									v22.Size = Vector3.new(v1, v2.Size.Y, v1)

									local BlockMesh = v22:FindFirstChildOfClass("BlockMesh")
									local v6

									if BlockMesh then
										v6 = BlockMesh.Scale
										BlockMesh.Scale = Vector3.new(1, 1, 1)
									else
										v6 = nil
									end

									v22.Parent = Model
									table.insert(t2, v22)

									if not BlockMesh then
										v3(v22)
										v9 = v9 - 1

										return
									end

									GlobalFunctions.Tween(BlockMesh, {
										Scale = Vector3.new(v6.X * (v2.Size.X / v1), v6.Y, v6.Z * (v2.Size.Z / v1))
									}, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
									v3(v22)
									v9 = v9 - 1
								end)
							end

							task.wait(0.02)
						end

						repeat
							task.wait()
						until v9 == 0

						os.clock()
						Model:Destroy()
						v2.Parent = p23
					else
						if v2.Name ~= "OuterLand" then
							v2.Parent = p23
							v3(v2)

							return
						end

						local BlockMesh = v2:FindFirstChildOfClass("BlockMesh")

						if BlockMesh then
							local Scale = BlockMesh.Scale

							BlockMesh.Scale = Vector3.new(0, 1, 0)
							task.spawn(function() --[[ Line: 1726 | Upvalues: GlobalFunctions (ref), BlockMesh (copy), Scale (ref) ]]
								task.wait(1)
								GlobalFunctions.Tween(BlockMesh, {
									Scale = Scale
								}, TweenInfo.new(8, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut))
							end)
						end

						v2.Parent = p23
					end
				end)

				continue
			end

			if v2:IsA("Model") then
				local Model = Instance.new("Model")

				Model.Name = v2.Name
				Model.Parent = p23
				v4(v2, Model)

				continue
			end

			if v2:IsA("Folder") then
				local v32 = Instance.new("Folder")

				v32.Name = v2.Name
				v32.Parent = p23
				v4(v2, v32)

				continue
			end

			v2.Parent = p23
		end
	end
	v4(v1, Map)
end

local function CampaignDeath() --[[ CampaignDeath | Line: 1766 | Upvalues: Players (copy), GlobalFunctions (copy) ]]
	for v1, v2 in Players:GetPlayers() do
		task.spawn(function() --[[ Line: 1768 | Upvalues: v2 (copy) ]]
			v2:SetAttribute("NextLifeRequirement", 999999999)
			v2:SetAttribute("CanAttack", false)
			v2:SetAttribute("CanDash", false)
			v2:SetAttribute("CanTaunt", false)
		end)
	end

	task.wait(5)

	for v3, v4 in Players:GetPlayers() do
		task.spawn(function() --[[ Line: 1778 | Upvalues: v4 (copy), GlobalFunctions (ref) ]]
			if v4:GetAttribute("Dead") ~= false then
				return
			end

			local Character = v4.Character

			if v4:GetAttribute("Lives") > 1 then
				local v1 = v4:GetAttribute("Lives") - 1

				v4:SetAttribute("Lives", 1)
				GlobalFunctions.ScoreLabels(v4)
				v4:SetAttribute("StreakMultiplier", 1)
				GlobalFunctions.AddStreak(v4, 5000 * v1, v1 .. (if v1 == 1 then " extra life bonus" else " extra lives bonus"))
				task.wait(3)
			end

			local v3 = time()

			repeat
				if v4.Character then
					GlobalFunctions.DamagePlayer(nil, v4.Character, 6, false, true)
				end

				task.wait(0.2)
			until Character.Humanoid.Health == 0 or v3 + 5 < time()

			if not (Character.Humanoid.Health > 0) then
				return
			end

			Character.Humanoid.Health = 0
		end)
	end
end

function t2.BEGIN() --[[ Line: 1838 | Upvalues: RunService (copy), ReplicatedStorage (copy), v2 (ref), CurrentStage (copy), Stages (copy), GlobalFunctions (copy), NewStage (copy), Songs (copy), CampaignDeath (copy), ModifiersActive (copy), NewWave (copy), LocalEvent (copy), CurrentMap (copy), Players (copy), PlayerFolder (copy), StageTimeFinish (copy), PlayerUpgrades (copy) ]]
	RunService.Heartbeat:Connect(function(p1) --[[ Line: 1852 | Upvalues: ReplicatedStorage (ref) ]]
		if ReplicatedStorage.TrackStageTime.Value ~= true or workspace:GetAttribute("Hitstopped") ~= false then
			return
		end

		local StageTime = ReplicatedStorage.StageTime

		StageTime.Value = StageTime.Value + p1
	end)

	if ReplicatedStorage.Difficulty.Value == "Easy" then
		v2 = v2 / 2
	end

	while true do
		while true do
			if CurrentStage.Value:FindFirstChild("CustomCode") then
				require(CurrentStage.Value.CustomCode).Run()
			end

			if CurrentStage.Value.Parent ~= Stages.MiniStages then
				break
			end

			task.wait()
			GlobalFunctions.WaitUntilAllAlive()
			NewStage()
		end

		if CurrentStage.Value ~= Stages.CampaignDeathZone then
			GlobalFunctions.NewSong(Songs[CurrentStage.Value.Name .. "Default"])
			ReplicatedStorage.EventsAllowed.Value = true

			if CurrentStage.Value ~= Stages.Grasslands then
				GlobalFunctions.SummonGuiseShip()
			end
		end

		if CurrentStage.Value == Stages.CampaignDeathZone then
			CampaignDeath()

			return
		end

		if ModifiersActive:FindFirstChild("sic \'em 1x1x1x1!") then
			GlobalFunctions.Unleash1x()
		end

		ReplicatedStorage.StageTime.Value = 0
		ReplicatedStorage.TrackStageTime.Value = true
		ReplicatedStorage.StageOver.Value = false

		for i = 1, 10 do
			if GlobalFunctions.GetPlayersStillAlive() > 0 then
				NewWave()
			end
		end

		if GlobalFunctions.GetPlayersStillAlive() == 0 or not workspace:FindFirstChild("EnemyFolder") then
			return
		end

		ReplicatedStorage.StageOver.Value = true
		ReplicatedStorage.TrackStageTime.Value = false
		ReplicatedStorage.EventsAllowed.Value = false

		if ReplicatedStorage.HellModeActive.Value == true then
			ReplicatedStorage.HellModeActive.Value = false
			LocalEvent:FireAllClients("HellMode", { false })
			GlobalFunctions.NewSky(CurrentMap.Map.Sky)
		end

		for k, v in pairs(Players:GetPlayers()) do
			if ModifiersActive:FindFirstChild("unstable fate") then
				v:SetAttribute("UnstableChance", 10000)
			end
		end

		for k, v in pairs(PlayerFolder:GetChildren()) do
			if v.Name == "Mech" then
				v.Humanoid.Health = 0
			end
		end

		GlobalFunctions.Detain1x()
		task.wait(2)

		if CurrentStage.Value ~= Stages.Infinity then
			for k, v in pairs(Players:GetPlayers()) do
				GlobalFunctions.StageBeat(v)
			end

			StageTimeFinish()
		end

		GlobalFunctions.WaitUntilNoEnemies()
		GlobalFunctions.WaitUntilAllAlive()

		if #Stages.MiddleStages:GetChildren() > 1 then
			PlayerUpgrades()
		end

		task.wait(3)
		GlobalFunctions.WaitUntilAllAlive()
		NewStage()
	end
end

local function ActivateDebrisRing() --[[ ActivateDebrisRing | Line: 2059 | Upvalues: v10 (copy), Resources (copy), RunService (copy) ]]
	local t = {}

	for i = 1, 100 do
		local v1 = v10:NextNumber(0, 9999)
		local v2 = v10:NextInteger(0, 40)
		local v3 = v10:NextNumber(0.8, 1.2)
		local t2 = {}

		for v4, v5 in Resources.RingDebris:GetChildren() do
			if v5:GetAttribute("Count") and t[v5] then
				if v5:GetAttribute("Count") < t[v5] then
					table.insert(t2, v5)
				end

				continue
			end

			table.insert(t2, v5)
		end

		local v6 = t2[math.random(1, #t2)]
		local v7 = v6:Clone()

		v7.Parent = workspace

		if t[v6] then
			t[v6] = t[v6] + 1
		else
			t[v6] = 1
		end

		local v8 = v1
		local v9 = CFrame.Angles(0, 0, 0)

		RunService.Heartbeat:Connect(function(p1) --[[ Line: 2092 | Upvalues: v8 (ref), v3 (copy), v9 (ref), v1 (copy), v7 (copy), v2 (copy) ]]
			v8 = v8 + p1 * v3
			v9 = v9 * CFrame.Angles(p1 * v3, p1 * v3, p1 * v3)

			local v12 = math.noise(1, v8 / 2, v1) * 20

			v7:PivotTo(CFrame.new(math.cos(v8 / 2) * (400 + v2), 50 + v12, math.sin(v8 / 2) * (400 + v2)) * v9)
		end)
	end
end

function t2.INFINITE() --[[ Line: 2109 | Upvalues: RunService (copy), ReplicatedStorage (copy), CurrentStage (copy), Stages (copy), Enemies (copy), PlayerFolder (copy), GlobalFunctions (copy), v10 (copy), Sounds (copy), Debris (copy), v5 (ref), CurrentMap (copy), InfinityMix (copy), ModifiersActive (copy), Players (copy), TaskModule (copy), ChooseChaos (copy), v3 (ref), NewWave (copy), BetsModule (copy), StageTimeFinish (copy), PlayerUpgrades (copy), BetEvent (copy), ServerStorage (copy), LocalEvent (copy), EffectsFolder (copy), DomainExpansion_Infinity_MapChange (copy) ]]
	RunService.Heartbeat:Connect(function(p1) --[[ Line: 2113 | Upvalues: ReplicatedStorage (ref) ]]
		if ReplicatedStorage.TrackStageTime.Value ~= true or workspace:GetAttribute("Hitstopped") ~= false then
			return
		end

		local StageTime = ReplicatedStorage.StageTime

		StageTime.Value = StageTime.Value + p1
	end)
	CurrentStage.Value = Stages.Infinity

	local t = {}

	setmetatable(t, {
		__mode = "k"
	})

	local t2 = {}
	local v1 = 0
	local count = 0
	local t3 = {}
	local v2 = nil

	for v32, v4 in Enemies:GetChildren() do
		if v4:IsA("Folder") then
			for v52, v6 in v4:GetChildren() do
				local v7 = v6:GetAttribute("WaveAppearance")

				if v7 > 1 and math.random(1, 2) == 1 then
					v6:SetAttribute("WaveAppearance", v7 * 2)
				end
			end
		end
	end

	if math.random(1, 2) == 1 and not RunService:IsStudio() then
		task.wait(1)

		local Arch = workspace.CurrentMap.Map.Arch
		local v8 = RaycastParams.new()

		v8.FilterType = Enum.RaycastFilterType.Exclude
		v8.FilterDescendantsInstances = { Arch, PlayerFolder }

		local v9 = GlobalFunctions.GetRandomPlayer()

		for v102, v11 in Arch:GetChildren() do
			task.spawn(function() --[[ Line: 2186 | Upvalues: v11 (copy), v10 (ref), GlobalFunctions (ref), RunService (ref), v9 (copy), Sounds (ref), v8 (copy), Debris (ref) ]]
				v11.CanCollide = false

				local Vector3Value = Instance.new("Vector3Value")

				Vector3Value.Value = v11.Position

				local Position = v11.Position

				GlobalFunctions.Tween(Vector3Value, {
					Value = Position + Vector3.new(v10:NextNumber(-2, 2), v10:NextNumber(0, 2), v10:NextNumber(-2, 2))
				}, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), true)

				local v5 = RunService.Heartbeat:Connect(function() --[[ Line: 2196 | Upvalues: v11 (ref), Vector3Value (copy), v9 (ref) ]]
					v11.CFrame = CFrame.lookAt(Vector3Value.Value, v9.PrimaryPart.Position)
				end)

				GlobalFunctions.Tween(v11, {
					Size = Vector3.new(2, 2, 2)
				}, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), true)
				GlobalFunctions.AttackHighlight(v11, 1.2)
				GlobalFunctions.PlaySound(Sounds.ArchPieceActivate, v11, 1, false)
				task.wait(0.6)
				v5:Disconnect()
				task.wait(0.6)

				local LookVector = CFrame.lookAt(v11.Position, v9.PrimaryPart.Position).LookVector
				local v6 = workspace:Raycast(v11.Position, LookVector * 1000, v8)
				local v7 = if v6 then v6.Distance else 1000
				local v82 = CFrame.lookAt(v11.Position, v9.PrimaryPart.Position) + LookVector * (v7 / 2)
				local v92 = Vector3.new(2, 2, v7 + 2)

				v11.CFrame = v82
				v11.Size = v92
				GlobalFunctions.Tween(v11, {
					Size = Vector3.new(0, 0, v7)
				}, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), true)
				Debris:AddItem(v11, 0.3)
				GlobalFunctions.PlaySound(Sounds.ArchPieceActivate, v11, 1.5, false)

				local t = {}

				for v102, v112 in workspace:GetPartBoundsInBox(v82, v92) do
					if GlobalFunctions.IsTargetValid(v112.Parent) and (not table.find(t, v112.Parent) and v112.Parent:GetAttribute("Dashing") == false) then
						table.insert(t, v112.Parent)
						GlobalFunctions.DamagePlayer(nil, v112.Parent, 10, true)
					end
				end
			end)
			task.wait(0.05)
		end

		task.wait(2)
	end

	while true do
		v5 = 1

		for v12, v13 in CurrentMap.Map:GetChildren() do
			if v13:IsA("Script") then
				v13.Enabled = true
				v13:SetAttribute("GoodToGo", true)
			end
		end

		local v14 = if CurrentMap.Map:FindFirstChild("CustomCode") then require(CurrentMap.Map.CustomCode) else nil

		if #t2 >= #InfinityMix:GetChildren() then
			table.clear(t2)
		end

		local t4 = {}

		for v15, v16 in InfinityMix:GetChildren() do
			if not table.find(t2, v16.SoundId) and v1 ~= v16.SoundId then
				table.insert(t4, v16)
			end
		end

		local v17 = t4[math.random(1, #t4)]

		table.insert(t2, v17.SoundId)
		v1 = v17.SoundId
		GlobalFunctions.NewSong(v17, true)
		ReplicatedStorage.EventsAllowed.Value = true

		if ModifiersActive:FindFirstChild("sic \'em 1x1x1x1!") then
			GlobalFunctions.Unleash1x()
		end

		ReplicatedStorage.StageTime.Value = 0
		ReplicatedStorage.TrackStageTime.Value = true
		ReplicatedStorage.StageOver.Value = false

		local count2 = 0

		for i = 1, 10 do
			if GlobalFunctions.GetPlayersStillAlive() == 0 then
				return
			end

			count2 = count2 + 1

			if v14 and table.find(v14.FunctionWaves, count2) then
				v14.WaveFunc(count2)
			end

			task.spawn(function() --[[ Line: 2364 | Upvalues: Players (ref), TaskModule (ref) ]]
				task.wait(0.1)

				for k, v in pairs(Players:GetPlayers()) do
					if v:GetAttribute("Dead") ~= true then
						local v1 = TaskModule.GetTask(v)
						local TasksFrame = v.PlayerGui.GlobalMultGui.TasksFrame

						for k2, v5 in pairs(TasksFrame:GetChildren()) do
							if v5:IsA("Frame") and v5 ~= TasksFrame.SampleTask then
								v5:Destroy()
							end
						end

						local v5 = TasksFrame.SampleTask:Clone()

						v5.Title.Text = v1[1]
						v5.Reward.Text = v1[2] .. "x"
						v5.Visible = true
						v5.Parent = TasksFrame
						TaskModule[v1[3]](v)
					end
				end
			end)

			local v18 = ChooseChaos()
			local v19 = v18.GetInfo()
			local v20 = false

			task.spawn(function() --[[ Line: 2400 | Upvalues: Players (ref), RunService (ref), v19 (copy), v20 (ref), v18 (copy) ]]
				for v1, v2 in Players:GetPlayers() do
					task.spawn(function() --[[ Line: 2402 | Upvalues: v2 (copy), RunService (ref), v19 (ref) ]]
						local ChaosWave = v2.PlayerGui.MainGui.ChaosWave

						ChaosWave.Visible = true

						local v1 = RunService.Heartbeat:Connect(function() --[[ Line: 2409 | Upvalues: ChaosWave (copy) ]]
							ChaosWave.Text = math.random(1, 99999999)
						end)

						task.wait(1)
						v1:Disconnect()
						ChaosWave.Text = v19.Name
						task.wait(2)
						ChaosWave.Visible = false
					end)
				end

				task.wait(1)
				v20 = true
				v18.Start()
			end)

			local t5 = {}
			local v21 = CurrentStage.Value.SpecialWaves:FindFirstChild("Wave" .. v3)

			if v21 and v21.Type.Value == "Boss" then
				count = count + 1

				for v22, v23 in Players:GetPlayers() do
					local Health = v23.Character.Humanoid.Health
					local v24 = nil

					v24 = RunService.Heartbeat:Connect(function() --[[ Line: 2438 | Upvalues: v24 (ref), v23 (copy), Health (ref), t5 (copy) ]]
						if v24 == nil then
							return
						end

						if v23.Character == nil then
							return
						end

						if Health < v23.Character.Humanoid.Health then
							Health = v23.Character.Humanoid.Health
						end

						if not (v23.Character.Humanoid.Health < Health) then
							return
						end

						t5[v23].TookDamage = true
						v24:Disconnect()
					end)
					t5[v23] = {}
					t5[v23].Connection = v24
					t5[v23].TookDamage = false
					t5[v23].StartingDamageDealt = v23:GetAttribute("DamageDealt")
				end
			end

			NewWave()

			if v20 == true then
				v18.End()
			end

			if v21 and v21.Type.Value == "Boss" then
				task.wait(0.1)

				local v25 = #Players:GetPlayers()
				local count3 = 0
				local sum = 0

				for v26, v27 in t5 do
					if v27.TookDamage == false then
						count3 = count3 + 1
					end

					sum = sum + (v26:GetAttribute("DamageDealt") - v27.StartingDamageDealt)
				end

				for v29, v30 in t5 do
					local v28

					if v29.Parent ~= nil then
						v30.Connection:Disconnect()

						local v31 = v29:GetAttribute("DamageDealt") - v30.StartingDamageDealt
						local v32 = v31 / sum * 100

						print(v29.DisplayName .. " did " .. v32 .. "% of the damage")
						print("total damage they dealt: " .. v31)

						if v30.TookDamage == false and 50 / v25 < v32 then
							v28 = if count3 == 1 and v25 == 1 then "you no-hit the boss!" elseif count3 == 1 and v25 > 1 then v29.DisplayName .. " no-hit the boss (and did all the work)" else v29.DisplayName .. " contributed without taking damage"
							GlobalFunctions.AddGlobalMultiplier(0.3, v28)
							task.wait(0.1)
						end
					end
				end

				table.clear(t5)
			end

			local v33 = #Players:GetPlayers()

			for v34, v35 in t do
				if v34.Parent then
					v35.WavesActive = v35.WavesActive - 1

					if v34:GetAttribute("Dead") == false then
						local v36 = if v35.WavesActive > 0 then if v33 == 1 then "for partial challenge completion" else v34.DisplayName .. " partial challenge completion" elseif v33 == 1 then "for a challenge fully completed" else v34.DisplayName .. " full challenge completion"
						local GlobalScoreMultiplier = ReplicatedStorage.GlobalScoreMultiplier.Value

						GlobalFunctions.AddGlobalMultiplier(v35.Reward + (GlobalScoreMultiplier * (1 + v35.Reward / 2) - GlobalScoreMultiplier), v36)
					end

					if v35.WavesActive <= 0 then
						BetsModule[v35.FunctionName .. "End"](v34)
						t[v34] = nil
					end
				end
			end
		end

		if GlobalFunctions.GetPlayersStillAlive() == 0 or not workspace:FindFirstChild("EnemyFolder") then
			break
		end

		ReplicatedStorage.StageOver.Value = true
		ReplicatedStorage.TrackStageTime.Value = false
		ReplicatedStorage.EventsAllowed.Value = false

		for k, v in pairs(Players:GetPlayers()) do
			if ModifiersActive:FindFirstChild("unstable fate") then
				v:SetAttribute("UnstableChance", 10000)
			end
		end

		for k, v in pairs(PlayerFolder:GetChildren()) do
			if v.Name == "Mech" then
				v.Humanoid.Health = 0
			end
		end

		GlobalFunctions.Detain1x()
		task.wait(2)

		if CurrentStage.Value ~= Stages.Infinity then
			for k, v in pairs(Players:GetPlayers()) do
				GlobalFunctions.StageBeat(v)
			end

			StageTimeFinish()
		end

		if count == 3 then
			for v38, v39 in CurrentStage.Value.SpecialWaves:GetChildren() do
				v39.Name = "Wave" .. tonumber(string.split(v39.Name, "Wave")[2]) + count * 10
			end

			count = 0
		end

		GlobalFunctions.WaitUntilNoEnemies()
		GlobalFunctions.WaitUntilAllAlive()
		PlayerUpgrades()
		task.wait(0.5)
		GlobalFunctions.WaitUntilAllAlive()

		for k, v in pairs(Players:GetPlayers()) do
			GlobalFunctions.RevivePlayer(v)
		end

		task.wait(0.5)

		for v41, v42 in t do
			if v41.Parent then
				BetsModule[v42 .. "End"](v41)
			end
		end

		table.clear(t)

		local v43 = BetsModule.GetBet()
		local _ = v43[1]
		local v44 = v43[2]
		local v45 = v43[3]
		local v46 = v43[4]

		BetEvent:FireAllClients(v43)

		local v47 = 0
		local t5 = {}
		local v49 = BetEvent.OnServerEvent:Connect(function(p1, p2, p3) --[[ Line: 2635 | Upvalues: t5 (copy), v45 (copy), t (copy), v46 (copy), Players (ref), GlobalFunctions (ref), v44 (copy), ReplicatedStorage (ref), v47 (ref), BetsModule (ref) ]]
			local v1 = p3 or 10

			if type(v1) ~= "number" then
				return
			end

			if v1 ~= v1 then
				return
			end

			if v1 < 0 or v1 > 10 then
				return
			end

			if table.find(t5, p1) then
				return
			end

			table.insert(t5, p1)

			if p2 ~= true then
				return
			end

			if v45 == false then
				t[p1] = {}
				t[p1].FunctionName = v46
				t[p1].WavesActive = 10
				t[p1].Reward = 0
				GlobalFunctions.AddGlobalMultiplier(v44 * ReplicatedStorage.GlobalScoreMultiplier.Value, if #Players:GetPlayers() == 1 then "for taking the challenge" else p1.DisplayName .. " took a challenge")
			else
				t[p1] = {}
				t[p1].FunctionName = v46
				t[p1].WavesActive = v1
				t[p1].Reward = v44 / 10
			end

			v47 = v47 + 1
			BetsModule[v46 .. "Start"](p1)
			v47 = v47 - 1
		end)

		for j = 1, 400 do
			if #t5 >= #Players:GetPlayers() and v47 == 0 then
				break
			end

			task.wait(0.1)
		end

		v49:Disconnect()
		task.wait(1.3)

		local v50 = ServerStorage.InfinityMaps:GetChildren()

		if #v50 <= #t3 then
			table.clear(t3)
		end

		local t6 = {}

		for v51, v52 in v50 do
			if not table.find(t3, v52) and v2 ~= v52 then
				table.insert(t6, v52)
			end
		end

		local v53 = t6[math.random(1, #t6)]

		table.insert(t3, v53)

		local v54

		v54, v2 = {}, v53

		for v55, v56 in Players:GetPlayers() do
			table.insert(v54, v56:GetNetworkPing() / 2)
		end

		table.sort(v54, function(p1, p2) --[[ Line: 2714 ]]
			return p2 < p1
		end)

		local v58 = v54[1]

		print("highest ping: " .. v58)

		local count3 = 0

		for v59, v60 in Players:GetPlayers() do
			count3 = count3 + 1
			task.spawn(function() --[[ Line: 2725 | Upvalues: v60 (copy), v58 (copy), LocalEvent (ref), count3 (ref) ]]
				local v1 = v60:GetNetworkPing() / 2

				LocalEvent:FireClient(v60, "InfiniteStageChange", { (math.min(v58 - v1, 1)) })
				task.wait(v1)
				count3 = count3 - 1
			end)
		end

		repeat
			task.wait()
		until count3 == 0

		task.wait(v58)
		GlobalFunctions.DeleteSong()
		task.spawn(function() --[[ Line: 2753 | Upvalues: EffectsFolder (ref), GlobalFunctions (ref) ]]
			for k, v in pairs(EffectsFolder:GetDescendants()) do
				if v ~= EffectsFolder.Debris then
					if v:IsA("BasePart") then
						GlobalFunctions.SpawnBeam(v:GetPivot().Position, 3, Color3.fromRGB(248, 248, 248))
					end

					v:Destroy()
				end
			end
		end)
		task.wait(0.5)
		DomainExpansion_Infinity_MapChange(v53)
		task.wait(7)

		for v61, v62 in PlayerFolder:GetChildren() do
			task.spawn(function() --[[ Line: 2779 | Upvalues: GlobalFunctions (ref), v62 (copy) ]]
				GlobalFunctions.Tween(v62.Humanoid, {
					Health = v62.Humanoid.MaxHealth
				}, TweenInfo.new(3.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In), true)
			end)
		end

		task.wait(1)
		task.wait(0.5)
	end
end

return t2