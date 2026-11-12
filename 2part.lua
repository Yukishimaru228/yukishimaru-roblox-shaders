-- YukiShader V25 (V24 + Pets & Cars tabs): keeps game effects on the character, fixed Rain, camera-following 3D effects, new map effects, living menu.
--============================================================
-- SERVICES
--============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local MarketplaceService = game:GetService("MarketplaceService")
local AvatarEditorService = game:GetService("AvatarEditorService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Keep all cursor-related state in one local table.
-- This avoids pushing the main Luau chunk over its ~200-register limit.
local CursorState = {
    Mouse = LocalPlayer:GetMouse(),
    IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled,
    IsPC = not (UserInputService.TouchEnabled and not UserInputService.MouseEnabled),
    OriginalMouseIcon = "",
    CurrentName = "Default",
    CurrentId = nil,
    StatusLabel = nil,
    Cards = {}
}
CursorState.OriginalMouseIcon = CursorState.Mouse.Icon or ""

--============================================================
-- CONFIG
--============================================================

local CONFIG = {
    Width = 800,
    Height = 510,

    -- Monochrome UI palette. Names are kept for compatibility with the existing UI code.
    Purple = Color3.fromRGB(224, 224, 228),
    PurpleLight = Color3.fromRGB(255, 255, 255),
    PurpleSoft = Color3.fromRGB(46, 46, 50),

    -- Deep charcoal palette inspired by the supplied new menu.
    BackgroundTop = Color3.fromRGB(48, 48, 53),
    BackgroundBottom = Color3.fromRGB(27, 27, 31),

    Panel = Color3.fromRGB(34, 34, 39),
    PanelLight = Color3.fromRGB(49, 49, 55),

    White = Color3.fromRGB(232, 232, 237),
    Text = Color3.fromRGB(242, 242, 246),
    Muted = Color3.fromRGB(166, 166, 175),

    BubbleCount = 110,
    BubbleGravity = 110,
    BubbleMagnet = 8.5,
    BubbleDrag = 0.90,

    WindowRadius = 24,
    PanelRadius = 18,
    ButtonRadius = 12,

    RightAlt = Enum.KeyCode.RightAlt,

    ShaderPrefix = "YukiShader_",
    VignetteName = "YukiShader_Vignette"
}

--============================================================
-- GLOBAL STATE
--============================================================

local Alive = true
local Collapsed = false
local ConfirmOpen = false

local Connections = {}
local Bubbles = {}

local CurrentPage = "Home"
local CurrentPreset = "Default"

local CustomPresets = {}
local CustomPresetFile = "YukiShaderCustomPresets.json"
local CustomEditorOpen = false
local CustomEditorOriginal = nil
local CustomEditorOverlay = nil
local CustomEditorFrame = nil
local CustomEditorBody = nil
local CustomNameDialog = nil
local CustomNameInput = nil
local CustomEditorMessage = nil
local OpenCustomEditor

local Dragging = false
local DragStart = nil
local DragOrigin = nil
local SavedPosition = nil

local VignetteGui = nil
local MotionBlurEffect = nil
local LastCameraCFrame = nil
local MenuBlurEffect = nil

local Effects = {
    ColorCorrection = nil,
    Bloom = nil,
    Blur = nil,
    DepthOfField = nil,
    SunRays = nil,
    Atmosphere = nil,
    MotionBlur = nil
}

--============================================================
-- SHADER STATE
--============================================================

local ShaderState = {
    Saturation = 0,
    Brightness = 0,
    Contrast = 0,

    Blur = 0,

    BloomIntensity = 0,
    BloomSize = 24,
    BloomThreshold = 1,

    SunRaysIntensity = 0,
    SunRaysSpread = 1,

    DOFFarIntensity = 0,
    DOFNearIntensity = 0,
    DOFFocusDistance = 10,

    AtmosphereDensity = 0,
    AtmosphereColor = Color3.fromRGB(
        200,
        200,
        200
    ),

    MotionBlur = false,
    MotionBlurStrength = 0,

    Vignette = false,
    VignetteStrength = 0
}

-- UI Settings (FOV, Aspect Ratio, Kill Atmosphere)
local UISettings = {
    FOVEnabled = false,
    FOVValue = 70,
    AspectEnabled = false,
    AspectValue = 0.6,
    KillAtmosphere = false,
    SavedAtmosphere = nil,
    AtmosphereRemoved = false
}

-- Anti Lag settings
local AntiLagEnabled = false

--============================================================
-- HELPERS
--============================================================

local function Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Connections, connection)
    return connection
end

local function DisconnectAll()
    for _, connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(Connections)
end

local function Tween(
    object,
    properties,
    duration,
    style,
    direction
)
    if _G.YukiThemeTween then
        properties = _G.YukiThemeTween(object, properties)
    end

    local tweenInfo = TweenInfo.new(
        duration or 0.25,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )

    local tween = TweenService:Create(
        object,
        tweenInfo,
        properties
    )

    tween:Play()

    return tween
end

local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(
        0,
        radius
    )
    corner.Parent = parent

    return corner
end

local function AddStroke(
    parent,
    color,
    transparency,
    thickness
)
    local stroke = Instance.new("UIStroke")

    stroke.Color = color or CONFIG.Purple
    stroke.Transparency =
        transparency or 0.5
    stroke.Thickness =
        thickness or 1

    stroke.ApplyStrokeMode =
        Enum.ApplyStrokeMode.Border

    stroke.Parent = parent

    return stroke
end

local function AddGradient(
    parent,
    color1,
    color2,
    rotation
)
    local gradient = Instance.new("UIGradient")

    gradient.Color =
        ColorSequence.new({
            ColorSequenceKeypoint.new(
                0,
                color1
            ),
            ColorSequenceKeypoint.new(
                1,
                color2
            )
        })

    gradient.Rotation =
        rotation or 0

    gradient.Parent =
        parent

    return gradient
end

local function Clamp(
    value,
    minValue,
    maxValue
)
    return math.max(
        minValue,
        math.min(
            maxValue,
            value
        )
    )
end

local function SafeDestroy(object)
    if object then
        pcall(function()
            object:Destroy()
        end)
    end
end

local function SetMenuBlur(_enabled)
    -- Menu blur is permanently disabled.
    -- Remove stale blur objects left by older versions.
    local existing = Lighting:FindFirstChild("YukiMenuBlur")
    if existing then
        SafeDestroy(existing)
    end
    MenuBlurEffect = nil
end

local EffectClock = {}
local function StepEffect(key, interval)
    local now = os.clock()
    local last = EffectClock[key] or 0
    if now - last < interval then
        return false
    end
    EffectClock[key] = now
    return true
end

--============================================================
-- PORTED VISUAL EFFECTS (from Portal Visuals -> Visuals)
--============================================================
-- Kept isolated so the original Yuki Shader Engine remains independent.

if type(getgenv) ~= "function" then
    function getgenv()
        return _G
    end
end

local PortalVisualsMeta = {
    __index = function(t, k)
        return rawget(t, "_enabled_" .. tostring(k)) or false
    end,
    __newindex = function(t, k, v)
        if type(k) ~= "string" then
            return
        end

        -- Internal registries must be real table fields, not pseudo-toggle keys.
        if k == "_enableFuncs" or k == "_disableFuncs" or k == "_listeners" then
            rawset(t, k, v)
            return
        end

        local enabled = (v == true)
        rawset(t, "_enabled_" .. k, enabled)

        local registry = rawget(t, enabled and "_enableFuncs" or "_disableFuncs")
        local fn = registry and registry[k]
        if fn then
            task.spawn(fn)
        end

        local listeners = rawget(t, "_listeners")
        local effectListeners = listeners and listeners[k]
        if effectListeners then
            for _, listener in ipairs(effectListeners) do
                task.spawn(listener, enabled)
            end
        end
    end
}

if type(_G.PortalVisuals) ~= "table" then
    _G.PortalVisuals = {}
end
if getmetatable(_G.PortalVisuals) == nil then
    setmetatable(_G.PortalVisuals, PortalVisualsMeta)
end

rawset(_G.PortalVisuals, "_enableFuncs", rawget(_G.PortalVisuals, "_enableFuncs") or {})
rawset(_G.PortalVisuals, "_disableFuncs", rawget(_G.PortalVisuals, "_disableFuncs") or {})
rawset(_G.PortalVisuals, "_listeners", rawget(_G.PortalVisuals, "_listeners") or {})

local PortalVisualEffects = {
    "RGB Body", "FullBright", "Motion Blur", "Aura Pulse", "Night Mode", "Ghost Trail",
    "ESP Chams", "Neon Trail", "Orbit", "Paradox Engine", "Atmospheric Fog",
    "Rain", "Fireflies", "Snowfall", "StarFall", "Thunder", "RGB Circle",
    "Leaves Fall", "Cherry Blossoms", "Floating Lamps", "Butterflies", "Birds",
    "Footprints", "Angel's Halo", "Wind",
    "Crystal Orbit", "Energy Ribbons", "Pulse Halo 3D",
    "Map Crystals", "Ground Runes", "Floating Relics", "Light Pillars",
    "World Energy Nodes", "Ground Vortex",
    "World Shards", "Hologram Rings", "Mystic Totems", "Floating Cubes",
    "Ancient Stones", "Sky Ribbons", "Crystal Garden", "Beacon Columns",
    "World Motes", "Portal Gates",
    "Prism Field 3D", "Orbital Relays 3D", "Wave Columns 3D",
    "Aurora Curtains 3D", "Rune Circles 3D", "Drifting Lanterns 3D", "Spirit Wisps 3D"
}

local function PortalGetRoot(char)
    if not char then
        return nil
    end
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("UpperTorso")
end


-- [[ Ghost Trail / Movement History ]]
-- Build visual-only snapshots from BaseParts. Never clone the entire Character
-- model: game-specific Carry/Tool/CharacterService objects must not be copied.
do
    local name = "Ghost Trail"
    local running = false
    local updateConn, characterConn
    local ghostFolder
    local lastSample = 0
    local activeGhosts = {}
    local settings = {
        Color = Color3.fromRGB(190, 150, 255),
        Duration = 1.15,
        FadeIn = 0.12,
        FadeOut = 0.42,
        SampleInterval = 0.14,
        MaxGhosts = 8,
        -- Lower transparency means a stronger, more visible silhouette.
        Transparency = 0.14,
    }

    local function safeClone(instance)
        if not instance then return nil end
        local oldArchivable
        local couldRead = pcall(function() oldArchivable = instance.Archivable end)
        if couldRead and oldArchivable == false then
            local enabled = pcall(function() instance.Archivable = true end)
            if not enabled then return nil end
        end
        local ok, copy = pcall(function() return instance:Clone() end)
        if couldRead and oldArchivable == false then
            pcall(function() instance.Archivable = false end)
        end
        if ok then return copy end
        return nil
    end

    local function hasToolAncestor(part, character)
        local current = part.Parent
        while current and current ~= character do
            if current:IsA("Tool") then return true end
            current = current.Parent
        end
        return false
    end

    local function keepOnlyVisuals(partCopy)
        for _, child in ipairs(partCopy:GetDescendants()) do
            local keep = child:IsA("SpecialMesh")
                or child:IsA("Decal")
                or child:IsA("Texture")
                or child:IsA("SurfaceAppearance")
                or child:IsA("WrapLayer")
                or child:IsA("WrapTarget")
            if not keep then
                pcall(function() child:Destroy() end)
            end
        end
    end

    local function applyTint(record, color)
        if not record then return end
        for _, info in ipairs(record.Parts or {}) do
            if info.Part and info.Part.Parent then
                pcall(function()
                    info.Part.Color = color
                    info.Part.Material = Enum.Material.ForceField
                end)
            end
        end
        if record.Highlight and record.Highlight.Parent then
            pcall(function()
                record.Highlight.FillColor = color
                record.Highlight.OutlineColor = color
            end)
        end
    end

    local function setColor(color)
        if typeof(color) ~= "Color3" then return end
        settings.Color = color
        for _, record in ipairs(activeGhosts) do
            if not record.Removing then applyTint(record, color) end
        end
    end

    local function makeGhost(character)
        if not character or not character.Parent or not ghostFolder then return end

        local ghost = Instance.new("Model")
        ghost.Name = "YukiGhostSnapshot"
        local parts = {}

        -- Copy only clothing descriptors, never scripts, tools, humanoids or
        -- game-specific instances such as carried equipment state.
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Shirt") or child:IsA("Pants")
                or child:IsA("ShirtGraphic") or child:IsA("BodyColors")
                or child:IsA("CharacterMesh") then
                local visual = safeClone(child)
                if visual then visual.Parent = ghost end
            end
        end

        for _, source in ipairs(character:GetDescendants()) do
            if source:IsA("BasePart")
                and source.Transparency < 0.98
                and not hasToolAncestor(source, character) then
                local partCopy = safeClone(source)
                if partCopy and partCopy:IsA("BasePart") then
                    keepOnlyVisuals(partCopy)
                    partCopy.Anchored = true
                    partCopy.CanCollide = false
                    partCopy.CanTouch = false
                    partCopy.CanQuery = false
                    partCopy.CastShadow = false
                    partCopy.Massless = true
                    partCopy.CFrame = source.CFrame
                    partCopy.Color = settings.Color
                    partCopy.Material = Enum.Material.ForceField
                    partCopy.Transparency = math.clamp(
                        settings.Transparency + math.min(source.Transparency, 0.45) * 0.35,
                        0.04,
                        0.78
                    )
                    partCopy.Parent = ghost
                    table.insert(parts, {
                        Part = partCopy,
                        BaseTransparency = partCopy.Transparency,
                    })
                elseif partCopy then
                    pcall(function() partCopy:Destroy() end)
                end
            end
        end

        if #parts == 0 then
            ghost:Destroy()
            return nil
        end

        ghost.Parent = ghostFolder
        local highlight = Instance.new("Highlight")
        highlight.Name = "YukiGhostTint"
        highlight.Adornee = ghost
        highlight.FillColor = settings.Color
        highlight.OutlineColor = settings.Color
        highlight.FillTransparency = 1
        highlight.OutlineTransparency = 1
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded
        highlight.Parent = ghost

        local record = {
            Model = ghost,
            Parts = parts,
            Highlight = highlight,
            Born = os.clock(),
            Duration = math.max(0.30, settings.Duration),
            FadeIn = math.max(0.04, settings.FadeIn),
            FadeOut = math.max(0.08, settings.FadeOut),
        }
        table.insert(activeGhosts, record)

        for _, info in ipairs(parts) do
            if info.Part and info.Part.Parent then
                local targetTransparency = info.BaseTransparency
                info.Part.Transparency = 1
                Tween(
                    info.Part,
                    {Transparency = targetTransparency},
                    record.FadeIn,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                )
            end
        end
        Tween(highlight, {FillTransparency = 0.24, OutlineTransparency = 0.04}, record.FadeIn)
        return record
    end

    local function removeGhost(record)
        if not record or record.Removing then return end
        record.Removing = true
        local fade = math.max(0.08, record.FadeOut or settings.FadeOut)
        for _, info in ipairs(record.Parts or {}) do
            if info.Part and info.Part.Parent then
                Tween(info.Part, {Transparency = 1}, fade, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            end
        end
        if record.Highlight and record.Highlight.Parent then
            Tween(record.Highlight, {FillTransparency = 1, OutlineTransparency = 1}, fade)
        end
        task.delay(fade + 0.08, function()
            if record.Model then pcall(function() record.Model:Destroy() end) end
            for i = #activeGhosts, 1, -1 do
                if activeGhosts[i] == record then
                    table.remove(activeGhosts, i)
                    break
                end
            end
        end)
    end

    local function clearGhosts()
        for _, record in ipairs(activeGhosts) do
            if record.Model then pcall(function() record.Model:Destroy() end) end
        end
        table.clear(activeGhosts)
    end

    local function onCharacterAdded()
        lastSample = 0
    end

    local function enable()
        if running then return end
        running = true
        lastSample = 0
        ghostFolder = Instance.new("Folder")
        ghostFolder.Name = "Yuki_GhostTrail_Local"
        ghostFolder.Parent = Workspace
        characterConn = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
        updateConn = RunService.Heartbeat:Connect(function()
            if not running then return end
            local now = os.clock()
            if now - lastSample >= settings.SampleInterval then
                lastSample = now
                local character = LocalPlayer.Character
                local root = character and PortalGetRoot(character)
                if root and root.AssemblyLinearVelocity.Magnitude > 1.25 then
                    local ok, err = pcall(makeGhost, character)
                    if not ok then warn("[Yuki Ghost Trail] snapshot failed:", err) end
                    while #activeGhosts > settings.MaxGhosts do
                        local oldest = activeGhosts[1]
                        if not oldest then break end
                        table.remove(activeGhosts, 1)
                        removeGhost(oldest)
                    end
                end
            end
            for i = #activeGhosts, 1, -1 do
                local record = activeGhosts[i]
                if record and not record.Removing and now - record.Born >= record.Duration then
                    removeGhost(record)
                end
            end
        end)
    end

    local function disable()
        running = false
        if updateConn then updateConn:Disconnect(); updateConn = nil end
        if characterConn then characterConn:Disconnect(); characterConn = nil end
        clearGhosts()
        if ghostFolder then pcall(function() ghostFolder:Destroy() end); ghostFolder = nil end
    end

    _G.PortalVisuals._enableFuncs[name] = enable
    _G.PortalVisuals._disableFuncs[name] = disable
    getgenv().PortalVisual = getgenv().PortalVisual or {}
    getgenv().PortalVisual[name] = {
        Settings = settings,
        Toggle = function(state) if state then enable() else disable() end end,
        Start = enable,
        Stop = disable,
        SetColor = setColor,
    }
end

-- [[ RGB Body ]]
do     local name="RGB Body"local running=false      local heartbeatConn      local originalData={}     local charConn      local function savePart(part)         if not originalData[part]then              originalData[part]={color=part.Color,material=part.Material}         end     end     local function scanChar(char)         if not char then              return          end         for _,part in ipairs(char:GetDescendants())do             if part:IsA("BasePart")then                  savePart(part)             end         end     end     local function enable()         if running then              return          end          running=true          if LocalPlayer.Character then              scanChar(LocalPlayer.Character)         end             charConn=LocalPlayer.CharacterAdded:Connect(scanChar)             heartbeatConn=RunService.Heartbeat:Connect(function()
                         if not running then                  return              end             local char=LocalPlayer.Character              if not char then                  return              end             local hue=(tick()%2)/2              local color=Color3.fromHSV(hue,1,1)             for _,part in ipairs(char:GetDescendants())do                 if part:IsA("BasePart")then                         savePart(part)                         part.Color=color part.Material=Enum.Material.Neon                 end             end         end)     end     local function disable()     running=false         if heartbeatConn then              heartbeatConn:Disconnect()         end         if charConn then              charConn:Disconnect()         end         for part,data in pairs(originalData)do             if part and part.Parent then                  part.Color=data.color part.Material=data.material              end         end          table.clear(originalData)     end      _G.PortalVisuals._enableFuncs[name]=enable _G.PortalVisuals._disableFuncs[name]=disable  end

-- [[ FullBright ]]
do     local name="FullBright"local saved={}     local function enable()     saved.Ambient=Lighting.Ambient saved.Brightness=Lighting.Brightness saved.OutdoorAmbient=Lighting.OutdoorAmbient saved.GlobalShadows=Lighting.GlobalShadows saved.ClockTime=Lighting.ClockTime saved.GeographicLatitude=Lighting.GeographicLatitude saved.FogEnd=Lighting.FogEnd saved.FogColor=Lighting.FogColor saved.ColorShift_Top=Lighting.ColorShift_Top saved.ColorShift_Bottom=Lighting.ColorShift_Bottom Lighting.Ambient=Color3.new(1,1,1)     Lighting.Brightness=6     Lighting.OutdoorAmbient=Color3.new(1,1,1)     Lighting.GlobalShadows=false     Lighting.ClockTime=14     Lighting.GeographicLatitude=0     Lighting.FogEnd=9e9 Lighting.FogColor=Color3.new(1,1,1)     Lighting.ColorShift_Top=Color3.new(1,1,1)     Lighting.ColorShift_Bottom=Color3.new(1,1,1)     end     local function disable()         if not saved.Ambient then              return          end          Lighting.Ambient=saved.Ambient Lighting.Brightness=saved.Brightness Lighting.OutdoorAmbient=saved.OutdoorAmbient Lighting.GlobalShadows=saved.GlobalShadows Lighting.ClockTime=saved.ClockTime Lighting.GeographicLatitude=saved.GeographicLatitude Lighting.FogEnd=saved.FogEnd Lighting.FogColor=saved.FogColor Lighting.ColorShift_Top=saved.ColorShift_Top Lighting.ColorShift_Bottom=saved.ColorShift_Bottom      end      _G.PortalVisuals._enableFuncs[name]=enable _G.PortalVisuals._disableFuncs[name]=disable  end

-- [[ Motion Blur ]]
do     local name="Motion Blur"local running=false      local blur=nil      local camera=Workspace.CurrentCamera      local lastLookVector=Vector3.new(0,0,1)     local currentBlurSize=0      local renderConn,cameraConn      local BlurAmount=32      local MaxBlurSize=25      local Deadzone=0.004      local function createBlur()         if blur then              blur:Destroy()         end             blur=Instance.new("BlurEffect")             blur.Name="CinematicBlur"blur.Size=0             blur.Parent=camera     end     local function onRender(dt)         if not running or not camera or not blur then              return          end         if dt==0 then              return          end         local currentLookVector=camera.CFrame.LookVector          local magnitude=(currentLookVector-lastLookVector).Magnitude          if magnitude<Deadzone then              magnitude=0          end         if magnitude>0.5 then              lastLookVector=currentLookVector return          end         local targetBlur=math.clamp((magnitude/dt)*(BlurAmount*0.055),0,MaxBlurSize)         local lerpFactor=1-math.exp(-12*dt)         currentBlurSize=currentBlurSize+(targetBlur-currentBlurSize)*lerpFactor         blur.Size=currentBlurSize lastLookVector=currentLookVector     end     local function onCameraChanged()     camera=Workspace.CurrentCamera         if camera and running then             if blur then                  blur.Parent=camera              end              lastLookVector=camera.CFrame.LookVector currentBlurSize=0             if blur then                  blur.Size=0              end         end     end     local function enable()         if running then              return          end             running=true             camera=Workspace.CurrentCamera         if not camera then              return          end             createBlur()             lastLookVector=camera.CFrame.LookVector currentBlurSize=0             renderConn=RunService.Heartbeat:Connect(onRender)             cameraConn=Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(onCameraChanged)     end     local function disable()     running=false         if renderConn then              renderConn:Disconnect()         end         if cameraConn then              cameraConn:Disconnect()         end         if blur then                 blur:Destroy()                 blur=nil         end          currentBlurSize=0     end      _G.PortalVisuals._enableFuncs[name]=enable _G.PortalVisuals._disableFuncs[name]=disable  end

-- [[ Aura Pulse ]]
do     local name="Aura Pulse"local running=false      local heartbeatConn,charConn      local auraContainer,bodyHighlight,ambientLight,baseEmitter      local purpleOrb,purpleTrail,purpleGlow,blueOrb,blueTrail,blueGlow      local springPurple,springBlue      local orbitConnection,pulseThread      local activePulsePart=nil      local currentLTM=0      local angle=0      local firstFrame=true      local pulseCounter=0      local sparkleEmitters={}     local CONFIG={ColorPurple=Color3.fromRGB(160,32,240),ColorBlue=Color3.fromRGB(0,140,255),PulseInterval=1.6,ExpansionTime=1.1,MaxSize=18,OrbitRadius=3.6,OrbitSpeed=2.8,OrbBaseSize=0.5,SpringMass=1.0,SpringDamping=4.5,SpringStiffness=45.0,}     local function createVector3Spring(mass,damping,stiffness)         local spring={x=Vector3.new(),v=Vector3.new(),target=Vector3.new(),mass=mass or 1,damping=damping or 4,stiffness=stiffness or 40}function spring:update(dt)             local displacement=self.x-self.target              local force=-self.stiffness*displacement-self.damping*self.v              local acceleration=force/self.mass self.v=self.v+acceleration*dt self.x=self.x+self.v*dt return self.x          end          return spring      end     local function getNextColor()     pulseCounter=(pulseCounter%4)+1         if pulseCounter<=2 then              return CONFIG.ColorPurple,CONFIG.ColorBlue          else              return CONFIG.ColorBlue,CONFIG.ColorPurple          end     end     local function isFirstPerson(character)         if not character then              return false          end         local cam=Workspace.CurrentCamera          if not cam then              return false          end         local head=character:FindFirstChild("Head")         if not head then              return false          end          return(cam.CFrame.Position-head.Position).Magnitude<2.5      end     local function createCometOrb(color)         local orb=Instance.new("Part")         orb.Shape=Enum.PartType.Ball orb.Size=Vector3.new(CONFIG.OrbBaseSize,CONFIG.OrbBaseSize,CONFIG.OrbBaseSize)         orb.Material=Enum.Material.Neon orb.Color=color orb.Anchored=true         orb.CanCollide=false         orb.CanTouch=false         orb.CanQuery=false         orb.CastShadow=false         orb.Parent=auraContainer         local glowGui=Instance.new("BillboardGui")         glowGui.Size=UDim2.new(3.2,0,3.2,0)         glowGui.AlwaysOnTop=false         glowGui.LightInfluence=0         glowGui.Parent=orb         local glowImage=Instance.new("ImageLabel")         glowImage.BackgroundTransparency=1         glowImage.Image="rbxassetid://13470377227"glowImage.ImageColor3=color glowImage.Size=UDim2.new(1,0,1,0)         glowImage.Parent=glowGui         local att0=Instance.new("Attachment",orb)         att0.Position=Vector3.new(0,CONFIG.OrbBaseSize/2,0)         local att1=Instance.new("Attachment",orb)         att1.Position=Vector3.new(0,-CONFIG.OrbBaseSize/2,0)         local trail=Instance.new("Trail")         trail.Attachment0=att0 trail.Attachment1=att1 trail.Color=ColorSequence.new(color)         trail.Lifetime=0.7         trail.Transparency=NumberSequence.new(0.3)         trail.WidthScale=NumberSequence.new({NumberSequenceKeypoint.new(0,1.2),NumberSequenceKeypoint.new(1,0)})             trail.Parent=orb         local sparks=Instance.new("ParticleEmitter")         sparks.Texture="rbxassetid://5813005513"sparks.Size=NumberSequence.new(0.15,0)         sparks.Lifetime=NumberRange.new(0.3,0.6)         sparks.Rate=12         sparks.Speed=NumberRange.new(0.5,1.5)         sparks.Transparency=NumberSequence.new(0,1)         sparks.Color=ColorSequence.new(color)         sparks.Parent=orb         local sparkle=Instance.new("ParticleEmitter")         sparkle.Texture="rbxassetid://10849912115"sparkle.Size=NumberSequence.new(0.06,0)         sparkle.Lifetime=NumberRange.new(0.5,1.2)         sparkle.Rate=8         sparkle.Speed=NumberRange.new(0.3,0.8)         sparkle.Transparency=NumberSequence.new(0.2,1)         sparkle.Color=ColorSequence.new(Color3.fromRGB(255,255,255))         sparkle.LightEmission=1         sparkle.LightInfluence=0         sparkle.Parent=orb         table.insert(sparkleEmitters,sparkle)         return orb,trail,glowImage     end     local function triggerPulse(rootPart,startColor,endColor)         local spherePulse=Instance.new("Part")         spherePulse.Shape=Enum.PartType.Ball spherePulse.Material=Enum.Material.Neon spherePulse.Color=startColor spherePulse.Size=Vector3.new(0.1,0.1,0.1)         spherePulse.Transparency=1         spherePulse.Anchored=false         spherePulse.CanCollide=false         spherePulse.CanTouch=false         spherePulse.CanQuery=false         spherePulse.CastShadow=false         spherePulse.Parent=auraContainer         local weld=Instance.new("Weld")         weld.Part0=rootPart weld.Part1=spherePulse weld.Parent=spherePulse         local burstSparks=Instance.new("ParticleEmitter")         burstSparks.Texture="rbxassetid://5813005513"burstSparks.Color=ColorSequence.new(startColor)         burstSparks.Size=NumberSequence.new(0.3,0)         burstSparks.Speed=NumberRange.new(12,22)         burstSparks.SpreadAngle=Vector2.new(-180,180)         burstSparks.Lifetime=NumberRange.new(0.4,0.8)         burstSparks.Transparency=NumberSequence.new(0,1)         burstSparks.Rate=0         burstSparks.Parent=rootPart burstSparks:Emit(35)         task.delay(1.2,function()burstSparks:Destroy()         end)         local burstGlow=Instance.new("ParticleEmitter")         burstGlow.Texture="rbxassetid://10849912115"burstGlow.Color=ColorSequence.new(startColor)         burstGlow.Size=NumberSequence.new(0.5,0)         burstGlow.Speed=NumberRange.new(4,8)         burstGlow.SpreadAngle=Vector2.new(-180,180)         burstGlow.Lifetime=NumberRange.new(0.3,0.5)         burstGlow.Transparency=NumberSequence.new(0.3,1)         burstGlow.LightEmission=1         burstGlow.LightInfluence=0         burstGlow.Rate=0         burstGlow.Parent=rootPart burstGlow:Emit(20)         task.delay(1.0,function()burstGlow:Destroy()         end)         local infoIn=TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)         local tweenIn=TweenService:Create(spherePulse,infoIn,{Size=Vector3.new(CONFIG.MaxSize*0.3,CONFIG.MaxSize*0.3,CONFIG.MaxSize*0.3),Transparency=0.35})         local infoOut=TweenInfo.new(CONFIG.ExpansionTime-0.18,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out)         local tweenOut=TweenService:Create(spherePulse,infoOut,{Size=Vector3.new(CONFIG.MaxSize,CONFIG.MaxSize,CONFIG.MaxSize),Transparency=1,Color=endColor})         if bodyHighlight then                 bodyHighlight.FillColor=startColor bodyHighlight.OutlineColor=startColor TweenService:Create(bodyHighlight,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{FillTransparency=0.45,OutlineTransparency=0.08}):Play()                     task.delay(0.18,function()                 if bodyHighlight and bodyHighlight.Parent then                      TweenService:Create(bodyHighlight,TweenInfo.new(CONFIG.ExpansionTime-0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{FillTransparency=0.94,OutlineTransparency=0.65}):Play()                 end             end)         end         if ambientLight then                 TweenService:Create(ambientLight,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Color=startColor,Brightness=4.5,Range=20}):Play()                     task.delay(0.18,function()                 if ambientLight and ambientLight.Parent then                      TweenService:Create(ambientLight,TweenInfo.new(CONFIG.ExpansionTime-0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Brightness=1.5,Range=12}):Play()                 end             end)         end             tweenIn:Play()             task.spawn(function()tweenIn.Completed:Wait()             if spherePulse.Parent then                  tweenOut:Play()tweenOut.Completed:Wait()spherePulse:Destroy()             end     end)     return spherePulse     end     local function cleanupAura()         if orbitConnection then              orbitConnection:Disconnect()         end         if pulseThread then              task.cancel(pulseThread)         end         if bodyHighlight and bodyHighlight.Parent then              bodyHighlight:Destroy()         end         if baseEmitter and baseEmitter.Parent then              baseEmitter:Destroy()         end         if ambientLight and ambientLight.Parent then              ambientLight:Destroy()         end         for _,se in ipairs(sparkleEmitters)do              pcall(function()se:Destroy()end)         end         sparkleEmitters={}         if auraContainer and auraContainer.Parent then              auraContainer:Destroy()         end             auraContainer=nil             bodyHighlight=nil             ambientLight=nil             baseEmitter=nil             purpleOrb=nil             purpleTrail=nil             purpleGlow=nil             blueOrb=nil             blueTrail=nil             blueGlow=nil             springPurple=nil             springBlue=nil             activePulsePart=nil             angle=0             firstFrame=true             pulseCounter=0             currentLTM=0     end     local function onCharacterAdded(char)         if not running then              return          end          cleanupAura()         local rootPart=char:WaitForChild("HumanoidRootPart",5)         if not rootPart then              return          end             auraContainer=Instance.new("Folder")             auraContainer.Name="AuraPulseV35_Container"auraContainer.Parent=Workspace bodyHighlight=Instance.new("Highlight")             bodyHighlight.Adornee=char bodyHighlight.FillColor=CONFIG.ColorPurple bodyHighlight.OutlineColor=CONFIG.ColorPurple bodyHighlight.FillTransparency=0.96             bodyHighlight.OutlineTransparency=0.7             bodyHighlight.Parent=auraContainer purpleOrb,purpleTrail,purpleGlow=createCometOrb(CONFIG.ColorPurple)blueOrb,blueTrail,blueGlow=createCometOrb(CONFIG.ColorBlue)             springPurple=createVector3Spring(CONFIG.SpringMass,CONFIG.SpringDamping,CONFIG.SpringStiffness)             springBlue=createVector3Spring(CONFIG.SpringMass,CONFIG.SpringDamping,CONFIG.SpringStiffness)             baseEmitter=Instance.new("ParticleEmitter")             baseEmitter.Name="InteractiveAura"baseEmitter.Texture="rbxassetid://10849912115"baseEmitter.Color=ColorSequence.new(CONFIG.ColorPurple)             baseEmitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(0.5,1.2),NumberSequenceKeypoint.new(1,0)})                 baseEmitter.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.15,0.4),NumberSequenceKeypoint.new(0.8,0.4),NumberSequenceKeypoint.new(1,1)})                     baseEmitter.Lifetime=NumberRange.new(0.8,1.4)                     baseEmitter.EmissionDirection=Enum.NormalId.Top baseEmitter.Parent=rootPart ambientLight=Instance.new("PointLight")                     ambientLight.Color=CONFIG.ColorPurple ambientLight.Range=10                     ambientLight.Brightness=1.2                     ambientLight.Parent=rootPart angle=0                     firstFrame=true                     currentLTM=0                     orbitConnection=RunService.Heartbeat:Connect(function(dt)
                          if not char.Parent or not rootPart.Parent then                     orbitConnection:Disconnect()                     return             end             if not running then                  return              end              angle=angle+dt*CONFIG.OrbitSpeed              local rootPos=rootPart.Position              local firstPersonActive=isFirstPerson(char)             local breathingSize=CONFIG.OrbBaseSize+math.sin(angle*3)*0.12             purpleOrb.Size=Vector3.new(breathingSize,breathingSize,breathingSize)             blueOrb.Size=Vector3.new(breathingSize,breathingSize,breathingSize)             local trailWidthMod=0.6+math.sin(angle*3)*0.4             purpleTrail.WidthScale=NumberSequence.new({NumberSequenceKeypoint.new(0,trailWidthMod),NumberSequenceKeypoint.new(1,0)})                 blueTrail.WidthScale=NumberSequence.new({NumberSequenceKeypoint.new(0,trailWidthMod),NumberSequenceKeypoint.new(1,0)})             local targetLTM=firstPersonActive and 1 or 0             currentLTM=currentLTM+(targetLTM-currentLTM)*0.2             purpleOrb.LocalTransparencyModifier=currentLTM blueOrb.LocalTransparencyModifier=currentLTM purpleGlow.ImageTransparency=currentLTM blueGlow.ImageTransparency=currentLTM             if firstPersonActive then                     bodyHighlight.Enabled=false                     baseEmitter.Enabled=false                 if activePulsePart and activePulsePart.Parent then                      activePulsePart.LocalTransparencyModifier=1                  end             else                     bodyHighlight.Enabled=true                     baseEmitter.Enabled=true                 if activePulsePart and activePulsePart.Parent then                      activePulsePart.LocalTransparencyModifier=0                  end             end             local px=math.cos(angle)*CONFIG.OrbitRadius              local pz=math.sin(angle)*CONFIG.OrbitRadius              local py=math.sin(angle*2)*0.5              local bx=math.cos(angle+math.pi)*CONFIG.OrbitRadius              local bz=math.sin(angle+math.pi)*CONFIG.OrbitRadius              local by=math.sin((angle+math.pi)*2)*0.5              local targetP1=rootPos+Vector3.new(px,py,pz)             local targetP2=rootPos+Vector3.new(bx,by,bz)             if firstFrame then                  springPurple.x=targetP1 springBlue.x=targetP2 purpleOrb.Position=targetP1 blueOrb.Position=targetP2 firstFrame=false              else                  springPurple.target=targetP1 springBlue.target=targetP2                  local clampedDt=math.min(dt,0.1)                 purpleOrb.Position=springPurple:update(clampedDt)                 blueOrb.Position=springBlue:update(clampedDt)             end             local velocity=rootPart.AssemblyLinearVelocity.Magnitude              if velocity>3 then                     baseEmitter.Rate=40                     baseEmitter.Speed=NumberRange.new(4,9)                     baseEmitter.VelocityInheritance=0.25             else                     baseEmitter.Rate=12                     baseEmitter.Speed=NumberRange.new(1.5,3)                     baseEmitter.VelocityInheritance=0             end     end)     pulseThread=task.spawn(function()             while char.Parent and rootPart.Parent and running do                 local nextStartColor,nextEndColor=getNextColor()                 baseEmitter.Color=ColorSequence.new(nextStartColor)                 activePulsePart=triggerPulse(rootPart,nextStartColor,nextEndColor)                 task.wait(CONFIG.PulseInterval)             end         end)     end     local function enable()         if running then              return          end          running=true          if LocalPlayer.Character then              onCharacterAdded(LocalPlayer.Character)         end          charConn=LocalPlayer.CharacterAdded:Connect(onCharacterAdded)     end     local function disable()     running=false         if charConn then              charConn:Disconnect()         end          cleanupAura()     end      _G.PortalVisuals._enableFuncs[name]=enable _G.PortalVisuals._disableFuncs[name]=disable  end

-- [[ Night Mode ]]
do     local name="Night Mode"local saved={}     local atmosphere      local function enable()     saved.Ambient=Lighting.Ambient saved.Brightness=Lighting.Brightness saved.OutdoorAmbient=Lighting.OutdoorAmbient saved.ClockTime=Lighting.ClockTime saved.FogColor=Lighting.FogColor saved.FogEnd=Lighting.FogEnd saved.ColorShift_Top=Lighting.ColorShift_Top saved.ColorShift_Bottom=Lighting.ColorShift_Bottom saved.GlobalShadows=Lighting.GlobalShadows Lighting.Ambient=Color3.new(0.3,0.3,0.4)     Lighting.Brightness=1.2     Lighting.OutdoorAmbient=Color3.new(0.3,0.3,0.4)     Lighting.ClockTime=0     Lighting.FogColor=Color3.new(0.2,0.2,0.3)     Lighting.FogEnd=1000     Lighting.ColorShift_Top=Color3.new(0.3,0.3,0.5)     Lighting.ColorShift_Bottom=Color3.new(0.1,0.1,0.2)     Lighting.GlobalShadows=true         if not atmosphere then                 atmosphere=Instance.new("Atmosphere")                 atmosphere.Parent=Lighting         end             atmosphere.Density=0.2             atmosphere.Offset=0.4             atmosphere.Color=Color3.new(0.2,0.2,0.3)             atmosphere.Decay=Color3.new(0.4,0.4,0.6)             atmosphere.Glare=0.1     end     local function disable()         if not saved.Ambient then              return          end          Lighting.Ambient=saved.Ambient Lighting.Brightness=saved.Brightness Lighting.OutdoorAmbient=saved.OutdoorAmbient Lighting.ClockTime=saved.ClockTime Lighting.FogColor=saved.FogColor Lighting.FogEnd=saved.FogEnd Lighting.ColorShift_Top=saved.ColorShift_Top Lighting.ColorShift_Bottom=saved.ColorShift_Bottom Lighting.GlobalShadows=saved.GlobalShadows          if atmosphere then                 atmosphere:Destroy()                 atmosphere=nil         end     end      _G.PortalVisuals._enableFuncs[name]=enable _G.PortalVisuals._disableFuncs[name]=disable  end

-- [[ ESP Chams ]]
do     local name="ESP Chams"local running=false      local heartbeatConn,playerAddedConn      local a=string.char      local b=Players      local c=RunService      local d=game:GetService(a(83,116,97,114,116,101,114,71,117,105))     local e=UserInputService      local f=LocalPlayer      local g=true      local h=true      local i=Color3.fromRGB(0,0,255)     local j=Color3.fromRGB(255,0,0)     local nameMode="displayname"local function k(l,m,n)d:SetCore(a(83,101,110,100,78,111,116,105,102,105,99,97,116,105,111,110),{Title=l,Text=m,Duration=n or 3})     end     local function o(p)     return h and p.TeamColor.Color or((f.TeamColor==p.TeamColor)and i or j)     end     local function q(r,s)         if not r:IsDescendantOf(Workspace)then              return          end         local t=r:FindFirstChild(a(71,101,116,82,101,97,108))         if not t then                 t=Instance.new(a(72,105,103,104,108,105,103,104,116))                 t.Name=a(71,101,116,82,101,97,108)                 t.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop t.Parent=r                 t.FillTransparency=0.7                 t.OutlineTransparency=0.4         end          t.FillColor=s t.OutlineColor=s t.Enabled=g      end     local function u(v)         local w=v.Character          if not w then              return          end         local x=w:FindFirstChild(a(72,117,109,97,110,111,105,100,82,111,111,116,80,97,114,116))or w:FindFirstChild(a(84,111,114,115,111))or w:FindFirstChild(a(85,112,112,101,114,84,111,114,115,111))         if not x then              return          end         local y=x:FindFirstChild(a(66,111,120,69,83,80))         if not y then                 y=Instance.new(a(66,111,120,72,97,110,100,108,101,65,100,111,114,110,109,101,110,116))                 y.Name=a(66,111,120,69,83,80)                 y.Size=Vector3.new(2,3,2)                 y.Adornee=x y.AlwaysOnTop=true                 y.ZIndex=5                 y.Transparency=0.5                 y.Parent=x         end             y.Color3=o(v)             y.Visible=g     end     local function z(v)         local w=v.Character          if not w or not w:FindFirstChild(a(72,101,97,100))then              return          end         local A=w.Head          local B=A:FindFirstChild(a(78,97,109,101,69,83,80))         if not B then                 B=Instance.new(a(66,105,108,108,98,111,97,114,100,71,117,105))                 B.Name=a(78,97,109,101,69,83,80)                 B.Size=UDim2.new(0,200,0,65)                 B.AlwaysOnTop=true             local C=Instance.new(a(84,101,120,116,76,97,98,101,108))             C.Name=a(78,97,109,101,76,97,98,101,108)             C.BackgroundTransparency=1             C.Size=UDim2.new(1,0,0.7,0)             C.Font=Enum.Font.SourceSansBold C.TextSize=16             C.TextStrokeTransparency=0.5             C.Parent=B             B.Parent=A         end         local C=B:FindFirstChild(a(78,97,109,101,76,97,98,101,108))         if C then             local nameText=v.DisplayName              if nameMode=="username"then                  nameText=v.Name              elseif nameMode=="both"then                  nameText=string.format("%s (%s)",v.DisplayName,v.Name)             end              C.Text=nameText               C.TextColor3=o(v)         end     end     local function E()         for _,G in ipairs(b:GetPlayers())do             if G~=f and G.Character then                     q(G.Character,o(G))                     z(G)                     u(G)             end         end     end     local function removeESPFromPlayer(p)         if not p.Character then              return          end         local char=p.Character          local highlight=char:FindFirstChild(a(71,101,116,82,101,97,108))         if highlight then              highlight:Destroy()         end         local head=char:FindFirstChild(a(72,101,97,100))         if head then             local nameESP=head:FindFirstChild(a(78,97,109,101,69,83,80))             if nameESP then                  nameESP:Destroy()             end         end         local root=char:FindFirstChild(a(72,117,109,97,110,111,105,100,82,111,111,116,80,97,114,116))or char:FindFirstChild(a(84,111,114,115,111))or char:FindFirstChild(a(85,112,112,101,114,84,111,114,115,111))         if root then             local box=root:FindFirstChild(a(66,111,120,69,83,80))             if box then                  box:Destroy()             end         end     end     local function onPlayerAdded(p)         if p==f then              return          end          p.CharacterAdded:Connect(function(char)             if not running then                  return              end         end)     end     local function enable()         if running then              return          end             running=true             g=true         for _,p in ipairs(b:GetPlayers())do             if p~=f and p.Character then                     q(p.Character,o(p))                     z(p)                     u(p)             end         end             playerAddedConn=b.PlayerAdded:Connect(onPlayerAdded)             heartbeatConn=c.Heartbeat:Connect(function()
                if StepEffect("ESPChams", 1/12) then E() end
            end)             k(a(83,121,115,116,101,109,32,78,111,116,105,102,105,99,97,116,105,111,110),a(69,83,80,32,119,105,116,104,32,67,104,97,109,115,32,101,110,97,98,108,101,100),3)     end     local function disable()         if not running then              return          end             running=false             g=false         if heartbeatConn then              heartbeatConn:Disconnect()         end         if playerAddedConn then              playerAddedConn:Disconnect()         end         for _,p in ipairs(b:GetPlayers())do             if p~=f then                  removeESPFromPlayer(p)             end         end          k(a(83,121,115,116,101,109,32,78,111,116,105,102,105,99,97,116,105,111,110),a(69,83,80,32,100,105,115,97,98,108,101,100),2)     end      _G.PortalVisuals._enableFuncs[name]=enable _G.PortalVisuals._disableFuncs[name]=disable  end

-- [[ Neon Trail ]]
do     local name="Neon Trail"local running=false      local trailUpdateConn      local lastPositions={}     local bufferIndex=1      local maxTrailLength=20      local updateRate=0.05      local lastUpdate=0      local function createTrailPart(pos,color)         local part=Instance.new("Part")         local sz=0.5+math.random()*0.4         part.Name="NeonTrail"part.Size=Vector3.new(sz,sz,sz)         part.Shape=Enum.PartType.Ball part.CFrame=CFrame.new(pos)         part.Anchored=true         part.CanCollide=false         part.Material=Enum.Material.Neon part.Color=color part.Transparency=0.15         part.Parent=Workspace         local sparkle=Instance.new("ParticleEmitter")         sparkle.Texture="rbxassetid://10849912115"sparkle.Size=NumberSequence.new(0.04,0)         sparkle.Lifetime=NumberRange.new(0.3,0.6)         sparkle.Rate=5         sparkle.Speed=NumberRange.new(0.2,0.5)         sparkle.Transparency=NumberSequence.new(0.3,1)         sparkle.Color=ColorSequence.new(color)         sparkle.LightEmission=1         sparkle.LightInfluence=0         sparkle.Parent=part         local tween=TweenService:Create(part,TweenInfo.new(1.8),{Transparency=1,Size=Vector3.new(0,0,0)})tween:Play()         tween.Completed:Connect(function()part:Destroy()         end)     end     local function updateTrail()         if not running then              return          end         local char=LocalPlayer.Character          if not char then              return          end         local root=PortalGetRoot(char)         if not root then              return          end         local now=tick()         if now-lastUpdate<updateRate then              return          end          lastUpdate=now          local currentPos=root.Position          local currentColor=Color3.fromHSV((now%3)/3,1,1)lastPositions[bufferIndex]={pos=currentPos,color=currentColor}             bufferIndex=bufferIndex+1         if bufferIndex>maxTrailLength then              bufferIndex=1          end         for i=1,3 do             local idx=bufferIndex-i-1              if idx<1 then                  idx=maxTrailLength+idx              end             if lastPositions[idx]then                  createTrailPart(lastPositions[idx].pos,lastPositions[idx].color)             end         end     end     local function enable()         if running then              return          end             running=true             lastPositions={}                 bufferIndex=1                 lastUpdate=tick()                 trailUpdateConn=RunService.Heartbeat:Connect(function(dt)
            if StepEffect("NeonTrail", 1/60) then updateTrail(dt) end
        end)     end     local function disable()     running=false         if trailUpdateConn then              trailUpdateConn:Disconnect()         end     end      _G.PortalVisuals._enableFuncs[name]=enable _G.PortalVisuals._disableFuncs[name]=disable  end

-- [[ Orbit ]]
do     local name="Orbit"local running=false      local heartbeatConn      local spheres={}     local RADIUS=10      local SPEED=3      local COUNT=6      local BALL_SIZE=1      local SMOOTHNESS=0.15      local function createOrbits()         local char=LocalPlayer.Character          if not char then              return          end         for _,s in pairs(spheres)do              s:Destroy()         end          spheres={}         for i=1,COUNT do             local p=Instance.new("Part")             p.Size=Vector3.new(BALL_SIZE,BALL_SIZE,BALL_SIZE)             p.Shape=Enum.PartType.Ball p.Material=Enum.Material.Neon p.Color=Color3.fromRGB(0,255,255)             p.Anchored=true             p.CanCollide=false             p.Parent=Workspace             local a0=Instance.new("Attachment",p)             a0.Position=Vector3.new(0,0.5,0)             local a1=Instance.new("Attachment",p)             a1.Position=Vector3.new(0,-0.5,0)             local trail=Instance.new("Trail")             trail.Attachment0=a0 trail.Attachment1=a1 trail.Lifetime=0.6             trail.Color=ColorSequence.new(Color3.fromRGB(0,255,255),Color3.fromRGB(170,0,255))             trail.Transparency=NumberSequence.new(0.1,0.8)             trail.WidthScale=NumberSequence.new(1.2,0)             trail.LightEmission=0.8             trail.Parent=p             local glow=Instance.new("PointLight")             glow.Color=Color3.fromRGB(0,200,255)glow.Brightness=1.5 glow.Range=6 glow.Shadows=false             glow.Parent=p             local dust=Instance.new("ParticleEmitter")             dust.Texture="rbxassetid://10849912115"dust.Size=NumberSequence.new(0.05,0)             dust.Lifetime=NumberRange.new(0.4,0.8)             dust.Rate=6             dust.Speed=NumberRange.new(0.1,0.3)             dust.Transparency=NumberSequence.new(0.2,1)             dust.Color=ColorSequence.new(Color3.fromRGB(0,255,255))             dust.LightEmission=1             dust.LightInfluence=0             dust.Parent=p             table.insert(spheres,p)         end     end     local function updateOrbits()         if not running then              return          end         local char=LocalPlayer.Character          local root=char and PortalGetRoot(char)         if not root then              return          end         if#spheres==0 then              createOrbits()         end         local t=tick()         for i,p in ipairs(spheres)do             local angle=(t*SPEED)+(i*(math.pi*2/COUNT))             local offset=Vector3.new(math.cos(angle)*RADIUS,math.sin(t*2+i)*1.5+2,math.sin(angle)*RADIUS)             local goalPos=root.Position+offset p.Position=p.Position:Lerp(goalPos,SMOOTHNESS)             local hue=(t*0.08+i/COUNT)%1             p.Color=Color3.fromHSV(hue,0.9,1)             local glow=p:FindFirstChildOfClass("PointLight")             if glow then                 glow.Color=Color3.fromHSV(hue,0.8,1)             end             local dust=p:FindFirstChildOfClass("ParticleEmitter")             if dust then                 dust.Color=ColorSequence.new(Color3.fromHSV(hue,0.9,1))             end         end     end     local function enable()         if running then              return          end             running=true createOrbits()             heartbeatConn=RunService.Heartbeat:Connect(function(dt)
            if StepEffect("Orbit", 1/60) then updateOrbits(dt) end
        end)     end     local function disable()     running=false         if heartbeatConn then              heartbeatConn:Disconnect()         end         for _,s in pairs(spheres)do              s:Destroy()         end          spheres={}     end      _G.PortalVisuals._enableFuncs[name]=enable _G.PortalVisuals._disableFuncs[name]=disable  end

-- [[ Paradox Engine ]]
do     local name="Paradox Engine"local running=false      local heartbeatConn      local particles={}     local particleData={}     local PARTICLE_COUNT=40      local RADIUS=6      local SMOOTHNESS=0.12      local function createGravityWell()         local char=LocalPlayer.Character          if not char then              return          end         for _,p in pairs(particles)do              p:Destroy()         end             particles={}                 particleData={}         for i=1,PARTICLE_COUNT do             local p=Instance.new("Part")             p.Size=Vector3.new(0.3+math.random()*0.2,0.3+math.random()*0.2,0.3+math.random()*0.2)             p.Shape=Enum.PartType.Ball p.Material=Enum.Material.Neon p.Color=Color3.fromRGB(0,255,255)             p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=false             p.Parent=Workspace             local a0=Instance.new("Attachment",p)             a0.Position=Vector3.new(0,0.2,0)             local a1=Instance.new("Attachment",p)             a1.Position=Vector3.new(0,-0.2,0)             local trail=Instance.new("Trail")             trail.Attachment0=a0 trail.Attachment1=a1 trail.Lifetime=0.4             trail.Transparency=NumberSequence.new(0.3,0.9)             trail.WidthScale=NumberSequence.new(1.2,0)             trail.Color=ColorSequence.new(Color3.fromRGB(0,255,255),Color3.fromRGB(170,0,255))             trail.Parent=p             table.insert(particles,p)particleData[i]={Type=math.random(1,3),Speed=math.random(15,25)/10,Offset=i*(math.pi*2/PARTICLE_COUNT),SizeOffset=math.random()*0.5}         end     end     local function updateGravityWell()         if not running then              return          end         local char=LocalPlayer.Character          local root=char and PortalGetRoot(char)         if not root then              return          end         if#particles==0 then              createGravityWell()         end         local t=tick()         for i,p in ipairs(particles)do             local data=particleData[i]             local mt=t*data.Speed+data.Offset              local targetPos              if data.Type==1 then                  targetPos=Vector3.new(math.sin(mt)*RADIUS,math.cos(mt*0.5)*2+math.sin(t*1.5+i)*0.3,math.cos(mt)*RADIUS)             elseif data.Type==2 then                  targetPos=Vector3.new(math.sin(mt)*2+math.cos(t*0.7+i)*0.5,math.sin(mt)*RADIUS,math.cos(mt)*RADIUS)             else                  targetPos=Vector3.new(math.cos(mt)*RADIUS,math.sin(mt)*(RADIUS/2)+math.sin(t*1.2+i)*0.5,math.sin(mt)*RADIUS)             end             local finalTarget=root.Position+targetPos+Vector3.new(0,1,0)             p.Position=p.Position:Lerp(finalTarget,SMOOTHNESS)             p.Color=Color3.fromHSV((t*0.08+i/PARTICLE_COUNT)%1,0.8,1)         end     end     local function enable()         if running then              return          end             running=true createGravityWell()             heartbeatConn=RunService.Heartbeat:Connect(function(dt)
            if StepEffect("ParadoxEngine", 1/60) then updateGravityWell(dt) end
        end)     end     local function disable()     running=false         if heartbeatConn then              heartbeatConn:Disconnect()         end         for _,p in pairs(particles)do              p:Destroy()         end             particles={}                 particleData={}     end      _G.PortalVisuals._enableFuncs[name]=enable _G.PortalVisuals._disableFuncs[name]=disable  end

-- [[ Atmospheric Fog ]]
do     local name="Atmospheric Fog"local running=false      local saved={}     local atmosphere      local function enable()         if running then              return          end             running=true             saved.FogColor=Lighting.FogColor saved.FogStart=Lighting.FogStart saved.FogEnd=Lighting.FogEnd saved.Atmosphere=Lighting:FindFirstChildOfClass("Atmosphere")         for _,obj in pairs(Lighting:GetChildren())do             if obj.Name=="PortalAura"and obj:IsA("Atmosphere")then                  obj:Destroy()             end         end             atmosphere=Instance.new("Atmosphere",Lighting)             atmosphere.Name="PortalAura"atmosphere.Color=Color3.fromRGB(185,195,210)             atmosphere.Decay=Color3.fromRGB(170,175,185)             atmosphere.Density=0.42             atmosphere.Haze=3.5             atmosphere.Glare=0.5             atmosphere.Offset=0             Lighting.FogColor=Color3.fromRGB(185,195,210)             Lighting.FogStart=50             Lighting.FogEnd=900     end     local function disable()         if not running then              return          end             running=false             Lighting.FogColor=saved.FogColor Lighting.FogStart=saved.FogStart Lighting.FogEnd=saved.FogEnd         if atmosphere then                 atmosphere:Destroy()                 atmosphere=nil         end     end      _G.PortalVisuals._enableFuncs[name]=enable _G.PortalVisuals._disableFuncs[name]=disable  end

-- V22: camera-centred helper shared by every map/atmosphere effect.
function Yuki_CameraCenter(lookAhead)
    local cam = Workspace.CurrentCamera
    local character = LocalPlayer.Character
    local root = character and PortalGetRoot(character)
    local camPos = cam and cam.CFrame.Position or (root and root.Position) or Vector3.zero
    local look = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
    look = Vector3.new(look.X, 0, look.Z)
    look = look.Magnitude > 0.05 and look.Unit or Vector3.zero
    local y = root and root.Position.Y or camPos.Y
    return Vector3.new(camPos.X, y, camPos.Z) + look * (lookAhead or 0)
end

-- [[ Rain ]]
do
    local name = "Rain"
    local running = false
    local heartbeatConn = nil
    local rainContainer = nil
    local emitterPart = nil
    local rainEmitter = nil
    local splashAnchor = nil
    local splashEmitter = nil
    local rainDrops = {}
    local rainFloorY = nil
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local savedFogColor, savedFogStart, savedFogEnd, savedAtmo = nil, nil, nil, nil

    local CONFIG = {
        RAIN_COUNT = 210,
        RAIN_RADIUS = 45,
        RAIN_HEIGHT = 35,
        FALL_SPEED = 82,
        WIND_X = 2.5,
        SPEED_VARIANCE = 12,
        SPLASH_COOLDOWN = 0.10
    }

    _G.PortalVisuals._rainConfig = CONFIG

    local function applyRainAppearance()
        if not rainEmitter then
            return
        end

        local rate = math.clamp(
            math.floor(CONFIG.RAIN_COUNT * (CONFIG.RAIN_RADIUS / 45)^1.12),
            110,
            420
        )

        rainEmitter.Rate = rate
        rainEmitter.Speed = NumberRange.new(
            math.max(50, CONFIG.FALL_SPEED - CONFIG.SPEED_VARIANCE),
            CONFIG.FALL_SPEED + CONFIG.SPEED_VARIANCE
        )
        rainEmitter.SpreadAngle = Vector2.new(4, 4)
        rainEmitter.LockedToPart = true
        rainEmitter.Orientation = Enum.ParticleOrientation.VelocityParallel
        rainEmitter.Shape = Enum.ParticleEmitterShape.Disc
        rainEmitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
        rainEmitter.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
        -- ShapeSize is not a Roblox ParticleEmitter property. The disc size is
        -- defined by emitterPart.Size above; assigning ShapeSize aborts initRain().
    end

    local function setupAtmosphere()
        savedFogColor = Lighting.FogColor
        savedFogStart = Lighting.FogStart
        savedFogEnd = Lighting.FogEnd

        Lighting.FogColor = Color3.fromRGB(150, 150, 155)
        Lighting.FogStart = 0
        Lighting.FogEnd = 240

        local exAtmo = Lighting:FindFirstChildOfClass("Atmosphere")
        if exAtmo then
            savedAtmo = {
                Ref = exAtmo,
                Color = exAtmo.Color,
                Density = exAtmo.Density,
                Decay = exAtmo.Decay,
                Haze = exAtmo.Haze,
                Glare = exAtmo.Glare
            }
        else
            savedAtmo = "created"
        end

        local atm = exAtmo or Instance.new("Atmosphere")
        atm.Name = exAtmo and exAtmo.Name or "RainAtmosphere"
        atm.Parent = Lighting
        atm.Density = 0.18
        atm.Color = Color3.fromRGB(170, 175, 185)
        atm.Decay = Color3.fromRGB(150, 155, 165)
        atm.Haze = 1.6
        atm.Glare = 0
    end

    local function cleanupAtmosphere()
        if savedFogColor then
            Lighting.FogColor = savedFogColor
            Lighting.FogStart = savedFogStart
            Lighting.FogEnd = savedFogEnd
            savedFogColor = nil
        end

        if savedAtmo then
            local saved = savedAtmo
            local atm = saved.Ref
            if saved == "created" then
                local current = Lighting:FindFirstChild("RainAtmosphere")
                if current and current:IsA("Atmosphere") then
                    current:Destroy()
                end
            elseif atm and atm.Parent then
                atm.Color = saved.Color
                atm.Density = saved.Density
                atm.Decay = saved.Decay
                atm.Haze = saved.Haze
                atm.Glare = saved.Glare
            end
            savedAtmo = nil
        end
    end

    local function pulseSplash(hitPosition)
        if not splashEmitter or not splashAnchor then
            return
        end

        splashAnchor.Position = hitPosition + Vector3.new(0, 0.04, 0)
        splashEmitter:Emit(3)
    end

    local function rainLook()
        local cam = Workspace.CurrentCamera
        if not cam then return nil end
        local l = cam.CFrame.LookVector
        l = Vector3.new(l.X, 0, l.Z)
        return l.Magnitude > 0.05 and l.Unit or nil
    end

    local function rainSpawnPos(center)
        local look = rainLook()
        local angle
        if look and math.random() < 0.6 then
            angle = math.atan2(look.Z, look.X) + (math.random() - 0.5) * math.pi * 1.5
        else
            angle = math.random() * math.pi * 2
        end
        local r = math.sqrt(math.random()) * CONFIG.RAIN_RADIUS
        local y = center.Y + CONFIG.RAIN_HEIGHT * (0.35 + math.random() * 0.65)
        if rainFloorY then
            y = math.max(y, rainFloorY + 8)
        end
        return Vector3.new(center.X + math.cos(angle) * r, y, center.Z + math.sin(angle) * r)
    end

    -- V22: plain thin semi-transparent streaks. No Trail objects: a Trail on a
    -- teleported part draws a huge beam across the screen (the old bug).
    local function newDrop(index, center)
        local length = 0.9 + math.random() * 0.8
        local p = Instance.new("Part")
        p.Name = "RainDrop_" .. index
        p.Size = Vector3.new(0.028, 0.028, length)
        p.Material = Enum.Material.SmoothPlastic
        p.Color = Color3.fromRGB(205, 222, 240)
        p.Transparency = 0.62 + math.random() * 0.22
        p.Anchored = true
        p.CanCollide = false
        p.CanTouch = false
        p.CanQuery = false
        p.CastShadow = false
        p.Parent = rainContainer

        local pos = rainSpawnPos(center)
        return {
            Part = p,
            Position = pos,
            Velocity = CONFIG.FALL_SPEED + math.random() * CONFIG.SPEED_VARIANCE,
            Wind = Vector3.new(CONFIG.WIND_X, 0, math.random(-10, 10) / 10),
        }
    end

    local function respawnDrop(drop, center)
        drop.Position = rainSpawnPos(center)
        drop.Velocity = CONFIG.FALL_SPEED + math.random() * CONFIG.SPEED_VARIANCE
        drop.Wind = Vector3.new(CONFIG.WIND_X, 0, math.random(-10, 10) / 10)
    end

    local function initRain()
        rainContainer = Instance.new("Folder")
        rainContainer.Name = "RainEffect_Optimized"
        rainContainer.Parent = Workspace

        emitterPart = Instance.new("Part")
        emitterPart.Name = "RainEmitter"
        -- ParticleEmitter uses its parent part's dimensions for the emission shape.
        -- Keep the disc wide enough to cover the configured rain radius.
        emitterPart.Size = Vector3.new(CONFIG.RAIN_RADIUS * 2, 1, CONFIG.RAIN_RADIUS * 2)
        emitterPart.Transparency = 1
        emitterPart.Anchored = true
        emitterPart.CanCollide = false
        emitterPart.CanTouch = false
        emitterPart.CanQuery = false
        emitterPart.CastShadow = false
        emitterPart.Parent = rainContainer

        rainEmitter = Instance.new("ParticleEmitter")
        rainEmitter.Name = "RainMist"
        rainEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
        rainEmitter.Enabled = false -- V22: star-shaped sparkles were the "spikes"
        rainEmitter.LightEmission = 0
        rainEmitter.LightInfluence = 0
        rainEmitter.Lifetime = NumberRange.new(0.28, 0.45)
        rainEmitter.Size = NumberSequence.new(0.05)
        rainEmitter.Transparency = NumberSequence.new(0.78, 1)
        rainEmitter.Color = ColorSequence.new(Color3.fromRGB(190, 220, 255))
        rainEmitter.Acceleration = Vector3.new(0, -10, 0)
        rainEmitter.Drag = 0
        rainEmitter.Rotation = NumberRange.new(0, 0)
        rainEmitter.RotSpeed = NumberRange.new(0, 0)
        rainEmitter.Parent = emitterPart

        splashAnchor = Instance.new("Part")
        splashAnchor.Name = "RainSplashAnchor"
        splashAnchor.Size = Vector3.new(0.2, 0.2, 0.2)
        splashAnchor.Transparency = 1
        splashAnchor.Anchored = true
        splashAnchor.CanCollide = false
        splashAnchor.CanTouch = false
        splashAnchor.CanQuery = false
        splashAnchor.Parent = rainContainer

        splashEmitter = Instance.new("ParticleEmitter")
        splashEmitter.Name = "RainSplash"
        splashEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
        splashEmitter.Rate = 0
        splashEmitter.Lifetime = NumberRange.new(0.08, 0.18)
        splashEmitter.Speed = NumberRange.new(2, 4)
        splashEmitter.SpreadAngle = Vector2.new(180, 180)
        splashEmitter.Size = NumberSequence.new(0.07, 0.2)
        splashEmitter.Transparency = NumberSequence.new(0.55, 1)
        splashEmitter.Color = ColorSequence.new(Color3.fromRGB(185, 215, 255))
        splashEmitter.LightEmission = 0.1
        splashEmitter.LightInfluence = 0
        splashEmitter.Parent = splashAnchor

        rainDrops = {}
        local count = math.clamp(math.floor(CONFIG.RAIN_COUNT * 1.1), 180, 340)
        local character = LocalPlayer.Character
        local root = character and PortalGetRoot(character)
        local cam0 = Workspace.CurrentCamera
        local center = (cam0 and cam0.CFrame.Position) or (root and root.Position) or Vector3.zero

        for i = 1, count do
            rainDrops[i] = newDrop(i, center)
        end

        applyRainAppearance()
    end

    _G.PortalVisuals._rainSync = applyRainAppearance

    local function onHeartbeat(dt)
        if not running then
            return
        end
        dt = math.min(dt, 0.1)

        local character = LocalPlayer.Character
        local root = character and PortalGetRoot(character)
        local cam = Workspace.CurrentCamera
        -- V22: the whole rain volume follows the CAMERA.
        local center = (cam and cam.CFrame.Position) or (root and root.Position)
        if not center then
            return
        end

        if StepEffect("RainFloor", 0.25) then
            raycastParams.FilterDescendantsInstances = {rainContainer, character}
            local ref = root and root.Position or center
            local hit = Workspace:Raycast(ref + Vector3.new(0, 3, 0), Vector3.new(0, -400, 0), raycastParams)
            rainFloorY = hit and hit.Position.Y or (ref.Y - 4)
        end
        local floorY = rainFloorY or (center.Y - 4)

        if emitterPart then
            emitterPart.CFrame = CFrame.new(center + Vector3.new(0, CONFIG.RAIN_HEIGHT * 0.78, 0))
        end

        local radius = CONFIG.RAIN_RADIUS
        local limitSq = (radius * 1.2) ^ 2
        local topY = center.Y + CONFIG.RAIN_HEIGHT * 1.3
        local parts, cfs, n = {}, {}, 0
        for _, drop in ipairs(rainDrops) do
            local part = drop.Part
            if part and part.Parent then
                local pos = drop.Position + Vector3.new(drop.Wind.X * dt, -drop.Velocity * dt, drop.Wind.Z * dt)
                drop.Position = pos
                local dx, dz = pos.X - center.X, pos.Z - center.Z
                -- Behind-the-camera / fallen drops are recycled next to the camera.
                if pos.Y < floorY or dx * dx + dz * dz > limitSq or pos.Y > topY then
                    respawnDrop(drop, center)
                    pos = drop.Position
                end
                n += 1
                parts[n] = part
                cfs[n] = CFrame.lookAt(pos, pos + Vector3.new(drop.Wind.X, -drop.Velocity, drop.Wind.Z))
            end
        end
        if n > 0 then
            Workspace:BulkMoveTo(parts, cfs, Enum.BulkMoveMode.FireCFrameChanged)
        end

        if splashAnchor and StepEffect("RainRay", math.max(CONFIG.SPLASH_COOLDOWN, 0.08)) then
            raycastParams.FilterDescendantsInstances = {rainContainer, character}
            local a = math.random() * math.pi * 2
            local r = math.sqrt(math.random()) * math.min(radius * 0.7, 28)
            local start = Vector3.new(center.X + math.cos(a) * r, floorY + 15, center.Z + math.sin(a) * r)
            local hit = Workspace:Raycast(start, Vector3.new(0, -45, 0), raycastParams)
            if hit then
                pulseSplash(hit.Position)
            end
        end
    end

    local function enable()
        if running then
            return
        end
        running = true
        local ok, err = pcall(function()
            initRain()
            setupAtmosphere()
        end)
        if not ok then
            running = false
            if rainContainer then rainContainer:Destroy(); rainContainer = nil end
            emitterPart = nil
            rainEmitter = nil
            splashAnchor = nil
            splashEmitter = nil
            rainDrops = {}
            cleanupAtmosphere()
            warn("[Yuki Shader Engine] Rain setup failed: " .. tostring(err))
            return
        end
        heartbeatConn = RunService.Heartbeat:Connect(onHeartbeat)
    end

    local function disable()
        running = false
        if heartbeatConn then
            heartbeatConn:Disconnect()
            heartbeatConn = nil
        end
        if rainContainer then
            rainContainer:Destroy()
            rainContainer = nil
        end
        emitterPart = nil
        rainEmitter = nil
        splashAnchor = nil
        splashEmitter = nil
        rainDrops = {}
        cleanupAtmosphere()
    end

    _G.PortalVisuals._enableFuncs[name] = enable
    _G.PortalVisuals._disableFuncs[name] = disable
end

-- [[ Fireflies ]]
do     local name="Fireflies"     local running=false     local fireflies={}     local updateConnection=nil     local charAddedConn=nil     local folder=nil     local rootPart=nil     local CONFIG={Count=20,MinDist=24,MaxDist=33,MinH=-4,MaxH=15,MinSpeed=4,MaxSpeed=8,Wander=5,Follow=0.85,FollowSmooth=2.5,GlowColor=Color3.fromRGB(255,238,105),BodyColor=Color3.fromRGB(30,28,20),WingColor=Color3.fromRGB(205,225,215),}     local function part(parent,nm,sz,color,mat,trans)         local p=Instance.new("Part")         p.Name=nm p.Size=sz p.Color=color         p.Material=mat or Enum.Material.SmoothPlastic         p.Transparency=trans or 0 p.Anchored=true         p.CanCollide=false p.CanTouch=false p.CanQuery=false         p.CastShadow=false p.Parent=parent         return p     end     local function target()         local a=math.random()*math.pi*2         local d=CONFIG.MinDist+math.random()*(CONFIG.MaxDist-CONFIG.MinDist)         return rootPart.Position+Vector3.new(math.cos(a)*d,CONFIG.MinH+math.random()*(CONFIG.MaxH-CONFIG.MinH),math.sin(a)*d)     end     local function createFirefly(i)         local m=Instance.new("Model")         m.Name="Firefly_"..i m.Parent=folder         local body=part(m,"Body",Vector3.new(.18,.18,.42),CONFIG.BodyColor)         local segment=part(m,"Segment",Vector3.new(.17,.17,.20),Color3.fromRGB(18,18,14))         local head=part(m,"Head",Vector3.new(.17,.17,.17),Color3.fromRGB(10,10,8))         head.Shape=Enum.PartType.Ball         local eyes={part(m,"EyeL",Vector3.new(.045,.045,.045),Color3.fromRGB(130,85,35),Enum.Material.Neon),part(m,"EyeR",Vector3.new(.045,.045,.045),Color3.fromRGB(130,85,35),Enum.Material.Neon)}         for _,e in ipairs(eyes) do e.Shape=Enum.PartType.Ball end         local glow=part(m,"Glow",Vector3.new(.16,.16,.20),CONFIG.GlowColor,Enum.Material.Neon)         glow.Shape=Enum.PartType.Ball         local light=Instance.new("PointLight")         light.Color=CONFIG.GlowColor light.Brightness=1.8 light.Range=5 light.Shadows=false light.Parent=glow         local wings={part(m,"WingL1",Vector3.new(.40,.018,.17),CONFIG.WingColor,Enum.Material.Glass,.48),part(m,"WingR1",Vector3.new(.40,.018,.17),CONFIG.WingColor,Enum.Material.Glass,.48),part(m,"WingL2",Vector3.new(.30,.018,.13),Color3.fromRGB(220,235,225),Enum.Material.Glass,.58),part(m,"WingR2",Vector3.new(.30,.018,.13),Color3.fromRGB(220,235,225),Enum.Material.Glass,.58)}         local antenna={part(m,"AntennaL",Vector3.new(.015,.015,.20),Color3.fromRGB(30,30,25)),part(m,"AntennaR",Vector3.new(.015,.015,.20),Color3.fromRGB(30,30,25))}         local pos=target()         local goal=target()         local speed=CONFIG.MinSpeed+math.random()*(CONFIG.MaxSpeed-CONFIG.MinSpeed)         table.insert(fireflies,{Model=m,Body=body,Segment=segment,Head=head,Eyes=eyes,Glow=glow,Light=light,Wings=wings,Antenna=antenna,Position=pos,Target=goal,Velocity=(goal-pos).Unit*speed,FollowVelocity=Vector3.zero,Speed=speed,Offset=math.random()*1000,NX=math.random()*100,NY=math.random()*100,NZ=math.random()*100,NextTarget=os.clock()+math.random(1,4),WingSpeed=45+math.random()*20})     end     local function updateModel(f,cf,t)         f.Body.CFrame=cf*CFrame.new(0,0,.04)*CFrame.Angles(0,math.rad(90),0)         f.Segment.CFrame=cf*CFrame.new(0,0,.27)*CFrame.Angles(0,math.rad(90),0)         f.Head.CFrame=cf*CFrame.new(0,0,-.27)         f.Eyes[1].CFrame=cf*CFrame.new(-.07,.035,-.30)         f.Eyes[2].CFrame=cf*CFrame.new(.07,.035,-.30)         f.Glow.CFrame=cf*CFrame.new(0,0,.27)         local flap=math.sin(t*f.WingSpeed+f.Offset)         local fa=math.rad(17)*flap         local tilt=math.sin(t*2+f.Offset)*math.rad(3)         f.Wings[1].CFrame=cf*CFrame.new(-.20,.055,-.02)*CFrame.Angles(tilt,fa,math.rad(-8))         f.Wings[2].CFrame=cf*CFrame.new(.20,.055,-.02)*CFrame.Angles(tilt,-fa,math.rad(8))         f.Wings[3].CFrame=cf*CFrame.new(-.17,.075,.13)*CFrame.Angles(tilt,fa*.7,math.rad(-14))         f.Wings[4].CFrame=cf*CFrame.new(.17,.075,.13)*CFrame.Angles(tilt,-fa*.7,math.rad(14))         f.Antenna[1].CFrame=cf*CFrame.new(-.06,.07,-.37)*CFrame.Angles(math.rad(-20),math.rad(-15),math.rad(-12))         f.Antenna[2].CFrame=cf*CFrame.new(.06,.07,-.37)*CFrame.Angles(math.rad(-20),math.rad(15),math.rad(12))     end     local function cleanup()         if updateConnection then updateConnection:Disconnect() updateConnection=nil end         for _,f in ipairs(fireflies) do             if f.Model then f.Model:Destroy() end         end         table.clear(fireflies)         if folder then folder:Destroy() folder=nil end     end     local function initFireflies(character)         cleanup()         folder=Instance.new("Folder")         folder.Name="RealisticFireflies" folder.Parent=workspace         rootPart=character:WaitForChild("HumanoidRootPart",10)         if not rootPart then return end         for i=1,CONFIG.Count do createFirefly(i) end         updateConnection=RunService.RenderStepped:Connect(function(dt)             if not running then return end             if not rootPart or not rootPart.Parent then                 local newChar=LocalPlayer.Character                 if newChar then rootPart=newChar:FindFirstChild("HumanoidRootPart") end                 if not rootPart then return end             end             local t=os.clock()             local playerVelocity=Vector3.new(rootPart.AssemblyLinearVelocity.X,0,rootPart.AssemblyLinearVelocity.Z)             for _,f in ipairs(fireflies) do                 if t>=f.NextTarget or(f.Target-f.Position).Magnitude<2 then                     f.Target=target() f.NextTarget=t+1.2+math.random()*3.5                 end                 local wander=Vector3.new(math.noise(f.NX,t*.45),math.noise(f.NY,t*.35),math.noise(f.NZ,t*.40))*CONFIG.Wander                 local toTarget=f.Target-f.Position                 if toTarget.Magnitude>.1 then                     local desired=toTarget.Unit*f.Speed+wander                     f.Velocity=f.Velocity:Lerp(desired,math.clamp(dt*2.2,0,1))                 end                 local offset=f.Position-rootPart.Position                 local distance=offset.Magnitude                 if distance<CONFIG.MinDist then                     local dir=distance>.1 and offset.Unit or Vector3.new(1,0,0)                     f.Velocity=f.Velocity:Lerp(dir*f.Speed*2,math.clamp(dt*4,0,1))                 elseif distance>CONFIG.MaxDist+5 then                     local dir=rootPart.Position-f.Position                     if dir.Magnitude>.1 then                         f.Velocity=f.Velocity:Lerp(dir.Unit*f.Speed*2.5,math.clamp(dt*3,0,1))                     end                 end                 local desiredFollow=playerVelocity*CONFIG.Follow                 if desiredFollow.Magnitude>35 then desiredFollow=desiredFollow.Unit*35 end                 local alpha=1-math.exp(-CONFIG.FollowSmooth*dt)                 f.FollowVelocity=f.FollowVelocity:Lerp(desiredFollow,alpha)                 local micro=Vector3.new(math.sin(t*2.7+f.Offset),math.sin(t*2.15+f.Offset*1.7),math.cos(t*2.4+f.Offset))*.45                 f.Position+=(f.Velocity+f.FollowVelocity+micro)*dt                 local newOffset=f.Position-rootPart.Position                 if newOffset.Magnitude>CONFIG.MaxDist+12 then                     f.Position=rootPart.Position+newOffset.Unit*CONFIG.MaxDist                     f.Target=target()                 end                 local vel=f.Velocity+f.FollowVelocity                 if vel.Magnitude<.05 then vel=Vector3.new(0,0,-1) end                 local cf=CFrame.lookAt(f.Position,f.Position+vel.Unit)                 updateModel(f,cf,t)                 local pulse=(math.sin(t*(2.2+f.Speed*.08)+f.Offset)+1)/2                 f.Glow.Transparency=.05+(1-pulse)*.35                 f.Light.Brightness=.35+pulse*3.2                 f.Light.Range=3.5+pulse*4             end         end)     end     local function enable()         if running then return end         running=true         if LocalPlayer.Character then initFireflies(LocalPlayer.Character) end         if charAddedConn then charAddedConn:Disconnect() end         charAddedConn=LocalPlayer.CharacterAdded:Connect(function(char)             if running then initFireflies(char) end         end)     end     local function disable()         running=false         if charAddedConn then charAddedConn:Disconnect() charAddedConn=nil end         cleanup()     end     _G.PortalVisuals._enableFuncs[name]=enable     _G.PortalVisuals._disableFuncs[name]=disable     getgenv().PortalVisual=getgenv().PortalVisual or{}     getgenv().PortalVisual.Fireflies={         Settings=CONFIG,         Toggle=function(state) if state then enable() else disable() end end,         Start=enable,Stop=disable
    }
end

-- [[ Snowfall ]]
do
    local name = "Snowfall"
    local running = false
    local snowContainer = nil
    local flakes = {}
    local heartbeatConn = nil
    local charAddedConn = nil
    local timeAccumulator = 0
    local raycastIndex = 1
    local BASE_SNOW_COUNT = 280
    local BASE_SNOW_RADIUS = 60
    local CONFIG = {
        MaxFlakes = BASE_SNOW_COUNT,
        SpawnRadius = 60,
        HeightOffset = 15,
        RaycastHeight = 200,
        Gravity = Vector3.new(0, -7.5, 0),
        WindVector = Vector3.new(11, -0.5, 5),
        TurbulenceScale = 0.045,
        TurbulenceSpeed = 1.2,
        SizeMin = 0.15,
        SizeMax = 0.7,
        TransparencyMin = 0.08,
        TransparencyMax = 0.58,
        FlakeTexture = "rbxassetid://6071575925",
        AtmosphereFog = {
            Enabled = true,
            Color = Color3.fromRGB(195, 210, 225),
            Density = 0.24,
            Offset = 0.05,
            Haze = 1.8
        }
    }
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    local savedLighting = nil
    local savedAtmosphere = nil
    local rng = Random.new()

    local function getTargetData()
        local character = LocalPlayer.Character
        local camera = Workspace.CurrentCamera
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if camera then
            -- V22: snow volume follows the camera.
            return hrp, camera.CFrame.Position + Vector3.new(0, CONFIG.HeightOffset, 0)
        end
        if hrp then
            return hrp, hrp.Position + Vector3.new(0, CONFIG.HeightOffset, 0)
        end
        return nil, Vector3.zero
    end

    local function setupAtmosphere()
        if not CONFIG.AtmosphereFog.Enabled then return end
        pcall(function()
            savedLighting = {FogColor = Lighting.FogColor, FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd}
            local existingAtmo = Lighting:FindFirstChildOfClass("Atmosphere")
            if existingAtmo then
                savedAtmosphere = {Color=existingAtmo.Color, Density=existingAtmo.Density, Offset=existingAtmo.Offset, Haze=existingAtmo.Haze, Glare=existingAtmo.Glare, Decay=existingAtmo.Decay}
            else
                savedAtmosphere = "created"
            end
            Lighting.FogColor = CONFIG.AtmosphereFog.Color
            Lighting.FogStart = 5
            Lighting.FogEnd = 240
            local atmosphere = existingAtmo or Instance.new("Atmosphere")
            atmosphere.Parent = Lighting
            atmosphere.Color = CONFIG.AtmosphereFog.Color
            atmosphere.Density = CONFIG.AtmosphereFog.Density
            atmosphere.Offset = CONFIG.AtmosphereFog.Offset
            atmosphere.Haze = CONFIG.AtmosphereFog.Haze
            atmosphere.Glare = 0.15
            atmosphere.Decay = Color3.fromRGB(145, 158, 172)
        end)
    end

    local function getRandomOffset()
        local r = CONFIG.SpawnRadius
        local windOffset = -CONFIG.WindVector.Unit * (r * 0.35)
        return Vector3.new(rng:NextNumber(-r, r), rng:NextNumber(-r * 0.55, r * 1.45), rng:NextNumber(-r, r)) + windOffset
    end

    local function createFlake(initialPos)
        local baseSz = rng:NextNumber(CONFIG.SizeMin, CONFIG.SizeMax)
        local part = Instance.new("Part")
        part.Size = Vector3.new(baseSz, baseSz * 0.14, baseSz)
        part.Position = initialPos
        part.Anchored = true
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
        part.CastShadow = false
        part.Transparency = rng:NextNumber(CONFIG.TransparencyMin, CONFIG.TransparencyMax)
        part.Material = Enum.Material.SmoothPlastic
        part.Color = Color3.fromRGB(240, 245, 255)
        part.Parent = snowContainer
        local mesh = Instance.new("SpecialMesh")
        local variant = rng:NextInteger(1, 2)
        if variant == 1 then
            mesh.MeshType = Enum.MeshType.Sphere
        else
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = "rbxassetid://1095708"
            mesh.Scale = Vector3.new(0.4, 0.4, 0.4)
        end
        mesh.Parent = part
        return {
            Part=part, Position=initialPos, BaseSize=baseSz,
            Seed=rng:NextNumber(0,100000),
            BaseWobbleSpeed=rng:NextNumber(1.4,3.0),
            UnderRoof=false, CoveredTime=0,
            Rotation=Vector3.new(rng:NextNumber(0,360),rng:NextNumber(0,360),rng:NextNumber(0,360)),
            RotationSpeed=Vector3.new(rng:NextNumber(-55,55),rng:NextNumber(-65,65),rng:NextNumber(-50,50)),
            PhysicsBias=Vector3.new(rng:NextNumber(0.9,1.1),rng:NextNumber(0.95,1.05),rng:NextNumber(0.9,1.1))
        }
    end

    _G.PortalVisuals._snowConfig = CONFIG

    local function syncSnowCount()
        if not running or not snowContainer then return end
        local newCount = math.clamp(math.floor(BASE_SNOW_COUNT * (CONFIG.SpawnRadius / BASE_SNOW_RADIUS)^2), BASE_SNOW_COUNT, 600)
        if newCount > #flakes then
            local _, center = getTargetData()
            for i=#flakes+1,newCount do
                flakes[i] = createFlake(center + getRandomOffset())
            end
        elseif newCount < #flakes then
            for i=#flakes,newCount+1,-1 do
                local f = flakes[i]
                if f and f.Part then f.Part:Destroy() end
                flakes[i] = nil
            end
        end
        CONFIG.MaxFlakes = newCount
    end
    _G.PortalVisuals._snowSync = syncSnowCount

    local function initSnow()
        for _,oldName in ipairs({"UltraBlizzardContainer","3DSnowContainer","Atmospheric3DSnow","FixedSnowContainer","CollisionSnowContainer"}) do
            local old = Workspace:FindFirstChild(oldName)
            if old then old:Destroy() end
        end
        setupAtmosphere()
        snowContainer = Instance.new("Folder")
        snowContainer.Name = "CollisionSnowContainer"
        snowContainer.Parent = Workspace
        flakes = {}
        timeAccumulator = 0
        raycastIndex = 1
        raycastParams.FilterDescendantsInstances = {snowContainer, LocalPlayer.Character}
        local _, center = getTargetData()
        for i=1,CONFIG.MaxFlakes do
            flakes[i] = createFlake(center + getRandomOffset())
        end
    end

    local function respawnFlake(flake, center)
        local pos = center + getRandomOffset()
        flake.Position = pos
        flake.CoveredTime = 0
        flake.UnderRoof = false
        flake.Rotation = Vector3.new(rng:NextNumber(0,360),rng:NextNumber(0,360),rng:NextNumber(0,360))
        flake.Part.CFrame = CFrame.new(pos)
        flake.Part.Transparency = rng:NextNumber(CONFIG.TransparencyMin, CONFIG.TransparencyMax)
    end

    local function cleanupSnow()
        if heartbeatConn then heartbeatConn:Disconnect(); heartbeatConn=nil end
        if charAddedConn then charAddedConn:Disconnect(); charAddedConn=nil end
        for _,data in ipairs(flakes) do
            if data.Part then data.Part:Destroy() end
        end
        flakes = {}
        if snowContainer then snowContainer:Destroy(); snowContainer=nil end
        pcall(function()
            if savedLighting then
                Lighting.FogColor=savedLighting.FogColor
                Lighting.FogStart=savedLighting.FogStart
                Lighting.FogEnd=savedLighting.FogEnd
                savedLighting=nil
            end
            if savedAtmosphere then
                local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere")
                if savedAtmosphere=="created" and atmosphere then atmosphere:Destroy()
                elseif typeof(savedAtmosphere)=="table" and atmosphere then
                    atmosphere.Color=savedAtmosphere.Color
                    atmosphere.Density=savedAtmosphere.Density
                    atmosphere.Offset=savedAtmosphere.Offset
                    atmosphere.Haze=savedAtmosphere.Haze
                    atmosphere.Glare=savedAtmosphere.Glare
                    atmosphere.Decay=savedAtmosphere.Decay
                end
                savedAtmosphere=nil
            end
        end)
    end

    local function onUpdate(dt)
        if not running then return end
        timeAccumulator = timeAccumulator + dt
        local _, center = getTargetData()
        local radius = CONFIG.SpawnRadius
        local maxDistSq = radius*radius
        local farDistSq = (radius*1.20)*(radius*1.20)

        -- Only a tiny rotating sample is raycasted. Importantly, covered flakes keep simulating.
        if #flakes > 0 and StepEffect("SnowRoofRay", 0.30) then
            local checks = math.clamp(math.floor(#flakes / 180), 2, 5)
            for k=1,checks do
                raycastIndex = (raycastIndex % #flakes) + 1
                local f = flakes[raycastIndex]
                if f then
                    local rayResult = Workspace:Raycast(f.Position, Vector3.new(0, CONFIG.RaycastHeight, 0), raycastParams)
                    f.UnderRoof = rayResult ~= nil
                end
            end
        end

        for _,flake in ipairs(flakes) do
            local pos = flake.Position
            local dx = pos.X-center.X
            local dy = pos.Y-center.Y
            local dz = pos.Z-center.Z
            local distSq = dx*dx+dy*dy+dz*dz

            if distSq > farDistSq or pos.Y < center.Y - radius*0.95 then
                respawnFlake(flake, center)
                pos = flake.Position
            end

            local nsX = math.noise(pos.X*CONFIG.TurbulenceScale, timeAccumulator*CONFIG.TurbulenceSpeed, flake.Seed)
            local nsZ = math.noise(pos.Z*CONFIG.TurbulenceScale, timeAccumulator*CONFIG.TurbulenceSpeed, flake.Seed+1000)
            local wobbleY = math.sin(timeAccumulator*flake.BaseWobbleSpeed + flake.Seed) * 0.9
            local velocity = Vector3.new(
                nsX*8 + CONFIG.WindVector.X*flake.PhysicsBias.X,
                CONFIG.Gravity.Y*flake.PhysicsBias.Y + wobbleY,
                nsZ*8 + CONFIG.WindVector.Z*flake.PhysicsBias.Z
            )
            pos = pos + velocity*dt

            if math.abs(pos.X-center.X)>radius*1.35 or math.abs(pos.Z-center.Z)>radius*1.35 then
                respawnFlake(flake, center)
            else
                flake.Position = pos
            end

            flake.Rotation = flake.Rotation + flake.RotationSpeed*dt
            local alpha = math.clamp(1 - (math.sqrt(dx*dx+dz*dz) / math.max(radius,1)), 0.15, 1)
            local size = CONFIG.SizeMin + (CONFIG.SizeMax-CONFIG.SizeMin)*alpha
            if flake.UnderRoof then
                flake.Part.Transparency = 1
            else
                flake.Part.Transparency = CONFIG.TransparencyMax - (CONFIG.TransparencyMax-CONFIG.TransparencyMin)*alpha
            end
            flake.Part.Size = Vector3.new(size,size*0.14,size)
            flake.Part.CFrame = CFrame.new(flake.Position) * CFrame.Angles(math.rad(flake.Rotation.X),math.rad(flake.Rotation.Y),math.rad(flake.Rotation.Z))
        end
    end

    local function enable()
        if running then return end
        running=true
        initSnow()
        heartbeatConn=RunService.RenderStepped:Connect(onUpdate)
        charAddedConn=LocalPlayer.CharacterAdded:Connect(function(newChar)
            if not running then return end
            raycastParams.FilterDescendantsInstances={snowContainer,newChar}
            task.delay(0.35,function()
                if running and snowContainer then syncSnowCount() end
            end)
        end)
    end

    local function disable()
        if not running then return end
        running=false
        cleanupSnow()
    end

    _G.PortalVisuals._enableFuncs[name]=enable
    _G.PortalVisuals._disableFuncs[name]=disable
    getgenv().PortalVisual=getgenv().PortalVisual or {}
    getgenv().PortalVisual.Snow={Settings=CONFIG,Toggle=function(state) if state then enable() else disable() end end,Update=function(setting,value) CONFIG[setting]=value end,Start=enable,Stop=disable}
end

-- [[ StarFall ]]
do     local name="StarFall"local running=false      local Settings={SpawnInterval=0.1,MaxActiveStars=35,StarColor=Color3.fromRGB(255,230,150),TrailColor=Color3.fromRGB(255,190,80),StarSize=Vector3.new(1.8,1.8,1.8),Speed=125,FallHeight=125,MinRadius=35,MaxRadius=135,TrailLifetime=0.55,StarLifetime=4.5}     local ActiveStars={}     local SpawnConnection=nil      local MovementConnection=nil      local StarsFolder=nil      local FrameCounter=0      local GlobalRaycastParams=RaycastParams.new()     GlobalRaycastParams.FilterType=Enum.RaycastFilterType.Exclude     local function UpdateRaycastFilter()         local filter={GetStarsFolder()}         if LocalPlayer.Character then              table.insert(filter,LocalPlayer.Character)         end          GlobalRaycastParams.FilterDescendantsInstances=filter      end      function GetStarsFolder()         if not StarsFolder or not StarsFolder.Parent then                 StarsFolder=Instance.new("Folder")                 StarsFolder.Name="PortalVisual_Stars_Optimized"StarsFolder.Parent=Workspace UpdateRaycastFilter()         end          return StarsFolder      end     local function CreateImpactExplosion(position,normal)         local folder=GetStarsFolder()         local ring=Instance.new("Part")         ring.Shape=Enum.PartType.Cylinder ring.Size=Vector3.new(0.05,0.1,0.1)         ring.Material=Enum.Material.Neon ring.Color=Settings.TrailColor ring.Transparency=0.15         ring.Anchored=true ring.CanCollide=false ring.CanQuery=false         ring.CFrame=CFrame.lookAt(position,position+normal)*CFrame.Angles(math.rad(90),0,0)         ring.Parent=folder         local ringTween=TweenService:Create(ring,TweenInfo.new(0.4,Enum.EasingStyle.QuadOut),{Size=Vector3.new(0.05,10.0,10.0),Transparency=1})ringTween:Play()Debris:AddItem(ring,0.4)         local flash=Instance.new("Part")         flash.Shape=Enum.PartType.Ball flash.Size=Vector3.new(0.5,0.5,0.5)         flash.Material=Enum.Material.Neon flash.Color=Color3.fromRGB(255,255,255)         flash.Transparency=0.3 flash.Anchored=true flash.CanCollide=false flash.CanQuery=false         flash.Position=position flash.Parent=folder         TweenService:Create(flash,TweenInfo.new(0.2,Enum.EasingStyle.QuadOut),{Size=Vector3.new(4,4,4),Transparency=1}):Play()         Debris:AddItem(flash,0.3)         local sparkPart=Instance.new("Part")         sparkPart.Size=Vector3.new(0.1,0.1,0.1)         sparkPart.Transparency=1 sparkPart.Anchored=true sparkPart.CanCollide=false         sparkPart.Position=position sparkPart.Parent=folder         local emitter=Instance.new("ParticleEmitter")         emitter.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Settings.StarColor),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,200,100))})         emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.45),NumberSequenceKeypoint.new(0.3,0.3),NumberSequenceKeypoint.new(1,0)})             emitter.Lifetime=NumberRange.new(0.35,0.8)             emitter.Speed=NumberRange.new(15,35)             emitter.SpreadAngle=Vector2.new(-180,180)             emitter.Acceleration=Vector3.new(0,-25,0)             emitter.Drag=2             emitter.LightEmission=1.5             emitter.Parent=sparkPart emitter:Emit(35)             task.delay(1.0,function()sparkPart:Destroy()         end)         local glowBurst=Instance.new("ParticleEmitter")         glowBurst.Color=ColorSequence.new(Color3.fromRGB(255,230,180))         glowBurst.Size=NumberSequence.new(0.8,0)         glowBurst.Lifetime=NumberRange.new(0.15,0.3)         glowBurst.Speed=NumberRange.new(2,5)         glowBurst.SpreadAngle=Vector2.new(-180,180)         glowBurst.LightEmission=2         glowBurst.Rate=0         glowBurst.Parent=sparkPart glowBurst:Emit(18)         task.delay(0.5,function()sparkPart:Destroy()         end)     end     local function GetPlayerPosition()         local character=LocalPlayer.Character          if character then             local rootPart=character:FindFirstChild("HumanoidRootPart")             if rootPart then                  return (workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Position) or rootPart.Position              end         end         if workspace.CurrentCamera then              return workspace.CurrentCamera.CFrame.Position          end          return Vector3.new(0,0,0)     end     local function FadeOutStar(starData,instant)         if starData.IsDying then              return          end          starData.IsDying=true          local star=starData.Instance          if star and star.Parent then             if instant then                     star.Transparency=1                     star.Size=Vector3.new(0,0,0)                     task.delay(Settings.TrailLifetime,function()star:Destroy()                 end)             else                 local tween=TweenService:Create(star,TweenInfo.new(0.25),{Size=Vector3.new(0,0,0),Transparency=1})tween:Play()                     task.delay(Settings.TrailLifetime,function()star:Destroy()                 end)             end         end         local index=table.find(ActiveStars,starData)         if index then              table.remove(ActiveStars,index)         end     end     local function CreateStar()         local center=GetPlayerPosition()         local folder=GetStarsFolder()         if#ActiveStars>=Settings.MaxActiveStars then              FadeOutStar(ActiveStars[1],false)         end         local angle=math.random()*math.pi*2          local distance=math.random(Settings.MinRadius,Settings.MaxRadius)         local targetPos=center+Vector3.new(math.cos(angle)*distance,0,math.sin(angle)*distance)         local slowRotationAngle=tick()*0.05          local dynamicBaseDirection=Vector3.new(math.cos(slowRotationAngle)*0.75,-1,math.sin(slowRotationAngle)*0.75).Unit          local wobble=Vector3.new((math.random()-0.5)*0.15,0,(math.random()-0.5)*0.15)         local finalDirection=(dynamicBaseDirection+wobble).Unit          local spawnPos=targetPos-(finalDirection*(Settings.FallHeight/-finalDirection.Y))         local star=Instance.new("Part")         star.Name="ShootingStar"star.Size=Settings.StarSize star.Shape=Enum.PartType.Ball star.Color=Settings.StarColor star.Material=Enum.Material.Neon star.Anchored=true         star.CanCollide=false star.CanQuery=false star.CanTouch=false star.CastShadow=false         star.Position=spawnPos star.Parent=folder         local starGlow=Instance.new("PointLight")         starGlow.Color=Settings.StarColor starGlow.Brightness=4 starGlow.Range=12 starGlow.Shadows=false         starGlow.Parent=star         local starHue=(math.random(0,60)/360)         local starVariety=Color3.fromHSV(starHue,0.6,1)         local att0=Instance.new("Attachment")         att0.Position=Vector3.new(0,Settings.StarSize.Y/2,0)         att0.Parent=star         local att1=Instance.new("Attachment")         att1.Position=Vector3.new(0,-Settings.StarSize.Y/2,0)         att1.Parent=star         local trail=Instance.new("Trail")         trail.Attachment0=att0 trail.Attachment1=att1 trail.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,starVariety),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))})             trail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.0),NumberSequenceKeypoint.new(0.5,0.2),NumberSequenceKeypoint.new(1,0.9)})                 trail.Lifetime=Settings.TrailLifetime trail.LightEmission=1.5                 trail.LightInfluence=0                 trail.WidthScale=NumberSequence.new({NumberSequenceKeypoint.new(0,1.6),NumberSequenceKeypoint.new(1,0)})                     trail.Parent=star         local dust=Instance.new("ParticleEmitter")         dust.Color=ColorSequence.new(Settings.StarColor)         dust.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.3),NumberSequenceKeypoint.new(1,0)})             dust.Lifetime=NumberRange.new(0.2,0.45)             dust.Speed=NumberRange.new(0,3)             dust.Rate=25             dust.LightEmission=1.0             dust.Parent=star         local starData={Instance=star,Position=spawnPos,Direction=finalDirection,Speed=Settings.Speed*(0.85+math.random()*0.3),SpawnTime=os.clock(),IsDying=false,Color=starVariety}             table.insert(ActiveStars,starData)     end     local function UpdateStars(deltaTime)         local currentClock=os.clock()         FrameCounter=FrameCounter+1         for i=#ActiveStars,1,-1 do             local starData=ActiveStars[i]             local star=starData.Instance              if not star or not star.Parent then                     table.remove(ActiveStars,i)                     continue             end             if currentClock-starData.SpawnTime>=Settings.StarLifetime then                     FadeOutStar(starData,false)                     continue             end             local nextPosition=starData.Position+(starData.Direction*starData.Speed*deltaTime)             starData.Position=nextPosition star.Position=nextPosition             if FrameCounter%2==0 then                 local raycastResult=Workspace:Raycast(starData.Position,starData.Direction*(starData.Speed*deltaTime*2.5),GlobalRaycastParams)                 if raycastResult then                         CreateImpactExplosion(raycastResult.Position,raycastResult.Normal)                         FadeOutStar(starData,true)                 end             end         end     end     local function enable()         if running then              return          end          running=true UpdateRaycastFilter()         local lastSpawn=0         SpawnConnection=RunService.Heartbeat:Connect(function(deltaTime)             if not running then                  return              end              lastSpawn=lastSpawn+deltaTime              if lastSpawn>=Settings.SpawnInterval then                  lastSpawn=0 CreateStar()             end     end)     MovementConnection=RunService.RenderStepped:Connect(function(deltaTime)
            if running then UpdateStars(deltaTime) end         end)     end     local function disable()         if not running then              return          end          running=false          if SpawnConnection then              SpawnConnection:Disconnect()         end         if MovementConnection then              MovementConnection:Disconnect()         end         for _,starData in ipairs(ActiveStars)do              FadeOutStar(starData,true)         end             table.clear(ActiveStars)             task.delay(Settings.TrailLifetime+0.1,function()             if StarsFolder then                     StarsFolder:Destroy()                     StarsFolder=nil             end         end)     end      _G.PortalVisuals._enableFuncs[name]=enable _G.PortalVisuals._disableFuncs[name]=disable  end

-- [[ Thunder ]]
do     local name="Thunder"local running=false      local Settings={MinInterval=2.0,MaxInterval=5.0,StrikeRadiusMin=40,StrikeRadiusMax=150,StrikeHeight=300,LightningColor=Color3.fromRGB(190,225,255),Thickness=1.2,Segments=11,Displacement=13,FadeInDuration=0.04,FadeOutDuration=0.45,SegmentDelay=0.015,BranchDelay=0.06,PulseIntensity=0.35,GroundFlashSize=14}     local LightningFolder=nil      local CharConnection=nil      local RayParams=RaycastParams.new()     RayParams.FilterType=Enum.RaycastFilterType.Exclude     local function UpdateRayParams()         local filter={}         if LightningFolder then              table.insert(filter,LightningFolder)         end         if LocalPlayer.Character then              table.insert(filter,LocalPlayer.Character)         end          RayParams.FilterDescendantsInstances=filter      end     local function GetLightningFolder()         if not LightningFolder or not LightningFolder.Parent then                 LightningFolder=Instance.new("Folder")                 LightningFolder.Name="PortalVisual_Lightning_Local"LightningFolder.Parent=Workspace UpdateRayParams()         end          return LightningFolder      end     local function DrawSegment(p1,p2,thickness,color,folder)         local distance=(p1-p2).Magnitude          local part=Instance.new("Part")         part.Size=Vector3.new(thickness,thickness,distance)         part.CFrame=CFrame.lookAt((p1+p2)/2,p2)         part.Color=color part.Material=Enum.Material.Neon part.Anchored=true         part.CanCollide=false         part.CanQuery=false         part.CanTouch=false         part.CastShadow=false         part.Transparency=1         part.Parent=folder Debris:AddItem(part,2.5)         return part     end     local function SafeTween(obj,info,props)         local ok,tw=pcall(TweenService.Create,TweenService,obj,info,props)         if ok and tw then                 tw:Play()                 return tw         else             for k,v in pairs(props)do                  pcall(function()obj[k]=v                  end)             end              return nil          end     end     local function AnimateLightning(mainParts,branchParts)         for _,part in ipairs(mainParts)do             if part and part.Parent then                     SafeTween(part,TweenInfo.new(Settings.FadeInDuration,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Transparency=0})                         task.wait(Settings.SegmentDelay)             end         end          task.wait(Settings.BranchDelay)         for _,part in ipairs(branchParts)do             if part and part.Parent then                  SafeTween(part,TweenInfo.new(Settings.FadeInDuration*1.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Transparency=0.1})             end         end          task.wait(0.06)         for _,part in ipairs(mainParts)do             if part and part.Parent then                  SafeTween(part,TweenInfo.new(0.04,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0.2})             end         end          task.wait(0.04)         for _,part in ipairs(mainParts)do             if part and part.Parent then                  SafeTween(part,TweenInfo.new(0.04,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0})             end         end          task.wait(0.04)         for _,part in ipairs(mainParts)do             if part and part.Parent then                  SafeTween(part,TweenInfo.new(0.04,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0.25})             end         end          task.wait(0.04)         for _,part in ipairs(mainParts)do             if part and part.Parent then                  SafeTween(part,TweenInfo.new(0.04,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0})             end         end          task.wait(0.2)         local allParts={}         for _,p in ipairs(mainParts)do              table.insert(allParts,p)         end         for _,p in ipairs(branchParts)do              table.insert(allParts,p)         end         for _,part in ipairs(allParts)do             if part and part.Parent then                 local tw=SafeTween(part,TweenInfo.new(Settings.FadeOutDuration,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Transparency=1})                 if tw then                      tw.Completed:Connect(function()                         if part and part.Parent then                              part:Destroy()                         end                     end)                 else                      part:Destroy()                 end             end         end     end     local function CreateGroundImpact(position,normal)         local folder=GetLightningFolder()         local lightPart=Instance.new("Part")         lightPart.Shape=Enum.PartType.Ball lightPart.Size=Vector3.new(0.1,0.1,0.1)         lightPart.Color=Color3.fromRGB(255,255,255)         lightPart.Material=Enum.Material.Neon lightPart.Position=position lightPart.Anchored=true         lightPart.CanCollide=false         lightPart.Transparency=1         lightPart.Parent=folder         local pointLight=Instance.new("PointLight")         pointLight.Color=Settings.LightningColor pointLight.Brightness=0         pointLight.Range=Settings.GroundFlashSize*1.5         pointLight.Parent=lightPart SafeTween(pointLight,TweenInfo.new(0.08,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Brightness=10})             SafeTween(lightPart,TweenInfo.new(0.08,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=Vector3.new(Settings.GroundFlashSize,Settings.GroundFlashSize,Settings.GroundFlashSize)})                 task.delay(0.12,function()             if lightPart.Parent then                     SafeTween(pointLight,TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Brightness=0})                         SafeTween(lightPart,TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=Vector3.new(0.1,0.1,0.1),Transparency=1})Debris:AddItem(lightPart,0.4)             end         end)         local ring=Instance.new("Part")         ring.Shape=Enum.PartType.Cylinder ring.Size=Vector3.new(0.05,1,1)         ring.Color=Settings.LightningColor ring.Material=Enum.Material.Neon ring.Transparency=0.3         ring.Anchored=true         ring.CanCollide=false         ring.CFrame=CFrame.lookAt(position,position+normal)*CFrame.Angles(math.rad(90),0,0)         ring.Parent=folder SafeTween(ring,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=Vector3.new(0.05,28,28),Transparency=1})Debris:AddItem(ring,0.5)         pcall(function()             Lighting.Brightness=2             task.delay(0.1,function()                 pcall(function()Lighting.Brightness=1                 end)             end)         end)     end     local function GenerateLightningBranch(startPos,endPos,segments,displacement,thickness,isBranch,folder,mainParts,branchParts)         local points={startPos}         for i=2,segments do             local t=(i-1)/(segments-1)             local basePos=startPos:Lerp(endPos,t)             if i<segments then                 local offset=Vector3.new(math.random(-displacement,displacement),math.random(-displacement*0.3,displacement*0.3),math.random(-displacement,displacement))points[i]=basePos+offset              else                  points[i]=endPos              end         end         for i=1,#points-1 do             local p1=points[i]             local p2=points[i+1]             local currentThickness=isBranch and(thickness*0.5)or thickness              local part=DrawSegment(p1,p2,currentThickness,Settings.LightningColor,folder)             if isBranch then                  table.insert(branchParts,part)             else                  table.insert(mainParts,part)             end             if not isBranch and i>2 and i<#points-1 and math.random()<0.25 then                 local branchDir=(p2-p1).Unit+Vector3.new(math.random(-10,10)/10,-0.4,math.random(-10,10)/10).Unit                  local branchLength=(endPos-startPos).Magnitude*0.35                  local branchEnd=p2+(branchDir*branchLength)                 GenerateLightningBranch(p2,branchEnd,5,displacement*0.5,thickness,true,folder,mainParts,branchParts)             end         end     end     local function TriggerLightningStrike()         local character=LocalPlayer.Character          local rootPart=character and character:FindFirstChild("HumanoidRootPart")         local center=rootPart and rootPart.Position or(workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Position or Vector3.new(0,0,0))         local angle=math.random()*math.pi*2          local distance=math.random(Settings.StrikeRadiusMin,Settings.StrikeRadiusMax)         local targetPosXZ=center+Vector3.new(math.cos(angle)*distance,0,math.sin(angle)*distance)         local skyCheckPos=targetPosXZ+Vector3.new(0,400,0)         local rayResult=Workspace:Raycast(skyCheckPos,Vector3.new(0,-800,0),RayParams)         local endPos=rayResult and rayResult.Position or targetPosXZ         local normal=rayResult and rayResult.Normal or Vector3.new(0,1,0)         local startPos=endPos+Vector3.new(math.random(-40,40),Settings.StrikeHeight,math.random(-40,40))         local mainParts,branchParts={},{}             GenerateLightningBranch(startPos,endPos,Settings.Segments,Settings.Displacement,Settings.Thickness,false,GetLightningFolder(),mainParts,branchParts)             CreateGroundImpact(endPos,normal)             task.spawn(AnimateLightning,mainParts,branchParts)     end     local function enable()         if running then              return          end          running=true UpdateRayParams()         if not CharConnection then              CharConnection=LocalPlayer.CharacterAdded:Connect(UpdateRayParams)         end          task.spawn(function()             while running do                 local waitTime=math.random(Settings.MinInterval*10,Settings.MaxInterval*10)/10 task.wait(waitTime)                 if not running then                      break                  end                 local success,err=pcall(TriggerLightningStrike)                 if not success then                      warn("[Thunder Error]: "..tostring(err))                 end             end         end)     end     local function disable()     running=false         if CharConnection then                 CharConnection:Disconnect()                 CharConnection=nil         end         if LightningFolder then                 LightningFolder:Destroy()                 LightningFolder=nil         end     end      _G.PortalVisuals._enableFuncs[name]=enable _G.PortalVisuals._disableFuncs[name]=disable  end

-- [[ RGB Circle ]]
do     local name="RGB Circle"local running=false      local parts={}     local angleOffset=0      local heartbeatConn      local cameraConn      local CONFIG={Radius=6,NumParts=24,PartSize=Vector3.new(0.4,0.4,0.4),RotationSpeed=1,ColorSpeed=0.3,HeightOffset=-1.5,WaveAmp=1}     local partTargets={}     local function createParts()         local camera=Workspace.CurrentCamera          if not camera then              return          end         local existing=camera:FindFirstChild("PortalVisual_RainbowAura")         if existing then              existing:Destroy()         end         local folder=Instance.new("Folder")         folder.Name="PortalVisual_RainbowAura"folder.Parent=camera parts={}partTargets={}         for i=1,CONFIG.NumParts do             local p=Instance.new("Part")             p.Size=CONFIG.PartSize p.Material=Enum.Material.Neon p.Anchored=true             p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=false             p.Parent=folder             local gl=Instance.new("PointLight")             gl.Brightness=1.5 gl.Range=5 gl.Shadows=false             gl.Parent=p             parts[i]=p partTargets[i]=Vector3.new(0,0,0)         end     end     local function onHeartbeat(dt)         local character=LocalPlayer.Character          local root=character and character:FindFirstChild("HumanoidRootPart")         local camera=Workspace.CurrentCamera          local folder=camera and camera:FindFirstChild("PortalVisual_RainbowAura")         if not folder then                 createParts()                 return         end         if not root then             for _,p in ipairs(parts)do                 if p and p.Parent then                      p.Transparency=1                  end             end              return          end      angleOffset=angleOffset+dt*CONFIG.RotationSpeed          local timeValue=tick()*CONFIG.ColorSpeed          local centerPosition=root.Position+Vector3.new(0,CONFIG.HeightOffset,0)         for i=1,CONFIG.NumParts do             local p=parts[i]             if p and p.Parent then                  p.Transparency=0                  local angle=(i/CONFIG.NumParts)*math.pi*2+angleOffset                  local x=math.cos(angle)*CONFIG.Radius                  local z=math.sin(angle)*CONFIG.Radius                 local y=math.sin(angle*2+timeValue*2)*CONFIG.WaveAmp                 local target=centerPosition+Vector3.new(x,y,z)                 partTargets[i]=target p.Position=p.Position:Lerp(target,0.35)                 local hue=((i/CONFIG.NumParts)+timeValue)%1                 p.Color=Color3.fromHSV(hue,1,1)                 local gl=p:FindFirstChildOfClass("PointLight")                 if gl then                     gl.Color=Color3.fromHSV(hue,0.8,1) gl.Brightness=1.2+math.sin(angle*2+timeValue*3)*0.5                 end             end         end     end     local function onCameraChanged()         if running then              createParts()         end     end     local function enable()         if running then              return          end             running=true createParts()             heartbeatConn=RunService.Heartbeat:Connect(function(dt)
            if StepEffect("RGBCircle", 1/60) then onHeartbeat(dt) end
        end)             cameraConn=Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(onCameraChanged)     end     local function disable()     running=false         if heartbeatConn then              heartbeatConn:Disconnect()         end         if cameraConn then              cameraConn:Disconnect()         end         local camera=Workspace.CurrentCamera          if camera then             local folder=camera:FindFirstChild("PortalVisual_RainbowAura")             if folder then                  folder:Destroy()             end         end          parts={}     end      _G.PortalVisuals._enableFuncs[name]=enable _G.PortalVisuals._disableFuncs[name]=disable  end

-- [[ Leaves Fall ]]
do     local name="Leaves Fall"local running=false      local LeavesSettings={MaxLeaves=110,SpawnRate=0.04,Lifetime=16,FallSpeed=4.8,WindDirection=Vector3.new(1.8,0,1.2),SpawnRadius=60,SpawnHeight=60,GroundDuration=4.0,Colors={         Color3.fromRGB(210,80,20),Color3.fromRGB(225,155,25),Color3.fromRGB(180,45,25),         Color3.fromRGB(195,115,40),Color3.fromRGB(140,75,30),Color3.fromRGB(240,175,15),         Color3.fromRGB(160,55,20),Color3.fromRGB(230,130,35),Color3.fromRGB(200,95,30),         Color3.fromRGB(170,65,25)     }}     local activeLeaves={}     local leafFolder=nil      local windGust=Vector3.new(0,0,0)     local windTime=0      local spawnConnection,updateConnection,windConnection      local rng=Random.new()     local function createLeaf()         if#activeLeaves>=LeavesSettings.MaxLeaves then              return          end         local char=LocalPlayer.Character          local hrp=char and char:FindFirstChild("HumanoidRootPart")         if not hrp then              return          end         local leaf=Instance.new("Part")         leaf.Name="AutumnLeaf"         leaf.Size=Vector3.new(0.5,0.05,0.8)         leaf.Material=Enum.Material.SmoothPlastic         leaf.CanCollide=false         leaf.CanTouch=false         leaf.CastShadow=false         leaf.Anchored=true         leaf.Reflectance=0.12         leaf.Transparency=1         leaf.Parent=leafFolder         local mesh=Instance.new("SpecialMesh")         mesh.MeshType=Enum.MeshType.Sphere         local scaleMult=0.5+rng:NextNumber()*1.1         mesh.Scale=Vector3.new(1*scaleMult,0.22,1.6*scaleMult)         mesh.Parent=leaf         local baseColor=LeavesSettings.Colors[rng:NextInteger(1,#LeavesSettings.Colors)]         local brightness=0.75+rng:NextNumber()*0.5         leaf.Color=Color3.new(math.clamp(baseColor.R*brightness,0,1),math.clamp(baseColor.G*brightness,0,1),math.clamp(baseColor.B*brightness,0,1))         if rng:NextNumber()<0.2 then             local gl=Instance.new("PointLight")             gl.Color=leaf.Color gl.Brightness=0.35 gl.Range=3.5 gl.Shadows=false             gl.Parent=leaf         end         local randomOffset=Vector3.new(             rng:NextNumber(-LeavesSettings.SpawnRadius,LeavesSettings.SpawnRadius),             LeavesSettings.SpawnHeight+rng:NextNumber(-10,15),             rng:NextNumber(-LeavesSettings.SpawnRadius,LeavesSettings.SpawnRadius)         )         leaf.Position=hrp.Position+randomOffset         leaf.CFrame=CFrame.new(leaf.Position)*CFrame.Angles(rng:NextNumber(0,6.28),rng:NextNumber(0,6.28),rng:NextNumber(0,6.28))         local leafData={             Instance=leaf,             Position=leaf.Position,Age=0,             Lifetime=LeavesSettings.Lifetime+rng:NextNumber(-4,5),             SwaySpeed=rng:NextNumber(1.2,3.5),             SwayWidth=rng:NextNumber(0.6,2.2),             RotSpeed=Vector3.new(rng:NextNumber(-130,130),rng:NextNumber(-70,70),rng:NextNumber(-130,130)),             SpiralRadius=rng:NextNumber(0.8,5.0),             SpiralSpeed=rng:NextNumber(0.6,2.2),             SpiralPhase=rng:NextNumber(0,6.28),             TurbulencePhase=rng:NextNumber(0,6.28),             FlutterPhase=rng:NextNumber(0,6.28),             FlutterSpeed=rng:NextNumber(3,8),             Grounded=false,GroundTime=0,             GroundY=hrp.Position.Y-3-rng:NextNumber(0,3),             ScaleMult=scaleMult,             DepthAlpha=1         }         table.insert(activeLeaves,leafData)     end     local function updateLeaves(deltaTime)         for i=#activeLeaves,1,-1 do             local data=activeLeaves[i]             local leaf=data.Instance              if not leaf or not leaf.Parent then                     table.remove(activeLeaves,i)                     continue             end             data.Age=data.Age+deltaTime              local char=LocalPlayer.Character             local hrp=char and char:FindFirstChild("HumanoidRootPart")             local camPos=Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.Position or Vector3.zero             local viewerPos=hrp and hrp.Position or camPos             local dist=(data.Position-viewerPos).Magnitude             local maxDist=LeavesSettings.SpawnRadius*1.5             data.DepthAlpha=math.clamp(1-dist/maxDist,0.15,1)             local fadeIn=math.min(data.Age/0.8,1)             fadeIn=fadeIn*fadeIn*(3-2*fadeIn)             local fadeOut=1              if data.Grounded then                     fadeOut=math.max(1-data.GroundTime/LeavesSettings.GroundDuration,0)                     fadeOut=fadeOut*fadeOut             elseif data.Age>data.Lifetime-2.5 then                 local t=(data.Age-(data.Lifetime-2.5))/2.5                 fadeOut=math.max(1-t*t,0)             end             leaf.Transparency=1-(fadeIn*fadeOut*data.DepthAlpha)             if data.Grounded then                  data.GroundTime=data.GroundTime+deltaTime                  local sink=math.min(data.GroundTime/LeavesSettings.GroundDuration,1)                 leaf.Position=Vector3.new(data.Position.X,data.GroundY-sink*0.4,data.Position.Z)                 local groundFade=math.max(1-data.GroundTime/LeavesSettings.GroundDuration,0)                 local gs=data.ScaleMult*groundFade                 leaf.Size=Vector3.new(0.5*gs,0.05*gs,0.8*gs)                 if data.GroundTime>=LeavesSettings.GroundDuration then                         leaf:Destroy()                         table.remove(activeLeaves,i)                 end                  continue              end             if data.Age>=data.Lifetime then                     leaf:Destroy()                     table.remove(activeLeaves,i)                     continue             end             local flutter=math.sin(data.Age*data.FlutterSpeed+data.FlutterPhase)*0.15             local turbX=math.sin(data.Age*2.3+data.TurbulencePhase)*0.6+math.sin(data.Age*5.7+data.TurbulencePhase*1.3)*0.25+math.sin(data.Age*11+data.TurbulencePhase*0.3)*0.1             local turbZ=math.cos(data.Age*1.9+data.TurbulencePhase*0.7)*0.5+math.cos(data.Age*4.2+data.TurbulencePhase*1.7)*0.2+math.cos(data.Age*9+data.TurbulencePhase*0.5)*0.1             local spiralAngle=data.Age*data.SpiralSpeed+data.SpiralPhase             local spiralX=math.cos(spiralAngle)*data.SpiralRadius              local spiralZ=math.sin(spiralAngle)*data.SpiralRadius              local swayX=math.sin(data.Age*data.SwaySpeed)*data.SwayWidth              local swayZ=math.cos(data.Age*data.SwaySpeed*0.65)*data.SwayWidth              local gustFactor=1+math.sin(data.Age*0.8)*0.3             local currentFall=LeavesSettings.FallSpeed*(0.8+flutter)             local fallVector=Vector3.new(0,-currentFall,0)             local driftVector=(LeavesSettings.WindDirection+windGust*gustFactor)*Vector3.new(1,0.1,1)+Vector3.new(swayX+spiralX*0.35+turbX,flutter,swayZ+spiralZ*0.35+turbZ)             data.Position=data.Position+(fallVector+driftVector)*deltaTime             if data.Position.Y<=data.GroundY then                     data.Position=Vector3.new(data.Position.X,data.GroundY,data.Position.Z)                     data.Grounded=true                     leaf.CFrame=CFrame.new(data.Position)*CFrame.Angles(math.rad(rng:NextNumber(-25,25)),rng:NextNumber(0,6.28),math.rad(rng:NextNumber(-25,25)))                     continue             end             leaf.Position=data.Position              local tumbleIntensity=1+math.sin(data.Age*3)*0.35             leaf.CFrame=CFrame.new(data.Position)*CFrame.Angles(                 math.rad(data.RotSpeed.X*data.Age*0.55*tumbleIntensity),                 math.rad(data.RotSpeed.Y*data.Age*0.22*tumbleIntensity),                 math.rad(data.RotSpeed.Z*data.Age*0.55*tumbleIntensity)             )         end     end     local function windUpdate(dt)         windTime=windTime+dt         local gustX=math.sin(windTime*0.5)*4.0+math.sin(windTime*1.4)*2.5+math.sin(windTime*3.1)*1.0+math.sin(windTime*0.15)*1.5         local gustZ=math.cos(windTime*0.4)*3.5+math.sin(windTime*1.8)*1.8+math.cos(windTime*2.7)*0.8+math.cos(windTime*0.12)*1.2         local gustY=math.sin(windTime*0.7)*0.5         windGust=Vector3.new(gustX,gustY,gustZ)     end     local function enable()         if running then              return          end          running=true          local old=Workspace:FindFirstChild("PortalVisual_LeavesFall")         if old then              old:Destroy()         end             leafFolder=Instance.new("Folder")             leafFolder.Name="PortalVisual_LeavesFall"leafFolder.Parent=Workspace activeLeaves={}                 windGust=Vector3.new(0,0,0)                 windTime=0                 windConnection=RunService.Heartbeat:Connect(windUpdate)                 spawnConnection=task.spawn(function()             while running do                     createLeaf()                     task.wait(LeavesSettings.SpawnRate)             end     end)     updateConnection=RunService.RenderStepped:Connect(function(dt)
            if StepEffect("LeavesFall", 1/60) then updateLeaves(dt) end
        end)     end     local function disable()     running=false         if spawnConnection then              task.cancel(spawnConnection)         end         if updateConnection then              updateConnection:Disconnect()         end         if windConnection then              windConnection:Disconnect()         end         if leafFolder then              leafFolder:Destroy()         end          activeLeaves={}     end      _G.PortalVisuals._enableFuncs[name]=enable _G.PortalVisuals._disableFuncs[name]=disable  end

-- [[ Cherry Blossoms ]]
do     local name="Cherry Blossoms"local running=false      local PetalSettings={MaxPetals=120,SpawnRate=0.035,Lifetime=18,FallSpeed=1.5,WindDirection=Vector3.new(2.2,0,1.8),SpawnRadius=55,SpawnHeight=50,GroundDuration=5.0,Colors={         Color3.fromRGB(255,195,215),Color3.fromRGB(255,175,205),Color3.fromRGB(255,215,230),         Color3.fromRGB(255,155,185),Color3.fromRGB(255,205,220),Color3.fromRGB(250,185,210),         Color3.fromRGB(255,225,240),Color3.fromRGB(245,170,200),Color3.fromRGB(255,190,212)     }}     local activePetals={}     local petalFolder=nil      local windGust=Vector3.new(0,0,0)     local windTime=0      local spawnConnection,updateConnection,windConnection      local rng=Random.new()     local function createPetal()         if#activePetals>=PetalSettings.MaxPetals then              return          end         local char=LocalPlayer.Character          local hrp=char and char:FindFirstChild("HumanoidRootPart")         if not hrp then              return          end         local petal=Instance.new("Part")         petal.Name="SakuraPetal"         petal.Size=Vector3.new(0.35,0.02,0.5)         petal.Material=Enum.Material.SmoothPlastic         petal.CanCollide=false         petal.CanTouch=false         petal.CastShadow=false         petal.Anchored=true         petal.Reflectance=0.2         petal.Transparency=1         petal.Parent=petalFolder         local mesh=Instance.new("SpecialMesh")         mesh.MeshType=Enum.MeshType.Sphere         local scaleMult=0.4+rng:NextNumber()*0.8         mesh.Scale=Vector3.new(1*scaleMult,0.15,1.8*scaleMult)         mesh.Parent=petal         local baseColor=PetalSettings.Colors[rng:NextInteger(1,#PetalSettings.Colors)]         local brightness=0.85+rng:NextNumber()*0.3         petal.Color=Color3.new(math.clamp(baseColor.R*brightness,0,1),math.clamp(baseColor.G*brightness,0,1),math.clamp(baseColor.B*brightness,0,1))         if rng:NextNumber()<0.15 then             local gl=Instance.new("PointLight")             gl.Color=Color3.fromRGB(255,200,220) gl.Brightness=0.25 gl.Range=2.0 gl.Shadows=false             gl.Parent=petal         end         local randomOffset=Vector3.new(             rng:NextNumber(-PetalSettings.SpawnRadius,PetalSettings.SpawnRadius),             PetalSettings.SpawnHeight+rng:NextNumber(-8,12),             rng:NextNumber(-PetalSettings.SpawnRadius,PetalSettings.SpawnRadius)         )         petal.Position=hrp.Position+randomOffset         petal.CFrame=CFrame.new(petal.Position)*CFrame.Angles(rng:NextNumber(0,6.28),rng:NextNumber(0,6.28),rng:NextNumber(0,6.28))         local petalData={             Instance=petal,             Position=petal.Position,Age=0,             Lifetime=PetalSettings.Lifetime+rng:NextNumber(-5,6),             SwaySpeed=rng:NextNumber(0.8,2.8),             SwayWidth=rng:NextNumber(0.8,2.5),             RotSpeed=Vector3.new(rng:NextNumber(-160,160),rng:NextNumber(-90,90),rng:NextNumber(-160,160)),             SpiralRadius=rng:NextNumber(1.2,6.0),             SpiralSpeed=rng:NextNumber(0.4,1.8),             SpiralPhase=rng:NextNumber(0,6.28),             TurbulencePhase=rng:NextNumber(0,6.28),             FloatPhase=rng:NextNumber(0,6.28),             FlutterPhase=rng:NextNumber(0,6.28),             FlutterSpeed=rng:NextNumber(2,6),             Grounded=false,GroundTime=0,             GroundY=hrp.Position.Y-3-rng:NextNumber(0,2.5),             ScaleMult=scaleMult,             DepthAlpha=1         }         table.insert(activePetals,petalData)     end     local function updatePetals(deltaTime)         for i=#activePetals,1,-1 do             local data=activePetals[i]             local petal=data.Instance              if not petal or not petal.Parent then                     table.remove(activePetals,i)                     continue             end             data.Age=data.Age+deltaTime              local char=LocalPlayer.Character             local hrp=char and char:FindFirstChild("HumanoidRootPart")             local camPos=Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.Position or Vector3.zero             local viewerPos=hrp and hrp.Position or camPos             local dist=(data.Position-viewerPos).Magnitude             local maxDist=PetalSettings.SpawnRadius*1.5             data.DepthAlpha=math.clamp(1-dist/maxDist,0.1,1)             local fadeIn=math.min(data.Age/1.0,1)             fadeIn=fadeIn*fadeIn*(3-2*fadeIn)             local fadeOut=1              if data.Grounded then                     fadeOut=math.max(1-data.GroundTime/PetalSettings.GroundDuration,0)                     fadeOut=fadeOut*fadeOut             elseif data.Age>data.Lifetime-3.0 then                 local t=(data.Age-(data.Lifetime-3.0))/3.0                 fadeOut=math.max(1-t*t,0)             end             petal.Transparency=1-(fadeIn*fadeOut*data.DepthAlpha)             if data.Grounded then                  data.GroundTime=data.GroundTime+deltaTime                  local sink=math.min(data.GroundTime/PetalSettings.GroundDuration,1)                 petal.Position=Vector3.new(data.Position.X,data.GroundY-sink*0.25,data.Position.Z)                 local groundFade=math.max(1-data.GroundTime/PetalSettings.GroundDuration,0)                 local gs=data.ScaleMult*groundFade                 petal.Size=Vector3.new(0.35*gs,0.02*gs,0.5*gs)                 if data.GroundTime>=PetalSettings.GroundDuration then                         petal:Destroy()                         table.remove(activePetals,i)                 end                  continue              end             if data.Age>=data.Lifetime then                     petal:Destroy()                     table.remove(activePetals,i)                     continue             end             local flutter=math.sin(data.Age*data.FlutterSpeed+data.FlutterPhase)*0.12             local floatY=math.sin(data.Age*1.2+data.FloatPhase)*1.0             local turbX=math.sin(data.Age*1.8+data.TurbulencePhase)*0.55+math.sin(data.Age*4.5+data.TurbulencePhase*1.2)*0.2+math.sin(data.Age*8+data.TurbulencePhase*0.5)*0.08             local turbZ=math.cos(data.Age*1.5+data.TurbulencePhase*0.6)*0.45+math.cos(data.Age*3.8+data.TurbulencePhase*1.5)*0.18+math.cos(data.Age*7+data.TurbulencePhase*0.3)*0.07             local spiralAngle=data.Age*data.SpiralSpeed+data.SpiralPhase             local spiralX=math.cos(spiralAngle)*data.SpiralRadius              local spiralZ=math.sin(spiralAngle)*data.SpiralRadius              local swayX=math.sin(data.Age*data.SwaySpeed)*data.SwayWidth              local swayZ=math.cos(data.Age*data.SwaySpeed*0.6)*data.SwayWidth              local gustFactor=1+math.sin(data.Age*0.6)*0.25             local currentFall=PetalSettings.FallSpeed*(0.7+flutter)             local fallVector=Vector3.new(0,-currentFall+floatY*0.35,0)             local driftVector=(PetalSettings.WindDirection+windGust*gustFactor)*Vector3.new(1,0.08,1)+Vector3.new(swayX+spiralX*0.4+turbX,floatY*0.12+flutter,swayZ+spiralZ*0.4+turbZ)             data.Position=data.Position+(fallVector+driftVector)*deltaTime             if data.Position.Y<=data.GroundY then                     data.Position=Vector3.new(data.Position.X,data.GroundY,data.Position.Z)                     data.Grounded=true                     petal.CFrame=CFrame.new(data.Position)*CFrame.Angles(math.rad(rng:NextNumber(-35,35)),rng:NextNumber(0,6.28),math.rad(rng:NextNumber(-35,35)))                     continue             end             petal.Position=data.Position              local tumbleIntensity=1+math.sin(data.Age*2.2)*0.45             petal.CFrame=CFrame.new(data.Position)*CFrame.Angles(                 math.rad(data.RotSpeed.X*data.Age*0.45*tumbleIntensity),                 math.rad(data.RotSpeed.Y*data.Age*0.28*tumbleIntensity),                 math.rad(data.RotSpeed.Z*data.Age*0.45*tumbleIntensity)             )         end     end     local function windUpdate(dt)         windTime=windTime+dt         local gustX=math.sin(windTime*0.4)*3.0+math.sin(windTime*1.1)*1.8+math.sin(windTime*2.5)*0.7+math.sin(windTime*0.1)*1.0         local gustZ=math.cos(windTime*0.3)*2.5+math.sin(windTime*1.4)*1.4+math.cos(windTime*2.1)*0.6+math.cos(windTime*0.08)*0.8         local gustY=math.sin(windTime*0.5)*0.3         windGust=Vector3.new(gustX,gustY,gustZ)     end     local function enable()         if running then              return          end          running=true          local old=Workspace:FindFirstChild("PortalVisual_CherryBlossoms")         if old then              old:Destroy()         end             petalFolder=Instance.new("Folder")             petalFolder.Name="PortalVisual_CherryBlossoms"petalFolder.Parent=Workspace activePetals={}                 windGust=Vector3.new(0,0,0)                 windTime=0                 windConnection=RunService.Heartbeat:Connect(windUpdate)                 spawnConnection=task.spawn(function()             while running do                     createPetal()                     task.wait(PetalSettings.SpawnRate)             end     end)     updateConnection=RunService.RenderStepped:Connect(function(dt)
            if StepEffect("CherryBlossoms", 1/60) then updatePetals(dt) end
        end)     end     local function disable()     running=false         if spawnConnection then              task.cancel(spawnConnection)         end         if updateConnection then              updateConnection:Disconnect()         end         if windConnection then              windConnection:Disconnect()         end         if petalFolder then              petalFolder:Destroy()         end          activePetals={}     end      _G.PortalVisuals._enableFuncs[name]=enable _G.PortalVisuals._disableFuncs[name]=disable  end

-- [[ Floating Lamps ]]
do     local name="Floating Lamps"local running=false      local maxLamps=7      local lamps={}     local lampFolder=nil      local updateConn      local function createLamp(index)         local char=LocalPlayer.Character          local hrp=char and char:FindFirstChild("HumanoidRootPart")         if not hrp then              return          end         local cap=Instance.new("Part")         cap.Size=Vector3.new(1.4,0.2,1.4)         cap.Material=Enum.Material.SmoothPlastic cap.Color=Color3.fromRGB(200,45,45)         cap.CanCollide=false         cap.CastShadow=false         cap.Anchored=true         cap.Parent=lampFolder         local body=Instance.new("Part")         body.Size=Vector3.new(1.2,1.8,1.2)         body.Material=Enum.Material.Neon body.Color=Color3.fromRGB(255,220,150)         body.Transparency=0.25         body.CanCollide=false         body.CastShadow=false         body.Anchored=true         body.Parent=lampFolder         local gold=Instance.new("Part")         gold.Size=Vector3.new(1.3,0.12,1.3)         gold.Material=Enum.Material.Metal gold.Color=Color3.fromRGB(220,170,50)         gold.CanCollide=false         gold.CastShadow=false         gold.Anchored=true         gold.Parent=lampFolder         local bottom=Instance.new("Part")         bottom.Size=Vector3.new(1.4,0.2,1.4)         bottom.Material=Enum.Material.SmoothPlastic bottom.Color=Color3.fromRGB(200,45,45)         bottom.CanCollide=false         bottom.CastShadow=false         bottom.Anchored=true         bottom.Parent=lampFolder         local fringes={}         for i=1,6 do             local fringe=Instance.new("Part")             fringe.Size=Vector3.new(0.06,0.7,0.06)             fringe.Material=Enum.Material.Fabric fringe.Color=Color3.fromRGB(220,60,60)             fringe.CanCollide=false             fringe.CastShadow=false             fringe.Anchored=true             fringe.Parent=lampFolder table.insert(fringes,fringe)         end         local tassel=Instance.new("Part")         tassel.Size=Vector3.new(0.1,0.9,0.1)         tassel.Material=Enum.Material.Fabric tassel.Color=Color3.fromRGB(200,50,50)         tassel.CanCollide=false         tassel.CastShadow=false         tassel.Anchored=true         tassel.Parent=lampFolder         local flame=Instance.new("Part")         flame.Size=Vector3.new(0.35,0.45,0.35)         flame.Material=Enum.Material.Neon flame.Color=Color3.fromRGB(255,240,180)         flame.CanCollide=false flame.CastShadow=false         flame.Anchored=true flame.Parent=lampFolder         local embers=Instance.new("ParticleEmitter")         embers.Texture="rbxassetid://1426893421"embers.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,200,80)),ColorSequenceKeypoint.new(1,Color3.fromRGB(200,80,20))})         embers.Size=NumberSequence.new(0.04,0)embers.Lifetime=NumberRange.new(0.4,1)         embers.Rate=8 embers.Speed=NumberRange.new(0.3,0.8)         embers.SpreadAngle=Vector2.new(10,10)         embers.Acceleration=Vector3.new(0,1,0)         embers.LightEmission=1 embers.LightInfluence=0         embers.Parent=flame         local hook=Instance.new("Part")         hook.Size=Vector3.new(0.08,0.4,0.08)         hook.Material=Enum.Material.Metal hook.Color=Color3.fromRGB(180,140,40)         hook.CanCollide=false         hook.CastShadow=false         hook.Anchored=true         hook.Parent=lampFolder         local chain=Instance.new("Part")         chain.Size=Vector3.new(0.05,1.5,0.05)         chain.Material=Enum.Material.Metal chain.Color=Color3.fromRGB(160,120,40)         chain.CanCollide=false         chain.CastShadow=false         chain.Anchored=true         chain.Parent=lampFolder         local light=Instance.new("PointLight")         light.Color=Color3.fromRGB(255,200,100)         light.Brightness=5         light.Range=16         light.Shadows=false         light.Parent=flame         local trail=Instance.new("Trail")         trail.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,220,120)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,180,60)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,140,30))}             trail.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(1,1)}                 trail.Lifetime=0.8                 trail.WidthScale=NumberSequence.new{NumberSequenceKeypoint.new(0,0.15),NumberSequenceKeypoint.new(1,0)}                     trail.LightEmission=0.6                     trail.Parent=flame         local att0=Instance.new("Attachment")         att0.Position=Vector3.new(0,0.3,0)         att0.Parent=flame         local att1=Instance.new("Attachment")         att1.Position=Vector3.new(0,-0.3,0)         att1.Parent=flame trail.Attachment0=att0 trail.Attachment1=att1         local angle=(index/maxLamps)*math.pi*2          local radius=35+math.random(0,150)/10          local height=12+math.random(0,100)/10          local startPos=hrp.Position+Vector3.new(math.cos(angle)*radius,height,math.sin(angle)*radius)         local p=startPos hook.CFrame=CFrame.new(p+Vector3.new(0,2.2,0))         chain.CFrame=CFrame.new(p+Vector3.new(0,1.2,0))         cap.CFrame=CFrame.new(p+Vector3.new(0,0.9,0))         body.CFrame=CFrame.new(p)         gold.CFrame=CFrame.new(p)         bottom.CFrame=CFrame.new(p-Vector3.new(0,0.9,0))         flame.CFrame=CFrame.new(p+Vector3.new(0,0.1,0))         tassel.CFrame=CFrame.new(p-Vector3.new(0,1.4,0))         for i,fringe in ipairs(fringes)do             local a=(i-1)*math.pi/3             fringe.CFrame=CFrame.new(p-Vector3.new(0,1.1,0)+Vector3.new(math.cos(a)*0.5,0,math.sin(a)*0.5))         end          table.insert(lamps,{cap=cap,body=body,gold=gold,bottom=bottom,fringes=fringes,tassel=tassel,flame=flame,hook=hook,chain=chain,light=light,trail=trail,angle=angle,radius=radius,baseHeight=height,bobPhase=math.random(0,1000)/100,bobSpeed=math.random(15,35)/100,bobAmp=math.random(60,120)/100,orbitSpeed=math.random(6,15)/100,orbitDir=math.random()>0.5 and 1 or-1,swayPhase=math.random(0,1000)/100,flamePhase=math.random(0,1000)/100,fringePhase=math.random(0,1000)/100,targetPos=startPos,currentPos=startPos,velocity=Vector3.zero,accel=Vector3.zero,})     end     local function onUpdate(dt)         local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")         if not hrp then              return          end         local time=tick()         local playerPos=hrp.Position          for _,l in ipairs(lamps)do             if not l.flame or not l.flame.Parent then                  continue              end              l.angle=l.angle+dt*l.orbitSpeed*l.orbitDir              local roseT=time*0.12+l.swayPhase              local roseX=math.sin(roseT*2)*math.cos(roseT*0.6)*1.5              local roseZ=math.sin(roseT*2)*math.sin(roseT*0.6)*1.5              local bob=math.sin(time*l.bobSpeed+l.bobPhase)*l.bobAmp              local drift=math.sin(time*0.1+l.swayPhase)*0.5              local targetX=playerPos.X+math.cos(l.angle)*l.radius+roseX              local targetZ=playerPos.Z+math.sin(l.angle)*l.radius+roseZ              local targetY=playerPos.Y+l.baseHeight+bob+drift l.targetPos=Vector3.new(targetX,targetY,targetZ)             local diff=l.targetPos-l.currentPos              local omega=2.0              local zeta=0.9             l.accel=diff*(omega*omega)-l.velocity*(zeta*omega*2)             l.velocity=l.velocity+l.accel*dt l.currentPos=l.currentPos+l.velocity*dt             local dist=(l.currentPos-playerPos).Magnitude              if dist>55 then                     l.currentPos=playerPos+(l.currentPos-playerPos).Unit*55                     l.velocity=l.velocity*0.3             end             local pos=l.currentPos              local tiltX=math.clamp(l.velocity.Z*5,-6,6)             local tiltZ=math.clamp(-l.velocity.X*5,-6,6)             local swayTilt=math.sin(time*0.35+l.swayPhase)*1.5              local flameJump=math.sin(time*1.8+l.flamePhase)*0.1              local flameSway=math.sin(time*2.8+l.flamePhase*1.2)*0.05              local flicker=1+math.sin(time*5+l.flamePhase)*0.07+math.sin(time*9)*0.03              local fringeSwing=math.sin(time*2+l.fringePhase)*8              local cf=CFrame.new(pos)*CFrame.Angles(math.rad(tiltX+swayTilt),0,math.rad(tiltZ))             l.hook.CFrame=cf*CFrame.new(0,2.2,0)             l.chain.CFrame=cf*CFrame.new(0,1.2,0)             l.cap.CFrame=cf*CFrame.new(0,0.9,0)             l.body.CFrame=cf l.gold.CFrame=cf l.bottom.CFrame=cf*CFrame.new(0,-0.9,0)             l.flame.CFrame=cf*CFrame.new(flameSway,0.1+flameJump,0)*CFrame.Angles(0,time,0)             l.tassel.CFrame=cf*CFrame.new(0,-1.4,0)*CFrame.Angles(math.rad(fringeSwing*0.5),0,0)             for i,fringe in ipairs(l.fringes)do                 local a=(i-1)*math.pi/3+l.angle*0.1                  local swing=math.sin(time*2.5+l.fringePhase+i)*12                 fringe.CFrame=cf*CFrame.new(math.cos(a)*0.5,-1.1,math.sin(a)*0.5)*CFrame.Angles(math.rad(swing),0,0)             end              l.light.Brightness=5*flicker l.light.Range=16+math.sin(time)*2              local warmth=math.sin(time*0.5+l.swayPhase)*10             l.light.Color=Color3.fromRGB(255,math.clamp(200+warmth,190,215),math.clamp(100+warmth*0.3,92,110))             l.flame.Color=Color3.fromRGB(255,math.clamp(240+warmth*0.1,235,248),math.clamp(180+warmth*0.1,175,190))             l.body.Color=Color3.fromRGB(255,math.clamp(220+warmth*0.2,212,230),math.clamp(150+warmth*0.3,142,162))         end     end     local function enable()         if running then              return          end          running=true          local old=Workspace:FindFirstChild("PortalVisual_Lamps")         if old then              old:Destroy()         end             lampFolder=Instance.new("Folder")             lampFolder.Name="PortalVisual_Lamps"lampFolder.Parent=Workspace lamps={}         for i=1,maxLamps do              createLamp(i)         end          updateConn=RunService.RenderStepped:Connect(function(dt)
            if StepEffect("FloatingLamps", 1/60) then onUpdate(dt) end
        end)     end     local function disable()     running=false         if updateConn then              updateConn:Disconnect()         end         if lampFolder then              lampFolder:Destroy()         end          lamps={}     end      _G.PortalVisuals._enableFuncs[name]=enable _G.PortalVisuals._disableFuncs[name]=disable  end

-- [[ Butterflies ]]
do     local name="Butterflies"local running=false      local CONFIG={NumButterflies=17,MinRadius=26.0,MaxRadius=34.0,BodySize=Vector3.new(0.14,0.14,0.72),ForeInnerSize=Vector3.new(0.42,0.024,0.6),ForeOuterSize=Vector3.new(0.34,0.018,0.48),HindSize=Vector3.new(0.36,0.018,0.42),MinHeight=8,MaxHeight=14,MinFlapSpeed=8,MaxFlapSpeed=13,}     local butterflyFolder=nil      local activeConnection=nil      local butterflies={}     local characterConn=nil      local function cleanup()         if activeConnection then                 activeConnection:Disconnect()                 activeConnection=nil         end         if butterflyFolder then                 butterflyFolder:Destroy()                 butterflyFolder=nil         end          table.clear(butterflies)     end     local function createButterfly()         local group=Instance.new("Model")         group.Name="BendingButterfly"group.Parent=butterflyFolder         local scale=0.6+math.random()*0.8          local startColor=Color3.fromHSV(math.random(),0.85,1)         local contrastColor=Color3.fromHSV((math.random()+0.5)%1,0.9,1)         local darkColor=Color3.fromHSV(math.random(),0.95,0.4)         local body=Instance.new("Part")         body.Name="Body"body.Size=CONFIG.BodySize*scale body.Color=Color3.fromRGB(25,25,25)         body.Material=Enum.Material.SmoothPlastic body.CanCollide=false         body.Anchored=true         body.CastShadow=false         body.Parent=group         local bodySegment1=Instance.new("Part")         bodySegment1.Name="BodySegment1"bodySegment1.Size=Vector3.new(0.08*scale,0.08*scale,0.25*scale)         bodySegment1.Color=Color3.fromRGB(35,35,35)         bodySegment1.Material=Enum.Material.SmoothPlastic bodySegment1.CanCollide=false         bodySegment1.Anchored=true         bodySegment1.CastShadow=false         bodySegment1.Parent=group         local bodySegment2=Instance.new("Part")         bodySegment2.Name="BodySegment2"bodySegment2.Size=Vector3.new(0.06*scale,0.06*scale,0.18*scale)         bodySegment2.Color=Color3.fromRGB(30,30,30)         bodySegment2.Material=Enum.Material.SmoothPlastic bodySegment2.CanCollide=false         bodySegment2.Anchored=true         bodySegment2.CastShadow=false         bodySegment2.Parent=group         local function createDetailedWing(side,wingType,baseSize,mat)             local s=side=="L"and-1 or 1              local prefix=side=="L"and"Left"or"Right"local parts={}             local base=Instance.new("Part")             base.Name=prefix..wingType.."Base"base.Size=baseSize*scale base.Material=mat or Enum.Material.Neon base.CanCollide=false             base.Anchored=true             base.CastShadow=false             base.Parent=group parts.Base=base             local inner=Instance.new("Part")             inner.Name=prefix..wingType.."Inner"inner.Size=Vector3.new(baseSize.X*0.85*scale,baseSize.Y*1.5*scale,baseSize.Z*0.7*scale)             inner.Material=mat or Enum.Material.Neon inner.CanCollide=false             inner.Anchored=true             inner.CastShadow=false             inner.Parent=group parts.Inner=inner             local tip=Instance.new("Part")             tip.Name=prefix..wingType.."Tip"tip.Size=Vector3.new(baseSize.X*0.5*scale,baseSize.Y*2*scale,baseSize.Z*0.4*scale)             tip.Material=mat or Enum.Material.Neon tip.CanCollide=false             tip.Anchored=true             tip.CastShadow=false             tip.Parent=group parts.Tip=tip             local edge=Instance.new("Part")             edge.Name=prefix..wingType.."Edge"edge.Size=Vector3.new(baseSize.X*0.3*scale,baseSize.Y*1.8*scale,baseSize.Z*0.25*scale)             edge.Material=Enum.Material.Neon edge.Color=darkColor edge.CanCollide=false             edge.Anchored=true             edge.CastShadow=false             edge.Parent=group parts.Edge=edge return parts         end         local leftForeWing=createDetailedWing("L","ForeWing",CONFIG.ForeInnerSize)         local leftHindWing=createDetailedWing("L","HindWing",CONFIG.HindSize)         local rightForeWing=createDetailedWing("R","ForeWing",CONFIG.ForeInnerSize)         local rightHindWing=createDetailedWing("R","HindWing",CONFIG.HindSize)         local function createWingVein(side,wingType,veinLength)             local s=side=="L"and-1 or 1              local prefix=side=="L"and"Left"or"Right"local vein=Instance.new("Part")             vein.Name=prefix..wingType.."Vein"vein.Size=Vector3.new(0.008*scale,veinLength*scale,0.008*scale)             vein.Material=Enum.Material.SmoothPlastic vein.Color=darkColor vein.CanCollide=false             vein.Anchored=true             vein.CastShadow=false             vein.Parent=group return vein         end         local leftForeVein1=createWingVein("L","ForeWingVein1",0.35)         local leftForeVein2=createWingVein("L","ForeWingVein2",0.28)         local leftHindVein1=createWingVein("L","HindWingVein1",0.25)         local rightForeVein1=createWingVein("R","ForeWingVein1",0.35)         local rightForeVein2=createWingVein("R","ForeWingVein2",0.28)         local rightHindVein1=createWingVein("R","HindWingVein1",0.25)         local function createWingSpot(side,wingType,spotSize,spotY)             local s=side=="L"and-1 or 1              local prefix=side=="L"and"Left"or"Right"local spot=Instance.new("Part")             spot.Name=prefix..wingType.."Spot"spot.Size=Vector3.new(spotSize*scale,0.006*scale,spotSize*scale)             spot.Shape=Enum.PartType.Cylinder spot.Material=Enum.Material.Neon spot.Color=contrastColor spot.CanCollide=false             spot.Anchored=true             spot.CastShadow=false             spot.Parent=group return spot         end         local leftForeSpot1=createWingSpot("L","Fore",0.12,0)         local leftForeSpot2=createWingSpot("L","Fore",0.08,0.15)         local leftHindSpot1=createWingSpot("L","Hind",0.1,0)         local rightForeSpot1=createWingSpot("R","Fore",0.12,0)         local rightForeSpot2=createWingSpot("R","Fore",0.08,0.15)         local rightHindSpot1=createWingSpot("R","Hind",0.1,0)         local leftAntenna=Instance.new("Part")         leftAntenna.Name="LeftAntenna"leftAntenna.Size=Vector3.new(0.015*scale,0.3*scale,0.015*scale)         leftAntenna.Material=Enum.Material.SmoothPlastic leftAntenna.Color=Color3.fromRGB(30,30,30)         leftAntenna.CanCollide=false         leftAntenna.Anchored=true         leftAntenna.CastShadow=false         leftAntenna.Parent=group         local leftAntennaTip=Instance.new("Part")         leftAntennaTip.Name="LeftAntennaTip"leftAntennaTip.Size=Vector3.new(0.04*scale,0.04*scale,0.04*scale)         leftAntennaTip.Shape=Enum.PartType.Ball leftAntennaTip.Material=Enum.Material.Neon leftAntennaTip.Color=startColor leftAntennaTip.CanCollide=false         leftAntennaTip.Anchored=true         leftAntennaTip.CastShadow=false         leftAntennaTip.Parent=group         local rightAntenna=Instance.new("Part")         rightAntenna.Name="RightAntenna"rightAntenna.Size=Vector3.new(0.015*scale,0.3*scale,0.015*scale)         rightAntenna.Material=Enum.Material.SmoothPlastic rightAntenna.Color=Color3.fromRGB(30,30,30)         rightAntenna.CanCollide=false         rightAntenna.Anchored=true         rightAntenna.CastShadow=false         rightAntenna.Parent=group         local rightAntennaTip=Instance.new("Part")         rightAntennaTip.Name="RightAntennaTip"rightAntennaTip.Size=Vector3.new(0.04*scale,0.04*scale,0.04*scale)         rightAntennaTip.Shape=Enum.PartType.Ball rightAntennaTip.Material=Enum.Material.Neon rightAntennaTip.Color=startColor rightAntennaTip.CanCollide=false         rightAntennaTip.Anchored=true         rightAntennaTip.CastShadow=false         rightAntennaTip.Parent=group         local light=Instance.new("PointLight")         light.Color=startColor light.Brightness=1.5*scale light.Range=8.0*scale light.Shadows=false         light.Parent=body         local glow=Instance.new("Part")         glow.Name="BodyGlow"glow.Size=Vector3.new(0.2*scale,0.2*scale,0.9*scale)         glow.Shape=Enum.PartType.Ball glow.Material=Enum.Material.Neon glow.Color=startColor glow.Transparency=0.7         glow.CanCollide=false         glow.Anchored=true         glow.CastShadow=false         glow.Parent=group         local pollen=Instance.new("ParticleEmitter")         pollen.Name="Pollen"pollen.Rate=5         pollen.Lifetime=NumberRange.new(1.5,2.5)         pollen.Speed=NumberRange.new(0.15,0.5)         pollen.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.15*scale),NumberSequenceKeypoint.new(0.5,0.1*scale),NumberSequenceKeypoint.new(1,0)})             pollen.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.05),NumberSequenceKeypoint.new(0.7,0.3),NumberSequenceKeypoint.new(1,1)})                 pollen.LightEmission=1.0                 pollen.LightInfluence=0                 pollen.Color=ColorSequence.new(startColor)                 pollen.Acceleration=Vector3.new(0,-0.2,0)                 pollen.SpreadAngle=Vector2.new(20,20)                 pollen.Parent=body         local sparkle=Instance.new("ParticleEmitter")         sparkle.Name="Sparkles"sparkle.Rate=4         sparkle.Lifetime=NumberRange.new(0.8,1.5)         sparkle.Speed=NumberRange.new(0.3,0.8)         sparkle.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.08*scale),NumberSequenceKeypoint.new(0.5,0.05*scale),NumberSequenceKeypoint.new(1,0)})             sparkle.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(1,1)})                 sparkle.LightEmission=1.5                 sparkle.LightInfluence=0                 sparkle.Color=ColorSequence.new(contrastColor)                 sparkle.Acceleration=Vector3.new(0,0.5,0)                 sparkle.SpreadAngle=Vector2.new(360,360)                 sparkle.Parent=glow         local att0=Instance.new("Attachment",body)         att0.Position=Vector3.new(0,0,-(CONFIG.BodySize.Z*scale)/2)         local att1=Instance.new("Attachment",body)         att1.Position=Vector3.new(0,0,(CONFIG.BodySize.Z*scale)/2)         local trail=Instance.new("Trail",body)         trail.Attachment0=att0 trail.Attachment1=att1 trail.Color=ColorSequence.new(startColor)         trail.Lifetime=0.9         trail.Transparency=NumberSequence.new(0.05,0.7)         trail.WidthScale=NumberSequence.new(0.8*scale,0)         trail.LightEmission=1.5 trail.LightInfluence=0 return{Group=group,Body=body,BodySegment1=bodySegment1,BodySegment2=bodySegment2,Glow=glow,Light=light,Trail=trail,Pollen=pollen,LeftForeWing=leftForeWing,LeftHindWing=leftHindWing,RightForeWing=rightForeWing,RightHindWing=rightHindWing,LeftForeSpot1=leftForeSpot1,LeftForeSpot2=leftForeSpot2,LeftHindSpot1=leftHindSpot1,RightForeSpot1=rightForeSpot1,RightForeSpot2=rightForeSpot2,RightHindSpot1=rightHindSpot1,LeftForeVein1=leftForeVein1,LeftForeVein2=leftForeVein2,LeftHindVein1=leftHindVein1,RightForeVein1=rightForeVein1,RightForeVein2=rightForeVein2,RightHindVein1=rightHindVein1,LeftAntenna=leftAntenna,LeftAntennaTip=leftAntennaTip,RightAntenna=rightAntenna,RightAntennaTip=rightAntennaTip,InnerOffset=(CONFIG.ForeInnerSize.X*scale)/2,OuterOffset=(CONFIG.ForeOuterSize.X*scale)/2,HindOffset=(CONFIG.HindSize.X*scale)/2,ForeZShift=-0.12*scale,HindZShift=0.18*scale,Scale=scale,StartColor=startColor,ContrastColor=contrastColor,Angle=math.random()*math.pi*2,Speed=0.08+math.random()*0.12,Radius=CONFIG.MinRadius+(math.random()*(CONFIG.MaxRadius-CONFIG.MinRadius)),HeightOffset=CONFIG.MinHeight+(math.random()*(CONFIG.MaxHeight-CONFIG.MinHeight)),State="Orbit",TargetLeader=nil,StateTimer=math.random(5,15),SeedX=math.random(1,100000),SeedY=math.random(1,100000),SeedZ=math.random(1,100000),TimeAccumulator=math.random()*100,TimeOffset=math.random()*40,FlapSpeed=CONFIG.MinFlapSpeed+math.random()*(CONFIG.MaxFlapSpeed-CONFIG.MinFlapSpeed),GlideSpeed=0.15+math.random()*0.20,LastPosition=Vector3.new(),CurrentPosition=Vector3.new(),SmoothedDirection=Vector3.new(0,0,-1),CurrentCFrame=CFrame.new()}     end     local function startEffect(character)     cleanup()         local hrp=character:WaitForChild("HumanoidRootPart",5)         if not hrp then              return          end             butterflyFolder=Instance.new("Folder")             butterflyFolder.Name="ProceduralButterflies_Premium"butterflyFolder.Parent=workspace         for i=1,CONFIG.NumButterflies do             local b=createButterfly()             local startX=math.cos(b.Angle)*b.Radius              local startZ=math.sin(b.Angle)*b.Radius              local startPos=hrp.Position+Vector3.new(startX,b.HeightOffset,startZ)             b.LastPosition=startPos b.CurrentPosition=startPos b.CurrentCFrame=CFrame.new(startPos)             table.insert(butterflies,b)         end          activeConnection=RunService.RenderStepped:Connect(function(dt)             local currentHRP=character:FindFirstChild("HumanoidRootPart")             if not currentHRP then                  return              end             local hrpPos=currentHRP.Position              for _,b in ipairs(butterflies)do                  b.TimeAccumulator=b.TimeAccumulator+dt                  local localTime=b.TimeAccumulator b.StateTimer=b.StateTimer-dt                  if b.StateTimer<=0 then                     if b.State=="Orbit"then                         if math.random()<0.30 and#butterflies>1 then                              local candidates={}                             for _,other in ipairs(butterflies)do                                 if other~=b and other.State=="Orbit"then                                      table.insert(candidates,other)                                 end                             end                             if#candidates>0 then                                  b.State="Chase"b.TargetLeader=candidates[math.random(#candidates)]b.StateTimer=4+math.random()*6                              else                                  b.StateTimer=4+math.random()*8                              end                         else                              b.StateTimer=4+math.random()*8                          end                     else                             b.State="Orbit"b.TargetLeader=nil                             b.StateTimer=5+math.random()*10                     end                 end                 local targetPos b.Angle=b.Angle+(b.Speed*dt)                 local noiseX=math.noise(localTime*0.30,b.SeedX)*5.5                  local noiseY=math.noise(localTime*0.20,b.SeedY)*3.5                  local noiseZ=math.noise(localTime*0.30,b.SeedZ)*5.5                  if b.State=="Chase"and b.TargetLeader and b.TargetLeader.Group and b.TargetLeader.Group.Parent then                     local leaderPos=b.TargetLeader.CurrentPosition                      local chaseRadius=4.0*b.Scale                      local tX=math.cos(b.Angle*1.6)*chaseRadius                      local tZ=math.sin(b.Angle*1.6)*chaseRadius                      local tY=math.sin(localTime*2.0+b.TimeOffset)*(1.8*b.Scale)                     targetPos=leaderPos+Vector3.new(tX,tY,tZ)                 else                     if b.State=="Chase"then                             b.State="Orbit"b.TargetLeader=nil                             b.StateTimer=5                     end                     local targetX=math.cos(b.Angle)*b.Radius+noiseX                      local targetZ=math.sin(b.Angle)*b.Radius+noiseZ                      local targetY=b.HeightOffset+noiseY targetPos=hrpPos+Vector3.new(targetX,targetY,targetZ)                 end                 local posAlpha=1-math.exp(-1.0*dt)                 b.CurrentPosition=b.CurrentPosition:Lerp(targetPos,posAlpha)                 local rawDirection=(b.CurrentPosition-b.LastPosition)                 if rawDirection.Magnitude>0.0005 then                     local dirAlpha=1-math.exp(-3.5*dt)                     b.SmoothedDirection=b.SmoothedDirection:Lerp(rawDirection.Unit,dirAlpha)                     local rawCF=CFrame.lookAt(b.CurrentPosition,b.CurrentPosition+b.SmoothedDirection)                     local roll=math.sin(localTime*1.5+b.TimeOffset)*math.rad(15)                     local pitch=math.cos(localTime*1.0+b.TimeOffset)*math.rad(8)                     local targetCF=rawCF*CFrame.Angles(pitch,0,roll)                     local rotAlpha=1-math.exp(-2.0*dt)                     b.CurrentCFrame=b.CurrentCFrame:Lerp(targetCF,rotAlpha)                     b.Body.CFrame=b.CurrentCFrame                     local hue=(localTime*0.03+b.TimeOffset*0.05)%1                      local dynamicColor=Color3.fromHSV(hue,0.85,1)                     local contrastColor=Color3.fromHSV((hue+0.5)%1,0.95,1)                     local function setWingColor(wingTable,color)                         if wingTable.Base then                              wingTable.Base.Color=color                          end                         if wingTable.Inner then                              wingTable.Inner.Color=color                          end                         if wingTable.Tip then                              wingTable.Tip.Color=color                          end                         if wingTable.Edge then                              wingTable.Edge.Color=b.ContrastColor                          end                     end                         setWingColor(b.LeftForeWing,dynamicColor)                         setWingColor(b.LeftHindWing,dynamicColor)                         setWingColor(b.RightForeWing,dynamicColor)                         setWingColor(b.RightHindWing,dynamicColor)                     if b.LeftForeSpot1 then                          b.LeftForeSpot1.Color=contrastColor                      end                     if b.LeftForeSpot2 then                          b.LeftForeSpot2.Color=contrastColor                      end                     if b.LeftHindSpot1 then                          b.LeftHindSpot1.Color=contrastColor                      end                     if b.RightForeSpot1 then                          b.RightForeSpot1.Color=contrastColor                      end                     if b.RightForeSpot2 then                          b.RightForeSpot2.Color=contrastColor                      end                     if b.RightHindSpot1 then                          b.RightHindSpot1.Color=contrastColor                      end                         b.Light.Color=dynamicColor b.Glow.Color=dynamicColor b.Trail.Color=ColorSequence.new(dynamicColor)                         b.Pollen.Color=ColorSequence.new(dynamicColor)                     if b.LeftAntennaTip then                          b.LeftAntennaTip.Color=dynamicColor                      end                     if b.RightAntennaTip then                          b.RightAntennaTip.Color=dynamicColor                      end                     local indTime=localTime+b.TimeOffset                      local glideEnvelope=math.clamp(math.sin(indTime*b.GlideSpeed)*0.75+0.6,0.12,1.0)                     local flapAngle=math.sin(indTime*b.FlapSpeed)*math.rad(42)*glideEnvelope                      local bendAngle=math.cos(indTime*b.FlapSpeed)*math.rad(28)*glideEnvelope                      local hindFlapAngle=flapAngle*0.75                      local function applyWingTransform(wingTable,baseCF,isLeft)                         if not wingTable or not wingTable.Base then                              return                          end                         local s=isLeft and-1 or 1                          local angle=isLeft and flapAngle or-flapAngle                          local bend=isLeft and-bendAngle or bendAngle                          if wingTable.Base then                              wingTable.Base.CFrame=baseCF*CFrame.new(s*b.InnerOffset*0.5,0,0)*CFrame.Angles(0,0,angle*0.3)                         end                         if wingTable.Inner then                              wingTable.Inner.CFrame=baseCF*CFrame.new(s*b.InnerOffset,0,0)*CFrame.Angles(0,0,angle)                         end                         if wingTable.Tip then                              wingTable.Tip.CFrame=baseCF*CFrame.new(s*b.InnerOffset*1.8,0,0)*CFrame.Angles(0,0,angle*1.3)                         end                         if wingTable.Edge then                              wingTable.Edge.CFrame=baseCF*CFrame.new(s*b.InnerOffset*2.2,0,0)*CFrame.Angles(0,0,angle*1.6)                         end                     end                     local function applyHindWingTransform(wingTable,baseCF,isLeft)                         if not wingTable or not wingTable.Base then                              return                          end                         local s=isLeft and-1 or 1                          local angle=isLeft and hindFlapAngle or-hindFlapAngle                          if wingTable.Base then                              wingTable.Base.CFrame=baseCF*CFrame.new(s*b.HindOffset*0.4,0,b.HindZShift*0.5)*CFrame.Angles(0,0,angle*0.5)                         end                         if wingTable.Inner then                              wingTable.Inner.CFrame=baseCF*CFrame.new(s*b.HindOffset*0.8,0,b.HindZShift*0.8)*CFrame.Angles(0,0,angle*0.8)                         end                         if wingTable.Tip then                              wingTable.Tip.CFrame=baseCF*CFrame.new(s*b.HindOffset,0,b.HindZShift)*CFrame.Angles(0,0,angle)                         end                         if wingTable.Edge then                              wingTable.Edge.CFrame=baseCF*CFrame.new(s*b.HindOffset*1.3,0,b.HindZShift*1.2)*CFrame.Angles(0,0,angle*1.3)                         end                     end                     local function applySpotTransform(spot,parentCF,offset,isLeft)                         if not spot then                              return                          end                         local s=isLeft and-1 or 1                         spot.CFrame=parentCF*CFrame.new(s*offset,0.01*b.Scale,0)*CFrame.Angles(math.rad(90),0,0)                     end                     local foreBaseCF=b.CurrentCFrame*CFrame.new(0,0,b.ForeZShift)                     applyWingTransform(b.LeftForeWing,foreBaseCF,true)                     applyWingTransform(b.RightForeWing,foreBaseCF,false)                     applySpotTransform(b.LeftForeSpot1,b.LeftForeWing.Tip.CFrame,0.05,true)                     applySpotTransform(b.LeftForeSpot2,b.LeftForeWing.Edge.CFrame,0.03,true)                     applySpotTransform(b.RightForeSpot1,b.RightForeWing.Tip.CFrame,0.05,false)                     applySpotTransform(b.RightForeSpot2,b.RightForeWing.Edge.CFrame,0.03,false)                     local hindBaseCF=b.CurrentCFrame*CFrame.new(0,0,b.HindZShift)                     applyHindWingTransform(b.LeftHindWing,hindBaseCF,true)                     applyHindWingTransform(b.RightHindWing,hindBaseCF,false)                     applySpotTransform(b.LeftHindSpot1,b.LeftHindWing.Tip.CFrame,0.04,true)                     applySpotTransform(b.RightHindSpot1,b.RightHindWing.Tip.CFrame,0.04,false)                     if b.LeftAntenna then                         local antennaBase=b.CurrentCFrame*CFrame.new(-0.05*b.Scale,0.25*b.Scale,-0.35*b.Scale)                         b.LeftAntenna.CFrame=antennaBase*CFrame.Angles(math.sin(localTime*2+b.TimeOffset)*0.2,0,0.3)                         if b.LeftAntennaTip then                              b.LeftAntennaTip.CFrame=b.LeftAntenna.CFrame*CFrame.new(0,0.15*b.Scale,0)                         end                     end                     if b.RightAntenna then                         local antennaBase=b.CurrentCFrame*CFrame.new(0.05*b.Scale,0.25*b.Scale,-0.35*b.Scale)                         b.RightAntenna.CFrame=antennaBase*CFrame.Angles(math.sin(localTime*2.5+b.TimeOffset)*0.2,0,-0.3)                         if b.RightAntennaTip then                              b.RightAntennaTip.CFrame=b.RightAntenna.CFrame*CFrame.new(0,0.15*b.Scale,0)                         end                     end                     if b.BodySegment1 then                          b.BodySegment1.CFrame=b.CurrentCFrame*CFrame.new(0,0.02*b.Scale,-0.2*b.Scale)*CFrame.Angles(0,0,math.sin(localTime*1.5)*0.05)                     end                     if b.BodySegment2 then                          b.BodySegment2.CFrame=b.CurrentCFrame*CFrame.new(0,-0.01*b.Scale,-0.32*b.Scale)*CFrame.Angles(0,0,math.sin(localTime*2)*0.03)                     end                     if b.Glow then                          b.Glow.CFrame=b.CurrentCFrame                      end                 end                  b.LastPosition=b.CurrentPosition              end         end)     end     local function enable()         if running then              return          end          running=true          if LocalPlayer.Character then              startEffect(LocalPlayer.Character)         end          characterConn=LocalPlayer.CharacterAdded:Connect(function(char)             if running then                  startEffect(char)             end         end)     end     local function disable()     running=false         if characterConn then                 characterConn:Disconnect()                 characterConn=nil         end          cleanup()     end      _G.PortalVisuals._enableFuncs[name]=enable _G.PortalVisuals._disableFuncs[name]=disable  end

-- [[ Birds ]]
do     local name="Birds"local running=false      local heartbeatConn,charConn      local birdFolder      local renderConnection      local birdData,activePoops,activeSplats={},{},{}     local BIRD_COUNT=6      local SCALE=2.5      local BIRD_TYPES={"Flapper","Glider","Diver"}     local function lerp(a,b,t)     return a+(b-a)*t     end     local function selectBehavior(data)         local pool          if data.birdType=="Glider"then              pool={"Soaring","Soaring","Flapping"}         elseif data.birdType=="Diver"then              pool={"Swooping","Swooping","Flapping"}         else              pool={"Flapping","Flapping","Soaring","Swooping"}         end          data.state=pool[math.random(#pool)]         local dur=math.random(10,22)         data.behaviorTimer=dur data.behaviorDuration=dur data.targetRadius=math.random(75,125)         data.targetHeight=math.random(50,90)     end     local function makePart(model,name,size,color,mat)         local p=Instance.new("Part")         p.Name=name p.Size=size*SCALE p.Color=color p.Material=mat or Enum.Material.SmoothPlastic p.Anchored=true         p.CanCollide=false         p.CanTouch=false         p.CanQuery=false         p.Parent=model return p     end     local function createBird(birdType)         local m=Instance.new("Model")         m.Name="Bird_"..birdType         local palette={Flapper={body=Color3.fromRGB(248,248,248),mid=Color3.fromRGB(195,195,195),dark=Color3.fromRGB(60,60,60),beak=Color3.fromRGB(255,120,0),eye=Color3.fromRGB(15,15,15),},Glider={body=Color3.fromRGB(210,230,255),mid=Color3.fromRGB(140,170,210),dark=Color3.fromRGB(40,70,130),beak=Color3.fromRGB(255,200,0),eye=Color3.fromRGB(10,10,10),},Diver={body=Color3.fromRGB(30,30,30),mid=Color3.fromRGB(80,80,80),dark=Color3.fromRGB(200,200,200),beak=Color3.fromRGB(255,80,0),eye=Color3.fromRGB(200,0,0),},}         local c=palette[birdType]         local function P(n,sz,col,mat)         return makePart(m,n,sz,col,mat)         end         local body=P("Body",Vector3.new(0.65,0.50,2.0),c.body)         local belly=P("Belly",Vector3.new(0.70,0.40,1.2),Color3.fromRGB(255,255,245))         local back=P("Back",Vector3.new(0.60,0.18,1.6),c.mid)         local chest=P("Chest",Vector3.new(0.75,0.60,1.0),c.body)         local neck=P("Neck",Vector3.new(0.35,0.35,0.60),c.body)         local head=P("Head",Vector3.new(0.48,0.48,0.48),c.body)         local crest=P("Crest",Vector3.new(0.10,0.24,0.48),c.mid)         local eyeL=P("EyeL",Vector3.new(0.09,0.09,0.09),c.eye,Enum.Material.Glass)         local eyeR=P("EyeR",Vector3.new(0.09,0.09,0.09),c.eye,Enum.Material.Glass)         local pupilL=P("PupilL",Vector3.new(0.04,0.04,0.04),Color3.fromRGB(255,255,255),Enum.Material.Neon)         local pupilR=P("PupilR",Vector3.new(0.04,0.04,0.04),Color3.fromRGB(255,255,255),Enum.Material.Neon)         local beakU=P("BeakU",Vector3.new(0.18,0.13,0.52),c.beak)         local beakL=P("BeakL",Vector3.new(0.14,0.07,0.46),c.beak)         local beakTip=P("BeakTip",Vector3.new(0.10,0.08,0.20),Color3.fromRGB(200,80,0))         local nostril=P("Nostril",Vector3.new(0.06,0.04,0.16),Color3.fromRGB(180,60,0))         local thighL=P("ThighL",Vector3.new(0.14,0.28,0.14),c.beak)         local shinL=P("ShinL",Vector3.new(0.10,0.22,0.10),c.beak)         local thighR=P("ThighR",Vector3.new(0.14,0.28,0.14),c.beak)         local shinR=P("ShinR",Vector3.new(0.10,0.22,0.10),c.beak)         local tailC=P("TailC",Vector3.new(0.50,0.03,1.30),c.mid)         local tailL=P("TailL",Vector3.new(0.40,0.03,1.20),c.mid)         local tailR=P("TailR",Vector3.new(0.40,0.03,1.20),c.mid)         local tailLL=P("TailLL",Vector3.new(0.28,0.02,1.00),c.dark)         local tailRR=P("TailRR",Vector3.new(0.28,0.02,1.00),c.dark)         local function makeWing(side)             local s=side=="L"and-1 or 1              local prefix=side=="L"and"Left"or"Right"return{Inner=P(prefix.."Inner",Vector3.new(0.85,0.06,0.72),c.body),Mid=P(prefix.."Mid",Vector3.new(1.05,0.05,0.62),c.mid),Outer=P(prefix.."Outer",Vector3.new(0.92,0.04,0.52),c.dark),Tip=P(prefix.."Tip",Vector3.new(0.55,0.03,0.40),c.dark),Feat1=P(prefix.."Feat1",Vector3.new(0.16,0.02,0.85),c.dark),Feat2=P(prefix.."Feat2",Vector3.new(0.16,0.02,0.75),c.dark),Feat3=P(prefix.."Feat3",Vector3.new(0.14,0.02,0.65),c.mid),Covert=P(prefix.."Covert",Vector3.new(0.70,0.03,0.35),c.mid),}         end         local LW=makeWing("L")         local RW=makeWing("R")         m.PrimaryPart=body m.Parent=birdFolder return{Model=m,Body=body,Belly=belly,Back=back,Chest=chest,Neck=neck,Head=head,Crest=crest,EyeL=eyeL,EyeR=eyeR,PupilL=pupilL,PupilR=pupilR,BeakU=beakU,BeakL=beakL,BeakTip=beakTip,Nostril=nostril,ThighL=thighL,ShinL=shinL,ThighR=thighR,ShinR=shinR,TailC=tailC,TailL=tailL,TailR=tailR,TailLL=tailLL,TailRR=tailRR,LW=LW,RW=RW,}     end     local function createSplat(pos,normal)         local s=Instance.new("Part")         s.Name="BirdPoopSplat"s.Size=Vector3.new(0.8,0.01,0.8)*SCALE*0.4         s.Color=Color3.fromRGB(242,242,242)         s.Material=Enum.Material.SmoothPlastic s.Anchored=true;s.CanCollide=false;s.CanTouch=false;s.CanQuery=false         s.CFrame=CFrame.lookAt(pos,pos+normal)*CFrame.Angles(math.rad(90),0,0)         s.Parent=birdFolder table.insert(activeSplats,{part=s,spawnTime=os.clock(),duration=15})     end     local function applyWing(parts,bodyCF,side,innerA,midA,outerA,tipA,sweep,covertA)         local s=side=="L"and-1 or 1          local W=side=="L"and parts.LW or parts.RW          local innerCF=bodyCF*CFrame.new(s*0.32*SCALE,0.1*SCALE,0)*CFrame.Angles(sweep,0,s*innerA)*CFrame.new(s*0.42*SCALE,0,0)         W.Inner.CFrame=innerCF W.Covert.CFrame=bodyCF*CFrame.new(s*0.28*SCALE,0.14*SCALE,-0.1*SCALE)*CFrame.Angles(sweep*0.5,0,s*innerA*0.6)*CFrame.new(s*0.35*SCALE,0,0)         local midCF=innerCF*CFrame.new(s*0.42*SCALE,0,0)*CFrame.Angles(sweep*0.6,0,s*midA)*CFrame.new(s*0.52*SCALE,0,0)         W.Mid.CFrame=midCF         local outerCF=midCF*CFrame.new(s*0.50*SCALE,0,0)*CFrame.Angles(sweep*0.3,0,s*outerA)*CFrame.new(s*0.46*SCALE,0,0)         W.Outer.CFrame=outerCF         local tipCF=outerCF*CFrame.new(s*0.46*SCALE,0,0)*CFrame.Angles(0,0,s*tipA)*CFrame.new(s*0.28*SCALE,0,0)         W.Tip.CFrame=tipCF         for idx,feat in ipairs({W.Feat1,W.Feat2,W.Feat3})do              feat.CFrame=outerCF*CFrame.new(s*0.46*SCALE,0,0)*CFrame.Angles(0,s*math.rad(-15*idx),0)*CFrame.new(s*(0.42-idx*0.04)*SCALE,0,0)         end     end     local function initBirds()     birdData={}         activePoops={}             activeSplats={}         for i=1,BIRD_COUNT do             local bType=BIRD_TYPES[((i-1)%#BIRD_TYPES)+1]             local r=math.random(80,110)             local h=math.random(55,80)             local data={parts=createBird(bType),birdType=bType,currentRadius=r,targetRadius=r,currentHeight=h,targetHeight=h,angleSpeed=(math.random(32,58)/100)*(math.random(0,1)==0 and 1 or-1),phase=(i/BIRD_COUNT)*math.pi*2+math.random()*0.5,wingSpeed=math.random(8,12),flapAmplitude=math.random(22,34),state="Flapping",behaviorTimer=0,behaviorDuration=1,flapIntensity=1.0,innerAngle=0,midAngle=0,outerAngle=0,outerTipAngle=0,poopTimer=math.random(15,35),}                 selectBehavior(data)                 table.insert(birdData,data)         end     end     local function onHeartbeat(dt)         if not running then              return          end          dt=math.min(dt,0.1)         if not birdFolder or not birdFolder.Parent then              return          end         local char=LocalPlayer.Character          if not char then              return          end         local hrp=char:FindFirstChild("HumanoidRootPart")         if not hrp then              return          end         local center=hrp.Position          local t=os.clock()         local tf=1-math.exp(-2.2*dt)         local tff=1-math.exp(-3.8*dt)         for i=#activePoops,1,-1 do             local p=activePoops[i]p.velocity=p.velocity+Vector3.new(0,-Workspace.Gravity*dt,0)             local disp=p.velocity*dt              local rp=RaycastParams.new()             rp.FilterType=Enum.RaycastFilterType.Exclude rp.FilterDescendantsInstances={birdFolder,char}             local ray=Workspace:Raycast(p.part.Position,disp,rp)             if ray then                  createSplat(ray.Position,ray.Normal)p.part:Destroy();table.remove(activePoops,i)             else                  p.part.Position=p.part.Position+disp                  if p.part.Position.Y<-400 then                      p.part:Destroy();table.remove(activePoops,i)                 end             end         end         for i=#activeSplats,1,-1 do             local s=activeSplats[i]             local age=t-s.spawnTime              if age>s.duration then                  s.part:Destroy();table.remove(activeSplats,i)             elseif s.duration-age<3 then                  s.part.Transparency=1-(s.duration-age)/3              end         end         for _,data in ipairs(birdData)do              data.behaviorTimer-=dt              if data.behaviorTimer<=0 then                  selectBehavior(data)             end              data.poopTimer-=dt              if data.poopTimer<=0 then                  data.poopTimer=math.random(15,35)                 if math.random()<0.4 then                     local pp=Instance.new("Part")                     pp.Shape=Enum.PartType.Ball pp.Size=Vector3.new(0.25,0.25,0.25)*SCALE pp.Color=Color3.fromRGB(240,240,240)                     pp.Material=Enum.Material.SmoothPlastic pp.Anchored=true;pp.CanCollide=false;pp.CanTouch=false;pp.CanQuery=false                     pp.Position=data.parts.TailC.Position pp.Parent=birdFolder                     local spm=data.state=="Swooping"and 1.65 or(data.state=="Soaring"and 0.75 or 1.0)                     local ang=(t*data.angleSpeed*spm)+data.phase                      local rX=data.currentRadius+math.sin(t*0.18+data.phase)*12                      local rZ=data.currentRadius*0.8+math.cos(t*0.25-data.phase)*12                      local tv=Vector3.new(-math.sin(ang)*rX,0,math.cos(ang)*rZ).Unit*(math.abs(data.angleSpeed)*spm*data.currentRadius)                     table.insert(activePoops,{part=pp,velocity=tv+Vector3.new(0,-3,0)})                 end             end                 data.currentRadius=lerp(data.currentRadius,data.targetRadius,tf)                 data.currentHeight=lerp(data.currentHeight,data.targetHeight,tf)             local spm,tfi,swoopY,sweep,chirp=1.0,1.0,0,0,0              local tIn,tMid,tOut,tTip=0,0,0,0              local tailPitch,tailSpread=math.rad(-5),math.rad(6)             local tailFlare=false              local flapT=t*data.wingSpeed              if data.state=="Soaring"then                     tfi=0.04;spm=0.75                     tIn=math.rad(6);tMid=math.rad(-4);tOut=math.rad(-2);tTip=math.rad(-1)             elseif data.state=="Flapping"then                 local intensityMod=data.birdType=="Glider"and 0.6 or(data.birdType=="Diver"and 0.9 or 1.0)                 tfi=(0.7+math.sin(t*1.2)*0.3)*intensityMod spm=1.0                 chirp=math.clamp(math.sin(t*4.5+data.phase),0,1)*math.rad(15)                 local up=math.max(0,math.cos(flapT))                 tIn=math.sin(flapT)*math.rad(data.flapAmplitude)*data.flapIntensity tMid=math.sin(flapT-0.5)*math.rad(data.flapAmplitude*0.95)*data.flapIntensity+up*math.rad(32)*data.flapIntensity tOut=math.sin(flapT-1.0)*math.rad(data.flapAmplitude*0.80)*data.flapIntensity+up*math.rad(48)*data.flapIntensity tTip=math.sin(flapT-1.5)*math.rad(data.flapAmplitude*0.60)*data.flapIntensity+up*math.rad(58)*data.flapIntensity             elseif data.state=="Swooping"then                  tfi=0.04;spm=1.65                  local prog=math.clamp((data.behaviorDuration-data.behaviorTimer)/data.behaviorDuration,0,1)                 swoopY=-math.sin(prog*math.pi)*35                 sweep=math.rad(-16)*math.sin(prog*math.pi)                 local f=math.sin(prog*math.pi)                 tIn=lerp(0,math.rad(-15),f)                 tMid=lerp(0,math.rad(65),f)                 tOut=lerp(0,math.rad(-50),f)                 tTip=lerp(0,math.rad(-70),f)                 if prog>0.45 then                         tailFlare=true                         tailPitch=math.rad(-5)+math.sin(prog*math.pi)*math.rad(-20)                         tailSpread=math.rad(6)+math.sin(prog*math.pi)*math.rad(22)                 end             end                 data.flapIntensity=lerp(data.flapIntensity,tfi,tff)                 data.innerAngle=lerp(data.innerAngle,tIn,tff)                 data.midAngle=lerp(data.midAngle,tMid,tff)                 data.outerAngle=lerp(data.outerAngle,tOut,tff)                 data.outerTipAngle=lerp(data.outerTipAngle,tTip,tff)             local wX=math.sin(t*1.5+data.phase)*0.8              local wY=math.cos(t*1.1)*0.5              local wZ=math.sin(t*1.3+data.phase)*0.8              local angle=(t*data.angleSpeed*spm)+data.phase              local rX=data.currentRadius+math.sin(t*0.18+data.phase)*12+wX              local rZ=data.currentRadius*0.8+math.cos(t*0.25-data.phase)*12+wZ              local birdPos=center+Vector3.new(math.cos(angle)*rX,data.currentHeight+math.sin(t*0.32+data.phase*2)*6+wY+swoopY,math.sin(angle)*rZ)             local dm=data.angleSpeed>0 and 1 or-1              local tangent=Vector3.new(-math.sin(angle)*rX,0,math.cos(angle)*rZ).Unit*dm              local dy=math.cos(t+data.phase)*0.08              if data.state=="Swooping"then                 local prog=math.clamp((data.behaviorDuration-data.behaviorTimer)/data.behaviorDuration,0,1)                 dy=-math.cos(prog*math.pi)*0.45             end             local lookDir=(tangent+Vector3.new(0,dy,0)).Unit              local roll=-0.35*(data.angleSpeed*spm)             local bodyCF=CFrame.lookAt(birdPos,birdPos+lookDir)*CFrame.Angles(0,0,roll)             local p=data.parts p.Body.CFrame=bodyCF p.Belly.CFrame=bodyCF*CFrame.new(0,-0.18*SCALE,-0.1*SCALE)             p.Back.CFrame=bodyCF*CFrame.new(0,0.16*SCALE,0.1*SCALE)             p.Chest.CFrame=bodyCF*CFrame.new(0,0.05*SCALE,-0.3*SCALE)             local neckCF=bodyCF*CFrame.new(0,0.2*SCALE,-1.0*SCALE)*CFrame.Angles(math.rad(15),0,0)             p.Neck.CFrame=neckCF             local headCF=neckCF*CFrame.new(0,0.1*SCALE,-0.35*SCALE)*CFrame.Angles(0,0,-roll*0.65)             p.Head.CFrame=headCF p.Crest.CFrame=headCF*CFrame.new(0,0.30*SCALE,0.15*SCALE)*CFrame.Angles(math.rad(-18),0,0)             p.EyeL.CFrame=headCF*CFrame.new(-0.22*SCALE,0.09*SCALE,-0.10*SCALE)             p.EyeR.CFrame=headCF*CFrame.new(0.22*SCALE,0.09*SCALE,-0.10*SCALE)             p.PupilL.CFrame=headCF*CFrame.new(-0.23*SCALE,0.09*SCALE,-0.13*SCALE)             p.PupilR.CFrame=headCF*CFrame.new(0.23*SCALE,0.09*SCALE,-0.13*SCALE)             p.BeakU.CFrame=headCF*CFrame.new(0,-0.05*SCALE,-0.44*SCALE)             p.BeakL.CFrame=headCF*CFrame.new(0,-0.13*SCALE,-0.40*SCALE)*CFrame.Angles(-chirp,0,0)             p.BeakTip.CFrame=headCF*CFrame.new(0,-0.07*SCALE,-0.65*SCALE)             p.Nostril.CFrame=headCF*CFrame.new(0,0.00*SCALE,-0.35*SCALE)             local legPitch=data.state=="Swooping"and math.rad(65)or math.rad(35)             for _,side in ipairs({{p.ThighL,p.ShinL,-1},{p.ThighR,p.ShinR,1}})do                 local thigh,shin,sx=side[1],side[2],side[3]thigh.CFrame=bodyCF*CFrame.new(sx*0.20*SCALE,-0.22*SCALE,0.28*SCALE)*CFrame.Angles(legPitch*0.6,0,0)                 shin.CFrame=thigh.CFrame*CFrame.new(0,-0.20*SCALE,0)*CFrame.Angles(legPitch*0.5,0,0)             end                 p.TailC.CFrame=bodyCF*CFrame.new(0,-0.05*SCALE,1.35*SCALE)*CFrame.Angles(tailPitch,0,0)                 p.TailL.CFrame=bodyCF*CFrame.new(-0.15*SCALE,-0.05*SCALE,1.30*SCALE)*CFrame.Angles(tailPitch,-tailSpread,0)                 p.TailR.CFrame=bodyCF*CFrame.new(0.15*SCALE,-0.05*SCALE,1.30*SCALE)*CFrame.Angles(tailPitch,tailSpread,0)                 p.TailLL.CFrame=bodyCF*CFrame.new(-0.30*SCALE,-0.05*SCALE,1.20*SCALE)*CFrame.Angles(tailPitch,-tailSpread*1.6,0)                 p.TailRR.CFrame=bodyCF*CFrame.new(0.30*SCALE,-0.05*SCALE,1.20*SCALE)*CFrame.Angles(tailPitch,tailSpread*1.6,0)             local covertA=data.innerAngle*0.4 applyWing(p,bodyCF,"L",data.innerAngle,data.midAngle,data.outerAngle,data.outerTipAngle,sweep,covertA)             applyWing(p,bodyCF,"R",data.innerAngle,data.midAngle,data.outerAngle,data.outerTipAngle,sweep,covertA)         end     end     local function enable()         if running then              return          end             running=true             birdFolder=Instance.new("Folder")             birdFolder.Name="LocalBirdsFolder"birdFolder.Parent=Workspace initBirds()             heartbeatConn=RunService.RenderStepped:Connect(function(dt)
            if StepEffect("Birds", 1/60) then onHeartbeat(dt) end
        end)     end     local function disable()     running=false         if heartbeatConn then              heartbeatConn:Disconnect()         end         if birdFolder then              birdFolder:Destroy()         end             birdData={}                 activePoops={}                     activeSplats={}     end      _G.PortalVisuals._enableFuncs[name]=enable _G.PortalVisuals._disableFuncs[name]=disable  end

-- [[ Footprints ]]
do     local name="Footprints"     local running=false     local heartbeatConn=nil     local charAddedConn=nil     local lastStep=0     local isLeft=true     local CONFIG={Color=Color3.fromRGB(0,0,0),Size=Vector3.new(0.9,0.05,1.6),FadeTime=2.5,StepDelay=0.22,SideOffset=0.7,ForwardOffset=0.3,MinSpeed=0.15,MaxDistance=300,}     local function spawnFootstep(pos,normal,lookDir)         local part=Instance.new("Part")         part.Name="Footstep"         part.Anchored=true part.CanCollide=false part.CanQuery=false part.CanTouch=false         part.Size=CONFIG.Size part.Transparency=0 part.Color=CONFIG.Color         part.Material=Enum.Material.Concrete part.CastShadow=false         part.TopSurface=Enum.SurfaceType.Smooth part.BottomSurface=Enum.SurfaceType.Smooth         local rightDir=lookDir:Cross(normal).Unit         if rightDir.Magnitude<0.001 then rightDir=Vector3.new(1,0,0) end         local forwardDir=normal:Cross(rightDir).Unit         part.CFrame=CFrame.fromMatrix(pos+normal*0.03,rightDir,normal,forwardDir)         part.Parent=workspace         local tween=TweenService:Create(part,TweenInfo.new(CONFIG.FadeTime,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Transparency=1,Size=Vector3.new(CONFIG.Size.X*1.2,0.05,CONFIG.Size.Z*1.1)})         tween:Play()         Debris:AddItem(part,CONFIG.FadeTime+0.2)     end     local function onCharacterAdded(character)         local humanoid=character:WaitForChild("Humanoid")         local hrp=character:WaitForChild("HumanoidRootPart")         if heartbeatConn then heartbeatConn:Disconnect() end         heartbeatConn=RunService.RenderStepped:Connect(function()
            if not StepEffect("Footprints", 1/60) then return end             if not running then return end             if not character or not character.Parent then return end             if humanoid.FloorMaterial==Enum.Material.Air then return end             if humanoid.MoveDirection.Magnitude<CONFIG.MinSpeed then return end             local now=tick()             if now-lastStep<CONFIG.StepDelay then return end             lastStep=now             local moveDir=humanoid.MoveDirection.Unit             if moveDir.Magnitude<0.1 then moveDir=hrp.CFrame.LookVector end             local side=isLeft and-1 or 1             isLeft=not isLeft             local offset=(moveDir*CONFIG.ForwardOffset)+(hrp.CFrame.RightVector*CONFIG.SideOffset*side)             local origin=hrp.Position+offset+Vector3.new(0,2,0)             local params=RaycastParams.new()             params.FilterDescendantsInstances={character}             params.FilterType=Enum.RaycastFilterType.Blacklist             local result=workspace:Raycast(origin,Vector3.new(0,-CONFIG.MaxDistance,0),params)             if not result then return end             spawnFootstep(result.Position,result.Normal,moveDir)         end)     end     _G.PortalVisuals._enableFuncs[name]=function()         running=true lastStep=0 isLeft=true         local player=Players.LocalPlayer         if player.Character then onCharacterAdded(player.Character) end         if charAddedConn then charAddedConn:Disconnect() end         charAddedConn=player.CharacterAdded:Connect(onCharacterAdded)     end     _G.PortalVisuals._disableFuncs[name]=function()         running=false         if heartbeatConn then heartbeatConn:Disconnect() heartbeatConn=nil end         if charAddedConn then charAddedConn:Disconnect() charAddedConn=nil end     end     getgenv().PortalVisual=getgenv().PortalVisual or{}     getgenv().PortalVisual.Footprints={         Settings=CONFIG,         Toggle=function(state) if state then _G.PortalVisuals._enableFuncs[name]() else _G.PortalVisuals._disableFuncs[name]() end end,         Start=function() _G.PortalVisuals._enableFuncs[name]() end,         Stop=function() _G.PortalVisuals._disableFuncs[name]() end
    }
end

-- [[ Angel's Halo ]]
do
    local name = "Angel's Halo"
    local running = false
    local heartbeatConn = nil
    local charAddedConn = nil
    local folder = nil
    local fireflies = {}
    local haloData = nil
    local CONFIG = {
        Count = 14,
        Radius = 4,
        HeightOffset = 2.5,
        HaloHeight = 2.8,
        HaloRadius = 1.2,
        FadeTime = 2.5,
    }

    local function createHalo()
        local halo = Instance.new("Part")
        halo.Name = "AngelHalo_Ring"
        halo.Shape = Enum.PartType.Ball
        halo.Size = Vector3.new(CONFIG.HaloRadius * 2, 0.2, CONFIG.HaloRadius * 2)
        halo.Material = Enum.Material.Neon
        halo.Color = Color3.fromRGB(255, 230, 150)
        halo.Anchored = true
        halo.CanCollide = false
        halo.CastShadow = false
        halo.Parent = folder

        local mesh = Instance.new("SpecialMesh")
        mesh.MeshId = "rbxassetid://163079940"
        mesh.Scale = Vector3.new(CONFIG.HaloRadius, 0.1, CONFIG.HaloRadius)
        mesh.Parent = halo

        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255, 220, 130)
        light.Range = 8
        light.Brightness = 3
        light.Parent = halo

        return {
            part = halo,
            light = light,
            baseHeight = CONFIG.HaloHeight,
            angle = 0,
            rotSpeed = 0.3,
            pulseOffset = math.random() * math.pi * 2,
        }
    end

    local function createFirefly()
        local part = Instance.new("Part")
        part.Name = "AngelHalo_Firefly"
        part.Shape = Enum.PartType.Ball
        part.Size = Vector3.new(0.15, 0.15, 0.15)
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(255, 255, 230)
        part.Anchored = true
        part.CanCollide = false
        part.CastShadow = false
        part.Parent = folder

        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255, 240, 150)
        light.Range = 5
        light.Brightness = 2
        light.Parent = part

        local a0 = Instance.new("Attachment")
        a0.Position = Vector3.new(0, 0.05, 0)
        a0.Parent = part

        local a1 = Instance.new("Attachment")
        a1.Position = Vector3.new(0, -0.05, 0)
        a1.Parent = part

        local trail = Instance.new("Trail")
        trail.Attachment0 = a0
        trail.Attachment1 = a1
        trail.Lifetime = 0.5
        trail.MinLength = 0
        trail.FaceCamera = true
        trail.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 200)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 100)),
        })
        trail.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        trail.WidthScale = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        })
        trail.Parent = part

        return {
            part = part,
            light = light,
            trail = trail,
            angle = math.random() * math.pi * 2,
            angleSpeed = (math.random() * 0.6 + 0.2) * (math.random() < 0.5 and 1 or -1),
            radius = CONFIG.Radius * (0.4 + math.random() * 0.6),
            heightOffset = CONFIG.HeightOffset + math.random() * 1.5,
            bobSpeed = math.random() * 2 + 1,
            bobOffset = math.random() * math.pi * 2,
            bobHeight = math.random() * 0.8 + 0.3,
            flickerOffset = math.random() * math.pi * 2,
            flickerSpeed = math.random() * 3 + 2,
        }
    end

    local function onCharacterAdded(character)
        if heartbeatConn then
            heartbeatConn:Disconnect()
            heartbeatConn = nil
        end

        local hrp = character:WaitForChild("HumanoidRootPart")
        local t = 0

        heartbeatConn = RunService.Heartbeat:Connect(function(dt)
            if not running then
                return
            end

            t = t + dt

            if not hrp or not hrp.Parent then
                local newChar = LocalPlayer.Character
                if newChar then
                    hrp = newChar:FindFirstChild("HumanoidRootPart")
                end
                if not hrp then
                    return
                end
            end

            local basePos = hrp.Position
            haloData.angle = haloData.angle + haloData.rotSpeed * dt

            local haloPulse = 1 + math.sin(t * 2 + haloData.pulseOffset) * 0.1
            local haloPos = basePos + Vector3.new(0, haloData.baseHeight, 0)
            haloData.part.CFrame = CFrame.new(haloPos) * CFrame.Angles(0, haloData.angle, math.rad(90))
            haloData.part.Size = Vector3.new(
                CONFIG.HaloRadius * 2 * haloPulse,
                0.2 * haloPulse,
                CONFIG.HaloRadius * 2 * haloPulse
            )
            haloData.light.Brightness = 2.5 + math.sin(t * 2 + haloData.pulseOffset) * 0.5

            for _, f in ipairs(fireflies) do
                f.angle = f.angle + f.angleSpeed * dt
                local x = math.cos(f.angle) * f.radius
                local z = math.sin(f.angle) * f.radius
                local y = f.heightOffset + math.sin(t * f.bobSpeed + f.bobOffset) * f.bobHeight
                local targetPos = basePos + Vector3.new(x, y, z)
                local lerpAlpha = 1 - math.exp(-dt * 6)
                f.part.Position = f.part.Position:Lerp(targetPos, lerpAlpha)

                local flicker = 0.6 + math.sin(t * f.flickerSpeed + f.flickerOffset) * 0.4
                f.light.Brightness = math.clamp(flicker * 2.5, 0.5, 3)
                f.part.Transparency = math.clamp(1 - flicker, 0, 0.5)
            end
        end)
    end

    local function enable()
        if running then
            return
        end

        running = true
        folder = Instance.new("Folder")
        folder.Name = "AngelHalo_Container"
        folder.Parent = workspace
        fireflies = {}
        haloData = createHalo()

        for i = 1, CONFIG.Count do
            fireflies[i] = createFirefly()
        end

        local player = Players.LocalPlayer
        if player.Character then
            onCharacterAdded(player.Character)
        end

        if charAddedConn then
            charAddedConn:Disconnect()
        end
        charAddedConn = player.CharacterAdded:Connect(onCharacterAdded)
    end

    local function disable()
        running = false

        if heartbeatConn then
            heartbeatConn:Disconnect()
            heartbeatConn = nil
        end

        if charAddedConn then
            charAddedConn:Disconnect()
            charAddedConn = nil
        end

        if folder then
            folder:Destroy()
            folder = nil
        end

        fireflies = {}
        haloData = nil
    end

    _G.PortalVisuals._enableFuncs[name] = enable
    _G.PortalVisuals._disableFuncs[name] = disable

    getgenv().PortalVisual = getgenv().PortalVisual or {}
    getgenv().PortalVisual["Angel's Halo"] = {
        Settings = CONFIG,
        Toggle = function(state)
            if state then
                enable()
            else
                disable()
            end
        end,
        Start = enable,
        Stop = disable,
    }
end

-- [[ Wind ]]
do     local name="Wind"local running=false      local connection=nil      local function startWind()         if running then              return          end          running=true          local camera=workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")         if not camera then              running=false return          end         local oldWind=workspace:FindFirstChild("VisualWind_Container")         if oldWind then              oldWind:Destroy()         end         local windContainer=Instance.new("Folder")         windContainer.Name="VisualWind_Container"windContainer.Parent=workspace         local dustEmitter=Instance.new("ParticleEmitter")         dustEmitter.Texture="rbxassetid://1426893421"         dustEmitter.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(210,220,230)),ColorSequenceKeypoint.new(1,Color3.fromRGB(180,190,200))})         dustEmitter.Size=NumberSequence.new(0.15,0.02)dustEmitter.Lifetime=NumberRange.new(2,5)         dustEmitter.Rate=3 dustEmitter.Speed=NumberRange.new(0.2,0.8)         dustEmitter.SpreadAngle=Vector2.new(180,180)dustEmitter.VelocityInheritance=0         dustEmitter.Acceleration=Vector3.new(0,-0.1,0)         dustEmitter.Rotation=NumberRange.new(0,360)dustEmitter.RotSpeed=NumberRange.new(-5,5)         dustEmitter.Transparency=NumberSequence.new(0.7,0.95)         dustEmitter.LightInfluence=0.5         dustEmitter.Parent=windContainer         local MAX_WIND_LINES=18          local SPAWN_COOLDOWN=0.09          local WIND_SPEED_BASE=40          local CAMERA_FORWARD_OFFSET=45          local SCATTER_HORIZONTAL=55          local SCATTER_VERTICAL=30          local FADE_IN_DURATION=0.25          local WIND_TYPES={{Name="Draft",Weight=50,Lifetime=2.0,TrailLifetime=0.25,SpeedMult=0.8,WaveAmp=2.5,WaveFreq=3.5,Width=0.12,Color=Color3.fromRGB(235,245,255)},{Name="Gust",Weight=35,Lifetime=1.0,TrailLifetime=0.15,SpeedMult=1.5,WaveAmp=0.2,WaveFreq=1.0,Width=0.08,Color=Color3.fromRGB(245,250,255)},{Name="Vortex",Weight=15,Lifetime=1.6,TrailLifetime=0.22,SpeedMult=0.9,WaveAmp=4.0,WaveFreq=5.5,Width=0.10,Color=Color3.fromRGB(215,238,255)}}         local activeLines={}         local lastSpawnTime=0          local function getRandomWindType()             local totalWeight=0              for _,wType in ipairs(WIND_TYPES)do                  totalWeight=totalWeight+wType.Weight              end             local r=math.random(1,totalWeight)             local current=0              for _,wType in ipairs(WIND_TYPES)do                  current=current+wType.Weight                  if r<=current then                      return wType                  end             end              return WIND_TYPES[1]         end         local function getPerpendicularVectors(dir)             local perp1=dir:Cross(Vector3.new(0,1,0))             if perp1.Magnitude<0.01 then                  perp1=dir:Cross(Vector3.new(1,0,0))             end              perp1=perp1.Unit              local perp2=dir:Cross(perp1).Unit return perp1,perp2          end         local function spawnWindLine(globalDirection,globalSpeed)             if#activeLines>=MAX_WIND_LINES or not camera then                  return              end             local wType=getRandomWindType()             local localSpeed=globalSpeed*wType.SpeedMult              local camPos=camera.CFrame.Position              local lookVec=camera.CFrame.LookVector              local centerPos=camPos+(lookVec*CAMERA_FORWARD_OFFSET)             local spawnOffset=-globalDirection*(localSpeed*wType.Lifetime*0.4)             local randomScatter=(camera.CFrame.RightVector*math.random(-SCATTER_HORIZONTAL,SCATTER_HORIZONTAL))+(camera.CFrame.UpVector*math.random(-SCATTER_VERTICAL,SCATTER_VERTICAL))             local startPos=centerPos+spawnOffset+randomScatter              local perp1,perp2=getPerpendicularVectors(globalDirection)             local part=Instance.new("Part")             part.Size=Vector3.new(0.01,0.01,0.01)             part.Transparency=1             part.CanCollide=false             part.CanTouch=false             part.CanQuery=false             part.Anchored=true             part.Position=startPos part.Parent=windContainer             local att0=Instance.new("Attachment",part)             att0.Position=Vector3.new(0,0,0)             local att1=Instance.new("Attachment",part)             att1.Position=Vector3.new(0,0,0)             local trail=Instance.new("Trail")             trail.Attachment0=att0 trail.Attachment1=att1 trail.FaceCamera=true             trail.Lifetime=wType.TrailLifetime trail.Color=ColorSequence.new(wType.Color)             trail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.12,0.45),NumberSequenceKeypoint.new(0.85,0.45),NumberSequenceKeypoint.new(1,1)})                 trail.WidthScale=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.12,1),NumberSequenceKeypoint.new(0.88,0.6),NumberSequenceKeypoint.new(1,0)})                     trail.Parent=part table.insert(activeLines,{Part=part,Att0=att0,Att1=att1,Trail=trail,SpawnTime=os.clock(),StartPos=startPos,CurrentBasePos=startPos,Direction=globalDirection,Speed=localSpeed,Lifetime=wType.Lifetime,TrailLifetime=wType.TrailLifetime,Width=wType.Width,Perp1=perp1,Perp2=perp2,WaveAmp=wType.WaveAmp,WaveFreq=wType.WaveFreq,Phase=math.random()*math.pi*2,Disappearing=false})         end              local dustCount=0              connection=RunService.Heartbeat:Connect(function(dt)

    -- Wind motion is frame-driven; spawn rate remains capped
             if not running or not windContainer or not windContainer.Parent then                 if connection then                      connection:Disconnect();connection=nil                  end                  return              end             local t=os.clock()             local angleNoise=math.noise(t*0.05,2,2)*math.pi*2              local pitchNoise=math.noise(2,t*0.03,2)*0.08              local speedNoise=math.noise(2,2,t*0.07)             local currentDir=Vector3.new(math.cos(angleNoise),pitchNoise,math.sin(angleNoise)).Unit              local currentSpeed=WIND_SPEED_BASE+(speedNoise*15)             pcall(function()             workspace.GlobalWind=currentDir*(currentSpeed*0.08)             end)             local currentTime=os.clock()             for i=#activeLines,1,-1 do                 local data=activeLines[i]                 local age=currentTime-data.SpawnTime                  if age>=(data.Lifetime-data.TrailLifetime)and not data.Disappearing then                         data.Disappearing=true                         data.Trail.Enabled=false                 end                 if age>=data.Lifetime or not data.Part.Parent then                         data.Part:Destroy()                         table.remove(activeLines,i)                 else                      data.CurrentBasePos=data.CurrentBasePos+(data.Direction*data.Speed*dt)                     local waveOffset=(data.Perp1*math.sin(age*data.WaveFreq+data.Phase)*data.WaveAmp)+(data.Perp2*math.cos(age*data.WaveFreq*1.1+data.Phase)*(data.WaveAmp*0.7))                     data.Part.Position=data.CurrentBasePos+waveOffset                     if age<FADE_IN_DURATION then                         local alpha=age/FADE_IN_DURATION                          local scale=math.sin(alpha*math.pi/2)                         local currentHalfWidth=(data.Width/2)*scale data.Att0.Position=Vector3.new(0,-currentHalfWidth,0)                         data.Att1.Position=Vector3.new(0,currentHalfWidth,0)                     end                 end             end             if currentTime-lastSpawnTime>=SPAWN_COOLDOWN then                     spawnWindLine(currentDir,currentSpeed)                     lastSpawnTime=currentTime             end         end)     end     local function stopWind()         if not running then              return          end          running=false          if connection then              connection:Disconnect();connection=nil          end         local container=workspace:FindFirstChild("VisualWind_Container")         if container then              container:Destroy()         end             pcall(function()             workspace.GlobalWind=Vector3.new(0,0,0)         end)     end      _G.PortalVisuals._enableFuncs[name]=startWind _G.PortalVisuals._disableFuncs[name]=stopWind  end

-- [[ Crystal Orbit ]]
do
    local name = "Crystal Orbit"
    local running = false
    local conn = nil
    local folder = nil
    local crystals = {}
    local CONFIG = {Count=8,Radius=7,Height=2.2,Speed=0.9,VerticalWave=0.8}
    local function createCrystal(i)
        local p=Instance.new("Part")
        p.Name="Crystal_"..i
        p.Size=Vector3.new(0.45,1.5,0.45)
        p.Material=Enum.Material.Neon
        p.Color=Color3.fromHSV((i/CONFIG.Count)*0.75,0.72,1)
        p.Anchored=true
        p.CanCollide=false
        p.CanTouch=false
        p.CanQuery=false
        p.CastShadow=false
        p.Parent=folder
        local mesh=Instance.new("SpecialMesh")
        mesh.MeshType=Enum.MeshType.Wedge
        mesh.Scale=Vector3.new(0.75,1.4,0.75)
        mesh.Parent=p
        return {Part=p,Phase=(i/CONFIG.Count)*math.pi*2,Spin=(i%2==0 and 1 or -1),Bob=i*0.7}
    end
    local function update(dt)
        if not running then return end
        if not StepEffect("CrystalOrbit",1/60) then return end
        local char=LocalPlayer.Character
        local root=char and PortalGetRoot(char)
        if not root then return end
        local t=os.clock()
        for _,c in ipairs(crystals) do
            if c.Part.Parent then
                local a=c.Phase+t*CONFIG.Speed*c.Spin
                local pos=root.Position+Vector3.new(math.cos(a)*CONFIG.Radius,CONFIG.Height+math.sin(t*1.8+c.Bob)*CONFIG.VerticalWave,math.sin(a)*CONFIG.Radius)
                c.Part.CFrame=CFrame.new(pos)*CFrame.Angles(math.sin(t*2+c.Bob)*0.35,a+math.pi/2,math.cos(t*1.3+c.Bob)*0.25)
                c.Part.Color=Color3.fromHSV(((t*0.06)+c.Phase/(math.pi*2))%1,0.72,1)
            end
        end
    end
    local function enable()
        if running then return end
        running=true
        folder=Instance.new("Folder")
        folder.Name="PortalVisual_CrystalOrbit"
        folder.Parent=Workspace
        crystals={}
        for i=1,CONFIG.Count do crystals[i]=createCrystal(i) end
        conn=RunService.RenderStepped:Connect(update)
    end
    local function disable()
        running=false
        if conn then conn:Disconnect();conn=nil end
        if folder then folder:Destroy();folder=nil end
        crystals={}
    end
    _G.PortalVisuals._enableFuncs[name]=enable
    _G.PortalVisuals._disableFuncs[name]=disable
end

-- [[ Energy Ribbons ]]
do
    local name = "Energy Ribbons"
    local running = false
    local conn = nil
    local folder = nil
    local ribbons = {}
    local CONFIG = {Count=3,Radius=5.5,Height=1.6,Speed=1.35,TrailLifetime=0.35}
    local function makeRibbon(i)
        local p=Instance.new("Part")
        p.Name="Ribbon_"..i
        p.Size=Vector3.new(0.14,0.14,0.14)
        p.Transparency=1
        p.Anchored=true
        p.CanCollide=false
        p.CanTouch=false
        p.CanQuery=false
        p.Parent=folder
        local a0=Instance.new("Attachment",p)
        local a1=Instance.new("Attachment",p)
        a0.Position=Vector3.new(0,-0.55,0)
        a1.Position=Vector3.new(0,0.55,0)
        local trail=Instance.new("Trail")
        trail.Attachment0=a0; trail.Attachment1=a1
        trail.FaceCamera=true
        trail.Lifetime=CONFIG.TrailLifetime
        trail.LightEmission=0.8
        trail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.15),NumberSequenceKeypoint.new(1,1)})
        trail.WidthScale=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})
        trail.Color=ColorSequence.new(Color3.fromHSV((i-1)/CONFIG.Count,0.9,1))
        trail.Parent=p
        return {Part=p,Trail=trail,Phase=(i-1)*math.pi*2/CONFIG.Count}
    end
    local function update(dt)
        if not running then return end
        if not StepEffect("EnergyRibbons",1/60) then return end
        local char=LocalPlayer.Character
        local root=char and PortalGetRoot(char)
        if not root then return end
        local t=os.clock()
        for i,r in ipairs(ribbons) do
            if r.Part.Parent then
                local a=t*CONFIG.Speed+r.Phase
                local offset=Vector3.new(math.cos(a)*CONFIG.Radius,CONFIG.Height+math.sin(a*2+t)*0.7,math.sin(a)*CONFIG.Radius)
                r.Part.Position=root.Position+offset
                local c=Color3.fromHSV(((t*0.10)+(i-1)/#ribbons)%1,0.9,1)
                r.Trail.Color=ColorSequence.new(c)
            end
        end
    end
    local function enable()
        if running then return end
        running=true
        folder=Instance.new("Folder")
        folder.Name="PortalVisual_EnergyRibbons"
        folder.Parent=Workspace
        ribbons={}
        for i=1,CONFIG.Count do ribbons[i]=makeRibbon(i) end
        conn=RunService.RenderStepped:Connect(update)
    end
    local function disable()
        running=false
        if conn then conn:Disconnect();conn=nil end
        if folder then folder:Destroy();folder=nil end
        ribbons={}
    end
    _G.PortalVisuals._enableFuncs[name]=enable
    _G.PortalVisuals._disableFuncs[name]=disable
end

-- [[ Pulse Halo 3D ]]
do
    local name = "Pulse Halo 3D"
    local running = false
    local conn = nil
    local folder = nil
    local nodes = {}
    local CONFIG = {Count=18,Radius=4.2,Height=2.2,Speed=0.8,PulseSpeed=2.4}
    local function enable()
        if running then return end
        running=true
        folder=Instance.new("Folder")
        folder.Name="PortalVisual_PulseHalo3D"
        folder.Parent=Workspace
        nodes={}
        for i=1,CONFIG.Count do
            local p=Instance.new("Part")
            p.Name="PulseNode_"..i
            p.Size=Vector3.new(0.18,0.18,0.18)
            p.Shape=Enum.PartType.Ball
            p.Material=Enum.Material.Neon
            p.Color=Color3.fromRGB(180,135,255)
            p.Anchored=true
            p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
            p.Parent=folder
            nodes[i]=p
        end
        conn=RunService.RenderStepped:Connect(function(dt)
            if not StepEffect("PulseHalo3D",1/60) then return end
            local root=LocalPlayer.Character and PortalGetRoot(LocalPlayer.Character)
            if not root then return end
            local t=os.clock()
            local pulse=1+math.sin(t*CONFIG.PulseSpeed)*0.12
            for i,p in ipairs(nodes) do
                if p.Parent then
                    local a=(i/CONFIG.Count)*math.pi*2+t*CONFIG.Speed
                    local radius=CONFIG.Radius*pulse
                    p.Position=root.Position+Vector3.new(math.cos(a)*radius,CONFIG.Height+math.sin(a*2+t)*0.22,math.sin(a)*radius)
                    p.Size=Vector3.new(0.15+0.05*pulse,0.15+0.05*pulse,0.15+0.05*pulse)
                    p.Color=Color3.fromHSV((t*0.08+i/CONFIG.Count)%1,0.75,1)
                end
            end
        end)
    end
    local function disable()
        running=false
        if conn then conn:Disconnect();conn=nil end
        if folder then folder:Destroy();folder=nil end
        nodes={}
    end
    _G.PortalVisuals._enableFuncs[name]=enable
    _G.PortalVisuals._disableFuncs[name]=disable
end


-- [[ Map Crystals ]]
do
    local name="Map Crystals"
    local running=false
    local conn=nil
    local folder=nil
    local crystals={}
    local rng=Random.new()
    local CONFIG={Count=20,Radius=70,MinHeight=1.2,MaxHeight=3.8,SpinSpeed=0.28,Drift=0.18,RelocateDistance=22}

    local function groundPosition(center)
        local angle=rng:NextNumber(0,math.pi*2)
        local radius=math.sqrt(rng:NextNumber())*CONFIG.Radius
        local x=center.X+math.cos(angle)*radius
        local z=center.Z+math.sin(angle)*radius
        local origin=Vector3.new(x,center.Y+85,z)
        local hit=Workspace:Raycast(origin,Vector3.new(0,-180,0))
        if hit then return hit.Position,hit.Normal end
        return Vector3.new(x,center.Y,z),Vector3.new(0,1,0)
    end

    local function createCrystal(i,pos,normal)
        local cluster=Instance.new("Model")
        cluster.Name="MapCrystalCluster_"..i
        cluster.Parent=folder
        local parts={}
        local baseCF=CFrame.new(pos+normal*0.15)
        local hue=((i-1)/CONFIG.Count*0.45+0.68)%1
        for j=1,3 do
            local p=Instance.new("Part")
            p.Name="Shard"
            p.Size=Vector3.new(0.7+0.18*j,1.9+0.35*j,0.7+0.18*j)
            p.Material=Enum.Material.Neon
            p.Color=Color3.fromHSV((hue+(j-1)*0.035)%1,0.55,1)
            p.Anchored=true
            p.CanCollide=false
            p.CanTouch=false
            p.CanQuery=false
            p.CastShadow=false
            p.Parent=cluster
            local mesh=Instance.new("SpecialMesh")
            mesh.MeshType=Enum.MeshType.Wedge
            mesh.Scale=Vector3.new(0.72,1.55,0.72)
            mesh.Parent=p
            parts[j]=p
        end
        return {Model=cluster,Parts=parts,Base=pos,Normal=normal,Phase=rng:NextNumber(0,6.28),Seed=rng:NextNumber(0,1000),LastCenter=pos}
    end

    local function rebuild(center)
        for _,d in ipairs(crystals) do if d.Model then d.Model:Destroy() end end
        table.clear(crystals)
        for i=1,CONFIG.Count do
            local pos,normal=groundPosition(center)
            crystals[i]=createCrystal(i,pos,normal)
        end
    end

    local function update(dt)
        if not running or not folder then return end
        local char=LocalPlayer.Character
        local root=char and PortalGetRoot(char)
        if not root then return end
        local center=Yuki_CameraCenter(10)
        local t=os.clock()
        for _,d in ipairs(crystals) do
            if d.Model and d.Model.Parent then
                local dx=d.Base.X-center.X
                local dz=d.Base.Z-center.Z
                if dx*dx+dz*dz>(CONFIG.Radius+CONFIG.RelocateDistance)^2 then
                    local pos,normal=groundPosition(center)
                    d.Base=pos; d.Normal=normal
                    d.Phase=rng:NextNumber(0,6.28)
                else
                    local y=math.sin(t*1.2+d.Phase)*CONFIG.Drift
                    local cf=CFrame.new(d.Base+d.Normal*(0.18+y))*CFrame.Angles(0,t*CONFIG.SpinSpeed+d.Phase,0)
                    for j,p in ipairs(d.Parts) do
                        if p and p.Parent then
                            local side=(j-2)*0.65
                            p.CFrame=cf*CFrame.new(side,0,(j%2==0 and 0.35 or -0.2))*CFrame.Angles(0,0,(j-2)*0.08)
                        end
                    end
                end
            end
        end
    end

    local function enable()
        if running then return end
        running=true
        folder=Instance.new("Folder")
        folder.Name="YukiWorld_MapCrystals"
        folder.Parent=Workspace
        rebuild((LocalPlayer.Character and PortalGetRoot(LocalPlayer.Character) and PortalGetRoot(LocalPlayer.Character).Position) or (Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.Position) or Vector3.zero)
        conn=RunService.RenderStepped:Connect(update)
    end
    local function disable()
        running=false
        if conn then conn:Disconnect();conn=nil end
        if folder then folder:Destroy();folder=nil end
        table.clear(crystals)
    end
    _G.PortalVisuals._enableFuncs[name]=enable
    _G.PortalVisuals._disableFuncs[name]=disable
end

-- [[ Ground Runes ]]
do
    local name="Ground Runes"
    local running=false
    local conn=nil
    local folder=nil
    local runes={}
    local rng=Random.new()
    local CONFIG={Count=12,Radius=65,Refresh=0.65,RadiusSize=2.2,Height=0.05}

    local function placeRune(center,i)
        local angle=rng:NextNumber(0,math.pi*2)
        local dist=math.sqrt(rng:NextNumber())*CONFIG.Radius
        local x=center.X+math.cos(angle)*dist
        local z=center.Z+math.sin(angle)*dist
        local hit=Workspace:Raycast(Vector3.new(x,center.Y+70,z),Vector3.new(0,-150,0))
        if not hit then return end
        local p=Instance.new("Part")
        p.Name="GroundRune_"..i
        p.Shape=Enum.PartType.Cylinder
        p.Size=Vector3.new(CONFIG.Height,CONFIG.RadiusSize*2,CONFIG.RadiusSize*2)
        p.Material=Enum.Material.Neon
        p.Color=Color3.fromRGB(180,135,255)
        p.Transparency=0.5
        p.Anchored=true
        p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
        p.CFrame=CFrame.lookAt(hit.Position+hit.Normal*0.03,hit.Position+hit.Normal)*CFrame.Angles(0,0,math.rad(90))
        p.Parent=folder
        local mesh=Instance.new("SpecialMesh")
        mesh.MeshType=Enum.MeshType.Cylinder
        mesh.Scale=Vector3.new(1,1,1)
        mesh.Parent=p
        runes[i]={Part=p,Base=hit.Position,Normal=hit.Normal,Phase=rng:NextNumber(0,6.28),Age=rng:NextNumber(0,6.28)}
    end

    local function rebuild(center)
        for _,d in ipairs(runes) do if d.Part then d.Part:Destroy() end end
        table.clear(runes)
        for i=1,CONFIG.Count do placeRune(center,i) end
    end

    local function update(dt)
        if not running then return end
        local root=LocalPlayer.Character and PortalGetRoot(LocalPlayer.Character)
        if not root then return end
        local t=os.clock()
        for i,d in ipairs(runes) do
            if d.Part and d.Part.Parent then
                d.Age=d.Age+dt
                local pulse=(math.sin(t*2.0+d.Phase)+1)*0.5
                d.Part.Transparency=0.72-0.28*pulse
                local s=CONFIG.RadiusSize*(0.92+0.10*pulse)
                d.Part.Size=Vector3.new(CONFIG.Height,s*2,s*2)
            end
        end
        if StepEffect("GroundRunesRebuild",CONFIG.Refresh) then
            for _,d in ipairs(runes) do
                if d.Part and (d.Base-Yuki_CameraCenter(10)).Magnitude>CONFIG.Radius*1.35 then
                    local idx=table.find(runes,d)
                    if idx then
                        d.Part:Destroy()
                        table.remove(runes,idx)
                        placeRune(Yuki_CameraCenter(10),idx)
                    end
                end
            end
            while #runes<CONFIG.Count do placeRune(Yuki_CameraCenter(10),#runes+1) end
        end
    end

    local function enable()
        if running then return end
        running=true
        folder=Instance.new("Folder")
        folder.Name="YukiWorld_GroundRunes"
        folder.Parent=Workspace
        local root=LocalPlayer.Character and PortalGetRoot(LocalPlayer.Character)
        rebuild(root and Yuki_CameraCenter(10) or (Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.Position) or Vector3.zero)
        conn=RunService.RenderStepped:Connect(update)
    end
    local function disable()
        running=false
        if conn then conn:Disconnect();conn=nil end
        if folder then folder:Destroy();folder=nil end
        table.clear(runes)
    end
    _G.PortalVisuals._enableFuncs[name]=enable
    _G.PortalVisuals._disableFuncs[name]=disable
end

-- [[ Floating Relics ]]
do
    local name="Floating Relics"
    local running=false
    local conn=nil
    local folder=nil
    local relics={}
    local rng=Random.new()
    local CONFIG={Count=10,Radius=65,HeightMin=5,HeightMax=15,SpeedMin=0.12,SpeedMax=0.3}

    local function createRelic(i,center)
        local angle=rng:NextNumber(0,math.pi*2)
        local r=math.sqrt(rng:NextNumber())*CONFIG.Radius
        local pos=center+Vector3.new(math.cos(angle)*r,rng:NextNumber(CONFIG.HeightMin,CONFIG.HeightMax),math.sin(angle)*r)
        local p=Instance.new("Part")
        p.Name="FloatingRelic_"..i
        p.Size=Vector3.new(1.1,2.2,1.1)
        p.Material=Enum.Material.Glass
        p.Color=Color3.fromRGB(170,120,255)
        p.Transparency=0.32
        p.Anchored=true
        p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
        p.Parent=folder
        local mesh=Instance.new("SpecialMesh")
        mesh.MeshType=Enum.MeshType.Wedge
        mesh.Scale=Vector3.new(0.8,1.8,0.8)
        mesh.Parent=p
        local glow=Instance.new("PointLight")
        glow.Color=p.Color;glow.Brightness=1.2;glow.Range=8;glow.Shadows=false;glow.Parent=p
        return {Part=p,Light=glow,Base=pos,Phase=rng:NextNumber(0,6.28),Spin=rng:NextNumber(CONFIG.SpeedMin,CONFIG.SpeedMax)*(rng:NextNumber()>0.5 and 1 or -1),Radius=r,LastCenter=center}
    end

    local function update(dt)
        if not running then return end
        local root=LocalPlayer.Character and PortalGetRoot(LocalPlayer.Character)
        if not root then return end
        local center=Yuki_CameraCenter(10)
        local t=os.clock()
        for _,d in ipairs(relics) do
            if d.Part and d.Part.Parent then
                local dx=d.Base.X-center.X; local dz=d.Base.Z-center.Z
                if dx*dx+dz*dz>(CONFIG.Radius+35)^2 then
                    local a=rng:NextNumber(0,math.pi*2)
                    local r=math.sqrt(rng:NextNumber())*CONFIG.Radius
                    d.Base=center+Vector3.new(math.cos(a)*r,rng:NextNumber(CONFIG.HeightMin,CONFIG.HeightMax),math.sin(a)*r)
                end
                local bob=math.sin(t*1.15+d.Phase)*0.65
                d.Part.CFrame=CFrame.new(d.Base+Vector3.new(0,bob,0))*CFrame.Angles(0,t*d.Spin+d.Phase,math.sin(t*0.7+d.Phase)*0.18)
                d.Light.Brightness=0.85+0.45*(math.sin(t*2+d.Phase)*0.5+0.5)
            end
        end
    end

    local function enable()
        if running then return end
        running=true
        folder=Instance.new("Folder")
        folder.Name="YukiWorld_FloatingRelics"
        folder.Parent=Workspace
        relics={}
        local root=LocalPlayer.Character and PortalGetRoot(LocalPlayer.Character)
        local center=root and Yuki_CameraCenter(10) or (Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.Position) or Vector3.zero
        for i=1,CONFIG.Count do relics[i]=createRelic(i,center) end
        conn=RunService.RenderStepped:Connect(update)
    end
    local function disable()
        running=false
        if conn then conn:Disconnect();conn=nil end
        if folder then folder:Destroy();folder=nil end
        table.clear(relics)
    end
    _G.PortalVisuals._enableFuncs[name]=enable
    _G.PortalVisuals._disableFuncs[name]=disable
end

-- [[ Light Pillars ]]
do
    local name="Light Pillars"
    local running=false
    local conn=nil
    local folder=nil
    local pillars={}
    local rng=Random.new()
    local CONFIG={Count=7,Radius=85,Height=28,Width=2.2,Refresh=1.1}

    local function createPillar(i,center)
        local angle=rng:NextNumber(0,math.pi*2)
        local r=math.sqrt(rng:NextNumber())*CONFIG.Radius
        local x=center.X+math.cos(angle)*r; local z=center.Z+math.sin(angle)*r
        local hit=Workspace:Raycast(Vector3.new(x,center.Y+100,z),Vector3.new(0,-220,0))
        if not hit then return end
        local p=Instance.new("Part")
        p.Name="LightPillar_"..i
        p.Size=Vector3.new(CONFIG.Width,CONFIG.Height,CONFIG.Width)
        p.Material=Enum.Material.Neon
        p.Color=Color3.fromRGB(180,140,255)
        p.Transparency=0.82
        p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
        p.CFrame=CFrame.new(hit.Position+Vector3.new(0,CONFIG.Height*0.5,0))
        p.Parent=folder
        local glow=Instance.new("PointLight")
        glow.Color=p.Color;glow.Range=12;glow.Brightness=0.8;glow.Shadows=false;glow.Parent=p
        return {Part=p,Light=glow,Base=hit.Position,Phase=rng:NextNumber(0,6.28)}
    end

    local function rebuild(center)
        for _,d in ipairs(pillars) do if d.Part then d.Part:Destroy() end end
        table.clear(pillars)
        for i=1,CONFIG.Count do
            local d=createPillar(i,center)
            if d then table.insert(pillars,d) end
        end
    end

    local function update(dt)
        if not running then return end
        local root=LocalPlayer.Character and PortalGetRoot(LocalPlayer.Character)
        if not root then return end
        local t=os.clock()
        for _,d in ipairs(pillars) do
            if d.Part and d.Part.Parent then
                local pulse=(math.sin(t*1.6+d.Phase)+1)*0.5
                d.Part.Transparency=0.88-0.18*pulse
                d.Light.Brightness=0.45+0.9*pulse
                d.Part.Size=Vector3.new(CONFIG.Width*(0.92+0.12*pulse),CONFIG.Height*(0.96+0.04*pulse),CONFIG.Width*(0.92+0.12*pulse))
            end
        end
        if StepEffect("LightPillarsRebuild",CONFIG.Refresh) then
            for _,d in ipairs(pillars) do
                if (d.Base-Yuki_CameraCenter(10)).Magnitude>CONFIG.Radius*1.35 then
                    local center=Yuki_CameraCenter(10)
                    local nd=createPillar(math.random(1,CONFIG.Count),center)
                    if nd then
                        d.Part:Destroy()
                        d.Part=nd.Part; d.Light=nd.Light; d.Base=nd.Base; d.Phase=nd.Phase
                    end
                end
            end
        end
    end

    local function enable()
        if running then return end
        running=true
        folder=Instance.new("Folder")
        folder.Name="YukiWorld_LightPillars"
        folder.Parent=Workspace
        local root=LocalPlayer.Character and PortalGetRoot(LocalPlayer.Character)
        rebuild(root and Yuki_CameraCenter(10) or (Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.Position) or Vector3.zero)
        conn=RunService.RenderStepped:Connect(update)
    end
    local function disable()
        running=false
        if conn then conn:Disconnect();conn=nil end
        if folder then folder:Destroy();folder=nil end
        table.clear(pillars)
    end
    _G.PortalVisuals._enableFuncs[name]=enable
    _G.PortalVisuals._disableFuncs[name]=disable
end

-- [[ World Energy Nodes ]]
do
    local name="World Energy Nodes"
    local running=false
    local conn=nil
    local folder=nil
    local nodes={}
    local beams={}
    local rng=Random.new()
    local CONFIG={Count=12,Radius=60,Height=3.5,LinkDistance=28,ColorSpeed=0.08,Refresh=1.5}

    local function addLink(a,b,color)
        local at0=Instance.new("Attachment",a.Part)
        local at1=Instance.new("Attachment",b.Part)
        local beam=Instance.new("Beam")
        beam.Attachment0=at0; beam.Attachment1=at1
        beam.FaceCamera=true;beam.LightEmission=1;beam.LightInfluence=0
        beam.Width0=0.12;beam.Width1=0.04;beam.Transparency=NumberSequence.new(0.35,0.95)
        beam.Color=ColorSequence.new(color)
        beam.Parent=folder
        table.insert(beams,{Beam=beam,A=a,B=b,At0=at0,At1=at1})
    end

    local function placeNode(center,i)
        local angle=rng:NextNumber(0,math.pi*2)
        local r=math.sqrt(rng:NextNumber())*CONFIG.Radius
        local x=center.X+math.cos(angle)*r; local z=center.Z+math.sin(angle)*r
        local hit=Workspace:Raycast(Vector3.new(x,center.Y+70,z),Vector3.new(0,-150,0))
        if not hit then return end
        local p=Instance.new("Part")
        p.Name="WorldEnergyNode_"..i
        p.Shape=Enum.PartType.Ball
        p.Size=Vector3.new(0.7,0.7,0.7)
        p.Material=Enum.Material.Neon
        p.Color=Color3.fromRGB(160,110,255)
        p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
        p.Position=hit.Position+hit.Normal*CONFIG.Height
        p.Parent=folder
        local light=Instance.new("PointLight")
        light.Color=p.Color;light.Range=8;light.Brightness=0.7;light.Shadows=false;light.Parent=p
        return {Part=p,Light=light,Base=p.Position,Phase=rng:NextNumber(0,6.28)}
    end

    local function rebuild(center)
        for _,v in ipairs(beams) do if v.Beam then v.Beam:Destroy() end end
        for _,d in ipairs(nodes) do if d.Part then d.Part:Destroy() end end
        table.clear(beams);table.clear(nodes)
        for i=1,CONFIG.Count do
            local d=placeNode(center,i)
            if d then table.insert(nodes,d) end
        end
        for i=1,#nodes do
            for j=i+1,#nodes do
                local dist=(nodes[i].Base-nodes[j].Base).Magnitude
                if dist<=CONFIG.LinkDistance then
                    local c=Color3.fromHSV((i/#nodes*0.55+0.7)%1,0.72,1)
                    addLink(nodes[i],nodes[j],c)
                end
            end
        end
    end

    local function update(dt)
        if not running then return end
        local root=LocalPlayer.Character and PortalGetRoot(LocalPlayer.Character)
        if not root then return end
        local t=os.clock()
        for _,d in ipairs(nodes) do
            if d.Part and d.Part.Parent then
                local pulse=(math.sin(t*2+d.Phase)+1)*0.5
                d.Part.Position=d.Base+Vector3.new(0,math.sin(t*1.3+d.Phase)*0.25,0)
                d.Part.Size=Vector3.new(0.56+0.22*pulse,0.56+0.22*pulse,0.56+0.22*pulse)
                d.Light.Brightness=0.45+0.7*pulse
                local hue=(t*CONFIG.ColorSpeed+d.Phase/(math.pi*2))%1
                local c=Color3.fromHSV(hue,0.72,1)
                d.Part.Color=c;d.Light.Color=c
            end
        end
        if StepEffect("WorldEnergyRebuild",CONFIG.Refresh) then
            local far=false
            for _,d in ipairs(nodes) do if (d.Base-Yuki_CameraCenter(10)).Magnitude>CONFIG.Radius*1.35 then far=true break end end
            if far then rebuild(Yuki_CameraCenter(10)) end
        end
    end

    local function enable()
        if running then return end
        running=true
        folder=Instance.new("Folder")
        folder.Name="YukiWorld_EnergyNodes"
        folder.Parent=Workspace
        local root=LocalPlayer.Character and PortalGetRoot(LocalPlayer.Character)
        rebuild(root and Yuki_CameraCenter(10) or (Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.Position) or Vector3.zero)
        conn=RunService.RenderStepped:Connect(update)
    end
    local function disable()
        running=false
        if conn then conn:Disconnect();conn=nil end
        if folder then folder:Destroy();folder=nil end
        table.clear(nodes);table.clear(beams)
    end
    _G.PortalVisuals._enableFuncs[name]=enable
    _G.PortalVisuals._disableFuncs[name]=disable
end

-- [[ Ground Vortex ]]
do
    local name="Ground Vortex"
    local running=false
    local conn=nil
    local folder=nil
    local rings={}
    local CONFIG={Count=6,Radius=42,OrbitRadius=5.5,Speed=0.7,Height=0.12}

    local function createRing(i,center)
        local angle=(i/CONFIG.Count)*math.pi*2
        local dist=10+((i%3)*9)
        local x=center.X+math.cos(angle)*dist
        local z=center.Z+math.sin(angle)*dist
        local hit=Workspace:Raycast(Vector3.new(x,center.Y+60,z),Vector3.new(0,-130,0))
        if not hit then return end
        local p=Instance.new("Part")
        p.Name="VortexRing_"..i
        p.Shape=Enum.PartType.Cylinder
        p.Size=Vector3.new(CONFIG.Height,2.0+i*0.18,2.0+i*0.18)
        p.Material=Enum.Material.Neon
        p.Color=Color3.fromHSV((0.72+i*0.025)%1,0.62,1)
        p.Transparency=0.62
        p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
        p.CFrame=CFrame.new(hit.Position+hit.Normal*0.04)*CFrame.Angles(0,0,math.rad(90))
        p.Parent=folder
        return {Part=p,Base=hit.Position,Phase=i*0.8,Size=p.Size.Y}
    end

    local function enable()
        if running then return end
        running=true
        folder=Instance.new("Folder")
        folder.Name="YukiWorld_GroundVortex"
        folder.Parent=Workspace
        rings={}
        local root=LocalPlayer.Character and PortalGetRoot(LocalPlayer.Character)
        local center=root and Yuki_CameraCenter(10) or (Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.Position) or Vector3.zero
        for i=1,CONFIG.Count do
            local d=createRing(i,center)
            if d then table.insert(rings,d) end
        end
        conn=RunService.RenderStepped:Connect(function(dt)
            if not running then return end
            local rootNow=LocalPlayer.Character and PortalGetRoot(LocalPlayer.Character)
            if not rootNow then return end
            local t=os.clock()
            for _,d in ipairs(rings) do
                if d.Part and d.Part.Parent then
                    local pulse=(math.sin(t*CONFIG.Speed+d.Phase)+1)*0.5
                    local s=d.Size*(0.94+0.12*pulse)
                    d.Part.Size=Vector3.new(CONFIG.Height,s,s)
                    d.Part.Transparency=0.74-0.20*pulse
                    d.Part.CFrame=CFrame.new(d.Base+Vector3.new(0,math.sin(t*0.8+d.Phase)*0.08,0))*CFrame.Angles(0,0,math.rad(90))*CFrame.Angles(0,0,t*0.5+d.Phase)
                    if (d.Base-Yuki_CameraCenter(10)).Magnitude>CONFIG.Radius then
                        d.Base=Yuki_CameraCenter(10)+Vector3.new(math.cos(d.Phase)*18,0,math.sin(d.Phase)*18)
                    end
                end
            end
        end)
    end
    local function disable()
        running=false
        if conn then conn:Disconnect();conn=nil end
        if folder then folder:Destroy();folder=nil end
        table.clear(rings)
    end
    _G.PortalVisuals._enableFuncs[name]=enable
    _G.PortalVisuals._disableFuncs[name]=disable
end

