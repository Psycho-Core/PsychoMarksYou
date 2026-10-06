-- ============================================================================
-- Psycho Mark's You - Manual Marking Mode
-- ============================================================================

local PMY = PsychoMarksYou

function PMY.IsModifierHeld()
    local modKey = PMY.db and PMY.db.markKey or "ALT"
    local checkFn = PMY.MODIFIER_CHECK[modKey]
    if checkFn then return checkFn() end
    return IsAltKeyDown()
end

function PMY.HandleManualTarget()
    if PMY.IsMarkingProtected() then return end
    if not PMY.ShouldMark() then return end
    if PMY.db.markingMode ~= "manual" then return end
    if not PMY.IsModifierHeld() then return end

    if not PMY.IsValidMobToMark("target") then return end

    local guid = PMY.SafeUnitAPI(UnitGUID, "target")
    if not guid then return end

    if PMY.markedGUIDs[guid] then
        local cur = PMY.SafeUnitAPI(GetRaidTargetIndex, "target")
        if cur ~= PMY.markedGUIDs[guid] then
            PMY.SafeSetRaidTarget("target", PMY.markedGUIDs[guid])
        end
        return
    end

    local maxMarks = PMY.db.proximityMarks or 3
    if PMY.CountMarkedMobs() >= maxMarks then return end

    PMY.ScanPartyCC()
    PMY.MarkSingleUnit("target")
end
