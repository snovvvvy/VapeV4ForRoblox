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

local raf2 = {}

local modules = replicatedStorage:FindFirstChild("Modules")
local remoteEvents = replicatedStorage:FindFirstChild("Events")

local floppa = workspace:FindFirstChild("Floppa")

local function notif(...)
	return vape:CreateNotification(...)
end

local function getTool()
	return lplr.Character and lplr.Character:FindFirstChildWhichIsA('Tool', true) or nil
end

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
	
		if obj.Name == "Milk Delivery" then
			current = obj.Parent
	
			while current do
				if current == workspace then
					tag(obj, "MilkDelivery")
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

run(function()
	raf2 = {
		Sound = require(modules.Sound)
	}

	vape:Clean(function()
		table.clear(raf2)
	end)
end)

entitylib.start()

run(function() 
	local AutoClicker

	local clickDetector = floppa:FindFirstChildWhichIsA("ClickDetector")

	AutoClicker = vape.Categories.Blatant:CreateModule({
		Name = "AutoClicker",
		Function = function(callback)
			if callback then 
				repeat
					fireclickdetector(clickDetector)
					task.wait()
				until not AutoClicker.Enabled
			end
		end,
		Tooltip = "Autoclicks the floppa."
	})
end)

run(function() 
	local AutoSave
	local Interval

	AutoSave = vape.Categories.Blatant:CreateModule({
		Name = "AutoSave",
		Function = function(callback)
			if callback then 
				repeat
					remoteEvents:FindFirstChild("Save"):FireServer()
					task.wait(Interval.Value)
				until not AutoSave.Enabled
			end
		end,
		Tooltip = "Automatically saves your game after x amount of seconds."
	})

	Interval = AutoSave:CreateSlider({
		Name = "Interval",
		Min = 1,
		Max = 60,
		Suffix = function(val)
			return val == 1 and 'second' or 'seconds'
		end,
		Tooltip = "The interval to save every x amount of seconds"
	})
end)

run(function() 
	local AutoCollectMilkDelivery

	local function Collect(obj)
		local prompt = obj.Crate:FindFirstChildWhichIsA("ProximityPrompt")

		if prompt then 
			fireproximityprompt(prompt)
		end
	end

	AutoCollectMilkDelivery = vape.Categories.Blatant:CreateModule({
		Name = "AutoCollectMilkDelivery",
		Function = function(callback)
			if callback then 
				AutoCollectMilkDelivery:Clean(collectionService:GetInstanceAddedSignal("MilkDelivery"):Connect(Collect))
		
				for _, obj in ipairs(collectionService:GetTagged("MilkDelivery")) do
					Collect(obj)
				end
			end
		end,
		Tooltip = "Auto collects the milk delivery."
	})
end)

run(function()
	local PlaySound
	local Sound

    local module = getscriptclosure(modules.Sound)()
	local upvalues = debug.getupvalues(module.Play)

    local soundsTable

    for i, v in pairs(upvalues) do
        if type(v) == "table" then
            soundsTable = v
            break
        end
    end

    local soundNames = {}
    for name in pairs(soundsTable) do
        table.insert(soundNames, name)
    end

    PlaySound = vape.Categories.Utility:CreateModule({
        Name = "PlaySound",
        Function = function(callback)
            if callback then
                raf2.Sound.Play(Sound.Value)
				PlaySound:Toggle()
            end
        end,
        Tooltip = "Plays a specific sound of choice (from the game)."
    })

    Sound = PlaySound:CreateDropdown({
        Name = "Sound",
        List = soundNames
    })
end)