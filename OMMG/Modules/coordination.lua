-- modules/coordination.lua
local mq = require('mq')
local missionManager = require('modules.mission_manager')
local logger = require('utils.logger')
local comms = require('modules/comms')

local coordination = {}

-- Assign a role to a group member using the selected coordination plugin.
function coordination.assignRole(memberName, role)
    local plugin = missionManager.getCoordinationPlugin()
    if plugin == "MQ2DanNet" then
        mq.cmdf("/dannet role %s %s", memberName, role)
        logger.info("Assigned role %s to %s via MQ2DanNet", role, memberName)
    elseif plugin == "MQ2EQBCS" then
        mq.cmdf("/eqbcs role %s %s", memberName, role)
        logger.info("Assigned role %s to %s via MQ2EQBCS", role, memberName)
    else
        logger.error("Unknown coordination plugin: %s", plugin)
    end
end

-- Broadcast role assignments to the group.
function coordination.broadcastRoleAssignments(roleAssignments)
    for memberName, role in pairs(roleAssignments) do
        comms.broadcast(string.format("Assigning %s role to %s", role, memberName))
        coordination.assignRole(memberName, role)
    end
end

-- Rotate tasks among group members.
function coordination.rotateTasks()
    comms.broadcast("Rotating tasks among group members.")
    mq.delay(500)
    -- Additional logic for task rotation can be added here.
end

return coordination
