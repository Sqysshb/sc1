-- Sqays Hub - Auto Mine + Auto Trial
local env = getgenv and getgenv() or _G
if env.NILoaded then return end
env.NILoaded = true; env.NIStop = false

-- ===== EXECUTOR DETECTION =====
local execName = "Unknown"
if identifyexecutor then execName = identifyexecutor() end
if execName == "Unknown" then
    -- Windows Script Executors
    if syn then execName = "Synapse Z"
    elseif KRNL then execName = "KRNL"
    elseif Fluxus then execName = "Fluxus"
    elseif Wave then execName = "Wave"
    elseif Solara then execName = "Solara"
    elseif Seliware then execName = "Seliware"
    elseif Xeno then execName = "Xeno"
    elseif Volt then execName = "Volt"
    elseif Potassium then execName = "Potassium"
    elseif Madium then execName = "Madium"
    elseif Cosmic then execName = "Cosmic"
    elseif Velocity then execName = "Velocity"
    elseif SirHurt then execName = "SirHurt"
    -- Windows External Exploits
    elseif Serotonin then execName = "Serotonin"
    elseif Severe then execName = "Severe"
    elseif RbxCli then execName = "RbxCli"
    elseif Lumen then execName = "Lumen"
    elseif Ronin then execName = "Ronin"
    elseif Matcha then execName = "Matcha"
    elseif MatrixHub then execName = "Matrix Hub"
    elseif Photon then execName = "Photon"
    elseif DX9WARE then execName = "DX9WARE V2"
    elseif getgenv and getgenv().SeliwareLoaded then execName = "Seliware"
    elseif getgenv and getgenv().NihonLoaded then execName = "Nihon"
    -- Mac Executors
    elseif MacSploit then execName = "MacSploit"
    elseif Opiumware then execName = "Opiumware"
    -- Android/iOS Executors
    elseif Delta then execName = "Delta"
    elseif Codex then execName = "Codex"
    elseif VegaX then execName = "Vega X"
    -- Other
    elseif Electron then execName = "Electron"
    elseif SW then execName = "ScriptWare"
    end
end
local gameName = "Unknown"
pcall(function() gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
warn("[Sqays Hub] Executor: " .. execName)
warn("[Sqays Hub] Game: " .. gameName)

-- ===== ANTI-CHEAT BYPASS =====
pcall(function()
    local net = game:GetService("ReplicatedStorage"):FindFirstChild("__Net")
    if net then
        local ak = net:FindFirstChild("AutoKick")
        if ak and ak:IsA("RemoteEvent") then ak.OnClientEvent:Connect(function() end) end
    end
end)
pcall(function()
    if getconnections then for _, c in ipairs(getconnections(game:GetService("ScriptContext").Error)) do c:Disable() end end
end)
-- Silence MineralGained events (prevents queue exhaustion)
pcall(function()
    local net = game:GetService("ReplicatedStorage"):FindFirstChild("__Net")
    if net then
        local mg = net:FindFirstChild("MineralGained")
        if mg then mg.OnClientEvent:Connect(function() end) end
    end
end)

-- ===== SERVICES =====
local P = game:GetService("Players")
local WS = game:GetService("Workspace")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local VU = game:GetService("VirtualUser")
local LP = P.LocalPlayer

-- ===== ACTIVE USER HEARTBEAT =====
-- Anonymous ping every 30s — random session ID used only for counting, no personal data
local HEARTBEAT_WEBHOOK = "https://discord.com/api/webhooks/1524413636880105603/Y0Ow9lIxaQvCykXB4YAz2qWhjTvzGgCvHIcxsGBEthnCfdiuNv9XBrh5K10Lt6ceHjb5"
local sessionId = tostring(math.random(100000000, 999999999))

local function sendHeartbeat()
    if HEARTBEAT_WEBHOOK == "" then return end
    pcall(function()
        local http = syn and syn.request or http_request or request
        http({
            Url = HEARTBEAT_WEBHOOK .. "?wait=true",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = '{"content":"♥ `' .. sessionId .. '`"}'
        })
    end)
end

-- Start heartbeat loop (30s interval)
task.spawn(function()
    while true do
        sendHeartbeat()
        task.wait(30)
    end
end)

-- ===== AUTO-JOIN DISCORD =====
pcall(function()
    local HttpService = game:GetService("HttpService")
    http.request({
        Url = "http://127.0.0.1:6463/rpc?v=1",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Origin"] = "https://discord.com"
        },
        Body = HttpService:JSONEncode({
            cmd = "INVITE_BROWSER",
            args = {code = "vV7Db9p2Zs"},
            nonce = HttpService:GenerateGUID(false)
        })
    })
end)

local ORES = {"Stone","Coal","Copper","Iron","Silver","Gold","Platinum","Titanium","Uranium","Cobalt","Palladium","Ruby","Aetherite","Celestium","Voidsteel","Infinity"}

-- ===== STATE =====
local S = {
    running = false,
    noclip = false,
    tweenSpeed = 0.6, -- Glide speed (s → lower = faster)
}

-- ===== TRIAL STATE =====
local TRIAL_COORDS = Vector3.new(853.2357788085938, 11.014291763305664, 13443.501953125)

local MOB_COORDS = {
    Vector3.new(752.47119140625, 10.54693603515625, 13500.953125),
    Vector3.new(752.4614868164062, 10.54693603515625, 13460.4580078125),
    Vector3.new(720.5638427734375, 10.546934127807617, 13499.5654296875),
    Vector3.new(719.0774536132812, 10.546934127807617, 13461.4169921875),
    Vector3.new(691.6233520507812, 10.546934127807617, 13470.2548828125),
    Vector3.new(691.3533325195312, 10.546934127807617, 13496.181640625),
    Vector3.new(661.2548828125, 10.546934127807617, 13482.4951171875)
}

local T = {
    enabled = false,
    grinding = false,
    schedulerRunning = false
}

-- ===== NO CLIP =====
local nc1, nc2, fixedY
local function noclip(on)
    S.noclip = on
    local c = LP.Character or LP.CharacterAdded:Wait()
    local hrp = c:WaitForChild("HumanoidRootPart", 5)
    local hum = c:WaitForChild("Humanoid", 5)
    if not hrp or not hum then return end
    if on then
        fixedY = hrp.Position.Y
        hum.JumpPower = 0
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        if not nc1 then nc1 = RS.Stepped:Connect(function()
            if S.noclip and LP.Character then for _, v in ipairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end end end
        end) end
        if not nc2 then nc2 = RS.Heartbeat:Connect(function()
            if not S.noclip then return end
            pcall(function()
                local char = LP.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                local h = char:FindFirstChildOfClass("Humanoid")
                if not root or not h then return end
                h.Jump = false
                if math.abs(root.Position.Y - fixedY) > 0.5 then
                    root.CFrame = CFrame.new(Vector3.new(root.Position.X, fixedY, root.Position.Z)) * root.CFrame.Rotation
                end
                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
            end)
        end) end
    else
        if nc1 then nc1:Disconnect(); nc1 = nil end
        if nc2 then nc2:Disconnect(); nc2 = nil end
        hum.JumpPower = 50; hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    end
end

-- ===== ANTI-AFK =====
local afkConn
local function antiAFK(on)
    if afkConn then afkConn:Disconnect(); afkConn = nil end
    if not on then return end
    afkConn = LP.Idled:Connect(function() pcall(function() VU:CaptureController(); VU:ClickButton2(Vector2.new()) end) end)
end
antiAFK(true)

-- ===== MOVEMENT =====
local activeTween = nil

local function isCloseEnough(hrp, orePos, threshold)
    if not hrp then return false end
    local d = Vector3.new(orePos.X - hrp.Position.X, 0, orePos.Z - hrp.Position.Z)
    return d.Magnitude <= threshold
end

local function tweenTo(pos)
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp then return end

    if isCloseEnough(hrp, pos, 3) then return end

    if activeTween then
        pcall(function() activeTween:Cancel() end)
        activeTween = nil
    end

    local target = CFrame.new(pos.X, pos.Y, pos.Z)
    local ti = TweenInfo.new(S.tweenSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tw = TS:Create(hrp, ti, {CFrame = target})
    activeTween = tw
    tw:Play()
    tw.Completed:Wait()
    activeTween = nil

    pcall(function() hrp.AssemblyLinearVelocity = Vector3.new() end)
    pcall(function()
        if hum then
            hum.PlatformStand = false
            hum.Sit = false
        end
    end)
end

local function moveToOre(orePos, hrp)
    if not orePos or not hrp then return end
    if isCloseEnough(hrp, orePos, 3) then return end
    pcall(tweenTo, Vector3.new(orePos.X, orePos.Y, orePos.Z))
end

-- ===== ORE DETECTION =====
local function isOreReady(ore)
    if not ore or not ore.Parent then return false end
    if not ore:FindFirstChild("Rock") then return false end
    local ui = ore:FindFirstChild("OresTopUI")
    if ui then local bar = ui:FindFirstChild("Bar")
        if bar then local hp = bar:FindFirstChild("Health")
            if hp and hp.Text == "Respawning..." then return false end
        end
    end
    return true
end

local function getOrePosition(ore)
    local rock = ore:FindFirstChild("Rock")
    if rock and rock:IsA("BasePart") then
        return rock.Position
    end
    for _, child in ipairs(ore:GetChildren()) do
        if child:IsA("BasePart") then return child.Position end
    end
    local ok, pivot = pcall(function() return ore:GetPivot() end)
    if ok and pivot then return pivot.Position end
    return nil
end

local function findBestOre()
    local gc = WS:FindFirstChild("__GAME_CONTENT")
    local of = gc and gc:FindFirstChild("Ores")
    if not of then return nil end
    for i = #ORES, 1, -1 do
        if S["m" .. ORES[i]] then
            local children = nil
            pcall(function() children = of:GetChildren() end)
            if not children then return nil end
            for _, o in ipairs(children) do
                if o.Name == ORES[i] and isOreReady(o) then return o end
            end
        end
    end
    return nil
end

local function isInMine()
    local gc = WS:FindFirstChild("__GAME_CONTENT")
    if not gc then return false end
    local of = gc:FindFirstChild("Ores")
    if not of then return false end
    local ok, children = pcall(function() return of:GetChildren() end)
    if not ok or not children then return false end
    return #children > 0
end

-- ===== MINING LOOP =====
local function loop()
    while S.running and not env.NIStop do
        if not isInMine() then task.wait(0.5); continue end

        local any = false
        for _, n in ipairs(ORES) do if S["m"..n] then any = true; break end end
        if not any then task.wait(0.3); continue end

        local ore = findBestOre()
        if not ore then task.wait(0.1); continue end

        local c = LP.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then task.wait(0.3); continue end

        local orePos = getOrePosition(ore)
        if not orePos then task.wait(0.1); continue end

        moveToOre(orePos, hrp)
        if not S.running or env.NIStop then break end

        local waitStart = tick()
        while S.running and not env.NIStop do
            local ready = false
            pcall(function() ready = isOreReady(ore) end)
            if not ready then break end
            if tick() - waitStart > 40 then break end
            task.wait(0.05)
        end
    end
end

-- ===== AUTO TRIAL SYSTEM =====
local function shouldJoinTrial()
    local currentTime = os.date("*t")
    local minute = currentTime.min
    local second = currentTime.sec
    -- Join at xx:29:10 or xx:59:10 (1 min before trial starts)
    return (minute == 29 or minute == 59) and second == 10
end

local function shouldStartGrind()
    local currentTime = os.date("*t")
    local minute = currentTime.min
    local second = currentTime.sec
    -- Start grind at xx:30:05 or xx:00:05 (5s after trial starts)
    return (minute == 0 or minute == 30) and second == 5
end

local function teleportToTrial()
    local char = LP.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    pcall(function()
        hrp.CFrame = CFrame.new(TRIAL_COORDS)
        pcall(function() hrp.AssemblyLinearVelocity = Vector3.new() end)
    end)
    
    return true
end

local function getMobCount()
    local gc = WS:FindFirstChild("__GAME_CONTENT")
    local trials = gc and gc:FindFirstChild("Trials")
    local mobs = trials and trials:FindFirstChild("Mobs")
    if not mobs then return 0 end
    
    local ok, children = pcall(function() return mobs:GetChildren() end)
    if not ok or not children then return 0 end
    
    local count = 0
    for _, mob in ipairs(children) do
        if mob.Parent then
            count = count + 1
        end
    end
    
    return count
end

local function grindTrial()
    T.grinding = true
    
    for i, coord in ipairs(MOB_COORDS) do
        if not T.enabled or not T.grinding or env.NIStop then break end
        
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then task.wait(0.5); continue end
        
        if not isCloseEnough(hrp, coord, 5) then
            pcall(function()
                hrp.CFrame = CFrame.new(coord)
                pcall(function() hrp.AssemblyLinearVelocity = Vector3.new() end)
            end)
        end
        
        local waitStart = tick()
        local countBefore = getMobCount()
        
        while T.enabled and T.grinding and not env.NIStop do
            local countAfter = getMobCount()
            if countAfter < countBefore then
                break
            end
            if tick() - waitStart > 45 then
                break
            end
            task.wait(0.1)
        end
        
        task.wait(0.5)
    end
    
    T.grinding = false
end

local function trialScheduler()
    T.schedulerRunning = true
    
    while T.enabled and not env.NIStop do
        if shouldJoinTrial() then
            if teleportToTrial() then
                Rayfield:Notify({
                    Title = "Auto Trial",
                    Content = "Joined Easy Trial!",
                    Duration = 5,
                    Image = "info"
                })
            end
            
            task.wait(60)
        elseif shouldStartGrind() then
            if not T.grinding then
                task.spawn(grindTrial)
            end
            
            task.wait(60)
        else
            task.wait(1)
        end
    end
    
    T.schedulerRunning = false
end

-- ===== RAYFIELD =====
local Rayfield = nil
local ok, result = pcall(function() return loadstring(game:HttpGet('https://sirius.menu/rayfield'))() end)
if ok and result then Rayfield = result end
if not Rayfield then
    ok, result = pcall(function() return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))() end)
    if ok and result then Rayfield = result end
end
if not Rayfield then warn("[Sqays Hub] Failed to load Rayfield UI"); return end

local Window = Rayfield:CreateWindow({
    Name = "Sqays Hub - " .. gameName,
    Icon = 0,
    LoadingTitle = "Made by Exotic",
    LoadingSubtitle = "Credits to Exotic | " .. execName,
    ShowText = "Sqays Hub",
    Theme = "DarkBlue",
    ToggleUIKeybind = Enum.KeyCode.K,
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SqaysHub",
        FileName = "Config"
    },
    Discord = {
        Enabled = true,
        Invite = "vV7Db9p2Zs",
        RememberJoins = false
    },
    KeySystem = true,
    KeySettings = {
        Title = "Sqays Hub",
        Subtitle = "Key System",
        Note = "discord.gg/vV7Db9p2Zs",
        FileName = "SqaysHubKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"Exotic"}
    }
})

local Main = Window:CreateTab("⛏ Mine")
local SetTab = Window:CreateTab("⚙ Settings")
local TrialTab = Window:CreateTab("⚔ Auto Trial")

-- Mining Tab
local tiers = {
    {"🔷 High Tier", {"Voidsteel","Celestium","Aetherite","Ruby","Infinity"}},
    {"🔶 Mid Tier",   {"Palladium","Cobalt","Uranium","Titanium","Platinum"}},
    {"🔹 Low Tier",   {"Gold","Silver","Iron","Copper","Coal","Stone"}},
}
for _, tier in ipairs(tiers) do
    Main:CreateSection(tier[1])
    for _, n in ipairs(tier[2]) do
        local flag = "m" .. n
        Main:CreateToggle({
            Name = n,
            CurrentValue = S[flag] or false,
            Flag = flag,
            Callback = function(v)
                S[flag] = v
                if v and not S.running then
                    if not isInMine() then
                        Rayfield:Notify({Title = "Sqays Hub", Content = "Enter the Mine realm first!", Duration = 4, Image = "info"})
                        S[flag] = false
                        return
                    end
                    S.running = true
                    task.spawn(loop)
                end
            end
        })
    end
end

-- Settings Tab
SetTab:CreateSection("Info")
SetTab:CreateParagraph({Title = "📋 Session", Content = "Executor: " .. execName .. "\nGame: " .. gameName .. "\nPlayer: " .. LP.Name .. "\n\n🔗 Discord: discord.gg/vV7Db9p2Zs"})

SetTab:CreateSection("Glide Speed")
SetTab:CreateSlider({
    Name = "Glide Speed (s)",
    Range = {0.2, 2},
    Increment = 0.1,
    CurrentValue = S.tweenSpeed,
    Callback = function(v) S.tweenSpeed = v end
})

SetTab:CreateSection("Ghost Mode")
SetTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v) noclip(v) end
})

-- Auto Trial Tab
TrialTab:CreateSection("Auto Trial")
TrialTab:CreateToggle({
    Name = "Enable Auto Trial",
    CurrentValue = false,
    Flag = "trialEnabled",
    Callback = function(v)
        T.enabled = v
        if v and not T.schedulerRunning then
            task.spawn(trialScheduler)
            Rayfield:Notify({
                Title = "Auto Trial",
                Content = "Auto Trial started! Will join at xx:29:10 or xx:59:10",
                Duration = 5,
                Image = "info"
            })
        end
    end
})

TrialTab:CreateSection("Info")
TrialTab:CreateParagraph({
    Title = "📋 Schedule",
    Content = "Auto-joins Easy Trial every 30 minutes:\n• xx:29:10 (1 min before xx:30:00)\n• xx:59:10 (1 min before xx:00:00)\n\nAuto-grind starts at:\n• xx:30:05 (5s after trial starts)\n• xx:00:05 (5s after trial starts)\n\nGrinds all 7 mobs in order"
})

Rayfield:LoadConfiguration()
task.wait(1)

Rayfield:Notify({
    Title = "Sqays Hub",
    Content = "🔗 Discord: discord.gg/vV7Db9p2Zs\nKey is in the Discord!",
    Duration = 10,
    Image = "info"
})

task.spawn(function()
    local flags = {}
    pcall(function() flags = Window.Flags or {} end)
    
    for _, n in ipairs(ORES) do
        local flag = "m" .. n
        if flags[flag] then S[flag] = true end
    end
    
    if flags.trialEnabled then T.enabled = true end
    
    local any = false; for _, n in ipairs(ORES) do if S["m"..n] then any = true; break end end
    if any and isInMine() then
        task.wait(2)
        S.running = true; task.spawn(loop)
    end
    
    if T.enabled then
        task.wait(2)
        task.spawn(trialScheduler)
    end
end)

print("[Sqays Hub] Ready - " .. execName .. " | " .. gameName)
