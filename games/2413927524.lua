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
local sessioninfo = vape.Libraries.SessionInfo

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
end

for _, obj in ipairs(workspace.Debris.Traps:GetDescendants()) do
	tagObj(obj)
end

vape:Clean(workspace.Debris.Traps.DescendantAdded:Connect(tagObj))

for _, v in { "Reach", "Disabler", "Jesus", "Killaura", "MurderMystery", "SilentAim", "AimAssist" } do
	vape:Remove(v)
end

run(function() 
    local powerValues = replicatedStorage.PowerValues
    local powerLevel = powerValues.PowerLevel

    local power = vape.Libraries.SessionInfo:AddItem("Power", powerLevel.MaxValue, function(val) 
        return powerLevel.Value
    end, false)
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
    
        local ref = obj.HitBox
        local oldParent = ref.Parent
    
        ref.Parent = Folder
    
        Reference[obj] = {
            HitBox = ref,
            OriginalParent = oldParent
        }
    end
    
    local function Removed(obj)
        local ref = Reference[obj]
        if not ref then
            return
        end
    
        if vape.ThreadFix then
            setthreadidentity(8)
        end
    
        if ref.HitBox and ref.HitBox.OriginalParent == Folder then
            ref.HitBox.OriginalParent = ref.OriginalParent
        end
    end

	AntiTrap = vape.Categories.Render:CreateModule({
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
                    if data.HitBox then
                        data.HitBox.OriginalParent = data.OriginalParent
                    end
                end
                
                table.clear(Reference)
			end
		end,
	})
end)