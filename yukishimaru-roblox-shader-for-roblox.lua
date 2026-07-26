--// 
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

--// 
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/lates-lib/main/Main.lua"))()
local Window = Library:CreateWindow({
    Title = "Yukishimaru Shader Engine",
    Theme = "Dark",
    Size = UDim2.fromOffset(720, 560),
    Transparency = 0.12,
    Blurring = true,
    MinimizeKeybind = Enum.KeyCode.LeftAlt,
})

--// 
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

--// 
Window:AddTabSection({ Name = "Main", Order = 1 })
Window:AddTabSection({ Name = "Shaders", Order = 2 })
Window:AddTabSection({ Name = "Profiles", Order = 3 })
Window:AddTabSection({ Name = "Settings", Order = 4 })

--// 
local Shaders = {
    Bloom = nil,
    Blur = nil,
    ColorCorrection = nil,
    DepthOfField = nil,
    SunRays = nil,
    Atmosphere = nil,
    -- Кастомные (сделаны через комбинации)
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
        -- Делаем через Bloom (не совсем виньетка, но имитация)
        effect = Instance.new("BloomEffect")
        effect.Intensity = params and params.Intensity or 0.5
        effect.Size = 1
        effect.Threshold = 0.9
    elseif name == "Chromatic" then
        -- Имитация через ColorCorrection (сдвиг цветов)
        effect = Instance.new("ColorCorrectionEffect")
        effect.TintColor = params and params.TintColor or Color3.fromRGB(255, 100, 100)
        effect.Saturation = 0.5
    elseif name == "Grain" then
        -- Имитация через добавление шума (но это не реализуемо в Lighting, оставим заглушку)
        effect = Instance.new("BlurEffect")
        effect.Size = 0.5
    elseif name == "Sharpen" then
        -- Имитация через контраст
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

--// 
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
}

--// 
local ShadersTab = Window:AddTab({
    Title = "Shaders",
    Section = "Shaders",
    Icon = "rbxassetid://11293977610"
})

Window:AddSection({ Name = "Post-Processing", Tab = ShadersTab })

-- 
Window:AddToggle({
    Title = "Bloom",
    Description = "Свечение",
    Tab = ShadersTab,
    Default = false,
    Callback = function(bool)
        if bool then CreateEffect("Bloom", {Intensity = 0.3, Size = 24, Threshold = 0.8}) else RemoveEffect("Bloom") end
    end,
})
Window:AddSlider({
    Title = "Bloom Intensity",
    Tab = ShadersTab,
    MaxValue = 2,
    AllowDecimals = true,
    Callback = function(amount)
        if Shaders.Bloom then Shaders.Bloom.Intensity = amount end
    end,
})
Window:AddSlider({
    Title = "Bloom Size",
    Tab = ShadersTab,
    MaxValue = 50,
    Callback = function(amount)
        if Shaders.Bloom then Shaders.Bloom.Size = amount end
    end,
})
Window:AddSlider({
    Title = "Bloom Threshold",
    Tab = ShadersTab,
    MaxValue = 1,
    AllowDecimals = true,
    Callback = function(amount)
        if Shaders.Bloom then Shaders.Bloom.Threshold = amount end
    end,
})

-- 
Window:AddToggle({
    Title = "Blur",
    Description = "Размытие",
    Tab = ShadersTab,
    Default = false,
    Callback = function(bool)
        if bool then CreateEffect("Blur", {Size = 6}) else RemoveEffect("Blur") end
    end,
})
Window:AddSlider({
    Title = "Blur Size",
    Tab = ShadersTab,
    MaxValue = 20,
    Callback = function(amount)
        if Shaders.Blur then Shaders.Blur.Size = amount end
    end,
})

-- 
Window:AddToggle({
    Title = "Color Correction",
    Tab = ShadersTab,
    Default = false,
    Callback = function(bool)
        if bool then CreateEffect("ColorCorrection") else RemoveEffect("ColorCorrection") end
    end,
})
Window:AddSlider({ Title = "Brightness", Tab = ShadersTab, MaxValue = 1, MinValue = -1, AllowDecimals = true,
    Callback = function(amount) if Shaders.ColorCorrection then Shaders.ColorCorrection.Brightness = amount end end })
Window:AddSlider({ Title = "Contrast", Tab = ShadersTab, MaxValue = 1, MinValue = -1, AllowDecimals = true,
    Callback = function(amount) if Shaders.ColorCorrection then Shaders.ColorCorrection.Contrast = amount end end })
Window:AddSlider({ Title = "Saturation", Tab = ShadersTab, MaxValue = 1, MinValue = -1, AllowDecimals = true,
    Callback = function(amount) if Shaders.ColorCorrection then Shaders.ColorCorrection.Saturation = amount end end })
Window:AddButton({
    Title = "Random Tint Color",
    Tab = ShadersTab,
    Callback = function()
        if Shaders.ColorCorrection then
            Shaders.ColorCorrection.TintColor = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
            Window:Notify({ Title = "Yukishimaru", Description = "Tint changed", Duration = 2 })
        end
    end,
})

-- 
Window:AddToggle({
    Title = "Depth of Field",
    Tab = ShadersTab,
    Default = false,
    Callback = function(bool)
        if bool then CreateEffect("DepthOfField", {FarIntensity = 0.5, NearIntensity = 0.2, FocusDistance = 10}) else RemoveEffect("DepthOfField") end
    end,
})
Window:AddSlider({ Title = "Far Intensity", Tab = ShadersTab, MaxValue = 1, AllowDecimals = true,
    Callback = function(amount) if Shaders.DepthOfField then Shaders.DepthOfField.FarIntensity = amount end end })
Window:AddSlider({ Title = "Near Intensity", Tab = ShadersTab, MaxValue = 1, AllowDecimals = true,
    Callback = function(amount) if Shaders.DepthOfField then Shaders.DepthOfField.NearIntensity = amount end end })
Window:AddSlider({ Title = "Focus Distance", Tab = ShadersTab, MaxValue = 30,
    Callback = function(amount) if Shaders.DepthOfField then Shaders.DepthOfField.FocusDistance = amount end end })

-- 
Window:AddToggle({
    Title = "Sun Rays",
    Tab = ShadersTab,
    Default = false,
    Callback = function(bool)
        if bool then CreateEffect("SunRays", {Intensity = 0.2, Spread = 0.8}) else RemoveEffect("SunRays") end
    end,
})
Window:AddSlider({ Title = "Intensity", Tab = ShadersTab, MaxValue = 1, AllowDecimals = true,
    Callback = function(amount) if Shaders.SunRays then Shaders.SunRays.Intensity = amount end end })
Window:AddSlider({ Title = "Spread", Tab = ShadersTab, MaxValue = 1, AllowDecimals = true,
    Callback = function(amount) if Shaders.SunRays then Shaders.SunRays.Spread = amount end end })

-- 
Window:AddToggle({
    Title = "Atmosphere",
    Tab = ShadersTab,
    Default = false,
    Callback = function(bool)
        if bool then CreateEffect("Atmosphere", {Density = 0.2, Offset = 0.1, Color = Color3.fromRGB(135, 206, 235)}) else RemoveEffect("Atmosphere") end
    end,
})
Window:AddSlider({ Title = "Density", Tab = ShadersTab, MaxValue = 1, AllowDecimals = true,
    Callback = function(amount) if Shaders.Atmosphere then Shaders.Atmosphere.Density = amount end end })
Window:AddSlider({ Title = "Offset", Tab = ShadersTab, MaxValue = 0.5, AllowDecimals = true,
    Callback = function(amount) if Shaders.Atmosphere then Shaders.Atmosphere.Offset = amount end end })
Window:AddButton({
    Title = "Random Atmosphere Color",
    Tab = ShadersTab,
    Callback = function()
        if Shaders.Atmosphere then
            Shaders.Atmosphere.Color = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
        end
    end,
})

-- 
Window:AddSection({ Name = "Custom Effects (experimental)", Tab = ShadersTab })

local customEffects = {
    "Vignette", "Chromatic", "Grain", "Sharpen", "EdgeDetect", "Posterize"
}
for _, name in ipairs(customEffects) do
    Window:AddToggle({
        Title = name,
        Tab = ShadersTab,
        Default = false,
        Callback = function(bool)
            if bool then CreateEffect(name) else RemoveEffect(name) end
        end,
    })
end

--//
Window:AddSection({ Name = "Presets — Yukishimaru", Tab = ShadersTab })
for presetName, presetFunc in pairs(Presets) do
    Window:AddButton({
        Title = presetName,
        Tab = ShadersTab,
        Callback = presetFunc,
    })
end

Window:AddButton({
    Title = "Reset All",
    Tab = ShadersTab,
    Callback = ResetAllShaders,
})

--//
local ProfilesTab = Window:AddTab({
    Title = "Profiles",
    Section = "Profiles",
    Icon = "rbxassetid://11963373994"
})

local function SaveProfile(name)
    local data = {}
    for effectName, effect in pairs(Shaders) do
        if effect then
            data[effectName] = {
                ClassName = effect.ClassName,
                Properties = {}
            }
            for prop, val in pairs(effect) do
                if type(val) ~= "function" and prop ~= "Parent" then
                    data[effectName].Properties[prop] = val
                end
            end
        end
    end
    _G.GrayStarProfiles = _G.GrayStarProfiles or {}
    _G.GrayStarProfiles[name] = data
    Window:Notify({ Title = "Yukishimaru", Description = "Profile '" .. name .. "' saved", Duration = 2 })
end

local function LoadProfile(name)
    local data = _G.GrayStarProfiles and _G.GrayStarProfiles[name]
    if not data then
        Window:Notify({ Title = "Error", Description = "Profile not found", Duration = 2 })
        return
    end
    ResetAllShaders()
    for effectName, effectData in pairs(data) do
        local effect = CreateEffect(effectName)
        if effect then
            for prop, val in pairs(effectData.Properties) do
                pcall(function() effect[prop] = val end)
            end
        end
    end
    Window:Notify({ Title = "Yukishimaru", Description = "Profile '" .. name .. "' loaded", Duration = 2 })
end

Window:AddSection({ Name = "Save/Load Profiles", Tab = ProfilesTab })
Window:AddInput({
    Title = "Profile Name",
    Tab = ProfilesTab,
    Callback = function(text) ProfileName = text end,
})
local ProfileName = ""
Window:AddButton({
    Title = "Save Profile",
    Tab = ProfilesTab,
    Callback = function()
        if ProfileName ~= "" then SaveProfile(ProfileName) end
    end,
})
Window:AddButton({
    Title = "Load Profile",
    Tab = ProfilesTab,
    Callback = function()
        if ProfileName ~= "" then LoadProfile(ProfileName) end
    end,
})
Window:AddButton({
    Title = "List Profiles",
    Tab = ProfilesTab,
    Callback = function()
        local list = ""
        for name, _ in pairs(_G.GrayStarProfiles or {}) do
            list = list .. name .. "\n"
        end
        Window:Notify({ Title = "Profiles", Description = list ~= "" and list or "No profiles", Duration = 5 })
    end,
})

--//
local Settings = Window:AddTab({
    Title = "Settings",
    Section = "Settings",
    Icon = "rbxassetid://11293977610",
})

local MinimizeKeybind = nil
Window:AddKeybind({
    Title = "Minimize Keybind",
    Tab = Settings,
    Callback = function(Key)
        Window:SetSetting("Keybind", Key)
        MinimizeKeybind = Key
    end,
})

Window:AddDropdown({
    Title = "Set Theme",
    Tab = Settings,
    Options = {
        ["Light Mode"] = "Light",
        ["Dark Mode"] = "Dark",
        ["Extra Dark"] = "Void",
    },
    Callback = function(Theme)
        Window:SetTheme(Themes[Theme])
    end,
})

Window:AddToggle({
    Title = "UI Blur",
    Default = true,
    Tab = Settings,
    Callback = function(bool)
        Window:SetSetting("Blur", bool)
    end,
})

Window:AddSlider({
    Title = "UI Transparency",
    Tab = Settings,
    AllowDecimals = true,
    MaxValue = 1,
    Callback = function(amount)
        Window:SetSetting("Transparency", amount)
    end,
})

--//
Window:Notify({
    Title = "GrayStar Engine",
    Description = "Yukishimaru — полный шейдер-пак",
    Duration = 10,
})

--//
UserInputService.InputBegan:Connect(function(Key, GameProcessed)
    if GameProcessed then return end
    if Key.KeyCode == MinimizeKeybind then
        warn("Minimize key pressed")
    end
end)
