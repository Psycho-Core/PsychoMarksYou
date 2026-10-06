-- ============================================================================
-- Psycho Mark's You - Database Browser & Editor Tab
-- Features expandable "WoW Forever" & "Classic" dungeon/raid tree, danger
-- badges, CC immunity flags, and tactical mob tooltips.
-- ============================================================================

local PMY = PsychoMarksYou

function PMY.BuildDatabaseTab(tab3)
    local selectedZone = "The Hall of Thanes"
    local filterText   = ""
    local addMobZone   = ""

    local dbDesc = tab3:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    dbDesc:SetPoint("TOPLEFT", 12, -8)
    dbDesc:SetPoint("RIGHT", tab3, "RIGHT", -12, 0)
    dbDesc:SetJustifyH("LEFT")
    dbDesc:SetText("|cFFFF3366Target Priority Database:|r Edit default marks, CC roles, danger, and tactical notes. Note-only entries have no default priority.")

    local addZoneLabel = tab3:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    addZoneLabel:SetPoint("TOPLEFT", 12, -28)
    addZoneLabel:SetText("Zone:")

    local addZoneBtn = CreateFrame("Button", nil, tab3, "UIPanelButtonTemplate")
    addZoneBtn:SetSize(155, 20)
    addZoneBtn:SetPoint("LEFT", addZoneLabel, "RIGHT", 4, 0)
    addZoneBtn:SetText("Current Zone")

    local addMobLabel = tab3:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    addMobLabel:SetPoint("LEFT", addZoneBtn, "RIGHT", 8, 0)
    addMobLabel:SetText("Mob:")

    local addMobBox = CreateFrame("EditBox", nil, tab3, "InputBoxTemplate")
    addMobBox:SetSize(140, 20)
    addMobBox:SetPoint("LEFT", addMobLabel, "RIGHT", 6, 0)
    addMobBox:SetAutoFocus(false)

    local useTargetBtn = CreateFrame("Button", nil, tab3, "UIPanelButtonTemplate")
    useTargetBtn:SetSize(56, 20)
    useTargetBtn:SetPoint("LEFT", addMobBox, "RIGHT", 4, 0)
    useTargetBtn:SetText("Target")
    useTargetBtn:SetScript("OnClick", function()
        if PMY.SafeUnitAPI(UnitExists, "target") then
            local tName = PMY.SafeUnitAPI(UnitName, "target")
            if tName then addMobBox:SetText(tName) end
        else
            PMY.Print("No target selected.")
        end
    end)

    local addMarkIdx = 8
    local markCycleOrder = { 8, 7, 6, 5, 4, 3, 2, 1, "SKIP" }
    local addMarkBtn = CreateFrame("Button", nil, tab3, "UIPanelButtonTemplate")
    addMarkBtn:SetSize(74, 20)
    addMarkBtn:SetPoint("LEFT", useTargetBtn, "RIGHT", 4, 0)

    local function UpdateAddMarkBtnText()
        if addMarkIdx == "SKIP" then
            addMarkBtn:SetText("|cFF888888SKIP|r")
        else
            addMarkBtn:SetText(PMY.GetIconText(addMarkIdx))
        end
    end
    UpdateAddMarkBtnText()

    addMarkBtn:SetScript("OnClick", function()
        for idx, val in ipairs(markCycleOrder) do
            if val == addMarkIdx then
                local nextIdx = (idx % #markCycleOrder) + 1
                addMarkIdx = markCycleOrder[nextIdx]
                break
            end
        end
        UpdateAddMarkBtnText()
    end)

    local addSaveBtn = CreateFrame("Button", nil, tab3, "UIPanelButtonTemplate")
    addSaveBtn:SetSize(46, 20)
    addSaveBtn:SetPoint("LEFT", addMarkBtn, "RIGHT", 4, 0)
    addSaveBtn:SetText("Save")

    local searchLabel = tab3:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    searchLabel:SetPoint("TOPLEFT", 12, -54)
    searchLabel:SetText("Filter:")

    local searchBox = CreateFrame("EditBox", nil, tab3, "InputBoxTemplate")
    searchBox:SetSize(180, 18)
    searchBox:SetPoint("LEFT", searchLabel, "RIGHT", 6, 0)
    searchBox:SetAutoFocus(false)

    local clearFilterBtn = CreateFrame("Button", nil, tab3, "UIPanelButtonTemplate")
    clearFilterBtn:SetSize(48, 18)
    clearFilterBtn:SetPoint("LEFT", searchBox, "RIGHT", 4, 0)
    clearFilterBtn:SetText("Clear")

    local showModOnly = false
    local modOnlyCheck = CreateFrame("CheckButton", nil, tab3, "UICheckButtonTemplate")
    modOnlyCheck:SetSize(22, 22)
    modOnlyCheck:SetPoint("LEFT", clearFilterBtn, "RIGHT", 8, 0)
    local modOnlyLabel = modOnlyCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    modOnlyLabel:SetPoint("LEFT", modOnlyCheck, "RIGHT", 2, 0)
    modOnlyLabel:SetText("Custom/Modified Only")

    local resetZoneBtn = CreateFrame("Button", nil, tab3, "UIPanelButtonTemplate")
    resetZoneBtn:SetSize(100, 18)
    resetZoneBtn:SetPoint("RIGHT", tab3, "RIGHT", -12, 0)
    resetZoneBtn:SetPoint("TOP", searchBox, "TOP", 0, 0)
    resetZoneBtn:SetText("Reset Zone")

    local ZONE_LIST_W = 185
    local PANEL_TOP   = -78
    local PANEL_BOT   = 8

    local zonePanel = CreateFrame("Frame", nil, tab3, "BackdropTemplate")
    zonePanel:SetPoint("TOPLEFT", 10, PANEL_TOP)
    zonePanel:SetPoint("BOTTOMLEFT", 10, PANEL_BOT)
    zonePanel:SetWidth(ZONE_LIST_W)
    zonePanel:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })

    local zoneScroll = CreateFrame("ScrollFrame", "PMY_ZoneScrollFrame", zonePanel, "UIPanelScrollFrameTemplate")
    zoneScroll:SetPoint("TOPLEFT", 4, -4)
    zoneScroll:SetPoint("BOTTOMRIGHT", -24, 4)

    local zoneContent = CreateFrame("Frame", nil, zoneScroll)
    zoneContent:SetWidth(ZONE_LIST_W - 30)
    zoneContent:SetHeight(1)
    zoneScroll:SetScrollChild(zoneContent)

    local mobPanel = CreateFrame("Frame", nil, tab3, "BackdropTemplate")
    mobPanel:SetPoint("TOPLEFT", zonePanel, "TOPRIGHT", 6, 0)
    mobPanel:SetPoint("BOTTOMRIGHT", tab3, "BOTTOMRIGHT", -10, PANEL_BOT)
    mobPanel:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })

    local mobHeader = CreateFrame("Frame", nil, mobPanel)
    mobHeader:SetPoint("TOPLEFT", 6, -4)
    mobHeader:SetPoint("TOPRIGHT", -26, -4)
    mobHeader:SetHeight(18)

    local hdrName = mobHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hdrName:SetPoint("LEFT", 4, 0)
    hdrName:SetText("|cFFFFCC00Mob Name (Hover for Notes)|r")

    local hdrSource = mobHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hdrSource:SetPoint("RIGHT", -155, 0)
    hdrSource:SetText("|cFFFFCC00Type/Info|r")

    local hdrDanger = mobHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hdrDanger:SetPoint("RIGHT", -115, 0)
    hdrDanger:SetText("|cFFFFCC00Dng|r")

    local hdrMark = mobHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hdrMark:SetPoint("RIGHT", -48, 0)
    hdrMark:SetText("|cFFFFCC00Mark|r")

    local hdrAct = mobHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hdrAct:SetPoint("RIGHT", -4, 0)
    hdrAct:SetText("|cFFFFCC00Act|r")

    local hdrSep = mobPanel:CreateTexture(nil, "ARTWORK")
    hdrSep:SetPoint("TOPLEFT", 6, -22)
    hdrSep:SetPoint("TOPRIGHT", -6, -22)
    hdrSep:SetHeight(1)
    hdrSep:SetColorTexture(0.4, 0.4, 0.4, 0.6)

    local mobScroll = CreateFrame("ScrollFrame", "PMY_MobScrollFrame", mobPanel, "UIPanelScrollFrameTemplate")
    mobScroll:SetPoint("TOPLEFT", 4, -24)
    mobScroll:SetPoint("BOTTOMRIGHT", -24, 4)

    local mobContent = CreateFrame("Frame", nil, mobScroll)
    mobContent:SetWidth(mobPanel:GetWidth() - 32)
    mobContent:SetHeight(1)
    mobScroll:SetScrollChild(mobContent)

    local zoneButtons   = {}
    local mobRows       = {}
    local EXPANSION_DEFS = PsychoMarksYou_ExpansionOrder or {}
    local expandedExps   = { ["WoW Forever"] = true }
    local RefreshZoneList
    local RefreshMobList

    local function CountZoneMobs(zKey)
        local merged = {}
        if PsychoMarksYou_DefaultMobs and PsychoMarksYou_DefaultMobs[zKey] then
            for mName, _ in pairs(PsychoMarksYou_DefaultMobs[zKey]) do
                merged[mName] = true
            end
        end
        if PMY.db and PMY.db.customMobs and PMY.db.customMobs[zKey] then
            for mName, _ in pairs(PMY.db.customMobs[zKey]) do
                merged[mName] = true
            end
        end
        local c = 0
        for _ in pairs(merged) do c = c + 1 end
        return c
    end

    local function GetExtraCustomZones()
        local known = { ["*"] = true }
        for _, exp in ipairs(EXPANSION_DEFS) do
            for _, z in ipairs(exp.dungeons) do known[z] = true end
            for _, z in ipairs(exp.raids)    do known[z] = true end
        end
        if PsychoMarksYou_DefaultMobs then
            for z, _ in pairs(PsychoMarksYou_DefaultMobs) do known[z] = true end
        end
        local extras = {}
        if PMY.db and PMY.db.customMobs then
            for z, mobs in pairs(PMY.db.customMobs) do
                if not known[z] and next(mobs) ~= nil then
                    table.insert(extras, z)
                end
            end
        end
        table.sort(extras)
        return extras
    end

    local function AcquireZoneRow(idx)
        local btn = zoneButtons[idx]
        if not btn then
            btn = CreateFrame("Button", nil, zoneContent)
            btn:SetHeight(20)
            btn.bg = btn:CreateTexture(nil, "BACKGROUND")
            btn.bg:SetAllPoints()
            btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            btn.text:SetPoint("LEFT", 6, 0)
            btn.text:SetPoint("RIGHT", -4, 0)
            btn.text:SetJustifyH("LEFT")
            btn.text:SetWordWrap(false)
            zoneButtons[idx] = btn
        end
        return btn
    end

    RefreshZoneList = function()
        for _, btn in ipairs(zoneButtons) do btn:Hide() end

        local rowIdx = 0
        local yOff   = 0
        local rowW   = ZONE_LIST_W - 30

        local function AddSelectRow(key, displayText, indent)
            rowIdx = rowIdx + 1
            local btn = AcquireZoneRow(rowIdx)
            btn:SetWidth(rowW)
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", 0, yOff)
            btn.text:SetPoint("LEFT", indent or 6, 0)
            btn.text:SetText(displayText)

            local isSel = (selectedZone == key)
            if isSel then
                btn.bg:SetColorTexture(0.55, 0.12, 0.25, 0.65)
            else
                btn.bg:SetColorTexture(0, 0, 0, 0)
            end

            btn:SetScript("OnEnter", function(self)
                if selectedZone ~= key then
                    self.bg:SetColorTexture(0.3, 0.3, 0.3, 0.4)
                end
            end)
            btn:SetScript("OnLeave", function(self)
                if selectedZone ~= key then
                    self.bg:SetColorTexture(0, 0, 0, 0)
                end
            end)
            btn:SetScript("OnClick", function()
                selectedZone = key
                if key ~= "__ALL__" then
                    addMobZone = key
                    addZoneBtn:SetText(key == "*" and "Global (*)" or key)
                end
                RefreshZoneList()
                RefreshMobList()
            end)

            btn:Show()
            yOff = yOff - 20
        end

        local function AddSubHeader(label)
            rowIdx = rowIdx + 1
            local btn = AcquireZoneRow(rowIdx)
            btn:SetWidth(rowW)
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", 0, yOff)
            btn.text:SetPoint("LEFT", 10, 0)
            btn.text:SetText("|cFF999999" .. label .. "|r")
            btn.bg:SetColorTexture(0.12, 0.12, 0.12, 0.5)
            btn:SetScript("OnEnter", nil)
            btn:SetScript("OnLeave", nil)
            btn:SetScript("OnClick", nil)
            btn:Show()
            yOff = yOff - 18
        end

        AddSelectRow("__ALL__", "|cFF00CCFF[All Zones]|r", 6)
        local globCount = CountZoneMobs("*")
        AddSelectRow("*", "|cFFFFCC00* Global Overrides|r |cFF888888(" .. globCount .. ")|r", 6)

        local extraZones = GetExtraCustomZones()
        if #extraZones > 0 then
            AddSubHeader("Learned / Custom Zones")
            for _, zKey in ipairs(extraZones) do
                local cnt = CountZoneMobs(zKey)
                AddSelectRow(zKey, "|cFF00FF88" .. zKey .. "|r |cFF888888(" .. cnt .. ")|r", 14)
            end
        end

        for _, exp in ipairs(EXPANSION_DEFS) do
            local expName  = exp.name
            local isOpen   = expandedExps[expName]
            local arrow    = isOpen and "|cFFFFCC00[-]|r " or "|cFFFFCC00[+]|r "
            local totalZ   = #exp.dungeons + #exp.raids
            local expColor = (expName == "WoW Forever") and "|cFFFF3366" or "|cFFFFD100"

            rowIdx = rowIdx + 1
            local hdrBtn = AcquireZoneRow(rowIdx)
            hdrBtn:SetWidth(rowW)
            hdrBtn:ClearAllPoints()
            hdrBtn:SetPoint("TOPLEFT", 0, yOff)
            hdrBtn.text:SetPoint("LEFT", 4, 0)
            hdrBtn.text:SetText(arrow .. expColor .. expName .. "|r |cFF888888(" .. totalZ .. ")|r")
            hdrBtn.bg:SetColorTexture(0.22, 0.15, 0.08, 0.65)
            hdrBtn:SetScript("OnEnter", function(self)
                self.bg:SetColorTexture(0.32, 0.22, 0.10, 0.8)
            end)
            hdrBtn:SetScript("OnLeave", function(self)
                self.bg:SetColorTexture(0.22, 0.15, 0.08, 0.65)
            end)
            hdrBtn:SetScript("OnClick", function()
                expandedExps[expName] = not expandedExps[expName]
                RefreshZoneList()
            end)
            hdrBtn:Show()
            yOff = yOff - 21

            if isOpen then
                if #exp.dungeons > 0 then
                    AddSubHeader("Dungeons (" .. #exp.dungeons .. ")")
                    for _, zKey in ipairs(exp.dungeons) do
                        local cnt = CountZoneMobs(zKey)
                        local hasCustom = PMY.db and PMY.db.customMobs and PMY.db.customMobs[zKey] and next(PMY.db.customMobs[zKey]) ~= nil
                        local prefix = hasCustom and "|cFF00FF88* |r" or ""
                        AddSelectRow(zKey, prefix .. zKey .. " |cFF888888(" .. cnt .. ")|r", 16)
                    end
                end
                if #exp.raids > 0 then
                    AddSubHeader("Raids (" .. #exp.raids .. ")")
                    for _, zKey in ipairs(exp.raids) do
                        local cnt = CountZoneMobs(zKey)
                        local hasCustom = PMY.db and PMY.db.customMobs and PMY.db.customMobs[zKey] and next(PMY.db.customMobs[zKey]) ~= nil
                        local prefix = hasCustom and "|cFF00FF88* |r" or ""
                        AddSelectRow(zKey, prefix .. "|cFFFF8800" .. zKey .. "|r |cFF888888(" .. cnt .. ")|r", 16)
                    end
                end
            end
        end

        zoneContent:SetHeight(math.max(1, -yOff))
    end

    local function CollectMobEntries()
        local results = {}
        local zonesToScan = {}

        if selectedZone == "__ALL__" then
            table.insert(zonesToScan, "*")
            local seenZ = { ["*"] = true }
            for _, exp in ipairs(EXPANSION_DEFS) do
                for _, z in ipairs(exp.dungeons) do
                    if not seenZ[z] then seenZ[z] = true; table.insert(zonesToScan, z) end
                end
                for _, z in ipairs(exp.raids) do
                    if not seenZ[z] then seenZ[z] = true; table.insert(zonesToScan, z) end
                end
            end
            for _, z in ipairs(GetExtraCustomZones()) do
                if not seenZ[z] then seenZ[z] = true; table.insert(zonesToScan, z) end
            end
        else
            table.insert(zonesToScan, selectedZone)
        end

        local lowerFilter = string.lower(filterText or "")

        for _, zKey in ipairs(zonesToScan) do
            local defTable = (PsychoMarksYou_DefaultMobs and PsychoMarksYou_DefaultMobs[zKey]) or {}
            local cusTable = (PMY.db and PMY.db.customMobs and PMY.db.customMobs[zKey]) or {}

            local allNames = {}
            for mName, _ in pairs(defTable) do allNames[mName] = true end
            for mName, _ in pairs(cusTable) do allNames[mName] = true end

            for mName, _ in pairs(allNames) do
                local defRaw   = defTable[mName]
                local cusRaw   = cusTable[mName]
                local defVal   = PMY.GetEntryMark(defRaw)
                local cusVal   = PMY.GetEntryMark(cusRaw)
                local activeRaw = (cusRaw ~= nil) and cusRaw or defRaw
                local activeVal = (cusVal ~= nil) and cusVal or defVal
                local ctype     = PMY.GetEntryCreatureType(activeRaw) or PMY.GetEntryCreatureType(defRaw)
                local ccImm     = PMY.GetEntryCCImmune(activeRaw) or PMY.GetEntryCCImmune(defRaw)
                local danger    = PMY.GetEntryDangerLevel(activeRaw) or PMY.GetEntryDangerLevel(defRaw)
                local note      = PMY.GetEntryNote(activeRaw) or PMY.GetEntryNote(defRaw)
                local isCustom  = (cusRaw ~= nil and defRaw == nil)
                local isMod     = (cusRaw ~= nil and defRaw ~= nil and (
                    cusVal ~= defVal
                    or PMY.GetEntryDangerLevel(cusRaw) ~= PMY.GetEntryDangerLevel(defRaw)
                ))

                local passFilter = true
                if showModOnly and not (isCustom or isMod) then
                    passFilter = false
                end
                if passFilter and lowerFilter ~= "" then
                    local matchName = string.find(string.lower(mName), lowerFilter, 1, true)
                    local matchZone = string.find(string.lower(zKey), lowerFilter, 1, true)
                    local matchNote = note and string.find(string.lower(note), lowerFilter, 1, true)
                    if not matchName and not matchZone and not matchNote then
                        passFilter = false
                    end
                end

                if passFilter then
                    table.insert(results, {
                        zone         = zKey,
                        name         = mName,
                        mark         = activeVal,
                        defaultMark  = defVal,
                        creatureType = ctype,
                        ccImmune     = ccImm,
                        dangerLevel  = danger,
                        note         = note,
                        isCustom     = isCustom,
                        isModified   = isMod,
                    })
                end
            end
        end

        table.sort(results, function(a, b)
            local ma = (type(a.mark) == "number") and a.mark or 0
            local mb = (type(b.mark) == "number") and b.mark or 0
            if ma ~= mb then return ma > mb end
            local da = a.dangerLevel or 1
            local db = b.dangerLevel or 1
            if da ~= db then return da > db end
            return a.name < b.name
        end)

        return results
    end

    RefreshMobList = function()
        for _, row in ipairs(mobRows) do row:Hide() end

        local entries = CollectMobEntries()
        local yOff = 0
        local rowW = mobPanel:GetWidth() - 34

        for idx, entry in ipairs(entries) do
            local row = mobRows[idx]
            if not row then
                row = CreateFrame("Button", nil, mobContent)
                row:SetHeight(22)
                row:EnableMouse(true)

                row.bg = row:CreateTexture(nil, "BACKGROUND")
                row.bg:SetAllPoints()

                row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                row.nameText:SetPoint("LEFT", 4, 0)
                row.nameText:SetWidth(195)
                row.nameText:SetJustifyH("LEFT")
                row.nameText:SetWordWrap(false)

                row.sourceText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                row.sourceText:SetPoint("RIGHT", -150, 0)
                row.sourceText:SetWidth(95)
                row.sourceText:SetJustifyH("RIGHT")

                row.dangerBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
                row.dangerBtn:SetSize(32, 18)
                row.dangerBtn:SetPoint("RIGHT", -112, 0)

                row.markBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
                row.markBtn:SetSize(68, 18)
                row.markBtn:SetPoint("RIGHT", -40, 0)

                row.actBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
                row.actBtn:SetSize(34, 18)
                row.actBtn:SetPoint("RIGHT", -2, 0)

                mobRows[idx] = row
            end

            row:SetWidth(rowW)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, yOff)

            if idx % 2 == 0 then
                row.bg:SetColorTexture(0.15, 0.15, 0.15, 0.45)
            else
                row.bg:SetColorTexture(0.08, 0.08, 0.08, 0.25)
            end

            local displayName = entry.name
            if selectedZone == "__ALL__" then
                local shortZ = (entry.zone == "*") and "Global" or entry.zone
                displayName = "|cFF888888[" .. shortZ .. "]|r " .. entry.name
            end
            row.nameText:SetText(displayName)

            -- Tooltip with tactical notes when hovering row
            row:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine("|cFFFF3366" .. entry.name .. "|r")
                GameTooltip:AddLine("Zone: |cFFFFCC00" .. entry.zone .. "|r", 0.8, 0.8, 0.8)
                if entry.creatureType then
                    local imm = entry.ccImmune and " |cFFFF4444(CC Immune)|r" or ""
                    GameTooltip:AddLine("Creature Type: |cFFFFFFFF" .. entry.creatureType .. "|r" .. imm, 0.8, 0.8, 0.8)
                end
                if entry.mark == "SKIP" then
                    GameTooltip:AddLine("Preferred Mark: |cFF888888SKIP (Do Not Mark)|r", 0.8, 0.8, 0.8)
                elseif type(entry.mark) == "number" then
                    GameTooltip:AddLine("Preferred Mark: " .. PMY.GetIconText(entry.mark) .. " (" .. (PMY.MARK_ROLES[entry.mark] or "") .. ")", 0.8, 0.8, 0.8)
                end
                if entry.note then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("|cFFFFCC66Tactical Note:|r " .. entry.note, 1, 1, 1, true)
                end
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            local ctypeShort = entry.creatureType or ""
            local immFlag = entry.ccImmune and "|cFFFF4444!|r" or ""
            if entry.isCustom then
                row.sourceText:SetText("|cFF00FF88" .. (ctypeShort ~= "" and ctypeShort or "Custom") .. "|r" .. immFlag)
            elseif entry.isModified then
                row.sourceText:SetText("|cFFFFAA00" .. (ctypeShort ~= "" and ctypeShort or "Edited") .. "|r" .. immFlag)
            elseif entry.mark == nil and entry.note then
                row.sourceText:SetText("|cFF777777Note|r")
            else
                row.sourceText:SetText("|cFF777777" .. (ctypeShort ~= "" and ctypeShort or "Default") .. "|r" .. immFlag)
            end

            local effDanger = entry.dangerLevel
            if not effDanger then
                effDanger = (entry.mark == 8 or entry.mark == 7) and 2 or 1
            end
            if entry.mark == "SKIP" then
                row.dangerBtn:SetText("|cFF555555-|r")
                row.dangerBtn:Disable()
            else
                row.dangerBtn:Enable()
                local dangerLabels = {
                    [1] = "|cFF8888881|r",
                    [2] = "|cFFFFAA002|r",
                    [3] = "|cFFFF33333!|r",
                }
                row.dangerBtn:SetText(dangerLabels[effDanger] or "|cFF8888881|r")
            end

            row.dangerBtn:SetScript("OnClick", function()
                if entry.mark == "SKIP" then return end
                local nextDanger = (effDanger % 3) + 1
                if not PMY.db.customMobs[entry.zone] then
                    PMY.db.customMobs[entry.zone] = {}
                end
                PMY.db.customMobs[entry.zone][entry.name] = {
                    mark         = entry.mark,
                    creatureType = entry.creatureType,
                    ccImmune     = entry.ccImmune or nil,
                    dangerLevel  = nextDanger,
                    note         = entry.note,
                }
                RefreshZoneList()
                RefreshMobList()
            end)

            row.dangerBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine("Danger Level: " .. effDanger)
                GameTooltip:AddLine("|cFF8888881 = Normal (melee, pack filler)|r", 1, 1, 1)
                GameTooltip:AddLine("|cFFFFAA002 = High (casters, AoE, heavy hitters)|r", 1, 1, 1)
                GameTooltip:AddLine("|cFFFF33333 = Critical (healers, summoners, fears, silences)|r", 1, 1, 1)
                GameTooltip:AddLine("Click to cycle danger level.", 0.5, 0.8, 1)
                GameTooltip:Show()
            end)
            row.dangerBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

            if entry.mark == "SKIP" then
                row.markBtn:SetText("|cFF888888SKIP|r")
            else
                row.markBtn:SetText(PMY.GetIconText(entry.mark))
            end

            row.markBtn:SetScript("OnClick", function()
                local curMark = entry.mark
                local nextMark = 8
                for cIdx, val in ipairs(markCycleOrder) do
                    if val == curMark then
                        nextMark = markCycleOrder[(cIdx % #markCycleOrder) + 1]
                        break
                    end
                end
                if not PMY.db.customMobs[entry.zone] then
                    PMY.db.customMobs[entry.zone] = {}
                end
                local defEntry = PsychoMarksYou_DefaultMobs
                    and PsychoMarksYou_DefaultMobs[entry.zone]
                    and PsychoMarksYou_DefaultMobs[entry.zone][entry.name]
                local defMark   = PMY.GetEntryMark(defEntry)
                local defDanger = PMY.GetEntryDangerLevel(defEntry)
                if defEntry ~= nil and nextMark == defMark and entry.dangerLevel == defDanger then
                    PMY.db.customMobs[entry.zone][entry.name] = nil
                elseif nextMark == "SKIP" then
                    PMY.db.customMobs[entry.zone][entry.name] = "SKIP"
                else
                    PMY.db.customMobs[entry.zone][entry.name] = {
                        mark         = nextMark,
                        creatureType = entry.creatureType,
                        ccImmune     = entry.ccImmune or nil,
                        dangerLevel  = entry.dangerLevel,
                        note         = entry.note,
                    }
                end
                RefreshZoneList()
                RefreshMobList()
            end)

            if entry.isCustom then
                row.actBtn:SetText("|cFFFF4444Del|r")
                row.actBtn:Enable()
                row.actBtn:SetScript("OnClick", function()
                    if PMY.db.customMobs[entry.zone] then
                        PMY.db.customMobs[entry.zone][entry.name] = nil
                    end
                    RefreshZoneList()
                    RefreshMobList()
                end)
            elseif entry.isModified then
                row.actBtn:SetText("|cFFFFAA00Rst|r")
                row.actBtn:Enable()
                row.actBtn:SetScript("OnClick", function()
                    if PMY.db.customMobs[entry.zone] then
                        PMY.db.customMobs[entry.zone][entry.name] = nil
                    end
                    RefreshZoneList()
                    RefreshMobList()
                end)
            else
                row.actBtn:SetText("|cFF555555-|r")
                row.actBtn:Disable()
                row.actBtn:SetScript("OnClick", nil)
            end

            row:Show()
            yOff = yOff - 22
        end

        mobContent:SetHeight(math.max(1, -yOff))
    end

    addZoneBtn:SetScript("OnClick", function()
        if addMobZone == "*" then
            local curZ = (PMY.currentZone ~= "" and PMY.currentZone) or selectedZone
            if curZ == "__ALL__" or curZ == "*" then curZ = "The Hall of Thanes" end
            addMobZone = curZ
            addZoneBtn:SetText(curZ)
        else
            addMobZone = "*"
            addZoneBtn:SetText("Global (*)")
        end
    end)

    addSaveBtn:SetScript("OnClick", function()
        local mobName = strtrim(addMobBox:GetText() or "")
        if mobName == "" then
            PMY.Print("Enter a mob name or click 'Target' first.")
            return
        end
        local targetZone = (addMobZone ~= "" and addMobZone) or selectedZone
        if targetZone == "__ALL__" then targetZone = "*" end

        if not PMY.db.customMobs[targetZone] then
            PMY.db.customMobs[targetZone] = {}
        end
        if addMarkIdx == "SKIP" then
            PMY.db.customMobs[targetZone][mobName] = "SKIP"
        else
            local ctype = nil
            if PMY.SafeUnitAPI(UnitExists, "target") and PMY.SafeUnitAPI(UnitName, "target") == mobName then
                local tc = PMY.SafeUnitAPI(UnitCreatureType, "target")
                if tc and tc ~= "Unknown" then ctype = tc end
            end
            if not ctype then
                local existing = PMY.GetMobDBEntry(mobName)
                ctype = PMY.GetEntryCreatureType(existing)
            end
            PMY.db.customMobs[targetZone][mobName] = {
                mark         = addMarkIdx,
                creatureType = ctype,
            }
        end

        local markLabel = (addMarkIdx == "SKIP") and "|cFF888888SKIP|r" or PMY.GetIconText(addMarkIdx)
        PMY.Print("Saved [" .. mobName .. "] in [" .. targetZone .. "] -> " .. markLabel)
        addMobBox:SetText("")
        selectedZone = targetZone
        RefreshZoneList()
        RefreshMobList()
    end)

    searchBox:SetScript("OnTextChanged", function(self)
        filterText = self:GetText() or ""
        RefreshMobList()
    end)
    searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    searchBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

    clearFilterBtn:SetScript("OnClick", function()
        searchBox:SetText("")
        filterText = ""
        RefreshMobList()
    end)

    modOnlyCheck:SetScript("OnClick", function(self)
        showModOnly = self:GetChecked() and true or false
        RefreshMobList()
    end)

    resetZoneBtn:SetScript("OnClick", function()
        if selectedZone == "__ALL__" then
            PMY.db.customMobs = {}
            PMY.Print("All custom overrides cleared across all zones.")
        else
            if PMY.db.customMobs[selectedZone] then
                PMY.db.customMobs[selectedZone] = nil
            end
            PMY.Print("Reset [" .. selectedZone .. "] to default mob priorities.")
        end
        RefreshZoneList()
        RefreshMobList()
    end)

    tab3:SetScript("OnShow", function()
        if PMY.currentZone and PMY.currentZone ~= "" and PsychoMarksYou_DefaultMobs and PsychoMarksYou_DefaultMobs[PMY.currentZone] then
            selectedZone = PMY.currentZone
        end
        if addMobZone == "" then
            addMobZone = (PMY.currentZone ~= "" and PMY.currentZone) or selectedZone
            if addMobZone == "__ALL__" then addMobZone = "The Hall of Thanes" end
            addZoneBtn:SetText(addMobZone == "*" and "Global (*)" or addMobZone)
        end
        RefreshZoneList()
        RefreshMobList()
    end)
end
