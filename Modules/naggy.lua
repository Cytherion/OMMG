-- modules/missions/naggy.lua

local mq = require('mq')
local combat = require('modules.combat')
local readiness = require('modules.readiness')
local navigation = require('modules.navigation')
local logger = require('utils.logger')
local missionManager = require('modules.mission_manager')
local ui = require('modules.ui')

local naggy = {}

local objectives = {
    { label = "naggy_noble",       objective = 4,  target = "noble" },
    { label = "naggy_king",        objective = 7,  target = "king" },
    { label = "naggy_priest",      objective = 5,  target = "priest" },
    { label = "naggy_champion",    objective = 6,  target = "champion" },
    { label = "naggy_guano",       objective = 2,  target = "guano" },
    { label = "naggy_noxious",     objective = 8,  target = "noxious" },
    { label = "naggy_stone",       objective = 9,  target = "stone" },
    { label = "naggy_deathbeetle", objective = 3,  target = "death beetle" },
    { label = "naggy_djarn",       objective = 10, target = "djarn" },
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
    navigation.navTo("naggy", step.label)
    mq.delay(2000)
end

function naggy.run()
    missionManager.setActive("naggy")
    ui.setCurrentMission("Nagafen's Lair")
    updateObjectivesStatus(1)
    
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
        until mq.TLO.Task("Ancient Heroes - Nagafen's Lair").Objective(step.objective).Status() == "Done"
        
        if mq.TLO.Task("Ancient Heroes - Nagafen's Lair").Objective(step.objective).Status() ~= "Done" then
            logger.error("Objective %s still not complete. Skipping to next objective.", step.label)
        else
            logger.success("Objective complete: %s", step.label)
        end
        
        updateObjectivesStatus(i + 1)
        mq.cmd("/stand")
        mq.delay(2000)
    end
    
    missionManager.clearActive()
    ui.setCurrentMission(nil)
    ui.setMissionSteps("None", "None")
    logger.info("All Nagafen's Lair objectives complete. Looting chest...")
    mq.cmd("/target me")
    mq.delay(500)
    mq.cmd("/autoloot")
end

return naggy
