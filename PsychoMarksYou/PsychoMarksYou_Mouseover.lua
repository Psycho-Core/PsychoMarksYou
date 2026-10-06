-- ============================================================================
-- Psycho Mark's You - Mouseover Marking Mode
-- ============================================================================

local PMY = PsychoMarksYou

function PMY.HandleMouseover()
    -- Always update tooltip advisor if enabled
    PMY.UpdateTooltipWithMobInfo()

    if PMY.IsMarkingProtected() then return end
    if not PMY.ShouldMark() then return end
    if PMY.db.markingMode ~= "mouseover" then return end

    if not PMY.IsValidMobToMark("mouseover") then return end

    local guid = PMY.SafeUnitAPI(UnitGUID, "mouseover")
    if not guid then return end

    if PMY.markedGUIDs[guid] then
        local cur = PMY.SafeUnitAPI(GetRaidTargetIndex, "mouseover")
        if cur ~= PMY.markedGUIDs[guid] then
            PMY.SafeSetRaidTarget("mouseover", PMY.markedGUIDs[guid])
        end
        return
    end

    if PMY.inCombat then return end

    local mName = PMY.SafeUnitAPI(UnitName, "mouseover")
    local mType = PMY.SafeUnitAPI(UnitCreatureType, "mouseover")
    if PMY.ConsumeGraveyardEntry(mName, mType) then return end

    local maxMarks = PMY.db.proximityMarks or 3
    if PMY.CountMarkedMobs() >= maxMarks then return end

    PMY.ScanPartyCC()
    PMY.MarkSingleUnit("mouseover")
end
