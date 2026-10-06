-- ============================================================================
-- Psycho Mark's You - Mob Classification, Scoring & Mark Allocation
-- ============================================================================

local PMY = PsychoMarksYou

function PMY.CleanupGraveyard()
    local now = GetTime()
    local i = 1
    while i <= #PMY.graveyardList do
        if now >= PMY.graveyardList[i].expire then
            table.remove(PMY.graveyardList, i)
        else
            i = i + 1
        end
    end
end

function PMY.AddToGraveyard(name, ctype)
    if not name or name == "" then return end
    PMY.CleanupGraveyard()
    table.insert(PMY.graveyardList, {
        name   = name,
        ctype  = ctype or "",
        expire = GetTime() + PMY.GRAVEYARD_COOLDOWN,
    })
    PMY.Debug("Graveyard add: " .. name .. " (" .. tostring(ctype) .. ") — count now " .. #PMY.graveyardList)
end

function PMY.ConsumeGraveyardEntry(name, ctype)
    if not name then return false end
    PMY.CleanupGraveyard()
    for i, entry in ipairs(PMY.graveyardList) do
        if entry.name == name and (entry.ctype == "" or not ctype or entry.ctype == ctype) then
            table.remove(PMY.graveyardList, i)
            PMY.Debug("Graveyard consumed: " .. name .. " — remaining " .. #PMY.graveyardList)
            return true
        end
    end
    return false
end

function PMY.IsValidMobToMark(unit)
    if not PMY.SafeUnitAPI(UnitExists, unit) then return false end
    if PMY.SafeUnitAPI(UnitIsDead, unit) then return false end
    if PMY.SafeUnitAPI(UnitIsPlayer, unit) then return false end
    if PMY.SafeUnitAPI(UnitIsFriend, "player", unit) then return false end
    if not PMY.SafeUnitAPI(UnitCanAttack, "player", unit) then return false end

    local ctype = PMY.SafeUnitAPI(UnitCreatureType, unit)
    if ctype == "Critter" or ctype == "Non-combat Pet" or ctype == "Totem" then
        return false
    end

    if PMY.SafeUnitAPI(UnitIsUnit, unit, "pet") then return false end
    for i = 1, 4 do
        if PMY.SafeUnitAPI(UnitIsUnit, unit, "partypet" .. i) then return false end
    end

    return true
end

function PMY.ClassifyMob(unit)
    local name          = PMY.SafeUnitAPI(UnitName, unit) or "Unknown"
    local guid          = PMY.SafeUnitAPI(UnitGUID, unit)
    local level         = PMY.SafeUnitAPI(UnitLevel, unit) or 0
    local classif       = PMY.SafeUnitAPI(UnitClassification, unit) or "normal"
    local creatureType  = PMY.SafeUnitAPI(UnitCreatureType, unit) or "Unknown"
    local powerType     = PMY.SafeUnitAPI(UnitPowerType, unit)
    local maxMana       = (powerType == 0) and (PMY.SafeUnitAPI(UnitPowerMax, unit, 0) or 0) or 0
    local hasMana       = (powerType == 0 and maxMana > 0)
    local isBoss        = (classif == "worldboss" or classif == "rareelite" or level == -1)
    local isElite       = (classif == "elite" or classif == "rareelite" or classif == "worldboss")
    local maxHP         = PMY.SafeUnitAPI(UnitHealthMax, unit) or 1
    local curHP         = PMY.SafeUnitAPI(UnitHealth, unit) or 1
    local inCombat      = PMY.SafeUnitAPI(UnitAffectingCombat, unit) or false
    local existingMark  = PMY.SafeUnitAPI(GetRaidTargetIndex, unit)

    local isCasting = false
    if UnitCastingInfo then
        local castName = PMY.SafeUnitAPI(UnitCastingInfo, unit)
        if castName then isCasting = true end
    end
    if not isCasting and UnitChannelInfo then
        local chanName = PMY.SafeUnitAPI(UnitChannelInfo, unit)
        if chanName then isCasting = true end
    end

    local dbEntry        = PMY.GetMobDBEntry(name)
    local dbMark         = PMY.GetEntryMark(dbEntry)
    local dbCreatureType = PMY.GetEntryCreatureType(dbEntry)
    local dbCCImmune     = PMY.GetEntryCCImmune(dbEntry)
    local dbDanger       = PMY.GetEntryDangerLevel(dbEntry)
    local dbNote         = PMY.GetEntryNote(dbEntry)

    return {
        unit           = unit,
        name           = name,
        guid           = guid,
        level          = level,
        classification = classif,
        creatureType   = creatureType,
        hasMana        = hasMana,
        maxMana        = maxMana,
        isBoss         = isBoss,
        isElite        = isElite,
        isCasting      = isCasting,
        maxHP          = maxHP,
        curHP          = curHP,
        inCombat       = inCombat,
        existingMark   = existingMark,
        dbPriority     = dbMark,
        dbCreatureType = dbCreatureType,
        dbCCImmune     = dbCCImmune,
        dbDanger       = dbDanger,
        dbNote         = dbNote,
        score          = 0,
        assignedMark   = nil,
        assignedRole   = nil,
    }
end

function PMY.AutoLearnMob(mob)
    if not mob or not mob.name or mob.name == "Unknown" then return end
    if not PMY.db then return end
    if not PMY.inInstance then return end
    if PMY.GetMobDBEntry(mob.name) ~= nil then return end

    local zone = PMY.currentZone
    if not zone or zone == "" then return end

    if not PMY.db.customMobs[zone] then
        PMY.db.customMobs[zone] = {}
    end

    if mob.classification == "minus" or mob.classification == "trivial" then
        PMY.db.customMobs[zone][mob.name] = "SKIP"
        mob.dbPriority = "SKIP"
        PMY.Debug("Auto-learned in [" .. zone .. "]: " .. mob.name .. " -> SKIP (trivial/minus)")
        return
    end

    local mark
    local danger
    if mob.isBoss then
        mark = 8
        danger = 2
    elseif mob.isCasting then
        mark = 8
        danger = 3
    elseif mob.hasMana and mob.isElite then
        mark = 8
        danger = 2
    elseif mob.hasMana then
        mark = 8
        danger = 2
    elseif mob.isElite then
        mark = 5
        danger = 1
    else
        mark = 5
        danger = 1
    end

    local ctype = (mob.creatureType and mob.creatureType ~= "Unknown") and mob.creatureType or nil
    local ccImm = mob.isBoss or nil

    PMY.db.customMobs[zone][mob.name] = {
        mark         = mark,
        creatureType = ctype,
        ccImmune     = ccImm,
        dangerLevel  = danger,
    }

    mob.dbPriority     = mark
    mob.dbCreatureType = ctype
    mob.dbCCImmune     = ccImm or false
    mob.dbDanger       = danger

    local ctypeStr = ctype and (" [" .. ctype .. "]") or ""
    local immStr   = ccImm and " (CC Immune)" or ""
    PMY.Debug("Auto-learned in [" .. zone .. "]: " .. mob.name .. " -> " .. PMY.GetIconText(mark) .. " D:" .. danger .. ctypeStr .. immStr)
end

function PMY.PromoteMobOnCast(unit)
    if not PMY.db or not PMY.inInstance then return end
    local name = PMY.SafeUnitAPI(UnitName, unit)
    if not name or name == "Unknown" then return end

    local zone = PMY.currentZone
    if not zone or zone == "" then return end

    if PsychoMarksYou_DefaultMobs and PsychoMarksYou_DefaultMobs[zone]
       and PsychoMarksYou_DefaultMobs[zone][name] ~= nil then
        return
    end

    local custom = PMY.db.customMobs and PMY.db.customMobs[zone] and PMY.db.customMobs[zone][name]
    if not custom or type(custom) ~= "table" then return end

    local changed = false
    if custom.mark ~= 8 then
        custom.mark = 8
        changed = true
    end
    if not custom.dangerLevel or custom.dangerLevel < 2 then
        custom.dangerLevel = 2
        changed = true
    end
    if changed then
        PMY.Debug("Promoted [" .. name .. "] in [" .. zone .. "] to Skull D:" .. custom.dangerLevel .. " (observed casting)")
    end
end

function PMY.GetEffectiveDanger(mob)
    local danger = mob.dbDanger
    if not danger then
        local pref = mob.dbPriority
        if pref == 8 or pref == 7 then
            danger = 2
        else
            danger = 1
        end
    end

    if mob.isCasting and danger < 3 then
        danger = math.min(danger + 1, 3)
    end

    return danger
end

function PMY.GetEffectiveCreatureType(mob)
    if mob.creatureType and mob.creatureType ~= "Unknown" then
        return mob.creatureType
    end
    return mob.dbCreatureType or "Unknown"
end

function PMY.ScoreMob(mob)
    if mob.dbPriority == "SKIP" then
        mob.score = -1
        return
    end

    local score = 0
    local preferred = mob.dbPriority
    local danger = PMY.GetEffectiveDanger(mob)

    if preferred and type(preferred) == "number" then
        if preferred == 8 or preferred == 7 then
            score = 1000 + (danger * 100)
        elseif preferred >= 1 and preferred <= 6 then
            score = 500 + (danger * 100)
        end
    else
        if mob.isBoss then
            score = 900
        elseif mob.isCasting then
            score = 850
        elseif mob.hasMana and mob.isElite then
            score = 800
        elseif mob.hasMana then
            score = 700
        elseif mob.isElite then
            score = 600
        else
            score = 400
        end
    end

    if mob.isCasting then score = score + 60 end
    if mob.hasMana then score = score + 40 end
    if mob.isElite then score = score + 25 end
    if mob.isBoss  then score = score + 50 end
    if mob.level and mob.level > 0 then
        score = score + (mob.level * 0.3)
    elseif mob.level == -1 then
        score = score + 30
    end
    if mob.maxHP and mob.maxHP > 0 then
        score = score + math.min(mob.maxHP / 10000, 10)
    end

    mob.score = score
end

function PMY.IsMobSuitableForCC(mob)
    if mob.isBoss then return false end
    if mob.dbCCImmune then return false end
    local danger = PMY.GetEffectiveDanger(mob)
    if danger >= 3 then return false end
    return true
end

function PMY.AllocateMark(mob)
    if mob.dbPriority == "SKIP" or mob.score < 0 then
        return nil, nil
    end

    local preferred      = mob.dbPriority
    local effectiveCtype = PMY.GetEffectiveCreatureType(mob)
    local ccImmune       = mob.dbCCImmune or mob.isBoss
    local isHeroic       = PMY.IsHeroicDifficulty()

    if isHeroic and PMY.IsMobSuitableForCC(mob) and preferred ~= 8 then
        local ccMark, ccEntry = PMY.FindCCMark(effectiveCtype, ccImmune, mob.guid)
        if ccMark then
            return ccMark, ccEntry.spell .. " (" .. ccEntry.class .. ")"
        end
    end

    if preferred and type(preferred) == "number" and preferred >= 1 and preferred <= 8 then
        if PMY.IsMarkAvailable(preferred) and PMY.IsMarkSlotFree(preferred, mob.guid) then
            local isCCMark = (preferred >= 1 and preferred <= 6)
            if isCCMark then
                if not ccImmune then
                    for _, cc in ipairs(PMY.partyCC) do
                        if cc.icon == preferred and cc.creatureTypes[effectiveCtype] then
                            return preferred, PMY.MARK_ROLES[preferred] or "CC"
                        end
                    end
                end
            else
                return preferred, PMY.MARK_ROLES[preferred] or "Kill"
            end
        end
    end

    if PMY.IsMarkAvailable(8) and PMY.IsMarkSlotFree(8, mob.guid) then
        return 8, PMY.MARK_ROLES[8]
    end
    if not isHeroic and PMY.IsMarkAvailable(7) and PMY.IsMarkSlotFree(7, mob.guid) then
        return 7, PMY.MARK_ROLES[7]
    end

    local ccMark, ccEntry = PMY.FindCCMark(effectiveCtype, ccImmune, mob.guid)
    if ccMark then
        return ccMark, ccEntry.spell .. " (" .. ccEntry.class .. ")"
    end

    if isHeroic and PMY.IsMarkAvailable(7) and PMY.IsMarkSlotFree(7, mob.guid) then
        return 7, PMY.MARK_ROLES[7]
    end

    return nil, nil
end

function PMY.MarkSingleUnit(unit)
    if not PMY.ShouldMark() then return false end
    if not PMY.IsValidMobToMark(unit) then return false end

    local guid = PMY.SafeUnitAPI(UnitGUID, unit)
    if not guid then return false end

    if PMY.markedGUIDs[guid] then
        local existingOnUnit = PMY.SafeUnitAPI(GetRaidTargetIndex, unit)
        if existingOnUnit == PMY.markedGUIDs[guid] then
            return false
        end
        if PMY.SafeSetRaidTarget(unit, PMY.markedGUIDs[guid]) then
            return true
        end
        return false
    end

    local existingOnUnit = PMY.SafeUnitAPI(GetRaidTargetIndex, unit)
    if existingOnUnit and existingOnUnit >= 1 and existingOnUnit <= 8 then
        if not PMY.iconToGUID[existingOnUnit] then
            local uName = PMY.SafeUnitAPI(UnitName, unit)
            PMY.ReserveMark(existingOnUnit, guid, uName)
            return false
        end
    end

    local mob = PMY.ClassifyMob(unit)
    PMY.AutoLearnMob(mob)
    PMY.ScoreMob(mob)

    if mob.score < 0 then return false end

    local mark, role = PMY.AllocateMark(mob)
    if mark then
        if not PMY.SafeSetRaidTarget(unit, mark) then
            return false
        end
        PMY.ReserveMark(mark, guid, mob.name)
        mob.assignedMark = mark
        mob.assignedRole = role
        table.insert(PMY.packMobs, mob)
        PMY.Debug("Marked " .. mob.name .. " with " .. PMY.GetIconText(mark) .. " (" .. (role or "") .. ") [score=" .. mob.score .. "]")
        return true
    end

    return false
end

function PMY.ScanAndMarkPack(triggerUnit)
    if not PMY.ShouldMark() then return end

    local now = GetTime()
    if (now - PMY.lastScanTime) < (PMY.db.scanDelay or 0.15) then
        if not PMY.scanPending then
            PMY.scanPending = true
            C_Timer.After(PMY.db.scanDelay or 0.15, function()
                PMY.scanPending = false
                PMY.ScanAndMarkPack(triggerUnit)
            end)
        end
        return
    end
    PMY.lastScanTime = now

    PMY.ScanPartyCC()

    local allUnits = PMY.GetAllVisibleUnits()
    local candidates = {}

    local targetInCombat = false
    if triggerUnit and PMY.SafeUnitAPI(UnitExists, triggerUnit) then
        targetInCombat = PMY.SafeUnitAPI(UnitAffectingCombat, triggerUnit) or false
    end

    for _, unit in ipairs(allUnits) do
        if PMY.IsValidMobToMark(unit) then
            local guid = PMY.SafeUnitAPI(UnitGUID, unit)
            if guid and not PMY.markedGUIDs[guid] then
                local include = true

                if PMY.db.onlyTargetPack and triggerUnit and PMY.SafeUnitAPI(UnitExists, triggerUnit) then
                    local mobInCombat = PMY.SafeUnitAPI(UnitAffectingCombat, unit)
                    if targetInCombat then
                        include = mobInCombat or PMY.SafeUnitAPI(UnitIsUnit, unit, triggerUnit) or false
                    else
                        include = not mobInCombat
                    end
                end

                if include then
                    local existingIcon = PMY.SafeUnitAPI(GetRaidTargetIndex, unit)
                    if existingIcon and existingIcon >= 1 and existingIcon <= 8 and not PMY.iconToGUID[existingIcon] then
                        local uName = PMY.SafeUnitAPI(UnitName, unit)
                        PMY.ReserveMark(existingIcon, guid, uName)
                    else
                        local mob = PMY.ClassifyMob(unit)
                        PMY.AutoLearnMob(mob)
                        PMY.ScoreMob(mob)
                        if mob.score >= 0 then
                            table.insert(candidates, mob)
                        end
                    end
                end
            end
        end
    end

    table.sort(candidates, function(a, b) return a.score > b.score end)

    local newMarks = {}
    for _, mob in ipairs(candidates) do
        local mark, role = PMY.AllocateMark(mob)
        if mark then
            if PMY.SafeSetRaidTarget(mob.unit, mark) then
                PMY.ReserveMark(mark, mob.guid, mob.name)
                mob.assignedMark = mark
                mob.assignedRole = role
                table.insert(PMY.packMobs, mob)
                table.insert(newMarks, mob)
                PMY.Debug(string.format("Pack mark: %s -> %s (%s) [score=%.0f, ctype=%s, mana=%s]",
                    mob.name, PMY.GetIconText(mark), role or "", mob.score, mob.creatureType, tostring(mob.hasMana)))
            end
        end
    end

    if #newMarks > 0 and PMY.db.announceParty and not PMY.combatAnnounced then
        if UnitAffectingCombat("player") then
            PMY.AnnounceMarks()
            PMY.combatAnnounced = true
        end
    end
end

function PMY.HandleMarkedMobDeath(deadGUID, freedIcon)
    local deadName = PMY.guidToName[deadGUID] or "Unknown"
    PMY.Debug("Marked mob died: " .. deadName .. " (" .. tostring(deadGUID) .. ") freeing " .. PMY.GetIconText(freedIcon))
    PMY.ReleaseGUID(deadGUID)

    if not PMY.db.reMarkOnDeath then return end
    if not PMY.ShouldMark() then return end

    if freedIcon == 8 or freedIcon == 7 then
        C_Timer.After(0.1, function()
            if not PMY.ShouldMark() then return end
            local allUnits = PMY.GetAllVisibleUnits()
            local bestMob = nil
            local bestScore = -1

            for _, unit in ipairs(allUnits) do
                if PMY.IsValidMobToMark(unit) and PMY.SafeUnitAPI(UnitAffectingCombat, unit) then
                    local guid = PMY.SafeUnitAPI(UnitGUID, unit)
                    if guid and not PMY.markedGUIDs[guid] then
                        local mob = PMY.ClassifyMob(unit)
                        PMY.ScoreMob(mob)
                        if mob.score > bestScore then
                            bestScore = mob.score
                            bestMob = mob
                        end
                    end
                end
            end

            if bestMob and PMY.IsMarkSlotFree(freedIcon) then
                if PMY.SafeSetRaidTarget(bestMob.unit, freedIcon) then
                    PMY.ReserveMark(freedIcon, bestMob.guid, bestMob.name)
                    PMY.Debug("Re-marked " .. bestMob.name .. " with " .. PMY.GetIconText(freedIcon))
                end
            end
        end)
    end
end

-- ============================================================================
-- PARTY / RAID CHAT ANNOUNCEMENTS
-- ============================================================================

function PMY.AnnounceMarks()
    if not PMY.db or not PMY.db.announceParty then return end
    if PMY.InChatLockdown() then
        PMY.Debug("AnnounceMarks skipped: chat messaging lockdown active")
        return
    end
    local now = GetTime()
    if (now - PMY.lastAnnounceTime) < 3 then return end
    PMY.lastAnnounceTime = now

    local chatType = PMY.db.announceChatType or "PARTY"
    if not IsInGroup() then
        if PMY.db.soloMode then
            chatType = "SAY"
        else
            return
        end
    elseif IsInRaid() and chatType == "PARTY" then
        chatType = "RAID"
    end

    local lines = {}
    local iconOrder = { 8, 7, 5, 3, 4, 1, 2, 6 }

    for _, icon in ipairs(iconOrder) do
        local guid = PMY.iconToGUID[icon]
        if guid then
            local mobName = nil
            local role = PMY.MARK_ROLES[icon] or ""

            for _, mob in ipairs(PMY.packMobs) do
                if mob.guid == guid then
                    mobName = mob.name
                    role = mob.assignedRole or role
                    break
                end
            end

            if not mobName then
                mobName = PMY.guidToName[guid]
            end

            if not mobName then
                local unit = PMY.FindUnitByGUID(guid)
                if unit then mobName = PMY.SafeUnitAPI(UnitName, unit) end
            end

            if mobName then
                local token = PMY.GetIconChatToken(icon)
                table.insert(lines, token .. " " .. role .. ": " .. mobName)
            end
        end
    end

    if #lines > 0 then
        local prefix = "[" .. (PMY.db.announcePrefix or "Psycho Mark's You") .. "] "
        local fullMsg = prefix .. table.concat(lines, " | ")
        if #fullMsg <= 255 then
            pcall(SendChatMessage, fullMsg, chatType)
        else
            pcall(SendChatMessage, prefix .. "Mark Plan:", chatType)
            for _, line in ipairs(lines) do
                pcall(SendChatMessage, "  " .. line, chatType)
            end
        end
    end
end
