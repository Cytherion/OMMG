-- modules/healing.lua
local mq = require('mq')
local logger = require('utils.logger')

local healing = {}

-- Auto-buff routine: casts buffs based on class
function healing.autoBuff()
    local myClass = mq.TLO.Me.Class.ShortName()
    if myClass == "DRU" then
        if mq.TLO.Me.AltAbilityReady("Pack Chloroplast")() then
            mq.cmd("/alt act " .. mq.TLO.Me.AltAbility("Pack Chloroplast").ID())
            logger.info("Casting Pack Chloroplast")
            mq.delay(1000)
        end
        if mq.TLO.Me.AltAbilityReady("Pack Spirit")() then
            mq.cmd("/alt act " .. mq.TLO.Me.AltAbility("Pack Spirit").ID())
            logger.info("Casting Pack Spirit")
            mq.delay(1000)
        end
    elseif myClass == "SHM" then
        if mq.TLO.Me.AltAbilityReady("Talisman of Altuna")() then
            mq.cmd("/alt act " .. mq.TLO.Me.AltAbility("Talisman of Altuna").ID())
            logger.info("Casting Talisman of Altuna")
            mq.delay(1000)
        end
    end
    -- Add additional class-specific buffs as needed.
end

-- Auto-heal group members below a certain HP percentage.
function healing.autoHealGroup(minHP)
    for i = 0, mq.TLO.Group.Members() - 1 do
        local member = mq.TLO.Group.Member(i)
        if member() then
            local hpPct = member.PctHPs()
            if hpPct and hpPct < minHP then
                if mq.TLO.Me.AltAbilityReady("Greater Healing")() then
                    mq.cmdf("/alt act " .. mq.TLO.Me.AltAbility("Greater Healing").ID())
                    logger.info("Casting Greater Healing on %s (HP: %d%%)", member.Name(), hpPct)
                    mq.delay(1500)
                end
            end
        end
    end
end

-- Auto-heal pet if its HP is below threshold.
function healing.autoHealPet(minHP)
    if mq.TLO.Me.Pet.ID() > 0 then
        local petHP = mq.TLO.Me.Pet.PctHPs()
        if petHP and petHP < minHP then
            if mq.TLO.Me.AltAbilityReady("Invoke Death")() then  -- Example ability; adjust per class\n
                mq.cmd("/alt act " .. mq.TLO.Me.AltAbility("Invoke Death").ID())
                logger.info("Casting pet heal (Invoke Death) on pet (HP: %d%%)", petHP)
                mq.delay(1500)
            end
        end
    end
end

return healing
