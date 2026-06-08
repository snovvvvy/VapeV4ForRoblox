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

local remoteEvents = replicatedStorage:WaitForChild("RemoteEvents")

local assetfunction = getcustomasset

local vape = shared.vape
local tween = vape.Libraries.tween
local targetinfo = vape.Libraries.targetinfo
local getfontsize = vape.Libraries.getfontsize
local getcustomasset = vape.Libraries.getcustomasset
local uipallet = vape.Libraries.uipallet
local entitylib = vape.Libraries.entity

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

local function GiveTool(tool)
	remoteEvents:WaitForChild("GiveTool"):FireServer(tool)
end

local function getPlayersList()
    local t = {}

    for _, v in pairs(playersService:GetPlayers()) do
        if v.Name ~= lplr.Name then
            table.insert(t, v.Name)
        end
    end

    return t
end

-- break in game

run(function()
	local GiveItem
	local Item

	local itemList = {
		"Apple",
		"Bat",
		"BloxyCola",
		"CarKey",
		"Chips",
		"Cookie",
		"Cure",
		"Epic Pizza",
		"ExpiredBloxyCola",
		"LinkedSword",
		"Lollipop",
		"Medkit",
		"Pan",
		"Pie",
		"Pizza3",
		"Plank",
		"TeddyBloxpin",
	}

	GiveItem = vape.Categories.Inventory:CreateModule({
		Name = "GiveItem",
		Function = function(callback)
			if callback then
				if not entitylib.isAlive then
					return
				end

				local item = Item.Value

				GiveTool(item)
				GiveItem:Toggle()
			end
		end,
		Tooltip = "Gives you an item from the game.",
	})

	Item = GiveItem:CreateDropdown({
		Name = "Item",
		List = itemList,
		Function = function(val) end,
		Tooltip = "The item to give yourself.",
	})
end)

run(function()
	local QuickPlanks

	QuickPlanks = vape.Categories.Inventory:CreateModule({
		Name = "QuickPlanks",
		Function = function(callback)
			if callback then
				if not entitylib.isAlive then
					return
				end

				remoteEvents:WaitForChild("RefreshPlanks"):FireServer()

				QuickPlanks:Toggle()
			end
		end,
		Tooltip = "Gives you planks to use on the windows.\nUseful if you wanna bind it to a key and press it to quickly get planks.",
	})
end)

run(function()
	local BefriendCat

	BefriendCat = vape.Categories.Blatant:CreateModule({
		Name = "BefriendCat",
		Function = function(callback)
			if callback then
				if not entitylib.isAlive then
					return
				end

				remoteEvents:WaitForChild("Cattery"):FireServer()

				BefriendCat:Toggle()
			end
		end,
		Tooltip = "Befriends the cat in the game.",
	})
end)

run(function()
	local HealSelf

	HealSelf = vape.Categories.Blatant:CreateModule({
		Name = "HealSelf",
		Function = function(callback)
			if callback then
				if not entitylib.isAlive then
					return
				end

				remoteEvents:WaitForChild("HealPlayer"):FireServer(lplr.Name)
				remoteEvents:WaitForChild("CurePlayer"):FireServer(lplr.Name)

				HealSelf:Toggle()
			end
		end,
		Tooltip = "Heals yourself in the game.",
	})
end)

run(function()
	local HealPlayer
	local Player

	HealPlayer = vape.Categories.Blatant:CreateModule({
		Name = "HealPlayer",
		Function = function(callback)
			if callback then
				if not entitylib.isAlive then
					return
				end

				local plr = Player.Value

				remoteEvents:WaitForChild("HealPlayer"):FireServer(plr.Name)
				remoteEvents:WaitForChild("CurePlayer"):FireServer(plr.Name)

				Player:Change(getPlayersList())
				HealPlayer:Toggle()
			end
		end,
		Tooltip = "Heals a player in the game.",
	})
	Player = HealPlayer:CreateDropdown({
		Name = "Player",
		List = getPlayersList(),
		Function = function(val) end,
		Tooltip = "The player to heal.",
	})
end)

run(function()
	local UnlockBasement

	UnlockBasement = vape.Categories.Blatant:CreateModule({
		Name = "UnlockBasement",
		Function = function(callback)
			if callback then
				if not entitylib.isAlive then
					return
				end

				remoteEvents:WaitForChild("UnlockDoor"):FireServer()

				UnlockBasement:Toggle()
			end
		end,
		Tooltip = "Unlocks the basement in the game.",
	})
end)

run(function()
	local UnlockSafe

	UnlockSafe = vape.Categories.Blatant:CreateModule({
		Name = "UnlockSafe",
		Function = function(callback)
			if callback then
				if not entitylib.isAlive then
					return
				end

				remoteEvents:WaitForChild("Safe"):FireServer(tostring(workspace.CodeNote.SurfaceGui.TextLabel.Text))

				UnlockSafe:Toggle()
			end
		end,
		Tooltip = "Unlocks the safe in the game.",
	})
end)

run(function()
	local AutoEnergy

	AutoEnergy = vape.Categories.Blatant:CreateModule({
		Name = "AutoEnergy",
		Function = function(callback)
			if callback then
				if not entitylib.isAlive then
					return
				end

				repeat
					remoteEvents:WaitForChild("Energy"):FireServer("Cat")
					task.wait(0.1)
				until not AutoEnergy.Enabled or not entitylib.isAlive
			end
		end,
	})
end)

run(function()
	local AutoKillBadGuys

	local badGuys = workspace:WaitForChild("BadGuys")

	AutoKillBadGuys = vape.Categories.Blatant:CreateModule({
		Name = "AutoKillBadGuys",
		Function = function(callback)
			if callback then
				if not entitylib.isAlive then
					return
				end
                
				local conn
				conn = badGuys.ChildAdded:Connect(function(v)
					task.spawn(function()
						repeat
							remoteEvents.HitBadguy:FireServer(v, 10)
                            task.wait()
                            remoteEvents.HitBadguy:FireServer(v, 8)
							task.wait()
						until not AutoKillBadGuys.Enabled
							or not entitylib.isAlive
                            or not v
                            or not v.Parent
					end)
				end)
                AutoKillBadGuys:Clean(conn)
			end
		end,
	})
end)

run(function() 
    local KillPlayer
    local Player

    KillPlayer = vape.Categories.Blatant:CreateModule({
        Name = "KillPlayer",
        Function = function(callback)
            if callback then
                if not entitylib.isAlive then
                    return
                end

                local plr = Player.Value

                remoteEvents:WaitForChild("ToxicDrown"):FireServer(1, plr)

                Player:Change(getPlayersList())
                KillPlayer:Toggle()
            end
        end,
        Tooltip = "Kills a player in the game.",
    })

    Player = KillPlayer:CreateDropdown({
        Name = "Player",
        List = getPlayersList(),
        Function = function(val) end,
        Tooltip = "The player to kill.",
    })
end)

run(function()
    local MakeStealth
    local StealthTime

    MakeStealth = vape.Categories.Blatant:CreateModule({
        Name = "MakeStealth",
        Function = function(callback)
            if callback then
                if not entitylib.isAlive then
                    return
                end

                remoteEvents:WaitForChild("MakeStealth"):FireServer(StealthTime.Value)

                MakeStealth:Toggle()
            end
        end,
        Tooltip = "Makes you stealthy for __ seconds. (requires TeddyBloxpin)",
    })

    StealthTime = MakeStealth:CreateSlider({
        Name = "StealthTime",
        Min = 1,
        Max = 120,
        Function = function(val) end,
        Tooltip = "The amount of seconds to be stealthy for.",
    })
end)