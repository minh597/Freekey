local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local remoteFunction = ReplicatedStorage:WaitForChild("RemoteFunction")
local player = game.Players.LocalPlayer

if workspace:FindFirstChild("Elevators") then
    local args = {
        [1] = "Multiplayer",
        [2] = "v2:start",
        [3] = {
            ["count"] = 1,
            ["mode"] = "halloween"
        }
    }
    remoteFunction:InvokeServer(unpack(args))
else
    remoteFunction:InvokeServer("Voting", "Skip")
    task.wait(1)
end

local guiPath = player:WaitForChild("PlayerGui")
    :WaitForChild("ReactUniversalHotbar")
    :WaitForChild("Frame")
    :WaitForChild("values")
    :WaitForChild("cash")
    :WaitForChild("amount")

local function getCash()
    local rawText = guiPath.Text or ""
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

local sequence = {
    { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(4.668, 2.349, -37.184) }, "Shotgunner" }, cost = 300 },
    { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(-1.643, 2.349, -36.870) }, "Shotgunner" }, cost = 300 },
    { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(4.487, 2.386, -34.154) }, "Shotgunner" }, cost = 300 },
    { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(-1.185, 2.386, -33.905) }, "Shotgunner" }, cost = 300 },
    { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(-0.616, 2.386, -30.504) }, "Shotgunner" }, cost = 300 },
    { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(7.143, 2.350, -39.064) }, "Trapper" }, cost = 500 },
    { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(7.671, 2.386, -35.299) }, "Trapper" }, cost = 500 },
    { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(-4.269, 2.349, -38.972) }, "Trapper" }, cost = 500 },
    { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(4.907, 2.386, -31.026) }, "Trapper" }, cost = 500 },
    { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(7.948, 2.386, -30.539) }, "Trapper" }, cost = 500 },
    { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(0.052, 2.386, -27.333) }, "Trapper" }, cost = 500 },
    { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(3.450, 2.386, -25.265) }, "Trapper" }, cost = 500 },
}

for _, step in ipairs(sequence) do
    safeInvoke(step.args, step.cost)
end

local playerGui = player:WaitForChild("PlayerGui")
local rewardsGui = playerGui:WaitForChild("ReactGameNewRewards")

local function teleportToTDS()
    TeleportService:Teleport(3260590327, player)
end

task.spawn(function()
    while task.wait(1) do
        for _, obj in ipairs(rewardsGui:GetDescendants()) do
            if obj.Name == "gameOver" and obj:IsA("GuiObject") and obj.Visible then
                teleportToTDS()
                return
            end
        end
    end
end)

rewardsGui.DescendantAdded:Connect(function(obj)
    if obj.Name == "gameOver" and obj:IsA("GuiObject") then
        obj:GetPropertyChangedSignal("Visible"):Connect(function()
            if obj.Visible then
                teleportToTDS()
            end
        end)
    end
end)

local towerFolder = workspace:WaitForChild("Towers")
task.spawn(function()
    while task.wait(1) do
        local towers = towerFolder:GetChildren()
        for _, tower in ipairs(towers) do
            local args = {
                "Troops",
                "Upgrade",
                "Set",
                { Troop = tower, Path = 1 }
            }
            pcall(function()
                remoteFunction:InvokeServer(unpack(args))
            end)
        end
    end
end)

local waveContainer = player:WaitForChild("PlayerGui")
    :WaitForChild("ReactGameTopGameDisplay")
    :WaitForChild("Frame")
    :WaitForChild("wave")
    :WaitForChild("container")

local function sellAllTowers()
    for _, tower in ipairs(towerFolder:GetChildren()) do
        local args = {
            "Troops",
            "Se\108\108",
            { Troop = tower }
        }
        pcall(function()
            remoteFunction:InvokeServer(unpack(args))
        end)
        task.wait(0.2)
    end
end

local function getWaveNumber(label)
    local text = label.Text or ""
    return tonumber(text:match("^(%d+)"))
end

for _, label in ipairs(waveContainer:GetDescendants()) do
    if label:IsA("TextLabel") then
        label:GetPropertyChangedSignal("Text"):Connect(function()
            local currentWave = getWaveNumber(label)
            if currentWave and currentWave == 15 then
                sellAllTowers()
            end
        end)
    end
end
