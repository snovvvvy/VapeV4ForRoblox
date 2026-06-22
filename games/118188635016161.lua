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

local enemyFolder = workspace:FindFirstChild("EnemyFolder")

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

local keyMap = { -- idk if there is a better way to do this :sob:
	A = 0x41, B = 0x42, C = 0x43, D = 0x44, E = 0x45, F = 0x46, G = 0x47,
	H = 0x48, I = 0x49, J = 0x4A, K = 0x4B, L = 0x4C, M = 0x4D, N = 0x4E,
	O = 0x4F, P = 0x50, Q = 0x51, R = 0x52, S = 0x53, T = 0x54, U = 0x55,
	V = 0x56, W = 0x57, X = 0x58, Y = 0x59, Z = 0x5A,
    
	Zero = 0x30, One = 0x31, Two = 0x32, Three = 0x33, Four = 0x34,
	Five = 0x35, Six = 0x36, Seven = 0x37, Eight = 0x38, Nine = 0x39,
	Space = 0x20, LeftShift = 0xA0, RightShift = 0xA1,
	LeftControl = 0xA2, RightControl = 0xA3,
	LeftAlt = 0xA4, RightAlt = 0xA5,
	Tab = 0x09, Return = 0x0D, Escape = 0x1B, Backspace = 0x08,
	Up = 0x26, Down = 0x28, Left = 0x25, Right = 0x27,
	F1 = 0x70, F2 = 0x71, F3 = 0x72, F4 = 0x73, F5 = 0x74, F6 = 0x75,
	F7 = 0x76, F8 = 0x77, F9 = 0x78, F10 = 0x79, F11 = 0x7A, F12 = 0x7B,
}

run(function()
	local taggedObjects = {}

	local function tag(obj, tagName)
		if collectionService:HasTag(obj, tagName) then
			return
		end

		if vape.ThreadFix then
			setthreadidentity(8)
		end

		local success = pcall(function()
			collectionService:AddTag(obj, tagName)
		end)

		if success then
			taggedObjects[obj] = taggedObjects[obj] or {}
			taggedObjects[obj][tagName] = true
		end
	end

	local function isValidWorldObject(obj)
		if not obj then return false end

		if not obj:IsDescendantOf(workspace) then
			return false
		end

		if lplr then
			local backpack = lplr:FindFirstChild("Backpack")
			local character = lplr.Character

			if backpack and obj:IsDescendantOf(backpack) then
				return false
			end

			if character and obj:IsDescendantOf(character) then
				return false
			end
		end

		return true
	end

	local function tagObj(obj)
		if not obj or not obj.Parent then return end
		if not isValidWorldObject(obj) then return end

		local name = obj.Name

		if name == "RaygunBullet" then
			tag(obj, "RaygunBullet")
		end
	end

	for _, obj in ipairs(workspace:GetDescendants()) do
		tagObj(obj)
	end

	vape:Clean(workspace.DescendantAdded:Connect(tagObj))
end)

run(function() 
    local TargetedEnemy = lplr:FindFirstChild("TargetedEnemy")

    TargetedEnemy:GetPropertyChangedSignal("Value"):Connect(function() 
        if TargetedEnemy.Value ~= nil then 
            targetinfo.Targets[TargetedEnemy.Value] = tick() + 1
        end
    end)
end)

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
		Tooltip = "Spoofs your current weapon to any weapon.",
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