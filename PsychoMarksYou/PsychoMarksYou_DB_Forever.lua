-- ============================================================================
-- Psycho Mark's You - WoW Forever Beta Priority Database
--
-- Data policy:
--   * Static mark, danger, creature-type, and CC data is added only where
--     current playable guides or reliable encounter evidence support it.
--   * Context-dependent tactics may be note-only (no automatic priority).
--   * Unplayable, demo-only, disputed, and unsupported mob rosters are omitted.
--   * Never infer detailed priorities from a dungeon's theme or roster alone.
-- ============================================================================

local foreverMobs = {
    -- Hall of Thanes is live in the beta; these priorities are supported by
    -- current dungeon guides and are active.
    ["The Hall of Thanes"] = {
        ["Dark Iron Summoner"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Powerful Fireballs and Fiery Assistant summons; interrupt/stun and focus. Kill before Magmatus. In the final mixed pack, CC it while dealing with the Looter/Golem if possible.",
        },
        ["Dark Iron Looter"] = {
            mark = 7, creatureType = "Humanoid", dangerLevel = 2,
            note = "Fast poison-dagger damage can overwhelm the tank; clear before Durgen and focus in the final mixed pack if the Summoner is controlled.",
        },
        ["Dark Iron Engineer"] = {
            note = "Bombs target a ground location and can be avoided by moving; spread rather than treating the Engineer as a universal first kill.",
        },
        ["Fiery Assistant"] = {
            mark = 7, creatureType = "Elemental", dangerLevel = 2,
            note = "Summoned by Dark Iron Summoners; control/finish after the summoner or handle with the pack's assigned cleave.",
        },
        ["Lesser Stone Golem"] = {
            mark = 7, creatureType = "Elemental", dangerLevel = 2,
            note = "Hard-hitting final-room add; Method recommends killing it after Durgen Dirgehammer, while keeping the other adds controlled.",
        },
        ["Faldrim Anvilmar"] = {
            mark = 8, dangerLevel = 2,
            note = "Current beta encounter; generic boss focus only, with no unsupported add order encoded.",
        },
        ["Magmatus"] = {
            mark = 7, dangerLevel = 2,
            note = "Live guides call the boss Magmatus; kill the accompanying Dark Iron Summoner first and tank Magmatus away from the group for Fire Nova.",
        },
        ["Plunder"] = {
            mark = 8, dangerLevel = 2,
            note = "Current beta boss name; generic boss focus only, with no unsupported mechanics encoded.",
        },
        ["Durgen Dirgehammer"] = {
            mark = 8, dangerLevel = 3,
            note = "Clear nearby Looters and patrols before pulling. The boss fears and hits the tank hard; the current Method guide recommends killing Durgen first, then the Lesser Stone Golems.",
        },
    },

    -- Ruins of Lordaeron is live in the beta. Only current guide names with
    -- source-supported tactics are included; disputed roster variants are omitted.
    ["Ruins of Lordaeron"] = {
        ["Flesh Golem"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 2,
            note = "Hard-hitting patrol with a knockback; pull away from nearby packs and focus separately.",
        },
        ["Living Monstrosity"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 2,
            note = "Hard-hitting; take it down promptly and avoid combining it with other trash.",
        },
        ["Ragged Ghoul"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 2,
            note = "In close packs of Ghouls/Ragged Ghouls, kill the Ragged Ghoul first; pull back to avoid chaining the next pack.",
        },
        ["Ghoul"] = {
            mark = 7, creatureType = "Undead", dangerLevel = 2,
            note = "Ghouls hit hard in closely spaced packs; in mixed Ghoul packs, kill after the Ragged Ghoul and avoid overpulling.",
        },
        ["Witherfang"] = {
            mark = 8, dangerLevel = 2,
            note = "Boss patrols King's Alley; clear its route and pull in a safe spot. Leech Poison is applied to the tank.",
        },
        ["The Baron"] = {
            mark = 8, dangerLevel = 3,
            note = "Hard melee swings. Knockout deals heavy damage, knocks back, and stuns the tank; keep the tank near full health and use stuns when available.",
        },
        ["Viktor the Vile"] = {
            mark = 8, dangerLevel = 2,
            note = "Optional chimney event after five add waves; conserve resources between waves and establish tank threat when Viktor appears.",
        },
        ["The Abandoned"] = {
            mark = 8, dangerLevel = 2,
            note = "Market Square wave event; interrupt or stun the Life Drain cast. Clear each wave before the boss appears.",
        },
        ["Bjork"] = {
            mark = 8, dangerLevel = 2,
            note = "Patrols through the central area; nearby Ghouls are dangerous, so clear or pull with care.",
        },
        ["Rath'mael"] = {
            mark = 8, dangerLevel = 2,
            note = "Interrupt/stun Flamestrike or move out of it; clear nearby trash before engaging.",
        },
        ["Shrieking Banshee"] = { note = "Current guides identify this as a Kings Alley patrol but do not establish a special kill order; watch its route and pull packs back." },
        ["Skeletal Soldier"] = { note = "Appears in groups guarding The Baron; the guide reports tank damage but no special ability-based kill order." },
        ["Skeletal Mage"] = { note = "Appears in groups guarding The Baron; no spell-specific priority is confirmed in current guides." },
    },

    -- Excavation Site: current guide-supported bosses and add mechanics only.
    -- Context-dependent add tactics are note-only; no unverified encounter rows.
    ["Excavation Site: Wetlands"] = {
        ["Thicket Hunter"] = { note = "Shadetooth's two adds apply Infected Wound. CC both, or control one and kill the other first; if the group has no reliable CC, kill the Hunters before focusing Shadetooth and dispel the wound quickly." },
        ["Thicket Matriarch"] = { note = "Calls Thicket Lurkers when low. Current guides recommend killing the other pack mobs first, then bursting the Matriarch." },
        ["Thicket Lurker"] = { note = "Stepping through tall grass can spawn Lurkers; stay on the path and fight in cleared ground." },
        ["Saltspine"] = {
            mark = 8, dangerLevel = 2,
            note = "Boss patrols the marsh; clear only the route needed and pull to a safe area. Keep ranged players outside its close-range Dust Storm.",
        },
        ["Shadetooth"] = {
            mark = 8, dangerLevel = 3,
            note = "Boss with two Thicket Hunters. CC both or kill an add first if no reliable CC; dispel Infected Wound and fight in cleared ground so fear does not send players into tall grass.",
        },
        ["Relic Guardian"] = {
            mark = 8, dangerLevel = 2,
            note = "Mechanical boss susceptible to most crowd control; use CC to reduce pressure. Stay out of its close-range attacks/knockbacks.",
        },
    },

    -- Other announced dungeons and future raids are listed in the guide/zone
    -- registry below, but have no mob priority entries until dependable tactics
    -- are available. Demo-only and client-roster-only names are not in this DB.
}

-- Merge without replacing any pre-existing zone or mob entry.
PsychoMarksYou_DefaultMobs = PsychoMarksYou_DefaultMobs or {}
for zone, mobs in pairs(foreverMobs) do
    local runtimeZone = PsychoMarksYou_DefaultMobs[zone]
    if not runtimeZone then
        runtimeZone = {}
        PsychoMarksYou_DefaultMobs[zone] = runtimeZone
    end
    for mobName, entry in pairs(mobs) do
        if runtimeZone[mobName] == nil then
            runtimeZone[mobName] = entry
        end
    end
end

-- ============================================================================
-- WOW FOREVER ZONE ALIASES
-- Canonicalizes known Forever dungeon/subzone names. A mapped zone does not
-- imply mob-priority rows exist for that content.
-- ============================================================================
local foreverAliases = {
    -- 1. The Hall of Thanes
    ["The Hall of Thanes"]              = "The Hall of Thanes",
    ["Hall of Thanes"]                  = "The Hall of Thanes",
    ["Old Ironforge"]                   = "The Hall of Thanes",
    ["Anvilmar's Rest"]                 = "The Hall of Thanes",

    -- 2. Ruins of Lordaeron
    ["Ruins of Lordaeron"]              = "Ruins of Lordaeron",
    ["The Ruins of Lordaeron"]          = "Ruins of Lordaeron",
    ["Capital City"]                    = "Ruins of Lordaeron",

    -- 3. Excavation Site: Wetlands
    ["Excavation Site: Wetlands"]       = "Excavation Site: Wetlands",
    ["Excavation Site"]                 = "Excavation Site: Wetlands",
    ["The Excavation Site"]             = "Excavation Site: Wetlands",
    ["Wetlands Excavation Site"]        = "Excavation Site: Wetlands",
    ["Site of the Guardian"]            = "Excavation Site: Wetlands",
    ["Lost Dig Site"]                   = "Excavation Site: Wetlands",

    -- 4. City of Dalaran
    ["City of Dalaran"]                 = "City of Dalaran",
    ["The City of Dalaran"]             = "City of Dalaran",
    ["Ruins of Dalaran"]                = "City of Dalaran",
    ["Dalaran"]                         = "City of Dalaran",
    ["The Violet Citadel"]              = "City of Dalaran",

    -- 5. The Drowned City
    ["The Drowned City"]                = "The Drowned City",
    ["Drowned City"]                    = "The Drowned City",
    ["I'lalai"]                         = "The Drowned City",
    ["I'lalai the Drowned City"]        = "The Drowned City",
    ["Atal'Byzal"]                      = "The Drowned City",

    -- 6. Krol'dok Stronghold
    ["Krol'dok Stronghold"]             = "Krol'dok Stronghold",
    ["Krol'Dok Stronghold"]             = "Krol'dok Stronghold",
    ["Kroldok Stronghold"]              = "Krol'dok Stronghold",

    -- 7. Alcaz Prison
    ["Alcaz Prison"]                    = "Alcaz Prison",
    ["Alcaz Island Prison"]             = "Alcaz Prison",
    ["Alcaz Island"]                    = "Alcaz Prison",

    -- 8. Blackmaw Hold
    ["Blackmaw Hold"]                   = "Blackmaw Hold",
    ["Blackmaw"]                        = "Blackmaw Hold",

    -- 9. Shaper's Terrace
    ["Shaper's Terrace"]                = "Shaper's Terrace",
    ["The Shaper's Terrace"]            = "Shaper's Terrace",
    ["The Shapers Terrace"]             = "Shaper's Terrace",
    ["Shapers Terrace"]                 = "Shaper's Terrace",

    -- Forever Raids
    ["Barrow Deeps"]                    = "Barrow Deeps",
    ["The Barrow Deeps"]                = "Barrow Deeps",
    ["Hyjal Summit"]                    = "Hyjal Summit",
    ["Mount Hyjal"]                     = "Hyjal Summit",
}

PsychoMarksYou_ZoneAliases = PsychoMarksYou_ZoneAliases or {}
for alias, canonical in pairs(foreverAliases) do
    PsychoMarksYou_ZoneAliases[alias] = canonical
end

-- ============================================================================
-- EXPANSION REGISTRATION
-- Inserts "WoW Forever" at index 1 so the 9 new dungeons & 2 raids appear
-- at the very top of the Database tab.
-- ============================================================================
PsychoMarksYou_ExpansionOrder = PsychoMarksYou_ExpansionOrder or {}
table.insert(PsychoMarksYou_ExpansionOrder, 1, {
    name = "WoW Forever",
    dungeons = {
        "The Hall of Thanes",
        "Ruins of Lordaeron",
        "Excavation Site: Wetlands",
        "City of Dalaran",
        "The Drowned City",
        "Krol'dok Stronghold",
        "Alcaz Prison",
        "Blackmaw Hold",
        "Shaper's Terrace",
    },
    raids = {
        "Barrow Deeps",
        "Hyjal Summit",
    },
})
