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
	local GetWeapon
	local Weapon

	local WeaponsFolder = workspace:FindFirstChild("Weapons")

	local WeaponsList = function()
		local t = { "All" }

		for _, v in ipairs(WeaponsFolder:GetChildren()) do
			table.insert(t, v.Name)
		end

		return t
	end

	GetWeapon = vape.Categories.Inventory:CreateModule({
		Name = "GetWeapon",
		Function = function(callback)
			if callback then
				if entitylib.isAlive then
					if Weapon.Value ~= "All" then
						firetouchinterest(
							entitylib.character.RootPart,
							WeaponsFolder:FindFirstChild(Weapon.Value).Hitbox,
							0
						)
						firetouchinterest(
							entitylib.character.RootPart,
							WeaponsFolder:FindFirstChild(Weapon.Value).Hitbox,
							1
						)
					else
						for _, v in ipairs(WeaponsFolder:GetChildren()) do
							task.spawn(function() 
                                firetouchinterest(entitylib.character.RootPart, v.Hitbox, 0)
							    firetouchinterest(entitylib.character.RootPart, v.Hitbox, 1)
                            end)
						end
					end
                    notif("GetWeapon", "Sucessfully got " .. Weapon.Value .. "!", 3)
				else
					notif("GetWeapon", "You cannot get a weapon when you are dead.", 5, "warning")
				end
				GetWeapon:Toggle()
			end
		end,
		Tooltip = "Get whatever weapon you want.",
	})

	Weapon = GetWeapon:CreateDropdown({
		Name = "Weapon",
		List = WeaponsList(),
		Function = function(val) end,
		Tooltip = "Select what weapon you want to get.",
	})
end)

run(function()
	local AutoReplenishAmmo

	local TouchInterest = workspace.AREA51.PlantRoom["Box of Shells"].Box
	local AmmoLeft = lplr.PlayerGui.Ammo.AmmoLeft

	local AmmoChanged = AmmoLeft:GetPropertyChangedSignal("Text")

	local function ReplenishAmmo()
		firetouchinterest(entitylib.character.RootPart, TouchInterest, 0)
		firetouchinterest(entitylib.character.RootPart, TouchInterest, 1)
	end

	AutoReplenishAmmo = vape.Categories.Inventory:CreateModule({
		Name = "InfAmmo",
		Function = function(callback)
			if callback then
				AutoReplenishAmmo:Clean(AmmoChanged:Connect(ReplenishAmmo))
			end
		end,
	})
end)

run(function()
	local NoWeaponRecoil
	local module, old

	NoWeaponRecoil = vape.Categories.Blatant:CreateModule({
		Name = "NoWeaponRecoil",
		Function = function(callback)
			if callback then
				if not module then
					local suc = pcall(function()
						module = require(replicatedStorage:FindFirstChild("Weapon"))
					end)
					if not suc then
						module = {}
					end
				end
				old = module.move_camera
				module.move_camera = function(...) end
			else
				if module and old then
					module.move_camera = old
				end
			end
		end,
	})
end)
