-- modules/missions/lguk.lua

local mq = require('mq')
local combat = require('modules.combat')
local readiness = require('modules.readiness')
local navigation = require('modules.navigation')
local logger = require('utils.logger')
local missionManager = require('modules.mission_manager')
local ui = require('modules.ui')
local sync = require('modules.sync')

local lguk = {}

local objectives = {
    { label = "lguk_patriarch",  objective = 4,  target = "patriarch" },
    { label = "lguk_elder",      objective = 5,  target = "elder" },
    { label = "lguk_eye",        objective = 2,  target = "evil eye" },
    { label = "lguk_priest",     objective = 7,  target = "yun priest" },
    { label = "lguk_crusader",   objective = 3,  target = "crusader" },
    { label = "lguk_noble",      objective = 6,  target = "noble" },
    { label = "lguk_herbalist",  objective = 9,  target = "herbalist" },
    { label = "lguk_king",       objective = 10, target = "king" },
    { label = "lguk_tactician",  objective = 8,  target = "tactician" },
}

local function updateObjectivesStatus(completedIndex)
    local statusTable = {}
    for i, step in ipairs(objectives) do
        table.insert(statusTable, { label = step.label, completed = (i < completedIndex) })
    end
    ui.setObjectivesStatus(statusTable)
end

local function handleObjectiveError(step)
    logger.error("Failed to complete objective: %s after multiple attempts. Attempting recovery...", step.label)
    navigation.navTo("lguk", step.label)
    mq.delay(2000)
end

function lguk.run()
    missionManager.setActive("lguk")
    ui.setCurrentMission("Lower Guk")
    updateObjectivesStatus(1)
    
    local driverName = missionManager.getDriverName()
    local isDriver = mq.TLO.Me.Name():lower() == driverName:lower()
    logger.info("Driver check: current toon %s; driver is %s; isDriver = %s", mq.TLO.Me.Name(), driverName, tostring(isDriver))
    
    for i, step in ipairs(objectives) do
        ui.setMissionSteps("Current: " .. step.label, (objectives[i+1] and "Next: " .. objectives[i+1].label or "None"))
        logger.info("Moving to %s", step.label)
        combat.moveTo(step.label)
        
        local groupWaitTime = 0
        while not readiness.waitForGroup(10) do
            logger.warn("Group not ready near: %s, waiting...", step.label)
            mq.delay(5000)
            groupWaitTime = groupWaitTime + 5
            if groupWaitTime > 30 then
                logger.error("Group readiness timeout near %s. Attempting recovery.", step.label)
                break
            end
        end
        
        local attempts = 0
        local maxAttempts = 10
        repeat
            attempts = attempts + 1
            local targetID = mq.TLO.Spawn("npc " .. step.target).ID() or 0
            if targetID > 0 then
                mq.cmdf("/target id %d", targetID)
                mq.delay(500, function() return mq.TLO.Target.ID() == targetID end)
                combat.engage()
            else
                logger.warn("Target %s not found. Attempt %d/%d", step.target, attempts, maxAttempts)
            end
            if attempts >= maxAttempts then
                handleObjectiveError(step)
                break
            end
        until mq.TLO.Task("Ancient Heroes - Lower Guk").Objective(step.objective).Status() == "Done"
        
        if mq.TLO.Task("Ancient Heroes - Lower Guk").Objective(step.objective).Status() ~= "Done" then
            logger.error("Objective %s still not complete. Skipping.", step.label)
        else
            logger.success("Objective complete: %s", step.label)
        end
        
        updateObjectivesStatus(i + 1)
        
        if isDriver then
            sync.broadcastStep(i)
        else
            if not sync.waitForStep(i, 30000) then
                logger.error("Sync timeout waiting for objective %d", i)
            end
        end
        
        mq.cmd("/stand")
        mq.delay(2000)
    end

    missionManager.clearActive()
    ui.setCurrentMission(nil)
    ui.setMissionSteps("None", "None")
    logger.info("All Lower Guk objectives complete. Looting chest...")
    mq.cmd("/target me")
    mq.delay(500)
    mq.cmd("/autoloot")
end

return lguk
