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
            task.wait(0.5)
        end
    end

    local function safeInvoke(args, cost)
        waitForCash(cost)
        if not running then return end
        pcall(function()
            remoteFunction:InvokeServer(unpack(args))
        end)
        task.wait(0.5)
    end

    local function upgradeTower(num, cost)
        local towers = towerFolder:GetChildren()
        local towerToUpgrade = towers[num]
        if towerToUpgrade and towerToUpgrade.Parent then
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

    -- ========== Auto strat ==========
    task.spawn(function()
        safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(10.77, 1, 13.31) }, "Crook Boss" }, 950)
        upgradeTower(1, 500)
        upgradeTower(1, 1350)

        safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(3.36, 1, -12.77) }, "Trapper" }, 750)
        upgradeTower(2, 750)
        upgradeTower(2, 2250)

        safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(4.16, 1, -9.30) }, "Trapper" }, 750)
        upgradeTower(3, 750)
        upgradeTower(3, 2250)

        safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(-3.18, 1, -12.20) }, "Trapper" }, 750)
        upgradeTower(4, 750)
        upgradeTower(4, 2250)

        safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(7.46, 1, 14.37) }, "Crook Boss" }, 950)
        upgradeTower(5, 500)
        upgradeTower(5, 1350)

        safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(8.37, 1, 11.01) }, "Crook Boss" }, 950)
        upgradeTower(6, 500)
        upgradeTower(6, 1350)

        safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(10.04, 1, 16.74) }, "Crook Boss" }, 950)
        upgradeTower(7, 500)
        upgradeTower(7, 1350)

        safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(11.32, 1, 9.46) }, "Crook Boss" }, 950)
        upgradeTower(8, 500)
        upgradeTower(8, 1350)

        -- 👉 Bán tất cả ở wave 24 rồi dừng
        for _, label in ipairs(container:GetDescendants()) do
            if label:IsA("TextLabel") then
                local conn = label:GetPropertyChangedSignal("Text"):Connect(function()
                    if running and getCurrentFromLabel(label) == 24 then
                        sellAllTowers()
                        print("✅ Done all steps → stopping script")
                        cleanup()
                    end
                end)
                table.insert(connections, conn)
            end
        end
    end)

    -- ========== Auto skip mỗi 1s ==========
    task.spawn(function()
        while running do
            pcall(function()
                remoteFunction:InvokeServer("Voting", "Skip")
            end)
            task.wait(1)
        end
    end)
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
    main() -- 👉 gọi lại strat từ đầu
end

-- Theo dõi gameOver
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
