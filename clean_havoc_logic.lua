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