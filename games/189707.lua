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
local coreGui = cloneref(game:GetService("CoreGui"))

local isnetworkowner = identifyexecutor
		and table.find({ "AWP", "Nihon" }, ({ identifyexecutor() })[1])
		and isnetworkowner
	or function()
		return true
	end
local gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA("Camera")
local lplr = playersService.LocalPlayer
local assetfunction = getcustomasset

local vape = shared.vape
local tween = vape.Libraries.tween
local targetinfo = vape.Libraries.targetinfo
local getfontsize = vape.Libraries.getfontsize
local getcustomasset = vape.Libraries.getcustomasset

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

run(function()
	local SecretLab
	local gotopart = workspace.Tower.SecretElevator
	local clickdetector = gotopart:FindFirstChildWhichIsA("ClickDetector")

	SecretLab = vape.Categories.Utility:CreateModule({
		Name = "SecretLab",
		Function = function(callback)
			if callback then
				if not workspace:FindFirstChild("Secret Lab") and not lplr:GetAttribute("Playing") then
					lplr.Character:FindFirstChild("HumanoidRootPart").CFrame = gotopart.CFrame
					fireclickdetector(clickdetector)
				elseif lplr:GetAttribute("Playing") then
					notif("SecretLab", "You can't go to the Secret Lab while playing.", 3, "warning")
				else
					notif("SecretLab", "You are already in the Secret Lab.", 3, "warning")
				end
				SecretLab:Toggle()
			end
		end,
	})
end)

run(function()
    local Fling

    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local lplr = Players.LocalPlayer

    local NoclipConnection
    local HumanoidDiedConnection
    local AngularVelocity
    local Flinging = false

    local function Cleanup()
        Flinging = false

        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end

        if HumanoidDiedConnection then
            HumanoidDiedConnection:Disconnect()
            HumanoidDiedConnection = nil
        end

        if AngularVelocity then
            AngularVelocity:Destroy()
            AngularVelocity = nil
        end

        local character = lplr.Character
        if character then
            for _, v in character:GetDescendants() do
                if v:IsA("BasePart") then
                    v.Massless = false
                    v.CustomPhysicalProperties = nil
                    v.CanCollide = true
                end
            end
        end
    end

    Fling = vape.Categories.Blatant:CreateModule({
        Name = "Fling",
        Function = function(callback)
            if callback then
                Cleanup()

                local character = lplr.Character or lplr.CharacterAdded:Wait()
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local root = character:FindFirstChild("HumanoidRootPart")

                if not humanoid or not root then
                    Fling:Toggle(false)
                    return
                end

                for _, v in character:GetDescendants() do
                    if v:IsA("BasePart") then
                        v.CustomPhysicalProperties = PhysicalProperties.new(
                            100,
                            0.3,
                            0.5
                        )
                    end
                end

                NoclipConnection = RunService.Stepped:Connect(function()
                    local currentChar = lplr.Character
                    if not currentChar then
                        return
                    end

                    for _, v in currentChar:GetDescendants() do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end)

                task.wait(0.1)

                AngularVelocity = Instance.new("BodyAngularVelocity")
                AngularVelocity.Name = "FlingSpin"
                AngularVelocity.AngularVelocity = Vector3.new(0, 99999, 0)
                AngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
                AngularVelocity.P = math.huge
                AngularVelocity.Parent = root

                for _, v in character:GetChildren() do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                        v.Massless = true
                        v.AssemblyLinearVelocity = Vector3.zero
                    end
                end

                Flinging = true

                HumanoidDiedConnection = humanoid.Died:Connect(function()
                    if Fling.Enabled then
                        Fling:Toggle(false)
                    else
                        Cleanup()
                    end
                end)

                task.spawn(function()
                    while Flinging and Fling.Enabled and AngularVelocity do
                        AngularVelocity.AngularVelocity = Vector3.new(0, 99999, 0)
                        task.wait(0.2)

                        if not Flinging or not AngularVelocity then
                            break
                        end

                        AngularVelocity.AngularVelocity = Vector3.zero
                        task.wait(0.1)
                    end
                end)
            else
                Cleanup()
            end
        end,
    })
end)
