-- modules/task_manager.lua
local mq = require('mq')
local log = require('utils.logger')

local M = {}

local tasks = {
    naggy = {
        id = 8201,
        name = "Ancient Heroes - Nagafen's Lair",
        steps = {
            {name = "Kobold Noble", keyword = "noble"},
            {name = "King", keyword = "king"},
            {name = "Priest", keyword = "priest"},
            {name = "Champion", keyword = "champion"},
            {name = "Guano Bat", keyword = "guano"},
            {name = "Noxious Spider", keyword = "noxious"},
            {name = "Stone Spider", keyword = "stone"},
            {name = "Death Beetle", keyword = "death"},
            {name = "Djarn", keyword = "djarn"},
        },
    },
    dguk = {
        id = 8203,
        name = "Ancient Heroes - Cursed Guk",
        steps = {},
    },
    lguk = {
        id = 8204,
        name = "Ancient Heroes - Lower Guk",
        steps = {},
    },
}

M.selectedTask = nil

function M.select_task(name)
    local task = tasks[name:lower()]
    if not task then
        log.warn("Invalid task: %s", name)
        return false
    end
    M.selectedTask = task
    log.info("Selected task: %s", task.name)
    return true
end

function M.has_task()
    if not M.selectedTask then return false end
    return mq.TLO.Task(M.selectedTask.name).ID() == M.selectedTask.id
end

function M.get_current_step_status(index)
    if not M.selectedTask or not M.selectedTask.steps[index] then return nil end
    return mq.TLO.Task(M.selectedTask.name).Objective(index + 1).Status()
end

return M
