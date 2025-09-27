-- 📦 Dịch vụ
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- 🌍 Remote + Towers
local remoteFunction = ReplicatedStorage:WaitForChild("RemoteFunction")
local towerFolder = workspace:WaitForChild("Towers")

-- 💰 Cash GUI
local cashGui = player:WaitForChild("PlayerGui")
:WaitForChild("ReactUniversalHotbar")
:WaitForChild("Frame")
:WaitForChild("values")
:WaitForChild("cash")
:WaitForChild("amount")

-- 🌊 Wave GUI
local container = player:WaitForChild("PlayerGui")
:WaitForChild("ReactGameTopGameDisplay")
:WaitForChild("Frame")
:WaitForChild("wave")
:WaitForChild("container")

-- =========================
-- 🔹 HÀM CƠ BẢN
-- =========================
local function getCash()
    local rawText = cashGui.Text or ""
    local cleaned = rawText:gsub("[^%d%-]", "")
    return tonumber(cleaned) or 0
end

local function waitForCash(minAmount)
    while getCash() < minAmount do
        task.wait(1)
    end
end

local function safeInvoke(args, cost)
    waitForCash(cost)
    pcall(function()
        remoteFunction:InvokeServer(unpack(args))
    end)
    task.wait(1)
end

local function upgradeTower(num, cost)
    local towers = towerFolder:GetChildren()
    local towerToUpgrade = towers[num]
    if towerToUpgrade then
        local args = {
            "Troops",
            "Upgrade",
            "Set",
            { Troop = towerToUpgrade }
        }
        safeInvoke(args, cost)
    end
end

local function sellAllTowers()
    local towers = towerFolder:GetChildren()
    for _, tower in ipairs(towers) do
        local args = {
            "Troops",
            "Se\108\108", -- Sell
            { Troop = tower }
        }
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

-- =========================
-- 🔹 AUTO PLACE + UPGRADE
-- =========================
safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(10.7704, 0.9999, 13.3150) }, "Crook Boss" }, 950)
upgradeTower(1, 500)
upgradeTower(1, 1350)

safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(3.3605, 1.0000, -12.7730) }, "Trapper" }, 750)
upgradeTower(2, 750)
upgradeTower(2, 2250)

safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(4.1646, 1.0000, -9.3058) }, "Trapper" }, 750)
upgradeTower(3, 750)
upgradeTower(3, 2250)

safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(-3.1828, 1.0000, -12.2039) }, "Trapper" }, 750)
upgradeTower(4, 750)
upgradeTower(4, 2250)

safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(7.4607, 0.9999, 14.3718) }, "Crook Boss" }, 950)
upgradeTower(5, 500)
upgradeTower(5, 1350)

safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(8.3785, 0.9999, 11.0120) }, "Crook Boss" }, 950)
upgradeTower(6, 500)
upgradeTower(6, 1350)

safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(10.0447, 0.9999, 16.7455) }, "Crook Boss" }, 950)
upgradeTower(7, 500)
upgradeTower(7, 1350)

safeInvoke({ "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(11.3270, 0.9999, 9.4668) }, "Crook Boss" }, 950)
upgradeTower(8, 500)
upgradeTower(8, 1350)

-- =========================
-- 🔹 AUTO SELL WAVE 24
-- =========================
for _, label in ipairs(container:GetDescendants()) do
    if label:IsA("TextLabel") then
        label:GetPropertyChangedSignal("Text"):Connect(function()
            if getCurrentFromLabel(label) == 24 then
                sellAllTowers()
            end
        end)
    end
end
