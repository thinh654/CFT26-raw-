--[[
    THINH HUB V1 - DARK STYLE + LOADING 10s + FIX AUTO BLOCK
    - Loading 10 giây
    - Menu tối, tabs dọc trái
    - Toggle xanh lá bên phải
    - Auto block KHÔNG đỡ khi user tự đánh
]]

local LP = game.Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

local function C(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 4); c.Parent = p end
local function S(p, col, t) local s = Instance.new("UIStroke"); s.Color = col or Color3.fromRGB(50,50,60); s.Thickness = t or 1; s.Parent = p end

-- Màu theme tối
local C_BG       = Color3.fromRGB(20, 22, 28)      -- nền chính
local C_SIDE     = Color3.fromRGB(15, 17, 22)      -- sidebar
local C_TAB_OFF  = Color3.fromRGB(15, 17, 22)      -- tab không chọn
local C_TAB_ON   = Color3.fromRGB(28, 32, 42)      -- tab đang chọn
local C_ROW      = Color3.fromRGB(30, 34, 44)      -- row content
local C_TOGGLE_ON  = Color3.fromRGB(50, 200, 100)  -- toggle bật
local C_TOGGLE_OFF = Color3.fromRGB(60, 65, 80)    -- toggle tắt
local C_ACCENT   = Color3.fromRGB(70, 150, 255)    -- xanh dương (gạch chân)
local C_TXT      = Color3.fromRGB(220, 225, 235)
local C_TXT_DIM  = Color3.fromRGB(140, 145, 160)

----------------------------------------------------------------
-- LOADING 10 GIÂY
----------------------------------------------------------------
do
   local L = Instance.new("ScreenGui"); L.IgnoreGuiInset = true; L.DisplayOrder = 1000; L.Parent = PG
   local BG = Instance.new("Frame"); BG.Size = UDim2.fromScale(1,1); BG.BackgroundColor3 = Color3.fromRGB(8,10,15); BG.BorderSizePixel = 0; BG.Parent = L

   local Card = Instance.new("Frame")
   Card.AnchorPoint = Vector2.new(0.5,0.5); Card.Position = UDim2.fromScale(0.5,0.5)
   Card.Size = UDim2.new(0, 460, 0, 280)
   Card.BackgroundColor3 = Color3.fromRGB(20, 22, 28); Card.BorderSizePixel = 0
   Card.Parent = BG
   C(Card, 12); S(Card, Color3.fromRGB(50, 50, 60), 1)

   local Tit = Instance.new("TextLabel"); Tit.Size = UDim2.new(1,0,0,40); Tit.Position = UDim2.new(0,0,0,30); Tit.BackgroundTransparency = 1; Tit.Font = Enum.Font.GothamBold; Tit.Text = "⚡ THINH HUB"; Tit.TextSize = 32; Tit.TextColor3 = Color3.fromRGB(70,150,255); Tit.Parent = Card

   local Sub = Instance.new("TextLabel"); Sub.Size = UDim2.new(1,0,0,16); Sub.Position = UDim2.new(0,0,0,72); Sub.BackgroundTransparency = 1; Sub.Font = Enum.Font.Gotham; Sub.Text = "V1 - Auto Block JJS - Loading 10s"; Sub.TextSize = 12; Sub.TextColor3 = Color3.fromRGB(150,150,170); Sub.Parent = Card

   local Av = Instance.new("ImageLabel"); Av.AnchorPoint = Vector2.new(0.5,0); Av.Position = UDim2.new(0.5,0,0,100); Av.Size = UDim2.fromOffset(80,80); Av.BackgroundColor3 = Color3.fromRGB(35,38,48); Av.BorderSizePixel = 0; Av.Parent = Card; C(Av,99); S(Av,Color3.fromRGB(70,150,255),2)
   pcall(function() Av.Image = game.Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end)

   local UN = Instance.new("TextLabel"); UN.Size = UDim2.new(1,-40,0,20); UN.Position = UDim2.new(0,20,0,190); UN.BackgroundTransparency = 1; UN.Font = Enum.Font.GothamBold; UN.Text = "@" .. LP.Name; UN.TextSize = 15; UN.TextColor3 = Color3.fromRGB(255,255,255); UN.TextXAlignment = Enum.TextXAlignment.Left; UN.Parent = Card

   local BBG = Instance.new("Frame"); BBG.AnchorPoint = Vector2.new(0.5,0); BBG.Position = UDim2.new(0.5,0,0,220); BBG.Size = UDim2.new(0.8,0,0,5); BBG.BackgroundColor3 = Color3.fromRGB(40,42,55); BBG.BorderSizePixel = 0; BBG.Parent = Card; C(BBG,99)
   local BF = Instance.new("Frame"); BF.Size = UDim2.new(0,0,1,0); BF.BackgroundColor3 = Color3.fromRGB(70,150,255); BF.BorderSizePixel = 0; BF.Parent = BBG; C(BF,99)

   local ST = Instance.new("TextLabel"); ST.Size = UDim2.new(1,0,0,14); ST.Position = UDim2.new(0,0,1,-18); ST.BackgroundTransparency = 1; ST.Font = Enum.Font.Gotham; ST.Text = "Đang khởi tạo..."; ST.TextSize = 11; ST.TextColor3 = Color3.fromRGB(150,150,170); ST.Parent = Card

   -- Loading 10 giây, 8 bước
   local steps = {
      {0.12,"Tải modules..."},
      {0.25,"Quét PlayerGui..."},
      {0.40,"Nạp attack IDs..."},
      {0.55,"Kết nối animations..."},
      {0.68,"Build menu..."},
      {0.80,"Load components..."},
      {0.92,"Final check..."},
      {1.00,"Xong!"},
   }
   for _, s in ipairs(steps) do
      ST.Text = s[2]
      local tween = game:GetService("TweenService"):Create(BF, TweenInfo.new(1.1), {Size = UDim2.new(s[1], 0, 1, 0)})
      tween:Play()
      task.wait(10 / #steps)
   end
   task.wait(0.3)
   pcall(function() L:Destroy() end)
end

----------------------------------------------------------------
-- MENU DARK STYLE
----------------------------------------------------------------
local Menu = Instance.new("ScreenGui")
Menu.Name = "ThinhHub"
Menu.DisplayOrder = 999
Menu.Parent = PG

-- Nút toggle ngoài
local Tog = Instance.new("TextButton")
Tog.Size = UDim2.fromOffset(50, 50)
Tog.Position = UDim2.new(1, -60, 0, 20)
Tog.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
Tog.Text = "≡"
Tog.TextSize = 22
Tog.TextColor3 = Color3.fromRGB(255, 255, 255)
Tog.Font = Enum.Font.GothamBold
Tog.BorderSizePixel = 0
Tog.Parent = Menu
C(Tog, 8); S(Tog, Color3.fromRGB(70, 150, 255), 1)

----------------------------------------------------------------
-- MAIN FRAME
----------------------------------------------------------------
local W = IsMobile and 380 or 620
local H = IsMobile and 480 or 440
local SIDE_W = IsMobile and 100 or 130
local HEAD_H = 36

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(W, H)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = C_BG
Main.BorderSizePixel = 0
Main.Visible = true
Main.Parent = Menu
C(Main, 6); S(Main, Color3.fromRGB(50, 50, 60), 1)

----------------------------------------------------------------
-- HEADER (kéo thả)
----------------------------------------------------------------
local Head = Instance.new("Frame")
Head.Size = UDim2.new(1, 0, 0, HEAD_H)
Head.BackgroundColor3 = C_SIDE
Head.BorderSizePixel = 0
Head.Parent = Main
C(Head, 6)
local HF = Instance.new("Frame"); HF.Size = UDim2.new(1,0,0,10); HF.Position = UDim2.new(0,0,1,-10); HF.BackgroundColor3 = C_SIDE; HF.BorderSizePixel = 0; HF.Parent = Head

local HT = Instance.new("TextLabel")
HT.Size = UDim2.new(1, -100, 1, 0)
HT.Position = UDim2.new(0, 14, 0, 0)
HT.BackgroundTransparency = 1
HT.Font = Enum.Font.GothamBold
HT.Text = "⚡ TBO | Thinh Hub V1"
HT.TextSize = 14
HT.TextColor3 = Color3.fromRGB(255, 255, 255)
HT.TextXAlignment = Enum.TextXAlignment.Left
HT.Parent = Head

-- Min + Close
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.fromOffset(28, 28)
MinBtn.Position = UDim2.new(1, -64, 0.5, 0)
MinBtn.AnchorPoint = Vector2.new(0, 0.5)
MinBtn.BackgroundColor3 = C_BG
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "—"
MinBtn.TextSize = 16
MinBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
MinBtn.BorderSizePixel = 0
MinBtn.Parent = Head
C(MinBtn, 4)

local CB = Instance.new("TextButton")
CB.Size = UDim2.fromOffset(28, 28)
CB.Position = UDim2.new(1, -32, 0.5, 0)
CB.AnchorPoint = Vector2.new(0, 0.5)
CB.BackgroundColor3 = C_BG
CB.Font = Enum.Font.GothamBold
CB.Text = "✕"
CB.TextSize = 14
CB.TextColor3 = Color3.fromRGB(220, 100, 100)
CB.BorderSizePixel = 0
CB.Parent = Head
C(CB, 4)

-- Drag
do
   local drag, ds, sp
   Head.InputBegan:Connect(function(i)
      if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
         drag = true; ds = i.Position; sp = Main.Position
      end
   end)
   Head.InputEnded:Connect(function(i)
      if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
         drag = false
      end
   end)
   UIS.InputChanged:Connect(function(i)
      if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
         local d = i.Position - ds
         Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
      end
   end)
end

----------------------------------------------------------------
-- SIDEBAR (dọc bên trái)
----------------------------------------------------------------
local Side = Instance.new("Frame")
Side.Name = "Sidebar"
Side.Size = UDim2.new(0, SIDE_W, 1, -HEAD_H - 6)
Side.Position = UDim2.new(0, 3, 0, HEAD_H + 3)
Side.BackgroundColor3 = C_SIDE
Side.BorderSizePixel = 0
Side.ClipsDescendants = true
Side.Parent = Main
C(Side, 4)

----------------------------------------------------------------
-- CONTENT
----------------------------------------------------------------
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -SIDE_W - 8, 1, -HEAD_H - 6)
Content.Position = UDim2.new(0, SIDE_W + 5, 0, HEAD_H + 3)
Content.BackgroundColor3 = C_BG
Content.BorderSizePixel = 0
Content.ClipsDescendants = true
Content.Parent = Main
C(Content, 4)

----------------------------------------------------------------
-- PAGES + TABS
----------------------------------------------------------------
local Pages = {}
local tabDefs = {
   {n = "Main",       i = "🏠"},
   {n = "Combat",     i = "⚔"},
   {n = "Auto",       i = "🤖"},
   {n = "Teleports",  i = "📍"},
   {n = "Items",      i = "🎒"},
   {n = "Target",     i = "🎯"},
   {n = "Extra",      i = "⚙"},
   {n = "Info",       i = "ℹ"},
}

local tabH = 38
for idx, info in ipairs(tabDefs) do
   local y = (idx - 1) * (tabH + 2) + 4
   local tab = Instance.new("TextButton")
   tab.Name = "T_" .. info.n
   tab.Size = UDim2.new(1, -8, 0, tabH)
   tab.Position = UDim2.new(0, 4, 0, y)
   tab.BackgroundColor3 = C_TAB_OFF
   tab.BorderSizePixel = 0
   tab.Font = Enum.Font.GothamMedium
   tab.Text = info.i .. "  " .. info.n
   tab.TextSize = 12
   tab.TextColor3 = Color3.fromRGB(200, 205, 220)
   tab.TextXAlignment = Enum.TextXAlignment.Left
   tab.Parent = Side
   C(tab, 4)

   -- Gạch chân xanh khi chọn (ẩn mặc định)
   local underline = Instance.new("Frame")
   underline.Name = "Underline"
   underline.Size = UDim2.new(0.7, 0, 0, 2)
   underline.Position = UDim2.new(0.15, 0, 1, -3)
   underline.BackgroundColor3 = C_ACCENT
   underline.BorderSizePixel = 0
   underline.Visible = false
   underline.Parent = tab
   C(underline, 99)

   local page = Instance.new("Frame")
   page.Name = "P_" .. info.n
   page.Size = UDim2.new(1, 0, 1, 0)
   page.BackgroundTransparency = 1
   page.Visible = false
   page.Parent = Content

   Pages[info.n] = {tab = tab, page = page, underline = underline}

   tab.MouseButton1Click:Connect(function()
      for _, pg in pairs(Pages) do
         pg.page.Visible = false
         pg.tab.BackgroundColor3 = C_TAB_OFF
         pg.underline.Visible = false
         pg.tab.TextColor3 = Color3.fromRGB(200, 205, 220)
      end
      page.Visible = true
      tab.BackgroundColor3 = C_TAB_ON
      underline.Visible = true
      tab.TextColor3 = Color3.fromRGB(255, 255, 255)
   end)
end

----------------------------------------------------------------
-- COMPONENTS (style row)
----------------------------------------------------------------
local function Section(p, txt)
   local l = Instance.new("TextLabel")
   l.Size = UDim2.new(1, -16, 0, 20)
   l.BackgroundTransparency = 1
   l.Font = Enum.Font.GothamBold
   l.Text = txt:upper()
   l.TextSize = 10
   l.TextColor3 = Color3.fromRGB(100, 150, 220)
   l.TextXAlignment = Enum.TextXAlignment.Left
   l.Parent = p.page
end

local function RowToggle(p, name, default, callback)
   local h = Instance.new("Frame")
   h.Size = UDim2.new(1, -16, 0, 36)
   h.BackgroundColor3 = C_ROW
   h.BorderSizePixel = 0
   h.Parent = p.page
   C(h, 4)

   local l = Instance.new("TextLabel")
   l.Size = UDim2.new(1, -60, 1, 0)
   l.Position = UDim2.new(0, 12, 0, 0)
   l.BackgroundTransparency = 1
   l.Font = Enum.Font.GothamMedium
   l.Text = name
   l.TextSize = 12
   l.TextColor3 = C_TXT
   l.TextXAlignment = Enum.TextXAlignment.Left
   l.TextWrapped = true
   l.Parent = h

   local btn = Instance.new("TextButton")
   btn.AnchorPoint = Vector2.new(1, 0.5)
   btn.Position = UDim2.new(1, -10, 0.5, 0)
   btn.Size = UDim2.fromOffset(44, 22)
   btn.BackgroundColor3 = default and C_TOGGLE_ON or C_TOGGLE_OFF
   btn.BorderSizePixel = 0
   btn.Text = ""
   btn.Parent = h
   C(btn, 99)

   local knob = Instance.new("Frame")
   knob.Size = UDim2.fromOffset(18, 18)
   knob.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
   knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
   knob.BorderSizePixel = 0
   knob.Parent = btn
   C(knob, 99)

   local state = default
   btn.MouseButton1Click:Connect(function()
      state = not state
      knob.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
      btn.BackgroundColor3 = state and C_TOGGLE_ON or C_TOGGLE_OFF
      callback(state)
   end)
end

local function RowSlider(p, name, min, max, default, callback)
   local h = Instance.new("Frame")
   h.Size = UDim2.new(1, -16, 0, 48)
   h.BackgroundColor3 = C_ROW
   h.BorderSizePixel = 0
   h.Parent = p.page
   C(h, 4)

   local l = Instance.new("TextLabel")
   l.Size = UDim2.new(1, -60, 0, 20)
   l.Position = UDim2.new(0, 12, 0, 4)
   l.BackgroundTransparency = 1
   l.Font = Enum.Font.GothamMedium
   l.Text = name
   l.TextSize = 12
   l.TextColor3 = C_TXT
   l.TextXAlignment = Enum.TextXAlignment.Left
   l.Parent = h

   local v = Instance.new("TextLabel")
   v.AnchorPoint = Vector2.new(1, 0)
   v.Position = UDim2.new(1, -10, 0, 6)
   v.Size = UDim2.fromOffset(50, 18)
   v.BackgroundTransparency = 1
   v.Font = Enum.Font.GothamBold
   v.Text = tostring(default)
   v.TextSize = 12
   v.TextColor3 = C_ACCENT
   v.TextXAlignment = Enum.TextXAlignment.Right
   v.Parent = h

   local track = Instance.new("Frame")
   track.Size = UDim2.new(1, -24, 0, 6)
   track.Position = UDim2.new(0, 12, 0, 32)
   track.BackgroundColor3 = Color3.fromRGB(50, 52, 60)
   track.BorderSizePixel = 0
   track.Parent = h
   C(track, 99)

   local fill = Instance.new("Frame")
   fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
   fill.BackgroundColor3 = C_TOGGLE_ON
   fill.BorderSizePixel = 0
   fill.Parent = track
   C(fill, 99)

   local dragging = false
   local function update(i)
      local abs = track.AbsolutePosition.X
      local sz = track.AbsoluteSize.X
      local rel = math.clamp((i.Position.X - abs) / sz, 0, 1)
      fill.Size = UDim2.new(rel, 0, 1, 0)
      local val = math.floor(min + (max - min) * rel)
      v.Text = tostring(val)
      callback(val)
   end
   track.InputBegan:Connect(function(i)
      if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
         dragging = true; update(i)
      end
   end)
   track.InputEnded:Connect(function(i)
      if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
         dragging = false
      end
   end)
   UIS.InputChanged:Connect(function(i)
      if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
         update(i)
      end
   end)
end

local function RowBtn(p, name, callback)
   local b = Instance.new("TextButton")
   b.Size = UDim2.new(1, -16, 0, 36)
   b.BackgroundColor3 = Color3.fromRGB(50, 55, 70)
   b.BorderSizePixel = 0
   b.Font = Enum.Font.GothamMedium
   b.Text = name
   b.TextSize = 12
   b.TextColor3 = C_TXT
   b.Parent = p.page
   C(b, 4)
   b.MouseButton1Click:Connect(callback)
end

local function RowLbl(p, text)
   local l = Instance.new("TextLabel")
   l.Size = UDim2.new(1, -16, 0, 18)
   l.BackgroundTransparency = 1
   l.Font = Enum.Font.Gotham
   l.Text = text
   l.TextSize = 11
   l.TextColor3 = C_TXT_DIM
   l.TextXAlignment = Enum.TextXAlignment.Left
   l.TextWrapped = true
   l.Parent = p.page
end

local function RowInput(p, name, ph, callback)
   local h = Instance.new("Frame")
   h.Size = UDim2.new(1, -16, 0, 56)
   h.BackgroundColor3 = C_ROW
   h.BorderSizePixel = 0
   h.Parent = p.page
   C(h, 4)
   local l = Instance.new("TextLabel")
   l.Size = UDim2.new(1, -24, 0, 18)
   l.Position = UDim2.new(0, 12, 0, 4)
   l.BackgroundTransparency = 1
   l.Font = Enum.Font.GothamMedium
   l.Text = name
   l.TextSize = 12
   l.TextColor3 = C_TXT
   l.TextXAlignment = Enum.TextXAlignment.Left
   l.Parent = h
   local tb = Instance.new("TextBox")
   tb.Size = UDim2.new(1, -24, 0, 26)
   tb.Position = UDim2.new(0, 12, 0, 24)
   tb.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
   tb.BorderSizePixel = 0
   tb.Font = Enum.Font.Gotham
   tb.PlaceholderText = ph or ""
   tb.Text = ""
   tb.TextSize = 12
   tb.TextColor3 = C_TXT
   tb.PlaceholderColor3 = Color3.fromRGB(80, 85, 100)
   tb.ClearTextOnFocus = true
   tb.Parent = h
   C(tb, 4)
   tb.FocusLost:Connect(function(enter) if enter then callback(tb.Text) end end)
end

-- Dropdown
local function RowDropdown(p, name, options, default, callback)
   local h = Instance.new("Frame")
   h.Size = UDim2.new(1, -16, 0, 36)
   h.BackgroundColor3 = C_ROW
   h.BorderSizePixel = 0
   h.Parent = p.page
   C(h, 4)

   local l = Instance.new("TextLabel")
   l.Size = UDim2.new(0.5, 0, 1, 0)
   l.Position = UDim2.new(0, 12, 0, 0)
   l.BackgroundTransparency = 1
   l.Font = Enum.Font.GothamMedium
   l.Text = name
   l.TextSize = 12
   l.TextColor3 = C_TXT
   l.TextXAlignment = Enum.TextXAlignment.Left
   l.Parent = h

   local dd = Instance.new("TextButton")
   dd.AnchorPoint = Vector2.new(1, 0.5)
   dd.Position = UDim2.new(1, -8, 0.5, 0)
   dd.Size = UDim2.new(0, 130, 0, 24)
   dd.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
   dd.BorderSizePixel = 0
   dd.Font = Enum.Font.Gotham
   dd.Text = default or (options[1] or "")
   dd.TextSize = 11
   dd.TextColor3 = C_TXT
   dd.Parent = h
   C(dd, 4)
   dd.MouseButton1Click:Connect(function()
      local cur = dd.Text
      for i, opt in ipairs(options) do
         if opt == cur then
            dd.Text = options[i % #options + 1]
            callback(dd.Text)
            return
         end
      end
   end)
end

-- Xếp tay
local function layoutPage(p)
   local y = 8
   for _, child in pairs(p.page:GetChildren()) do
      if child:IsA("Frame") or child:IsA("TextLabel") then
         child.Position = UDim2.new(0, 8, 0, y)
         y = y + child.AbsoluteSize.Y + 6
      end
   end
end

----------------------------------------------------------------
-- AUTO BLOCK (FIX: KHÔNG ĐỠ KHI USER TỰ ĐÁNH)
----------------------------------------------------------------
local AttackAnimIDs = {
   -- M1 & Đòn đánh cơ bản
   ["10468665991"]=true,
   ["10469493270"]=true,
   ["10469630950"]=true,
   ["10469639222"]=true,
   ["10469643643"]=true,
   ["95421145178968"]=true,
   ["138898960225788"]=true,
   ["137844586546509"]=true,
   ["120133391090244"]=true,
   ["96489184596023"]=true,
   ["13826705245289"]=true,
   ["140491244934559"]=true,
   ["1012839390868172"]=true,
   ["139479927693015"]=true,
   ["119619096808750"]=true,
   ["104408538049330"]=true,
   ["77705898607209"]=true,

   -- Skill & Kỹ năng đặc biệt (Phá thủ, Ult, Black Flash, Fuga...)
   ["10466974800"]=true,
   ["10471336737"]=true,
   ["12510170988"]=true,
   ["12832505612"]=true,
   ["12983333733"]=true,
   ["13073745835"]=true,
   ["13560306510"]=true,
   ["14326861262"]=true,
   ["15583493700"]=true,
   ["17861840167"]=true,
   ["17284219852"]=true,

   -- Dash (Tới, Lùi, Trái/Phải, Air Dash)
   ["10470389823"]=true, -- Front Dash
   ["10470396025"]=true, -- Back Dash
   ["10470402283"]=true, -- Side Step
   ["10470410125"]=true, -- Air Dash
}
local AtkK = {"slash","stab","punch","kick","swing","smash","cut","thrust","slice","attack","hit","combo","slam","uppercut","jab","hook","bash","cleave","impale","spin"}
local BlockK = {"block","defend","shield","parry","guard","def","button1","btn1","skill1","action1","combat1","ability1"}

local AutoBlockOn, DynamicOn, LockFacing = false, true, true
local BlockRange, LastBlock, BlockCount = 15, 0, 0
local HoldTime, CooldownTime = 0.30, 0.22

local function FindBlockBtn()
   local pg = LP:FindFirstChild("PlayerGui")
   if not pg then return nil end
   local best, bestS = nil, 0
   for _, v in pairs(pg:GetDescendants()) do
      if (v:IsA("ImageButton") or v:IsA("TextButton") or v:IsA("GuiButton")) and v.Visible then
         local n = v.Name:lower()
         local s = 0
         for _, kw in ipairs(BlockK) do if n:find(kw) then s = s + #kw end end
         if s > bestS then bestS = s; best = v end
      end
   end
   return best, bestS
end

local CachedBtn, CachedAt = nil, 0
local function GetBlockBtn()
   if CachedBtn and CachedBtn.Parent and CachedBtn.Visible then return CachedBtn end
   if tick() - CachedAt < 1.5 then return nil end
   CachedAt = tick()
   local b, s = FindBlockBtn()
   if b and s > 0 then CachedBtn = b; return b end
   return nil
end

local function PerformBlock()
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

local function FaceAtk(r)
   if not LockFacing then return end
   local ch = LP.Character
   if not ch or not ch:FindFirstChild("HumanoidRootPart") then return end
   local my = ch.HumanoidRootPart
   local d = (r.Position - my.Position) * Vector3.new(1,0,1)
   if d.Magnitude > 0.1 then my.CFrame = CFrame.lookAt(my.Position, my.Position + d.Unit) end
end

local function isAtkName(n)
   for _, w in ipairs(AtkK) do if n:lower():find(w) then return true end end
   return false
end

local function MonitorP(p)
   -- BỎ QUA NẾU LÀ CHÍNH MÌNH (FIX LỖI TỰ ĐỠ KHI USER TỰ ĐÁNH)
   if p == LP then return end

   local function onC(c)
      local h = c:WaitForChild("Humanoid", 10)
      if not h then return end
      h.AnimationPlayed:Connect(function(tr)
         if not AutoBlockOn then return end

         -- CHECK THÊM: nếu model này là của LocalPlayer thì skip
         local attackerPlayer = game.Players:GetPlayerFromCharacter(c)
         if attackerPlayer == LP then return end

         local my = LP.Character
         if not my or not my:FindFirstChild("HumanoidRootPart") or not c:FindFirstChild("HumanoidRootPart") then return end
         if (c.HumanoidRootPart.Position - my.HumanoidRootPart.Position).Magnitude > BlockRange then return end

         local id = (tr.Animation and tr.Animation.AnimationId or ""):match("%d+")
         if (id and AttackAnimIDs[id]) or (DynamicOn and isAtkName(tr.Name or "")) then
            FaceAtk(c.HumanoidRootPart)
            PerformBlock()
         end
      end)
   end
   if p.Character then onC(p.Character) end
   p.CharacterAdded:Connect(onC)
end

-- BỎ QUA: không monitor chính mình
-- (chỉ monitor người chơi khác + NPC)
for _, pl in pairs(game.Players:GetPlayers()) do
   if pl ~= LP then MonitorP(pl) end
end
game.Players.PlayerAdded:Connect(function(pl)
   if pl ~= LP then MonitorP(pl) end
end)

-- Nếu muốn monitor NPC: thêm vòng lặp quét workspace
task.spawn(function()
   while true do
      task.wait(2)
      for _, obj in pairs(workspace:GetDescendants()) do
         if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            local pl = game.Players:GetPlayerFromCharacter(obj)
            if not pl and not obj:GetAttribute("_monitored") then
               obj:SetAttribute("_monitored", true)
               local h = obj:FindFirstChild("Humanoid")
               if h then
                  h.AnimationPlayed:Connect(function(tr)
                     if not AutoBlockOn then return end
                     local my = LP.Character
                     if not my or not my:FindFirstChild("HumanoidRootPart") or not obj:FindFirstChild("HumanoidRootPart") then return end
                     if (obj.HumanoidRootPart.Position - my.HumanoidRootPart.Position).Magnitude > BlockRange then return end
                     local id = (tr.Animation and tr.Animation.AnimationId or ""):match("%d+")
                     if (id and AttackAnimIDs[id]) or (DynamicOn and isAtkName(tr.Name or "")) then
                        FaceAtk(obj.HumanoidRootPart)
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
-- NỘI DUNG TỪNG TAB
----------------------------------------------------------------
local TMain = Pages["Main"]
local TC    = Pages["Combat"]
local TAuto = Pages["Auto"]
local TTP   = Pages["Teleports"]
local TItem = Pages["Items"]
local TTar  = Pages["Target"]
local TExt  = Pages["Extra"]
local TInfo = Pages["Info"]

-- MAIN
Section(TMain, "Chào mừng")
RowLbl(TMain, "⚡ Thinh Hub V1")
RowLbl(TMain, "Auto Block cho JJS - Dark style")
RowLbl(TMain, "Hold F: 0.30s | Cooldown: 0.22s")
Section(TMain, "Trạng thái")
RowLbl(TMain, "👤 @" .. LP.Name)
RowLbl(TMain, "📅 " .. LP.AccountAge .. " ngày")
RowLbl(TMain, "📱 " .. (IsMobile and "Mobile" or "PC"))

-- COMBAT
Section(TC, "Auto Block")
RowToggle(TC, "⚡ Auto Block", false, function(v) AutoBlockOn = v end)
RowToggle(TC, "🧠 Smart Detection", true, function(v) DynamicOn = v end)
RowToggle(TC, "🔒 Lock Facing", true, function(v) LockFacing = v end)
Section(TC, "Cấu hình")
RowSlider(TC, "Block Range", 8, 25, 15, function(v) BlockRange = v end)
RowSlider(TC, "Hold Time (s)", 20, 50, 30, function(v) HoldTime = v / 100 end)
RowSlider(TC, "Cooldown (s)", 15, 40, 22, function(v) CooldownTime = v / 100 end)

-- AUTO
Section(TAuto, "Farm")
RowToggle(TAuto, "💰 Auto Coins", false, function(v)
   _G.AutoFarm = v
   if v then
      task.spawn(function()
         while _G.AutoFarm do
            for _, p in pairs(workspace:GetDescendants()) do
               if p:IsA("ProximityPrompt") then pcall(function() fireproximityprompt(p) end) end
            end
            task.wait(0.5)
         end
      end)
   end
end)
RowToggle(TAuto, "🛡 Anti-AFK", false, function(v)
   if v then
      pcall(function()
         local vu = game:GetService("VirtualUser")
         LP.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
         end)
      end)
   end
end)

-- TELEPORTS
Section(TTP, "Di chuyển")
RowBtn(TTP, "👥 TP tới người chơi", function()
   for _, p in pairs(game.Players:GetPlayers()) do
      if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
         LP.Character:WaitForChild("HumanoidRootPart").CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
         return
      end
   end
end)
RowBtn(TTP, "⬆️ Lên cao 200", function()
   if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
      LP.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame + Vector3.new(0,200,0)
   end
end)
RowInput(TTP, "TP theo tọa độ", "0, 50, 0", function(text)
   local x, y, z = text:match("([%-%d%.]+),%s*([%-%d%.]+),%s*([%-%d%.]+)")
   if x and y and z and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
      LP.Character.HumanoidRootPart.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
   end
end)

-- ITEMS
Section(TItem, "Vật phẩm")
RowBtn(TItem, "🎒 Không có", function() end)
Section(TItem, "Khác")
RowBtn(TItem, "🔄 Respawn", function() LP:LoadCharacter() end)

-- TARGET
Section(TTar, "Mục tiêu")
RowToggle(TTar, "🎯 Auto target", false, function(v) _G.AutoTarget = v end)
RowDropdown(TTar, "Phương thức", {"tp away", "tp to", "freeze"}, "tp away", function(v) _G.TargetMethod = v end)
RowSlider(TTar, "Distance", 5, 50, 15, function(v) _G.TargetDist = v end)

-- EXTRA
Section(TExt, "Tiện ích")
RowBtn(TExt, "🔁 Rejoin Server", function()
   pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end)
end)
RowBtn(TExt, "🌍 Server Hop", function()
   pcall(function()
      local http = game:GetService("HttpService")
      local data = http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/0?sortOrder=Asc&limit=100"))
      for _, s in pairs(data.data) do
         if s.playing < s.maxPlayers and s.id ~= game.JobId then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id)
            return
         end
      end
   end)
end)
Section(TExt, "Player")
RowSlider(TExt, "WalkSpeed", 16, 250, 16, function(v)
   if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed = v end
end)
RowSlider(TExt, "JumpPower", 50, 300, 50, function(v)
   if LP.Character and LP.Character:FindFirstChild("Humanoid") then
      LP.Character.Humanoid.UseJumpPower = true
      LP.Character.Humanoid.JumpPower = v
   end
end)

-- INFO
Section(TInfo, "Tài khoản")
RowLbl(TInfo, "👤 @" .. LP.Name)
RowLbl(TInfo, "✨ " .. LP.DisplayName)
RowLbl(TInfo, "🆔 " .. tostring(LP.UserId))
RowLbl(TInfo, "📅 " .. LP.AccountAge .. " ngày")
RowLbl(TInfo, "📱 " .. (IsMobile and "Mobile" or "PC"))
Section(TInfo, "Thống kê")
local countLbl = Instance.new("TextLabel")
countLbl.Size = UDim2.new(1, -16, 0, 22)
countLbl.BackgroundTransparency = 1
countLbl.Font = Enum.Font.GothamBold
countLbl.Text = "🛡 Blocks đã đỡ: 0"
countLbl.TextSize = 12
countLbl.TextColor3 = C_TOGGLE_ON
countLbl.TextXAlignment = Enum.TextXAlignment.Left
countLbl.Parent = TInfo.page
task.spawn(function()
   while countLbl and countLbl.Parent do
      pcall(function() countLbl.Text = "🛡 Blocks đã đỡ: " .. BlockCount end)
      task.wait(1)
   end
end)

-- Layout
task.defer(function()
   for _, pg in pairs(Pages) do
      layoutPage(pg)
   end
end)

-- Mở tab Main đầu tiên
TMain.page.Visible = true
TMain.tab.BackgroundColor3 = C_TAB_ON
TMain.underline.Visible = true
TMain.tab.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Toggle
Tog.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
CB.MouseButton1Click:Connect(function() Main.Visible = false end)
MinBtn.MouseButton1Click:Connect(function()
   Main.Visible = false
   -- Tạo nút mở lại nhỏ
   local m = Instance.new("TextButton")
   m.Size = UDim2.fromOffset(120, 30)
   m.Position = UDim2.new(0.5, 0, 0, 20)
   m.AnchorPoint = Vector2.new(0.5, 0)
   m.BackgroundColor3 = C_BG
   m.Text = "▼ Mở menu"
   m.TextSize = 12
   m.TextColor3 = C_TXT
   m.Font = Enum.Font.GothamMedium
   m.BorderSizePixel = 0
   m.Parent = Menu
   C(m, 4)
   m.MouseButton1Click:Connect(function()
      Main.Visible = true
      m:Destroy()
   end)
end)
