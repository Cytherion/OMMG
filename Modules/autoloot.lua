-- modules/autoloot.lua
local mq = require('mq')
local logger = require('utils.logger')

local autoloot = {}

function autoloot.run()
    local timeout = 10000
    local elapsed = 0
    while not mq.TLO.Window("LootWnd").Open() and elapsed < timeout do
        mq.delay(500)
        elapsed = elapsed + 500
    end
    if mq.TLO.Window("LootWnd").Open() then
        logger.info("Loot window open. Executing autoloot command.")
        mq.cmd("/mloot")
        mq.delay(1000)
    else
        logger.warn("Loot window did not open within timeout, autoloot not executed.")
    end
end

return autoloot
