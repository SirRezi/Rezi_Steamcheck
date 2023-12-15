Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

        if Config.SteamCheckEnabled then
            TriggerServerEvent("CheckSteamID")
        end
    end
end)
