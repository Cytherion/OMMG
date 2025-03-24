-- modules/sync.lua
local mq = require('mq')
local logger = require('utils.logger')

local sync = {}
sync.currentStep = 0

-- Broadcast the current objective step to the group.
function sync.broadcastStep(step)
    sync.currentStep = step
    -- Broadcast using MQ2DanNet (modify this command if using EQBCS)
    mq.cmdf("/dannet broadcast sync:%d", step)
    logger.info("Broadcasting sync step: %d", step)
end

-- Wait until the current sync step is at least the expectedStep.
-- Timeout (in milliseconds) defaults to 30000 if not provided.
function sync.waitForStep(expectedStep, timeout)
    timeout = timeout or 30000
    local startTime = mq.gettime()
    while mq.gettime() - startTime < timeout do
        if sync.currentStep >= expectedStep then
            logger.info("Sync reached expected step: %d", expectedStep)
            return true
        end
        mq.delay(1000)
    end
    logger.error("Timeout waiting for sync step: %d", expectedStep)
    return false
end

-- Listen for sync messages in the format "sync:<number>"
mq.event("SyncStep", "sync:(%d+)", function(step)
    sync.currentStep = tonumber(step)
    logger.info("Received sync update: %d", sync.currentStep)
end)

return sync
