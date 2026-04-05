-- ╔══════════════════════════════════════════╗
-- ║       HAVOC — Admin Dashboard             ║
-- ║       by dxni  //  v2.4                   ║
-- ║       Tag card · Split tabs               ║
-- ╚══════════════════════════════════════════╝

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local HttpService      = game:GetService("HttpService")
local TextService      = game:GetService("TextService")
local LocalPlayer      = Players.LocalPlayer
local Mouse            = LocalPlayer:GetMouse()
local Camera           = workspace.CurrentCamera

-- ══════════════════════════════════════════
--  COLOR PALETTE
-- ══════════════════════════════════════════
local C = {
    BG        = Color3.fromRGB(6,5,8),
    SURFACE   = Color3.fromRGB(10,9,13),
    CARD      = Color3.fromRGB(14,13,18),
    CARD2     = Color3.fromRGB(20,18,25),
    TOPBAR    = Color3.fromRGB(8,7,11),
    ACCENT    = Color3.fromRGB(230,30,30),
    ACCENTHI  = Color3.fromRGB(255,60,60),
    ACCENTDIM = Color3.fromRGB(45,12,12),
    BORDER    = Color3.fromRGB(24,22,30),
    BORDER2   = Color3.fromRGB(36,34,45),
    TEXT      = Color3.fromRGB(240,238,245),
    SUBTEXT   = Color3.fromRGB(120,115,135),
    MUTED     = Color3.fromRGB(28,26,34),
    GREEN     = Color3.fromRGB(52,210,100),
    YELLOW    = Color3.fromRGB(255,215,0),
    CYAN      = Color3.fromRGB(0,200,220),
    AMBER     = Color3.fromRGB(245,158,11),
    WHITE     = Color3.fromRGB(255,255,255),
    GOLD      = Color3.fromRGB(255,215,0),
    PURPLE    = Color3.fromRGB(160,80,255),
    PINK      = Color3.fromRGB(255,80,160),
    NEUTRAL   = Color3.fromRGB(46,44,56),
    RED       = Color3.fromRGB(220,38,38),
}

local themeRegistry = {}
local function reg(obj, prop, key)
    if not key then return end
    table.insert(themeRegistry, {obj=obj, prop=prop, key=key})
end

-- ══════════════════════════════════════════
--  FEATURE STATE
-- ══════════════════════════════════════════
local speedVal         = 16
local speedOn          = false
local speedConn        = nil
local flyOn            = false
local flyBodyVel       = nil
local flyBodyGyro      = nil
local flyCharConn      = nil
local FLY_SPEED        = 60
local noclipOn         = false
local noclipConn       = nil
local invisOn          = false
local invisOrigTrans   = {}
local invisCharConn    = nil
local infJumpConn      = nil
local antiAfkConn      = nil
local fullbrightOn     = false
local origAmb          = Lighting.Ambient
local origOutAmb       = Lighting.OutdoorAmbient
local origBright       = Lighting.Brightness
local origFogEnd       = Lighting.FogEnd
local jumpPowerVal     = 50
local espOn            = false
local espConns         = {}
local fovCircleEnabled = false
local fovCircleSg      = nil
local fovCircleFrame   = nil
local FOV_RADIUS       = 120
local ESP_TEXT_SIZE    = 13
local TRACER_THICKNESS = 2
local tracersOn        = false
local tracerSg         = nil
local chamsOn          = false
local chamsConns       = {}
local chamsOrigData    = {}
local antiKBConn       = nil
local antiVoidConn     = nil
local voidThreshold    = -100
local antiRagdollConn  = nil
local safeTpEnabled    = true
local rejoinOnKick     = false
local kickConn         = nil
local fpsBoosterOn     = false
local chatLogConn      = nil
local autoRespawnConn  = nil
local serverHopOn      = false

-- ══════════════════════════════════════════
--  EXECUTOR HTTP DETECTION
-- ══════════════════════════════════════════
local crequest = nil
pcall(function()
    if type(syn)=="table" and type(syn.request)=="function" then crequest=syn.request
    elseif type(http_request)=="function" then crequest=http_request
    elseif type(request)=="function" then crequest=request
    elseif type(fluxus)=="table" and type(fluxus.request)=="function" then crequest=fluxus.request
    end
end)

-- ══════════════════════════════════════════
--  FEATURE IMPLEMENTATIONS
-- ══════════════════════════════════════════

local function applySpeed()
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = speedVal end
end
local function resetSpeed()
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16 end
end

local function disableFly()
    if flyBodyVel  then pcall(function() flyBodyVel:Destroy()  end); flyBodyVel  = nil end
    if flyBodyGyro then pcall(function() flyBodyGyro:Destroy() end); flyBodyGyro = nil end
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.PlatformStand = false end) end
end

local function enableFly()
    disableFly()
    local char = LocalPlayer.Character; if not char then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
    flyBodyVel = Instance.new("BodyVelocity", hrp)
    flyBodyVel.Velocity = Vector3.new(0,0,0)
    flyBodyVel.MaxForce = Vector3.new(1e9,1e9,1e9)
    flyBodyGyro = Instance.new("BodyGyro", hrp)
    flyBodyGyro.MaxTorque = Vector3.new(1e9,1e9,1e9)
    flyBodyGyro.P = 1e4
    local flyConn
    flyConn = RunService.RenderStepped:Connect(function()
        if not flyOn then flyConn:Disconnect(); return end
        local dir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir = dir + Camera.CFrame.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir = dir - Camera.CFrame.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir = dir + Vector3.new(0,1,0)        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir + Vector3.new(0,-1,0)       end
        if flyBodyVel then
            flyBodyVel.Velocity = dir.Magnitude > 0 and dir.Unit * FLY_SPEED or Vector3.new(0,0,0)
        end
        if flyBodyGyro then
            flyBodyGyro.CFrame = Camera.CFrame
        end
    end)
end

local function enableNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        if not noclipOn then noclipConn:Disconnect(); return end
        local char = LocalPlayer.Character; if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end
local function disableNoclip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    local char = LocalPlayer.Character
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end

local function enableInvisibility()
    local char = LocalPlayer.Character; if not char then return end
    invisOrigTrans = {}
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            invisOrigTrans[p] = p.Transparency; p.Transparency = 1
        end
    end
    for _, a in ipairs(char:GetDescendants()) do
        if a:IsA("Accessory") then
            local h = a:FindFirstChildOfClass("Handle")
            if h then invisOrigTrans[h] = h.Transparency; h.Transparency = 1 end
        end
    end
end
local function disableInvisibility()
    if invisCharConn then invisCharConn:Disconnect(); invisCharConn = nil end
    local char = LocalPlayer.Character; if not char then return end
    for part, orig in pairs(invisOrigTrans) do
        if part and part.Parent then part.Transparency = orig end
    end
    invisOrigTrans = {}
end

local function enableInfJump()
    infJumpConn = UserInputService.JumpRequest:Connect(function()
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end
local function disableInfJump()
    if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
end

local function enableAntiAFK()
    if antiAfkConn then return end
    antiAfkConn = LocalPlayer.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait()
        vu:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end)
end
local function disableAntiAFK()
    if antiAfkConn then antiAfkConn:Disconnect(); antiAfkConn = nil end
end

local function enableFullbright()
    Lighting.Ambient        = Color3.fromRGB(255,255,255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
    Lighting.Brightness     = 2
    Lighting.FogEnd         = 1e6
end
local function disableFullbright()
    Lighting.Ambient        = origAmb
    Lighting.OutdoorAmbient = origOutAmb
    Lighting.Brightness     = origBright
    Lighting.FogEnd         = origFogEnd
end

local function enableESP()
    local function addESP(p)
        if p == LocalPlayer then return end
        local function setup(char)
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if not hrp then return end
            for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("Highlight") or (d:IsA("BillboardGui") and d.Name == "ESP_BB") then
                    d:Destroy()
                end
            end
            local highlight = Instance.new("Highlight", char)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = C.ACCENT
            local bb = Instance.new("BillboardGui", hrp)
            bb.Name = "ESP_BB"
            bb.Size = UDim2.new(0,100,0,24)
            bb.StudsOffset = Vector3.new(0,3,0)
            bb.AlwaysOnTop = true
            local nameLbl = Instance.new("TextLabel", bb)
            nameLbl.Size = UDim2.new(1,0,1,0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = p.Name
            nameLbl.TextColor3 = Color3.fromRGB(255,255,255)
            nameLbl.TextSize = ESP_TEXT_SIZE
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextXAlignment = Enum.TextXAlignment.Center
        end
        if p.Character then setup(p.Character) end
        espConns[p] = p.CharacterAdded:Connect(setup)
    end
    for _, p in ipairs(Players:GetPlayers()) do addESP(p) end
    espConns["_added"] = Players.PlayerAdded:Connect(addESP)
end
local function disableESP()
    for _, conn in pairs(espConns) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    espConns = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _, d in ipairs(p.Character:GetDescendants()) do
                if d:IsA("Highlight") or (d:IsA("BillboardGui") and d.Name=="ESP_BB") then
                    d:Destroy()
                end
            end
        end
    end
end

local function buildFovCircle()
    if fovCircleSg then fovCircleSg:Destroy() end
    fovCircleSg = Instance.new("ScreenGui")
    fovCircleSg.Name = "Havoc_FOVCircle"
    fovCircleSg.ResetOnSpawn = false
    fovCircleSg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    fovCircleSg.Parent = LocalPlayer.PlayerGui
    fovCircleFrame = Instance.new("Frame")
    fovCircleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    fovCircleFrame.Size = UDim2.new(0, FOV_RADIUS*2, 0, FOV_RADIUS*2)
    fovCircleFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    fovCircleFrame.BackgroundTransparency = 1
    fovCircleFrame.BorderSizePixel = 0
    fovCircleFrame.Parent = fovCircleSg
    local s = Instance.new("UIStroke", fovCircleFrame)
    s.Color = C.ACCENT; s.Thickness = 1.5; s.Transparency = 0.2
    Instance.new("UICorner", fovCircleFrame).CornerRadius = UDim.new(1,0)
end
local function enableFovCircle()
    fovCircleEnabled = true; buildFovCircle()
end
local function disableFovCircle()
    fovCircleEnabled = false
    if fovCircleSg then fovCircleSg:Destroy(); fovCircleSg = nil; fovCircleFrame = nil end
end

local function enableTracers()
    tracersOn = true
    if tracerSg then tracerSg:Destroy() end
    tracerSg = Instance.new("ScreenGui")
    tracerSg.Name = "Havoc_Tracers"
    tracerSg.ResetOnSpawn = false
    tracerSg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    tracerSg.Parent = LocalPlayer.PlayerGui
    task.spawn(function()
        while tracersOn and tracerSg and tracerSg.Parent do
            for _, c in ipairs(tracerSg:GetChildren()) do c:Destroy() end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local vp = Camera.ViewportSize
                            local sx = vp.X/2; local sy = vp.Y
                            local dx = screenPos.X - sx; local dy = screenPos.Y - sy
                            local len = math.sqrt(dx*dx + dy*dy)
                            local ang = math.deg(math.atan2(dy, dx))
                            local line = Instance.new("Frame", tracerSg)
                            line.AnchorPoint = Vector2.new(0, 0.5)
                            line.Size = UDim2.new(0, len, 0, TRACER_THICKNESS)
                            line.Position = UDim2.new(0, sx+dx/2-len/2, 0, sy+dy/2)
                            line.Rotation = ang
                            line.BackgroundColor3 = C.ACCENT
                            line.BackgroundTransparency = 0.3
                            line.BorderSizePixel = 0
                        end
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end
local function disableTracers()
    tracersOn = false
    if tracerSg then tracerSg:Destroy(); tracerSg = nil end
end

local function enableChams()
    chamsOn = true; chamsOrigData = {}
    local function addChams(p)
        if p == LocalPlayer then return end
        local function setup(char)
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    chamsOrigData[part] = {material=part.Material, color=part.Color}
                    part.Material = Enum.Material.Neon
                    part.Color = C.ACCENT
                end
            end
        end
        if p.Character then setup(p.Character) end
        chamsConns[p] = p.CharacterAdded:Connect(setup)
    end
    for _, p in ipairs(Players:GetPlayers()) do addChams(p) end
    chamsConns["_added"] = Players.PlayerAdded:Connect(addChams)
end
local function disableChams()
    chamsOn = false
    for _, conn in pairs(chamsConns) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    chamsConns = {}
    for part, orig in pairs(chamsOrigData) do
        if part and part.Parent then
            part.Material = orig.material
            part.Color    = orig.color
        end
    end
    chamsOrigData = {}
end

local function enableAntiKB()
    antiKBConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if hrp.AssemblyLinearVelocity.Magnitude  > 100 then hrp.AssemblyLinearVelocity  = Vector3.new(0,0,0) end
            if hrp.AssemblyAngularVelocity.Magnitude > 10  then hrp.AssemblyAngularVelocity = Vector3.new(0,0,0) end
        end
    end)
end
local function disableAntiKB()
    if antiKBConn then antiKBConn:Disconnect(); antiKBConn = nil end
end

local function enableAntiVoid()
    if antiVoidConn then return end
    antiVoidConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Position.Y < voidThreshold then
            hrp.CFrame = CFrame.new(hrp.Position.X, 10, hrp.Position.Z)
        end
    end)
end
local function disableAntiVoid()
    if antiVoidConn then antiVoidConn:Disconnect(); antiVoidConn = nil end
end

local function enableAntiRagdoll()
    antiRagdollConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character; if not char then return end
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState() == Enum.HumanoidStateType.Ragdoll then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
end
local function disableAntiRagdoll()
    if antiRagdollConn then antiRagdollConn:Disconnect(); antiRagdollConn = nil end
end

local function enableRejoinOnKick()
    rejoinOnKick = true
    if kickConn then kickConn:Disconnect() end
    kickConn = LocalPlayer.AncestryChanged:Connect(function(_, parent)
        if not parent and rejoinOnKick then
            task.wait(1)
            pcall(function()
                game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
            end)
        end
    end)
end
local function disableRejoinOnKick()
    rejoinOnKick = false
    if kickConn then kickConn:Disconnect(); kickConn = nil end
end

local function enableFPSBooster()
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") then v.Enabled = false end
    end
    pcall(function() workspace.GlobalShadows = false end)
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
end
local function disableFPSBooster()
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") then v.Enabled = true end
    end
    pcall(function() workspace.GlobalShadows = true end)
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
end

local function enableChatLogger()
    pcall(function()
        local tcs = game:GetService("TextChatService")
        local ch  = tcs.TextChannels:FindFirstChild("RBXGeneral")
        if ch then
            chatLogConn = ch.MessageReceived:Connect(function(msg)
                print(string.format("[HAVOC CHAT] [%s] %s",
                    msg.TextSource and msg.TextSource.Name or "?", msg.Text))
            end)
        end
    end)
end
local function disableChatLogger()
    if chatLogConn then chatLogConn:Disconnect(); chatLogConn = nil end
end

local function enableAutoRespawn()
    autoRespawnConn = LocalPlayer.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 10)
        if hum then
            hum.Died:Connect(function()
                if autoRespawnConn then task.wait(0.1); LocalPlayer:LoadCharacter() end
            end)
        end
    end)
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Died:Connect(function()
            if autoRespawnConn then task.wait(0.1); LocalPlayer:LoadCharacter() end
        end)
    end
end
local function disableAutoRespawn()
    if autoRespawnConn then autoRespawnConn:Disconnect(); autoRespawnConn = nil end
end

-- ══════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════
local function tw(obj, props, t, style)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        props):Play()
end
local function frm(props, parent, themeKey)
    local f = Instance.new("Frame"); f.BorderSizePixel = 0
    for k,v in pairs(props) do f[k] = v end
    if parent then f.Parent = parent end
    if themeKey then reg(f, "BackgroundColor3", themeKey) end
    return f
end
local function lbl(props, parent, themeKey)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1; l.BorderSizePixel = 0
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    for k,v in pairs(props) do l[k] = v end
    if parent then l.Parent = parent end
    if themeKey then reg(l, "TextColor3", themeKey) end
    return l
end
local function tbtn(props, parent, themeKey)
    local b = Instance.new("TextButton")
    b.BorderSizePixel = 0; b.AutoButtonColor = false; b.Font = Enum.Font.GothamBold
    for k,v in pairs(props) do b[k] = v end
    b.MouseEnter:Connect(function() tw(b, {BackgroundTransparency = (props.BackgroundTransparency or 0) * 0.8}) end)
    b.MouseLeave:Connect(function() tw(b, {BackgroundTransparency = props.BackgroundTransparency or 0}) end)
    if parent then b.Parent = parent end
    if themeKey then reg(b, "BackgroundColor3", themeKey) end
    return b
end
local function corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 12); c.Parent = p; return c
end
local function stroke(p, col, thick, trans, themeKey)
    local s = Instance.new("UIStroke")
    s.Color = col or C.BORDER; s.Thickness = thick or 1.2; s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p
    if themeKey then reg(s, "Color", themeKey) end
    return s
end
local function scroll(parent, size, pos)
    local sc = Instance.new("ScrollingFrame")
    sc.Size = size or UDim2.new(1,0,1,0); sc.Position = pos or UDim2.new(0,0,0,0)
    sc.BackgroundTransparency = 1; sc.BorderSizePixel = 0
    sc.ScrollBarThickness = 2; sc.ScrollBarImageColor3 = C.BORDER2
    sc.CanvasSize = UDim2.new(0,0,0,0); sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.Parent = parent; return sc
end
local function listLayout(parent, pad_px)
    local ul = Instance.new("UIListLayout")
    ul.SortOrder = Enum.SortOrder.LayoutOrder; ul.Padding = UDim.new(0, pad_px or 0)
    ul.Parent = parent; return ul
end
local function sectionHeader(parent, text)
    local row = frm({Size=UDim2.new(1,0,0,16), BackgroundTransparency=1}, parent)
    frm({Size=UDim2.new(0,6,0,6), Position=UDim2.new(0,0,0,5), BackgroundColor3=C.ACCENT}, row, "ACCENT")
    lbl({Size=UDim2.new(0,160,1,0), Position=UDim2.new(0,12,0,0), Text=text:upper(),
        TextColor3=C.SUBTEXT, TextSize=9, Font=Enum.Font.GothamBold}, row, "SUBTEXT")
    frm({Size=UDim2.new(1,-170,0,1), Position=UDim2.new(0,166,0,7), BackgroundColor3=C.BORDER}, row, "BORDER")
    return row
end
local function makeToggle(parent, label, subLabel, defaultOn, onToggle)
    local row = frm({Size=UDim2.new(1,0,0,54), BackgroundColor3=C.SURFACE, ZIndex=6}, parent, "SURFACE")
    corner(row,10); stroke(row,C.BORDER,1.2, 0, "BORDER")
    lbl({Size=UDim2.new(1,-80,0,18), Position=UDim2.new(0,14,0,10), Text=label,
        TextColor3=C.TEXT, TextSize=12, Font=Enum.Font.GothamBold, ZIndex=7}, row, "TEXT")
    lbl({Size=UDim2.new(1,-80,0,14), Position=UDim2.new(0,14,0,28), Text=subLabel,
        TextColor3=C.SUBTEXT, TextSize=9, Font=Enum.Font.Gotham, ZIndex=7}, row, "SUBTEXT")
    local isOn = defaultOn or false
    local trackW = 40
    local track = frm({Size=UDim2.new(0,trackW,0,22), Position=UDim2.new(1,-trackW-14,0.5,-11),
        BackgroundColor3=isOn and C.ACCENT or C.MUTED, ZIndex=7}, row, isOn and "ACCENT" or "MUTED")
    corner(track,11)
    local thumb = frm({Size=UDim2.new(0,16,0,16), Position=UDim2.new(0,isOn and trackW-19 or 3,0.5,-8),
        BackgroundColor3=C.WHITE, ZIndex=8}, track)
    corner(thumb,8)
    local cl = tbtn({Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=9}, row)
    cl.MouseButton1Click:Connect(function()
        isOn = not isOn
        tw(track,{BackgroundColor3=isOn and C.ACCENT or C.MUTED})
        tw(thumb,{Position=UDim2.new(0,isOn and trackW-19 or 3,0.5,-8)})
        if onToggle then onToggle(isOn) end
    end)
    cl.MouseEnter:Connect(function() tw(row,{BackgroundColor3=C.CARD2, Size=UDim2.new(1,6,0,54), Position=UDim2.new(0,-3,0,0)}) end)
    cl.MouseLeave:Connect(function() tw(row,{BackgroundColor3=C.SURFACE, Size=UDim2.new(1,0,0,54), Position=UDim2.new(0,0,0,0)}) end)
    return row
end
local function makeSlider(parent, label, subLabel, minVal, maxVal, defaultVal, onChange)
    local row = frm({Size=UDim2.new(1,0,0,64), BackgroundColor3=C.SURFACE, ZIndex=6}, parent, "SURFACE")
    corner(row,10); stroke(row,C.BORDER,1.2, 0, "BORDER")
    lbl({Size=UDim2.new(1,-100,0,18), Position=UDim2.new(0,14,0,10), Text=label,
        TextColor3=C.TEXT, TextSize=12, Font=Enum.Font.GothamBold, ZIndex=7}, row, "TEXT")
    lbl({Size=UDim2.new(1,-100,0,14), Position=UDim2.new(0,14,0,28), Text=subLabel,
        TextColor3=C.SUBTEXT, TextSize=9, Font=Enum.Font.Gotham, ZIndex=7}, row, "SUBTEXT")
    local valLbl = lbl({Size=UDim2.new(0,60,0,20), Position=UDim2.new(1,-74,0,18),
        Text=tostring(defaultVal), TextColor3=C.ACCENTHI, TextSize=13,
        Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=7}, row, "ACCENTHI")
    local trackBg = frm({Size=UDim2.new(1,-28,0,5), Position=UDim2.new(0,14,0,48),
        BackgroundColor3=C.MUTED, ZIndex=7}, row, "MUTED")
    corner(trackBg,2.5)
    local pct = (defaultVal - minVal) / (maxVal - minVal)
    local fill = frm({Size=UDim2.new(pct,0,1,0), BackgroundColor3=C.ACCENT, ZIndex=8}, trackBg, "ACCENT"); corner(fill,2.5)
    local handle = frm({Size=UDim2.new(0,14,0,14), Position=UDim2.new(pct,0,0.5,-7),
        BackgroundColor3=C.WHITE, ZIndex=9}, trackBg); corner(handle,7)
    local draggingSlider = false
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then draggingSlider=true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then draggingSlider=false end
    end)
    RunService.RenderStepped:Connect(function()
        if draggingSlider then
            local relX   = Mouse.X - trackBg.AbsolutePosition.X
            local newPct = math.clamp(relX / trackBg.AbsoluteSize.X, 0, 1)
            local newVal = math.floor(minVal + newPct*(maxVal-minVal))
            fill.Size            = UDim2.new(newPct, 0, 1, 0)
            handle.Position      = UDim2.new(newPct, 0, 0.5, -6)
            valLbl.Text          = tostring(newVal)
            if onChange then onChange(newVal) end
        end
    end)
    return row
end
local function cardHeader(card, title, dotColor)
    local head = frm({Size=UDim2.new(1,0,0,34), BackgroundColor3=C.TOPBAR, ZIndex=5}, card, "TOPBAR")
    corner(head,10)
    frm({Size=UDim2.new(1,0,0,10), Position=UDim2.new(0,0,1,-10), BackgroundColor3=C.TOPBAR, ZIndex=5}, head, "TOPBAR")
    frm({Size=UDim2.new(1,0,0,1),  Position=UDim2.new(0,0,1,-1),  BackgroundColor3=C.BORDER, ZIndex=5}, head, "BORDER")
    local dot = frm({Size=UDim2.new(0,6,0,6), Position=UDim2.new(0,12,0.5,-3),
        BackgroundColor3=dotColor or C.ACCENT, ZIndex=6}, head, dotColor == nil and "ACCENT" or nil)
    corner(dot,3)
    lbl({Size=UDim2.new(1,-20,1,0), Position=UDim2.new(0,22,0,0), Text=title,
        TextColor3=C.TEXT, TextSize=11, Font=Enum.Font.GothamBold, ZIndex=6}, head, "TEXT")
    return head
end

local function RefreshTheme()
    for _, r in ipairs(themeRegistry) do
        if r.obj and r.obj.Parent then
            pcall(function()
                r.obj[r.prop] = C[r.key]
            end)
        end
    end
end

local function ApplyTheme(theme)
    for k, v in pairs(theme) do
        C[k] = v
    end
    RefreshTheme()
end

local Themes = {
    ["Havoc (Default)"] = {
        BG        = Color3.fromRGB(6,5,8),
        SURFACE   = Color3.fromRGB(10,9,13),
        CARD      = Color3.fromRGB(14,13,18),
        CARD2     = Color3.fromRGB(20,18,25),
        TOPBAR    = Color3.fromRGB(8,7,11),
        ACCENT    = Color3.fromRGB(230,30,30),
        ACCENTHI  = Color3.fromRGB(255,60,60),
        ACCENTDIM = Color3.fromRGB(45,12,12),
        BORDER    = Color3.fromRGB(24,22,30),
        BORDER2   = Color3.fromRGB(36,34,45),
        TEXT      = Color3.fromRGB(240,238,245),
        SUBTEXT   = Color3.fromRGB(120,115,135),
        MUTED     = Color3.fromRGB(28,26,34),
    },
    ["Bloodline"] = {
        BG        = Color3.fromRGB(0, 0, 0),
        SURFACE   = Color3.fromRGB(15, 0, 0),
        CARD      = Color3.fromRGB(25, 0, 0),
        CARD2     = Color3.fromRGB(40, 0, 0),
        TOPBAR    = Color3.fromRGB(10, 0, 0),
        ACCENT    = Color3.fromRGB(255, 0, 0),
        ACCENTHI  = Color3.fromRGB(255, 255, 255),
        ACCENTDIM = Color3.fromRGB(60, 0, 0),
        BORDER    = Color3.fromRGB(50, 0, 0),
        BORDER2   = Color3.fromRGB(80, 0, 0),
        TEXT      = Color3.fromRGB(255, 255, 255),
        SUBTEXT   = Color3.fromRGB(200, 200, 200),
        MUTED     = Color3.fromRGB(30, 0, 0),
    }
}

-- ══════════════════════════════════════════
--  ROOT GUI
-- ══════════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name = "HavocDashboard"; sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = LocalPlayer.PlayerGui

local ambientGlow = frm({
    Size=UDim2.new(0,500,0,500), Position=UDim2.new(0,-200,0,-200),
    BackgroundColor3=C.ACCENT, BackgroundTransparency=0.96, ZIndex=0
}, sg)
corner(ambientGlow, 250)

-- ══════════════════════════════════════════
--  MAIN WINDOW
-- ══════════════════════════════════════════
local win = Instance.new("CanvasGroup")
win.Name = "Main"
win.Size = UDim2.new(0, 940, 0, 580)
win.Position = UDim2.new(0.5, -470, 0.5, -290)
win.BackgroundColor3 = C.BG
win.BorderSizePixel = 0
win.ZIndex = 1
win.Parent = sg
reg(win, "BackgroundColor3", "BG")

corner(win, 16); stroke(win, C.BORDER2, 1.2, 0, "BORDER2")

-- Ambient Background Effects
local bgGlow = frm({Size=UDim2.new(1.4,0,1.4,0), Position=UDim2.new(-0.2,0,-0.2,0), BackgroundColor3=C.ACCENT, BackgroundTransparency=0.96, ZIndex=2}, win, "ACCENT")
corner(bgGlow, 300)
local bgGlow2 = frm({Size=UDim2.new(0.8,0,0.8,0), Position=UDim2.new(0.4,0,0.4,0), BackgroundColor3=C.ACCENT, BackgroundTransparency=0.97, ZIndex=2}, win, "ACCENT")
corner(bgGlow2, 200)

frm({Size=UDim2.new(1,0,0,80), BackgroundColor3=C.ACCENT, BackgroundTransparency=0.94, ZIndex=2}, win, "ACCENT")

local dragging, dragStart, startPos = false, nil, nil

-- ══════════════════════════════════════════
--  SIDEBAR
-- ══════════════════════════════════════════
local sidebar = frm({Size=UDim2.new(0,210,1,0), BackgroundColor3=C.SURFACE, ZIndex=3}, win, "SURFACE")
frm({Size=UDim2.new(0,1,1,0), Position=UDim2.new(1,-1,0,0),
    BackgroundColor3=C.ACCENT, BackgroundTransparency=0.7, ZIndex=4}, sidebar, "ACCENT")
stroke(sidebar,C.BORDER,1, 0, "BORDER")

local logoArea = frm({Size=UDim2.new(1,0,0,90), BackgroundTransparency=1, ZIndex=4}, sidebar)
frm({Size=UDim2.new(1,-24,0,1), Position=UDim2.new(0,12,1,-1), BackgroundColor3=C.BORDER, ZIndex=4}, logoArea)
local logoPill = frm({Size=UDim2.new(0,42,0,42), Position=UDim2.new(0,16,0,20),
    BackgroundColor3=C.ACCENT, ZIndex=5}, logoArea, "ACCENT")
corner(logoPill,12)
local lgs = stroke(logoPill, C.ACCENTHI, 1.8, 0.25, "ACCENTHI")
lbl({Size=UDim2.new(1,0,1,0), Text="⚔", TextColor3=C.WHITE, TextSize=22,
    TextXAlignment=Enum.TextXAlignment.Center, ZIndex=6}, logoPill, "WHITE")
lbl({Size=UDim2.new(0,120,0,22), Position=UDim2.new(0,68,0,22), Text="HAVOC",
    TextColor3=C.TEXT, TextSize=18, Font=Enum.Font.GothamBold, ZIndex=5}, logoArea, "TEXT")
lbl({Size=UDim2.new(0,120,0,14), Position=UDim2.new(0,68,0,42), Text="Admin Intelligence",
    TextColor3=C.SUBTEXT, TextSize=10, Font=Enum.Font.Gotham, ZIndex=5}, logoArea, "SUBTEXT")
local vBadge = frm({Size=UDim2.new(0,140,0,18), Position=UDim2.new(0,16,0,62),
    BackgroundColor3=C.ACCENTDIM, ZIndex=5, BackgroundTransparency=0.8}, logoArea, "ACCENTDIM")
corner(vBadge,9); stroke(vBadge,C.ACCENT,1,0.6, "ACCENT")
lbl({Size=UDim2.new(1,0,1,0), Text="SYSTEM VERSION 2.4", TextColor3=C.ACCENTHI,
    TextSize=8, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Center, ZIndex=6}, vBadge)

local NAV_ITEMS = {
    {label="DASHBOARD", isSection=true},
    {icon="⬡",  name="Home",      tab="home"},
    {label="COMBAT", isSection=true},
    {icon="🎮",  name="Player",    tab="player"},
    {icon="⚔",  name="Aimbot",    tab="aimbot"},
    {icon="👁",  name="Visual",    tab="visual"},
    {label="PLAYERS", isSection=true},
    {icon="🔎",  name="Target",    tab="target"},
    {label="UTILITY", isSection=true},
    {icon="🛡",  name="Protect",   tab="protect"},
    {icon="⚙",  name="Misc",      tab="misc"},
    {icon="📜",  name="Scripts",   tab="scripts"},
    {icon="🎨",  name="Themes",    tab="themes"},
    {label="INFO", isSection=true},
    {icon="📋",  name="Changelog", tab="changelog"},
}

local navScroll = scroll(sidebar, UDim2.new(1,0,1,-140), UDim2.new(0,0,0,73))
local navInner = frm({Size=UDim2.new(1,-16,0,0), Position=UDim2.new(0,8,0,8),
    BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y, ZIndex=4}, navScroll)
listLayout(navInner,2)

local navBtnMap = {}
local currentTab = "home"

local function buildNavItem(icon, name, tabName)
    local isActive = (tabName == currentTab)
    local row = frm({Size=UDim2.new(1,0,0,38), BackgroundColor3=C.ACCENTDIM,
        BackgroundTransparency=isActive and 0.85 or 1, ZIndex=5}, navInner, isActive and "ACCENTDIM" or nil)
    corner(row,10)
    local rowStroke = stroke(row, C.ACCENT, 1.2, isActive and 0.6 or 1, "ACCENT")
    local bar = frm({Size=UDim2.new(0,4,0,18), Position=UDim2.new(0,0,0.5,-9),
        BackgroundColor3=C.ACCENT, ZIndex=7, Visible=isActive}, row, "ACCENT")
    corner(bar,2)
    local iconLbl = lbl({Size=UDim2.new(0,24,1,0), Position=UDim2.new(0,14,0,0),
        Text=icon, TextColor3=isActive and C.TEXT or C.SUBTEXT,
        TextSize=14, TextXAlignment=Enum.TextXAlignment.Center, ZIndex=6}, row, isActive and "TEXT" or "SUBTEXT")
    local nameLbl = lbl({Size=UDim2.new(1,-42,1,0), Position=UDim2.new(0,42,0,0),
        Text=name, TextColor3=isActive and C.TEXT or C.SUBTEXT,
        TextSize=12, Font=Enum.Font.GothamBold, ZIndex=6}, row, isActive and "TEXT" or "SUBTEXT")
    local cl = tbtn({Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=7}, row)
    cl.MouseEnter:Connect(function()
        if currentTab ~= tabName then
            tw(row,{BackgroundTransparency=0,BackgroundColor3=C.CARD})
            tw(nameLbl,{TextColor3=C.TEXT}); tw(iconLbl,{TextColor3=C.TEXT})
        end
    end)
    cl.MouseLeave:Connect(function()
        if currentTab ~= tabName then
            tw(row,{BackgroundTransparency=1})
            tw(nameLbl,{TextColor3=C.SUBTEXT}); tw(iconLbl,{TextColor3=C.SUBTEXT})
        end
    end)
    navBtnMap[tabName] = {row=row,nameLbl=nameLbl,iconLbl=iconLbl,bar=bar,rowStroke=rowStroke,cl=cl}
    return row
end
local function buildNavSection(label)
    local row = frm({Size=UDim2.new(1,0,0,24), BackgroundTransparency=1, ZIndex=5}, navInner)
    lbl({Size=UDim2.new(1,-8,1,0), Position=UDim2.new(0,8,0,0), Text=label,
        TextColor3=C.SUBTEXT, TextSize=8, Font=Enum.Font.GothamBold, ZIndex=6}, row)
    return row
end
for _, item in ipairs(NAV_ITEMS) do
    if item.isSection then buildNavSection(item.label)
    else buildNavItem(item.icon, item.name, item.tab) end
end

local sideFooter = frm({Size=UDim2.new(1,0,0,52), Position=UDim2.new(0,0,1,-52),
    BackgroundColor3=C.SURFACE, ZIndex=5}, sidebar)
frm({Size=UDim2.new(1,0,0,1), BackgroundColor3=C.BORDER, ZIndex=5}, sideFooter)
local chip = frm({Size=UDim2.new(1,-16,0,34), Position=UDim2.new(0,8,0,9),
    BackgroundColor3=C.CARD, ZIndex=6}, sideFooter)
corner(chip,8); stroke(chip,C.BORDER2,1)
local ownerIcon = frm({Size=UDim2.new(0,24,0,24), Position=UDim2.new(0,5,0.5,-12),
    BackgroundColor3=C.ACCENTDIM, ZIndex=7}, chip)
corner(ownerIcon,6); stroke(ownerIcon,C.ACCENT,1,0.4)
lbl({Size=UDim2.new(1,0,1,0), Text="★", TextColor3=C.YELLOW, TextSize=13,
    TextXAlignment=Enum.TextXAlignment.Center, ZIndex=8}, ownerIcon)
lbl({Size=UDim2.new(1,-36,0,14), Position=UDim2.new(0,34,0,5),
    Text="robloxguycoolestman", TextColor3=C.TEXT, TextSize=9, Font=Enum.Font.GothamBold, ZIndex=7}, chip)
lbl({Size=UDim2.new(1,-36,0,11), Position=UDim2.new(0,34,0,19),
    Text="★ OWNER", TextColor3=C.YELLOW, TextSize=8, Font=Enum.Font.GothamBold, ZIndex=7}, chip)

-- ══════════════════════════════════════════
--  MAIN AREA
-- ══════════════════════════════════════════
local mainArea = frm({Size=UDim2.new(1,-210,1,0), Position=UDim2.new(0,210,0,0),
    BackgroundTransparency=1, ClipsDescendants=true, ZIndex=3}, win)

local topbar = frm({Size=UDim2.new(1,0,0,44), BackgroundColor3=C.TOPBAR, ZIndex=4}, mainArea, "TOPBAR")
frm({Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BackgroundColor3=C.BORDER, ZIndex=4}, topbar, "BORDER")
local breadcrumb = lbl({Size=UDim2.new(0,300,1,0), Position=UDim2.new(0,14,0,0),
    Text="havoc  /  home", TextColor3=C.SUBTEXT, TextSize=10, Font=Enum.Font.GothamBold, ZIndex=5}, topbar, "SUBTEXT")
local liveDot = frm({Size=UDim2.new(0,7,0,7), Position=UDim2.new(1,-200,0.5,-3),
    BackgroundColor3=C.GREEN, ZIndex=5}, topbar, "GREEN"); corner(liveDot,4)
lbl({Size=UDim2.new(0,40,1,0), Position=UDim2.new(1,-190,0,0), Text="LIVE",
    TextColor3=C.GREEN, TextSize=9, Font=Enum.Font.GothamBold, ZIndex=5}, topbar, "GREEN")
task.spawn(function()
    while sg.Parent do
        tw(liveDot,{BackgroundTransparency=0.5},1); task.wait(1)
        tw(liveDot,{BackgroundTransparency=0},1);   task.wait(1)
    end
end)
local cmdBtn = tbtn({Size=UDim2.new(0,130,0,26), Position=UDim2.new(1,-144,0.5,-13),
    BackgroundColor3=C.CARD, TextColor3=C.SUBTEXT, TextSize=9, Text="⌘  Command  K",
    Font=Enum.Font.GothamBold, ZIndex=5}, topbar)
corner(cmdBtn,6); stroke(cmdBtn,C.BORDER2,1)
cmdBtn.MouseEnter:Connect(function() tw(cmdBtn,{BackgroundColor3=C.CARD2,TextColor3=C.TEXT}) end)
cmdBtn.MouseLeave:Connect(function() tw(cmdBtn,{BackgroundColor3=C.CARD,TextColor3=C.SUBTEXT}) end)
topbar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true; dragStart={Mouse.X,Mouse.Y}
        startPos={win.Position.X.Offset,win.Position.Y.Offset}
    end
end)
topbar.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)
RunService.RenderStepped:Connect(function()
    if dragging then
        win.Position=UDim2.new(0,startPos[1]+Mouse.X-dragStart[1],0,startPos[2]+Mouse.Y-dragStart[2])
    end
end)
local closeBtn = tbtn({Size=UDim2.new(0,22,0,22), Position=UDim2.new(1,-30,0.5,-11),
    BackgroundColor3=C.WHITE, BackgroundTransparency=1, TextColor3=C.WHITE,
    TextSize=10, Text="✕", Font=Enum.Font.GothamBold, ZIndex=6}, topbar)
corner(closeBtn,11)
local closeStroke = stroke(closeBtn,Color3.fromRGB(180,180,180),1.5)
closeBtn.MouseEnter:Connect(function() tw(closeBtn,{BackgroundTransparency=0.82}); tw(closeStroke,{Color=C.WHITE}) end)
closeBtn.MouseLeave:Connect(function() tw(closeBtn,{BackgroundTransparency=1}); tw(closeStroke,{Color=Color3.fromRGB(180,180,180)}) end)
closeBtn.MouseButton1Click:Connect(function() sg.Enabled=false end)

local tickerBar = frm({Size=UDim2.new(1,0,0,20), Position=UDim2.new(0,0,0,44),
    BackgroundColor3=C.SURFACE, ZIndex=4}, mainArea, "SURFACE")
frm({Size=UDim2.new(1,0,0,1), BackgroundColor3=C.BORDER, ZIndex=4}, tickerBar, "BORDER")
frm({Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BackgroundColor3=C.BORDER, ZIndex=4}, tickerBar, "BORDER")
local TICKER = "  HAVOC v2.4  //  AIMBOT BUILD  ▸  Speed · Fly · Noclip · Invis · Aimbot · ESP · Chams · Tracers · FOV · AntiVoid · AntiKB  ▸  "
local tickerLbl = lbl({Size=UDim2.new(0,2000,1,0), Position=UDim2.new(0,700,0,0),
    Text=TICKER..TICKER, TextColor3=C.SUBTEXT, TextSize=9,
    Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5}, tickerBar, "SUBTEXT")
task.spawn(function()
    while sg.Parent do
        local sx = tickerLbl.Position.X.Offset
        if sx < -1400 then tickerLbl.Position=UDim2.new(0,700,0,0)
        else tickerLbl.Position=UDim2.new(0,sx-1,0,0) end
        task.wait(0.03)
    end
end)

-- ══════════════════════════════════════════
--  TAB SYSTEM
-- ══════════════════════════════════════════
local tabContainer = frm({Size=UDim2.new(1,0,1,-64), Position=UDim2.new(0,0,0,64),
    BackgroundTransparency=1, ClipsDescendants=true, ZIndex=3}, mainArea)
local tabPages = {}
local function newTabPage(tabName)
    local page = scroll(tabContainer, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0))
    page.Visible=false; page.ZIndex=4
    local inner = frm({Size=UDim2.new(1,-24,0,0), Position=UDim2.new(0,12,0,12),
        BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y, ZIndex=4}, page)
    listLayout(inner,12)
    tabPages[tabName]={page=page,inner=inner}
    return inner
end
local function switchTab(tabName)
    for name,data in pairs(tabPages) do data.page.Visible=(name==tabName) end
    for name,nav in pairs(navBtnMap) do
        local isActive=(name==tabName)
        tw(nav.row,{BackgroundTransparency=isActive and 0 or 1,BackgroundColor3=C.ACCENTDIM})
        nav.rowStroke.Transparency=isActive and 0.7 or 1
        nav.bar.Visible=isActive
        nav.nameLbl.TextColor3=isActive and C.TEXT or C.SUBTEXT
        nav.iconLbl.TextColor3=isActive and C.TEXT or C.SUBTEXT
    end
    currentTab=tabName; breadcrumb.Text="havoc  /  "..tabName
end
for _,item in ipairs(NAV_ITEMS) do
    if not item.isSection and navBtnMap[item.tab] then
        local tabName=item.tab
        navBtnMap[tabName].cl.MouseButton1Click:Connect(function() switchTab(tabName) end)
    end
end

-- ══════════════════════════════════════════
--  TAB: HOME  (wrapped to isolate locals)
-- ══════════════════════════════════════════
local function buildHomeTab()
    local homeInner = newTabPage("home")
    sectionHeader(homeInner,"Overview")
    local statsRow = frm({Size=UDim2.new(1,0,0,82),BackgroundTransparency=1,ZIndex=4},homeInner)
    local STATS = {
        {label="WHITELISTED USERS",value="4",  meta="robloxguycoolestman +3",metaColor=C.SUBTEXT,topColor=C.ACCENT,icon="👥"},
        {label="ACTIVE NAMETAGS",  value="44", meta="↑ HVC ranks loaded",   metaColor=C.GREEN,  topColor=C.AMBER, icon="🏷"},
        {label="SCRIPT VERSION",   value="2.4",meta="✓ Tag card build",      metaColor=C.GREEN,  topColor=C.GREEN, icon="⚡"},
    }
    local cardW = 654/4
    for i,stat in ipairs(STATS) do
        local card=frm({Size=UDim2.new(0,cardW-4,1,0),Position=UDim2.new(0,(i-1)*cardW,0,0),BackgroundColor3=C.CARD,ZIndex=5},statsRow)
        corner(card,10); stroke(card,C.BORDER,1)
        frm({Size=UDim2.new(0.6,0,0,2),BackgroundColor3=stat.topColor,BackgroundTransparency=0.2,ZIndex=6},card)
        lbl({Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-34,0,6),Text=stat.icon,TextColor3=C.WHITE,TextSize=18,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=6},card)
        lbl({Size=UDim2.new(1,-10,0,12),Position=UDim2.new(0,8,0,8),Text=stat.label,TextColor3=C.SUBTEXT,TextSize=7,Font=Enum.Font.GothamBold,ZIndex=6},card)
        lbl({Size=UDim2.new(1,-10,0,28),Position=UDim2.new(0,8,0,22),Text=stat.value,TextColor3=C.TEXT,TextSize=24,Font=Enum.Font.GothamBold,ZIndex=6},card)
        lbl({Size=UDim2.new(1,-10,0,14),Position=UDim2.new(0,8,0,54),Text=stat.meta,TextColor3=stat.metaColor,TextSize=8,Font=Enum.Font.Gotham,ZIndex=6},card)
        local cl=tbtn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=7},card)
        cl.MouseEnter:Connect(function() tw(card,{BackgroundColor3=C.CARD2}) end)
        cl.MouseLeave:Connect(function() tw(card,{BackgroundColor3=C.CARD}) end)
    end

    -- 4th card: Nametag Yes/No + Rank/Custom
    local tagCard=frm({Size=UDim2.new(0,cardW-4,1,0),Position=UDim2.new(0,3*cardW,0,0),BackgroundColor3=C.CARD,ZIndex=5},statsRow)
    corner(tagCard,10); stroke(tagCard,C.BORDER,1)
    frm({Size=UDim2.new(0.6,0,0,2),BackgroundColor3=C.AMBER,BackgroundTransparency=0.2,ZIndex=6},tagCard)
    lbl({Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-34,0,6),Text="🏷",TextColor3=C.WHITE,TextSize=18,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=6},tagCard)
    lbl({Size=UDim2.new(1,-10,0,12),Position=UDim2.new(0,8,0,8),Text="NAMETAG",TextColor3=C.SUBTEXT,TextSize=7,Font=Enum.Font.GothamBold,ZIndex=6},tagCard)

    local tagYesActive=false; local tagTypeActive=nil

    -- Yes / No row
    local tagYesBtn=tbtn({Size=UDim2.new(0.5,-8,0,20),Position=UDim2.new(0,6,0,24),BackgroundColor3=C.MUTED,TextColor3=C.SUBTEXT,TextSize=9,Text="Yes",Font=Enum.Font.GothamBold,ZIndex=6},tagCard)
    corner(tagYesBtn,5); stroke(tagYesBtn,C.BORDER2,1)
    local tagNoBtn=tbtn({Size=UDim2.new(0.5,-8,0,20),Position=UDim2.new(0.5,2,0,24),BackgroundColor3=C.MUTED,TextColor3=C.SUBTEXT,TextSize=9,Text="No",Font=Enum.Font.GothamBold,ZIndex=6},tagCard)
    corner(tagNoBtn,5); stroke(tagNoBtn,C.BORDER2,1)

    -- Rank / Custom row (disabled look until Yes)
    local tagRankBtn=tbtn({Size=UDim2.new(0.5,-8,0,18),Position=UDim2.new(0,6,0,48),BackgroundColor3=C.MUTED,TextColor3=C.SUBTEXT,BackgroundTransparency=0.4,TextSize=8,Text="Rank",Font=Enum.Font.GothamBold,ZIndex=6},tagCard)
    corner(tagRankBtn,5); stroke(tagRankBtn,C.BORDER2,1)
    local tagCustomBtn=tbtn({Size=UDim2.new(0.5,-8,0,18),Position=UDim2.new(0.5,2,0,48),BackgroundColor3=C.MUTED,TextColor3=C.SUBTEXT,BackgroundTransparency=0.4,TextSize=8,Text="Custom",Font=Enum.Font.GothamBold,ZIndex=6},tagCard)
    corner(tagCustomBtn,5); stroke(tagCustomBtn,C.BORDER2,1)

    -- Custom text input (hidden until Custom selected)
    local tagInputBox=Instance.new("TextBox")
    tagInputBox.Size=UDim2.new(1,-12,0,15); tagInputBox.Position=UDim2.new(0,6,0,70)
    tagInputBox.BackgroundColor3=C.MUTED; tagInputBox.BorderSizePixel=0
    tagInputBox.PlaceholderText="custom tag..."; tagInputBox.PlaceholderColor3=C.SUBTEXT
    tagInputBox.TextColor3=C.TEXT; tagInputBox.TextSize=8; tagInputBox.Font=Enum.Font.GothamBold
    tagInputBox.ClearTextOnFocus=false; tagInputBox.ZIndex=7; tagInputBox.Visible=false
    tagInputBox.Parent=tagCard; corner(tagInputBox,5); stroke(tagInputBox,C.ACCENT,1,0.5)

    local function setTagType(which)
        if not tagYesActive then return end
        tagTypeActive=which
        if which=="rank" then
            tw(tagRankBtn,{BackgroundColor3=C.ACCENTDIM,BackgroundTransparency=0}); tagRankBtn.TextColor3=C.ACCENTHI
            tw(tagCustomBtn,{BackgroundColor3=C.MUTED,BackgroundTransparency=0.4}); tagCustomBtn.TextColor3=C.SUBTEXT
            tagInputBox.Visible=false
        else
            tw(tagCustomBtn,{BackgroundColor3=Color3.fromRGB(40,22,0),BackgroundTransparency=0}); tagCustomBtn.TextColor3=C.AMBER
            tw(tagRankBtn,{BackgroundColor3=C.MUTED,BackgroundTransparency=0.4}); tagRankBtn.TextColor3=C.SUBTEXT
            tagInputBox.Visible=true
        end
    end

    tagYesBtn.MouseButton1Click:Connect(function()
        tagYesActive=true
        tw(tagYesBtn,{BackgroundColor3=Color3.fromRGB(10,36,18)}); tagYesBtn.TextColor3=C.GREEN
        tw(tagNoBtn,{BackgroundColor3=C.MUTED}); tagNoBtn.TextColor3=C.SUBTEXT
        tw(tagRankBtn,{BackgroundTransparency=0}); tw(tagCustomBtn,{BackgroundTransparency=0})
    end)
    tagNoBtn.MouseButton1Click:Connect(function()
        tagYesActive=false; tagTypeActive=nil
        tw(tagNoBtn,{BackgroundColor3=Color3.fromRGB(36,10,10)}); tagNoBtn.TextColor3=C.RED
        tw(tagYesBtn,{BackgroundColor3=C.MUTED}); tagYesBtn.TextColor3=C.SUBTEXT
        tw(tagRankBtn,{BackgroundColor3=C.MUTED,BackgroundTransparency=0.4}); tagRankBtn.TextColor3=C.SUBTEXT
        tw(tagCustomBtn,{BackgroundColor3=C.MUTED,BackgroundTransparency=0.4}); tagCustomBtn.TextColor3=C.SUBTEXT
        tagInputBox.Visible=false
    end)
    tagRankBtn.MouseButton1Click:Connect(function() setTagType("rank") end)
    tagCustomBtn.MouseButton1Click:Connect(function() setTagType("custom") end)
    sectionHeader(homeInner,"Activity & Changelog")
    local midRow=frm({Size=UDim2.new(1,0,0,210),BackgroundTransparency=1,ZIndex=4},homeInner)
    local feedCard=frm({Size=UDim2.new(0.62,-6,1,0),BackgroundColor3=C.CARD,ZIndex=5},midRow); corner(feedCard,10); stroke(feedCard,C.BORDER,1)
    cardHeader(feedCard,"Recent Activity",C.ACCENT)
    local feedScroll=scroll(feedCard,UDim2.new(1,0,1,-34),UDim2.new(0,0,0,34))
    local feedInner=frm({Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=5},feedScroll); listLayout(feedInner,0)
    local FEED={
        {name="robloxguycoolestman",action="Loaded",    detail="Havoc v2.1",    role="OWNER", roleColor=C.ACCENT,avatarCol=C.ACCENTDIM,            time="just now"},
        {name="MelodyCrafter3",     action="Whitelist", detail="authorized",    role="MEMBER",roleColor=C.CYAN,  avatarCol=Color3.fromRGB(0,30,36),time="2m ago"},
        {name="itsdemix_3",         action="Whitelist", detail="authorized",    role="MEMBER",roleColor=C.CYAN,  avatarCol=Color3.fromRGB(0,30,36),time="5m ago"},
        {name="lil_mineturtle",     action="Role:",     detail="Admin assigned",role="ADMIN", roleColor=C.ACCENT,avatarCol=C.ACCENTDIM,            time="1h ago"},
        {name="System",             action="Nametag sys",detail="44 tags",      role="SYSTEM",roleColor=C.AMBER, avatarCol=Color3.fromRGB(30,20,0),time="1h ago"},
    }
    for _,item in ipairs(FEED) do
        local row=frm({Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,ZIndex=6},feedInner)
        local av=frm({Size=UDim2.new(0,22,0,22),Position=UDim2.new(0,10,0.5,-11),BackgroundColor3=item.avatarCol,ZIndex=7},row); corner(av,6); stroke(av,item.roleColor,1,0.5)
        lbl({Size=UDim2.new(1,0,1,0),Text="●",TextColor3=item.roleColor,TextSize=8,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=8},av)
        lbl({Size=UDim2.new(0,130,0,15),Position=UDim2.new(0,38,0,3),Text=item.name,TextColor3=C.TEXT,TextSize=10,Font=Enum.Font.GothamBold,ZIndex=7},row)
        lbl({Size=UDim2.new(0,160,0,12),Position=UDim2.new(0,38,0,17),Text=item.action.." "..item.detail,TextColor3=C.SUBTEXT,TextSize=8,Font=Enum.Font.Gotham,ZIndex=7},row)
        lbl({Size=UDim2.new(0,50,1,0),Position=UDim2.new(1,-140,0,0),Text=item.time,TextColor3=C.SUBTEXT,TextSize=8,Font=Enum.Font.Gotham,ZIndex=7},row)
        local badge=frm({Size=UDim2.new(0,54,0,16),Position=UDim2.new(1,-62,0.5,-8),BackgroundColor3=Color3.new(item.roleColor.R*0.1,item.roleColor.G*0.1,item.roleColor.B*0.1),ZIndex=7},row); corner(badge,8); stroke(badge,item.roleColor,1,0.4)
        lbl({Size=UDim2.new(1,0,1,0),Text=item.role,TextColor3=item.roleColor,TextSize=7,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=8},badge)
        local cl=tbtn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=9},row)
        cl.MouseEnter:Connect(function() tw(row,{BackgroundTransparency=0,BackgroundColor3=C.CARD2}) end)
        cl.MouseLeave:Connect(function() tw(row,{BackgroundTransparency=1}) end)
    end
    local clCard=frm({Size=UDim2.new(0.38,-6,1,0),Position=UDim2.new(0.62,6,0,0),BackgroundColor3=C.CARD,ZIndex=5},midRow); corner(clCard,10); stroke(clCard,C.BORDER,1)
    cardHeader(clCard,"Changelog",C.ACCENT)
    local clScroll=scroll(clCard,UDim2.new(1,0,1,-34),UDim2.new(0,0,0,34))
    local clInner=frm({Size=UDim2.new(1,-12,0,0),Position=UDim2.new(0,6,0,6),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=5},clScroll); listLayout(clInner,6)
    local CL={
        {"v2.2","Aimbot + ESP Tab","Full aimbot wired. Whitelist/Nametag tabs removed. B = aimbot."},
        {"v2.1","Final Build","All scripts wired. Speed, Fly, Noclip, Invis, ESP, etc."},
        {"v2.0","Tabbed Dashboard","Player, Target, Visual, Protect, Misc tabs."},
    }
    for _,entry in ipairs(CL) do
        local e=frm({Size=UDim2.new(1,0,0,60),BackgroundColor3=C.SURFACE,ZIndex=6},clInner); corner(e,8); stroke(e,C.BORDER,1)
        local vb=frm({Size=UDim2.new(0,30,0,14),Position=UDim2.new(0,8,0,6),BackgroundColor3=C.ACCENTDIM,ZIndex=7},e); corner(vb,7); stroke(vb,C.ACCENT,1,0.4)
        lbl({Size=UDim2.new(1,0,1,0),Text=entry[1],TextColor3=C.ACCENTHI,TextSize=7,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=8},vb)
        lbl({Size=UDim2.new(1,-52,0,16),Position=UDim2.new(0,8,0,20),Text=entry[2],TextColor3=C.WHITE,TextSize=11,Font=Enum.Font.GothamBold,ZIndex=7},e)
        lbl({Size=UDim2.new(1,-16,0,22),Position=UDim2.new(0,8,0,36),Text=entry[3],TextColor3=C.SUBTEXT,TextSize=8,Font=Enum.Font.Gotham,TextWrapped=true,ZIndex=7},e)
    end
    local bottomRow=frm({Size=UDim2.new(1,0,0,170),BackgroundTransparency=1,ZIndex=4},homeInner)
    local function bottomCard(xScale,xOff,title)
        local card=frm({Size=UDim2.new(xScale,-6,1,0),Position=UDim2.new(xOff*0.333,xOff==0 and 0 or 6,0,0),BackgroundColor3=C.CARD,ZIndex=5},bottomRow)
        corner(card,10); stroke(card,C.BORDER,1); cardHeader(card,title,C.ACCENT); return card
    end
    local roleCard=bottomCard(0.333,0,"Role Breakdown")
    local roleInner=frm({Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,0,34),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=5},roleCard); listLayout(roleInner,0)
    for _,r in ipairs({{name="Owner",color=C.YELLOW,count="1",pct=0.25},{name="Admin",color=C.ACCENT,count="1",pct=0.25},{name="Member",color=C.CYAN,count="2",pct=0.5},{name="Named Tags",color=C.AMBER,count="44",pct=1.0}}) do
        local row=frm({Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,ZIndex=6},roleInner)
        local dot=frm({Size=UDim2.new(0,7,0,7),Position=UDim2.new(0,10,0.5,-3),BackgroundColor3=r.color,ZIndex=7},row); corner(dot,4)
        lbl({Size=UDim2.new(0,90,1,0),Position=UDim2.new(0,22,0,0),Text=r.name,TextColor3=C.TEXT,TextSize=10,Font=Enum.Font.GothamBold,ZIndex=7},row)
        local barBg=frm({Size=UDim2.new(0,60,0,4),Position=UDim2.new(1,-88,0.5,-2),BackgroundColor3=C.MUTED,ZIndex=7},row); corner(barBg,2)
        frm({Size=UDim2.new(r.pct,0,1,0),BackgroundColor3=r.color,ZIndex=8},barBg)
        lbl({Size=UDim2.new(0,22,1,0),Position=UDim2.new(1,-24,0,0),Text=r.count,TextColor3=C.SUBTEXT,TextSize=9,Font=Enum.Font.GothamBold,ZIndex=7},row)
    end
    local sysCard=bottomCard(0.333,1,"System Status")
    local sysInner=frm({Size=UDim2.new(1,-16,0,0),Position=UDim2.new(0,8,0,38),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=5},sysCard); listLayout(sysInner,2)
    for _,item in ipairs({{name="Whitelist Save",val="ONLINE",ok=true},{name="Nametag System",val="LOADED",ok=true},{name="ScriptBlox API",val="REACHABLE",ok=true},{name="Owner Auth",val="VERIFIED",ok=true},{name="UI Version",val="v2.1",ok=true}}) do
        local row=frm({Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,ZIndex=6},sysInner)
        local ind=frm({Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,0,0.5,-3),BackgroundColor3=item.ok and C.GREEN or C.YELLOW,ZIndex=7},row); corner(ind,3)
        task.spawn(function() while sysCard.Parent do tw(ind,{BackgroundTransparency=0.4},0.8); task.wait(0.9); tw(ind,{BackgroundTransparency=0},0.8); task.wait(0.9) end end)
        lbl({Size=UDim2.new(0,120,1,0),Position=UDim2.new(0,12,0,0),Text=item.name,TextColor3=C.SUBTEXT,TextSize=9,Font=Enum.Font.Gotham,ZIndex=7},row)
        lbl({Size=UDim2.new(0,70,1,0),Position=UDim2.new(1,-72,0,0),Text=item.val,TextColor3=item.ok and C.GREEN or C.YELLOW,TextSize=9,Font=Enum.Font.GothamBold,ZIndex=7},row)
    end
    local actCard=bottomCard(0.333,2,"Quick Actions")
    local actGrid=frm({Size=UDim2.new(1,-12,1,-40),Position=UDim2.new(0,6,0,38),BackgroundTransparency=1,ZIndex=5},actCard)
    for i,a in ipairs({{icon="➕",label="Add User",sub="Whitelist"},{icon="🏷",label="Assign Tag",sub="HVC rank"},{icon="📤",label="Export",sub="Copy IDs"},{icon="⚙",label="Settings",sub="Toggles"},{icon="⌘",label="Commands",sub="Palette"},{icon="📋",label="Log",sub="Activity"}}) do
        local col=(i-1)%2; local row2=math.floor((i-1)/2)
        local btn=frm({Size=UDim2.new(0.5,-4,0,40),Position=UDim2.new(col*0.5,col>0 and 4 or 0,0,row2*44),BackgroundColor3=C.SURFACE,ZIndex=6},actGrid); corner(btn,8); stroke(btn,C.BORDER,1)
        lbl({Size=UDim2.new(0,22,0,22),Position=UDim2.new(0,6,0,4),Text=a.icon,TextSize=14,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=7},btn)
        lbl({Size=UDim2.new(1,-30,0,14),Position=UDim2.new(0,28,0,4),Text=a.label,TextColor3=C.TEXT,TextSize=9,Font=Enum.Font.GothamBold,ZIndex=7},btn)
        lbl({Size=UDim2.new(1,-30,0,12),Position=UDim2.new(0,28,0,18),Text=a.sub,TextColor3=C.SUBTEXT,TextSize=8,Font=Enum.Font.Gotham,ZIndex=7},btn)
        local cl=tbtn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=8},btn)
        cl.MouseEnter:Connect(function() tw(btn,{BackgroundColor3=C.CARD2}) end)
        cl.MouseLeave:Connect(function() tw(btn,{BackgroundColor3=C.SURFACE}) end)
        cl.MouseButton1Click:Connect(function() tw(btn,{BackgroundColor3=C.ACCENTDIM}); task.delay(0.15,function() tw(btn,{BackgroundColor3=C.SURFACE}) end) end)
    end
    frm({Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,ZIndex=4},homeInner)
end
buildHomeTab()

-- (Whitelist tab removed in v2.2)

-- ══════════════════════════════════════════
--  TAB: PLAYER
-- ══════════════════════════════════════════
local function buildPlayerTab()
    local plInner=newTabPage("player")
    sectionHeader(plInner,"Player Controls")
    local plToggles=frm({Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=4},plInner); listLayout(plToggles,6)
    makeToggle(plToggles,"Speed Boost","Increase walk/run speed",false,function(isOn)
        speedOn=isOn
        if isOn then
            applySpeed()
            if speedConn then speedConn:Disconnect() end
            speedConn=LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5); if speedOn then applySpeed() end end)
        else resetSpeed(); if speedConn then speedConn:Disconnect(); speedConn=nil end end
    end)
    makeToggle(plToggles,"Fly","Enables player flight",false,function(isOn)
        flyOn=isOn
        if isOn then
            enableFly()
            if flyCharConn then flyCharConn:Disconnect() end
            flyCharConn=LocalPlayer.CharacterAdded:Connect(function()
                task.wait(0.5); if flyOn then enableFly() end
            end)
        else
            disableFly()
            if flyCharConn then flyCharConn:Disconnect(); flyCharConn=nil end
        end
    end)
    makeToggle(plToggles,"Noclip","Phase through walls and terrain",false,function(isOn)
        noclipOn=isOn; if isOn then enableNoclip() else disableNoclip() end
    end)
    makeToggle(plToggles,"Invisibility","Make local character transparent",false,function(isOn)
        invisOn=isOn
        if isOn then
            enableInvisibility()
            if invisCharConn then invisCharConn:Disconnect() end
            invisCharConn=LocalPlayer.CharacterAdded:Connect(function()
                task.wait(0.5); if invisOn then enableInvisibility() end
            end)
        else
            disableInvisibility()
        end
    end)
    makeToggle(plToggles,"Infinite Jump","Allow jumping in mid-air",false,function(isOn)
        if isOn then enableInfJump() else disableInfJump() end
    end)
    makeToggle(plToggles,"Anti-AFK","Prevents auto-kick from inactivity",true,function(isOn)
        if isOn then enableAntiAFK() else disableAntiAFK() end
    end)
    makeToggle(plToggles,"Fullbright","Forces max ambient lighting",false,function(isOn)
        if isOn then enableFullbright() else disableFullbright() end
    end)
    sectionHeader(plInner,"Tuning")
    local plSliders=frm({Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=4},plInner); listLayout(plSliders,6)
    makeSlider(plSliders,"Walk Speed","Default: 16",16,200,16,function(val)
        speedVal=val; if speedOn then applySpeed() end
    end)
    makeSlider(plSliders,"Jump Power","Default: 50",50,400,50,function(val)
        jumpPowerVal=val
        local char=LocalPlayer.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower=val end
    end)
    makeSlider(plSliders,"Fly Speed","Units per second",10,300,60,function(val) FLY_SPEED=val end)
    frm({Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,ZIndex=4},plInner)
end
buildPlayerTab()

-- ══════════════════════════════════════════
--  TAB: VISUAL / AIMBOT+ESP
-- ══════════════════════════════════════════
local aimbotPopup = nil

local function buildAimbotTab()
    local vsInner=newTabPage("aimbot")

    local aimbotOn=false; local aimbotConn=nil; local aimbotFOV=120
    local aimbotSmooth=0.15; local aimbotPred=0.08; local aimbotBone="Head"
    local aimbotFOVColor=Color3.fromRGB(255,255,255)
    local cam2=workspace.CurrentCamera

    local fovSg=Instance.new("ScreenGui"); fovSg.Name="Havoc_FOV"
    fovSg.ResetOnSpawn=false; fovSg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    fovSg.Parent=LocalPlayer.PlayerGui
    local fovCircle2=Instance.new("Frame"); fovCircle2.BackgroundTransparency=1
    fovCircle2.BorderSizePixel=0; fovCircle2.ZIndex=10; fovCircle2.Visible=false; fovCircle2.Parent=fovSg
    local fovStr2=Instance.new("UIStroke"); fovStr2.Color=Color3.fromRGB(255,255,255)
    fovStr2.Thickness=2; fovStr2.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; fovStr2.Parent=fovCircle2
    Instance.new("UICorner",fovCircle2).CornerRadius=UDim.new(1,0)
    local fovVisible2=true
    RunService.RenderStepped:Connect(function()
        if fovCircle2.Visible then
            local vp=cam2.ViewportSize
            fovCircle2.Size=UDim2.new(0,aimbotFOV*2,0,aimbotFOV*2)
            fovCircle2.Position=UDim2.new(0,vp.X/2-aimbotFOV,0,vp.Y/2-aimbotFOV)
        end
    end)

    local teamCheckOn=false
    local function isSameTeam(p)
        if not teamCheckOn then return false end
        if not LocalPlayer.Team or not p.Team then return false end
        return LocalPlayer.Team==p.Team
    end
    local triggerbotOn=false; local triggerbotConn=nil

    local function getBestTarget()
        local vp=cam2.ViewportSize; local cx,cy=vp.X/2,vp.Y/2; local best,bestDist=nil,math.huge
        for _,p in pairs(Players:GetPlayers()) do
            if p==LocalPlayer or not p.Character then continue end
            if isSameTeam(p) then continue end
            local bone=p.Character:FindFirstChild(aimbotBone); if not bone then continue end
            local hum=p.Character:FindFirstChildOfClass("Humanoid"); if hum and hum.Health<=0 then continue end
            local hrpv=p.Character:FindFirstChild("HumanoidRootPart")
            local vel=hrpv and hrpv.AssemblyLinearVelocity or Vector3.new()
            local predicted=bone.Position+vel*aimbotPred
            local sp,onScreen=cam2:WorldToViewportPoint(predicted); if not onScreen then continue end
            local dx=sp.X-cx; local dy=sp.Y-cy; local dist=math.sqrt(dx*dx+dy*dy)
            if dist<aimbotFOV and dist<bestDist then bestDist=dist; best=predicted end
        end
        return best
    end

    local abTrackW=38
    local abOnBtn=nil; local abTrackRef=nil; local abThumbRef=nil

    local function syncAimbotUI()
        if abOnBtn then
            if aimbotOn then tw(abOnBtn,{BackgroundColor3=Color3.fromRGB(10,40,20)}); abOnBtn.TextColor3=C.GREEN; abOnBtn.Text="Aimbot: ON"
            else tw(abOnBtn,{BackgroundColor3=C.CARD}); abOnBtn.TextColor3=C.TEXT; abOnBtn.Text="Aimbot: OFF" end
        end
        if abTrackRef and abThumbRef then
            if aimbotOn then tw(abTrackRef,{BackgroundColor3=C.ACCENT}); tw(abThumbRef,{Position=UDim2.new(0,abTrackW-17,0.5,-7)})
            else tw(abTrackRef,{BackgroundColor3=C.MUTED}); tw(abThumbRef,{Position=UDim2.new(0,3,0.5,-7)}) end
        end
    end

    local function enableAimbot()
        aimbotOn=true
        aimbotConn=RunService.RenderStepped:Connect(function(dt)
            if not aimbotOn then return end
            local t=getBestTarget(); if not t then return end
            local alpha=math.clamp(dt*(1/(aimbotSmooth+0.01))*8,0,1)
            cam2.CFrame=cam2.CFrame:Lerp(CFrame.new(cam2.CFrame.Position,t),alpha)
        end)
        fovCircle2.Visible=fovVisible2; syncAimbotUI()
    end
    local function disableAimbot()
        aimbotOn=false
        if aimbotConn then aimbotConn:Disconnect(); aimbotConn=nil end
        fovCircle2.Visible=false; syncAimbotUI()
    end
    local function enableTriggerbot()
        triggerbotOn=true
        triggerbotConn=RunService.Heartbeat:Connect(function()
            if not triggerbotOn then return end
            local vp=cam2.ViewportSize; local ray=cam2:ScreenPointToRay(vp.X/2,vp.Y/2)
            local params=RaycastParams.new()
            params.FilterDescendantsInstances={LocalPlayer.Character or workspace}
            params.FilterType=Enum.RaycastFilterType.Exclude
            local result=workspace:Raycast(ray.Origin,ray.Direction*1000,params)
            if result and result.Instance then
                local charv=result.Instance:FindFirstAncestorOfClass("Model")
                if charv then
                    local p2=Players:GetPlayerFromCharacter(charv)
                    if p2 and p2~=LocalPlayer and not isSameTeam(p2) then
                        local hum=charv:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health>0 then pcall(function() mouse1click() end); task.wait(0.05) end
                    end
                end
            end
        end)
    end
    local function disableTriggerbot()
        triggerbotOn=false
        if triggerbotConn then triggerbotConn:Disconnect(); triggerbotConn=nil end
    end

    -- Floating aimbot popup window
    local abSg=Instance.new("ScreenGui"); abSg.Name="Havoc_Aimbot"
    abSg.ResetOnSpawn=false; abSg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    abSg.Parent=LocalPlayer.PlayerGui
    local abW,abH=220,460
    local abWin=frm({Size=UDim2.new(0,abW,0,abH),Position=UDim2.new(0.5,20,0.5,-abH/2),BackgroundColor3=C.SURFACE,Visible=false,ZIndex=20},abSg)
    corner(abWin,12); stroke(abWin,C.BORDER2,1)
    frm({Size=UDim2.new(1,0,0,60),BackgroundColor3=C.ACCENT,BackgroundTransparency=0.94},abWin)
    local abtb=frm({Size=UDim2.new(1,0,0,38),BackgroundColor3=C.TOPBAR,ZIndex=20},abWin); corner(abtb,12)
    frm({Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-12),BackgroundColor3=C.TOPBAR,ZIndex=20},abtb)
    frm({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.ACCENT},abtb)
    frm({Size=UDim2.new(0,3,0,14),Position=UDim2.new(0,0,0.5,-7),BackgroundColor3=C.ACCENT,ZIndex=21},abtb)
    lbl({Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,12,0,0),Text="Aimbot",TextColor3=C.WHITE,TextSize=13,Font=Enum.Font.GothamBold,ZIndex=21},abtb)
    local abClose=tbtn({Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-28,0.5,-11),BackgroundColor3=C.WHITE,BackgroundTransparency=1,TextColor3=C.WHITE,TextSize=10,Text="X",Font=Enum.Font.GothamBold,ZIndex=21},abtb); corner(abClose,11)
    local abcs=Instance.new("UIStroke"); abcs.Color=Color3.fromRGB(180,180,180); abcs.Thickness=1.5; abcs.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; abcs.Parent=abClose
    abClose.MouseEnter:Connect(function() tw(abClose,{BackgroundTransparency=0.82}); tw(abcs,{Color=C.WHITE}) end)
    abClose.MouseLeave:Connect(function() tw(abClose,{BackgroundTransparency=1}); tw(abcs,{Color=Color3.fromRGB(180,180,180)}) end)
    abClose.MouseButton1Click:Connect(function() abWin.Visible=false end)
    local abDrag,abDS,abSP=false,nil,nil
    abtb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then abDrag=true; abDS={Mouse.X,Mouse.Y}; abSP={abWin.Position.X.Offset,abWin.Position.Y.Offset} end end)
    abtb.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then abDrag=false end end)
    RunService.RenderStepped:Connect(function() if abDrag then abWin.Position=UDim2.new(0,abSP[1]+Mouse.X-abDS[1],0,abSP[2]+Mouse.Y-abDS[2]) end end)

    abOnBtn=tbtn({Size=UDim2.new(1,-16,0,36),Position=UDim2.new(0,8,0,46),BackgroundColor3=C.CARD,TextColor3=C.TEXT,TextSize=12,Text="Aimbot: OFF",Font=Enum.Font.GothamBold,ZIndex=21},abWin)
    corner(abOnBtn,8); stroke(abOnBtn,C.BORDER2,1)
    abOnBtn.MouseButton1Click:Connect(function()
        if aimbotOn then disableAimbot() else enableAimbot() end
    end)

    local function abSlider(yOff,label,minV,maxV,initV,dec,onChange)
        local fmt=dec==0 and "%d" or "%.2f"
        local vl=lbl({Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,8,0,yOff),Text=label..": "..string.format(fmt,initV),TextColor3=C.SUBTEXT,TextSize=9,Font=Enum.Font.GothamBold,ZIndex=21},abWin)
        local tr=frm({Size=UDim2.new(1,-16,0,8),Position=UDim2.new(0,8,0,yOff+16),BackgroundColor3=C.MUTED,ZIndex=21},abWin); corner(tr,4)
        local p0=(initV-minV)/(maxV-minV)
        local fi=frm({Size=UDim2.new(p0,0,1,0),BackgroundColor3=C.ACCENT,ZIndex=22},tr); corner(fi,4)
        local th=frm({Size=UDim2.new(0,14,0,14),Position=UDim2.new(p0,-7,0.5,-7),BackgroundColor3=C.WHITE,ZIndex=23},tr); corner(th,7)
        local dragS=false
        local function upd(px)
            local pct=math.clamp((px-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
            local val=minV+(maxV-minV)*pct; if dec==0 then val=math.floor(val) end
            fi.Size=UDim2.new(pct,0,1,0); th.Position=UDim2.new(pct,-7,0.5,-7)
            vl.Text=label..": "..string.format(fmt,val); onChange(val)
        end
        tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragS=true; upd(Mouse.X) end end)
        th.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragS=true end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragS=false end end)
        RunService.RenderStepped:Connect(function() if dragS then upd(Mouse.X) end end)
    end
    abSlider(90,"FOV Size",20,400,120,0,function(v) aimbotFOV=v end)
    abSlider(128,"Smoothness",0,0.98,0.15,2,function(v) aimbotSmooth=v end)
    abSlider(166,"Prediction",0,0.3,0.08,2,function(v) aimbotPred=v end)

    local fovShowBtn=tbtn({Size=UDim2.new(1,-16,0,28),Position=UDim2.new(0,8,0,208),BackgroundColor3=Color3.fromRGB(10,40,20),TextColor3=C.GREEN,TextSize=10,Text="FOV Circle: Visible",Font=Enum.Font.GothamBold,ZIndex=21},abWin)
    corner(fovShowBtn,7); stroke(fovShowBtn,C.GREEN,1,0.4)
    fovShowBtn.MouseButton1Click:Connect(function()
        fovVisible2=not fovVisible2
        if aimbotOn then fovCircle2.Visible=fovVisible2 end
        if fovVisible2 then tw(fovShowBtn,{BackgroundColor3=Color3.fromRGB(10,40,20)}); fovShowBtn.TextColor3=C.GREEN; fovShowBtn.Text="FOV Circle: Visible"
        else tw(fovShowBtn,{BackgroundColor3=C.CARD}); fovShowBtn.TextColor3=C.SUBTEXT; fovShowBtn.Text="FOV Circle: Hidden" end
    end)
    lbl({Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,8,0,244),Text="FOV COLOR",TextColor3=C.SUBTEXT,TextSize=8,Font=Enum.Font.GothamBold,ZIndex=21},abWin)
    local colorPresets={{Color3.fromRGB(220,38,38),"Red"},{Color3.fromRGB(52,210,100),"Green"},{Color3.fromRGB(0,180,220),"Cyan"},{Color3.fromRGB(240,185,30),"Yellow"},{Color3.fromRGB(180,50,255),"Purple"},{Color3.fromRGB(255,255,255),"White"}}
    for ci,preset in ipairs(colorPresets) do
        local cx2=8+((ci-1)%6)*((abW-16)/6)
        local swatch=tbtn({Size=UDim2.new(0,math.floor((abW-24)/6),0,20),Position=UDim2.new(0,cx2,0,262),BackgroundColor3=preset[1],Text="",ZIndex=21},abWin); corner(swatch,4)
        swatch.MouseButton1Click:Connect(function() aimbotFOVColor=preset[1]; fovStr2.Color=preset[1] end)
    end
    lbl({Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,8,0,294),Text="TARGET BONE",TextColor3=C.SUBTEXT,TextSize=8,Font=Enum.Font.GothamBold,ZIndex=21},abWin)
    local bones={"Head","HumanoidRootPart","UpperTorso"}; local boneIdx=1
    local boneLbl2=lbl({Size=UDim2.new(1,-56,0,24),Position=UDim2.new(0,8,0,312),Text="Head",TextColor3=C.TEXT,TextSize=11,Font=Enum.Font.GothamBold,ZIndex=21},abWin)
    local boneBtn=tbtn({Size=UDim2.new(0,44,0,24),Position=UDim2.new(1,-52,0,312),BackgroundColor3=C.CARD,TextColor3=C.ACCENT,TextSize=9,Text="Next",Font=Enum.Font.GothamBold,ZIndex=21},abWin)
    corner(boneBtn,6); stroke(boneBtn,C.BORDER2,1)
    boneBtn.MouseButton1Click:Connect(function() boneIdx=boneIdx%#bones+1; aimbotBone=bones[boneIdx]; boneLbl2.Text=bones[boneIdx] end)
    local tbOnBtn=tbtn({Size=UDim2.new(1,-16,0,30),Position=UDim2.new(0,8,0,346),BackgroundColor3=C.CARD,TextColor3=C.TEXT,TextSize=11,Text="Triggerbot: OFF",Font=Enum.Font.GothamBold,ZIndex=21},abWin)
    corner(tbOnBtn,7); stroke(tbOnBtn,C.BORDER2,1)
    tbOnBtn.MouseButton1Click:Connect(function()
        if triggerbotOn then disableTriggerbot(); tw(tbOnBtn,{BackgroundColor3=C.CARD}); tbOnBtn.TextColor3=C.TEXT; tbOnBtn.Text="Triggerbot: OFF"
        else enableTriggerbot(); tw(tbOnBtn,{BackgroundColor3=Color3.fromRGB(10,40,20)}); tbOnBtn.TextColor3=C.GREEN; tbOnBtn.Text="Triggerbot: ON" end
    end)
    local tcBtn=tbtn({Size=UDim2.new(1,-16,0,30),Position=UDim2.new(0,8,0,384),BackgroundColor3=C.CARD,TextColor3=C.TEXT,TextSize=11,Text="Team Check: OFF",Font=Enum.Font.GothamBold,ZIndex=21},abWin)
    corner(tcBtn,7); stroke(tcBtn,C.BORDER2,1)
    tcBtn.MouseButton1Click:Connect(function()
        teamCheckOn=not teamCheckOn
        if teamCheckOn then tw(tcBtn,{BackgroundColor3=Color3.fromRGB(10,40,20)}); tcBtn.TextColor3=C.GREEN; tcBtn.Text="Team Check: ON"
        else tw(tcBtn,{BackgroundColor3=C.CARD}); tcBtn.TextColor3=C.TEXT; tcBtn.Text="Team Check: OFF" end
    end)

    -- B keybind toggles aimbot
    UserInputService.InputBegan:Connect(function(i,gpe)
        if gpe or UserInputService:GetFocusedTextBox() then return end
        if i.KeyCode==Enum.KeyCode.B then
            if aimbotOn then disableAimbot() else enableAimbot() end
        end
    end)

    aimbotPopup=abWin

    -- Aimbot tab page: toggle row + panel button
    sectionHeader(vsInner,"Aimbot")
    local abRow=frm({Size=UDim2.new(1,0,0,48),BackgroundColor3=C.CARD,ZIndex=5},vsInner)
    corner(abRow,8); stroke(abRow,C.BORDER,1)
    frm({Size=UDim2.new(0,3,0,28),Position=UDim2.new(0,0,0.5,-14),BackgroundColor3=C.ACCENT,ZIndex=6},abRow)
    lbl({Size=UDim2.new(1,-160,0,16),Position=UDim2.new(0,12,0,8),Text="Aimbot",TextColor3=C.TEXT,TextSize=11,Font=Enum.Font.GothamBold,ZIndex=6},abRow)
    lbl({Size=UDim2.new(1,-160,0,12),Position=UDim2.new(0,12,0,26),Text="FOV lock \xc2\xb7 Smooth \xc2\xb7 Prediction \xc2\xb7 Triggerbot",TextColor3=C.SUBTEXT,TextSize=8,Font=Enum.Font.Gotham,ZIndex=6},abRow)
    local abTrack=frm({Size=UDim2.new(0,abTrackW,0,20),Position=UDim2.new(1,-abTrackW-90,0.5,-10),BackgroundColor3=C.MUTED,ZIndex=6},abRow); corner(abTrack,10)
    local abThumb=frm({Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,3,0.5,-7),BackgroundColor3=C.WHITE,ZIndex=7},abTrack); corner(abThumb,7)
    abTrackRef=abTrack; abThumbRef=abThumb
    local abOpenBtn=tbtn({Size=UDim2.new(0,72,0,28),Position=UDim2.new(1,-82,0.5,-14),BackgroundColor3=C.ACCENTDIM,TextColor3=C.ACCENTHI,TextSize=9,Text="\xe2\x9a\x99 Panel",Font=Enum.Font.GothamBold,ZIndex=7},abRow)
    corner(abOpenBtn,6); stroke(abOpenBtn,C.ACCENT,1,0.5)
    abOpenBtn.MouseEnter:Connect(function() tw(abOpenBtn,{BackgroundColor3=C.ACCENT,TextColor3=C.WHITE}) end)
    abOpenBtn.MouseLeave:Connect(function() tw(abOpenBtn,{BackgroundColor3=C.ACCENTDIM,TextColor3=C.ACCENTHI}) end)
    abOpenBtn.MouseButton1Click:Connect(function()
        if abWin.Visible then abWin.Visible=false
        else abWin.Visible=true; tw(abWin,{Position=UDim2.new(0.5,20,0.5,-abH/2)},0.18,Enum.EasingStyle.Back) end
    end)
    local abToggleHit=tbtn({Size=UDim2.new(0,abTrackW+6,0,30),Position=UDim2.new(1,-abTrackW-93,0.5,-15),BackgroundTransparency=1,Text="",ZIndex=8},abRow)
    abToggleHit.MouseButton1Click:Connect(function()
        if aimbotOn then disableAimbot() else enableAimbot() end
    end)
    abRow.MouseEnter:Connect(function() tw(abRow,{BackgroundColor3=C.CARD2}) end)
    abRow.MouseLeave:Connect(function() tw(abRow,{BackgroundColor3=C.CARD}) end)
    frm({Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,ZIndex=4},vsInner)
end
buildAimbotTab()

-- ══════════════════════════════════════════
--  TAB: VISUAL (ESP only)
-- ══════════════════════════════════════════
local function buildVisualTab()
    local vsInner=newTabPage("visual")
    sectionHeader(vsInner,"ESP")
    local vsToggles=frm({Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=4},vsInner); listLayout(vsToggles,6)
    makeToggle(vsToggles,"ESP \xe2\x80\x94 Through-wall","Highlight players through walls",false,function(isOn)
        espOn=isOn; if isOn then enableESP() else disableESP() end
    end)
    makeToggle(vsToggles,"ESP \xe2\x80\x94 Health Bars","Show HP bars above characters",false)
    makeToggle(vsToggles,"ESP \xe2\x80\x94 Distance","Show distance label per player",false,function(isOn)
        if isOn then
            task.spawn(function()
                while isOn and sg.Parent do
                    for _,p in ipairs(Players:GetPlayers()) do
                        if p~=LocalPlayer and p.Character then
                            local hrpv=p.Character:FindFirstChild("HumanoidRootPart")
                            local myHRP=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrpv and myHRP then
                                local dist=math.floor((hrpv.Position-myHRP.Position).Magnitude)
                                local bb=hrpv:FindFirstChild("ESP_BB")
                                if bb then
                                    local dl=bb:FindFirstChild("DistLbl") or Instance.new("TextLabel",bb)
                                    dl.Name="DistLbl"; dl.Size=UDim2.new(1,0,1,0); dl.Position=UDim2.new(0,0,0.5,0)
                                    dl.BackgroundTransparency=1; dl.TextSize=9; dl.Font=Enum.Font.Gotham
                                    dl.TextColor3=C.CYAN; dl.TextXAlignment=Enum.TextXAlignment.Center
                                    dl.Text=dist.."m"
                                end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end)
    makeToggle(vsToggles,"ESP \xe2\x80\x94 Team Color","Color ESP by team color",true,function(isOn)
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character then
                local hl=p.Character:FindFirstChildOfClass("Highlight")
                if hl then hl.OutlineColor=isOn and (p.TeamColor and p.TeamColor.Color or C.CYAN) or C.ACCENT end
            end
        end
    end)
    makeToggle(vsToggles,"Chams","Surface color override on characters",false,function(isOn)
        if isOn then enableChams() else disableChams() end
    end)
    makeToggle(vsToggles,"Tracers","Draw line from screen-bottom to players",false,function(isOn)
        if isOn then enableTracers() else disableTracers() end
    end)
    makeToggle(vsToggles,"FOV Circle","Show targeting radius circle",false,function(isOn)
        if isOn then enableFovCircle() else disableFovCircle() end
    end)
    makeToggle(vsToggles,"Fullbright","Maximize scene ambient brightness",false,function(isOn)
        if isOn then enableFullbright() else disableFullbright() end
    end)
    makeToggle(vsToggles,"Nametag Overlay","HVC rank nametags above characters",true)
    makeToggle(vsToggles,"Baseplate Color Override","Override baseplate colour",false)
    sectionHeader(vsInner,"Visual Tuning")
    local vsTuning=frm({Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=4},vsInner); listLayout(vsTuning,6)
    makeSlider(vsTuning,"FOV Circle Radius","Screen-space radius in pixels",50,600,120,function(val)
        FOV_RADIUS=val
        if fovCircleEnabled and fovCircleFrame then fovCircleFrame.Size=UDim2.new(0,FOV_RADIUS*2,0,FOV_RADIUS*2) end
    end)
    makeSlider(vsTuning,"ESP Text Size","Label font size",8,24,13,function(val)
        ESP_TEXT_SIZE=val
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local hrpv=p.Character:FindFirstChild("HumanoidRootPart"); if not hrpv then return end
                local bb=hrpv:FindFirstChild("ESP_BB")
                if bb then for _,l in ipairs(bb:GetDescendants()) do if l:IsA("TextLabel") then l.TextSize=val end end end
            end
        end
    end)
    makeSlider(vsTuning,"Tracer Thickness","Line thickness",1,8,2,function(val) TRACER_THICKNESS=val end)
    frm({Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,ZIndex=4},vsInner)
end
buildVisualTab()

-- ══════════════════════════════════════════
--  TAB: TARGET
-- ══════════════════════════════════════════
local function buildTargetTab()
    local tgInner=newTabPage("target")
    local tb_currentTarget=nil
    local tb_backpackActive=false
    local tb_followActive=false
    local tb_spectateActive=false
    local tb_backpackConn=nil
    local tb_headsitConn=nil
    local tb_dynColor=C.NEUTRAL
    local tb_dynElements={}

    local function tb_registerDyn(obj,prop) table.insert(tb_dynElements,{obj=obj,prop=prop}) end
    local function tb_applyDynColor(color)
        tb_dynColor=color or C.NEUTRAL
        for _,e in ipairs(tb_dynElements) do pcall(function() e.obj[e.prop]=tb_dynColor end) end
    end

    local board=frm({Size=UDim2.new(1,0,0,470),BackgroundColor3=C.BG,ClipsDescendants=true,ZIndex=5},tgInner)
    local bc=Instance.new("UICorner"); bc.CornerRadius=UDim.new(0,14); bc.Parent=board
    stroke(board,C.BORDER,1.2)

    local listPane = frm({Size=UDim2.new(0.35,0,1,0), BackgroundColor3=C.SURFACE, ZIndex=6}, board, "SURFACE")
    stroke(listPane, C.BORDER, 1.2, 0, "BORDER")

    local detailPane = frm({Size=UDim2.new(0.65,0,1,0), Position=UDim2.new(0.35,0,0,0), BackgroundTransparency=1, ZIndex=6}, board)

    local stringLayer=frm({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=7},detailPane)
    local stringFrames={}

    local tbBar=frm({Size=UDim2.new(1,0,0,44),BackgroundColor3=C.TOPBAR,BackgroundTransparency=0.08,ZIndex=20},detailPane)
    local tbc=Instance.new("UICorner"); tbc.CornerRadius=UDim.new(0,14); tbc.Parent=tbBar
    frm({Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),BackgroundColor3=Color3.fromRGB(8,7,10),BackgroundTransparency=0.08,ZIndex=20},tbBar)
    stroke(tbBar,C.BORDER,1)
    local tbAccentDot=frm({Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,12,0.5,-3),BackgroundColor3=tb_dynColor,ZIndex=21},tbBar); corner(tbAccentDot,2); tb_registerDyn(tbAccentDot,"BackgroundColor3")
    lbl({Size=UDim2.new(0,140,1,0),Position=UDim2.new(0,22,0,0),Text="TARGET BOARD",TextColor3=C.TEXT,TextSize=11,Font=Enum.Font.GothamBold,ZIndex=21},tbBar)
    local tbCaseLabel=lbl({Size=UDim2.new(1,-300,1,0),Position=UDim2.new(0,165,0,0),Text="CASE #0001 — HAVOC INTEL",TextColor3=C.SUBTEXT,TextSize=9,Font=Enum.Font.Gotham,ZIndex=21},tbBar)
    local tbStatusFrame=frm({Size=UDim2.new(0,90,0,20),Position=UDim2.new(1,-102,0.5,-10),BackgroundColor3=C.MUTED,ZIndex=21},tbBar); corner(tbStatusFrame,5)
    local tbStatusStroke=stroke(tbStatusFrame,C.BORDER,1)
    local tbStatusLabel=lbl({Size=UDim2.new(1,0,1,0),Text="NO TARGET",TextColor3=C.SUBTEXT,TextSize=8,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=22},tbStatusFrame)

    local searchBox2=frm({Size=UDim2.new(1,-24,0,36),Position=UDim2.new(0,12,0,12),BackgroundColor3=C.CARD,ZIndex=21},listPane); corner(searchBox2,10)
    local searchStroke=stroke(searchBox2,C.BORDER,1.2)
    lbl({Size=UDim2.new(0,20,1,0),Position=UDim2.new(0,10,0,0),Text="🔍",TextColor3=C.SUBTEXT,TextSize=12,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=22},searchBox2)
    local searchInput=Instance.new("TextBox"); searchInput.Size=UDim2.new(1,-40,1,-8); searchInput.Position=UDim2.new(0,34,0,4)
    searchInput.BackgroundTransparency=1; searchInput.BorderSizePixel=0; searchInput.PlaceholderText="Search..."
    searchInput.PlaceholderColor3=C.SUBTEXT; searchInput.TextColor3=C.TEXT; searchInput.TextSize=11; searchInput.Font=Enum.Font.Gotham
    searchInput.ClearTextOnFocus=false; searchInput.ZIndex=22; searchInput.Parent=searchBox2

    local pillsFrame=frm({Size=UDim2.new(1,-24,1,-64),Position=UDim2.new(0,12,0,56),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=20},listPane)
    local pillsScroll = scroll(pillsFrame, UDim2.new(1,0,1,0))
    local pillsInner=frm({Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=20},pillsScroll)
    listLayout(pillsInner, 6)

    local dropdownFrame=frm({Size=UDim2.new(0,190,0,0),Position=UDim2.new(0,12,0,82),BackgroundColor3=C.SURFACE,AutomaticSize=Enum.AutomaticSize.Y,Visible=false,ZIndex=50,ClipsDescendants=false},board)
    corner(dropdownFrame,7); stroke(dropdownFrame,C.BORDER2,1)
    local dropInner=frm({Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=50},dropdownFrame)
    local dropLayout=Instance.new("UIListLayout"); dropLayout.SortOrder=Enum.SortOrder.LayoutOrder; dropLayout.Padding=UDim.new(0,0); dropLayout.Parent=dropInner
    local comingSoonRow=frm({Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,ZIndex=51},dropInner)
    frm({Size=UDim2.new(1,0,0,1),BackgroundColor3=C.BORDER,ZIndex=51},comingSoonRow)
    lbl({Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,10,0,0),Text="Join any server — coming soon",TextColor3=C.SUBTEXT,TextSize=8,Font=Enum.Font.Gotham,ZIndex=52},comingSoonRow)

    local function makeDropRow(name,userId)
        local row=frm({Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,ZIndex=51},dropInner)
        local dot=frm({Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,8,0.5,-3),BackgroundColor3=tb_dynColor,ZIndex=52},row); corner(dot,3); tb_registerDyn(dot,"BackgroundColor3")
        lbl({Size=UDim2.new(1,-80,1,0),Position=UDim2.new(0,20,0,0),Text=name,TextColor3=C.TEXT,TextSize=10,Font=Enum.Font.GothamBold,ZIndex=52},row)
        lbl({Size=UDim2.new(0,60,1,0),Position=UDim2.new(1,-62,0,0),Text="ID:"..userId,TextColor3=C.SUBTEXT,TextSize=8,Font=Enum.Font.Gotham,ZIndex=52},row)
        local cl=tbtn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=53},row)
        cl.MouseEnter:Connect(function() tw(row,{BackgroundTransparency=0,BackgroundColor3=C.CARD2}) end)
        cl.MouseLeave:Connect(function() tw(row,{BackgroundTransparency=1}) end)
        return row,cl
    end

    local avatarWrap=frm({Size=UDim2.new(0,116,0,172),Position=UDim2.new(0.5,-58,0,148),BackgroundTransparency=1,ZIndex=10},detailPane)
    local avatarFrame=frm({Size=UDim2.new(0,116,0,138),BackgroundColor3=Color3.fromRGB(10,9,13),ClipsDescendants=true,ZIndex=10},avatarWrap)
    local avc=Instance.new("UICorner"); avc.CornerRadius=UDim.new(0,10); avc.Parent=avatarFrame
    local avatarStroke=stroke(avatarFrame,tb_dynColor,2); tb_registerDyn(avatarStroke,"Color")
    local centerPin=frm({Size=UDim2.new(0,11,0,11),Position=UDim2.new(0.5,-5.5,0,-5),BackgroundColor3=tb_dynColor,ZIndex=16},avatarFrame); corner(centerPin,6); tb_registerDyn(centerPin,"BackgroundColor3")
    frm({Size=UDim2.new(0,4,0,4),Position=UDim2.new(0,2,0,2),BackgroundColor3=C.WHITE,BackgroundTransparency=0.65,ZIndex=17},centerPin)
    frm({Size=UDim2.new(0,34,0,13),Position=UDim2.new(0.5,-17,0,-5),BackgroundColor3=Color3.fromRGB(210,185,140),BackgroundTransparency=0.78,ZIndex=15},avatarFrame)
    local loadRing=frm({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=18},avatarFrame)
    local loadStroke=stroke(loadRing,tb_dynColor,2); loadRing.Visible=false; tb_registerDyn(loadStroke,"Color")
    task.spawn(function()
        local angle=0
        while sg.Parent do
            if loadRing.Visible then angle=(angle+3)%360; loadStroke.Transparency=0.3+0.3*math.abs(math.sin(math.rad(angle))) end
            task.wait(0.03)
        end
    end)
    local avatarPH=frm({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=11},avatarFrame)
    lbl({Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.1,0),Text="◈",TextColor3=Color3.fromRGB(20,18,24),TextSize=32,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=12},avatarPH)
    lbl({Size=UDim2.new(1,-12,0.4,0),Position=UDim2.new(0,6,0.52,0),Text="NO TARGET\nSELECTED",TextColor3=Color3.fromRGB(24,22,30),TextSize=8,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Center,TextWrapped=true,ZIndex=12},avatarPH)
    local avatarImg=Instance.new("ImageLabel"); avatarImg.BackgroundTransparency=1; avatarImg.BorderSizePixel=0; avatarImg.Size=UDim2.new(1,0,1,0); avatarImg.Image=""; avatarImg.ScaleType=Enum.ScaleType.Crop; avatarImg.ZIndex=11; avatarImg.Visible=false; avatarImg.Parent=avatarFrame
    Instance.new("UICorner",avatarImg).CornerRadius=UDim.new(0,10)
    local statusStrip=frm({Size=UDim2.new(0,116,0,22),Position=UDim2.new(0,0,0,140),BackgroundColor3=Color3.fromRGB(8,7,10),ZIndex=10},avatarWrap); corner(statusStrip,6)
    local statusStroke=stroke(statusStrip,C.BORDER,1)
    local statusDot=frm({Size=UDim2.new(0,5,0,5),Position=UDim2.new(0,8,0.5,-2.5),BackgroundColor3=C.SUBTEXT,BackgroundTransparency=1,ZIndex=11},statusStrip); corner(statusDot,3)
    local statusLabel=lbl({Size=UDim2.new(1,-18,1,0),Position=UDim2.new(0,16,0,0),Text="— AWAITING TARGET —",TextColor3=C.SUBTEXT,TextSize=7.5,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=11},statusStrip)
    task.spawn(function()
        while sg.Parent do
            if statusDot.BackgroundTransparency<1 then tw(statusDot,{BackgroundTransparency=0.25},0.6); task.wait(0.7); tw(statusDot,{BackgroundTransparency=0},0.6); task.wait(0.7) else task.wait(0.5) end
        end
    end)
    local avatarNameLabel=lbl({Size=UDim2.new(0,160,0,18),Position=UDim2.new(0.5,-80,0,166),Text="—",TextColor3=tb_dynColor,TextSize=10,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=10},avatarWrap)
    tb_registerDyn(avatarNameLabel,"TextColor3")

    local function cornerNote(text,pos,align)
        return lbl({Size=UDim2.new(0,120,0,28),Position=pos,Text=text,TextColor3=Color3.fromRGB(40,38,50),TextSize=8,Font=Enum.Font.Gotham,TextXAlignment=align or Enum.TextXAlignment.Left,TextWrapped=true,ZIndex=3},detailPane)
    end
    local tbPingLabel=cornerNote("SERVER: #4412\nPING: —ms",UDim2.new(0,14,0,52),Enum.TextXAlignment.Left)
    local tbCornerTR=cornerNote("TARGET: NONE\nUID: —",UDim2.new(1,-134,0,52),Enum.TextXAlignment.Right)
    cornerNote("HAVOC v2.4\nINTEL BOARD",UDim2.new(0,14,1,-42),Enum.TextXAlignment.Left)
    local tbPlayersLbl=cornerNote("PLAYERS: —\nSTATUS: LIVE",UDim2.new(1,-134,1,-42),Enum.TextXAlignment.Right)
    task.spawn(function()
        while sg.Parent do
            tbPlayersLbl.Text="PLAYERS: "..#Players:GetPlayers().."\nSTATUS: LIVE"
            pcall(function()
                local ping=math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                tbPingLabel.Text="SERVER: #4412\nPING: "..ping.."ms"
            end)
            task.wait(2)
        end
    end)

    local PIN_CONFIGS={
        {id="tp",icon="📍",label="TELEPORT", sub="TP to target",     pos=UDim2.new(0.11,0,0.34,0),action="teleport"},
        {id="hs",icon="🪑",label="HEADSIT",  sub="Sit on their head",pos=UDim2.new(0.19,0,0.76,0),action="headsit"},
        {id="bp",icon="🎒",label="BACKPACK", sub="Mount on back",    pos=UDim2.new(0.50,0,0.90,0),action="backpack"},
        {id="ft",icon="🔗",label="FOLLOW TP",sub="Continuous follow",pos=UDim2.new(0.81,0,0.76,0),action="followtp"},
        {id="sp",icon="👻",label="SPECTATE", sub="Follow camera",    pos=UDim2.new(0.89,0,0.34,0),action="spectate"},
    }
    local pinNodes={}
    local function makePinNode(cfg)
        local nW,nH=92,78
        local wrap=frm({Size=UDim2.new(0,nW,0,nH),Position=UDim2.new(cfg.pos.X.Scale,-(nW/2),cfg.pos.Y.Scale,-(nH/2)),BackgroundTransparency=1,ZIndex=10},detailPane)
        local nail=frm({Size=UDim2.new(0,12,0,12),Position=UDim2.new(0.5,-6,0,0),BackgroundColor3=tb_dynColor,ZIndex=11},wrap); corner(nail,6); tb_registerDyn(nail,"BackgroundColor3")
        frm({Size=UDim2.new(0,4,0,4),Position=UDim2.new(0,2,0,2),BackgroundColor3=C.WHITE,BackgroundTransparency=0.65,ZIndex=12},nail)
        local card=frm({Size=UDim2.new(0,nW,0,nH-16),Position=UDim2.new(0,0,0,16),BackgroundColor3=Color3.fromRGB(10,9,13),ClipsDescendants=true,ZIndex=11},wrap); corner(card,10)
        local cardStroke=stroke(card,tb_dynColor,1); tb_registerDyn(cardStroke,"Color")
        frm({Size=UDim2.new(0.65,0,0,1),Position=UDim2.new(0.175,0,0,0),BackgroundColor3=tb_dynColor,BackgroundTransparency=0.5,ZIndex=12},card)
        local iconLbl=lbl({Size=UDim2.new(1,0,0,34),Position=UDim2.new(0,0,0,4),Text=cfg.icon,TextSize=21,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=12},card)
        local nameLbl=lbl({Size=UDim2.new(1,-4,0,14),Position=UDim2.new(0,2,0,38),Text=cfg.label,TextColor3=tb_dynColor,TextSize=9,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=12},card); tb_registerDyn(nameLbl,"TextColor3")
        lbl({Size=UDim2.new(1,-4,0,11),Position=UDim2.new(0,2,0,51),Text=cfg.sub,TextColor3=C.SUBTEXT,TextSize=7,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=12},card)
        local cl=tbtn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=13},card)
        cl.MouseEnter:Connect(function()
            tw(card,{BackgroundColor3=Color3.fromRGB(20,18,26)})
            tw(wrap,{Size=UDim2.new(0,nW+4,0,nH+4),Position=UDim2.new(cfg.pos.X.Scale,-(nW/2)-2,cfg.pos.Y.Scale,-(nH/2)-2)})
        end)
        cl.MouseLeave:Connect(function()
            tw(card,{BackgroundColor3=Color3.fromRGB(10,9,13)})
            tw(wrap,{Size=UDim2.new(0,nW,0,nH),Position=UDim2.new(cfg.pos.X.Scale,-(nW/2),cfg.pos.Y.Scale,-(nH/2))})
        end)
        local phase={tp=0,hs=1,bp=2,ft=3,sp=4}; local t=phase[cfg.id] or 0
        task.spawn(function() while wrap.Parent do wrap.Rotation=math.sin(tick()*0.8+t)*0.8; task.wait(0.03) end end)
        pinNodes[cfg.id]={wrap=wrap,card=card,nail=nail,cardStroke=cardStroke,nameLbl=nameLbl,iconLbl=iconLbl,action=cfg.action,cl=cl,cfg=cfg}
    end
    for _,cfg in ipairs(PIN_CONFIGS) do makePinNode(cfg) end

    local function redrawStrings(color)
        for _,f in ipairs(stringFrames) do if f and f.Parent then f:Destroy() end end
        stringFrames={}
        local col=color or C.NEUTRAL
        local bPos=detailPane.AbsolutePosition
        local avAbs=avatarFrame.AbsolutePosition; local avSize=avatarFrame.AbsoluteSize
        local ax=(avAbs.X+avSize.X/2)-bPos.X; local ay=(avAbs.Y+avSize.Y/2)-bPos.Y
        for _,cfg in ipairs(PIN_CONFIGS) do
            local node=pinNodes[cfg.id]
            if node then
                local nAbs=node.nail.AbsolutePosition; local nSz=node.nail.AbsoluteSize
                local px=(nAbs.X+nSz.X/2)-bPos.X; local py=(nAbs.Y+nSz.Y/2)-bPos.Y
                local dx=px-ax; local dy=py-ay; local len=math.sqrt(dx*dx+dy*dy)
                if len>=1 then
                    local ang=math.atan2(dy,dx)
                    local gl=frm({Size=UDim2.new(0,len,0,3),Position=UDim2.new(0,ax+dx/2-len/2,0,ay+dy/2-1.5),BackgroundColor3=col,BackgroundTransparency=0.82,Rotation=math.deg(ang),ZIndex=6},stringLayer); table.insert(stringFrames,gl)
                    local ml=frm({Size=UDim2.new(0,len,0,1),Position=UDim2.new(0,ax+dx/2-len/2,0,ay+dy/2-0.5),BackgroundColor3=col,BackgroundTransparency=0.5,Rotation=math.deg(ang),ZIndex=7},stringLayer); table.insert(stringFrames,ml)
                end
            end
        end
    end
    task.delay(0.2,function() redrawStrings(nil) end)

    local function tb_setStatus(sType,msg)
        if sType=="ok" then tw(statusStrip,{BackgroundColor3=Color3.fromRGB(8,18,12)}); tw(statusStroke,{Color=C.GREEN}); statusDot.BackgroundTransparency=0; tw(statusDot,{BackgroundColor3=C.GREEN}); tw(statusLabel,{TextColor3=C.GREEN})
        elseif sType=="err" then tw(statusStrip,{BackgroundColor3=Color3.fromRGB(18,8,8)}); tw(statusStroke,{Color=C.RED}); statusDot.BackgroundTransparency=0; tw(statusDot,{BackgroundColor3=C.RED}); tw(statusLabel,{TextColor3=C.RED})
        else tw(statusStrip,{BackgroundColor3=Color3.fromRGB(8,7,10)}); tw(statusStroke,{Color=C.BORDER}); statusDot.BackgroundTransparency=1; tw(statusLabel,{TextColor3=C.SUBTEXT}) end
        statusLabel.Text=msg
    end
    local function tb_setTopStatus(sType,msg)
        if sType=="ok" then tw(tbStatusFrame,{BackgroundColor3=Color3.fromRGB(8,18,12)}); tw(tbStatusStroke,{Color=C.GREEN}); tw(tbStatusLabel,{TextColor3=C.GREEN})
        elseif sType=="err" then tw(tbStatusFrame,{BackgroundColor3=Color3.fromRGB(18,8,8)}); tw(tbStatusStroke,{Color=C.RED}); tw(tbStatusLabel,{TextColor3=C.RED})
        else tw(tbStatusFrame,{BackgroundColor3=C.MUTED}); tw(tbStatusStroke,{Color=C.BORDER}); tw(tbStatusLabel,{TextColor3=C.SUBTEXT}) end
        tbStatusLabel.Text=msg
    end
    local function tb_flashFrame(ok)
        local col=ok and C.GREEN or C.RED; tw(avatarStroke,{Color=col},0.1); task.delay(0.4,function() tw(avatarStroke,{Color=tb_dynColor},0.3) end)
    end
    local function tb_flashPin(pinId,ok)
        local node=pinNodes[pinId]; if not node then return end
        local col=ok and C.GREEN or C.RED; tw(node.cardStroke,{Color=col},0.1); task.delay(0.4,function() tw(node.cardStroke,{Color=tb_dynColor},0.3) end)
    end
    local function tb_applyDyn(color)
        tb_dynColor=color or C.NEUTRAL; tb_applyDynColor(tb_dynColor)
        task.delay(0.05,function() redrawStrings(tb_dynColor) end)
    end

    local tb_activePill=nil
    local tb_pillRefs={}
    local tb_selectTarget, tb_clearTarget

    local function tb_makePill(name,userId,isClear)
        local pill=frm({Size=UDim2.new(1,0,0,42),BackgroundColor3=C.CARD,ZIndex=21},pillsInner)
        corner(pill,10); local ps = stroke(pill,C.BORDER,1.2)

        if isClear then
            lbl({Size=UDim2.new(1,0,1,0), Position=UDim2.new(0,12,0,0), Text="✕ Clear Selection", TextColor3=C.SUBTEXT, TextSize=11, Font=Enum.Font.GothamBold, ZIndex=22}, pill)
            local cl=tbtn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=23},pill)
            cl.MouseButton1Click:Connect(function() if tb_clearTarget then tb_clearTarget() end end)
        else
            local av=frm({Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,8,0.5,-14),BackgroundColor3=C.ACCENTDIM,ZIndex=22},pill); corner(av,8)
            lbl({Size=UDim2.new(1,0,1,0),Text=name:sub(1,1):upper(),TextColor3=C.ACCENTHI,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=23},av)
            lbl({Size=UDim2.new(1,-44,1,0),Position=UDim2.new(0,44,0,0),Text=name,TextColor3=C.TEXT,TextSize=11,Font=Enum.Font.GothamBold,ZIndex=22},pill)

            local cl=tbtn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=23},pill)
            cl.MouseEnter:Connect(function() tw(pill,{BackgroundColor3=C.CARD2}); tw(ps,{Color=tb_dynColor}) end)
            cl.MouseLeave:Connect(function() if tb_activePill~=pill then tw(pill,{BackgroundColor3=C.CARD}); tw(ps,{Color=C.BORDER}) end end)
            cl.MouseButton1Click:Connect(function() if tb_selectTarget then tb_selectTarget(pill,name,userId) end end)
            tb_pillRefs[name]={pill=pill,pillStroke=ps}
        end
        return pill
    end
    local function tb_refreshPills()
        for _,c in ipairs(pillsInner:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        tb_activePill=nil; tb_pillRefs={}
        tb_makePill("None",nil,true)
        for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then tb_makePill(p.Name,tostring(p.UserId),false) end end
    end
    tb_refreshPills()
    Players.PlayerAdded:Connect(function() tb_refreshPills() end)
    Players.PlayerRemoving:Connect(function() task.wait(0.1); tb_refreshPills() end)

    searchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local q=searchInput.Text:lower()
        for _,c in ipairs(dropInner:GetChildren()) do if c~=comingSoonRow then c:Destroy() end end
        dropdownFrame.Visible=#searchInput.Text>0
        if #searchInput.Text>0 then tw(searchStroke,{Color=tb_dynColor}) end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Name:lower():find(q,1,true) then
                local row,cl=makeDropRow(p.Name,tostring(p.UserId))
                cl.MouseButton1Click:Connect(function()
                    if tb_selectTarget then tb_selectTarget(tb_pillRefs[p.Name] and tb_pillRefs[p.Name].pill or nil,p.Name,tostring(p.UserId)) end
                    searchInput.Text=""; dropdownFrame.Visible=false
                end)
            end
        end
    end)
    searchInput.FocusLost:Connect(function()
        task.delay(0.15,function() dropdownFrame.Visible=false; tw(searchStroke,{Color=C.BORDER}) end)
    end)

    tb_selectTarget=function(pillEl,name,userId)
        if tb_activePill then
            for _,ref in pairs(tb_pillRefs) do
                if ref.pill==tb_activePill then tw(tb_activePill,{BackgroundColor3=C.CARD,TextColor3=C.SUBTEXT}); tw(ref.pillStroke,{Color=C.BORDER}) end
            end
        end
        tb_activePill=pillEl
        if tb_backpackConn then tb_backpackConn:Disconnect(); tb_backpackConn=nil end
        if tb_headsitConn  then tb_headsitConn:Disconnect();  tb_headsitConn=nil  end
        if tb_spectateActive then Camera.CameraType=Enum.CameraType.Custom; local mc=LocalPlayer.Character; Camera.CameraSubject=mc and mc:FindFirstChildOfClass("Humanoid") end
        tb_backpackActive=false; tb_followActive=false; tb_spectateActive=false
        if pinNodes["bp"] then pinNodes["bp"].nameLbl.Text="BACKPACK" end
        if pinNodes["ft"] then pinNodes["ft"].nameLbl.Text="FOLLOW TP" end
        if pinNodes["sp"] then pinNodes["sp"].nameLbl.Text="SPECTATE" end
        if pinNodes["hs"] then pinNodes["hs"].nameLbl.Text="HEADSIT" end
        local targetPlayer=Players:FindFirstChild(name)
        tb_currentTarget={name=name,userId=userId,player=targetPlayer,character=targetPlayer and targetPlayer.Character or nil}
        if pillEl and tb_pillRefs[name] then tw(pillEl,{BackgroundColor3=C.CARD2,TextColor3=C.TEXT}); tw(tb_pillRefs[name].pillStroke,{Color=tb_dynColor}) end
        tbCaseLabel.Text="CASE #0001 — "..name:upper()
        tbCornerTR.Text="TARGET: "..name.."\nUID: "..userId
        avatarNameLabel.Text=name
        tb_setStatus("none","— LOADING —"); tb_setTopStatus("none","LOADING"); tb_applyDyn(nil)
        avatarPH.Visible=false; avatarImg.Visible=false; loadRing.Visible=true
        task.spawn(function()
            local uid=tonumber(userId) or 0
            local ok,result=pcall(function()
                return Players:GetUserThumbnailAsync(uid,Enum.ThumbnailType.AvatarBust,Enum.ThumbnailSize.Size420x420)
            end)
            if not sg.Parent then return end
            loadRing.Visible=false
            if ok and result and result~="" then avatarImg.Image=result; avatarImg.Visible=true; avatarPH.Visible=false
            else avatarImg.Visible=false; avatarPH.Visible=true end
            local hue=(uid*137.508)%360; local sat=math.clamp(0.5+(uid%13)*0.02,0.4,0.75)
            tb_applyDyn(Color3.fromHSV(hue/360,sat,0.72))
            if ok and result and result~="" then tb_setStatus("ok","200 — TARGET LOCKED"); tb_setTopStatus("ok","LOCKED"); tb_flashFrame(true)
            else tb_setStatus("err","404 — NO AVATAR"); tb_setTopStatus("err","404"); tb_flashFrame(false) end
        end)
    end

    tb_clearTarget=function()
        if tb_backpackConn then tb_backpackConn:Disconnect(); tb_backpackConn=nil end
        if tb_headsitConn  then tb_headsitConn:Disconnect();  tb_headsitConn=nil  end
        if tb_spectateActive then Camera.CameraType=Enum.CameraType.Custom; local mc=LocalPlayer.Character; Camera.CameraSubject=mc and mc:FindFirstChildOfClass("Humanoid") end
        tb_activePill=nil; tb_currentTarget=nil; tb_backpackActive=false; tb_followActive=false; tb_spectateActive=false
        for _,ref in pairs(tb_pillRefs) do
            if ref.pill and ref.pill.Parent then
                tw(ref.pill,{BackgroundColor3=C.CARD,TextColor3=C.SUBTEXT}); tw(ref.pillStroke,{Color=C.BORDER})
            end
        end
        if pinNodes["bp"] then pinNodes["bp"].nameLbl.Text="BACKPACK" end
        if pinNodes["ft"] then pinNodes["ft"].nameLbl.Text="FOLLOW TP" end
        if pinNodes["sp"] then pinNodes["sp"].nameLbl.Text="SPECTATE" end
        if pinNodes["hs"] then pinNodes["hs"].nameLbl.Text="HEADSIT" end
        tbCaseLabel.Text="CASE #0001 — HAVOC INTEL"; tbCornerTR.Text="TARGET: NONE\nUID: —"
        avatarNameLabel.Text="—"; avatarImg.Visible=false; loadRing.Visible=false; avatarPH.Visible=true
        tb_setStatus("none","— AWAITING TARGET —"); tb_setTopStatus("none","NO TARGET"); tb_applyDyn(nil)
    end

    local function tb_doAction(action,pinId)
        if not tb_currentTarget then tb_setStatus("err","400 — NO TARGET SET"); tb_setTopStatus("err","400"); tb_flashFrame(false); return end
        if tb_currentTarget.player then tb_currentTarget.character=tb_currentTarget.player.Character end
        local char=tb_currentTarget.character
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        local myChar=LocalPlayer.Character
        local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart")

        if action=="teleport" then
            if hrp and myHRP then
                if safeTpEnabled and not hrp.Parent then tb_setStatus("err","403 — TP BLOCKED"); tb_setTopStatus("err","ERR"); tb_flashFrame(false); tb_flashPin(pinId,false); return end
                myHRP.CFrame=hrp.CFrame*CFrame.new(3,0,0)
                tb_setStatus("ok","200 — TELEPORT OK"); tb_setTopStatus("ok","OK"); tb_flashFrame(true); tb_flashPin(pinId,true)
            else tb_setStatus("err","403 — TP BLOCKED"); tb_setTopStatus("err","ERR"); tb_flashFrame(false); tb_flashPin(pinId,false) end

        elseif action=="headsit" then
            if tb_headsitConn then
                tb_headsitConn:Disconnect(); tb_headsitConn=nil
                local lHum=myChar and myChar:FindFirstChildOfClass("Humanoid"); if lHum then lHum.PlatformStand=false end
                if pinNodes[pinId] then pinNodes[pinId].nameLbl.Text="HEADSIT"; tw(pinNodes[pinId].cardStroke,{Color=tb_dynColor,Thickness=1}) end
                tb_setStatus("ok","200 — HEADSIT OFF"); tb_setTopStatus("ok","LOCKED")
            else
                if hrp and myHRP then
                    local lHum=myChar and myChar:FindFirstChildOfClass("Humanoid"); if lHum then lHum.PlatformStand=true end
                    if pinNodes[pinId] then pinNodes[pinId].nameLbl.Text="SITTING"; tw(pinNodes[pinId].cardStroke,{Color=tb_dynColor,Thickness=1.5}) end
                    tb_headsitConn=RunService.Heartbeat:Connect(function()
                        local tChar=tb_currentTarget.player and tb_currentTarget.player.Character
                        local tHead=tChar and tChar:FindFirstChild("Head")
                        local lHRP=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if tHead and lHRP then lHRP.CFrame=tHead.CFrame*CFrame.new(0,2.5,0)
                        else
                            if tb_headsitConn then tb_headsitConn:Disconnect(); tb_headsitConn=nil end
                            local lH=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if lH then lH.PlatformStand=false end
                            if pinNodes[pinId] then pinNodes[pinId].nameLbl.Text="HEADSIT" end
                        end
                    end)
                    tb_setStatus("ok","200 — HEADSIT ACTIVE"); tb_setTopStatus("ok","OK"); tb_flashFrame(true); tb_flashPin(pinId,true)
                else tb_setStatus("err","500 — CHAR ERROR"); tb_setTopStatus("err","ERR"); tb_flashFrame(false); tb_flashPin(pinId,false) end
            end

        elseif action=="backpack" then
            tb_backpackActive=not tb_backpackActive
            if tb_backpackActive then
                if pinNodes[pinId] then pinNodes[pinId].nameLbl.Text="ACTIVE"; tw(pinNodes[pinId].cardStroke,{Color=tb_dynColor,Thickness=1.5}) end
                tb_backpackConn=RunService.RenderStepped:Connect(function()
                    if not tb_backpackActive then return end
                    local tChar=tb_currentTarget.player and tb_currentTarget.player.Character
                    local tHRP=tChar and tChar:FindFirstChild("HumanoidRootPart")
                    local lHRP=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if tHRP and lHRP then lHRP.CFrame=tHRP.CFrame*CFrame.new(0,1.5,-1.8) end
                end)
                tb_setStatus("ok","200 — MOUNTED BACK"); tb_setTopStatus("ok","MOUNTED"); tb_flashFrame(true); tb_flashPin(pinId,true)
            else
                if tb_backpackConn then tb_backpackConn:Disconnect(); tb_backpackConn=nil end
                if pinNodes[pinId] then pinNodes[pinId].nameLbl.Text="BACKPACK"; tw(pinNodes[pinId].cardStroke,{Color=tb_dynColor,Thickness=1}) end
                tb_setStatus("ok","200 — DISMOUNTED"); tb_setTopStatus("ok","LOCKED")
            end

        elseif action=="followtp" then
            tb_followActive=not tb_followActive
            if tb_followActive then
                if pinNodes[pinId] then pinNodes[pinId].nameLbl.Text="FOLLOWING"; tw(pinNodes[pinId].cardStroke,{Color=tb_dynColor,Thickness=1.5}) end
                task.spawn(function()
                    while tb_followActive and sg.Parent do
                        local tChar=tb_currentTarget and tb_currentTarget.player and tb_currentTarget.player.Character
                        local tHRP=tChar and tChar:FindFirstChild("HumanoidRootPart")
                        local lHRP=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if tHRP and lHRP then lHRP.CFrame=tHRP.CFrame*CFrame.new(3,0,0) end
                        task.wait(0.5)
                    end
                end)
                tb_setStatus("ok","200 — FOLLOW ACTIVE"); tb_setTopStatus("ok","FOLLOWING"); tb_flashFrame(true); tb_flashPin(pinId,true)
            else
                if pinNodes[pinId] then pinNodes[pinId].nameLbl.Text="FOLLOW TP"; tw(pinNodes[pinId].cardStroke,{Color=tb_dynColor,Thickness=1}) end
                tb_setStatus("ok","200 — FOLLOW STOPPED"); tb_setTopStatus("ok","LOCKED")
            end

        elseif action=="spectate" then
            tb_spectateActive=not tb_spectateActive
            if tb_spectateActive then
                if pinNodes[pinId] then pinNodes[pinId].nameLbl.Text="WATCHING"; tw(pinNodes[pinId].cardStroke,{Color=tb_dynColor,Thickness=1.5}) end
                local tChar=tb_currentTarget.player and tb_currentTarget.player.Character
                local tHum=tChar and tChar:FindFirstChildOfClass("Humanoid")
                if tHum then
                    Camera.CameraType=Enum.CameraType.Follow; Camera.CameraSubject=tHum
                    tb_setStatus("ok","200 — SPECTATING"); tb_setTopStatus("ok","SPECTATING"); tb_flashFrame(true); tb_flashPin(pinId,true)
                else
                    tb_spectateActive=false
                    if pinNodes[pinId] then pinNodes[pinId].nameLbl.Text="SPECTATE" end
                    tb_setStatus("err","500 — CAM ERROR"); tb_setTopStatus("err","ERR"); tb_flashFrame(false); tb_flashPin(pinId,false)
                end
            else
                Camera.CameraType=Enum.CameraType.Custom; local mc=LocalPlayer.Character; Camera.CameraSubject=mc and mc:FindFirstChildOfClass("Humanoid")
                if pinNodes[pinId] then pinNodes[pinId].nameLbl.Text="SPECTATE"; tw(pinNodes[pinId].cardStroke,{Color=tb_dynColor,Thickness=1}) end
                tb_setStatus("ok","200 — SPECTATE OFF"); tb_setTopStatus("ok","LOCKED")
            end
        end
    end

    for _,cfg in ipairs(PIN_CONFIGS) do
        local node=pinNodes[cfg.id]
        if node then node.cl.MouseButton1Click:Connect(function() tb_doAction(cfg.action,cfg.id) end) end
    end
    frm({Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,ZIndex=4},tgInner)
end
buildTargetTab()

-- ══════════════════════════════════════════
--  TAB: PROTECT
-- ══════════════════════════════════════════
local function buildProtectTab()
    local ptInner=newTabPage("protect")
    sectionHeader(ptInner,"Protection")
    local ptToggles=frm({Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=4},ptInner); listLayout(ptToggles,6)
    makeToggle(ptToggles,"Anti-Knockback","Null out velocity applied to local HRP",false,function(isOn)
        if isOn then enableAntiKB() else disableAntiKB() end
    end)
    makeToggle(ptToggles,"Anti-Void","Teleport back on Y < threshold",true,function(isOn)
        if isOn then enableAntiVoid() else disableAntiVoid() end
    end)
    makeToggle(ptToggles,"Anti-Ragdoll","Block ragdoll state changes",false,function(isOn)
        if isOn then enableAntiRagdoll() else disableAntiRagdoll() end
    end)
    makeToggle(ptToggles,"Safe Teleport","Verify destination before TP",true,function(isOn)
        safeTpEnabled=isOn
    end)
    makeToggle(ptToggles,"Rejoin on Kick","Auto-reconnect if kicked",false,function(isOn)
        if isOn then enableRejoinOnKick() else disableRejoinOnKick() end
    end)
    sectionHeader(ptInner,"Anti-Void Threshold")
    local ptSliders=frm({Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=4},ptInner); listLayout(ptSliders,6)
    makeSlider(ptSliders,"Void Y Threshold","Snap back if HRP.Y falls below this",-200,0,-100,function(val) voidThreshold=val end)
    frm({Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,ZIndex=4},ptInner)
end
buildProtectTab()

-- ══════════════════════════════════════════
--  TAB: MISC
-- ══════════════════════════════════════════
local function buildMiscTab()
    local msInner=newTabPage("misc")
    sectionHeader(msInner,"Miscellaneous")
    local msToggles=frm({Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=4},msInner); listLayout(msToggles,6)
    makeToggle(msToggles,"FPS Unlocker","Remove Roblox 60fps cap",false,function(isOn)
        pcall(function()
            if type(setfpscap)=="function" then setfpscap(isOn and 0 or 60)
            elseif type(syn)=="table" and type(syn.setfpscap)=="function" then syn.setfpscap(isOn and 0 or 60) end
        end)
    end)
    makeToggle(msToggles,"FPS Booster","Reduce graphics quality for performance",false,function(isOn)
        if isOn then enableFPSBooster() else disableFPSBooster() end
    end)
    makeToggle(msToggles,"Anti-AFK","Prevent auto-disconnect",true,function(isOn)
        if isOn then enableAntiAFK() else disableAntiAFK() end
    end)
    makeToggle(msToggles,"Chat Logger","Log all server chat to console",false,function(isOn)
        if isOn then enableChatLogger() else disableChatLogger() end
    end)
    makeToggle(msToggles,"Auto-Respawn","Instantly respawn on death",false,function(isOn)
        if isOn then enableAutoRespawn() else disableAutoRespawn() end
    end)
    makeToggle(msToggles,"Rejoin Button","Show quick rejoin button on HUD",false,function(isOn)
        if isOn then
            local rjSg=Instance.new("ScreenGui"); rjSg.Name="Havoc_RejoinBtn"; rjSg.ResetOnSpawn=false; rjSg.Parent=LocalPlayer.PlayerGui
            local rjBtn=tbtn({Size=UDim2.new(0,80,0,28),Position=UDim2.new(0,8,1,-96),BackgroundColor3=C.ACCENTDIM,TextColor3=C.ACCENTHI,TextSize=9,Text="↺ Rejoin",Font=Enum.Font.GothamBold},rjSg)
            corner(rjBtn,7); stroke(rjBtn,C.ACCENT,1,0.5)
            rjBtn.MouseButton1Click:Connect(function() pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId,LocalPlayer) end) end)
            rjBtn.MouseEnter:Connect(function() tw(rjBtn,{BackgroundColor3=C.ACCENT,TextColor3=C.WHITE}) end)
            rjBtn.MouseLeave:Connect(function() tw(rjBtn,{BackgroundColor3=C.ACCENTDIM,TextColor3=C.ACCENTHI}) end)
        else
            local rjSg=LocalPlayer.PlayerGui:FindFirstChild("Havoc_RejoinBtn"); if rjSg then rjSg:Destroy() end
        end
    end)
    makeToggle(msToggles,"Server Hop","Auto-join lowest populated server",false,function(isOn)
        serverHopOn=isOn
        if isOn and crequest then
            task.spawn(function()
                local ok,result=pcall(function()
                    local res=crequest({
                        Url="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=25",
                        Method="GET"
                    })
                    if res and res.Body then return HttpService:JSONDecode(res.Body) end
                end)
                if ok and result and result.data then
                    for _,server in ipairs(result.data) do
                        if server.id ~= game.JobId then
                            pcall(function()
                                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,server.id,LocalPlayer)
                            end)
                            return
                        end
                    end
                end
            end)
        elseif isOn and not crequest then
            print("[Havoc] Server Hop: no HTTP function available in this executor")
        end
    end)

    sectionHeader(msInner,"ScriptBlox Search")
    local sbCard=frm({Size=UDim2.new(1,0,0,50),BackgroundColor3=C.CARD,ZIndex=5},msInner); corner(sbCard,10); stroke(sbCard,C.BORDER,1)
    local sbInput=Instance.new("TextBox"); sbInput.Size=UDim2.new(1,-110,1,-16); sbInput.Position=UDim2.new(0,10,0,8)
    sbInput.BackgroundColor3=C.SURFACE; sbInput.BorderSizePixel=0; sbInput.PlaceholderText="Search ScriptBlox..."
    sbInput.PlaceholderColor3=C.SUBTEXT; sbInput.TextColor3=C.TEXT; sbInput.TextSize=11; sbInput.Font=Enum.Font.Gotham
    sbInput.ClearTextOnFocus=false; sbInput.ZIndex=6; sbInput.Parent=sbCard; corner(sbInput,6)
    local sbBtn=tbtn({Size=UDim2.new(0,90,1,-16),Position=UDim2.new(1,-100,0,8),BackgroundColor3=C.ACCENT,TextColor3=C.WHITE,TextSize=10,Text="Search",Font=Enum.Font.GothamBold,ZIndex=6},sbCard); corner(sbBtn,7)
    sbBtn.MouseEnter:Connect(function() tw(sbBtn,{BackgroundColor3=C.ACCENTHI}) end)
    sbBtn.MouseLeave:Connect(function() tw(sbBtn,{BackgroundColor3=C.ACCENT}) end)
    sbBtn.MouseButton1Click:Connect(function()
        if not crequest then print("[Havoc] ScriptBlox: no HTTP function available"); return end
        local q=sbInput.Text~="" and sbInput.Text or game.Name
        task.spawn(function()
            local ok,data=pcall(function()
                local res=crequest({Url="https://scriptblox.com/api/script/search?q="..HttpService:UrlEncode(q).."&max=5",Method="GET"})
                if res and res.Body then return HttpService:JSONDecode(res.Body) end
            end)
            if ok and data and data.result and data.result.scripts then
                print("[Havoc] ScriptBlox results for '"..q.."':")
                for i,sc in ipairs(data.result.scripts) do
                    print(string.format("  [%d] %s — %d views",i,sc.title or "?",sc.views or 0))
                end
            else print("[Havoc] ScriptBlox: no results or request failed") end
        end)
    end)

    sectionHeader(msInner,"Keybinds")
    local kbCard=frm({Size=UDim2.new(1,0,0,120),BackgroundColor3=C.CARD,ZIndex=5},msInner); corner(kbCard,10); stroke(kbCard,C.BORDER,1)
    for i,kb in ipairs({{"V","Toggle Dashboard UI"},{"K","Open Command Palette"},{"B","Toggle Aimbot"},{"F","Teleport (to crosshair)"},{"G","Noclip toggle"}}) do
        local row=frm({Size=UDim2.new(1,-16,0,20),Position=UDim2.new(0,8,0,6+(i-1)*22),BackgroundTransparency=1,ZIndex=6},kbCard)
        local keyBadge=frm({Size=UDim2.new(0,20,0,18),BackgroundColor3=C.MUTED,ZIndex=7},row); corner(keyBadge,5); stroke(keyBadge,C.BORDER2,1)
        lbl({Size=UDim2.new(1,0,1,0),Text=kb[1],TextColor3=C.TEXT,TextSize=10,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=8},keyBadge)
        lbl({Size=UDim2.new(1,-28,1,0),Position=UDim2.new(0,28,0,0),Text=kb[2],TextColor3=C.SUBTEXT,TextSize=9,Font=Enum.Font.Gotham,ZIndex=7},row)
    end
    frm({Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,ZIndex=4},msInner)
end
buildMiscTab()

-- ══════════════════════════════════════════
--  TAB: CHANGELOG
-- ══════════════════════════════════════════
local function buildChangelogTab()
    local cgInner=newTabPage("changelog")
    sectionHeader(cgInner,"Full Changelog")
    local cgList=frm({Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=4},cgInner); listLayout(cgList,8)
    for _,entry in ipairs({
        {"v2.2","Aimbot + ESP Tab","Full aimbot: FOV lock, smooth, prediction, triggerbot, team check. Whitelist/Nametag tabs removed. B key = aimbot toggle."},
        {"v2.1","Final Merged Build","All v1.5 scripts wired: Speed, Fly, Noclip, Invis, Inf Jump, Anti-AFK, Fullbright, ESP, Chams, Tracers, FOV, Anti-KB, Anti-Void, Anti-Ragdoll, AutoRespawn, Chat Logger, ServerHop, FPS Boost, RejoinOnKick."},
        {"v2.1","Restructured Tabs","Target in Players section. Removed god mode & stamina. Added Invisibility."},
        {"v2.0","Tabbed Dashboard","Player, Target, Visual, Protect, Misc tabs. Key tab removed."},
        {"v1.5","Nametag System & Discord Bot","HVC nametags JSON-driven. Discord bot for remote management."},
        {"v1.4","Polish & Performance","FPS Booster, Unlocker, draggable HUD, baseplate colour picker."},
        {"v1.3","Major Feature Update","ESP FOV circle, smoothness slider, prediction, ScriptBlox."},
        {"v1.2","ESP & Owner Panel","Through-wall ESP. Owner panel with admin actions."},
        {"v1.1","Scripts & UI Overhaul","Speed, Fly, Noclip, Fullbright, Anti-AFK. Full GUI rewrite."},
        {"v1.0","Initial Release","Core whitelist system, basic HUD, sidebar navigation."},
    }) do
        local e=frm({Size=UDim2.new(1,0,0,74),BackgroundColor3=C.CARD,ZIndex=5},cgList); corner(e,10); stroke(e,C.BORDER,1)
        local vb=frm({Size=UDim2.new(0,34,0,16),Position=UDim2.new(0,10,0,8),BackgroundColor3=C.ACCENTDIM,ZIndex=6},e); corner(vb,8); stroke(vb,C.ACCENT,1,0.4)
        lbl({Size=UDim2.new(1,0,1,0),Text=entry[1],TextColor3=C.ACCENTHI,TextSize=7,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=7},vb)
        lbl({Size=UDim2.new(1,-60,0,18),Position=UDim2.new(0,10,0,26),Text=entry[2],TextColor3=C.WHITE,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=6},e)
        lbl({Size=UDim2.new(1,-20,0,26),Position=UDim2.new(0,10,0,46),Text=entry[3],TextColor3=C.SUBTEXT,TextSize=8,Font=Enum.Font.Gotham,TextWrapped=true,ZIndex=6},e)
        local cl=tbtn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=7},e)
        cl.MouseEnter:Connect(function() tw(e,{BackgroundColor3=C.CARD2}) end)
        cl.MouseLeave:Connect(function() tw(e,{BackgroundColor3=C.CARD}) end)
    end
    frm({Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,ZIndex=4},cgInner)
end
buildChangelogTab()

-- ══════════════════════════════════════════
--  TAB: SCRIPTS
-- ══════════════════════════════════════════
local function buildScriptsTab()
    local scInner = newTabPage("scripts")
    sectionHeader(scInner, "External Scripts")

    local scripts = {
        {name="Solaris", url="https://solarishub.dev/script.lua", desc="A collection of your favorite scripts.", footer="solarishub.dev"},
        {name="V.G Hub", url="https://raw.githubusercontent.com/1201for/V.G-Hub/main/V.Ghub", desc="Featuring over 100 games.", footer="github.com/1201for"},
        {name="CMD-X", url="https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source", desc="Powerful administration commands.", footer="github.com/CMD-X"},
        {name="Infinite Yield", url="https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", desc="Universal admin script.", footer="github.com/EdgeIY"},
        {name="Dex Explorer", url="https://pastebin.com/raw/mMbsHWiQ", desc="In-game object browser.", footer="github.com/LorekeeperZinnia"},
        {name="Unnamed ESP", url="https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/master/UnnamedESP.lua", desc="Highly customizable ESP.", footer="github.com/ic3w0lf22"},
        {name="EvoV2", url="https://projectevo.xyz/script/loader.lua", desc="Reliable cheats for top shooter games.", footer="projectevo.xyz"}
    }

    local list = frm({Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y, ZIndex=4}, scInner)
    listLayout(list, 8)

    for _, s in ipairs(scripts) do
        local card = frm({Size=UDim2.new(1,0,0,74), BackgroundColor3=C.CARD, ZIndex=5}, list, "CARD")
        corner(card, 10); stroke(card, C.BORDER, 1, 0, "BORDER")

        lbl({Size=UDim2.new(1,-110,0,18), Position=UDim2.new(0,14,0,12), Text=s.name, TextColor3=C.WHITE, TextSize=14, Font=Enum.Font.GothamBold, ZIndex=6}, card, "WHITE")
        lbl({Size=UDim2.new(1,-110,0,26), Position=UDim2.new(0,14,0,32), Text=s.desc, TextColor3=C.SUBTEXT, TextSize=9, Font=Enum.Font.Gotham, TextWrapped=true, ZIndex=6}, card, "SUBTEXT")
        lbl({Size=UDim2.new(1,-110,0,12), Position=UDim2.new(0,14,0,56), Text=s.footer, TextColor3=C.ACCENTHI, TextSize=8, Font=Enum.Font.GothamBold, ZIndex=6}, card, "ACCENTHI")

        local loadBtn = tbtn({Size=UDim2.new(0,80,0,34), Position=UDim2.new(1,-94,0.5,-17), BackgroundColor3=C.ACCENTDIM, TextColor3=C.ACCENTHI, TextSize=10, Text="Execute", Font=Enum.Font.GothamBold, ZIndex=7}, card, "ACCENTDIM")
        corner(loadBtn, 8); stroke(loadBtn, C.ACCENT, 1, 0.5, "ACCENT")

        loadBtn.MouseEnter:Connect(function() tw(loadBtn, {BackgroundColor3=C.ACCENT, TextColor3=C.WHITE}) end)
        loadBtn.MouseLeave:Connect(function() tw(loadBtn, {BackgroundColor3=C.ACCENTDIM, TextColor3=C.ACCENTHI}) end)

        loadBtn.MouseButton1Click:Connect(function()
            local success, content = pcall(function() return game:HttpGet(s.url) end)
            if success then
                local func, err = loadstring(content)
                if func then task.spawn(func) else warn("Failed to load: "..tostring(err)) end
            else warn("Failed to fetch script from URL") end
        end)
    end

    frm({Size=UDim2.new(1,0,0,16), BackgroundTransparency=1, ZIndex=4}, scInner)
end
buildScriptsTab()

-- ══════════════════════════════════════════
--  TAB: THEMES
-- ══════════════════════════════════════════
local function buildThemesTab()
    local thInner = newTabPage("themes")
    sectionHeader(thInner, "UI Themes")

    local list = frm({Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y, ZIndex=4}, thInner)
    listLayout(list, 8)

    for name, palette in pairs(Themes) do
        local card = frm({Size=UDim2.new(1,0,0,60), BackgroundColor3=C.CARD, ZIndex=5}, list, "CARD")
        corner(card, 10); stroke(card, C.BORDER, 1, 0, "BORDER")

        lbl({Size=UDim2.new(1,-120,1,0), Position=UDim2.new(0,14,0,0), Text=name, TextColor3=C.TEXT, TextSize=14, Font=Enum.Font.GothamBold, ZIndex=6}, card, "TEXT")

        local applyBtn = tbtn({Size=UDim2.new(0,80,0,30), Position=UDim2.new(1,-94,0.5,-15), BackgroundColor3=C.ACCENTDIM, TextColor3=C.ACCENTHI, TextSize=10, Text="Apply", Font=Enum.Font.GothamBold, ZIndex=7}, card, "ACCENTDIM")
        corner(applyBtn, 8); stroke(applyBtn, C.ACCENT, 1, 0.5, "ACCENT")

        applyBtn.MouseEnter:Connect(function() tw(applyBtn, {BackgroundColor3=C.ACCENT, TextColor3=C.WHITE}) end)
        applyBtn.MouseLeave:Connect(function() tw(applyBtn, {BackgroundColor3=C.ACCENTDIM, TextColor3=C.ACCENTHI}) end)

        applyBtn.MouseButton1Click:Connect(function()
            ApplyTheme(palette)
        end)
    end

    frm({Size=UDim2.new(1,0,0,16), BackgroundTransparency=1, ZIndex=4}, thInner)
end
buildThemesTab()

-- ══════════════════════════════════════════
--  COMMAND PALETTE
-- ══════════════════════════════════════════
local cmdOverlay=frm({Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.5,Visible=false,ZIndex=20},win)
local cmdWin=frm({Size=UDim2.new(0,460,0,0),Position=UDim2.new(0.5,-230,0,80),BackgroundColor3=C.SURFACE,Visible=false,ZIndex=21},sg)
corner(cmdWin,12); stroke(cmdWin,C.BORDER2,1)
local cmdInputRow=frm({Size=UDim2.new(1,0,0,44),BackgroundTransparency=1,ZIndex=22},cmdWin)
frm({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.BORDER,ZIndex=22},cmdInputRow)
lbl({Size=UDim2.new(0,20,1,0),Position=UDim2.new(0,14,0,0),Text="⌘",TextColor3=C.SUBTEXT,TextSize=16,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=23},cmdInputRow)
local cmdBox=Instance.new("TextBox"); cmdBox.Size=UDim2.new(1,-80,1,0); cmdBox.Position=UDim2.new(0,36,0,0)
cmdBox.BackgroundTransparency=1; cmdBox.BorderSizePixel=0; cmdBox.PlaceholderText="Search commands, users, tabs..."
cmdBox.PlaceholderColor3=C.SUBTEXT; cmdBox.TextColor3=C.TEXT; cmdBox.TextSize=12; cmdBox.Font=Enum.Font.Gotham
cmdBox.ClearTextOnFocus=false; cmdBox.ZIndex=23; cmdBox.Parent=cmdInputRow
local escBadge=frm({Size=UDim2.new(0,30,0,18),Position=UDim2.new(1,-38,0.5,-9),BackgroundColor3=C.MUTED,ZIndex=22},cmdInputRow); corner(escBadge,4)
lbl({Size=UDim2.new(1,0,1,0),Text="ESC",TextColor3=C.SUBTEXT,TextSize=8,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=23},escBadge)
local CMD_PALETTE={
    {icon="⚔",name="Aimbot",        desc="Open Aimbot controls",       tab="aimbot"},
    {icon="👁",name="Visual / ESP",  desc="ESP and visual options",      tab="visual"},
    {icon="🎮",name="Player Settings",desc="Jump to Player tab",       tab="player"},
    {icon="🔎",name="Select Target", desc="Open Target Board",         tab="target"},
    {icon="🛡",name="Protection",    desc="Open Protect tab",          tab="protect"},
}
local cmdResultsFrame=frm({Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,0,44),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=22},cmdWin); listLayout(cmdResultsFrame,0)
local paletteOpen=false
local function openPalette()
    paletteOpen=true; cmdWin.Visible=true; cmdWin.Size=UDim2.new(0,460,0,0)
    tw(cmdWin,{Size=UDim2.new(0,460,0,44+(#CMD_PALETTE*40)+28)},0.2,Enum.EasingStyle.Back); cmdOverlay.Visible=true
end
local function closePalette()
    paletteOpen=false; tw(cmdWin,{Size=UDim2.new(0,460,0,0)},0.14)
    task.delay(0.15,function() cmdWin.Visible=false; cmdOverlay.Visible=false end)
end
for i,r in ipairs(CMD_PALETTE) do
    local row=frm({Size=UDim2.new(1,0,0,40),BackgroundColor3=i==1 and C.CARD2 or Color3.new(0,0,0),BackgroundTransparency=i==1 and 0 or 1,ZIndex=23},cmdResultsFrame)
    lbl({Size=UDim2.new(0,24,1,0),Position=UDim2.new(0,12,0,0),Text=r.icon,TextSize=16,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=24},row)
    lbl({Size=UDim2.new(0,200,0,16),Position=UDim2.new(0,40,0,6),Text=r.name,TextColor3=C.TEXT,TextSize=11,Font=Enum.Font.GothamBold,ZIndex=24},row)
    lbl({Size=UDim2.new(0,200,0,13),Position=UDim2.new(0,40,0,21),Text=r.desc,TextColor3=C.SUBTEXT,TextSize=8,Font=Enum.Font.Gotham,ZIndex=24},row)
    local tagBadge=frm({Size=UDim2.new(0,56,0,16),Position=UDim2.new(1,-64,0.5,-8),BackgroundColor3=C.MUTED,ZIndex=23},row); corner(tagBadge,4)
    lbl({Size=UDim2.new(1,0,1,0),Text=r.tab,TextColor3=C.SUBTEXT,TextSize=7,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=24},tagBadge)
    local cl=tbtn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=25},row)
    cl.MouseEnter:Connect(function() tw(row,{BackgroundTransparency=0,BackgroundColor3=C.CARD2}) end)
    cl.MouseLeave:Connect(function() if i~=1 then tw(row,{BackgroundTransparency=1}) end end)
    cl.MouseButton1Click:Connect(function() switchTab(r.tab); closePalette() end)
end
local cmdFooter=frm({Size=UDim2.new(1,0,0,28),BackgroundColor3=C.TOPBAR,ZIndex=22},cmdWin)
frm({Size=UDim2.new(1,0,0,1),BackgroundColor3=C.BORDER,ZIndex=22},cmdFooter)
lbl({Size=UDim2.new(0,300,1,0),Position=UDim2.new(0,12,0,0),Text="↑↓ navigate    ↵ select    ESC close",TextColor3=C.SUBTEXT,TextSize=8,Font=Enum.Font.Gotham,ZIndex=23},cmdFooter)
cmdBtn.MouseButton1Click:Connect(function() if paletteOpen then closePalette() else openPalette() end end)
cmdOverlay.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then closePalette() end end)

-- ══════════════════════════════════════════
--  KEYBINDS
-- ══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(i,gpe)
    if gpe or UserInputService:GetFocusedTextBox() then return end
    if i.KeyCode==Enum.KeyCode.V then sg.Enabled=not sg.Enabled end
    if i.KeyCode==Enum.KeyCode.K then if paletteOpen then closePalette() else openPalette() end end
    -- B keybind: toggle aimbot (wired inside buildAimbotTab)
    if i.KeyCode==Enum.KeyCode.F then
        local unitRay=Camera:ScreenPointToRay(Mouse.X,Mouse.Y)
        local result=workspace:Raycast(unitRay.Origin,unitRay.Direction*500)
        if result then
            local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame=CFrame.new(result.Position+Vector3.new(0,3,0)) end
        end
    end
    if i.KeyCode==Enum.KeyCode.G then
        noclipOn=not noclipOn; if noclipOn then enableNoclip() else disableNoclip() end
    end
end)

-- ══════════════════════════════════════════
--  STARTUP
-- ══════════════════════════════════════════
enableAntiAFK()
enableAntiVoid()

switchTab("home")
win.BackgroundTransparency=1
tw(win,{BackgroundTransparency=0},0.3,Enum.EasingStyle.Quint)

print("[Havoc v2.4] Loaded")
print("  V — toggle  |  K — palette  |  B — Aimbot ON/OFF  |  F — crosshair TP  |  G — noclip")
print("  Wired: Speed · Fly · Noclip · Invis · InfJump · AntiAFK · Fullbright")
print("         Aimbot · ESP · Chams · Tracers · FOV · AntiKB · AntiVoid · AntiRagdoll")
print("         AutoRespawn · ChatLogger · ServerHop · FPSBoost · RejoinOnKick")
