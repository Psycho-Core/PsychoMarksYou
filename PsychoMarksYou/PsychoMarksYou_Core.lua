-- ============================================================================
-- Psycho Mark's You - Core Utilities, API Wrappers & Database Access
-- ============================================================================

local PMY = PsychoMarksYou

-- ============================================================================
-- WOW FOREVER / CLIENT RESTRICTION DETECTION
-- ============================================================================

local _issecretvalue = issecretvalue
local _issecrettable = issecrettable

function PMY.IsSecret(val)
    if _issecretvalue and _issecretvalue(val) then return true end
    if _issecrettable and _issecrettable(val) then return true end
    return false
end

function PMY.InChatLockdown()
    if C_ChatInfo and C_ChatInfo.InChatMessagingLockdown then
        local ok, locked = pcall(C_ChatInfo.InChatMessagingLockdown)
        if ok and locked then return true end
    end
    return false
end

function PMY.SafeUnitAPI(fn, ...)
    if not fn then return nil end
    local ok, r1, r2, r3, r4 = pcall(fn, ...)
    if not ok then return nil end
    if PMY.IsSecret(r1) then return nil end
    if PMY.IsSecret(r2) then r2 = nil end
    if PMY.IsSecret(r3) then r3 = nil end
    if PMY.IsSecret(r4) then r4 = nil end
    return r1, r2, r3, r4
end

function PMY.IsForeverClient()
    if GetBuildInfo then
        local _, _, _, interfaceVersion = GetBuildInfo()
        if interfaceVersion and interfaceVersion >= 16000 and interfaceVersion < 20000 then
            return true
        end
    end
    return false
end

local function ClientProtectsRaidTargets()
    if WOW_PROJECT_ID and WOW_PROJECT_MAINLINE and WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        return true
    end
    if PMY.IsForeverClient() then
        return true
    end
    return false
end

PMY.markingForbidden = ClientProtectsRaidTargets()

function PMY.IsMarkingProtected()
    return PMY.markingForbidden == true
end

function PMY.GetUnitTrackingKey(unit)
    if not unit then return nil end
    local guid = PMY.SafeUnitAPI(UnitGUID, unit)
    if guid then return guid end
    -- When UnitGUID is secret in Forever instances, track by nameplate token
    for i = 1, 40 do
        local np = "nameplate" .. i
        if PMY.SafeUnitAPI(UnitExists, np) and PMY.SafeUnitAPI(UnitIsUnit, unit, np) then
            return "unit:" .. np
        end
    end
    return "unit:" .. unit
end

function PMY.GetMarkMobBindingText()
    if PMY.db and PMY.db.markMobKey and PMY.db.markMobKey ~= "" then
        if GetBindingText then
            return GetBindingText(PMY.db.markMobKey) or PMY.db.markMobKey
        end
        return PMY.db.markMobKey
    end
    if not GetBindingKey then return nil end
    local k1, k2 = GetBindingKey("CLICK PMY_MarkMobButton:LeftButton")
    local key = k1 or k2
    if not key then return nil end
    if GetBindingText then
        return GetBindingText(key) or key
    end
    return key
end

function PMY.NotifyMarkingBlocked()
    if PMY.markingBlockedWarned then return end
    PMY.markingBlockedWarned = true
    local triggers = {}
    if PMY.db and PMY.db.autoMarkOnTab then table.insert(triggers, "|cFF00FF00TAB|r") end
    if PMY.db and PMY.db.autoMarkOnWheel then table.insert(triggers, "|cFF00FF00Mouse Wheel|r") end
    local keyText = PMY.GetMarkMobBindingText()
    if keyText then table.insert(triggers, "|cFF00FF00" .. keyText .. "|r") end
    if #triggers > 0 then
        PMY.Print("|cFFFFCC00Auto-Group Mode:|r Press " .. table.concat(triggers, " or ") .. " when a pack is in view to mark the whole group at once.")
    else
        PMY.Print("|cFFFFCC00Auto-Group Mode:|r Enable Auto-TAB / Auto-Wheel or bind |cFF00FF00Mark Group|r in |cFFFF3366/pmy|r.")
    end
end

function PMY.SafeSetRaidTarget(unit, icon)
    if PMY.markingForbidden then
        PMY.NotifyMarkingBlocked()
        return false
    end
    if not unit or icon == nil then return false end
    local ok = pcall(SetRaidTarget, unit, icon)
    if not ok or PMY.markingForbidden then
        PMY.markingForbidden = true
        PMY.NotifyMarkingBlocked()
        return false
    end
    return true
end

local oocQueue = {}
function PMY.RunOutOfCombat(key, fn)
    if type(key) == "function" then
        fn = key
        key = tostring(fn)
    end
    if not InCombatLockdown or not InCombatLockdown() then
        fn()
    else
        oocQueue[key] = fn
    end
end

function PMY.FlushOutOfCombatQueue()
    if InCombatLockdown and InCombatLockdown() then return end
    for k, fn in pairs(oocQueue) do
        oocQueue[k] = nil
        pcall(fn)
    end
end

-- ============================================================================
-- LOGGING & UTILITY FUNCTIONS
-- ============================================================================

function PMY.Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(PMY.COLOR_PREFIX .. tostring(msg))
end

function PMY.Debug(msg)
    if PMY.db and PMY.db.debugMode then
        DEFAULT_CHAT_FRAME:AddMessage(PMY.COLOR_PREFIX .. "|cFF888888[DEBUG]|r " .. tostring(msg))
    end
end

function PMY.GetIconText(iconIndex)
    local info = PMY.RAID_ICONS[iconIndex]
    if not info then return "?" end
    return info.color .. info.name .. "|r"
end

function PMY.GetIconChatToken(iconIndex)
    local info = PMY.RAID_ICONS[iconIndex]
    if not info then return "" end
    return info.chat
end

function PMY.IsLeaderOrAssist()
    if not IsInGroup() then return true end
    if IsInRaid() then
        return UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")
    else
        return true
    end
end

function PMY.ShouldMark()
    if not PMY.db or not PMY.db.enabled then return false end
    if not IsInGroup() and not PMY.db.soloMode then return false end
    if IsInRaid() and not PMY.IsLeaderOrAssist() then return false end
    return true
end

function PMY.IsMarkAvailable(iconIndex)
    if not PMY.db then return true end
    return not PMY.db.disabledMarks[iconIndex]
end

function PMY.IsMarkSlotFree(iconIndex, excludeGUID)
    if PMY.db and PMY.db.disabledMarks[iconIndex] then return false end
    local existingGUID = PMY.iconToGUID[iconIndex]
    if not existingGUID or existingGUID == excludeGUID then return true end
    if PMY.IsUnitDead(existingGUID) then
        PMY.ReleaseMark(iconIndex)
        return true
    end
    return false
end

function PMY.ReserveMark(iconIndex, guid, mobName)
    if not guid then return end
    local oldIcon = PMY.markedGUIDs[guid]
    if oldIcon and oldIcon ~= iconIndex then
        PMY.iconToGUID[oldIcon] = nil
    end
    local oldGUID = PMY.iconToGUID[iconIndex]
    if oldGUID and oldGUID ~= guid then
        PMY.markedGUIDs[oldGUID] = nil
    end

    PMY.markedGUIDs[guid] = iconIndex
    PMY.iconToGUID[iconIndex] = guid
    if mobName then
        PMY.guidToName[guid] = mobName
    end
    PMY.markTimestamps[guid] = GetTime()
end

function PMY.CancelAllFadeTimers()
    for guid, timer in pairs(PMY.staleFadeTimers) do
        timer:Cancel()
    end
    PMY.staleFadeTimers = {}
end

function PMY.ReleaseMark(iconIndex)
    local guid = PMY.iconToGUID[iconIndex]
    if guid then
        PMY.markedGUIDs[guid] = nil
        PMY.guidToName[guid] = nil
        PMY.markTimestamps[guid] = nil
        if PMY.staleFadeTimers[guid] then
            PMY.staleFadeTimers[guid]:Cancel()
            PMY.staleFadeTimers[guid] = nil
        end
    end
    PMY.iconToGUID[iconIndex] = nil
end

function PMY.ReleaseGUID(guid)
    local icon = PMY.markedGUIDs[guid]
    if icon then
        PMY.iconToGUID[icon] = nil
    end
    PMY.markedGUIDs[guid] = nil
    PMY.guidToName[guid] = nil
    PMY.markTimestamps[guid] = nil
    if PMY.staleFadeTimers[guid] then
        PMY.staleFadeTimers[guid]:Cancel()
        PMY.staleFadeTimers[guid] = nil
    end
end

function PMY.ClearAllMarks()
    PMY.CancelAllFadeTimers()
    if not PMY.IsMarkingProtected() then
        local units = PMY.GetAllVisibleUnits()
        for _, unit in ipairs(units) do
            local existing = PMY.SafeUnitAPI(GetRaidTargetIndex, unit)
            if existing and existing >= 1 and existing <= 8 then
                PMY.SafeSetRaidTarget(unit, 0)
            end
        end
        if PMY.SafeUnitAPI(UnitExists, "target") and PMY.SafeUnitAPI(GetRaidTargetIndex, "target") then
            PMY.SafeSetRaidTarget("target", 0)
        end
    end

    PMY.markedGUIDs = {}
    PMY.iconToGUID = {}
    PMY.guidToName = {}
    PMY.packMobs = {}
    PMY.combatAnnounced = false
    PMY.targetPackActive = false
    PMY.pullTargetGUID = nil
    PMY.combatMarkedGUIDs = {}
    PMY.combatEntryCount = 0
    PMY.engagedGUIDs = {}
    PMY.markTimestamps = {}
    if PMY.ResetMarkKeySession then PMY.ResetMarkKeySession() end
    PMY.Debug("All marks cleared.")
end

function PMY.IsUnitDead(guid)
    if not guid then return false end
    if type(guid) == "string" and string.sub(guid, 1, 5) == "unit:" then
        local u = string.sub(guid, 6)
        if not PMY.SafeUnitAPI(UnitExists, u) then return true end
        return PMY.SafeUnitAPI(UnitIsDead, u) or false
    end
    local units = PMY.GetAllVisibleUnits()
    for _, unit in ipairs(units) do
        local uGuid = PMY.SafeUnitAPI(UnitGUID, unit)
        if uGuid == guid then
            return PMY.SafeUnitAPI(UnitIsDead, unit) or false
        end
    end
    return false
end

-- ============================================================================
-- VISIBLE UNIT ENUMERATION (Works even when UnitGUID is secret in Forever!)
-- ============================================================================

function PMY.GetAllVisibleUnits()
    local units = {}
    local seen = {}

    local function addUnit(u)
        local exists = PMY.SafeUnitAPI(UnitExists, u)
        if not exists then return end
        local guid = PMY.SafeUnitAPI(UnitGUID, u)
        if guid then
            if not seen[guid] then
                seen[guid] = true
                table.insert(units, u)
            end
        else
            for _, existingU in ipairs(units) do
                if existingU == u or PMY.SafeUnitAPI(UnitIsUnit, u, existingU) then
                    return
                end
            end
            table.insert(units, u)
        end
    end

    for npUnit, _ in pairs(PMY.activeNameplates) do
        addUnit(npUnit)
    end
    for i = 1, 40 do
        addUnit("nameplate" .. i)
    end

    addUnit("target")
    addUnit("mouseover")
    addUnit("focus")
    addUnit("targettarget")

    if IsInRaid() then
        for i = 1, 40 do
            addUnit("raid" .. i .. "target")
        end
    elseif IsInGroup() then
        for i = 1, 4 do
            addUnit("party" .. i .. "target")
        end
    end

    return units
end

function PMY.FindUnitByGUID(guid)
    if not guid or PMY.IsSecret(guid) then return nil end
    if type(guid) == "string" and string.sub(guid, 1, 5) == "unit:" then
        local u = string.sub(guid, 6)
        if PMY.SafeUnitAPI(UnitExists, u) then return u end
        return nil
    end
    for npUnit, _ in pairs(PMY.activeNameplates) do
        if PMY.SafeUnitAPI(UnitExists, npUnit) and PMY.SafeUnitAPI(UnitGUID, npUnit) == guid then
            return npUnit
        end
    end
    for i = 1, 40 do
        local u = "nameplate" .. i
        if PMY.SafeUnitAPI(UnitExists, u) and PMY.SafeUnitAPI(UnitGUID, u) == guid then return u end
    end
    if PMY.SafeUnitAPI(UnitExists, "target") and PMY.SafeUnitAPI(UnitGUID, "target") == guid then return "target" end
    if PMY.SafeUnitAPI(UnitExists, "mouseover") and PMY.SafeUnitAPI(UnitGUID, "mouseover") == guid then return "mouseover" end
    if PMY.SafeUnitAPI(UnitExists, "focus") and PMY.SafeUnitAPI(UnitGUID, "focus") == guid then return "focus" end

    if IsInRaid() then
        for i = 1, 40 do
            local u = "raid" .. i .. "target"
            if PMY.SafeUnitAPI(UnitExists, u) and PMY.SafeUnitAPI(UnitGUID, u) == guid then return u end
        end
    elseif IsInGroup() then
        for i = 1, 4 do
            local u = "party" .. i .. "target"
            if PMY.SafeUnitAPI(UnitExists, u) and PMY.SafeUnitAPI(UnitGUID, u) == guid then return u end
        end
    end
    return nil
end

function PMY.CountMarkedMobs()
    local count = 0
    for key, icon in pairs(PMY.markedGUIDs) do
        if PMY.IsUnitDead(key) then
            PMY.ReleaseMark(icon)
        else
            count = count + 1
        end
    end
    return count
end

function PMY.IsActiveOnUnit(unit)
    local guid = PMY.GetUnitTrackingKey(unit)
    if not guid then return false end
    if PMY.SafeUnitAPI(UnitAffectingCombat, unit) then return true end
    local tt = unit .. "target"
    if PMY.SafeUnitAPI(UnitExists, tt) then
        if PMY.SafeUnitAPI(UnitIsUnit, tt, "player")
            or PMY.SafeUnitAPI(UnitInParty, tt)
            or PMY.SafeUnitAPI(UnitInRaid, tt) then
            return true
        end
    end
    if PMY.pullTargetGUID and guid == PMY.pullTargetGUID then return true end
    if PMY.engagedGUIDs[guid] then return true end
    if PMY.SafeUnitAPI(UnitExists, "target") and PMY.GetUnitTrackingKey("target") == guid then return true end
    if IsInRaid() then
        for i = 1, 40 do
            local u = "raid" .. i .. "target"
            if PMY.SafeUnitAPI(UnitExists, u) and PMY.GetUnitTrackingKey(u) == guid then return true end
        end
    elseif IsInGroup() then
        for i = 1, 4 do
            local u = "party" .. i .. "target"
            if PMY.SafeUnitAPI(UnitExists, u) and PMY.GetUnitTrackingKey(u) == guid then return true end
        end
    end
    return false
end

function PMY.VerifyCombatMarks()
    if not PMY.inCombat then return end
    if not PMY.db or not PMY.db.enabled then return end

    local toClear = {}
    for guid, icon in pairs(PMY.markedGUIDs) do
        local unit = PMY.FindUnitByGUID(guid)
        if unit then
            if PMY.IsActiveOnUnit(unit) then
                PMY.engagedGUIDs[guid] = true
            else
                table.insert(toClear, { guid = guid, unit = unit, icon = icon, reason = "not in combat" })
            end
        else
            if not PMY.engagedGUIDs[guid] then
                table.insert(toClear, { guid = guid, unit = nil, icon = icon, reason = "out of range, never engaged" })
            end
        end
    end

    for _, info in ipairs(toClear) do
        local mobName = PMY.guidToName[info.guid] or "Unknown"
        if info.unit and not PMY.IsMarkingProtected() then
            PMY.SafeSetRaidTarget(info.unit, 0)
        end
        PMY.ReleaseGUID(info.guid)
        PMY.Debug("VerifyCombatMarks: cleared " .. PMY.GetIconText(info.icon)
            .. " from " .. mobName .. " (" .. info.reason .. ")")
    end
end

-- ============================================================================
-- PARTY / GROUP CC DETECTION
-- ============================================================================

function PMY.ScanPartyCC()
    PMY.partyCC = {}

    local classList = {}
    local _, playerClass = UnitClass("player")
    if playerClass then
        classList[playerClass] = (classList[playerClass] or 0) + 1
    end

    if IsInRaid() then
        for i = 1, 40 do
            local u = "raid" .. i
            if UnitExists(u) and not UnitIsUnit(u, "player") and UnitIsConnected(u) then
                local _, cls = UnitClass(u)
                if cls then classList[cls] = (classList[cls] or 0) + 1 end
            end
        end
    elseif IsInGroup() then
        for i = 1, 4 do
            local u = "party" .. i
            if UnitExists(u) and UnitIsConnected(u) then
                local _, cls = UnitClass(u)
                if cls then classList[cls] = (classList[cls] or 0) + 1 end
            end
        end
    end

    local ccEntries = {}
    for cls, count in pairs(classList) do
        local ccInfo = PMY.CC_ASSIGNMENTS[cls]
        if ccInfo and PMY.IsMarkAvailable(ccInfo.icon) then
            table.insert(ccEntries, {
                class         = cls,
                icon          = ccInfo.icon,
                spell         = ccInfo.spell,
                creatureTypes = ccInfo.creatureTypes,
                priority      = ccInfo.priority,
                count         = count,
            })
        end
    end

    table.sort(ccEntries, function(a, b) return a.priority < b.priority end)

    local usedIcons = {}
    for _, entry in ipairs(ccEntries) do
        if not usedIcons[entry.icon] then
            usedIcons[entry.icon] = true
            table.insert(PMY.partyCC, entry)
        end
    end
end

function PMY.FindCCMark(creatureType, ccImmune, excludeGUID)
    if ccImmune then return nil, nil end
    if not creatureType then return nil, nil end

    for _, cc in ipairs(PMY.partyCC) do
        if cc.creatureTypes[creatureType] and PMY.IsMarkSlotFree(cc.icon, excludeGUID) then
            return cc.icon, cc
        end
    end
    return nil, nil
end

function PMY.IsHeroicDifficulty()
    local _, instanceType, difficultyID = GetInstanceInfo()
    if instanceType ~= "party" then return false end
    return difficultyID and difficultyID >= 2
end

-- ============================================================================
-- ZONE DETECTION & DATABASE LOOKUP
-- ============================================================================

function PMY.UpdateZone()
    local zoneName = GetRealZoneText() or GetZoneText() or ""
    local inInst, instType = IsInInstance()
    PMY.inInstance = inInst
    PMY.instanceType = instType or "none"

    local resolved = PMY.ResolveZoneName(zoneName)
    if resolved ~= PMY.currentZone then
        PMY.currentZone = resolved
        PMY.sessionAnnounced = false
        PMY.Debug("Zone updated to: " .. tostring(PMY.currentZone) .. " (raw: " .. zoneName .. ", instance: " .. tostring(inInst) .. ")")
    end
end

function PMY.ResolveZoneName(rawZone)
    if not rawZone or rawZone == "" then return "" end

    if PsychoMarksYou_DefaultMobs and PsychoMarksYou_DefaultMobs[rawZone] then
        return rawZone
    end

    if PsychoMarksYou_ZoneAliases then
        if PsychoMarksYou_ZoneAliases[rawZone] then
            return PsychoMarksYou_ZoneAliases[rawZone]
        end
        local lowerRaw = string.lower(rawZone)
        for alias, canonical in pairs(PsychoMarksYou_ZoneAliases) do
            if string.find(lowerRaw, string.lower(alias), 1, true) then
                return canonical
            end
        end
    end

    if PsychoMarksYou_DefaultMobs then
        local lowerRaw = string.lower(rawZone)
        for zoneKey, _ in pairs(PsychoMarksYou_DefaultMobs) do
            if string.find(lowerRaw, string.lower(zoneKey), 1, true) or
               string.find(string.lower(zoneKey), lowerRaw, 1, true) then
                return zoneKey
            end
        end
    end

    return rawZone
end

-- ============================================================================
-- ENTRY HELPER FUNCTIONS
-- ============================================================================

function PMY.GetEntryMark(entry)
    if entry == "SKIP" then return "SKIP" end
    if type(entry) == "number" then return entry end
    if type(entry) == "table" then return entry.mark end
    return nil
end

function PMY.GetEntryCreatureType(entry)
    if type(entry) == "table" then return entry.creatureType end
    return nil
end

function PMY.GetEntryCCImmune(entry)
    if type(entry) == "table" then return entry.ccImmune or false end
    return false
end

function PMY.GetEntryDangerLevel(entry)
    if type(entry) == "table" then return entry.dangerLevel end
    return nil
end

function PMY.GetEntryNote(entry)
    if type(entry) == "table" and type(entry.note) == "string" and entry.note ~= "" then
        return entry.note
    end
    return nil
end

function PMY.GetMobDBEntry(mobName)
    if not mobName then return nil end

    local zone = PMY.currentZone
    if PMY.db and PMY.db.customMobs then
        if zone and PMY.db.customMobs[zone] and PMY.db.customMobs[zone][mobName] ~= nil then
            return PMY.db.customMobs[zone][mobName]
        end
        if PMY.db.customMobs["*"] and PMY.db.customMobs["*"][mobName] ~= nil then
            return PMY.db.customMobs["*"][mobName]
        end
    end

    if PsychoMarksYou_DefaultMobs and zone and PsychoMarksYou_DefaultMobs[zone] then
        -- A known instance zone is authoritative; never borrow a same-name row
        -- from a different expansion/instance.
        return PsychoMarksYou_DefaultMobs[zone][mobName]
    end

    -- If zone resolution failed while inside an instance, a global scan could
    -- apply an unrelated Classic/Forever entry with the same creature name.
    if PMY.inInstance then return nil end

    if PsychoMarksYou_DefaultMobs then
        for _, zoneMobs in pairs(PsychoMarksYou_DefaultMobs) do
            if zoneMobs[mobName] ~= nil then
                return zoneMobs[mobName]
            end
        end
    end

    return nil
end

function PMY.GetMobDefaultPriority(mobName)
    local raw = PMY.GetMobDBEntry(mobName)
    return PMY.GetEntryMark(raw)
end

-- ============================================================================
-- TOOLTIP ADVISOR (Shows Psycho Mark's You priority & note on mob tooltips)
-- ============================================================================

function PMY.UpdateTooltipWithMobInfo()
    if not PMY.db or not PMY.db.enabled or not PMY.db.showTooltipHint then return end
    if not GameTooltip or not GameTooltip:IsShown() then return end

    local unit = "mouseover"
    if not PMY.SafeUnitAPI(UnitExists, unit) then return end
    if PMY.SafeUnitAPI(UnitIsPlayer, unit) then return end
    if not PMY.SafeUnitAPI(UnitCanAttack, "player", unit) then return end

    local mobName = PMY.SafeUnitAPI(UnitName, unit)
    if not mobName then return end

    local entry = PMY.GetMobDBEntry(mobName)
    if not entry then return end

    local ttName = GameTooltip:GetName()
    if ttName then
        for i = 1, GameTooltip:NumLines() do
            local leftLine = _G[ttName .. "TextLeft" .. i]
            if leftLine then
                local txt = leftLine:GetText()
                if txt and not PMY.IsSecret(txt) and string.find(txt, "Psycho Mark's You", 1, true) then
                    return
                end
            end
        end
    end

    local mark = PMY.GetEntryMark(entry)
    local danger = PMY.GetEntryDangerLevel(entry)
    local note = PMY.GetEntryNote(entry)
    local ccImmune = PMY.GetEntryCCImmune(entry)

    local dangerText = ""
    if danger == 3 then
        dangerText = " |cFFFF3333[CRITICAL]|r"
    elseif danger == 2 then
        dangerText = " |cFFFFAA00[HIGH]|r"
    elseif danger == 1 then
        dangerText = " |cFF88CC88[NORMAL]|r"
    end

    if mark == "SKIP" then
        GameTooltip:AddLine("|cFFFF3366Psycho Mark's You:|r |cFF888888SKIP (Swarm / Non-Priority Add)|r")
    elseif type(mark) == "number" and PMY.RAID_ICONS[mark] then
        local role = PMY.MARK_ROLES[mark] or ""
        local immStr = ccImmune and " |cFFFF6600(CC Immune)|r" or ""
        GameTooltip:AddLine("|cFFFF3366Psycho Mark's You:|r " .. PMY.GetIconText(mark) .. " |cFFCCCCCC(" .. role .. ")|r" .. dangerText .. immStr)
    elseif mark == nil and note then
        GameTooltip:AddLine("|cFFFF3366Psycho Mark's You:|r |cFFCCCCCCTactical note|r")
    end

    if note then
        GameTooltip:AddLine("  |cFFFFCC66Tip:|r |cFFDDDDDD" .. note .. "|r", 1, 1, 1, true)
    end

    GameTooltip:Show()
end
