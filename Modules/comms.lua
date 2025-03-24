-- modules/comms.lua
local mq = require('mq')
local logger = require('utils.logger')
-- Removed: local missionManager = require('modules.mission_manager')

local comms = {}

function comms.broadcast(message)
    -- Lazy-load missionManager when needed to break the circular dependency.
    local missionManager = require('modules.mission_manager')
    local plugin = missionManager.getCoordinationPlugin()
    if plugin == "MQ2DanNet" then
        mq.cmdf("/dannet broadcast %s", message)
    elseif plugin == "MQ2EQBCS" then
        mq.cmdf("/eqbcs broadcast %s", message)
    else
        logger.error("Unknown coordination plugin: %s", plugin)
    end
end

return comms
