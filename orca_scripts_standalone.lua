-- Orca Script Loader Standalone
-- Original scripts from richie0866/orca

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local sg = Instance.new("ScreenGui")
sg.Name = "OrcaScripts"
sg.ResetOnSpawn = false
sg.Parent = LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 250, 0, 350)
main.Position = UDim2.new(0.5, -125, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BorderSizePixel = 0
main.Parent = sg

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Orca Scripts"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = main

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -50)
scroll.Position = UDim2.new(0, 10, 0, 45)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 4
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local function createButton(name, url)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = scroll

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        local success, content = pcall(function()
            return game:HttpGet(url)
        end)
        if success then
            local func, err = loadstring(content)
            if func then
                task.spawn(func)
            else
                warn("Failed to load script: " .. tostring(err))
            end
        else
            warn("Failed to fetch script from URL: " .. url)
        end
    end)
end

local scripts = {
    {"Solaris", "https://solarishub.dev/script.lua"},
    {"V.G Hub", "https://raw.githubusercontent.com/1201for/V.G-Hub/main/V.Ghub"},
    {"CMD-X", "https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source"},
    {"Infinite Yield", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"},
    {"Dex Explorer", "https://pastebin.com/raw/mMbsHWiQ"},
    {"Unnamed ESP", "https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/master/UnnamedESP.lua"},
    {"EvoV2", "https://projectevo.xyz/script/loader.lua"}
}

for _, s in ipairs(scripts) do
    createButton(s[1], s[2])
end

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 20, 0, 20)
close.Position = UDim2.new(1, -25, 0, 5)
close.BackgroundTransparency = 1
close.Text = "X"
close.TextColor3 = Color3.fromRGB(200, 200, 200)
close.TextSize = 14
close.Font = Enum.Font.GothamBold
close.Parent = main
close.MouseButton1Click:Connect(function()
    sg:Destroy()
end)

local dragging, dragStart, startPos
main.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = i.Position
        startPos = main.Position
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(i)
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
