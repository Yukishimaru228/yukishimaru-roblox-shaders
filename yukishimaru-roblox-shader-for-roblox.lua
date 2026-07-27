--// Services
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

--// Library (Late's Library)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/lates-lib/main/Main.lua"))()
local Window = Library:CreateWindow({
    Title = "GrayStar Engine | Yukishimaru",
    Theme = "Dark",
    Size = UDim2.fromOffset(720, 560),
    Transparency = 0.12,
    Blurring = true,
    MinimizeKeybind = Enum.KeyCode.LeftAlt,
})

--// Themes
local Themes = {
    Light = {
        Primary = Color3.fromRGB(232, 232, 232),
        Secondary = Color3.fromRGB(255, 255, 255),
        Component = Color3.fromRGB(245, 245, 245),
        Interactables = Color3.fromRGB(235, 235, 235),
        Tab = Color3.fromRGB(50, 50, 50),
        Title = Color3.fromRGB(0, 0, 0),
        Description = Color3.fromRGB(100, 100, 100),
        Shadow = Color3.fromRGB(255, 255, 255),
        Outline = Color3.fromRGB(210, 210, 210),
        Icon = Color3.fromRGB(100, 100, 100),
    },
    Dark = {
        Primary = Color3.fromRGB(30, 30, 30),
        Secondary = Color3.fromRGB(35, 35, 35),
        Component = Color3.fromRGB(40, 40, 40),
        Interactables = Color3.fromRGB(45, 45, 45),
        Tab = Color3.fromRGB(200, 200, 200),
        Title = Color3.fromRGB(240,240,240),
        Description = Color3.fromRGB(200,200,200),
        Shadow = Color3.fromRGB(0, 0, 0),
        Outline = Color3.fromRGB(40, 40, 40),
        Icon = Color3.fromRGB(220, 220, 220),
    },
    Void = {
        Primary = Color3.fromRGB(15, 15, 15),
        Secondary = Color3.fromRGB(20, 20, 20),
        Component = Color3.fromRGB(25, 25, 25),
        Interactables = Color3.fromRGB(30, 30, 30),
        Tab = Color3.fromRGB(200, 200, 200),
        Title = Color3.fromRGB(240,240,240),
        Description = Color3.fromRGB(200,200,200),
        Shadow = Color3.fromRGB(0, 0, 0),
        Outline = Color3.fromRGB(40, 40, 40),
        Icon = Color3.fromRGB(220, 220, 220),
    },
}

Window:SetTheme(Themes.Dark)

--// Sections (категории вкладок)
Window:AddTabSection({ Name = "Main", Order = 1 })
Window:AddTabSection({ Name = "Presets", Order = 2 })
Window:AddTabSection({ Name = "Color Correction", Order = 3 })
Window:AddTabSection({ Name = "Bloom", Order = 4 })
Window:AddTabSection({ Name = "Sun Rays", Order = 5 })
Window:AddTabSection({ Name = "Profiles", Order = 6 })
Window:AddTabSection({ Name = "Settings", Order = 7 })

--// ====================== ХРАНИЛИЩЕ ЭФФЕКТОВ ======================
local Shaders = {
    Bloom = nil,
    Blur = nil,
    ColorCorrection = nil,
    DepthOfField = nil,
    SunRays = nil,
    Atmosphere = nil,
    -- кастомные (заглушки)
    Vignette = nil,
    Chromatic = nil,
    Grain = nil,
    Sharpen = nil,
    EdgeDetect = nil,
    Posterize = nil,
}

local function CreateEffect(name, params)
    if Shaders[name] then
        Shaders[name]:Destroy()
        Shaders[name] = nil
    end
    local effect
    if name == "Bloom" then
        effect = Instance.new("BloomEffect")
        effect.Intensity = params and params.Intensity or 0.3
        effect.Size = params and params.Size or 24
        effect.Threshold = params and params.Threshold or 0.8
    elseif name == "Blur" then
        effect = Instance.new("BlurEffect")
        effect.Size = params and params.Size or 6
    elseif name == "ColorCorrection" then
        effect = Instance.new("ColorCorrectionEffect")
        effect.Brightness = params and params.Brightness or 0
        effect.Contrast = params and params.Contrast or 0
        effect.Saturation = params and params.Saturation or 0
        effect.TintColor = params and params.TintColor or Color3.new(1,1,1)
    elseif name == "DepthOfField" then
        effect = Instance.new("DepthOfFieldEffect")
        effect.FarIntensity = params and params.FarIntensity or 0
        effect.NearIntensity = params and params.NearIntensity or 0
        effect.FocusDistance = params and params.FocusDistance or 10
    elseif name == "SunRays" then
        effect = Instance.new("SunRaysEffect")
        effect.Intensity = params and params.Intensity or 0.2
        effect.Spread = params and params.Spread or 0.8
    elseif name == "Atmosphere" then
        effect = Instance.new("Atmosphere")
        effect.Density = params and params.Density or 0.2
        effect.Offset = params and params.Offset or 0.1
        effect.Color = params and params.Color or Color3.fromRGB(135, 206, 235)
        effect.Decay = Color3.new(1,1,1)
    elseif name == "Vignette" then
        effect = Instance.new("BloomEffect")
        effect.Intensity = params and params.Intensity or 0.5
        effect.Size = 1
        effect.Threshold = 0.9
    elseif name == "Chromatic" then
        effect = Instance.new("ColorCorrectionEffect")
        effect.TintColor = params and params.TintColor or Color3.fromRGB(255, 100, 100)
        effect.Saturation = 0.5
    elseif name == "Grain" then
        effect = Instance.new("BlurEffect")
        effect.Size = 0.5
    elseif name == "Sharpen" then
        effect = Instance.new("ColorCorrectionEffect")
        effect.Contrast = params and params.Contrast or 0.5
    elseif name == "EdgeDetect" then
        effect = Instance.new("ColorCorrectionEffect")
        effect.Saturation = 0
        effect.Contrast = 1
    elseif name == "Posterize" then
        effect = Instance.new("ColorCorrectionEffect")
        effect.Saturation = 0
        effect.Brightness = 0.3
    end
    if effect then
        effect.Parent = Lighting
        Shaders[name] = effect
    end
    return effect
end

local function RemoveEffect(name)
    if Shaders[name] then
        Shaders[name]:Destroy()
        Shaders[name] = nil
    end
end

local function ResetAllShaders()
    for name, _ in pairs(Shaders) do
        RemoveEffect(name)
    end
    Window:Notify({ Title = "Yukishimaru", Description = "Все шейдеры сброшены", Duration = 2 })
end

--// ====================== ПРЕСЕТЫ ======================
local Presets = {
    ["Default"] = function()
        ResetAllShaders()
    end,
    ["Cinematic"] = function()
        ResetAllShaders()
        CreateEffect("Bloom", {Intensity = 0.5, Size = 20, Threshold = 0.6})
        CreateEffect("DepthOfField", {FarIntensity = 0.6, NearIntensity = 0.2, FocusDistance = 15})
        CreateEffect("ColorCorrection", {Saturation = 0.2, Contrast = 0.1, Brightness = -0.05})
        CreateEffect("SunRays", {Intensity = 0.4})
        CreateEffect("Atmosphere", {Density = 0.3, Color = Color3.fromRGB(200, 180, 255)})
    end,
    ["Neon"] = function()
        ResetAllShaders()
        CreateEffect("Bloom", {Intensity = 1.2, Size = 40, Threshold = 0.3})
        CreateEffect("ColorCorrection", {Saturation = 0.8, Contrast = 0.3, Brightness = 0.1})
        CreateEffect("Blur", {Size = 3})
    end,
    ["Vintage"] = function()
        ResetAllShaders()
        CreateEffect("ColorCorrection", {Saturation = -0.3, Contrast = -0.1, Brightness = 0.05, TintColor = Color3.fromRGB(255, 200, 150)})
        CreateEffect("Bloom", {Intensity = 0.2, Size = 15, Threshold = 0.9})
        CreateEffect("Blur", {Size = 2})
    end,
    ["Cold"] = function()
        ResetAllShaders()
        CreateEffect("ColorCorrection", {TintColor = Color3.fromRGB(150, 200, 255), Brightness = -0.05, Saturation = -0.1})
        CreateEffect("Atmosphere", {Color = Color3.fromRGB(100, 150, 255), Density = 0.4})
    end,
    ["Warm"] = function()
        ResetAllShaders()
        CreateEffect("ColorCorrection", {TintColor = Color3.fromRGB(255, 200, 100), Brightness = 0.05, Saturation = 0.1})
        CreateEffect("Bloom", {Intensity = 0.4, Size = 25, Threshold = 0.7})
    end,
    ["Noir"] = function()
        ResetAllShaders()
        CreateEffect("ColorCorrection", {Saturation = -1, Contrast = 0.5, Brightness = -0.1})
        CreateEffect("Bloom", {Intensity = 0.1, Size = 5, Threshold = 0.5})
    end,
    ["Dreamy"] = function()
        ResetAllShaders()
        CreateEffect("Bloom", {Intensity = 0.8, Size = 35, Threshold = 0.4})
        CreateEffect("Blur", {Size = 6})
        CreateEffect("ColorCorrection", {Brightness = 0.1, Saturation = 0.3})
    end,

    -- ========== НОВЫЕ 10 ПРЕСЕТОВ ==========

    ["Pastel"] = function()
        ResetAllShaders()
        CreateEffect("ColorCorrection", {Brightness = 0.15, Contrast = -0.1, Saturation = 0.1, TintColor = Color3.fromRGB(255, 200, 200)})
        CreateEffect("Bloom", {Intensity = 0.6, Size = 30, Threshold = 0.5})
        CreateEffect("Blur", {Size = 2})
    end,
    ["Cyberpunk"] = function()
        ResetAllShaders()
        CreateEffect("ColorCorrection", {Brightness = -0.1, Contrast = 0.4, Saturation = 0.6, TintColor = Color3.fromRGB(255, 50, 200)})
        CreateEffect("Bloom", {Intensity = 1.0, Size = 45, Threshold = 0.2})
        CreateEffect("SunRays", {Intensity = 0.6, Spread = 0.9})
    end,
    ["Horror"] = function()
        ResetAllShaders()
        CreateEffect("ColorCorrection", {Brightness = -0.3, Contrast = 0.5, Saturation = -0.5, TintColor = Color3.fromRGB(50, 200, 50)})
        CreateEffect("DepthOfField", {FarIntensity = 0.8, NearIntensity = 0.1, FocusDistance = 5})
        CreateEffect("Blur", {Size = 4})
    end,
    ["Sunset"] = function()
        ResetAllShaders()
        CreateEffect("ColorCorrection", {Brightness = 0.1, Contrast = 0.1, Saturation = 0.3, TintColor = Color3.fromRGB(255, 150, 50)})
        CreateEffect("Bloom", {Intensity = 0.7, Size = 25, Threshold = 0.5})
        CreateEffect("Atmosphere", {Color = Color3.fromRGB(255, 100, 50), Density = 0.3})
        CreateEffect("SunRays", {Intensity = 0.5, Spread = 0.7})
    end,
    ["Aqua"] = function()
        ResetAllShaders()
        CreateEffect("ColorCorrection", {Brightness = -0.05, Contrast = 0.1, Saturation = 0.2, TintColor = Color3.fromRGB(50, 200, 255)})
        CreateEffect("Bloom", {Intensity = 0.4, Size = 20, Threshold = 0.6})
        CreateEffect("Atmosphere", {Color = Color3.fromRGB(50, 150, 255), Density = 0.2})
        CreateEffect("Blur", {Size = 1})
    end,
    ["Sepia"] = function()
        ResetAllShaders()
        CreateEffect("ColorCorrection", {Brightness = 0.05, Contrast = 0.1, Saturation = -0.5, TintColor = Color3.fromRGB(200, 150, 100)})
        CreateEffect("Bloom", {Intensity = 0.2, Size = 15, Threshold = 0.8})
        CreateEffect("Blur", {Size = 1})
    end,
    ["Matrix"] = function()
        ResetAllShaders()
        CreateEffect("ColorCorrection", {Brightness = -0.1, Contrast = 0.3, Saturation = 0.2, TintColor = Color3.fromRGB(50, 255, 50)})
        CreateEffect("Bloom", {Intensity = 0.3, Size = 10, Threshold = 0.7})
        CreateEffect("Blur", {Size = 1})
    end,
    ["Mystic"] = function()
        ResetAllShaders()
        CreateEffect("ColorCorrection", {Brightness = 0.05, Contrast = 0.1, Saturation = 0.4, TintColor = Color3.fromRGB(150, 100, 255)})
        CreateEffect("Bloom", {Intensity = 0.9, Size = 40, Threshold = 0.3})
        CreateEffect("Atmosphere", {Color = Color3.fromRGB(100, 50, 200), Density = 0.2})
        CreateEffect("DepthOfField", {FarIntensity = 0.3, NearIntensity = 0.1, FocusDistance = 20})
    end,
    ["Retro"] = function()
        ResetAllShaders()
        CreateEffect("ColorCorrection", {Brightness = 0.1, Contrast = 0.2, Saturation = 0.1, TintColor = Color3.fromRGB(255, 200, 100)})
        CreateEffect("Bloom", {Intensity = 0.5, Size = 18, Threshold = 0.7})
        CreateEffect("Blur", {Size = 3})
        CreateEffect("Vignette", {Intensity = 0.3})
    end,
    ["Aurora"] = function()
        ResetAllShaders()
        CreateEffect("ColorCorrection", {Brightness = 0.05, Contrast = 0.1, Saturation = 0.3, TintColor = Color3.fromRGB(100, 255, 200)})
        CreateEffect("Bloom", {Intensity = 0.6, Size = 30, Threshold = 0.4})
        CreateEffect("Atmosphere", {Color = Color3.fromRGB(50, 255, 150), Density = 0.15})
        CreateEffect("SunRays", {Intensity = 0.3, Spread = 0.6})
    end,
}

--// ====================== ВКЛАДКА MAIN ======================
local MainTab = Window:AddTab({
    Title = "Main",
    Section = "Main",
    Icon = "rbxassetid://11963373994"
})

Window:AddSection({ Name = "General", Tab = MainTab })
Window:AddButton({
    Title = "Notification Test",
    Description = "Показать уведомление",
    Tab = MainTab,
    Callback = function()
        Window:Notify({ Title = "Yukishimaru", Description = "Привет! Это GrayStar Engine.", Duration = 3 })
    end,
})

--// ====================== ВКЛАДКА PRESETS ======================
local PresetsTab = Window:AddTab({
    Title = "Presets",
    Section = "Presets",
    Icon = "rbxassetid://11963373994"
})

Window:AddSection({ Name = "Apply Preset", Tab = PresetsTab })
for presetName, presetFunc in pairs(Presets) do
    Window:AddButton({
        Title = presetName,
        Tab = PresetsTab,
        Callback = presetFunc,
    })
end
Window:AddButton({
    Title = "Reset All",
    Tab = PresetsTab,
    Callback = ResetAllShaders,
})

--// ====================== ВКЛАДКА COLOR CORRECTION ======================
local ColorCorrectionTab = Window:AddTab({
    Title = "Color Correction",
    Section = "Color Correction",
    Icon = "rbxassetid://11293977610"
})

Window:AddSection({ Name = "Color Correction Settings", Tab = ColorCorrectionTab })

Window:AddToggle({
    Title = "Enable Color Correction",
    Tab = ColorCorrectionTab,
    Default = false,
    Callback = function(bool)
        if bool then CreateEffect("ColorCorrection") else RemoveEffect("ColorCorrection") end
    end,
})

Window:AddSlider({
    Title = "Brightness",
    Tab = ColorCorrectionTab,
    MaxValue = 1,
    MinValue = -1,
    AllowDecimals = true,
    Callback = function(amount)
        if Shaders.ColorCorrection then Shaders.ColorCorrection.Brightness = amount end
    end,
})

Window:AddSlider({
    Title = "Contrast",
    Tab = ColorCorrectionTab,
    MaxValue = 1,
    MinValue = -1,
    AllowDecimals = true,
    Callback = function(amount)
        if Shaders.ColorCorrection then Shaders.ColorCorrection.Contrast = amount end
    end,
})

Window:AddSlider({
    Title = "Saturation",
    Tab = ColorCorrectionTab,
    MaxValue = 1,
    MinValue = -1,
    AllowDecimals = true,
    Callback = function(amount)
        if Shaders.ColorCorrection then Shaders.ColorCorrection.Saturation = amount end
    end,
})

Window:AddButton({
    Title = "Random Tint Color",
    Tab = ColorCorrectionTab,
    Callback = function()
        if Shaders.ColorCorrection then
            Shaders.ColorCorrection.TintColor = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
            Window:Notify({ Title = "Yukishimaru", Description = "Tint color changed", Duration = 2 })
        end
    end,
})

--// ====================== ВКЛАДКА BLOOM ======================
local BloomTab = Window:AddTab({
    Title = "Bloom",
    Section = "Bloom",
    Icon = "rbxassetid://11293977610"
})

Window:AddSection({ Name = "Bloom Settings", Tab = BloomTab })

Window:AddToggle({
    Title = "Enable Bloom",
    Tab = BloomTab,
    Default = false,
    Callback = function(bool)
        if bool then CreateEffect("Bloom", {Intensity = 0.3, Size = 24, Threshold = 0.8}) else RemoveEffect("Bloom") end
    end,
})

Window:AddSlider({
    Title = "Intensity",
    Tab = BloomTab,
    MaxValue = 2,
    AllowDecimals = true,
    Callback = function(amount)
        if Shaders.Bloom then Shaders.Bloom.Intensity = amount end
    end,
})

Window:AddSlider({
    Title = "Size",
    Tab = BloomTab,
    MaxValue = 50,
    Callback = function(amount)
        if Shaders.Bloom then Shaders.Bloom.Size = amount end
    end,
})

Window:AddSlider({
    Title = "Threshold",
    Tab = BloomTab,
    MaxValue = 1,
    AllowDecimals = true,
    Callback = function(amount)
        if Shaders.Bloom then Shaders.Bloom.Threshold = amount end
    end,
})

--// ====================== ВКЛАДКА SUN RAYS ======================
local SunRaysTab = Window:AddTab({
    Title = "Sun Rays",
    Section = "Sun Rays",
    Icon = "rbxassetid://11293977610"
})

Window:AddSection({ Name = "Sun Rays Settings", Tab = SunRaysTab })

Window:AddToggle({
    Title = "Enable Sun Rays",
    Tab = SunRaysTab,
    Default = false,
    Callback = function(bool)
        if bool then CreateEffect("SunRays", {Intensity = 0.2, Spread = 0.8}) else RemoveEffect("SunRays") end
    end,
})

Window:AddSlider({
    Title = "Intensity",
    Tab = SunRaysTab,
    MaxValue = 1,
    AllowDecimals = true,
    Callback = function(amount)
        if Shaders.SunRays then Shaders.SunRays.Intensity = amount end
    end,
})

Window:AddSlider({
    Title = "Spread",
    Tab = SunRaysTab,
    MaxValue = 1,
    AllowDecimals = true,
    Callback = function(amount)
        if Shaders.SunRays then Shaders.SunRays.Spread = amount end
    end,
})

-- Опция "Ignore Player" — отключает лучи, если смотреть на персонажа (для 3-го лица)
local sunRaysIgnorePlayer = false
Window:AddToggle({
    Title = "Ignore Player (3rd person)",
    Description = "Отключает лучи, когда вы смотрите на своего персонажа",
    Tab = SunRaysTab,
    Default = false,
    Callback = function(bool)
        sunRaysIgnorePlayer = bool
        -- Если включено, запускаем проверку
        if bool then
            local player = Players.LocalPlayer
            if player and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- В цикле проверяем направление взгляда
                    RunService.Heartbeat:Connect(function()
                        if not Shaders.SunRays then return end
                        if not sunRaysIgnorePlayer then return end
                        local char = player.Character
                        if not char then return end
                        local head = char:FindFirstChild("Head")
                        if not head then return end
                        local cam = workspace.CurrentCamera
                        if not cam then return end
                        local direction = (head.Position - cam.CFrame.Position).Unit
                        local dot = direction:Dot(cam.CFrame.LookVector)
                        if dot > 0.8 then -- смотрим прямо на персонажа
                            Shaders.SunRays.Enabled = false
                        else
                            Shaders.SunRays.Enabled = true
                        end
                    end)
                end
            end
        else
            -- Восстанавливаем видимость при отключении
            if Shaders.SunRays then
                Shaders.SunRays.Enabled = true
            end
        end
    end,
})

--// ====================== ПРОФИЛИ ======================
local ProfilesTab = Window:AddTab({
    Title = "Profiles",
    Section = "Profiles",
    Icon = "rbxassetid://11963373994"
})

local ProfileName = ""
Window:AddSection({ Name = "Save/Load Profiles", Tab = ProfilesTab })
Window:AddInput({
    Title = "Profile Name",
    Tab = ProfilesTab,
    Callback = function(text) ProfileName = text end,
})
Window:AddButton({
    Title = "Save Profile",
    Tab = ProfilesTab,
    Callback = function()
        if ProfileName == "" then return end
        local data = {}
        for effectName, effect in pairs(Shaders) do
            if effect then
                data[effectName] = { ClassName = effect.ClassName, Properties = {} }
                for prop, val in pairs(effect) do
                    if type(val) ~= "function" and prop ~= "Parent" then
                        data[effectName].Properties[prop] = val
                    end
                end
            end
        end
        _G.GrayStarProfiles = _G.GrayStarProfiles or {}
        _G.GrayStarProfiles[ProfileName] = data
        Window:Notify({ Title = "Yukishimaru", Description = "Saved '" .. ProfileName .. "'", Duration = 2 })
    end,
})
Window:AddButton({
    Title = "Load Profile",
    Tab = ProfilesTab,
    Callback = function()
        if ProfileName == "" then return end
        local data = _G.GrayStarProfiles and _G.GrayStarProfiles[ProfileName]
        if not data then Window:Notify({ Title = "Error", Description = "Not found", Duration = 2 }) return end
        ResetAllShaders()
        for effectName, effectData in pairs(data) do
            local effect = CreateEffect(effectName)
            if effect then
                for prop, val in pairs(effectData.Properties) do
                    pcall(function() effect[prop] = val end)
                end
            end
        end
        Window:Notify({ Title = "Yukishimaru", Description = "Loaded '" .. ProfileName .. "'", Duration = 2 })
    end,
})
Window:AddButton({
    Title = "List Profiles",
    Tab = ProfilesTab,
    Callback = function()
        local list = ""
        for name, _ in pairs(_G.GrayStarProfiles or {}) do list = list .. name .. "\n" end
        Window:Notify({ Title = "Profiles", Description = list ~= "" and list or "No profiles", Duration = 5 })
    end,
})

--// ====================== НАСТРОЙКИ ======================
local SettingsTab = Window:AddTab({
    Title = "Settings",
    Section = "Settings",
    Icon = "rbxassetid://11293977610",
})

local MinimizeKeybind = nil
Window:AddKeybind({
    Title = "Minimize Keybind",
    Tab = SettingsTab,
    Callback = function(Key)
        Window:SetSetting("Keybind", Key)
        MinimizeKeybind = Key
    end,
})

Window:AddDropdown({
    Title = "Set Theme",
    Tab = SettingsTab,
    Options = { ["Light Mode"] = "Light", ["Dark Mode"] = "Dark", ["Extra Dark"] = "Void" },
    Callback = function(Theme)
        Window:SetTheme(Themes[Theme])
    end,
})

Window:AddToggle({
    Title = "UI Blur",
    Default = true,
    Tab = SettingsTab,
    Callback = function(bool)
        Window:SetSetting("Blur", bool)
    end,
})

Window:AddSlider({
    Title = "UI Transparency",
    Tab = SettingsTab,
    AllowDecimals = true,
    MaxValue = 1,
    Callback = function(amount)
        Window:SetSetting("Transparency", amount)
    end,
})

--// Приветствие
Window:Notify({
    Title = "GrayStar Engine",
    Description = "Yukishimaru — полный шейдер-пак",
    Duration = 10,
})

--// ====================== ПЛАВНОЕ ПЕРЕТАСКИВАНИЕ (СИЛЬНОЕ ОТСТАВАНИЕ) ======================
local MainFrame = Window:GetMainFrame()
local isDragging = false
local dragOffset = Vector2.new()
local targetPosition = MainFrame.Position
local currentPosition = MainFrame.Position

-- Находим заголовок (первый Frame с высотой >= 40)
local titleBar = nil
for _, child in pairs(MainFrame:GetChildren()) do
    if child:IsA("Frame") and child.Size.Y.Offset >= 40 then
        titleBar = child
        break
    end
end
if not titleBar then
    for _, child in pairs(MainFrame:GetChildren()) do
        if child:IsA("Frame") then
            titleBar = child
            break
        end
    end
end

if titleBar then
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            local mousePos = input.Position
            local framePos = MainFrame.AbsolutePosition
            dragOffset = Vector2.new(mousePos.X - framePos.X, mousePos.Y - framePos.Y)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
            local newPos = UDim2.new(0, input.Position.X - dragOffset.X, 0, input.Position.Y - dragOffset.Y)
            targetPosition = newPos
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    -- Коэффициент 0.015 даёт очень заметное отставание (~1 секунда)
    RunService.Heartbeat:Connect(function()
        if not isDragging then
            local currentX = currentPosition.X.Offset
            local currentY = currentPosition.Y.Offset
            local targetX = targetPosition.X.Offset
            local targetY = targetPosition.Y.Offset
            local lerpX = currentX + (targetX - currentX) * 0.015
            local lerpY = currentY + (targetY - currentY) * 0.015
            MainFrame.Position = UDim2.new(0, lerpX, 0, lerpY)
            currentPosition = MainFrame.Position
        else
            -- при перетаскивании обновляем сразу (чтобы не было рывков)
            MainFrame.Position = targetPosition
            currentPosition = targetPosition
        end
    end)
end

--// Keybind
UserInputService.InputBegan:Connect(function(Key, GameProcessed)
    if GameProcessed then return end
    if Key.KeyCode == MinimizeKeybind then
        warn("Minimize key pressed")
    end
end)
