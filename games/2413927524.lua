local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification("Vape", "Failed to load : " .. err, 30, "alert")
	end
	return res
end
local isfile = isfile
	or function(file)
		local suc, res = pcall(function()
			return readfile(file)
		end)
		return suc and res ~= nil and res ~= ""
	end
local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet(
				"https://raw.githubusercontent.com/snovvvvy/VapeV4ForRoblox/"
					.. readfile("newvape/profiles/commit.txt")
					.. "/"
					.. select(1, path:gsub("newvape/", "")),
				true
			)
		end)
		if not suc or res == "404: Not Found" then
			error(res)
		end
		if path:find(".lua") then
			res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n"
				.. res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end
local run = function(func)
	func()
end
local queue_on_teleport = queue_on_teleport or function() end
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

local isnetworkowner = identifyexecutor
		and table.find({ "AWP", "Nihon" }, ({ identifyexecutor() })[1])
		and isnetworkowner
	or function()
		return true
	end
local gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA("Camera")
local lplr = playersService.LocalPlayer
local playerGui = lplr:WaitForChild("PlayerGui")

local map = workspace:WaitForChild("Map")

local assetfunction = getcustomasset

local vape = shared.vape
local tween = vape.Libraries.tween
local targetinfo = vape.Libraries.targetinfo
local getfontsize = vape.Libraries.getfontsize
local getcustomasset = vape.Libraries.getcustomasset
local uipallet = vape.Libraries.uipallet
local entitylib = vape.Libraries.entity
local sessioninfo = vape.Libraries.sessioninfo

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

-- rake remastered

local function safeTag(obj, tag)
	if collectionService:HasTag(obj, tag) then
		return
	end

	if vape.ThreadFix then
		setthreadidentity(8)
	end

	pcall(function()
		collectionService:AddTag(obj, tag)
	end)
end

local function tagObj(obj)
	local current

	if obj.Name == "RakeTrapModel" then
		current = obj.Parent

		while current do
			if current:IsA("Folder") and current.Name == "Traps" then
				safeTag(obj, "Trap")
				break
			end

			current = current.Parent
		end
	end

	if obj.Name == "Rake" then
		current = obj.Parent

		while current do
			if current == workspace then
				safeTag(obj, "Rake")
				break
			end

			current = current.Parent
		end
	end

	if obj.Name:find("Scrap") then 
		current = obj.Parent

		while current do
			if current.Name:find("ItemSpawn") then
				safeTag(obj, "Scrap")
				break
			end

			current = current.Parent
		end
	end

	if obj.Name == "Box" then 
		current = obj.Parent

		while current do
			if current.Name == "SupplyCrates" then
				safeTag(obj, "SupplyCrate")
				break
			end

			current = current.Parent
		end
	end
end

for _, obj in ipairs(workspace:GetDescendants()) do
	tagObj(obj)
end

vape:Clean(workspace.DescendantAdded:Connect(tagObj))

for _, v in { "Reach", "Invisible", "Disabler", "Jesus", "Killaura", "MurderMystery", "SilentAim", "AimAssist" } do
	vape:Remove(v)
end

run(function() 
    local powerValues = replicatedStorage.PowerValues
    local powerLevel = powerValues.PowerLevel
	
	local Timer = replicatedStorage.Timer

	local DistanceTravelled = lplr.DistanceTravelled

    local power = sessioninfo:AddItem("Power", powerLevel.MaxValue, function(val) 
        return powerLevel.Value <= 60 and "⚠️ " .. powerLevel.Value .. "/" .. powerLevel.MaxValue or powerLevel.Value .. "/" .. powerLevel.MaxValue
    end, false)

	local timer = sessioninfo:AddItem("Time Until Day/Night", 0, function(val)
		return Timer.Value == 1 and Timer.Value .. " sec" or Timer.Value .. " secs"
	end, false)

	local distanceTravelled = sessioninfo:AddItem("Distance Travelled", 0, function(val) 
		return DistanceTravelled.Value
	end, false)
end)

run(function() 
	vape:CreateCategory({
		Name = 'Troll',
		Icon = getcustomasset('newvape/assets/new/troll.png'),
		Size = UDim2.fromOffset(13, 14)
	})
end)

run(function()
	local RakeESP
	local FillColor
	local OutlineColor
	local FillTransparency
	local OutlineTransparency

	local Reference = {}
	local Folder = Instance.new("Folder")
	Folder.Parent = vape.gui

	local function IsRake(obj)
		if not obj then
			return false
		end

		if obj.Name ~= "Rake" then
			return false
		end

		local current = obj.Parent

		while current do
			if current == workspace then
				return true
			end

			current = current.Parent
		end

		return false
	end

	local function Added(obj)
		if Reference[obj] or not IsRake(obj) then
			return
		end

		local cham = Instance.new("Highlight")
		cham.Adornee = obj
		cham.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		cham.FillColor = Color3.fromHSV(FillColor.Hue, FillColor.Sat, FillColor.Value)
		cham.OutlineColor = Color3.fromHSV(OutlineColor.Hue, OutlineColor.Sat, OutlineColor.Value)
		cham.FillTransparency = FillTransparency.Value
		cham.OutlineTransparency = OutlineTransparency.Value
		cham.Parent = Folder

		Reference[obj] = cham
	end

	local function Removed(obj)
		if Reference[obj] then
			if vape.ThreadFix then
				setthreadidentity(8)
			end

			Reference[obj]:Destroy()
			Reference[obj] = nil
		end
	end

	RakeESP = vape.Categories.Render:CreateModule({
		Name = "RakeESP",
		Function = function(callback)
			if callback then
				RakeESP:Clean(collectionService:GetInstanceAddedSignal("Rake"):Connect(Added))
				RakeESP:Clean(collectionService:GetInstanceRemovedSignal("Rake"):Connect(Removed))

				for _, obj in ipairs(collectionService:GetTagged("Rake")) do
					Added(obj)
				end
			else
				for _, v in pairs(Reference) do
					v:Destroy()
				end

				table.clear(Reference)
			end
		end,
	})

	FillColor = RakeESP:CreateColorSlider({
		Name = "Color",
		Function = function(hue, sat, val)
			for _, v in pairs(Reference) do
				v.FillColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	OutlineColor = RakeESP:CreateColorSlider({
		Name = "Outline Color",
		DefaultSat = 0,
		Function = function(hue, sat, val)
			for _, v in pairs(Reference) do
				v.OutlineColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	FillTransparency = RakeESP:CreateSlider({
		Name = "Transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Function = function(val)
			for _, v in pairs(Reference) do
				v.FillTransparency = val
			end
		end,
		Decimal = 10,
	})

	OutlineTransparency = RakeESP:CreateSlider({
		Name = "Outline Transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Function = function(val)
			for _, v in pairs(Reference) do
				v.OutlineTransparency = val
			end
		end,
		Decimal = 10,
	})
end)

run(function()
	local SupplyCrateESP
	local FillColor
	local OutlineColor
	local FillTransparency
	local OutlineTransparency

	local Reference = {}
	local Folder = Instance.new("Folder")
	Folder.Parent = vape.gui

	local function IsASupplyCrate(obj)
		if not obj then
			return false
		end

		if not obj.Name == "Box" then
			return false
		end

		local current = obj.Parent

		while current do
			if current.Name == "SupplyCrates" then
				return true
			end

			current = current.Parent
		end

		return false
	end

	local function Added(obj)
		if Reference[obj] or not IsASupplyCrate(obj) then
			return
		end

		local cham = Instance.new("Highlight")
		cham.Adornee = obj
		cham.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		cham.FillColor = Color3.fromHSV(FillColor.Hue, FillColor.Sat, FillColor.Value)
		cham.OutlineColor = Color3.fromHSV(OutlineColor.Hue, OutlineColor.Sat, OutlineColor.Value)
		cham.FillTransparency = FillTransparency.Value
		cham.OutlineTransparency = OutlineTransparency.Value
		cham.Parent = Folder

		Reference[obj] = cham
	end

	local function Removed(obj)
		if Reference[obj] then
			if vape.ThreadFix then
				setthreadidentity(8)
			end

			Reference[obj]:Destroy()
			Reference[obj] = nil
		end
	end

	SupplyCrateESP = vape.Categories.Render:CreateModule({
		Name = "SupplyCrateESP",
		Function = function(callback)
			if callback then
				SupplyCrateESP:Clean(collectionService:GetInstanceAddedSignal("SupplyCrate"):Connect(Added))
				SupplyCrateESP:Clean(collectionService:GetInstanceRemovedSignal("SupplyCrate"):Connect(Removed))

				for _, obj in ipairs(collectionService:GetTagged("SupplyCrate")) do
					Added(obj)
				end
			else
				for _, v in pairs(Reference) do
					v:Destroy()
				end

				table.clear(Reference)
			end
		end,
	})

	FillColor = SupplyCrateESP:CreateColorSlider({
		Name = "Color",
		Function = function(hue, sat, val)
			for _, v in pairs(Reference) do
				v.FillColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	OutlineColor = SupplyCrateESP:CreateColorSlider({
		Name = "Outline Color",
		DefaultSat = 0,
		Function = function(hue, sat, val)
			for _, v in pairs(Reference) do
				v.OutlineColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	FillTransparency = SupplyCrateESP:CreateSlider({
		Name = "Transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Function = function(val)
			for _, v in pairs(Reference) do
				v.FillTransparency = val
			end
		end,
		Decimal = 10,
	})

	OutlineTransparency = SupplyCrateESP:CreateSlider({
		Name = "Outline Transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Function = function(val)
			for _, v in pairs(Reference) do
				v.OutlineTransparency = val
			end
		end,
		Decimal = 10,
	})
end)

run(function()
	local ScrapESP
	local FillColor
	local OutlineColor
	local FillTransparency
	local OutlineTransparency

	local Reference = {}
	local Folder = Instance.new("Folder")
	Folder.Parent = vape.gui

	local function IsAScrap(obj)
		if not obj then
			return false
		end

		if not obj.Name:find("Scrap") then
			return false
		end

		local current = obj.Parent

		while current do
			if current.Name:find("ItemSpawn") then
				return true
			end

			current = current.Parent
		end

		return false
	end

	local function Added(obj)
		if Reference[obj] or not IsAScrap(obj) then
			return
		end

		local cham = Instance.new("Highlight")
		cham.Adornee = obj
		cham.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		cham.FillColor = Color3.fromHSV(FillColor.Hue, FillColor.Sat, FillColor.Value)
		cham.OutlineColor = Color3.fromHSV(OutlineColor.Hue, OutlineColor.Sat, OutlineColor.Value)
		cham.FillTransparency = FillTransparency.Value
		cham.OutlineTransparency = OutlineTransparency.Value
		cham.Parent = Folder

		Reference[obj] = cham
	end

	local function Removed(obj)
		if Reference[obj] then
			if vape.ThreadFix then
				setthreadidentity(8)
			end

			Reference[obj]:Destroy()
			Reference[obj] = nil
		end
	end

	ScrapESP = vape.Categories.Render:CreateModule({
		Name = "ScrapESP",
		Function = function(callback)
			if callback then
				ScrapESP:Clean(collectionService:GetInstanceAddedSignal("Scrap"):Connect(Added))
				ScrapESP:Clean(collectionService:GetInstanceRemovedSignal("Scrap"):Connect(Removed))

				for _, obj in ipairs(collectionService:GetTagged("Scrap")) do
					Added(obj)
				end
			else
				for _, v in pairs(Reference) do
					v:Destroy()
				end

				table.clear(Reference)
			end
		end,
	})

	FillColor = ScrapESP:CreateColorSlider({
		Name = "Color",
		Function = function(hue, sat, val)
			for _, v in pairs(Reference) do
				v.FillColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	OutlineColor = ScrapESP:CreateColorSlider({
		Name = "Outline Color",
		DefaultSat = 0,
		Function = function(hue, sat, val)
			for _, v in pairs(Reference) do
				v.OutlineColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	FillTransparency = ScrapESP:CreateSlider({
		Name = "Transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Function = function(val)
			for _, v in pairs(Reference) do
				v.FillTransparency = val
			end
		end,
		Decimal = 10,
	})

	OutlineTransparency = ScrapESP:CreateSlider({
		Name = "Outline Transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Function = function(val)
			for _, v in pairs(Reference) do
				v.OutlineTransparency = val
			end
		end,
		Decimal = 10,
	})
end)

run(function()
	local TrapESP
	local FillColor
	local OutlineColor
	local FillTransparency
	local OutlineTransparency

	local Reference = {}
	local Folder = Instance.new("Folder")
	Folder.Parent = vape.gui

	local function IsATrap(obj)
		if not obj then
			return false
		end

		if obj.Name ~= "RakeTrapModel" then
			return false
		end

		local current = obj.Parent

		while current do
			if current:IsA("Folder") and (current.Name == "Traps") then
				return true
			end

			current = current.Parent
		end

		return false
	end

	local function Added(obj)
		if Reference[obj] or not IsATrap(obj) then
			return
		end

		local cham = Instance.new("Highlight")
		cham.Adornee = obj
		cham.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		cham.FillColor = Color3.fromHSV(FillColor.Hue, FillColor.Sat, FillColor.Value)
		cham.OutlineColor = Color3.fromHSV(OutlineColor.Hue, OutlineColor.Sat, OutlineColor.Value)
		cham.FillTransparency = FillTransparency.Value
		cham.OutlineTransparency = OutlineTransparency.Value
		cham.Parent = Folder

		Reference[obj] = cham
	end

	local function Removed(obj)
		if Reference[obj] then
			if vape.ThreadFix then
				setthreadidentity(8)
			end

			Reference[obj]:Destroy()
			Reference[obj] = nil
		end
	end

	TrapESP = vape.Categories.Render:CreateModule({
		Name = "TrapESP",
		Function = function(callback)
			if callback then
				TrapESP:Clean(collectionService:GetInstanceAddedSignal("Trap"):Connect(Added))
				TrapESP:Clean(collectionService:GetInstanceRemovedSignal("Trap"):Connect(Removed))

				for _, obj in ipairs(collectionService:GetTagged("Trap")) do
					Added(obj)
				end
			else
				for _, v in pairs(Reference) do
					v:Destroy()
				end

				table.clear(Reference)
			end
		end,
	})

	FillColor = TrapESP:CreateColorSlider({
		Name = "Color",
		Function = function(hue, sat, val)
			for _, v in pairs(Reference) do
				v.FillColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	OutlineColor = TrapESP:CreateColorSlider({
		Name = "Outline Color",
		DefaultSat = 0,
		Function = function(hue, sat, val)
			for _, v in pairs(Reference) do
				v.OutlineColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	FillTransparency = TrapESP:CreateSlider({
		Name = "Transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Function = function(val)
			for _, v in pairs(Reference) do
				v.FillTransparency = val
			end
		end,
		Decimal = 10,
	})

	OutlineTransparency = TrapESP:CreateSlider({
		Name = "Outline Transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Function = function(val)
			for _, v in pairs(Reference) do
				v.OutlineTransparency = val
			end
		end,
		Decimal = 10,
	})
end)

run(function()
	local AntiTrap
	local FillColor
	local OutlineColor
	local FillTransparency
	local OutlineTransparency

	local Reference = {}
	local Folder = Instance.new("Folder")
	Folder.Parent = vape.gui

	local function IsATrap(obj)
		if not obj then
			return false
		end

		if obj.Name ~= "RakeTrapModel" then
			return false
		end

		local current = obj.Parent

		while current do
			if current:IsA("Folder") and (current.Name == "Traps") then
				return true
			end

			current = current.Parent
		end

		return false
	end

	local function Added(obj)
		if Reference[obj] or not IsATrap(obj) then
			return
		end
	
		local hitbox = obj:FindFirstChild("HitBox", true)
		if not hitbox then
			--notif("AntiTrap", "No HitBox found for" .. obj:GetFullName(), 5, "warning")
			if AntiTrap.Enabled then
				AntiTrap:Toggle()
				task.wait(1)
				AntiTrap:Toggle()
			end
			return
		end
	
		local oldParent = hitbox.Parent
	
		if vape.ThreadFix then
			setthreadidentity(8)
		end
	
		hitbox.Parent = Folder
	
		Reference[obj] = {
			HitBox = hitbox,
			OriginalParent = oldParent
		}
	end
	
	local function Removed(obj)
		local data = Reference[obj]
		if not data then
			return
		end
	
		if vape.ThreadFix then
			setthreadidentity(8)
		end
	
		if data.HitBox
			and data.HitBox.Parent == Folder
			and data.OriginalParent then
			data.HitBox.Parent = data.OriginalParent
		end
	
		Reference[obj] = nil
	end

	AntiTrap = vape.Categories.Blatant:CreateModule({
		Name = "AntiTrap",
		Function = function(callback)
			if callback then
				AntiTrap:Clean(collectionService:GetInstanceAddedSignal("Trap"):Connect(Added))
				AntiTrap:Clean(collectionService:GetInstanceRemovedSignal("Trap"):Connect(Removed))

				for _, obj in ipairs(collectionService:GetTagged("Trap")) do
					Added(obj)
				end
			else
				for _, data in pairs(Reference) do
					if data.HitBox
						and data.HitBox.Parent == Folder
						and data.OriginalParent then
						data.HitBox.Parent = data.OriginalParent
					end
				end
			
				table.clear(Reference)
			end
		end,
	})
end)

run(function()
	local AutoSpacebar

	local Connections = {}

	local function IsATrap(obj)
		if not obj then
			return false
		end

		if obj.Name ~= "RakeTrapModel" then
			return false
		end

		local current = obj.Parent

		while current do
			if current:IsA("Folder") and current.Name == "Traps" then
				return true
			end

			current = current.Parent
		end

		return false
	end

	local function StartSpam(obj)
		if Connections[obj].Spam then
			return
		end

		Connections[obj].Spam = task.spawn(function()
			while Connections[obj] and obj.Parent do
				keypress(0x20)
				keyrelease(0x20)
				task.wait()
			end
		end)
	end

	local function Added(obj)
		if Connections[obj] or not IsATrap(obj) then
			return
		end

		local knownAttributes = {}

		for name in pairs(obj:GetAttributes()) do
			knownAttributes[name] = true
		end

		Connections[obj] = {}

		local hitChar = obj:GetAttribute("HitChar")
		if hitChar == lplr.Name then
			StartSpam(obj)
		end

		Connections[obj].AttributeChanged = obj.AttributeChanged:Connect(function(attributeName)
			if attributeName ~= "HitChar" then
				return
			end

			local value = obj:GetAttribute("HitChar")

			if value == lplr.Name then
				StartSpam(obj)
			end
		end)
	end

	local function Removed(obj)
		local data = Connections[obj]
		if not data then
			return
		end

		if data.AttributeChanged then
			data.AttributeChanged:Disconnect()
		end

		Connections[obj] = nil
	end

	AutoSpacebar = vape.Categories.Blatant:CreateModule({
		Name = "AutoSpacebar",
		Function = function(callback)
			if callback then
				AutoSpacebar:Clean(collectionService:GetInstanceAddedSignal("Trap"):Connect(Added))
				AutoSpacebar:Clean(collectionService:GetInstanceRemovedSignal("Trap"):Connect(Removed))

				for _, obj in ipairs(collectionService:GetTagged("Trap")) do
					Added(obj)
				end
			else
				for obj in pairs(Connections) do
					Removed(obj)
				end

				table.clear(Connections)
			end
		end,
		Tooltip = "Automatically presses spacebar when you get caught on a trap.\n(really fast)",
	})
end)

run(function()
	local Invisible
	local oldcf
	local animtrack
	local proper = true
	
	local function animationTrickery()
		if entitylib.isAlive then
			local isR15 = entitylib.character.Humanoid.RigType == Enum.HumanoidRigType.R15
			local anim = Instance.new('Animation')
			anim.AnimationId = 'rbxassetid://'..(isR15 and '18537363391' or '215384594')
			animtrack = entitylib.character.Humanoid.Animator:LoadAnimation(anim)
			animtrack.Priority = Enum.AnimationPriority.Action4
			animtrack:Play(0, 0.001, 0)
			anim:Destroy()
	
			task.delay(0, function()
				animtrack.TimePosition = isR15 and 0.77 or 0.38
			end)
		end
	end
	
	Invisible = vape.Categories.Blatant:CreateModule({
		Name = 'PartialGodMode',
		Function = function(callback)
			if callback then
				animationTrickery()
	
				oldcf = nil
				local bindKey = httpService:GenerateGUID(true)
				runService:BindToRenderStep(bindKey, 0, function()
					if entitylib.isAlive and oldcf then
						entitylib.character.RootPart.CFrame = oldcf
						animtrack:AdjustWeight(0.001)
					end
				end)
	
				Invisible:Clean(function()
					runService:UnbindFromRenderStep(bindKey)
				end)
	
				Invisible:Clean(runService.Heartbeat:Connect(function(dt)
					if entitylib.isAlive then
						local isR15 = entitylib.character.Humanoid.RigType == Enum.HumanoidRigType.R15
						local root = entitylib.character.RootPart
						local cf = root.CFrame - Vector3.new(0, entitylib.character.Humanoid.HipHeight + (root.Size.Y / 2) - 1, 0)
						oldcf = root.CFrame
	
						root.CFrame = cf * CFrame.Angles(math.rad(isR15 and 180 or 90), 0, 0)
						animtrack:AdjustWeight(100)
					end
				end))
	
				Invisible:Clean(entitylib.Events.LocalAdded:Connect(function(char)
					local animator = char.Humanoid:WaitForChild('Animator', 1)
					if animator and Invisible.Enabled then
						oldroot = nil
						Invisible:Toggle()
						Invisible:Toggle()
					end
				end))
			else
				if animtrack then
					animtrack:Stop()
					animtrack:Destroy()
				end
	
				if entitylib.isAlive and oldcf then
					entitylib.character.RootPart.CFrame = oldcf
				end
			end
		end,
		Tooltip = 'Turns you invisible so that the rake cant see you.\n (sometimes does not work, especially in bloodhour mode.)'
	})
end)

run(function()
	local ScrapFarm
	local AvoidTraps
	local AvoidRake
	local MoveMode

	local Farming = false
	local CurrentToken = 0
	local FailedScraps = {}
	local FailCooldown = 5
	local TrapAvoidRadius = 8
	local RakeAvoidRadius = 30
	local TweenSpeed = 20
	local LineSampleSpacing = 4

	local TrapModifiers = {}
	local ModifierFolder = Instance.new("Folder")
	ModifierFolder.Name = "ScrapFarm_TrapAvoidance"

	local RakeModifiers = {}
	local RakeModifierFolder = Instance.new("Folder")
	RakeModifierFolder.Name = "ScrapFarm_RakeAvoidance"
	local RakeUpdateConnection

	local function GetScrapPosition(scrap)
		if scrap:IsA("BasePart") then
			return scrap.Position
		end

		if scrap:IsA("Model") or scrap:IsA("Folder") then
			local part = (scrap.PrimaryPart) or scrap:FindFirstChildWhichIsA("BasePart", true)
			if part then
				return part.Position
			end
		end

		return nil
	end

	local function GetTrapPosition(trap)
		if trap:IsA("BasePart") then
			return trap.Position
		end

		if trap:IsA("Model") or trap:IsA("Folder") then
			local part = trap.PrimaryPart or trap:FindFirstChildWhichIsA("BasePart", true)
			if part then
				return part.Position
			end
		end

		return nil
	end

	local function GetRakePosition(rake)
		if rake:IsA("BasePart") then
			return rake.Position
		end

		if rake:IsA("Model") or rake:IsA("Folder") then
			local part = rake.PrimaryPart or rake:FindFirstChildWhichIsA("BasePart", true)
			if part then
				return part.Position
			end
		end

		return nil
	end

	local function CreateTrapModifier(trap)
		if TrapModifiers[trap] then
			return
		end

		local pos = GetTrapPosition(trap)
		if not pos then
			return
		end

		if vape.ThreadFix then
			setthreadidentity(8)
		end

		local zone = Instance.new("Part")
		zone.Name = "TrapAvoidanceZone"
		zone.Shape = Enum.PartType.Block
		zone.Size = Vector3.new(TrapAvoidRadius * 2, 12, TrapAvoidRadius * 2)
		zone.CFrame = CFrame.new(pos)
		zone.Anchored = true
		zone.CanCollide = false
		zone.CanQuery = false
		zone.CanTouch = false
		zone.Transparency = 1
		zone.Parent = ModifierFolder

		local modifier = Instance.new("PathfindingModifier")
		modifier.PassThrough = false
		modifier.Parent = zone

		TrapModifiers[trap] = zone
	end

	local function RemoveTrapModifier(trap)
		local zone = TrapModifiers[trap]
		if not zone then
			return
		end

		if vape.ThreadFix then
			setthreadidentity(8)
		end

		zone:Destroy()
		TrapModifiers[trap] = nil
	end

	local function ClearAllTrapModifiers()
		for trap in pairs(TrapModifiers) do
			RemoveTrapModifier(trap)
		end

		table.clear(TrapModifiers)
	end

	local function EnableTrapAvoidance()
		ModifierFolder.Parent = workspace

		for _, trap in ipairs(collectionService:GetTagged("Trap")) do
			if trap.Parent then
				CreateTrapModifier(trap)
			end
		end

		ScrapFarm:Clean(collectionService:GetInstanceAddedSignal("Trap"):Connect(CreateTrapModifier))
		ScrapFarm:Clean(collectionService:GetInstanceRemovedSignal("Trap"):Connect(RemoveTrapModifier))
	end

	local function DisableTrapAvoidance()
		ClearAllTrapModifiers()
		ModifierFolder.Parent = nil
	end

	local function CreateRakeModifier(rake)
		if RakeModifiers[rake] then
			return
		end

		local pos = GetRakePosition(rake)

		if vape.ThreadFix then
			setthreadidentity(8)
		end

		local zone = Instance.new("Part")
		zone.Name = "RakeAvoidanceZone"
		zone.Shape = Enum.PartType.Block
		zone.Size = Vector3.new(RakeAvoidRadius * 2, 12, RakeAvoidRadius * 2)
		zone.CFrame = CFrame.new(pos or Vector3.zero)
		zone.Anchored = true
		zone.CanCollide = false
		zone.CanQuery = false
		zone.CanTouch = false
		zone.Transparency = 1
		zone.Parent = RakeModifierFolder

		local modifier = Instance.new("PathfindingModifier")
		modifier.PassThrough = false
		modifier.Parent = zone

		RakeModifiers[rake] = zone
	end

	local function RemoveRakeModifier(rake)
		local zone = RakeModifiers[rake]
		if not zone then
			return
		end

		if vape.ThreadFix then
			setthreadidentity(8)
		end

		zone:Destroy()
		RakeModifiers[rake] = nil
	end

	local function ClearAllRakeModifiers()
		for rake in pairs(RakeModifiers) do
			RemoveRakeModifier(rake)
		end

		table.clear(RakeModifiers)
	end

	local function UpdateRakeModifierPositions()
		for rake, zone in pairs(RakeModifiers) do
			if rake.Parent then
				local pos = GetRakePosition(rake)
				if pos then
					zone.CFrame = CFrame.new(pos)
				end
			else
				RemoveRakeModifier(rake)
			end
		end
	end

	local function EnableRakeAvoidance()
		RakeModifierFolder.Parent = workspace

		for _, rake in ipairs(collectionService:GetTagged("Rake")) do
			if rake.Parent then
				CreateRakeModifier(rake)
			end
		end

		ScrapFarm:Clean(collectionService:GetInstanceAddedSignal("Rake"):Connect(CreateRakeModifier))
		ScrapFarm:Clean(collectionService:GetInstanceRemovedSignal("Rake"):Connect(RemoveRakeModifier))

		RakeUpdateConnection = runService.Heartbeat:Connect(UpdateRakeModifierPositions)
		ScrapFarm:Clean(RakeUpdateConnection)
	end

	local function DisableRakeAvoidance()
		if RakeUpdateConnection then
			RakeUpdateConnection:Disconnect()
			RakeUpdateConnection = nil
		end

		ClearAllRakeModifiers()
		RakeModifierFolder.Parent = nil
	end

	local function IsValidScrap(obj)
		if not obj or not obj.Parent then
			return false
		end

		local expiry = FailedScraps[obj]
		if expiry and os.clock() < expiry then
			return false
		elseif expiry then
			FailedScraps[obj] = nil
		end

		return true
	end

	local function GetClosestScrap()
		local root = entitylib.character.RootPart
		if not root then return nil end

		local closest, closestDist = nil, math.huge

		for _, obj in ipairs(collectionService:GetTagged("Scrap")) do
			if IsValidScrap(obj) then
				local pos = GetScrapPosition(obj)
				if pos then
					local dist = (root.Position - pos).Magnitude
					if dist < closestDist then
						closestDist = dist
						closest = obj
					end
				end
			end
		end

		return closest
	end

	local function GetLiveObstaclePositions(tag, radius)
		local positions = {}

		for _, obj in ipairs(collectionService:GetTagged(tag)) do
			if obj.Parent then
				local pos
				if tag == "Trap" then
					pos = GetTrapPosition(obj)
				else
					pos = GetRakePosition(obj)
				end

				if pos then
					positions[#positions + 1] = { Position = pos, Radius = radius }
				end
			end
		end

		return positions
	end

	local function LineIsBlocked(startPos, endPos, obstacles)
		if #obstacles == 0 then
			return false
		end

		local delta = endPos - startPos
		local distance = delta.Magnitude

		if distance <= 0 then
			return false
		end

		local direction = delta / distance
		local steps = math.max(1, math.ceil(distance / LineSampleSpacing))

		for i = 0, steps do
			local samplePos = startPos + direction * math.min(i * LineSampleSpacing, distance)

			for _, obstacle in ipairs(obstacles) do
				if (samplePos - obstacle.Position).Magnitude <= obstacle.Radius then
					return true
				end
			end
		end

		return false
	end

	local function WalkPathTo(targetPos, token)
		local character = entitylib.character
		local humanoid = entitylib.character.Humanoid
		local root = entitylib.character.RootPart

		if not humanoid or not root or not character then return false end

		local path = pathfindingService:CreatePath({
			AgentRadius = 1.5,
			AgentHeight = 5,
			AgentCanJump = true,
			WaypointSpacing = 6
		})

		local ok, err = pcall(function()
			path:ComputeAsync(root.Position, targetPos)
		end)

		if not ok then
			notif("ScrapFarm", "ComputeAsync error:" .. err, 10, "warning")
			return false
		end

		if path.Status ~= Enum.PathStatus.Success then
			return false
		end

		local waypoints = path:GetWaypoints()

		for i = 1, #waypoints do
			if not Farming or token ~= CurrentToken then
				return false
			end

			local wp = waypoints[i]

			if wp.Action == Enum.PathWaypointAction.Jump then
				humanoid.Jump = true
			end

			humanoid:MoveTo(wp.Position)

			local start = os.clock()
			while (root.Position - wp.Position).Magnitude > 3 do
				if not Farming or token ~= CurrentToken then
					return false
				end

				if os.clock() - start > 1.5 then
					break
				end

				task.wait(0.05)
			end
		end

		return true
	end

	local function GetGroundPosition(position, character)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.FilterDescendantsInstances = {character}
	
		local result = workspace:Raycast(
			position + Vector3.new(0, 20, 0),
			Vector3.new(0, -100, 0),
			params
		)
	
		if result then
			return result.Position
		end
	
		return position
	end

	local function WalkTweenTo(targetPos, token)
		local character = entitylib.character
		local humanoid = entitylib.character.Humanoid
		local root = entitylib.character.RootPart

		if not humanoid or not root or not character then return false end
	
		local obstacles = {}
	
		if AvoidTraps.Enabled then
			for _, obstacle in ipairs(GetLiveObstaclePositions("Trap", TrapAvoidRadius)) do
				obstacles[#obstacles + 1] = obstacle
			end
		end
	
		if AvoidRake.Enabled then
			for _, obstacle in ipairs(GetLiveObstaclePositions("Rake", RakeAvoidRadius)) do
				obstacles[#obstacles + 1] = obstacle
			end
		end
	
		local startPos = root.Position
	
		if LineIsBlocked(startPos, targetPos, obstacles) then
			return false
		end
	
		local distance = (targetPos - startPos).Magnitude
	
		if distance <= 0 then
			return true
		end
	
		local direction = (targetPos - startPos).Unit
	
		local wasAnchored = root.Anchored
	
		if vape.ThreadFix then
			setthreadidentity(8)
		end
	
		root.Anchored = true
	
		local stepDistance = 2
		local steps = math.max(1, math.ceil(distance / stepDistance))
	
		for i = 1, steps do
			if not Farming or token ~= CurrentToken then
				root.Anchored = wasAnchored
				return false
			end
	
			local alpha = i / steps
	
			local horizontalPos = startPos:Lerp(targetPos, alpha)
	
			local groundPos = GetGroundPosition(horizontalPos, character)
	
			local desiredPos = groundPos + Vector3.new(0, 3, 0)
	
			if AvoidTraps.Enabled or AvoidRake.Enabled then
				local liveObstacles = {}
	
				if AvoidTraps.Enabled then
					for _, obstacle in ipairs(GetLiveObstaclePositions("Trap", TrapAvoidRadius)) do
						liveObstacles[#liveObstacles + 1] = obstacle
					end
				end
	
				if AvoidRake.Enabled then
					for _, obstacle in ipairs(GetLiveObstaclePositions("Rake", RakeAvoidRadius)) do
						liveObstacles[#liveObstacles + 1] = obstacle
					end
				end
	
				for _, obstacle in ipairs(liveObstacles) do
					if (desiredPos - obstacle.Position).Magnitude <= obstacle.Radius then
						root.Anchored = wasAnchored
						return false
					end
				end
			end
	
			root.CFrame = CFrame.lookAt(
				desiredPos,
				desiredPos + Vector3.new(direction.X, 0, direction.Z)
			)
	
			task.wait(stepDistance / TweenSpeed)
		end
	
		root.Anchored = wasAnchored
	
		return true
	end

	ScrapFarm = vape.Categories.Blatant:CreateModule({
		Name = "ScrapFarm",
		Function = function(callback)
			if callback then
				Farming = true
				CurrentToken += 1
				local token = CurrentToken

				if MoveMode.Value == "Pathfinding" then
					if AvoidTraps.Enabled then
						EnableTrapAvoidance()
					end

					if AvoidRake.Enabled then
						EnableRakeAvoidance()
					end
				end

				task.spawn(function()
					while Farming and token == CurrentToken do
						local scrap = GetClosestScrap()

						if scrap then
							local pos = GetScrapPosition(scrap)

							if pos then
								local success

								if MoveMode.Value == "Tweening" then
									success = WalkTweenTo(pos, token)
								else
									success = WalkPathTo(pos, token)
								end

								if not success and Farming and token == CurrentToken then
									if scrap.Parent then
										FailedScraps[scrap] = os.clock() + FailCooldown
									end
								end
							end
						end

						task.wait(0.1)
					end
				end)
			else
				Farming = false
				CurrentToken += 1
				table.clear(FailedScraps)
				DisableTrapAvoidance()
				DisableRakeAvoidance()
				local root = entitylib.character.RootPart
				local humanoid = entitylib.character.Humanoid

				if root and root.Anchored then
					if vape.ThreadFix then
						setthreadidentity(8)
					end

					root.Anchored = false
				end

				if humanoid then
					humanoid:Move(Vector3.zero)
				end
			end
		end,
		Tooltip = "Automatically walks to and collects the nearest scrap.",
	})

	MoveMode = ScrapFarm:CreateDropdown({
		Name = "Move Mode",
		List = { "Pathfinding" },
		Function = function(val)
			if not Farming then
				return
			end

			if val == "Pathfinding" then
				if AvoidTraps.Enabled then
					EnableTrapAvoidance()
				end

				if AvoidRake.Enabled then
					EnableRakeAvoidance()
				end
			else
				DisableTrapAvoidance()
				DisableRakeAvoidance()
			end
		end,
	})

	AvoidTraps = ScrapFarm:CreateToggle({
		Name = "Avoid Traps",
		Default = true,
		Function = function(callback)
			if not Farming or MoveMode.Value ~= "Pathfinding" then
				return
			end

			if callback then
				EnableTrapAvoidance()
			else
				DisableTrapAvoidance()
			end
		end,
		Tooltip = "Avoids traps.",
	})

	AvoidRake = ScrapFarm:CreateToggle({
		Name = "Avoid Rake",
		Default = true,
		Function = function(callback)
			if not Farming or MoveMode.Value ~= "Pathfinding" then
				return
			end

			if callback then
				EnableRakeAvoidance()
			else
				DisableRakeAvoidance()
			end
		end,
		Tooltip = "Avoids the rake.",
	})
end)

run(function()
	local AntiRakeChase
	local DetectionRange
	local SpeedMultiplier

	local OriginalWalkSpeed = nil

	local Config = {
		MIN_RUN_DISTANCE = 20,
		MAX_RUN_DISTANCE = 40,
		CLOSE_RANGE = 10,
		SMOOTHNESS_CLOSE = 0.05,
		SMOOTHNESS_FAR = 0.1,
		RAY_HEIGHT = 5,
		RAY_DEPTH = -10,
		ALTERNATIVE_OFFSETS = {
			Vector3.new(5, 0, 5),
			Vector3.new(-5, 0, 5),
			Vector3.new(5, 0, -5),
			Vector3.new(-5, 0, -5)
		}
	}

	local function GetRakeRoot()
		for _, rake in ipairs(collectionService:GetTagged("Rake")) do
			if rake.Parent then
				local root = rake:FindFirstChild("HumanoidRootPart")
				if root then
					return root
				end
			end
		end

		return nil
	end

	local function FindSafePosition(desiredPosition)
		local rayOrigin = desiredPosition + Vector3.new(0, Config.RAY_HEIGHT, 0)
		local rayDirection = Vector3.new(0, Config.RAY_DEPTH, 0)

		local collision = workspace:FindPartOnRayWithIgnoreList(
			Ray.new(rayOrigin, rayDirection),
			{ entitylib.character.Character }
		)

		if not collision then
			return desiredPosition
		end

		for _, offset in ipairs(Config.ALTERNATIVE_OFFSETS) do
			local altPosition = desiredPosition + offset
			local altRayOrigin = altPosition + Vector3.new(0, Config.RAY_HEIGHT, 0)

			local altCollision = workspace:FindPartOnRayWithIgnoreList(
				Ray.new(altRayOrigin, rayDirection),
				{ entitylib.character.Character }
			)

			if not altCollision then
				return altPosition
			end
		end

		return desiredPosition + Vector3.new(0, 2, 0)
	end

	local function RunAwayFromTarget(targetRoot)
		if not entitylib.isAlive then return end

		local humanoidRootPart = entitylib.character.RootPart
		local humanoid = entitylib.character.Humanoid
		if not (humanoidRootPart and humanoid) then return end

		if humanoid.SeatPart then
			humanoid.Sit = false
			task.wait(0.0001)
		end

		if not targetRoot.Parent then
			return
		end

		local targetPosition = targetRoot.Position
		local currentPosition = humanoidRootPart.Position
		local distance = (targetPosition - currentPosition).Magnitude

		if distance <= DetectionRange.Value then
			local runDistance = math.min(
				Config.MAX_RUN_DISTANCE,
				math.max(Config.MIN_RUN_DISTANCE, distance * 0.75)
			)

			local directionAwayFromTarget = (currentPosition - targetPosition).Unit
			local desiredPosition = currentPosition + (directionAwayFromTarget * runDistance)

			local safePosition = FindSafePosition(desiredPosition)

			local targetLook = CFrame.new(safePosition, targetPosition)
			local smoothness = distance < Config.CLOSE_RANGE and Config.SMOOTHNESS_CLOSE or Config.SMOOTHNESS_FAR

			if vape.ThreadFix then
				setthreadidentity(8)
			end

			humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(targetLook, smoothness)
			humanoid:MoveTo(safePosition)
		end
	end

	AntiRakeChase = vape.Categories.Blatant:CreateModule({
		Name = "AntiRakeChase",
		Function = function(callback)
			if callback then
				if entitylib.isAlive then
					local humanoid = entitylib.character.Humanoid
					OriginalWalkSpeed = humanoid.WalkSpeed
					humanoid.WalkSpeed = OriginalWalkSpeed * SpeedMultiplier.Value
				end

				AntiRakeChase:Clean(runService.Heartbeat:Connect(function()
					local targetRoot = GetRakeRoot()
					if targetRoot then
						RunAwayFromTarget(targetRoot)
					end
				end))

				AntiRakeChase:Clean(entitylib.Events.LocalAdded:Connect(function()
					if entitylib.isAlive and OriginalWalkSpeed then
						entitylib.character.Humanoid.WalkSpeed = OriginalWalkSpeed * SpeedMultiplier.Value
					end
				end))
			else
				if entitylib.isAlive and OriginalWalkSpeed then
					entitylib.character.Humanoid.WalkSpeed = OriginalWalkSpeed
				end

				OriginalWalkSpeed = nil
			end
		end,
		Tooltip = "Automatically runs away from the Rake whenever it's within range, like an invisible barrier.",
	})

	DetectionRange = AntiRakeChase:CreateSlider({
		Name = "Detection Range",
		Min = 10,
		Max = 100,
		Default = 50,
		Suffix = function(val)
			return val == 1 and "stud" or "studs"
		end,
		Tooltip = "How close the Rake needs to be before you start running away.",
	})

	SpeedMultiplier = AntiRakeChase:CreateSlider({
		Name = "Speed Multiplier",
		Min = 1,
		Max = 4,
		Default = 2,
		Decimal = 10,
		Suffix = "x",
		Function = function(val)
			if not AntiRakeChase.Enabled then
				return
			end

			if entitylib.isAlive and OriginalWalkSpeed then
				entitylib.character.Humanoid.WalkSpeed = OriginalWalkSpeed * val
			end
		end,
		Tooltip = "How much faster you move while running from the Rake.",
	})
end)

run(function() 
	local SpamSafehouseDoor

	local SafehouseDoor = map:WaitForChild("SafeHouse"):WaitForChild("Door")

	SpamSafehouseDoor = vape.Categories.Troll:CreateModule({
		Name = "SpamSafehouseDoor",
		Function = function(callback) 
			if callback then 
				repeat
					SafehouseDoor:WaitForChild("RemoteEvent"):FireServer("Door")
					task.wait()
				until not SpamSafehouseDoor.Enabled
			end
		end
	})
end)