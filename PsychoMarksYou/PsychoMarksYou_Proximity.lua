-- ============================================================================
-- Psycho Mark's You - Proximity Marking Mode
-- ============================================================================

local PMY = PsychoMarksYou

function PMY.StartProximityScanner()
    PMY.StopProximityScanner()
    if PMY.IsMarkingProtected() then
        PMY.Debug("Proximity scanner suppressed: client protects SetRaidTarget (use Mark Mob key)")
        return
    end
    if not PMY.db or PMY.db.markingMode ~= "proximity" then return end

    PMY.npTicker = C_Timer.NewTicker(0.35, function()
        PMY.ProximityScanTick()
    end)
    PMY.Debug("Proximity scanner started.")
end

function PMY.StopProximityScanner()
    if PMY.npTicker then
        PMY.npTicker:Cancel()
        PMY.npTicker = nil
        PMY.Debug("Proximity scanner stopped.")
    end
end

function PMY.ProximityScanTick()
    if not PMY.ShouldMark() then return end
    if PMY.db.markingMode ~= "proximity" then return end

    local inCombat = PMY.inCombat

    if inCombat and PMY.combatEntryCount == 0 then
        local anyInCombat = false
        for npUnit, _ in pairs(PMY.activeNameplates) do
            if PMY.SafeUnitAPI(UnitExists, npUnit) and PMY.IsActiveOnUnit(npUnit) then
                anyInCombat = true
                break
            end
        end
        if not anyInCombat then
            for i = 1, 40 do
                local u = "nameplate" .. i
                if PMY.SafeUnitAPI(UnitExists, u) and PMY.IsActiveOnUnit(u) then
                    anyInCombat = true
                    break
                end
            end
        end
        if anyInCombat then
            PMY.Debug("Proximity: active enemy nameplate arrived — running deferred combat cleanup")
            local toRemove = {}
            for guid, icon in pairs(PMY.markedGUIDs) do
                local unit = PMY.FindUnitByGUID(guid)
                if unit then
                    if not PMY.IsActiveOnUnit(unit) then
                        table.insert(toRemove, { guid = guid, unit = unit, icon = icon })
                    end
                else
                    table.insert(toRemove, { guid = guid, unit = nil, icon = icon })
                end
            end
            for _, info in ipairs(toRemove) do
                if info.unit then
                    PMY.SafeSetRaidTarget(info.unit, 0)
                end
                PMY.ReleaseGUID(info.guid)
                PMY.Debug("Deferred cleanup: cleared " .. PMY.GetIconText(info.icon)
                    .. " from non-combat mob (" .. info.guid .. ")")
            end
            PMY.combatMarkedGUIDs = {}
            for guid, _ in pairs(PMY.markedGUIDs) do
                PMY.combatMarkedGUIDs[guid] = true
                PMY.engagedGUIDs[guid] = true
                PMY.combatEntryCount = PMY.combatEntryCount + 1
            end
            PMY.Debug("Deferred cleanup complete: " .. PMY.combatEntryCount .. " marks kept.")
        end
    end

    if inCombat then
        for guid, _ in pairs(PMY.markedGUIDs) do
            if not PMY.engagedGUIDs[guid] then
                local u = PMY.FindUnitByGUID(guid)
                if u and PMY.IsActiveOnUnit(u) then
                    PMY.engagedGUIDs[guid] = true
                end
            end
        end
    end

    PMY.ScanPartyCC()

    local visibleGUIDs = {}
    local candidates = {}

    local function checkUnit(npUnit)
        if not PMY.IsValidMobToMark(npUnit) then return end
        local guid = PMY.SafeUnitAPI(UnitGUID, npUnit)
        if not guid then return end

        local mobActive = PMY.IsActiveOnUnit(npUnit)
        if inCombat and not mobActive then
            if PMY.markedGUIDs[guid] then
                PMY.SafeSetRaidTarget(npUnit, 0)
                PMY.ReleaseGUID(guid)
                PMY.Debug("Cleared mark on passive mob during combat: " .. (PMY.SafeUnitAPI(UnitName, npUnit) or guid))
            end
            return
        end

        visibleGUIDs[guid] = npUnit

        if PMY.markedGUIDs[guid] then
            if PMY.staleFadeTimers[guid] then
                PMY.staleFadeTimers[guid]:Cancel()
                PMY.staleFadeTimers[guid] = nil
                PMY.Debug("Cancelled fade timer for returned mob: " .. (PMY.guidToName[guid] or guid))
            end
            local currentIcon = PMY.SafeUnitAPI(GetRaidTargetIndex, npUnit)
            if currentIcon ~= PMY.markedGUIDs[guid] then
                PMY.SafeSetRaidTarget(npUnit, PMY.markedGUIDs[guid])
            end
            return
        end

        local existingIcon = PMY.SafeUnitAPI(GetRaidTargetIndex, npUnit)
        if existingIcon and existingIcon >= 1 and existingIcon <= 8 and not PMY.iconToGUID[existingIcon] then
            local uName = PMY.SafeUnitAPI(UnitName, npUnit)
            PMY.ReserveMark(existingIcon, guid, uName)
            return
        end

        local mob = PMY.ClassifyMob(npUnit)
        PMY.AutoLearnMob(mob)

        if not inCombat and PMY.ConsumeGraveyardEntry(mob.name, mob.creatureType) then
            return
        end

        PMY.ScoreMob(mob)
        if mob.score >= 0 then
            table.insert(candidates, mob)
        end
    end

    for npUnit, _ in pairs(PMY.activeNameplates) do
        if PMY.SafeUnitAPI(UnitExists, npUnit) then
            checkUnit(npUnit)
        else
            PMY.activeNameplates[npUnit] = nil
        end
    end

    for i = 1, 40 do
        local u = "nameplate" .. i
        if PMY.SafeUnitAPI(UnitExists, u) and not PMY.activeNameplates[u] then
            checkUnit(u)
        end
    end

    if PMY.SafeUnitAPI(UnitExists, "target") and PMY.IsValidMobToMark("target") then
        local tGuid = PMY.SafeUnitAPI(UnitGUID, "target")
        if tGuid and not visibleGUIDs[tGuid] then
            checkUnit("target")
        end
    end

    local now = GetTime()
    local STALE_GRACE_OOC    = 0.5
    local STALE_FADE_DELAY   = 2.0
    local STALE_GRACE_COMBAT = 2.5
    for guid, icon in pairs(PMY.markedGUIDs) do
        if not visibleGUIDs[guid] then
            local age = now - (PMY.markTimestamps[guid] or 0)
            if inCombat then
                local stillExists = PMY.FindUnitByGUID(guid)
                if not stillExists and age >= STALE_GRACE_COMBAT then
                    PMY.Debug("Stale mark released (in combat, gone): " .. (PMY.guidToName[guid] or guid) .. " was " .. PMY.GetIconText(icon))
                    PMY.ReleaseGUID(guid)
                end
            else
                if age >= STALE_GRACE_OOC and not PMY.staleFadeTimers[guid] then
                    local fadeGUID = guid
                    local fadeName = PMY.guidToName[guid] or guid
                    local fadeIcon = icon
                    PMY.Debug("Starting " .. STALE_FADE_DELAY .. "s fade timer for out-of-range mob: " .. fadeName .. " (" .. PMY.GetIconText(fadeIcon) .. ")")
                    PMY.staleFadeTimers[fadeGUID] = C_Timer.NewTimer(STALE_FADE_DELAY, function()
                        PMY.staleFadeTimers[fadeGUID] = nil
                        if PMY.markedGUIDs[fadeGUID] then
                            local u = PMY.FindUnitByGUID(fadeGUID)
                            if not u then
                                PMY.Debug("Fade timer expired — releasing mark on: " .. fadeName .. " (" .. PMY.GetIconText(fadeIcon) .. ")")
                                PMY.ReleaseGUID(fadeGUID)
                            end
                        end
                    end)
                end
            end
        end
    end

    if #candidates == 0 then return end

    table.sort(candidates, function(a, b) return a.score > b.score end)

    local maxMarks = PMY.db.proximityMarks or 3
    if inCombat and PMY.combatEntryCount > 0 and PMY.combatEntryCount < maxMarks then
        maxMarks = PMY.combatEntryCount
    end
    local currentCount = PMY.CountMarkedMobs()

    if inCombat and currentCount >= maxMarks then return end

    local newMarks = {}
    for _, mob in ipairs(candidates) do
        if inCombat then
            if currentCount >= maxMarks then break end
            local mark, role = PMY.AllocateMark(mob)
            if mark then
                if PMY.SafeSetRaidTarget(mob.unit, mark) then
                    PMY.ReserveMark(mark, mob.guid, mob.name)
                    mob.assignedMark = mark
                    mob.assignedRole = role
                    table.insert(PMY.packMobs, mob)
                    table.insert(newMarks, mob)
                    currentCount = currentCount + 1
                    PMY.Debug(string.format("Proximity [combat]: %s -> %s (%s) [score=%.0f]",
                        mob.name, PMY.GetIconText(mark), role or "", mob.score))
                end
            end
        else
            if currentCount < maxMarks then
                local mark, role = PMY.AllocateMark(mob)
                if mark then
                    if PMY.SafeSetRaidTarget(mob.unit, mark) then
                        PMY.ReserveMark(mark, mob.guid, mob.name)
                        mob.assignedMark = mark
                        mob.assignedRole = role
                        table.insert(PMY.packMobs, mob)
                        table.insert(newMarks, mob)
                        currentCount = currentCount + 1
                        PMY.Debug(string.format("Proximity: %s -> %s (%s) [score=%.0f]",
                            mob.name, PMY.GetIconText(mark), role or "", mob.score))
                    end
                end
            else
                local worstGUID, worstScore, worstIcon = nil, 999999, nil
                for mGuid, mIcon in pairs(PMY.markedGUIDs) do
                    local mUnit = visibleGUIDs[mGuid]
                    if mUnit then
                        local mMob = PMY.ClassifyMob(mUnit)
                        PMY.ScoreMob(mMob)
                        if mMob.score < worstScore then
                            worstScore = mMob.score
                            worstGUID  = mGuid
                            worstIcon  = mIcon
                        end
                    end
                end

                if worstGUID and (mob.score - worstScore) >= 50 then
                    local oldUnit = visibleGUIDs[worstGUID]
                    if oldUnit then
                        PMY.SafeSetRaidTarget(oldUnit, 0)
                    end
                    PMY.ReleaseGUID(worstGUID)

                    local mark, role = PMY.AllocateMark(mob)
                    if mark then
                        if PMY.SafeSetRaidTarget(mob.unit, mark) then
                            PMY.ReserveMark(mark, mob.guid, mob.name)
                            mob.assignedMark = mark
                            mob.assignedRole = role
                            table.insert(PMY.packMobs, mob)
                            table.insert(newMarks, mob)
                            PMY.Debug(string.format("Proximity upgrade: %s -> %s [score %.0f > %.0f]",
                                mob.name, PMY.GetIconText(mark), mob.score, worstScore))
                        end
                    end
                end
            end
        end
    end

    if #newMarks > 0 and PMY.db.announceParty and not PMY.combatAnnounced then
        if inCombat then
            PMY.AnnounceMarks()
            PMY.combatAnnounced = true
        end
    end
end
