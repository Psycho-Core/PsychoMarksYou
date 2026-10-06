-- ============================================================================
-- Psycho Mark's You - Automatic Group / Pack Marking Engine (WoW Forever Beta)
--
-- Automatically scans all visible enemy nameplates in a dungeon pack, scores
-- the entire group against the WoW Forever database + party CC composition,
-- and marks the WHOLE GROUP AT ONCE using:
--   1. Auto-updated "PMY_AutoPack" macro (/tm [@nameplateX] 8, /tm [@nameplateY] 7, ...)
--      executed via SecureActionButtonTemplate (marks up to 8 mobs in 1 hardware event!)
--   2. Automatic out-of-combat triggers on TAB (targets enemy + marks whole pack),
--      Mouse Wheel scroll, or your bound Mark Group key / on-screen HUD button.
--   3. Automatic fallback to single-unit type="raidtarget" in priority order if
--      the player's macro book is completely full.
-- ============================================================================

local PMY = PsychoMarksYou

local MACRO_NAME = "PMY_AutoPack"
local MACRO_ICON = "INV_Misc_QuestionMark"

-- Primary Secure Button for marking the pack
local markBtn = CreateFrame("Button", "PMY_MarkMobButton", UIParent, "SecureActionButtonTemplate")
markBtn:RegisterForClicks("AnyUp", "AnyDown")
markBtn:SetAttribute("useOnKeyDown", false)
markBtn:SetAttribute("type", "raidtarget")
markBtn:SetAttribute("action", "set-unmarked")

-- Separate owner frame for temporary auto-triggers (TAB / MouseWheel) so user's
-- permanent Mark Group keybind on markBtn is never cleared when auto-triggers disarm.
local autoTriggerOwner = CreateFrame("Frame", "PMY_AutoTriggerOwner", UIParent)
local autoTriggersArmed = false
local lastMacroBody = ""
local pendingPlan = nil

PMY.markKeyBlindOrder = {}
PMY.markKeyBlindIdx   = 0

-- ============================================================================
-- WHOLE-GROUP PACK SCANNER & PLANNER
-- ============================================================================

local function BuildBlindIconOrder(tempUsedIcons)
    PMY.ScanPartyCC()
    local order = {}
    local seen  = {}
    local function push(icon)
        if icon and not seen[icon] and not (tempUsedIcons and tempUsedIcons[icon])
           and PMY.IsMarkAvailable(icon) and PMY.IsMarkSlotFree(icon) then
            seen[icon] = true
            table.insert(order, icon)
        end
    end
    local isHeroic = PMY.IsHeroicDifficulty()
    push(8)
    if not isHeroic then push(7) end
    for _, cc in ipairs(PMY.partyCC) do
        push(cc.icon)
    end
    if isHeroic then push(7) end
    -- Fill remaining enabled icons if maxMarks > kill + CC
    for _, fallbackIcon in ipairs({ 6, 5, 4, 3, 2, 1 }) do
        push(fallbackIcon)
    end
    return order
end

function PMY.ResetMarkKeySession()
    PMY.markKeyBlindOrder = {}
    PMY.markKeyBlindIdx   = 0
    pendingPlan           = nil
end

-- Allocate a mark for one mob while respecting icons already planned for earlier
-- mobs in the same pack scan (tempUsedIcons).
local function AllocateMarkInPack(mob, tempUsedIcons)
    if mob.dbPriority == "SKIP" or mob.score < 0 then
        return nil, nil
    end

    local function isFree(icon)
        if not icon then return false end
        if tempUsedIcons[icon] then return false end
        return PMY.IsMarkAvailable(icon) and PMY.IsMarkSlotFree(icon, mob.key)
    end

    local preferred      = mob.dbPriority
    local effectiveCtype = PMY.GetEffectiveCreatureType(mob)
    local ccImmune       = mob.dbCCImmune or mob.isBoss
    local isHeroic       = PMY.IsHeroicDifficulty()

    if isHeroic and PMY.IsMobSuitableForCC(mob) and preferred ~= 8 then
        for _, cc in ipairs(PMY.partyCC) do
            if cc.creatureTypes[effectiveCtype] and isFree(cc.icon) then
                return cc.icon, cc.spell .. " (" .. cc.class .. ")"
            end
        end
    end

    if preferred and type(preferred) == "number" and preferred >= 1 and preferred <= 8 then
        if isFree(preferred) then
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

    if isFree(8) then
        return 8, PMY.MARK_ROLES[8]
    end
    if not isHeroic and isFree(7) then
        return 7, PMY.MARK_ROLES[7]
    end

    if not ccImmune and effectiveCtype then
        for _, cc in ipairs(PMY.partyCC) do
            if cc.creatureTypes[effectiveCtype] and isFree(cc.icon) then
                return cc.icon, cc.spell .. " (" .. cc.class .. ")"
            end
        end
    end

    if isHeroic and isFree(7) then
        return 7, PMY.MARK_ROLES[7]
    end

    return nil, nil
end

-- Enumerate all visible pack units preferring @nameplateN tokens so /tm [@nameplateN]
-- can target every mob in the pack simultaneously without changing player target.
local function GetPackCandidateUnits()
    local units = {}
    local seenKeys = {}

    local function addCandidate(u)
        if not PMY.IsValidMobToMark(u) then return end
        local key = PMY.GetUnitTrackingKey(u)
        if key and not seenKeys[key] then
            seenKeys[key] = true
            table.insert(units, { unit = u, key = key })
        end
    end

    -- 1. All active/visible nameplates (best for multi-unit /tm [@nameplateX])
    for i = 1, 40 do
        local np = "nameplate" .. i
        if PMY.SafeUnitAPI(UnitExists, np) then
            addCandidate(np)
        end
    end
    for npUnit, _ in pairs(PMY.activeNameplates) do
        if PMY.SafeUnitAPI(UnitExists, npUnit) then
            addCandidate(npUnit)
        end
    end

    -- 2. Also include mouseover and target if they aren't already matched to a nameplate
    if PMY.SafeUnitAPI(UnitExists, "mouseover") then
        local alreadyInList = false
        for _, item in ipairs(units) do
            if PMY.SafeUnitAPI(UnitIsUnit, "mouseover", item.unit) then
                alreadyInList = true
                break
            end
        end
        if not alreadyInList then
            addCandidate("mouseover")
        end
    end

    if PMY.SafeUnitAPI(UnitExists, "target") then
        local alreadyInList = false
        for _, item in ipairs(units) do
            if PMY.SafeUnitAPI(UnitIsUnit, "target", item.unit) then
                alreadyInList = true
                break
            end
        end
        if not alreadyInList then
            addCandidate("target")
        end
    end

    return units
end

function PMY.BuildPackMarkPlan()
    if not PMY.ShouldMark() then return {} end

    local maxMarks = (PMY.db and PMY.db.proximityMarks) or 3
    local currentCount = PMY.CountMarkedMobs()
    local remainingSlots = maxMarks - currentCount
    if remainingSlots <= 0 then
        return {}
    end

    PMY.ScanPartyCC()

    local rawUnits = GetPackCandidateUnits()
    if #rawUnits == 0 then return {} end

    local candidates = {}
    local blindUnits = {}

    for _, info in ipairs(rawUnits) do
        local u   = info.unit
        local key = info.key

        if not PMY.markedGUIDs[key] then
            local existing = PMY.SafeUnitAPI(GetRaidTargetIndex, u)
            if existing and existing >= 1 and existing <= 8 then
                if not PMY.iconToGUID[existing] then
                    PMY.ReserveMark(existing, key, PMY.SafeUnitAPI(UnitName, u))
                end
            else
                local mob = PMY.ClassifyMob(u)
                mob.key = key
                if mob.name and mob.name ~= "Unknown" then
                    PMY.AutoLearnMob(mob)
                    PMY.ScoreMob(mob)
                    if mob.score >= 0 then
                        -- Slight bonus if player is currently targeting or hovering this mob
                        if PMY.SafeUnitAPI(UnitExists, "target") and PMY.SafeUnitAPI(UnitIsUnit, u, "target") then
                            mob.score = mob.score + 15
                        elseif PMY.SafeUnitAPI(UnitExists, "mouseover") and PMY.SafeUnitAPI(UnitIsUnit, u, "mouseover") then
                            mob.score = mob.score + 10
                        end
                        table.insert(candidates, mob)
                    end
                else
                    -- Identity is secret on this unit; queue for blind group marking
                    table.insert(blindUnits, { unit = u, key = key })
                end
            end
        end
    end

    table.sort(candidates, function(a, b) return a.score > b.score end)

    local planList = {}
    local tempUsedIcons = {}

    for _, mob in ipairs(candidates) do
        if #planList >= remainingSlots then break end
        local icon, role = AllocateMarkInPack(mob, tempUsedIcons)
        if icon then
            tempUsedIcons[icon] = true
            table.insert(planList, {
                unit = mob.unit,
                icon = icon,
                key  = mob.key,
                name = mob.name,
                role = role,
                mob  = mob,
            })
        end
    end

    -- If unit identities were secret, allocate blind icons across the visible pack nameplates
    if #planList < remainingSlots and #blindUnits > 0 then
        local blindOrder = BuildBlindIconOrder(tempUsedIcons)
        local bIdx = 1
        for _, bInfo in ipairs(blindUnits) do
            if #planList >= remainingSlots then break end
            while bIdx <= #blindOrder and tempUsedIcons[blindOrder[bIdx]] do
                bIdx = bIdx + 1
            end
            local icon = blindOrder[bIdx]
            if not icon then break end
            tempUsedIcons[icon] = true
            bIdx = bIdx + 1
            table.insert(planList, {
                unit  = bInfo.unit,
                icon  = icon,
                key   = bInfo.key,
                name  = "Pack Mob (" .. bInfo.unit .. ")",
                role  = PMY.MARK_ROLES[icon],
                blind = true,
            })
        end
    end

    return planList
end

-- ============================================================================
-- MULTI-TARGET MACRO BUILDER ("PMY_AutoPack")
-- Marks the entire pack in ONE hardware event using /tm [@nameplateX] <icon>
-- ============================================================================

local function EnsurePackMacro(planList, includeTargetEnemy)
    if InCombatLockdown and InCombatLockdown() then return false end
    if not GetMacroIndexByName or not CreateMacro or not EditMacro then return false end
    if not planList or #planList == 0 then return false end

    local lines = {}
    if includeTargetEnemy then
        table.insert(lines, "/targetenemy")
    end
    for _, item in ipairs(planList) do
        table.insert(lines, "/tm [@" .. item.unit .. "] " .. tostring(item.icon))
    end

    local body = table.concat(lines, "\n")
    if #body > 255 then
        -- Trim if ever exceeding 255 chars
        while #body > 255 and #lines > 1 do
            table.remove(lines)
            body = table.concat(lines, "\n")
        end
    end

    local okIdx, idx = pcall(GetMacroIndexByName, MACRO_NAME)
    if not okIdx then idx = 0 end

    if not idx or idx == 0 then
        local okNum, numGlobal, numPerChar = pcall(GetNumMacros)
        local maxGlobal = MAX_ACCOUNT_MACROS or 120
        local maxChar   = MAX_CHARACTER_MACROS or 30
        if okNum then
            if (numPerChar or 0) < maxChar then
                local okCreate, newIdx = pcall(CreateMacro, MACRO_NAME, MACRO_ICON, body, true)
                if okCreate and newIdx and newIdx > 0 then
                    lastMacroBody = body
                    return true
                end
            end
            if (numGlobal or 0) < maxGlobal then
                local okCreate, newIdx = pcall(CreateMacro, MACRO_NAME, MACRO_ICON, body, nil)
                if okCreate and newIdx and newIdx > 0 then
                    lastMacroBody = body
                    return true
                end
            end
        end
        return false
    else
        if body ~= lastMacroBody then
            local okEdit = pcall(EditMacro, idx, MACRO_NAME, MACRO_ICON, body)
            if not okEdit then return false end
            lastMacroBody = body
        end
        return true
    end
end

-- ============================================================================
-- ON-SCREEN PACK READY HUD BANNER (Draggable & Clickable!)
-- Shows planned group marks when an unmarked pack is in view out of combat.
-- Clicking the banner (or pressing TAB / MouseWheel / Mark Key) marks the group!
-- ============================================================================

local hudFrame = CreateFrame("Frame", "PMY_PackHUDFrame", UIParent, "BackdropTemplate")
hudFrame:SetSize(340, 48)
hudFrame:SetPoint("TOP", UIParent, "TOP", 0, -140)
hudFrame:SetFrameStrata("MEDIUM")
hudFrame:SetMovable(true)
hudFrame:EnableMouse(true)
hudFrame:RegisterForDrag("LeftButton")
hudFrame:SetScript("OnDragStart", hudFrame.StartMoving)
hudFrame:SetScript("OnDragStop", hudFrame.StopMovingOrSizing)
hudFrame:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true, tileSize = 16, edgeSize = 12,
    insets   = { left = 3, right = 3, top = 3, bottom = 3 },
})
hudFrame:Hide()

local hudTitle = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
hudTitle:SetPoint("TOPLEFT", 8, -6)
hudTitle:SetPoint("TOPRIGHT", -8, -6)
hudTitle:SetJustifyH("CENTER")
hudTitle:SetText("|cFFFF3366Psycho Mark's You|r — |cFF00FF00Pack Ready (Press TAB / Scroll / Mark Key)|r")

local hudPlanText = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
hudPlanText:SetPoint("BOTTOMLEFT", 8, 6)
hudPlanText:SetPoint("BOTTOMRIGHT", -8, 6)
hudPlanText:SetJustifyH("CENTER")
hudPlanText:SetWordWrap(false)

local function UpdatePackHUD(planList)
    if not PMY.db or not PMY.db.enabled or not PMY.db.showPackHUD or PMY.inCombat or not planList or #planList == 0 then
        if hudFrame:IsShown() then hudFrame:Hide() end
        return
    end

    local triggers = {}
    if PMY.db.autoMarkOnTab then table.insert(triggers, "TAB") end
    if PMY.db.autoMarkOnWheel then table.insert(triggers, "Scroll") end
    local keyText = PMY.GetMarkMobBindingText()
    if keyText then table.insert(triggers, keyText) end
    local trigStr = (#triggers > 0) and ("Press " .. table.concat(triggers, " / ")) or "Press Mark Key"

    hudTitle:SetText("|cFFFF3366Psycho Mark's You|r — |cFF00FF00Pack Detected (" .. #planList .. " marks): " .. trigStr .. "|r")

    local parts = {}
    for _, item in ipairs(planList) do
        table.insert(parts, PMY.GetIconText(item.icon) .. " " .. tostring(item.name or item.unit))
    end
    hudPlanText:SetText(table.concat(parts, "   |cFF666666•|r   "))
    if not hudFrame:IsShown() then
        hudFrame:Show()
    end
end

-- ============================================================================
-- AUTOMATIC HARDWARE TRIGGERS (TAB & MOUSE WHEEL INTERCEPT WHEN PACK APPEARS)
-- ============================================================================

local function DisarmAutoTriggers()
    if not autoTriggersArmed then return end
    if InCombatLockdown and InCombatLockdown() then
        PMY.RunOutOfCombat("DisarmAutoTriggers", function()
            ClearOverrideBindings(autoTriggerOwner)
            autoTriggersArmed = false
        end)
        return
    end
    ClearOverrideBindings(autoTriggerOwner)
    autoTriggersArmed = false
end

local function ArmAutoTriggersForPack(planList)
    if InCombatLockdown and InCombatLockdown() then return end
    if not PMY.db or not PMY.db.enabled or PMY.inCombat or not planList or #planList == 0 then
        DisarmAutoTriggers()
        return
    end

    local wantTab   = PMY.db.autoMarkOnTab == true
    local wantWheel = PMY.db.autoMarkOnWheel == true
    if not wantTab and not wantWheel then
        DisarmAutoTriggers()
        return
    end

    -- Pre-build the macro so it's ready before the user presses TAB or scrolls
    EnsurePackMacro(planList, false)

    if not autoTriggersArmed then
        ClearOverrideBindings(autoTriggerOwner)
        if wantTab then
            SetOverrideBindingClick(autoTriggerOwner, true, "TAB", "PMY_MarkMobButton", "TabTrigger")
        end
        if wantWheel then
            SetOverrideBindingClick(autoTriggerOwner, true, "MOUSEWHEELUP", "PMY_MarkMobButton", "WheelTrigger")
            SetOverrideBindingClick(autoTriggerOwner, true, "MOUSEWHEELDOWN", "PMY_MarkMobButton", "WheelTrigger")
        end
        autoTriggersArmed = true
        PMY.Debug("Auto-pack triggers armed for " .. #planList .. " mobs.")
    end
end

function PMY.RefreshAutoPackState()
    if InCombatLockdown and InCombatLockdown() then
        UpdatePackHUD(nil)
        return
    end
    if not PMY.ShouldMark() or PMY.inCombat then
        DisarmAutoTriggers()
        UpdatePackHUD(nil)
        return
    end

    local planList = PMY.BuildPackMarkPlan()
    if #planList > 0 then
        ArmAutoTriggersForPack(planList)
        UpdatePackHUD(planList)
    else
        DisarmAutoTriggers()
        UpdatePackHUD(nil)
    end
end

function PMY.StartAutoPackWatcher()
    if PMY.autoPackTicker then
        PMY.autoPackTicker:Cancel()
    end
    PMY.autoPackTicker = C_Timer.NewTicker(0.30, function()
        if PMY.IsMarkingProtected() then
            PMY.RefreshAutoPackState()
        end
    end)
end

-- ============================================================================
-- SECURE BUTTON PRECLICK / POSTCLICK HANDLERS
-- ============================================================================

markBtn:SetScript("PreClick", function(self, button, down)
    if InCombatLockdown and InCombatLockdown() then return end

    -- Reuse pendingPlan on key-up if already computed on key-down
    local planList = pendingPlan
    if not planList or #planList == 0 then
        planList = PMY.BuildPackMarkPlan()
        pendingPlan = planList
    end

    if not planList or #planList == 0 then
        self:SetAttribute("type", "raidtarget")
        self:SetAttribute("unit", "none")
        self:SetAttribute("marker", nil)
        return
    end

    local isTabTrigger = (button == "TabTrigger")
    local usedMacro = EnsurePackMacro(planList, isTabTrigger)

    if usedMacro then
        self:SetAttribute("type", "macro")
        self:SetAttribute("macro", MACRO_NAME)
        self:SetAttribute("unit", nil)
        self:SetAttribute("marker", nil)
    else
        -- Fallback if macro slots are 100% full: mark highest priority mob via raidtarget
        local top = planList[1]
        self:SetAttribute("type", "raidtarget")
        self:SetAttribute("action", "set-unmarked")
        self:SetAttribute("unit", top.unit)
        self:SetAttribute("marker", top.icon)
        pendingPlan = { top }
    end
end)

markBtn:SetScript("PostClick", function(self, button, down)
    -- SecureActionButton with useOnKeyDown=false fires the action on key-up (down == false)
    if down then return end

    if not InCombatLockdown or not InCombatLockdown() then
        self:SetAttribute("type", "raidtarget")
        self:SetAttribute("action", "set-unmarked")
        self:SetAttribute("unit", nil)
        self:SetAttribute("marker", nil)
        self:SetAttribute("macro", nil)
    end

    local appliedList = pendingPlan
    pendingPlan = nil

    if appliedList and #appliedList > 0 then
        for _, item in ipairs(appliedList) do
            if item.key then
                PMY.ReserveMark(item.icon, item.key, item.name)
            end
            if item.mob then
                item.mob.assignedMark = item.icon
                item.mob.assignedRole = item.role
                table.insert(PMY.packMobs, item.mob)
            end
            PMY.Debug("AutoPack Marked: " .. tostring(item.name or item.unit)
                .. " -> " .. PMY.GetIconText(item.icon) .. " (" .. tostring(item.role or "") .. ")")
        end
    end

    -- Immediately release TAB / MouseWheel intercept now that the group is marked!
    DisarmAutoTriggers()
    UpdatePackHUD(nil)
end)

-- Allow binding Mark Group directly from the /pmy General > Keybindings UI
function PMY.BindMarkMobKey(key)
    PMY.RunOutOfCombat("BindMarkMobKey", function()
        ClearOverrideBindings(markBtn)
        if key and key ~= "" then
            SetOverrideBindingClick(markBtn, true, key, "PMY_MarkMobButton", "LeftButton")
            PMY.Debug("Mark Group key bound to: " .. key)
        else
            PMY.Debug("Mark Group in-addon key unbound.")
        end
    end)
end
