local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-laundering:server:sellItem', function(amount, itemSell)
    local Player = QBCore.Functions.GetPlayer(source)
    local item = Player.Functions.GetItemByName(itemSell)
    if (item) then
        if (item.amount >= amount) then
            local money = Config.AllowedItems[itemSell].reward * amount
            Player.Functions.AddMoney('cash', money)
            Player.Functions.RemoveItem(itemSell, amount)
            TriggerClientEvent('QBCore:Notify', source, 'Vous avez vendu votre / vos ' .. QBCore.Shared.Items[itemSell].label .. ' pour $' .. money, 'success')
        else
            TriggerClientEvent('QBCore:Notify', source, 'Vous n\'avez que : ' .. item.amount .. ' ' .. QBCore.Shared.Items[itemSell].label, 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, 'Vous ne possedez pas de : ' .. QBCore.Shared.Items[itemSell].label, 'error')
    end
end)

RegisterNetEvent('qb-laundering:server:register', function(name, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        return
    end
    local amount = tonumber(amount)
    local citizenid = Player.PlayerData.citizenid
    local tax = math.floor(amount * Config.TaxRate)
    local startAmount = math.floor(amount - tax)
    -- You can send the tax somewhere here if you want
    if Player.Functions.RemoveMoney('cash', amount) then
        MySQL.query('INSERT INTO qb_laundering (owner, business, worth) VALUES (@citizenid, @name, @startAmount)', {
            ['@citizenid'] = citizenid,
            ['@name'] = name,
            ['@startAmount'] = startAmount,
        }, function()
        end)
        TriggerClientEvent('QBCore:Notify', source, 'Entreprise enregistrée avec succès !', 'success')
    elseif Player.Functions.RemoveMoney('bank', amount) then
        MySQL.query('INSERT INTO qb_laundering (owner, business, worth) VALUES (@citizenid, @name, @startAmount)', {
            ['@citizenid'] = citizenid,
            ['@name'] = name,
            ['@startAmount'] = startAmount,
        }, function()
        end)
        TriggerClientEvent('QBCore:Notify', source, 'Entreprise enregistrée avec succès !', 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'error', 'Vous n\'avez pas assez d\'argent')
    end
end)

RegisterNetEvent('qb-laundering:server:invest', function(amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        return
    end
    local amount = tonumber(amount)
    local tax = math.floor(amount * Config.TaxRate)
    local newAmount = math.floor(amount - tax)
    local citizenid = Player.PlayerData.citizenid
    if Player.Functions.RemoveMoney('cash', amount) then
        -- You can send the tax somewhere here if you want
        MySQL.query('UPDATE qb_laundering SET worth = worth + ' .. newAmount .. ' WHERE owner = ?', { citizenid })
        TriggerClientEvent('QBCore:Notify', source, 'Vous avez investi $' .. newAmount, 'success')
    elseif Player.Functions.RemoveMoney('bank', amount) then
        -- You can send the tax somewhere here if you want
        MySQL.query('UPDATE qb_laundering SET worth = worth + ' .. newAmount .. ' WHERE owner = ?', { citizenid })
        TriggerClientEvent('QBCore:Notify', source, 'Vous avez investi $' .. newAmount, 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Vous n\'avez pas assez d\'argent', 'error')
    end
end)

RegisterNetEvent('qb-laundering:server:clean', function(amount)
    local src = source
    local ped = GetPlayerPed(src)
    local Player = QBCore.Functions.GetPlayer(src)
    local worth = 0
    if not Player then
        return
    end

    local amount, amountToGive = tonumber(amount), tonumber(amount)

    local businessWorth = MySQL.scalar.await('SELECT worth FROM qb_laundering WHERE owner = ?', { Player.PlayerData.citizenid })

    if businessWorth < amount then
        return TriggerClientEvent('QBCore:Notify', src, 'Votre entreprise n\'a pas les fonds nécessaires', 'error')
    end

    local hasItem = Player.Functions.GetItemByName('markedbills')
    if not hasItem then
        return TriggerClientEvent('QBCore:Notify', src, 'Vous n\'avez pas de billets marqués !', 'error')
    end

    local hasItems = Player.Functions.GetItemsByName('markedbills')

    for i, v in ipairs(hasItems) do
        worth = worth + v.info.worth
    end

    if worth < amount then
        return TriggerClientEvent('QBCore:Notify', src, 'Votre / Vos sac(s) de billets ne contient / contiennent pas assez de billets pour blanchir cette somme !', 'error')
    end

    local washDate = MySQL.scalar.await('SELECT last_washed FROM qb_laundering WHERE owner = ?', { Player.PlayerData.citizenid })
    washDate = washDate / 1000

    if not washDate then
        return TriggerClientEvent('QBCore:Notify', src, 'Vous n\'avez pas d\'entreprise pour blanchir cet argent !', 'error')
    end

    local diff = os.time() - (washDate)

    local reqDiff = Config.Cooldown

    if diff >= reqDiff then
        for i, v in ipairs(hasItems) do
            if amount > 0 then
                if amount >= v.info.worth then
                    Player.Functions.RemoveItem('markedbills', 1, v.slot)
                    amount = amount - v.info.worth
                else
                    local Player = QBCore.Functions.GetPlayer(src)
                    Player.PlayerData.items[v.slot].info.worth = v.info.worth - amount
                    Player.Functions.SetInventory(Player.PlayerData.items, true)
                end
            end
        end

        TaskPlayAnim(ped, Config.animDict, Config.anim, 1.0, 1.0, Config.animTime, 1, 0, 0, 0, 0)
        TriggerClientEvent('QBCore:Notify', src, 'Lavage de vos billets en cours ..', 'primary')
        Wait(Config.animTime)

        Player.Functions.AddMoney('cash', amountToGive)
        TriggerClientEvent('QBCore:Notify', src, 'Vous avez reçu $' .. amountToGive .. ' en cash', 'success')
        MySQL.query('UPDATE qb_laundering SET last_washed = CURRENT_TIMESTAMP() WHERE owner = ?', { Player.PlayerData.citizenid })
    else
        TriggerClientEvent('QBCore:Notify', src, 'Vous ne pouvez nettoyer l\'argent qu\'une fois toutes les ' .. Config.Cooldown / 3600 .. ' heures', 'error')
    end
end)

RegisterNetEvent('qb-laundering:server:sell', function()
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        return
    end
    local citizenid = Player.PlayerData.citizenid
    local worth = MySQL.scalar.await('SELECT worth FROM qb_laundering WHERE owner = ?', { Player.PlayerData.citizenid })
    local backMoney = worth / 2
    MySQL.query('DELETE FROM qb_laundering WHERE owner = ?', { citizenid })
    Player.Functions.AddMoney('bank', backMoney)
    TriggerClientEvent('QBCore:Notify', source, 'Entreprise vendue avec succès ! Vous avez récupéré : $' .. backMoney, 'success')
end)

QBCore.Functions.CreateCallback('qb-laundering:server:getBusiness', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        return
    end

    local sql = MySQL.query.await('SELECT * FROM qb_laundering WHERE owner = ?', { Player.PlayerData.citizenid })
    if sql then
        cb(sql[1])
    else
        cb(false)
    end
end)
