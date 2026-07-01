local run = function(func)
	func()
end
local cloneref = cloneref or function(obj)
	return obj
end

local playersService = cloneref(game:GetService("Players"))
local replicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local runService = cloneref(game:GetService("RunService"))
local inputService = cloneref(game:GetService("UserInputService"))
local tweenService = cloneref(game:GetService("TweenService"))
local lightingService = cloneref(game:GetService("Lighting"))
local marketplaceService = cloneref(game:GetService("MarketplaceService"))
local teleportService = cloneref(game:GetService("TeleportService"))
local httpService = cloneref(game:GetService("HttpService"))
local guiService = cloneref(game:GetService("GuiService"))
local groupService = cloneref(game:GetService("GroupService"))
local textChatService = cloneref(game:GetService("TextChatService"))
local contextService = cloneref(game:GetService("ContextActionService"))
local collectionService = cloneref(game:GetService("CollectionService"))
local teamsService = cloneref(game:GetService("Teams"))
local pathfindingService = cloneref(game:GetService("PathfindingService"))
local coreGui = cloneref(game:GetService("CoreGui"))

local gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA("Camera")
local lplr = playersService.LocalPlayer
local playerGui = lplr:WaitForChild("PlayerGui")

local assetfunction = getcustomasset

local vape = shared.vape
local tween = vape.Libraries.tween
local targetinfo = vape.Libraries.targetinfo
local getfontsize = vape.Libraries.getfontsize
local getcustomasset = vape.Libraries.getcustomasset
local uipallet = vape.Libraries.uipallet
local entitylib = vape.Libraries.entity
local sessioninfo = vape.Libraries.sessioninfo
local parry = {}

local EnemyFolder = workspace:FindFirstChild("EnemyFolder")
local PlayerFolder = workspace:FindFirstChild("PlayerFolder")
local EffectsFolder = workspace:FindFirstChild("EffectsFolder")

local Remotes = replicatedStorage:FindFirstChild("Remotes")

local function notif(...)
	return vape:CreateNotification(...)
end

local function randomString()
	local array = {}
	for i = 1, math.random(10, 100) do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

entitylib.start()

run(function()
	local taggedObjects = setmetatable({}, { __mode = "k" })
	local enemyInitialized = setmetatable({}, { __mode = "k" })
	local destroyConnected = setmetatable({}, { __mode = "k" })

	local function tag(obj, tagName)
		if collectionService:HasTag(obj, tagName) then
			return
		end

		if vape.ThreadFix then
			setthreadidentity(8)
		end

		local ok = pcall(collectionService.AddTag, collectionService, obj, tagName)
		if not ok then
			return
		end

		taggedObjects[obj] = tagName

		if destroyConnected[obj] then
			return
		end

		destroyConnected[obj] = true

		obj.Destroying:Connect(function()
			taggedObjects[obj] = nil
			enemyInitialized[obj] = nil
			destroyConnected[obj] = nil
		end)
	end

	local function isValidWorldObject(obj)
		if not obj or not obj.Parent then
			return false
		end

		if not obj:IsDescendantOf(workspace) then
			return false
		end

		if lplr then
			local backpack = lplr:FindFirstChild("Backpack")
			if backpack and obj:IsDescendantOf(backpack) then
				return false
			end

			local character = entitylib.character.Character
			if character and obj:IsDescendantOf(character) and not obj:IsA("Highlight") then
				return false
			end
		end

		return true
	end

	local Whitelisted = {
		{
			tag = "Enemy",
			match = function(obj)
				return obj.Parent == EnemyFolder
			end,
		},
		{
			tag = "Mech",
			match = function(obj)
				return obj.Name == "Mech" and obj.Parent == PlayerFolder
			end,
		},
		{
			tag = "ParryHighlight",
			match = function(obj)
				return entitylib.isAlive and obj:IsA("Highlight") and obj.Name == "InvincibleHighlight" and obj.Parent == entitylib.character.Character
			end,
		},
		{
			tag = "x1Slash",
			match = function(obj)
				return obj.Name == "x1SlashWarning" and obj.Parent == EffectsFolder
			end,
		},
	}

	local function tagObject(obj)
		if not isValidWorldObject(obj) then
			return
		end

		for _, whitelist in ipairs(Whitelisted) do
			if whitelist.match(obj) then
				tag(obj, whitelist.tag)
				return
			end
		end
	end

	local TagBehaviors = {}

	function TagBehaviors.Enemy(obj)
		if enemyInitialized[obj] then
			return
		end

		enemyInitialized[obj] = true

		vape:Clean(obj:GetAttributeChangedSignal("Alive"):Connect(function()
			if not obj:GetAttribute("Alive") then
				collectionService:RemoveTag(obj, "Enemy")
			end
		end))

		vape:Clean(obj.AncestryChanged:Connect(function()
			if obj.Parent ~= EnemyFolder then
				collectionService:RemoveTag(obj, "Enemy")
			end
		end))

		if obj.Name == "CYBORGUS" then
			vape:Clean(obj:GetAttributeChangedSignal("FinaleActive"):Connect(function()
				if obj:GetAttribute("FinaleActive") then
					collectionService:RemoveTag(obj, "Enemy")
				end
			end))
		end
	end

	for _, obj in ipairs(workspace:GetDescendants()) do
		tagObject(obj)
	end

	vape:Clean(workspace.DescendantAdded:Connect(tagObject))

	for tagName, behavior in pairs(TagBehaviors) do
		vape:Clean(collectionService:GetInstanceAddedSignal(tagName):Connect(behavior))
	end

	vape:Clean(function()
		for obj, tagName in pairs(taggedObjects) do
			pcall(collectionService.RemoveTag, collectionService, obj, tagName)
		end
	end)
end)

run(function()
	local modules = replicatedStorage.Modules

	parry = {
		GlobalFunctions = require(modules.GlobalFunctions)
	}

	vape:Clean(function()
		table.clear(parry)
	end)
end)

run(function() -- ac bypass by koya
	local goofinator = replicatedStorage:FindFirstChild("GoofinatorActivationSequence")
	if goofinator then
		goofinator:Destroy()
		notif("Vape", "Successfully bypassed the anticheat, thanks koya!", 10)
	else
		notif("Vape", "Couldn't bypass the anticheat. Use at your own risk. (or anticheat alr bypassed)", 10, "warning")
	end
end)

for _, v in { "Reach", "Invisible", "Disabler", "Killaura", "MurderMystery", "SilentAim", "AimAssist" } do
	vape:Remove(v)
end

run(function()
	local AutoParry
	local Chance
	local UpdateRate
	local PerfectParry
	local LegitMode
	local oldGPP
	local cachedTracks = {}

	local function getParryTrack()
		local weapon = lplr:GetAttribute("Weapon")
		local track = cachedTracks[weapon]

		if track and track.Parent then
			return track
		end

		local animation = replicatedStorage.Animations.ParryStarts:FindFirstChild(weapon .. "ParryStart")
		if not animation or not entitylib.isAlive then
			return
		end

		track = entitylib.character.Humanoid.Animator:LoadAnimation(animation)
		cachedTracks[weapon] = track

		return track
	end

	local function isParrying()
		return math.random(100) <= Chance.Value
	end

	local function updateMechs(parrying)
		for _, mech in ipairs(collectionService:GetTagged("Mech")) do
			local seat = mech:FindFirstChildWhichIsA("Seat", true) or mech:FindFirstChildWhichIsA("VehicleSeat", true)
			local occupied = seat and seat.Occupant and seat.Occupant.Parent == lplr.Character

			if occupied then
				mech:SetAttribute("Parrying", parrying)
				mech:SetAttribute("PerfectParrying", parrying and PerfectParry.Enabled or false)
			end
		end
	end

	local function setupHighlight(obj)
		obj.Enabled = false

		AutoParry:Clean(entitylib.character.Character:GetAttributeChangedSignal("Parrying"):Connect(function()
			if not entitylib.isAlive then
				return
			end

			if not entitylib.character.Character:GetAttribute("Parrying") then
				obj.Enabled = true

				local track = getParryTrack()

				if track then
					task.spawn(function()
						track:Play()
						track.TimePosition = 0.2
						track.Stopped:Wait()
						obj.Enabled = false
					end)
				else
					obj.Enabled = false
				end
			end
		end))
	end

	AutoParry = vape.Categories.Blatant:CreateModule({
		Name = "AutoParry",
		Function = function(callback)
			if callback then
				oldGPP = parry.GlobalFunctions.GPP

				if LegitMode.Enabled then
					AutoParry:Clean(collectionService:GetInstanceAddedSignal("ParryHighlight"):Connect(setupHighlight))

					for _, obj in ipairs(collectionService:GetTagged("ParryHighlight")) do
						setupHighlight(obj)
					end
				else
					for _, obj in ipairs(collectionService:GetTagged("ParryHighlight")) do
						obj.Enabled = true
					end
				end

				repeat
					local parrying = isParrying()

					updateMechs(parrying)

					lplr:SetAttribute("ParryActiveTime", parrying and 0.3 or 0)

					parry.GlobalFunctions.GPP = function()
						return PerfectParry.Enabled
					end

					task.wait(1 / UpdateRate.Value)
				until not AutoParry.Enabled
			else
				if oldGPP then
					parry.GlobalFunctions.GPP = oldGPP
					oldGPP = nil
				end
			end
		end,
		Tooltip = "Automatically parries attacks."
	})

	Chance = AutoParry:CreateSlider({
		Name = "Chance",
		Min = 1,
		Max = 100,
		Default = 100,
		Suffix = function()
			return "%"
		end
	})

	UpdateRate = AutoParry:CreateSlider({
		Name = "Update Rate",
		Min = 1,
		Max = 120,
		Default = 20,
		Suffix = function()
			return "Hz"
		end
	})

	PerfectParry = AutoParry:CreateToggle({
		Name = "Perfect Parry"
	})

	LegitMode = AutoParry:CreateToggle({
		Name = "Legit Mode",
		Function = function()
			if AutoParry.Enabled then
				AutoParry:Toggle()
				AutoParry:Toggle()
			end
		end
	})

	LegitMode.Object.Visible = shared.vapedev -- wip module, im not adding private modules
end)

run(function()
	local AntiHazard
	local Reference = {}

	local function create(obj)
		if not obj or not obj:IsA("BasePart") then
			return
		end

		if Reference[obj] then
			return
		end

		local part = Instance.new("Part")
		part.Name = randomString()
		part.Anchored = true
		part.Transparency = 0
		part.CanCollide = false
		part.Size = obj.Size + Vector3.new(0.5, 0.5, 0.5)
		part.CFrame = obj.CFrame
		part.Parent = workspace

		Reference[obj] = part
	end

	local function remove(obj)
		local part = Reference[obj]
		if not part then
			return
		end

		Reference[obj] = nil

		task.delay(0.5, function()
			if part and part.Parent then
				part:Destroy()
			end
		end)
	end

	AntiHazard = vape.Categories.Blatant:CreateModule({
		Name = "AntiHazard",
		Function = function(callback)
			if callback then
				AntiHazard:Clean(collectionService:GetInstanceAddedSignal("x1Slash"):Connect(create))
				AntiHazard:Clean(collectionService:GetInstanceRemovedSignal("x1Slash"):Connect(remove))
				
				for _, obj in ipairs(collectionService:GetTagged("x1Slash")) do
					create(obj)
				end
			else
				for _, part in pairs(Reference) do
					if part and part.Parent then
						part:Destroy()
					end
				end
				table.clear(Reference)
			end
		end
	})
end)

run(function() 
	local SpoofWeapon
    local Weapon

    local oldWeapon

	SpoofWeapon = vape.Categories.Blatant:CreateModule({
		Name = "SpoofWeapon",
		Function = function(callback)
			if callback then 
                oldWeapon = lplr:GetAttribute("Weapon")

                lplr:SetAttribute("Weapon", Weapon.Value)
            else
                lplr:SetAttribute("Weapon", oldWeapon)
			end
		end,
		Tooltip = "Spoofs your current weapon's animation.",
        ExtraText = function()
			return Weapon.Value
		end
	})

    Weapon = SpoofWeapon:CreateDropdown({
        Name = "Weapon",
        List = {"Buster", "Katana", "Staff", "Nothing"},
        Function = function() 
            if SpoofWeapon.Enabled then 
                SpoofWeapon:Toggle()
                SpoofWeapon:Toggle()
            end
        end,
    })
end)

run(function()
	local HitBoxes
	local Expand
	local ExpandY
	local Y
	local Transparency
	local modified = {}

	local function Added(v)
		local part = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
		if not part then return end

		if not modified[part] then
			modified[part] = {
				Size = part.Size,
				Transparency = part.Transparency
			}
		end

		part.Size = modified[part].Size + Vector3.new(Expand.Value, ExpandY.Enabled and Y.Value or 3, Expand.Value)
		part.Transparency = Transparency.Value
	end

	HitBoxes = vape.Categories.Blatant:CreateModule({
		Name = "HitBoxes",
		Function = function(callback)
			if callback then
				repeat
					for _, obj in ipairs(collectionService:GetTagged("Enemy")) do
						Added(obj)
					end
					task.wait(0.1)
				until not HitBoxes.Enabled
			else
				for part, original in pairs(modified) do
					if part and part.Parent then
						part.Size = original.Size
						part.Transparency = original.Transparency
					end
				end

				table.clear(modified)
			end
		end,
		Tooltip = "Expands enemy hitboxes."
	})

	Expand = HitBoxes:CreateSlider({
		Name = "Expand amount",
		Min = 0,
		Max = 35,
		Suffix = function(val)
			return val == 1 and "stud" or "studs"
		end,
		Function = function()
			if HitBoxes.Enabled then
				HitBoxes:Toggle()
				HitBoxes:Toggle()
			end
		end,
		Default = 35
	})

	Transparency = HitBoxes:CreateSlider({
		Name = "Transparency",
		Min = 0,
		Max = 1,
		Default = 0.75,
		Decimal = 100,
		Function = function()
			if HitBoxes.Enabled then
				HitBoxes:Toggle()
				HitBoxes:Toggle()
			end
		end
	})

	ExpandY = HitBoxes:CreateToggle({
		Name = "Expand Y",
		Function = function(val)
			if HitBoxes.Enabled then
				HitBoxes:Toggle()
				HitBoxes:Toggle()
			end
			Y.Object.Visible = val
		end,
		Darker = true
	})
	
	Y = HitBoxes:CreateSlider({
		Name = "Expand amount (Y)",
		Min = 0,
		Max = 35,
		Suffix = function(val)
			return val == 1 and "stud" or "studs"
		end,
		Function = function()
			if HitBoxes.Enabled then
				HitBoxes:Toggle()
				HitBoxes:Toggle()
			end
		end,
		Default = 3,
		Darker = true
	})
end)

run(function() 
	local AutoOverCharge
	local Rate

	local LocalEvent = Remotes:FindFirstChild("LocalEvent")

	AutoOverCharge = vape.Categories.Blatant:CreateModule({
		Name = "AutoOverCharge",
		Function = function(callback) 
			if callback then 
				repeat
					LocalEvent:FireServer("Overcharge")
					task.wait(1 / Rate.Value)
				until not AutoOverCharge.Enabled
			end
		end
	})

	Rate = AutoOverCharge:CreateSlider({
		Name = "Rate",
		Min = 0,
		Max = 120,
		Suffix = function() return "Hz" end,
		Default = 30,
		Tooltip = "How many times a second you want to fire the overcharge refill remote."
	})
end)

--[[run(function() 
	local HipHeight
	local Height
	local modified = {}

	local function Added(obj)
		local humanoid = obj:FindFirstChildWhichIsA("Humanoid")
		
		if humanoid then 
			modified[humanoid] = humanoid.HipHeight
			humanoid.HipHeight = Height.Value
		end
	end

	HipHeight = vape.Categories.Blatant:CreateModule({
		Name = "HipHeight",
		Function = function(callback) 
			if callback then 
				repeat
					for _, obj in ipairs(collectionService:GetTagged("Enemy")) do
						Added(obj)
					end
					task.wait(0.1)
				until not HipHeight.Enabled
			else
				for humanoid, original in pairs(modified) do
					if humanoid and humanoid.Parent then
						humanoid.HipHeight = original
					end
				end

				table.clear(modified)
			end
		end
	})

	Height = HipHeight:CreateSlider({
		Name = "Height",
		Min = 0,
		Max = 100,
		Function = function() 
			if HipHeight.Enabled then 
				HipHeight:Toggle()
				HipHeight:Toggle()
			end
		end,
		Default = 10
	})
end)]]

run(function() 
	local AutoTeleport -- SON :sob:
	local Distance
	local UpdateRate

	local AttackEvent = Remotes:FindFirstChild("AttackEvent")

	AutoTeleport = vape.Categories.Blatant:CreateModule({
		Name = "AutoWin",
		Function = function(callback) 
			if callback then 
				repeat 
					if entitylib.isAlive then
						local enemies = collectionService:GetTagged("Enemy")

						if #enemies > 0 then
							local enemy = enemies[1]
							local enemyRootPart = enemy:FindFirstChild("HumanoidRootPart") or enemy.PrimaryPart

							if enemyRootPart then
								entitylib.character.RootPart.CFrame = CFrame.lookAt(
									(enemyRootPart.CFrame * CFrame.new(0, 0, Distance.Value)).Position,
									enemyRootPart.Position
								)
								AttackEvent:FireServer("Melee", {{enemy},{}})
							end
						end
					end
					
					task.wait(1 / UpdateRate.Value)
				until not AutoTeleport.Enabled
			end
		end,
		Tooltip = "Automatically teleports behind an enemy with a certain distance and rate and attacks them."
	})

	Distance = AutoTeleport:CreateSlider({
		Name = "Distance",
		Min = 1,
		Max = 35,
		Default = 10,
		Suffix = function(val)
			return val == 1 and "stud" or "studs"
		end
	})

	UpdateRate = AutoTeleport:CreateSlider({
		Name = "Update Rate",
		Min = 1,
		Max = 60,
		Default = 20,
		Suffix = function(val)
			return "Hz"
		end
	})
end)

run(function() 
	local DisableEventsAllowed
	local EventsAllowed = replicatedStorage:FindFirstChild("EventsAllowed")

	DisableEventsAllowed = vape.Categories.Blatant:CreateModule({
		Name = "DisableEventsAllowed",
		Function = function(callback)
			if callback then 
				repeat
					EventsAllowed.Value = false
					task.wait(1)
				until not DisableEventsAllowed.Enabled
			else
				task.wait(1)
				EventsAllowed.Value = true
			end
		end
	})
end)

run(function() 
	local DisableEffects

	local function remove(instance)
		task.defer(function()
			if instance.Parent and not instance:IsA("Folder") then
				instance:Destroy()
			end
		end)
	end

	DisableEffects = vape.Categories.World:CreateModule({
		Name = "DisableEffects",
		Function = function(callback)
			if callback then 
				if not EffectsFolder then 
					notif("DisableEffects", "Couldn't find the game's effects folder!", 10, "warning")
					DisableEffects:Toggle()
					return
				end

				for _, obj in ipairs(EffectsFolder:GetDescendants()) do
					remove(obj)
				end

				DisableEffects:Clean(EffectsFolder.DescendantAdded:Connect(remove))
			end
		end,
		Tooltip = "Attempts to destroy all the effects in the game. [BETA]"
	})
end)

run(function()
	local NewSong
	local Song
	local Volume
	local PlaybackSpeed

	local songs = workspace:FindFirstChild("Songs")

	local function PlaySong(sound)
		local oldSong = workspace:FindFirstChild("CurrentSong")
		if oldSong then
			oldSong:Destroy()
		end

		local CurrentSong = sound:Clone()

		CurrentSong.Name = "CurrentSong"
		CurrentSong.Parent = workspace

		local timeScale = PlaybackSpeed.Value or 1
		CurrentSong.PlaybackSpeed = timeScale
		CurrentSong.Volume = Volume.Value
		CurrentSong:Play()

		local drums = CurrentSong:FindFirstChild("Drums")
		if drums then
			drums.PlaybackSpeed = timeScale
			drums.Volume = Volume.Value

			if timeScale >= 1.5 then
				drums.PlaybackSpeed /= 2
			end

			drums:Play()
		end
	end

	local function GetSongs()
		local list = {}

		if songs then
			for _, v in ipairs(songs:GetChildren()) do
				if v:IsA("Sound") then
					table.insert(list, v.Name)
				end
			end
		end

		table.sort(list)
		return list
	end

	NewSong = vape.Categories.World:CreateModule({
		Name = "NewSong",
		Function = function(callback)
			if callback then
				local selectedSong = songs and songs:FindFirstChild(Song.Value)

				if selectedSong then
					PlaySong(selectedSong)
				else
					notif("NewSong", "Couldn't find the selected audio.", 10, "warning")
				end

				NewSong:Toggle()
			end
		end,
		Tooltip = "Changes the game's background music."
	})

	Song = NewSong:CreateDropdown({
		Name = "Song",
		List = GetSongs(),
		Default = "StadiumRave"
	})

	Volume = NewSong:CreateSlider({
		Name = "Volume",
		Min = 0,
		Max = 10,
		Default = 1,
		Function = function(val)
			local current = workspace:FindFirstChild("CurrentSong")
			if current then
				current.Volume = val

				local drums = current:FindFirstChild("Drums")
				if drums then
					drums.Volume = val
				end
			end
		end,
		Tooltip = "Increase the bass!",
	})

	PlaybackSpeed = NewSong:CreateSlider({
		Name = "Playback Speed",
		Min = 0.1,
		Max = 3,
		Default = 1,
		Decimal = 10,
		Function = function(val)
			local current = workspace:FindFirstChild("CurrentSong")
			if current then
				current.PlaybackSpeed = val
	
				local drums = current:FindFirstChild("Drums")
				if drums then
					drums.PlaybackSpeed = val
	
					if val >= 1.5 then
						drums.PlaybackSpeed = val / 2
					end
				end
			end
		end,
		Tooltip = "Changes the playback speed."
	})
end)