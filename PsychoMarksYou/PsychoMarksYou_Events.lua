-- ============================================================================
-- Psycho Mark's You - Event Handling, Keybindings & Slash Commands
-- ============================================================================

local PMY = PsychoMarksYou

local eventFrame = CreateFrame("Frame", "PsychoMarksYouEventFrame", UIParent)
local combatLogFrame = CreateFrame("Frame")

local function InitDB()
    if not PsychoMarksYouDB then
        PsychoMarksYouDB = {}
        if type(AutoMarkAssistDB) == "table" and type(AutoMarkAssistDB.customMobs) == "table" then
            PsychoMarksYouDB.customMobs = AutoMarkAssistDB.customMobs
        end
    end
    for k, v in pairs(PMY.DEFAULTS) do
        if PsychoMarksYouDB[k] == nil then
            if type(v) == "table" then
                PsychoMarksYouDB[k] = {}
                for tk, tv in pairs(v) do
                    PsychoMarksYouDB[k][tk] = tv
                end
            else
                PsychoMarksYouDB[k] = v
            end
        end
    end
    PMY.db = PsychoMarksYouDB
end

-- ============================================================================
-- CLEAR ALL MARKS SECURE BUTTON & KEYBINDING
-- ============================================================================

local secureReset = PMY.IsMarkingProtected()
local resetKeyBtn = CreateFrame("Button", "PMY_ResetMarksButton", UIParent,
    secureReset and "SecureActionButtonTemplate" or nil)
resetKeyBtn:RegisterForClicks("AnyUp", "AnyDown")

if secureReset then
    resetKeyBtn:SetAttribute("useOnKeyDown", false)
    resetKeyBtn:SetAttribute("type", "raidtarget")
    resetKeyBtn:SetAttribute("action", "clear-all")
    resetKeyBtn:SetScript("PostClick", function(self, button, down)
        if down then return end
        PMY.ClearAllMarks()
        if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
        PMY.Print("All marks cleared.")
    end)
else
    resetKeyBtn:SetScript("OnClick", function()
        if not PMY.db or not PMY.db.enabled then return end
        PMY.ClearAllMarks()
        PMY.Print("All marks cleared.")
    end)
end

function PMY.BindResetMarksKey(key)
    local function apply()
        ClearOverrideBindings(resetKeyBtn)
        if key and key ~= "" then
            SetOverrideBindingClick(resetKeyBtn, true, key, "PMY_ResetMarksButton", "LeftButton")
            PMY.Debug("Reset marks key bound to: " .. key)
        else
            PMY.Debug("Reset marks key unbound.")
        end
    end
    if secureReset then
        PMY.RunOutOfCombat("BindResetMarksKey", apply)
    else
        apply()
    end
end

-- Hook TooltipDataProcessor if present on Forever 1.60.1 client
if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Unit then
    pcall(TooltipDataProcessor.AddTooltipPostCall, Enum.TooltipDataType.Unit, function(tooltip)
        if tooltip == GameTooltip then
            PMY.UpdateTooltipWithMobInfo()
        end
    end)
elseif GameTooltip and GameTooltip.HookScript then
    pcall(function()
        GameTooltip:HookScript("OnTooltipSetUnit", function()
            PMY.UpdateTooltipWithMobInfo()
        end)
    end)
end

-- ============================================================================
-- EVENT HANDLER
-- ============================================================================

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("ZONE_CHANGED")
eventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
eventFrame:RegisterEvent("RAID_TARGET_UPDATE")
eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
eventFrame:RegisterEvent("ADDON_ACTION_FORBIDDEN")
eventFrame:RegisterEvent("UNIT_HEALTH")

-- Never register COMBAT_LOG_EVENT_UNFILTERED on WoW Forever (1.60.1 forbids it)
if not PMY.IsMarkingProtected() and not PMY.IsForeverClient() then
    pcall(function()
        combatLogFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end)
    combatLogFrame:SetScript("OnEvent", function()
        if not PMY.db or not PMY.db.enabled then return end
        if not CombatLogGetCurrentEventInfo then return end
        local _, subEvent, _, _, _, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()
        if subEvent == "UNIT_DIED" or subEvent == "PARTY_KILL" then
            if destGUID and not PMY.IsSecret(destGUID) then
                if destName and not PMY.IsSecret(destName) then
                    local ctype = nil
                    local u = PMY.FindUnitByGUID(destGUID)
                    if u then ctype = PMY.SafeUnitAPI(UnitCreatureType, u) end
                    PMY.AddToGraveyard(destName, ctype)
                end
                if PMY.markedGUIDs[destGUID] then
                    local freedIcon = PMY.markedGUIDs[destGUID]
                    PMY.HandleMarkedMobDeath(destGUID, freedIcon)
                end
            end
        end
    end)
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == PMY.ADDON_NAME then
            InitDB()
            PMY.CreateMinimapButton()
            if PMY.db.markMobKey and PMY.db.markMobKey ~= "" then
                PMY.BindMarkMobKey(PMY.db.markMobKey)
            end
            if PMY.db.resetMarksKey and PMY.db.resetMarksKey ~= "" then
                PMY.BindResetMarksKey(PMY.db.resetMarksKey)
            end
            local modeNote = PMY.IsMarkingProtected()
                and "|cFFFFCC00Auto-Group Pack Mode|r (TAB / Scroll / Mark Group key marks whole pack at once)"
                or ("|cFFFFCC00" .. tostring(PMY.db.markingMode) .. "|r mode")
            PMY.Print("v" .. PMY.VERSION .. " loaded (" .. modeNote .. "). Type |cFFFF3366/pmy|r for settings & Forever dungeon database.")
        end

    elseif event == "ADDON_ACTION_FORBIDDEN" then
        local blockedAddon, blockedFunc = ...
        if blockedAddon == PMY.ADDON_NAME and blockedFunc and string.find(blockedFunc, "SetRaidTarget", 1, true) then
            PMY.markingForbidden = true
            PMY.StopProximityScanner()
            if PMY.StartAutoPackWatcher then PMY.StartAutoPackWatcher() end
            PMY.NotifyMarkingBlocked()
        end

    elseif event == "UNIT_HEALTH" then
        if not PMY.db or not PMY.db.enabled then return end
        local unit = ...
        if not unit then return end
        if PMY.SafeUnitAPI(UnitIsDead, unit) then
            local key = PMY.GetUnitTrackingKey(unit)
            local name = PMY.SafeUnitAPI(UnitName, unit)
            if name then
                local ctype = PMY.SafeUnitAPI(UnitCreatureType, unit)
                PMY.AddToGraveyard(name, ctype)
            end
            if key and PMY.markedGUIDs[key] then
                local freedIcon = PMY.markedGUIDs[key]
                PMY.HandleMarkedMobDeath(key, freedIcon)
            end
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        PMY.UpdateZone()
        PMY.ScanPartyCC()
        PMY.ClearAllMarks()
        PMY.activeNameplates = {}
        if PMY.db and PMY.db.enabled then
            PMY.StartProximityScanner()
            if PMY.StartAutoPackWatcher then PMY.StartAutoPackWatcher() end
        end

    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" then
        PMY.UpdateZone()

    elseif event == "GROUP_ROSTER_UPDATE" then
        PMY.ScanPartyCC()
        if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end

    elseif event == "NAME_PLATE_UNIT_ADDED" then
        local unitToken = ...
        if unitToken then
            PMY.activeNameplates[unitToken] = true
            if PMY.db and PMY.db.enabled then
                if PMY.IsMarkingProtected() then
                    if not PMY.inCombat and PMY.RefreshAutoPackState then
                        C_Timer.After(0.05, PMY.RefreshAutoPackState)
                    end
                elseif PMY.db.markingMode == "proximity" then
                    if PMY.inCombat then
                        if PMY.IsActiveOnUnit(unitToken) then
                            C_Timer.After(0.05, PMY.ProximityScanTick)
                        end
                    else
                        C_Timer.After(0.05, PMY.ProximityScanTick)
                    end
                end
            end
        end

    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local unitToken = ...
        if unitToken then
            PMY.activeNameplates[unitToken] = nil
            if PMY.IsMarkingProtected() and not PMY.inCombat and PMY.RefreshAutoPackState then
                C_Timer.After(0.05, PMY.RefreshAutoPackState)
            end
        end

    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        PMY.HandleMouseover()

    elseif event == "PLAYER_TARGET_CHANGED" then
        local mode = PMY.db and PMY.db.markingMode or "proximity"
        if mode == "manual" then
            PMY.HandleManualTarget()
        end

    elseif event == "PLAYER_REGEN_DISABLED" then
        PMY.inCombat = true
        if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
        PMY.CancelAllFadeTimers()
        if not PMY.db or not PMY.db.enabled then return end

        if PMY.SafeUnitAPI(UnitExists, "target") and PMY.IsValidMobToMark("target") then
            PMY.pullTargetGUID = PMY.GetUnitTrackingKey("target")
        else
            PMY.pullTargetGUID = nil
        end

        PMY.engagedGUIDs = {}
        if PMY.pullTargetGUID then
            PMY.engagedGUIDs[PMY.pullTargetGUID] = true
        end

        local anyMobInCombat = false
        for npUnit, _ in pairs(PMY.activeNameplates) do
            if PMY.SafeUnitAPI(UnitExists, npUnit) and PMY.SafeUnitAPI(UnitAffectingCombat, npUnit) then
                anyMobInCombat = true
                local g = PMY.GetUnitTrackingKey(npUnit)
                if g then PMY.engagedGUIDs[g] = true end
            end
        end
        if not anyMobInCombat then
            for i = 1, 40 do
                local u = "nameplate" .. i
                if PMY.SafeUnitAPI(UnitExists, u) and PMY.SafeUnitAPI(UnitAffectingCombat, u) then
                    anyMobInCombat = true
                    local g = PMY.GetUnitTrackingKey(u)
                    if g then PMY.engagedGUIDs[g] = true end
                end
            end
        end

        PMY.combatMarkedGUIDs = {}
        PMY.combatEntryCount  = 0

        if anyMobInCombat then
            local toRemove = {}
            for guid, icon in pairs(PMY.markedGUIDs) do
                local unit = PMY.FindUnitByGUID(guid)
                if unit then
                    if PMY.IsActiveOnUnit(unit) then
                        PMY.engagedGUIDs[guid] = true
                    else
                        table.insert(toRemove, { guid = guid, unit = unit, icon = icon })
                    end
                else
                    table.insert(toRemove, { guid = guid, unit = nil, icon = icon })
                end
            end
            for _, info in ipairs(toRemove) do
                if info.unit and not PMY.IsMarkingProtected() then
                    PMY.SafeSetRaidTarget(info.unit, 0)
                end
                PMY.ReleaseGUID(info.guid)
            end
            for guid, _ in pairs(PMY.markedGUIDs) do
                PMY.combatMarkedGUIDs[guid] = true
                PMY.combatEntryCount = PMY.combatEntryCount + 1
            end
        end

        C_Timer.After(0.8, function()
            if not PMY.inCombat then return end
            PMY.VerifyCombatMarks()
            PMY.combatMarkedGUIDs = {}
            PMY.combatEntryCount  = 0
            for guid, _ in pairs(PMY.markedGUIDs) do
                PMY.combatMarkedGUIDs[guid] = true
                PMY.combatEntryCount = PMY.combatEntryCount + 1
            end
        end)

        if PMY.combatVerifyTimer then
            PMY.combatVerifyTimer:Cancel()
        end
        PMY.combatVerifyTimer = C_Timer.NewTicker(1.5, function()
            if not PMY.inCombat then return end
            PMY.VerifyCombatMarks()
        end)

        if PMY.db.announceParty and not PMY.combatAnnounced then
            C_Timer.After(0.9, function()
                if PMY.inCombat and not PMY.combatAnnounced and PMY.CountMarkedMobs() > 0 then
                    PMY.AnnounceMarks()
                    PMY.combatAnnounced = true
                end
            end)
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        PMY.inCombat = false
        PMY.FlushOutOfCombatQueue()
        if PMY.combatVerifyTimer then
            PMY.combatVerifyTimer:Cancel()
            PMY.combatVerifyTimer = nil
        end
        PMY.combatAnnounced  = false
        PMY.targetPackActive = false
        PMY.pullTargetGUID   = nil
        PMY.combatMarkedGUIDs = {}
        PMY.combatEntryCount = 0
        PMY.engagedGUIDs     = {}
        if PMY.db and PMY.db.clearOnCombatEnd then
            C_Timer.After(1.2, function()
                if not PMY.inCombat then
                    PMY.ClearAllMarks()
                    if PMY.IsMarkingProtected() then
                        if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
                    elseif PMY.db.enabled and PMY.db.markingMode == "proximity" then
                        C_Timer.After(0.3, function()
                            if not PMY.inCombat then
                                PMY.ProximityScanTick()
                            end
                        end)
                    end
                end
            end)
        else
            if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
        end

    elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
        if not PMY.db or not PMY.db.enabled then return end
        local unit = ...
        if unit and PMY.IsValidMobToMark(unit) then
            PMY.PromoteMobOnCast(unit)
        end

    elseif event == "RAID_TARGET_UPDATE" then
        for iconIdx = 1, 8 do
            local guid = PMY.iconToGUID[iconIdx]
            if guid then
                local unit = PMY.FindUnitByGUID(guid)
                if unit then
                    local curIcon = PMY.SafeUnitAPI(GetRaidTargetIndex, unit)
                    if curIcon ~= nil and curIcon ~= iconIdx then
                        PMY.ReleaseMark(iconIdx)
                        if curIcon >= 1 and curIcon <= 8 then
                            local uName = PMY.SafeUnitAPI(UnitName, unit)
                            PMY.ReserveMark(curIcon, guid, uName)
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================================
-- SLASH COMMANDS (/pmy, /psychomarksyou, /psychomark)
-- ============================================================================

local function HandleSlashCommand(msg)
    local cmd, rest = msg:match("^(%S*)%s*(.-)$")
    cmd = string.lower(cmd or "")

    if cmd == "" or cmd == "config" or cmd == "options" or cmd == "gui" then
        PMY.ToggleConfig()

    elseif cmd == "mark" or cmd == "scan" then
        if PMY.IsMarkingProtected() then
            if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
            PMY.NotifyMarkingBlocked()
        else
            PMY.ScanAndMarkPack("target")
            PMY.Print("Scanned and marked visible pack.")
        end

    elseif cmd == "clear" or cmd == "reset" then
        PMY.ClearAllMarks()
        if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
        PMY.Print("All marks cleared.")

    elseif cmd == "announce" or cmd == "ann" then
        PMY.lastAnnounceTime = 0
        PMY.AnnounceMarks()

    elseif cmd == "on" or cmd == "enable" then
        PMY.db.enabled = true
        PMY.UpdateMinimapIcon()
        PMY.StartProximityScanner()
        if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
        PMY.Print("Marking |cFF00FF00Enabled|r.")

    elseif cmd == "off" or cmd == "disable" then
        PMY.db.enabled = false
        PMY.UpdateMinimapIcon()
        PMY.StopProximityScanner()
        if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
        PMY.Print("Marking |cFFFF0000Disabled|r.")

    elseif cmd == "autotab" or cmd == "tab" then
        PMY.db.autoMarkOnTab = not PMY.db.autoMarkOnTab
        if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
        PMY.Print("Auto-Mark Group on TAB: " .. (PMY.db.autoMarkOnTab and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"))

    elseif cmd == "autowheel" or cmd == "wheel" then
        PMY.db.autoMarkOnWheel = not PMY.db.autoMarkOnWheel
        if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
        PMY.Print("Auto-Mark Group on Mouse Wheel: " .. (PMY.db.autoMarkOnWheel and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"))

    elseif cmd == "hud" then
        PMY.db.showPackHUD = not PMY.db.showPackHUD
        if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
        PMY.Print("Pack Preview HUD: " .. (PMY.db.showPackHUD and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"))

    elseif cmd == "solo" then
        PMY.db.soloMode = not PMY.db.soloMode
        if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
        PMY.Print("Solo mode: " .. (PMY.db.soloMode and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"))

    elseif cmd == "tooltip" or cmd == "tips" then
        PMY.db.showTooltipHint = not PMY.db.showTooltipHint
        PMY.Print("Tooltip Advisor: " .. (PMY.db.showTooltipHint and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"))

    elseif cmd == "debug" then
        PMY.db.debugMode = not PMY.db.debugMode
        PMY.Print("Debug mode: " .. (PMY.db.debugMode and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"))

    elseif cmd == "status" or cmd == "info" then
        PMY.UpdateZone()
        PMY.ScanPartyCC()
        PMY.Print("=== Psycho Mark's You Status ===")
        PMY.Print("Enabled: " .. tostring(PMY.db.enabled))
        if PMY.IsMarkingProtected() then
            PMY.Print("Client Mode: |cFFFFCC00Whole-Group Auto-Pack Mode|r")
            PMY.Print("  Auto-TAB: " .. tostring(PMY.db.autoMarkOnTab) .. " | Auto-Wheel: " .. tostring(PMY.db.autoMarkOnWheel) .. " | Key: " .. tostring(PMY.GetMarkMobBindingText() or "Unbound"))
        else
            PMY.Print("Marking Mode: |cFFFFCC00" .. (PMY.db.markingMode or "proximity") .. "|r (Max: " .. (PMY.db.proximityMarks or 3) .. ")")
        end
        PMY.Print("Zone: " .. (PMY.currentZone ~= "" and PMY.currentZone or "Open World") .. " (Instance: " .. tostring(PMY.inInstance) .. ")")
        PMY.Print("Active Marks: " .. PMY.CountMarkedMobs())
        PMY.Print("Available CC: " .. #PMY.partyCC .. " classes")
        for _, cc in ipairs(PMY.partyCC) do
            PMY.Print("  " .. PMY.GetIconText(cc.icon) .. " -> " .. cc.spell .. " (" .. cc.class .. ")")
        end

    else
        PMY.Print("Commands:")
        PMY.Print("  |cFFFF3366/pmy|r — Open settings & WoW Forever dungeon database")
        PMY.Print("  |cFFFF3366/pmy tab|r — Toggle Auto-Mark Group on TAB")
        PMY.Print("  |cFFFF3366/pmy wheel|r — Toggle Auto-Mark Group on Mouse Wheel")
        PMY.Print("  |cFFFF3366/pmy hud|r — Toggle on-screen Pack Preview HUD")
        PMY.Print("  |cFFFF3366/pmy clear|r — Clear all active marks")
        PMY.Print("  |cFFFF3366/pmy announce|r — Announce marks to party/raid chat")
        PMY.Print("  |cFFFF3366/pmy solo|r — Toggle solo mode")
        PMY.Print("  |cFFFF3366/pmy status|r — Show current status & party CC")
    end
end

SLASH_PSYCHOMARKSYOU1 = "/pmy"
SLASH_PSYCHOMARKSYOU2 = "/psychomarksyou"
SLASH_PSYCHOMARKSYOU3 = "/psychomark"
SlashCmdList["PSYCHOMARKSYOU"] = HandleSlashCommand

if not SlashCmdList["AUTOMARKASSIST"] then
    SLASH_AUTOMARKASSIST1 = "/ama"
    SlashCmdList["AUTOMARKASSIST"] = HandleSlashCommand
end
