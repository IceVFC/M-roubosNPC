local QBCore = exports['qb-core']:GetCoreObject()

-- Função para escolher um item com base nas probabilidades
local function chooseItemByProbability(probabilities)
    local totalChance = 0
    for _, data in ipairs(probabilities) do
        totalChance = totalChance + data.chance
    end

    if totalChance == 0 then return nil end -- Evitar divisão por zero se não houver chances

    local randomValue = math.random(0, totalChance)
    local cumulativeChance = 0

    for _, data in ipairs(probabilities) do
        cumulativeChance = cumulativeChance + data.chance
        if randomValue <= cumulativeChance then
            return data
        end
    end
    return nil
end

-- Evento do cliente para finalizar o assalto e dar o loot
RegisterNetEvent('mercado_negro_assaltos:finishRobbery', function(pedCoords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    local robbedLoot = {} -- Tabela para armazenar o que foi roubado para notificação final

    -- 1. Dar dinheiro sujo
    local selectedMoneyAmount = 0
    local totalMoneyChance = 0
    for _, prob in ipairs(Config.MoneyLoot.Probabilities) do
        totalMoneyChance = totalMoneyChance + prob.chance
    end

    if totalMoneyChance > 0 then
        local moneyRoll = math.random(0, totalMoneyChance)
        local currentMoneyChance = 0
        for _, prob in ipairs(Config.MoneyLoot.Probabilities) do
            currentMoneyChance = currentMoneyChance + prob.chance
            if moneyRoll <= currentMoneyChance then
                selectedMoneyAmount = math.random(prob.range[1], prob.range[2])
                break
            end
        end
    end
    
    if selectedMoneyAmount > 0 then
        Player.Functions.AddMoney('black_money', selectedMoneyAmount, 'robbed-npc')
        table.insert(robbedLoot, { type = "money", value = selectedMoneyAmount })
    end

    -- 2. Dar itens aleatórios
    local numItemsToGive = math.random(Config.ItemLoot.MaxItems.min, Config.ItemLoot.MaxItems.max)
    local itemsGivenCount = 0
    local weaponsGiven = 0

    -- Separa itens normais e armas para melhor controle de probabilidades
    local normalItemProbabilities = {}
    local weaponProbabilities = {}
    for _, itemData in ipairs(Config.ItemLoot.Probabilities) do
        if itemData.isWeapon then
            table.insert(weaponProbabilities, itemData)
        else
            table.insert(normalItemProbabilities, itemData)
        end
    end

    -- Tentar dar itens normais
    -- Evita loops infinitos se não houver itens normais configurados ou se a soma das chances for 0
    local maxAttempts = 5 -- Limite de tentativas para encontrar um item se a probabilidade for baixa
    while itemsGivenCount < numItemsToGive and maxAttempts > 0 do
        local chosenItemData = chooseItemByProbability(normalItemProbabilities)
        if chosenItemData then
            local qty = math.random(chosenItemData.minQty, chosenItemData.maxQty)
            if Player.Functions.AddItem(chosenItemData.item, qty) then
                table.insert(robbedLoot, { type = "item", name = chosenItemData.item, qty = qty })
                itemsGivenCount = itemsGivenCount + 1
            else
                TriggerClientEvent('QBCore:Notify', src, "Não tens espaço no inventário para mais " .. QBCore.Shared.Items[chosenItemData.item].label .. ".", "error", 3000)
                break -- Para de tentar adicionar itens se não houver espaço
            end
        else
            maxAttempts = maxAttempts - 1 -- Diminui tentativas se não encontrar item
            if #normalItemProbabilities == 0 then break end -- Não há itens para escolher
        end
    end

    -- Tentar dar uma arma (se permitido e com probabilidade)
    if weaponsGiven < 1 and #weaponProbabilities > 0 then -- Limita a 1 arma por assalto
        local chosenWeaponData = chooseItemByProbability(weaponProbabilities)
        if chosenWeaponData then
            -- Verifica se o jogador já tem esta arma no inventário para não dar duplicado
            -- Nota: QBCore gerencia automaticamente a duplicidade de armas por slot
            -- Aqui, verificamos se o jogador já possui o *tipo* de arma, não a instância.
            -- A menos que a tua base de dados e inventário permitam múltiplas instâncias da mesma arma.
            -- Para evitar dar a mesma arma repetidamente, podemos verificar se o item já existe no inventário do jogador
            local hasWeapon = false
            for _, playerItem in ipairs(Player.Functions.GetItems()) do
                if playerItem.name == chosenWeaponData.item and playerItem.type == 'weapon' then
                    hasWeapon = true
                    break
                end
            end

            if not hasWeapon then
                -- Adiciona a arma. O terceiro e quarto argumentos são para 'isNew' (false) e 'slot' (false para auto-slot)
                if Player.Functions.AddItem(chosenWeaponData.item, 1, false, false) then
                    table.insert(robbedLoot, { type = "weapon", name = chosenWeaponData.item, qty = 1 })
                    weaponsGiven = weaponsGiven + 1
                else
                    TriggerClientEvent('QBCore:Notify', src, "Não tens espaço no inventário para a arma " .. QBCore.Shared.Items[chosenWeaponData.item].label .. ".", "error", 5000)
                end
            end
        end
    end

    -- Enviar notificação final consolidada para o cliente
    local lootMessage = "Roubaste:"
    if #robbedLoot > 0 then
        for i, loot in ipairs(robbedLoot) do
            if loot.type == "money" then
                lootMessage = lootMessage .. " $" .. loot.value .. " (dinheiro sujo)"
            elseif loot.type == "item" then
                local itemLabel = QBCore.Shared.Items[loot.name] and QBCore.Shared.Items[loot.name].label or loot.name
                lootMessage = lootMessage .. " " .. loot.qty .. "x " .. itemLabel
            elseif loot.type == "weapon" then
                local weaponLabel = QBCore.Shared.Items[loot.name] and QBCore.Shared.Items[loot.name].label or loot.name
                lootMessage = lootMessage .. " 1x " .. weaponLabel .. " (arma)"
            end
            if i < #robbedLoot then
                lootMessage = lootMessage .. "," -- Adiciona vírgula entre os itens
            end
        end
        lootMessage = lootMessage .. "." -- Adiciona ponto final no final
        TriggerClientEvent('QBCore:Notify', src, lootMessage, "success", 7500) -- Notificação mais longa
    else
        TriggerClientEvent('QBCore:Notify', src, "O NPC não tinha nada de valor.", "info", 5000)
    end
end)