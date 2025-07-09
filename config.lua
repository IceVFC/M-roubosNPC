Config = {}

-- Distância máxima para interagir com o NPC
Config.InteractionDistance = 2.0

-- Tempo do progressbar para o assalto (em segundos)
Config.RobberyTime = { min = 5, max = 10 }

-- Probabilidades de Reação dos NPCs
Config.NPCReaction = {
    Enabled = true, -- Ativar/Desativar reações de NPCs
    Chance = 30,    -- % de chance de NPCs reagirem (0-100)
    Radius = 20.0,  -- Raio em torno do assalto onde NPCs podem reagir
    MaxReactingNPCs = 10, -- Número máximo de NPCs que podem reagir

    -- Modelos de NPCs reagentes e suas armas
    ReactionPeds = {
        { model = "a_m_m_southerner_01", weapon = "WEAPON_KNIFE", chance = 40 }, -- Faca
        { model = "a_m_m_fatlatin_01", weapon = "WEAPON_BAT", chance = 30 },    -- Bastão
        { model = "a_m_y_business_01", weapon = "WEAPON_PISTOL", chance = 20 },  -- Pistola
        { model = "s_m_y_cop_01", weapon = "WEAPON_SMG", chance = 10 },       -- SMG (pode ser um "civil" mais agressivo)
    },

    -- Reação de Cães
    DogReaction = {
        Enabled = true, -- Ativar/Desativar reação de cães
        Chance = 25,    -- % de chance de cães reagirem (0-100)
        MinDogs = 1,    -- Número mínimo de cães
        MaxDogs = 15,    -- Número máximo de cães
        DogModel = "a_c_shepherd", -- Modelo do cão
    },
}

-- Recompensas de Dinheiro (dinheiro sujo)
Config.MoneyLoot = {
    Min = 10,
    Max = 1200,
    Probabilities = {
        { range = { 10, 100 }, chance = 40 },   -- 40% de chance de ganhar entre 10 e 100
        { range = { 101, 500 }, chance = 35 },  -- 35% de chance de ganhar entre 101 e 500
        { range = { 501, 900 }, chance = 20 },  -- 20% de chance de ganhar entre 501 e 900
        { range = { 901, 1200 }, chance = 5 },  -- 5% de chance de ganhar entre 901 e 1200
    }
}

-- Recompensas de Itens
Config.ItemLoot = {
    MaxItems = { min = 2, max = 3 }, -- Número de itens a receber (excluindo armas)
    Probabilities = {
        -- Itens comuns (maior probabilidade)
        { item = "sandwich", minQty = 1, maxQty = 2, chance = 20 },
        { item = "kurkakola", minQty = 1, maxQty = 2, chance = 20 },
        { item = "plastic", minQty = 5, maxQty = 20, chance = 15 },
        { item = "metalscrap", minQty = 5, maxQty = 20, chance = 15 },
        { item = "rubber", minQty = 5, maxQty = 20, chance = 10 },
        { item = "glass", minQty = 5, maxQty = 20, chance = 10 },

        -- Itens menos comuns
        { item = "vodka", minQty = 1, maxQty = 1, chance = 8 },
        { item = "xtcbaggy", minQty = 1, maxQty = 1, chance = 7 },
        { item = "casinochips", minQty = 1, maxQty = 5, chance = 5 },
        { item = "goldchain", minQty = 1, maxQty = 1, chance = 3 },
        { item = "radio", minQty = 1, maxQty = 1, chance = 2 },

        -- Materiais (quantidades maiores)
        { item = "copper", minQty = 5, maxQty = 50, chance = 5 },
        { item = "aluminum", minQty = 5, maxQty = 50, chance = 5 },
        { item = "aluminumoxide", minQty = 5, maxQty = 50, chance = 5 },
        { item = "iron", minQty = 5, maxQty = 50, chance = 5 },
        { item = "ironoxide", minQty = 5, maxQty = 50, chance = 5 },
        { item = "steel", minQty = 5, maxQty = 50, chance = 5 },
        { item = "weed_ak47", minQty = 1, maxQty = 1, chance = 2 }, -- Exemplo de item de droga
        { item = "weed_nutrition", minQty = 1, maxQty = 1, chance = 2 }, -- Exemplo de item de droga

        -- Armas (muito raras, apenas 1 por assalto)
        { item = "weapon_snspistol", minQty = 1, maxQty = 1, chance = 1, isWeapon = true },
        { item = "weapon_ceramicpistol", minQty = 1, maxQty = 1, chance = 0.8, isWeapon = true },
        { item = "weapon_knife", minQty = 1, maxQty = 1, chance = 1.5, isWeapon = true }, -- Faca como arma
    }
}