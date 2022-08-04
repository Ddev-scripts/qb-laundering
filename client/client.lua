local QBCore = exports['qb-core']:GetCoreObject()

-- Functions

function LoadAnimationDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(1)
    end
end

local function comma_value(amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end
    return formatted
end

local function RegisterBusiness()
    QBCore.Functions.TriggerCallback('qb-laundering:server:getBusiness', function(business)
        if business then
            exports['qb-menu']:openMenu({
                { header = business.business .. ' | Value: $' .. comma_value(business.worth), isMenuHeader = true },
                {
                    header = 'Investir dans la société',
                    params = {
                        event = 'qb-laundering:client:invest',
                        args = {}
                    }
                },
                {
                    header = 'Vendre votre société',
                    params = {
                        isServer = true,
                        event = 'qb-laundering:server:sell',
                        args = {}
                    }
                }
            })
        else
            local dialog = exports['qb-input']:ShowInput({
                header = 'Enregistrer une société',
                submitText = 'Suivant',
                inputs = {
                    {
                        type = 'text',
                        isRequired = true,
                        name = 'name',
                        text = 'Nom du business'
                    },
                    {
                        type = 'number',
                        isRequired = true,
                        name = 'amount',
                        text = 'Minimum $' .. Config.StartupFee
                    }
                }
            })
            if dialog then
                if not dialog.name then
                    return
                end
                if not dialog.amount then
                    return
                end
                if tonumber(dialog.amount) < Config.StartupFee then
                    return QBCore.Functions.Notify('Didn\'t meet minimum', 'error')
                end
                TriggerServerEvent('qb-laundering:server:register', dialog.name, dialog.amount)
            end
        end
    end)
end

local function CleanMoney()
    QBCore.Functions.TriggerCallback('qb-laundering:server:getBusiness', function(business)
        if business then
            local dialog = exports['qb-input']:ShowInput({
                header = 'Nettoyer l\'argent',
                submitText = 'Suivant',
                inputs = {
                    {
                        type = 'number',
                        isRequired = true,
                        name = 'amount',
                        text = 'Maximum $' .. business.worth
                    }
                }
            })
            if dialog then
                if not dialog.amount then
                    return
                end
                if tonumber(dialog.amount) > business.worth then
                    return QBCore.Functions.Notify('Vous ne pouvez pas nettoyer autant !', 'error')
                end
                TriggerServerEvent('qb-laundering:server:clean', dialog.amount)
            end
        end
    end)
end

local function OpenDoorAnimation()
    local ped = PlayerPedId()
    LoadAnimationDict("anim@heists@keycard@")
    TaskPlayAnim(ped, "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0)
    Wait(400)
    ClearPedTasks(ped)
end

local function EnterLab()
    local ped = PlayerPedId()
    OpenDoorAnimation()
    CWarehouse = true
    Wait(500)
    DoScreenFadeOut(250)
    Wait(250)
    SetEntityCoords(ped, Config.Locations.washing.exit.coords.x, Config.Locations.washing.exit.coords.y, Config.Locations.washing.exit.coords.z - 0.98)
    SetEntityHeading(ped, Config.Locations.washing.exit.coords.w)
    Wait(1000)
    DoScreenFadeIn(250)
end

local function ExitLab()
    local ped = PlayerPedId()
    OpenDoorAnimation()
    CWarehouse = true
    Wait(500)
    DoScreenFadeOut(250)
    Wait(250)
    SetEntityCoords(ped, Config.Locations.washing.enter.coords.x, Config.Locations.washing.enter.coords.y, Config.Locations.washing.enter.coords.z - 0.98)
    SetEntityHeading(ped, Config.Locations.washing.enter.coords.w)
    Wait(1000)
    DoScreenFadeIn(250)
    CWarehouse = false
end

local function SellObjects()
    local menu = {
        {
            header = "Vendre vos objets sur le darknet",
            isMenuHeader = true,
        },

    }

    for k, v in pairs(Config.AllowedItems) do
        print(Config.AllowedItems[k].reward)
        table.insert(menu, {
            header = "<center><p><img src=nui://" .. Config.img .. QBCore.Shared.Items[k].image .. " width=30px></p>",
            txt = QBCore.Shared.Items[k].label .. " ($" .. Config.AllowedItems[k].reward .. "/pièce)",
            params = {
                event = "qb-laundering:SellItem",
                args = {
                    item = k,
                }
            }
        })
    end

    exports['qb-menu']:openMenu(menu)
end

-- Events
RegisterNetEvent('qb-laundering:SellItem', function(args)
    local dialog = exports['qb-input']:ShowInput({
        header = "Vendre : " .. QBCore.Shared.Items[args.item].label,
        submitText = "Vendre",
        inputs = {
            {
                type = 'number',
                isRequired = true,
                name = 'amount',
                text = "Montant à vendre"
            }
        }
    });
    TriggerServerEvent('qb-laundering:server:sellItem' , math.tointeger(dialog.amount) , args.item)
end)

RegisterNetEvent('qb-laundering:registerLlc', function()
    RegisterBusiness()
end)

RegisterNetEvent('qb-laundering:enterLab', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local dist = #(pos - vector3(Config.Locations.washing.enter.coords.x, Config.Locations.washing.enter.coords.y, Config.Locations.washing.enter.coords.z))
    if dist < 2 then
        EnterLab()
    end
end)

RegisterNetEvent('qb-laundering:exitLab', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local dist = #(pos - vector3(Config.Locations.washing.exit.coords.x, Config.Locations.washing.exit.coords.y, Config.Locations.washing.exit.coords.z))
    if dist < 2 then
        ExitLab()
    end
end)

RegisterNetEvent('qb-laundering:client:invest', function()
    local dialog = exports['qb-input']:ShowInput({
        header = 'Montant à investir',
        submitText = 'Suivant',
        inputs = {
            {
                type = 'number',
                isRequired = true,
                name = 'amount',
                text = 'Montant ($)'
            }
        }
    })
    if dialog then
        if not dialog.amount then
            return
        end
        TriggerServerEvent('qb-laundering:server:invest', dialog.amount)
    end
end)

-- Threads

CreateThread(function()
    for k, v in pairs(Config.Locations) do
        if k == 'washing' then
            exports['qb-target']:AddBoxZone(v.name, v.coords, v.length, v.width, {
                name = v.name,
                debugPoly = v.debugPoly,
                minZ = v.coords.z - 2,
                maxZ = v.coords.z + 2,
            }, {
                options = {
                    {
                        icon = 'fa-solid fa-sack-dollar',
                        label = 'Laver l\'argent sale',
                        action = function()
                            CleanMoney()
                        end
                    },
                },
                distance = 1.5
            })

            exports['qb-target']:AddBoxZone(v.name, v.coords, v.length, v.width, {
                name = v.name,
                debugPoly = v.debugPoly,
                minZ = v.coords.z - 2,
                maxZ = v.coords.z + 2,
            }, {
                options = {
                    {
                        icon = 'fa-solid fa-sack-dollar',
                        label = 'Laver l\'argent sale',
                        action = function()
                            CleanMoney()
                        end
                    },
                },
                distance = 1.5
            })

            exports['qb-target']:AddBoxZone(v.computer.name, v.computer.coords, v.computer.length, v.computer.width, {
                name = v.computer.name,
                debugPoly = v.computer.debugPoly,
                minZ = v.computer.coords.z - 2,
                maxZ = v.computer.coords.z + 2,
            }, {
                options = {
                    {
                        icon = 'fa-solid fa-sack-dollar',
                        label = 'Vendre des objets sur le darknet',
                        action = function()
                            SellObjects()
                        end
                    },
                },
                distance = 1.5
            })

            exports['qb-target']:AddBoxZone(v.enter.name, v.enter.coords, v.enter.length, v.enter.width, {
                name = v.enter.name,
                debugPoly = v.exit.debugPoly,
                minZ = v.enter.coords.z - 2,
                maxZ = v.enter.coords.z + 2,
            }, {
                options = {
                    {
                        icon = 'fa-solid fa-door-open',
                        label = 'Entrer',
                        action = function()
                            TriggerEvent('qb-laundering:enterLab')
                        end
                    },
                },
                distance = 1.5
            })

            exports['qb-target']:AddBoxZone(v.exit.name, v.exit.coords, v.exit.length, v.exit.width, {
                name = v.exit.name,
                debugPoly = v.exit.debugPoly,
                minZ = v.exit.coords.z - 2,
                maxZ = v.exit.coords.z + 2,
            }, {
                options = {
                    {
                        icon = 'fa-solid fa-door-open',
                        label = 'Sortir',
                        action = function()
                            TriggerEvent('qb-laundering:exitLab')
                        end
                    },
                },
                distance = 1.5
            })
        end
    end
end)
