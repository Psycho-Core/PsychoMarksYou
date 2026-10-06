-- ============================================================================
-- Psycho Mark's You - Tutorial & WoW Forever Dungeon Guide Tab
-- ============================================================================

local PMY = PsychoMarksYou

function PMY.BuildTutorialTab(tab4)
    local scrollFrame = CreateFrame("ScrollFrame", "PMY_TutorialScrollFrame", tab4, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)

    local content = CreateFrame("Frame", nil, scrollFrame)
    local contentW = tab4:GetWidth() - 46
    content:SetWidth(contentW)
    scrollFrame:SetScrollChild(content)

    local yOff = 0

    local function AddTitle(text)
        local fs = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        fs:SetPoint("TOPLEFT", 6, yOff)
        fs:SetPoint("RIGHT", content, "RIGHT", -6, 0)
        fs:SetJustifyH("LEFT")
        fs:SetText(text)
        yOff = yOff - (fs:GetStringHeight() + 6)
    end

    local function AddHeader(text)
        yOff = yOff - 8
        local bar = content:CreateTexture(nil, "BACKGROUND")
        bar:SetPoint("TOPLEFT", 2, yOff + 2)
        bar:SetPoint("RIGHT", content, "RIGHT", -2, 0)
        bar:SetHeight(22)
        bar:SetColorTexture(0.45, 0.10, 0.20, 0.45)

        local fs = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetPoint("TOPLEFT", 8, yOff)
        fs:SetPoint("RIGHT", content, "RIGHT", -8, 0)
        fs:SetJustifyH("LEFT")
        fs:SetText("|cFFFF3366" .. text .. "|r")
        yOff = yOff - 24
    end

    local function AddParagraph(text)
        local fs = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fs:SetPoint("TOPLEFT", 10, yOff)
        fs:SetPoint("RIGHT", content, "RIGHT", -10, 0)
        fs:SetJustifyH("LEFT")
        fs:SetSpacing(2)
        fs:SetText(text)
        yOff = yOff - (fs:GetStringHeight() + 8)
    end

    local function AddBullet(label, desc)
        local fs = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fs:SetPoint("TOPLEFT", 16, yOff)
        fs:SetPoint("RIGHT", content, "RIGHT", -10, 0)
        fs:SetJustifyH("LEFT")
        fs:SetSpacing(2)
        fs:SetText("|cFF00CCFF•|r |cFFFFFFFF" .. label .. "|r — " .. desc)
        yOff = yOff - (fs:GetStringHeight() + 5)
    end

    local function AddIconRow(iconIdx, role, desc)
        local row = CreateFrame("Frame", nil, content)
        row:SetPoint("TOPLEFT", 16, yOff)
        row:SetPoint("RIGHT", content, "RIGHT", -10, 0)
        row:SetHeight(20)

        local info = PMY.RAID_ICONS[iconIdx]
        local ico = row:CreateTexture(nil, "ARTWORK")
        ico:SetSize(16, 16)
        ico:SetPoint("LEFT", 0, 0)
        ico:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        ico:SetTexCoord(unpack(info.texCoords))

        local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fs:SetPoint("LEFT", ico, "RIGHT", 6, 0)
        fs:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        fs:SetJustifyH("LEFT")
        fs:SetText(info.color .. info.name .. "|r  |cFFFFCC00(" .. role .. ")|r — " .. desc)

        yOff = yOff - 20
    end

    AddTitle("|cFFFF3366Psycho Mark's|r |cFFFFFFFFYou|r — Whole-Group Auto-Marker Guide")
    AddParagraph(
        "|cFFFF3366Psycho Mark's You|r is built specifically for the |cFFFFCC00World of Warcraft: Forever Beta|r (Patch 1.60.1). " ..
        "Unlike stock AutoMarkAssist (which only marked one mob at a time when you hovered it), |cFFFF3366Psycho Mark's You|r " ..
        "automatically scans |cFF00FF00every visible enemy nameplate in the pack|r, scores the entire group against the mob-priority database " ..
        "and your party's CC classes, and marks |cFFFFFFFFthe whole group of mobs simultaneously|r!"
    )

    AddHeader("1. How Whole-Group Automatic Marking Works")
    AddParagraph(
        "As soon as an unmarked enemy pack's nameplates appear on screen out of combat, Psycho Mark's You automatically builds " ..
        "the |cFF00FF00PMY_AutoPack|r multi-target macro (e.g. |cFFCCCCCC/tm [@nameplate2] 8|r, |cFFCCCCCC/tm [@nameplate1] 7|r, " ..
        "|cFFCCCCCC/tm [@nameplate4] 5|r) and arms your automatic triggers:"
    )
    AddBullet("Auto-Mark on TAB (Default ON)",
        "When an unmarked pack is in front of you out of combat, pressing |cFF00FF00TAB|r targets the enemy as normal |cFFFFFFFFAND marks the entire group of mobs at the exact same time|r! Once the pack is marked, TAB immediately reverts to normal target cycling until the next unmarked pack appears.")
    AddBullet("Auto-Mark on Mouse Wheel (Default ON)",
        "When an unmarked pack is in view out of combat, scrolling your |cFF00FF00Mouse Wheel|r one click marks the entire group of mobs at once without changing your target, then immediately returns your scroll wheel to normal camera zoom.")
    AddBullet("Mark Whole Group Keybind",
        "You can also bind a dedicated |cFF00FF00Mark Whole Group|r key in the |cFFFFCC00General|r tab. Pressing it marks the entire visible pack at once without needing to hover or target any mob.")
    AddBullet("On-Screen Pack Preview HUD Banner",
        "Displays a draggable banner when an unmarked pack is detected showing the exact marks planned for the pack (e.g. |cFFFFFFFFSkull: Dark Iron Summoner • Cross: Dark Iron Looter|r).")

    AddHeader("2. Raid Icon Priority & Party CC System")
    AddIconRow(8, "First Kill",         "Primary focus target — healers, summoners, AoE fears, and silences.")
    AddIconRow(7, "Second Kill",        "Secondary focus target — high-damage casters, cleavers, and boss adds.")
    AddIconRow(5, "Polymorph / Repent", "Mage Polymorph (Humanoid, Beast, Critter) or Paladin Repentance.")
    AddIconRow(3, "Sap",                "Rogue Sap (Humanoid).")
    AddIconRow(4, "Banish",             "Warlock Banish (Demon, Elemental).")
    AddIconRow(1, "Shackle Undead",     "Priest Shackle Undead (Undead).")
    AddIconRow(2, "Hibernate",          "Druid Hibernate (Beast, Dragonkin).")
    AddIconRow(6, "Freezing Trap",      "Hunter Freezing Trap (Humanoid, Beast, Demon, Dragonkin, Giant, Undead).")

    AddHeader("3. Researched WoW Forever Priorities")

    AddBullet("The Hall of Thanes (Beta-tested)",
        "\n  • |cFFFFFFFFSkull:|r |cFFFF5555Dark Iron Summoner|r — interrupt/stun its Fireballs and summons; prioritize it before Magmatus. |cFFFF5555Durgen Dirgehammer|r is a dangerous boss; clear nearby Looters/patrols and handle the Lesser Stone Golems after Durgen.\n  • |cFFFF0000Cross:|r |cFFFFCC00Magmatus|r after the Summoner; |cFFFFCC00Dark Iron Looter|r / |cFFFFCC00Fiery Assistant|r may use the second focus mark as the pack calls for it. Looters hit quickly; Assistants are summoned by Summoners.\n  • |cFFFFCC66Dark Iron Engineer:|r bombs can be avoided by moving; its entry has a note, not a fixed priority.")

    AddBullet("Ruins of Lordaeron (Beta-tested)",
        "\n  • |cFFFFFFFFSkull:|r |cFFFF5555Flesh Golem|r / |cFFFF5555Living Monstrosity|r when pulled alone; kill |cFFFF5555Ragged Ghoul|r before regular |cFFFFCC00Ghouls|r in mixed packs. Pull back to avoid nearby packs.\n  • Boss notes cover Witherfang's tank poison, The Baron's heavy Knockout/stun, The Abandoned's interruptible Life Drain, Bjork's patrol/nearby-pull risk, and Rath'mael's Flamestrike.\n  • Banshees and skeletal packs are situational; their note-only entries do not set a universal mark.")

    AddBullet("Excavation Site: Wetlands (Beta-tested)",
        "\n  • Boss targets: |cFFFFFFFFSaltspine|r, |cFFFFFFFFShadetooth|r, and |cFFFFFFFFRelic Guardian|r. Move out of Saltspine's close-range Dust Storm; control Shadetooth's Thicket Hunters or kill them one at a time and dispel Infected Wound.\n  • Thicket Hunter, Matriarch, and Lurker entries are note-only because their handling depends on CC, pack composition, and positioning. Stay on paths: crossing tall grass can spawn Lurkers.")

    AddBullet("Research coverage and gaps",
        "\n  • Automatic mob-priority rows are currently limited to the three beta-tested dungeons above. City of Dalaran remains outside the latest reviewed public-beta roster; its pre-beta run and guide-reported mob tactics are not verified in the current build, so no rows are encoded. The Drowned City material is show-floor preview coverage; four other announced dungeons and Barrow Deeps/Hyjal Summit have no playable tactics. No priority is inferred from themes or client rosters. See docs/target-priority-research.md in the repository for sources and limitations.")

    AddHeader("4. Slash Commands")
    AddBullet("/pmy",             "Open/close the Psycho Mark's You settings & database window")
    AddBullet("/pmy tab",         "Toggle automatic whole-group marking on TAB out of combat")
    AddBullet("/pmy wheel",       "Toggle automatic whole-group marking on Mouse Wheel out of combat")
    AddBullet("/pmy hud",         "Toggle the on-screen Pack Preview HUD banner")
    AddBullet("/pmy clear",       "Clear all tracked marks")
    AddBullet("/pmy announce",    "Announce current mark assignments to party/raid chat")
    AddBullet("/pmy status",      "Display current zone, mode, active marks, and detected party CC")

    yOff = yOff - 12
    content:SetHeight(math.max(1, -yOff))
end
