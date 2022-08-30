Config = {}

Config.TaxRate = 0.10 -- percentage
Config.StartupFee = 75000 -- Minimum required to start business
Config.Cooldown = 86400 -- secondes
Config.img = "qb-inventory/html/images/" -- Set this to your inventory
Config.animDict = 'anim@amb@business@cfm@cfm_drying_notes@'
Config.anim = 'loading_v3_worker'
Config.animTime = 5000 -- milliseconds


Config.AllowedItems = {
    ["metalscrap"] = {
        name = "metalscrap",
        reward = 3,
    },
    ["copper"] = {
        name = "copper",
        reward = 2,
    },
    ["iron"] = {
        name = "iron",
        reward = 2,
    },
    ["aluminum"] = {
        name = "aluminum",
        reward = 2,
    },
    ["steel"] = {
        name = "steel",
        reward = 2,
    },
    ["glass"] = {
        name = "glass",
        reward = 2,
    },
    ["lockpick"] = {
        name = "lockpick",
        reward = 150,
    },
    ["screwdriverset"] = {
        name = "screwdriverset",
        reward = 300,
    },
    ["electronickit"] = {
        name = "electronickit",
        reward = 300,
    },
    ["radioscanner"] = {
        name = "radioscanner",
        reward = 850,
    },
    ["gatecrack"] = {
        name = "gatecrack",
        reward = 600,
    },
    ["trojan_usb"] = {
        name = "trojan_usb",
        reward = 1000,
    },
    ["weed_brick"] = {
        name = "weed_brick",
        reward = 250,
    },
    ["phone"] = {
        name = "phone",
        reward = 750,
    },
    ["radio"] = {
        name = "radio",
        reward = 180,
    },
    ["handcuffs"] = {
        name = "handcuffs",
        reward = 400,
    },
    ["10kgoldchain"] = {
        name = "10kgoldchain",
        reward = 5750,
    },
    ["goldchain"] = {
        name = "goldchain",
        reward = 2500,
    },
    ["rolex"] = {
        name = "rolex",
        reward = 3200,
    },
    ["diamond_ring"] = {
        name = "diamond_ring",
        reward = 2700,
    },
    ["goldbar"] = {
        name = "goldbar",
        reward = 5000,
    },
    ["diamond"] = {
        name = "diamond",
        reward = 750,
    },
}

Config.Locations = {
    ['washing'] = {
        enter = {
            name = "washLabDoorEnter",
            coords = vector4(747.2, -1214.92, 24.75, 83.82),
            length = 3,
            width = 1.1,
            debugPoly = false
        },
        exit = {
            name = "washLabDoorExit",
            coords = vector4(1138.23, -3199.35, -39.67, 177.22),
            length = 0.2,
            width = 1.5,
            debugPoly = false
        },
        computer = {
            coords = vector4(1129.57, -3193.57, -40.00, 266.38),
            heading = 271,
            length = 2,
            width = 3,
            name = "computer",
            debugPoly = false
        },
        coords = vector3(1125.00, -3194.24, -40.4),
        heading = 271,
        length = 3,
        width = 7,
        name = "moneywash",
        debugPoly = false
    }
}
