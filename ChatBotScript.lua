-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")

-- Local Player
local LocalPlayer = Players.LocalPlayer

-- Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Guerric9018/OrionLibFixed/main/OrionLib.lua"))()

-- Version
local VERSION = "Ox01BABA"

-- Settings
local Settings = {
    TTA = false,
    AI_MODEL = "Llama-8B ( default | 5 points )",
    ON = false,
    CREDITS = 0,
    CUSTOMPROMPT = false,
    CUSTOMPROMPTTEXT = "Just be a normal AI.",
    WHITELIST = false,
    BOTFORMAT = false,
    TTA_RUNNING = true,
    CHAT_BYPASS = false,
    KEY = "default",
    LOADED = false,
    DELAYED_CHAT = false,
    REMINDING_STATE = false,
    MaxDistance = 20,
    Character = "Normal (Roblox aware)",
    BUFFER = false,
    LANGUAGE = "en",
    AUTOMOVING = false,
    AUTOMOVINGMAXDISTANCE = 30,
    MAX_MESSAGE_LENGTH = 190,
    CUSTOMAIS = {},
    BLACKLISTED = {},
    DISPLAYTOFULLNAME = {},
    BLACKLISTEDCONTENT = {},
    LOGIN = false,
    PREMIUM = false
}

-- Create Window
local Window = OrionLib:MakeWindow({
    Name = "ChatBot Hub",
    HidePremium = false,
    SaveConfig = false,
    IntroText = "ChatBot Hub",
    IntroEnabled = true,
    IntroIcon = "rbxassetid://13188306657"
})

-- Create Tabs
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://6034798461"
})

local AITab = Window:MakeTab({
    Name = "AI",
    Icon = "rbxassetid://13680871118"
})

local PremiumTab = Window:MakeTab({
    Name = "Premium",
    Icon = "rbxassetid://11835491319"
})

local ChatTab = Window:MakeTab({
    Name = "Chat",
    Icon = "rbxassetid://14376097365"
})

local MoreTab = Window:MakeTab({
    Name = "More",
    Icon = "rbxassetid://5107175347"
})

local HelpTab = Window:MakeTab({
    Name = "Help",
    Icon = "rbxassetid://15668939723"
})

-- Helper functions
local function getKeys(t)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

-- UI Elements
-- Main Tab
local runningToggle
local pointsLabel
local blacklistTextbox
local blacklistedDropdown
local whitelistToggle

runningToggle = MainTab:AddToggle({
    Name = "Running",
    Default = Settings.ON,
    Callback = function(value)
        if not Settings.LOGIN and value then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "You first need to login, go check the 'more' tab",
                Image = "rbxassetid://6723839910",
                Time = 3
            })
            runningToggle:Set(false)
        else
            Settings.ON = value
        end
    end
})

pointsLabel = MainTab:AddLabel("Points balance: " .. Settings.CREDITS)

blacklistTextbox = MainTab:AddTextbox({
    Name = "Blacklist player",
    Default = "",
    TextDisappear = true,
    Callback = function(text)
        if text and text ~= "" then
            local player = Players:FindFirstChild(text)
            if player then
                Settings.BLACKLISTED[player.Name] = true
                table.insert(Settings.BLACKLISTEDCONTENT, player.Name)
                blacklistedDropdown:Refresh(Settings.BLACKLISTEDCONTENT, true)
            end
        end
    end
})

blacklistedDropdown = MainTab:AddDropdown({
    Name = "Blacklisted players",
    Description = "Select player to whitelist...",
    Default = "",
    Options = Settings.BLACKLISTEDCONTENT,
    Callback = function(option)
        Settings.BLACKLISTED[option] = nil
        for i, v in ipairs(Settings.BLACKLISTEDCONTENT) do
            if v == option then
                table.remove(Settings.BLACKLISTEDCONTENT, i)
                break
            end
        end
        blacklistedDropdown:Refresh(Settings.BLACKLISTEDCONTENT, true)
    end
})

MainTab:AddButton({
    Name = "Reset blacklist",
    Callback = function()
        Settings.BLACKLISTED = {}
        Settings.BLACKLISTEDCONTENT = {}
        blacklistedDropdown:Refresh(Settings.BLACKLISTEDCONTENT, true)
    end
})

whitelistToggle = MainTab:AddToggle({
    Name = "Whitelist mode",
    Default = Settings.WHITELIST,
    Callback = function(value)
        Settings.WHITELIST = value
        if value then
            blacklistedDropdown:Title("Whitelisted players")
            blacklistTextbox:Title("Whitelist player")
        else
            blacklistedDropdown:Title("Blacklisted players")
            blacklistTextbox:Title("Blacklist player")
        end
    end
})

MainTab:AddTextbox({
    Name = "Listening range",
    Default = tostring(Settings.MaxDistance),
    TextDisappear = false,
    Callback = function(text)
        local num = tonumber(text)
        if num then
            Settings.MaxDistance = num
        end
    end
})

MainTab:AddTextbox({
    Name = "Max message length",
    Default = tostring(Settings.MAX_MESSAGE_LENGTH),
    TextDisappear = false,
    Callback = function(text)
        local num = tonumber(text)
        if num then
            Settings.MAX_MESSAGE_LENGTH = num
        end
    end
})

MainTab:AddToggle({
    Name = "Anti spam",
    Default = Settings.DELAYED_CHAT,
    Callback = function(value)
        Settings.DELAYED_CHAT = value
        -- Anti-spam logic will be added later
    end
})

MainTab:AddToggle({
    Name = "Buffer (adds a 3 seconds delay)",
    Default = Settings.BUFFER,
    Callback = function(value)
        Settings.BUFFER = value
        -- Buffer logic will be added later
    end
})

MainTab:AddButton({
    Name = "Reset AI memory",
    Callback = function()
        -- Reset memory logic will be added later
    end
})

MainTab:AddToggle({
    Name = "Chatbot message formatting ([Chatbot] ...)",
    Default = Settings.BOTFORMAT,
    Callback = function(value)
        Settings.BOTFORMAT = value
    end
})

MainTab:AddToggle({
    Name = "Auto remind you're a chatbot",
    Default = Settings.REMINDING_STATE,
    Callback = function(value)
        Settings.REMINDING_STATE = value
        -- Auto-remind logic will be added later
    end
})

-- AI Tab
local characterOptions = {
    "Normal (Roblox aware)", "Normal", "Furry", "Roast", "Waifu", "Nerd", "Christian", "Robot", "Brainrot"
}

AITab:AddDropdown({
    Name = "Select the character of your AI",
    Description = "List is subject to change in future updates! Give ideas in the Discord server!",
    Default = Settings.Character,
    Options = characterOptions,
    Callback = function(value)
        Settings.Character = value
        -- Character change logic will be added later
    end
})

local modelOptions = {
    "Llama-8B ( default | 5 points )", "Llama2-7B ( if default one fails | 5 points )", "Llama-70B ( 50 points )"
}

AITab:AddDropdown({
    Name = "Select the AI model",
    Description = "Some AIs are smarter but cost more points!",
    Default = Settings.AI_MODEL,
    Options = modelOptions,
    Callback = function(value)
        Settings.AI_MODEL = value
    end
})

local languageOptions = {
    "en", "fr", "ru", "es", "br", "ar"
}

AITab:AddDropdown({
    Name = "Language",
    Description = "New languages can be added if there is enough demand",
    Default = Settings.LANGUAGE,
    Options = languageOptions,
    Callback = function(value)
        Settings.LANGUAGE = value
    end
})

-- Premium Tab
local premiumLabel = PremiumTab:AddLabel("Premium is NOT activated")
local ttaToggle
local automovingToggle
local customPromptToggle

ttaToggle = PremiumTab:AddToggle({
    Name = "Text to action mode ( 1.5x points )",
    Default = Settings.TTA,
    Callback = function(value)
        if Settings.PREMIUM then
            Settings.TTA = value
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "You need to have premium to use this feature!",
                Image = "rbxassetid://6723839910",
                Time = 3
            })
            ttaToggle:Set(false)
        end
    end
})

automovingToggle = PremiumTab:AddToggle({
    Name = "Auto moving (under development)",
    Default = Settings.AUTOMOVING,
    Callback = function(value)
        if Settings.PREMIUM then
            Settings.AUTOMOVING = value
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "You need to have premium to use this feature!",
                Image = "rbxassetid://6723839910",
                Time = 3
            })
            automovingToggle:Set(false)
        end
    end
})

customPromptToggle = PremiumTab:AddToggle({
    Name = "Enable custom prompt",
    Default = Settings.CUSTOMPROMPT,
    Callback = function(value)
        if Settings.PREMIUM then
            Settings.CUSTOMPROMPT = value
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "You need to have premium to use this feature!",
                Image = "rbxassetid://6723839910",
                Time = 3
            })
            customPromptToggle:Set(false)
        end
    end
})

PremiumTab:AddTextbox({
    Name = "Enter custom prompt here: ",
    Default = "",
    TextDisappear = true,
    Callback = function(text)
        if Settings.PREMIUM then
            Settings.CUSTOMPROMPTTEXT = text
        end
    end
})

local customPromptParagraph = PremiumTab:AddParagraph("Custom Prompt", Settings.CUSTOMPROMPTTEXT)

local customAIsDropdown = PremiumTab:AddDropdown({
    Name = "Custom AIs",
    Description = "Your saved custom AIs",
    Default = "",
    Options = getKeys(Settings.CUSTOMAIS),
    Callback = function(value)
        Settings.CUSTOMPROMPTTEXT = Settings.CUSTOMAIS[value]
        customPromptParagraph:Set(Settings.CUSTOMPROMPTTEXT)
    end
})

PremiumTab:AddTextbox({
    Name = "Save custom prompt with name: ",
    Default = "",
    TextDisappear = true,
    Callback = function(text)
        if text and text ~= "" and Settings.PREMIUM then
            Settings.CUSTOMAIS[text] = Settings.CUSTOMPROMPTTEXT
            customAIsDropdown:Refresh(getKeys(Settings.CUSTOMAIS), true)
        end
    end
})

-- Chat Tab
local aiAnswerParagraph

ChatTab:AddButton({
    Name = "Clear chat",
    Callback = function()
        if aiAnswerParagraph then
            aiAnswerParagraph:Set("")
        end
    end
})

aiAnswerParagraph = ChatTab:AddParagraph("AI's answer", "")

ChatTab:AddButton({
    Name = "Copy the answer",
    Description = "Click to copy the full answer",
    Callback = function()
        -- Copy logic will be added later
    end
})

ChatTab:AddTextbox({
    Name = "Message",
    Default = "",
    TextDisappear = true,
    Callback = function(text)
        -- Send message logic will be added later
    end
})

-- More Tab
MoreTab:AddTextbox({
    Name = "Key",
    Default = "",
    TextDisappear = true,
    Callback = function(text)
        if text and text ~= "" then
            local success, response = pcall(function()
                return game:HttpGet("https://guerric.pythonanywhere.com/login?uid=" .. LocalPlayer.UserId .. "&key=" .. text)
            end)

            if success and response == "ACCEPTED" then
                Settings.KEY = text
                Settings.LOGIN = true
                Settings.PREMIUM = true -- Assuming key validation implies premium
                premiumLabel:Set("Premium activated!")

                local creditsSuccess, creditsResponse = pcall(function()
                    return game:HttpGet("https://guerric.pythonanywhere.com/credits?uid=" .. LocalPlayer.UserId)
                end)

                if creditsSuccess then
                    Settings.CREDITS = tonumber(creditsResponse) or 0
                    pointsLabel:Set("Points balance: " .. Settings.CREDITS)
                end

                OrionLib:MakeNotification({
                    Name = "Logged in",
                    Content = "You successfully logged in! You have " .. Settings.CREDITS .. " points.",
                    Image = "rbxassetid://7115671043",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Wrong key given",
                    Image = "rbxassetid://16661795528",
                    Time = 3
                })
            end
        end
    end
})

MoreTab:AddButton({
    Name = "Official Discord server",
    Description = "Click to copy the link",
    Callback = function()
        setclipboard("https://discord.gg/MJagjEv9VX")
        OrionLib:MakeNotification({
            Name = "Discord",
            Content = "Discord link copied to clipboard",
            Image = "rbxassetid://10337369764",
            Time = 3
        })
    end
})

MoreTab:AddButton({
    Name = "Chat bypass by Guerric",
    Description = "Click to execute the script",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Guerric9018/chat_bypass/main/main.lua"))()
        OrionLib:MakeNotification({
            Name = "Chat bypass by Guerric",
            Content = "Chat bypass script launched",
            Image = "rbxassetid://7115671043",
            Time = 3
        })
    end
})

MoreTab:AddButton({
    Name = "Anti chat logger",
    Description = "Click to execute the script",
    Callback = function()
        -- Anti-chat logger logic will be added later
    end
})

MoreTab:AddButton({
    Name = "Delete saved AIs",
    Description = "This will instantly delete all of your saved custom AIs",
    Callback = function()
        Settings.CUSTOMAIS = {}
        customAIsDropdown:Refresh({}, true)
        OrionLib:MakeNotification({
            Name = "Success",
            Content = "AIs were successfully deleted!",
            Image = "rbxassetid://7115671043",
            Time = 3
        })
    end
})

-- Help Tab
HelpTab:AddParagraph("Help", [[
<b>If you encounter issues. Please check the following:</b>

<font color="rgb(255, 0, 0)"><b>• Have you logged in?</b></font> Have you put your key in the 'more' tab? If not, go get your key on Discord then come back.
<font color="rgb(255, 0, 0)"><b>• Have you set 'Running' on in the main tab?</b></font>
<font color="rgb(255, 0, 0)"><b>• Do you have enough points to generate responses?</b></font>

<b>If nothing works please ask your question in the Discord server.</b>
]])

-- Logic
local modelCosts = {
    ["Llama-8B ( default | 5 points )"] = 5,
    ["Llama2-7B ( if default one fails | 5 points )"] = 5,
    ["Llama-70B ( 50 points )"] = 50
}

local chatHistory = {}

local function sendApiRequest(message, player)
    local userDisplayURI = HttpService:UrlEncode(player.DisplayName)
    local historyURI = HttpService:UrlEncode(table.concat(chatHistory[player] or {}, " "))
    local characterURI = HttpService:UrlEncode(Settings.Character)
    local modelURI = HttpService:UrlEncode(Settings.AI_MODEL)
    local customPromptURI = "no"
    local customPromptTextURI = ""

    if Settings.PREMIUM and Settings.CUSTOMPROMPT then
        customPromptURI = "yes"
        customPromptTextURI = HttpService:UrlEncode(Settings.CUSTOMPROMPTTEXT)
    end

    local url = string.format(
        "https://guerric.pythonanywhere.com/chat?msg=%s&user=%s&key=%s&history=%s&ai=%s&uid=%s&custom=%s&model=%s&lang=%s&long=no&tta=no&version=%s",
        HttpService:UrlEncode(message),
        userDisplayURI,
        Settings.KEY,
        historyURI,
        characterURI, -- ai parameter
        player.UserId,
        customPromptURI,
        modelURI,
        Settings.LANGUAGE,
        VERSION
    )

    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if success then
        -- Process response
        local cost = modelCosts[Settings.AI_MODEL] or 0
        if Settings.TTA then cost = cost * 1.5 end
        Settings.CREDITS = Settings.CREDITS - cost
        pointsLabel:Set("Points balance: " .. Settings.CREDITS)

        OrionLib:MakeNotification({
            Name = tostring(math.floor(cost)) .. " points used",
            Content = tostring(Settings.CREDITS) .. " points left",
            Time = 1
        })

        return response
    else
        warn("API request failed:", response)
        return nil
    end
end

local function sendChat(message)
    pcall(function()
        local textChatService = game:GetService("TextChatService")
        local textChannels = textChatService.TextChannels
        local generalChannel = textChannels.RBXGeneral
        generalChannel:SendAsync(message)
    end)
end

local function handlePlayerChat(message, player)
    if not Settings.ON or not Settings.LOGIN or Settings.CREDITS <= 0 then return end

    if Settings.BLACKLISTED[player.Name] and not Settings.WHITELIST then return end
    if not Settings.BLACKLISTED[player.Name] and Settings.WHITELIST then return end

    if player == LocalPlayer then return end

    if (LocalPlayer.Character and player.Character and
        (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude > Settings.MaxDistance) then
        return
    end

    local response = sendApiRequest(message, player)
    if response then
        -- Update chat history
        if not chatHistory[player] then
            chatHistory[player] = {}
        end
        table.insert(chatHistory[player], "Previous user message: " .. message)
        table.insert(chatHistory[player], "Previous AI assistant message: " .. response)
        if #chatHistory[player] > 4 then
            table.remove(chatHistory[player], 1)
            table.remove(chatHistory[player], 1)
        end

        -- Send response to chat
        local formattedResponse = response
        if Settings.BOTFORMAT then
            formattedResponse = "[ChatBot]: " .. response
        end

        local chunks = {}
        for i = 1, math.ceil(#formattedResponse / Settings.MAX_MESSAGE_LENGTH) do
            table.insert(chunks, string.sub(formattedResponse, (i-1) * Settings.MAX_MESSAGE_LENGTH + 1, i * Settings.MAX_MESSAGE_LENGTH))
        end

        for _, chunk in ipairs(chunks) do
            sendChat(chunk)
            wait(0.1)
        end
    end
end

-- Event Connections
Players.PlayerAdded:Connect(function(player)
    chatHistory[player] = {}
end)

Players.PlayerRemoving:Connect(function(player)
    chatHistory[player] = nil
end)

pcall(function()
    TextChatService.OnIncomingMessage = function(message)
        if message.Status == Enum.TextChatMessageStatus.Success then
            local player = Players:GetPlayerByUserId(message.TextSource.UserId)
            if player then
                handlePlayerChat(message.Text, player)
            end
        end
    end
end)

Players.PlayerChatted:Connect(function(player, message)
    handlePlayerChat(message, player)
end)

-- Initialize
OrionLib:Init()
print("ChatBot Hub loaded successfully!")
