-- modules/missions/naggy.lua

local mq = require('mq')
local combat = require('modules.combat')
local readiness = require('modules.readiness')
local navigation = require('modules.navigation')
local logger = require('utils.logger')
local missionManager = require('modules.mission_manager')
local ui = require('modules.ui')
local sync = require('modules.sync')

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
    logger.error("Objective '%s' failed after maximum attempts. Re-navigating...", step.label)
    navigation.navTo("naggy", step.label)
    mq.delay(2000)
end

function naggy.run()
    missionManager.setActive("naggy")
    ui.setCurrentMission("Nagafen's Lair")
    updateObjectivesStatus(1)

    local driverName = missionManager.getDriverName()  -- returns the designated driver's name
    local isDriver = mq.TLO.Me.Name():lower() == driverName:lower()
    logger.info("Driver check: Current toon is '%s'; Driver is '%s' → isDriver = %s",
        mq.TLO.Me.Name(), driverName, tostring(isDriver))

    for i, step in ipairs(objectives) do
        ui.setMissionSteps("Current: " .. step.label, (objectives[i+1] and "Next: " .. objectives[i+1].label or "None"))
        logger.info("Moving to objective: %s", step.label)
        combat.moveTo(step.label)
        
        local groupWaitTime = 0
        while not readiness.waitForGroup(10) do
            logger.warn("Group not ready near '%s'. Waiting...", step.label)
            mq.delay(5000)
            groupWaitTime = groupWaitTime + 5
            if groupWaitTime > 30 then
                logger.error("Group readiness timeout near '%s'. Attempting recovery...", step.label)
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
                combat.engage()  -- Full combat/heal/buff routine
            else
                logger.warn("Target '%s' not found (Attempt %d/%d)", step.target, attempts, maxAttempts)
            end
            if attempts >= maxAttempts then
                handleObjectiveError(step)
                break
            end
        until mq.TLO.Task("Ancient Heroes - Nagafen's Lair").Objective(step.objective).Status() == "Done"

        if mq.TLO.Task("Ancient Heroes - Nagafen's Lair").Objective(step.objective).Status() ~= "Done" then
            logger.error("Objective '%s' still incomplete. Skipping to next.", step.label)
        else
            logger.success("Objective '%s' completed.", step.label)
        end

        updateObjectivesStatus(i + 1)

        -- Synchronize: if driver, broadcast; if follower, wait.
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
    logger.info("All Nagafen's Lair objectives complete. Initiating auto-loot...")
    mq.cmd("/target me")
    mq.delay(500)
    mq.cmd("/autoloot")
end

return naggy
