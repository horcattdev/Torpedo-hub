local Environment = getgenv()

local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local TweenService = game:GetService("TweenService")

local UserInputService = game:GetService("UserInputService")

local Workspace = game:GetService("Workspace")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local isMobile = UserInputService.TouchEnabled

    and not UserInputService.MouseEnabled

    and not UserInputService.KeyboardEnabled

local NOVA_GUI_NAMES = {

    NOVAUI = true,

    NOVAUIScroll = true,

    NOVAUIPopup = true,

    TorpedoLoadingUI = true,

    TorpedoKeyUI = true,

}

local function destroyNOVAInterface()

    local guiParents = {}

    local function addGUIParent(parent)

        if not parent then return end

        for _, existing in ipairs(guiParents) do

            if existing == parent then return end

        end

        guiParents[#guiParents + 1] = parent

    end

    addGUIParent(PlayerGui)

    pcall(function() addGUIParent(game:GetService("CoreGui")) end)

    pcall(function()

        if type(gethui) == "function" then addGUIParent(gethui()) end

    end)

    for _, parent in ipairs(guiParents) do

        pcall(function()

            for _, child in ipairs(parent:GetDescendants()) do

                if NOVA_GUI_NAMES[child.Name] then

                    child:Destroy()

                end

            end

            if NOVA_GUI_NAMES[parent.Name] then

                parent:Destroy()

            end

        end)

    end

end

if type(Environment.NOVACleanup) == "function" then

    pcall(Environment.NOVACleanup)

end

-- An older broken cleanup may have stopped its loops but left Fluent's GUI.

destroyNOVAInterface()

Environment.VortexLoaded = false

local oldVortexGui = PlayerGui:FindFirstChild("VortexStudioUI")

if oldVortexGui then

    oldVortexGui:Destroy()

end

local function requireTorpedoKey()

    local keyFileName = "torpedo_key.txt"
    local savedKey

    if type(isfile) == "function" and type(readfile) == "function" then
        if isfile(keyFileName) then
            local readSuccess, value = pcall(readfile, keyFileName)
            if readSuccess and type(value) == "string" then
                savedKey = value:gsub("%s+", "")
            end
        end
    end

    if savedKey == "torpedo" then
        return true
    end

    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "TorpedoKeyUI"
    keyGui.ResetOnSpawn = false
    keyGui.IgnoreGuiInset = true
    keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    keyGui.Parent = PlayerGui

    local panel = Instance.new("Frame")
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.fromScale(0.5, 0.5)
    panel.Size = UDim2.fromOffset(320, 190)
    panel.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    panel.BorderSizePixel = 0
    panel.Parent = keyGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = panel

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(20, 14)
    title.Size = UDim2.new(1, -40, 0, 28)
    title.Font = Enum.Font.GothamBold
    title.Text = "TORPEDO KEY"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Parent = panel

    local input = Instance.new("TextBox")
    input.ClearTextOnFocus = false
    input.PlaceholderText = "Enter key"
    input.Text = ""
    input.Position = UDim2.fromOffset(20, 58)
    input.Size = UDim2.new(1, -40, 0, 40)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    input.BorderSizePixel = 0
    input.Font = Enum.Font.Gotham
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.PlaceholderColor3 = Color3.fromRGB(150, 150, 160)
    input.TextSize = 15
    input.Parent = panel

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input

    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Position = UDim2.fromOffset(20, 105)
    status.Size = UDim2.new(1, -40, 0, 22)
    status.Font = Enum.Font.Gotham
    status.Text = "Key required"
    status.TextColor3 = Color3.fromRGB(180, 180, 190)
    status.TextSize = 13
    status.Parent = panel

    local submit = Instance.new("TextButton")
    submit.Position = UDim2.fromOffset(20, 137)
    submit.Size = UDim2.new(1, -40, 0, 36)
    submit.BackgroundColor3 = Color3.fromRGB(55, 220, 149)
    submit.BorderSizePixel = 0
    submit.Font = Enum.Font.GothamBold
    submit.Text = "Unlock"
    submit.TextColor3 = Color3.fromRGB(12, 20, 18)
    submit.TextSize = 14
    submit.Parent = panel

    local submitCorner = Instance.new("UICorner")
    submitCorner.CornerRadius = UDim.new(0, 6)
    submitCorner.Parent = submit

    local accepted = false
    local submitConnection
    local focusConnection

    local function checkKey()

        if input.Text == "torpedo" then
            accepted = true
            status.Text = "Unlocked"
            status.TextColor3 = Color3.fromRGB(55, 220, 149)

            if type(writefile) == "function" then
                pcall(writefile, keyFileName, "torpedo")
            end

        else
            input.Text = ""
            status.Text = "Invalid key"
            status.TextColor3 = Color3.fromRGB(255, 90, 90)
        end

    end

    submitConnection = submit.MouseButton1Click:Connect(checkKey)
    focusConnection = input.FocusLost:Connect(function(enterPressed)
        if enterPressed then checkKey() end
    end)

    input:CaptureFocus()

    while not accepted do
        task.wait()
    end

    if submitConnection then submitConnection:Disconnect() end
    if focusConnection then focusConnection:Disconnect() end
    keyGui:Destroy()

    return true

end

requireTorpedoKey()

local function showTorpedoLoadingScreen(mainGui, mainRoot)

    local loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "TorpedoLoadingUI"
    loadingGui.ResetOnSpawn = false
    loadingGui.IgnoreGuiInset = true
    loadingGui.DisplayOrder = 2147483647
    loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local overlayParent = PlayerGui
    pcall(function()
        if type(gethui) == "function" then
            overlayParent = gethui()
        end
    end)

    loadingGui.Parent = overlayParent

    if mainGui and mainGui:IsA("ScreenGui") then
        mainGui.Enabled = false
    end

    local background = Instance.new("Frame")
    background.Size = UDim2.fromScale(1, 1)
    background.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    background.BorderSizePixel = 0
    background.Parent = loadingGui

    local logo = Instance.new("ImageLabel")
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Position = UDim2.fromScale(0.5, 0.36)
    logo.Size = UDim2.fromOffset(150, 150)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://125088661807855"
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Parent = background

    local title = Instance.new("TextLabel")
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.Position = UDim2.fromScale(0.5, 0.54)
    title.Size = UDim2.fromOffset(400, 42)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "TORPEDO"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 30
    title.Parent = background

    local status = Instance.new("TextLabel")
    status.AnchorPoint = Vector2.new(0.5, 0.5)
    status.Position = UDim2.fromScale(0.5, 0.61)
    status.Size = UDim2.fromOffset(400, 24)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.Text = "Initializing..."
    status.TextColor3 = Color3.fromRGB(150, 150, 160)
    status.TextSize = 13
    status.Parent = background

    local barBack = Instance.new("Frame")
    barBack.AnchorPoint = Vector2.new(0.5, 0.5)
    barBack.Position = UDim2.fromScale(0.5, 0.69)
    barBack.Size = UDim2.fromOffset(300, 6)
    barBack.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    barBack.BorderSizePixel = 0
    barBack.Parent = background

    local barBackCorner = Instance.new("UICorner")
    barBackCorner.CornerRadius = UDim.new(1, 0)
    barBackCorner.Parent = barBack

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.fromScale(0, 1)
    barFill.BackgroundColor3 = Color3.fromRGB(125, 125, 135)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBack

    local barFillCorner = Instance.new("UICorner")
    barFillCorner.CornerRadius = UDim.new(1, 0)
    barFillCorner.Parent = barFill

    local percent = Instance.new("TextLabel")
    percent.AnchorPoint = Vector2.new(0.5, 0.5)
    percent.Position = UDim2.fromScale(0.5, 0.75)
    percent.Size = UDim2.fromOffset(120, 24)
    percent.BackgroundTransparency = 1
    percent.Font = Enum.Font.GothamMedium
    percent.Text = "0%"
    percent.TextColor3 = Color3.fromRGB(190, 190, 200)
    percent.TextSize = 14
    percent.Parent = background

    local topCurtain = Instance.new("Frame")
    topCurtain.Size = UDim2.fromScale(1, 0.5)
    topCurtain.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    topCurtain.BorderSizePixel = 0
    topCurtain.ZIndex = 1
    topCurtain.Parent = background

    local bottomCurtain = Instance.new("Frame")
    bottomCurtain.Position = UDim2.fromScale(0, 0.5)
    bottomCurtain.Size = UDim2.fromScale(1, 0.5)
    bottomCurtain.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    bottomCurtain.BorderSizePixel = 0
    bottomCurtain.ZIndex = 1
    bottomCurtain.Parent = background

    for _, object in ipairs({ logo, title, status, barBack, percent }) do
        object.Visible = true
        object.ZIndex = 30
    end

    for _, object in ipairs(background:GetChildren()) do
        if object:IsA("GuiObject") and object ~= topCurtain and object ~= bottomCurtain then
            object.ZIndex = 10
        end
    end

    local startTime = os.clock()
    local loadDuration = 0.7
    local mainShown = false

    while true do

        local progress = math.clamp((os.clock() - startTime) / loadDuration, 0, 1)
        local value = math.floor(progress * 100)

        barFill.Size = UDim2.fromScale(progress, 1)
        percent.Text = tostring(value) .. "%"

        logo.Rotation = math.sin(progress * math.pi * 4) * 3
        logo.ImageTransparency = 0.02 + math.sin(progress * math.pi * 2) * 0.02

        if progress < 0.35 then
            status.Text = "Initializing..."
        elseif progress < 0.7 then
            status.Text = "Loading modules..."
        else
            status.Text = "Almost ready..."
        end

        if progress >= 0.5 and not mainShown then
            mainShown = true

            if mainGui and mainGui:IsA("ScreenGui") then
                mainGui.Enabled = true
            end

            if mainRoot and mainRoot:IsA("GuiObject") then
                mainRoot.Visible = true

                local scale = mainRoot:FindFirstChild("TorpedoOpenScale")

                if scale then
                    scale.Scale = 0.72
                    TweenService:Create(scale, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Scale = 1,
                    }):Play()
                end
            end

            local revealInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            TweenService:Create(background, revealInfo, {
                BackgroundTransparency = 1,
            }):Play()
            TweenService:Create(topCurtain, revealInfo, {
                Size = UDim2.fromScale(1, 0),
            }):Play()
            TweenService:Create(bottomCurtain, revealInfo, {
                Position = UDim2.fromScale(0, 1),
                Size = UDim2.fromScale(1, 0),
            }):Play()
        end

        if progress >= 1 then break end
        task.wait(1 / 30)

    end

    barFill.Size = UDim2.fromScale(1, 1)
    percent.Text = "100%"
    status.Text = "Ready"

    task.wait(0.05)

    if mainGui and mainGui:IsA("ScreenGui") then
        mainGui.Enabled = true
    end

    local closeInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
    TweenService:Create(background, closeInfo, {
        BackgroundTransparency = 1,
    }):Play()

    for _, object in ipairs({ logo, title, status, barBack, percent }) do
        if object:IsA("TextLabel") then
            TweenService:Create(object, closeInfo, { TextTransparency = 1 }):Play()
        elseif object:IsA("ImageLabel") then
            TweenService:Create(object, closeInfo, { ImageTransparency = 1 }):Play()
        else
            TweenService:Create(object, closeInfo, { BackgroundTransparency = 1 }):Play()
        end
    end

    task.wait(0.25)

    if loadingGui.Parent then
        loadingGui:Destroy()
    end

end

local FLUENT_URL = "https://github.com/StyearX/Fluent-modded/releases/download/1.5.5/FluentPro"

local function loadFluent()

    assert(type(loadstring) == "function", "This environment does not support loadstring.")

    local requestOk, source = pcall(function()

        return game:HttpGet(FLUENT_URL)

    end)

    assert(requestOk and type(source) == "string" and #source > 0, "Failed to download FluentPro.")

    local compileOk, library = pcall(function()

        return loadstring(source)()

    end)

    assert(compileOk and library, "Failed to start FluentPro.")

    return library

end

local Fluent = loadFluent()

Fluent:SetErrorHandler(function(message, fullError)

    warn("[NOVA] " .. tostring(message))

    if fullError then

        warn(fullError)

    end

end)


local DEFAULT_CONFIG = {

    Aimbot = false,

    AimbotRequiresWeapon = true,

    VisibilityCheck = true,

    Prediction = false,

    Smoothness = 0.2,

    FOV = 15,

    CameraFOV = 70,

    AimbotMaxDistance = 500,

    ESPMaxDistance = 1000,

    AimPart = "Head",

    ClosestPlusHeadChange = 20,

    AimKey = "MouseRight",

    ShowFOV = false,

    FOVColor = Color3.fromRGB(255, 50, 50),

    ESP = false,

    ESPTeamHide = false,

    ESPHighlight = false,

    ESPBox = false,

    ESPTracers = false,

    ESPSkeleton = false,

    ESPNames = false,

    ESPHealth = false,

    ESPHotbar = false,

    EnemyColor = Color3.fromRGB(255, 50, 50),

    TeamColor = Color3.fromRGB(55, 220, 149),

    Silent = {
        Enabled = false,
        Mode = "Universal",
        ActiveMode = "Always",
        Key = "MouseButton2",
        AimPart = "Head",
        TeamCheck = true,
        WallCheck = true,
        MaxDistance = 1500,
        Fov = 180,
        HitChance = 100,
        Prediction = true,
        PredictionTime = 0.115,
        UseRemoteHook = true,
        UseRaycastHook = true,
    },

}

local function cloneConfigValue(value)

    if type(value) ~= "table" then return value end

    local copy = {}

    for key, nestedValue in pairs(value) do
        copy[key] = cloneConfigValue(nestedValue)
    end

    return copy

end

local Config = {}

for key, defaultValue in pairs(DEFAULT_CONFIG) do
    if Config[key] == nil then
        Config[key] = cloneConfigValue(defaultValue)
    end
end

local Settings = {
    Enabled = false,
    TeamCheck = false,
    VisibleCheck = true,
    TargetPart = "Head",
    FOVRadius = 130,
    FOVVisible = false,
    Prediction = false,
    PredictionAmount = 0.08,
    HitChance = 100,
}

local function sanitizeSilentConfig()
    if type(Config.Silent) ~= "table" then
        Config.Silent = {}
    end

    local silent = Config.Silent
    local defaults = DEFAULT_CONFIG.Silent

    silent.Enabled = silent.Enabled == true
    if silent.Mode ~= "Universal" and silent.Mode ~= "Rivals" and silent.Mode ~= "BloxStrike" then
        silent.Mode = defaults.Mode
    end
    if silent.ActiveMode ~= "Hold" and silent.ActiveMode ~= "Toggle" and silent.ActiveMode ~= "Always" then
        silent.ActiveMode = defaults.ActiveMode
    end
    silent.Key = silent.Key or defaults.Key
    local validSilentAimParts = {
        ["Closest Bone"] = true,
        ["Closest+"] = true,
        Head = true,
        UpperTorso = true,
        HumanoidRootPart = true,
    }
    silent.AimPart = validSilentAimParts[silent.AimPart] and silent.AimPart or defaults.AimPart
    silent.TeamCheck = silent.TeamCheck ~= false
    silent.WallCheck = silent.WallCheck ~= false
    silent.MaxDistance = math.clamp(tonumber(silent.MaxDistance) or defaults.MaxDistance, 50, 5000)
    silent.Fov = math.clamp(tonumber(silent.Fov) or defaults.Fov, 0, 500)
    silent.HitChance = math.clamp(tonumber(silent.HitChance) or defaults.HitChance, 0, 100)
    silent.Prediction = silent.Prediction ~= false
    silent.PredictionTime = math.clamp(tonumber(silent.PredictionTime) or defaults.PredictionTime, 0, 1)
    silent.UseRemoteHook = silent.UseRemoteHook ~= false
    silent.UseRaycastHook = silent.UseRaycastHook ~= false
end

local function sanitizeSettings()
    Settings.TargetPart = Settings.TargetPart or "Head"
    Settings.FOVRadius = math.clamp(tonumber(Settings.FOVRadius) or 130, 0, 500)
    Settings.PredictionAmount = math.clamp(tonumber(Settings.PredictionAmount) or 0.08, 0, 1)
    Settings.HitChance = math.clamp(tonumber(Settings.HitChance) or 100, 0, 100)
end

sanitizeSettings()

local Whitelist = {}

local CONFIG_FILE_NAME = "torpedo_config.json"

local function getKeyName(value)

    if typeof(value) == "EnumItem" then
        return value.Name
    end

    local keyName = tostring(value or "")
    local enumName = keyName:match("^Enum%.KeyCode%.(.+)$")

    return enumName or keyName:match("^Enum%.UserInputType%.(.+)$") or keyName

end

local function serializeConfigValue(value)

    if typeof(value) == "Color3" then

        return {

            __type = "Color3",

            R = value.R,

            G = value.G,

            B = value.B,

        }

    end

    return value

end

local function deserializeConfigValue(value)

    if type(value) == "table" and value.__type == "Color3" then

        return Color3.new(

            tonumber(value.R) or 1,

            tonumber(value.G) or 1,

            tonumber(value.B) or 1

        )

    end

    return value

end

local function getSerializedConfig()

    local serialized = {}

    for key, value in pairs(Config) do

        local normalized = value

        if key == "AimKey" then
            normalized = getKeyName(value)
        end

        serialized[key] = serializeConfigValue(normalized)

    end

    return serialized

end

local function saveConfig()

    if type(writefile) ~= "function" or not game:GetService("HttpService") then

        return false, "This environment does not support file writing."

    end

    local success, result = pcall(function()

        return game:GetService("HttpService"):JSONEncode(getSerializedConfig())

    end)

    if not success then return false, "Config could not be encoded as JSON." end

    local writeSuccess = pcall(function() writefile(CONFIG_FILE_NAME, result) end)

    if not writeSuccess then return false, "Config file could not be saved." end

    return true, "Config saved."

end

local function loadConfig()

    if type(readfile) ~= "function" or type(isfile) ~= "function" or not isfile(CONFIG_FILE_NAME) then

        return false, "No saved config was found."

    end

    local readSuccess, contents = pcall(function() return readfile(CONFIG_FILE_NAME) end)

    if not readSuccess or type(contents) ~= "string" then return false, "Config file could not be read." end

    local decodeSuccess, values = pcall(function()

        return game:GetService("HttpService"):JSONDecode(contents)

    end)

    if not decodeSuccess or type(values) ~= "table" then return false, "Config file is invalid." end

    for key, defaultValue in pairs(DEFAULT_CONFIG) do

        if values[key] ~= nil then

            local value = deserializeConfigValue(values[key])

            if key == "Silent" and type(value) == "table" then

                local mergedSilent = cloneConfigValue(defaultValue)

                for nestedKey, nestedValue in pairs(value) do
                    mergedSilent[nestedKey] = nestedValue
                end

                value = mergedSilent

            end

            if type(value) == type(defaultValue) or typeof(value) == typeof(defaultValue) then

                Config[key] = value

            end

        end

    end

    Config.CameraFOV = math.clamp(tonumber(Config.CameraFOV) or DEFAULT_CONFIG.CameraFOV, 40, 120)
    Config.FOV = math.clamp(tonumber(Config.FOV) or DEFAULT_CONFIG.FOV, 10, 500)
    Config.Smoothness = math.clamp(tonumber(Config.Smoothness) or DEFAULT_CONFIG.Smoothness, 0.1, 1)
    Config.AimbotMaxDistance = math.clamp(tonumber(Config.AimbotMaxDistance) or DEFAULT_CONFIG.AimbotMaxDistance, 50, 5000)
    Config.ESPMaxDistance = math.clamp(tonumber(Config.ESPMaxDistance) or DEFAULT_CONFIG.ESPMaxDistance, 50, 5000)
    Config.ClosestPlusHeadChange = math.clamp(tonumber(Config.ClosestPlusHeadChange) or DEFAULT_CONFIG.ClosestPlusHeadChange, 0, 100)
    Config.AimKey = getKeyName(Config.AimKey)
    sanitizeSilentConfig()
    local validAimParts = {
        ["Closest Bone"] = true,
        ["Closest+"] = true,
        Head = true,
        UpperTorso = true,
        HumanoidRootPart = true,
    }

    if not validAimParts[Config.AimPart] then
        Config.AimPart = DEFAULT_CONFIG.AimPart
    end

    local validSilentAimParts = {
        ["Closest Bone"] = true,
        ["Closest+"] = true,
        Head = true,
        UpperTorso = true,
        HumanoidRootPart = true,
    }

    if not validSilentAimParts[Config.Silent.AimPart] then
        Config.Silent.AimPart = DEFAULT_CONFIG.Silent.AimPart
    end

    return true, "Config loaded."

end

local function resetConfig()

    for key, value in pairs(DEFAULT_CONFIG) do

        Config[key] = value

    end

    local saved, message = saveConfig()

    if not saved then
        return false, "Settings were reset but could not be saved: " .. message
    end

    return true, "Config reset to defaults and saved."

end

for key, value in pairs(DEFAULT_CONFIG) do

    Config[key] = cloneConfigValue(value)

end

loadConfig()

sanitizeSilentConfig()

Environment.NOVAConfig = Config

Environment.NOVALoaded = true

local runtimeAlive = true
Environment.runtimeAlive = true

local OriginalCameraFOV

local CameraChangedConnection

local MinimizeInputConnection

local Window

local CUSTOM_THEME_NAME = "Gargantua"

local DEFAULT_THEME_NAME = "AMOLED"

local DEFAULT_ACCENT = Color3.fromRGB(225, 225, 225)

local Appearance = {

    Accent = DEFAULT_ACCENT,

    Background = "",

    BackgroundTransparency = 0.18,

    ShowBackground = true,

    Animated = true,

    Acrylic = true,

    Transparent = true,

}

local BackgroundPresets = {

    ["None"] = "",

    ["Dark Glass"] = "rbxassetid://134736124666311",

    ["Red"] = "rbxassetid://121343473918667",

    ["Cyan"] = "rbxassetid://95656189244173",

    ["Gold"] = "rbxassetid://107795771598485",

    ["Floral"] = "rbxassetid://133541508207801",

    ["Purple Galaxy"] = "rbxassetid://136310484943077",

}

local BackgroundNames = {

    "None",

    "Dark Glass",

    "Red",

    "Cyan",

    "Gold",

    "Floral",

    "Purple Galaxy",

}

local function mix(from, to, amount)

    return from:Lerp(to, amount)

end

local function buildCustomTheme()

    local accent = Appearance.Accent

    local black = Color3.fromRGB(5, 5, 10)

    local dark = Color3.fromRGB(10, 9, 18)

    local white = Color3.fromRGB(245, 242, 255)

    local softAccent = mix(accent, white, 0.22)

    local deepAccent = mix(black, accent, 0.34)

    local mediumAccent = mix(black, accent, 0.56)

    return {

        Accent = accent,

        AcrylicMain = dark,

        AcrylicBorder = mediumAccent,

        AcrylicGradient = ColorSequence.new({

            ColorSequenceKeypoint.new(0, mix(dark, accent, 0.24)),

            ColorSequenceKeypoint.new(0.5, dark),

            ColorSequenceKeypoint.new(1, black),

        }),

        AcrylicNoise = 0.92,

        TitleBarLine = mediumAccent,

        Tab = deepAccent,

        Element = Color3.fromRGB(16, 16, 16),

        ElementBorder = deepAccent,

        InElementBorder = mediumAccent,

        ElementTransparency = 0.88,

        ElementBorderThickness = 1,

        ToggleSlider = deepAccent,

        ToggleToggled = accent,

        SliderRail = deepAccent,

        CheckboxUnchecked = deepAccent,

        CheckboxChecked = accent,

        CheckboxCheck = white,

        ProgressBarRail = deepAccent,

        ProgressBarFill = accent,

        DropdownFrame = Color3.fromRGB(12, 12, 12),

        DropdownHolder = black,

        DropdownBorder = mediumAccent,

        DropdownBorderThickness = 1,

        DropdownOption = Color3.fromRGB(24, 24, 24),

        Keybind = Color3.fromRGB(18, 18, 18),

        Input = Color3.fromRGB(18, 18, 18),

        InputFocused = black,

        InputIndicator = softAccent,

        InputIndicatorFocus = white,

        Dialog = dark,

        DialogHolder = black,

        DialogHolderLine = mediumAccent,

        DialogButton = Color3.fromRGB(22, 22, 22),

        DialogButtonBorder = mediumAccent,

        DialogBorder = deepAccent,

        DialogInput = Color3.fromRGB(18, 18, 18),

        DialogInputLine = softAccent,

        Text = white,

        SubText = mix(Color3.fromRGB(155, 150, 175), accent, 0.22),

        Hover = accent,

        HoverChange = 0.06,

        IconColor = softAccent,

        IconSize = 17,

        Background = Appearance.Background ~= "" and Appearance.Background or nil,

        BackgroundTransparency = Appearance.BackgroundTransparency,

        ViewportBackground = black,

        ViewportBackgroundImages = Appearance.ShowBackground,

        DropdownOutsideWindowBackground = black,

        DropdownOutsideWindowBackgroundImages = Appearance.ShowBackground,

        ShineEnabled = Appearance.Animated,

        Shine = {

            Speed = 0.45,

            RotationSpeed = 22,

            ColorSequence = ColorSequence.new({

                ColorSequenceKeypoint.new(0, deepAccent),

                ColorSequenceKeypoint.new(0.5, softAccent),

                ColorSequenceKeypoint.new(1, deepAccent),

            }),

        },

        StrokeShine = Appearance.Animated,

        StrokeDark = deepAccent,

        ButtonGradient = {

            Background = ColorSequence.new({

                ColorSequenceKeypoint.new(0, mix(dark, accent, 0.28)),

                ColorSequenceKeypoint.new(1, black),

            }),

            Stroke = ColorSequence.new({

                ColorSequenceKeypoint.new(0, mediumAccent),

                ColorSequenceKeypoint.new(0.5, softAccent),

                ColorSequenceKeypoint.new(1, mediumAccent),

            }),

        },

        ThemeAccentColors = { accent },

    }

end

Fluent:RegisterCustomTheme(CUSTOM_THEME_NAME, buildCustomTheme())

local function updateBackgroundVisibility()

    task.defer(function()

        if not runtimeAlive then return end

        local acrylicPaint = Window and Window.AcrylicPaint

        local frame = acrylicPaint and acrylicPaint.Frame

        local background = frame and frame:FindFirstChild("__ThemeBG")

        if background then

            background.Visible = Appearance.ShowBackground and Appearance.Background ~= ""

        end

    end)

end

local function applyCustomTheme()

    if not runtimeAlive or not Fluent then return end

    Fluent:RegisterCustomTheme(CUSTOM_THEME_NAME, buildCustomTheme())

    if Window then

        Fluent:SetTheme(CUSTOM_THEME_NAME)

        updateBackgroundVisibility()

    end

end

local function normalizeAssetId(value)

    local rawValue = tostring(value or "")

    if rawValue == "" then return "" end

    local assetId = rawValue:match("%d+")

    return assetId and ("rbxassetid://" .. assetId) or nil

end

local function makeDropdownClosable(dropdown)

    if not dropdown or not dropdown.Frame or not dropdown.Open or not dropdown.Close then return end

    local closeOverlay = Instance.new("TextButton")

    closeOverlay.Name = "__NovaDropdownCloseFix"

    closeOverlay.Text = ""

    closeOverlay.AutoButtonColor = false

    closeOverlay.BackgroundTransparency = 1

    closeOverlay.Size = UDim2.fromOffset(160, 30)

    closeOverlay.Position = UDim2.new(1, -10, 0.5, 0)

    closeOverlay.AnchorPoint = Vector2.new(1, 0.5)

    closeOverlay.ZIndex = 100

    closeOverlay.Visible = false

    closeOverlay.Parent = dropdown.Frame

    local originalOpen = dropdown.Open

    local originalClose = dropdown.Close

    dropdown.Open = function(self, ...) originalOpen(self, ...); closeOverlay.Visible = true end

    dropdown.Close = function(self, ...) originalClose(self, ...); closeOverlay.Visible = false end

    closeOverlay.MouseButton1Click:Connect(function() dropdown:Close() end)

end

-- ============================================================

-- AIMBOT & TEAM CHECK

-- ============================================================

assert(Drawing and type(Drawing.new) == "function", "This environment does not support the Drawing API.")

local FOVCircle = Drawing.new("Circle")

FOVCircle.Thickness = 2

FOVCircle.Visible = false

FOVCircle.Color = Config.FOVColor

FOVCircle.Transparency = 0.5

FOVCircle.Filled = false

local TeamCache = setmetatable({}, { __mode = "k" })
local TEAM_CACHE_DURATION = 0.25
local TeamChangedConnection

TeamChangedConnection = LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()

    for player in pairs(TeamCache) do
        TeamCache[player] = nil
    end

end)

local function isSameTeam(player)

    if not player or player == LocalPlayer then

        return true

    end

    local now = os.clock()
    local cached = TeamCache[player]

    if cached and now - cached.Timestamp < TEAM_CACHE_DURATION then

        return cached.Value

    end

    local sameTeam = LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team

    if not sameTeam then

        local success1, lAttr = pcall(function() return LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("Faction") end)
        local success2, pAttr = pcall(function() return player:GetAttribute("Team") or player:GetAttribute("Faction") end)

        sameTeam = success1 and success2 and lAttr ~= nil and pAttr ~= nil and lAttr == pAttr

    end

    TeamCache[player] = {
        Timestamp = now,
        Value = sameTeam == true,
    }

    return sameTeam == true

end

local function isTargetVisible(character, targetPart)

    local localCharacter = LocalPlayer.Character

    if not localCharacter or not character or not targetPart then return false end

    local originPart = localCharacter:FindFirstChild("Head")
        or localCharacter:FindFirstChild("HumanoidRootPart")
        or localCharacter.PrimaryPart
        or localCharacter:FindFirstChild("UpperTorso")
        or localCharacter:FindFirstChild("Torso")
        or localCharacter:FindFirstChild("LowerTorso")

    if not originPart then return false end

    local direction = targetPart.Position - originPart.Position

    if direction.Magnitude <= 0 then return true end

    local raycastParams = RaycastParams.new()

    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    raycastParams.FilterDescendantsInstances = { localCharacter }

    raycastParams.IgnoreWater = true

    local result = Workspace:Raycast(originPart.Position, direction, raycastParams)

    return result == nil or result.Instance:IsDescendantOf(character)

end

local function isESPVisible(character, originPart)

    local targetPart = character and (character:FindFirstChild("Head") or originPart)

    if not targetPart then return false end

    local localCharacter = LocalPlayer.Character

    local localOrigin = localCharacter and (
        localCharacter:FindFirstChild("Head")
        or localCharacter:FindFirstChild("HumanoidRootPart")
        or localCharacter.PrimaryPart
        or localCharacter:FindFirstChild("UpperTorso")
        or localCharacter:FindFirstChild("Torso")
        or localCharacter:FindFirstChild("LowerTorso")
    )

    if not localOrigin then return false end

    local raycastParams = RaycastParams.new()

    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    raycastParams.FilterDescendantsInstances = { localCharacter }

    raycastParams.IgnoreWater = true

    local result = Workspace:Raycast(localOrigin.Position, targetPart.Position - localOrigin.Position, raycastParams)

    return result == nil or result.Instance:IsDescendantOf(character)

end

local function getCharacterRootPart(character)

    if not character then return nil end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
        or character.PrimaryPart
        or character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Torso")
        or character:FindFirstChild("LowerTorso")

    if rootPart and rootPart:IsA("BasePart") then
        return rootPart
    end

    for _, descendant in ipairs(character:GetDescendants()) do

        if descendant:IsA("BasePart") then
            return descendant
        end

    end

    return nil

end

local function getCharacterHumanoid(character)

    if not character then return nil end

    return character:FindFirstChildOfClass("Humanoid")
        or character:FindFirstChildWhichIsA("Humanoid", true)

end

local function buildTargetSelectionSettings(settings)
    local normalized = {
        FOV = tonumber((settings and settings.FOV) or Config.FOV or DEFAULT_CONFIG.FOV) or DEFAULT_CONFIG.FOV,
        AimbotMaxDistance = tonumber((settings and settings.AimbotMaxDistance) or Config.AimbotMaxDistance or DEFAULT_CONFIG.AimbotMaxDistance) or DEFAULT_CONFIG.AimbotMaxDistance,
        AimPart = (settings and settings.AimPart) or Config.AimPart or DEFAULT_CONFIG.AimPart,
        ClosestPlusHeadChange = tonumber((settings and settings.ClosestPlusHeadChange) or Config.ClosestPlusHeadChange or DEFAULT_CONFIG.ClosestPlusHeadChange) or DEFAULT_CONFIG.ClosestPlusHeadChange,
        VisibilityCheck = (settings and settings.VisibilityCheck ~= nil) and settings.VisibilityCheck or (Config.VisibilityCheck ~= false),
        Prediction = (settings and settings.Prediction ~= nil) and settings.Prediction or (Config.Prediction == true),
        TeamCheck = (settings and settings.TeamCheck ~= nil) and settings.TeamCheck or Settings.TeamCheck == true,
        TargetPart = (settings and settings.TargetPart) or Settings.TargetPart or Config.AimPart or DEFAULT_CONFIG.AimPart,
    }

    sanitizeSettings()
    return normalized
end

Environment.isSameTeam = isSameTeam
Environment.getCharacterRootPart = getCharacterRootPart
Environment.getCharacterHumanoid = getCharacterHumanoid

local function getTarget(settings)
    settings = buildTargetSelectionSettings(settings)

    local camera = Workspace.CurrentCamera

    if not camera then return nil end

    local closestPart = nil

    local closestDistance = math.max(1, tonumber(settings.FOV) or DEFAULT_CONFIG.FOV)

    local screenCenter = camera.ViewportSize / 2

    local localCharacter = LocalPlayer.Character

    local localRootPart = getCharacterRootPart(localCharacter)

    local targetPartName = settings.TargetPart or Settings.TargetPart or "Head"

    if not localRootPart then return nil end

    for _, player in ipairs(Players:GetPlayers()) do

        local character = player.Character

        local humanoid = getCharacterHumanoid(character)

        local rootPart = getCharacterRootPart(character)

        local canTarget = player ~= LocalPlayer
            and character ~= nil
            and character.Parent ~= nil
            and humanoid ~= nil
            and humanoid.Health > 0
            and rootPart ~= nil
            and not Whitelist[player.UserId]
            and (settings.TeamCheck == false or not isSameTeam(player))
            and (rootPart.Position - localRootPart.Position).Magnitude <= (tonumber(settings.AimbotMaxDistance) or DEFAULT_CONFIG.AimbotMaxDistance)

        if canTarget then

            local part = nil

            pcall(function()

                if settings.AimPart == "Closest Bone" or settings.AimPart == "Closest+" then

                    local closestDistance = math.huge

                    local headChange = math.clamp(tonumber(settings.ClosestPlusHeadChange) or 0, 0, 100) / 100

                    local boneNames = {

                        "Head", "UpperTorso", "LowerTorso", "Torso", "HumanoidRootPart",

                        "LeftUpperArm", "LeftLowerArm", "LeftHand", "Left Arm",

                        "RightUpperArm", "RightLowerArm", "RightHand", "Right Arm",

                        "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Left Leg",

                        "RightUpperLeg", "RightLowerLeg", "RightFoot", "Right Leg",

                    }

                    for _, boneName in ipairs(boneNames) do

                        local bone = character:FindFirstChild(boneName)

                        if bone and bone:IsA("BasePart") then

                            local bonePosition, boneVisible = camera:WorldToViewportPoint(bone.Position)

                            if boneVisible then

                                local distance = (Vector2.new(bonePosition.X, bonePosition.Y) - screenCenter).Magnitude

                                local score = distance

                                if settings.AimPart == "Closest+" and boneName == "Head" then

                                    score = distance * (1 - headChange)

                                end

                                if score < closestDistance then

                                    closestDistance = score

                                    part = bone

                                end

                            end

                        end

                    end

                else

                    part = character:FindFirstChild(targetPartName)
                        or character:FindFirstChild(settings.AimPart)
                        or character:FindFirstChild("Head")
                        or character:FindFirstChild("UpperTorso")
                        or character:FindFirstChild("Torso")
                        or character:FindFirstChild("LowerTorso")
                        or character:FindFirstChild("HumanoidRootPart")

                    if not part then

                        for _, descendant in ipairs(character:GetDescendants()) do

                            if descendant:IsA("BasePart") then
                                part = descendant
                                break
                            end

                        end

                    end

                end

            end)

            if part and (not settings.VisibilityCheck or isTargetVisible(character, part)) then

                local targetPosition = part.Position

                if settings.Prediction and rootPart then

                    targetPosition = targetPosition + (rootPart.AssemblyLinearVelocity * 0.08)

                end

                local screenPosition, onScreen = camera:WorldToViewportPoint(targetPosition)

                if onScreen and screenPosition.Z > 0 then

                    local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - screenCenter).Magnitude

                    if distance < closestDistance then

                        closestDistance = distance

                        closestPart = part

                    end

                end

            end

        end

    end

    return closestPart

end

Environment.getTarget = getTarget

local function getClosestPlayer()
    local settings = buildTargetSelectionSettings({
        FOV = Config.FOV,
        AimbotMaxDistance = Config.AimbotMaxDistance,
        AimPart = Config.AimPart,
        ClosestPlusHeadChange = Config.ClosestPlusHeadChange,
        VisibilityCheck = Config.VisibilityCheck,
        Prediction = Config.Prediction,
        TeamCheck = Settings.TeamCheck,
        TargetPart = Settings.TargetPart,
    })

    return getTarget(settings)
end

local function loadSilentModule()
    local fileName = "silent.lua"

    if type(loadfile) == "function" then
        local ok, result = pcall(function()
            return loadfile(fileName)()
        end)
        if ok then
            return result
        end
        warn("[Torpedo] Failed to load silent.lua via loadfile: " .. tostring(result))
    end

    if type(isfile) == "function" and type(readfile) == "function" and isfile(fileName) then
        local ok, source = pcall(function()
            return readfile(fileName)
        end)
        if ok and type(source) == "string" and #source > 0 then
            local loadOk, result = pcall(function()
                return loadstring(source)()
            end)
            if loadOk then
                return result
            end
            warn("[Torpedo] Failed to load silent.lua via loadstring: " .. tostring(result))
        end
    end

    return nil
end

pcall(loadSilentModule)

local SilentAim = Environment.SilentAim

local function isAimKeyDown(keyValue)

    local keyName = getKeyName(keyValue or Config.AimKey)

    if keyName == "MouseRight" or keyName == "MouseButton2" then

        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)

    elseif keyName == "MouseLeft" or keyName == "MouseButton1" then

        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)

    end

    local keyCode = Enum.KeyCode[keyName]

    if keyCode and keyCode ~= Enum.KeyCode.Unknown then

        return UserInputService:IsKeyDown(keyCode)

    end

    return false

end

function MoveMouse(dx, dy)

    dx = tonumber(dx) or 0
    dy = tonumber(dy) or 0

    if type(mousemoverel) == "function" then
        local success = pcall(mousemoverel, dx, dy)
        if success then return true end
    end

    if type(syn) == "table" and type(syn.mouse_move) == "function" then
        local success = pcall(syn.mouse_move, dx, dy)
        if success then return true end
    end

    if type(mouse_move) == "function" then
        local success = pcall(mouse_move, dx, dy)
        if success then return true end
    end

    local success = pcall(function()
        local virtualInputManager = game:GetService("VirtualInputManager")
        virtualInputManager:SendMouseMoveEvent(dx, dy, false)
    end)

    return success

end

local function isWeaponTool(item)

    if not item or not item:IsA("Tool") then return false end

    local itemName = string.lower(item.Name)

    return not itemName:find("energy shot", 1, true)

        and not itemName:find("blood bag", 1, true)

end

local function isHoldingWeapon()

    local character = LocalPlayer.Character

    if not character then return false end

    for _, item in ipairs(character:GetChildren()) do

        if isWeaponTool(item) then return true end

    end

    return false

end

-- ============================================================
-- SILENT AIM BACKEND 

-- Silent module moved to silent.lua.
-- The main script keeps only the UI config and shared target selectors.

-- ============================================================

-- ESP MODULE

-- ============================================================

local ESPObjects = {}

local FriendControls = {}

local FriendsPlayerAddedConnection

local function destroyFriendControl(userId)

    local control = FriendControls[userId]

    if not control then return end

    pcall(function()

        if type(control.Destroy) == "function" then

            control:Destroy()

        elseif type(control.Remove) == "function" then

            control:Remove()

        elseif control.Instance then

            control.Instance:Destroy()

        elseif control.Container then

            control.Container:Destroy()

        end

    end)

    FriendControls[userId] = nil

end

local function destroyAllFriendControls()

    for userId in pairs(FriendControls) do
        destroyFriendControl(userId)
    end

    for userId in pairs(Whitelist) do
        Whitelist[userId] = nil
    end

end

local ESP_UPDATE_INTERVAL = 1 / 60

local ESP_EXPENSIVE_UPDATE_INTERVAL = 0.8

local ESP_HOTBAR_UPDATE_INTERVAL = 2.5

local function createDrawingLine()

    local line = Drawing.new("Line")

    line.Thickness = 1.5

    line.Visible = false

    return line

end

local function hideLines(lines)

    for _, line in ipairs(lines) do line.Visible = false end

end

local function hideESPData(data)

    if data.Highlight then data.Highlight.Enabled = false end

    if data.Billboard then data.Billboard.Enabled = false end

    if data.FriendBillboard then data.FriendBillboard.Enabled = false end

    if data.Label then data.Label.Visible = false end

    if data.HealthBarBackground then data.HealthBarBackground.Visible = false end

    if data.HealthBarFill then data.HealthBarFill.Visible = false end

    hideLines(data.BoxLines)

    data.TracerLine.Visible = false

    hideLines(data.SkeletonLines)

    for _, slot in ipairs(data.HotbarSlots) do slot.Visible = false end

end

local function hideESPHealthAndHotbar(data)

    if data.HealthBarBackground then data.HealthBarBackground.Visible = false end

    if data.HealthBarFill then data.HealthBarFill.Visible = false end

    for _, slot in ipairs(data.HotbarSlots) do slot.Visible = false end

end

local function hideAllESP()

    for _, data in pairs(ESPObjects) do

        hideESPData(data)

    end

end

local function removeDrawing(object)

    if object then

        pcall(function() object.Visible = false end)

        pcall(function() object:Remove() end)

    end

end

local function createDrawingText()

    local text = Drawing.new("Text")

    text.Size = 13

    text.Center = true

    text.Outline = true

    text.Visible = false

    return text

end

local function disconnectConnection(connection)

    if connection then

        pcall(function() connection:Disconnect() end)

    end

end

local function destroyInstance(instance)

    if instance then

        pcall(function() instance:Destroy() end)

    end

end

local function destroyCharacterVisuals(data)

    destroyInstance(data.Highlight)

    destroyInstance(data.Billboard)

    destroyInstance(data.FriendBillboard)

    data.Highlight = nil

    data.Billboard = nil

    data.FriendBillboard = nil

    data.Label = nil

    data.FriendLabel = nil

end

local function setupCharacterVisuals(data, character)

    if not runtimeAlive or data.Destroyed or not character or not character.Parent then return end

    destroyCharacterVisuals(data)

    local highlight = Instance.new("Highlight")

    highlight.Name = "NOVA_ESPHighlight"

    highlight.Adornee = character

    highlight.FillTransparency = 0.7

    highlight.OutlineTransparency = 0.2

    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    highlight.Enabled = false

    highlight.Parent = character

    data.Highlight = highlight

    local billboard = Instance.new("BillboardGui")

    billboard.Name = "NOVA_ESPName"

    billboard.Size = UDim2.new(0, 200, 0, 50)

    billboard.AlwaysOnTop = true

    billboard.ExtentsOffset = Vector3.new(0, 2.5, 0)

    billboard.Enabled = true

    billboard.Parent = character

    -- Store this reference before WaitForChild yields. This lets Unload destroy

    -- the BillboardGui even if the character has not received its Head yet.

    data.Billboard = billboard

    local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 2)
    local anchorPart = head
        or character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Torso")
        or character:FindFirstChild("LowerTorso")

    -- A delayed setup task may resume after Unload. Never recreate ESP then.

    if not runtimeAlive or data.Destroyed or data.Character ~= character or data.Billboard ~= billboard or not billboard.Parent then

        destroyInstance(billboard)

        if data.Billboard == billboard then data.Billboard = nil end

        return

    end

    if anchorPart then billboard.Adornee = anchorPart end

    local label = Instance.new("TextLabel")

    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.TextSize = 13
    label.Font = Enum.Font.SourceSansBold
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Visible = false
    label.Parent = billboard

    data.Label = label

    local friendBillboard = Instance.new("BillboardGui")

    friendBillboard.Name = "NOVA_FriendTag"

    friendBillboard.Size = UDim2.new(0, 120, 0, 28)

    friendBillboard.AlwaysOnTop = true

    friendBillboard.ExtentsOffset = Vector3.new(0, 3.5, 0)

    friendBillboard.Enabled = true

    friendBillboard.Parent = character

    if anchorPart then friendBillboard.Adornee = anchorPart end

    data.FriendBillboard = friendBillboard

    local friendLabel = Instance.new("TextLabel")

    friendLabel.Size = UDim2.new(1, 0, 1, 0)

    friendLabel.BackgroundTransparency = 1

    friendLabel.Text = "Friend"

    friendLabel.TextColor3 = Color3.fromRGB(55, 220, 149)

    friendLabel.TextStrokeTransparency = 0

    friendLabel.TextSize = 14

    friendLabel.Font = Enum.Font.SourceSansBold

    friendLabel.Visible = runtimeAlive and data.Player and Whitelist[data.Player.UserId] == true

    friendLabel.Parent = friendBillboard

    data.FriendLabel = friendLabel

end

local function ensureCharacterVisuals(data, character)

    if not runtimeAlive or not character or not character.Parent or data.VisualSetupPending then return end

    if data.Billboard or data.FriendBillboard then return end

    data.Character = character
    data.VisualSetupPending = true

    task.spawn(function()

        setupCharacterVisuals(data, character)

        data.VisualSetupPending = false

    end)

end

local function updateFriendTag(player, data)

    if Whitelist[player.UserId] and not data.FriendBillboard then
        ensureCharacterVisuals(data, player.Character)

    end

    if data.FriendLabel then

        data.FriendLabel.Visible = runtimeAlive and Whitelist[player.UserId] == true

    end

end

local function disconnectHotbarConnections(data)

    for _, connection in ipairs(data.HotbarConnections or {}) do
        disconnectConnection(connection)
    end

    data.HotbarConnections = {}

end

local function invalidateHotbar(data)

    data.HotbarDirty = true
    data.LastHotbarUpdate = 0

end

local function watchHotbarContainer(data, container)

    if not container then return end

    data.HotbarConnections[#data.HotbarConnections + 1] = container.ChildAdded:Connect(function()
        invalidateHotbar(data)
    end)

    data.HotbarConnections[#data.HotbarConnections + 1] = container.ChildRemoved:Connect(function()
        invalidateHotbar(data)
    end)

end

local function updateHotbarWatchers(data, character, backpack)

    if data.HotbarCharacter == character and data.HotbarBackpack == backpack then return end

    disconnectHotbarConnections(data)

    data.HotbarCharacter = character
    data.HotbarBackpack = backpack

    watchHotbarContainer(data, character)
    watchHotbarContainer(data, backpack)
    invalidateHotbar(data)

end

local function connectSkeletonPart(camera, data, firstPart, secondPart, lineIndex, color)

    local line = data.SkeletonLines[lineIndex]

    if not line or not firstPart or not secondPart then return end

    local firstPosition, firstVisible = camera:WorldToViewportPoint(firstPart.Position)

    local secondPosition, secondVisible = camera:WorldToViewportPoint(secondPart.Position)

    if firstVisible or secondVisible then

        line.From = Vector2.new(firstPosition.X, firstPosition.Y)

        line.To = Vector2.new(secondPosition.X, secondPosition.Y)

        line.Color = color

        line.Visible = true

    end

end

local function getItemIdentifier(instance, key)

    local attributeValue = instance:GetAttribute(key)

    if attributeValue ~= nil then return tostring(attributeValue) end

    local child = instance:FindFirstChild(key, true)

    if child and child:IsA("ValueBase") and child.Value ~= nil then

        return tostring(child.Value)

    end

    return nil

end

local GunTemplateCache = setmetatable({}, { __mode = "k" })

local function isItemTemplate(instance)
    return instance
        and (instance:IsA("Tool") or instance:IsA("Model") or instance:IsA("Folder"))
end

local function findGunTemplate(item)

    if not item or not item:IsA("Tool") then return nil end

    if GunTemplateCache[item] ~= nil then

        return GunTemplateCache[item] or nil

    end

    local gunTemplates = ReplicatedStorage:FindFirstChild("Items")
    local templateFolders = {}

    if gunTemplates then

        for _, folderName in ipairs({ "Guns", "gun", "Gun", "Melees", "melee", "Melee" }) do

            local folder = gunTemplates:FindFirstChild(folderName)

            if folder then templateFolders[#templateFolders + 1] = folder end

        end

    end

    for _, folder in ipairs(templateFolders) do

        local directTemplate = folder:FindFirstChild(item.Name)

        if isItemTemplate(directTemplate) then

            GunTemplateCache[item] = directTemplate
            return directTemplate

        end

    end

    local nameKeys = { "DisplayName", "ItemName", "WeaponName", "Name", "Item" }
    local normalizedNames = {}

    for _, key in ipairs(nameKeys) do

        local value = getItemIdentifier(item, key)

        if value and value ~= "" then
            normalizedNames[string.lower(value):gsub("[%s_%-]+", "")] = true
        end

    end

    if next(normalizedNames) then

        for _, folder in ipairs(templateFolders) do

            for _, candidate in ipairs(folder:GetChildren()) do

                if isItemTemplate(candidate) then

                    local candidateNames = { candidate.Name }

                    for _, key in ipairs(nameKeys) do
                        local value = getItemIdentifier(candidate, key)
                        if value then candidateNames[#candidateNames + 1] = value end
                    end

                    for _, value in ipairs(candidateNames) do

                        local normalizedValue = string.lower(tostring(value)):gsub("[%s_%-]+", "")

                        if normalizedNames[normalizedValue] then
                            GunTemplateCache[item] = candidate
                            return candidate
                        end

                    end

                end

            end

        end

    end

    if #templateFolders == 0 then return nil end

    local template
    local imageId = item:GetAttribute("ImageId")

    if imageId then

        for _, folder in ipairs(templateFolders) do

            for _, candidate in ipairs(folder:GetChildren()) do

                if isItemTemplate(candidate) and candidate:GetAttribute("ImageId") == imageId then

                    GunTemplateCache[item] = candidate
                    return candidate

                end

            end

        end

    end

    local candidates = {}

    for _, folder in ipairs(templateFolders) do
        for _, candidate in ipairs(folder:GetChildren()) do
            if isItemTemplate(candidate) then candidates[#candidates + 1] = candidate end
        end
    end

    if #candidates > 0 then

        local matchKeys = {
            "Value", "ItemValue", "ItemId", "ItemID", "ID", "Id",
            "ItemGUID", "RarityName", "AmmoType", "damage", "MagSize",
            "fire_rate", "range", "ImageId", "Price", "RarityPrice",
        }

        local bestScore = 0
        local secondBestScore = 0
        local bestCandidate

        for _, candidate in ipairs(candidates) do

            if isItemTemplate(candidate) then

                local score = 0

                for _, key in ipairs(matchKeys) do

                    local itemValue = getItemIdentifier(item, key)
                    local candidateValue = getItemIdentifier(candidate, key)

                    if itemValue ~= nil and itemValue == candidateValue then

                        score = score + 1

                    end

                end

                if score > bestScore then

                    secondBestScore = bestScore
                    bestScore = score
                    bestCandidate = candidate

                elseif score > secondBestScore then

                    secondBestScore = score

                end

            end

        end

        if bestScore >= 2 and bestScore > secondBestScore then
            template = bestCandidate
        end

    end
    if template then
        GunTemplateCache[item] = template
    end

    return template

end

local ItemInfoCache = setmetatable({}, { __mode = "k" })

local KNOWN_TOOL_NAMES = {
    AK47 = true,
    AUG = true,
    Anaconda = true,
    AWP = true,
    Bizon = true,
    C9 = true,
    Crossbow = true,
    ["Double Barrel"] = true,
    Draco = true,
    ["Energy Shot"] = true,
    ["Firework Launcher"] = true,
    G3 = true,
    Glock = true,
    ["Hunting Rifle"] = true,
    M16 = true,
    M24 = true,
    M249 = true,
    MP5 = true,
    P226 = true,
    P90 = true,
    RPG = true,
    Remington = true,
    Sawnoff = true,
    Skorpion = true,
    Uzi = true,
}

local HIDDEN_HOTBAR_NAMES = {
    fists = true,
    soil = true,
}

local KNOWN_TOOL_NAMES_NORMALIZED = {}

for name in pairs(KNOWN_TOOL_NAMES) do
    KNOWN_TOOL_NAMES_NORMALIZED[string.lower(name):gsub("[%s_-]+", "")] = true
end

local WEAPON_ATTRIBUTE_KEYS = {
    "AmmoType",
    "MagSize",
    "fire_rate",
    "reload_time",
    "bullet_speed",
}

local function isHotbarWeapon(item)

    if not item or not item:IsA("Tool") then return false end

    local normalizedName = string.lower(item.Name):gsub("[%s_-]+", "")

    if HIDDEN_HOTBAR_NAMES[normalizedName] then return false end

    if KNOWN_TOOL_NAMES_NORMALIZED[normalizedName] then return true end

    if findGunTemplate(item) then return true end

    local matches = 0

    for _, key in ipairs(WEAPON_ATTRIBUTE_KEYS) do

        if getItemIdentifier(item, key) ~= nil then

            matches = matches + 1

        end

    end

    return matches >= 2

end

local function getToolInfo(item)

    if not item or not item:IsA("Tool") then
        return { Name = "Unknown", Rarity = nil }
    end

    local function isReadableName(value)

        if type(value) ~= "string" or value == "" then return false end

        if value:match("^%d+$") or value:match("^%{%s*%d+%s*%}$") then

            return false

        end

        local compact = value:gsub("[%s_%-{}]+", "")

        if #compact >= 8 and compact:match("^[%da-fA-F]+$") then

            return false

        end

        if #compact >= 14 and compact:match("^[%w]+$") and not value:match("%s") then

            return false

        end

        return true

    end

    local function cleanItemText(value)

        if type(value) ~= "string" then return nil end

        value = value:gsub("%{%s*%d+%s*%}", "")
        value = value:gsub("^%s+", ""):gsub("%s+$", "")

        if value == "" or value:match("^%d+$") then return nil end

        return value

    end

    local function isRarityName(value)

        if type(value) ~= "string" then return false end

        local normalized = string.lower(value):gsub("[%s_-]+", "")

        return normalized == "common"
            or normalized == "uncommon"
            or normalized == "rare"
            or normalized == "epic"
            or normalized == "legendary"
            or normalized == "mythic"
            or normalized == "godly"

    end

    local function readTextAttribute(instance, names)

        for _, attributeName in ipairs(names) do

            local value = instance:GetAttribute(attributeName)

            if isReadableName(value) then return value end

        end

        for _, descendant in ipairs(instance:GetDescendants()) do

            local lowerName = string.lower(descendant.Name)

            if descendant:IsA("StringValue")
                and isReadableName(descendant.Value)
                and not isRarityName(descendant.Value)
                and (lowerName:find("name", 1, true)
                    or lowerName:find("display", 1, true)
                    or lowerName:find("item", 1, true)
                    or lowerName:find("weapon", 1, true)) then

                return descendant.Value

            end

        end

        return nil

    end

    local cached = ItemInfoCache[item]

    if cached then return cached end

    local template = findGunTemplate(item)

    local displayAttributes = { "DisplayName", "ItemName", "Display", "Label", "Title", "WeaponName" }
    local rarityAttributes = { "Rarity", "Tier", "Quality", "ItemRarity", "RarityName" }

    local name = readTextAttribute(item, displayAttributes)
    local rarity = readTextAttribute(item, rarityAttributes)

    if KNOWN_TOOL_NAMES_NORMALIZED[string.lower(item.Name):gsub("[%s_-]+", "")] then

        name = item.Name

    end

    if not name then

        for attributeName, attributeValue in pairs(item:GetAttributes()) do

            local lowerName = string.lower(attributeName)

            if (lowerName:find("name", 1, true)

                or lowerName:find("display", 1, true)

                or lowerName:find("item", 1, true)

                or lowerName:find("weapon", 1, true))
                and isReadableName(attributeValue)
                and not isRarityName(attributeValue) then

                name = attributeValue
                break

            end

        end

    end

    for _, descendant in ipairs(item:GetDescendants()) do

        if descendant:IsA("StringValue") and isReadableName(descendant.Value) then

            local lowerName = string.lower(descendant.Name)

            if not name and (lowerName:find("name", 1, true)

                or lowerName:find("display", 1, true)

                or lowerName:find("item", 1, true)

                or lowerName:find("weapon", 1, true))
                and not isRarityName(descendant.Value) then

                name = descendant.Value

            elseif not rarity and (lowerName:find("rarity", 1, true)

                or lowerName:find("tier", 1, true)

                or lowerName:find("quality", 1, true)) then

                rarity = descendant.Value

            end

        end

    end

    if isItemTemplate(template) then

        name = name or readTextAttribute(template, displayAttributes)
        rarity = rarity or readTextAttribute(template, rarityAttributes)

        for _, descendant in ipairs(template:GetDescendants()) do

            if descendant:IsA("StringValue") and isReadableName(descendant.Value) then

                local lowerName = string.lower(descendant.Name)

                if not name and (lowerName:find("name", 1, true)

                    or lowerName:find("display", 1, true)

                    or lowerName:find("item", 1, true)

                    or lowerName:find("weapon", 1, true))
                    and not isRarityName(descendant.Value) then

                    name = descendant.Value

                elseif not rarity and (lowerName:find("rarity", 1, true)

                    or lowerName:find("tier", 1, true)

                    or lowerName:find("quality", 1, true)) then

                    rarity = descendant.Value

                end

            end

        end

        if not name and (KNOWN_TOOL_NAMES_NORMALIZED[string.lower(template.Name):gsub("[%s_-]+", "")]
            or (isReadableName(template.Name) and not isRarityName(template.Name))) then

            name = template.Name

        end

    end

    if name and rarity and string.lower(name) == string.lower(rarity) then

        name = nil

    end

    name = cleanItemText(name)
    rarity = cleanItemText(rarity)

    if not name and isReadableName(item.Name) and not isRarityName(item.Name) then

        name = item.Name

    end

    if not name then

        name = item.Name

    end

    local info = {
        Name = name,
        Rarity = rarity and string.gsub(rarity, "^%l", string.upper) or nil,
    }

    ItemInfoCache[item] = info

    return info

end

local RARITY_COLORS = {
    common = Color3.fromRGB(190, 190, 190),
    uncommon = Color3.fromRGB(80, 220, 120),
    rare = Color3.fromRGB(70, 150, 255),
    epic = Color3.fromRGB(180, 80, 255),
    legendary = Color3.fromRGB(255, 190, 45),
    mythic = Color3.fromRGB(255, 80, 80),
}

local function getRarityColor(rarity, fallback)

    if type(rarity) ~= "string" then return fallback end

    return RARITY_COLORS[string.lower(rarity):gsub("%s+", "")] or fallback

end

local function getToolSlotIndex(item, fallback)

    local slotKeys = { "Slot", "SlotIndex", "HotbarSlot", "Index", "LayoutOrder" }

    for _, key in ipairs(slotKeys) do

        local value = tonumber(getItemIdentifier(item, key))

        if value then return value end

    end

    return fallback

end

local function updateESP(player, data)

    if not runtimeAlive or not Config.ESP then

        hideESPData(data)

        return

    end

    local currentCharacter = player.Character
    local backpack = player:FindFirstChildOfClass("Backpack")

    updateHotbarWatchers(data, currentCharacter, backpack)

    if data.Character ~= currentCharacter then
        destroyCharacterVisuals(data)
        data.Character = currentCharacter
        data.CharacterSize = nil
        data.HotbarTools = {}
        data.LastVisibilityUpdate = 0
        data.LastHotbarUpdate = 0
        data.IsVisible = nil
    end

    local hasESPElements = Config.ESPHighlight

        or Config.ESPBox

        or Config.ESPTracers

        or Config.ESPSkeleton

        or Config.ESPNames

        or Config.ESPHealth

        or Config.ESPHotbar

    if not hasESPElements then

        hideESPData(data)

        return

    end

    local now = os.clock()

    if now - (data.LastUpdate or 0) < ESP_UPDATE_INTERVAL then return end

    data.LastUpdate = now
    updateFriendTag(player, data)
    ensureCharacterVisuals(data, currentCharacter)

    local teammate = isSameTeam(player)

    if Config.ESPTeamHide and teammate then

        hideESPData(data)

        return

    end

    local camera = Workspace.CurrentCamera

    local character = player.Character

    local localCharacter = LocalPlayer.Character

    local humanoid = getCharacterHumanoid(character)

    local rootPart = getCharacterRootPart(character)

    local localRootPart = getCharacterRootPart(localCharacter)

    if not camera or not character or not humanoid or humanoid.Health <= 0 or not rootPart or not localRootPart then

        hideESPData(data)

        return

    end

    local currentColor = teammate and Config.TeamColor or Config.EnemyColor

    local distance = (rootPart.Position - localRootPart.Position).Magnitude

    if distance > Config.ESPMaxDistance then

        hideESPData(data)

        return

    end

    local needsVisibilityColor = Config.ESPHighlight
        or Config.ESPNames
        or Config.ESPHealth
        or Config.ESPBox
        or Config.ESPTracers
        or Config.ESPSkeleton

    local visibilityCheckDue = now - (data.LastVisibilityUpdate or 0) >= ESP_EXPENSIVE_UPDATE_INTERVAL

    if needsVisibilityColor and visibilityCheckDue then
        data.LastVisibilityUpdate = now
        data.IsVisible = isESPVisible(character, character:FindFirstChild("Head") or rootPart)
    end

    if needsVisibilityColor and data.IsVisible == false then

        currentColor = Color3.fromRGB(128, 128, 128)

    end

    distance = math.floor(distance)

    if data.Highlight then

        data.Highlight.Enabled = Config.ESPHighlight

        data.Highlight.FillColor = currentColor

        data.Highlight.OutlineColor = currentColor

    end

    if data.Label then

        data.Label.Visible = Config.ESPNames

        data.Label.Text = player.Name .. " [" .. distance .. "m]"

        data.Label.TextColor3 = currentColor

    end

    if data.HealthBarBackground then data.HealthBarBackground.Visible = false end

    if data.HealthBarFill then data.HealthBarFill.Visible = false end

    hideLines(data.BoxLines)

    if Config.ESPBox or Config.ESPHealth then

        local size = data.CharacterSize or character:GetExtentsSize()
        data.CharacterSize = size

        local verticalOffset = size.Y / 2 + 0.5
        local topWorld = rootPart.Position + Vector3.new(0, verticalOffset, 0)

        local bottomWorld = rootPart.Position - Vector3.new(0, verticalOffset, 0)

        local topPosition, topVisible = camera:WorldToViewportPoint(topWorld)

        local bottomPosition, bottomVisible = camera:WorldToViewportPoint(bottomWorld)

        if topVisible or bottomVisible then

            local height = math.clamp(math.abs(topPosition.Y - bottomPosition.Y), 1, 250)

            local width = height / 2

            local boxX = topPosition.X - width / 2

            local boxY = topPosition.Y

            local lines = data.BoxLines

            if Config.ESPBox then

                lines[1].From = Vector2.new(boxX, boxY); lines[1].To = Vector2.new(boxX + width, boxY)

                lines[2].From = Vector2.new(boxX, boxY + height); lines[2].To = Vector2.new(boxX + width, boxY + height)

                lines[3].From = Vector2.new(boxX, boxY); lines[3].To = Vector2.new(boxX, boxY + height)

                lines[4].From = Vector2.new(boxX + width, boxY); lines[4].To = Vector2.new(boxX + width, boxY + height)

                for _, line in ipairs(lines) do

                    line.Color = currentColor

                    line.Visible = true

                end

            end

            if Config.ESPHealth and data.HealthBarBackground and data.HealthBarFill then

                local health = math.max(0, humanoid.Health)
                local maxHealth = math.max(1, humanoid.MaxHealth)
                local healthPercent = math.clamp(health / maxHealth, 0, 1)
                local barX = boxX - 6
                local barWidth = 3
                local barTop = boxY
                local barBottom = boxY + height
                local fillTop = barBottom - (height * healthPercent)

                data.HealthBarBackground.From = Vector2.new(barX, barTop)
                data.HealthBarBackground.To = Vector2.new(barX, barBottom)
                data.HealthBarBackground.Color = Color3.fromRGB(35, 35, 35)
                data.HealthBarBackground.Thickness = barWidth
                data.HealthBarBackground.Visible = true

                data.HealthBarFill.From = Vector2.new(barX, fillTop)
                data.HealthBarFill.To = Vector2.new(barX, barBottom)
                data.HealthBarFill.Color = Color3.fromRGB(
                    math.floor(255 * (1 - healthPercent)),
                    math.floor(220 * healthPercent),
                    60
                )
                data.HealthBarFill.Thickness = barWidth
                data.HealthBarFill.Visible = true

            end

        end

    end

    data.TracerLine.Visible = false

    if Config.ESPTracers then

        local screenPosition, onScreen = camera:WorldToViewportPoint(rootPart.Position)

        if onScreen then

            data.TracerLine.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)

            data.TracerLine.To = Vector2.new(screenPosition.X, screenPosition.Y)

            data.TracerLine.Color = currentColor

            data.TracerLine.Visible = true

        end

    end

    hideLines(data.SkeletonLines)

    if Config.ESPSkeleton then

        pcall(function()

            local head = character:FindFirstChild("Head")

            local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("LowerTorso")

            local leftArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm")

            local rightArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")

            local leftLeg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg")

            local rightLeg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg")

            connectSkeletonPart(camera, data, head, torso, 1, currentColor)

            connectSkeletonPart(camera, data, torso, leftArm, 2, currentColor)

            connectSkeletonPart(camera, data, torso, rightArm, 3, currentColor)

            connectSkeletonPart(camera, data, torso, leftLeg, 4, currentColor)

            connectSkeletonPart(camera, data, torso, rightLeg, 5, currentColor)

        end)

    end

    for _, slot in ipairs(data.HotbarSlots) do slot.Visible = false end

    local tools = data.HotbarTools or {}

    if Config.ESPHotbar and (data.HotbarDirty or now - (data.LastHotbarUpdate or 0) >= ESP_HOTBAR_UPDATE_INTERVAL) then
        data.LastHotbarUpdate = now
        data.HotbarDirty = false
        tools = {}

        local seenTools = {}
        local orderedTools = {}
        local sequence = 0

        local function addTools(container)

            if not container then return end

            for _, item in ipairs(container:GetChildren()) do

                if isHotbarWeapon(item) and not seenTools[item] then

                    seenTools[item] = true
                    sequence = sequence + 1
                    orderedTools[#orderedTools + 1] = {
                        Item = item,
                        Slot = getToolSlotIndex(item, sequence),
                        Sequence = sequence,
                    }

                end

            end

            for _, item in ipairs(container:GetDescendants()) do

                if isHotbarWeapon(item) and not seenTools[item] then

                    seenTools[item] = true
                    sequence = sequence + 1
                    orderedTools[#orderedTools + 1] = {
                        Item = item,
                        Slot = getToolSlotIndex(item, sequence),
                        Sequence = sequence,
                    }

                end

            end

        end

        addTools(character)
        addTools(player:FindFirstChildOfClass("Backpack"))

        table.sort(orderedTools, function(left, right)

            if left.Slot == right.Slot then

                return left.Sequence < right.Sequence

            end

            return left.Slot < right.Slot

        end)

        for _, entry in ipairs(orderedTools) do

            local info = getToolInfo(entry.Item)
            local displayName = info.Name

            if info.Rarity and info.Rarity ~= "" then

                displayName = displayName .. " [" .. info.Rarity .. "]"

            end

            tools[#tools + 1] = {
                Name = displayName,
                Rarity = info.Rarity,
                Index = entry.Slot,
            }

        end

        data.HotbarTools = tools
    end

    if Config.ESPHotbar then

        local size = data.CharacterSize or character:GetExtentsSize()
        data.CharacterSize = size

        local verticalOffset = size.Y / 2 + 0.5
        local topWorld = rootPart.Position + Vector3.new(0, verticalOffset, 0)

        local bottomWorld = rootPart.Position - Vector3.new(0, verticalOffset, 0)

        local topPosition, topVisible = camera:WorldToViewportPoint(topWorld)

        local bottomPosition, bottomVisible = camera:WorldToViewportPoint(bottomWorld)

        if topVisible or bottomVisible then

            local height = math.clamp(math.abs(topPosition.Y - bottomPosition.Y), 1, 250)

            local width = height / 2

            local startX = topPosition.X - width / 2

            local y = bottomPosition.Y + 5

            for index, toolInfo in ipairs(tools) do

                local slot = data.HotbarSlots[index]

                if not slot then break end

                slot.Text = "[" .. tostring(toolInfo.Index or index) .. "] " .. toolInfo.Name
                slot.Position = Vector2.new(startX + width / 2, y + (index - 1) * 15)
                slot.Color = getRarityColor(toolInfo.Rarity, currentColor)

                slot.Visible = true

            end

        end

    end

end

local function createESP(player)

    if player == LocalPlayer or ESPObjects[player] then return end

    local data = {

        Highlight = nil, Billboard = nil, Label = nil, FriendBillboard = nil, FriendLabel = nil,

        BoxLines = { createDrawingLine(), createDrawingLine(), createDrawingLine(), createDrawingLine() },

        TracerLine = createDrawingLine(),
        HealthBarBackground = createDrawingLine(),
        HealthBarFill = createDrawingLine(),

        SkeletonLines = { createDrawingLine(), createDrawingLine(), createDrawingLine(), createDrawingLine(), createDrawingLine() },

        HotbarSlots = { createDrawingText(), createDrawingText(), createDrawingText(), createDrawingText(), createDrawingText(), createDrawingText(), createDrawingText(), createDrawingText(), createDrawingText(), createDrawingText() },

        CharacterConnection = nil, LastUpdate = 0, LastVisibilityUpdate = 0,
        LastHotbarUpdate = 0, CharacterSize = nil, HotbarTools = {}, IsVisible = nil,
        HotbarConnections = {}, HotbarCharacter = nil, HotbarBackpack = nil, HotbarDirty = true,
        VisualSetupPending = false, Destroyed = false, Character = nil, Player = player,

    }

    ESPObjects[player] = data

    data.CharacterConnection = player.CharacterAdded:Connect(function(character)

        destroyCharacterVisuals(data)
        data.Character = character
        data.CharacterSize = nil
        data.HotbarTools = {}
        data.LastVisibilityUpdate = 0
        data.LastHotbarUpdate = 0
        data.IsVisible = nil

        if Config.ESP or Whitelist[player.UserId] then

            ensureCharacterVisuals(data, character)

        end

    end)

    if player.Character and (Config.ESP or Whitelist[player.UserId]) then

        data.Character = player.Character
        ensureCharacterVisuals(data, player.Character)

    end

end

local function destroyESP(player)

    local data = ESPObjects[player]

    TeamCache[player] = nil
    destroyFriendControl(player.UserId)
    Whitelist[player.UserId] = nil

    if not data then return end

    data.Destroyed = true
    data.Character = nil

    disconnectConnection(data.CharacterConnection)

    data.CharacterConnection = nil

    disconnectHotbarConnections(data)

    destroyCharacterVisuals(data)

    for _, line in ipairs(data.BoxLines) do removeDrawing(line) end

    removeDrawing(data.TracerLine)
    removeDrawing(data.HealthBarBackground)
    removeDrawing(data.HealthBarFill)

    for _, line in ipairs(data.SkeletonLines) do removeDrawing(line) end

    for _, slot in ipairs(data.HotbarSlots) do removeDrawing(slot) end

    ESPObjects[player] = nil

end

for _, player in ipairs(Players:GetPlayers()) do createESP(player) end

local PlayerAddedConnection = Players.PlayerAdded:Connect(createESP)

local PlayerRemovingConnection = Players.PlayerRemoving:Connect(destroyESP)

local ESPRenderConnection = RunService.RenderStepped:Connect(function()

    if not runtimeAlive then return end

    if not Config.ESP then

        hideAllESP()

        return

    end

    for player, data in pairs(ESPObjects) do

        updateESP(player, data)

    end

end)

-- Reconcile the registry as a fallback for late joins or missed PlayerAdded events.
local lastPlayerSync = 0
local PlayerSyncConnection = RunService.Heartbeat:Connect(function()

    local now = os.clock()

    if now - lastPlayerSync < 0.5 then return end

    lastPlayerSync = now

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer and not ESPObjects[player] then

            createESP(player)

        end

    end

end)

local regularAimTargetCache
local nextAimTargetAt = 0

local function updateAimTargetLoop(settings, keyValue, targetCache)
    local camera = Workspace.CurrentCamera
    if not camera then return end

    local targetSettings = {
        FOV = settings.FOV,
        AimbotMaxDistance = settings.AimbotMaxDistance,
        AimPart = settings.AimPart,
        ClosestPlusHeadChange = settings.ClosestPlusHeadChange,
        VisibilityCheck = settings.VisibilityCheck,
        Prediction = settings.Prediction,
    }

    local holdingItem = not settings.RequiresWeapon or isHoldingWeapon()
    local showFov = settings.ShowFOV and settings.Enabled and holdingItem

    FOVCircle.Visible = showFov
    FOVCircle.Radius = settings.FOV
    FOVCircle.Position = camera.ViewportSize / 2
    FOVCircle.Color = settings.FOVColor

    if settings.Enabled and holdingItem and isAimKeyDown(keyValue) then
        local now = os.clock()
        if now >= (nextAimTargetAt or 0) then
            targetCache = getTarget(targetSettings)
            nextAimTargetAt = now + 0.06
        end

        local target = targetCache
        if target then
            local targetPosition = target.Position
            local rootPart = getCharacterRootPart(target.Parent)
            if settings.Prediction and rootPart then
                targetPosition = targetPosition + (rootPart.AssemblyLinearVelocity * 0.08)
            end

            local screenPosition = camera:WorldToViewportPoint(targetPosition)
            local screenCenter = camera.ViewportSize / 2

            local moveX = (screenPosition.X - screenCenter.X) * settings.Smoothness
            local moveY = (screenPosition.Y - screenCenter.Y) * settings.Smoothness

            if not MoveMouse(moveX, moveY) then
                camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
            end
        else
            targetCache = nil
            nextAimTargetAt = 0
        end
    end

    return targetCache
end

local AimRenderConnection = RunService.RenderStepped:Connect(function()

    if not runtimeAlive then return end

    local camera = Workspace.CurrentCamera

    if not camera then

        FOVCircle.Visible = false

        return
    end

    if not OriginalCameraFOV then

        OriginalCameraFOV = camera.FieldOfView

    end

    camera.FieldOfView = math.clamp(tonumber(Config.CameraFOV) or 70, 40, 120)

    local regularSettings = {
        Enabled = Config.Aimbot,
        RequiresWeapon = Config.AimbotRequiresWeapon,
        FOV = Config.FOV,
        AimbotMaxDistance = Config.AimbotMaxDistance,
        AimPart = Config.AimPart,
        ClosestPlusHeadChange = Config.ClosestPlusHeadChange,
        VisibilityCheck = Config.VisibilityCheck,
        Prediction = Config.Prediction,
        Smoothness = Config.Smoothness,
        ShowFOV = Config.ShowFOV,
        FOVColor = Config.FOVColor,
    }

    regularAimTargetCache = updateAimTargetLoop(regularSettings, Config.AimKey, regularAimTargetCache)

end)

CameraChangedConnection = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()

    OriginalCameraFOV = nil

end)

local function unloadNOVA()

    if not runtimeAlive then return end

    -- Stop every callback before destroying any visual resource.

    runtimeAlive = false
    Environment.runtimeAlive = false

    Environment.NOVALoaded = false

    Config.Aimbot = false

    Config.ShowFOV = false

    Config.ESP = false

    Config.ESPHotbar = false

    local camera = Workspace.CurrentCamera

    if camera and OriginalCameraFOV then

        camera.FieldOfView = OriginalCameraFOV

    end

    disconnectConnection(AimRenderConnection)

    disconnectConnection(CameraChangedConnection)

    if SilentAim then pcall(function() SilentAim:Destroy() end) end
    disconnectConnection(Environment.SilentRenderConnection)
    SilentAim = nil
    Environment.SilentAim = nil
    Environment.SilentRenderConnection = nil

    disconnectConnection(PlayerAddedConnection)

    disconnectConnection(PlayerRemovingConnection)

    disconnectConnection(ESPRenderConnection)

    disconnectConnection(PlayerSyncConnection)

    disconnectConnection(FriendsPlayerAddedConnection)
    disconnectConnection(MinimizeInputConnection)

    AimRenderConnection = nil

    CameraChangedConnection = nil

    PlayerAddedConnection = nil

    PlayerRemovingConnection = nil

    ESPRenderConnection = nil

    PlayerSyncConnection = nil
    FriendsPlayerAddedConnection = nil
    MinimizeInputConnection = nil

    removeDrawing(FOVCircle)

    FOVCircle = nil

    -- Copy the keys first so removing entries cannot skip a player.

    local trackedPlayers = {}

    for player in pairs(ESPObjects) do

        trackedPlayers[#trackedPlayers + 1] = player

    end

    for _, player in ipairs(trackedPlayers) do

        destroyESP(player)

    end

    destroyAllFriendControls()

    for item in pairs(GunTemplateCache) do
        GunTemplateCache[item] = nil
    end

    for item in pairs(ItemInfoCache) do
        ItemInfoCache[item] = nil
    end

    -- Remove any orphaned instances left by a setup task that yielded.

    pcall(function()

        for _, object in ipairs(Workspace:GetDescendants()) do

            if object.Name == "NOVA_ESPHighlight" or object.Name == "NOVA_ESPName" or object.Name == "NOVA_FriendTag" then

                object:Destroy()

            end

        end

    end)

    -- FluentPro 1.5.5 exposes Destroy(), not Unload().

    pcall(function()

        if Fluent and type(Fluent.Destroy) == "function" then

            Fluent:Destroy()

        end

    end)

    -- Hard fallback for partial library cleanup and executor-specific GUI parents.

    if Fluent then

        destroyInstance(Fluent.PopupGUI)

        destroyInstance(Fluent.ScrollGUI)

        destroyInstance(Fluent.GUI)

    end

    if Window then

        destroyInstance(Window.Root)

    end

    destroyNOVAInterface()

    if Environment.NOVAConfig == Config then

        Environment.NOVAConfig = nil

    end

    if Environment.NOVACleanup == unloadNOVA then

        Environment.NOVACleanup = nil

    end

    Window = nil

    Fluent = nil

end

Environment.NOVACleanup = unloadNOVA

-- ============================================================

-- GUI INTERFACE (FluentPro)

-- ============================================================

Window = Fluent:CreateWindow({

    Title = "",

    SubTitle = "",

    Version = "",

    Tags = {},

    ScreenGuiName = "NOVAUI",

    TabWidth = isMobile and 130 or 165,

    Size = isMobile and UDim2.fromOffset(470, 540) or UDim2.fromOffset(700, 600),

    Acrylic = false,

    Theme = DEFAULT_THEME_NAME,

    Animated = false,

    Search = true,

    UserInfoTop = false,

})

pcall(function()

    local logo = Instance.new("ImageLabel")

    logo.Name = "TorpedoLogo"

    logo.BackgroundTransparency = 1

    logo.Image = "rbxassetid://125088661807855"

    logo.Size = UDim2.fromOffset(58, 58)

    logo.Position = UDim2.fromOffset(10, 6)

    logo.ScaleType = Enum.ScaleType.Fit

    logo.ZIndex = 20

    logo.Parent = Window.Root

end)

local AimbotTab = Window:AddTab({ Title = "Aimbot", Icon = "solar/target-bold" })

local SilentTab = Window:AddTab({ Title = "Silent", Icon = "solar/shield-check" })

local PlayersTab = Window:AddTab({ Title = "Players", Icon = "solar/eye-bold" })

local FriendsTab = Window:AddTab({ Title = "Friends", Icon = "solar/users-group-rounded-bold" })

local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "solar/settings-bold" })

task.defer(function()

    if not Window or not Window.Root then return end

    for _, object in ipairs(Window.Root:GetDescendants()) do

        if object:IsA("GuiObject") then

            local name = string.lower(object.Name)
            local isSearch = name:find("search", 1, true) ~= nil
            local isCategoryList = name == "tabs"
                or name == "tablist"
                or name:find("sidebar", 1, true) ~= nil

            if isSearch or isCategoryList then

                local position = object.Position
                object.Position = UDim2.new(
                    position.X.Scale,
                    position.X.Offset,
                    position.Y.Scale,
                    position.Y.Offset + 12
                )

            end

        end

    end

end)

local Controls = {}

local FriendsSection = FriendsTab:AddSection("Whitelist Players", "solar/users-group-rounded-bold")

local function addFriendControl(player)

    if player == LocalPlayer or FriendControls[player.UserId] then return end

    local title = player.DisplayName

    if player.DisplayName ~= player.Name then

        title = title .. " (" .. player.Name .. ")"

    end

    FriendControls[player.UserId] = FriendsSection:AddToggle("NovaFriend_" .. tostring(player.UserId), {

        Title = title,

        Description = "Shows the Friend tag.",

        Default = false,

        Callback = function(value)

            Whitelist[player.UserId] = value == true

            local data = ESPObjects[player]

            if data then updateFriendTag(player, data) end

        end,

    })

end

for _, player in ipairs(Players:GetPlayers()) do addFriendControl(player) end

FriendsPlayerAddedConnection = Players.PlayerAdded:Connect(addFriendControl)

local AimMainSection = AimbotTab:AddSection("General", "solar/target-bold")

Controls.Aimbot = AimMainSection:AddToggle("NovaAimbot", { Title = "Aimbot", Default = Config.Aimbot, Callback = function(v) Config.Aimbot = v end })

Controls.AimbotRequiresWeapon = AimMainSection:AddToggle("NovaAimbotRequiresWeapon", {

    Title = "Require Held Item",

    Description = "Aimbot works only while holding an item or weapon.",

    Default = Config.AimbotRequiresWeapon,

    Callback = function(v) Config.AimbotRequiresWeapon = v end,

})

Controls.VisibilityCheck = AimMainSection:AddToggle("NovaVisibilityCheck", { Title = "Visibility Check", Description = "Targets only players in line of sight.", Default = Config.VisibilityCheck, Callback = function(v) Config.VisibilityCheck = v end })

Controls.AimKey = AimMainSection:AddKeybind("NovaAimKey", { Title = "Aim Key", Default = Config.AimKey })

Controls.AimKey:OnChanged(function()
    Config.AimKey = getKeyName(Controls.AimKey.Value)
end)

local AimConfigSection = AimbotTab:AddSection("Config", "solar/tuning-square-2-bold")

Controls.AimPart = AimConfigSection:AddDropdown("NovaAimPart", { Title = "Aim Part", Values = { "Closest Bone", "Closest+", "Head", "UpperTorso", "HumanoidRootPart" }, Default = Config.AimPart, Multi = false, Callback = function(v) Config.AimPart = v end })

makeDropdownClosable(Controls.AimPart)

Controls.ClosestPlusHeadChange = AimConfigSection:AddSlider("NovaClosestPlusHeadChange", { Title = "Closest+ Head Change", Description = "Adjusts head priority in Closest+ mode.", Min = 0, Max = 100, Default = Config.ClosestPlusHeadChange, Rounding = 0, Callback = function(v) Config.ClosestPlusHeadChange = v end })

Controls.FOV = AimConfigSection:AddSlider("NovaFOV", { Title = "FOV", Min = 10, Max = 500, Default = Config.FOV, Rounding = 0, Callback = function(v) Config.FOV = v end })

Controls.AimbotMaxDistance = AimConfigSection:AddSlider("NovaAimbotMaxDistance", { Title = "Aimbot Distance", Description = "Limits the aimbot target range.", Min = 50, Max = 5000, Default = Config.AimbotMaxDistance, Rounding = 0, Callback = function(v) Config.AimbotMaxDistance = v end })

Controls.Smoothness = AimConfigSection:AddSlider("NovaSmoothness", { Title = "Aim Speed", Min = 1, Max = 15, Default = math.floor(Config.Smoothness * 10), Rounding = 0, Callback = function(v) Config.Smoothness = v / 10 end })

Controls.ShowFOV = AimConfigSection:AddToggle("NovaShowFOV", { Title = "Show FOV Circle", Default = Config.ShowFOV, Callback = function(v) Config.ShowFOV = v end })

Controls.FOVColor = AimConfigSection:AddColorpicker("NovaFOVColor", { Title = "FOV Circle Color", Default = Config.FOVColor, Callback = function(c) Config.FOVColor = c; FOVCircle.Color = c end })

local AimTargetingSection = AimbotTab:AddSection("Targeting", "solar/crosshair-bold")

Controls.Prediction = AimTargetingSection:AddToggle("NovaPrediction", { Title = "Movement Prediction", Default = Config.Prediction, Callback = function(v) Config.Prediction = v end })

local SilentSection = SilentTab:AddSection("Silent", "solar/target-bold")

Controls.SilentEnabled = SilentSection:AddToggle("NovaSilentEnabled", { Title = "Enabled", Default = Config.Silent.Enabled, Callback = function(v) Config.Silent.Enabled = v end })

Controls.SilentMode = SilentSection:AddDropdown("NovaSilentMode", { Title = "Mode", Values = { "Universal", "Rivals", "BloxStrike" }, Default = Config.Silent.Mode, Multi = false, Callback = function(v) Config.Silent.Mode = v end })

Controls.SilentActiveMode = SilentSection:AddDropdown("NovaSilentActiveMode", { Title = "Active Mode", Values = { "Hold", "Toggle", "Always" }, Default = Config.Silent.ActiveMode, Multi = false, Callback = function(v) Config.Silent.ActiveMode = v end })

Controls.SilentKey = SilentSection:AddKeybind("NovaSilentKey", { Title = "Key", Default = Config.Silent.Key })

Controls.SilentKey:OnChanged(function()
    Config.Silent.Key = getKeyName(Controls.SilentKey.Value)
end)

Controls.SilentAimPart = SilentSection:AddDropdown("NovaSilentAimPart", { Title = "Aim Part", Values = { "Closest Bone", "Closest+", "Head", "UpperTorso", "HumanoidRootPart" }, Default = Config.Silent.AimPart, Multi = false, Callback = function(v) Config.Silent.AimPart = v end })

Controls.SilentTeamCheck = SilentSection:AddToggle("NovaSilentTeamCheck", { Title = "Team Check", Default = Config.Silent.TeamCheck, Callback = function(v) Config.Silent.TeamCheck = v end })

Controls.SilentWallCheck = SilentSection:AddToggle("NovaSilentWallCheck", { Title = "Wall Check", Default = Config.Silent.WallCheck, Callback = function(v) Config.Silent.WallCheck = v end })

Controls.SilentMaxDistance = SilentSection:AddSlider("NovaSilentMaxDistance", { Title = "Max Distance", Min = 50, Max = 5000, Default = Config.Silent.MaxDistance, Rounding = 0, Callback = function(v) Config.Silent.MaxDistance = v end })

Controls.SilentFov = SilentSection:AddSlider("NovaSilentFov", { Title = "FOV", Min = 0, Max = 500, Default = Config.Silent.Fov, Rounding = 0, Callback = function(v) Config.Silent.Fov = v end })

Controls.SilentHitChance = SilentSection:AddSlider("NovaSilentHitChance", { Title = "Hit Chance", Min = 0, Max = 100, Default = Config.Silent.HitChance, Rounding = 0, Callback = function(v) Config.Silent.HitChance = v end })

Controls.SilentPrediction = SilentSection:AddToggle("NovaSilentPrediction", { Title = "Prediction", Default = Config.Silent.Prediction, Callback = function(v) Config.Silent.Prediction = v end })

Controls.SilentPredictionTime = SilentSection:AddSlider("NovaSilentPredictionTime", { Title = "Prediction Time", Min = 0, Max = 1, Default = Config.Silent.PredictionTime, Rounding = 3, Callback = function(v) Config.Silent.PredictionTime = v end })

Controls.SilentRemoteHook = SilentSection:AddToggle("NovaSilentRemoteHook", { Title = "Use Remote Hook", Default = Config.Silent.UseRemoteHook, Callback = function(v) Config.Silent.UseRemoteHook = v end })

Controls.SilentRemoteHook:OnChanged(function()
    Config.Silent.UseRemoteHook = Controls.SilentRemoteHook.Value
    if Config.Silent.UseRemoteHook and SilentAim then
        pcall(function() SilentAim:_hook() end)
    end
end)

Controls.SilentRaycastHook = SilentSection:AddToggle("NovaSilentRaycastHook", { Title = "Use Raycast Hook", Default = Config.Silent.UseRaycastHook, Callback = function(v) Config.Silent.UseRaycastHook = v end })

Controls.SilentRaycastHook:OnChanged(function()
    Config.Silent.UseRaycastHook = Controls.SilentRaycastHook.Value
    if Config.Silent.UseRaycastHook and SilentAim then
        pcall(function() SilentAim:_hookRaycast() end)
    end
end)

Controls.SilentEnabled:OnChanged(function()
    Config.Silent.Enabled = Controls.SilentEnabled.Value
    if Config.Silent.Enabled and SilentAim then
        pcall(function() SilentAim:_hookRaycast() end)
        pcall(function() SilentAim:_hook() end)
    end
end)

-- Visuals: Players

local ESPMainSection = PlayersTab:AddSection("ESP Elements", "solar/eye-bold")

Controls.ESP = ESPMainSection:AddToggle("NovaESP", { Title = "ESP Enabled", Default = Config.ESP, Callback = function(v)

    Config.ESP = v

    if not v then

        hideAllESP()

    end

end })

Controls.ESPTeamHide = ESPMainSection:AddToggle("NovaESPTeamHide", { Title = "Hide Team ESP", Default = Config.ESPTeamHide, Callback = function(v) Config.ESPTeamHide = v end })

Controls.ESPHighlight = ESPMainSection:AddToggle("NovaESPHighlight", { Title = "Character Highlight", Default = Config.ESPHighlight, Callback = function(v) Config.ESPHighlight = v end })

Controls.ESPBox = ESPMainSection:AddToggle("NovaESPBox", { Title = "Box ESP", Default = Config.ESPBox, Callback = function(v) Config.ESPBox = v end })

Controls.ESPTracers = ESPMainSection:AddToggle("NovaESPTracers", { Title = "Tracers", Default = Config.ESPTracers, Callback = function(v) Config.ESPTracers = v end })

Controls.ESPSkeleton = ESPMainSection:AddToggle("NovaESPSkeleton", { Title = "Skeleton", Default = Config.ESPSkeleton, Callback = function(v) Config.ESPSkeleton = v end })

Controls.ESPNames = ESPMainSection:AddToggle("NovaESPNames", { Title = "Names & Distance", Default = Config.ESPNames, Callback = function(v) Config.ESPNames = v end })

Controls.ESPHealth = ESPMainSection:AddToggle("NovaESPHealth", { Title = "Health", Default = Config.ESPHealth, Callback = function(v) Config.ESPHealth = v end })

Controls.ESPHotbar = ESPMainSection:AddToggle("NovaESPHotbar", { Title = "Hotbar", Default = Config.ESPHotbar, Callback = function(v) Config.ESPHotbar = v end })

Controls.ESPMaxDistance = ESPMainSection:AddSlider("NovaESPMaxDistance", { Title = "ESP Distance", Description = "Limits the ESP display range.", Min = 50, Max = 5000, Default = Config.ESPMaxDistance, Rounding = 0, Callback = function(v) Config.ESPMaxDistance = v end })

local ESPColorSection = PlayersTab:AddSection("ESP Colors", "solar/palette-bold")

Controls.EnemyColor = ESPColorSection:AddColorpicker("NovaEnemyColor", { Title = "Enemy Color", Default = Config.EnemyColor, Callback = function(c) Config.EnemyColor = c end })

Controls.TeamColor = ESPColorSection:AddColorpicker("NovaTeamColor", { Title = "Team Color", Default = Config.TeamColor, Callback = function(c) Config.TeamColor = c end })

local ConfigSection = SettingsTab:AddSection("Config", "solar/diskette-bold")

local CameraSection = SettingsTab:AddSection("Camera", "solar/camera-bold")

Controls.CameraFOV = CameraSection:AddSlider("NovaCameraFOV", {

    Title = "Camera FOV",

    Description = "Changes the camera field of view. 70 is the default.",

    Min = 40,

    Max = 120,

    Default = Config.CameraFOV,

    Rounding = 0,

    Callback = function(value)

        Config.CameraFOV = value

    end,

})

local function applyConfigToControls()

    local values = {
        { Controls.CameraFOV, Config.CameraFOV },
        { Controls.Aimbot, Config.Aimbot },
        { Controls.AimbotRequiresWeapon, Config.AimbotRequiresWeapon },
        { Controls.VisibilityCheck, Config.VisibilityCheck },
        { Controls.AimKey, Config.AimKey },
        { Controls.AimPart, Config.AimPart },
        { Controls.ClosestPlusHeadChange, Config.ClosestPlusHeadChange },
        { Controls.FOV, Config.FOV },
        { Controls.AimbotMaxDistance, Config.AimbotMaxDistance },
        { Controls.Smoothness, math.floor(Config.Smoothness * 10) },
        { Controls.ShowFOV, Config.ShowFOV },
        { Controls.Prediction, Config.Prediction },
        { Controls.SilentEnabled, Config.Silent.Enabled },
        { Controls.SilentMode, Config.Silent.Mode },
        { Controls.SilentActiveMode, Config.Silent.ActiveMode },
        { Controls.SilentKey, Config.Silent.Key },
        { Controls.SilentAimPart, Config.Silent.AimPart },
        { Controls.SilentTeamCheck, Config.Silent.TeamCheck },
        { Controls.SilentWallCheck, Config.Silent.WallCheck },
        { Controls.SilentMaxDistance, Config.Silent.MaxDistance },
        { Controls.SilentFov, Config.Silent.Fov },
        { Controls.SilentHitChance, Config.Silent.HitChance },
        { Controls.SilentPrediction, Config.Silent.Prediction },
        { Controls.SilentPredictionTime, Config.Silent.PredictionTime },
        { Controls.SilentRemoteHook, Config.Silent.UseRemoteHook },
        { Controls.SilentRaycastHook, Config.Silent.UseRaycastHook },
        { Controls.ESP, Config.ESP },
        { Controls.ESPTeamHide, Config.ESPTeamHide },
        { Controls.ESPHighlight, Config.ESPHighlight },
        { Controls.ESPBox, Config.ESPBox },
        { Controls.ESPTracers, Config.ESPTracers },
        { Controls.ESPSkeleton, Config.ESPSkeleton },
        { Controls.ESPNames, Config.ESPNames },
        { Controls.ESPHealth, Config.ESPHealth },
        { Controls.ESPHotbar, Config.ESPHotbar },
        { Controls.ESPMaxDistance, Config.ESPMaxDistance },
    }

    for _, entry in ipairs(values) do
        pcall(function() entry[1]:SetValue(entry[2]) end)
    end

    pcall(function() Controls.FOVColor:SetValueRGB(Config.FOVColor, 0) end)
    pcall(function() Controls.EnemyColor:SetValueRGB(Config.EnemyColor, 0) end)
    pcall(function() Controls.TeamColor:SetValueRGB(Config.TeamColor, 0) end)

end

ConfigSection:AddButton({

    Title = "Save Config",

    Description = "Saves the active settings to torpedo_config.json.",

    Icon = "solar/diskette-bold",

    Callback = function()

        local success, message = saveConfig()

        Fluent:Notify({ Title = "Torpedo", Content = message, Type = success and "Success" or "Error", Duration = 4 })

    end,

})

ConfigSection:AddButton({

    Title = "Load Config",

    Description = "Loads settings from torpedo_config.json.",

    Icon = "solar/upload-bold",

    Callback = function()

        local success, message = loadConfig()

        if success then

            task.defer(function()

                if runtimeAlive then
                    applyConfigToControls()
                end

            end)

        end

        Fluent:Notify({ Title = "Torpedo", Content = message, Type = success and "Success" or "Error", Duration = 4 })

    end,

})

ConfigSection:AddButton({

    Title = "Reset Config",

    Description = "Restores all settings to their defaults.",

    Icon = "solar/refresh-bold",

    Callback = function()

        local success, message = resetConfig()

        if success then

            task.defer(function()

                if runtimeAlive then
                    applyConfigToControls()
                end

            end)

        end

        Fluent:Notify({ Title = "Torpedo", Content = message, Type = success and "Success" or "Error", Duration = 4 })

    end,

})

local UnloadSection = SettingsTab:AddSection("Unload", "solar/power-bold")

local MenuSection = SettingsTab:AddSection("Menu Controls", "solar/keyboard-bold")

Controls.MinimizeKeybind = MenuSection:AddKeybind("NovaMinimizeKey", {

    Title = "Minimize Key",

    Description = "Press a key to hide or show the menu.",

    Icon = "solar/keyboard-bold",

    Default = "End",

})

UnloadSection:AddButton({ Title = "Unload Torpedo", Description = "Stops the script and removes the interface.", Callback = function() unloadNOVA() end })

pcall(function() Window:SelectTab(1) end)

local windowMinimized = false
local windowAnimating = false
local windowRoot = Window and Window.Root
local windowScale = windowRoot and windowRoot:FindFirstChild("TorpedoOpenScale")
local windowTransparencyTargets = {}

local function collectWindowTransparency(object)

    if object:IsA("GuiObject") then

        local target = { Object = object }

        if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
            target.TextTransparency = object.TextTransparency
        end

        if object:IsA("ImageLabel") or object:IsA("ImageButton") then
            target.ImageTransparency = object.ImageTransparency
        end

        target.BackgroundTransparency = object.BackgroundTransparency
        windowTransparencyTargets[#windowTransparencyTargets + 1] = target

    elseif object:IsA("UIStroke") then

        windowTransparencyTargets[#windowTransparencyTargets + 1] = {
            Object = object,
            Transparency = object.Transparency,
        }

    end

    for _, child in ipairs(object:GetChildren()) do
        collectWindowTransparency(child)
    end

end

local function tweenWindowTransparency(transparency, duration)

    for _, target in ipairs(windowTransparencyTargets) do

        local object = target.Object

        if object and object.Parent then

            local properties = {}

            if target.TextTransparency ~= nil then
                properties.TextTransparency = transparency == 1 and 1 or target.TextTransparency
            end

            if target.ImageTransparency ~= nil then
                properties.ImageTransparency = transparency == 1 and 1 or target.ImageTransparency
            end

            if target.BackgroundTransparency ~= nil then
                properties.BackgroundTransparency = transparency == 1 and 1 or target.BackgroundTransparency
            end

            if target.Transparency ~= nil then
                properties.Transparency = transparency == 1 and 1 or target.Transparency
            end

            if next(properties) then
                TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), properties):Play()
            end

        end

    end

end

if windowRoot and windowRoot:IsA("GuiObject") then

    collectWindowTransparency(windowRoot)

    if not windowScale then
        windowScale = Instance.new("UIScale")
        windowScale.Name = "TorpedoOpenScale"
        windowScale.Parent = windowRoot
    end

    local function toggleWindowAnimated()

        if windowAnimating or not runtimeAlive then return end

        windowAnimating = true

        if windowMinimized then
            windowRoot.Visible = true
            windowScale.Scale = 0.72
            tweenWindowTransparency(0, 0.45)

            local tween = TweenService:Create(windowScale, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Scale = 1,
            })

            tween:Play()
            tween.Completed:Wait()
            windowMinimized = false
        else
            tweenWindowTransparency(1, 0.35)

            local tween = TweenService:Create(windowScale, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Scale = 0.72,
            })

            tween:Play()
            tween.Completed:Wait()
            windowRoot.Visible = false
            windowMinimized = true
        end

        windowAnimating = false

    end

    MinimizeInputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)

        if input.KeyCode ~= Enum.KeyCode.End then return end
        task.spawn(toggleWindowAnimated)

    end)

end

-- The main window is fully built before the splash starts, so its fade-out
-- reveals the actual interface instead of showing an empty loading screen.
local mainGui = PlayerGui:FindFirstChild("NOVAUI", true)

if not mainGui then
    pcall(function()
        if type(gethui) == "function" then
            mainGui = gethui():FindFirstChild("NOVAUI", true)
        end
    end)
end

if mainGui and not mainGui:IsA("ScreenGui") then
    mainGui = mainGui:FindFirstAncestorOfClass("ScreenGui")
end

showTorpedoLoadingScreen(mainGui, Window and Window.Root)
