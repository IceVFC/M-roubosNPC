local QBCore = exports['qb-core']:GetCoreObject()

local isRobbing = false -- Variável de controlo para saber se o jogador está a assaltar
local currentRobbedPed = nil -- Ped que está a ser assaltado
local reactionPeds = {} -- Tabela para armazenar os peds de reação spawnados
local currentAimingAtPed = nil -- Para rastrear o NPC que está a ser apontado
local robberyStartedForPed = {} -- Para evitar múltiplos assaltos/progressbars no mesmo ped

-- Função auxiliar para verificar se o jogador tem uma arma de fogo ou faca equipada
local function hasWeaponEquipped()
    local ped = PlayerPedId()
    local weaponHash = GetCurrentPedWeapon(ped)
    if weaponHash == `WEAPON_UNARMED` then
        return false
    end

    -- Obter o tipo de dano da arma para verificar se é de fogo ou corpo a corpo
    local weaponType = GetWeaponDamageType(weaponHash)
    -- Tipos de dano: 0=None, 1=Melee, 2=Bullet, 3=Explosive, 4=Electric, 5=Fire, 6=Collision
    if weaponType == 2 then -- Se for uma arma de fogo (Bullet)
        return true
    end

    -- Lista de hashes de armas brancas que consideramos para o assalto
    local meleeWeapons = {
        `WEAPON_KNIFE`, `WEAPON_DAGGER`, `WEAPON_BAT`, `WEAPON_HAMMER`, `WEAPON_CROWBAR`,
        `WEAPON_GOLFCLUB`, `WEAPON_BOTTLE`, `WEAPON_MACHETE`, `WEAPON_HATCHET`, `WEAPON_KNUCKLE`
    }
    for _, meleeHash in ipairs(meleeWeapons) do
        if weaponHash == meleeHash then
            return true
        end
    end

    return false
end

-- Thread principal para detecção de NPCs e interação
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) -- Espera mínima para alta responsividade

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        local weaponDrawn = hasWeaponEquipped()
        local entityAimingAt = GetEntityPlayerIsAimingAt(PlayerId())

        if weaponDrawn then
            -- Se parou de apontar para o ped anterior ou mudou de alvo, cancela o assalto nele
            if currentAimingAtPed ~= entityAimingAt then
                if isRobbing and currentRobbedPed == currentAimingAtPed then
                    TriggerEvent("QBCore:Client:CancelProgressBar")
                end
                currentAimingAtPed = entityAimingAt -- Atualiza o ped que está a ser apontado
            end

            -- Verifica se o alvo é um NPC válido e não está a ser assaltado
            if currentAimingAtPed ~= 0 and IsPedHuman(currentAimingAtPed) and not IsPedAPlayer(currentAimingAtPed) and not IsPedDeadOrDying(currentAimingAtPed, true) and not IsPedInAnyVehicle(currentAimingAtPed, false) then
                local pedCoords = GetEntityCoords(currentAimingAtPed)
                local dist = #(playerCoords - pedCoords)

                if dist <= Config.InteractionDistance then
                    -- Inicia o assalto se ainda não estiver a assaltar e se este ped não foi recentemente assaltado
                    if not isRobbing and not robberyStartedForPed[currentAimingAtPed] then
                        isRobbing = true
                        currentRobbedPed = currentAimingAtPed
                        robberyStartedForPed[currentRobbedPed] = true -- Marca o ped como alvo para evitar múltiplos assaltos

                        -- NPC levanta as mãos imediatamente
                        TaskHandsUp(currentRobbedPed, -1, playerPed, 0, false) -- -1 para manter as mãos para cima indefinidamente

                        -- Barra de progresso do QBCore
                        local robberyDuration = math.random(Config.RobberyTime.min, Config.RobberyTime.max)
                        QBCore.Functions.Progressbar("robbing_npc", "Assaltando NPC...", robberyDuration * 1000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {}, {}, {}, function() -- Callback para sucesso
                            -- Lógica de sucesso do assalto
                            if DoesEntityExist(currentRobbedPed) and not IsPedDeadOrDying(currentRobbedPed, true) then
                                TriggerServerEvent("mercado_negro_assaltos:finishRobbery", GetEntityCoords(currentRobbedPed))
                            else
                                QBCore.Functions.Notify("O NPC morreu ou desapareceu durante o assalto!", "error", 5000)
                            end

                            -- Reset do estado do assalto
                            isRobbing = false
                            robberyStartedForPed[currentRobbedPed] = nil -- Libera o ped para futuros assaltos (ou implementa cooldown aqui)
                            currentRobbedPed = nil
                            currentAimingAtPed = nil

                            -- Limpar peds de reação após o assalto (se houver)
                            for i = #reactionPeds, 1, -1 do
                                if DoesEntityExist(reactionPeds[i]) then
                                    DeletePed(reactionPeds[i])
                                end
                                table.remove(reactionPeds, i)
                            end

                            -- Lidar com reações de outros NPCs e cães após o assalto
                            handleNPCReactions(playerCoords, playerPed)

                        end, function() -- Callback para cancelamento
                            QBCore.Functions.Notify("Assalto cancelado!", "error", 5000)
                            if DoesEntityExist(currentRobbedPed) then
                                ClearPedTasks(currentRobbedPed) -- Limpa as tarefas do NPC
                                if math.random(1, 100) <= 50 then -- 50% de chance de fugir ao cancelar
                                    TaskSmartFleePed(currentRobbedPed, playerPed, 1000.0, -1)
                                else
                                    TaskCombatPed(currentRobbedPed, playerPed, 0, 16) -- Ou pode reagir
                                end
                            end
                            -- Reset do estado do assalto
                            isRobbing = false
                            robberyStartedForPed[currentRobbedPed] = nil
                            currentRobbedPed = nil
                            currentAimingAtPed = nil

                            -- Limpar peds de reação se o assalto for cancelado
                            for i = #reactionPeds, 1, -1 do
                                if DoesEntityExist(reactionPeds[i]) then
                                    DeletePed(reactionPeds[i])
                                end
                                table.remove(reactionPeds, i)
                            end
                        end)
                    end
                else
                    -- Se o NPC que está a ser apontado está fora de alcance mas o assalto está ativo
                    if isRobbing and currentRobbedPed == currentAimingAtPed then
                        TriggerEvent("QBCore:Client:CancelProgressBar")
                    end
                end
            else
                -- Se não estiver a apontar para um ped válido (ou se o ped alvo morreu/desapareceu)
                if isRobbing and currentRobbedPed == currentAimingAtPed then
                    TriggerEvent("QBCore:Client:CancelProgressBar")
                end
            end
        else
            -- Se não tiver arma equipada, garante que não está em assalto
            if isRobbing then
                TriggerEvent("QBCore:Client:CancelProgressBar")
            end
            currentAimingAtPed = nil -- Resetar quando não há arma
        end
    end
end)

-- Função para lidar com a reação de outros NPCs e cães
local function handleNPCReactions(playerCoords, playerPed)
    -- Reação de NPCs
    if Config.NPCReaction.Enabled and math.random(1, 100) <= Config.NPCReaction.Chance then
        local pedsAround = GetGamePool('CPed')
        local countReacting = 0

        for _, ped in ipairs(pedsAround) do
            if DoesEntityExist(ped) and ped ~= playerPed and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped, true) then
                local pedCoords = GetEntityCoords(ped)
                local dist = #(playerCoords - pedCoords)

                if dist <= Config.NPCReaction.Radius then
                    -- Chance de este NPC específico reagir, de acordo com o Config.ReactionPeds
                    local selectedReactionPedData = Config.NPCReaction.ReactionPeds[math.random(1, #Config.NPCReaction.ReactionPeds)]
                    if math.random(1, 100) <= selectedReactionPedData.chance then
                        countReacting = countReacting + 1
                        if countReacting > Config.NPCReaction.MaxReactingNPCs then break end

                        local modelHash = GetHashKey(selectedReactionPedData.model)
                        local weaponHash = GetHashKey(selectedReactionPedData.weapon)

                        RequestModel(modelHash)
                        while not HasModelLoaded(modelHash) do Citizen.Wait(0) end

                        RequestWeaponAsset(weaponHash, 3) -- 3 para qualquer tipo de arma
                        while not HasWeaponAssetLoaded(weaponHash) do Citizen.Wait(0) end

                        -- Spawnar o NPC reagente ligeiramente afastado do jogador
                        local spawnOffset = GetRandomFloatInRange(-5.0, 5.0)
                        local reactionPedCoords = GetOffsetFromEntityInWorldCoords(playerPed, spawnOffset, spawnOffset, 0.0)

                        local reactPed = CreatePed(2, modelHash, reactionPedCoords.x, reactionPedCoords.y, reactionPedCoords.z, GetEntityHeading(playerPed), false, true)
                        SetPedKeepTask(reactPed, true)
                        SetPedCombatAbility(reactPed, 100)
                        SetPedCombatRange(reactPed, 2) -- Curta distância
                        GiveWeaponToPed(reactPed, weaponHash, 1000, false, true)
                        SetPedRelationshipGroupHash(reactPed, GetHashKey("HATES_PLAYER")) -- Faz com que odeie o jogador
                        TaskCombatPed(reactPed, playerPed, 0, 16) -- Ataca o jogador
                        SetModelAsNoLongerNeeded(modelHash)
                        RemoveWeaponAsset(weaponHash) -- Libera o asset da arma
                        table.insert(reactionPeds, reactPed) -- Adiciona para limpeza posterior
                    end
                end
            end
        end
        if countReacting > 0 then
            QBCore.Functions.Notify("Outros NPCs reagiram ao assalto!", "error", 7000)
            SetPlayerWantedLevel(PlayerId(), 1, false) -- Ganha 1 estrela de procurado
            SetPlayerWantedLevelNow(PlayerId(), false)
        end
    end

    -- Reação de Cães
    if Config.NPCReaction.DogReaction.Enabled and math.random(1, 100) <= Config.NPCReaction.DogReaction.Chance then
        local numDogs = math.random(Config.NPCReaction.DogReaction.MinDogs, Config.NPCReaction.DogReaction.MaxDogs)
        for i = 1, numDogs do
            local dogModelHash = GetHashKey(Config.NPCReaction.DogReaction.DogModel)
            RequestModel(dogModelHash)
            while not HasModelLoaded(dogModelHash) do Citizen.Wait(0) end

            local spawnOffset = GetRandomFloatInRange(-3.0, 3.0)
            local dogSpawnCoords = GetOffsetFromEntityInWorldCoords(playerPed, spawnOffset, spawnOffset, 0.0)

            local dogPed = CreatePed(2, dogModelHash, dogSpawnCoords.x, dogSpawnCoords.y, dogSpawnCoords.z, 0.0, false, true)
            SetPedKeepTask(dogPed, true)
            SetPedCombatAbility(dogPed, 100)
            SetPedCombatRange(dogPed, 0) -- Alcance muito curto (ataque de corpo a corpo)
            SetPedRelationshipGroupHash(dogPed, GetHashKey("HATES_PLAYER"))
            TaskCombatPed(dogPed, playerPed, 0, 16) -- Ataca o jogador
            SetModelAsNoLongerNeeded(dogModelHash)
            table.insert(reactionPeds, dogPed) -- Adiciona para limpeza posterior
        end
        if numDogs > 0 then
            QBCore.Functions.Notify("Cães selvagens atacaram-te!", "error", 7000)
            SetPlayerWantedLevel(PlayerId(), 1, false) -- Cães também podem dar 1 estrela
            SetPlayerWantedLevelNow(PlayerId(), false)
        end
    end
end

-- Limpa os peds de reação quando o script é parado ou o jogador desconecta (segurança)
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, ped in ipairs(reactionPeds) do
            if DoesEntityExist(ped) then
                DeletePed(ped)
            end
        end
    end
end)