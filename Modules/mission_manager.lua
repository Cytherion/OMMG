-- modules/mission_manager.lua

local mq = require('mq')
local logger = require('utils.logger')
local comms = require('modules.comms')

local missionManager = {}

local missions = {
    naggy = require('modules.missions.naggy'),
    dguk  = require('modules.missions.dguk'),
    lguk  = require('modules.missions.lguk')
}

local currentMission = nil
local coordinationPlugin = "MQ2DanNet"  -- Default coordination plugin

function missionManager.select(missionName)
    local mission = missions[missionName]
    if not mission then
        logger.error("Unknown mission: %s", missionName)
        return false
    end
    currentMission = mission
    logger.info("Mission '%s' selected.", missionName)
    return true
end

function missionManager.run()
    if not currentMission then
        logger.error("No mission selected.")
        return
    end
    logger.info("Starting mission...")
    comms.broadcast("Mission starting: " .. currentMission and currentMission.name or "Unknown")
    currentMission.run()
    comms.broadcast("Mission complete!")
    logger.info("Mission complete!")
end

-- Run a cycle of selected missions; repeat if repeatFlag is true.
function missionManager.runSelected(selectedMissions, repeatFlag)
    logger.info("Starting mission cycle...")
    missionManager.ensureInPoK()  -- Ensure we start from PoK.
    repeat
        for _, missionKey in ipairs(selectedMissions) do
            local mission = missions[missionKey]
            if mission then
                logger.info("Running mission: %s", missionKey)
                comms.broadcast("Mission starting: " .. missionKey)
                mission.run()
                comms.broadcast("Mission complete: " .. missionKey)
            else
                logger.error("Mission not found: %s", missionKey)
            end
        end
        if repeatFlag then
            logger.info("Repeating mission cycle...")
        end
    until not repeatFlag
    logger.info("Mission cycle complete!")
end

function missionManager.clearActive()
    currentMission = nil
end

function missionManager.available()
    local list = {}
    for k, _ in pairs(missions) do
        table.insert(list, k)
    end
    return list
end

-- Ensure the user is in the Plane of Knowledge, then target Old Man McKenzie.
function missionManager.ensureInPoK()
    local zone = mq.TLO.Zone.ShortName() or ""
    if zone:lower() ~= "pok" then
        logger.info("Not in PoK. Navigating to PoK...")
        local navigation = require('modules.navigation')
        navigation.navTo("general", "pok")
        while (mq.TLO.Zone.ShortName() or ""):lower() ~= "pok" do
            mq.delay(1000)
        end
        logger.info("Entered PoK.")
    end
    mq.cmd("/target npc Old Man McKenzie")
    mq.delay(1000)
end

-- Getter and setter for the coordination plugin.
function missionManager.getCoordinationPlugin()
    return coordinationPlugin
end

function missionManager.setCoordinationPlugin(pluginName)
    coordinationPlugin = pluginName
    logger.info("Coordination plugin set to: %s", coordinationPlugin)
end

return missionManager
