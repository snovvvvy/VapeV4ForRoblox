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

-- granny multiplayer chapter 1

run(function() 
	local function tag(obj, tag)
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
	
		if obj.Name == "Granny" then
			current = obj.Parent
	
			while current do
				if current:IsA("Model") and current.Name == "Locks" then
					tag(obj, "Granny")
					break
				end
	
				current = current.Parent
			end
		end
	
		if obj.Name == "Open" and obj:FindFirstChild("BeartrapHumanoid") then
			tag(obj, "Trap")
		end
	
		if obj:FindFirstChild("InteractRemote") then
			local current = obj.Parent
	
			while current do
				if current:IsA("Model") and current.Name:lower():find("preset") then
					SafeTag(obj, "Item")
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
end)

for _, v in { "Reach", "Disabler", "Jesus", "Killaura", "MurderMystery", "SilentAim", "AimAssist" } do
	vape:Remove(v)
end

run(function()
	local GrannyESP
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

	local function IsGranny(obj)
		if not obj then
			return false
		end

		if obj.Name ~= "Granny" then
			return false
		end

		local current = obj.Parent

		while current do
			if current:IsA("Model") and current.Name == "Locks" then
				return true
			end

			current = current.Parent
		end

		return false
	end

	local function CreateLabel(obj)
		local text = "Granny"
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

	GrannyESP = vape.Categories.Render:CreateModule({
		Name = "GrannyESP",
		Function = function(callback)
			if callback then
				GrannyESP:Clean(collectionService:GetInstanceAddedSignal("Granny"):Connect(Added))
				GrannyESP:Clean(collectionService:GetInstanceRemovedSignal("Granny"):Connect(Removed))

				for _, obj in ipairs(collectionService:GetTagged("Granny")) do
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
		Tooltip = "Adds a cham to granny."
	})

	FillColor = GrannyESP:CreateColorSlider({
		Name = "Color",
		Function = function(hue, sat, val)
			for _, data in pairs(Reference) do
				data.Cham.FillColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	OutlineColor = GrannyESP:CreateColorSlider({
		Name = "Outline Color",
		DefaultSat = 0,
		Function = function(hue, sat, val)
			for _, data in pairs(Reference) do
				data.Cham.OutlineColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	FillTransparency = GrannyESP:CreateSlider({
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

	OutlineTransparency = GrannyESP:CreateSlider({
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

	ShowLabels = GrannyESP:CreateToggle({
		Name = "Nametags",
		Default = true,
		Function = function(callback)
			if not GrannyESP.Enabled then
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
		Tooltip = "Shows a nametag on granny.",
	})

	FontOption = GrannyESP:CreateFont({
		Name = "Label Font",
		Blacklist = "Arial",
		Function = function()
			if GrannyESP.Enabled then
				GrannyESP:Toggle()
				GrannyESP:Toggle()
			end
		end,
	})

	LabelColor = GrannyESP:CreateColorSlider({
		Name = "Label Color",
		Function = function(hue, sat, val)
			for _, data in pairs(Reference) do
				if data.Label then
					data.Label.TextLabel.TextColor3 = Color3.fromHSV(hue, sat, val)
				end
			end
		end,
	})

	LabelScale = GrannyESP:CreateSlider({
		Name = "Label Scale",
		Default = 1,
		Min = 0.1,
		Max = 1.5,
		Decimal = 10,
		Function = function()
			if GrannyESP.Enabled then
				GrannyESP:Toggle()
				GrannyESP:Toggle()
			end
		end,
	})

	LabelBackground = GrannyESP:CreateSlider({
		Name = "Label Transparency",
		Default = 0.5,
		Min = 0,
		Max = 1,
		Decimal = 10,
		Function = function()
			if GrannyESP.Enabled then
				GrannyESP:Toggle()
				GrannyESP:Toggle()
			end
		end,
	})
end)