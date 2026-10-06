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
        "automatically scans |cFF00FF00every visible enemy nameplate in the pack|r, scores the entire group against the Forever database " ..
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
        "Displays a draggable banner when an unmarked pack is detected showing the exact marks planned for the pack (e.g. |cFFFFFFFFSkull: Dark Iron Summoner • Cross: Magmatus • Moon: Dark Iron Engineer|r).")

    AddHeader("2. Raid Icon Priority & Party CC System")
    AddIconRow(8, "First Kill",         "Primary focus target — healers, summoners, AoE fears, and silences.")
    AddIconRow(7, "Second Kill",        "Secondary focus target — high-damage casters, cleavers, and boss adds.")
    AddIconRow(5, "Polymorph / Repent", "Mage Polymorph (Humanoid, Beast, Critter) or Paladin Repentance.")
    AddIconRow(3, "Sap",                "Rogue Sap (Humanoid).")
    AddIconRow(4, "Banish",             "Warlock Banish (Demon, Elemental).")
    AddIconRow(1, "Shackle Undead",     "Priest Shackle Undead (Undead).")
    AddIconRow(2, "Hibernate",          "Druid Hibernate (Beast, Dragonkin).")
    AddIconRow(6, "Freezing Trap",      "Hunter Freezing Trap (Humanoid, Beast, Demon, Dragonkin, Giant, Undead).")

    AddHeader("3. New WoW Forever Dungeons — Priority Cheat Sheet")

    AddBullet("The Hall of Thanes (Lvl 13-18, Beneath Ironforge)",
        "\n  • |cFFFFFFFFSkull (Kill 1st):|r |cFFFF5555Dark Iron Summoner|r (Fireball + summons Fiery Assistant; MUST kill before |cFFFFCC00Magmatus|r!), |cFFFF5555Dark Iron Shadowcaster|r (Terrify AoE Fear!), |cFFFF5555Lesser Stone Golem|r (burn both golems first on |cFFFFCC00Durgen Dirgehammer|r!), |cFFFF5555Enraged Apparition|r.\n  • |cFF8888FFMoon / Diamond (CC):|r |cFFFFCC00Dark Iron Engineer|r (AoE dynamite), |cFFFFCC00Dark Iron Enforcer|r (5s stun), |cFFFFCC00Dark Iron Looter|r.\n  • |cFF888888SKIP:|r |cFFAAAAAABloodhound Runt|r (cleave down).")

    AddBullet("Ruins of Lordaeron (Lvl 15-20, Tirisfal Glades)",
        "\n  • |cFFFFFFFFSkull (Kill 1st):|r |cFFFF5555Shrieking Banshee|r (AoE Silence), |cFFFF5555Flesh Golem|r & |cFFFF5555Living Monstrosity|r (heavy melee + Knock Away threat drop), |cFFFF5555Skeletal Mage|r, |cFFFF5555Ragged Ghoul|r (always kill before regular Ghouls), |cFFFF5555Plague Ghoul|r, |cFFFF5555Deep Widow|r / |cFFFF5555Broodwidow|r.\n  • |cFFFF0000Cross (Kill 2nd):|r |cFFFFCC00Stone Watcher|r (uses Stone Slumber physical immunity — finish with spells), |cFFFFCC00Venom Lurker|r, |cFFFFCC00Fallen Berserker|r.\n  • |cFFFFFF00Star / Moon (CC):|r |cFFFFCC00Skeletal Soldier|r, |cFFFFCC00Ghoul|r, |cFFFFCC00Tarantula|r, |cFFFFCC00Spider|r.\n  • |cFF888888SKIP:|r |cFFAAAAAABroodling|r, |cFFAAAAAAMindless Undead|r, |cFFAAAAAASkeletal Servant|r.")

    AddBullet("Excavation Site: Wetlands (Lvl 24-29, Above Whelgar's Excavation)",
        "\n  • |cFFFFFFFFSkull (Kill 1st):|r |cFFFF5555Thicket Matriarch|r (alpha pack raptor), |cFFFF5555Highland Creeper|r (bog elemental — or Warlock Banish), |cFFFF5555Highland Lurker|r (lvl 28-29 elite), |cFFFF5555Errant Construct|r (Titan construct, CC immune).\n  • |cFFFF0000Cross (Kill 2nd):|r |cFFFFCC00Thicket Hunter|r.\n  • |cFF8888FFMoon / Circle / Square (Beast CC):|r |cFFFFCC00Thicket Lurker|r, |cFFFFCC00Highland Spider|r, |cFFFFCC00Highland Crocolisk|r, |cFFFFCC00Highland Tortoise|r.")

    AddBullet("City of Dalaran (Lvl 28-33, Alterac Mountains)",
        "\n  • |cFFFFFFFFSkull (Kill 1st):|r |cFFFF5555Kirin Tor Necromancer|r (continuously raises skeletons in Underbelly ritual — kill before |cFFFFCC00Atrexis the Grave Knight|r!), |cFFFF5555Arcanic Enigma|r (10s Silence + summons Arcane Manalings), |cFFFF5555Kirin Tor Mage|r, |cFFFF5555Angry Tome|r (adds on |cFFFFCC00Unstable Sentinel|r).\n  • |cFF00FF00Triangle (Banish):|r |cFFFFCC00Suffused Treant|r (Demon treants around |cFFFFCC00Fel Ancient|r).\n  • |cFFFF0000Cross (Kill 2nd):|r |cFFFFCC00Arcane Golem|r (CC immune).\n  • |cFF888888SKIP:|r |cFFAAAAAArcane Manaling|r, |cFFAAAAAARisen Skeleton|r.")

    AddBullet("The Drowned City (Lvl 35-40, Stranglethorn Vale)",
        "\n  • |cFFFFFFFFSkull (Kill 1st):|r |cFFFF5555Brinescale Priestess|r (Naga healer — interrupt & kill first!), |cFFFF5555Deathless Sorcerer|r (undead troll caster), |cFFFF5555Saltseer Manhunter|r, |cFFFF5555Primeval Elemental|r (or Banish on |cFFFFCC00Deathless Marrow|r).\n  • |cFFFFFF00Star (Shackle Undead):|r |cFFFFCC00Risen Sentry|r (patrol), |cFFFFCC00Deathless Guardian|r.\n  • |cFF8888FFMoon / Diamond (CC):|r |cFFFFCC00Brinescale Explorer|r, |cFFFFCC00Goaz Warder|r, |cFFFFCC00Makrura Snapper|r, |cFFFFCC00Saltscale Muckdweller|r.")

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
