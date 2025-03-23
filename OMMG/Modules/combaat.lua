-- modules/combat.lua

local mq = require('mq')
local logger = require('utils.logger')
local ui = require('modules.ui')

local combat = {}

-- Wait until the UI's pause flag is false
local function waitIfPaused()
    while ui.getPaused() do
        logger.info("Combat paused, waiting...")
        mq.delay(1000)
    end
end

local function isTargetValid()
    return mq.TLO.Target.ID() > 0 and mq.TLO.Target.Type() == "NPC"
end

function combat.engage()
    waitIfPaused()
    if not isTargetValid() then
        logger.warn("No valid target to engage.")
        return
    end

    local class = mq.TLO.Me.Class.ShortName()
    
    if class == "ENC" then
        -- Mezzing logic for enchanters
        if mq.TLO.SpawnCount("npc radius 40")() > 3 and not mq.TLO.Me.Silenced() then
            if mq.TLO.Me.AltAbilityReady("Mesmerization")() then
                mq.cmd("/alt act " .. mq.TLO.Me.AltAbility("Mesmerization").ID())
                mq.delay(2000)
            end
        end
    elseif class == "NEC" then
        -- Necro: use Splurt if target not already buffed, then Drain Soul
        if isTargetValid() and not mq.TLO.Target.Buff("Splurt")() then
            if mq.TLO.Me.AltAbilityReady("Splurt")() then
                mq.cmd("/alt act " .. mq.TLO.Me.AltAbility("Splurt").ID())
                mq.delay(1500)
            end
        end
        if mq.TLO.Me.AltAbilityReady("Drain Soul")() then
            mq.cmd("/alt act " .. mq.TLO.Me.AltAbility("Drain Soul").ID())
            mq.delay(1500)
        end
    elseif class == "MAG" then
        if mq.TLO.Me.AltAbilityReady("Shock of Swords")() then
            mq.cmd("/alt act " .. mq.TLO.Me.AltAbility("Shock of Swords").ID())
            mq.delay(1500)
        end
    elseif class == "WIZ" then
        if mq.TLO.Me.AltAbilityReady("Ice Comet")() then
            mq.cmd("/alt act " .. mq.TLO.Me.AltAbility("Ice Comet").ID())
            mq.delay(1500)
        end
    elseif class == "SHM" then
        if mq.TLO.Me.AltAbilityReady("Blizzard Blast")() then
            mq.cmd("/alt act " .. mq.TLO.Me.AltAbility("Blizzard Blast").ID())
            mq.delay(1500)
        end
    elseif class == "DRU" then
        if mq.TLO.Me.AltAbilityReady("Ice")() then
            mq.cmd("/alt act " .. mq.TLO.Me.AltAbility("Ice").ID())
            mq.delay(1500)
        end
    end

    -- Pet attack logic
    if mq.TLO.Me.Pet.ID() > 0 and mq.TLO.Target.ID() ~= mq.TLO.Me.Pet.Target.ID() then
        mq.cmd("/pet attack")
        mq.delay(250)
    end
end

-- Loot handling routine to target self and autoloot chest
function combat.lootChest()
    logger.info("Initiating loot routine...")
    mq.cmd("/target me")
    mq.delay(500)
    mq.cmd("/autoloot")
end

return combat
