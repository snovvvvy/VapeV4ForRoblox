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
local CannonCharging = Events.RemoteEvents:FindFirstChild("CannonCharging")

local Cash = 0
local cannonCooldownEnd = 0
local bankPriorityActive = false

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

local function randomString()
	local array = {}
	for i = 1, math.random(10, 100) do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
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
        table.clear(imageToUnit)
	end)
end)

run(function() 
	sessioninfo:AddItem("Cash", 0, function(val) 
		return Cash
	end, false)

    --[[sessioninfo:AddItem("Cannon Cooldown", 0, function(val) 
		return math.round(math.max(0, cannonCooldownEnd - tick()))
	end, false)]]

	vape:Clean(BattleInfo.OnClientEvent:Connect(function(val) 
		Cash = val or 0 
	end))

    vape:Clean(CannonCharging.OnClientEvent:Connect(function(duration)
		cannonCooldownEnd = tick() + (duration or 0)
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
		local mode = Mode.Value or "Cheapest"
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
        
                    if screen then
                        if bankPriorityActive then
                            task.wait(Rate.Value)
                            continue
                        end

                        local NPCText = screen.Info and screen.Info:FindFirstChild("NPCText")
        
                        local slot = getTargetSlot()
        
                        local npcs = NPCText and string.split(NPCText.Text:match("(%d+/%d+)"), "/")
                        local current = npcs and tonumber(npcs[1])
                        local max = npcs and tonumber(npcs[2])
        
                        if slot and current and max and current < max then
                            firesignal(slot.Activated)
                            if Notify.Enabled then
                                notif("AutoUnit", "Spawned " .. imageToUnit[slot.Image] and imageToUnit[slot.Image].Name or "" .. ".", 4)
                            end
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

run(function()
	local AutoBankPriority
	local Threshold

	local function getBankUpgradeCost(screen)
		local btn = screen:FindFirstChild("BankButton")
		if not btn or not btn.Active then return nil end
		local upg = btn:FindFirstChild("Upgrade")
		if not upg or upg.Text == "Maxed" then return nil end
		return tonumber((upg.Text:gsub("[%$ ,]", "")))
	end

	AutoBankPriority = vape.Categories.Blatant:CreateModule({
		Name = "AutoBankPriority",
		Function = function(callback)
			if callback then
				repeat
                    local screen = getBattleScreen()
                    if not screen then
                        bankPriorityActive = false
                        task.wait(0.1)
                        continue
                    end

                    local cost = getBankUpgradeCost(screen)
                    if not cost then
                        bankPriorityActive = false
                        task.wait(0.1)
                        continue
                    end
                    task.wait(0.1)
                    bankPriorityActive = Cash < cost and (cost - Cash) <= Threshold.Value
					task.wait(0.1)
				until not AutoBankPriority.Enabled
            else
                bankPriorityActive = false
			end
		end,
        Tooltip = "Automatically prioritizes bank upgrades.",
	})

	Threshold = AutoBankPriority:CreateSlider({
		Name = "Threshold",
		Min = 0,
		Max = 500,
		Default = 100,
		Tooltip = "How many dollars below the bank upgrade cost to start blocking unit spawns.",
	})
end)

run(function()
	local AutoCannon
    local Range
    local Notify

	local function getBlueBase()
		local n = workspace:FindFirstChild("NPCFolders")
		local bf = n and n:FindFirstChild("BaseFolder")
		return bf and bf:FindFirstChild("Blue Base")
	end

	local function getBasePos(base)
		if not base then return nil end
		return base:GetPrimaryPartCFrame()
			or (base:FindFirstChild("HumanoidRootPart") and base.HumanoidRootPart.CFrame)
			or (base:FindFirstChild("MainHitbox") and base.MainHitbox.CFrame)
	end

	local function isEnemyInRange(basePos, range)
		local npcFolder = workspace:FindFirstChild("NPCFolders")
		local enemyFolder = npcFolder and npcFolder:FindFirstChild("EnemyFolder")
		if not enemyFolder or not basePos then return false end
		for _, e in ipairs(enemyFolder:GetChildren()) do
			if e:IsA("Model") then
				local root = e:FindFirstChild("HumanoidRootPart") or e.PrimaryPart
				if root and (root.Position - basePos.Position).Magnitude <= range then
					return true
				end
			end
		end
		return false
	end

	AutoCannon = vape.Categories.Blatant:CreateModule({
		Name = "AutoCannon",
		Function = function(callback)
			if callback then
				repeat
					local screen = getBattleScreen()

					if screen then
						local cooldownRemaining = math.max(0, cannonCooldownEnd - tick())

						if cooldownRemaining <= 0 then
							local base = getBlueBase()
							local basePos = getBasePos(base)

							if basePos and isEnemyInRange(basePos, Range.Value) then
								local btn = screen:FindFirstChild("CannonButton")
								if btn and btn.Active then
									firesignal(btn.Activated)
                                    if Notify.Enabled then 
                                        notif("AutoCannon", "Fired the cannon.", 5)
                                    end
								end
							end
						end
					end

					task.wait(0.1)
				until not AutoCannon.Enabled
			end
		end,
        Tooltip = "Automatically fires the cannon when an enemy is within range."
	})

	Range = AutoCannon:CreateSlider({
		Name = "Range",
		Min = 5,
		Max = 100,
		Default = 30,
		Tooltip = "Distance from base an enemy must be within to fire the cannon.",
	})

    Notify = AutoCannon:CreateToggle({
		Name = "Notify",
	})
end)

run(function()
	local DPSDisplay
	local dpsLabels = {}

	local function getUnitDPS(unitData)
		if not unitData then return 0 end
		local dmg = unitData.Damage or 0
		local rate = unitData.AttackRate or 1
		if rate <= 0 then rate = 1 end
		return math.floor((dmg / rate) * 10) / 10
	end

	local function formatDPS(val)
		if val >= 1000 then
			return string.format("%.0f", val)
		elseif val >= 100 then
			return string.format("%.1f", val)
		else
			return string.format("%.2f", val)
		end
	end

	local function clearLabels()
		for _, label in pairs(dpsLabels) do
			label.Visible = false
			label.Parent = nil
		end
	end

	local function updateLabels(screen)
		local sm = getSpawnMenu()
		if not sm then
			clearLabels()
			return
		end

		for _, label in pairs(dpsLabels) do
			label.Visible = false
		end

		eachSlot(function(slot, i)
            if slot.Visible then 
                local label = dpsLabels[i]
                if not label then
                    label = Instance.new("TextLabel")
                    label.Name = randomString()
                    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    label.BackgroundTransparency = 0.4
                    label.TextColor3 = Color3.fromRGB(255, 220, 100)
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 11
                    label.BorderSizePixel = 0
                    label.ZIndex = 25
                    label.Size = UDim2.new(1, 0, 0, 16)
                    label.Position = UDim2.fromOffset(0, -18)
                    dpsLabels[i] = label
                end

                local unitData = imageToUnit[slot.Image]
                label.Text = unitData and (unitData.Name .. " " .. formatDPS(getUnitDPS(unitData)) .. " DPS") or "?"
                label.Parent = slot
                label.Visible = true
            end
        end)
	end

	DPSDisplay = vape.Categories.Render:CreateModule({
		Name = "DPSDisplay",
		Function = function(callback)
			if callback then
				clearLabels()
				repeat
					local screen = getBattleScreen()

					if screen then
						updateLabels(screen)
					else
						clearLabels()
					end

					task.wait(0.5)
				until not DPSDisplay.Enabled
            else
                clearLabels()
			end
		end,
		Tooltip = "Shows the DPS of each unit in your spawn menu.",
	})
end)