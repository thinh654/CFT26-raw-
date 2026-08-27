--[[
    AUTO BLOCK V5 - RAYFIELD (MENU CŨ DARK STYLE)
    ✅ Sửa lỗi unblock sớm - giữ F đủ thời gian để đỡ trọn đòn
    ✅ Hold Duration 0.3-0.8s (mặc định 0.5s)
    ✅ Cooldown 0.15-0.2s
    ✅ Smart Dynamic Detection
    ✅ Mobile + Clean Stop
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
local LP           = Players.LocalPlayer
local Camera       = workspace.CurrentCamera
local IsMobile     = UIS.TouchEnabled and not UIS.KeyboardEnabled

----------------------------------------------------------------
-- BIẾN
----------------------------------------------------------------
local AutoBlockOn   = false
local BlockRange    = 15
local HoldDuration  = 0.5    -- GIỮ F trong 0.5s (mặc định)
local CooldownTime  = 0.18   -- Nghỉ 0.18s giữa 2 lần block
local SmartDetect   = true
local LockFacing    = true
local EmergencyStop = false

local LastBlock  = 0
local BlockCount = 0

----------------------------------------------------------------
-- BẢNG ID ĐÒN ĐÁNH JJS (đầy đủ)
----------------------------------------------------------------
local AttackAnimIDs = {
   -- M1 cơ bản (chuỗi 5 đòn)
   ["10468665991"]=true, ["10469493270"]=true, ["10469630950"]=true,
   ["10469639222"]=true, ["10469643643"]=true,
   -- Hero M1 khác
   ["95421145178968"]=true, ["138898960225788"]=true, ["137844586546509"]=true,
   ["120133391090244"]=true, ["96489184596023"]=true, ["13826705245289"]=true,
   ["140491244934559"]=true, ["1012839390868172"]=true, ["139479927693015"]=true,
   ["119619096808750"]=true, ["104408538049330"]=true, ["77705898607209"]=true,
   -- Skill đặc biệt
   ["10466974800"]=true, ["10471336737"]=true, ["12510170988"]=true,
   ["12832505612"]=true, ["12983333733"]=true, ["13073745835"]=true,
   ["13560306510"]=true, ["14326861262"]=true, ["15583493700"]=true,
   ["17861840167"]=true, ["17284219852"]=true,
   -- Dash
   ["10470389823"]=true, ["10470396025"]=true,
   ["10470402283"]=true, ["10470410125"]=true,
}

-- Từ khóa CHẮC CHẮN là đòn đánh (Smart Detect)
local AttackKeywords = {
   "slash","stab","punch","kick","swing","smash","cut","thrust",
   "slice","attack","hit","combo","slam","uppercut","jab","hook",
   "bash","cleave","impale","spin"
}

-- Từ khóa BỎ QUA (không phải đòn)
local SafeKeywords = {
   "walk","run","idle","jump","fall","land","swim","dash","climb",
   "strafe","turn","sprint","emote","sit","sleep","death","die",
   "hurt","stun","block","defend","parry","heal","buff"
}

----------------------------------------------------------------
-- TÌM NÚT BLOCK MOBILE
----------------------------------------------------------------
local BlockKeywords = {
   "block","defend","shield","parry","guard","def",
   "button1","btn1","skill1","action1","combat1","ability1"
}
local CachedBtn, CachedAt = nil, 0
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
-- PERFORM BLOCK - FIX UNBLOCK SỚM
-- Logic mới: bấm F → GIỮ HoldDuration → nhả F (chỉ nhả sau khi giữ đủ)
----------------------------------------------------------------
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
         -- PC: BẤM F → GIỮ đủ HoldDuration → NHẢ F
         -- FIX UNBLOCK SỚM: KHÔNG nhả F trước khi đòn hoàn tất
         pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            -- Giữ F đúng số giây người dùng cài (0.3-0.8s)
            task.wait(HoldDuration)
            -- CHỈ nhả F sau khi đã giữ đủ thời gian
            VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
         end)
      end
   end)
end

-- Hàm nhả F khẩn cấp (dùng khi tắt toggle / emergency)
local function ReleaseBlock()
   pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game) end)
end

----------------------------------------------------------------
-- SMART DETECTION
----------------------------------------------------------------
local function isSafeName(name)
   local n = name:lower()
   for _, w in ipairs(SafeKeywords) do
      if n:find(w) then return true end
   end
   return false
end

local function isAttackName(name)
   local n = name:lower()
   for _, w in ipairs(AttackKeywords) do
      if n:find(w) then return true end
   end
   return false
end

----------------------------------------------------------------
-- MONITOR PLAYER + NPC
----------------------------------------------------------------
local function FaceAttacker(r)
   if not LockFacing then return end
   local ch = LP.Character
   if not ch or not ch:FindFirstChild("HumanoidRootPart") then return end
   local my = ch.HumanoidRootPart
   local d = (r.Position - my.Position) * Vector3.new(1,0,1)
   if d.Magnitude > 0.1 then my.CFrame = CFrame.lookAt(my.Position, my.Position + d.Unit) end
end

local function shouldBlock(track, c)
   local id = (track.Animation and track.Animation.AnimationId or ""):match("%d+")
   local name = track.Name or ""

   -- Bỏ qua nếu tên an toàn
   if isSafeName(name) then return false end

   -- Nhánh 1: ID thuộc danh sách → BLOCK
   if id and AttackAnimIDs[id] then return true end

   -- Nhánh 2: Smart detect - tên có từ khóa đòn đánh
   if SmartDetect and isAttackName(name) then return true end

   return false
end

local function MonitorCharacter(c)
   local h = c:FindFirstChild("Humanoid")
   if not h then
      h = c:WaitForChild("Humanoid", 5)
      if not h then return end
   end

   h.AnimationPlayed:Connect(function(track)
      if not AutoBlockOn or EmergencyStop then return end
      if game.Players:GetPlayerFromCharacter(c) == LP then return end

      local my = LP.Character
      if not my or not my:FindFirstChild("HumanoidRootPart") or not c:FindFirstChild("HumanoidRootPart") then return end

      local dist = (c.HumanoidRootPart.Position - my.HumanoidRootPart.Position).Magnitude
      if dist > BlockRange then return end

      if shouldBlock(track, c) then
         FaceAttacker(c.HumanoidRootPart)
         PerformBlock()
      end
   end)
end

local function MonitorPlayer(p)
   if p == LP then return end
   if p.Character then MonitorCharacter(p.Character) end
   p.CharacterAdded:Connect(MonitorCharacter)
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
         if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not obj:GetAttribute("_mon") then
            if not Players:GetPlayerFromCharacter(obj) then
               obj:SetAttribute("_mon", true)
               MonitorCharacter(obj)
            end
         end
      end
   end
end)

----------------------------------------------------------------
-- EMERGENCY STOP
----------------------------------------------------------------
local function EmergencyStopAll()
   EmergencyStop = true
   AutoBlockOn = false
   ReleaseBlock()
   ReleaseBlock()  -- 2 lần cho chắc
   Rayfield:Notify({
      Title = "⛔ EMERGENCY STOP",
      Content = "Đã dừng Auto Block + nhả F",
      Duration = 4,
   })
   task.delay(2, function() EmergencyStop = false end)
end

----------------------------------------------------------------
-- RAYFIELD UI (giữ style menu cũ)
----------------------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "⚡ Auto Block V5 | JJS",
   LoadingTitle = "Auto Block V5",
   LoadingSubtitle = "by Thinh Hub",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

-- Theme colors (giống menu cũ)
local Tab = Window:CreateTab("⚔ Combat", 4483362458)

----------------------------------------------------------------
-- COMBAT TAB
----------------------------------------------------------------
Tab:CreateSection("Auto Block V5")

local togBlock = Tab:CreateToggle({
   Name = "⚡ Auto Block V5",
   CurrentValue = false,
   Flag = "AutoBlock",
   Callback = function(v)
      AutoBlockOn = v
      -- CLEAN STOP: nhả F ngay khi tắt
      if not v then ReleaseBlock() end
   end,
})

Tab:CreateToggle({
   Name = "🧠 Smart Dynamic Detection",
   CurrentValue = true,
   Flag = "SmartDetect",
   Callback = function(v) SmartDetect = v end,
})

Tab:CreateToggle({
   Name = "🔒 Lock Facing (đứng yên + xoay mặt)",
   CurrentValue = true,
   Flag = "LockFacing",
   Callback = function(v) LockFacing = v end,
})

Tab:CreateSection("Cấu hình Block")

Tab:CreateSlider({
   Name = "Block Range",
   Range = {8, 25},
   Increment = 1,
   Suffix = " studs",
   CurrentValue = 15,
   Flag = "BlockRange",
   Callback = function(v) BlockRange = v end,
})

Tab:CreateSlider({
   Name = "Block Hold Duration",
   Range = {30, 80},
   Increment = 1,
   Suffix = " (×0.01s)",
   CurrentValue = 50,  -- MẶC ĐỊNH 0.5s
   Flag = "HoldDuration",
   Callback = function(v) HoldDuration = v / 100 end,
})

Tab:CreateSlider({
   Name = "Cooldown giữa 2 lần block",
   Range = {15, 20},
   Increment = 1,
   Suffix = " (×0.01s)",
   CurrentValue = 18,  -- MẶC ĐỊNH 0.18s
   Flag = "Cooldown",
   Callback = function(v) CooldownTime = v / 100 end,
})

Tab:CreateSection("Thống kê")

local statsPara = Tab:CreateParagraph("Stats", "🛡 Blocks đã đỡ: 0")
task.spawn(function()
   while statsPara do
      pcall(function() statsPara:Set("🛡 Blocks đã đỡ: " .. BlockCount) end)
      task.wait(1)
   end
end)

local holdPara = Tab:CreateParagraph("Current", "⏱ Hold: 0.50s | 🕐 CD: 0.18s | 🎯 Range: 15")
task.spawn(function()
   while holdPara do
      pcall(function()
         holdPara:Set(string.format("⏱ Hold: %.2fs | 🕐 CD: %.2fs | 🎯 Range: %d",
            HoldDuration, CooldownTime, BlockRange))
      end)
      task.wait(0.5)
   end
end)

Tab:CreateSection("Khẩn cấp")
Tab:CreateButton({
   Name = "⛔ DỪNG KHẨN CẤP (nhả F + tắt Auto Block)",
   Callback = EmergencyStopAll,
})

----------------------------------------------------------------
-- THÔNG BÁO
----------------------------------------------------------------
Rayfield:Notify({
   Title = "⚡ Auto Block V5",
   Content = "Loaded! " .. #AttackAnimIDs .. " attack IDs | Hold: 0.5s | CD: 0.18s",
   Duration = 5,
})
