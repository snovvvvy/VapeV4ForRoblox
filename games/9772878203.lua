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

local function notif(...)
	return vape:CreateNotification(...)
end

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