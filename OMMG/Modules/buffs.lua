-- modules/buffs.lua: Handles buffing and pet preparation routines for Old Man McKenzie missions

---@type mq
local mq = require('mq')
local logger = require('utils.logger')

local buffs = {}

local function castAA(spell)
    if mq.TLO.Me.AltAbilityReady(spell)() then
        mq.cmdf("/alt act %d", mq.TLO.Me.AltAbility(spell).ID())
        mq.delay(1000, function() return not mq.TLO.Me.Casting.ID() end)
    else
        logger.debug("AA %s not ready", spell)
    end
end

local function castBuff(spell, targetId)
    if mq.TLO.Me.AltAbilityReady(spell)() and mq.TLO.Spawn(string.format("id %d", targetId)).Distance3D() < 100 then
        mq.cmdf("/target id %d", targetId)
        mq.delay(500, function() return mq.TLO.Target.ID() == targetId end)
        castAA(spell)
    end
end

--- Buff up based on class
function buffs.buff()
    local class = mq.TLO.Me.Class.ShortName()
    logger.info("Buffing for class: %s", class)

    if class == 'DRU' then
        castAA("Pack Chloroplast")
        castAA("Pack Spirit")
        castAA("Skin Like Nature")
    elseif class == 'ENC' then
        castAA("Group Resist Magic")
        castAA("Clarity")
    elseif class == 'SHM' then
        castAA("Talisman of Altuna")
        buffs.makePet("Frenzied Spirit")
    elseif class == 'NEC' then
        castAA("Lich")
        buffs.makePet("Invoke Death")
        castAA("Dead Man Floating")
    elseif class == 'MAG' then
        buffs.makePet("Greater Conjuration: Earth")
        buffs.petBuff("Shield of Lava")
    end
end

--- Summon pet based on class and spell
function buffs.makePet(spellName)
    if mq.TLO.Pet.ID() == 0 and mq.TLO.Me.AltAbilityReady(spellName)() then
        castAA(spellName)
    end
end

--- Buff pets in group with a specified buff
function buffs.petBuff(buffName)
    for i = 0, mq.TLO.Group.Members() - 1 do
        local petId = mq.TLO.Group.Member(i).Pet.ID()
        if petId and petId > 0 then
            local hasBuff = mq.TLO.Spawn(string.format("id %d", petId)).Buff(buffName)()
            if not hasBuff then
                castBuff(buffName, petId)
            end
        end
    end
end

return buffs