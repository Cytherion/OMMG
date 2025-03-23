-- modules/navigation.lua

local mq = require('mq')
local logger = require('utils.logger')

local navigation = {}

local navPoints = {
    lguk = {
        patriarch  = { x = 604.3,  y = 129.6,  z = -210.6 },
        elder      = { x = 1025.8, y = -147.8, z = -211.0 },
        eye        = { x = 668.5,  y = -452.5, z = -205.0 },
        priest     = { x = 232.2,  y = -555.6, z = -223.9 },
        crusader   = { x = 232.2,  y = -555.6, z = -223.9 }, -- same as priest if needed
        noble      = { x = 341.5,  y = -159.4, z = -219.0 },
        herbalist  = { x = 37.8,   y = -138.4, z = -238.5 },
        king       = { x = -107.3, y = -8.3,   z = -237.8 },
    },
    dguk = {
        ritualist   = { x = 756.1,  y = -643.0,  z = -135.2 },
        savant      = { x = 583.2,  y = -608.6,  z = -163.3 },
        executioner = { x = 605.1,  y = -817.1,  z = -191.2 },
        cavalier    = { x = 622.2,  y = -607.0,  z = -191.2 },
        hand        = { x = 1140.7, y = -684.8,  z = -191.2 },
        archmagus   = { x = 1167.6, y = -791.3,  z = -191.2 },
        king        = { x = 1477.9, y = -748.7,  z = -177.2 },
    },
    naggy = {
        noble       = { x = -560.5, y = -120.7, z = -94.0 },
        king        = { x = -543.8, y = -336.9, z = -64.0 },
        priest      = { x = -579.2, y = -316.4, z = -75.0 },
        champ       = { x = -651.6, y = -317.8, z = -70.0 },
        guano       = { x = -666.6, y = -235.0, z = -83.0 },
        spider_nox  = { x = -867.7, y = -282.6, z = -66.0 },
        spider_stone= { x = -981.6, y = -344.1, z = -85.0 },
        djarn       = { x = -479.8, y = 354.1,  z = -79.8 },
    },
    general = {
        -- Replace these placeholder coordinates with the actual PoK coordinates.
        pok = { x = 123.45, y = 678.90, z = -50.0 }
    }
}

function navigation.navTo(zone, label)
    local point = navPoints[zone] and navPoints[zone][label]
    if point then
        local cmd = string.format("/nav loc %s %s %s", point.x, point.y, point.z)
        logger.debug(("Navigating to %s:%s → %s"):format(zone, label, cmd))
        mq.cmd(cmd)
        mq.delay(200)
        while mq.TLO.Navigation.Active() do
            mq.delay(100)
        end
    else
        logger.error("No navigation point defined for [%s][%s]", zone, label)
    end
end

return navigation
