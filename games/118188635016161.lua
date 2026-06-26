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

local function notif(...)
	return vape:CreateNotification(...)
end

run(function()
	local taggedObjects = {}

	local function tag(obj, tagName)
		if collectionService:HasTag(obj, tagName) then
			return
		end

		if vape.ThreadFix then
			setthreadidentity(8)
		end

		pcall(function()
			collectionService:AddTag(obj, tagName)

			taggedObjects[obj] = {tagName}

			obj.Destroying:Connect(function() 
				taggedObjects[obj] = nil
			end)
		end)
	end

	local function isValidWorldObject(obj)
		if not obj then return false end

		if not obj:IsDescendantOf(workspace) then
			return false
		end

		if lplr then
			local backpack = lplr:FindFirstChild("Backpack")
			local character = lplr.Character

			if backpack and obj:IsDescendantOf(backpack) then
				return false
			end

			if character and obj:IsDescendantOf(character) then
				return false
			end
		end

		return true
	end

	local function tagObj(obj)
		if not obj or not obj.Parent then return end
		if not isValidWorldObject(obj) then return end

		local name = obj.Name

		if obj.Parent == EnemyFolder then
			tag(obj, "Enemy")
		
		elseif name == "Mech" and obj.Parent == PlayerFolder then
			tag(obj, "Mech")
		end
	end

	for _, obj in ipairs(workspace:GetDescendants()) do
		tagObj(obj)
	end

	vape:Clean(workspace.DescendantAdded:Connect(tagObj))
	vape:Clean(function() 
		for obj, tags in pairs(taggedObjects) do
			for _, tagName in ipairs(tags) do
				pcall(function()
					collectionService:RemoveTag(obj, tagName)
				end)
			end
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
	local old

	AutoParry = vape.Categories.Blatant:CreateModule({
		Name = "AutoParry",
		Function = function(callback)
			if callback then
				local parrying = (math.random() * 100 <= Chance.Value)
				old = parry.GlobalFunctions.GPP

                repeat
					for _, mech in ipairs(collectionService:GetTagged("Mech")) do
						local seat = mech:FindFirstChildWhichIsA("Seat", true) or mech:FindFirstChildWhichIsA("VehicleSeat", true)
					
						local occupiedBylocal = seat and seat.Occupant and seat.Occupant.Parent == lplr.Character
					
						if parrying and occupiedBylocal then
							mech:SetAttribute("Parrying", true)
							mech:SetAttribute("PerfectParrying", PerfectParry.Enabled)
						elseif not parrying and occupiedBylocal then
							mech:SetAttribute("Parrying", false)
							mech:SetAttribute("PerfectParrying", false)
						end
					end
				
					lplr:SetAttribute("ParryActiveTime", parrying and 0.3 or 0)
				
					parry.GlobalFunctions.GPP = function(...)
						return PerfectParry.Enabled
					end
				
					task.wait(1 / UpdateRate.Value)
				until not AutoParry.Enabled
			else
				if old then
					parry.GlobalFunctions.GPP = old
				end
			end
		end,
		Tooltip = "Automatically parries attacks."
	})

	Chance = AutoParry:CreateSlider({
		Name = "Chance",
		Min = 1,
		Max = 100,
        Suffix = function()
            return '%'
        end,
		Default = 100
	})

	UpdateRate = AutoParry:CreateSlider({
		Name = "Update Rate",
		Min = 1,
		Max = 120,
		Default = 20,
		Suffix = function(val)
			return "Hz"
		end
	})

    PerfectParry = AutoParry:CreateToggle({
		Name = "Perfect Parry",
	})

	-- PerfectParry.Object.Visible = false
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

		part.Size = modified[part].Size + Vector3.new(Expand.Value, 3, Expand.Value)
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
		end
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
end)

run(function() 
	local DisableEffects

	local EffectsFolder = workspace:FindFirstChild("EffectsFolder")

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
		local list = {"StadiumRave"}

		if songs then
			for _, v in ipairs(songs:GetChildren()) do
				if v:IsA("Sound") and not list[v.Name] then
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
		Tooltip = "Increase the bass!"
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