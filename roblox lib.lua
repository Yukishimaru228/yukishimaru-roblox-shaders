--[[
    ============================================================
    SCRIPT LIBRARY v2.0.0 (Full)
    ============================================================
    Модульная библиотека для Roblox-скриптов.
    Модули:
      Core   : Signal, Table, String, Util, Json, Http,
               Instance, Connection, Raycast, Pathfinding,
               Players, AntiAFK, Bind, Chat
      UI     : Theme, Notification, Window, Tab, Components,
               ColorPicker, ProgressBar, Dialog, Console,
               ContextMenu, Tooltip
      Config : Config, Profile
      Drawing: Drawing, ESP
      Util   : Timer, Stopwatch, Queue, StateMachine,
               EventBus, Sequence
    ============================================================
]]

--//===== ОБЩИЕ СЕРВИСЫ =====
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local LocalPlayer      = Players.LocalPlayer

local Lib = {}
Lib.__index = Lib
Lib.Version = "2.0.0"

--//===== MODULE: Core/Signal =====
do
    local Signal = {}
    Signal.__index = Signal

    function Signal.new()
        return setmetatable({_handlers = {}, _nextId = 1}, Signal)
    end

    function Signal:Connect(fn)
        assert(type(fn) == "function", "Signal:Connect ожидает функцию")
        local id = self._nextId
        self._nextId = self._nextId + 1
        self._handlers[id] = fn
        local conn = {}
        function conn:Disconnect() self._handlers[id] = nil end
        return conn
    end

    function Signal:Once(fn)
        local conn
        conn = self:Connect(function(...)
            if conn then conn:Disconnect() end
            fn(...)
        end)
        return conn
    end

    function Signal:Fire(...)
        for _, fn in pairs(self._handlers) do
            local ok, err = pcall(fn, ...)
            if not ok then warn("[Signal] " .. tostring(err)) end
        end
    end

    function Signal:DisconnectAll() self._handlers = {} end

    Lib.Signal = Signal
end

--//===== MODULE: Core/Table =====
do
    local T = {}

    function T.shallowCopy(t)
        local out = {}
        for k, v in pairs(t) do out[k] = v end
        return out
    end

    function T.deepCopy(t, seen)
        if type(t) ~= "table" then return t end
        seen = seen or {}
        if seen[t] then return seen[t] end
        local out = {}
        seen[t] = out
        for k, v in pairs(t) do out[T.deepCopy(k, seen)] = T.deepCopy(v, seen) end
        return setmetatable(out, getmetatable(t))
    end

    function T.merge(...)
        local out = {}
        for _, t in ipairs({...}) do
            for k, v in pairs(t) do out[k] = v end
        end
        return out
    end

    function T.deepMerge(...)
        local out = {}
        for _, t in ipairs({...}) do
            for k, v in pairs(t) do
                if type(v) == "table" and type(out[k]) == "table" then
                    out[k] = T.deepMerge(out[k], v)
                else
                    out[k] = T.deepCopy(v)
                end
            end
        end
        return out
    end

    function T.map(t, fn)
        local out = {}
        for k, v in pairs(t) do out[k] = fn(v, k) end
        return out
    end

    function T.filter(t, fn)
        local out = {}
        for k, v in pairs(t) do if fn(v, k) then out[k] = v end end
        return out
    end

    function T.reduce(t, fn, acc)
        for k, v in pairs(t) do acc = fn(acc, v, k) end
        return acc
    end

    function T.find(t, fn)
        for k, v in pairs(t) do if fn(v, k) then return v, k end end
        return nil
    end

    function T.contains(t, val)
        for _, v in pairs(t) do if v == val then return true end end
        return false
    end

    function T.keys(t)
        local out = {}
        for k in pairs(t) do table.insert(out, k) end
        return out
    end

    function T.values(t)
        local out = {}
        for _, v in pairs(t) do table.insert(out, v) end
        return out
    end

    function T.count(t)
        local n = 0
        for _ in pairs(t) do n = n + 1 end
        return n
    end

    function T.isEmpty(t) return next(t) == nil end

    function T.sorted(t, cmp)
        local out = T.shallowCopy(t)
        table.sort(out, cmp)
        return out
    end

    function T.reverse(t)
        local out = {}
        for i = #t, 1, -1 do table.insert(out, t[i]) end
        return out
    end

    function T.serialize(t, indent, seen)
        seen = seen or {}
        indent = indent or 0
        local pad = string.rep("  ", indent)
        if type(t) ~= "table" then
            if type(t) == "string" then return string.format("%q", t) end
            return tostring(t)
        end
        if seen[t] then return "--[[circular]]" end
        seen[t] = true
        local parts = {}
        for k, v in pairs(t) do
            local key
            if type(k) == "string" and k:match("^[%a_][%w_]*$") then
                key = k
            else
                key = "[" .. T.serialize(k, 0, seen) .. "]"
            end
            table.insert(parts, pad .. "  " .. key .. " = " .. T.serialize(v, indent + 1, seen))
        end
        seen[t] = nil
        if #parts == 0 then return "{}" end
        return "{\n" .. table.concat(parts, ",\n") .. "\n" .. pad .. "}"
    end

    Lib.Table = T
end

--//===== MODULE: Core/String =====
do
    local S = {}

    function S.trim(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end

    function S.split(s, sep)
        sep = sep or "%s"
        local out = {}
        for part in s:gmatch("([^" .. sep .. "]+)") do
            table.insert(out, part)
        end
        return out
    end

    function S.startsWith(s, prefix) return s:sub(1, #prefix) == prefix end
    function S.endsWith(s, suffix) return s:sub(-#suffix) == suffix end

    function S.padLeft(s, len, char)
        char = char or " "
        s = tostring(s)
        while #s < len do s = char .. s end
        return s
    end

    function S.padRight(s, len, char)
        char = char or " "
        s = tostring(s)
        while #s < len do s = s .. char end
        return s
    end

    function S.capitalize(s) return (s:gsub("^%l", string.upper)) end

    function S.truncate(s, maxLen, suffix)
        suffix = suffix or "..."
        if #s <= maxLen then return s end
        return s:sub(1, maxLen - #suffix) .. suffix
    end

    function S.formatBytes(bytes)
        local units = {"B", "KB", "MB", "GB", "TB"}
        local i = 1
        while bytes >= 1024 and i < #units do
            bytes = bytes / 1024
            i = i + 1
        end
        return string.format("%.2f %s", bytes, units[i])
    end

    function S.formatTime(seconds)
        local h = math.floor(seconds / 3600)
        local m = math.floor((seconds % 3600) / 60)
        local s = math.floor(seconds % 60)
        if h > 0 then return string.format("%dh %dm %ds", h, m, s)
        elseif m > 0 then return string.format("%dm %ds", m, s)
        else return string.format("%ds", s) end
    end

    function S.random(length, charset)
        charset = charset or "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        local out = {}
        for _ = 1, length do
            local idx = math.random(1, #charset)
            table.insert(out, charset:sub(idx, idx))
        end
        return table.concat(out)
    end

    Lib.String = S
end

--//===== MODULE: Core/Util =====
do
    local U = {}

    function U.wait(s) return task.wait(s) end
    function U.spawn(fn, ...) return task.spawn(fn, ...) end
    function U.delay(s, fn, ...) return task.delay(s, fn, ...) end
    function U.defer(fn, ...) return task.defer(fn, ...) end

    function U.once(fn)
        local called = false
        return function(...)
            if called then return end
            called = true
            return fn(...)
        end
    end

    function U.debounce(fn, delay_)
        local last = 0
        return function(...)
            local now = tick()
            if now - last >= delay_ then
                last = now
                return fn(...)
            end
        end
    end

    function U.throttle(fn, interval)
        local ready = true
        return function(...)
            if not ready then return end
            ready = false
            fn(...)
            task.delay(interval, function() ready = true end)
        end
    end

    function U.memoize(fn)
        local cache = {}
        return function(...)
            local key = tostring(...)
            if cache[key] == nil then cache[key] = fn(...) end
            return cache[key]
        end
    end

    function U.retry(fn, attempts, delay_)
        attempts = attempts or 3
        delay_ = delay_ or 0.5
        for i = 1, attempts do
            local ok, result = pcall(fn)
            if ok then return true, result end
            if i < attempts then task.wait(delay_) end
        end
        return false, nil
    end

    function U.clamp(v, min, max)
        if v < min then return min end
        if v > max then return max end
        return v
    end

    function U.lerp(a, b, t) return a + (b - a) * t end

    function U.round(n, decimals)
        decimals = decimals or 0
        local mult = 10 ^ decimals
        return math.floor(n * mult + 0.5) / mult
    end

    function U.formatNumber(n, separator)
        separator = separator or " "
        local s = tostring(math.floor(n))
        local out = s:reverse():gsub("(%d%d%d)", "%1" .. separator):reverse()
        out = out:gsub("^" .. separator, "")
        return out
    end

    function U.instance(className, props, children)
        local inst = Instance.new(className)
        if props then
            for k, v in pairs(props) do
                if k ~= "Parent" then inst[k] = v end
            end
        end
        if children then
            for _, child in ipairs(children) do child.Parent = inst end
        end
        if props and props.Parent then inst.Parent = props.Parent end
        return inst
    end

    function U.tween(inst, props, info, callback)
        local tween = TweenService:Create(inst, info or TweenInfo.new(0.2), props)
        if callback then tween.Completed:Connect(callback) end
        tween:Play()
        return tween
    end

    function U.findPlayer(name)
        name = name:lower()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name:lower():find(name, 1, true) or p.DisplayName:lower():find(name, 1, true) then
                return p
            end
        end
        return nil
    end

    function U.getHRP(player)
        player = player or LocalPlayer
        local char = player.Character
        if not char then return nil end
        return char:FindFirstChild("HumanoidRootPart")
    end

    function U.getHumanoid(player)
        player = player or LocalPlayer
        local char = player.Character
        if not char then return nil end
        return char:FindFirstChildOfClass("Humanoid")
    end

    function U.distance(a, b) return (a.Position - b.Position).Magnitude end

    function U.waitForChildRecursive(parent, name, timeout)
        timeout = timeout or 5
        local start = tick()
        while tick() - start < timeout do
            local found = parent:FindFirstChild(name, true)
            if found then return found end
            task.wait(0.1)
        end
        return nil
    end

    Lib.Util = U
end

--//===== MODULE: Core/Json =====
do
    local J = {}

    local function escapeChar(c)
        local map = {['"'] = '\\"', ['\\'] = '\\\\', ['\b'] = '\\b',
                     ['\f'] = '\\f', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t'}
        return map[c] or string.format("\\u%04x", c:byte())
    end

    function J.encode(value)
        local t = type(value)
        if value == nil then return "null"
        elseif t == "boolean" then return value and "true" or "false"
        elseif t == "number" then
            if value ~= value or value == math.huge or value == -math.huge then return "null" end
            return tostring(value)
        elseif t == "string" then
            return '"' .. value:gsub('[%z\1-\31\\"]', escapeChar) .. '"'
        elseif t == "table" then
            local isArray = #value > 0
            local parts = {}
            if isArray then
                for _, v in ipairs(value) do table.insert(parts, J.encode(v)) end
                return "[" .. table.concat(parts, ",") .. "]"
            else
                for k, v in pairs(value) do
                    if type(k) == "string" then
                        table.insert(parts, J.encode(k) .. ":" .. J.encode(v))
                    elseif type(k) == "number" then
                        table.insert(parts, J.encode(tostring(k)) .. ":" .. J.encode(v))
                    end
                end
                return "{" .. table.concat(parts, ",") .. "}"
            end
        end
        return "null"
    end

    local function skipWhitespace(str, pos)
        while pos <= #str do
            local c = str:sub(pos, pos)
            if c == " " or c == "\t" or c == "\n" or c == "\r" then
                pos = pos + 1
            else break end
        end
        return pos
    end

    local parseValue

    local function parseString(str, pos)
        pos = pos + 1
        local out = {}
        while pos <= #str do
            local c = str:sub(pos, pos)
            if c == '"' then return table.concat(out), pos + 1
            elseif c == "\\" then
                local next_ = str:sub(pos + 1, pos + 1)
                if next_ == "n" then table.insert(out, "\n")
                elseif next_ == "t" then table.insert(out, "\t")
                elseif next_ == "r" then table.insert(out, "\r")
                elseif next_ == "b" then table.insert(out, "\b")
                elseif next_ == "f" then table.insert(out, "\f")
                elseif next_ == "u" then
                    local hex = str:sub(pos + 2, pos + 5)
                    local code = tonumber(hex, 16) or 63
                    table.insert(out, utf8.char(code))
                    pos = pos + 4
                else
                    table.insert(out, next_)
                end
                pos = pos + 2
            else
                table.insert(out, c)
                pos = pos + 1
            end
        end
        error("Незакрытая строка")
    end

    local function parseNumber(str, pos)
        local start = pos
        while pos <= #str and str:sub(pos, pos):match("[%d%.eE%+%-]") do
            pos = pos + 1
        end
        return tonumber(str:sub(start, pos - 1)), pos
    end

    parseValue = function(str, pos)
        pos = skipWhitespace(str, pos)
        local c = str:sub(pos, pos)
        if c == '"' then
            return parseString(str, pos)
        elseif c == "{" then
            local obj = {}
            pos = pos + 1
            pos = skipWhitespace(str, pos)
            if str:sub(pos, pos) == "}" then return obj, pos + 1 end
            while true do
                pos = skipWhitespace(str, pos)
                local key, value
                key, pos = parseString(str, pos)
                pos = skipWhitespace(str, pos)
                if str:sub(pos, pos) ~= ":" then error("Ожидалось ':'") end
                pos = pos + 1
                value, pos = parseValue(str, pos)
                obj[key] = value
                pos = skipWhitespace(str, pos)
                local ch = str:sub(pos, pos)
                if ch == "," then pos = pos + 1
                elseif ch == "}" then return obj, pos + 1
                else error("Ожидалось ',' или '}'") end
            end
        elseif c == "[" then
            local arr = {}
            pos = pos + 1
            pos = skipWhitespace(str, pos)
            if str:sub(pos, pos) == "]" then return arr, pos + 1 end
            while true do
                local value
                value, pos = parseValue(str, pos)
                table.insert(arr, value)
                pos = skipWhitespace(str, pos)
                local ch = str:sub(pos, pos)
                if ch == "," then pos = pos + 1
                elseif ch == "]" then return arr, pos + 1
                else error("Ожидалось ',' или ']'") end
            end
        elseif c == "t" and str:sub(pos, pos + 3) == "true" then
            return true, pos + 4
        elseif c == "f" and str:sub(pos, pos + 4) == "false" then
            return false, pos + 5
        elseif c == "n" and str:sub(pos, pos + 3) == "null" then
            return nil, pos + 4
        elseif c:match("[%d%-]") then
            return parseNumber(str, pos)
        end
        error("Неизвестный символ: " .. c)
    end

    function J.decode(str)
        if type(str) ~= "string" then return nil end
        local ok, result = pcall(function() return (parseValue(str, 1)) end)
        if ok then return result end
        return nil
    end

    Lib.Json = J
end

--//===== MODULE: Core/Http =====
do
    local H = {}
    local cache = {}
    local DEFAULT_TTL = 300

    function H.get(url, headers, ttl)
        ttl = ttl or DEFAULT_TTL
        local now = tick()
        local cached = cache[url]
        if cached and now - cached.time < cached.ttl then return cached.body end
        local ok, body = pcall(function() return game:HttpGet(url, headers) end)
        if ok and body then
            cache[url] = {body = body, time = now, ttl = ttl}
            return body
        end
        return nil
    end

    function H.post(url, data)
        local ok, body = pcall(function()
            return HttpService:PostAsync(url, data, Enum.HttpContentType.ApplicationJson)
        end)
        return ok and body or nil
    end

    function H.json(url, ttl)
        local body = H.get(url, nil, ttl)
        if not body then return nil end
        return Lib.Json.decode(body)
    end

    function H.lua(url, ttl)
        local body = H.get(url, nil, ttl)
        if not body then return nil end
        local fn, err = loadstring(body)
        if not fn then
            warn("[HTTP] " .. tostring(err))
            return nil
        end
        local ok, result = pcall(fn)
        return ok and result or nil
    end

    function H.clearCache() cache = {} end
    function H.clearUrl(url) cache[url] = nil end

    Lib.Http = H
end

--//===== MODULE: Core/Instance =====
do
    local I = {}

    function I.new(class, props, parent)
        local inst = Instance.new(class)
        if props then
            for k, v in pairs(props) do
                if k ~= "Parent" then
                    local ok = pcall(function() inst[k] = v end)
                    if not ok then warn("[Instance] Не удалось установить " .. k) end
                end
            end
        end
        if parent then inst.Parent = parent end
        if props and props.Parent then inst.Parent = props.Parent end
        return inst
    end

    function I.waitFor(parent, name, timeout)
        timeout = timeout or 10
        local existing = parent:FindFirstChild(name)
        if existing then return existing end
        return parent:WaitForChild(name, timeout)
    end

    function I.findFirst(parent, predicate)
        for _, c in ipairs(parent:GetChildren()) do
            if predicate(c) then return c end
        end
        return nil
    end

    function I.findAll(parent, predicate)
        local out = {}
        for _, c in ipairs(parent:GetDescendants()) do
            if predicate(c) then table.insert(out, c) end
        end
        return out
    end

    function I.findByClass(parent, className)
        return I.findFirst(parent, function(c) return c:IsA(className) end)
    end

    function I.findAllByClass(parent, className)
        return I.findAll(parent, function(c) return c:IsA(className) end)
    end

    function I.findByNameContains(parent, fragment)
        fragment = fragment:lower()
        return I.findAll(parent, function(c) return c.Name:lower():find(fragment, 1, true) ~= nil end)
    end

    function I.getPath(inst)
        local path = {}
        while inst and inst ~= game do
            table.insert(path, 1, inst.Name)
            inst = inst.Parent
        end
        return table.concat(path, ".")
    end

    function I.cloneWithParent(inst, parent)
        local new = inst:Clone()
        new.Parent = parent
        return new
    end

    function I.destroyAll(instances)
        for _, inst in ipairs(instances or {}) do
            pcall(function() inst:Destroy() end)
        end
    end

    Lib.Instance = I
end

--//===== MODULE: Core/Connection =====
do
    local C = {}
    C.__index = C

    function C.new(name)
        return setmetatable({name = name or "ConnGroup", items = {}}, C)
    end

    function C:add(connection)
        if connection then table.insert(self.items, connection) end
        return connection
    end

    function C:addMultiple(...)
        for _, conn in ipairs({...}) do self:add(conn) end
    end

    function C:disconnectAll()
        for _, conn in ipairs(self.items) do
            pcall(function() conn:Disconnect() end)
        end
        self.items = {}
    end

    function C:remove(connection)
        for i, c in ipairs(self.items) do
            if c == connection then
                table.remove(self.items, i)
                return true
            end
        end
        return false
    end

    function C:count() return #self.items end

    function C.connect(self, signal, fn)
        local conn = signal:Connect(fn)
        self:add(conn)
        return conn
    end

    Lib.Connection = C
end

--//===== MODULE: Core/Raycast =====
do
    local R = {}

    function R.cast(origin, direction, options)
        options = options or {}
        local params = options.params
        if not params then
            params = RaycastParams.new()
            params.FilterType = options.filterType or Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = options.filter or {}
            params.IgnoreWater = options.ignoreWater ~= false
        end
        return workspace:Raycast(origin, direction, params)
    end

    function R.castFromCamera(distance, options)
        local cam = workspace.CurrentCamera
        return R.cast(cam.CFrame.Position, cam.CFrame.LookVector * (distance or 500), options)
    end

    function R.castFromMouse(distance, options)
        local mouse = LocalPlayer:GetMouse()
        local origin = workspace.CurrentCamera.CFrame.Position
        local target = mouse.Hit.Position
        local dir = (target - origin).Unit * (distance or 500)
        return R.cast(origin, dir, options)
    end

    function R.canSee(targetPart, options)
        options = options or {}
        local cam = workspace.CurrentCamera
        local origin = cam.CFrame.Position
        local target = targetPart.Position
        local dir = target - origin
        local filter = options.filter or {}
        table.insert(filter, targetPart)
        local hit = R.cast(origin, dir, {filter = filter, ignoreWater = true})
        return hit == nil
    end

    function R.findPartUnderMouse(distance)
        local hit = R.castFromMouse(distance)
        return hit and hit.Instance or nil
    end

    Lib.Raycast = R
end

--//===== MODULE: Core/Pathfinding =====
do
    local P = {}
    P.__index = P

    local PathfindingService = game:GetService("PathfindingService")

    function P.new()
        local self = setmetatable({}, P)
        self.path = PathfindingService:CreatePath({
            AgentRadius = 2, AgentHeight = 5, AgentCanJump = true,
            AgentJumpHeight = 7, AgentMaxSlope = 45,
        })
        self.waypoints = {}
        self.currentIndex = 0
        return self
    end

    function P:compute(startPos, endPos)
        local ok, err = pcall(function() self.path:ComputeAsync(startPos, endPos) end)
        if not ok then
            warn("[Pathfinding] " .. tostring(err))
            return false
        end
        self.waypoints = self.path:GetWaypoints()
        self.currentIndex = 1
        return self.path.Status == Enum.PathStatus.Success
    end

    function P:walk(character, options)
        options = options or {}
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not hrp then return false end

        local timeout = options.timeout or 30
        local start = tick()

        for i = 2, #self.waypoints do
            if tick() - start > timeout then return false end
            local wp = self.waypoints[i]
            if wp.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
            humanoid:MoveTo(wp.Position)
            local reached = false
            local conn
            conn = humanoid.MoveToFinished:Connect(function(ok)
                reached = ok
                if conn then conn:Disconnect() end
            end)
            while not reached and tick() - start < timeout do
                task.wait(0.1)
                if (hrp.Position - wp.Position).Magnitude < 3 then
                    reached = true
                    break
                end
            end
        end
        return true
    end

    Lib.Pathfinding = P
end

--//===== MODULE: Core/Players =====
do
    local P = {}

    function P.localPlayer() return LocalPlayer end
    function P.all() return Players:GetPlayers() end

    function P.others()
        local out = {}
        for _, p in ipairs(P.all()) do
            if p ~= LocalPlayer then table.insert(out, p) end
        end
        return out
    end

    function P.find(query)
        query = tostring(query):lower()
        for _, p in ipairs(P.all()) do
            if p.Name:lower() == query or p.DisplayName:lower() == query then return p end
        end
        for _, p in ipairs(P.all()) do
            if p.Name:lower():find(query, 1, true) or p.DisplayName:lower():find(query, 1, true) then
                return p
            end
        end
        return nil
    end

    function P.getHRP(player)
        player = player or LocalPlayer
        if not player or not player.Character then return nil end
        return player.Character:FindFirstChild("HumanoidRootPart")
    end

    function P.getHumanoid(player)
        player = player or LocalPlayer
        if not player or not player.Character then return nil end
        return player.Character:FindFirstChildOfClass("Humanoid")
    end

    function P.isAlive(player)
        player = player or LocalPlayer
        local hum = P.getHumanoid(player)
        return hum and hum.Health > 0
    end

    function P.getDistance(a, b)
        local pa = P.getHRP(a)
        local pb = P.getHRP(b)
        if not pa or not pb then return math.huge end
        return (pa.Position - pb.Position).Magnitude
    end

    function P.nearest(options)
        options = options or {}
        local hrp = P.getHRP(LocalPlayer)
        if not hrp then return nil end
        local best, bestDist = nil, options.maxDistance or math.huge
        for _, p in ipairs(P.others()) do
            if not options.filter or options.filter(p) then
                local otherHRP = P.getHRP(p)
                if otherHRP then
                    local d = (otherHRP.Position - hrp.Position).Magnitude
                    if d < bestDist then
                        best, bestDist = p, d
                    end
                end
            end
        end
        return best, bestDist
    end

    function P.onPlayerAdded(fn) return Players.PlayerAdded:Connect(fn) end
    function P.onCharacterAdded(player, fn) return player.CharacterAdded:Connect(fn) end

    function P.forEach(fn)
        for _, p in ipairs(P.all()) do fn(p) end
    end

    Lib.Players = P
end

--//===== MODULE: Core/AntiAFK =====
do
    local A = {}
    A.enabled = false
    A.thread = nil

    function A.start(interval)
        interval = interval or 60
        if A.enabled then return end
        A.enabled = true
        A.thread = task.spawn(function()
            while A.enabled do
                task.wait(interval)
                if not A.enabled then break end
                local VIM = game:GetService("VirtualInputManager")
                pcall(function()
                    VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                    task.wait(0.1)
                    VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game)
                end)
            end
        end)
    end

    function A.stop()
        A.enabled = false
        A.thread = nil
    end

    Lib.AntiAFK = A
end

--//===== MODULE: Core/Bind =====
do
    local B = {}
    B.__index = B

    function B.new()
        local self = setmetatable({binds = {}}, B)
        self.conn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            local bind = self.binds[input.KeyCode]
            if bind then
                local ok, err = pcall(bind.fn)
                if not ok then warn("[Bind] " .. tostring(err)) end
            end
        end)
        return self
    end

    function B:register(key, fn, description)
        if typeof(key) == "string" then key = Enum.KeyCode[key] end
        self.binds[key] = {fn = fn, description = description or ""}
        return key
    end

    function B:unregister(key) self.binds[key] = nil end

    function B:list()
        local out = {}
        for k, v in pairs(self.binds) do
            table.insert(out, {key = k, description = v.description})
        end
        return out
    end

    function B:destroy()
        if self.conn then self.conn:Disconnect() end
        self.binds = {}
    end

    Lib.Bind = B
end

--//===== MODULE: Core/Chat =====
do
    local C = {}

    local function getChatRemote()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        for _, name in ipairs({"DefaultChatSystemChatEvents", "Chat", "ChatService"}) do
            local folder = ReplicatedStorage:FindFirstChild(name)
            if folder then
                local remote = folder:FindFirstChild("SayMessageRequest")
                if remote then return remote end
            end
        end
        return nil
    end

    function C.send(message)
        local remote = getChatRemote()
        if remote then
            pcall(function() remote:FireServer(message, "All") end)
            return true
        end
        local StarterGui = game:GetService("StarterGui")
        pcall(function() StarterGui:SetCore("ChatSendMessage", message) end)
        return true
    end

    function C.system(message)
        local StarterGui = game:GetService("StarterGui")
        pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = message,
                Color = Color3.fromRGB(255, 200, 100),
                Font = Enum.Font.SourceSansBold,
            })
        end)
    end

    Lib.Chat = C
end

--//===== MODULE: UI/Theme =====
do
    local Themes = {
        Dark = {
            Background = Color3.fromRGB(22, 22, 28),
            Surface = Color3.fromRGB(32, 32, 40),
            SurfaceAlt = Color3.fromRGB(42, 42, 52),
            Border = Color3.fromRGB(60, 60, 75),
            Text = Color3.fromRGB(230, 230, 235),
            TextDim = Color3.fromRGB(150, 150, 160),
            Accent = Color3.fromRGB(100, 160, 255),
            AccentHover = Color3.fromRGB(130, 180, 255),
            Success = Color3.fromRGB(80, 200, 120),
            Warning = Color3.fromRGB(255, 200, 80),
            Danger = Color3.fromRGB(220, 70, 70),
        },
        Light = {
            Background = Color3.fromRGB(240, 240, 245),
            Surface = Color3.fromRGB(255, 255, 255),
            SurfaceAlt = Color3.fromRGB(230, 230, 240),
            Border = Color3.fromRGB(200, 200, 210),
            Text = Color3.fromRGB(30, 30, 40),
            TextDim = Color3.fromRGB(100, 100, 110),
            Accent = Color3.fromRGB(60, 130, 240),
            AccentHover = Color3.fromRGB(90, 150, 250),
            Success = Color3.fromRGB(50, 180, 100),
            Warning = Color3.fromRGB(230, 170, 40),
            Danger = Color3.fromRGB(200, 60, 60),
        },
        Midnight = {
            Background = Color3.fromRGB(15, 15, 25),
            Surface = Color3.fromRGB(25, 25, 40),
            SurfaceAlt = Color3.fromRGB(35, 35, 55),
            Border = Color3.fromRGB(55, 55, 80),
            Text = Color3.fromRGB(220, 220, 240),
            TextDim = Color3.fromRGB(140, 140, 170),
            Accent = Color3.fromRGB(150, 100, 255),
            AccentHover = Color3.fromRGB(170, 130, 255),
            Success = Color3.fromRGB(90, 210, 140),
            Warning = Color3.fromRGB(255, 190, 90),
            Danger = Color3.fromRGB(230, 80, 100),
        },
    }

    local Theme = {Current = "Dark"}

    function Theme.set(name)
        if Themes[name] then Theme.Current = name end
    end

    function Theme.get() return Themes[Theme.Current] end

    function Theme.list()
        local names = {}
        for k in pairs(Themes) do table.insert(names, k) end
        return names
    end

    function Theme.register(name, colors) Themes[name] = colors end

    Lib.Theme = Theme
end

--//===== MODULE: UI/Notification =====
do
    local N = {}

    local active = {}
    local MAX_VISIBLE = 5
    local WIDTH = 280
    local PADDING = 10
    local HEIGHT = 60
    local DURATION = 4

    local function getParent()
        local existing = CoreGui:FindFirstChild("LibNotifications")
        if existing then return existing end
        local sg = Instance.new("ScreenGui")
        sg.Name = "LibNotifications"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        local ok = pcall(function() sg.Parent = CoreGui end)
        if not ok or not sg.Parent then
            sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
        return sg
    end

    local function layout()
        local screenH = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.Y or 600
        local baseY = screenH - 30
        for i = #active, 1, -1 do
            local n = active[i]
            local y = baseY - (i * (HEIGHT + PADDING))
            if n.gui then
                TweenService:Create(n.gui, TweenInfo.new(0.2), {
                    Position = UDim2.new(1, -WIDTH - 20, 0, y),
                }):Play()
            end
        end
    end

    function N.push(config)
        config = config or {}
        local parent = getParent()
        local theme = Lib.Theme.get()

        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
        frame.Position = UDim2.new(1, 20, 0, 0)
        frame.BackgroundColor3 = theme.Surface
        frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = theme.Border
        stroke.Thickness = 1

        local accentBar = Instance.new("Frame", frame)
        accentBar.Size = UDim2.new(0, 4, 1, -12)
        accentBar.Position = UDim2.new(0, 6, 0, 6)
        accentBar.BackgroundColor3 = config.color or theme.Accent
        accentBar.BorderSizePixel = 0
        Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1, 0)

        local titleLbl = Instance.new("TextLabel", frame)
        titleLbl.Size = UDim2.new(1, -30, 0, 22)
        titleLbl.Position = UDim2.new(0, 20, 0, 8)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = config.title or "Уведомление"
        titleLbl.TextColor3 = theme.Text
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 13
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left

        local msgLbl = Instance.new("TextLabel", frame)
        msgLbl.Size = UDim2.new(1, -30, 0, 20)
        msgLbl.Position = UDim2.new(0, 20, 0, 30)
        msgLbl.BackgroundTransparency = 1
        msgLbl.Text = config.message or ""
        msgLbl.TextColor3 = theme.TextDim
        msgLbl.Font = Enum.Font.Gotham
        msgLbl.TextSize = 11
        msgLbl.TextXAlignment = Enum.TextXAlignment.Left
        msgLbl.TextWrapped = true

        local notif = {gui = frame, duration = config.duration or DURATION, id = tick()}
        table.insert(active, notif)
        if #active > MAX_VISIBLE then
            local oldest = table.remove(active, 1)
            if oldest.gui then oldest.gui:Destroy() end
        end
        layout()

        task.delay(notif.duration, function()
            for i, n in ipairs(active) do
                if n.id == notif.id then
                    table.remove(active, i)
                    break
                end
            end
            local tween = TweenService:Create(frame, TweenInfo.new(0.2), {
                Position = UDim2.new(1, 300, 0, frame.Position.Y.Offset),
                BackgroundTransparency = 1,
            })
            tween:Play()
            tween.Completed:Connect(function() frame:Destroy() end)
            layout()
        end)

        return notif
    end

    function N.info(t, m) return N.push({title = t, message = m, color = Lib.Theme.get().Accent}) end
    function N.success(t, m) return N.push({title = t, message = m, color = Lib.Theme.get().Success}) end
    function N.warning(t, m) return N.push({title = t, message = m, color = Lib.Theme.get().Warning}) end
    function N.error(t, m) return N.push({title = t, message = m, color = Lib.Theme.get().Danger}) end

    --// Прогресс-нотификация
    function N.progress(title, message, duration)
        duration = duration or 5
        local theme = Lib.Theme.get()
        local parent = getParent()

        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(0, 300, 0, 70)
        frame.Position = UDim2.new(0.5, -150, 0, 30)
        frame.BackgroundColor3 = theme.Surface
        frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = theme.Border

        local titleLbl = Instance.new("TextLabel", frame)
        titleLbl.Size = UDim2.new(1, -20, 0, 20)
        titleLbl.Position = UDim2.new(0, 10, 0, 6)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = title
        titleLbl.TextColor3 = theme.Text
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 13
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left

        local msgLbl = Instance.new("TextLabel", frame)
        msgLbl.Size = UDim2.new(1, -20, 0, 16)
        msgLbl.Position = UDim2.new(0, 10, 0, 26)
        msgLbl.BackgroundTransparency = 1
        msgLbl.Text = message or ""
        msgLbl.TextColor3 = theme.TextDim
        msgLbl.Font = Enum.Font.Gotham
        msgLbl.TextSize = 11
        msgLbl.TextXAlignment = Enum.TextXAlignment.Left

        local track = Instance.new("Frame", frame)
        track.Size = UDim2.new(1, -20, 0, 6)
        track.Position = UDim2.new(0, 10, 1, -18)
        track.BackgroundColor3 = theme.Border
        track.BorderSizePixel = 0
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = theme.Accent
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        TweenService:Create(fill, TweenInfo.new(duration), {Size = UDim2.new(1, 0, 1, 0)}):Play()

        task.delay(duration, function()
            TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            for _, c in ipairs(frame:GetDescendants()) do
                if c:IsA("TextLabel") then
                    TweenService:Create(c, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                elseif c:IsA("Frame") then
                    TweenService:Create(c, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                end
            end
            task.wait(0.35)
            frame:Destroy()
        end)

        return {
            setProgress = function(p)
                fill.Size = UDim2.new(math.clamp(p, 0, 1), 0, 1, 0)
            end,
            setMessage = function(t) msgLbl.Text = t end,
            close = function() frame:Destroy() end,
        }
    end

    Lib.Notification = N
end

--//===== MODULE: UI/Window =====
do
    local Window = {}
    Window.__index = Window

    local function makeDraggable(frame, handle)
        handle = handle or frame
        local dragging = false
        local dragStart, startPos

        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    local function getGuiParent()
        local existing = CoreGui:FindFirstChild("LibUI")
        if existing then return existing end
        local sg = Instance.new("ScreenGui")
        sg.Name = "LibUI"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        local ok = pcall(function() sg.Parent = CoreGui end)
        if not ok or not sg.Parent then
            sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
        return sg
    end

    function Window.new(config)
        config = config or {}
        local self = setmetatable({}, Window)
        self.tabs = {}
        self.signals = {OnClose = Lib.Signal.new()}
        self.theme = Lib.Theme.get()
        self.config = config

        local parent = getGuiParent()

        self.gui = Instance.new("Frame")
        self.gui.Name = "LibWindow"
        self.gui.Size = UDim2.new(0, config.width or 560, 0, config.height or 380)
        self.gui.Position = UDim2.new(0.5, -(config.width or 560) / 2, 0.5, -(config.height or 380) / 2)
        self.gui.BackgroundColor3 = self.theme.Background
        self.gui.BorderSizePixel = 0
        self.gui.Active = true
        self.gui.Parent = parent

        Instance.new("UICorner", self.gui).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", self.gui)
        stroke.Color = self.theme.Border
        stroke.Thickness = 1

        self.titleBar = Instance.new("Frame", self.gui)
        self.titleBar.Size = UDim2.new(1, 0, 0, 36)
        self.titleBar.BackgroundColor3 = self.theme.Surface
        self.titleBar.BorderSizePixel = 0
        Instance.new("UICorner", self.titleBar).CornerRadius = UDim.new(0, 10)

        local tbFix = Instance.new("Frame", self.titleBar)
        tbFix.Size = UDim2.new(1, 0, 0, 10)
        tbFix.Position = UDim2.new(0, 0, 1, -10)
        tbFix.BackgroundColor3 = self.theme.Surface
        tbFix.BorderSizePixel = 0

        self.titleLabel = Instance.new("TextLabel", self.titleBar)
        self.titleLabel.Size = UDim2.new(1, -80, 1, 0)
        self.titleLabel.Position = UDim2.new(0, 15, 0, 0)
        self.titleLabel.BackgroundTransparency = 1
        self.titleLabel.Text = config.title or "Library"
        self.titleLabel.TextColor3 = self.theme.Text
        self.titleLabel.Font = Enum.Font.GothamBold
        self.titleLabel.TextSize = 14
        self.titleLabel.TextXAlignment = Enum.TextXAlignment.Left

        self.closeBtn = Instance.new("TextButton", self.titleBar)
        self.closeBtn.Size = UDim2.new(0, 26, 0, 26)
        self.closeBtn.Position = UDim2.new(1, -32, 0.5, -13)
        self.closeBtn.BackgroundColor3 = self.theme.Danger
        self.closeBtn.BorderSizePixel = 0
        self.closeBtn.Text = "×"
        self.closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        self.closeBtn.Font = Enum.Font.GothamBold
        self.closeBtn.TextSize = 16
        self.closeBtn.Parent = self.titleBar
        Instance.new("UICorner", self.closeBtn).CornerRadius = UDim.new(0, 6)

        self.closeBtn.MouseButton1Click:Connect(function()
            self.signals.OnClose:Fire()
            self:destroy()
        end)

        self.tabBar = Instance.new("ScrollingFrame", self.gui)
        self.tabBar.Size = UDim2.new(0, 150, 1, -46)
        self.tabBar.Position = UDim2.new(0, 10, 0, 42)
        self.tabBar.BackgroundColor3 = self.theme.Surface
        self.tabBar.BorderSizePixel = 0
        self.tabBar.ScrollBarThickness = 3
        self.tabBar.ScrollBarImageColor3 = self.theme.Accent
        Instance.new("UICorner", self.tabBar).CornerRadius = UDim.new(0, 8)
        local tabLayout = Instance.new("UIListLayout", self.tabBar)
        tabLayout.Padding = UDim.new(0, 4)
        tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        local tabPad = Instance.new("UIPadding", self.tabBar)
        tabPad.PaddingTop = UDim.new(0, 6)
        tabPad.PaddingLeft = UDim.new(0, 6)
        tabPad.PaddingRight = UDim.new(0, 6)

        self.contentFrame = Instance.new("Frame", self.gui)
        self.contentFrame.Size = UDim2.new(1, -170, 1, -46)
        self.contentFrame.Position = UDim2.new(0, 160, 0, 42)
        self.contentFrame.BackgroundColor3 = self.theme.Surface
        self.contentFrame.BorderSizePixel = 0
        Instance.new("UICorner", self.contentFrame).CornerRadius = UDim.new(0, 8)

        makeDraggable(self.gui, self.titleBar)
        return self
    end

    function Window:createTab(config)
        config = config or {}
        local tab = {window = self, name = config.name or "Tab"}
        tab.button = Instance.new("TextButton", self.tabBar)
        tab.button.Size = UDim2.new(1, 0, 0, 30)
        tab.button.BackgroundColor3 = self.theme.SurfaceAlt
        tab.button.BorderSizePixel = 0
        tab.button.Text = tab.name
        tab.button.TextColor3 = self.theme.Text
        tab.button.Font = Enum.Font.Gotham
        tab.button.TextSize = 12
        tab.button.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", tab.button).CornerRadius = UDim.new(0, 6)
        local tabPad = Instance.new("UIPadding", tab.button)
        tabPad.PaddingLeft = UDim.new(0, 10)

        tab.page = Instance.new("ScrollingFrame", self.contentFrame)
        tab.page.Size = UDim2.new(1, -10, 1, -10)
        tab.page.Position = UDim2.new(0, 5, 0, 5)
        tab.page.BackgroundTransparency = 1
        tab.page.ScrollBarThickness = 4
        tab.page.ScrollBarImageColor3 = self.theme.Accent
        tab.page.Visible = false
        tab.page.CanvasSize = UDim2.new(0, 0, 0, 0)

        local pageLayout = Instance.new("UIListLayout", tab.page)
        pageLayout.Padding = UDim.new(0, 6)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        local pagePad = Instance.new("UIPadding", tab.page)
        pagePad.PaddingTop = UDim.new(0, 6)
        pagePad.PaddingBottom = UDim.new(0, 6)
        pagePad.PaddingLeft = UDim.new(0, 6)
        pagePad.PaddingRight = UDim.new(0, 6)

        tab.button.MouseButton1Click:Connect(function() self:selectTab(tab) end)
        table.insert(self.tabs, tab)
        if #self.tabs == 1 then self:selectTab(tab) end
        return tab
    end

    function Window:selectTab(tab)
        for _, t in ipairs(self.tabs) do
            if t == tab then
                t.page.Visible = true
                t.button.BackgroundColor3 = self.theme.Accent
                t.button.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                t.page.Visible = false
                t.button.BackgroundColor3 = self.theme.SurfaceAlt
                t.button.TextColor3 = self.theme.Text
            end
        end
    end

    function Window:destroy()
        if self.gui then self.gui:Destroy() end
    end

    Lib.Window = Window
end

--//===== MODULE: UI/Components =====
do
    local C = {}
    local function theme() return Lib.Theme.get() end

    function C.section(parent, config)
        local container = Instance.new("Frame", parent)
        container.Size = UDim2.new(1, 0, 0, 26)
        container.BackgroundColor3 = theme().SurfaceAlt
        container.BorderSizePixel = 0
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel", container)
        label.Size = UDim2.new(1, -12, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = config.name or "Section"
        label.TextColor3 = theme().Accent
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left

        return container
    end

    function C.toggle(parent, config)
        local state = config.default or false
        local frame = Instance.new("TextButton", parent)
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = theme().SurfaceAlt
        frame.BorderSizePixel = 0
        frame.Text = ""
        frame.AutoButtonColor = false
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, -80, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = config.name or "Toggle"
        label.TextColor3 = theme().Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left

        local track = Instance.new("Frame", frame)
        track.Size = UDim2.new(0, 42, 0, 20)
        track.Position = UDim2.new(1, -52, 0.5, -10)
        track.BackgroundColor3 = state and theme().Success or theme().Border
        track.BorderSizePixel = 0
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame", track)
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        knob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        knob.BorderSizePixel = 0
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local onChange = config.callback
        local obj = {}

        local function setState(v)
            state = v
            track.BackgroundColor3 = state and theme().Success or theme().Border
            TweenService:Create(knob, TweenInfo.new(0.15), {
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            }):Play()
            if onChange then
                local ok, err = pcall(onChange, state)
                if not ok then warn("[Toggle] " .. tostring(err)) end
            end
        end

        frame.MouseButton1Click:Connect(function() setState(not state) end)
        obj.set = setState
        obj.get = function() return state end
        return obj
    end

    function C.button(parent, config)
        local frame = Instance.new("TextButton", parent)
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = config.color or theme().Accent
        frame.BorderSizePixel = 0
        frame.Text = config.name or "Button"
        frame.TextColor3 = Color3.fromRGB(255, 255, 255)
        frame.Font = Enum.Font.GothamBold
        frame.TextSize = 12
        frame.AutoButtonColor = false
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        local baseColor = frame.BackgroundColor3
        frame.MouseEnter:Connect(function()
            TweenService:Create(frame, TweenInfo.new(0.1), {
                BackgroundColor3 = baseColor:Lerp(Color3.fromRGB(255, 255, 255), 0.15)
            }):Play()
        end)
        frame.MouseLeave:Connect(function()
            TweenService:Create(frame, TweenInfo.new(0.1), {BackgroundColor3 = baseColor}):Play()
        end)
        frame.MouseButton1Click:Connect(function()
            if config.callback then
                local ok, err = pcall(config.callback)
                if not ok then warn("[Button] " .. tostring(err)) end
            end
        end)
        return frame
    end

    function C.slider(parent, config)
        local min = config.min or 0
        local max = config.max or 100
        local value = config.default or min

        local container = Instance.new("Frame", parent)
        container.Size = UDim2.new(1, 0, 0, 48)
        container.BackgroundColor3 = theme().SurfaceAlt
        container.BorderSizePixel = 0
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel", container)
        label.Size = UDim2.new(1, -12, 0, 18)
        label.Position = UDim2.new(0, 10, 0, 4)
        label.BackgroundTransparency = 1
        label.Text = config.name or "Slider"
        label.TextColor3 = theme().Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left

        local valueLabel = Instance.new("TextLabel", container)
        valueLabel.Size = UDim2.new(0, 60, 0, 18)
        valueLabel.Position = UDim2.new(1, -70, 0, 4)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(value)
        valueLabel.TextColor3 = theme().Accent
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 12
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right

        local bar = Instance.new("TextButton", container)
        bar.Size = UDim2.new(1, -20, 0, 8)
        bar.Position = UDim2.new(0, 10, 0, 30)
        bar.BackgroundColor3 = theme().Border
        bar.BorderSizePixel = 0
        bar.Text = ""
        bar.AutoButtonColor = false
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame", bar)
        fill.BackgroundColor3 = theme().Accent
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame", bar)
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        knob.BorderSizePixel = 0
        knob.ZIndex = 2
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local dragging = false
        local onChange = config.callback

        local function updateFromX(x)
            local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local newValue = min + (max - min) * rel
            if config.integer ~= false then newValue = math.floor(newValue) end
            if newValue ~= value then
                value = newValue
                valueLabel.Text = tostring(value)
                if onChange then
                    local ok, err = pcall(onChange, value)
                    if not ok then warn("[Slider] " .. tostring(err)) end
                end
            end
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -7, 0.5, -7)
        end

        local function refresh()
            local rel = (value - min) / (max - min)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -7, 0.5, -7)
        end
        refresh()

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateFromX(input.Position.X)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateFromX(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        local obj = {}
        obj.set = function(v)
            value = math.clamp(v, min, max)
            valueLabel.Text = tostring(value)
            refresh()
            if onChange then onChange(value) end
        end
        obj.get = function() return value end
        return obj
    end

    function C.textbox(parent, config)
        local container = Instance.new("Frame", parent)
        container.Size = UDim2.new(1, 0, 0, 48)
        container.BackgroundColor3 = theme().SurfaceAlt
        container.BorderSizePixel = 0
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel", container)
        label.Size = UDim2.new(1, -12, 0, 16)
        label.Position = UDim2.new(0, 10, 0, 4)
        label.BackgroundTransparency = 1
        label.Text = config.name or "Textbox"
        label.TextColor3 = theme().Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left

        local box = Instance.new("TextBox", container)
        box.Size = UDim2.new(1, -20, 0, 22)
        box.Position = UDim2.new(0, 10, 0, 22)
        box.BackgroundColor3 = theme().Background
        box.BorderSizePixel = 0
        box.Text = config.default or ""
        box.PlaceholderText = config.placeholder or "..."
        box.TextColor3 = theme().Text
        box.PlaceholderColor3 = theme().TextDim
        box.Font = Enum.Font.Gotham
        box.TextSize = 12
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.ClearTextOnFocus = false
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
        local pad = Instance.new("UIPadding", box)
        pad.PaddingLeft = UDim.new(0, 6)
        pad.PaddingRight = UDim.new(0, 6)

        box.FocusLost:Connect(function(enterPressed)
            if config.callback then
                local ok, err = pcall(config.callback, box.Text, enterPressed)
                if not ok then warn("[Textbox] " .. tostring(err)) end
            end
        end)

        local obj = {}
        obj.set = function(v) box.Text = v end
        obj.get = function() return box.Text end
        return obj
    end

    function C.dropdown(parent, config)
        local options = config.options or {}
        local selected = config.default or (options[1] or "")
        local isOpen = false

        local container = Instance.new("Frame", parent)
        container.Size = UDim2.new(1, 0, 0, 60)
        container.BackgroundColor3 = theme().SurfaceAlt
        container.BorderSizePixel = 0
        container.ClipsDescendants = false
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel", container)
        label.Size = UDim2.new(1, -12, 0, 16)
        label.Position = UDim2.new(0, 10, 0, 4)
        label.BackgroundTransparency = 1
        label.Text = config.name or "Dropdown"
        label.TextColor3 = theme().Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left

        local button = Instance.new("TextButton", container)
        button.Size = UDim2.new(1, -20, 0, 28)
        button.Position = UDim2.new(0, 10, 0, 22)
        button.BackgroundColor3 = theme().Background
        button.BorderSizePixel = 0
        button.Text = "  " .. tostring(selected) .. "  ▼"
        button.TextColor3 = theme().Text
        button.Font = Enum.Font.Gotham
        button.TextSize = 12
        button.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)

        local list = Instance.new("ScrollingFrame", container)
        list.Size = UDim2.new(1, -20, 0, 0)
        list.Position = UDim2.new(0, 10, 0, 52)
        list.BackgroundColor3 = theme().Background
        list.BorderSizePixel = 0
        list.Visible = false
        list.ScrollBarThickness = 3
        list.ZIndex = 10
        Instance.new("UICorner", list).CornerRadius = UDim.new(0, 4)
        local listLayout = Instance.new("UIListLayout", list)
        listLayout.Padding = UDim.new(0, 2)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        local listPad = Instance.new("UIPadding", list)
        listPad.PaddingTop = UDim.new(0, 4)
        listPad.PaddingLeft = UDim.new(0, 4)
        listPad.PaddingRight = UDim.new(0, 4)

        local onChange = config.callback

        for _, opt in ipairs(options) do
            local btn = Instance.new("TextButton", list)
            btn.Size = UDim2.new(1, -8, 0, 24)
            btn.BackgroundColor3 = theme().SurfaceAlt
            btn.BorderSizePixel = 0
            btn.Text = "  " .. tostring(opt)
            btn.TextColor3 = theme().Text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.ZIndex = 11
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            btn.MouseButton1Click:Connect(function()
                selected = opt
                button.Text = "  " .. tostring(selected) .. "  ▼"
                isOpen = false
                list.Visible = false
                list.Size = UDim2.new(1, -20, 0, 0)
                container.Size = UDim2.new(1, 0, 0, 60)
                if onChange then
                    local ok, err = pcall(onChange, selected)
                    if not ok then warn("[Dropdown] " .. tostring(err)) end
                end
            end)
        end

        button.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            list.Visible = isOpen
            if isOpen then
                local h = math.min(#options * 26 + 8, 120)
                list.Size = UDim2.new(1, -20, 0, h)
                container.Size = UDim2.new(1, 0, 0, 60 + h)
            else
                list.Size = UDim2.new(1, -20, 0, 0)
                container.Size = UDim2.new(1, 0, 0, 60)
            end
        end)

        local obj = {}
        obj.set = function(v)
            selected = v
            button.Text = "  " .. tostring(selected) .. "  ▼"
        end
        obj.get = function() return selected end
        return obj
    end

    function C.label(parent, config)
        local label = Instance.new("TextLabel", parent)
        label.Size = UDim2.new(1, 0, 0, config.height or 20)
        label.BackgroundTransparency = 1
        label.Text = config.text or "Label"
        label.TextColor3 = config.color or theme().Text
        label.Font = config.bold and Enum.Font.GothamBold or Enum.Font.Gotham
        label.TextSize = config.size or 12
        label.TextXAlignment = config.align or Enum.TextXAlignment.Left
        return label
    end

    function C.paragraph(parent, config)
        local label = Instance.new("TextLabel", parent)
        label.Size = UDim2.new(1, 0, 0, 0)
        label.AutomaticSize = Enum.AutomaticSize.Y
        label.BackgroundTransparency = 1
        label.Text = config.text or ""
        label.TextColor3 = config.color or theme().TextDim
        label.Font = Enum.Font.Gotham
        label.TextSize = config.size or 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextWrapped = true
        label.TextYAlignment = Enum.TextYAlignment.Top
        return label
    end

    function C.divider(parent)
        local div = Instance.new("Frame", parent)
        div.Size = UDim2.new(1, 0, 0, 1)
        div.BackgroundColor3 = theme().Border
        div.BorderSizePixel = 0
        return div
    end

    function C.keybind(parent, config)
        local currentKey = config.default or Enum.KeyCode.F
        local listening = false

        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = theme().SurfaceAlt
        frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, -100, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = config.name or "Keybind"
        label.TextColor3 = theme().Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left

        local keyBtn = Instance.new("TextButton", frame)
        keyBtn.Size = UDim2.new(0, 80, 0, 22)
        keyBtn.Position = UDim2.new(1, -90, 0.5, -11)
        keyBtn.BackgroundColor3 = theme().Background
        keyBtn.BorderSizePixel = 0
        keyBtn.Text = currentKey.Name
        keyBtn.TextColor3 = theme().Text
        keyBtn.Font = Enum.Font.GothamBold
        keyBtn.TextSize = 11
        Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 4)

        local onChange = config.callback

        keyBtn.MouseButton1Click:Connect(function()
            listening = true
            keyBtn.Text = "..."
        end)

        UserInputService.InputBegan:Connect(function(input, gp)
            if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                listening = false
                keyBtn.Text = currentKey.Name
                if onChange then
                    local ok, err = pcall(onChange, currentKey)
                    if not ok then warn("[Keybind] " .. tostring(err)) end
                end
            end
        end)

        local obj = {}
        obj.get = function() return currentKey end
        obj.set = function(k) currentKey = k; keyBtn.Text = k.Name end
        return obj
    end

    --// ProgressBar
    function C.progressbar(parent, config)
        config = config or {}
        local container = Instance.new("Frame", parent)
        container.Size = UDim2.new(1, 0, 0, 40)
        container.BackgroundColor3 = theme().SurfaceAlt
        container.BorderSizePixel = 0
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel", container)
        label.Size = UDim2.new(1, -12, 0, 16)
        label.Position = UDim2.new(0, 10, 0, 4)
        label.BackgroundTransparency = 1
        label.Text = config.name or "Progress"
        label.TextColor3 = theme().Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left

        local valueLabel = Instance.new("TextLabel", container)
        valueLabel.Size = UDim2.new(0, 60, 0, 16)
        valueLabel.Position = UDim2.new(1, -70, 0, 4)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = "0%"
        valueLabel.TextColor3 = theme().Accent
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 11
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right

        local track = Instance.new("Frame", container)
        track.Size = UDim2.new(1, -20, 0, 8)
        track.Position = UDim2.new(0, 10, 0, 24)
        track.BackgroundColor3 = theme().Border
        track.BorderSizePixel = 0
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = config.color or theme().Accent
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local obj = {}
        obj.set = function(percent, animate)
            percent = math.clamp(percent, 0, 100)
            valueLabel.Text = string.format("%.0f%%", percent)
            local targetSize = UDim2.new(percent / 100, 0, 1, 0)
            if animate ~= false then
                TweenService:Create(fill, TweenInfo.new(0.25), {Size = targetSize}):Play()
            else
                fill.Size = targetSize
            end
        end
        obj.setColor = function(c) fill.BackgroundColor3 = c end
        obj.setText = function(t) label.Text = t end
        return obj
    end

    --// ColorPicker
    function C.colorpicker(parent, config)
        config = config or {}
        local currentColor = config.default or Color3.fromRGB(255, 255, 255)
        local onChange = config.callback

        local container = Instance.new("Frame", parent)
        container.Size = UDim2.new(1, 0, 0, 32)
        container.BackgroundColor3 = theme().SurfaceAlt
        container.BorderSizePixel = 0
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel", container)
        label.Size = UDim2.new(1, -80, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = config.name or "Color"
        label.TextColor3 = theme().Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left

        local swatch = Instance.new("TextButton", container)
        swatch.Size = UDim2.new(0, 50, 0, 22)
        swatch.Position = UDim2.new(1, -60, 0.5, -11)
        swatch.BackgroundColor3 = currentColor
        swatch.BorderSizePixel = 0
        swatch.Text = ""
        Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 4)

        local picker = Instance.new("Frame", container)
        picker.Size = UDim2.new(1, -20, 0, 0)
        picker.Position = UDim2.new(0, 10, 0, 32)
        picker.BackgroundColor3 = theme().Background
        picker.BorderSizePixel = 0
        picker.ClipsDescendants = true
        picker.Visible = false
        Instance.new("UICorner", picker).CornerRadius = UDim.new(0, 4)

        local svBox = Instance.new("Frame", picker)
        svBox.Size = UDim2.new(1, -70, 0, 120)
        svBox.Position = UDim2.new(0, 5, 0, 5)
        svBox.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        svBox.BorderSizePixel = 0
        Instance.new("UICorner", svBox).CornerRadius = UDim.new(0, 4)

        local svOverlay = Instance.new("Frame", svBox)
        svOverlay.Size = UDim2.new(1, 0, 1, 0)
        svOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        svOverlay.BorderSizePixel = 0
        Instance.new("UICorner", svOverlay).CornerRadius = UDim.new(0, 4)
        local svGradient = Instance.new("UIGradient", svOverlay)
        svGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
        })
        svGradient.Rotation = 90

        local svCursor = Instance.new("Frame", svBox)
        svCursor.Size = UDim2.new(0, 10, 0, 10)
        svCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        svCursor.BorderSizePixel = 0
        svCursor.ZIndex = 5
        Instance.new("UICorner", svCursor).CornerRadius = UDim.new(1, 0)
        local cursorStroke = Instance.new("UIStroke", svCursor)
        cursorStroke.Color = Color3.fromRGB(0, 0, 0)
        cursorStroke.Thickness = 1

        local hueBar = Instance.new("Frame", picker)
        hueBar.Size = UDim2.new(0, 20, 0, 120)
        hueBar.Position = UDim2.new(1, -55, 0, 5)
        hueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hueBar.BorderSizePixel = 0
        Instance.new("UICorner", hueBar).CornerRadius = UDim.new(0, 4)

        local hueGradient = Instance.new("UIGradient", hueBar)
        local hueKeys = {}
        for i = 0, 6 do
            table.insert(hueKeys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
        end
        hueGradient.Color = ColorSequence.new(hueKeys)

        local hueCursor = Instance.new("Frame", hueBar)
        hueCursor.Size = UDim2.new(1, 4, 0, 6)
        hueCursor.Position = UDim2.new(-2, 0, 0, 0)
        hueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hueCursor.BorderSizePixel = 0
        hueCursor.ZIndex = 5
        Instance.new("UICorner", hueCursor).CornerRadius = UDim.new(0, 2)

        local h, s, v = currentColor:ToHSV()

        local function updateColor()
            local newColor = Color3.fromHSV(h, s, v)
            svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            swatch.BackgroundColor3 = newColor
            if onChange then pcall(onChange, newColor) end
        end

        local function updateCursors()
            svCursor.Position = UDim2.new(s, -5, 1 - v, -5)
            hueCursor.Position = UDim2.new(0, 0, h, -3)
        end
        updateCursors()

        local svDragging, hueDragging = false, false

        local function onSVMove(x, y)
            local relX = math.clamp((x - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
            local relY = math.clamp((y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
            s, v = relX, 1 - relY
            updateCursors()
            updateColor()
        end

        local function onHueMove(y)
            h = math.clamp((y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
            updateCursors()
            updateColor()
        end

        svBox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                svDragging = true
                onSVMove(input.Position.X, input.Position.Y)
            end
        end)
        hueBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                hueDragging = true
                onHueMove(input.Position.Y)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if svDragging then onSVMove(input.Position.X, input.Position.Y) end
                if hueDragging then onHueMove(input.Position.Y) end
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                svDragging, hueDragging = false, false
            end
        end)

        swatch.MouseButton1Click:Connect(function()
            picker.Visible = not picker.Visible
            if picker.Visible then
                picker.Size = UDim2.new(1, -20, 0, 130)
                container.Size = UDim2.new(1, 0, 0, 165)
            else
                picker.Size = UDim2.new(1, -20, 0, 0)
                container.Size = UDim2.new(1, 0, 0, 32)
            end
        end)

        local obj = {}
        obj.get = function() return Color3.fromHSV(h, s, v) end
        obj.set = function(c)
            h, s, v = c:ToHSV()
            updateCursors()
            updateColor()
        end
        return obj
    end

    Lib.Components = C
end

--//===== MODULE: UI/Tab methods =====
do
    local Tab = {}
    Tab.__index = Tab

    function Tab:addSection(config) return Lib.Components.section(self.page, config or {}) end
    function Tab:addToggle(config) return Lib.Components.toggle(self.page, config or {}) end
    function Tab:addButton(config) return Lib.Components.button(self.page, config or {}) end
    function Tab:addSlider(config) return Lib.Components.slider(self.page, config or {}) end
    function Tab:addTextbox(config) return Lib.Components.textbox(self.page, config or {}) end
    function Tab:addDropdown(config) return Lib.Components.dropdown(self.page, config or {}) end
    function Tab:addLabel(config) return Lib.Components.label(self.page, config or {}) end
    function Tab:addParagraph(config) return Lib.Components.paragraph(self.page, config or {}) end
    function Tab:addDivider() return Lib.Components.divider(self.page) end
    function Tab:addKeybind(config) return Lib.Components.keybind(self.page, config or {}) end
    function Tab:addProgress(config) return Lib.Components.progressbar(self.page, config or {}) end
    function Tab:addColorpicker(config) return Lib.Components.colorpicker(self.page, config or {}) end

    Lib.Tab = Tab

    --// Обёртка createTab для присоединения метатаблицы Tab
    local origCreateTab = Lib.Window.createTab
    function Lib.Window:createTab(config)
        local tab = origCreateTab(self, config)
        return setmetatable(tab, Lib.Tab)
    end
end

--//===== MODULE: UI/Dialog =====
do
    local D = {}

    local function getParent()
        local existing = CoreGui:FindFirstChild("LibDialogs")
        if existing then return existing end
        local sg = Instance.new("ScreenGui")
        sg.Name = "LibDialogs"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        local ok = pcall(function() sg.Parent = CoreGui end)
        if not ok or not sg.Parent then
            sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
        return sg
    end

    function D.show(config)
        config = config or {}
        local theme = Lib.Theme.get()
        local parent = getParent()

        local backdrop = Instance.new("TextButton", parent)
        backdrop.Size = UDim2.new(1, 0, 1, 0)
        backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        backdrop.BackgroundTransparency = 0.5
        backdrop.BorderSizePixel = 0
        backdrop.Text = ""
        backdrop.AutoButtonColor = false
        backdrop.ZIndex = 100

        local dialog = Instance.new("Frame", backdrop)
        dialog.Size = UDim2.new(0, 320, 0, 160)
        dialog.Position = UDim2.new(0.5, -160, 0.5, -80)
        dialog.BackgroundColor3 = theme.Background
        dialog.BorderSizePixel = 0
        dialog.ZIndex = 101
        Instance.new("UICorner", dialog).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", dialog)
        stroke.Color = theme.Border
        stroke.Thickness = 1

        local title = Instance.new("TextLabel", dialog)
        title.Size = UDim2.new(1, -20, 0, 26)
        title.Position = UDim2.new(0, 10, 0, 8)
        title.BackgroundTransparency = 1
        title.Text = config.title or "Confirm"
        title.TextColor3 = theme.Text
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 102

        local message = Instance.new("TextLabel", dialog)
        message.Size = UDim2.new(1, -20, 0, 50)
        message.Position = UDim2.new(0, 10, 0, 40)
        message.BackgroundTransparency = 1
        message.Text = config.message or ""
        message.TextColor3 = theme.TextDim
        message.Font = Enum.Font.Gotham
        message.TextSize = 12
        message.TextXAlignment = Enum.TextXAlignment.Left
        message.TextYAlignment = Enum.TextYAlignment.Top
        message.TextWrapped = true
        message.ZIndex = 102

        local function makeBtn(pos, text, color, fn)
            local b = Instance.new("TextButton", dialog)
            b.Size = UDim2.new(0, 140, 0, 32)
            b.Position = pos
            b.BackgroundColor3 = color
            b.BorderSizePixel = 0
            b.Text = text
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.Font = Enum.Font.GothamBold
            b.TextSize = 12
            b.ZIndex = 102
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            b.MouseButton1Click:Connect(function()
                backdrop:Destroy()
                if fn then fn() end
            end)
            return b
        end

        makeBtn(UDim2.new(0, 10, 1, -44), config.okText or "OK", theme.Success, config.onConfirm)
        makeBtn(UDim2.new(1, -150, 1, -44), config.cancelText or "Cancel",
                theme.Danger, config.onCancel or config.onClose)

        return {close = function() backdrop:Destroy() end}
    end

    function D.prompt(config)
        config = config or {}
        local theme = Lib.Theme.get()
        local parent = getParent()

        local backdrop = Instance.new("TextButton", parent)
        backdrop.Size = UDim2.new(1, 0, 1, 0)
        backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        backdrop.BackgroundTransparency = 0.5
        backdrop.BorderSizePixel = 0
        backdrop.Text = ""
        backdrop.AutoButtonColor = false
        backdrop.ZIndex = 100

        local dialog = Instance.new("Frame", backdrop)
        dialog.Size = UDim2.new(0, 320, 0, 180)
        dialog.Position = UDim2.new(0.5, -160, 0.5, -90)
        dialog.BackgroundColor3 = theme.Background
        dialog.BorderSizePixel = 0
        dialog.ZIndex = 101
        Instance.new("UICorner", dialog).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", dialog)
        stroke.Color = theme.Border

        local title = Instance.new("TextLabel", dialog)
        title.Size = UDim2.new(1, -20, 0, 26)
        title.Position = UDim2.new(0, 10, 0, 8)
        title.BackgroundTransparency = 1
        title.Text = config.title or "Input"
        title.TextColor3 = theme.Text
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 102

        local box = Instance.new("TextBox", dialog)
        box.Size = UDim2.new(1, -20, 0, 30)
        box.Position = UDim2.new(0, 10, 0, 45)
        box.BackgroundColor3 = theme.SurfaceAlt
        box.BorderSizePixel = 0
        box.Text = config.default or ""
        box.PlaceholderText = config.placeholder or "..."
        box.TextColor3 = theme.Text
        box.PlaceholderColor3 = theme.TextDim
        box.Font = Enum.Font.Gotham
        box.TextSize = 12
        box.ZIndex = 102
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
        local pad = Instance.new("UIPadding", box)
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingRight = UDim.new(0, 8)

        local function makeBtn(pos, text, color, fn)
            local b = Instance.new("TextButton", dialog)
            b.Size = UDim2.new(0, 140, 0, 32)
            b.Position = pos
            b.BackgroundColor3 = color
            b.BorderSizePixel = 0
            b.Text = text
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.Font = Enum.Font.GothamBold
            b.TextSize = 12
            b.ZIndex = 102
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            b.MouseButton1Click:Connect(function()
                backdrop:Destroy()
                if fn then fn() end
            end)
            return b
        end

        makeBtn(UDim2.new(0, 10, 1, -44), config.okText or "OK", theme.Success, function()
            if config.onConfirm then config.onConfirm(box.Text) end
        end)
        makeBtn(UDim2.new(1, -150, 1, -44), config.cancelText or "Cancel",
                theme.Danger, config.onCancel)

        return {close = function() backdrop:Destroy() end}
    end

    Lib.Dialog = D
end

--//===== MODULE: UI/Console =====
do
    local C = {}
    C.__index = C

    function C.new(config)
        config = config or {}
        local self = setmetatable({}, C)
        self.entries = {}
        self.max = config.max or 100
        self.filters = {info = true, warn = true, error = true, debug = true}

        local theme = Lib.Theme.get()
        local sg = Instance.new("ScreenGui")
        sg.Name = "LibConsole"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        local ok = pcall(function() sg.Parent = CoreGui end)
        if not ok or not sg.Parent then
            sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end

        self.gui = Instance.new("Frame", sg)
        self.gui.Size = UDim2.new(0, config.width or 420, 0, config.height or 260)
        self.gui.Position = UDim2.new(0, 20, 1, -(config.height or 260) - 20)
        self.gui.BackgroundColor3 = theme.Background
        self.gui.BorderSizePixel = 0
        self.gui.Visible = config.defaultVisible or false
        Instance.new("UICorner", self.gui).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", self.gui)
        stroke.Color = theme.Border

        local titleBar = Instance.new("Frame", self.gui)
        titleBar.Size = UDim2.new(1, 0, 0, 28)
        titleBar.BackgroundColor3 = theme.Surface
        titleBar.BorderSizePixel = 0
        Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

        local titleLbl = Instance.new("TextLabel", titleBar)
        titleLbl.Size = UDim2.new(1, -80, 1, 0)
        titleLbl.Position = UDim2.new(0, 10, 0, 0)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = config.title or "Console"
        titleLbl.TextColor3 = theme.Text
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 12
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left

        local clearBtn = Instance.new("TextButton", titleBar)
        clearBtn.Size = UDim2.new(0, 50, 0, 20)
        clearBtn.Position = UDim2.new(1, -110, 0, 4)
        clearBtn.BackgroundColor3 = theme.Danger
        clearBtn.BorderSizePixel = 0
        clearBtn.Text = "Clear"
        clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        clearBtn.Font = Enum.Font.GothamBold
        clearBtn.TextSize = 10
        Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 4)

        local closeBtn = Instance.new("TextButton", titleBar)
        closeBtn.Size = UDim2.new(0, 22, 0, 22)
        closeBtn.Position = UDim2.new(1, -26, 0, 3)
        closeBtn.BackgroundColor3 = theme.SurfaceAlt
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = "×"
        closeBtn.TextColor3 = theme.Text
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 14
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

        local list = Instance.new("ScrollingFrame", self.gui)
        list.Size = UDim2.new(1, -10, 1, -38)
        list.Position = UDim2.new(0, 5, 0, 33)
        list.BackgroundTransparency = 1
        list.BorderSizePixel = 0
        list.ScrollBarThickness = 4
        list.ScrollBarImageColor3 = theme.Accent
        list.CanvasSize = UDim2.new(0, 0, 0, 0)
        local layout = Instance.new("UIListLayout", list)
        layout.Padding = UDim.new(0, 2)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        self.list = list
        self.layout = layout

        clearBtn.MouseButton1Click:Connect(function() self:clear() end)
        closeBtn.MouseButton1Click:Connect(function() self.gui.Visible = false end)

        return self
    end

    function C:log(kind, message)
        if not self.filters[kind] then return end
        local theme = Lib.Theme.get()
        local colors = {info = theme.Text, warn = theme.Warning, error = theme.Danger, debug = theme.TextDim}
        local prefix = {info = "[I]", warn = "[W]", error = "[E]", debug = "[D]"}
        local entry = {
            kind = kind,
            text = os.date("%H:%M:%S") .. " " .. prefix[kind] .. " " .. tostring(message),
            color = colors[kind] or theme.Text,
        }
        table.insert(self.entries, entry)
        if #self.entries > self.max then
            table.remove(self.entries, 1)
            if self.list:FindFirstChildOfClass("TextLabel") then
                self.list:FindFirstChildOfClass("TextLabel"):Destroy()
            end
        end
        local lbl = Instance.new("TextLabel", self.list)
        lbl.Size = UDim2.new(1, -6, 0, 0)
        lbl.AutomaticSize = Enum.AutomaticSize.Y
        lbl.BackgroundTransparency = 1
        lbl.Text = entry.text
        lbl.TextColor3 = entry.color
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Top
        lbl.TextWrapped = true
        self.list.CanvasSize = UDim2.new(0, 0, 0, self.layout.AbsoluteContentSize.Y + 10)
        self.list.CanvasPosition = Vector2.new(0, self.list.AbsoluteCanvasSize.Y)
        print(entry.text)
    end

    function C:info(msg) self:log("info", msg) end
    function C:warn(msg) self:log("warn", msg) end
    function C:error(msg) self:log("error", msg) end
    function C:debug(msg) self:log("debug", msg) end

    function C:clear()
        for _, c in ipairs(self.list:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
        self.entries = {}
        self.list.CanvasSize = UDim2.new(0, 0, 0, 0)
    end

    function C:toggle() self.gui.Visible = not self.gui.Visible end

    Lib.Console = C
end

--//===== MODULE: UI/ContextMenu =====
do
    local CM = {}
    local activeMenu = nil

    local function getParent()
        local existing = CoreGui:FindFirstChild("LibContext")
        if existing then return existing end
        local sg = Instance.new("ScreenGui")
        sg.Name = "LibContext"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        local ok = pcall(function() sg.Parent = CoreGui end)
        if not ok or not sg.Parent then
            sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
        return sg
    end

    function CM.close()
        if activeMenu then
            activeMenu:Destroy()
            activeMenu = nil
        end
    end

    function CM.show(items, x, y)
        CM.close()
        local theme = Lib.Theme.get()
        local parent = getParent()

        local menu = Instance.new("Frame", parent)
        menu.BackgroundColor3 = theme.Background
        menu.BorderSizePixel = 0
        menu.Position = UDim2.new(0, x, 0, y)
        menu.Size = UDim2.new(0, 180, 0, #items * 28 + 8)
        menu.ZIndex = 200
        Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 6)
        local stroke = Instance.new("UIStroke", menu)
        stroke.Color = theme.Border

        local layout = Instance.new("UIListLayout", menu)
        layout.Padding = UDim.new(0, 2)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        local pad = Instance.new("UIPadding", menu)
        pad.PaddingTop = UDim.new(0, 4)
        pad.PaddingLeft = UDim.new(0, 4)
        pad.PaddingRight = UDim.new(0, 4)

        for _, item in ipairs(items) do
            local btn = Instance.new("TextButton", menu)
            btn.Size = UDim2.new(1, -8, 0, 24)
            btn.BackgroundColor3 = item.color or theme.SurfaceAlt
            btn.BorderSizePixel = 0
            btn.Text = "  " .. (item.text or "Option")
            btn.TextColor3 = theme.Text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.ZIndex = 201
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            btn.MouseButton1Click:Connect(function()
                CM.close()
                if item.callback then pcall(item.callback) end
            end)
        end

        activeMenu = menu
        return menu
    end

    Lib.ContextMenu = CM
end

--//===== MODULE: UI/Tooltip =====
do
    local T = {}

    local function getParent()
        local existing = CoreGui:FindFirstChild("LibTooltip")
        if existing then return existing end
        local sg = Instance.new("ScreenGui")
        sg.Name = "LibTooltip"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        local ok = pcall(function() sg.Parent = CoreGui end)
        if not ok or not sg.Parent then
            sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
        return sg
    end

    function T.attach(target, text)
        local theme = Lib.Theme.get()
        local parent = getParent()

        local tooltip = Instance.new("TextLabel", parent)
        tooltip.BackgroundColor3 = theme.Background
        tooltip.BorderSizePixel = 0
        tooltip.Text = text
        tooltip.TextColor3 = theme.Text
        tooltip.Font = Enum.Font.Gotham
        tooltip.TextSize = 11
        tooltip.AutomaticSize = Enum.AutomaticSize.XY
        tooltip.Size = UDim2.new(0, 0, 0, 20)
        tooltip.Visible = false
        tooltip.ZIndex = 300
        Instance.new("UICorner", tooltip).CornerRadius = UDim.new(0, 4)
        local pad = Instance.new("UIPadding", tooltip)
        pad.PaddingTop = UDim.new(0, 4)
        pad.PaddingBottom = UDim.new(0, 4)
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingRight = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", tooltip)
        stroke.Color = theme.Border

        target.MouseEnter:Connect(function()
            local mouse = UserInputService:GetMouseLocation()
            tooltip.Position = UDim2.new(0, mouse.X + 15, 0, mouse.Y + 15)
            tooltip.Visible = true
        end)
        target.MouseLeave:Connect(function() tooltip.Visible = false end)
        return tooltip
    end

    Lib.Tooltip = T
end

--//===== MODULE: Drawing =====
do
    local D = {}

    function D.available() return type(Drawing) == "table" and Drawing.new ~= nil end

    function D.text(config)
        if not D.available() then return nil end
        config = config or {}
        local t = Drawing.new("Text")
        t.Text = config.text or ""
        t.Color = config.color or Color3.fromRGB(255, 255, 255)
        t.Size = config.size or 14
        t.Center = config.center ~= false
        t.Outline = config.outline ~= false
        t.OutlineColor = config.outlineColor or Color3.fromRGB(0, 0, 0)
        t.Transparency = config.transparency or 1
        t.Visible = config.visible ~= false
        if config.position then t.Position = config.position end
        return t
    end

    function D.square(config)
        if not D.available() then return nil end
        config = config or {}
        local s = Drawing.new("Square")
        s.Color = config.color or Color3.fromRGB(255, 255, 255)
        s.Thickness = config.thickness or 1
        s.Filled = config.filled or false
        s.Transparency = config.transparency or 1
        s.Visible = config.visible ~= false
        if config.size then s.Size = config.size end
        if config.position then s.Position = config.position end
        return s
    end

    function D.line(config)
        if not D.available() then return nil end
        config = config or {}
        local l = Drawing.new("Line")
        l.Color = config.color or Color3.fromRGB(255, 255, 255)
        l.Thickness = config.thickness or 1
        l.Transparency = config.transparency or 1
        l.Visible = config.visible ~= false
        if config.from then l.From = config.from end
        if config.to then l.To = config.to end
        return l
    end

    function D.circle(config)
        if not D.available() then return nil end
        config = config or {}
        local c = Drawing.new("Circle")
        c.Color = config.color or Color3.fromRGB(255, 255, 255)
        c.Thickness = config.thickness or 1
        c.Filled = config.filled or false
        c.NumSides = config.sides or 32
        c.Radius = config.radius or 20
        c.Transparency = config.transparency or 1
        c.Visible = config.visible ~= false
        if config.position then c.Position = config.position end
        return c
    end

    function D.clear(list)
        for _, obj in ipairs(list or {}) do
            pcall(function() obj:Remove() end)
        end
    end

    Lib.Drawing = D
end

--//===== MODULE: ESP =====
do
    local E = {}
    local active = {}

    function E.box(target, config)
        config = config or {}
        if not Lib.Drawing.available() then return nil end
        local entry = {
            target = target,
            config = config,
            box = Drawing.new("Square"),
            text = Drawing.new("Text"),
            tracer = config.tracer and Drawing.new("Line") or nil,
        }
        entry.box.Visible = false
        entry.box.Thickness = config.thickness or 2
        entry.box.Color = config.color or Color3.fromRGB(255, 0, 0)
        entry.box.Filled = false
        entry.box.Transparency = config.transparency or 0.9

        entry.text.Visible = false
        entry.text.Color = config.textColor or Color3.fromRGB(255, 255, 255)
        entry.text.Size = config.textSize or 14
        entry.text.Center = true
        entry.text.Outline = true

        table.insert(active, entry)
        return entry
    end

    function E.updateAll()
        if not Lib.Drawing.available() then return end
        local cam = workspace.CurrentCamera
        for _, e in ipairs(active) do
            local part
            if typeof(e.target) == "Instance" and e.target:IsA("BasePart") then
                part = e.target
            elseif typeof(e.target) == "Instance" and e.target:IsA("Model") then
                part = e.target.PrimaryPart or e.target:FindFirstChildWhichIsA("BasePart")
            end
            if not part or not part.Parent then
                e.box.Visible = false
                e.text.Visible = false
                if e.tracer then e.tracer.Visible = false end
            else
                local pos, onScreen = cam:WorldToViewportPoint(part.Position)
                if onScreen then
                    local size = Vector2.new(50, 50)
                    e.box.Visible = true
                    e.box.Size = size
                    e.box.Position = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)
                    e.text.Visible = true
                    e.text.Text = e.config.label or part.Name
                    e.text.Position = Vector2.new(pos.X, pos.Y - size.Y / 2 - 20)
                    if e.tracer then
                        e.tracer.Visible = true
                        e.tracer.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                        e.tracer.To = Vector2.new(pos.X, pos.Y)
                        e.tracer.Color = e.config.color or Color3.fromRGB(255, 0, 0)
                        e.tracer.Thickness = 1
                    end
                else
                    e.box.Visible = false
                    e.text.Visible = false
                    if e.tracer then e.tracer.Visible = false end
                end
            end
        end
    end

    function E.remove(entry)
        for i, e in ipairs(active) do
            if e == entry then
                pcall(function() e.box:Remove() end)
                pcall(function() e.text:Remove() end)
                if e.tracer then pcall(function() e.tracer:Remove() end) end
                table.remove(active, i)
                return
            end
        end
    end

    function E.clear()
        for _, e in ipairs(active) do
            pcall(function() e.box:Remove() end)
            pcall(function() e.text:Remove() end)
            if e.tracer then pcall(function() e.tracer:Remove() end) end
        end
        active = {}
    end

    RunService.RenderStepped:Connect(E.updateAll)

    Lib.ESP = E
end

--//===== MODULE: Config =====
do
    local Config = {}
    Config.__index = Config

    local FOLDER = "LibScripts"

    function Config.new(name)
        local self = setmetatable({}, Config)
        self.name = name or "default"
        self.data = {}
        self.flags = {}
        self.autoSave = true
        self.path = FOLDER .. "/" .. self.name .. ".json"
        return self
    end

    function Config:register(flag, default)
        self.flags[flag] = default
        if self.data[flag] == nil then self.data[flag] = default end
        return self.data[flag]
    end

    function Config:set(flag, value)
        self.data[flag] = value
        self:save()
    end

    function Config:get(flag)
        if flag == nil then return self.data end
        return self.data[flag]
    end

    function Config:reset()
        for k, v in pairs(self.flags) do self.data[k] = v end
        self:save()
    end

    function Config:save()
        if not self.autoSave then return end
        pcall(function()
            if writefile then
                if makefolder and not isfolder(FOLDER) then makefolder(FOLDER) end
                writefile(self.path, HttpService:JSONEncode(self.data))
            end
        end)
    end

    function Config:load()
        local ok, result = pcall(function()
            if readfile and isfile and isfile(self.path) then
                local content = readfile(self.path)
                if content and #content > 0 then
                    return HttpService:JSONDecode(content)
                end
            end
        end)
        if ok and result then
            for k, v in pairs(result) do self.data[k] = v end
        end
        return self.data
    end

    function Config:delete()
        pcall(function()
            if delfile and isfile and isfile(self.path) then delfile(self.path) end
        end)
    end

    Lib.Config = Config
end

--//===== MODULE: Profile =====
do
    local Profile = {}
    Profile.__index = Profile

    local FOLDER = "LibProfiles"

    function Profile.new(scriptName)
        local self = setmetatable({}, Profile)
        self.scriptName = scriptName or "script"
        self.data = {}
        self.name = "default"
        self.autoSave = true
        return self
    end

    function Profile:_path()
        return FOLDER .. "/" .. self.scriptName .. "/" .. self.name .. ".json"
    end

    function Profile:save(name)
        if name then self.name = name end
        if not self.autoSave then return end
        pcall(function()
            if makefolder then
                if not isfolder(FOLDER) then makefolder(FOLDER) end
                local sub = FOLDER .. "/" .. self.scriptName
                if not isfolder(sub) then makefolder(sub) end
            end
            if writefile then writefile(self:_path(), HttpService:JSONEncode(self.data)) end
        end)
    end

    function Profile:load(name)
        if name then self.name = name end
        local ok, result = pcall(function()
            if readfile and isfile and isfile(self:_path()) then
                return HttpService:JSONDecode(readfile(self:_path()))
            end
        end)
        if ok and result then self.data = result end
        return self.data
    end

    function Profile:set(key, value)
        self.data[key] = value
        if self.autoSave then self:save() end
    end

    function Profile:get(key) return self.data[key] end

    function Profile:list()
        local out = {}
        pcall(function()
            if listfiles then
                local folder = FOLDER .. "/" .. self.scriptName
                if isfolder(folder) then
                    for _, f in ipairs(listfiles(folder)) do
                        local name = f:match("([^/\\]+)%.json$")
                        if name then table.insert(out, name) end
                    end
                end
            end
        end)
        return out
    end

    function Profile:delete(name)
        name = name or self.name
        local oldName = self.name
        self.name = name
        pcall(function()
            if delfile and isfile and isfile(self:_path()) then delfile(self:_path()) end
        end)
        self.name = oldName
    end

    Lib.Profile = Profile
end

--//===== MODULE: Util/Timer =====
do
    local T = {}
    T.__index = T

    function T.new(duration, callback)
        local self = setmetatable({}, T)
        self.duration = duration
        self.callback = callback
        self.elapsed = 0
        self.running = false
        self.signal = Lib.Signal.new()
        return self
    end

    function T:start()
        if self.running then return end
        self.running = true
        self.startTime = tick()
        task.spawn(function()
            while self.running and (tick() - self.startTime) < self.duration do
                self.elapsed = tick() - self.startTime
                self.signal:Fire(self.elapsed, self.duration)
                task.wait(0.05)
            end
            if self.running then
                self.running = false
                if self.callback then pcall(self.callback) end
            end
        end)
    end

    function T:stop() self.running = false end

    function T:reset()
        self.running = false
        self.elapsed = 0
    end

    function T:remaining()
        return math.max(0, self.duration - (tick() - (self.startTime or tick())))
    end

    Lib.Timer = T
end

--//===== MODULE: Util/Stopwatch =====
do
    local S = {}
    S.__index = S

    function S.new() return setmetatable({startTime = tick(), laps = {}}, S) end

    function S:reset()
        self.startTime = tick()
        self.laps = {}
    end

    function S:elapsed() return tick() - self.startTime end

    function S:lap(name)
        local t = self:elapsed()
        table.insert(self.laps, {name = name or ("lap" .. (#self.laps + 1)), time = t})
        return t
    end

    function S:report()
        local out = {"=== Stopwatch ==="}
        for _, lap in ipairs(self.laps) do
            table.insert(out, string.format("  %s: %.3fs", lap.name, lap.time))
        end
        table.insert(out, string.format("  total: %.3fs", self:elapsed()))
        return table.concat(out, "\n")
    end

    Lib.Stopwatch = S
end

--//===== MODULE: Util/Queue =====
do
    local Q = {}
    Q.__index = Q

    function Q.new() return setmetatable({items = {}}, Q) end
    function Q:push(item) table.insert(self.items, item) end
    function Q:pop() return table.remove(self.items, 1) end
    function Q:peek() return self.items[1] end
    function Q:size() return #self.items end
    function Q:isEmpty() return #self.items == 0 end
    function Q:clear() self.items = {} end
    function Q:forEach(fn)
        for _, v in ipairs(self.items) do fn(v) end
    end

    Lib.Queue = Q
end

--//===== MODULE: Util/StateMachine =====
do
    local SM = {}
    SM.__index = SM

    function SM.new(initial)
        local self = setmetatable({}, SM)
        self.current = initial
        self.states = {}
        self.signal = Lib.Signal.new()
        return self
    end

    function SM:addState(name, handlers) self.states[name] = handlers or {} end

    function SM:transition(newState, ...)
        local oldState = self.current
        if oldState == newState then return end
        local oldDef = self.states[oldState]
        if oldDef and oldDef.onExit then pcall(oldDef.onExit, ...) end
        self.current = newState
        local newDef = self.states[newState]
        if newDef and newDef.onEnter then pcall(newDef.onEnter, ...) end
        self.signal:Fire(oldState, newState, ...)
    end

    function SM:update(...)
        local def = self.states[self.current]
        if def and def.onUpdate then pcall(def.onUpdate, ...) end
    end

    function SM:is(state) return self.current == state end

    Lib.StateMachine = SM
end

--//===== MODULE: Util/EventBus =====
do
    local EB = {}
    local channels = {}

    function EB.subscribe(channel, fn)
        if not channels[channel] then channels[channel] = Lib.Signal.new() end
        return channels[channel]:Connect(fn)
    end

    function EB.publish(channel, ...)
        if channels[channel] then channels[channel]:Fire(...) end
    end

    function EB.once(channel, fn)
        if not channels[channel] then channels[channel] = Lib.Signal.new() end
        return channels[channel]:Once(fn)
    end

    function EB.clear(channel)
        if channel then channels[channel] = nil else channels = {} end
    end

    Lib.EventBus = EB
end

--//===== MODULE: Util/Sequence =====
do
    local Seq = {}
    Seq.__index = Seq

    function Seq.new() return setmetatable({steps = {}}, Seq) end

    function Seq:add(instance, props, info, delay_)
        table.insert(self.steps, {
            type = "tween", instance = instance, props = props,
            info = info or TweenInfo.new(0.3), delay = delay_ or 0,
        })
        return self
    end

    function Seq:wait(seconds)
        table.insert(self.steps, {type = "wait", duration = seconds})
        return self
    end

    function Seq:call(fn)
        table.insert(self.steps, {type = "call", fn = fn})
        return self
    end

    function Seq:play(callback)
        task.spawn(function()
            for _, step in ipairs(self.steps) do
                if step.type == "tween" then
                    if step.delay > 0 then task.wait(step.delay) end
                    local tween = TweenService:Create(step.instance, step.info, step.props)
                    tween:Play()
                    tween.Completed:Wait()
                elseif step.type == "wait" then
                    task.wait(step.duration)
                elseif step.type == "call" then
                    pcall(step.fn)
                end
            end
            if callback then pcall(callback) end
        end)
        return self
    end

    Lib.Sequence = Seq
end

--//===== PUBLIC API =====
function Lib.createWindow(config)
    return Lib.Window.new(config)
end

function Lib.notify(config)
    return Lib.Notification.push(config)
end

function Lib.setTheme(name)
    Lib.Theme.set(name)
end

function Lib.createConfig(name)
    return Lib.Config.new(name)
end

function Lib.createConsole(config)
    return Lib.Console.new(config)
end

function Lib.createProfile(scriptName)
    return Lib.Profile.new(scriptName)
end

function Lib.createBind()
    return Lib.Bind.new()
end

function Lib.confirm(config)
    return Lib.Dialog.show(config)
end

function Lib.prompt(config)
    return Lib.Dialog.prompt(config)
end

function Lib.showContext(items, x, y)
    return Lib.ContextMenu.show(items, x, y)
end

return Lib
