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
local imageToUnit = {}

local Events = replicatedStorage.Events
local BattleInfo = Events.RemoteEvents:FindFirstChild("BattleInfo")

local Cash = 0

local PlayerSpawn = Events.RemoteFunction.PlayerSpawn

local function getBattleScreen()
	local screen = lplr.PlayerGui:FindFirstChild("BattleScreen")
	if screen and screen.Enabled then
		return screen
	end
	return nil
end

local function getSpawnMenu()
	local screen = getBattleScreen()
	if not screen then return nil end
	return screen:FindFirstChild("SpawnMenu")
		or screen:FindFirstChild("MobileSpawnMenu")
end

local function getSlotCost(slot)
	local costLabel = slot:FindFirstChild("CostText")
	if not costLabel then
		return math.huge
	end
	return tonumber((costLabel.Text:gsub("[%$ ,]", ""))) or math.huge
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

    for _, entry in ipairs(bb.FriendlyNPCLibrary) do
        if type(entry) == "table" and entry.A then
            imageToUnit[entry.A.Image] = entry.A
        end
    end

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
	local Mode
    local Rate
	local Notify

	local function getCheapestSlot()
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

	local function getMostExpensiveSlot()
		local bestSlot
		local bestCost = -math.huge

		eachSlot(function(slot)
			if slot.Active then
				local cost = getSlotCost(slot)
				if cost <= Cash and cost > bestCost then
					bestCost = cost
					bestSlot = slot
				end
			end
		end)

		return bestSlot
	end

	local function getTargetSlot()
		local mode = Mode and Mode.Value or "Cheapest"
		if mode == "Most Expensive" then
			return getMostExpensiveSlot()
		end
		return getCheapestSlot()
	end

	AutoUnit = vape.Categories.Blatant:CreateModule({
        Name = "AutoUnit",
        Function = function(callback)
            if callback then
                repeat
                    local screen = getBattleScreen()
                    print("screen:", screen)
        
                    if screen then
                        local NPCText = screen.Info and screen.Info:FindFirstChild("NPCText")
                        print("NPCText:", NPCText, NPCText and NPCText.Text)
                        print("raw NPCText:", NPCText.Text)
        
                        local slot = getTargetSlot()
                        print("slot:", slot)
        
                        local npcs = NPCText and string.split(NPCText.Text, "/")
                        local current = npcs and tonumber(npcs[1])
                        local max = npcs and tonumber(npcs[2])
                        print("current:", current, "max:", max)
        
                        if slot and current and max and current < max then
                            firesignal(slot.Activated)
                            print("fired!")
                        end
                    end
        
                    task.wait(Rate.Value)
                until not AutoUnit.Enabled
            end
        end,
        Tooltip = "Automatically spawns a unit."
    })

	Mode = AutoUnit:CreateDropdown({
		Name = "Mode",
		List = {"Cheapest", "Most Expensive"},
		Tooltip = "Which unit to prioritize when auto spawning.",
	})

    Rate = AutoUnit:CreateSlider({
		Name = "Rate",
        Min = 0.1,
        Max = 5,
		Tooltip = "The rate of checking and spawning a unit.",
        Default = 1,
        Decimal = 10
	})

	Notify = AutoUnit:CreateToggle({
		Name = "Notify",
	})
end)

run(function()
    local AutoBank
    local Rate
    local Notify

    AutoBank = vape.Categories.Blatant:CreateModule({
        Name = "AutoBank",
        Function = function(callback)
            if callback then
                repeat
                    local screen = getBattleScreen()
    
                    if screen then
                        local btn = screen:FindFirstChild("BankButton")
                        if btn and btn.Active then
                            local upg = btn:FindFirstChild("Upgrade")

                            if upg and upg.Text ~= "Maxed" then
                                local cost = tonumber((upg.Text:gsub("[%$ ,]", "")))

                                if cost and Cash >= cost then
                                    task.spawn(function()
                                        firesignal(btn.Activated)
                                        if Notify.Enabled then 
                                            notif("AutoBank", "Bought " .. upg.Text .. " bank.", 5)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                    task.wait(Rate.Value)
                until not AutoBank.Enabled
            end
        end,
        Tooltip = "Automatically buys bank upgrades."
    })

    Rate = AutoBank:CreateSlider({
		Name = "Rate",
        Min = 0.1,
        Max = 5,
		Tooltip = "The rate of checking and buying a bank upgrade.",
        Default = 0.5,
        Decimal = 10
	})

    Notify = AutoBank:CreateToggle({
		Name = "Notify",
	})
end)