-- modules/ui.lua

local mq = require('mq')
local imgui = mq.imgui
local missionManager = require('modules.mission_manager')

local ui = {
    currentMission = nil,
    paused = false,
    debugEnabled = true,
    debugInfo = "No debug info available.",
    currentStep = nil,
    nextStep = nil,
    showObjectives = false,
    objectivesStatus = {},
    missionStartTime = 0,
    showLogs = false,
    logs = {},
    missionSelections = { lguk = false, naggy = false, dguk = false },
    repeatMissions = false,
    driverSelection = nil, -- The name of the driver selected from group members
}

function ui.setCurrentMission(missionName)
    ui.currentMission = missionName
    if missionName then
        ui.missionStartTime = mq.gettime()
    else
        ui.missionStartTime = 0
    end
end

function ui.getCurrentMission()
    return ui.currentMission
end

function ui.setPaused(state)
    ui.paused = state
end

function ui.getPaused()
    return ui.paused
end

function ui.setDebugInfo(info)
    ui.debugInfo = info
    table.insert(ui.logs, os.date("%X") .. " - " .. info)
    if #ui.logs > 50 then
        table.remove(ui.logs, 1)
    end
end

function ui.setMissionSteps(current, nextStep)
    ui.currentStep = current
    ui.nextStep = nextStep
end

function ui.setObjectivesStatus(objectivesTable)
    ui.objectivesStatus = objectivesTable
end

local function renderMissionProgress()
    if ui.currentMission then
        local total = #ui.objectivesStatus
        local completed = 0
        for _, obj in ipairs(ui.objectivesStatus) do
            if obj.completed then
                completed = completed + 1
            end
        end
        local progress = total > 0 and (completed / total) or 0
        imgui.Text(string.format("Mission: %s", ui.currentMission))
        imgui.ProgressBar(progress, imgui.ImVec2(200, 20), string.format("%d/%d", completed, total))
        if ui.missionStartTime > 0 then
            local elapsed = mq.gettime() - ui.missionStartTime
            imgui.Text(string.format("Time Elapsed: %d sec", elapsed))
        end
        if ui.currentStep then
            imgui.Text(ui.currentStep)
        end
        if ui.nextStep then
            imgui.Text(ui.nextStep)
        end
    else
        imgui.Text("No mission selected.")
    end
end

function ui.renderObjectivesWindow()
    if not ui.showObjectives then return end
    if not imgui.Begin("Mission Objectives", true, 0) then
        imgui.End()
        return
    end
    imgui.Text("Objectives Status:")
    for _, obj in ipairs(ui.objectivesStatus) do
        local statusText = obj.completed and "Done" or "Not Done"
        local color = obj.completed and imgui.IM_COL32(0, 200, 0, 255) or imgui.IM_COL32(200, 0, 0, 255)
        imgui.PushStyleColor(imgui.ImGuiCol_Button, color)
        if imgui.Button(obj.label .. ": " .. statusText, 200, 0) then
            -- Optional: more detail on click.
        end
        imgui.PopStyleColor()
    end
    imgui.End()
end

function ui.renderLogsWindow()
    if not ui.showLogs then return end
    if not imgui.Begin("Mission Logs", true, 0) then
        imgui.End()
        return
    end
    for _, logEntry in ipairs(ui.logs) do
        imgui.TextWrapped(logEntry)
    end
    imgui.End()
end

-- Helper: Get a list of group member names.
local function getGroupMembers()
    local members = {}
    local count = mq.TLO.Group.Members() or 0
    for i = 0, count - 1 do
        local name = mq.TLO.Group.Member(i).Name()
        if name then
            table.insert(members, name)
        end
    end
    return members
end

function ui.renderUI()
    if not imgui.Begin("OMM Mission Manager", true, 0) then
        imgui.End()
        return
    end

    imgui.Text("Select a mission:")
    if imgui.BeginCombo("Mission", ui.currentMission or "") then
        local missionOptions = {"lguk", "naggy", "dguk"}
        for _, opt in ipairs(missionOptions) do
            if imgui.Selectable(opt, ui.currentMission == opt) then
                ui.setCurrentMission(opt)
            end
        end
        imgui.EndCombo()
    end

    imgui.Separator()
    if ui.currentMission then
        imgui.Text("Current Mission: " .. ui.currentMission)
        if imgui.Button("Start Mission", 100, 0) then
            mq.cmdf("/omm start %s", ui.currentMission)
        end
    end

    imgui.Separator()
    -- Driver selection dropdown
    imgui.Text("Select Driver:")
    local groupMembers = getGroupMembers()
    local currentDriver = missionManager.getDriverName()
    if imgui.BeginCombo("Driver", currentDriver or "None") then
        for _, name in ipairs(groupMembers) do
            if imgui.Selectable(name, currentDriver and (currentDriver:lower() == name:lower())) then
                missionManager.setDriverName(name)
            end
        end
        imgui.EndCombo()
    end

    imgui.Separator()
    imgui.Text("Mission Cycle Selection:")
    for key, value in pairs(ui.missionSelections) do
        local changed, selected = imgui.Checkbox(key, value)
        if changed then
            ui.missionSelections[key] = selected
        end
    end
    local changedRepeat, rep = imgui.Checkbox("Repeat Missions", ui.repeatMissions)
    if changedRepeat then
        ui.repeatMissions = rep
    end
    if imgui.Button("Start Mission Cycle", 150, 0) then
        local selectedMissions = {}
        for key, selected in pairs(ui.missionSelections) do
            if selected then
                table.insert(selectedMissions, key)
            end
        end
        if #selectedMissions > 0 then
            missionManager.runSelected(selectedMissions, ui.repeatMissions)
        else
            mq.cmd("/echo No missions selected for cycle.")
        end
    end

    imgui.Separator()
    renderMissionProgress()
    imgui.Separator()
    if imgui.Button("Toggle Objectives", 150, 0) then
        ui.showObjectives = not ui.showObjectives
    end
    if imgui.Button("Toggle Logs", 150, 0) then
        ui.showLogs = not ui.showLogs
    end

    imgui.Separator()
    if imgui.Button("Pause Mission", 100, 0) then
        ui.paused = not ui.paused
        if ui.paused then
            mq.cmd("/omm pause")
        else
            mq.cmd("/omm unpause")
        end
    end
    imgui.SameLine()
    if imgui.Button("Stop Mission", 100, 0) then
        mq.cmd("/omm stop")
    end

    imgui.Separator()
    imgui.Text("Status: " .. (ui.paused and "Paused" or "Running"))
    imgui.Text("Debug Info: " .. ui.debugInfo)
    if imgui.Button("Run Self Test", 150, 0) then
        mq.cmd("/omm selftest")
    end

    imgui.End()

    ui.renderObjectivesWindow()
    ui.renderLogsWindow()
end

return ui
