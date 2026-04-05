-- Orca Script Loader Standalone (Original Style)
-- Matches the aesthetic of richie0866/orca

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local sg = Instance.new("ScreenGui")
sg.Name = "OrcaStandalone"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("CanvasGroup")
main.Name = "Main"
main.Size = UDim2.new(0, 800, 0, 500)
main.Position = UDim2.new(0.5, -400, 0.5, -250)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.BorderSizePixel = 0
main.Parent = sg

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(45, 45, 45)
stroke.Thickness = 1.5
stroke.Parent = main

-- Background Glows (Mimicking Orca aesthetic)
local glow1 = Instance.new("Frame")
glow1.Size = UDim2.new(0, 400, 0, 400)
glow1.Position = UDim2.new(0, -100, 0, -100)
glow1.BackgroundColor3 = Color3.fromRGB(230, 30, 30)
glow1.BackgroundTransparency = 0.95
glow1.BorderSizePixel = 0
glow1.ZIndex = 0
glow1.Parent = main
local c1 = Instance.new("UICorner"); c1.CornerRadius = UDim.new(1,0); c1.Parent = glow1

-- Navigation Bar (Bottom)
local navbar = Instance.new("Frame")
navbar.Name = "Navbar"
navbar.Size = UDim2.new(0, 400, 0, 56)
navbar.Position = UDim2.new(0.5, 0, 1, -10)
navbar.AnchorPoint = Vector2.new(0.5, 1)
navbar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
navbar.BorderSizePixel = 0
navbar.Parent = main
local nc = Instance.new("UICorner"); nc.CornerRadius = UDim.new(0, 12); nc.Parent = navbar
local ns = Instance.new("UIStroke"); ns.Color = Color3.fromRGB(60, 60, 60); ns.Thickness = 1.2; ns.Parent = navbar

local navLabel = Instance.new("TextLabel")
navLabel.Size = UDim2.new(1, 0, 1, 0)
navLabel.BackgroundTransparency = 1
navLabel.Text = "SCRIPTS"
navLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
navLabel.TextSize = 14
navLabel.Font = Enum.Font.GothamBold
navLabel.Parent = navbar

-- Content Area
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -60, 1, -100)
content.Position = UDim2.new(0, 30, 0, 30)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.ScrollBarThickness = 0
content.Parent = main

local layout = Instance.new("UIGridLayout")
layout.CellPadding = UDim2.new(0, 20, 0, 20)
layout.CellSize = UDim2.new(0.31, 0, 0, 160)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local function createScriptCard(name, url, desc, footer)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    card.BorderSizePixel = 0
    card.Parent = content

    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 12); cc.Parent = card
    local cs = Instance.new("UIStroke"); cs.Color = Color3.fromRGB(50, 50, 50); cs.Thickness = 1.2; cs.Parent = card

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(1, -20, 0, 60)
    description.Position = UDim2.new(0, 10, 0, 40)
    description.BackgroundTransparency = 1
    description.Text = desc
    description.TextColor3 = Color3.fromRGB(180, 180, 180)
    description.TextSize = 11
    description.Font = Enum.Font.Gotham
    description.TextWrapped = true
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextYAlignment = Enum.TextYAlignment.Top
    description.Parent = card

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 1, -42)
    btn.BackgroundColor3 = Color3.fromRGB(230, 30, 30)
    btn.BorderSizePixel = 0
    btn.Text = "Execute"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Parent = card
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 8); bc.Parent = btn

    btn.MouseButton1Click:Connect(function()
        local success, content = pcall(function() return game:HttpGet(url) end)
        if success then
            local func, err = loadstring(content)
            if func then task.spawn(func) else warn("Failed to load: "..tostring(err)) end
        else warn("Failed to fetch script") end
    end)

    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(230, 30, 30)}):Play()
    end)
end

local scripts = {
    {"Solaris", "https://solarishub.dev/script.lua", "A collection of your favorite scripts.", "solarishub.dev"},
    {"V.G Hub", "https://raw.githubusercontent.com/1201for/V.G-Hub/main/V.Ghub", "Featuring over 100 games.", "github.com/1201for"},
    {"CMD-X", "https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source", "Powerful administration commands.", "github.com/CMD-X"},
    {"Infinite Yield", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", "Universal admin script.", "github.com/EdgeIY"},
    {"Dex Explorer", "https://pastebin.com/raw/mMbsHWiQ", "In-game object browser.", "github.com/LorekeeperZinnia"},
    {"Unnamed ESP", "https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/master/UnnamedESP.lua", "Highly customizable ESP.", "github.com/ic3w0lf22"},
    {"EvoV2", "https://projectevo.xyz/script/loader.lua", "Reliable cheats for top shooter games.", "projectevo.xyz"}
}

for _, s in ipairs(scripts) do
    createScriptCard(s[1], s[2], s[3], s[4])
end

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = main
closeBtn.MouseButton1Click:Connect(function()
    sg.Enabled = false
end)

-- Toggle Keybind (K)
UserInputService.InputBegan:Connect(function(i, gpe)
    if not gpe and i.KeyCode == Enum.KeyCode.K then
        sg.Enabled = not sg.Enabled
    end
end)

-- Draggable
local dragging, dragStart, startPos
main.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = i.Position
        startPos = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
main.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("[Orca Standalone] Loaded. Press K to toggle.")
