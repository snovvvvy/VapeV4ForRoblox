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

local Unlock = remoteEvents:FindFirstChild("Unlock")

local floppa = workspace:FindFirstChild("Floppa")
local roommate = workspace.Unlocks:FindFirstChild("Roommate")

local Keyparts = workspace:FindFirstChild("Key Parts")

if not roommate then 
	Unlock:FireServer("Roommate", "the_interwebs")
	notif("Vape", "Bought the roommate for free.", 3)
	roommate = workspace.Unlocks:FindFirstChild("Roommate")
end

local RentAmount = roommate and roommate:FindFirstChild("Amt") or nil

local function notif(...)
	return vape:CreateNotification(...)
end

local function getTool(toolName)
	if not entitylib.isAlive then
		return nil
	end

	local backpack = lplr:FindFirstChild("Backpack")
	local character = lplr.Character

	return (backpack and backpack:FindFirstChild(toolName)) or (character and character:FindFirstChild(toolName))
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
				if obj.Parent == workspace then
					tag(obj, "MilkDelivery")
					break
				end

				current = current.Parent
			end
		end

		if obj.Name == "Meteorite" then
			current = obj.Parent

			while current do 
				if obj.Parent == workspace then
					tag(obj, "Meteorite")
					break
				end

				current = current.Parent
			end
		end

		if obj.Name == "Money" or obj.Name == "Money Bag" then 
			current = obj.Parent

			while current do 
				if obj.Parent == workspace then
					tag(obj, "Money")
					break
				end

				current = current.Parent
			end
		end

		if obj.Name == "Poop" then 
			current = obj.Parent

			while current do
				if obj.Parent.Name == "Litter Box" then
					tag(obj, "Poop")
					break
				end

				current = current.Parent
			end
		end

		if obj.Name == "Rent" then 
			current = obj.Parent

			while current do
				if obj.Parent == workspace then
					tag(obj, "Rent")
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
		Sound = require(modules.Sound),
		Recipes = require(modules.Recipes),
		Abbreviate = require(modules.Abbreviate),
		RoommateDialogue = lplr.PlayerScripts["Roommate Dialogue"]
	}

	vape:Clean(function()
		table.clear(raf2)
	end)
end)

run(function() 
	vape:CreateCategory({
		Name = 'Troll',
		Icon = getcustomasset('newvape/assets/new/troll.png'),
		Size = UDim2.fromOffset(14, 15)
	})
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
		Default = 10,
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

	AutoCollectMilkDelivery = vape.Categories.Minigames:CreateModule({
		Name = "AutoCollectMilkDelivery",
		Function = function(callback)
			if callback then 
				local old
				repeat
					if entitylib.isAlive then
						local success = true
						for _, v in collectionService:GetTagged("MilkDelivery") do
							if not old then
								old = entitylib.character.RootPart.CFrame
							end

							success = false
							entitylib.character.RootPart.CFrame = v.PrimaryPart.CFrame
							Collect(v)
							break
						end
	
						if success and old then
							entitylib.character.RootPart.CFrame = old
							old = nil
						end
					else
						old = nil
					end
	
					task.wait(0.2)
				until not AutoCollectMilkDelivery.Enabled
			end
		end,
		Tooltip = "Auto collects the milk delivery."
	})
end)

run(function() 
	local AutoPet
	local Threshold

	local Happiness = floppa.Configuration.Happiness
	local prompt = floppa.HumanoidRootPart.ProximityPrompt

	AutoPet = vape.Categories.Minigames:CreateModule({
		Name = "AutoPet",
		Function = function(callback)
			if callback then 
				local old
				repeat 
					if entitylib.isAlive then 
						local success = true
						if Happiness.Value <= Threshold.Value then -- should i use rounded version of Happiness? 
							if not old then
								old = entitylib.character.RootPart.CFrame
							end

							success = false
							entitylib.character.RootPart.CFrame = floppa.PrimaryPart.CFrame
							fireproximityprompt(prompt)
						end

						if success and old then
							entitylib.character.RootPart.CFrame = old
							old = nil
						end
					else
						old = nil
					end
					task.wait(0.2)
				until not AutoPet.Enabled
			end
		end,
		Tooltip = "Automatically pets the floppa when under or equal to a certain threshold."
	})

	Threshold = AutoPet:CreateSlider({
		Name = "Threshold",
		Min = 1,
		Max = 75,
		Default = 50
	})
end)

run(function() 
	local AutoCleanPoop

	local function CleanPoop(poop)
		local prompt = poop:FindFirstChildWhichIsA("ProximityPrompt")

		if prompt then 
			fireproximityprompt(prompt)
		end
	end

	AutoCleanPoop = vape.Categories.Minigames:CreateModule({
		Name = "AutoCleanPoop",
		Function = function(callback)
			if callback then 
				local old
				repeat
					if entitylib.isAlive then
						local success = true
						for _, v in collectionService:GetTagged("Poop") do
							if not old then
								old = entitylib.character.RootPart.CFrame
							end
							success = false
							if v:FindFirstChild("PoopPart") then 
								v:FindFirstChild("PoopPart").CanTouch = false
							end
							entitylib.character.RootPart.CFrame = v.PrimaryPart.CFrame
							CleanPoop(v)
							break
						end
	
						if success and old then
							entitylib.character.RootPart.CFrame = old
							old = nil
						end
					else
						old = nil
					end
	
					task.wait(0.4)
				until not AutoCleanPoop.Enabled
			end
		end,
		Tooltip = "Automatically cleans poop from the litter box."
	})
end)

if roommate then 
	run(function() 
		local LandLord
	
		local CanRaise = roommate:FindFirstChild("Can Raise")
		local CanCollect = roommate:FindFirstChild("Can Collect")
	
		local function Raise()
			if CanRaise.Value then 
				remoteEvents:FindFirstChild("Raise Rent"):FireServer()
				task.wait(0.1)
				notif("LandLord", "Raised the Roommate's rent to $" .. raf2.Abbreviate.Convert(RentAmount.Value) .. ".", 6)
			end
		end
	
		local function Collect()
			if CanCollect.Value then 
				remoteEvents:FindFirstChild("Collect Rent"):FireServer()
			end
		end
	
		LandLord = vape.Categories.Blatant:CreateModule({
			Name = "LandLord",
			Function = function(callback) 
				if callback then 
					LandLord:Clean(CanRaise:GetPropertyChangedSignal("Value"):Connect(Raise))
					LandLord:Clean(CanCollect:GetPropertyChangedSignal("Value"):Connect(Collect))
					Raise()
					Collect()
					repeat
						if entitylib.isAlive then
							for _, v in collectionService:GetTagged("Rent") do
								firetouchinterest(entitylib.character.RootPart, v, 0)
								firetouchinterest(entitylib.character.RootPart, v, 1)
								notif("LandLord", "Collected the Roommate's rent: $" .. raf2.Abbreviate.Convert(RentAmount.Value) .. ".", 6)
								break
							end
						end
		
						task.wait(0.4)
					until not LandLord.Enabled
				end
			end
		})
	end)
end

run(function() 
	local AutoCollectMoney

	AutoCollectMoney = vape.Categories.Minigames:CreateModule({
		Name = "AutoCollectMoney",
		Function = function(callback)
			if callback then 
				repeat
					if entitylib.isAlive then
						for _, v in collectionService:GetTagged("Money") do
							firetouchinterest(entitylib.character.RootPart, v, true)
							firetouchinterest(entitylib.character.RootPart, v, false)
							break
						end
					end
	
					task.wait(0.1)
				until not AutoCollectMoney.Enabled
			end
		end,
		Tooltip = "Automatically collects money."
	})
end)

run(function() 
	local AutoFillBowl

	local BowlPart = Keyparts.Bowl:FindFirstChild("Part")

	local function FillBowl(old) 
		if not getTool("Floppa Food") then 
			Unlock:FireServer("Floppa Food", "the_interwebs")
		end
		entitylib.character.Humanoid:EquipTool(getTool("Floppa Food"))
		task.wait(0.067) -- funny number because why not
		entitylib.character.RootPart.CFrame = BowlPart.CFrame
		task.wait(0.1)
		fireproximityprompt(BowlPart:FindFirstChildWhichIsA("ProximityPrompt"))
		task.wait(0.2)
		entitylib.character.RootPart.CFrame = old
	end

	AutoFillBowl = vape.Categories.Minigames:CreateModule({
		Name = "AutoFillBowl",
		Function = function(callback)
			if callback then 
				local old
				repeat
					if entitylib.isAlive then
						if BowlPart.Transparency ~= 0 then 
							old = entitylib.character.RootPart.CFrame
							FillBowl(old)
						end
					else
						old = nil
					end
					task.wait(0.4)
				until not AutoFillBowl.Enabled
			end
		end,
		Tooltip = "Automatically fills the floppa's bowl"
	})
end)

run(function()
    local Chef
    local Menu
    local FoodMarket = workspace.Village:FindFirstChild("FoodMarket")
    local Cooking = remoteEvents:FindFirstChild("Cooking")
    local Stove = Keyparts:FindFirstChild("Stove")
    local StovePrimary = Stove.Parts:FindFirstChild("Primary")

    local inventoryOnly = {
        Milk = true,
        Meteorite = true,
        ["Dragon Egg"] = true,
        Flopptonium = true,
        Bomb = true,
        Carrot = true,
        Lettuce = true
    }

    local temperatures = {
        ["Grilled Cheese"] = 3,
        ["Vegetable Soup"] = 1,
        Burger = 2,
        Cake = 1,
        ["Space Soup"] = 1,
        ["Mega Breakfast"] = 3,
    }

    local function getRecipeNames(recipes)
        local names = {}
        for recipeName in pairs(recipes) do
            names[#names + 1] = recipeName
        end
        return names
    end

    local function buyItem(item)
        local prompt
        if item == "Sugar" or item == "Bread" or item == "Flour" then
            prompt = FoodMarket[item .. " Crate"].Crate["Empty Display Crate"].Primary:FindFirstChildWhichIsA("ProximityPrompt")
        else
            local marketItem = FoodMarket:FindFirstChild(item)
            if not marketItem then
                notif("Chef", item .. " could not be found in the Food Market.", 10, "warning")
                return false
            end
            prompt = marketItem:FindFirstChildWhichIsA("ProximityPrompt")
        end
        local old = entitylib.character.RootPart.CFrame
        entitylib.character.RootPart.CFrame = prompt.Parent.CFrame * CFrame.new(1, 0, 0)
        task.wait(0.5)
        fireproximityprompt(prompt)
        task.wait(0.5)
        entitylib.character.RootPart.CFrame = old
        return true
    end

    local function checkInventoryRequirements(ingredients)
        local missing = {}
        for _, ingredient in ipairs(ingredients) do
            if inventoryOnly[ingredient] and not getTool(ingredient) then
                missing[#missing + 1] = ingredient
            end
        end
        return #missing == 0, missing
    end

    Chef = vape.Categories.Blatant:CreateModule({
        Name = "Chef",
        Function = function(callback)
            if callback then
                local selectedRecipe = Menu.Value
                local recipe = raf2.Recipes[selectedRecipe]

                if recipe and recipe.Ingredients then
                    local ready, missing = checkInventoryRequirements(recipe.Ingredients)

                    if not ready then
                        for _, ingredient in ipairs(missing) do
                            local suffix = (ingredient == "Milk") and " (Get this from the milk man)" or ""
                            notif("Chef", ingredient .. " is required to be in your inventory for this recipe." .. suffix, 10, "warning")
                        end
                        Chef:Toggle()
                        return
                    end

                    for i = 1, 4 do
                        Cooking:FireServer("Remove Ingredient", i)
                    end

                    local old = entitylib.character.RootPart.CFrame
                    local failed = false

                    for _, ingredient in ipairs(recipe.Ingredients) do
                        local tool = getTool(ingredient)

                        if not tool then
                            local bought = buyItem(ingredient)
                            if not bought then
                                failed = true
                                break
                            end
                            tool = getTool(ingredient)
                        end

                        entitylib.character.Humanoid:EquipTool(tool)
                        task.wait(0.5)
                        entitylib.character.RootPart.CFrame = StovePrimary.CFrame * CFrame.new(0, 0, 1)
                        task.wait(0.5)
                        fireproximityprompt(StovePrimary:FindFirstChildWhichIsA("ProximityPrompt"))
                        task.wait(0.5)
                    end

                    entitylib.character.RootPart.CFrame = old

                    if not failed then
                        Cooking:FireServer("Change Temperature", temperatures[selectedRecipe])
                        Cooking:FireServer("Cook")
                    end
                end

                Chef:Toggle()
            end
        end,
        Tooltip = "Cooks any recipe for you.",
		ExtraText = function() 
			return Menu.Value
		end
    })

    Menu = Chef:CreateDropdown({
        Name = "Menu",
        List = getRecipeNames(raf2.Recipes)
    })
end)

run(function() 
    local RoommateDialogue
    local Dialogues
    local oldt = {}
    local Dialog = workspace.Unlocks.Roommate.Head.Dialog
    local connections = getconnections(Dialog.DialogChoiceSelected)
    local t = debug.getupvalue(connections[1].Function, 8)

    RoommateDialogue = vape.Categories.Minigames:CreateModule({
        Name = "RoommateDialogue",
        Function = function(callback)
            if callback then
                table.move(t, 1, #t, 1, oldt)
                table.clear(t)
                for i, v in ipairs(Dialogues.ListEnabled) do
                    t[i] = v
                end
            else
                table.clear(t)
                for i, v in ipairs(oldt) do
                    t[i] = v
                end
                table.clear(oldt)
            end
        end,
        Tooltip = "Change the roommate's initial dialogue. (might work)"
    })

    Dialogues = RoommateDialogue:CreateTextList({
        Name = 'Dialogues',
        Function = function() 
			if RoommateDialogue.Enabled then 
				RoommateDialogue:Toggle()
				RoommateDialogue:Toggle()
			end
		end,
        Placeholder = 'Dialogue',
        Tooltip = 'Enter the custom dialogues here.'
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

run(function() 
	local THEOVENISONFIRE

	local oldHeat, oldSize, oldEnabled

	local oven = Keyparts.Stove:FindFirstChild("Oven")
	local fire = oven:FindFirstChildWhichIsA("Fire")

	local function bigFire(fire) 
		fire.Enabled = true
		fire.Heat = 25
		fire.Size = 30
	end

	THEOVENISONFIRE = vape.Categories.Troll:CreateModule({
		Name = "THEOVENISONFIRE",
		Function = function(callback)
			if callback then 
				if fire then
					oldHeat = fire.Heat
					oldSize = fire.Size
					oldEnabled = fire.Enabled

					bigFire(fire)
					THEOVENISONFIRE:Clean(fire:GetPropertyChangedSignal("Enabled"):Connect(function() 
						bigFire(fire)
					end))
				end
			else
				fire.Enabled = oldEnabled or false
				fire.Heat = oldHeat or 2
				fire.Size = oldSize or 5
			end
		end,
		Tooltip = "THE OVEN IS ON FIRE"
	})
end)