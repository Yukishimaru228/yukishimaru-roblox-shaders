local f=game:GetService("Players")local x=game:GetService("UserInputService")local l=game:GetService("RunService")local v=game:GetService("TweenService")local d=game:GetService("Lighting")local F=game:GetService("CoreGui")local W=f.LocalPlayer local B=workspace.CurrentCamera local I={Width=800;Height=510,Purple=Color3.fromRGB(153,70,255);PurpleLight=Color3.fromRGB(205,138,255),PurpleSoft=Color3.fromRGB(108,44,183);BackgroundTop=Color3.fromRGB(11,6,19);BackgroundBottom=Color3.fromRGB(42,18,63),Panel=Color3.fromRGB(27,13,42),PanelLight=Color3.fromRGB(43,21,63),White=Color3.fromRGB(247,243,255),Text=Color3.fromRGB(219,209,231);Muted=Color3.fromRGB(157,142,175),BubbleCount=85;BubbleGravity=110,BubbleMagnet=8.5;BubbleDrag=.9;WindowRadius=27;PanelRadius=21,ButtonRadius=14,RightAlt=Enum.KeyCode.RightAlt,ShaderPrefix="YukiShader_";VignetteName="YukiShader_Vignette"}local r=true local P=false local X=false local Y={}local G={}local Z="Home"local N="Default"local p=false local m=nil local b=nil local A=nil local Q=nil local J=nil local o=nil local c={ColorCorrection=nil;Bloom=nil,Blur=nil,DepthOfField=nil;SunRays=nil,Atmosphere=nil,MotionBlur=nil}local t={Saturation=0;Brightness=0,Contrast=0;Blur=0,BloomIntensity=0;BloomSize=24,BloomThreshold=1,SunRaysIntensity=0,SunRaysSpread=1,DOFFarIntensity=0,DOFNearIntensity=0,DOFFocusDistance=10;AtmosphereDensity=0;AtmosphereColor=Color3.fromRGB(200,200,200),MotionBlur=false,MotionBlurStrength=0;Vignette=false,VignetteStrength=0}local T={FOVEnabled=false;FOVValue=80;AspectEnabled=false,AspectValue=.6}local q=70 pcall(function()local x=f.LocalPlayer if x and(x:FindFirstChild("PlayerData")and(x.PlayerData:FindFirstChild("Settings")and x.PlayerData.Settings:FindFirstChild("Game")))then local f=x.PlayerData.Settings.Game:FindFirstChild("FieldOfView")if f and f:IsA("ValueBase")then q=f.Value T.FOVValue=f.Value end end end)local function C(x)local l=f.LocalPlayer if l and(l.PlayerData and(l.PlayerData.Settings and l.PlayerData.Settings.Game))then local f=l.PlayerData.Settings.Game:FindFirstChild("FieldOfView")if f then f.Value=x end end if B then B.FieldOfView=x end end local function w()C(q)end local s=nil local M=nil local function S()if s then return end s=l:BindToRenderStep("YukiFOV_Force",Enum.RenderPriority.Last,function()if T.FOVEnabled and r then C(T.FOVValue)end end)if not M then M=l.Heartbeat:Connect(function()if T.FOVEnabled and r then C(T.FOVValue)end end)end end local function U()if s then l:UnbindFromRenderStep("YukiFOV_Force")s=nil end if M then M:Disconnect()M=nil end end local k={FullBright=false,NoLag=false}local D={Saved=false;Brightness=nil;Ambient=nil}local h=nil local function H(f,x)local l=f:Connect(x)table.insert(Y,l)return l end local function n()for f,x in ipairs(Y)do pcall(function()x:Disconnect()end)end table.clear(Y)end local function g(f,x,l,d,F)local W=TweenInfo.new(l or.25,d or Enum.EasingStyle.Quart,F or Enum.EasingDirection.Out)local B=v:Create(f,W,x)B:Play()return B end local function y(f,x)local l=Instance.new("UICorner")l.CornerRadius=UDim.new(0,x)l.Parent=f return l end local function V(f,x,l,v)local d=Instance.new("UIStroke")d.Color=x or I.Purple d.Transparency=l or.5 d.Thickness=v or 1 d.ApplyStrokeMode=Enum.ApplyStrokeMode.Border d.Parent=f return d end local function O(f,x,l,v)local d=Instance.new("UIGradient")d.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,x);ColorSequenceKeypoint.new(1,l)})d.Rotation=v or 0 d.Parent=f return d end local function K(f,x,l)return math.max(x,math.min(l,f))end local function E(f)if f then pcall(function()f:Destroy()end)end end local function z(f)k.FullBright=f if f then if not D.Saved then D.Brightness=d.Brightness D.Ambient=d.Ambient D.Saved=true end d.Brightness=5 d.Ambient=Color3.fromRGB(255,255,255)elseif D.Saved then d.Brightness=D.Brightness d.Ambient=D.Ambient D.Saved=false end end local function a(f)if not f or not((f:IsA("Part")or f:IsA("MeshPart")))then return end if f.Transparency>=1 then return end if not f:GetAttribute("YukiOldMaterial")then f:SetAttribute("YukiOldMaterial",f.Material.Name)end f.Material=Enum.Material.SmoothPlastic if f:IsA("MeshPart")then if f.TextureID~=""and not f:GetAttribute("YukiOldTextureID")then f:SetAttribute("YukiOldTextureID",f.TextureID)end f.TextureID=""end end local function R()for f,x in ipairs(workspace:GetDescendants())do a(x)end if h then h:Disconnect()h=nil end h=workspace.DescendantAdded:Connect(function(f)if not k.NoLag then return end task.defer(function()if k.NoLag then a(f)end end)end)end local function e()if h then h:Disconnect()h=nil end for f,x in ipairs(workspace:GetDescendants())do if x:IsA("Part")or x:IsA("MeshPart")then local f=x:GetAttribute("YukiOldMaterial")if f then for l,v in ipairs(Enum.Material:GetEnumItems())do if v.Name==f then x.Material=v break end end x:SetAttribute("YukiOldMaterial",nil)end if x:IsA("MeshPart")then local f=x:GetAttribute("YukiOldTextureID")if f then x.TextureID=f x:SetAttribute("YukiOldTextureID",nil)end end end end end local j=Instance.new("ScreenGui")j.Name="YukiShaderEngine"j.ResetOnSpawn=false j.IgnoreGuiInset=true j.DisplayOrder=999999 j.ZIndexBehavior=Enum.ZIndexBehavior.Sibling pcall(function()if syn and syn.protect_gui then syn.protect_gui(j)end end)j.Parent=F local L=Instance.new("Frame")L.Name="Main"L.AnchorPoint=Vector2.new(.5,.5)L.Position=UDim2.fromScale(.5,.5)L.Size=UDim2.fromOffset(I.Width,I.Height)L.BackgroundColor3=I.BackgroundTop L.BackgroundTransparency=.02 L.BorderSizePixel=0 L.ClipsDescendants=true L.ZIndex=1 L.Parent=j y(L,I.WindowRadius)V(L,I.PurpleLight,.56,1.25)O(L,I.BackgroundTop,I.BackgroundBottom,35)local i=Instance.new("Frame")i.AnchorPoint=Vector2.new(.5,.5)i.Position=UDim2.fromScale(.5,.5)i.Size=UDim2.new(1,160,1,160)i.BackgroundColor3=I.Purple i.BackgroundTransparency=.955 i.BorderSizePixel=0 i.ZIndex=2 i.Parent=L y(i,60)local u=Instance.new("Frame")u.Name="BubbleLayer"u.Size=UDim2.fromScale(1,1)u.BackgroundTransparency=1 u.BorderSizePixel=0 u.ClipsDescendants=true u.ZIndex=5 u.Parent=L local fc=Instance.new("Frame")fc.Name="Content"fc.Size=UDim2.fromScale(1,1)fc.BackgroundTransparency=1 fc.BorderSizePixel=0 fc.ZIndex=20 fc.Parent=L local xc=Instance.new("Frame")xc.Name="Header"xc.Position=UDim2.fromOffset(26,20)xc.Size=UDim2.new(1,-52,0,68)xc.BackgroundTransparency=1 xc.BorderSizePixel=0 xc.ZIndex=30 xc.Parent=fc local lc=Instance.new("Frame")lc.Position=UDim2.fromOffset(0,6)lc.Size=UDim2.fromOffset(54,54)lc.BackgroundColor3=I.Purple lc.BackgroundTransparency=.08 lc.BorderSizePixel=0 lc.ZIndex=31 lc.Parent=xc y(lc,18)V(lc,I.PurpleLight,.28,1)local vc=Instance.new("Frame")vc.AnchorPoint=Vector2.new(.5,.5)vc.Position=UDim2.fromScale(.5,.5)vc.Size=UDim2.fromOffset(21,21)vc.BackgroundColor3=I.White vc.BorderSizePixel=0 vc.Rotation=45 vc.ZIndex=32 vc.Parent=lc y(vc,4)local dc=Instance.new("Frame")dc.AnchorPoint=Vector2.new(.5,.5)dc.Position=UDim2.fromScale(.5,.5)dc.Size=UDim2.fromOffset(8,8)dc.BackgroundColor3=I.Purple dc.BorderSizePixel=0 dc.ZIndex=33 dc.Parent=lc y(dc,2)local Fc=Instance.new("TextLabel")Fc.Position=UDim2.fromOffset(70,2)Fc.Size=UDim2.new(1,-210,0,35)Fc.BackgroundTransparency=1 Fc.Font=Enum.Font.GothamBold Fc.Text="Yuki Shader Engine"Fc.TextSize=28 Fc.TextColor3=I.White Fc.TextXAlignment=Enum.TextXAlignment.Left Fc.ZIndex=31 Fc.Parent=xc local Wc=Instance.new("TextLabel")Wc.Position=UDim2.fromOffset(71,38)Wc.Size=UDim2.new(1,-210,0,20)Wc.BackgroundTransparency=1 Wc.Font=Enum.Font.Gotham Wc.Text="Liquid Glass Shader Environment"Wc.TextSize=12 Wc.TextColor3=I.Muted Wc.TextXAlignment=Enum.TextXAlignment.Left Wc.ZIndex=31 Wc.Parent=xc local Bc=Instance.new("Frame")Bc.AnchorPoint=Vector2.new(1,0)Bc.Position=UDim2.new(1,0,0,8)Bc.Size=UDim2.fromOffset(112,35)Bc.BackgroundColor3=I.PanelLight Bc.BackgroundTransparency=.12 Bc.BorderSizePixel=0 Bc.ZIndex=31 Bc.Parent=xc y(Bc,13)V(Bc,I.PurpleLight,.78,1)local Ic=Instance.new("Frame")Ic.Position=UDim2.fromOffset(13,13)Ic.Size=UDim2.fromOffset(8,8)Ic.BackgroundColor3=I.PurpleLight Ic.BorderSizePixel=0 Ic.ZIndex=32 Ic.Parent=Bc y(Ic,99)local rc=Instance.new("TextLabel")rc.Position=UDim2.fromOffset(28,0)rc.Size=UDim2.new(1,-35,1,0)rc.BackgroundTransparency=1 rc.Font=Enum.Font.GothamSemibold rc.Text="READY"rc.TextSize=10 rc.TextColor3=I.White rc.TextXAlignment=Enum.TextXAlignment.Left rc.ZIndex=32 rc.Parent=Bc local Pc=Instance.new("Frame")Pc.Name="PageContainer"Pc.Position=UDim2.fromOffset(26,98)Pc.Size=UDim2.new(1,-52,1,-175)Pc.BackgroundTransparency=1 Pc.BorderSizePixel=0 Pc.ZIndex=20 Pc.Parent=fc local Xc=Instance.new("Frame")Xc.Name="Home"Xc.Size=UDim2.fromScale(1,1)Xc.BackgroundTransparency=1 Xc.BorderSizePixel=0 Xc.Visible=true Xc.Parent=Pc local Yc=Instance.new("Frame")Yc.Size=UDim2.fromScale(1,1)Yc.BackgroundColor3=I.Panel Yc.BackgroundTransparency=.21 Yc.BorderSizePixel=0 Yc.ZIndex=20 Yc.Parent=Xc y(Yc,I.PanelRadius)V(Yc,I.PurpleLight,.83,1)O(Yc,Color3.fromRGB(28,13,43),Color3.fromRGB(45,20,64),18)local Gc=Instance.new("Frame")Gc.Position=UDim2.fromOffset(22,14)Gc.Size=UDim2.new(1,-44,0,2)Gc.BackgroundColor3=I.PurpleLight Gc.BackgroundTransparency=.43 Gc.BorderSizePixel=0 Gc.ZIndex=21 Gc.Parent=Yc y(Gc,5)local Zc=Instance.new("TextLabel")Zc.Position=UDim2.fromOffset(27,27)Zc.Size=UDim2.new(1,-54,0,36)Zc.BackgroundTransparency=1 Zc.Font=Enum.Font.GothamBold Zc.Text="Welcome to Yuki Shader Engine"Zc.TextSize=23 Zc.TextColor3=I.White Zc.TextXAlignment=Enum.TextXAlignment.Left Zc.ZIndex=23 Zc.Parent=Yc local Nc=Instance.new("TextLabel")Nc.Position=UDim2.fromOffset(28,64)Nc.Size=UDim2.new(1,-56,0,43)Nc.BackgroundTransparency=1 Nc.Font=Enum.Font.Gotham Nc.Text="Advanced visual presets and manual shader controls for Roblox."Nc.TextSize=13 Nc.TextColor3=I.Muted Nc.TextWrapped=true Nc.TextXAlignment=Enum.TextXAlignment.Left Nc.ZIndex=23 Nc.Parent=Yc local pc=Instance.new("Frame")pc.Position=UDim2.fromOffset(27,124)pc.Size=UDim2.new(.61,-17,0,151)pc.BackgroundColor3=I.PanelLight pc.BackgroundTransparency=.27 pc.BorderSizePixel=0 pc.ZIndex=22 pc.Parent=Yc y(pc,18)V(pc,I.PurpleLight,.87,1)local mc=Instance.new("TextLabel")mc.Position=UDim2.fromOffset(17,17)mc.Size=UDim2.new(1,-34,0,23)mc.BackgroundTransparency=1 mc.Font=Enum.Font.GothamSemibold mc.Text="About the project"mc.TextSize=14 mc.TextColor3=I.White mc.TextXAlignment=Enum.TextXAlignment.Left mc.ZIndex=23 mc.Parent=pc local bc=Instance.new("TextLabel")bc.Position=UDim2.fromOffset(17,45)bc.Size=UDim2.new(1,-34,0,102)bc.BackgroundTransparency=1 bc.Font=Enum.Font.Gotham bc.Text="Welcome to my universal, free script for any Roblox game.\n\nWhat does it include? A massive collection of shaders, exactly what our game was missing.\n\nI write all the code myself, without a development team or AI. Enjoy!\n\nMy TikTok: @yukishimaruoffc.\n\nIf you make a video using my script, please to tag me in the description if you want!"bc.TextSize=10 bc.TextColor3=I.Text bc.TextWrapped=true bc.TextXAlignment=Enum.TextXAlignment.Left bc.TextYAlignment=Enum.TextYAlignment.Top bc.ZIndex=23 bc.Parent=pc local Ac=Instance.new("Frame")Ac.Position=UDim2.new(.61,12,0,124)Ac.Size=UDim2.new(.39,-39,0,151)Ac.BackgroundColor3=I.PanelLight Ac.BackgroundTransparency=.27 Ac.BorderSizePixel=0 Ac.ZIndex=22 Ac.Parent=Yc y(Ac,18)V(Ac,I.PurpleLight,.87,1)local Qc=Instance.new("TextLabel")Qc.Position=UDim2.fromOffset(17,17)Qc.Size=UDim2.new(1,-34,0,23)Qc.BackgroundTransparency=1 Qc.Font=Enum.Font.GothamSemibold Qc.Text="Engine"Qc.TextSize=14 Qc.TextColor3=I.White Qc.TextXAlignment=Enum.TextXAlignment.Left Qc.ZIndex=23 Qc.Parent=Ac local Jc=Instance.new("TextLabel")Jc.Position=UDim2.fromOffset(17,47)Jc.Size=UDim2.new(1,-34,0,25)Jc.BackgroundTransparency=1 Jc.Font=Enum.Font.GothamBold Jc.Text="READY"Jc.TextSize=19 Jc.TextColor3=I.PurpleLight Jc.TextXAlignment=Enum.TextXAlignment.Left Jc.ZIndex=23 Jc.Parent=Ac local oc=Instance.new("TextLabel")oc.Position=UDim2.fromOffset(17,80)oc.Size=UDim2.new(1,-34,0,24)oc.BackgroundTransparency=1 oc.Font=Enum.Font.Gotham oc.Text="Preset: Default"oc.TextSize=10 oc.TextColor3=I.Muted oc.TextXAlignment=Enum.TextXAlignment.Left oc.ZIndex=23 oc.Parent=Ac local cc=Instance.new("TextLabel")cc.Position=UDim2.fromOffset(17,108)cc.Size=UDim2.new(1,-34,0,30)cc.BackgroundTransparency=1 cc.Font=Enum.Font.Gotham cc.Text="Use Presets or Settings below."cc.TextSize=9 cc.TextColor3=I.Muted cc.TextWrapped=true cc.TextXAlignment=Enum.TextXAlignment.Left cc.ZIndex=23 cc.Parent=Ac local tc=Instance.new("Frame")tc.Name="Presets"tc.Size=UDim2.fromScale(1,1)tc.BackgroundColor3=I.Panel tc.BackgroundTransparency=.21 tc.BorderSizePixel=0 tc.Visible=false tc.ZIndex=20 tc.Parent=Pc y(tc,I.PanelRadius)V(tc,I.PurpleLight,.83,1)O(tc,Color3.fromRGB(28,13,43),Color3.fromRGB(45,20,64),18)local Tc=Instance.new("TextLabel")Tc.Position=UDim2.fromOffset(20,16)Tc.Size=UDim2.new(1,-40,0,26)Tc.BackgroundTransparency=1 Tc.Font=Enum.Font.GothamBold Tc.Text="Shader Presets"Tc.TextSize=20 Tc.TextColor3=I.White Tc.TextXAlignment=Enum.TextXAlignment.Left Tc.ZIndex=22 Tc.Parent=tc local qc=Instance.new("TextLabel")qc.Position=UDim2.fromOffset(21,42)qc.Size=UDim2.new(1,-42,0,21)qc.BackgroundTransparency=1 qc.Font=Enum.Font.Gotham qc.Text="Choose a preset. Loading a preset resets previous shader state."qc.TextSize=10 qc.TextColor3=I.Muted qc.TextXAlignment=Enum.TextXAlignment.Left qc.ZIndex=22 qc.Parent=tc local Cc=Instance.new("ScrollingFrame")Cc.Position=UDim2.fromOffset(15,70)Cc.Size=UDim2.new(1,-30,1,-84)Cc.BackgroundTransparency=1 Cc.BorderSizePixel=0 Cc.ScrollBarThickness=3 Cc.ScrollBarImageColor3=I.Purple Cc.CanvasSize=UDim2.fromOffset(0,0)Cc.ZIndex=22 Cc.Parent=tc local wc=Instance.new("UIGridLayout")wc.CellSize=UDim2.new(.333,-8,0,55)wc.CellPadding=UDim2.fromOffset(8,8)wc.SortOrder=Enum.SortOrder.LayoutOrder wc.Parent=Cc local sc=Instance.new("Frame")sc.Name="Settings"sc.Size=UDim2.fromScale(1,1)sc.BackgroundColor3=I.Panel sc.BackgroundTransparency=.21 sc.BorderSizePixel=0 sc.Visible=false sc.ZIndex=20 sc.Parent=Pc y(sc,I.PanelRadius)V(sc,I.PurpleLight,.83,1)O(sc,Color3.fromRGB(28,13,43),Color3.fromRGB(45,20,64),18)local Mc=Instance.new("TextLabel")Mc.Position=UDim2.fromOffset(20,16)Mc.Size=UDim2.new(1,-180,0,26)Mc.BackgroundTransparency=1 Mc.Font=Enum.Font.GothamBold Mc.Text="Shader Settings"Mc.TextSize=20 Mc.TextColor3=I.White Mc.TextXAlignment=Enum.TextXAlignment.Left Mc.ZIndex=22 Mc.Parent=sc local Sc=Instance.new("TextLabel")Sc.Position=UDim2.fromOffset(21,42)Sc.Size=UDim2.new(1,-190,0,21)Sc.BackgroundTransparency=1 Sc.Font=Enum.Font.Gotham Sc.Text="Changes apply instantly without recreating the shader stack."Sc.TextSize=10 Sc.TextColor3=I.Muted Sc.TextXAlignment=Enum.TextXAlignment.Left Sc.ZIndex=22 Sc.Parent=sc local Uc=Instance.new("TextButton")Uc.AnchorPoint=Vector2.new(1,0)Uc.Position=UDim2.new(1,-20,0,16)Uc.Size=UDim2.fromOffset(120,31)Uc.BackgroundColor3=Color3.fromRGB(49,23,69)Uc.BackgroundTransparency=.06 Uc.BorderSizePixel=0 Uc.AutoButtonColor=false Uc.Text="Reset"Uc.Font=Enum.Font.GothamSemibold Uc.TextSize=9 Uc.TextColor3=I.White Uc.ZIndex=23 Uc.Parent=sc y(Uc,10)local kc=Instance.new("ScrollingFrame")kc.Position=UDim2.fromOffset(15,70)kc.Size=UDim2.new(1,-30,1,-84)kc.BackgroundTransparency=1 kc.BorderSizePixel=0 kc.ScrollBarThickness=3 kc.ScrollBarImageColor3=I.Purple kc.CanvasSize=UDim2.fromOffset(0,0)kc.ZIndex=22 kc.Parent=sc local function Dc(f,x)local l if f=="Bloom"then l=Instance.new("BloomEffect")elseif f=="ColorCorrection"then l=Instance.new("ColorCorrectionEffect")elseif f=="Blur"then l=Instance.new("BlurEffect")elseif f=="DepthOfField"then l=Instance.new("DepthOfFieldEffect")elseif f=="SunRays"then l=Instance.new("SunRaysEffect")elseif f=="Atmosphere"then l=Instance.new("Atmosphere")else return nil end l.Name=I.ShaderPrefix..f for f,x in pairs(x or{})do pcall(function()l[f]=x end)end l.Parent=d c[f]=l return l end local function hc()for f,x in pairs(c)do if x then E(x)end c[f]=nil end for f,x in ipairs(d:GetChildren())do if x.Name:sub(1,#I.ShaderPrefix)==I.ShaderPrefix then E(x)end end if J then E(J)J=nil end end local function Hc()if Q then E(Q)Q=nil end end local function nc(f)Hc()Q=Instance.new("ScreenGui")Q.Name=I.VignetteName Q.IgnoreGuiInset=true Q.ResetOnSpawn=false Q.DisplayOrder=999998 pcall(function()if syn and syn.protect_gui then syn.protect_gui(Q)end end)Q.Parent=F local x=Instance.new("Frame")x.Size=UDim2.new(1,0,.27,0)x.BackgroundColor3=Color3.new(0,0,0)x.BackgroundTransparency=K(1-f*.72,.18,.98)x.BorderSizePixel=0 x.Parent=Q local l=Instance.new("UIGradient")l.Rotation=90 l.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0);NumberSequenceKeypoint.new(1,1)})l.Parent=x local v=x:Clone()v.AnchorPoint=Vector2.new(0,1)v.Position=UDim2.fromScale(0,1)v.Rotation=180 v.Parent=Q local d=Instance.new("Frame")d.Size=UDim2.new(.2,0,1,0)d.BackgroundColor3=Color3.new(0,0,0)d.BackgroundTransparency=K(1-f*.68,.18,.98)d.BorderSizePixel=0 d.Parent=Q local W=Instance.new("UIGradient")W.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0);NumberSequenceKeypoint.new(1,1)})W.Parent=d local B=d:Clone()B.AnchorPoint=Vector2.new(1,0)B.Position=UDim2.fromScale(1,0)B.Rotation=180 B.Parent=Q end local function gc()if not t.Vignette then Hc()return end nc(t.VignetteStrength)end local function yc()if J then E(J)J=nil end c.MotionBlur=nil o=nil end local function Vc()if J then return end J=Instance.new("BlurEffect")J.Name=I.ShaderPrefix.."MotionBlur"J.Size=0 J.Parent=d c.MotionBlur=J local f=workspace.CurrentCamera if f then o=f.CFrame end end H(l.RenderStepped,function(f)if not r then return end if k.FullBright then d.Brightness=5 d.Ambient=Color3.fromRGB(255,255,255)end if T.AspectEnabled and B then local f=B.CFrame B.CFrame=f*CFrame.new(0,0,0,1,0,0,0,T.AspectValue,0,0,0,1)end d.PostProcessing=true if c.ColorCorrection then local f=c.ColorCorrection f.Saturation=t.Saturation f.Brightness=t.Brightness f.Contrast=t.Contrast else local f=Instance.new("ColorCorrectionEffect")f.Name=I.ShaderPrefix.."ColorCorrection"f.Saturation=t.Saturation f.Brightness=t.Brightness f.Contrast=t.Contrast f.Parent=d c.ColorCorrection=f end if c.Bloom then c.Bloom.Intensity=t.BloomIntensity c.Bloom.Size=t.BloomSize c.Bloom.Threshold=t.BloomThreshold elseif t.BloomIntensity>0 then local f=Instance.new("BloomEffect")f.Name=I.ShaderPrefix.."Bloom"f.Intensity=t.BloomIntensity f.Size=t.BloomSize f.Threshold=t.BloomThreshold f.Parent=d c.Bloom=f end if c.Blur then c.Blur.Size=t.Blur elseif t.Blur>0 then local f=Instance.new("BlurEffect")f.Name=I.ShaderPrefix.."Blur"f.Size=t.Blur f.Parent=d c.Blur=f end if c.SunRays then c.SunRays.Intensity=t.SunRaysIntensity c.SunRays.Spread=t.SunRaysSpread elseif t.SunRaysIntensity>0 then local f=Instance.new("SunRaysEffect")f.Name=I.ShaderPrefix.."SunRays"f.Intensity=t.SunRaysIntensity f.Spread=t.SunRaysSpread f.Parent=d c.SunRays=f end if c.DepthOfField then c.DepthOfField.FarIntensity=t.DOFFarIntensity c.DepthOfField.NearIntensity=t.DOFNearIntensity c.DepthOfField.FocusDistance=t.DOFFocusDistance elseif t.DOFFarIntensity>0 or t.DOFNearIntensity>0 then local f=Instance.new("DepthOfFieldEffect")f.Name=I.ShaderPrefix.."DepthOfField"f.FarIntensity=t.DOFFarIntensity f.NearIntensity=t.DOFNearIntensity f.FocusDistance=t.DOFFocusDistance f.Parent=d c.DepthOfField=f end if c.Atmosphere then c.Atmosphere.Density=t.AtmosphereDensity c.Atmosphere.Color=t.AtmosphereColor elseif t.AtmosphereDensity>0 then local f=Instance.new("Atmosphere")f.Name=I.ShaderPrefix.."Atmosphere"f.Density=t.AtmosphereDensity f.Color=t.AtmosphereColor f.Parent=d c.Atmosphere=f end if not t.MotionBlur then if J then yc()end else local x=workspace.CurrentCamera if x then Vc()if not o then o=x.CFrame else local l=x.CFrame local v=((l.Position-o.Position)).Magnitude local d,F,W=l:ToOrientation()local B,I,r=o:ToOrientation()local P=(math.abs(d-B)+math.abs(F-I))+math.abs(W-r)local X=v+P*18 local Y=K((X*t.MotionBlurStrength)*12,0,24)J.Size=J.Size+((Y-J.Size))*K(f*12,0,1)o=l end end end end)local function Oc()t.Saturation=0 t.Brightness=0 t.Contrast=0 t.Blur=0 t.BloomIntensity=0 t.BloomSize=24 t.BloomThreshold=1 t.SunRaysIntensity=0 t.SunRaysSpread=1 t.DOFFarIntensity=0 t.DOFNearIntensity=0 t.DOFFocusDistance=10 t.AtmosphereDensity=0 t.MotionBlur=false t.MotionBlurStrength=0 t.Vignette=false t.VignetteStrength=0 N="Default"end local function Kc() end local function Ec() end local function zc() end local function ac() end local function Rc() end local function ec() end local function jc(f)if c[f]then return c[f]end if f=="ColorCorrection"then return Dc("ColorCorrection",{Saturation=t.Saturation,Brightness=t.Brightness,Contrast=t.Contrast})elseif f=="Blur"then return Dc("Blur",{Size=t.Blur})elseif f=="Bloom"then return Dc("Bloom",{Intensity=t.BloomIntensity,Size=t.BloomSize,Threshold=t.BloomThreshold})elseif f=="SunRays"then return Dc("SunRays",{Intensity=t.SunRaysIntensity,Spread=t.SunRaysSpread})elseif f=="DepthOfField"then return Dc("DepthOfField",{FarIntensity=t.DOFFarIntensity;NearIntensity=t.DOFNearIntensity;FocusDistance=t.DOFFocusDistance})elseif f=="Atmosphere"then return Dc("Atmosphere",{Density=t.AtmosphereDensity;Color=t.AtmosphereColor})end return nil end local function Lc(f,x)t[f]=x N="Custom"oc.Text="Preset: Custom"end local ic={Default=function()Oc()hc()Hc()yc()end,Cinematic=function()Oc()hc()Hc()Dc("Bloom",{Intensity=.5;Size=20,Threshold=.6})Dc("DepthOfField",{FarIntensity=.6;NearIntensity=.2;FocusDistance=15})Dc("ColorCorrection",{Saturation=.2;Contrast=.1,Brightness=-0.05})Dc("SunRays",{Intensity=.4,Spread=.8})Dc("Atmosphere",{Density=.3,Color=Color3.fromRGB(200,180,255)})end,Neon=function()Oc()hc()Hc()Dc("Bloom",{Intensity=1.2,Size=40;Threshold=.3})Dc("ColorCorrection",{Saturation=.8,Contrast=.3,Brightness=.1})Dc("Blur",{Size=3})end;Vintage=function()Oc()hc()Hc()Dc("ColorCorrection",{Saturation=-0.3,Contrast=-0.1,Brightness=.05;TintColor=Color3.fromRGB(255,200,150)})Dc("Bloom",{Intensity=.2;Size=15;Threshold=.9})Dc("Blur",{Size=2})end,Cold=function()Oc()hc()Hc()Dc("ColorCorrection",{TintColor=Color3.fromRGB(150,200,255);Brightness=-0.05,Saturation=-0.1})Dc("Atmosphere",{Color=Color3.fromRGB(100,150,255);Density=.4})end;Warm=function()Oc()hc()Hc()Dc("ColorCorrection",{TintColor=Color3.fromRGB(255,200,100),Brightness=.05,Saturation=.1})Dc("Bloom",{Intensity=.4;Size=25;Threshold=.7})end,Noir=function()Oc()hc()Hc()Dc("ColorCorrection",{Saturation=-1,Contrast=.5,Brightness=-0.1})Dc("Bloom",{Intensity=.1;Size=5;Threshold=.5})end;Dreamy=function()Oc()hc()Hc()Dc("Bloom",{Intensity=.8,Size=35,Threshold=.4})Dc("Blur",{Size=6})Dc("ColorCorrection",{Brightness=.1;Saturation=.3})end;Pastel=function()Oc()hc()Hc()Dc("ColorCorrection",{Brightness=.15,Contrast=-0.1;Saturation=.1;TintColor=Color3.fromRGB(255,200,200)})Dc("Bloom",{Intensity=.6;Size=30;Threshold=.5})Dc("Blur",{Size=2})end,Cyberpunk=function()Oc()hc()Hc()Dc("ColorCorrection",{Brightness=-0.1;Contrast=.4,Saturation=.6;TintColor=Color3.fromRGB(255,50,200)})Dc("Bloom",{Intensity=1,Size=45,Threshold=.2})Dc("SunRays",{Intensity=.6,Spread=.9})end;Horror=function()Oc()hc()Hc()Dc("ColorCorrection",{Brightness=-0.3,Contrast=.5;Saturation=-0.5;TintColor=Color3.fromRGB(50,200,50)})Dc("DepthOfField",{FarIntensity=.8,NearIntensity=.1;FocusDistance=5})Dc("Blur",{Size=4})end;Sunset=function()Oc()hc()Hc()Dc("ColorCorrection",{Brightness=.1;Contrast=.1;Saturation=.3,TintColor=Color3.fromRGB(255,150,50)})Dc("Bloom",{Intensity=.7;Size=25;Threshold=.5})Dc("Atmosphere",{Color=Color3.fromRGB(255,100,50),Density=.3})Dc("SunRays",{Intensity=.5;Spread=.7})end,Aqua=function()Oc()hc()Hc()Dc("ColorCorrection",{Brightness=-0.05,Contrast=.1;Saturation=.2;TintColor=Color3.fromRGB(50,200,255)})Dc("Bloom",{Intensity=.4,Size=20,Threshold=.6})Dc("Atmosphere",{Color=Color3.fromRGB(50,150,255),Density=.2})Dc("Blur",{Size=1})end,Sepia=function()Oc()hc()Hc()Dc("ColorCorrection",{Brightness=.05,Contrast=.1;Saturation=-0.5;TintColor=Color3.fromRGB(200,150,100)})Dc("Bloom",{Intensity=.2;Size=15;Threshold=.8})Dc("Blur",{Size=1})end;Matrix=function()Oc()hc()Hc()Dc("ColorCorrection",{Brightness=-0.1,Contrast=.3,Saturation=.2,TintColor=Color3.fromRGB(50,255,50)})Dc("Bloom",{Intensity=.3;Size=10,Threshold=.7})Dc("Blur",{Size=1})end,Mystic=function()Oc()hc()Hc()Dc("ColorCorrection",{Brightness=.05,Contrast=.1,Saturation=.4;TintColor=Color3.fromRGB(150,100,255)})Dc("Bloom",{Intensity=.9;Size=40;Threshold=.3})Dc("Atmosphere",{Color=Color3.fromRGB(100,50,200),Density=.2})Dc("DepthOfField",{FarIntensity=.3,NearIntensity=.1;FocusDistance=20})end,Retro=function()Oc()hc()Hc()Dc("ColorCorrection",{Brightness=.1,Contrast=.2,Saturation=.1;TintColor=Color3.fromRGB(255,200,100)})Dc("Bloom",{Intensity=.5,Size=18;Threshold=.7})Dc("Blur",{Size=3})t.Vignette=true t.VignetteStrength=.3 gc()end;Aurora=function()Oc()hc()Hc()Dc("ColorCorrection",{Brightness=.05,Contrast=.1;Saturation=.3;TintColor=Color3.fromRGB(100,255,200)})Dc("Bloom",{Intensity=.6;Size=30,Threshold=.4})Dc("Atmosphere",{Color=Color3.fromRGB(50,255,150),Density=.15})Dc("SunRays",{Intensity=.3;Spread=.6})end,["Soapy Graphics (Beta)"]=function()Oc()hc()Hc()Dc("DepthOfField",{FarIntensity=1;NearIntensity=.1,FocusDistance=10})Dc("Bloom",{Intensity=.3,Size=20,Threshold=.8})Dc("Atmosphere",{Density=.3,Color=Color3.fromRGB(200,200,210)})Dc("ColorCorrection",{Brightness=.2,Contrast=-0.1,Saturation=-0.1})end,["Saturation My Love"]=function()Oc()hc()Hc()yc()Dc("ColorCorrection",{Saturation=1;Brightness=.05,Contrast=-0.1})Dc("Atmosphere",{Density=.01;Color=Color3.fromRGB(0,0,0)})Dc("Bloom",{Intensity=0;Size=0,Threshold=0})T.FOVValue=120 T.FOVEnabled=true C(120)end}local uc={"Default","Cinematic";"Neon","Vintage","Cold";"Warm";"Noir","Dreamy","Pastel";"Cyberpunk";"Horror","Sunset","Aqua";"Sepia","Matrix","Mystic","Retro","Aurora";"Soapy Graphics (Beta)";"Saturation My Love"}local fF local xF local function lF()local f=c.ColorCorrection if f then t.Saturation=f.Saturation t.Brightness=f.Brightness t.Contrast=f.Contrast else t.Saturation=0 t.Brightness=0 t.Contrast=0 end if c.Blur then t.Blur=c.Blur.Size else t.Blur=0 end if c.Bloom then t.BloomIntensity=c.Bloom.Intensity t.BloomSize=c.Bloom.Size t.BloomThreshold=c.Bloom.Threshold else t.BloomIntensity=0 t.BloomSize=24 t.BloomThreshold=1 end if c.SunRays then t.SunRaysIntensity=c.SunRays.Intensity t.SunRaysSpread=c.SunRays.Spread else t.SunRaysIntensity=0 t.SunRaysSpread=1 end if c.DepthOfField then t.DOFFarIntensity=c.DepthOfField.FarIntensity t.DOFNearIntensity=c.DepthOfField.NearIntensity t.DOFFocusDistance=c.DepthOfField.FocusDistance else t.DOFFarIntensity=0 t.DOFNearIntensity=0 t.DOFFocusDistance=10 end if c.Atmosphere then t.AtmosphereDensity=c.Atmosphere.Density t.AtmosphereColor=c.Atmosphere.Color else t.AtmosphereDensity=0 end end local function vF(f)local x=ic[f]if not x then return end hc()Hc()yc()Oc()N=f x()lF()oc.Text="Preset: "..f Jc.Text="ACTIVE"if fF then fF()end if xF then xF()end end for f,x in ipairs(uc)do local l=Instance.new("TextButton")l.Name="Preset_"..x l.LayoutOrder=f l.BackgroundColor3=Color3.fromRGB(41,19,59)l.BackgroundTransparency=.1 l.BorderSizePixel=0 l.AutoButtonColor=false l.Text=""l.ZIndex=23 l.Parent=Cc y(l,13)local v=V(l,I.PurpleLight,.89,1)local d=Instance.new("Frame")d.Position=UDim2.fromOffset(9,9)d.Size=UDim2.fromOffset(4,37)d.BackgroundColor3=I.Purple d.BorderSizePixel=0 d.ZIndex=24 d.Parent=l y(d,5)local F=Instance.new("TextLabel")F.Position=UDim2.fromOffset(23,7)F.Size=UDim2.new(1,-31,0,19)F.BackgroundTransparency=1 F.Font=Enum.Font.GothamSemibold F.Text=x F.TextSize=10 F.TextColor3=I.White F.TextTruncate=Enum.TextTruncate.AtEnd F.TextXAlignment=Enum.TextXAlignment.Left F.ZIndex=25 F.Parent=l local W=Instance.new("TextLabel")W.Position=UDim2.fromOffset(23,26)W.Size=UDim2.new(1,-31,0,12)W.BackgroundTransparency=1 W.Font=Enum.Font.Gotham W.Text="Apply visual preset"W.TextSize=7 W.TextColor3=I.Muted W.TextXAlignment=Enum.TextXAlignment.Left W.ZIndex=25 W.Parent=l H(l.MouseEnter,function()g(l,{BackgroundColor3=Color3.fromRGB(55,25,78),BackgroundTransparency=.02},.2,Enum.EasingStyle.Sine)g(v,{Transparency=.42,Thickness=1.25},.2)g(d,{Size=UDim2.fromOffset(6,39)},.2,Enum.EasingStyle.Back)end)H(l.MouseLeave,function()g(l,{BackgroundColor3=Color3.fromRGB(41,19,59);BackgroundTransparency=.1},.3,Enum.EasingStyle.Sine)g(v,{Transparency=.89;Thickness=1},.3)g(d,{Size=UDim2.fromOffset(4,37)},.3,Enum.EasingStyle.Sine)end)H(l.MouseButton1Click,function()vF(x)g(l,{BackgroundColor3=I.Purple},.12,Enum.EasingStyle.Sine)task.delay(.13,function()if not r then return end g(l,{BackgroundColor3=Color3.fromRGB(41,19,59)},.35,Enum.EasingStyle.Sine)end)end)end Cc.CanvasSize=UDim2.fromOffset(0,math.ceil(#uc/3)*63)local dF={{Name="Saturation";Key="Saturation";Min=-1;Max=1;Step=.01,Default=0},{Name="Brightness";Key="Brightness",Min=-1;Max=1;Step=.01,Default=0};{Name="Contrast",Key="Contrast";Min=-1;Max=1;Step=.01;Default=0},{Name="Blur";Key="Blur",Min=0;Max=24,Step=1,Default=0},{Name="Bloom";Key="BloomIntensity",Min=0,Max=2;Step=.01,Default=0},{Name="Bloom Size",Key="BloomSize",Min=1;Max=56;Step=1,Default=24},{Name="Sun Rays";Key="SunRaysIntensity",Min=0,Max=1,Step=.01,Default=0},{Name="DOF Far";Key="DOFFarIntensity",Min=0,Max=1;Step=.01;Default=0},{Name="DOF Near";Key="DOFNearIntensity",Min=0,Max=1;Step=.01;Default=0},{Name="DOF Focus";Key="DOFFocusDistance",Min=1;Max=100;Step=1,Default=10};{Name="Atmosphere";Key="AtmosphereDensity",Min=0;Max=1;Step=.01;Default=0},{Name="Motion Blur Strength";Key="MotionBlurStrength",Min=0,Max=1;Step=.01;Default=0};{Name="Vignette Strength",Key="VignetteStrength";Min=0;Max=1,Step=.01,Default=0}}local FF={}local WF={}local function BF(f,l,v)local d=Instance.new("Frame")d.Name=l.Key d.Position=UDim2.fromOffset(8,((v-1))*65)d.Size=UDim2.new(1,-16,0,58)d.BackgroundColor3=Color3.fromRGB(39,18,56)d.BackgroundTransparency=.18 d.BorderSizePixel=0 d.ZIndex=23 d.Parent=f y(d,13)V(d,I.PurpleLight,.91,1)local F=Instance.new("TextLabel")F.Position=UDim2.fromOffset(13,7)F.Size=UDim2.new(1,-100,0,18)F.BackgroundTransparency=1 F.Font=Enum.Font.GothamMedium F.Text=l.Name F.TextSize=10 F.TextColor3=I.Text F.TextXAlignment=Enum.TextXAlignment.Left F.ZIndex=24 F.Parent=d local W=Instance.new("TextLabel")W.AnchorPoint=Vector2.new(1,0)W.Position=UDim2.new(1,-13,0,7)W.Size=UDim2.fromOffset(70,18)W.BackgroundTransparency=1 W.Font=Enum.Font.GothamSemibold W.TextSize=9 W.TextColor3=I.PurpleLight W.TextXAlignment=Enum.TextXAlignment.Right W.ZIndex=24 W.Parent=d local B=Instance.new("Frame")B.Position=UDim2.fromOffset(13,37)B.Size=UDim2.new(1,-26,0,6)B.BackgroundColor3=Color3.fromRGB(68,38,84)B.BorderSizePixel=0 B.ZIndex=24 B.Parent=d y(B,10)local r=Instance.new("Frame")r.Size=UDim2.fromScale(0,1)r.BackgroundColor3=I.Purple r.BorderSizePixel=0 r.ZIndex=25 r.Parent=B y(r,10)local P=Instance.new("Frame")P.AnchorPoint=Vector2.new(.5,.5)P.Position=UDim2.fromScale(0,.5)P.Size=UDim2.fromOffset(12,12)P.BackgroundColor3=I.White P.BorderSizePixel=0 P.ZIndex=26 P.Parent=B y(P,99)local X=false local function Y(f,x)local v=((f-l.Min))/((l.Max-l.Min))v=K(v,0,1)W.Text=string.format("%.2f",f)if x then r.Size=UDim2.fromScale(v,1)P.Position=UDim2.fromScale(v,.5)else g(r,{Size=UDim2.fromScale(v,1)},.08,Enum.EasingStyle.Sine)g(P,{Position=UDim2.fromScale(v,.5)},.08,Enum.EasingStyle.Sine)end end local function G(f)local x=math.max(B.AbsoluteSize.X,1)local v=K(((f-B.AbsolutePosition.X))/x,0,1)local d=l.Min+((l.Max-l.Min))*v local F=math.round(d/l.Step)*l.Step F=K(F,l.Min,l.Max)t[l.Key]=F Y(F,false)Lc(l.Key,F)end H(B.InputBegan,function(f)if f.UserInputType==Enum.UserInputType.MouseButton1 then X=true G(f.Position.X)end end)H(x.InputChanged,function(f)if not X then return end if f.UserInputType==Enum.UserInputType.MouseMovement then G(f.Position.X)end end)H(x.InputEnded,function(f)if f.UserInputType==Enum.UserInputType.MouseButton1 then X=false end end)FF[l.Key]={SetValue=Y}Y(l.Default,true)end for f,x in ipairs(dF)do BF(kc,x,f)end fF=function()for f,x in ipairs(dF)do local l=FF[x.Key]if l then local f=t[x.Key]if f==nil then f=x.Default end l.SetValue(f,true)end end end kc.CanvasSize=UDim2.fromOffset(0,#dF*65+140)local IF={}local function rF(f,x,l,v,d)local F=(#dF*65+8)+((l-1))*65 local W=Instance.new("TextButton")W.Name=x W.Position=UDim2.fromOffset(8,F)W.Size=UDim2.new(1,-16,0,45)W.BackgroundColor3=Color3.fromRGB(39,18,56)W.BackgroundTransparency=.18 W.BorderSizePixel=0 W.AutoButtonColor=false W.Text=""W.ZIndex=23 W.Parent=f y(W,13)V(W,I.PurpleLight,.91,1)local B=Instance.new("TextLabel")B.Position=UDim2.fromOffset(13,0)B.Size=UDim2.new(1,-85,1,0)B.BackgroundTransparency=1 B.Font=Enum.Font.GothamMedium B.Text=x B.TextSize=10 B.TextColor3=I.Text B.TextXAlignment=Enum.TextXAlignment.Left B.ZIndex=24 B.Parent=W local r=Instance.new("Frame")r.AnchorPoint=Vector2.new(1,.5)r.Position=UDim2.new(1,-13,.5,0)r.Size=UDim2.fromOffset(42,20)r.BackgroundColor3=Color3.fromRGB(61,34,78)r.BorderSizePixel=0 r.ZIndex=24 r.Parent=W y(r,99)local P=Instance.new("Frame")P.Position=UDim2.fromOffset(2,2)P.Size=UDim2.fromOffset(16,16)P.BackgroundColor3=I.White P.BorderSizePixel=0 P.ZIndex=25 P.Parent=r y(P,99)local function X()local f=v()if f then g(r,{BackgroundColor3=I.Purple},.18,Enum.EasingStyle.Sine)g(P,{Position=UDim2.fromOffset(24,2)},.22,Enum.EasingStyle.Back)else g(r,{BackgroundColor3=Color3.fromRGB(61,34,78)},.18,Enum.EasingStyle.Sine)g(P,{Position=UDim2.fromOffset(2,2)},.22,Enum.EasingStyle.Back)end end H(W.MouseButton1Click,function()local f=not v()d(f)N="Custom"oc.Text="Preset: Custom"X()end)IF[x]=X X()end rF(kc,"Motion Blur",1,function()return t.MotionBlur end,function(f)t.MotionBlur=f t.MotionBlurStrength=math.max(t.MotionBlurStrength,.15)if f then Vc()else yc()end end)rF(kc,"Vignette",2,function()return t.Vignette end,function(f)t.Vignette=f if f then t.VignetteStrength=math.max(t.VignetteStrength,.3)gc()else Hc()end end)local PF=3 local function XF(f,x,l)rF(kc,f,PF,x,l)PF=PF+1 end local function YF(f,l)local v=PF local d=Instance.new("Frame")d.Name=f.Key d.Position=UDim2.fromOffset(8,(#dF*65+8)+((v-1))*65)d.Size=UDim2.new(1,-16,0,58)d.BackgroundColor3=Color3.fromRGB(39,18,56)d.BackgroundTransparency=.18 d.BorderSizePixel=0 d.ZIndex=23 d.Parent=kc y(d,13)V(d,I.PurpleLight,.91,1)local F=Instance.new("TextLabel")F.Position=UDim2.fromOffset(13,7)F.Size=UDim2.new(1,-100,0,18)F.BackgroundTransparency=1 F.Font=Enum.Font.GothamMedium F.Text=f.Name F.TextSize=10 F.TextColor3=I.Text F.TextXAlignment=Enum.TextXAlignment.Left F.ZIndex=24 F.Parent=d local W=Instance.new("TextLabel")W.AnchorPoint=Vector2.new(1,0)W.Position=UDim2.new(1,-13,0,7)W.Size=UDim2.fromOffset(70,18)W.BackgroundTransparency=1 W.Font=Enum.Font.GothamSemibold W.TextSize=9 W.TextColor3=I.PurpleLight W.TextXAlignment=Enum.TextXAlignment.Right W.ZIndex=24 W.Parent=d local B=Instance.new("Frame")B.Position=UDim2.fromOffset(13,37)B.Size=UDim2.new(1,-26,0,6)B.BackgroundColor3=Color3.fromRGB(68,38,84)B.BorderSizePixel=0 B.ZIndex=24 B.Parent=d y(B,10)local r=Instance.new("Frame")r.Size=UDim2.fromScale(0,1)r.BackgroundColor3=I.Purple r.BorderSizePixel=0 r.ZIndex=25 r.Parent=B y(r,10)local P=Instance.new("Frame")P.AnchorPoint=Vector2.new(.5,.5)P.Position=UDim2.fromScale(0,.5)P.Size=UDim2.fromOffset(12,12)P.BackgroundColor3=I.White P.BorderSizePixel=0 P.ZIndex=26 P.Parent=B y(P,99)local X=false local function Y(x,l)local v=K(((x-f.Min))/((f.Max-f.Min)),0,1)W.Text=string.format(f.Format or"%.2f",x)if l then r.Size=UDim2.fromScale(v,1)P.Position=UDim2.fromScale(v,.5)else g(r,{Size=UDim2.fromScale(v,1)},.08,Enum.EasingStyle.Sine)g(P,{Position=UDim2.fromScale(v,.5)},.08,Enum.EasingStyle.Sine)end end local function G(x)local v=math.max(B.AbsoluteSize.X,1)local d=K(((x-B.AbsolutePosition.X))/v,0,1)local F=f.Min+((f.Max-f.Min))*d local W=math.round(F/f.Step)*f.Step W=K(W,f.Min,f.Max)T[f.Key]=W Y(W,false)if l then l(W)end end H(B.InputBegan,function(f)if f.UserInputType==Enum.UserInputType.MouseButton1 then X=true G(f.Position.X)end end)H(x.InputChanged,function(f)if not X then return end if f.UserInputType==Enum.UserInputType.MouseMovement then G(f.Position.X)end end)H(x.InputEnded,function(f)if f.UserInputType==Enum.UserInputType.MouseButton1 then X=false end end)FF[f.Key]={SetValue=Y}Y(f.Default,true)PF=PF+1 end XF("FullBright",function()return k.FullBright end,function(f)z(f)end)XF("No Lag",function()return k.NoLag end,function(f)k.NoLag=f if f then R()else e()end end)XF("Enable FOV Changer",function()return T.FOVEnabled end,function(f)T.FOVEnabled=f if f then S()C(T.FOVValue)else U()w()end end)YF({Name="FOV";Key="FOVValue",Min=1;Max=120,Step=1;Default=80,Format="%.0f"},function(f)T.FOVValue=f if T.FOVEnabled then C(f)end end)XF("Enable Aspect Ratio",function()return T.AspectEnabled end,function(f)T.AspectEnabled=f end)YF({Name="Ratio Value",Key="AspectValue",Min=.05,Max=1.14,Step=.01;Default=.6;Format="%.2f"})local GF=((#dF*65+8)+PF*65)+20 kc.CanvasSize=UDim2.fromOffset(0,GF)xF=function()for f,x in pairs(IF)do x()end if FF.FOVValue then FF.FOVValue.SetValue(T.FOVValue,true)end if FF.AspectValue then FF.AspectValue.SetValue(T.AspectValue,true)end end H(Uc.MouseButton1Click,function()vF("Default")fF()xF()oc.Text="Preset: Default"end)local ZF=Instance.new("Frame")ZF.Name="Navigation"ZF.Position=UDim2.new(0,26,1,-67)ZF.Size=UDim2.new(1,-52,0,50)ZF.BackgroundTransparency=1 ZF.BorderSizePixel=0 ZF.ZIndex=50 ZF.Parent=fc local NF=145 local pF=50 local mF=5 local function bF(f)local x=Instance.new("Frame")x.Position=UDim2.fromOffset(8,14)x.Size=UDim2.fromOffset(20,15)x.BackgroundColor3=I.White x.BorderSizePixel=0 x.ZIndex=55 x.Parent=f y(x,3)local l=Instance.new("Frame")l.AnchorPoint=Vector2.new(.5,.5)l.Position=UDim2.fromOffset(13,10)l.Size=UDim2.fromOffset(15,4)l.BackgroundColor3=I.White l.BorderSizePixel=0 l.Rotation=31 l.ZIndex=56 l.Parent=f y(l,3)local v=l:Clone()v.Position=UDim2.fromOffset(23,10)v.Rotation=-31 v.Parent=f local d=Instance.new("Frame")d.AnchorPoint=Vector2.new(.5,1)d.Position=UDim2.fromScale(.5,1)d.Size=UDim2.fromOffset(6,9)d.BackgroundColor3=I.White d.BorderSizePixel=0 d.ZIndex=57 d.Parent=x y(d,2)end local function AF(f)for x=0,1,1 do for l=0,1,1 do local v=Instance.new("Frame")v.Position=UDim2.fromOffset(7+x*12,7+l*12)v.Size=UDim2.fromOffset(9,9)v.BackgroundColor3=I.White v.BorderSizePixel=0 v.ZIndex=55 v.Parent=f y(v,3)end end end local function QF(f)local x=Instance.new("Frame")x.AnchorPoint=Vector2.new(.5,.5)x.Position=UDim2.fromScale(.5,.5)x.Size=UDim2.fromOffset(13,13)x.BackgroundColor3=I.White x.BorderSizePixel=0 x.ZIndex=56 x.Parent=f y(x,99)for x=0,7,1 do local l=Instance.new("Frame")l.AnchorPoint=Vector2.new(.5,.5)l.Position=UDim2.fromScale(.5,.5)l.Size=UDim2.fromOffset(5,10)l.BackgroundColor3=I.White l.BorderSizePixel=0 l.Rotation=x*45 l.ZIndex=55 l.Parent=f y(l,2)end end local function JF(f)local x=Instance.new("Frame")x.AnchorPoint=Vector2.new(.5,.5)x.Position=UDim2.fromScale(.5,.5)x.Size=UDim2.fromOffset(22,3)x.BackgroundColor3=I.White x.BorderSizePixel=0 x.ZIndex=55 x.Parent=f y(x,3)end local function oF(f)local x=Instance.new("Frame")x.Position=UDim2.fromOffset(5,5)x.Size=UDim2.fromOffset(13,22)x.BackgroundColor3=I.White x.BorderSizePixel=0 x.ZIndex=55 x.Parent=f y(x,3)local l=Instance.new("Frame")l.Position=UDim2.fromOffset(17,16)l.Size=UDim2.fromOffset(12,3)l.BackgroundColor3=I.White l.BorderSizePixel=0 l.ZIndex=57 l.Parent=f y(l,3)local v=Instance.new("Frame")v.Position=UDim2.fromOffset(24,12)v.Size=UDim2.fromOffset(8,3)v.BackgroundColor3=I.White v.BorderSizePixel=0 v.Rotation=36 v.ZIndex=58 v.Parent=f y(v,3)local d=v:Clone()d.Position=UDim2.fromOffset(24,20)d.Rotation=-36 d.Parent=f end local cF={}local function tF(f,x,l,v)local d=Instance.new("TextButton")d.Name=x d.Position=UDim2.fromOffset(((f-1))*((NF+mF)),0)d.Size=UDim2.fromOffset(NF,pF)d.BackgroundColor3=Color3.fromRGB(38,18,56)d.BackgroundTransparency=.1 d.BorderSizePixel=0 d.AutoButtonColor=false d.Text=""d.ZIndex=51 d.Parent=ZF y(d,I.ButtonRadius)local F=V(d,I.PurpleLight,.87,1)local W=Instance.new("Frame")W.Position=UDim2.fromOffset(8,7)W.Size=UDim2.fromOffset(36,36)W.BackgroundColor3=I.Purple W.BackgroundTransparency=.78 W.BorderSizePixel=0 W.ZIndex=52 W.Parent=d y(W,11)v(W)local B=Instance.new("TextLabel")B.Position=UDim2.fromOffset(53,6)B.Size=UDim2.new(1,-60,0,18)B.BackgroundTransparency=1 B.Font=Enum.Font.GothamSemibold B.Text=x B.TextSize=11 B.TextColor3=I.Text B.TextXAlignment=Enum.TextXAlignment.Left B.ZIndex=53 B.Parent=d local r=Instance.new("TextLabel")r.Position=UDim2.fromOffset(53,24)r.Size=UDim2.new(1,-60,0,15)r.BackgroundTransparency=1 r.Font=Enum.Font.Gotham r.Text=l r.TextSize=8 r.TextColor3=I.Muted r.TextXAlignment=Enum.TextXAlignment.Left r.ZIndex=53 r.Parent=d H(d.MouseEnter,function()g(d,{BackgroundColor3=Color3.fromRGB(53,25,76),BackgroundTransparency=.02},.22,Enum.EasingStyle.Sine)g(F,{Transparency=.45;Thickness=1.3},.22,Enum.EasingStyle.Sine)g(W,{BackgroundTransparency=.55;Size=UDim2.fromOffset(38,38);Position=UDim2.fromOffset(7,6)},.22,Enum.EasingStyle.Back)g(B,{TextColor3=I.White},.18)end)H(d.MouseLeave,function()g(d,{BackgroundColor3=Color3.fromRGB(38,18,56);BackgroundTransparency=.1},.3,Enum.EasingStyle.Sine)g(F,{Transparency=.87,Thickness=1},.3,Enum.EasingStyle.Sine)g(W,{BackgroundTransparency=.78,Size=UDim2.fromOffset(36,36);Position=UDim2.fromOffset(8,7)},.3,Enum.EasingStyle.Sine)g(B,{TextColor3=I.Text},.22)end)cF[x]=d return d end local TF=tF(1,"Home","About project",bF)local qF=tF(2,"Presets","Shader presets",AF)local CF=tF(3,"Settings","Fine controls",QF)local wF=tF(4,"Collapse","Hide window",JF)local sF=tF(5,"Exit","Unload engine",oF)local MF={Home=Xc;Presets=tc;Settings=sc}local function SF(f)local x=MF[f]if not x then return end if Z==f then return end Z=f for f,x in pairs(MF)do x.Visible=false end x.Visible=true x.Position=UDim2.fromOffset(8,0)g(x,{Position=UDim2.fromOffset(0,0)},.32,Enum.EasingStyle.Quint)end H(TF.MouseButton1Click,function()SF("Home")end)H(qF.MouseButton1Click,function()SF("Presets")end)H(CF.MouseButton1Click,function()SF("Settings")end)local function UF(f)if not r then return end if P==f then return end P=f if f then A=L.Position g(L,{Size=UDim2.fromOffset(8,8),BackgroundTransparency=1},.42,Enum.EasingStyle.Quint,Enum.EasingDirection.In)task.delay(.28,function()if not r or not P then return end L.Visible=false end)else L.Visible=true L.Position=A L.Size=UDim2.fromOffset(8,8)L.BackgroundTransparency=1 g(L,{Size=UDim2.fromOffset(I.Width,I.Height);BackgroundTransparency=.02},.48,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)end end H(wF.MouseButton1Click,function()UF(true)end)H(x.InputBegan,function(f,x)if x then return end if f.KeyCode==I.RightAlt then if X then return end UF(not P)end end)local kF=Instance.new("Frame")kF.Name="ConfirmOverlay"kF.Size=UDim2.fromScale(1,1)kF.BackgroundColor3=Color3.fromRGB(2,1,5)kF.BackgroundTransparency=1 kF.BorderSizePixel=0 kF.Visible=false kF.ZIndex=100 kF.Parent=L local DF=Instance.new("Frame")DF.AnchorPoint=Vector2.new(.5,.5)DF.Position=UDim2.fromScale(.5,.5)DF.Size=UDim2.fromOffset(420,220)DF.BackgroundColor3=Color3.fromRGB(28,13,43)DF.BackgroundTransparency=.02 DF.BorderSizePixel=0 DF.ZIndex=101 DF.Parent=kF y(DF,22)V(DF,I.PurpleLight,.57,1)O(DF,Color3.fromRGB(32,15,47),Color3.fromRGB(47,20,67),20)local hF=Instance.new("TextLabel")hF.Position=UDim2.fromOffset(25,22)hF.Size=UDim2.new(1,-50,0,32)hF.BackgroundTransparency=1 hF.Font=Enum.Font.GothamBold hF.Text="Close Yuki Shader Engine?"hF.TextSize=20 hF.TextColor3=I.White hF.TextXAlignment=Enum.TextXAlignment.Left hF.ZIndex=103 hF.Parent=DF local HF=Instance.new("TextLabel")HF.Position=UDim2.fromOffset(25,67)HF.Size=UDim2.new(1,-50,0,55)HF.BackgroundTransparency=1 HF.Font=Enum.Font.Gotham HF.Text="Are you sure you want to close the menu?\nPressing Yes will unload the Yuki Shader Engine."HF.TextSize=12 HF.TextColor3=I.Muted HF.TextWrapped=true HF.TextXAlignment=Enum.TextXAlignment.Left HF.TextYAlignment=Enum.TextYAlignment.Top HF.ZIndex=103 HF.Parent=DF local nF=Instance.new("TextButton")nF.Position=UDim2.fromOffset(25,151)nF.Size=UDim2.fromOffset(170,43)nF.BackgroundColor3=Color3.fromRGB(50,24,67)nF.BackgroundTransparency=.07 nF.BorderSizePixel=0 nF.AutoButtonColor=false nF.Text="No"nF.Font=Enum.Font.GothamSemibold nF.TextSize=12 nF.TextColor3=I.White nF.ZIndex=103 nF.Parent=DF y(nF,12)local gF=Instance.new("TextButton")gF.Position=UDim2.fromOffset(220,151)gF.Size=UDim2.fromOffset(170,43)gF.BackgroundColor3=I.Purple gF.BackgroundTransparency=.02 gF.BorderSizePixel=0 gF.AutoButtonColor=false gF.Text="Yes"gF.Font=Enum.Font.GothamSemibold gF.TextSize=12 gF.TextColor3=I.White gF.ZIndex=103 gF.Parent=DF y(gF,12)local function yF()X=true kF.Visible=true kF.BackgroundTransparency=1 DF.Size=UDim2.fromOffset(375,195)g(kF,{BackgroundTransparency=.28},.23,Enum.EasingStyle.Sine)g(DF,{Size=UDim2.fromOffset(420,220)},.38,Enum.EasingStyle.Back)end local function VF()g(kF,{BackgroundTransparency=1},.18,Enum.EasingStyle.Sine)g(DF,{Size=UDim2.fromOffset(375,195)},.18,Enum.EasingStyle.Quint)task.delay(.19,function()kF.Visible=false X=false end)end H(sF.MouseButton1Click,yF)H(nF.MouseButton1Click,VF)local function OF()if not r then return end r=false U()n()hc()Hc()yc()g(L,{Size=UDim2.fromOffset(5,5);BackgroundTransparency=1},.3,Enum.EasingStyle.Quint,Enum.EasingDirection.In)task.delay(.32,function()E(j)end)end H(gF.MouseButton1Click,OF)H(xc.InputBegan,function(f)if f.UserInputType==Enum.UserInputType.MouseButton1 then p=true m=f.Position b=L.Position end end)H(x.InputEnded,function(f)if f.UserInputType==Enum.UserInputType.MouseButton1 then p=false end end)H(x.InputChanged,function(f)if not p then return end if f.UserInputType~=Enum.UserInputType.MouseMovement then return end local x=f.Position-m L.Position=UDim2.new(b.X.Scale,b.X.Offset+x.X,b.Y.Scale,b.Y.Offset+x.Y)A=L.Position end)local KF=Random.new()local function EF(f)local x=KF:NextNumber(10,26)local l=Instance.new("Frame")l.Name="Bubble_"..f l.AnchorPoint=Vector2.new(.5,.5)l.Size=UDim2.fromOffset(x,x)l.BackgroundColor3=I.PurpleLight l.BackgroundTransparency=KF:NextNumber(.44,.7)l.BorderSizePixel=0 l.ZIndex=6 l.Parent=u y(l,99)local v=V(l,Color3.fromRGB(231,206,255),KF:NextNumber(.48,.78),.8)local d=Instance.new("Frame")d.AnchorPoint=Vector2.new(.5,.5)d.Position=UDim2.fromScale(.29,.27)d.Size=UDim2.fromScale(.23,.23)d.BackgroundColor3=I.White d.BackgroundTransparency=.24 d.BorderSizePixel=0 d.ZIndex=7 d.Parent=l y(d,99)local F=KF:NextNumber(20,I.Width-20)local W=KF:NextNumber(30,I.Height-90)l.Position=UDim2.fromOffset(F,W)table.insert(G,{Object=l;Stroke=v;X=F,Y=W;VX=KF:NextNumber(-18,18),VY=KF:NextNumber(-12,14);Phase=KF:NextNumber(0,math.pi*2);Radius=x,RingRadius=KF:NextNumber(32,125);RingSpeed=KF:NextNumber(.18,.55),RingWobble=KF:NextNumber(4,14)})end for f=1,I.BubbleCount,1 do EF(f)end H(l.RenderStepped,function(f)if not r then return end if not L.Visible then return end local l=x:GetMouseLocation()local v=L.AbsolutePosition local d=L.AbsoluteSize local F=l.X-v.X local W=l.Y-v.Y local B=F>=0 and(F<=d.X and(W>=0 and W<=d.Y))local P=math.max(d.X,1)local X=math.max(d.Y,1)if B then local x=os.clock()for l,v in ipairs(G)do local d=v.Phase+x*v.RingSpeed local B=math.sin(x*1.15+v.Phase*2)*v.RingWobble local r=v.RingRadius+B local Y=F+math.cos(d)*r local G=W+math.sin(d)*r Y=K(Y,v.Radius+5,(P-v.Radius)-5)G=K(G,v.Radius+5,(X-v.Radius)-5)local Z=Y-v.X local N=G-v.Y v.VX=v.VX+((Z*I.BubbleMagnet)*.92)*f v.VY=v.VY+((N*I.BubbleMagnet)*.92)*f v.VX=v.VX-(math.sin(d)*7)*f v.VY=v.VY+(math.cos(d)*7)*f local p=math.pow(.86,f*60)v.VX=v.VX*p v.VY=v.VY*p v.X=v.X+v.VX*f v.Y=v.Y+v.VY*f v.Object.Position=UDim2.fromOffset(v.X,v.Y)end else for x,l in ipairs(G)do l.VY=l.VY+I.BubbleGravity*f l.VX=l.VX*math.pow(.992,f*60)l.VX=l.VX+math.sin(os.clock()*.7+l.Phase)*.4 l.X=l.X+l.VX*f l.Y=l.Y+l.VY*f local v=(X-l.Radius)-7 if l.Y>=v then l.Y=v l.VY=-math.abs(l.VY)*.22 if math.abs(l.VY)<7 then l.VY=0 end end if l.X<-l.Radius then l.X=P+l.Radius l.Y=KF:NextNumber(X*.22,X*.55)l.VY=KF:NextNumber(0,15)end if l.X>P+l.Radius then l.X=-l.Radius l.Y=KF:NextNumber(X*.22,X*.55)l.VY=KF:NextNumber(0,15)end l.Object.Position=UDim2.fromOffset(l.X,l.Y)end end end)task.spawn(function()while r do for f,x in ipairs(G)do if x.Object and x.Object.Parent then g(x.Object,{BackgroundTransparency=KF:NextNumber(.44,.72)},KF:NextNumber(.9,1.6),Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)g(x.Stroke,{Transparency=KF:NextNumber(.48,.8)},KF:NextNumber(.9,1.6),Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)end end task.wait(.55)end end)task.spawn(function()while r do g(i,{Size=UDim2.new(1,195,1,195);BackgroundTransparency=.965},2.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)task.wait(2.6)if not r then break end g(i,{Size=UDim2.new(1,155,1,155);BackgroundTransparency=.95},2.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)task.wait(2.6)end end)task.spawn(function()while r do g(Ic,{Size=UDim2.fromOffset(11,11);BackgroundTransparency=.02},1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)task.wait(1)if not r then break end g(Ic,{Size=UDim2.fromOffset(8,8),BackgroundTransparency=.18},1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)task.wait(1)end end)H(xc.InputBegan,function(f)if f.UserInputType==Enum.UserInputType.MouseButton1 then p=true m=f.Position b=L.Position end end)A=L.Position vF("Default")SF("Home")if T.FOVEnabled then S()end local function zF()L.Visible=true L.Size=UDim2.fromOffset(20,20)L.BackgroundTransparency=1 g(L,{Size=UDim2.fromOffset(I.Width,I.Height);BackgroundTransparency=.02},.62,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)end local aF="Welcome to Yukishimaru Shaders! Good luck!"local RF="https://t.me/yukishaderenginekey_bot"local eF="YukiShaderKey.txt"local function jF()pcall(function()if writefile and readfile then local f=readfile(eF)if f==aF then return true end end end)return false end if jF()then zF()L.Visible=true else local f=Instance.new("ScreenGui")f.Name="YukiKeySystem"f.ResetOnSpawn=false f.IgnoreGuiInset=true f.DisplayOrder=1000000 f.ZIndexBehavior=Enum.ZIndexBehavior.Sibling pcall(function()if syn and syn.protect_gui then syn.protect_gui(f)end end)f.Parent=F local l=Instance.new("Frame")l.AnchorPoint=Vector2.new(.5,.5)l.Position=UDim2.fromScale(.5,.5)l.Size=UDim2.fromOffset(420,250)l.BackgroundColor3=I.BackgroundTop l.BackgroundTransparency=.02 l.BorderSizePixel=0 l.ClipsDescendants=true l.ZIndex=1 l.Parent=f y(l,I.WindowRadius)V(l,I.PurpleLight,.56,1.25)O(l,I.BackgroundTop,I.BackgroundBottom,35)local v=Instance.new("TextLabel")v.Position=UDim2.fromOffset(20,15)v.Size=UDim2.new(1,-40,0,55)v.BackgroundTransparency=1 v.Font=Enum.Font.GothamBold v.Text="Hello! You are in the BEST shaders script for roblox.\nHow to get key? Click on the \"Get Key\" button and go to my telegram bot.\nSubscribe to my channel then copy the key and paste! This is easy!"v.TextSize=11 v.TextColor3=I.White v.TextWrapped=true v.TextXAlignment=Enum.TextXAlignment.Left v.TextYAlignment=Enum.TextYAlignment.Top v.ZIndex=10 v.Parent=l local d=Instance.new("TextBox")d.Position=UDim2.fromOffset(20,80)d.Size=UDim2.new(1,-40,0,35)d.BackgroundColor3=I.PanelLight d.BackgroundTransparency=.15 d.BorderSizePixel=0 d.Font=Enum.Font.Gotham d.Text=""d.PlaceholderText="Enter key here..."d.TextSize=13 d.TextColor3=I.White d.PlaceholderColor3=I.Muted d.ZIndex=10 d.Parent=l y(d,10)V(d,I.PurpleLight,.8,1)local W=Instance.new("TextLabel")W.Position=UDim2.fromOffset(20,120)W.Size=UDim2.new(1,-40,0,20)W.BackgroundTransparency=1 W.Font=Enum.Font.GothamSemibold W.Text=""W.TextSize=10 W.TextColor3=I.White W.TextXAlignment=Enum.TextXAlignment.Left W.ZIndex=10 W.Parent=l local B=Instance.new("TextButton")B.Position=UDim2.fromOffset(20,150)B.Size=UDim2.fromOffset(180,35)B.BackgroundColor3=I.Purple B.BackgroundTransparency=.05 B.BorderSizePixel=0 B.AutoButtonColor=false B.Text="Get Key"B.Font=Enum.Font.GothamSemibold B.TextSize=12 B.TextColor3=I.White B.ZIndex=10 B.Parent=l y(B,10)V(B,I.PurpleLight,.45,1)local r=Instance.new("TextButton")r.Position=UDim2.fromOffset(220,150)r.Size=UDim2.fromOffset(180,35)r.BackgroundColor3=I.PurpleSoft r.BackgroundTransparency=.05 r.BorderSizePixel=0 r.AutoButtonColor=false r.Text="Execute!"r.Font=Enum.Font.GothamSemibold r.TextSize=12 r.TextColor3=I.White r.ZIndex=10 r.Parent=l y(r,10)V(r,I.PurpleLight,.45,1)B.MouseButton1Click:Connect(function()pcall(function()setclipboard(RF)end)d.Text=""W.Text="Bot link copied!"W.TextColor3=Color3.fromRGB(0,255,0)end)r.MouseButton1Click:Connect(function()local x=d.Text if x==aF then W.Text="YaY! Correct key! Execute script."W.TextColor3=Color3.fromRGB(0,255,0)task.wait(.5)pcall(function()if writefile then writefile(eF,aF)end end)zF()pcall(function()f:Destroy()end)else W.Text="Incorrect key!"W.TextColor3=Color3.fromRGB(255,0,0)end end)local P=Instance.new("Frame")P.Size=UDim2.fromScale(1,1)P.BackgroundTransparency=1 P.BorderSizePixel=0 P.ClipsDescendants=true P.ZIndex=5 P.Parent=l local X={}for f=1,30,1 do local x=KF:NextNumber(8,18)local l=Instance.new("Frame")l.AnchorPoint=Vector2.new(.5,.5)l.Size=UDim2.fromOffset(x,x)l.BackgroundColor3=I.PurpleLight l.BackgroundTransparency=KF:NextNumber(.5,.7)l.BorderSizePixel=0 l.ZIndex=6 l.Parent=P y(l,99)table.insert(X,{Object=l,X=KF:NextNumber(20,400);Y=KF:NextNumber(20,230),VX=KF:NextNumber(-10,10),VY=KF:NextNumber(-5,5);Phase=KF:NextNumber(0,math.pi*2);Radius=x})end task.spawn(function()while f and f.Parent do local f=x:GetMouseLocation()local v=l.AbsolutePosition local d=l.AbsoluteSize local F=f.X>=v.X and(f.X<=v.X+d.X and(f.Y>=v.Y and f.Y<=v.Y+d.Y))for f,x in ipairs(X)do x.VY=x.VY+30*task.wait()x.X=x.X+x.VX*task.wait()x.Y=x.Y+x.VY*task.wait()if x.Y>230-x.Radius then x.Y=230-x.Radius x.VY=-math.abs(x.VY)*.3 end if x.X<-x.Radius then x.X=420+x.Radius end if x.X>420+x.Radius then x.X=-x.Radius end x.Object.Position=UDim2.fromOffset(x.X,x.Y)end task.wait(.05)end end)end L.Visible=false local function LF()L.Visible=true L.Size=UDim2.fromOffset(20,20)L.BackgroundTransparency=1 g(L,{Size=UDim2.fromOffset(I.Width,I.Height);BackgroundTransparency=.02},.62,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)end L.Visible=false

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
-- RENDER LOOP (БЕЗ FOV, только эффекты)
--============================================================

Connect(
    RunService.RenderStepped,
    function(deltaTime)
        if not Alive then return end

        -- FullBright
        if PerformanceState.FullBright then
            Lighting.Brightness = 5
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        end

        -- Aspect Ratio (если нужен)
        if UISettings.AspectEnabled and Camera then
            local cf = Camera.CFrame
            Camera.CFrame = cf * CFrame.new(0,0,0, 1,0,0, 0,UISettings.AspectValue,0, 0,0,1)
        end

        -- ==== ПРИНУДИТЕЛЬНОЕ ОБНОВЛЕНИЕ ЭФФЕКТОВ (каждый кадр) ====
        Lighting.PostProcessing = true

        -- ColorCorrection
        if Effects.ColorCorrection then
            local cc = Effects.ColorCorrection
            cc.Saturation = ShaderState.Saturation
            cc.Brightness = ShaderState.Brightness
            cc.Contrast = ShaderState.Contrast
        else
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = CONFIG.ShaderPrefix .. "ColorCorrection"
            cc.Saturation = ShaderState.Saturation
            cc.Brightness = ShaderState.Brightness
            cc.Contrast = ShaderState.Contrast
            cc.Parent = Lighting
            Effects.ColorCorrection = cc
        end

        -- Bloom
        if Effects.Bloom then
            Effects.Bloom.Intensity = ShaderState.BloomIntensity
            Effects.Bloom.Size = ShaderState.BloomSize
            Effects.Bloom.Threshold = ShaderState.BloomThreshold
        elseif ShaderState.BloomIntensity > 0 then
            local bloom = Instance.new("BloomEffect")
            bloom.Name = CONFIG.ShaderPrefix .. "Bloom"
            bloom.Intensity = ShaderState.BloomIntensity
            bloom.Size = ShaderState.BloomSize
            bloom.Threshold = ShaderState.BloomThreshold
            bloom.Parent = Lighting
            Effects.Bloom = bloom
        end

        -- Blur
        if Effects.Blur then
            Effects.Blur.Size = ShaderState.Blur
        elseif ShaderState.Blur > 0 then
            local blur = Instance.new("BlurEffect")
            blur.Name = CONFIG.ShaderPrefix .. "Blur"
            blur.Size = ShaderState.Blur
            blur.Parent = Lighting
            Effects.Blur = blur
        end

        -- SunRays
        if Effects.SunRays then
            Effects.SunRays.Intensity = ShaderState.SunRaysIntensity
            Effects.SunRays.Spread = ShaderState.SunRaysSpread
        elseif ShaderState.SunRaysIntensity > 0 then
            local sr = Instance.new("SunRaysEffect")
            sr.Name = CONFIG.ShaderPrefix .. "SunRays"
            sr.Intensity = ShaderState.SunRaysIntensity
            sr.Spread = ShaderState.SunRaysSpread
            sr.Parent = Lighting
            Effects.SunRays = sr
        end

        -- DepthOfField
        if Effects.DepthOfField then
            Effects.DepthOfField.FarIntensity = ShaderState.DOFFarIntensity
            Effects.DepthOfField.NearIntensity = ShaderState.DOFNearIntensity
            Effects.DepthOfField.FocusDistance = ShaderState.DOFFocusDistance
        elseif ShaderState.DOFFarIntensity > 0 or ShaderState.DOFNearIntensity > 0 then
            local dof = Instance.new("DepthOfFieldEffect")
            dof.Name = CONFIG.ShaderPrefix .. "DepthOfField"
            dof.FarIntensity = ShaderState.DOFFarIntensity
            dof.NearIntensity = ShaderState.DOFNearIntensity
            dof.FocusDistance = ShaderState.DOFFocusDistance
            dof.Parent = Lighting
            Effects.DepthOfField = dof
        end

        -- Atmosphere
        if Effects.Atmosphere then
            Effects.Atmosphere.Density = ShaderState.AtmosphereDensity
            Effects.Atmosphere.Color = ShaderState.AtmosphereColor
        elseif ShaderState.AtmosphereDensity > 0 then
            local atm = Instance.new("Atmosphere")
            atm.Name = CONFIG.ShaderPrefix .. "Atmosphere"
            atm.Density = ShaderState.AtmosphereDensity
            atm.Color = ShaderState.AtmosphereColor
            atm.Parent = Lighting
            Effects.Atmosphere = atm
        end

        -- Motion Blur
        if not ShaderState.MotionBlur then
            if MotionBlurEffect then
                StopMotionBlur()
            end
        else
            local camera = workspace.CurrentCamera
            if camera then
                StartMotionBlur()

                if not LastCameraCFrame then
                    LastCameraCFrame = camera.CFrame
                else
                    local current = camera.CFrame
                    local positionDelta = (current.Position - LastCameraCFrame.Position).Magnitude
                    local a1, b1, c1 = current:ToOrientation()
                    local a2, b2, c2 = LastCameraCFrame:ToOrientation()
                    local rotationDelta = math.abs(a1 - a2) + math.abs(b1 - b2) + math.abs(c1 - c2)
                    local movement = positionDelta + rotationDelta * 18
                    local target = Clamp(movement * ShaderState.MotionBlurStrength * 12, 0, 24)
                    MotionBlurEffect.Size = MotionBlurEffect.Size + (target - MotionBlurEffect.Size) * Clamp(deltaTime * 12, 0, 1)
                    LastCameraCFrame = current
                end
            end
        end
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
-- LIVE EFFECT UPDATERS (оставлены для совместимости)
--============================================================

local function UpdateColorCorrection()
    -- больше не требуется, так как обновляется в RenderStepped
end

local function UpdateBlur()
    -- больше не требуется
end

local function UpdateBloom()
    -- больше не требуется
end

local function UpdateSunRays()
    -- больше не требуется
end

local function UpdateDOF()
    -- больше не требуется
end

local function UpdateAtmosphere()
    -- больше не требуется
end

--============================================================
-- ENSURE EFFECT (используется только при создании пресетов)
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
    end,

    ["Saturation My Love"] = function()
        ResetShaderState()
        DestroyShaderEffects()
        DestroyVignette()
        StopMotionBlur()

        CreateEffect("ColorCorrection", {
            Saturation = 1,
            Brightness = 0.05,
            Contrast = -0.10
        })

        CreateEffect("Atmosphere", {
            Density = 0.01,
            Color = Color3.fromRGB(0, 0, 0)
        })

        CreateEffect("Bloom", {
            Intensity = 0,
            Size = 0,
            Threshold = 0
        })

        UISettings.FOVValue = 120
        UISettings.FOVEnabled = true
        SetGameFOV(120)
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
    "Soapy Graphics (Beta)",
    "Saturation My Love"
}

local RefreshAllSliders
local RefreshUIToggles

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

    DestroyShaderEffects()
    DestroyVignette()
    StopMotionBlur()
    ResetShaderState()

    CurrentPreset =
        presetName

    preset()

    SyncStateFromLoadedPreset()

    EnginePreset.Text =
        "Preset: "
        .. presetName

    EngineStatus.Text =
        "ACTIVE"

    if RefreshAllSliders then
        RefreshAllSliders()
    end

    if RefreshUIToggles then
        RefreshUIToggles()
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
local UIToggleRefs = {}

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
        ) * 65

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

    row.ZIndex = 100 -- FIX: высокий ZIndex, чтобы не перекрывался

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

    title.ZIndex = 101

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

    switch.ZIndex = 102

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

    knob.ZIndex = 103

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

-- Existing toggles: Motion Blur and Vignette
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

--============================================================
-- PERFORMANCE / FOV / ASPECT SETTINGS
--============================================================

-- Все дополнительные контролы начинаются с индекса 3, чтобы не перекрывать Motion Blur и Vignette
local nextControlIndex = 3

local function CreateControlToggle(name, getter, setter)
    CreateToggle(
        SettingsScroll,
        name,
        nextControlIndex,
        getter,
        setter
    )

    nextControlIndex = nextControlIndex + 1
end

local function CreateControlSlider(definition, onChanged)
    local controlIndex = nextControlIndex

    local row = Instance.new("Frame")
    row.Name = definition.Key
    row.Position = UDim2.fromOffset(
        8,
        #SettingDefinitions * 65
            + 8
            + (controlIndex - 1) * 65
    )
    row.Size = UDim2.new(1, -16, 0, 58)
    row.BackgroundColor3 = Color3.fromRGB(39, 18, 56)
    row.BackgroundTransparency = 0.18
    row.BorderSizePixel = 0
    row.ZIndex = 100 -- FIX: высокий ZIndex
    row.Parent = SettingsScroll

    AddCorner(row, 13)
    AddStroke(row, CONFIG.PurpleLight, 0.91, 1)

    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(13, 7)
    label.Size = UDim2.new(1, -100, 0, 18)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.Text = definition.Name
    label.TextSize = 10
    label.TextColor3 = CONFIG.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 101
    label.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.AnchorPoint = Vector2.new(1, 0)
    valueLabel.Position = UDim2.new(1, -13, 0, 7)
    valueLabel.Size = UDim2.fromOffset(70, 18)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamSemibold
    valueLabel.TextSize = 9
    valueLabel.TextColor3 = CONFIG.PurpleLight
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 101
    valueLabel.Parent = row

    local track = Instance.new("Frame")
    track.Position = UDim2.fromOffset(13, 37)
    track.Size = UDim2.new(1, -26, 0, 6)
    track.BackgroundColor3 = Color3.fromRGB(68, 38, 84)
    track.BorderSizePixel = 0
    track.ZIndex = 102
    track.Parent = row
    AddCorner(track, 10)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = CONFIG.Purple
    fill.BorderSizePixel = 0
    fill.ZIndex = 103
    fill.Parent = track
    AddCorner(fill, 10)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.fromScale(0, 0.5)
    knob.Size = UDim2.fromOffset(12, 12)
    knob.BackgroundColor3 = CONFIG.White
    knob.BorderSizePixel = 0
    knob.ZIndex = 104
    knob.Parent = track
    AddCorner(knob, 99)

    local dragging = false

    local function SetValue(value, instant)
        local normalized = Clamp(
            (value - definition.Min) / (definition.Max - definition.Min),
            0,
            1
        )

        valueLabel.Text = string.format(
            definition.Format or "%.2f",
            value
        )

        if instant then
            fill.Size = UDim2.fromScale(normalized, 1)
            knob.Position = UDim2.fromScale(normalized, 0.5)
        else
            Tween(
                fill,
                {Size = UDim2.fromScale(normalized, 1)},
                0.08,
                Enum.EasingStyle.Sine
            )

            Tween(
                knob,
                {Position = UDim2.fromScale(normalized, 0.5)},
                0.08,
                Enum.EasingStyle.Sine
            )
        end
    end

    local function UpdateFromMouse(mouseX)
        local trackWidth = math.max(track.AbsoluteSize.X, 1)
        local normalized = Clamp(
            (mouseX - track.AbsolutePosition.X) / trackWidth,
            0,
            1
        )

        local rawValue =
            definition.Min
            + (definition.Max - definition.Min) * normalized

        local value =
            math.round(rawValue / definition.Step)
            * definition.Step

        value = Clamp(
            value,
            definition.Min,
            definition.Max
        )

        UISettings[definition.Key] = value
        SetValue(value, false)

        if onChanged then
            onChanged(value)
        end
    end

    Connect(
        track.InputBegan,
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                UpdateFromMouse(input.Position.X)
            end
        end
    )

    Connect(
        UserInputService.InputChanged,
        function(input)
            if not dragging then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseMovement then
                UpdateFromMouse(input.Position.X)
            end
        end
    )

    Connect(
        UserInputService.InputEnded,
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end
    )

    SliderUI[definition.Key] = {
        SetValue = SetValue
    }

    SetValue(definition.Default, true)
    nextControlIndex = nextControlIndex + 1
end

-- Performance
CreateControlToggle(
    "FullBright",
    function()
        return PerformanceState.FullBright
    end,
    function(value)
        SetFullBright(value)
    end
)

CreateControlToggle(
    "No Lag",
    function()
        return PerformanceState.NoLag
    end,
    function(value)
        PerformanceState.NoLag = value

        if value then
            ApplyNoLag()
        else
            RestoreNoLag()
        end
    end
)

-- FOV – теперь включает агрессивный цикл
CreateControlToggle(
    "Enable FOV Changer",
    function()
        return UISettings.FOVEnabled
    end,
    function(value)
        UISettings.FOVEnabled = value
        if value then
            StartFOVLoop()
            SetGameFOV(UISettings.FOVValue)
        else
            StopFOVLoop()
            RestoreGameFOV()
        end
    end
)

CreateControlSlider(
    {
        Name = "FOV",
        Key = "FOVValue",
        Min = 1,
        Max = 120,
        Step = 1,
        Default = 80,
        Format = "%.0f"
    },
    function(value)
        UISettings.FOVValue = value
        if UISettings.FOVEnabled then
            SetGameFOV(value)
        end
    end
)

-- Aspect Ratio
CreateControlToggle(
    "Enable Aspect Ratio",
    function()
        return UISettings.AspectEnabled
    end,
    function(value)
        UISettings.AspectEnabled = value
    end
)

CreateControlSlider(
    {
        Name = "Ratio Value",
        Key = "AspectValue",
        Min = 0.05,
        Max = 1.14,
        Step = 0.01,
        Default = 0.6,
        Format = "%.2f"
    }
)

-- Update canvas size (увеличиваем запас)
local totalRows = #SettingDefinitions * 65 + 8 + nextControlIndex * 65 + 80 -- FIX: добавили запас
SettingsScroll.CanvasSize = UDim2.fromOffset(0, totalRows)

-- Refresh function for UI toggles
RefreshUIToggles = function()
    for name, refresh in pairs(ToggleUI) do
        refresh()
    end
    if SliderUI["FOVValue"] then
        SliderUI["FOVValue"].SetValue(UISettings.FOVValue, true)
    end
    if SliderUI["AspectValue"] then
        SliderUI["AspectValue"].SetValue(UISettings.AspectValue, true)
    end
end

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
        RefreshUIToggles()

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

    StopFOVLoop()  -- обязательно остановить циклы FOV

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

                bubble.VX =
                    bubble.VX
                    + dx * CONFIG.BubbleMagnet * 0.92 * deltaTime

                bubble.VY =
                    bubble.VY
                    + dy * CONFIG.BubbleMagnet * 0.92 * deltaTime

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

-- Запускаем FOV-цикл, если опция уже была включена (на случай сохранения настроек)
if UISettings.FOVEnabled then
    StartFOVLoop()
end

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

