-- ============================================================================
-- Psycho Mark's You - Configuration Window (General & Marks/CC Tabs)
-- ============================================================================

local PMY = PsychoMarksYou

function PMY.ToggleConfig()
    if not PMY.configFrame then
        PMY.CreateConfigFrame()
    end
    if PMY.configFrame:IsShown() then
        PMY.configFrame:Hide()
    else
        PMY.configFrame:Show()
    end
end

function PMY.CreateConfigFrame()
    if PMY.configFrame then return end

    local f = CreateFrame("Frame", "PsychoMarksYouConfigFrame", UIParent, "BackdropTemplate")
    f:SetSize(720, 640)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile     = true, tileSize = 32, edgeSize = 32,
        insets   = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    f:Hide()

    tinsert(UISpecialFrames, "PsychoMarksYouConfigFrame")

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText("|cFFFF3366Psycho Mark's|r |cFFFFFFFFYou|r |cFF888888v" .. PMY.VERSION .. "|r")

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)

    local tabNames = { "General", "Marks & CC", "Database", "Forever Guide" }
    local tabs = {}
    local tabFrames = {}

    for idx, tabName in ipairs(tabNames) do
        local tabBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        tabBtn:SetSize(130, 26)
        tabBtn:SetPoint("TOPLEFT", 18 + (idx - 1) * 136, -42)
        tabBtn:SetText(tabName)
        tabs[idx] = tabBtn

        local content = CreateFrame("Frame", nil, f)
        content:SetPoint("TOPLEFT", 16, -74)
        content:SetPoint("BOTTOMRIGHT", -16, 48)
        content:Hide()
        tabFrames[idx] = content

        tabBtn:SetScript("OnClick", function()
            for i, tf in ipairs(tabFrames) do
                if i == idx then
                    tf:Show()
                    tabs[i]:Disable()
                else
                    tf:Hide()
                    tabs[i]:Enable()
                end
            end
        end)
    end

    tabFrames[1]:Show()
    tabs[1]:Disable()

    -- ========================================================================
    -- TAB 1: GENERAL SETTINGS
    -- ========================================================================
    local tab1 = tabFrames[1]
    local yOffset = -4

    local function CreateCheckbox(parent, label, dbKey, onChange)
        local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 12, yOffset)
        cb:SetSize(24, 24)
        local text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        text:SetText(label)
        cb:SetChecked(PMY.db[dbKey])
        cb:SetScript("OnClick", function(self)
            PMY.db[dbKey] = self:GetChecked() and true or false
            if onChange then onChange(PMY.db[dbKey]) end
        end)
        yOffset = yOffset - 23
        return cb
    end

    CreateCheckbox(tab1, "Enable Psycho Mark's You", "enabled", function()
        PMY.UpdateMinimapIcon()
        if PMY.db.enabled then
            PMY.StartProximityScanner()
            if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
        else
            PMY.StopProximityScanner()
            if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
        end
    end)

    CreateCheckbox(tab1, "Auto-Mark Whole Group on TAB Out of Combat (targets enemy + marks entire pack at once)", "autoMarkOnTab", function()
        if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
    end)

    CreateCheckbox(tab1, "Auto-Mark Whole Group on Mouse Wheel Scroll Out of Combat (marks entire pack at once)", "autoMarkOnWheel", function()
        if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
    end)

    CreateCheckbox(tab1, "Show 'Pack Detected' On-Screen Mark Preview HUD Banner Out of Combat", "showPackHUD", function()
        if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
    end)

    CreateCheckbox(tab1, "Show Recommended Mark & Tactical Tip on Mob Tooltips", "showTooltipHint")
    CreateCheckbox(tab1, "Solo Mode (allow marking when not in a party/raid)", "soloMode", function()
        if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
    end)
    CreateCheckbox(tab1, "Only Mark Target's Pack", "onlyTargetPack")
    CreateCheckbox(tab1, "Clear Marks When Combat Ends", "clearOnCombatEnd")
    CreateCheckbox(tab1, "Re-mark Next Priority Mob When Skull/Cross Dies", "reMarkOnDeath")

    CreateCheckbox(tab1, "Hide Minimap Button", "hideMinimapButton", function(val)
        if PMY.minimapButton then
            if val then PMY.minimapButton:Hide() else PMY.minimapButton:Show() end
        end
    end)

    CreateCheckbox(tab1, "Debug Mode (verbose chat output)", "debugMode")

    -- Keybindings Section
    yOffset = yOffset - 4
    local kbHeader = tab1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    kbHeader:SetPoint("TOPLEFT", 14, yOffset)
    kbHeader:SetText("|cFFFF3366Keybindings (Click to Bind):|r")
    yOffset = yOffset - 20

    -- 1. Mark Group Keybinder
    local markKeyLabel = tab1:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    markKeyLabel:SetPoint("TOPLEFT", 18, yOffset - 3)
    markKeyLabel:SetText("Mark Whole Group:")

    local markKeyBindBtn = CreateFrame("Button", nil, tab1, "UIPanelButtonTemplate")
    markKeyBindBtn:SetSize(125, 22)
    markKeyBindBtn:SetPoint("LEFT", markKeyLabel, "RIGHT", 8, 0)

    local isListeningMarkKey = false
    local function UpdateMarkKeyBindBtnText()
        if isListeningMarkKey then
            markKeyBindBtn:SetText("|cFF00FF00Press a key...|r")
        elseif PMY.db.markMobKey and PMY.db.markMobKey ~= "" then
            markKeyBindBtn:SetText("|cFFFFCC00" .. PMY.db.markMobKey .. "|r")
        else
            local blizzardKey = PMY.GetMarkMobBindingText()
            if blizzardKey then
                markKeyBindBtn:SetText("|cFF00FF00" .. blizzardKey .. "|r")
            else
                markKeyBindBtn:SetText("|cFF888888Not Bound|r")
            end
        end
    end
    UpdateMarkKeyBindBtnText()

    local clearMarkKeyBtn = CreateFrame("Button", nil, tab1, "UIPanelButtonTemplate")
    clearMarkKeyBtn:SetSize(56, 22)
    clearMarkKeyBtn:SetPoint("LEFT", markKeyBindBtn, "RIGHT", 4, 0)
    clearMarkKeyBtn:SetText("Unbind")
    clearMarkKeyBtn:SetScript("OnClick", function()
        isListeningMarkKey = false
        markKeyBindBtn:EnableKeyboard(false)
        PMY.db.markMobKey = nil
        PMY.BindMarkMobKey(nil)
        UpdateMarkKeyBindBtnText()
        if f.RefreshForeverKeyNotice then f.RefreshForeverKeyNotice() end
        PMY.Print("Mark Group in-addon keybinding cleared.")
    end)

    markKeyBindBtn:SetScript("OnClick", function(self)
        isListeningMarkKey = not isListeningMarkKey
        self:EnableKeyboard(isListeningMarkKey)
        UpdateMarkKeyBindBtnText()
    end)

    markKeyBindBtn:SetScript("OnKeyDown", function(self, key)
        if not isListeningMarkKey then
            self:SetPropagateKeyboardInput(true)
            return
        end
        self:SetPropagateKeyboardInput(false)
        if key == "LSHIFT" or key == "RSHIFT" or key == "LCTRL" or key == "RCTRL" or key == "LALT" or key == "RALT" then
            return
        end
        isListeningMarkKey = false
        self:EnableKeyboard(false)
        if key == "ESCAPE" then
            UpdateMarkKeyBindBtnText()
            return
        end
        local combo = ""
        if IsControlKeyDown() then combo = combo .. "CTRL-" end
        if IsAltKeyDown()     then combo = combo .. "ALT-" end
        if IsShiftKeyDown()   then combo = combo .. "SHIFT-" end
        combo = combo .. key
        PMY.db.markMobKey = combo
        PMY.BindMarkMobKey(combo)
        UpdateMarkKeyBindBtnText()
        if f.RefreshForeverKeyNotice then f.RefreshForeverKeyNotice() end
        PMY.Print("Mark Group bound to |cFFFFCC00" .. combo .. "|r")
    end)

    -- 2. Clear All Marks Keybinder
    local resetKeyLabel = tab1:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    resetKeyLabel:SetPoint("LEFT", clearMarkKeyBtn, "RIGHT", 18, 0)
    resetKeyLabel:SetText("Clear Marks:")

    local resetBindBtn = CreateFrame("Button", nil, tab1, "UIPanelButtonTemplate")
    resetBindBtn:SetSize(120, 22)
    resetBindBtn:SetPoint("LEFT", resetKeyLabel, "RIGHT", 8, 0)

    local isListeningKey = false
    local function UpdateResetBindBtnText()
        if isListeningKey then
            resetBindBtn:SetText("|cFF00FF00Press a key...|r")
        elseif PMY.db.resetMarksKey and PMY.db.resetMarksKey ~= "" then
            resetBindBtn:SetText("|cFFFFCC00" .. PMY.db.resetMarksKey .. "|r")
        else
            resetBindBtn:SetText("|cFF888888Not Bound|r")
        end
    end
    UpdateResetBindBtnText()

    local clearBindBtn = CreateFrame("Button", nil, tab1, "UIPanelButtonTemplate")
    clearBindBtn:SetSize(56, 22)
    clearBindBtn:SetPoint("LEFT", resetBindBtn, "RIGHT", 4, 0)
    clearBindBtn:SetText("Unbind")
    clearBindBtn:SetScript("OnClick", function()
        isListeningKey = false
        resetBindBtn:EnableKeyboard(false)
        PMY.db.resetMarksKey = nil
        PMY.BindResetMarksKey(nil)
        UpdateResetBindBtnText()
        PMY.Print("Clear All Marks keybinding removed.")
    end)

    resetBindBtn:SetScript("OnClick", function(self)
        isListeningKey = not isListeningKey
        self:EnableKeyboard(isListeningKey)
        UpdateResetBindBtnText()
    end)

    resetBindBtn:SetScript("OnKeyDown", function(self, key)
        if not isListeningKey then
            self:SetPropagateKeyboardInput(true)
            return
        end
        self:SetPropagateKeyboardInput(false)
        if key == "LSHIFT" or key == "RSHIFT" or key == "LCTRL" or key == "RCTRL" or key == "LALT" or key == "RALT" then
            return
        end
        isListeningKey = false
        self:EnableKeyboard(false)
        if key == "ESCAPE" then
            UpdateResetBindBtnText()
            return
        end
        local combo = ""
        if IsControlKeyDown() then combo = combo .. "CTRL-" end
        if IsAltKeyDown()     then combo = combo .. "ALT-" end
        if IsShiftKeyDown()   then combo = combo .. "SHIFT-" end
        combo = combo .. key
        PMY.db.resetMarksKey = combo
        PMY.BindResetMarksKey(combo)
        UpdateResetBindBtnText()
        PMY.Print("Clear All Marks bound to |cFFFFCC00" .. combo .. "|r")
    end)

    yOffset = yOffset - 28

    -- Marking Mode Section
    local modeHeader = tab1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    modeHeader:SetPoint("TOPLEFT", 14, yOffset)
    modeHeader:SetText("|cFFFF3366Automatic Group Marking Engine:|r")
    yOffset = yOffset - 20

    if PMY.IsMarkingProtected() then
        local notice = tab1:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        notice:SetPoint("TOPLEFT", 18, yOffset)
        notice:SetWidth(640)
        notice:SetJustifyH("LEFT")

        local function RefreshNoticeText()
            local keyText = PMY.GetMarkMobBindingText()
            local bindHint = keyText and ("|cFF00FF00" .. keyText .. "|r") or "|cFF888888Unbound|r"
            notice:SetText(
                "|cFFFFCC00Whole-Group Auto-Marker Active:|r Scans all visible enemy nameplates in the pack and builds the " ..
                "|cFF00FF00PMY_AutoPack|r multi-target macro so |cFFFFFFFFall mobs in the group are marked simultaneously|r (Skull + Cross + CC) " ..
                "the moment you press |cFF00FF00TAB|r, scroll your |cFF00FF00Mouse Wheel|r, or press your Mark Group key (" .. bindHint .. ")."
            )
            UpdateMarkKeyBindBtnText()
        end
        f.RefreshForeverKeyNotice = RefreshNoticeText
        RefreshNoticeText()
        tab1:HookScript("OnShow", RefreshNoticeText)
        yOffset = yOffset - 32
    else
        local modeOptions = {
            { value = "proximity", label = "Proximity", desc = "Auto-marks mobs as their nameplates appear nearby" },
            { value = "mouseover", label = "Mouseover", desc = "Marks mobs when you hover your cursor over them" },
            { value = "manual",    label = "Manual",    desc = "Marks when you target a mob while holding modifier key" },
        }
        local modeBtns = {}

        local function UpdateModeButtons()
            local cur = PMY.db.markingMode or "proximity"
            for _, info in ipairs(modeBtns) do
                if info.value == cur then
                    info.btn:Disable()
                else
                    info.btn:Enable()
                end
            end
        end

        for i, opt in ipairs(modeOptions) do
            local mb = CreateFrame("Button", nil, tab1, "UIPanelButtonTemplate")
            mb:SetSize(95, 22)
            mb:SetPoint("TOPLEFT", 18 + (i - 1) * 102, yOffset)
            mb:SetText(opt.label)
            mb:SetScript("OnClick", function()
                PMY.db.markingMode = opt.value
                UpdateModeButtons()
                PMY.Print("Marking mode set to: |cFFFFCC00" .. opt.label .. "|r — " .. opt.desc)
                if opt.value == "proximity" and PMY.db.enabled then
                    PMY.StartProximityScanner()
                else
                    PMY.StopProximityScanner()
                end
            end)
            mb:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:AddLine(opt.label .. " Mode", 1, 0.82, 0)
                GameTooltip:AddLine(opt.desc, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            mb:SetScript("OnLeave", function() GameTooltip:Hide() end)
            table.insert(modeBtns, { value = opt.value, btn = mb })
        end
        UpdateModeButtons()

        local modLabel = tab1:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        modLabel:SetPoint("TOPLEFT", 336, yOffset - 4)
        modLabel:SetText("Manual Key:")

        local modKeys = { "ALT", "CTRL", "SHIFT", "NONE" }
        local modBtns = {}

        local function UpdateModButtons()
            for _, info in ipairs(modBtns) do
                if info.key == PMY.db.markKey then
                    info.btn:Disable()
                else
                    info.btn:Enable()
                end
            end
        end

        for i, mk in ipairs(modKeys) do
            local kb = CreateFrame("Button", nil, tab1, "UIPanelButtonTemplate")
            kb:SetSize(52, 20)
            kb:SetPoint("TOPLEFT", 412 + (i - 1) * 56, yOffset - 1)
            kb:SetText(mk)
            kb:SetScript("OnClick", function()
                PMY.db.markKey = mk
                UpdateModButtons()
            end)
            table.insert(modBtns, { key = mk, btn = kb })
        end
        UpdateModButtons()
        yOffset = yOffset - 28
    end

    local proxCountLabel = tab1:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    proxCountLabel:SetPoint("TOPLEFT", 18, yOffset - 3)
    proxCountLabel:SetText("Max Marks Per Group (1-8):")

    local proxBtns = {}
    local function UpdateProxCountButtons()
        local cur = PMY.db.proximityMarks or 3
        for _, info in ipairs(proxBtns) do
            if info.n == cur then info.btn:Disable() else info.btn:Enable() end
        end
    end

    for n = 1, 8 do
        local pb = CreateFrame("Button", nil, tab1, "UIPanelButtonTemplate")
        pb:SetSize(28, 20)
        pb:SetPoint("TOPLEFT", 180 + (n - 1) * 32, yOffset)
        pb:SetText(tostring(n))
        pb:SetScript("OnClick", function()
            PMY.db.proximityMarks = n
            UpdateProxCountButtons()
            if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
        end)
        table.insert(proxBtns, { n = n, btn = pb })
    end
    UpdateProxCountButtons()
    yOffset = yOffset - 26

    -- Announcements Section
    local annHeader = tab1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    annHeader:SetPoint("TOPLEFT", 14, yOffset)
    annHeader:SetText("|cFFFF3366Party / Raid Announcements:|r")
    yOffset = yOffset - 20

    CreateCheckbox(tab1, "Announce Mark Plan to Chat on Combat Start", "announceParty")

    local chatLabel = tab1:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    chatLabel:SetPoint("TOPLEFT", 18, yOffset - 3)
    chatLabel:SetText("Channel:")

    local chatTypes = { "PARTY", "RAID", "RAID_WARNING", "SAY" }
    local chatBtns = {}

    local function UpdateChatButtons()
        for _, info in ipairs(chatBtns) do
            if info.ct == PMY.db.announceChatType then
                info.btn:Disable()
            else
                info.btn:Enable()
            end
        end
    end

    for i, ct in ipairs(chatTypes) do
        local cb = CreateFrame("Button", nil, tab1, "UIPanelButtonTemplate")
        cb:SetSize(96, 20)
        cb:SetPoint("TOPLEFT", 80 + (i - 1) * 102, yOffset)
        cb:SetText(ct)
        cb:SetScript("OnClick", function()
            PMY.db.announceChatType = ct
            UpdateChatButtons()
        end)
        table.insert(chatBtns, { ct = ct, btn = cb })
    end
    UpdateChatButtons()
    yOffset = yOffset - 24

    local prefixLabel = tab1:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    prefixLabel:SetPoint("TOPLEFT", 18, yOffset - 3)
    prefixLabel:SetText("Chat Prefix:")

    local prefixBox = CreateFrame("EditBox", nil, tab1, "InputBoxTemplate")
    prefixBox:SetSize(160, 20)
    prefixBox:SetPoint("LEFT", prefixLabel, "RIGHT", 8, 0)
    prefixBox:SetAutoFocus(false)
    prefixBox:SetMaxLetters(32)
    prefixBox:SetText(PMY.db.announcePrefix or "Psycho Mark's You")

    local prefixSaveBtn = CreateFrame("Button", nil, tab1, "UIPanelButtonTemplate")
    prefixSaveBtn:SetSize(50, 20)
    prefixSaveBtn:SetPoint("LEFT", prefixBox, "RIGHT", 6, 0)
    prefixSaveBtn:SetText("Save")

    local prefixResetBtn = CreateFrame("Button", nil, tab1, "UIPanelButtonTemplate")
    prefixResetBtn:SetSize(56, 20)
    prefixResetBtn:SetPoint("LEFT", prefixSaveBtn, "RIGHT", 4, 0)
    prefixResetBtn:SetText("Reset")

    local prefixPreview = tab1:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    prefixPreview:SetPoint("LEFT", prefixResetBtn, "RIGHT", 10, 0)

    local function UpdatePrefixPreview()
        local cur = PMY.db.announcePrefix or "Psycho Mark's You"
        prefixPreview:SetText("|cFF888888Preview:|r |cFFFFCC00[" .. cur .. "]|r")
    end
    UpdatePrefixPreview()

    local function SavePrefixValue()
        local val = strtrim(prefixBox:GetText() or "")
        if val == "" then val = "Psycho Mark's You" end
        PMY.db.announcePrefix = val
        prefixBox:SetText(val)
        prefixBox:ClearFocus()
        UpdatePrefixPreview()
        PMY.Print("Announcement prefix set to: |cFFFFCC00[" .. val .. "]|r")
    end

    prefixSaveBtn:SetScript("OnClick", SavePrefixValue)
    prefixBox:SetScript("OnEnterPressed", SavePrefixValue)
    prefixBox:SetScript("OnEscapePressed", function(self)
        self:SetText(PMY.db.announcePrefix or "Psycho Mark's You")
        self:ClearFocus()
    end)

    prefixResetBtn:SetScript("OnClick", function()
        PMY.db.announcePrefix = "Psycho Mark's You"
        prefixBox:SetText("Psycho Mark's You")
        prefixBox:ClearFocus()
        UpdatePrefixPreview()
        PMY.Print("Announcement prefix reset to: |cFFFFCC00[Psycho Mark's You]|r")
    end)

    -- ========================================================================
    -- TAB 2: MARKS & CC CONFIGURATION
    -- ========================================================================
    local tab2 = tabFrames[2]

    local markDesc = tab2:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    markDesc:SetPoint("TOPLEFT", 12, -10)
    markDesc:SetWidth(640)
    markDesc:SetJustifyH("LEFT")
    markDesc:SetText("Uncheck any raid icon below to prevent Psycho Mark's You from assigning it (for example, if your tank uses Star to mark themselves):")

    local iconY = -48
    for iconIdx = 8, 1, -1 do
        local info = PMY.RAID_ICONS[iconIdx]
        local role = PMY.MARK_ROLES[iconIdx] or ""

        local cb = CreateFrame("CheckButton", nil, tab2, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 16, iconY)
        cb:SetSize(26, 26)
        cb:SetChecked(not PMY.db.disabledMarks[iconIdx])

        local iconTex = tab2:CreateTexture(nil, "ARTWORK")
        iconTex:SetSize(20, 20)
        iconTex:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        iconTex:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        iconTex:SetTexCoord(unpack(info.texCoords))

        local label = tab2:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", iconTex, "RIGHT", 8, 0)
        label:SetText(info.color .. info.name .. "|r  —  |cFFFFCC00" .. role .. "|r")

        cb:SetScript("OnClick", function(self)
            if self:GetChecked() then
                PMY.db.disabledMarks[iconIdx] = nil
            else
                PMY.db.disabledMarks[iconIdx] = true
            end
            PMY.ScanPartyCC()
            if PMY.RefreshAutoPackState then PMY.RefreshAutoPackState() end
        end)

        iconY = iconY - 30
    end

    local ccStatusHeader = tab2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ccStatusHeader:SetPoint("TOPLEFT", 16, iconY - 12)
    ccStatusHeader:SetText("|cFFFF3366Detected Party CC Capabilities:|r")

    local ccStatusText = tab2:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    ccStatusText:SetPoint("TOPLEFT", 20, iconY - 34)
    ccStatusText:SetWidth(620)
    ccStatusText:SetJustifyH("LEFT")

    tab2:SetScript("OnShow", function()
        PMY.ScanPartyCC()
        if #PMY.partyCC == 0 then
            ccStatusText:SetText("|cFF888888No CC classes detected in current group (or icons disabled).|r")
        else
            local lines = {}
            for _, cc in ipairs(PMY.partyCC) do
                table.insert(lines, PMY.GetIconText(cc.icon) .. " — " .. cc.spell .. " (" .. cc.class .. ")")
            end
            ccStatusText:SetText(table.concat(lines, "\n"))
        end
    end)

    -- ========================================================================
    -- TAB 3 & TAB 4
    -- ========================================================================
    PMY.BuildDatabaseTab(tabFrames[3])
    PMY.BuildTutorialTab(tabFrames[4])

    -- ========================================================================
    -- BOTTOM ACTION BAR
    -- ========================================================================
    local markNowBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    markNowBtn:SetSize(130, 26)
    markNowBtn:SetPoint("BOTTOMLEFT", 20, 14)
    markNowBtn:SetText("Mark Pack Now")
    markNowBtn:SetScript("OnClick", function()
        if PMY.IsMarkingProtected() then
            PMY.NotifyMarkingBlocked()
        else
            PMY.ScanAndMarkPack("target")
        end
    end)

    local clearAllBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    clearAllBtn:SetSize(130, 26)
    clearAllBtn:SetPoint("LEFT", markNowBtn, "RIGHT", 10, 0)
    clearAllBtn:SetText("Clear All Marks")
    clearAllBtn:SetScript("OnClick", function()
        PMY.ClearAllMarks()
        PMY.Print("All marks cleared.")
    end)

    local announceBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    announceBtn:SetSize(130, 26)
    announceBtn:SetPoint("LEFT", clearAllBtn, "RIGHT", 10, 0)
    announceBtn:SetText("Announce Marks")
    announceBtn:SetScript("OnClick", function()
        PMY.lastAnnounceTime = 0
        PMY.AnnounceMarks()
    end)

    PMY.configFrame = f
end
