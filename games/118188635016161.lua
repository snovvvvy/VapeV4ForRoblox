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

local function notif(...)
	return vape:CreateNotification(...)
end

for _, v in { "Reach", "Invisible", "Disabler", "Killaura", "MurderMystery", "SilentAim", "AimAssist" } do
	vape:Remove(v)
end

run(function()
	local AutoParry
	local Chance
    local PerfectParry

	AutoParry = vape.Categories.Blatant:CreateModule({
		Name = "AutoParry",
		Function = function(callback)
			if callback then
                repeat
                    if math.random() * 100 <= Chance.Value then
                        lplr:SetAttribute("ParryActiveTime", 0.3)
                    else
                        lplr:SetAttribute("ParryActiveTime", 0)
                    end
                    entitylib.character.Character:SetAttribute("PerfectParrying", PerfectParry.Enabled)
                    task.wait(0.1)
                until not AutoParry.Enabled
			end
		end,
		Tooltip = "Automatically parries attacks."
	})

	Chance = AutoParry:CreateSlider({
		Name = "Chance",
		Min = 1,
		Max = 100,
        Suffix = function()
            return '%'
        end,
		Default = 100
	})

    PerfectParry = AutoParry:CreateToggle({
		Name = "Perfect Parry",
	})
end)

run(function() 
	local SpoofWeapon
    local Weapon

    local oldWeapon

	SpoofWeapon = vape.Categories.Blatant:CreateModule({
		Name = "SpoofWeapon",
		Function = function(callback)
			if callback then 
                oldWeapon = lplr:GetAttribute("Weapon")

                lplr:SetAttribute("Weapon", Weapon.Value)
            else
                lplr:SetAttribute("Weapon", oldWeapon)
			end
		end,
		Tooltip = "Spoofs your current weapon's animation.",
        ExtraText = function()
			return Weapon.Value
		end
	})

    Weapon = SpoofWeapon:CreateDropdown({
        Name = "Weapon",
        List = {"Buster", "Katana", "Staff", "Nothing"},
        Function = function() 
            if SpoofWeapon.Enabled then 
                SpoofWeapon:Toggle()
                SpoofWeapon:Toggle()
            end
        end,
    })
end)

run(function() 
	local DisableEffects

	local EffectsFolder = workspace:WaitForChild("EffectsFolder")

	local function remove(instance)
		task.defer(function()
			if instance.Parent and not instance:IsA("Folder") then
				instance:Destroy()
			end
		end)
	end

	DisableEffects = vape.Categories.World:CreateModule({
		Name = "DisableEffects",
		Function = function(callback)
			if callback then 
				for _, obj in ipairs(EffectsFolder:GetDescendants()) do
					remove(obj)
				end

				DisableEffects:Clean(EffectsFolder.DescendantAdded:Connect(remove))
			end
		end,
		Tooltip = "Attempts to destroy all the effects in the game. [BETA]"
	})
end)