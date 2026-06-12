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
	local ShowPath

	local Farming = false
	local CurrentToken = 0
	local FailedScraps = {}
	local FailCooldown = 5
	local TrapAvoidRadius = 8

	local TrapModifiers = {}
	local ModifierFolder = Instance.new("Folder")
	ModifierFolder.Name = "ScrapFarm_TrapAvoidance"

	local PathVisuals = {}
	local PathFolder = Instance.new("Folder")
	PathFolder.Name = "ScrapFarm_PathVisuals"
	PathFolder.Parent = vape.gui

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

	local function ClearPathVisuals()
		if vape.ThreadFix then
			setthreadidentity(8)
		end

		for _, part in ipairs(PathVisuals) do
			part:Destroy()
		end

		table.clear(PathVisuals)
	end

	local function DrawPathVisuals(waypoints)
		ClearPathVisuals()

		if vape.ThreadFix then
			setthreadidentity(8)
		end

		for i, wp in ipairs(waypoints) do
			local node = Instance.new("Part")
			node.Name = "PathNode"
			node.Shape = Enum.PartType.Ball
			node.Size = Vector3.new(0.6, 0.6, 0.6)
			node.Position = wp.Position
			node.Anchored = true
			node.CanCollide = false
			node.CanQuery = false
			node.CanTouch = false
			node.Material = Enum.Material.Neon
			node.Color = wp.Action == Enum.PathWaypointAction.Jump and Color3.new(1, 1, 0) or Color3.new(0, 1, 0.5)
			node.Parent = PathFolder

			PathVisuals[#PathVisuals + 1] = node

			if i > 1 then
				local prev = waypoints[i - 1]
				local distance = (wp.Position - prev.Position).Magnitude

				local line = Instance.new("Part")
				line.Name = "PathLine"
				line.Size = Vector3.new(0.15, 0.15, distance)
				line.CFrame = CFrame.new(prev.Position, wp.Position) * CFrame.new(0, 0, -distance / 2)
				line.Anchored = true
				line.CanCollide = false
				line.CanQuery = false
				line.CanTouch = false
				line.Material = Enum.Material.Neon
				line.Color = Color3.new(0, 1, 0.5)
				line.Parent = PathFolder

				PathVisuals[#PathVisuals + 1] = line
			end
		end
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
		local character = lplr.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
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

	local function WalkPathTo(targetPos, token)
		local character = lplr.Character
		if not character then return false end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local root = character:FindFirstChild("HumanoidRootPart")
		if not humanoid or not root then return false end

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
			warn("[ScrapFarm] ComputeAsync error:", err)
			return false
		end

		if path.Status ~= Enum.PathStatus.Success then
			if ShowPath.Enabled then
				ClearPathVisuals()
			end

			return false
		end

		local waypoints = path:GetWaypoints()

		if ShowPath.Enabled then
			DrawPathVisuals(waypoints)
		end

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

	ScrapFarm = vape.Categories.Blatant:CreateModule({
		Name = "ScrapFarm",
		Function = function(callback)
			if callback then
				Farming = true
				CurrentToken += 1
				local token = CurrentToken

				if AvoidTraps.Enabled then
					EnableTrapAvoidance()
				end

				task.spawn(function()
					while Farming and token == CurrentToken do
						local scrap = GetClosestScrap()

						if scrap then
							local pos = GetScrapPosition(scrap)

							if pos then
								local success = WalkPathTo(pos, token)

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
				ClearPathVisuals()

				local character = lplr.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					humanoid:Move(Vector3.zero)
				end
			end
		end,
		Tooltip = "Automatically walks to and collects the nearest tagged Scrap.",
	})

	AvoidTraps = ScrapFarm:CreateToggle({
		Name = "Avoid Traps",
		Default = true,
		Function = function(callback)
			if not Farming then
				return
			end

			if callback then
				EnableTrapAvoidance()
			else
				DisableTrapAvoidance()
			end
		end,
		Tooltip = "Treats tagged Traps as solid obstacles so pathfinding routes around them instead of through.",
	})

	ShowPath = ScrapFarm:CreateToggle({
		Name = "Show Path",
		Default = false,
		Function = function(callback)
			if not callback then
				ClearPathVisuals()
			end
		end,
		Tooltip = "Renders the current PathfindingService route as nodes and lines.",
	})
end)