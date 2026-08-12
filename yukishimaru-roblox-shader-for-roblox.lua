--[[
Author:
    Yukishimaru

TikTok:
    @yukishimaruoffc
]]

--============================================================
-- SERVICES
--============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--============================================================
-- CONFIG
--============================================================

local CONFIG = {
    Width = 800,
    Height = 510,

    Purple = Color3.fromRGB(153, 70, 255),
    PurpleLight = Color3.fromRGB(205, 138, 255),
    PurpleSoft = Color3.fromRGB(108, 44, 183),

    BackgroundTop = Color3.fromRGB(11, 6, 19),
    BackgroundBottom = Color3.fromRGB(42, 18, 63),

    Panel = Color3.fromRGB(27, 13, 42),
    PanelLight = Color3.fromRGB(43, 21, 63),

    White = Color3.fromRGB(247, 243, 255),
    Text = Color3.fromRGB(219, 209, 231),
    Muted = Color3.fromRGB(157, 142, 175),

    BubbleCount = 85,
    BubbleGravity = 110,
    BubbleMagnet = 8.5,
    BubbleDrag = 0.90,

    WindowRadius = 27,
    PanelRadius = 21,
    ButtonRadius = 14,

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

local Dragging = false
local DragStart = nil
local DragOrigin = nil
local SavedPosition = nil

local VignetteGui = nil
local MotionBlurEffect = nil
local LastCameraCFrame = nil

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

--============================================================
-- SCREEN GUI
--============================================================

local ScreenGui = Instance.new(
    "ScreenGui"
)

ScreenGui.Name =
    "YukiShaderEngine"

ScreenGui.ResetOnSpawn =
    false

ScreenGui.IgnoreGuiInset =
    true

ScreenGui.DisplayOrder =
    999999

ScreenGui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
    end
end)

ScreenGui.Parent =
    CoreGui

--============================================================
-- MAIN WINDOW
--============================================================

local Main = Instance.new("Frame")

Main.Name =
    "Main"

Main.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

Main.Position =
    UDim2.fromScale(
        0.5,
        0.5
    )

Main.Size =
    UDim2.fromOffset(
        CONFIG.Width,
        CONFIG.Height
    )

Main.BackgroundColor3 =
    CONFIG.BackgroundTop

Main.BackgroundTransparency =
    0.02

Main.BorderSizePixel =
    0

Main.ClipsDescendants =
    true

Main.ZIndex =
    1

Main.Parent =
    ScreenGui

AddCorner(
    Main,
    CONFIG.WindowRadius
)

AddStroke(
    Main,
    CONFIG.PurpleLight,
    0.56,
    1.25
)

AddGradient(
    Main,
    CONFIG.BackgroundTop,
    CONFIG.BackgroundBottom,
    35
)

--============================================================
-- OUTER GLOW
--============================================================

local OuterGlow =
    Instance.new("Frame")

OuterGlow.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

OuterGlow.Position =
    UDim2.fromScale(
        0.5,
        0.5
    )

OuterGlow.Size =
    UDim2.new(
        1,
        160,
        1,
        160
    )

OuterGlow.BackgroundColor3 =
    CONFIG.Purple

OuterGlow.BackgroundTransparency =
    0.955

OuterGlow.BorderSizePixel =
    0

OuterGlow.ZIndex =
    2

OuterGlow.Parent =
    Main

AddCorner(
    OuterGlow,
    60
)

--============================================================
-- BUBBLE LAYER
--============================================================

local BubbleLayer =
    Instance.new("Frame")

BubbleLayer.Name =
    "BubbleLayer"

BubbleLayer.Size =
    UDim2.fromScale(
        1,
        1
    )

BubbleLayer.BackgroundTransparency =
    1

BubbleLayer.BorderSizePixel =
    0

BubbleLayer.ClipsDescendants =
    true

BubbleLayer.ZIndex =
    5

BubbleLayer.Parent =
    Main

--============================================================
-- CONTENT
--============================================================

local Content =
    Instance.new("Frame")

Content.Name =
    "Content"

Content.Size =
    UDim2.fromScale(
        1,
        1
    )

Content.BackgroundTransparency =
    1

Content.BorderSizePixel =
    0

Content.ZIndex =
    20

Content.Parent =
    Main

--============================================================
-- HEADER
--============================================================

local Header =
    Instance.new("Frame")

Header.Name =
    "Header"

Header.Position =
    UDim2.fromOffset(
        26,
        20
    )

Header.Size =
    UDim2.new(
        1,
        -52,
        0,
        68
    )

Header.BackgroundTransparency =
    1

Header.BorderSizePixel =
    0

Header.ZIndex =
    30

Header.Parent =
    Content

--============================================================
-- LOGO
--============================================================

local Logo =
    Instance.new("Frame")

Logo.Position =
    UDim2.fromOffset(
        0,
        6
    )

Logo.Size =
    UDim2.fromOffset(
        54,
        54
    )

Logo.BackgroundColor3 =
    CONFIG.Purple

Logo.BackgroundTransparency =
    0.08

Logo.BorderSizePixel =
    0

Logo.ZIndex =
    31

Logo.Parent =
    Header

AddCorner(
    Logo,
    18
)

AddStroke(
    Logo,
    CONFIG.PurpleLight,
    0.28,
    1
)

local LogoOuter =
    Instance.new("Frame")

LogoOuter.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

LogoOuter.Position =
    UDim2.fromScale(
        0.5,
        0.5
    )

LogoOuter.Size =
    UDim2.fromOffset(
        21,
        21
    )

LogoOuter.BackgroundColor3 =
    CONFIG.White

LogoOuter.BorderSizePixel =
    0

LogoOuter.Rotation =
    45

LogoOuter.ZIndex =
    32

LogoOuter.Parent =
    Logo

AddCorner(
    LogoOuter,
    4
)

local LogoInner =
    Instance.new("Frame")

LogoInner.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

LogoInner.Position =
    UDim2.fromScale(
        0.5,
        0.5
    )

LogoInner.Size =
    UDim2.fromOffset(
        8,
        8
    )

LogoInner.BackgroundColor3 =
    CONFIG.Purple

LogoInner.BorderSizePixel =
    0

LogoInner.ZIndex =
    33

LogoInner.Parent =
    Logo

AddCorner(
    LogoInner,
    2
)

--============================================================
-- HEADER TEXT
--============================================================

local Title =
    Instance.new("TextLabel")

Title.Position =
    UDim2.fromOffset(
        70,
        2
    )

Title.Size =
    UDim2.new(
        1,
        -210,
        0,
        35
    )

Title.BackgroundTransparency =
    1

Title.Font =
    Enum.Font.GothamBold

Title.Text =
    "Yuki Shader Engine"

Title.TextSize =
    28

Title.TextColor3 =
    CONFIG.White

Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.ZIndex =
    31

Title.Parent =
    Header

local Subtitle =
    Instance.new("TextLabel")

Subtitle.Position =
    UDim2.fromOffset(
        71,
        38
    )

Subtitle.Size =
    UDim2.new(
        1,
        -210,
        0,
        20
    )

Subtitle.BackgroundTransparency =
    1

Subtitle.Font =
    Enum.Font.Gotham

Subtitle.Text =
    "Liquid Glass Shader Environment"

Subtitle.TextSize =
    12

Subtitle.TextColor3 =
    CONFIG.Muted

Subtitle.TextXAlignment =
    Enum.TextXAlignment.Left

Subtitle.ZIndex =
    31

Subtitle.Parent =
    Header

--============================================================
-- STATUS
--============================================================

local Status =
    Instance.new("Frame")

Status.AnchorPoint =
    Vector2.new(
        1,
        0
    )

Status.Position =
    UDim2.new(
        1,
        0,
        0,
        8
    )

Status.Size =
    UDim2.fromOffset(
        112,
        35
    )

Status.BackgroundColor3 =
    CONFIG.PanelLight

Status.BackgroundTransparency =
    0.12

Status.BorderSizePixel =
    0

Status.ZIndex =
    31

Status.Parent =
    Header

AddCorner(
    Status,
    13
)

AddStroke(
    Status,
    CONFIG.PurpleLight,
    0.78,
    1
)

local StatusDot =
    Instance.new("Frame")

StatusDot.Position =
    UDim2.fromOffset(
        13,
        13
    )

StatusDot.Size =
    UDim2.fromOffset(
        8,
        8
    )

StatusDot.BackgroundColor3 =
    CONFIG.PurpleLight

StatusDot.BorderSizePixel =
    0

StatusDot.ZIndex =
    32

StatusDot.Parent =
    Status

AddCorner(
    StatusDot,
    99
)

local StatusText =
    Instance.new("TextLabel")

StatusText.Position =
    UDim2.fromOffset(
        28,
        0
    )

StatusText.Size =
    UDim2.new(
        1,
        -35,
        1,
        0
    )

StatusText.BackgroundTransparency =
    1

StatusText.Font =
    Enum.Font.GothamSemibold

StatusText.Text =
    "READY"

StatusText.TextSize =
    10

StatusText.TextColor3 =
    CONFIG.White

StatusText.TextXAlignment =
    Enum.TextXAlignment.Left

StatusText.ZIndex =
    32

StatusText.Parent =
    Status

--============================================================
-- PAGE CONTAINER
--============================================================

local PageContainer =
    Instance.new("Frame")

PageContainer.Name =
    "PageContainer"

PageContainer.Position =
    UDim2.fromOffset(
        26,
        98
    )

PageContainer.Size =
    UDim2.new(
        1,
        -52,
        1,
        -175
    )

PageContainer.BackgroundTransparency =
    1

PageContainer.BorderSizePixel =
    0

PageContainer.ZIndex =
    20

PageContainer.Parent =
    Content

--============================================================
-- HOME PAGE
--============================================================

local HomePage =
    Instance.new("Frame")

HomePage.Name =
    "Home"

HomePage.Size =
    UDim2.fromScale(
        1,
        1
    )

HomePage.BackgroundTransparency =
    1

HomePage.BorderSizePixel =
    0

HomePage.Visible =
    true

HomePage.Parent =
    PageContainer

local HomeCard =
    Instance.new("Frame")

HomeCard.Size =
    UDim2.fromScale(
        1,
        1
    )

HomeCard.BackgroundColor3 =
    CONFIG.Panel

HomeCard.BackgroundTransparency =
    0.21

HomeCard.BorderSizePixel =
    0

HomeCard.ZIndex =
    20

HomeCard.Parent =
    HomePage

AddCorner(
    HomeCard,
    CONFIG.PanelRadius
)

AddStroke(
    HomeCard,
    CONFIG.PurpleLight,
    0.83,
    1
)

AddGradient(
    HomeCard,
    Color3.fromRGB(
        28,
        13,
        43
    ),
    Color3.fromRGB(
        45,
        20,
        64
    ),
    18
)

local HomeHighlight =
    Instance.new("Frame")

HomeHighlight.Position =
    UDim2.fromOffset(
        22,
        14
    )

HomeHighlight.Size =
    UDim2.new(
        1,
        -44,
        0,
        2
    )

HomeHighlight.BackgroundColor3 =
    CONFIG.PurpleLight

HomeHighlight.BackgroundTransparency =
    0.43

HomeHighlight.BorderSizePixel =
    0

HomeHighlight.ZIndex =
    21

HomeHighlight.Parent =
    HomeCard

AddCorner(
    HomeHighlight,
    5
)

local HomeTitle =
    Instance.new("TextLabel")

HomeTitle.Position =
    UDim2.fromOffset(
        27,
        27
    )

HomeTitle.Size =
    UDim2.new(
        1,
        -54,
        0,
        36
    )

HomeTitle.BackgroundTransparency =
    1

HomeTitle.Font =
    Enum.Font.GothamBold

HomeTitle.Text =
    "Welcome to Yuki Shader Engine"

HomeTitle.TextSize =
    23

HomeTitle.TextColor3 =
    CONFIG.White

HomeTitle.TextXAlignment =
    Enum.TextXAlignment.Left

HomeTitle.ZIndex =
    23

HomeTitle.Parent =
    HomeCard

local HomeDescription =
    Instance.new("TextLabel")

HomeDescription.Position =
    UDim2.fromOffset(
        28,
        64
    )

HomeDescription.Size =
    UDim2.new(
        1,
        -56,
        0,
        43
    )

HomeDescription.BackgroundTransparency =
    1

HomeDescription.Font =
    Enum.Font.Gotham

HomeDescription.Text =
    "Advanced visual presets and manual shader controls for Roblox."

HomeDescription.TextSize =
    13

HomeDescription.TextColor3 =
    CONFIG.Muted

HomeDescription.TextWrapped =
    true

HomeDescription.TextXAlignment =
    Enum.TextXAlignment.Left

HomeDescription.ZIndex =
    23

HomeDescription.Parent =
    HomeCard

--============================================================
-- AUTHOR CARD
--============================================================

local AuthorCard =
    Instance.new("Frame")

AuthorCard.Position =
    UDim2.fromOffset(
        27,
        124
    )

AuthorCard.Size =
    UDim2.new(
        0.61,
        -17,
        0,
        151
    )

AuthorCard.BackgroundColor3 =
    CONFIG.PanelLight

AuthorCard.BackgroundTransparency =
    0.27

AuthorCard.BorderSizePixel =
    0

AuthorCard.ZIndex =
    22

AuthorCard.Parent =
    HomeCard

AddCorner(
    AuthorCard,
    18
)

AddStroke(
    AuthorCard,
    CONFIG.PurpleLight,
    0.87,
    1
)

local AuthorTitle =
    Instance.new("TextLabel")

AuthorTitle.Position =
    UDim2.fromOffset(
        17,
        17
    )

AuthorTitle.Size =
    UDim2.new(
        1,
        -34,
        0,
        23
    )

AuthorTitle.BackgroundTransparency =
    1

AuthorTitle.Font =
    Enum.Font.GothamSemibold

AuthorTitle.Text =
    "About the project"

AuthorTitle.TextSize =
    14

AuthorTitle.TextColor3 =
    CONFIG.White

AuthorTitle.TextXAlignment =
    Enum.TextXAlignment.Left

AuthorTitle.ZIndex =
    23

AuthorTitle.Parent =
    AuthorCard

local AuthorText =
    Instance.new("TextLabel")

AuthorText.Position =
    UDim2.fromOffset(
        17,
        45
    )

AuthorText.Size =
    UDim2.new(
        1,
        -34,
        0,
        102
    )

AuthorText.BackgroundTransparency =
    1

AuthorText.Font =
    Enum.Font.Gotham

AuthorText.Text =
    "Welcome to my universal, free script for any Roblox game.\n\n" ..
    "What does it include? A massive collection of shaders, exactly what our game was missing.\n\n" ..
    "I write all the code myself, without a development team or AI. Enjoy!\n\n" ..
    "My TikTok: @yukishimaruoffc.\n\n" ..
    "If you make a video using my script, please to tag me in the description if you want!"

AuthorText.TextSize =
    10

AuthorText.TextColor3 =
    CONFIG.Text

AuthorText.TextWrapped =
    true

AuthorText.TextXAlignment =
    Enum.TextXAlignment.Left

AuthorText.TextYAlignment =
    Enum.TextYAlignment.Top

AuthorText.ZIndex =
    23

AuthorText.Parent =
    AuthorCard

--============================================================
-- ENGINE CARD
--============================================================

local EngineCard =
    Instance.new("Frame")

EngineCard.Position =
    UDim2.new(
        0.61,
        12,
        0,
        124
    )

EngineCard.Size =
    UDim2.new(
        0.39,
        -39,
        0,
        151
    )

EngineCard.BackgroundColor3 =
    CONFIG.PanelLight

EngineCard.BackgroundTransparency =
    0.27

EngineCard.BorderSizePixel =
    0

EngineCard.ZIndex =
    22

EngineCard.Parent =
    HomeCard

AddCorner(
    EngineCard,
    18
)

AddStroke(
    EngineCard,
    CONFIG.PurpleLight,
    0.87,
    1
)

local EngineTitle =
    Instance.new("TextLabel")

EngineTitle.Position =
    UDim2.fromOffset(
        17,
        17
    )

EngineTitle.Size =
    UDim2.new(
        1,
        -34,
        0,
        23
    )

EngineTitle.BackgroundTransparency =
    1

EngineTitle.Font =
    Enum.Font.GothamSemibold

EngineTitle.Text =
    "Engine"

EngineTitle.TextSize =
    14

EngineTitle.TextColor3 =
    CONFIG.White

EngineTitle.TextXAlignment =
    Enum.TextXAlignment.Left

EngineTitle.ZIndex =
    23

EngineTitle.Parent =
    EngineCard

local EngineStatus =
    Instance.new("TextLabel")

EngineStatus.Position =
    UDim2.fromOffset(
        17,
        47
    )

EngineStatus.Size =
    UDim2.new(
        1,
        -34,
        0,
        25
    )

EngineStatus.BackgroundTransparency =
    1

EngineStatus.Font =
    Enum.Font.GothamBold

EngineStatus.Text =
    "READY"

EngineStatus.TextSize =
    19

EngineStatus.TextColor3 =
    CONFIG.PurpleLight

EngineStatus.TextXAlignment =
    Enum.TextXAlignment.Left

EngineStatus.ZIndex =
    23

EngineStatus.Parent =
    EngineCard

local EnginePreset =
    Instance.new("TextLabel")

EnginePreset.Position =
    UDim2.fromOffset(
        17,
        80
    )

EnginePreset.Size =
    UDim2.new(
        1,
        -34,
        0,
        24
    )

EnginePreset.BackgroundTransparency =
    1

EnginePreset.Font =
    Enum.Font.Gotham

EnginePreset.Text =
    "Preset: Default"

EnginePreset.TextSize =
    10

EnginePreset.TextColor3 =
    CONFIG.Muted

EnginePreset.TextXAlignment =
    Enum.TextXAlignment.Left

EnginePreset.ZIndex =
    23

EnginePreset.Parent =
    EngineCard

local EngineHint =
    Instance.new("TextLabel")

EngineHint.Position =
    UDim2.fromOffset(
        17,
        108
    )

EngineHint.Size =
    UDim2.new(
        1,
        -34,
        0,
        30
    )

EngineHint.BackgroundTransparency =
    1

EngineHint.Font =
    Enum.Font.Gotham

EngineHint.Text =
    "Use Presets or Settings below."

EngineHint.TextSize =
    9

EngineHint.TextColor3 =
    CONFIG.Muted

EngineHint.TextWrapped =
    true

EngineHint.TextXAlignment =
    Enum.TextXAlignment.Left

EngineHint.ZIndex =
    23

EngineHint.Parent =
    EngineCard

--============================================================
-- PRESETS PAGE
--============================================================

local PresetsPage =
    Instance.new("Frame")

PresetsPage.Name =
    "Presets"

PresetsPage.Size =
    UDim2.fromScale(
        1,
        1
    )

PresetsPage.BackgroundColor3 =
    CONFIG.Panel

PresetsPage.BackgroundTransparency =
    0.21

PresetsPage.BorderSizePixel =
    0

PresetsPage.Visible =
    false

PresetsPage.ZIndex =
    20

PresetsPage.Parent =
    PageContainer

AddCorner(
    PresetsPage,
    CONFIG.PanelRadius
)

AddStroke(
    PresetsPage,
    CONFIG.PurpleLight,
    0.83,
    1
)

AddGradient(
    PresetsPage,
    Color3.fromRGB(
        28,
        13,
        43
    ),
    Color3.fromRGB(
        45,
        20,
        64
    ),
    18
)

local PresetsTitle =
    Instance.new("TextLabel")

PresetsTitle.Position =
    UDim2.fromOffset(
        20,
        16
    )

PresetsTitle.Size =
    UDim2.new(
        1,
        -40,
        0,
        26
    )

PresetsTitle.BackgroundTransparency =
    1

PresetsTitle.Font =
    Enum.Font.GothamBold

PresetsTitle.Text =
    "Shader Presets"

PresetsTitle.TextSize =
    20

PresetsTitle.TextColor3 =
    CONFIG.White

PresetsTitle.TextXAlignment =
    Enum.TextXAlignment.Left

PresetsTitle.ZIndex =
    22

PresetsTitle.Parent =
    PresetsPage

local PresetsSubtitle =
    Instance.new("TextLabel")

PresetsSubtitle.Position =
    UDim2.fromOffset(
        21,
        42
    )

PresetsSubtitle.Size =
    UDim2.new(
        1,
        -42,
        0,
        21
    )

PresetsSubtitle.BackgroundTransparency =
    1

PresetsSubtitle.Font =
    Enum.Font.Gotham

PresetsSubtitle.Text =
    "Choose a preset. Loading a preset resets previous shader state."

PresetsSubtitle.TextSize =
    10

PresetsSubtitle.TextColor3 =
    CONFIG.Muted

PresetsSubtitle.TextXAlignment =
    Enum.TextXAlignment.Left

PresetsSubtitle.ZIndex =
    22

PresetsSubtitle.Parent =
    PresetsPage

local PresetScroll =
    Instance.new("ScrollingFrame")

PresetScroll.Position =
    UDim2.fromOffset(
        15,
        70
    )

PresetScroll.Size =
    UDim2.new(
        1,
        -30,
        1,
        -84
    )

PresetScroll.BackgroundTransparency =
    1

PresetScroll.BorderSizePixel =
    0

PresetScroll.ScrollBarThickness =
    3

PresetScroll.ScrollBarImageColor3 =
    CONFIG.Purple

PresetScroll.CanvasSize =
    UDim2.fromOffset(
        0,
        0
    )

PresetScroll.ZIndex =
    22

PresetScroll.Parent =
    PresetsPage

local PresetLayout =
    Instance.new("UIGridLayout")

PresetLayout.CellSize =
    UDim2.new(
        0.333,
        -8,
        0,
        55
    )

PresetLayout.CellPadding =
    UDim2.fromOffset(
        8,
        8
    )

PresetLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

PresetLayout.Parent =
    PresetScroll

--============================================================
-- SETTINGS PAGE
--============================================================

local SettingsPage =
    Instance.new("Frame")

SettingsPage.Name =
    "Settings"

SettingsPage.Size =
    UDim2.fromScale(
        1,
        1
    )

SettingsPage.BackgroundColor3 =
    CONFIG.Panel

SettingsPage.BackgroundTransparency =
    0.21

SettingsPage.BorderSizePixel =
    0

SettingsPage.Visible =
    false

SettingsPage.ZIndex =
    20

SettingsPage.Parent =
    PageContainer

AddCorner(
    SettingsPage,
    CONFIG.PanelRadius
)

AddStroke(
    SettingsPage,
    CONFIG.PurpleLight,
    0.83,
    1
)

AddGradient(
    SettingsPage,
    Color3.fromRGB(
        28,
        13,
        43
    ),
    Color3.fromRGB(
        45,
        20,
        64
    ),
    18
)

local SettingsTitle =
    Instance.new("TextLabel")

SettingsTitle.Position =
    UDim2.fromOffset(
        20,
        16
    )

SettingsTitle.Size =
    UDim2.new(
        1,
        -180,
        0,
        26
    )

SettingsTitle.BackgroundTransparency =
    1

SettingsTitle.Font =
    Enum.Font.GothamBold

SettingsTitle.Text =
    "Shader Settings"

SettingsTitle.TextSize =
    20

SettingsTitle.TextColor3 =
    CONFIG.White

SettingsTitle.TextXAlignment =
    Enum.TextXAlignment.Left

SettingsTitle.ZIndex =
    22

SettingsTitle.Parent =
    SettingsPage

local SettingsSubtitle =
    Instance.new("TextLabel")

SettingsSubtitle.Position =
    UDim2.fromOffset(
        21,
        42
    )

SettingsSubtitle.Size =
    UDim2.new(
        1,
        -190,
        0,
        21
    )

SettingsSubtitle.BackgroundTransparency =
    1

SettingsSubtitle.Font =
    Enum.Font.Gotham

SettingsSubtitle.Text =
    "Changes apply instantly without recreating the shader stack."

SettingsSubtitle.TextSize =
    10

SettingsSubtitle.TextColor3 =
    CONFIG.Muted

SettingsSubtitle.TextXAlignment =
    Enum.TextXAlignment.Left

SettingsSubtitle.ZIndex =
    22

SettingsSubtitle.Parent =
    SettingsPage

local ResetSettingsButton =
    Instance.new("TextButton")

ResetSettingsButton.AnchorPoint =
    Vector2.new(
        1,
        0
    )

ResetSettingsButton.Position =
    UDim2.new(
        1,
        -20,
        0,
        16
    )

ResetSettingsButton.Size =
    UDim2.fromOffset(
        120,
        31
    )

ResetSettingsButton.BackgroundColor3 =
    Color3.fromRGB(
        49,
        23,
        69
    )

ResetSettingsButton.BackgroundTransparency =
    0.06

ResetSettingsButton.BorderSizePixel =
    0

ResetSettingsButton.AutoButtonColor =
    false

ResetSettingsButton.Text =
    "Reset"

ResetSettingsButton.Font =
    Enum.Font.GothamSemibold

ResetSettingsButton.TextSize =
    9

ResetSettingsButton.TextColor3 =
    CONFIG.White

ResetSettingsButton.ZIndex =
    23

ResetSettingsButton.Parent =
    SettingsPage

AddCorner(
    ResetSettingsButton,
    10
)

local SettingsScroll =
    Instance.new("ScrollingFrame")

SettingsScroll.Position =
    UDim2.fromOffset(
        15,
        70
    )

SettingsScroll.Size =
    UDim2.new(
        1,
        -30,
        1,
        -84
    )

SettingsScroll.BackgroundTransparency =
    1

SettingsScroll.BorderSizePixel =
    0

SettingsScroll.ScrollBarThickness =
    3

SettingsScroll.ScrollBarImageColor3 =
    CONFIG.Purple

SettingsScroll.CanvasSize =
    UDim2.fromOffset(
        0,
        0
    )

SettingsScroll.ZIndex =
    22

SettingsScroll.Parent =
    SettingsPage

--============================================================
-- EFFECT FACTORY
--============================================================

local function CreateEffect(
    effectType,
    properties
)
    local effect

    if effectType == "Bloom" then

        effect =
            Instance.new(
                "BloomEffect"
            )

    elseif effectType == "ColorCorrection" then

        effect =
            Instance.new(
                "ColorCorrectionEffect"
            )

    elseif effectType == "Blur" then

        effect =
            Instance.new(
                "BlurEffect"
            )

    elseif effectType == "DepthOfField" then

        effect =
            Instance.new(
                "DepthOfFieldEffect"
            )

    elseif effectType == "SunRays" then

        effect =
            Instance.new(
                "SunRaysEffect"
            )

    elseif effectType == "Atmosphere" then

        effect =
            Instance.new(
                "Atmosphere"
            )

    else
        return nil
    end

    effect.Name =
        CONFIG.ShaderPrefix
        .. effectType

    for property, value in pairs(
        properties or {}
    ) do

        pcall(function()
            effect[property] =
                value
        end)
    end

    effect.Parent =
        Lighting

    Effects[effectType] =
        effect

    return effect
end

--============================================================
-- DESTROY OUR EFFECTS
--============================================================

local function DestroyShaderEffects()
    for key, effect in pairs(
        Effects
    ) do

        if effect then
            SafeDestroy(effect)
        end

        Effects[key] = nil
    end

    -- safety cleanup
    for _, child in ipairs(
        Lighting:GetChildren()
    ) do

        if child.Name:sub(
            1,
            #CONFIG.ShaderPrefix
        ) == CONFIG.ShaderPrefix then

            SafeDestroy(child)
        end
    end

    if MotionBlurEffect then
        SafeDestroy(
            MotionBlurEffect
        )
        MotionBlurEffect = nil
    end
end

--============================================================
-- VIGNETTE
--============================================================

local function DestroyVignette()
    if VignetteGui then
        SafeDestroy(
            VignetteGui
        )

        VignetteGui = nil
    end
end

local function CreateVignette(
    strength
)
    DestroyVignette()

    VignetteGui =
        Instance.new(
            "ScreenGui"
        )

    VignetteGui.Name =
        CONFIG.VignetteName

    VignetteGui.IgnoreGuiInset =
        true

    VignetteGui.ResetOnSpawn =
        false

    VignetteGui.DisplayOrder =
        999998

    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(
                VignetteGui
            )
        end
    end)

    VignetteGui.Parent =
        CoreGui

    local top =
        Instance.new("Frame")

    top.Size =
        UDim2.new(
            1,
            0,
            0.27,
            0
        )

    top.BackgroundColor3 =
        Color3.new(
            0,
            0,
            0
        )

    top.BackgroundTransparency =
        Clamp(
            1 - strength * 0.72,
            0.18,
            0.98
        )

    top.BorderSizePixel =
        0

    top.Parent =
        VignetteGui

    local topGradient =
        Instance.new(
            "UIGradient"
        )

    topGradient.Rotation =
        90

    topGradient.Transparency =
        NumberSequence.new({
            NumberSequenceKeypoint.new(
                0,
                0
            ),
            NumberSequenceKeypoint.new(
                1,
                1
            )
        })

    topGradient.Parent =
        top

    local bottom =
        top:Clone()

    bottom.AnchorPoint =
        Vector2.new(
            0,
            1
        )

    bottom.Position =
        UDim2.fromScale(
            0,
            1
        )

    bottom.Rotation =
        180

    bottom.Parent =
        VignetteGui

    local left =
        Instance.new("Frame")

    left.Size =
        UDim2.new(
            0.20,
            0,
            1,
            0
        )

    left.BackgroundColor3 =
        Color3.new(
            0,
            0,
            0
        )

    left.BackgroundTransparency =
        Clamp(
            1 - strength * 0.68,
            0.18,
            0.98
        )

    left.BorderSizePixel =
        0

    left.Parent =
        VignetteGui

    local leftGradient =
        Instance.new(
            "UIGradient"
        )

    leftGradient.Transparency =
        NumberSequence.new({
            NumberSequenceKeypoint.new(
                0,
                0
            ),
            NumberSequenceKeypoint.new(
                1,
                1
            )
        })

    leftGradient.Parent =
        left

    local right =
        left:Clone()

    right.AnchorPoint =
        Vector2.new(
            1,
            0
        )

    right.Position =
        UDim2.fromScale(
            1,
            0
        )

    right.Rotation =
        180

    right.Parent =
        VignetteGui
end

local function UpdateVignette()
    if not ShaderState.Vignette then
        DestroyVignette()
        return
    end

    CreateVignette(
        ShaderState.VignetteStrength
    )
end

--============================================================
-- MOTION BLUR
--============================================================

local function StopMotionBlur()
    if MotionBlurEffect then
        SafeDestroy(
            MotionBlurEffect
        )
        MotionBlurEffect = nil
    end

    Effects.MotionBlur = nil
    LastCameraCFrame = nil
end

local function StartMotionBlur()
    if MotionBlurEffect then
        return
    end

    MotionBlurEffect =
        Instance.new(
            "BlurEffect"
        )

    MotionBlurEffect.Name =
        CONFIG.ShaderPrefix
        .. "MotionBlur"

    MotionBlurEffect.Size =
        0

    MotionBlurEffect.Parent =
        Lighting

    Effects.MotionBlur =
        MotionBlurEffect

    local camera =
        workspace.CurrentCamera

    if camera then
        LastCameraCFrame =
            camera.CFrame
    end
end

--============================================================
-- MOTION BLUR RENDER LOOP
--============================================================

Connect(
    RunService.RenderStepped,
    function(deltaTime)

        if not Alive then
            return
        end

        if not ShaderState.MotionBlur then

            if MotionBlurEffect then
                StopMotionBlur()
            end

            return
        end

        local camera =
            workspace.CurrentCamera

        if not camera then
            return
        end

        StartMotionBlur()

        if not LastCameraCFrame then
            LastCameraCFrame =
                camera.CFrame
            return
        end

        local current =
            camera.CFrame

        local positionDelta =
            (
                current.Position
                -
                LastCameraCFrame.Position
            ).Magnitude

        local a1, b1, c1 =
            current:ToOrientation()

        local a2, b2, c2 =
            LastCameraCFrame:ToOrientation()

        local rotationDelta =
            math.abs(
                a1 - a2
            )
            +
            math.abs(
                b1 - b2
            )
            +
            math.abs(
                c1 - c2
            )

        local movement =
            positionDelta
            +
            rotationDelta * 18

        local target =
            Clamp(
                movement
                * ShaderState.MotionBlurStrength
                * 12,

                0,
                24
            )

        MotionBlurEffect.Size =
            MotionBlurEffect.Size
            +
            (
                target
                -
                MotionBlurEffect.Size
            )
            *
            Clamp(
                deltaTime * 12,
                0,
                1
            )

        LastCameraCFrame =
            current
    end
)

--============================================================
-- DEFAULT STATE RESET
--============================================================

local function ResetShaderState()
    ShaderState.Saturation = 0
    ShaderState.Brightness = 0
    ShaderState.Contrast = 0

    ShaderState.Blur = 0

    ShaderState.BloomIntensity = 0
    ShaderState.BloomSize = 24
    ShaderState.BloomThreshold = 1

    ShaderState.SunRaysIntensity = 0
    ShaderState.SunRaysSpread = 1

    ShaderState.DOFFarIntensity = 0
    ShaderState.DOFNearIntensity = 0
    ShaderState.DOFFocusDistance = 10

    ShaderState.AtmosphereDensity = 0

    ShaderState.MotionBlur = false
    ShaderState.MotionBlurStrength = 0

    ShaderState.Vignette = false
    ShaderState.VignetteStrength = 0

    CurrentPreset =
        "Default"
end

--============================================================
-- LIVE EFFECT UPDATERS
--============================================================

local function UpdateColorCorrection()
    local effect =
        Effects.ColorCorrection

    if not effect then
        return
    end

    effect.Saturation =
        ShaderState.Saturation

    effect.Brightness =
        ShaderState.Brightness

    effect.Contrast =
        ShaderState.Contrast
end

local function UpdateBlur()
    local effect =
        Effects.Blur

    if not effect then
        return
    end

    effect.Size =
        ShaderState.Blur
end

local function UpdateBloom()
    local effect =
        Effects.Bloom

    if not effect then
        return
    end

    effect.Intensity =
        ShaderState.BloomIntensity

    effect.Size =
        ShaderState.BloomSize

    effect.Threshold =
        ShaderState.BloomThreshold
end

local function UpdateSunRays()
    local effect =
        Effects.SunRays

    if not effect then
        return
    end

    effect.Intensity =
        ShaderState.SunRaysIntensity

    effect.Spread =
        ShaderState.SunRaysSpread
end

local function UpdateDOF()
    local effect =
        Effects.DepthOfField

    if not effect then
        return
    end

    effect.FarIntensity =
        ShaderState.DOFFarIntensity

    effect.NearIntensity =
        ShaderState.DOFNearIntensity

    effect.FocusDistance =
        ShaderState.DOFFocusDistance
end

local function UpdateAtmosphere()
    local effect =
        Effects.Atmosphere

    if not effect then
        return
    end

    effect.Density =
        ShaderState.AtmosphereDensity

    effect.Color =
        ShaderState.AtmosphereColor
end

--============================================================
-- ENSURE EFFECT
--============================================================

local function EnsureEffect(effectType)
    if Effects[effectType] then
        return Effects[effectType]
    end

    if effectType == "ColorCorrection" then

        return CreateEffect(
            "ColorCorrection",
            {
                Saturation =
                    ShaderState.Saturation,

                Brightness =
                    ShaderState.Brightness,

                Contrast =
                    ShaderState.Contrast
            }
        )

    elseif effectType == "Blur" then

        return CreateEffect(
            "Blur",
            {
                Size =
                    ShaderState.Blur
            }
        )

    elseif effectType == "Bloom" then

        return CreateEffect(
            "Bloom",
            {
                Intensity =
                    ShaderState.BloomIntensity,

                Size =
                    ShaderState.BloomSize,

                Threshold =
                    ShaderState.BloomThreshold
            }
        )

    elseif effectType == "SunRays" then

        return CreateEffect(
            "SunRays",
            {
                Intensity =
                    ShaderState.SunRaysIntensity,

                Spread =
                    ShaderState.SunRaysSpread
            }
        )

    elseif effectType == "DepthOfField" then

        return CreateEffect(
            "DepthOfField",
            {
                FarIntensity =
                    ShaderState.DOFFarIntensity,

                NearIntensity =
                    ShaderState.DOFNearIntensity,

                FocusDistance =
                    ShaderState.DOFFocusDistance
            }
        )

    elseif effectType == "Atmosphere" then

        return CreateEffect(
            "Atmosphere",
            {
                Density =
                    ShaderState.AtmosphereDensity,

                Color =
                    ShaderState.AtmosphereColor
            }
        )
    end

    return nil
end

--============================================================
-- LIVE SETTING CHANGE
--============================================================

local function SetLiveSetting(
    key,
    value
)
    ShaderState[key] =
        value

    CurrentPreset =
        "Custom"

    EnginePreset.Text =
        "Preset: Custom"

    if key == "Saturation"
        or key == "Brightness"
        or key == "Contrast" then

        EnsureEffect(
            "ColorCorrection"
        )

        UpdateColorCorrection()

    elseif key == "Blur" then

        if value <= 0 then

            SafeDestroy(
                Effects.Blur
            )

            Effects.Blur =
                nil

        else

            EnsureEffect(
                "Blur"
            )

            UpdateBlur()
        end

    elseif key == "BloomIntensity"
        or key == "BloomSize"
        or key == "BloomThreshold" then

        if ShaderState.BloomIntensity <= 0 then

            SafeDestroy(
                Effects.Bloom
            )

            Effects.Bloom =
                nil

        else

            EnsureEffect(
                "Bloom"
            )

            UpdateBloom()
        end

    elseif key == "SunRaysIntensity"
        or key == "SunRaysSpread" then

        if ShaderState.SunRaysIntensity <= 0 then

            SafeDestroy(
                Effects.SunRays
            )

            Effects.SunRays =
                nil

        else

            EnsureEffect(
                "SunRays"
            )

            UpdateSunRays()
        end

    elseif key == "DOFFarIntensity"
        or key == "DOFNearIntensity"
        or key == "DOFFocusDistance" then

        if ShaderState.DOFFarIntensity <= 0
            and ShaderState.DOFNearIntensity <= 0 then

            SafeDestroy(
                Effects.DepthOfField
            )

            Effects.DepthOfField =
                nil

        else

            EnsureEffect(
                "DepthOfField"
            )

            UpdateDOF()
        end

    elseif key == "AtmosphereDensity" then

        if value <= 0 then

            SafeDestroy(
                Effects.Atmosphere
            )

            Effects.Atmosphere =
                nil

        else

            EnsureEffect(
                "Atmosphere"
            )

            UpdateAtmosphere()
        end

    elseif key == "MotionBlurStrength" then

        if value <= 0 then

            ShaderState.MotionBlur =
                false

            StopMotionBlur()

        else

            ShaderState.MotionBlur =
                true

            StartMotionBlur()
        end

    elseif key == "VignetteStrength" then

        if value <= 0 then

            ShaderState.Vignette =
                false

            DestroyVignette()

        else

            ShaderState.Vignette =
                true

            UpdateVignette()
        end
    end
end

--============================================================
-- PRESETS
--============================================================

local Presets = {

    Default = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()
        StopMotionBlur()

    end,

    Cinematic = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()

        CreateEffect(
            "Bloom",
            {
                Intensity = 0.5,
                Size = 20,
                Threshold = 0.6
            }
        )

        CreateEffect(
            "DepthOfField",
            {
                FarIntensity = 0.6,
                NearIntensity = 0.2,
                FocusDistance = 15
            }
        )

        CreateEffect(
            "ColorCorrection",
            {
                Saturation = 0.2,
                Contrast = 0.1,
                Brightness = -0.05
            }
        )

        CreateEffect(
            "SunRays",
            {
                Intensity = 0.4,
                Spread = 0.8
            }
        )

        CreateEffect(
            "Atmosphere",
            {
                Density = 0.3,
                Color = Color3.fromRGB(
                    200,
                    180,
                    255
                )
            }
        )
    end,

    Neon = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()

        CreateEffect(
            "Bloom",
            {
                Intensity = 1.2,
                Size = 40,
                Threshold = 0.3
            }
        )

        CreateEffect(
            "ColorCorrection",
            {
                Saturation = 0.8,
                Contrast = 0.3,
                Brightness = 0.1
            }
        )

        CreateEffect(
            "Blur",
            {
                Size = 3
            }
        )
    end,

    Vintage = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()

        CreateEffect(
            "ColorCorrection",
            {
                Saturation = -0.3,
                Contrast = -0.1,
                Brightness = 0.05,

                TintColor =
                    Color3.fromRGB(
                        255,
                        200,
                        150
                    )
            }
        )

        CreateEffect(
            "Bloom",
            {
                Intensity = 0.2,
                Size = 15,
                Threshold = 0.9
            }
        )

        CreateEffect(
            "Blur",
            {
                Size = 2
            }
        )
    end,

    Cold = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()

        CreateEffect(
            "ColorCorrection",
            {
                TintColor =
                    Color3.fromRGB(
                        150,
                        200,
                        255
                    ),

                Brightness = -0.05,
                Saturation = -0.1
            }
        )

        CreateEffect(
            "Atmosphere",
            {
                Color =
                    Color3.fromRGB(
                        100,
                        150,
                        255
                    ),

                Density = 0.4
            }
        )
    end,

    Warm = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()

        CreateEffect(
            "ColorCorrection",
            {
                TintColor =
                    Color3.fromRGB(
                        255,
                        200,
                        100
                    ),

                Brightness = 0.05,
                Saturation = 0.1
            }
        )

        CreateEffect(
            "Bloom",
            {
                Intensity = 0.4,
                Size = 25,
                Threshold = 0.7
            }
        )
    end,

    Noir = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()

        CreateEffect(
            "ColorCorrection",
            {
                Saturation = -1,
                Contrast = 0.5,
                Brightness = -0.1
            }
        )

        CreateEffect(
            "Bloom",
            {
                Intensity = 0.1,
                Size = 5,
                Threshold = 0.5
            }
        )
    end,

    Dreamy = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()

        CreateEffect(
            "Bloom",
            {
                Intensity = 0.8,
                Size = 35,
                Threshold = 0.4
            }
        )

        CreateEffect(
            "Blur",
            {
                Size = 6
            }
        )

        CreateEffect(
            "ColorCorrection",
            {
                Brightness = 0.1,
                Saturation = 0.3
            }
        )
    end,

    Pastel = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()

        CreateEffect(
            "ColorCorrection",
            {
                Brightness = 0.15,
                Contrast = -0.1,
                Saturation = 0.1,

                TintColor =
                    Color3.fromRGB(
                        255,
                        200,
                        200
                    )
            }
        )

        CreateEffect(
            "Bloom",
            {
                Intensity = 0.6,
                Size = 30,
                Threshold = 0.5
            }
        )

        CreateEffect(
            "Blur",
            {
                Size = 2
            }
        )
    end,

    Cyberpunk = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()

        CreateEffect(
            "ColorCorrection",
            {
                Brightness = -0.1,
                Contrast = 0.4,
                Saturation = 0.6,

                TintColor =
                    Color3.fromRGB(
                        255,
                        50,
                        200
                    )
            }
        )

        CreateEffect(
            "Bloom",
            {
                Intensity = 1.0,
                Size = 45,
                Threshold = 0.2
            }
        )

        CreateEffect(
            "SunRays",
            {
                Intensity = 0.6,
                Spread = 0.9
            }
        )
    end,

    Horror = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()

        CreateEffect(
            "ColorCorrection",
            {
                Brightness = -0.3,
                Contrast = 0.5,
                Saturation = -0.5,

                TintColor =
                    Color3.fromRGB(
                        50,
                        200,
                        50
                    )
            }
        )

        CreateEffect(
            "DepthOfField",
            {
                FarIntensity = 0.8,
                NearIntensity = 0.1,
                FocusDistance = 5
            }
        )

        CreateEffect(
            "Blur",
            {
                Size = 4
            }
        )
    end,

    Sunset = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()

        CreateEffect(
            "ColorCorrection",
            {
                Brightness = 0.1,
                Contrast = 0.1,
                Saturation = 0.3,

                TintColor =
                    Color3.fromRGB(
                        255,
                        150,
                        50
                    )
            }
        )

        CreateEffect(
            "Bloom",
            {
                Intensity = 0.7,
                Size = 25,
                Threshold = 0.5
            }
        )

        CreateEffect(
            "Atmosphere",
            {
                Color =
                    Color3.fromRGB(
                        255,
                        100,
                        50
                    ),

                Density = 0.3
            }
        )

        CreateEffect(
            "SunRays",
            {
                Intensity = 0.5,
                Spread = 0.7
            }
        )
    end,

    Aqua = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()

        CreateEffect(
            "ColorCorrection",
            {
                Brightness = -0.05,
                Contrast = 0.1,
                Saturation = 0.2,

                TintColor =
                    Color3.fromRGB(
                        50,
                        200,
                        255
                    )
            }
        )

        CreateEffect(
            "Bloom",
            {
                Intensity = 0.4,
                Size = 20,
                Threshold = 0.6
            }
        )

        CreateEffect(
            "Atmosphere",
            {
                Color =
                    Color3.fromRGB(
                        50,
                        150,
                        255
                    ),

                Density = 0.2
            }
        )

        CreateEffect(
            "Blur",
            {
                Size = 1
            }
        )
    end,

    Sepia = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()

        CreateEffect(
            "ColorCorrection",
            {
                Brightness = 0.05,
                Contrast = 0.1,
                Saturation = -0.5,

                TintColor =
                    Color3.fromRGB(
                        200,
                        150,
                        100
                    )
            }
        )

        CreateEffect(
            "Bloom",
            {
                Intensity = 0.2,
                Size = 15,
                Threshold = 0.8
            }
        )

        CreateEffect(
            "Blur",
            {
                Size = 1
            }
        )
    end,

    Matrix = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()

        CreateEffect(
            "ColorCorrection",
            {
                Brightness = -0.1,
                Contrast = 0.3,
                Saturation = 0.2,

                TintColor =
                    Color3.fromRGB(
                        50,
                        255,
                        50
                    )
            }
        )

        CreateEffect(
            "Bloom",
            {
                Intensity = 0.3,
                Size = 10,
                Threshold = 0.7
            }
        )

        CreateEffect(
            "Blur",
            {
                Size = 1
            }
        )
    end,

    Mystic = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()

        CreateEffect(
            "ColorCorrection",
            {
                Brightness = 0.05,
                Contrast = 0.1,
                Saturation = 0.4,

                TintColor =
                    Color3.fromRGB(
                        150,
                        100,
                        255
                    )
            }
        )

        CreateEffect(
            "Bloom",
            {
                Intensity = 0.9,
                Size = 40,
                Threshold = 0.3
            }
        )

        CreateEffect(
            "Atmosphere",
            {
                Color =
                    Color3.fromRGB(
                        100,
                        50,
                        200
                    ),

                Density = 0.2
            }
        )

        CreateEffect(
            "DepthOfField",
            {
                FarIntensity = 0.3,
                NearIntensity = 0.1,
                FocusDistance = 20
            }
        )
    end,

    Retro = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()

        CreateEffect(
            "ColorCorrection",
            {
                Brightness = 0.1,
                Contrast = 0.2,
                Saturation = 0.1,

                TintColor =
                    Color3.fromRGB(
                        255,
                        200,
                        100
                    )
            }
        )

        CreateEffect(
            "Bloom",
            {
                Intensity = 0.5,
                Size = 18,
                Threshold = 0.7
            }
        )

        CreateEffect(
            "Blur",
            {
                Size = 3
            }
        )

        ShaderState.Vignette =
            true

        ShaderState.VignetteStrength =
            0.30

        UpdateVignette()
    end,

    Aurora = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()

        CreateEffect(
            "ColorCorrection",
            {
                Brightness = 0.05,
                Contrast = 0.1,
                Saturation = 0.3,

                TintColor =
                    Color3.fromRGB(
                        100,
                        255,
                        200
                    )
            }
        )

        CreateEffect(
            "Bloom",
            {
                Intensity = 0.6,
                Size = 30,
                Threshold = 0.4
            }
        )

        CreateEffect(
            "Atmosphere",
            {
                Color =
                    Color3.fromRGB(
                        50,
                        255,
                        150
                    ),

                Density = 0.15
            }
        )

        CreateEffect(
            "SunRays",
            {
                Intensity = 0.3,
                Spread = 0.6
            }
        )
    end,

    ["Soapy Graphics (Beta)"] = function()

        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()

        CreateEffect(
            "DepthOfField",
            {
                FarIntensity = 1.0,
                NearIntensity = 0.1,
                FocusDistance = 10
            }
        )

        CreateEffect(
            "Bloom",
            {
                Intensity = 0.3,
                Size = 20,
                Threshold = 0.8
            }
        )

        CreateEffect(
            "Atmosphere",
            {
                Density = 0.3,

                Color =
                    Color3.fromRGB(
                        200,
                        200,
                        210
                    )
            }
        )

        CreateEffect(
            "ColorCorrection",
            {
                Brightness = 0.2,
                Contrast = -0.1,
                Saturation = -0.1
            }
        )
    end
}

--============================================================
-- PRESET LIST
--============================================================

local PresetNames = {
    "Default",
    "Cinematic",
    "Neon",
    "Vintage",
    "Cold",
    "Warm",
    "Noir",
    "Dreamy",
    "Pastel",
    "Cyberpunk",
    "Horror",
    "Sunset",
    "Aqua",
    "Sepia",
    "Matrix",
    "Mystic",
    "Retro",
    "Aurora",
    "Soapy Graphics (Beta)"
}

local RefreshAllSliders

--============================================================
-- APPLY PRESET
--============================================================

local function SyncStateFromLoadedPreset()
    local colorCorrection =
        Effects.ColorCorrection

    if colorCorrection then
        ShaderState.Saturation =
            colorCorrection.Saturation

        ShaderState.Brightness =
            colorCorrection.Brightness

        ShaderState.Contrast =
            colorCorrection.Contrast
    else
        ShaderState.Saturation = 0
        ShaderState.Brightness = 0
        ShaderState.Contrast = 0
    end

    if Effects.Blur then
        ShaderState.Blur =
            Effects.Blur.Size
    else
        ShaderState.Blur = 0
    end

    if Effects.Bloom then
        ShaderState.BloomIntensity =
            Effects.Bloom.Intensity

        ShaderState.BloomSize =
            Effects.Bloom.Size

        ShaderState.BloomThreshold =
            Effects.Bloom.Threshold
    else
        ShaderState.BloomIntensity = 0
        ShaderState.BloomSize = 24
        ShaderState.BloomThreshold = 1
    end

    if Effects.SunRays then
        ShaderState.SunRaysIntensity =
            Effects.SunRays.Intensity

        ShaderState.SunRaysSpread =
            Effects.SunRays.Spread
    else
        ShaderState.SunRaysIntensity = 0
        ShaderState.SunRaysSpread = 1
    end

    if Effects.DepthOfField then
        ShaderState.DOFFarIntensity =
            Effects.DepthOfField.FarIntensity

        ShaderState.DOFNearIntensity =
            Effects.DepthOfField.NearIntensity

        ShaderState.DOFFocusDistance =
            Effects.DepthOfField.FocusDistance
    else
        ShaderState.DOFFarIntensity = 0
        ShaderState.DOFNearIntensity = 0
        ShaderState.DOFFocusDistance = 10
    end

    if Effects.Atmosphere then
        ShaderState.AtmosphereDensity =
            Effects.Atmosphere.Density

        ShaderState.AtmosphereColor =
            Effects.Atmosphere.Color
    else
        ShaderState.AtmosphereDensity = 0
    end
end

local function ApplyPreset(
    presetName
)
    local preset =
        Presets[presetName]

    if not preset then
        return
    end

    -- Every new preset starts clean:
    -- previous manual changes are discarded.
    DestroyShaderEffects()
    DestroyVignette()
    StopMotionBlur()
    ResetShaderState()

    CurrentPreset =
        presetName

    -- Load the selected preset.
    preset()

    -- Read the values created by the preset into ShaderState.
    -- This is the important part that makes the Settings sliders
    -- control the selected preset instead of starting from zero.
    SyncStateFromLoadedPreset()

    EnginePreset.Text =
        "Preset: "
        .. presetName

    EngineStatus.Text =
        "ACTIVE"

    -- Synchronize slider positions and values with the preset.
    if RefreshAllSliders then
        RefreshAllSliders()
    end

    if ToggleUI then
        for _, refresh in pairs(
            ToggleUI
        ) do
            refresh()
        end
    end
end

--============================================================
-- PRESET BUTTONS
--============================================================

for index, presetName in ipairs(
    PresetNames
) do

    local button =
        Instance.new("TextButton")

    button.Name =
        "Preset_" .. presetName

    button.LayoutOrder =
        index

    button.BackgroundColor3 =
        Color3.fromRGB(
            41,
            19,
            59
        )

    button.BackgroundTransparency =
        0.10

    button.BorderSizePixel =
        0

    button.AutoButtonColor =
        false

    button.Text =
        ""

    button.ZIndex =
        23

    button.Parent =
        PresetScroll

    AddCorner(
        button,
        13
    )

    local stroke =
        AddStroke(
            button,
            CONFIG.PurpleLight,
            0.89,
            1
        )

    local accent =
        Instance.new("Frame")

    accent.Position =
        UDim2.fromOffset(
            9,
            9
        )

    accent.Size =
        UDim2.fromOffset(
            4,
            37
        )

    accent.BackgroundColor3 =
        CONFIG.Purple

    accent.BorderSizePixel =
        0

    accent.ZIndex =
        24

    accent.Parent =
        button

    AddCorner(
        accent,
        5
    )

    local title =
        Instance.new("TextLabel")

    title.Position =
        UDim2.fromOffset(
            23,
            7
        )

    title.Size =
        UDim2.new(
            1,
            -31,
            0,
            19
        )

    title.BackgroundTransparency =
        1

    title.Font =
        Enum.Font.GothamSemibold

    title.Text =
        presetName

    title.TextSize =
        10

    title.TextColor3 =
        CONFIG.White

    title.TextTruncate =
        Enum.TextTruncate.AtEnd

    title.TextXAlignment =
        Enum.TextXAlignment.Left

    title.ZIndex =
        25

    title.Parent =
        button

    local subtitle =
        Instance.new("TextLabel")

    subtitle.Position =
        UDim2.fromOffset(
            23,
            26
        )

    subtitle.Size =
        UDim2.new(
            1,
            -31,
            0,
            12
        )

    subtitle.BackgroundTransparency =
        1

    subtitle.Font =
        Enum.Font.Gotham

    subtitle.Text =
        "Apply visual preset"

    subtitle.TextSize =
        7

    subtitle.TextColor3 =
        CONFIG.Muted

    subtitle.TextXAlignment =
        Enum.TextXAlignment.Left

    subtitle.ZIndex =
        25

    subtitle.Parent =
        button

    Connect(
        button.MouseEnter,
        function()

            Tween(
                button,
                {
                    BackgroundColor3 =
                        Color3.fromRGB(
                            55,
                            25,
                            78
                        ),

                    BackgroundTransparency =
                        0.02
                },
                0.20,
                Enum.EasingStyle.Sine
            )

            Tween(
                stroke,
                {
                    Transparency =
                        0.42,

                    Thickness =
                        1.25
                },
                0.20
            )

            Tween(
                accent,
                {
                    Size =
                        UDim2.fromOffset(
                            6,
                            39
                        )
                },
                0.20,
                Enum.EasingStyle.Back
            )
        end
    )

    Connect(
        button.MouseLeave,
        function()

            Tween(
                button,
                {
                    BackgroundColor3 =
                        Color3.fromRGB(
                            41,
                            19,
                            59
                        ),

                    BackgroundTransparency =
                        0.10
                },
                0.30,
                Enum.EasingStyle.Sine
            )

            Tween(
                stroke,
                {
                    Transparency =
                        0.89,

                    Thickness =
                        1
                },
                0.30
            )

            Tween(
                accent,
                {
                    Size =
                        UDim2.fromOffset(
                            4,
                            37
                        )
                },
                0.30,
                Enum.EasingStyle.Sine
            )
        end
    )

    Connect(
        button.MouseButton1Click,
        function()

            ApplyPreset(
                presetName
            )

            Tween(
                button,
                {
                    BackgroundColor3 =
                        CONFIG.Purple
                },
                0.12,
                Enum.EasingStyle.Sine
            )

            task.delay(
                0.13,
                function()

                    if not Alive then
                        return
                    end

                    Tween(
                        button,
                        {
                            BackgroundColor3 =
                                Color3.fromRGB(
                                    41,
                                    19,
                                    59
                                )
                        },
                        0.35,
                        Enum.EasingStyle.Sine
                    )
                end
            )
        end
    )
end

PresetScroll.CanvasSize =
    UDim2.fromOffset(
        0,
        math.ceil(
            #PresetNames / 3
        ) * 63
    )

--============================================================
-- SETTINGS DEFINITIONS
--============================================================

local SettingDefinitions = {
    {
        Name = "Saturation",
        Key = "Saturation",
        Min = -1,
        Max = 1,
        Step = 0.01,
        Default = 0
    },

    {
        Name = "Brightness",
        Key = "Brightness",
        Min = -1,
        Max = 1,
        Step = 0.01,
        Default = 0
    },

    {
        Name = "Contrast",
        Key = "Contrast",
        Min = -1,
        Max = 1,
        Step = 0.01,
        Default = 0
    },

    {
        Name = "Blur",
        Key = "Blur",
        Min = 0,
        Max = 24,
        Step = 1,
        Default = 0
    },

    {
        Name = "Bloom",
        Key = "BloomIntensity",
        Min = 0,
        Max = 2,
        Step = 0.01,
        Default = 0
    },

    {
        Name = "Bloom Size",
        Key = "BloomSize",
        Min = 1,
        Max = 56,
        Step = 1,
        Default = 24
    },

    {
        Name = "Sun Rays",
        Key = "SunRaysIntensity",
        Min = 0,
        Max = 1,
        Step = 0.01,
        Default = 0
    },

    {
        Name = "DOF Far",
        Key = "DOFFarIntensity",
        Min = 0,
        Max = 1,
        Step = 0.01,
        Default = 0
    },

    {
        Name = "DOF Near",
        Key = "DOFNearIntensity",
        Min = 0,
        Max = 1,
        Step = 0.01,
        Default = 0
    },

    {
        Name = "DOF Focus",
        Key = "DOFFocusDistance",
        Min = 1,
        Max = 100,
        Step = 1,
        Default = 10
    },

    {
        Name = "Atmosphere",
        Key = "AtmosphereDensity",
        Min = 0,
        Max = 1,
        Step = 0.01,
        Default = 0
    },

    {
        Name = "Motion Blur Strength",
        Key = "MotionBlurStrength",
        Min = 0,
        Max = 1,
        Step = 0.01,
        Default = 0
    },

    {
        Name = "Vignette Strength",
        Key = "VignetteStrength",
        Min = 0,
        Max = 1,
        Step = 0.01,
        Default = 0
    }
}

--============================================================
-- SETTINGS UI REFERENCES
--============================================================

local SliderUI = {}

--============================================================
-- SLIDER CREATOR
--============================================================

local function CreateSlider(
    parent,
    definition,
    index
)

    local row =
        Instance.new("Frame")

    row.Name =
        definition.Key

    row.Position =
        UDim2.fromOffset(
            8,
            (index - 1) * 65
        )

    row.Size =
        UDim2.new(
            1,
            -16,
            0,
            58
        )

    row.BackgroundColor3 =
        Color3.fromRGB(
            39,
            18,
            56
        )

    row.BackgroundTransparency =
        0.18

    row.BorderSizePixel =
        0

    row.ZIndex =
        23

    row.Parent =
        parent

    AddCorner(
        row,
        13
    )

    AddStroke(
        row,
        CONFIG.PurpleLight,
        0.91,
        1
    )

    local label =
        Instance.new("TextLabel")

    label.Position =
        UDim2.fromOffset(
            13,
            7
        )

    label.Size =
        UDim2.new(
            1,
            -100,
            0,
            18
        )

    label.BackgroundTransparency =
        1

    label.Font =
        Enum.Font.GothamMedium

    label.Text =
        definition.Name

    label.TextSize =
        10

    label.TextColor3 =
        CONFIG.Text

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.ZIndex =
        24

    label.Parent =
        row

    local valueLabel =
        Instance.new("TextLabel")

    valueLabel.AnchorPoint =
        Vector2.new(
            1,
            0
        )

    valueLabel.Position =
        UDim2.new(
            1,
            -13,
            0,
            7
        )

    valueLabel.Size =
        UDim2.fromOffset(
            70,
            18
        )

    valueLabel.BackgroundTransparency =
        1

    valueLabel.Font =
        Enum.Font.GothamSemibold

    valueLabel.TextSize =
        9

    valueLabel.TextColor3 =
        CONFIG.PurpleLight

    valueLabel.TextXAlignment =
        Enum.TextXAlignment.Right

    valueLabel.ZIndex =
        24

    valueLabel.Parent =
        row

    local track =
        Instance.new("Frame")

    track.Position =
        UDim2.fromOffset(
            13,
            37
        )

    track.Size =
        UDim2.new(
            1,
            -26,
            0,
            6
        )

    track.BackgroundColor3 =
        Color3.fromRGB(
            68,
            38,
            84
        )

    track.BorderSizePixel =
        0

    track.ZIndex =
        24

    track.Parent =
        row

    AddCorner(
        track,
        10
    )

    local fill =
        Instance.new("Frame")

    fill.Size =
        UDim2.fromScale(
            0,
            1
        )

    fill.BackgroundColor3 =
        CONFIG.Purple

    fill.BorderSizePixel =
        0

    fill.ZIndex =
        25

    fill.Parent =
        track

    AddCorner(
        fill,
        10
    )

    local knob =
        Instance.new("Frame")

    knob.AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        )

    knob.Position =
        UDim2.fromScale(
            0,
            0.5
        )

    knob.Size =
        UDim2.fromOffset(
            12,
            12
        )

    knob.BackgroundColor3 =
        CONFIG.White

    knob.BorderSizePixel =
        0

    knob.ZIndex =
        26

    knob.Parent =
        track

    AddCorner(
        knob,
        99
    )

    local dragging =
        false

    local function SetUIValue(
        value,
        instant
    )
        local normalized =
            (
                value
                -
                definition.Min
            )
            /
            (
                definition.Max
                -
                definition.Min
            )

        normalized =
            Clamp(
                normalized,
                0,
                1
            )

        valueLabel.Text =
            string.format(
                "%.2f",
                value
            )

        if instant then

            fill.Size =
                UDim2.fromScale(
                    normalized,
                    1
                )

            knob.Position =
                UDim2.fromScale(
                    normalized,
                    0.5
                )

        else

            Tween(
                fill,
                {
                    Size =
                        UDim2.fromScale(
                            normalized,
                            1
                        )
                },
                0.08,
                Enum.EasingStyle.Sine
            )

            Tween(
                knob,
                {
                    Position =
                        UDim2.fromScale(
                            normalized,
                            0.5
                        )
                },
                0.08,
                Enum.EasingStyle.Sine
            )
        end
    end

    local function UpdateFromMouse(
        mouseX
    )
        local trackWidth =
            math.max(
                track.AbsoluteSize.X,
                1
            )

        local normalized =
            Clamp(
                (
                    mouseX
                    -
                    track.AbsolutePosition.X
                )
                /
                trackWidth,
                0,
                1
            )

        local rawValue =
            definition.Min
            +
            (
                definition.Max
                -
                definition.Min
            )
            *
            normalized

        local value =
            math.round(
                rawValue
                /
                definition.Step
            )
            *
            definition.Step

        value =
            Clamp(
                value,
                definition.Min,
                definition.Max
            )

        ShaderState[
            definition.Key
        ] =
            value

        SetUIValue(
            value,
            false
        )

        SetLiveSetting(
            definition.Key,
            value
        )
    end

    Connect(
        track.InputBegan,
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1 then

                dragging =
                    true

                UpdateFromMouse(
                    input.Position.X
                )
            end
        end
    )

    Connect(
        UserInputService.InputChanged,
        function(input)

            if not dragging then
                return
            end

            if input.UserInputType ==
                Enum.UserInputType.MouseMovement then

                UpdateFromMouse(
                    input.Position.X
                )
            end
        end
    )

    Connect(
        UserInputService.InputEnded,
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1 then

                dragging =
                    false
            end
        end
    )

    SliderUI[
        definition.Key
    ] = {
        SetValue =
            SetUIValue
    }

    SetUIValue(
        definition.Default,
        true
    )
end

for index, definition in ipairs(
    SettingDefinitions
) do

    CreateSlider(
        SettingsScroll,
        definition,
        index
    )
end

--============================================================
-- UPDATE ALL SLIDER UI
--============================================================

RefreshAllSliders = function()
    for _, definition in ipairs(
        SettingDefinitions
    ) do

        local data =
            SliderUI[
                definition.Key
            ]

        if data then

            local value =
                ShaderState[
                    definition.Key
                ]

            if value == nil then
                value =
                    definition.Default
            end

            data.SetValue(
                value,
                true
            )
        end
    end
end

SettingsScroll.CanvasSize =
    UDim2.fromOffset(
        0,
        #SettingDefinitions
        * 65
        + 140
    )

--============================================================
-- TOGGLE CREATOR
--============================================================

local ToggleUI = {}

local function CreateToggle(
    parent,
    name,
    index,
    getter,
    setter
)

    local y =
        #SettingDefinitions
        * 65
        + 8
        + (
            index - 1
        ) * 53

    local row =
        Instance.new("TextButton")

    row.Name =
        name

    row.Position =
        UDim2.fromOffset(
            8,
            y
        )

    row.Size =
        UDim2.new(
            1,
            -16,
            0,
            45
        )

    row.BackgroundColor3 =
        Color3.fromRGB(
            39,
            18,
            56
        )

    row.BackgroundTransparency =
        0.18

    row.BorderSizePixel =
        0

    row.AutoButtonColor =
        false

    row.Text =
        ""

    row.ZIndex =
        23

    row.Parent =
        parent

    AddCorner(
        row,
        13
    )

    AddStroke(
        row,
        CONFIG.PurpleLight,
        0.91,
        1
    )

    local title =
        Instance.new("TextLabel")

    title.Position =
        UDim2.fromOffset(
            13,
            0
        )

    title.Size =
        UDim2.new(
            1,
            -85,
            1,
            0
        )

    title.BackgroundTransparency =
        1

    title.Font =
        Enum.Font.GothamMedium

    title.Text =
        name

    title.TextSize =
        10

    title.TextColor3 =
        CONFIG.Text

    title.TextXAlignment =
        Enum.TextXAlignment.Left

    title.ZIndex =
        24

    title.Parent =
        row

    local switch =
        Instance.new("Frame")

    switch.AnchorPoint =
        Vector2.new(
            1,
            0.5
        )

    switch.Position =
        UDim2.new(
            1,
            -13,
            0.5,
            0
        )

    switch.Size =
        UDim2.fromOffset(
            42,
            20
        )

    switch.BackgroundColor3 =
        Color3.fromRGB(
            61,
            34,
            78
        )

    switch.BorderSizePixel =
        0

    switch.ZIndex =
        24

    switch.Parent =
        row

    AddCorner(
        switch,
        99
    )

    local knob =
        Instance.new("Frame")

    knob.Position =
        UDim2.fromOffset(
            2,
            2
        )

    knob.Size =
        UDim2.fromOffset(
            16,
            16
        )

    knob.BackgroundColor3 =
        CONFIG.White

    knob.BorderSizePixel =
        0

    knob.ZIndex =
        25

    knob.Parent =
        switch

    AddCorner(
        knob,
        99
    )

    local function Refresh()
        local state =
            getter()

        if state then

            Tween(
                switch,
                {
                    BackgroundColor3 =
                        CONFIG.Purple
                },
                0.18,
                Enum.EasingStyle.Sine
            )

            Tween(
                knob,
                {
                    Position =
                        UDim2.fromOffset(
                            24,
                            2
                        )
                },
                0.22,
                Enum.EasingStyle.Back
            )

        else

            Tween(
                switch,
                {
                    BackgroundColor3 =
                        Color3.fromRGB(
                            61,
                            34,
                            78
                        )
                },
                0.18,
                Enum.EasingStyle.Sine
            )

            Tween(
                knob,
                {
                    Position =
                        UDim2.fromOffset(
                            2,
                            2
                        )
                },
                0.22,
                Enum.EasingStyle.Back
            )
        end
    end

    Connect(
        row.MouseButton1Click,
        function()

            local newValue =
                not getter()

            setter(
                newValue
            )

            CurrentPreset =
                "Custom"

            EnginePreset.Text =
                "Preset: Custom"

            Refresh()
        end
    )

    ToggleUI[name] =
        Refresh

    Refresh()
end

CreateToggle(
    SettingsScroll,
    "Motion Blur",
    1,

    function()
        return ShaderState.MotionBlur
    end,

    function(value)

        ShaderState.MotionBlur =
            value

        ShaderState.MotionBlurStrength =
            math.max(
                ShaderState.MotionBlurStrength,
                0.15
            )

        if value then
            StartMotionBlur()
        else
            StopMotionBlur()
        end
    end
)

CreateToggle(
    SettingsScroll,
    "Vignette",
    2,

    function()
        return ShaderState.Vignette
    end,

    function(value)

        ShaderState.Vignette =
            value

        if value then

            ShaderState.VignetteStrength =
                math.max(
                    ShaderState.VignetteStrength,
                    0.30
                )

            UpdateVignette()

        else

            DestroyVignette()
        end
    end
)

SettingsScroll.CanvasSize =
    UDim2.fromOffset(
        0,
        #SettingDefinitions
        * 65
        + 8
        + 2 * 53
        + 20
    )

--============================================================
-- RESET SETTINGS
--============================================================

Connect(
    ResetSettingsButton.MouseButton1Click,
    function()

        ApplyPreset(
            "Default"
        )

        RefreshAllSliders()

        for _, refresh in pairs(
            ToggleUI
        ) do
            refresh()
        end

        EnginePreset.Text =
            "Preset: Default"
    end
)

--============================================================
-- NAVIGATION
--============================================================

local Navigation =
    Instance.new("Frame")

Navigation.Name =
    "Navigation"

Navigation.Position =
    UDim2.new(
        0,
        26,
        1,
        -67
    )

Navigation.Size =
    UDim2.new(
        1,
        -52,
        0,
        50
    )

Navigation.BackgroundTransparency =
    1

Navigation.BorderSizePixel =
    0

Navigation.ZIndex =
    50

Navigation.Parent =
    Content

local ButtonWidth = 145
local ButtonHeight = 50
local ButtonGap = 5

local function BuildHomeIcon(parent)

    -- Body: solid white
    local body =
        Instance.new("Frame")

    body.Position =
        UDim2.fromOffset(8, 14)

    body.Size =
        UDim2.fromOffset(20, 15)

    body.BackgroundColor3 =
        CONFIG.White

    body.BorderSizePixel = 0
    body.ZIndex = 55
    body.Parent = parent

    AddCorner(body, 3)

    -- Roof: two clean white strokes meeting at the center
    local roofLeft =
        Instance.new("Frame")

    roofLeft.AnchorPoint =
        Vector2.new(0.5, 0.5)

    roofLeft.Position =
        UDim2.fromOffset(13, 10)

    roofLeft.Size =
        UDim2.fromOffset(15, 4)

    roofLeft.BackgroundColor3 =
        CONFIG.White

    roofLeft.BorderSizePixel = 0
    roofLeft.Rotation = 31
    roofLeft.ZIndex = 56
    roofLeft.Parent = parent

    AddCorner(roofLeft, 3)

    local roofRight = roofLeft:Clone()

    roofRight.Position =
        UDim2.fromOffset(23, 10)

    roofRight.Rotation = -31
    roofRight.Parent = parent

    -- Door: also pure white; no purple cut-out
    local door =
        Instance.new("Frame")

    door.AnchorPoint =
        Vector2.new(0.5, 1)

    door.Position =
        UDim2.fromScale(0.5, 1)

    door.Size =
        UDim2.fromOffset(6, 9)

    door.BackgroundColor3 =
        CONFIG.White

    door.BorderSizePixel = 0
    door.ZIndex = 57
    door.Parent = body

    AddCorner(door, 2)
end

local function BuildGridIcon(parent)

    for x = 0, 1 do
        for y = 0, 1 do

            local cube =
                Instance.new("Frame")

            cube.Position =
                UDim2.fromOffset(7 + x * 12, 7 + y * 12)

            cube.Size =
                UDim2.fromOffset(9, 9)

            cube.BackgroundColor3 =
                CONFIG.White

            cube.BorderSizePixel = 0
            cube.ZIndex = 55
            cube.Parent = parent

            AddCorner(cube, 3)
        end
    end
end

local function BuildSettingsIcon(parent)

    -- Pure white cog. The center is also white so the whole icon is one color.
    local center =
        Instance.new("Frame")

    center.AnchorPoint =
        Vector2.new(0.5, 0.5)

    center.Position =
        UDim2.fromScale(0.5, 0.5)

    center.Size =
        UDim2.fromOffset(13, 13)

    center.BackgroundColor3 =
        CONFIG.White

    center.BorderSizePixel = 0
    center.ZIndex = 56
    center.Parent = parent

    AddCorner(center, 99)

    for i = 0, 7 do

        local tooth =
            Instance.new("Frame")

        tooth.AnchorPoint =
            Vector2.new(0.5, 0.5)

        tooth.Position =
            UDim2.fromScale(0.5, 0.5)

        tooth.Size =
            UDim2.fromOffset(5, 10)

        tooth.BackgroundColor3 =
            CONFIG.White

        tooth.BorderSizePixel = 0
        tooth.Rotation = i * 45
        tooth.ZIndex = 55
        tooth.Parent = parent

        AddCorner(tooth, 2)
    end
end

local function BuildCollapseIcon(parent)

    local line =
        Instance.new("Frame")

    line.AnchorPoint =
        Vector2.new(0.5, 0.5)

    line.Position =
        UDim2.fromScale(0.5, 0.5)

    line.Size =
        UDim2.fromOffset(22, 3)

    line.BackgroundColor3 =
        CONFIG.White

    line.BorderSizePixel = 0
    line.ZIndex = 55
    line.Parent = parent

    AddCorner(line, 3)
end

local function BuildExitIcon(parent)

    -- Door body - solid white
    local door =
        Instance.new("Frame")

    door.Position =
        UDim2.fromOffset(5, 5)

    door.Size =
        UDim2.fromOffset(13, 22)

    door.BackgroundColor3 =
        CONFIG.White

    door.BorderSizePixel = 0
    door.ZIndex = 55
    door.Parent = parent

    AddCorner(door, 3)

    -- Visible white exit arrow, kept completely inside the icon holder
    local arrow =
        Instance.new("Frame")

    arrow.Position =
        UDim2.fromOffset(17, 16)

    arrow.Size =
        UDim2.fromOffset(12, 3)

    arrow.BackgroundColor3 =
        CONFIG.White

    arrow.BorderSizePixel = 0
    arrow.ZIndex = 57
    arrow.Parent = parent

    AddCorner(arrow, 3)

    local arrowTop =
        Instance.new("Frame")

    arrowTop.Position =
        UDim2.fromOffset(24, 12)

    arrowTop.Size =
        UDim2.fromOffset(8, 3)

    arrowTop.BackgroundColor3 =
        CONFIG.White

    arrowTop.BorderSizePixel = 0
    arrowTop.Rotation = 36
    arrowTop.ZIndex = 58
    arrowTop.Parent = parent

    AddCorner(arrowTop, 3)

    local arrowBottom = arrowTop:Clone()

    arrowBottom.Position =
        UDim2.fromOffset(24, 20)

    arrowBottom.Rotation = -36
    arrowBottom.Parent = parent
end

local NavButtons = {}

local function CreateNavButton(
    index,
    name,
    description,
    iconBuilder
)

    local button =
        Instance.new("TextButton")

    button.Name =
        name

    button.Position =
        UDim2.fromOffset(
            (index - 1)
            * (ButtonWidth + ButtonGap),
            0
        )

    button.Size =
        UDim2.fromOffset(
            ButtonWidth,
            ButtonHeight
        )

    button.BackgroundColor3 =
        Color3.fromRGB(
            38,
            18,
            56
        )

    button.BackgroundTransparency =
        0.10

    button.BorderSizePixel =
        0

    button.AutoButtonColor =
        false

    button.Text =
        ""

    button.ZIndex =
        51

    button.Parent =
        Navigation

    AddCorner(
        button,
        CONFIG.ButtonRadius
    )

    local stroke =
        AddStroke(
            button,
            CONFIG.PurpleLight,
            0.87,
            1
        )

    local iconHolder =
        Instance.new("Frame")

    iconHolder.Position =
        UDim2.fromOffset(
            8,
            7
        )

    iconHolder.Size =
        UDim2.fromOffset(
            36,
            36
        )

    iconHolder.BackgroundColor3 =
        CONFIG.Purple

    iconHolder.BackgroundTransparency =
        0.78

    iconHolder.BorderSizePixel =
        0

    iconHolder.ZIndex =
        52

    iconHolder.Parent =
        button

    AddCorner(
        iconHolder,
        11
    )

    iconBuilder(
        iconHolder
    )

    local title =
        Instance.new("TextLabel")

    title.Position =
        UDim2.fromOffset(
            53,
            6
        )

    title.Size =
        UDim2.new(
            1,
            -60,
            0,
            18
        )

    title.BackgroundTransparency =
        1

    title.Font =
        Enum.Font.GothamSemibold

    title.Text =
        name

    title.TextSize =
        11

    title.TextColor3 =
        CONFIG.Text

    title.TextXAlignment =
        Enum.TextXAlignment.Left

    title.ZIndex =
        53

    title.Parent =
        button

    local sub =
        Instance.new("TextLabel")

    sub.Position =
        UDim2.fromOffset(
            53,
            24
        )

    sub.Size =
        UDim2.new(
            1,
            -60,
            0,
            15
        )

    sub.BackgroundTransparency =
        1

    sub.Font =
        Enum.Font.Gotham

    sub.Text =
        description

    sub.TextSize =
        8

    sub.TextColor3 =
        CONFIG.Muted

    sub.TextXAlignment =
        Enum.TextXAlignment.Left

    sub.ZIndex =
        53

    sub.Parent =
        button

    Connect(
        button.MouseEnter,
        function()

            Tween(
                button,
                {
                    BackgroundColor3 =
                        Color3.fromRGB(
                            53,
                            25,
                            76
                        ),

                    BackgroundTransparency =
                        0.02
                },
                0.22,
                Enum.EasingStyle.Sine
            )

            Tween(
                stroke,
                {
                    Transparency =
                        0.45,

                    Thickness =
                        1.3
                },
                0.22,
                Enum.EasingStyle.Sine
            )

            Tween(
                iconHolder,
                {
                    BackgroundTransparency =
                        0.55,

                    Size =
                        UDim2.fromOffset(
                            38,
                            38
                        ),

                    Position =
                        UDim2.fromOffset(
                            7,
                            6
                        )
                },
                0.22,
                Enum.EasingStyle.Back
            )

            Tween(
                title,
                {
                    TextColor3 =
                        CONFIG.White
                },
                0.18
            )
        end
    )

    Connect(
        button.MouseLeave,
        function()

            Tween(
                button,
                {
                    BackgroundColor3 =
                        Color3.fromRGB(
                            38,
                            18,
                            56
                        ),

                    BackgroundTransparency =
                        0.10
                },
                0.30,
                Enum.EasingStyle.Sine
            )

            Tween(
                stroke,
                {
                    Transparency =
                        0.87,

                    Thickness =
                        1
                },
                0.30,
                Enum.EasingStyle.Sine
            )

            Tween(
                iconHolder,
                {
                    BackgroundTransparency =
                        0.78,

                    Size =
                        UDim2.fromOffset(
                            36,
                            36
                        ),

                    Position =
                        UDim2.fromOffset(
                            8,
                            7
                        )
                },
                0.30,
                Enum.EasingStyle.Sine
            )

            Tween(
                title,
                {
                    TextColor3 =
                        CONFIG.Text
                },
                0.22
            )
        end
    )

    NavButtons[name] =
        button

    return button
end

local HomeButton =
    CreateNavButton(
        1,
        "Home",
        "About project",
        BuildHomeIcon
    )

local PresetsButton =
    CreateNavButton(
        2,
        "Presets",
        "Shader presets",
        BuildGridIcon
    )

local SettingsButton =
    CreateNavButton(
        3,
        "Settings",
        "Fine controls",
        BuildSettingsIcon
    )

local CollapseButton =
    CreateNavButton(
        4,
        "Collapse",
        "Hide window",
        BuildCollapseIcon
    )

local ExitButton =
    CreateNavButton(
        5,
        "Exit",
        "Unload engine",
        BuildExitIcon
    )

--============================================================
-- PAGE SWITCHING
--============================================================

local Pages = {
    Home = HomePage,
    Presets = PresetsPage,
    Settings = SettingsPage
}

local function SwitchPage(
    pageName
)
    local page =
        Pages[pageName]

    if not page then
        return
    end

    if CurrentPage ==
        pageName then
        return
    end

    CurrentPage =
        pageName

    for _, pageObject in pairs(
        Pages
    ) do

        pageObject.Visible =
            false
    end

    page.Visible =
        true

    page.Position =
        UDim2.fromOffset(
            8,
            0
        )

    Tween(
        page,
        {
            Position =
                UDim2.fromOffset(
                    0,
                    0
                )
        },
        0.32,
        Enum.EasingStyle.Quint
    )
end

Connect(
    HomeButton.MouseButton1Click,
    function()
        SwitchPage(
            "Home"
        )
    end
)

Connect(
    PresetsButton.MouseButton1Click,
    function()
        SwitchPage(
            "Presets"
        )
    end
)

Connect(
    SettingsButton.MouseButton1Click,
    function()
        SwitchPage(
            "Settings"
        )
    end
)

--============================================================
-- COLLAPSE
--============================================================

local function SetCollapsed(
    state
)
    if not Alive then
        return
    end

    if Collapsed ==
        state then
        return
    end

    Collapsed =
        state

    if state then

        SavedPosition =
            Main.Position

        Tween(
            Main,
            {
                Size =
                    UDim2.fromOffset(
                        8,
                        8
                    ),

                BackgroundTransparency =
                    1
            },
            0.42,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.In
        )

        task.delay(
            0.28,
            function()

                if not Alive
                    or not Collapsed then
                    return
                end

                Main.Visible =
                    false
            end
        )

    else

        Main.Visible =
            true

        Main.Position =
            SavedPosition

        Main.Size =
            UDim2.fromOffset(
                8,
                8
            )

        Main.BackgroundTransparency =
            1

        Tween(
            Main,
            {
                Size =
                    UDim2.fromOffset(
                        CONFIG.Width,
                        CONFIG.Height
                    ),

                BackgroundTransparency =
                    0.02
            },
            0.48,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        )
    end
end

Connect(
    CollapseButton.MouseButton1Click,
    function()
        SetCollapsed(
            true
        )
    end
)

Connect(
    UserInputService.InputBegan,
    function(
        input,
        processed
    )

        if processed then
            return
        end

        if input.KeyCode ==
            CONFIG.RightAlt then

            if ConfirmOpen then
                return
            end

            SetCollapsed(
                not Collapsed
            )
        end
    end
)

--============================================================
-- EXIT CONFIRMATION
--============================================================

local Overlay =
    Instance.new("Frame")

Overlay.Name =
    "ConfirmOverlay"

Overlay.Size =
    UDim2.fromScale(
        1,
        1
    )

Overlay.BackgroundColor3 =
    Color3.fromRGB(
        2,
        1,
        5
    )

Overlay.BackgroundTransparency =
    1

Overlay.BorderSizePixel =
    0

Overlay.Visible =
    false

Overlay.ZIndex =
    100

Overlay.Parent =
    Main

local Confirm =
    Instance.new("Frame")

Confirm.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

Confirm.Position =
    UDim2.fromScale(
        0.5,
        0.5
    )

Confirm.Size =
    UDim2.fromOffset(
        420,
        220
    )

Confirm.BackgroundColor3 =
    Color3.fromRGB(
        28,
        13,
        43
    )

Confirm.BackgroundTransparency =
    0.02

Confirm.BorderSizePixel =
    0

Confirm.ZIndex =
    101

Confirm.Parent =
    Overlay

AddCorner(
    Confirm,
    22
)

AddStroke(
    Confirm,
    CONFIG.PurpleLight,
    0.57,
    1
)

AddGradient(
    Confirm,
    Color3.fromRGB(
        32,
        15,
        47
    ),
    Color3.fromRGB(
        47,
        20,
        67
    ),
    20
)

local ConfirmTitle =
    Instance.new("TextLabel")

ConfirmTitle.Position =
    UDim2.fromOffset(
        25,
        22
    )

ConfirmTitle.Size =
    UDim2.new(
        1,
        -50,
        0,
        32
    )

ConfirmTitle.BackgroundTransparency =
    1

ConfirmTitle.Font =
    Enum.Font.GothamBold

ConfirmTitle.Text =
    "Close Yuki Shader Engine?"

ConfirmTitle.TextSize =
    20

ConfirmTitle.TextColor3 =
    CONFIG.White

ConfirmTitle.TextXAlignment =
    Enum.TextXAlignment.Left

ConfirmTitle.ZIndex =
    103

ConfirmTitle.Parent =
    Confirm

local ConfirmText =
    Instance.new("TextLabel")

ConfirmText.Position =
    UDim2.fromOffset(
        25,
        67
    )

ConfirmText.Size =
    UDim2.new(
        1,
        -50,
        0,
        55
    )

ConfirmText.BackgroundTransparency =
    1

ConfirmText.Font =
    Enum.Font.Gotham

ConfirmText.Text =
    "Are you sure you want to close the menu?\n" ..
    "Pressing Yes will unload the Yuki Shader Engine."

ConfirmText.TextSize =
    12

ConfirmText.TextColor3 =
    CONFIG.Muted

ConfirmText.TextWrapped =
    true

ConfirmText.TextXAlignment =
    Enum.TextXAlignment.Left

ConfirmText.TextYAlignment =
    Enum.TextYAlignment.Top

ConfirmText.ZIndex =
    103

ConfirmText.Parent =
    Confirm

local NoButton =
    Instance.new("TextButton")

NoButton.Position =
    UDim2.fromOffset(
        25,
        151
    )

NoButton.Size =
    UDim2.fromOffset(
        170,
        43
    )

NoButton.BackgroundColor3 =
    Color3.fromRGB(
        50,
        24,
        67
    )

NoButton.BackgroundTransparency =
    0.07

NoButton.BorderSizePixel =
    0

NoButton.AutoButtonColor =
    false

NoButton.Text =
    "No"

NoButton.Font =
    Enum.Font.GothamSemibold

NoButton.TextSize =
    12

NoButton.TextColor3 =
    CONFIG.White

NoButton.ZIndex =
    103

NoButton.Parent =
    Confirm

AddCorner(
    NoButton,
    12
)

local YesButton =
    Instance.new("TextButton")

YesButton.Position =
    UDim2.fromOffset(
        220,
        151
    )

YesButton.Size =
    UDim2.fromOffset(
        170,
        43
    )

YesButton.BackgroundColor3 =
    CONFIG.Purple

YesButton.BackgroundTransparency =
    0.02

YesButton.BorderSizePixel =
    0

YesButton.AutoButtonColor =
    false

YesButton.Text =
    "Yes"

YesButton.Font =
    Enum.Font.GothamSemibold

YesButton.TextSize =
    12

YesButton.TextColor3 =
    CONFIG.White

YesButton.ZIndex =
    103

YesButton.Parent =
    Confirm

AddCorner(
    YesButton,
    12
)

local function OpenConfirmation()

    ConfirmOpen =
        true

    Overlay.Visible =
        true

    Overlay.BackgroundTransparency =
        1

    Confirm.Size =
        UDim2.fromOffset(
            375,
            195
        )

    Tween(
        Overlay,
        {
            BackgroundTransparency =
                0.28
        },
        0.23,
        Enum.EasingStyle.Sine
    )

    Tween(
        Confirm,
        {
            Size =
                UDim2.fromOffset(
                    420,
                    220
                )
        },
        0.38,
        Enum.EasingStyle.Back
    )
end

local function CloseConfirmation()

    Tween(
        Overlay,
        {
            BackgroundTransparency =
                1
        },
        0.18,
        Enum.EasingStyle.Sine
    )

    Tween(
        Confirm,
        {
            Size =
                UDim2.fromOffset(
                    375,
                    195
                )
        },
        0.18,
        Enum.EasingStyle.Quint
    )

    task.delay(
        0.19,
        function()

            Overlay.Visible =
                false

            ConfirmOpen =
                false
        end
    )
end

Connect(
    ExitButton.MouseButton1Click,
    OpenConfirmation
)

Connect(
    NoButton.MouseButton1Click,
    CloseConfirmation
)

--============================================================
-- UNLOAD
--============================================================

local function Unload()

    if not Alive then
        return
    end

    Alive =
        false

    DisconnectAll()

    DestroyShaderEffects()
    DestroyVignette()
    StopMotionBlur()

    Tween(
        Main,
        {
            Size =
                UDim2.fromOffset(
                    5,
                    5
                ),

            BackgroundTransparency =
                1
        },
        0.30,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.In
    )

    task.delay(
        0.32,
        function()
            SafeDestroy(
                ScreenGui
            )
        end
    )
end

Connect(
    YesButton.MouseButton1Click,
    Unload
)

--============================================================
-- DRAG
--============================================================

Connect(
    Header.InputBegan,
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            Dragging =
                true

            DragStart =
                input.Position

            DragOrigin =
                Main.Position
        end
    end
)

Connect(
    UserInputService.InputEnded,
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            Dragging =
                false
        end
    end
)

Connect(
    UserInputService.InputChanged,
    function(input)

        if not Dragging then
            return
        end

        if input.UserInputType ~=
            Enum.UserInputType.MouseMovement then

            return
        end

        local delta =
            input.Position
            -
            DragStart

        Main.Position =
            UDim2.new(
                DragOrigin.X.Scale,
                DragOrigin.X.Offset
                    + delta.X,

                DragOrigin.Y.Scale,
                DragOrigin.Y.Offset
                    + delta.Y
            )

        SavedPosition =
            Main.Position
    end
)

--============================================================
-- BUBBLES
--============================================================

local RNG =
    Random.new()

local function CreateBubble(
    index
)

    local size =
        RNG:NextNumber(10, 26)

    local bubble =
        Instance.new("Frame")

    bubble.Name =
        "Bubble_" .. index

    bubble.AnchorPoint =
        Vector2.new(0.5, 0.5)

    bubble.Size =
        UDim2.fromOffset(size, size)

    bubble.BackgroundColor3 =
        CONFIG.PurpleLight

    bubble.BackgroundTransparency =
        RNG:NextNumber(0.44, 0.70)

    bubble.BorderSizePixel = 0
    bubble.ZIndex = 6
    bubble.Parent = BubbleLayer

    AddCorner(bubble, 99)

    local stroke =
        AddStroke(
            bubble,
            Color3.fromRGB(231, 206, 255),
            RNG:NextNumber(0.48, 0.78),
            0.8
        )

    local shine =
        Instance.new("Frame")

    shine.AnchorPoint =
        Vector2.new(0.5, 0.5)

    shine.Position =
        UDim2.fromScale(0.29, 0.27)

    shine.Size =
        UDim2.fromScale(0.23, 0.23)

    shine.BackgroundColor3 =
        CONFIG.White

    shine.BackgroundTransparency =
        0.24

    shine.BorderSizePixel = 0
    shine.ZIndex = 7
    shine.Parent = bubble

    AddCorner(shine, 99)

    local startX =
        RNG:NextNumber(20, CONFIG.Width - 20)

    local startY =
        RNG:NextNumber(30, CONFIG.Height - 90)

    bubble.Position =
        UDim2.fromOffset(startX, startY)

    table.insert(
        Bubbles,
        {
            Object = bubble,
            Stroke = stroke,

            X = startX,
            Y = startY,

            VX = RNG:NextNumber(-18, 18),
            VY = RNG:NextNumber(-12, 14),

            Phase = RNG:NextNumber(0, math.pi * 2),

            Radius = size,

            RingRadius = RNG:NextNumber(32, 125),
            RingSpeed = RNG:NextNumber(0.18, 0.55),
            RingWobble = RNG:NextNumber(4, 14)
        }
    )
end

for i = 1, CONFIG.BubbleCount do
    CreateBubble(i)
end

--============================================================
-- BUBBLE PHYSICS
--============================================================

Connect(
    RunService.RenderStepped,
    function(deltaTime)

        if not Alive then
            return
        end

        if not Main.Visible then
            return
        end

        local mouse =
            UserInputService:GetMouseLocation()

        local mainPosition =
            Main.AbsolutePosition

        local mainSize =
            Main.AbsoluteSize

        local mouseX =
            mouse.X - mainPosition.X

        local mouseY =
            mouse.Y - mainPosition.Y

        local inside =
            mouseX >= 0
            and mouseX <= mainSize.X
            and mouseY >= 0
            and mouseY <= mainSize.Y

        local width =
            math.max(mainSize.X, 1)

        local height =
            math.max(mainSize.Y, 1)

        if inside then

            local time = os.clock()

            -- Every bubble gets its own angle and radius.
            -- This creates a proper halo around the cursor instead of one blob.
            for _, bubble in ipairs(Bubbles) do

                local angle =
                    bubble.Phase
                    + time * bubble.RingSpeed

                local wobble =
                    math.sin(
                        time * 1.15
                        + bubble.Phase * 2
                    )
                    * bubble.RingWobble

                local ring =
                    bubble.RingRadius + wobble

                local targetX =
                    mouseX
                    + math.cos(angle) * ring

                local targetY =
                    mouseY
                    + math.sin(angle) * ring

                targetX =
                    Clamp(
                        targetX,
                        bubble.Radius + 5,
                        width - bubble.Radius - 5
                    )

                targetY =
                    Clamp(
                        targetY,
                        bubble.Radius + 5,
                        height - bubble.Radius - 5
                    )

                local dx =
                    targetX - bubble.X

                local dy =
                    targetY - bubble.Y

                -- Spring toward the bubble's own point on the ring.
                bubble.VX =
                    bubble.VX
                    + dx * CONFIG.BubbleMagnet * 0.92 * deltaTime

                bubble.VY =
                    bubble.VY
                    + dy * CONFIG.BubbleMagnet * 0.92 * deltaTime

                -- Tangential movement makes the halo feel alive.
                bubble.VX =
                    bubble.VX
                    - math.sin(angle) * 7 * deltaTime

                bubble.VY =
                    bubble.VY
                    + math.cos(angle) * 7 * deltaTime

                local drag =
                    math.pow(0.86, deltaTime * 60)

                bubble.VX =
                    bubble.VX * drag

                bubble.VY =
                    bubble.VY * drag

                bubble.X =
                    bubble.X + bubble.VX * deltaTime

                bubble.Y =
                    bubble.Y + bubble.VY * deltaTime

                bubble.Object.Position =
                    UDim2.fromOffset(
                        bubble.X,
                        bubble.Y
                    )
            end

        else

            for _, bubble in ipairs(Bubbles) do

                bubble.VY =
                    bubble.VY
                    + CONFIG.BubbleGravity * deltaTime

                bubble.VX =
                    bubble.VX
                    * math.pow(0.992, deltaTime * 60)

                bubble.VX =
                    bubble.VX
                    + math.sin(
                        os.clock() * 0.7
                        + bubble.Phase
                    ) * 0.4

                bubble.X =
                    bubble.X + bubble.VX * deltaTime

                bubble.Y =
                    bubble.Y + bubble.VY * deltaTime

                local floor =
                    height - bubble.Radius - 7

                if bubble.Y >= floor then

                    bubble.Y = floor
                    bubble.VY = -math.abs(bubble.VY) * 0.22

                    if math.abs(bubble.VY) < 7 then
                        bubble.VY = 0
                    end
                end

                if bubble.X < -bubble.Radius then

                    bubble.X = width + bubble.Radius
                    bubble.Y = RNG:NextNumber(
                        height * 0.22,
                        height * 0.55
                    )
                    bubble.VY = RNG:NextNumber(0, 15)
                end

                if bubble.X > width + bubble.Radius then

                    bubble.X = -bubble.Radius
                    bubble.Y = RNG:NextNumber(
                        height * 0.22,
                        height * 0.55
                    )
                    bubble.VY = RNG:NextNumber(0, 15)
                end

                bubble.Object.Position =
                    UDim2.fromOffset(
                        bubble.X,
                        bubble.Y
                    )
            end
        end
    end
)

--============================================================
-- BUBBLE VISUAL ANIMATION
--============================================================

task.spawn(function()

    while Alive do

        for _, bubble in ipairs(
            Bubbles
        ) do

            if bubble.Object
                and bubble.Object.Parent then

                Tween(
                    bubble.Object,
                    {
                        BackgroundTransparency =
                            RNG:NextNumber(
                                0.44,
                                0.72
                            )
                    },
                    RNG:NextNumber(
                        0.9,
                        1.6
                    ),
                    Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut
                )

                Tween(
                    bubble.Stroke,
                    {
                        Transparency =
                            RNG:NextNumber(
                                0.48,
                                0.80
                            )
                    },
                    RNG:NextNumber(
                        0.9,
                        1.6
                    ),
                    Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut
                )
            end
        end

        task.wait(
            0.55
        )
    end
end)

--============================================================
-- GLOW ANIMATION
--============================================================

task.spawn(function()

    while Alive do

        Tween(
            OuterGlow,
            {
                Size =
                    UDim2.new(
                        1,
                        195,
                        1,
                        195
                    ),

                BackgroundTransparency =
                    0.965
            },
            2.6,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut
        )

        task.wait(
            2.6
        )

        if not Alive then
            break
        end

        Tween(
            OuterGlow,
            {
                Size =
                    UDim2.new(
                        1,
                        155,
                        1,
                        155
                    ),

                BackgroundTransparency =
                    0.95
            },
            2.6,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut
        )

        task.wait(
            2.6
        )
    end
end)

--============================================================
-- STATUS ANIMATION
--============================================================

task.spawn(function()

    while Alive do

        Tween(
            StatusDot,
            {
                Size =
                    UDim2.fromOffset(
                        11,
                        11
                    ),

                BackgroundTransparency =
                    0.02
            },
            1,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut
        )

        task.wait(
            1
        )

        if not Alive then
            break
        end

        Tween(
            StatusDot,
            {
                Size =
                    UDim2.fromOffset(
                        8,
                        8
                    ),

                BackgroundTransparency =
                    0.18
            },
            1,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut
        )

        task.wait(
            1
        )
    end
end)

--============================================================
-- DRAG HEADER EVENTS
--============================================================

Connect(
    Header.InputBegan,
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            Dragging =
                true

            DragStart =
                input.Position

            DragOrigin =
                Main.Position
        end
    end
)

--============================================================
-- INITIAL STATE
--============================================================

SavedPosition =
    Main.Position

ApplyPreset(
    "Default"
)

SwitchPage(
    "Home"
)

--============================================================
-- OPEN ANIMATION
--============================================================

Main.Size =
    UDim2.fromOffset(
        20,
        20
    )

Main.BackgroundTransparency =
    1

Tween(
    Main,
    {
        Size =
            UDim2.fromOffset(
                CONFIG.Width,
                CONFIG.Height
            ),

        BackgroundTransparency =
            0.02
    },
    0.62,
    Enum.EasingStyle.Quint,
    Enum.EasingDirection.Out
)

--============================================================
-- READY
--============================================================
