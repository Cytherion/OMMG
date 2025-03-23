-- modules/roles.lua

---@type mq
local mq = require('mq')

local M = {}

---Returns true if the current character is the group leader
---@return boolean
function M.isGroupLeader()
    return mq.TLO.Me.GroupLeader() or false
end

---Returns the name of the group leader
---@return string
function M.getGroupLeader()
    return mq.TLO.Group.Leader.Name() or ''
end

---Returns the number of group members (excluding mercs)
---@return integer
function M.getGroupSize()
    return mq.TLO.Group.Members() or 0
end

---Checks if the group has any mercenaries
---@return boolean
function M.hasMercenaries()
    return mq.TLO.Group.MercenaryCount() > 0
end

---Get a list of group member names
---@return string[]
function M.getGroupMembers()
    local members = {}
    for i = 1, M.getGroupSize() do
        local name = mq.TLO.Group.Member(i).Name()
        if name then
            table.insert(members, name)
        end
    end
    return members
end

return M