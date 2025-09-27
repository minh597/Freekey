local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function safeInvoke(args, cost)
    pcall(function()
        ReplicatedStorage.RemoteFunction:InvokeServer(unpack(args))
    end)
end

local function upgradeTower(id, cost)
    pcall(function()
        ReplicatedStorage.RemoteFunction:InvokeServer("Troops", "Upgrade", id)
    end)
end

local function sellTower(id)
    pcall(function()
        ReplicatedStorage.RemoteFunction:InvokeServer("Troops", "Sell", id)
    end)
end

local function autoSkip()
    task.spawn(function()
        while task.wait(10) do
            if game.Workspace:FindFirstChild("gameOver") then break end
            pcall(function()
                ReplicatedStorage.RemoteFunction:InvokeServer("Voting", "Skip")
            end)
        end
    end)
end

local function runStrat()
    safeInvoke({ "Troops", "Place", { Rotation = CFrame.new(), Position = Vector3.new(10.770484924316406, 0.9999977946281433, 13.315070152282715) }, "Crook Boss" }, 950)
    upgradeTower(1, 500)
    upgradeTower(1, 1350)

    safeInvoke({ "Troops", "Place", { Rotation = CFrame.new(), Position = Vector3.new(3.360581398010254, 1.0000020265579224, -12.773082733154297) }, "Trapper" }, 750)
    upgradeTower(2, 750)
    upgradeTower(2, 2250)

    safeInvoke({ "Troops", "Place", { Rotation = CFrame.new(), Position = Vector3.new(4.164698600769043, 1.0000014305114746, -9.305870056152344) }, "Trapper" }, 750)
    upgradeTower(3, 750)
    upgradeTower(3, 2250)

    safeInvoke({ "Troops", "Place", { Rotation = CFrame.new(), Position = Vector3.new(-3.1828041076660156, 1.0000081062316895, -12.20391845703125) }, "Trapper" }, 750)
    upgradeTower(4, 750)
    upgradeTower(4, 2250)

    safeInvoke({ "Troops", "Place", { Rotation = CFrame.new(), Position = Vector3.new(7.460733413696289, 0.999997615814209, 14.37181282043457) }, "Crook Boss" }, 950)
    upgradeTower(5, 500)
    upgradeTower(5, 1350)

    safeInvoke({ "Troops", "Place", { Rotation = CFrame.new(), Position = Vector3.new(8.37854290008545, 0.999998152256012, 11.012062072753906) }, "Crook Boss" }, 950)
    upgradeTower(6, 500)
    upgradeTower(6, 1350)

    safeInvoke({ "Troops", "Place", { Rotation = CFrame.new(), Position = Vector3.new(10.044734001159668, 0.9999972581863403, 16.745502471923828) }, "Crook Boss" }, 950)
    upgradeTower(7, 500)
    upgradeTower(7, 1350)

    safeInvoke({ "Troops", "Place", { Rotation = CFrame.new(), Position = Vector3.new(11.327095031738281, 0.9999984502792358, 9.466830253601074) }, "Crook Boss" }, 950)
    upgradeTower(8, 500)
    upgradeTower(8, 1350)
end

local function sellAtWave24()
    task.spawn(function()
        while task.wait(1) do
            if game.Workspace:FindFirstChild("gameOver") then break end
            local wave = ReplicatedStorage:FindFirstChild("WaveNumber")
            if wave and wave.Value >= 24 then
                for i = 1, 8 do
                    sellTower(i)
                end
                break
            end
        end
    end)
end

local function main()
    autoSkip()
    runStrat()
    sellAtWave24()
end

task.spawn(function()
    while true do
        main()
        repeat task.wait(1) until game.Workspace:FindFirstChild("gameOver")
        task.wait(2)
    end
end)
