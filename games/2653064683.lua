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
	local WordBomb

	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local UserInputService = game:GetService("UserInputService")

	local lplr = Players.LocalPlayer
	local Games = ReplicatedStorage:WaitForChild("Network"):WaitForChild("Games")

	local IsOnMobile = table.find({
		Enum.Platform.IOS,
		Enum.Platform.Android,
	}, UserInputService:GetPlatform())

	local WordList =
		loadstring(game:HttpGet("https://raw.githubusercontent.com/jjengu/scripts/main/wordbomb/words.lua"))()

	local WordList_Two =
		loadstring(game:HttpGet("https://raw.githubusercontent.com/jjengu/scripts/main/wordbomb/words_two.lua"))()

	local WordList_Three = { -- TODO: turn into loadstring to compress
		"pseudopseudohypoparathyroidism",
		"floccinaucinihilipilification",
		"antidisestablishmentarianism",
		"supercalifragilisticexpialidocious",
		"hexakosioihexekontahexaphobia",
		"dichlorodiphenyltrichloroethane",
		"sphenopalatineganglioneuralgia",
		"radioimmunoelectrophoresis",
		"electroencephalographically",
		"ethylenediaminetetraacetates",
		"xenotransplantations",
		"unselfconsciousnesses",
		"weatherproofnesses",
		"zoogeographically",
		"worthwhilenesses",
		"overintellectualizations",
		"untranslatabilities",
		"phosphatidylethanolamines",
		"unexceptionablenesses",
		"reinstituionalizations",
		"counterdemonstrations",
		"characteristically",
		"unconstitutionality",
		"intercontinental",
		"misinterpretations",
		"phenomenological",
		"oversimplification",
		"representationalism",
		"disenfranchisement",
		"incompatibilities",
		"institutionalizing",
		"underrepresentation",
		"thermodynamically",
		"photosynthetically",
		"magnetohydrodynamics",
		"uncharacteristically",
		"electroencephalogram",
		"counterrevolutionary",
		"microminiaturization",
		"internationalization",
		"conceptualizations",
		"microarchitectures",
		"counterproductive",
		"environmentalists",
		"differentiability",
		"subcategorization",
		"ultramicroscopic",
		"disproportionately",
		"industrialization",
		"dematerialization",
		"recommendations",
		"overcompensations",
		"misunderstanding",
		"interrelationships",
		"transcontinental",
		"uncontrollability",
		"administratively",
		"photosensitizing",
		"bioluminescence",
		"counterarguments",
		"telecommunications",
		"immunohistochemistry",
	}

	local Settings = {
		AutoType = false,
		AutoJoin = false,
		WordList = 1,
		LetterTypeDelay = 0.1,
		WordTypeDelay = 0.5,
	}

	local Connections = {}

	local GameID = "-1"
	local UsedWords = {}
	local Typing = false
	local TypingActive = false
	local LastWord = ""

	local function GetWordList()
		if Settings.WordList == 1 then
			return WordList
		elseif Settings.WordList == 2 then
			return WordList_Two
		end

		return WordList_Three
	end

	local function GetTurn()
		for _, v in getgc(true) do
			if type(v) == "function" and debug.getinfo(v).name == "updateInfoFrame" then
				for _, upv in ipairs(debug.getupvalues(v)) do
					if type(upv) == "table" and upv.PlayerID then
						return upv.PlayerID
					end
				end
			end
		end
	end

	local function GetLetters()
		for _, v in getgc(true) do
			if type(v) == "function" and debug.getinfo(v).name == "updateInfoFrame" then
				for _, upv in pairs(debug.getupvalues(v)) do
					if type(upv) == "table" and upv.Prompt then
						return upv.Prompt
					end
				end
			end
		end

		return ""
	end

	local function FindWord(letters)
		if not letters or letters == "" then
			return nil
		end

		letters = string.lower(letters)

		for _, word in ipairs(GetWordList()) do
			local lower = string.lower(word)

			if string.find(lower, letters) and not table.find(UsedWords, word) and string.upper(word) ~= LastWord then
				table.insert(UsedWords, word)
				return string.upper(word)
			end
		end
	end

	local function TypeWord(word)
		if Typing or not word then
			return
		end

		Typing = true

		for i = 1, #word do
			Games.GameEvent:FireServer(GameID, "TypingEvent", string.sub(word, 1, i), false)

			task.wait(Settings.LetterTypeDelay)
		end

		Games.GameEvent:FireServer(GameID, "TypingEvent", word, true)

		Typing = false
	end

	local function TryTyping()
		if TypingActive or not Settings.AutoType or not WordBomb.Enabled then
			return
		end

		TypingActive = true

		task.spawn(function()
			while WordBomb.Enabled and Settings.AutoType do
				repeat
					task.wait(0.1)

					if not WordBomb.Enabled or not Settings.AutoType then
						TypingActive = false
						return
					end
				until GetTurn() == lplr.UserId

				local foundWord

				for _ = 1, 5 do
					foundWord = FindWord(GetLetters())

					if foundWord then
						break
					end

					task.wait()
				end

				if foundWord then
					LastWord = foundWord

					task.wait(Settings.WordTypeDelay)

					if WordBomb.Enabled then
						TypeWord(foundWord)
					end
				end

				task.wait(0.2)
			end

			TypingActive = false
		end)
	end

	local function DisconnectAll()
		for _, connection in ipairs(Connections) do
			connection:Disconnect()
		end

		table.clear(Connections)
	end

	WordBomb = vape.Categories.Blatant:CreateModule({
		Name = "WordBomb",
		Function = function(callback)
			if callback then
				table.insert(
					Connections,
					Games:WaitForChild("RegisterGame").OnClientEvent:Connect(function(id)
						GameID = id
						UsedWords = {}
						LastWord = ""

						if Settings.AutoJoin then
							Games.GameEvent:FireServer(id, "JoinGame")
						end

						task.wait(1)

						if Settings.AutoType then
							TryTyping()
						end
					end)
				)

				local PlayerGui = lplr:WaitForChild("PlayerGui")

				table.insert(
					Connections,
					PlayerGui.GameUI.DescendantAdded:Connect(function(obj)
						if obj.Name == "Typebox" then
							task.wait(0.2)

							if Settings.AutoType then
								TryTyping()
							end
						end
					end)
				)
			else
				DisconnectAll()

				Typing = false
				TypingActive = false
			end
		end,
        Tooltip = "Lets you sit and relax while the bot does it for you.\n (might be broken :omegalol:)"
	})

	WordBombToggle = WordBomb:CreateToggle({
		Name = "Auto Type",
		Function = function(value)
			Settings.AutoType = value

			if value and WordBomb.Enabled then
				TryTyping()
			end
		end,
	})

	WordBomb:CreateToggle({
		Name = "Auto Join",
		Function = function(value)
			Settings.AutoJoin = value

			if value then
				for i = -1, -1000, -1 do
					Games.GameEvent:FireServer(i, "JoinGame")
				end
			end
		end,
	})

	WordBomb:CreateDropdown({
		Name = "Word List",
		List = {
			"List 1",
			"List 2",
			"List 3",
		},
		Function = function(value)
			if value == "List 1" then
				Settings.WordList = 1
			elseif value == "List 2" then
				Settings.WordList = 2
			else
				Settings.WordList = 3
			end
		end,
	})

	WordBomb:CreateSlider({
		Name = "Letter Delay",
		Min = 0,
		Max = 1,
		Default = 0.1,
		Decimal = 10,

		Function = function(value)
			Settings.LetterTypeDelay = value
		end,
	})

	WordBomb:CreateSlider({
		Name = "Word Delay",
		Min = 0,
		Max = 3,
		Default = 0.5,
		Decimal = 10,

		Function = function(value)
			Settings.WordTypeDelay = value
		end,
	})

	WordBomb:CreateButton({
		Name = "Type Word",

		Function = function()
			if GameID == "-1" then
				return
			end

			task.spawn(function()
				repeat
					task.wait(0.1)
				until GetTurn() == lplr.UserId

				local word = FindWord(GetLetters())

				if word then
					LastWord = word
					task.wait(Settings.WordTypeDelay)
					TypeWord(word)
				end
			end)
		end,
	})

	WordBomb:CreateButton({
		Name = "Blurt Word",

		Function = function()
			if GameID == "-1" then
				return
			end

			local word = FindWord(GetLetters())

			if word then
				ReplicatedStorage.Network.Chat.SendMessage:FireServer(GameID, word)
			end
		end,
	})
end)
