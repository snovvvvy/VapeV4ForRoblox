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
		Size = UDim2.fromOffset(14, 15)
	})
end)

run(function()
	local RakeESP
	local FillColor
	local OutlineColor
	local FillTransparency
	local OutlineTransparency
	local ShowLabels
	local FontOption
	local LabelColor
	local LabelScale
	local LabelBackground

	local Reference = {}
	local Folder = Instance.new("Folder")
	Folder.Parent = vape.gui

	local LabelFolder = Instance.new("Folder")
	LabelFolder.Parent = vape.gui

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

	local function CreateLabel(obj)
		local text = "Rake"
		local tagSize = getfontsize(text, 14 * LabelScale.Value, FontOption.Value, Vector2.new(100000, 100000))

		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.fromOffset(tagSize.X + 8, tagSize.Y + 7)
		billboard.StudsOffset = Vector3.new(0, 5, 0)
		billboard.AlwaysOnTop = true
		billboard.Adornee = obj
		billboard.Parent = LabelFolder

		local tag = Instance.new("TextLabel")
		tag.BackgroundColor3 = Color3.new()
		tag.BorderSizePixel = 0
		tag.Visible = true
		tag.RichText = true
		tag.FontFace = FontOption.Value
		tag.TextSize = 14 * LabelScale.Value
		tag.BackgroundTransparency = LabelBackground.Value
		tag.Size = billboard.Size
		tag.Text = text
		tag.TextColor3 = Color3.fromHSV(LabelColor.Hue, LabelColor.Sat, LabelColor.Value)
		tag.Parent = billboard

		return billboard
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

		local label = ShowLabels.Enabled and CreateLabel(obj) or nil

		Reference[obj] = {
			Cham = cham,
			Label = label,
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

		data.Cham:Destroy()

		if data.Label then
			data.Label:Destroy()
		end

		Reference[obj] = nil
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
				for _, data in pairs(Reference) do
					data.Cham:Destroy()

					if data.Label then
						data.Label:Destroy()
					end
				end

				table.clear(Reference)
			end
		end,
		Tooltip = "Adds a cham to the rake."
	})

	FillColor = RakeESP:CreateColorSlider({
		Name = "Color",
		Function = function(hue, sat, val)
			for _, data in pairs(Reference) do
				data.Cham.FillColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	OutlineColor = RakeESP:CreateColorSlider({
		Name = "Outline Color",
		DefaultSat = 0,
		Function = function(hue, sat, val)
			for _, data in pairs(Reference) do
				data.Cham.OutlineColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	FillTransparency = RakeESP:CreateSlider({
		Name = "Transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Function = function(val)
			for _, data in pairs(Reference) do
				data.Cham.FillTransparency = val
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
			for _, data in pairs(Reference) do
				data.Cham.OutlineTransparency = val
			end
		end,
		Decimal = 10,
	})

	ShowLabels = RakeESP:CreateToggle({
		Name = "Nametags",
		Default = true,
		Function = function(callback)
			if not RakeESP.Enabled then
				return
			end

			for obj, data in pairs(Reference) do
				if callback then
					if not data.Label then
						data.Label = CreateLabel(obj)
					end
				else
					if data.Label then
						data.Label:Destroy()
						data.Label = nil
					end
				end
			end
			FontOption.Object.Visible = callback
			LabelColor.Object.Visible = callback
			LabelScale.Object.Visible = callback
			LabelBackground.Object.Visible = callback
		end,
		Tooltip = "Shows a nametag on the Rake.",
	})

	FontOption = RakeESP:CreateFont({
		Name = "Label Font",
		Blacklist = "Arial",
		Function = function()
			if RakeESP.Enabled then
				RakeESP:Toggle()
				RakeESP:Toggle()
			end
		end,
	})

	LabelColor = RakeESP:CreateColorSlider({
		Name = "Label Color",
		Function = function(hue, sat, val)
			for _, data in pairs(Reference) do
				if data.Label then
					data.Label.TextLabel.TextColor3 = Color3.fromHSV(hue, sat, val)
				end
			end
		end,
	})

	LabelScale = RakeESP:CreateSlider({
		Name = "Label Scale",
		Default = 1,
		Min = 0.1,
		Max = 1.5,
		Decimal = 10,
		Function = function()
			if RakeESP.Enabled then
				RakeESP:Toggle()
				RakeESP:Toggle()
			end
		end,
	})

	LabelBackground = RakeESP:CreateSlider({
		Name = "Label Transparency",
		Default = 0.5,
		Min = 0,
		Max = 1,
		Decimal = 10,
		Function = function()
			if RakeESP.Enabled then
				RakeESP:Toggle()
				RakeESP:Toggle()
			end
		end,
	})
end)

run(function()
	local SupplyCrateESP
	local FillColor
	local OutlineColor
	local FillTransparency
	local OutlineTransparency
	local ShowLabels
	local FontOption
	local LabelColor
	local LabelScale
	local LabelBackground

	local Reference = {}
	local Folder = Instance.new("Folder")
	Folder.Parent = vape.gui

	local LabelFolder = Instance.new("Folder")
	LabelFolder.Parent = vape.gui

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

	local function CreateLabel(obj)
		local text = "Supply Crate"
		local tagSize = getfontsize(text, 14 * LabelScale.Value, FontOption.Value, Vector2.new(100000, 100000))

		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.fromOffset(tagSize.X + 8, tagSize.Y + 7)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = true
		billboard.Adornee = obj
		billboard.Parent = LabelFolder

		local tag = Instance.new("TextLabel")
		tag.BackgroundColor3 = Color3.new()
		tag.BorderSizePixel = 0
		tag.Visible = true
		tag.RichText = true
		tag.FontFace = FontOption.Value
		tag.TextSize = 14 * LabelScale.Value
		tag.BackgroundTransparency = LabelBackground.Value
		tag.Size = billboard.Size
		tag.Text = text
		tag.TextColor3 = Color3.fromHSV(LabelColor.Hue, LabelColor.Sat, LabelColor.Value)
		tag.Parent = billboard

		return billboard
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

		local label = ShowLabels.Enabled and CreateLabel(obj) or nil

		Reference[obj] = {
			Cham = cham,
			Label = label,
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

		data.Cham:Destroy()

		if data.Label then
			data.Label:Destroy()
		end

		Reference[obj] = nil
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
				for _, data in pairs(Reference) do
					data.Cham:Destroy()

					if data.Label then
						data.Label:Destroy()
					end
				end

				table.clear(Reference)
			end
		end,
	})

	FillColor = SupplyCrateESP:CreateColorSlider({
		Name = "Color",
		Function = function(hue, sat, val)
			for _, data in pairs(Reference) do
				data.Cham.FillColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	OutlineColor = SupplyCrateESP:CreateColorSlider({
		Name = "Outline Color",
		DefaultSat = 0,
		Function = function(hue, sat, val)
			for _, data in pairs(Reference) do
				data.Cham.OutlineColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	FillTransparency = SupplyCrateESP:CreateSlider({
		Name = "Transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Function = function(val)
			for _, data in pairs(Reference) do
				data.Cham.FillTransparency = val
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
			for _, data in pairs(Reference) do
				data.Cham.OutlineTransparency = val
			end
		end,
		Decimal = 10,
	})

	ShowLabels = SupplyCrateESP:CreateToggle({
		Name = "Nametags",
		Default = true,
		Function = function(callback)
			if not SupplyCrateESP.Enabled then
				return
			end

			for obj, data in pairs(Reference) do
				if callback then
					if not data.Label then
						data.Label = CreateLabel(obj)
					end
				else
					if data.Label then
						data.Label:Destroy()
						data.Label = nil
					end
				end
			end
			FontOption.Object.Visible = callback
			LabelColor.Object.Visible = callback
			LabelScale.Object.Visible = callback
			LabelBackground.Object.Visible = callback
		end,
		Tooltip = "Shows a nametag on each Supply Crate.",
	})

	FontOption = SupplyCrateESP:CreateFont({
		Name = "Label Font",
		Blacklist = "Arial",
		Function = function()
			if SupplyCrateESP.Enabled then
				SupplyCrateESP:Toggle()
				SupplyCrateESP:Toggle()
			end
		end,
	})

	LabelColor = SupplyCrateESP:CreateColorSlider({
		Name = "Label Color",
		Function = function(hue, sat, val)
			for _, data in pairs(Reference) do
				if data.Label then
					data.Label.TextLabel.TextColor3 = Color3.fromHSV(hue, sat, val)
				end
			end
		end,
	})

	LabelScale = SupplyCrateESP:CreateSlider({
		Name = "Label Scale",
		Default = 1,
		Min = 0.1,
		Max = 1.5,
		Decimal = 10,
		Function = function()
			if SupplyCrateESP.Enabled then
				SupplyCrateESP:Toggle()
				SupplyCrateESP:Toggle()
			end
		end,
	})

	LabelBackground = SupplyCrateESP:CreateSlider({
		Name = "Label Transparency",
		Default = 0.5,
		Min = 0,
		Max = 1,
		Decimal = 10,
		Function = function()
			if SupplyCrateESP.Enabled then
				SupplyCrateESP:Toggle()
				SupplyCrateESP:Toggle()
			end
		end,
	})
end)

run(function()
	local ScrapESP
	local FillColor
	local OutlineColor
	local FillTransparency
	local OutlineTransparency
	local ShowLabels
	local FontOption
	local LabelColor
	local LabelScale
	local LabelBackground

	local Reference = {}
	local Folder = Instance.new("Folder")
	Folder.Parent = vape.gui

	local LabelFolder = Instance.new("Folder")
	LabelFolder.Parent = vape.gui

	local function IsAScrap(obj)
		if not obj then
			return false
		end

		if not obj.Name:find("Scrap") then
			return false
		end

		if not obj:IsA("Model") then 
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

	local function CreateLabel(obj)
		local name = string.match(obj.Name, "%a+")
		local level = string.match(obj.Name, "%d+")

		local text = name .. " (Lv. " .. level .. ")"
		local tagSize = getfontsize(text, 14 * LabelScale.Value, FontOption.Value, Vector2.new(100000, 100000))

		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.fromOffset(tagSize.X + 8, tagSize.Y + 7)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = true
		billboard.Adornee = obj
		billboard.Parent = LabelFolder

		local tag = Instance.new("TextLabel")
		tag.BackgroundColor3 = Color3.new()
		tag.BorderSizePixel = 0
		tag.Visible = true
		tag.RichText = true
		tag.FontFace = FontOption.Value
		tag.TextSize = 14 * LabelScale.Value
		tag.BackgroundTransparency = LabelBackground.Value
		tag.Size = billboard.Size
		tag.Text = text
		tag.TextColor3 = Color3.fromHSV(LabelColor.Hue, LabelColor.Sat, LabelColor.Value)
		tag.Parent = billboard

		return billboard
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

		local label = ShowLabels.Enabled and CreateLabel(obj) or nil

		Reference[obj] = {
			Cham = cham,
			Label = label,
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

		data.Cham:Destroy()

		if data.Label then
			data.Label:Destroy()
		end

		Reference[obj] = nil
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
				for _, data in pairs(Reference) do
					data.Cham:Destroy()

					if data.Label then
						data.Label:Destroy()
					end
				end

				table.clear(Reference)
			end
		end,
	})

	FillColor = ScrapESP:CreateColorSlider({
		Name = "Color",
		Function = function(hue, sat, val)
			for _, data in pairs(Reference) do
				data.Cham.FillColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	OutlineColor = ScrapESP:CreateColorSlider({
		Name = "Outline Color",
		DefaultSat = 0,
		Function = function(hue, sat, val)
			for _, data in pairs(Reference) do
				data.Cham.OutlineColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	FillTransparency = ScrapESP:CreateSlider({
		Name = "Transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Function = function(val)
			for _, data in pairs(Reference) do
				data.Cham.FillTransparency = val
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
			for _, data in pairs(Reference) do
				data.Cham.OutlineTransparency = val
			end
		end,
		Decimal = 10,
	})

	ShowLabels = ScrapESP:CreateToggle({
		Name = "Nametags",
		Default = true,
		Function = function(callback)
			if not ScrapESP.Enabled then
				return
			end

			for obj, data in pairs(Reference) do
				if callback then
					if not data.Label then
						data.Label = CreateLabel(obj)
					end
				else
					if data.Label then
						data.Label:Destroy()
						data.Label = nil
					end
				end
			end
			FontOption.Object.Visible = callback
			LabelColor.Object.Visible = callback
			LabelScale.Object.Visible = callback
			LabelBackground.Object.Visible = callback
		end,
		Tooltip = "Shows a nametag on each scrap.",
	})

	FontOption = ScrapESP:CreateFont({
		Name = "Label Font",
		Blacklist = "Arial",
		Function = function()
			if ScrapESP.Enabled then
				ScrapESP:Toggle()
				ScrapESP:Toggle()
			end
		end,
	})

	LabelColor = ScrapESP:CreateColorSlider({
		Name = "Label Color",
		Function = function(hue, sat, val)
			for _, data in pairs(Reference) do
				if data.Label then
					data.Label.TextLabel.TextColor3 = Color3.fromHSV(hue, sat, val)
				end
			end
		end,
	})

	LabelScale = ScrapESP:CreateSlider({
		Name = "Label Scale",
		Default = 1,
		Min = 0.1,
		Max = 1.5,
		Decimal = 10,
		Function = function()
			if ScrapESP.Enabled then
				ScrapESP:Toggle()
				ScrapESP:Toggle()
			end
		end,
	})

	LabelBackground = ScrapESP:CreateSlider({
		Name = "Label Transparency",
		Default = 0.5,
		Min = 0,
		Max = 1,
		Decimal = 10,
		Function = function()
			if ScrapESP.Enabled then
				ScrapESP:Toggle()
				ScrapESP:Toggle()
			end
		end,
	})
end)

run(function()
	local TrapESP
	local FillColor
	local OutlineColor
	local FillTransparency
	local OutlineTransparency
	local ShowLabels
	local FontOption
	local LabelColor
	local LabelScale
	local LabelBackground

	local Reference = {}
	local Folder = Instance.new("Folder")
	Folder.Parent = vape.gui

	local LabelFolder = Instance.new("Folder")
	LabelFolder.Parent = vape.gui

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

	local function CreateLabel(obj)
		local text = "Trap"
		local tagSize = getfontsize(text, 14 * LabelScale.Value, FontOption.Value, Vector2.new(100000, 100000))

		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.fromOffset(tagSize.X + 8, tagSize.Y + 7)
		billboard.StudsOffset = Vector3.new(0, 2, 0)
		billboard.AlwaysOnTop = true
		billboard.Adornee = obj
		billboard.Parent = LabelFolder

		local tag = Instance.new("TextLabel")
		tag.BackgroundColor3 = Color3.new()
		tag.BorderSizePixel = 0
		tag.Visible = true
		tag.RichText = true
		tag.FontFace = FontOption.Value
		tag.TextSize = 14 * LabelScale.Value
		tag.BackgroundTransparency = LabelBackground.Value
		tag.Size = billboard.Size
		tag.Text = text
		tag.TextColor3 = Color3.fromHSV(LabelColor.Hue, LabelColor.Sat, LabelColor.Value)
		tag.Parent = billboard

		return billboard
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

		local label = ShowLabels.Enabled and CreateLabel(obj) or nil

		Reference[obj] = {
			Cham = cham,
			Label = label,
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

		data.Cham:Destroy()

		if data.Label then
			data.Label:Destroy()
		end

		Reference[obj] = nil
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
				for _, data in pairs(Reference) do
					data.Cham:Destroy()

					if data.Label then
						data.Label:Destroy()
					end
				end

				table.clear(Reference)
			end
		end,
	})

	FillColor = TrapESP:CreateColorSlider({
		Name = "Color",
		Function = function(hue, sat, val)
			for _, data in pairs(Reference) do
				data.Cham.FillColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	OutlineColor = TrapESP:CreateColorSlider({
		Name = "Outline Color",
		DefaultSat = 0,
		Function = function(hue, sat, val)
			for _, data in pairs(Reference) do
				data.Cham.OutlineColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	FillTransparency = TrapESP:CreateSlider({
		Name = "Transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Function = function(val)
			for _, data in pairs(Reference) do
				data.Cham.FillTransparency = val
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
			for _, data in pairs(Reference) do
				data.Cham.OutlineTransparency = val
			end
		end,
		Decimal = 10,
	})

	ShowLabels = TrapESP:CreateToggle({
		Name = "Nametags",
		Default = true,
		Function = function(callback)
			if not TrapESP.Enabled then
				return
			end

			for obj, data in pairs(Reference) do
				if callback then
					if not data.Label then
						data.Label = CreateLabel(obj)
					end
				else
					if data.Label then
						data.Label:Destroy()
						data.Label = nil
					end
				end
			end
			FontOption.Object.Visible = callback
			LabelColor.Object.Visible = callback
			LabelScale.Object.Visible = callback
			LabelBackground.Object.Visible = callback
		end,
		Tooltip = "Shows a nametag on each trap.",
	})

	FontOption = TrapESP:CreateFont({
		Name = "Label Font",
		Blacklist = "Arial",
		Function = function()
			if TrapESP.Enabled then
				TrapESP:Toggle()
				TrapESP:Toggle()
			end
		end,
	})

	LabelColor = TrapESP:CreateColorSlider({
		Name = "Label Color",
		Function = function(hue, sat, val)
			for _, data in pairs(Reference) do
				if data.Label then
					data.Label.TextLabel.TextColor3 = Color3.fromHSV(hue, sat, val)
				end
			end
		end,
	})

	LabelScale = TrapESP:CreateSlider({
		Name = "Label Scale",
		Default = 1,
		Min = 0.1,
		Max = 1.5,
		Decimal = 10,
		Function = function()
			if TrapESP.Enabled then
				TrapESP:Toggle()
				TrapESP:Toggle()
			end
		end,
	})

	LabelBackground = TrapESP:CreateSlider({
		Name = "Label Transparency",
		Default = 0.5,
		Min = 0,
		Max = 1,
		Decimal = 10,
		Function = function()
			if TrapESP.Enabled then
				TrapESP:Toggle()
				TrapESP:Toggle()
			end
		end,
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
	local NoFall
	local event

	local Reference = {}
	local folder = Instance.new("Folder")
	folder.Parent = vape.gui

	NoFall = vape.Categories.Blatant:CreateModule({
		Name = "NoFall",
		Function = function(callback) 
			if callback then
				event = replicatedStorage:FindFirstChild("FD_Event")

				if event then
					event.Parent = folder
				else
					notif("NoFall", "FD_Event not found in ReplicatedStorage.", 10, "warning")
				end
			else
				if folder:FindFirstChild("FD_Event") then 
					folder:FindFirstChild("FD_Event").Parent = replicatedStorage
				end
			end
		end,
		Tooltip = "Disables fall damage."
	})
end)

run(function() 
	local SafehouseDoor
	local Mode

	local safehouseDoor = map:WaitForChild("SafeHouse"):WaitForChild("Door")

	SafehouseDoor = vape.Categories.Troll:CreateModule({
		Name = "SafehouseDoor",
		Function = function(callback) 
			if callback then 
				if Mode.Value == "Spam" then 
					repeat
						safehouseDoor:WaitForChild("RemoteEvent"):FireServer("Door")
						task.wait()
					until not SafehouseDoor.Enabled
				else
					safehouseDoor:WaitForChild("RemoteEvent"):FireServer("Door")
					SafehouseDoor:Toggle()
				end
			end
		end,
		Tooltip = "Toggles/spams the safehouse door, even when you are outside the safehouse.\n(only works when you are near the safehouse)"
	})

	Mode = SafehouseDoor:CreateDropdown({
		Name = "Mode",
		List = {"Toggle", "Spam"},
		Function = function(val) 
			if SafehouseDoor.Enabled then 
				SafehouseDoor:Toggle()
				SafehouseDoor:Toggle()
			end
		end
	})
end)