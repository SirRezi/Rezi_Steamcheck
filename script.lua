local discordWebhook = Config.Webhook
local embedSettings = Config.EmbedSettings

function SendToDiscord(name, message, color, source)
    if discordWebhook == nil then
        print("Discord-Webhook nicht konfiguriert!")
        return
    end

    local steamIdentifier = nil
    local fivemIdentifier = nil

    -- Versuche, die Steam-ID und FiveM-ID des Spielers zu erhalten
    for k, v in pairs(GetPlayerIdentifiers(source)) do
        if string.find(v, "steam") then
            steamIdentifier = v
        elseif string.find(v, "license") then
            fivemIdentifier = v
        end
    end

    local embed = {
        ["title"] = embedSettings.title,
        ["description"] = message,
        ["color"] = color or embedSettings.color,
        ["footer"] = {
            ["text"] = embedSettings.watermark
        },
        ["author"] = {
            ["name"] = "SirRezi System",
            ["icon_url"] = embedSettings.icon_url
        },
        ["fields"] = {
            {["name"] = "Steam ID", ["value"] = steamIdentifier, ["inline"] = true},
            {["name"] = "FiveM ID", ["value"] = fivemIdentifier, ["inline"] = true}
        },
        ["timestamp"] = os.date('!%Y-%m-%dT%H:%M:%SZ')
    }

    PerformHttpRequest(discordWebhook, function(err, text, headers) end, 'POST', json.encode({embeds = {embed}}), {['Content-Type'] = 'application/json'})
end

AddEventHandler("playerConnecting", function(name, setCallback, deferrals)
    local source = source
    local countdownTime = 5 -- Countdown-Zeit in Sekunden

    deferrals.defer()

    -- Starte den Countdown
    deferrals.update("Verbinde zum Server. Bitte warte " .. countdownTime .. " Sekunden.")

    Citizen.Wait(countdownTime * 1000) -- Warte für die festgelegte Zeit in Millisekunden

    if not GetPlayerIdentifiers(source) then
        -- Keine Identifikatoren gefunden
        deferrals.done("Keine Identifikatoren gefunden.")
        SendToDiscord("Steam-Check", "Keine Identifikatoren gefunden.", 16711680, source) -- Rot als Standardfarbe für Ablehnung
    else
        -- Identifikatoren gefunden
        deferrals.done()
        local steamName = GetPlayerName(source)
        SendToDiscord("Steam-Check", "Spieler hat erfolgreich verbunden.\nSpielername: " .. steamName, 65280, source) -- Grünes Farbschema für Erfolgsmeldung
    end
end)
