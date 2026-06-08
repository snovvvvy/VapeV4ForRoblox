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

local function SafeTag(obj, tag)
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

for _, obj in ipairs(playerGui:GetDescendants()) do
	if obj.Name == "FallSystem" and obj:FindFirstChild("FallSignal") then
		SafeTag(obj, "NoFall")
	end
end

playerGui.DescendantAdded:Connect(function(obj)
	if obj.Name == "FallSystem" and obj:FindFirstChild("FallSignal") then
		SafeTag(obj, "NoFall")
	end
end)

for _, obj in ipairs(workspace:GetDescendants()) do
	if obj.Name == "Granny" then
		SafeTag(obj, "GrannyESP")
	end

	if obj.Name == "Open" and obj:FindFirstChild("BeartrapHumanoid") then
		SafeTag(obj, "BearTrap")
	end

	if obj:FindFirstChildWhichIsA("ParticleEmitter") then
		local current = obj.Parent

		while current do
			if current:IsA("Model") and current.Name:lower():find("preset") then
				SafeTag(obj, "ItemESP")
				break
			end

			current = current.Parent
		end
	end
end

workspace.DescendantAdded:Connect(function(obj)
	if obj.Name == "Granny" then
		SafeTag(obj, "GrannyESP")
	end

	if obj.Name == "Open" and obj:FindFirstChild("BeartrapHumanoid") then
		SafeTag(obj, "BearTrap")
	end

	if obj:FindFirstChildWhichIsA("ParticleEmitter") then
		local current = obj.Parent

		while current do
			if current:IsA("Model") and current.Name:lower():find("preset") then
				SafeTag(obj, "ItemESP")
				break
			end

			current = current.Parent
		end
	end
end)

for _, v in { "Reach", "Invisible", "Disabler", "Jesus", "Killaura", "MurderMystery", "SilentAim", "AimAssist" } do
	vape:Remove(v)
end

run(function()
	local GrannyESP
	local FillColor
	local OutlineColor
	local FillTransparency
	local OutlineTransparency

	local Reference = {}
	local Folder = Instance.new("Folder")
	Folder.Parent = vape.gui

	local function IsGranny(obj)
		if not obj then
			return false
		end

		if obj.Name ~= "Granny" then
			return false
		end

		return true
	end

	local function Added(obj)
		if Reference[obj] or not IsGranny(obj) then
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

	local function Scan()
		for _, obj in workspace:GetDescendants() do
			if IsGranny(obj) then
				task.spawn(Added, obj)
			end
		end
	end

	GrannyESP = vape.Categories.Render:CreateModule({
		Name = "GrannyESP",
		Function = function(callback)
			if callback then
				GrannyESP:Clean(collectionService:GetInstanceAddedSignal("GrannyESP"):Connect(Added))
				GrannyESP:Clean(collectionService:GetInstanceRemovedSignal("GrannyESP"):Connect(Removed))

				for _, obj in ipairs(collectionService:GetTagged("GrannyESP")) do
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

	FillColor = GrannyESP:CreateColorSlider({
		Name = "Color",
		Function = function(hue, sat, val)
			for _, v in pairs(Reference) do
				v.FillColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	OutlineColor = GrannyESP:CreateColorSlider({
		Name = "Outline Color",
		DefaultSat = 0,
		Function = function(hue, sat, val)
			for _, v in pairs(Reference) do
				v.OutlineColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	FillTransparency = GrannyESP:CreateSlider({
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

	OutlineTransparency = GrannyESP:CreateSlider({
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
	local ItemESP
	local FillColor
	local OutlineColor
	local FillTransparency
	local OutlineTransparency

	local Reference = {}
	local Folder = Instance.new("Folder")
	Folder.Parent = vape.gui

	local function IsAnItem(obj)
		if not obj then
			return false
		end

		if not obj:FindFirstChild("InteractRemote") then
			return false
		end

		local current = obj.Parent

		while current do
			if current:IsA("Model") and (current.Name:lower():find("preset") or current.Name:lower() == "general items") then
				return true
			end

			current = current.Parent
		end

		return false
	end

	local function Added(obj)
        if Reference[obj] or not IsAnItem(obj) then
            return
        end

        local cham = Instance.new('Highlight')
        cham.Adornee = obj
        cham.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        cham.FillColor = Color3.fromHSV(FillColor.Hue, FillColor.Sat, FillColor.Value)
        cham.OutlineColor = Color3.fromHSV(OutlineColor.Hue, OutlineColor.Sat, OutlineColor.Value)
        cham.FillTransparency = FillTransparency.Value
        cham.OutlineTransparency = OutlineTransparency.Value
        cham.Parent = Folder

        local billboard = Instance.new("BillboardGui")
        billboard.Name = randomString()
        billboard.Adornee = obj
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.fromOffset(200, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.MaxDistance = 150
        billboard.Parent = cham

        local text = Instance.new("TextLabel")
        text.BackgroundTransparency = 1
        text.Size = UDim2.fromScale(1, 1)
        text.Font = Enum.Font.SourceSansBold
        text.Text = obj.Name
        text.TextColor3 = Color3.new(1, 1, 1)
        text.TextStrokeTransparency = 0
        text.TextScaled = true
        text.Parent = billboard

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

	local function Scan()
		for _, obj in workspace:GetDescendants() do
			if IsAnItem(obj) then
				task.spawn(Added, obj)
			end
		end
	end

	ItemESP = vape.Categories.Render:CreateModule({
		Name = "ItemESP",
		Function = function(callback)
			if callback then
				ItemESP:Clean(collectionService:GetInstanceAddedSignal("ItemESP"):Connect(Added))
				ItemESP:Clean(collectionService:GetInstanceRemovedSignal("ItemESP"):Connect(Removed))

				for _, obj in ipairs(collectionService:GetTagged("ItemESP")) do
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

	FillColor = ItemESP:CreateColorSlider({
		Name = "Color",
		Function = function(hue, sat, val)
			for _, v in pairs(Reference) do
				v.FillColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	OutlineColor = ItemESP:CreateColorSlider({
		Name = "Outline Color",
		DefaultSat = 0,
		Function = function(hue, sat, val)
			for _, v in pairs(Reference) do
				v.OutlineColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	FillTransparency = ItemESP:CreateSlider({
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

	OutlineTransparency = ItemESP:CreateSlider({
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
	local AntiBearTrap

	local Reference = {}

	local function IsABearTrap(obj)
		if not obj then
			return false
		end

		if obj.Name ~= "Open" then
			return false
		end

		return obj:FindFirstChild("BeartrapHumanoid") and true or false
	end

	local function Added(obj)
		if Reference[obj] or not IsABearTrap(obj) then
			return
		end

		obj.CanCollide = false
		obj.CanTouch = false

		Reference[obj] = obj
	end

	local function Removed(obj)
		if Reference[obj] then
			if vape.ThreadFix then
				setthreadidentity(8)
			end

			Reference[obj].CanCollide = true
			Reference[obj].CanTouch = true

			Reference[obj] = nil
		end
	end

	AntiBearTrap = vape.Categories.Blatant:CreateModule({
		Name = "AntiBearTrap",
		Function = function(callback)
			if callback then
				AntiBearTrap:Clean(collectionService:GetInstanceAddedSignal("BearTrap"):Connect(Added))
				AntiBearTrap:Clean(collectionService:GetInstanceRemovedSignal("BearTrap"):Connect(Removed))

				for _, obj in ipairs(collectionService:GetTagged("BearTrap")) do
					Added(obj)
				end
			else
				for _, v in pairs(Reference) do
					v.CanCollide = true
					v.CanTouch = true
				end

				table.clear(Reference)
			end
		end,
	})
end)

run(function()
	local NoFall

	local Reference = {}

	local function Added(obj)
		if Reference[obj] then
			return
		end

		obj.Enabled = false
		Reference[obj] = obj
	end

	local function Removed(obj)
		if not Reference[obj] then
			return
		end

		obj.Enabled = true
		Reference[obj] = nil
	end

	NoFall = vape.Categories.Blatant:CreateModule({
		Name = "NoFall",
		Function = function(callback)
			if callback then
				NoFall:Clean(collectionService:GetInstanceAddedSignal("NoFall"):Connect(Added))

				NoFall:Clean(collectionService:GetInstanceRemovedSignal("NoFall"):Connect(Removed))

				for _, obj in ipairs(collectionService:GetTagged("NoFall")) do
					Added(obj)
				end
			else
				for _, obj in pairs(Reference) do
					obj.Enabled = true
				end

				table.clear(Reference)
			end
		end,
	})
end)
