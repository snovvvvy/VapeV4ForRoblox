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
local bb = {}

local Events = replicatedStorage.Events
local BattleInfo = Events.RemoteEvents:FindFirstChild("BattleInfo")

local Cash = 0

local BattleScreen = lplr.PlayerGui:FindFirstChild("BattleScreen")
local PlayerSpawn = Events.RemoteFunction.PlayerSpawn

local function getSpawnMenu()
	if not BattleScreen then return nil end
	return BattleScreen:FindFirstChild("SpawnMenu")
		or BattleScreen:FindFirstChild("MobileSpawnMenu")
end

local function getSlotCost(slot)
	local costLabel = slot:FindFirstChild("CostText")
	if not costLabel then
		return math.huge
	end
	return tonumber(costLabel.Text:gsub("[%$ ,]", "")) or math.huge
end

local function eachSlot(callback)
	local menu = getSpawnMenu()
	if not menu then return end

	for i = 1, 8 do
		local bar = menu:FindFirstChild(i <= 4 and "Bar1" or "Bar2")
		local slot = bar and bar:FindFirstChild(("Slot%d"):format(i))

		if slot then
			callback(slot, i)
		end
	end
end

local function notif(...)
	return vape:CreateNotification(...)
end

entitylib.start()

run(function()
	local modules = replicatedStorage.Modules

	bb = {
		FriendlyNPCLibrary = require(modules.FriendlyNPCLibrary)
	}

	vape:Clean(function()
		table.clear(bb)
	end)
end)

run(function() 
	sessioninfo:AddItem("Cash", 0, function(val) 
		return Cash
	end)

	vape:Clean(BattleInfo.OnClientEvent:Connect(function(val) 
		Cash = val or 0 
	end))
end)

run(function()
	local AutoUnit
	local Unit
	local Cooldown

	local lastUnitSpawn = 0
	local unitCache = {}
	local slotToUnit = {}
	local imageToUnit = {}

    for _, entry in ipairs(bb.FriendlyNPCLibrary) do
        if type(entry) == "table" and entry.A then
            imageToUnit[entry.A.Image] = entry.A
        end
    end

	local function getUnits()
		local sm = getSpawnMenu()
		if not sm then return end

		local newCache = {}
		local newSlotMap = {}
		for i = 1, 8 do
			local bar = sm:FindFirstChild(i <= 4 and "Bar1" or "Bar2")
			local slot = bar and bar:FindFirstChild("Slot" .. i)
			if slot then
				local unitData = imageToUnit[slot.Image]
				local name = unitData and unitData.Name or nil
				local cost = getSlotCost(slot)
				if name then
					newCache[name] = {
						name = name,
						slotName = "Slot" .. i,
						cost = cost,
						slot = slot,
					}
					newSlotMap["Slot" .. i] = newCache[name]
				end
			end
		end
		unitCache = newCache
		slotToUnit = newSlotMap
		local names = {}
		for name in pairs(newCache) do
			table.insert(names, name)
		end
		table.sort(names)
		if #names > 0 then
			table.insert(names, 1, "Cheapest")
			Unit:Change(names)
		end
	end

	local function findCheapest()
		local bestSlot
		local bestCost = math.huge
		eachSlot(function(slot)
			if slot.Active then
				local cost = getSlotCost(slot)
				if cost <= Cash and cost < bestCost then
					bestCost = cost
					bestSlot = slot
				end
			end
		end)
		return bestSlot
	end

	local function findSlotForUnit(unitName)
		local found
		eachSlot(function(slot)
			local unitData = imageToUnit[slot.Image]
			if unitData and unitData.Name == unitName then
				found = slot
			end
		end)
		return found
	end

	local function spawnUnit()
		if not BattleScreen or not BattleScreen.Enabled then return end
		if next(unitCache) == nil then
			getUnits()
		end
		local now = tick()

		local selected = Unit and Unit.Value or "Cheapest"
		local targetSlot
		if selected == "Cheapest" then
			targetSlot = findCheapest()
		else
			targetSlot = findSlotForUnit(selected)
			if targetSlot then
				local cost = getSlotCost(targetSlot)
				if cost > Cash or not targetSlot.Active then
					targetSlot = nil
				end
			end
		end
		if targetSlot then
			task.spawn(function() firesignal(targetSlot.Activated) end)
			lastUnitSpawn = now
		end
	end

	AutoUnit = vape.Categories.Blatant:CreateModule({
		Name = "AutoUnit",
		Tooltip = "Automatically spawns a unit on cooldown.",
		Function = function(callback)
			if callback then
				if next(unitCache) == nil then
					getUnits()
				end

				repeat
					spawnUnit()
					task.wait(Cooldown.Value)
				until not AutoUnit.Enabled
			end
		end
	})

	Unit = AutoUnit:CreateDropdown({
		Name = "Unit",
		List = {"Cheapest"},
		Function = function()
			if AutoUnit.Enabled then
				AutoUnit:Toggle()
				AutoUnit:Toggle()
			end
		end,
        Tooltip = "Which unit to spawn"
	})

	Cooldown = AutoUnit:CreateSlider({
		Name = "Cooldown",
		Min = 0,
		Max = 10,
		Suffix = function() return "s" end,
		Default = 1,
		Decimal = 10,
		Tooltip = "Seconds between each spawn attempt",
	})

	vape:Clean(function()
		table.clear(unitCache)
		table.clear(slotToUnit)
		table.clear(imageToUnit)
		lastUnitSpawn = 0
	end)
end)