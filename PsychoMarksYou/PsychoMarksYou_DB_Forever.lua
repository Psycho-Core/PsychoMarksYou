-- ============================================================================
-- Psycho Mark's You - WoW Forever Beta Priority Database
--
-- Data policy:
--   * Static mark, danger, creature-type, and CC data is added only where
--     current playable guides or reliable encounter evidence support it.
--   * Context-dependent tactics may be note-only (no automatic priority).
--   * Unplayable, demo-only and client-roster-only names are included only with
--     an explicit note saying so, and never with invented mechanics.
--   * Never infer detailed priorities from a dungeon's theme or roster alone.
--   * Dungeons with no published mob roster get no rows at all; see the
--     no-data block near the end of the table.
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
            mark = 5, creatureType = "Humanoid", dangerLevel = 2,
            note = "AoE dynamite that targets a ground location, so it can be dodged by moving. A Polymorph or Sap target rather than a universal first kill; spread out instead of stacking on it."
        },
        ["Fiery Assistant"] = {
            mark = 7, creatureType = "Elemental", dangerLevel = 2,
            note = "Summoned by Dark Iron Summoners; control/finish after the summoner or handle with the pack's assigned cleave.",
        },
        ["Lesser Stone Golem"] = {
            mark = 7, creatureType = "Elemental", dangerLevel = 2,
            note = "Two of them guard Durgen Dirgehammer. Guides disagree: one says burn the Golems quickly then take the boss, the Method walkthrough says kill Durgen first. Pick one and stick to it; both agree the Golems must stay controlled."
        },
        ["Faldrim Anvilmar"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Curse that petrifies and cuts attack speed by 20%, plus Mind Blast style Shadow damage. Clear the spirits around him first and keep a curse cleanse ready."
        },
        ["Magmatus"] = {
            mark = 7, creatureType = "Elemental", dangerLevel = 3,
            note = "Fire damage and Combust. Dark Iron Summoners and Engineers are up with him, so kill or control them before committing."
        },
        ["Plunder"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Charge plus an AoE knock-up. Keep the group spread and away from ledges so the knock-up does not throw anyone into the next pack."
        },
        ["Durgen Dirgehammer"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "AoE Fear plus a bleed, and hits the tank hard. Clear nearby Looters and patrols before pulling, keep Fear Ward or Tremor available, and see the Lesser Stone Golem note for the disputed add order."
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

    -- Krol'dok Stronghold (40-45), Alcaz Prison (48-53), Blackmaw Hold (55-60)
    -- and Shaper's Terrace (58-60) have NO mob data to work from. Every source
    -- checked lists them as "Bosses: Unknown yet / Mob Packs: Unknown yet", and
    -- none is playable in the beta. Their zone aliases are registered below so
    -- the addon still resolves the zone name, and the runtime heuristics
    -- (caster / mana / boss detection) plus auto-learn cover them in the
    -- meantime. Inventing mob names from the dungeon theme is exactly what the
    -- data policy at the top of this file forbids, so no rows are added.
    -- City of Dalaran (28-33, Alterac Mountains). NOT playable in the beta as
    -- of the October 2026 builds; the boss roster is the beta client's own list
    -- and the mechanics are the ones Wowhead documents for the encounters.
    -- Almost all trash here is immune to Arcane damage, so marks matter more
    -- than the usual caster-first assumption.
    ["City of Dalaran"] = {
        ["Kirin Tor Necromancer"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Summoner. Runs the Underbelly ritual and skeletons keep rising through it; kill it first or the pack never shrinks.",
        },
        ["Mana Phantom"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 3,
            note = "Casts Mana Burn; interrupt it. Two of them spawn with Arcanic Enigma.",
        },
        ["Angry Tome"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Spawns out of the buildings during Unstable Sentinel. Kill the Tomes before you engage the boss, not during it.",
        },
        ["Arcanic Enigma"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 3,
            note = "Brings two Mana Phantoms and a Silence the healer must stay clear of; dispel Manamorph. Wowhead lists it as an encounter, the beta client's boss list does not.",
        },
        ["Atrexis the Grave Knight"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Disarms the tank and summons skeletons. Establish threat before anyone AoEs. Sits at the Underbelly ritual circle with Necromancers around him.",
        },
        ["Shade of the Archmage"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Mass Polymorph, Evocation, Arcane Explosion and Bounding Mana. Assign strict interrupts and keep a Polymorph break ready.",
        },
        ["Arcane Anomaly"] = {
            mark = 7, creatureType = "Elemental", dangerLevel = 2,
            note = "Arcane Bolt plus Focal Blast, a rotating beam that kills. Stay on the platform and move with the beam.",
        },
        ["Unstable Sentinel"] = {
            mark = 7, creatureType = "Elemental", dangerLevel = 2,
            note = "Malfunction blasts everyone within 25 yards after a wind-up. Melee run out on the wind-up, ranged stay at maximum range.",
        },
        ["Mana Devourer"] = {
            mark = 7, creatureType = "Elemental", dangerLevel = 2,
            note = "Mana drain; kill it while the healers still have a pool to work from.",
        },
        ["Mana Wraith"] = {
            mark = 7, creatureType = "Elemental", dangerLevel = 2,
            note = "Listed as the final encounter in the beta client; a level 27 Mana Wraith has also been pulled as ordinary street trash, so confirm which one you are marking.",
        },
        ["Mana Elemental"] = {
            mark = 7, creatureType = "Elemental", dangerLevel = 2,
            note = "Arcane-immune elemental; physical and non-Arcane damage only.",
        },
        ["Fel Ancient"] = {
            mark = 7, creatureType = "Demon", dangerLevel = 2,
            note = "Locked behind a mana barrier until the nearby bosses are down; Warlock Banish applies if the group needs to park it.",
        },
        ["Lyn the Ignored"] = {
            mark = 7, creatureType = "Humanoid", dangerLevel = 2,
            note = "Rare elite. No mechanics published yet.",
        },
        ["Saturated Remnant"] = "SKIP",
    },

    -- The Drowned City (35-40, off the Stranglethorn coast). Not in the beta;
    -- this comes from the playable BlizzCon 2026 show-floor build, so treat it
    -- as a build snapshot rather than final data. The boss roster itself is
    -- still disputed between sources.
    ["The Drowned City"] = {
        ["Deathless Sorcerer"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 3,
            note = "Caster trash in the deeper sections; interrupt or CC it before anything else in the pack.",
        },
        ["Deathless Guardian"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 2,
            note = "Undead group deeper in the city. The reason not to combine packs here.",
        },
        ["Risen Sentry"] = {
            mark = 7, creatureType = "Undead", dangerLevel = 2,
            note = "Undead patrol. Watch its route before committing to a pull; Shackle Undead applies.",
        },
        ["Brinescale Explorer"] = {
            mark = 7, creatureType = "Humanoid", dangerLevel = 2,
            note = "Naga in the mixed aquatic packs; kill the spellcasters first.",
        },
        ["Makrura"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 2,
            note = "Early-area aquatic packs around the water-heavy rooms; druid Hibernate applies.",
        },
        ["Zul'Alai"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "First boss. Very strong enrage near death plus hard AoE hits; save tank defensives and DPS cooldowns for the last phase.",
        },
        ["Zin'aka"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Reachable through the water. Reported to put extreme pressure on the tank; enter with defensives ready. Not on every published roster.",
        },
        ["Deathless Marrow"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 3,
            note = "Reported to put severe pressure on the tank. Clear nearby enemies first and arrive with healer mana.",
        },
        ["Min'loth the Serpent"] = {
            mark = 8, creatureType = "Beast", dangerLevel = 2,
            note = "Deeper encounter. No ability list, phases or named spells published; treat any detailed strategy as unconfirmed.",
        },
        ["Var'Taka"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 2,
            note = "On one published roster but not the other; no mechanics documented either way.",
        },
        ["Captain Dreadrise"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 2,
            note = "Pirate encounter on one published roster; a ship has crashed into the city. No mechanics documented.",
        },
        ["Gill"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 2,
            note = "On one published roster but not the other; no mechanics documented.",
        },
    },

    -- New raids. Both open December 9 2026 and neither is playable in the beta.
    -- Names are the beta client's Legacy achievement criteria (Hyjal Summit) and
    -- the BlizzCon demo roster (Barrow Deeps); no mechanics have been tested, so
    -- these rows only carry the boss mark.
    ["Barrow Deeps"] = {
        ["Deepscar Matriarch"]     = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, note = "Demo roster name; mechanics untested." },
        ["Elder Tangleclaw"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, note = "Demo roster name; mechanics untested." },
        ["Khalith the Dreadspinner"] = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, note = "Demo roster name; mechanics untested." },
        ["Well of Sorrow"]         = { mark = 8, dangerLevel = 2, note = "Demo roster name; mechanics untested." },
        ["Amethrax"]               = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, note = "Demo roster name; mechanics untested." },
        ["Del'lynar Songwood"]     = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, note = "Demo roster name; mechanics untested." },
        ["Ravus"]                  = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, note = "Demo roster name; paired with Darlissa. Mechanics untested." },
        ["Darlissa"]               = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, note = "Demo roster name; paired with Ravus. Mechanics untested." },
        ["Sonya Darkhallow"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, note = "Demo roster name; mechanics untested." },
    },

    ["Hyjal Summit"] = {
        ["Bandalar"]               = { mark = 8, dangerLevel = 2, note = "From the beta client's Legacy achievement order, which is not a confirmed kill order; mechanics untested." },
        ["Ancient of Decay"]       = { mark = 8, dangerLevel = 2, note = "From the beta client's Legacy achievement order; mechanics untested." },
        ["Time-Lost Battalion"]    = { mark = 8, dangerLevel = 2, note = "From the beta client's Legacy achievement order; mechanics untested." },
        ["Sylvestris Dusksong"]    = { mark = 8, dangerLevel = 2, note = "From the beta client's Legacy achievement order; mechanics untested." },
        ["Old Gloomlurker"]        = { mark = 8, dangerLevel = 2, note = "From the beta client's Legacy achievement order; mechanics untested." },
        ["Gharalis the Abyssal"]   = { mark = 8, dangerLevel = 2, note = "From the beta client's Legacy achievement order; mechanics untested." },
        ["Kathris the Haunted"]    = { mark = 8, dangerLevel = 2, note = "From the beta client's Legacy achievement order; mechanics untested." },
        ["Anara Chillwind"]        = { mark = 8, dangerLevel = 2, note = "From the beta client's Legacy achievement order; mechanics untested." },
        ["Elder Minderel"]         = { mark = 8, dangerLevel = 2, note = "From the beta client's Legacy achievement order; mechanics untested." },
        ["Tracker Stillwind"]      = { mark = 8, dangerLevel = 2, note = "From the beta client's Legacy achievement order; mechanics untested." },
        ["Council of Thorns"]      = { mark = 8, dangerLevel = 2, note = "From the beta client's Legacy achievement order; mechanics untested." },
        ["Nythus the Dreambound"]  = { mark = 8, dangerLevel = 2, note = "From the beta client's Legacy achievement order; one source spells this Dreadmbound. Mechanics untested." },
        ["The Wild King"]          = { mark = 8, dangerLevel = 2, note = "From the beta client's Legacy achievement order; mechanics untested." },
    },

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
