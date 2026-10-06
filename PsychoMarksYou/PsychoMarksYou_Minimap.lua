-- ============================================================================
-- Psycho Mark's You - Minimap Button
-- ============================================================================

local PMY = PsychoMarksYou

function PMY.CreateMinimapButton()
    if PMY.minimapButton then return end

    local btn = CreateFrame("Button", "PsychoMarksYouMinimapBtn", Minimap)
    btn:SetSize(32, 32)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local overlay = btn:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetPoint("TOPLEFT")

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetSize(20, 20)
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetPoint("CENTER", 0, 1)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(18, 18)
    icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    icon:SetTexCoord(0.75, 1.0, 0.25, 0.5)
    icon:SetPoint("CENTER", 0, 1)
    btn.icon = icon

    local function UpdatePosition()
        local angle = math.rad(PMY.db and PMY.db.minimapPos or 220)
        local x = math.cos(angle) * 80
        local y = math.sin(angle) * 80
        btn:ClearAllPoints()
        btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end

    btn:SetMovable(true)
    btn:RegisterForDrag("LeftButton")
    local isDragging = false

    btn:SetScript("OnDragStart", function(self)
        isDragging = true
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            cx, cy = cx / scale, cy / scale
            local angle = math.deg(math.atan2(cy - my, cx - mx))
            if PMY.db then PMY.db.minimapPos = angle end
            UpdatePosition()
        end)
    end)

    btn:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        C_Timer.After(0.05, function() isDragging = false end)
    end)

    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:SetScript("OnClick", function(self, button)
        if isDragging then return end
        if button == "LeftButton" then
            PMY.ToggleConfig()
        elseif button == "RightButton" then
            if IsShiftKeyDown() then
                PMY.ClearAllMarks()
                PMY.Print("All marks cleared.")
            else
                if PMY.db then
                    PMY.db.enabled = not PMY.db.enabled
                    local state = PMY.db.enabled and "|cFF00FF00Enabled|r" or "|cFFFF0000Disabled|r"
                    PMY.Print("Marking is now " .. state)
                    PMY.UpdateMinimapIcon()
                    if PMY.db.enabled then
                        PMY.StartProximityScanner()
                    else
                        PMY.StopProximityScanner()
                    end
                end
            end
        end
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("|cFFFF3366Psycho Mark's|r |cFFFFFFFFYou|r |cFF888888v" .. PMY.VERSION .. "|r")
        local status = (PMY.db and PMY.db.enabled) and "|cFF00FF00Enabled|r" or "|cFFFF0000Disabled|r"
        GameTooltip:AddLine("Status: " .. status, 1, 1, 1)

        if PMY.IsMarkingProtected() then
            local keyText = PMY.GetMarkMobBindingText()
            local bindStr = keyText and ("|cFF00FF00" .. keyText .. "|r") or "|cFFFF5555unbound (set in /pmy)|r"
            GameTooltip:AddLine("Mode: |cFFFFCC00Mark Mob Key|r (" .. bindStr .. ")", 0.8, 0.8, 0.8)
        else
            local modeNames = { proximity = "Proximity", mouseover = "Mouseover", manual = "Manual (" .. (PMY.db and PMY.db.markKey or "ALT") .. ")" }
            local modeStr = modeNames[PMY.db and PMY.db.markingMode or "proximity"] or "Proximity"
            GameTooltip:AddLine("Mode: |cFFFFCC00" .. modeStr .. "|r (Max: " .. (PMY.db and PMY.db.proximityMarks or 3) .. ")", 0.8, 0.8, 0.8)
        end

        GameTooltip:AddLine("Zone: |cFFFFCC00" .. (PMY.currentZone ~= "" and PMY.currentZone or "Open World") .. "|r", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Active Marks: |cFFFFCC00" .. PMY.CountMarkedMobs() .. "|r", 0.8, 0.8, 0.8)

        if #PMY.partyCC > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Available Party CC:", 0.6, 0.8, 1)
            for _, cc in ipairs(PMY.partyCC) do
                GameTooltip:AddLine("  " .. PMY.GetIconText(cc.icon) .. " - " .. cc.spell .. " (" .. cc.class .. ")", 1, 1, 1)
            end
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFF00FF00Left-Click:|r Open Settings & Forever DB", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("|cFF00FF00Right-Click:|r Toggle Enable/Disable", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("|cFF00FF00Shift+Right-Click:|r Clear All Marks", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    PMY.minimapButton = btn
    UpdatePosition()
    PMY.UpdateMinimapIcon()

    if PMY.db and PMY.db.hideMinimapButton then
        btn:Hide()
    end
end

function PMY.UpdateMinimapIcon()
    if not PMY.minimapButton then return end
    if PMY.db and PMY.db.enabled then
        PMY.minimapButton.icon:SetDesaturated(false)
        PMY.minimapButton.icon:SetAlpha(1.0)
    else
        PMY.minimapButton.icon:SetDesaturated(true)
        PMY.minimapButton.icon:SetAlpha(0.5)
    end
end
