-- 📦 Dịch vụ
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local rewardsGui = player:WaitForChild("PlayerGui"):WaitForChild("ReactGameNewRewards")

-- 🔁 Biến điều khiển
local running = false
local connections = {}

-- =========================
-- 🔹 Dọn dẹp khi reset
-- =========================
local function cleanup()
    running = false
    for _, c in ipairs(connections) do
        if c and c.Disconnect then
            c:Disconnect()
        end
    end
    connections = {}
end

-- =========================
-- 🔹 MAIN FUNCTION
-- =========================
local function main()
    if running then return end
    cleanup()
    running = true
    print("🚀 Script started")

    local towerFolder = workspace:WaitForChild("Towers")
    local remoteFunction = ReplicatedStorage:WaitForChild("RemoteFunction")

    local cashGui = player:WaitForChild("PlayerGui")
        :WaitForChild("ReactUniversalHotbar")
        :WaitForChild("Frame")
        :WaitForChild("values")
        :WaitForChild("cash")
        :WaitForChild("amount")

    local container = player:WaitForChild("PlayerGui")
        :WaitForChild("ReactGameTopGameDisplay")
        :WaitForChild("Frame")
        :WaitForChild("wave")
        :WaitForChild("container")

    -- ========== Hàm phụ ==========
    local function getCash()
        local rawText = cashGui.Text or ""
        local cleaned = rawText:gsub("[^%d%-]", "")
        return tonumber(cleaned) or 0
    end

    local function waitForCash(minAmount)
        while running and getCash() < minAmount do
            task.wait(1)
        end
    end

    local function safeInvoke(args, cost)
        waitForCash(cost)
        if not running then return end
        pcall(function()
            remoteFunction:InvokeServer(unpack(args))
        end)
        task.wait(1)
    end

    local function upgradeTower(num, cost)
        local towers = towerFolder:GetChildren()
        local towerToUpgrade = towers[num]
        if towerToUpgrade then
            local args = { "Troops", "Upgrade", "Set", { Troop = towerToUpgrade } }
            safeInvoke(args, cost)
        end
    end

    local function sellAllTowers()
        local towers = towerFolder:GetChildren()
        for _, tower in ipairs(towers) do
            local args = { "Troops", "Se\108\108", { Troop = tower } }
            pcall(function()
                remoteFunction:InvokeServer(unpack(args))
            end)
            task.wait(0.2)
        end
    end

    local function getCurrentFromLabel(label)
        local text = label.Text
        return tonumber(text:match("^(%d+)"))
    end

    -- ========== Auto strat (ví dụ) ==========
    task.spawn(function()
        safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(10.7704, 1, 13.3150) }, "Crook Boss" }, 950)
        upgradeTower(1, 500)
        upgradeTower(1, 1350)

        safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(3.3605, 1, -12.7730) }, "Trapper" }, 750)
        upgradeTower(2, 750)
        upgradeTower(2, 2250)

        safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(4.1646, 1, -9.3058) }, "Trapper" }, 750)
        upgradeTower(3, 750)
        upgradeTower(3, 2250)

        safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(-3.1828, 1, -12.2039) }, "Trapper" }, 750)
        upgradeTower(4, 750)
        upgradeTower(4, 2250)

        safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(7.4607, 1, 14.3718) }, "Crook Boss" }, 950)
        upgradeTower(5, 500)
        upgradeTower(5, 1350)

        safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(8.3785, 1, 11.0120) }, "Crook Boss" }, 950)
        upgradeTower(6, 500)
        upgradeTower(6, 1350)

        safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(10.0447, 1, 16.7455) }, "Crook Boss" }, 950)
        upgradeTower(7, 500)
        upgradeTower(7, 1350)

        safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(11.3270, 1, 9.4668) }, "Crook Boss" }, 950)
        upgradeTower(8, 500)
        upgradeTower(8, 1350)
    end)

    -- ========== Auto skip mỗi 10s ==========
    task.spawn(function()
        while running do
            pcall(function()
                remoteFunction:InvokeServer("Voting", "Skip")
            end)
            task.wait(1)
        end
    end)

    -- ========== Auto sell wave 24 ==========
    for _, label in ipairs(container:GetDescendants()) do
        if label:IsA("TextLabel") then
            local conn = label:GetPropertyChangedSignal("Text"):Connect(function()
                if running and getCurrentFromLabel(label) == 24 then
                    sellAllTowers()
                end
            end)
            table.insert(connections, conn)
        end
    end
end

-- =========================
-- 🔹 RESET & RESTART
-- =========================
local function restartScript()
    print("💀 Game Over → Restarting...")
    local towerFolder = workspace:FindFirstChild("Towers")
    local remoteFunction = ReplicatedStorage:WaitForChild("RemoteFunction")
    if towerFolder then
        for _, tower in ipairs(towerFolder:GetChildren()) do
            local args = { "Troops", "Se\108\108", { Troop = tower } }
            pcall(function()
                remoteFunction:InvokeServer(unpack(args))
            end)
            task.wait(0.2)
        end
    end
    cleanup()
    task.wait(2)
    main()
end

-- Theo dõi khi có gameOver
task.spawn(function()
    while task.wait(1) do
        for _, obj in ipairs(rewardsGui:GetDescendants()) do
            if obj.Name == "gameOver" and obj:IsA("GuiObject") and obj.Visible then
                restartScript()
                return
            end
        end
    end
end)

-- Nếu gameOver add sau thì cũng bắt
local conn = rewardsGui.DescendantAdded:Connect(function(obj)
    if obj.Name == "gameOver" and obj:IsA("GuiObject") then
        local c = obj:GetPropertyChangedSignal("Visible"):Connect(function()
            if obj.Visible then
                restartScript()
            end
        end)
        table.insert(connections, c)
    end
end)
table.insert(connections, conn)

-- 🚀 Lần chạy đầu
main()
