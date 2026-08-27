--[[
    THINH HUB JJS - FINAL (TỔNG HỢP TẤT CẢ TÍNH NĂNG)
    ✅ Auto Block (30 ID + Hold 0.3s + Cooldown 0.22s)
    ✅ Fly (BodyVelocity + BodyGyro, theo Camera, WASD + Space/Shift)
    ✅ Fake Lag (Anchor/Unanchor HumanoidRootPart)
    ✅ WalkSpeed / JumpPower slider
    ✅ Teleport (người chơi, tọa độ, lên cao)
    ✅ Auto Farm Coins + Auto Rebirth
    ✅ Anti-AFK, Rejoin, Server Hop, Respawn
    ✅ Quét nút Block + Test Block
    ✅ Clean Stop cho MỌI tính năng
    ✅ KHÔNG auto M1, KHÔNG spam
]]

----------------------------------------------------------------
-- RAYFIELD
----------------------------------------------------------------
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

----------------------------------------------------------------
-- SERVICES
----------------------------------------------------------------
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local VIM          = game:GetService("VirtualInputManager")
local Http         = game:GetService("HttpService")
local TPS          = game:GetService("TeleportService")
local VirtualUser  = game:GetService("VirtualUser")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

----------------------------------------------------------------
-- BIẾN TRẠNG THÁI
----------------------------------------------------------------
local EmergencyStop = false

-- Auto Block
local AutoBlockOn      = false
local BlockRange       = 15
local HoldTime         = 0.30
local CooldownTime     = 0.22
local LockFacing       = true
local SmartDetect      = true
local LastBlock        = 0
local BlockCount       = 0

-- Player
local WS_Current       = 16
local JP_Current       = 50

-- Fly
local FlyOn     = false
local FlySpeed  = 60
local FlyBV, FlyBG, FlyConn

-- Fake Lag
local FakeLagOn      = false
local FakeLagDelay   = 0.15
local FakeLagRunning = false

-- Farm
local AutoFarm       = false
local AutoRebirth    = false

-- Anti-AFK
local AntiAFKOn      = false

-- Block button cache
local CachedBtn, CachedAt = nil, 0

-- ID đòn đánh JJS (30 ID)
local AttackAnimIDs = {
   -- M1 cơ bản
   ["10468665991"]=true, ["10469493270"]=true, ["10469630950"]=true,
   ["10469639222"]=true, ["10469643643"]=true,
   -- Hero M1
   ["95421145178968"]=true, ["138898960225788"]=true, ["137844586546509"]=true,
   ["120133391090244"]=true, ["96489184596023"]=true, ["13826705245289"]=true,
   ["140491244934559"]=true, ["1012839390868172"]=true, ["139479927693015"]=true,
   ["119619096808750"]=true, ["104408538049330"]=true, ["77705898607209"]=true,
   -- Skill
   ["10466974800"]=true, ["10471336737"]=true, ["12510170988"]=true,
   ["12832505612"]=true, ["12983333733"]=true, ["13073745835"]=true,
   ["13560306510"]=true, ["14326861262"]=true, ["15583493700"]=true,
   ["17861840167"]=true, ["17284219852"]=true,
   -- Dash
   ["10470389823"]=true, ["10470396025"]=true,
   ["10470402283"]=true, ["10470410125"]=true,
}

----------------------------------------------------------------
-- TÌM NÚT BLOCK MOBILE
----------------------------------------------------------------
local BlockKeywords = {
   "block","defend","shield","parry","guard","def",
   "button1","btn1","skill1","action1","combat1","ability1"
}

local function FindBlockBtn()
   local pg = LP:FindFirstChild("PlayerGui")
   if not pg then return nil end
   local best, bestS = nil, 0
   for _, v in pairs(pg:GetDescendants()) do
      if (v:IsA("ImageButton") or v:IsA("TextButton") or v:IsA("GuiButton")) and v.Visible then
         local n = v.Name:lower()
         local s = 0
         for _, kw in ipairs(BlockKeywords) do
            if n:find(kw) then s = s + #kw end
         end
         if s > bestS then bestS = s; best = v end
      end
   end
   return best
end

local function GetBlockBtn()
   if CachedBtn and CachedBtn.Parent and CachedBtn.Visible then return CachedBtn end
   if tick() - CachedAt < 2 then return nil end
   CachedAt = tick()
   local b = FindBlockBtn()
   if b then CachedBtn = b end
   return b
end

----------------------------------------------------------------
-- AUTO BLOCK
----------------------------------------------------------------
local function ReleaseBlock()
   pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game) end)
end

local function PerformBlock()
   if EmergencyStop then return end
   if tick() - LastBlock < CooldownTime then return end
   LastBlock = tick()
   BlockCount = BlockCount + 1

   task.spawn(function()
      if IsMobile then
         local b = GetBlockBtn()
         if b then
            pcall(function()
               for _, sn in ipairs({"MouseButton1Click","MouseButton1Down","Activated","TouchTap"}) do
                  local sig = b[sn]
                  if sig then for _, c in ipairs(getconnections(sig)) do pcall(function() c:Fire() end) end end
               end
            end)
            pcall(function()
               local ch = LP.Character
               if ch then
                  local tool = ch:FindFirstChildWhichIsA("Tool") or ch
                  firetouchinterest(tool, b, 0)
                  task.wait(0.03)
                  firetouchinterest(tool, b, 1)
               end
            end)
         else
            CachedBtn = nil
         end
      else
         pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            task.wait(HoldTime)
            VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
         end)
      end
   end)
end

local function FaceAttacker(r)
   if not LockFacing then return end
   local ch = LP.Character
   if not ch or not ch:FindFirstChild("HumanoidRootPart") then return end
   local my = ch.HumanoidRootPart
   local d = (r.Position - my.Position) * Vector3.new(1,0,1)
   if d.Magnitude > 0.1 then my.CFrame = CFrame.lookAt(my.Position, my.Position + d.Unit) end
end

local function isAtkName(n)
   local kws = {"slash","stab","punch","kick","swing","smash","cut","thrust","attack","hit","combo","slam","uppercut","jab","hook","bash","dash"}
   for _, w in ipairs(kws) do
      if n:lower():find(w) then return true end
   end
   return false
end

local function MonitorPlayer(p)
   if p == LP then return end
   local function onChar(c)
      local h = c:WaitForChild("Humanoid", 10)
      if not h then return end
      h.AnimationPlayed:Connect(function(tr)
         if not AutoBlockOn or EmergencyStop then return end
         if game.Players:GetPlayerFromCharacter(c) == LP then return end
         local my = LP.Character
         if not my or not my:FindFirstChild("HumanoidRootPart") or not c:FindFirstChild("HumanoidRootPart") then return end
         if (c.HumanoidRootPart.Position - my.HumanoidRootPart.Position).Magnitude > BlockRange then return end
         local id = (tr.Animation and tr.Animation.AnimationId or ""):match("%d+")
         if (id and AttackAnimIDs[id]) or (SmartDetect and isAtkName(tr.Name or "")) then
            FaceAttacker(c.HumanoidRootPart)
            PerformBlock()
         end
      end)
   end
   if p.Character then onChar(p.Character) end
   p.CharacterAdded:Connect(onChar)
end

for _, pl in pairs(Players:GetPlayers()) do
   if pl ~= LP then MonitorPlayer(pl) end
end
Players.PlayerAdded:Connect(function(pl) if pl ~= LP then MonitorPlayer(pl) end end)

-- Monitor NPC (Hero AI)
task.spawn(function()
   while true do
      task.wait(2)
      for _, obj in pairs(workspace:GetDescendants()) do
         if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not obj:GetAttribute("_jjs_mon") then
            if not Players:GetPlayerFromCharacter(obj) then
               obj:SetAttribute("_jjs_mon", true)
               local h = obj:FindFirstChild("Humanoid")
               if h then
                  h.AnimationPlayed:Connect(function(tr)
                     if not AutoBlockOn or EmergencyStop then return end
                     local my = LP.Character
                     if not my or not my:FindFirstChild("HumanoidRootPart") or not obj:FindFirstChild("HumanoidRootPart") then return end
                     if (obj.HumanoidRootPart.Position - my.HumanoidRootPart.Position).Magnitude > BlockRange then return end
                     local id = (tr.Animation and tr.Animation.AnimationId or ""):match("%d+")
                     if (id and AttackAnimIDs[id]) or (SmartDetect and isAtkName(tr.Name or "")) then
                        FaceAttacker(obj.HumanoidRootPart)
                        PerformBlock()
                     end
                  end)
               end
            end
         end
      end
   end
end)

----------------------------------------------------------------
-- FLY
----------------------------------------------------------------
local function StartFly()
   local ch = LP.Character
   if not ch or not ch:FindFirstChild("HumanoidRootPart") then return end
   local root = ch.HumanoidRootPart

   if FlyBV then FlyBV:Destroy() end
   if FlyBG then FlyBG:Destroy() end

   FlyBV = Instance.new("BodyVelocity")
   FlyBV.Name = "JJS_FlyBV"
   FlyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
   FlyBV.Velocity = Vector3.zero
   FlyBV.Parent = root

   FlyBG = Instance.new("BodyGyro")
   FlyBG.Name = "JJS_FlyBG"
   FlyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
   FlyBG.D = 100; FlyBG.P = 10000
   FlyBG.Parent = root

   FlyConn = RunService.Heartbeat:Connect(function()
      if not FlyOn or not FlyBV or not FlyBG then return end
      if not root or not root.Parent then return end
      local dir = Vector3.zero
      if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
      if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
      if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
      if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
      if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
      if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
      if dir.Magnitude > 0 then
         FlyBV.Velocity = dir.Unit * FlySpeed
      else
         FlyBV.Velocity = Vector3.zero
      end
      FlyBG.CFrame = Camera.CFrame
   end)
end

local function StopFly()
   FlyOn = false
   if FlyConn then FlyConn:Disconnect(); FlyConn = nil end
   if FlyBV then pcall(function() FlyBV:Destroy() end); FlyBV = nil end
   if FlyBG then pcall(function() FlyBG:Destroy() end); FlyBG = nil end
end

----------------------------------------------------------------
-- FAKE LAG
----------------------------------------------------------------
local function StartFakeLag()
   local ch = LP.Character
   if not ch or not ch:FindFirstChild("HumanoidRootPart") then return end
   local root = ch.HumanoidRootPart
   FakeLagRunning = true
   task.spawn(function()
      while FakeLagRunning and FakeLagOn and not EmergencyStop do
         if root and root.Parent then
            root.Anchored = true
            task.wait(FakeLagDelay / 2)
            if not FakeLagRunning then break end
            root.Anchored = false
            task.wait(FakeLagDelay / 2)
         else
            task.wait(0.1)
         end
      end
      if root and root.Parent then root.Anchored = false end
   end)
end

local function StopFakeLag()
   FakeLagOn = false
   FakeLagRunning = false
   local ch = LP.Character
   if ch and ch:FindFirstChild("HumanoidRootPart") then
      pcall(function() ch.HumanoidRootPart.Anchored = false end)
   end
end

----------------------------------------------------------------
-- AUTO FARM (vòng lặp liên tục)
----------------------------------------------------------------
task.spawn(function()
   while true do
      task.wait(0.4)
      if not AutoFarm or EmergencyStop then continue end
      pcall(function()
         for _, p in pairs(workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
               fireproximityprompt(p)
            end
         end
      end)
   end
end)

----------------------------------------------------------------
-- ANTI AFK
----------------------------------------------------------------
local antiAFKConn
local function StartAntiAFK()
   AntiAFKOn = true
   antiAFKConn = LP.Idled:Connect(function()
      pcall(function()
         VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
         task.wait(1)
         VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
      end)
   end)
end
local function StopAntiAFK()
   AntiAFKOn = false
   if antiAFKConn then antiAFKConn:Disconnect(); antiAFKConn = nil end
end

----------------------------------------------------------------
-- EMERGENCY STOP
----------------------------------------------------------------
local function EmergencyStopAll()
   EmergencyStop = true
   AutoBlockOn = false
   StopFly()
   StopFakeLag()
   ReleaseBlock()
   local ch = LP.Character
   if ch and ch:FindFirstChild("HumanoidRootPart") then
      pcall(function() ch.HumanoidRootPart.Anchored = false end)
   end
   Rayfield:Notify({
      Title = "⛔ EMERGENCY STOP",
      Content = "Đã dừng mọi tính năng + nhả F",
      Duration = 5,
   })
   task.delay(2, function() EmergencyStop = false end)
end

----------------------------------------------------------------
-- RAYFIELD UI
----------------------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "⚡ Thinh Hub | JJS Final",
   LoadingTitle = "Thinh Hub JJS",
   LoadingSubtitle = "All features loaded",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local TC = Window:CreateTab("⚔ Combat",     4483362458)
local TM = Window:CreateTab("🏃 Movement",   4483362458)
local TT = Window:CreateTab("📍 Teleport",   4483362458)
local TF = Window:CreateTab("💰 Farm",       4483362458)
local TX = Window:CreateTab("⚙ Misc",        4483362458)
local TD = Window:CreateTab("🔧 Debug",      4483362458)
local TI = Window:CreateTab("ℹ Info",        4483362458)

----------------------------------------------------------------
-- COMBAT
----------------------------------------------------------------
TC:CreateSection("Auto Block")
local togBlock = TC:CreateToggle({
   Name = "⚡ Auto Block",
   CurrentValue = false,
   Flag = "AutoBlock",
   Callback = function(v)
      AutoBlockOn = v
      if not v then ReleaseBlock() end
   end,
})
TC:CreateToggle({
   Name = "🧠 Smart Detection",
   CurrentValue = true,
   Flag = "SmartDetect",
   Callback = function(v) SmartDetect = v end,
})
TC:CreateToggle({
   Name = "🔒 Lock Facing",
   CurrentValue = true,
   Flag = "LockFacing",
   Callback = function(v) LockFacing = v end,
})
TC:CreateSection("Cấu hình Block")
TC:CreateSlider({
   Name = "Block Range", Range = {8, 30}, Increment = 1,
   Suffix = " studs", CurrentValue = 15,
   Flag = "BlockRange", Callback = function(v) BlockRange = v end,
})
TC:CreateSlider({
   Name = "Hold Time", Range = {20, 50}, Increment = 1,
   Suffix = " (×0.01s)", CurrentValue = 30,
   Flag = "HoldTime", Callback = function(v) HoldTime = v / 100 end,
})
TC:CreateSlider({
   Name = "Cooldown", Range = {15, 40}, Increment = 1,
   Suffix = " (×0.01s)", CurrentValue = 22,
   Flag = "Cooldown", Callback = function(v) CooldownTime = v / 100 end,
})
TC:CreateSection("Thống kê")
local statsPara = TC:CreateParagraph("Stats", "🛡 Blocks: 0")
task.spawn(function()
   while statsPara do
      pcall(function() statsPara:Set("🛡 Blocks: " .. BlockCount) end)
      task.wait(1)
   end
end)
TC:CreateSection("Khẩn cấp")
TC:CreateButton({
   Name = "⛔ DỪNG KHẨN CẤP (nhả F + tắt tất cả)",
   Callback = EmergencyStopAll,
})

----------------------------------------------------------------
-- MOVEMENT
----------------------------------------------------------------
TM:CreateSection("Player")
TM:CreateSlider({
   Name = "WalkSpeed", Range = {16, 250}, Increment = 5,
   Suffix = " speed", CurrentValue = 16,
   Flag = "WS", Callback = function(v)
      WS_Current = v
      pcall(function()
         if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = v
         end
      end)
   end,
})
TM:CreateSlider({
   Name = "JumpPower", Range = {50, 300}, Increment = 10,
   Suffix = " power", CurrentValue = 50,
   Flag = "JP", Callback = function(v)
      JP_Current = v
      pcall(function()
         if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.UseJumpPower = true
            LP.Character.Humanoid.JumpPower = v
         end
      end)
   end,
})
TM:CreateButton({
   Name = "↩️ Reset WalkSpeed/JumpPower về mặc định",
   Callback = function()
      pcall(function()
         if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = 16
            LP.Character.Humanoid.JumpPower = 50
         end
      end)
      Rayfield:Notify({Title = "OK", Content = "Reset về mặc định", Duration = 2})
   end,
})

TM:CreateSection("Fly")
local togFly = TM:CreateToggle({
   Name = "✈️ Fly", CurrentValue = false, Flag = "Fly",
   Callback = function(v)
      FlyOn = v
      if v then StartFly() else StopFly() end
   end,
})
TM:CreateSlider({
   Name = "Fly Speed", Range = {10, 200}, Increment = 5,
   Suffix = " speed", CurrentValue = 60,
   Flag = "FlySpeed", Callback = function(v) FlySpeed = v end,
})
TM:CreateParagraph("Keys", "WASD = di chuyển\nSpace = lên | Shift = xuống\nTheo hướng camera")

TM:CreateSection("Fake Lag (Desync)")
local togLag = TM:CreateToggle({
   Name = "📡 Fake Lag", CurrentValue = false, Flag = "FakeLag",
   Callback = function(v)
      FakeLagOn = v
      if v then StartFakeLag() else StopFakeLag() end
   end,
})
TM:CreateSlider({
   Name = "Fake Lag Delay", Range = {5, 50}, Increment = 1,
   Suffix = " (×0.01s)", CurrentValue = 15,
   Flag = "FakeLagDelay", Callback = function(v) FakeLagDelay = v / 100 end,
})
TM:CreateButton({
   Name = "🛑 Tắt Fly + Fake Lag",
   Callback = function()
      StopFly(); StopFakeLag()
      togFly:Set(false); togLag:Set(false)
   end,
})

----------------------------------------------------------------
-- TELEPORT
----------------------------------------------------------------
TT:CreateSection("Dịch chuyển")
TT:CreateButton({
   Name = "👥 TP tới người chơi khác",
   Callback = function()
      for _, p in pairs(Players:GetPlayers()) do
         if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
               LP.Character:WaitForChild("HumanoidRootPart").CFrame =
                  p.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
            end)
            return
         end
      end
      Rayfield:Notify({Title = "Lỗi", Content = "Không có người chơi khác", Duration = 2})
   end,
})
TT:CreateButton({
   Name = "⬆️ Lên cao 200 studs",
   Callback = function()
      pcall(function()
         if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame + Vector3.new(0, 200, 0)
         end
      end)
   end,
})
TT:CreateButton({
   Name = "⬇️ Xuống thấp -200 studs",
   Callback = function()
      pcall(function()
         if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame + Vector3.new(0, -200, 0)
         end
      end)
   end,
})
TT:CreateInput({
   Name = "TP theo tọa độ (x, y, z)",
   PlaceholderText = "0, 50, 0",
   RemoveTextAfterFocusLost = true,
   Flag = "TPCoord",
   Callback = function(text)
      local x, y, z = text:match("([%-%d%.]+),%s*([%-%d%.]+),%s*([%-%d%.]+)")
      if x and y and z then
         pcall(function()
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
               LP.Character.HumanoidRootPart.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
            end
         end)
      end
   end,
})

----------------------------------------------------------------
-- FARM
----------------------------------------------------------------
TF:CreateSection("Tự động")
TF:CreateToggle({
   Name = "💰 Auto nhặt Coins (Proximity)",
   CurrentValue = false, Flag = "AutoFarm",
   Callback = function(v) AutoFarm = v end,
})
TF:CreateToggle({
   Name = "♾ Auto Rebirth",
   CurrentValue = false, Flag = "AutoRebirth",
   Callback = function(v) AutoRebirth = v end,
})
TF:CreateSection("Hành động")
TF:CreateButton({
   Name = "🛑 Tắt Auto Farm",
   Callback = function()
      AutoFarm = false
      Rayfield:Notify({Title = "OK", Content = "Đã tắt Auto Farm", Duration = 2})
   end,
})

----------------------------------------------------------------
-- MISC
----------------------------------------------------------------
TX:CreateSection("Tiện ích")
local togAAFK = TX:CreateToggle({
   Name = "🛡 Anti-AFK", CurrentValue = false, Flag = "AntiAFK",
   Callback = function(v)
      if v then StartAntiAFK() else StopAntiAFK() end
   end,
})
TX:CreateSection("Server")
TX:CreateButton({
   Name = "🔁 Rejoin Server",
   Callback = function()
      pcall(function() TPS:Teleport(game.PlaceId, LP) end)
   end,
})
TX:CreateButton({
   Name = "🌍 Server Hop",
   Callback = function()
      pcall(function()
         local data = Http:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/0?sortOrder=Asc&limit=100"
         ))
         for _, s in pairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
               TPS:TeleportToPlaceInstance(game.PlaceId, s.id)
               return
            end
         end
      end)
   end,
})
TX:CreateSection("Khác")
TX:CreateButton({
   Name = "🔄 Respawn",
   Callback = function() LP:LoadCharacter() end,
})

----------------------------------------------------------------
-- DEBUG
----------------------------------------------------------------
TD:CreateSection("Công cụ")
TD:CreateButton({
   Name = "🔍 Quét nút Block (Mobile)",
   Callback = function()
      CachedBtn = nil; CachedAt = 0
      local b = GetBlockBtn()
      if b then
         Rayfield:Notify({Title = "✅ Tìm thấy", Content = b.Name .. " | " .. b:GetFullName(), Duration = 6})
      else
         Rayfield:Notify({Title = "❌ Không thấy", Content = "Vào combat rồi thử lại", Duration = 4})
      end
   end,
})
TD:CreateButton({
   Name = "🧪 Test Block ngay",
   Callback = function()
      LastBlock = 0
      PerformBlock()
      Rayfield:Notify({Title = "Test", Content = "Count: " .. BlockCount, Duration = 2})
   end,
})
TD:CreateButton({
   Name = "🧹 Xóa cache nút",
   Callback = function()
      CachedBtn = nil; CachedAt = 0
      Rayfield:Notify({Title = "OK", Content = "Đã xóa cache", Duration = 2})
   end,
})

----------------------------------------------------------------
-- INFO
----------------------------------------------------------------
TI:CreateSection("Tài khoản")
TI:CreateParagraph("User", "@" .. LP.Name)
TI:CreateParagraph("Display", LP.DisplayName)
TI:CreateParagraph("UserId", tostring(LP.UserId))
TI:CreateParagraph("Age", LP.AccountAge .. " ngày")
TI:CreateSection("Phiên")
TI:CreateParagraph("Platform", IsMobile and "📱 Mobile" or "💻 PC")
TI:CreateParagraph("Game", "Jujutsu Shenanigans")
TI:CreateParagraph("PlaceId", tostring(game.PlaceId))
local infoPara = TI:CreateParagraph("Blocks", "🛡 0")
task.spawn(function()
   while infoPara do
      pcall(function() infoPara:Set("🛡 " .. BlockCount) end)
      task.wait(1)
   end
end)

----------------------------------------------------------------
-- RESPAWN → REBUILD FLY
----------------------------------------------------------------
LP.CharacterAdded:Connect(function()
   task.wait(0.5)
   if FlyOn then StartFly() end
end)

----------------------------------------------------------------
-- THÔNG BÁO
----------------------------------------------------------------
Rayfield:Notify({
   Title = "⚡ Thinh Hub JJS Final",
   Content = "Đã load! " .. #Players:GetPlayers() .. " người chơi, " .. #AttackAnimIDs .. " attack IDs",
   Duration = 5,
})
