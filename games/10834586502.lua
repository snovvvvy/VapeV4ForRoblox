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

		if slot and slot.Activated then
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
	local Notify

    local function getCheapestSlot()
        local bestSlot
        local bestCost = math.huge
        eachSlot(function(slot)
			local cost = getSlotCost(slot)

			if cost <= c and cost < bestCost then
				bestCost = cost
				bestSlot = slot
			end
        end)
        return bestSlot
    end

	AutoUnit = vape.Categories.Blatant:CreateModule({
		Name = "AutoUnit",
		Function = function(callback)
			if callback then
				repeat
					local slot = getCheapestSlot()

                    if slot then
                        firesignal(slot.Activated)
                    end

                    task.wait(1)
				until not AutoUnit.Enabled
			end
		end,
		Tooltip = "Automatically spawns the cheapest unit."
	})

    Notify = AutoUnit:CreateToggle({
        Name = "Notify",
    })
end)