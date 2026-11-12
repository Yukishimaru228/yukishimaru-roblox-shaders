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

HomePage.BackgroundColor3 =
    CONFIG.Panel

HomePage.BackgroundTransparency =
    0

HomePage.BorderSizePixel =
    0

HomePage.Visible =
    true

HomePage.Parent =
    PageContainer

AddCorner(
    HomePage,
    CONFIG.PanelRadius
)

AddStroke(
    HomePage,
    CONFIG.PurpleLight,
    0.83,
    1
)


local HomeCard =
    Instance.new("Frame")

HomeCard.Size =
    UDim2.fromScale(
        1,
        1
    )

HomeCard.BackgroundTransparency =
    1

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
        71,
        52,
        40
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
    CONFIG.Text

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
    CONFIG.Text

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
    CONFIG.Text

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
    0

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
    CONFIG.Text

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
    0

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


--============================================================
-- EFFECTS PAGE
--============================================================

local EffectsPage = Instance.new("Frame")
EffectsPage.Name = "Effects"
EffectsPage.Size = UDim2.fromScale(1, 1)
EffectsPage.BackgroundColor3 = CONFIG.Panel
EffectsPage.BackgroundTransparency = 0
EffectsPage.BorderSizePixel = 0
EffectsPage.Visible = false
EffectsPage.ZIndex = 20
EffectsPage.Parent = PageContainer

AddCorner(EffectsPage, CONFIG.PanelRadius)
AddStroke(EffectsPage, CONFIG.PurpleLight, 0.45, 1)

local EffectsTitle = Instance.new("TextLabel")
EffectsTitle.Position = UDim2.fromOffset(20, 16)
EffectsTitle.Size = UDim2.new(1, -40, 0, 26)
EffectsTitle.BackgroundTransparency = 1
EffectsTitle.Font = Enum.Font.GothamBold
EffectsTitle.Text = "Effects"
EffectsTitle.TextSize = 20
EffectsTitle.TextColor3 = CONFIG.Text
EffectsTitle.TextXAlignment = Enum.TextXAlignment.Left
EffectsTitle.ZIndex = 22
EffectsTitle.Parent = EffectsPage

local EffectsSubtitle = Instance.new("TextLabel")
EffectsSubtitle.Position = UDim2.fromOffset(21, 42)
EffectsSubtitle.Size = UDim2.new(1, -42, 0, 21)
EffectsSubtitle.BackgroundTransparency = 1
EffectsSubtitle.Font = Enum.Font.Gotham
EffectsSubtitle.Text = "Visual effects from the Portal Visuals Visuals tab."
EffectsSubtitle.TextSize = 10
EffectsSubtitle.TextColor3 = CONFIG.Muted
EffectsSubtitle.TextXAlignment = Enum.TextXAlignment.Left
EffectsSubtitle.ZIndex = 22
EffectsSubtitle.Parent = EffectsPage

--============================================================
-- AVATAR MODIFIERS PAGE
--============================================================

do
    -- Dedicated avatar-modifier tab. Toggle rows intentionally reuse the same
    -- visual language as Effects: dark card + white OFF switch on the right.
    _G.YukiAvatarModifiersUI = {}

    local AvatarModsPage = Instance.new("Frame")
    AvatarModsPage.Name = "AvatarMods"
    AvatarModsPage.Size = UDim2.fromScale(1, 1)
    AvatarModsPage.BackgroundColor3 = CONFIG.Panel
    AvatarModsPage.BackgroundTransparency = 0
    AvatarModsPage.BorderSizePixel = 0
    AvatarModsPage.Visible = false
    AvatarModsPage.ZIndex = 20
    AvatarModsPage.Parent = PageContainer
    AddCorner(AvatarModsPage, CONFIG.PanelRadius)
    AddStroke(AvatarModsPage, CONFIG.PurpleLight, 0.45, 1)

    local ui = _G.YukiAvatarModifiersUI
    ui.Page = AvatarModsPage
    ui.Buttons = {}
    ui.Switches = {}

    local AvatarModsTitle = Instance.new("TextLabel")
    AvatarModsTitle.Position = UDim2.fromOffset(20, 16)
    AvatarModsTitle.Size = UDim2.new(1, -40, 0, 26)
    AvatarModsTitle.BackgroundTransparency = 1
    AvatarModsTitle.Font = Enum.Font.GothamBold
    AvatarModsTitle.Text = "Avatar"
    AvatarModsTitle.TextSize = 20
    AvatarModsTitle.TextColor3 = CONFIG.Text
    AvatarModsTitle.TextXAlignment = Enum.TextXAlignment.Left
    AvatarModsTitle.ZIndex = 22
    AvatarModsTitle.Parent = AvatarModsPage

    local AvatarModsSubtitle = Instance.new("TextLabel")
    AvatarModsSubtitle.Position = UDim2.fromOffset(21, 42)
    AvatarModsSubtitle.Size = UDim2.new(1, -42, 0, 21)
    AvatarModsSubtitle.BackgroundTransparency = 1
    AvatarModsSubtitle.Font = Enum.Font.Gotham
    AvatarModsSubtitle.Text = "Korblox, Headless и 20 слотов для Roblox Asset ID."
    AvatarModsSubtitle.TextSize = 10
    AvatarModsSubtitle.TextColor3 = CONFIG.Muted
    AvatarModsSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    AvatarModsSubtitle.ZIndex = 22
    AvatarModsSubtitle.Parent = AvatarModsPage

    local AvatarModsScroll = Instance.new("ScrollingFrame")
    AvatarModsScroll.Name = "AvatarModsScroll"
    AvatarModsScroll.Position = UDim2.fromOffset(8, 70)
    AvatarModsScroll.Size = UDim2.new(1, -16, 1, -92)
    AvatarModsScroll.BackgroundTransparency = 1
    AvatarModsScroll.BorderSizePixel = 0
    AvatarModsScroll.ScrollBarThickness = 3
    AvatarModsScroll.ScrollBarImageColor3 = CONFIG.Purple
    AvatarModsScroll.CanvasSize = UDim2.fromOffset(0, 0)
    AvatarModsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    AvatarModsScroll.ZIndex = 22
    AvatarModsScroll.Parent = AvatarModsPage
    ui.Scroll = AvatarModsScroll

    local AvatarModsLayout = Instance.new("UIListLayout")
    AvatarModsLayout.FillDirection = Enum.FillDirection.Vertical
    AvatarModsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    AvatarModsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    AvatarModsLayout.Padding = UDim.new(0, 7)
    AvatarModsLayout.Parent = AvatarModsScroll

    local function MakeAvatarModifierButton(name, label, order)
        local row = Instance.new("TextButton")
        row.Name = name
        row.LayoutOrder = order
        row.Size = UDim2.new(1, -8, 0, 47)
        row.BackgroundColor3 = Color3.fromRGB(31, 31, 35)
        row.BackgroundTransparency = 0.02
        row.BorderSizePixel = 0
        row.AutoButtonColor = false
        row.Text = ""
        row.ZIndex = 23
        row.Parent = AvatarModsScroll
        AddCorner(row, 13)
        AddStroke(row, CONFIG.PurpleLight, 0.91, 1)

        local title = Instance.new("TextLabel")
        title.Position = UDim2.fromOffset(13, 0)
        title.Size = UDim2.new(1, -85, 1, 0)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamMedium
        title.Text = label
        title.TextSize = 10
        title.TextColor3 = CONFIG.Text
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 24
        title.Parent = row

        local switch = Instance.new("Frame")
        switch.Name = "YukiToggleTrack"
        switch.AnchorPoint = Vector2.new(1, 0.5)
        switch.Position = UDim2.new(1, -13, 0.5, 0)
        switch.Size = UDim2.fromOffset(42, 20)
        switch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        switch.BackgroundTransparency = 0.02
        switch.BorderSizePixel = 0
        switch.ZIndex = 24
        switch.Parent = row
        AddCorner(switch, 99)

        local knob = Instance.new("Frame")
        knob.Name = "YukiToggleKnob"
        knob.Position = UDim2.fromOffset(2, 2)
        knob.Size = UDim2.fromOffset(16, 16)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.ZIndex = 25
        knob.Parent = switch
        AddCorner(knob, 99)

        ui.Buttons[name] = row
        ui.Switches[name] = {Track = switch, Knob = knob}
        return row
    end

    ui.HeadlessButton = MakeAvatarModifierButton("HeadlessButton", "Headless", 1)
    ui.KorbloxButton = MakeAvatarModifierButton("KorbloxButton", "Korblox", 2)
    ui.DeleteHairButton = MakeAvatarModifierButton("DeleteHairButton", "Delete hair", 3)
    ui.DeleteAccessoriesButton = MakeAvatarModifierButton("DeleteAccessoriesButton", "Delete accessories", 4)
    ui.DeleteAllAccessoriesButton = MakeAvatarModifierButton("DeleteAllAccessoriesButton", "Delete all accessories", 5)
    ui.DeleteArmsFPButton = MakeAvatarModifierButton("DeleteArmsFPButton", "Delete arms in First Person", 6)

    local AvatarItemsTitle = Instance.new("TextLabel")
    AvatarItemsTitle.LayoutOrder = 7
    AvatarItemsTitle.Size = UDim2.new(1, -8, 0, 24)
    AvatarItemsTitle.BackgroundTransparency = 1
    AvatarItemsTitle.Font = Enum.Font.GothamBold
    AvatarItemsTitle.Text = "Custom Avatar IDs"
    AvatarItemsTitle.TextSize = 12
    AvatarItemsTitle.TextColor3 = CONFIG.Text
    AvatarItemsTitle.TextXAlignment = Enum.TextXAlignment.Left
    AvatarItemsTitle.ZIndex = 23
    AvatarItemsTitle.Parent = AvatarModsScroll

    local AvatarItemsHint = Instance.new("TextLabel")
    AvatarItemsHint.LayoutOrder = 8
    AvatarItemsHint.Size = UDim2.new(1, -8, 0, 32)
    AvatarItemsHint.BackgroundTransparency = 1
    AvatarItemsHint.Font = Enum.Font.Gotham
    AvatarItemsHint.Text = "Вставляй Asset ID. Слоты пытаются применить аксессуары, одежду, лицо и части тела. Пустой слот игнорируется."
    AvatarItemsHint.TextSize = 8
    AvatarItemsHint.TextColor3 = CONFIG.Muted
    AvatarItemsHint.TextWrapped = true
    AvatarItemsHint.TextXAlignment = Enum.TextXAlignment.Left
    AvatarItemsHint.TextYAlignment = Enum.TextYAlignment.Top
    AvatarItemsHint.ZIndex = 23
    AvatarItemsHint.Parent = AvatarModsScroll

    ui.ItemInputs = {}
    ui.ItemRows = {}

    local function MakeAvatarItemInput(index)
        local row = Instance.new("Frame")
        row.Name = "AvatarItemRow" .. tostring(index)
        row.LayoutOrder = 8 + index
        row.Size = UDim2.new(1, -8, 0, 42)
        row.BackgroundColor3 = Color3.fromRGB(31, 31, 35)
        row.BackgroundTransparency = 0.02
        row.BorderSizePixel = 0
        row.ZIndex = 23
        row.Parent = AvatarModsScroll
        AddCorner(row, 12)
        AddStroke(row, CONFIG.PurpleLight, 0.91, 1)

        local label = Instance.new("TextLabel")
        label.Position = UDim2.fromOffset(12, 0)
        label.Size = UDim2.fromOffset(54, 42)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamMedium
        label.Text = string.format("Item %02d", index)
        label.TextSize = 9
        label.TextColor3 = CONFIG.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 24
        label.Parent = row

        local box = Instance.new("TextBox")
        box.Name = "AssetIdInput"
        box.Position = UDim2.fromOffset(70, 6)
        box.Size = UDim2.new(1, -82, 0, 30)
        box.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
        box.BorderSizePixel = 0
        box.ClearTextOnFocus = false
        box.PlaceholderText = "Пример: 12345"
        box.Text = ""
        box.Font = Enum.Font.Gotham
        box.TextSize = 10
        box.TextColor3 = CONFIG.Text
        box.PlaceholderColor3 = CONFIG.Muted
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.ZIndex = 24
        box.Parent = row
        AddCorner(box, 9)
        AddStroke(box, CONFIG.PurpleLight, 0.84, 1)

        ui.ItemInputs[index] = box
        ui.ItemRows[index] = row
    end

    for i = 1, 30 do
        MakeAvatarItemInput(i)
    end

    local ApplyAvatarItemsButton = Instance.new("TextButton")
    ApplyAvatarItemsButton.Name = "ApplyAvatarItemsButton"
    ApplyAvatarItemsButton.LayoutOrder = 50
    ApplyAvatarItemsButton.Size = UDim2.new(1, -8, 0, 42)
    ApplyAvatarItemsButton.BackgroundColor3 = Color3.fromRGB(47, 47, 52)
    ApplyAvatarItemsButton.BorderSizePixel = 0
    ApplyAvatarItemsButton.AutoButtonColor = false
    ApplyAvatarItemsButton.Text = "Apply Item IDs"
    ApplyAvatarItemsButton.Font = Enum.Font.GothamBold
    ApplyAvatarItemsButton.TextSize = 10
    ApplyAvatarItemsButton.TextColor3 = CONFIG.Text
    ApplyAvatarItemsButton.ZIndex = 23
    ApplyAvatarItemsButton.Parent = AvatarModsScroll
    AddCorner(ApplyAvatarItemsButton, 11)
    AddStroke(ApplyAvatarItemsButton, CONFIG.PurpleLight, 0.72, 1)
    ui.ApplyItemIdsButton = ApplyAvatarItemsButton

    local AvatarItemsStatus = Instance.new("TextLabel")
    AvatarItemsStatus.LayoutOrder = 51
    AvatarItemsStatus.Size = UDim2.new(1, -8, 0, 34)
    AvatarItemsStatus.BackgroundTransparency = 1
    AvatarItemsStatus.Font = Enum.Font.Gotham
    AvatarItemsStatus.Text = "30 слотов готовы."
    AvatarItemsStatus.TextSize = 8
    AvatarItemsStatus.TextColor3 = CONFIG.Muted
    AvatarItemsStatus.TextWrapped = true
    AvatarItemsStatus.TextXAlignment = Enum.TextXAlignment.Left
    AvatarItemsStatus.TextYAlignment = Enum.TextYAlignment.Top
    AvatarItemsStatus.ZIndex = 23
    AvatarItemsStatus.Parent = AvatarModsScroll
    ui.ItemStatus = AvatarItemsStatus

    local AvatarModsHint = Instance.new("TextLabel")
    AvatarModsHint.LayoutOrder = 52
    AvatarModsHint.Size = UDim2.new(1, -8, 0, 34)
    AvatarModsHint.BackgroundTransparency = 1
    AvatarModsHint.Font = Enum.Font.Gotham
    AvatarModsHint.Text = "Delete hair убирает волосы. Delete accessories убирает аксессуары с головы и лица. Delete all accessories убирает все аксессуары с аватара."
    AvatarModsHint.TextSize = 8
    AvatarModsHint.TextColor3 = CONFIG.Muted
    AvatarModsHint.TextWrapped = true
    AvatarModsHint.TextXAlignment = Enum.TextXAlignment.Left
    AvatarModsHint.TextYAlignment = Enum.TextYAlignment.Top
    AvatarModsHint.ZIndex = 23
    AvatarModsHint.Parent = AvatarModsScroll

    local function BuildYukiAvatarExtras(uiRef, pageRef, scrollRef)
        uiRef.SkinColors = {
            {Name="Default", Color=nil},
            {Name="Очень светлый", Color=Color3.fromRGB(255,224,189)},
            {Name="Светлый", Color=Color3.fromRGB(245,205,175)},
            {Name="Бежевый", Color=Color3.fromRGB(235,184,145)},
            {Name="Тёплый бежевый", Color=Color3.fromRGB(214,160,118)},
            {Name="Смуглый", Color=Color3.fromRGB(188,132,92)},
            {Name="Коричневый", Color=Color3.fromRGB(145,91,60)},
            {Name="Тёмный", Color=Color3.fromRGB(92,56,38)},
        }
        uiRef.SkinColorIndex = 1

        local colorRow = Instance.new("Frame")
        colorRow.LayoutOrder = 53
        colorRow.Size = UDim2.new(1,-8,0,48)
        colorRow.BackgroundColor3 = Color3.fromRGB(31,31,35)
        colorRow.BackgroundTransparency = 0.02
        colorRow.BorderSizePixel = 0
        colorRow.ZIndex = 23
        colorRow.Parent = scrollRef
        AddCorner(colorRow,13)
        AddStroke(colorRow,CONFIG.PurpleLight,0.91,1)

        local colorLabel = Instance.new("TextLabel")
        colorLabel.Position = UDim2.fromOffset(13,0)
        colorLabel.Size = UDim2.new(0.46,0,1,0)
        colorLabel.BackgroundTransparency = 1
        colorLabel.Font = Enum.Font.GothamMedium
        colorLabel.Text = "Skin color"
        colorLabel.TextSize = 10
        colorLabel.TextColor3 = CONFIG.Text
        colorLabel.TextXAlignment = Enum.TextXAlignment.Left
        colorLabel.ZIndex = 24
        colorLabel.Parent = colorRow

        local colorButton = Instance.new("TextButton")
        colorButton.AnchorPoint = Vector2.new(1,0.5)
        colorButton.Position = UDim2.new(1,-10,0.5,0)
        colorButton.Size = UDim2.fromOffset(178,30)
        colorButton.BackgroundColor3 = Color3.fromRGB(24,24,28)
        colorButton.BorderSizePixel = 0
        colorButton.AutoButtonColor = false
        colorButton.Text = "Default"
        colorButton.Font = Enum.Font.Gotham
        colorButton.TextSize = 9
        colorButton.TextColor3 = CONFIG.Text
        colorButton.ZIndex = 24
        colorButton.Parent = colorRow
        AddCorner(colorButton,9)
        AddStroke(colorButton,CONFIG.PurpleLight,0.84,1)
        uiRef.SkinColorButton = colorButton

        local savedHeader = Instance.new("Frame")
        savedHeader.LayoutOrder = 54
        savedHeader.Size = UDim2.new(1,-8,0,38)
        savedHeader.BackgroundTransparency = 1
        savedHeader.BorderSizePixel = 0
        savedHeader.ZIndex = 23
        savedHeader.Parent = scrollRef

        local savedTitle = Instance.new("TextLabel")
        savedTitle.Position = UDim2.fromOffset(0,3)
        savedTitle.Size = UDim2.new(1,-54,1,-6)
        savedTitle.BackgroundTransparency = 1
        savedTitle.Font = Enum.Font.GothamBold
        savedTitle.Text = "Saved avatars"
        savedTitle.TextSize = 12
        savedTitle.TextColor3 = CONFIG.Text
        savedTitle.TextXAlignment = Enum.TextXAlignment.Left
        savedTitle.ZIndex = 24
        savedTitle.Parent = savedHeader

        local plusButton = Instance.new("TextButton")
        plusButton.AnchorPoint = Vector2.new(1,0.5)
        plusButton.Position = UDim2.new(1,0,0.5,0)
        plusButton.Size = UDim2.fromOffset(38,30)
        plusButton.BackgroundColor3 = Color3.fromRGB(47,47,52)
        plusButton.BorderSizePixel = 0
        plusButton.AutoButtonColor = false
        plusButton.Text = "+"
        plusButton.Font = Enum.Font.GothamBold
        plusButton.TextSize = 16
        plusButton.TextColor3 = CONFIG.Text
        plusButton.ZIndex = 24
        plusButton.Parent = savedHeader
        AddCorner(plusButton,9)
        AddStroke(plusButton,CONFIG.PurpleLight,0.70,1)
        uiRef.SavedPlusButton = plusButton

        local savedHint = Instance.new("TextLabel")
        savedHint.LayoutOrder = 55
        savedHint.Size = UDim2.new(1,-8,0,26)
        savedHint.BackgroundTransparency = 1
        savedHint.Font = Enum.Font.Gotham
        savedHint.Text = "Нажми +, чтобы сохранить текущий внешний вид. Скины переживают перезапуск скрипта."
        savedHint.TextSize = 8
        savedHint.TextColor3 = CONFIG.Muted
        savedHint.TextWrapped = true
        savedHint.TextXAlignment = Enum.TextXAlignment.Left
        savedHint.ZIndex = 23
        savedHint.Parent = scrollRef

        local savedList = Instance.new("Frame")
        savedList.Name = "SavedAvatarList"
        savedList.LayoutOrder = 56
        savedList.Size = UDim2.new(1,-8,0,0)
        savedList.BackgroundTransparency = 1
        savedList.BorderSizePixel = 0
        savedList.AutomaticSize = Enum.AutomaticSize.Y
        savedList.ZIndex = 23
        savedList.Parent = scrollRef
        uiRef.SavedList = savedList

        local savedLayout = Instance.new("UIListLayout")
        savedLayout.FillDirection = Enum.FillDirection.Vertical
        savedLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        savedLayout.SortOrder = Enum.SortOrder.LayoutOrder
        savedLayout.Padding = UDim.new(0,6)
        savedLayout.Parent = savedList

        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Size = UDim2.new(1,0,0,26)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Font = Enum.Font.Gotham
        emptyLabel.Text = "Сохранённых скинов пока нет."
        emptyLabel.TextSize = 8
        emptyLabel.TextColor3 = CONFIG.Muted
        emptyLabel.TextXAlignment = Enum.TextXAlignment.Left
        emptyLabel.ZIndex = 24
        emptyLabel.Parent = savedList
        uiRef.SavedEmptyLabel = emptyLabel

        local overlay = Instance.new("Frame")
        overlay.Name = "AvatarSaveOverlay"
        overlay.Size = UDim2.fromScale(1,1)
        overlay.BackgroundColor3 = Color3.new(0,0,0)
        overlay.BackgroundTransparency = 0.42
        overlay.Visible = false
        overlay.ZIndex = 140
        overlay.Parent = pageRef
        uiRef.SaveOverlay = overlay

        local dialog = Instance.new("Frame")
        dialog.AnchorPoint = Vector2.new(0.5,0.5)
        dialog.Position = UDim2.fromScale(0.5,0.5)
        dialog.Size = UDim2.fromOffset(420,205)
        dialog.BackgroundColor3 = Color3.fromRGB(19,19,22)
        dialog.BorderSizePixel = 0
        dialog.ZIndex = 141
        dialog.Parent = overlay
        AddCorner(dialog,18)
        AddStroke(dialog,CONFIG.PurpleLight,0.40,1.2)

        local dialogTitle = Instance.new("TextLabel")
        dialogTitle.Position = UDim2.fromOffset(18,17)
        dialogTitle.Size = UDim2.new(1,-36,0,26)
        dialogTitle.BackgroundTransparency = 1
        dialogTitle.Font = Enum.Font.GothamBold
        dialogTitle.Text = "Сохранить аватар"
        dialogTitle.TextSize = 16
        dialogTitle.TextColor3 = CONFIG.Text
        dialogTitle.ZIndex = 142
        dialogTitle.Parent = dialog

        local nameInput = Instance.new("TextBox")
        nameInput.Position = UDim2.fromOffset(18,57)
        nameInput.Size = UDim2.new(1,-36,0,38)
        nameInput.BackgroundColor3 = Color3.fromRGB(29,29,33)
        nameInput.BorderSizePixel = 0
        nameInput.ClearTextOnFocus = false
        nameInput.TextEditable = true
        nameInput.Active = true
        nameInput.Selectable = true
        nameInput.PlaceholderText = "Пример: Мой чёрный скин"
        nameInput.Text = ""
        nameInput.Font = Enum.Font.Gotham
        nameInput.TextSize = 10
        nameInput.TextColor3 = CONFIG.Text
        nameInput.PlaceholderColor3 = CONFIG.Muted
        nameInput.ZIndex = 142
        nameInput.Parent = dialog
        AddCorner(nameInput,10)
        AddStroke(nameInput,CONFIG.PurpleLight,0.70,1)
        uiRef.SaveNameInput = nameInput

        local message = Instance.new("TextLabel")
        message.Position = UDim2.fromOffset(18,99)
        message.Size = UDim2.new(1,-36,0,20)
        message.BackgroundTransparency = 1
        message.Font = Enum.Font.Gotham
        message.Text = ""
        message.TextSize = 8
        message.TextColor3 = CONFIG.Muted
        message.TextXAlignment = Enum.TextXAlignment.Left
        message.ZIndex = 142
        message.Parent = dialog
        uiRef.SaveMessage = message

        local cancel = Instance.new("TextButton")
        cancel.Size = UDim2.fromOffset(160,35)
        cancel.Position = UDim2.new(0,18,1,-50)
        cancel.BackgroundColor3 = Color3.fromRGB(50,50,55)
        cancel.BorderSizePixel = 0
        cancel.AutoButtonColor = false
        cancel.Text = "Отмена"
        cancel.Font = Enum.Font.GothamSemibold
        cancel.TextSize = 9
        cancel.TextColor3 = CONFIG.Text
        cancel.ZIndex = 142
        cancel.Parent = dialog
        AddCorner(cancel,10)
        uiRef.SaveCancel = cancel

        local confirm = Instance.new("TextButton")
        confirm.Size = UDim2.fromOffset(160,35)
        confirm.Position = UDim2.new(1,-178,1,-50)
        confirm.BackgroundColor3 = Color3.fromRGB(70,70,76)
        confirm.BorderSizePixel = 0
        confirm.AutoButtonColor = false
        confirm.Text = "Сохранить"
        confirm.Font = Enum.Font.GothamSemibold
        confirm.TextSize = 9
        confirm.TextColor3 = CONFIG.White
        confirm.ZIndex = 142
        confirm.Parent = dialog
        AddCorner(confirm,10)
        uiRef.SaveConfirm = confirm
    end

    BuildYukiAvatarExtras(ui, AvatarModsPage, AvatarModsScroll)
end

--============================================================
-- EFFECTS PAGE SCROLL
--============================================================

local EffectsScroll = Instance.new("ScrollingFrame")
EffectsScroll.Name = "EffectsScroll"
EffectsScroll.Position = UDim2.fromOffset(15, 70)
EffectsScroll.Size = UDim2.new(1, -30, 1, -84)
EffectsScroll.BackgroundTransparency = 1
EffectsScroll.BorderSizePixel = 0
EffectsScroll.ScrollBarThickness = 3
EffectsScroll.ScrollBarImageColor3 = CONFIG.Purple
EffectsScroll.CanvasSize = UDim2.fromOffset(0, 0)
EffectsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
EffectsScroll.ZIndex = 22
EffectsScroll.Parent = EffectsPage

local EffectsListLayout = Instance.new("UIListLayout")
EffectsListLayout.FillDirection = Enum.FillDirection.Vertical
EffectsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
EffectsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
EffectsListLayout.Padding = UDim.new(0, 7)
EffectsListLayout.Parent = EffectsScroll


