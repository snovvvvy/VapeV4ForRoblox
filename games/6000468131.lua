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

local function safeTag(obj, tag)
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

	if obj.Name == "Trap" then
		current = obj.Parent

		while current do
			if current:IsA("Folder") and current.Name == "Traps" then
				safeTag(obj, "Trap")
				break
			end

			current = current.Parent
		end
	end

	if obj:FindFirstChild("Item") then
		current = obj.Parent

		while current do
			if current:IsA("Folder") and current.Name == "Tools" then
				safeTag(obj, "ItemESP")
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

for _, v in { "Reach", "Invisible", "Disabler", "Jesus", "Killaura", "MurderMystery", "SilentAim", "AimAssist" } do
	vape:Remove(v)
end

run(function()
	local Teams

	local enemyobjval = replicatedStorage.Game:WaitForChild("Enemy")

	local function getTeams()
		local greenTeam = teamsService:FindFirstChild("Players")
		local redTeam = teamsService:FindFirstChild("Enemy")

		if not greenTeam then
			greenTeam = Instance.new("Team")
			greenTeam.Name = "Players"
			greenTeam.TeamColor = BrickColor.new("Lime green")
			greenTeam.AutoAssignable = false
			greenTeam.Parent = teamsService
		end

		if not redTeam then
			redTeam = Instance.new("Team")
			redTeam.Name = "Enemy"
			redTeam.TeamColor = BrickColor.new("Really red")
			redTeam.AutoAssignable = false
			redTeam.Parent = teamsService
		end

		return greenTeam, redTeam
	end

	local function updateTeams()
		local map = workspace:FindFirstChild("Map")

		if not map then
			return
		end

		local playersFolder = map:FindFirstChild("Players")

		if not playersFolder then
			return
		end

		local enemyCharacter = playersFolder:FindFirstChild("Enemy")

		if not enemyCharacter then
			return
		end

		local enemyPlayer = enemyobjval.Value

		if not enemyPlayer or not enemyPlayer:IsA("Player") then
			return
		end

		local greenTeam, redTeam = getTeams()

		local localIsEnemy = lplr == enemyPlayer

		for _, player in playersService:GetPlayers() do
			if localIsEnemy then
				if player == lplr then
					player.Team = greenTeam
				else
					player.Team = redTeam
				end
			else
				if player == enemyPlayer then
					player.Team = redTeam
				else
					player.Team = greenTeam
				end
			end
		end
	end

	local function removeTeams()
		local greenTeam = teamsService:FindFirstChild("Players")
		local redTeam = teamsService:FindFirstChild("Enemy")

		for _, player in playersService:GetPlayers() do
			if player.Team == greenTeam or player.Team == redTeam then
				player.Team = nil
				player.Neutral = true
			end
		end

		if greenTeam then
			greenTeam:Destroy()
		end

		if redTeam then
			redTeam:Destroy()
		end
	end

	Teams = vape.Categories.Render:CreateModule({
		Name = "Teams",
		Function = function(callback)
			if callback then
				repeat
					updateTeams()
					task.wait(10)
				until not Teams.Enabled

				Teams:Clean(enemyobjval:GetPropertyChangedSignal("Value"):Connect(function()
					task.defer(updateTeams)
				end))

				Teams:Clean(playersService.PlayerAdded:Connect(function()
					task.defer(updateTeams)
				end))

				Teams:Clean(workspace.ChildAdded:Connect(function(child)
					if child.Name == "Map" then
						task.defer(updateTeams)
					end
				end))
			else
				removeTeams()
			end
		end,
		Tooltip = "Makes teams so that ESP can figure out who the enemy is.\n(not server-sided, but works)",
		Default = true,
	})
end)

run(function()
	local ItemESP
	local FillColor
	local OutlineColor
	local FillTransparency
	local OutlineTransparency
	local Reference = {}
	local Folder = Instance.new("Folder")
	Folder.Parent = vape.gui
	local function IsAnItem(obj)
		if not obj then
			return false
		end
		if not obj:FindFirstChild("Item") then
			return false
		end
		local current = obj.Parent
		while current do
			if current:IsA("Folder") and (current.Name == "Tools") then
				return true
			end
			current = current.Parent
		end
		return false
	end
	local function Added(obj)
		if Reference[obj] or not IsAnItem(obj) then
			return
		end
		local cham = Instance.new("Highlight")
        cham.Name = randomString()
		cham.Adornee = obj
		cham.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		cham.FillColor = Color3.fromHSV(FillColor.Hue, FillColor.Sat, FillColor.Value)
		cham.OutlineColor = Color3.fromHSV(OutlineColor.Hue, OutlineColor.Sat, OutlineColor.Value)
		cham.FillTransparency = FillTransparency.Value
		cham.OutlineTransparency = OutlineTransparency.Value
		cham.Parent = Folder
		local billboard = Instance.new("BillboardGui")
		billboard.Name = randomString()
		billboard.Adornee = obj
		billboard.AlwaysOnTop = true
		billboard.Size = UDim2.fromOffset(200, 50)
		billboard.StudsOffset = Vector3.new(0, 2, 0)
		billboard.MaxDistance = 150
		billboard.Parent = cham
		local text = Instance.new("TextLabel")
        text.Name = randomString()
		text.BackgroundTransparency = 1
		text.Size = UDim2.fromScale(.5, .5)
		text.FontFace = uipallet.Font
		text.Text = obj.Name
		text.TextColor3 = Color3.new(1, 1, 1)
		text.TextStrokeTransparency = 0
		text.TextScaled = true
		text.Parent = billboard
		Reference[obj] = cham
	end
	local function Removed(obj)
		if Reference[obj] then
			if vape.ThreadFix then
				setthreadidentity(8)
			end
			Reference[obj]:Destroy()
			Reference[obj] = nil
		end
	end
	local function Scan()
		for _, obj in workspace:GetDescendants() do
			if IsAnItem(obj) then
				task.spawn(Added, obj)
			end
		end
	end
	ItemESP = vape.Categories.Render:CreateModule({
		Name = "ItemESP",
		Function = function(callback)
			if callback then
				ItemESP:Clean(collectionService:GetInstanceAddedSignal("ItemESP"):Connect(Added))
				ItemESP:Clean(collectionService:GetInstanceRemovedSignal("ItemESP"):Connect(Removed))
				for _, obj in ipairs(collectionService:GetTagged("ItemESP")) do
					Added(obj)
				end
			else
				for _, v in pairs(Reference) do
					v:Destroy()
				end
				table.clear(Reference)
			end
		end,
	})
	FillColor = ItemESP:CreateColorSlider({
		Name = "Color",
		Function = function(hue, sat, val)
			for _, v in pairs(Reference) do
				v.FillColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})
	OutlineColor = ItemESP:CreateColorSlider({
		Name = "Outline Color",
		DefaultSat = 0,
		Function = function(hue, sat, val)
			for _, v in pairs(Reference) do
				v.OutlineColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})
	FillTransparency = ItemESP:CreateSlider({
		Name = "Transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Function = function(val)
			for _, v in pairs(Reference) do
				v.FillTransparency = val
			end
		end,
		Decimal = 10,
	})
	OutlineTransparency = ItemESP:CreateSlider({
		Name = "Outline Transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Function = function(val)
			for _, v in pairs(Reference) do
				v.OutlineTransparency = val
			end
		end,
		Decimal = 10,
	})
end)

run(function()
	local TrapESP
	local FillColor
	local OutlineColor
	local FillTransparency
	local OutlineTransparency

	local Reference = {}
	local Folder = Instance.new("Folder")
	Folder.Parent = vape.gui

	local function IsATrap(obj)
		if not obj then
			return false
		end

		if obj.Name ~= "Trap" then
			return false
		end

		local current = obj.Parent

		while current do
			if current:IsA("Folder") and (current.Name == "Traps") then
				return true
			end

			current = current.Parent
		end

		return false
	end

	local function Added(obj)
		if Reference[obj] or not IsATrap(obj) then
			return
		end

		local cham = Instance.new("Highlight")
		cham.Adornee = obj
		cham.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		cham.FillColor = Color3.fromHSV(FillColor.Hue, FillColor.Sat, FillColor.Value)
		cham.OutlineColor = Color3.fromHSV(OutlineColor.Hue, OutlineColor.Sat, OutlineColor.Value)
		cham.FillTransparency = FillTransparency.Value
		cham.OutlineTransparency = OutlineTransparency.Value
		cham.Parent = Folder

		local billboard = Instance.new("BillboardGui")
		billboard.Name = randomString()
		billboard.Adornee = obj
		billboard.AlwaysOnTop = true
		billboard.Size = UDim2.fromOffset(200, 50)
		billboard.StudsOffset = Vector3.new(0, 2, 0)
		billboard.MaxDistance = 150
		billboard.Parent = cham

		local text = Instance.new("TextLabel")
		text.BackgroundTransparency = 1
		text.Size = UDim2.fromScale(1, 1)
		text.FontFace = uipallet.Font
		text.Text = obj.Name
		text.TextColor3 = Color3.new(1, 1, 1)
		text.TextStrokeTransparency = 0
		text.TextScaled = true
		text.Parent = billboard

		Reference[obj] = cham
	end

	local function Removed(obj)
		if Reference[obj] then
			if vape.ThreadFix then
				setthreadidentity(8)
			end

			Reference[obj]:Destroy()
			Reference[obj] = nil
		end
	end

	TrapESP = vape.Categories.Render:CreateModule({
		Name = "TrapESP",
		Function = function(callback)
			if callback then
				TrapESP:Clean(collectionService:GetInstanceAddedSignal("Trap"):Connect(Added))
				TrapESP:Clean(collectionService:GetInstanceRemovedSignal("Trap"):Connect(Removed))

				for _, obj in ipairs(collectionService:GetTagged("Trap")) do
					Added(obj)
				end
			else
				for _, v in pairs(Reference) do
					v:Destroy()
				end

				table.clear(Reference)
			end
		end,
	})

	FillColor = TrapESP:CreateColorSlider({
		Name = "Color",
		Function = function(hue, sat, val)
			for _, v in pairs(Reference) do
				v.FillColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	OutlineColor = TrapESP:CreateColorSlider({
		Name = "Outline Color",
		DefaultSat = 0,
		Function = function(hue, sat, val)
			for _, v in pairs(Reference) do
				v.OutlineColor = Color3.fromHSV(hue, sat, val)
			end
		end,
	})

	FillTransparency = TrapESP:CreateSlider({
		Name = "Transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Function = function(val)
			for _, v in pairs(Reference) do
				v.FillTransparency = val
			end
		end,
		Decimal = 10,
	})

	OutlineTransparency = TrapESP:CreateSlider({
		Name = "Outline Transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Function = function(val)
			for _, v in pairs(Reference) do
				v.OutlineTransparency = val
			end
		end,
		Decimal = 10,
	})
end)


run(function()
	local AntiTrap

	local Reference = {}
	local Folder = Instance.new("Folder")
	Folder.Parent = vape.gui

	local function IsATrap(obj)
		if not obj then
			return false
		end

		if obj.Name ~= "Trap" then
			return false
		end

		local current = obj.Parent

		while current do
			if current:IsA("Folder") and (current.Name == "Traps") then
				return true
			end

			current = current.Parent
		end

		return false
	end

	local function Added(obj)
		if Reference[obj] or not IsATrap(obj) then
			return
		end

		local part = Instance.new("Part")
        part.Name = randomString()
        part.Position = obj.PrimaryPart.Position
        part.Size = obj.PrimaryPart.Size + Vector3.new(4, 4, 4)
        part.Anchored = true
        part.Parent = workspace

		Reference[obj] = part
	end

	local function Removed(obj)
		if Reference[obj] then
			if vape.ThreadFix then
				setthreadidentity(8)
			end

			Reference[obj]:Destroy()
			Reference[obj] = nil
		end
	end

	AntiTrap = vape.Categories.Blatant:CreateModule({
		Name = "AntiTrap",
		Function = function(callback)
			if callback then
				AntiTrap:Clean(collectionService:GetInstanceAddedSignal("Trap"):Connect(Added))
				AntiTrap:Clean(collectionService:GetInstanceRemovedSignal("Trap"):Connect(Removed))

				for _, obj in ipairs(collectionService:GetTagged("Trap")) do
					Added(obj)
				end
			else
				for _, v in pairs(Reference) do
					v:Destroy()
				end

				table.clear(Reference)
			end
		end,
		Tooltip = "Lets you jump on top of traps to avoid them.\n(Best used with EnableJump)",
	})
end)

run(function()
    local EnableJump

    local character, hum

    local function updateCharacter(char)
        character = char
        hum = char:WaitForChild("Humanoid")
    end

    if lplr.Character then
        updateCharacter(lplr.Character)
    end

    vape:Clean(lplr.CharacterAdded:Connect(updateCharacter))

    EnableJump = vape.Categories.Blatant:CreateModule({
        Name = "EnableJump",
        Function = function(callback)
            if callback then
                task.spawn(function()
                    repeat 
						if hum then
                            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                            hum.JumpHeight = 3.6
                        end
                        task.wait()
					until not EnableJump.Enabled
                end)
            else
                if hum then
                    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
                end
            end
        end,
    })
end)
