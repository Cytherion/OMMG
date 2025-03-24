-- init.lua: Entry point for the OMM Missions plugin

local mq = require('mq')
local missionManager = require('modules.mission_manager')
local ui = require('modules.ui')
local logger = require('utils.logger')

local lguk = require('modules.missions.lguk')
local naggy = require('modules.missions.naggy')
local dguk  = require('modules.missions.dguk')
local follower = require('modules.follower')

-- Determine if this toon is the driver using the stored driver name.
local driverName = missionManager.getDriverName()
local isDriver = mq.TLO.Me.Name():lower() == driverName:lower()

if isDriver then
    logger.info("Running in DRIVER mode. Driver: %s", driverName)
else
    logger.info("Running in FOLLOWER mode. Following driver: %s", driverName)
end

local running = true

if isDriver then
    local function renderMainUI()
        ui.renderUI()
    end
    mq.imgui.init("OMMMissions", renderMainUI)
    mq.event("Shutdown", "You have been disconnected", function() running = false end)
    while running do
        mq.delay(1000)
    end
else
    follower.run()
end
