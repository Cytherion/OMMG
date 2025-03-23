-- shroud.lua: Handles shroud logic and coordination for Old Man McKenzie missions

---@type mq
local mq = require('mq')
local logger = require('utils.logger')
local config = require('utils.config')

local shroud = {}

-- Class templates for shroud selection (using template IDs or indexes)
local classOptions = {
    10, -- SHM
    13, -- MAG
    11, -- NEC
    12, -- WIZ
    6   -- DRU
}

-- Determine which communication system is available
local function sendCommand(name, cmd)
    if mq.TLO.Plugin("DanNet").IsLoaded() and mq.TLO.DanNet(name).IsConnected() then
        mq.cmdf("/dexecute %s", cmd)
    elseif mq.TLO.Plugin("EQBC").IsLoaded() and mq.TLO.EQBC.Connected() then
        mq.cmdf("/bct %s //%s", name, cmd)
    else
        logger.warn("Unable to send command to %s: No comms available.", name)
    end
end

--- Initiate shroud selection for all group members.
function shroud.selectTemplates()
    local groupSize = mq.TLO.Group.Members()
    local isLeader = mq.TLO.Me.GroupLeader()
    if not isLeader then return end

    -- Open shroud window and select template on each toon
    for i = 1, groupSize do
        local member = mq.TLO.Group.Member(i - 1).Name()
        if member and member ~= mq.TLO.Me.Name() then
            local template = classOptions[i] or classOptions[1]
            sendCommand(member, string.format(
                [[/notify TaskTemplateSelectWnd TaskTemplateSelectListOptional listselect %d; /delay 5; /notify TaskTemplateSelectWnd TaskTemplateSelectAcceptButton leftmouseup]],
                template
            ))
        else
            -- Self selection
            local template = classOptions[i] or classOptions[1]
            mq.cmdf("/notify TaskTemplateSelectWnd TaskTemplateSelectListOptional listselect %d", template)
            mq.delay(500)
            mq.cmd("/notify TaskTemplateSelectWnd TaskTemplateSelectAcceptButton leftmouseup")
        end
    end
end

return shroud
