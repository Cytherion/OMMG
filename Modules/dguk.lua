-- modules/missions/dguk.lua

local mq = require('mq')
local combat = require('modules.combat')
local readiness = require('modules.readiness')
local navigation = require('modules.navigation')
local logger = require('utils.logger')
local missionManager = require('modules.mission_manager')
local ui = require('modules.ui')
local sync = require('modules.sync')

local dguk = {}

local objectives = {
    { label = "dguk_ritualist",    objective = 12, target = "ritualist" },
    { label = "dguk_asssup",       objective = 3,  target = "supplier" },
    { label = "dguk_savant",       objective = 6,  target = "savant" },
    { label = "dguk_sage_scribe",  objective = 5,  target = "sage" },
    { label = "dguk_executioner",  objective = 9,  target = "executioner" },
    { label = "dguk_cavalier",     objective = 11, target = "cavalier" },
    { label = "dguk_frenzy",       objective = 13, target = "frenzied" },
    { label = "dguk_sentinel",     objective = 10, target = "sentinel" },
    { label = "dguk_hand",         objective = 2,  target = "hand" },
    { label = "dguk_magus",        objective = 4,  target = "magus" },
    { label = "dguk_lord",         objective = 14, target = "lord" },
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
    navigation.navTo("dguk", step.label)
    mq.delay(2000)
end

function dguk.run()
    missionManager.setActive("dguk")
    ui.setCurrentMission("Cursed Guk")
    updateObjectivesStatus(1)
    
    local driverName = missionManager.getDriverName()
    local isDriver = mq.TLO.Me.Name():lower() == driverName:lower()
    logger.info("Driver check: Current toon '%s'; Driver '%s'; isDriver = %s",
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
                combat.engage()
            else
                logger.warn("Target '%s' not found. Attempt %d/%d", step.target, attempts, maxAttempts)
            end
            if attempts >= maxAttempts then
                handleObjectiveError(step)
                break
            end
        until mq.TLO.Task("Ancient Heroes - Cursed Guk").Objective(step.objective).Status() == "Done"
        
        if mq.TLO.Task("Ancient Heroes - Cursed Guk").Objective(step.objective).Status() ~= "Done" then
            logger.error("Objective '%s' still not complete. Skipping.", step.label)
        else
            logger.success("Objective '%s' complete.", step.label)
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
    logger.info("All Cursed Guk objectives complete. Looting chest...")
    mq.cmd("/target me")
    mq.delay(500)
    mq.cmd("/autoloot")
end

return dguk
