-- init.lua: Entry point for the OMM Missions plugin

local mq = require('mq')
local missionManager = require('modules.mission_manager')
local ui = require('modules.ui')
local logger = require('utils.logger')

local lguk = require('modules.missions.lguk')
local naggy = require('modules.missions.naggy')
local dguk  = require('modules.missions.dguk')

-- Bind self-test command
mq.bind("/omm selftest", function()
    local required = {"MQ2Nav", missionManager.getCoordinationPlugin()}
    local missing = {}
    for _, plugin in ipairs(required) do
        if not mq.TLO.Plugin(plugin).Name() then
            table.insert(missing, plugin)
        end
    end
    if #missing > 0 then
        local err = "Self Test Failed. Missing plugins: " .. table.concat(missing, ", ")
        mq.cmdf("/echo %s", err)
        logger.error(err)
    else
        mq.cmd("/echo Self Test Passed. All required plugins are loaded.")
        logger.info("Self Test Passed.")
    end
end)

local running = true

local function renderMainUI()
    ui.renderUI()
end

mq.imgui.init("OMMMissions", renderMainUI)

mq.event("Shutdown", "You have been disconnected", function()
    running = false
end)

while running do
    mq.delay(1000)
end
