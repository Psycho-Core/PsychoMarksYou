-- ============================================================================
-- Psycho Mark's You - Mob Priority Database (World of Warcraft: Forever Beta)
-- Covers all 9 new WoW: Forever 5-player dungeons and 2 new raids introduced
-- in Patch 1.60.1 (Interface 16001).
--
-- Format per entry:
--   ["Mob Name"] = {
--       mark         = 1-8,        -- Preferred raid target icon
--       creatureType = "Humanoid", -- Creature type for CC compatibility
--       dangerLevel  = 1-3,        -- 3 = Critical (healer/summoner/fear/silence)
--                                  -- 2 = High (caster/AoE/cleave/interrupt)
--                                  -- 1 = Normal (melee/pack filler)
--       ccImmune     = true/nil,   -- True if immune to standard CC
--       note         = "...",      -- Tactical tooltip & DB guide note
--   }
--   or "SKIP" for trivial non-elite swarm adds that should not consume marks.
--
-- Raid Icon Reference:
--   8 = Skull (First Kill)         4 = Triangle (Banish - Warlock)
--   7 = Cross (Second Kill)        3 = Diamond  (Sap - Rogue)
--   6 = Square (Trap - Hunter)     2 = Circle   (Hibernate - Druid)
--   5 = Moon (Poly - Mage/Paladin) 1 = Star     (Shackle - Priest)
-- ============================================================================

local foreverMobs = {

    -- ========================================================================
    -- 1. THE HALL OF THANES (Levels 13-18, Beneath Ironforge)
    -- Playable in Beta Phase 1 & 2. Dark Iron incursion into royal crypts.
    -- ========================================================================
    ["The Hall of Thanes"] = {
        -- Critical Priority Trash (Danger 3)
        ["Dark Iron Summoner"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Casts Fireball & Summon Fiery Assistant; interrupt & kill first (focus before Magmatus)",
        },
        ["Dark Iron Shadowcaster"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Casts Terrify (AoE Fear into other packs) & Shadow Bolt; interrupt & kill first",
        },

        -- High Priority Trash & Constructs (Danger 2)
        ["Dark Iron Engineer"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 2,
            note = "Throws AoE bombs/dynamite; Polymorph/Sap on pull or kill second",
        },
        ["Lesser Stone Golem"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 2, ccImmune = true,
            note = "Fast hard-hitting golem; on Durgen Dirgehammer pull, burn both golems down first",
        },
        ["Stone Golem"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 2, ccImmune = true,
            note = "Hard-hitting construct in final vault; immune to humanoid CC",
        },
        ["Raging Magma Elemental"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 2,
            note = "Stacks Flame Buffet fire vulnerability; Banish or focus down quickly",
        },
        ["Enraged Apparition"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 2,
            note = "Haunted crypt caster spirit; focus before Tormented Souls",
        },
        ["Dark Iron Enforcer"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 2,
            note = "Uses Concussion Blow (5s stun on tank); Polymorph/Sap or kill second",
        },
        ["Fiery Assistant"] = {
            mark = 7, creatureType = "Elemental", dangerLevel = 2,
            note = "Summoned Fire Elemental add from Dark Iron Summoner; cleave/focus after Summoner",
        },
        ["Animated Anvil"] = {
            mark = 8, creatureType = "Mechanical", dangerLevel = 2, ccImmune = true,
            note = "Animated forge construct add; burn down immediately",
        },

        -- Standard Pack Trash (Danger 1)
        ["Dark Iron Looter"] = {
            mark = 3, creatureType = "Humanoid", dangerLevel = 1,
            note = "Melee rogue with poisoned daggers; Sap/Polymorph or tank & cleave",
        },
        ["Dark Iron Invader"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 1,
            note = "Standard Dark Iron melee/ranged invader; good CC target",
        },
        ["Dark Iron Prospector"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 1,
            note = "Entrance vestibule dwarf; Sap or Polymorph",
        },
        ["Dark IronGuard"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 1,
            note = "Dark Iron guard; CC or cleave",
        },
        ["Dark Iron Guard"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 1,
            note = "Dark Iron guard; CC or cleave",
        },
        ["Tormented Soul"] = {
            mark = 1, creatureType = "Undead", dangerLevel = 1,
            note = "Restless burial spirit; Shackle Undead or cleave after Enraged Apparition",
        },

        -- Swarm / Non-Elite Adds (Skip marking)
        ["Bloodhound Runt"] = "SKIP",

        -- Bosses (for boss-pack marking priority)
        ["Faldrim Anvilmar"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 2, ccImmune = true,
            note = "Boss 1: Casts Mind Blast & Anvilmar's Curse; clear nearby Enraged Apparitions first",
        },
        ["Theron the Unbroken"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 2, ccImmune = true,
            note = "Boss 1 (early build): Interrupt/step out of Ground Slam",
        },
        ["Magmatus"] = {
            mark = 7, creatureType = "Elemental", dangerLevel = 2, ccImmune = true,
            note = "Boss 2: Kill his Dark Iron Summoner (Skull) FIRST, tank Magmatus away from party (Fire Nova)",
        },
        ["Infurnus"] = {
            mark = 7, creatureType = "Elemental", dangerLevel = 2, ccImmune = true,
            note = "Boss 2 (client name): Kill Dark Iron Summoner first, watch Fire Nova & Combustion",
        },
        ["Plunder"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 2, ccImmune = true,
            note = "Boss 3: Patrols before final room; pull back to previous room to avoid Knockback into packs",
        },
        ["Master Smith Bronzebeard"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 2, ccImmune = true,
            note = "Boss 3 (early build): Disarm/kite during Molten Weapon; kill Animated Anvil adds",
        },
        ["Durgen Dirgehammer"] = {
            mark = 7, creatureType = "Humanoid", dangerLevel = 2, ccImmune = true,
            note = "Final Boss: Clear room edges first (AoE Fear); burn his 2 Lesser Stone Golems (Skull) before Durgen",
        },
    },

    -- ========================================================================
    -- 2. RUINS OF LORDAERON (Levels 15-20, Tirisfal Glades / Capital City)
    -- Playable in Beta Phase 1 & 2. Undead Scourge, Abominations & Spiders.
    -- ========================================================================
    ["Ruins of Lordaeron"] = {
        -- Critical Priority Trash (Danger 3)
        ["Shrieking Banshee"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 3,
            note = "Patrols King's Alley; casts AoE Silence on casters — interrupt & kill first",
        },
        ["Flesh Golem"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 3, ccImmune = true,
            note = "Heavy melee + Knock Away (threat drop & knockback); pull back & burn first",
        },
        ["Living Monstrosity"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 3, ccImmune = true,
            note = "Hard-hitting abomination; focus down immediately to save tank",
        },

        -- High Priority Trash (Danger 2)
        ["Wailing Banshee"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 2,
            note = "Casts anti-hit curse lowering party hit chance; interrupt & focus",
        },
        ["Skeletal Mage"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 2,
            note = "Casts Frostbolt & Frost Armor in dense packs; LoS pull & kill before melee skeletons",
        },
        ["Ragged Ghoul"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 2,
            note = "Hits much harder than standard Ghouls in 3-4 mob packs; always kill before regular Ghouls",
        },
        ["Plague Ghoul"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 2,
            note = "Inflicts contagious plague/disease debuffs in Market Street packs; kill first",
        },
        ["Stone Watcher"] = {
            mark = 7, creatureType = "Undead", dangerLevel = 2,
            note = "Gargoyle on upper floor; casts Stone Slumber (physical immunity + heal, use spells to finish)",
        },
        ["Fallen Berserker"] = {
            mark = 7, creatureType = "Undead", dangerLevel = 2,
            note = "High melee damage undead berserker; kill second or Shackle/Trap",
        },
        ["Deep Widow"] = {
            mark = 8, creatureType = "Beast", dangerLevel = 2,
            note = "Large venomous spider in King's Alley packs; kill before smaller Spiders",
        },
        ["Broodwidow"] = {
            mark = 8, creatureType = "Beast", dangerLevel = 2,
            note = "Large venomous spider in King's Alley; focus first or Hibernate",
        },
        ["Venom Lurker"] = {
            mark = 7, creatureType = "Beast", dangerLevel = 2,
            note = "Stacks poison on tank in King's Alley; kill before Tarantulas/Spiders or Hibernate/Poly",
        },

        -- Standard Pack Trash (Danger 1)
        ["Skeletal Soldier"] = {
            mark = 1, creatureType = "Undead", dangerLevel = 1,
            note = "Melee skeleton in packs of 3; Shackle Undead / Freezing Trap or cleave",
        },
        ["Mangled Cadaver"] = {
            mark = 1, creatureType = "Undead", dangerLevel = 1,
            note = "Undead pack melee; Shackle or kill after casters/Ragged Ghouls",
        },
        ["Ghoul"] = {
            mark = 1, creatureType = "Undead", dangerLevel = 1,
            note = "Standard ghoul; kill Ragged Ghoul / Plague Ghoul first",
        },
        ["Skeleton"] = {
            mark = 1, creatureType = "Undead", dangerLevel = 1,
            note = "Market Street skeleton; kill Skeletal Mage first",
        },
        ["Ghostly Citizen"] = {
            mark = 1, creatureType = "Undead", dangerLevel = 1,
            note = "Spectral undead near passage to The Baron; Shackle or cleave",
        },
        ["Tarantula"] = {
            mark = 5, creatureType = "Beast", dangerLevel = 1,
            note = "King's Alley spider; Polymorph, Hibernate, or Freezing Trap",
        },
        ["Spider"] = {
            mark = 5, creatureType = "Beast", dangerLevel = 1,
            note = "Standard King's Alley spider; CC or cleave after Deep Widow/Venom Lurker",
        },

        -- Swarm / Non-Elite Adds (Skip marking)
        ["Broodling"] = "SKIP",
        ["Mindless Undead"] = "SKIP",
        ["Skeletal Servant"] = "SKIP",

        -- Bosses
        ["Witherfang"] = {
            mark = 8, creatureType = "Beast", dangerLevel = 2, ccImmune = true,
            note = "Boss 1: Patrols King's Alley with Broodlings; cleanse Leech Poison on tank",
        },
        ["The Baron"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 3, ccImmune = true,
            note = "Boss 2: Abomination with Knockout (5s stun + threat drop); keep tank topped",
        },
        ["The Butcher"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 3, ccImmune = true,
            note = "Boss 2 (client name): Abomination with heavy melee & threat-drop stun",
        },
        ["Viktor the Vile"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 2, ccImmune = true,
            note = "Fireplace Wave Boss: Spawns after 3 undead waves in ruined house; cleanse Leech Poison",
        },
        ["The Abandoned"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 3, ccImmune = true,
            note = "Statue Wave Boss: Stun/interrupt Drain Life immediately; watches Frost Nova + Chill",
        },
        ["Bjork"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 2, ccImmune = true,
            note = "Boss 5: Giant undead troll; position back against wall for Knockback, wait out Anti-Magic Shield",
        },
        ["Rath'mael"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 3, ccImmune = true,
            note = "Final Boss: MUST interrupt/stun Flamestrike and move out of ground fire; heavy melee AoE aura",
        },
        ["Lordaeron Captain"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 2, ccImmune = true,
            note = "Rare Boss (West wing): Long patrol route; pull away from surrounding packs",
        },
    },

    -- ========================================================================
    -- 3. EXCAVATION SITE: WETLANDS (Levels 24-29, Above Whelgar's Excavation)
    -- Unlocked Oct 1 in Beta Phase 2 (Level 30 cap). Lost Marsh, Stalker's
    -- Thicket, Lost Dig Site, and Site of the Guardian.
    -- ========================================================================
    ["Excavation Site: Wetlands"] = {
        -- High & Critical Priority Trash
        ["Thicket Matriarch"] = {
            mark = 8, creatureType = "Beast", dangerLevel = 3,
            note = "Alpha raptor in Stalker's Thicket packs; focus down first or Hibernate/Polymorph",
        },
        ["Highland Creeper"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 2,
            note = "Lost Marsh bog beast elemental; Banish (Warlock) or focus down first",
        },
        ["Highland Lurker"] = {
            mark = 8, creatureType = "Beast", dangerLevel = 2,
            note = "Level 28-29 elite ambusher; watch for stealthed/flanking pulls",
        },
        ["Thicket Hunter"] = {
            mark = 7, creatureType = "Beast", dangerLevel = 2,
            note = "Stalker's Thicket pack raptor; kill second or Polymorph/Hibernate/Trap",
        },
        ["Errant Construct"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 2, ccImmune = true,
            note = "Rogue Titan construct in Site of the Guardian; pull singles & focus down",
        },
        ["Ancient Construct"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 2, ccImmune = true,
            note = "Titan vault construct; immune to Polymorph/Sap",
        },
        ["Guardian Construct"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 2, ccImmune = true,
            note = "Site of the Guardian construct; heavy physical damage",
        },

        -- Standard Beast Trash (Great CC targets for Mage/Druid/Hunter)
        ["Thicket Lurker"] = {
            mark = 5, creatureType = "Beast", dangerLevel = 1,
            note = "Stealthing thicket raptor; Polymorph, Hibernate, or Freezing Trap",
        },
        ["Highland Spider"] = {
            mark = 5, creatureType = "Beast", dangerLevel = 1,
            note = "Excavation spider; immobilizing webs/poison — CC or cleave",
        },
        ["Highland Crocolisk"] = {
            mark = 5, creatureType = "Beast", dangerLevel = 1,
            note = "Lost Marsh crocolisk; Polymorph, Hibernate, or Trap",
        },
        ["Lost Marsh Crocolisk"] = {
            mark = 5, creatureType = "Beast", dangerLevel = 1,
            note = "Lost Marsh crocolisk; Polymorph, Hibernate, or Trap",
        },
        ["Highland Tortoise"] = {
            mark = 5, creatureType = "Beast", dangerLevel = 1,
            note = "High-armor marsh turtle; kill casters/raptors first",
        },

        -- Bosses
        ["Saltspine"] = {
            mark = 8, creatureType = "Beast", dangerLevel = 2, ccImmune = true,
            note = "Boss 1: Ancient white crocolisk in Lost Marsh; clear surrounding water packs first",
        },
        ["Shadetooth"] = {
            mark = 8, creatureType = "Beast", dangerLevel = 2, ccImmune = true,
            note = "Boss 2: Violet alpha raptor in Stalker's Thicket; watch for flanking raptor adds",
        },
        ["Highland Horror"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 3, ccImmune = true,
            note = "Boss 3: Mire-lord bog monstrosity (drops Horrible Rootcore); heavy nature/physical hits",
        },
        ["Relic Guardian"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 3, ccImmune = true,
            note = "Final Boss: Ancient Titan custodian in Site of the Guardian; watch knockback/slam",
        },
        ["Brogdul"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 2,
            note = "Rare encounter in Excavation Site",
        },
    },

    -- ========================================================================
    -- 4. CITY OF DALARAN (Levels 28-33, Alterac Mountains / Lordamere Lake)
    -- Underbelly, Dalaran Streets, Fel Grove, and Violet Citadel.
    -- ========================================================================
    ["City of Dalaran"] = {
        -- Critical Priority Trash (Danger 3)
        ["Kirin Tor Necromancer"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Underbelly ritualist: continuously raises skeletons! Kill/interrupt first (use Tome of Dalaran on circle)",
        },
        ["Arcanic Enigma"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 3,
            note = "Path of Renewal elite: casts 10s Silence and summons Arcane Manalings! Focus/Banish immediately",
        },

        -- High Priority Trash & Adds (Danger 2)
        ["Kirin Tor Mage"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 2,
            note = "Spellcaster at city gates & streets; interrupt & kill first or Polymorph/Sap",
        },
        ["Corrupted Kirin Tor Mage"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 2,
            note = "Hostile Dalaran caster; interrupt & focus down",
        },
        ["Angry Tome"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 2,
            note = "Animated spellbook add with Unstable Sentinel; burn down quickly",
        },
        ["Suffused Treant"] = {
            mark = 4, creatureType = "Demon", dangerLevel = 2,
            note = "Fel-infused treant in Fel Grove/streets; Warlock Banish (Triangle) or focus kill",
        },
        ["Arcane Golem"] = {
            mark = 7, creatureType = "Elemental", dangerLevel = 2, ccImmune = true,
            note = "Malfunctioning Kirin Tor construct at gates/streets; kill Kirin Tor Mages first",
        },
        ["Dalaran Arcane Golem"] = {
            mark = 7, creatureType = "Elemental", dangerLevel = 2, ccImmune = true,
            note = "Haywire arcane sentinel; heavy melee damage",
        },

        -- Swarm / Ritual Adds (Skip marking)
        ["Arcane Manaling"] = "SKIP",
        ["Risen Skeleton"] = "SKIP",
        ["Underbelly Skeleton"] = "SKIP",

        -- All 9 Client Boss Encounters
        ["Atrexis the Grave Knight"] = {
            mark = 7, creatureType = "Humanoid", dangerLevel = 2, ccImmune = true,
            note = "Underbelly Boss: Disarms tank; kill surrounding Kirin Tor Necromancers (Skull) FIRST",
        },
        ["Arcane Anomaly"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 3, ccImmune = true,
            note = "Terrace Boss: Pull out of bubble; casts Arcane Bolt & Focal Blast beam",
        },
        ["Fel Ancient"] = {
            mark = 8, creatureType = "Demon", dangerLevel = 2, ccImmune = true,
            note = "Fel Grove Boss: Clear or Banish nearby Suffused Treants before engaging",
        },
        ["Unstable Sentinel"] = {
            mark = 7, creatureType = "Elemental", dangerLevel = 3, ccImmune = true,
            note = "Magus Commerce Exchange Boss: Kill Angry Tome adds (Skull); run >25 yds out on Malfunction cast",
        },
        ["Shade of the Archmage"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 3, ccImmune = true,
            note = "Final Boss (Purple Parlor): Don't line up on Bounding Mana target; Mass Polymorphs party; do not leave room",
        },
        ["Mana Wraith"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 2,
            note = "Street Elite / Boss encounter: Drains mana; focus down",
        },
        ["Mana Devourer"] = {
            mark = 8, creatureType = "Demon", dangerLevel = 2, ccImmune = true,
            note = "Demon Boss: Consumes mana & arcane energy",
        },
        ["Mana Elemental"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 2, ccImmune = true,
            note = "Elemental Boss: Casts AoE Slow reducing movement & attack speed",
        },
        ["Lyn the Ignored"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 2, ccImmune = true,
            note = "Rare Elite Boss: Tracked by City of Dalaran completion achievement",
        },
    },

    -- ========================================================================
    -- 5. THE DROWNED CITY (Levels 35-40, Gillijim's Isle, Stranglethorn Vale)
    -- Sunken jungle troll city risen from the sea; Naga, Undead & Makrura.
    -- ========================================================================
    ["The Drowned City"] = {
        -- Critical Priority Healers & Casters (Danger 3)
        ["Brinescale Priestess"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Naga healer/caster in tight packs — MUST interrupt heals & kill first (or Polymorph/Sap)",
        },
        ["Deathless Sorcerer"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 3,
            note = "Undead troll caster in deep halls — heavy spell damage; interrupt & kill first or Shackle",
        },

        -- High Priority Trash (Danger 2)
        ["Saltseer Manhunter"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 2,
            note = "Troll specialist (drops Voodoo-Infused Artifact); focus down or CC",
        },
        ["Brinescale Explorer"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 2,
            note = "Naga pack combatant; Polymorph/Sap while burning Brinescale Priestess",
        },
        ["Risen Sentry"] = {
            mark = 1, creatureType = "Undead", dangerLevel = 2,
            note = "Patrolling undead troll sentry — pull back before engaging pack, or Shackle Undead",
        },
        ["Deathless Guardian"] = {
            mark = 7, creatureType = "Undead", dangerLevel = 2,
            note = "Heavy-hitting undead troll guard; kill Deathless Sorcerer first, or Shackle Undead",
        },
        ["Goaz Warder"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 2,
            note = "Temple warder; CC or kill second",
        },
        ["Primeval Elemental"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 2,
            note = "Elemental add with Deathless Marrow; Banish (Triangle) or burn down first",
        },

        -- Standard Aquatic / Jungle Trash (Danger 1)
        ["Makrura Snapper"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 1,
            note = "Entrance Makrura melee; armor-piercing pinch — CC or cleave",
        },
        ["Saltscale Muckdweller"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 1,
            note = "Murloc pack mob; watch for low-HP flee into extra packs",
        },
        ["Chasm Crawler"] = {
            mark = 5, creatureType = "Beast", dangerLevel = 1,
            note = "Deep-sea crab beast; Polymorph, Hibernate, or Trap",
        },

        -- All 7 Boss Encounters
        ["Zul'Alai"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 3, ccImmune = true,
            note = "Boss 1: Undead troll berserker; save defensive CDs for dangerous low-HP Enrage & AoE",
        },
        ["Zin'aka"] = {
            mark = 8, creatureType = "Beast", dangerLevel = 3, ccImmune = true,
            note = "Water Boss: Extreme tank damage; pre-heal tank through burst windows",
        },
        ["Var'Taka"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 2, ccImmune = true,
            note = "Troll Boss encounter in The Drowned City",
        },
        ["Captain Dreadrise"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 2, ccImmune = true,
            note = "Shipwreck Boss: Undead/pirate captain in the sunken hull section",
        },
        ["Deathless Marrow"] = {
            mark = 7, creatureType = "Elemental", dangerLevel = 3, ccImmune = true,
            note = "Boss: Pulled with Primeval Elemental (Skull/Banish); intense tank damage",
        },
        ["Gill"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 2, ccImmune = true,
            note = "Elemental Boss encounter in The Drowned City",
        },
        ["Min'loth the Serpent"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3, ccImmune = true,
            note = "Final Boss: Troll witch doctor / serpent priest; interrupt casts & clear adds",
        },
    },

    -- ========================================================================
    -- 6. KROL'DOK STRONGHOLD (Levels 40-45, Riverglades)
    -- Ogre & Twilight's Hammer stronghold in the new Riverglades zone.
    -- ========================================================================
    ["Krol'dok Stronghold"] = {
        ["Krol'dok Ogre Mage"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Ogre spellcaster/Bloodlust buffer; interrupt & kill first or Polymorph/Sap",
        },
        ["Krol'dok Shaman"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Healer/totem caller; top interrupt & Skull priority",
        },
        ["Krol'dok Warlock"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Shadow/fire caster & demon summoner; focus first",
        },
        ["Krol'dok Brute"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 1,
            note = "Heavy melee ogre; Polymorph, Sap, or Freezing Trap",
        },
        ["Krol'dok Enforcer"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 2,
            note = "Cleaving melee ogre; CC or kill after casters",
        },
        ["Krol'dok Mauler"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 1,
            note = "Melee ogre; good CC candidate",
        },
        ["Twilight Darkcaster"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Cultist shadow caster; interrupt & focus first",
        },
        ["Twilight Ritualist"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Cultist healer/summoner; top kill priority",
        },
    },

    -- ========================================================================
    -- 7. ALCAZ PRISON (Levels 48-53, Alcaz Island, Dustwallow Marsh)
    -- Island prison fortress holding Defias insurgents & Naga invaders.
    -- ========================================================================
    ["Alcaz Prison"] = {
        ["Wrathscale Siren"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Naga healer/frost caster; interrupt heals & kill first",
        },
        ["Strashaz Siren"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Elite Naga caster/healer on Alcaz; top kill or Polymorph priority",
        },
        ["Strashaz Sorceress"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Elite Naga spellcaster; interrupt & burn first",
        },
        ["Wrathscale Myrmidon"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 2,
            note = "Heavy melee Naga; Polymorph/Sap/Trap while killing Siren",
        },
        ["Strashaz Myrmidon"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 2,
            note = "Elite Naga warrior; CC or kill after casters",
        },
        ["Strashaz Serpent Guard"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 2,
            note = "Elite Naga guard; disarm/CC or secondary kill",
        },
        ["Defias Blood Wizard"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Prison caster; high burst magic damage — focus first",
        },
        ["Defias Warder"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 2,
            note = "Prison guard with net/crowd control; focus or Sap",
        },
        ["Defias Insurgent"] = {
            mark = 3, creatureType = "Humanoid", dangerLevel = 1,
            note = "Prison rioter; Sap, Polymorph, or cleave",
        },
    },

    -- ========================================================================
    -- 8. BLACKMAW HOLD (Levels 55-60, North Azshara Timbermaw Gates)
    -- Great Furbolg city behind the giant gates in northern Azshara.
    -- ========================================================================
    ["Blackmaw Hold"] = {
        ["Blackmaw Shaman"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Furbolg healer & totem caller; MUST interrupt Healing Wave & kill first",
        },
        ["Blackmaw Mystic"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3,
            note = "Furbolg healer/curser; top kill or Polymorph priority",
        },
        ["Blackmaw Ursolite"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 2,
            note = "Furbolg caster; interrupt & focus before melee warriors",
        },
        ["Blackmaw Totemic"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 2,
            note = "Drops dangerous totems; destroy totems & focus down",
        },
        ["Blackmaw Warrior"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 1,
            note = "Melee furbolg; Polymorph, Sap, or Freezing Trap",
        },
        ["Blackmaw Den Watcher"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 2,
            note = "Patrolling furbolg guard; pull back or CC",
        },
        ["Blackmaw Pathfinder"] = {
            mark = 5, creatureType = "Humanoid", dangerLevel = 2,
            note = "Ranged furbolg hunter; LoS pull or Polymorph",
        },
    },

    -- ========================================================================
    -- 9. SHAPER'S TERRACE (Levels 58-60, Un'Goro Crater)
    -- Endgame Titan research facility in Un'Goro Crater.
    -- ========================================================================
    ["Shaper's Terrace"] = {
        ["Titan Custodian"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3, ccImmune = true,
            note = "High-level Titan keeper; heavy AoE/construct abilities — focus first",
        },
        ["Shaper's Construct"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 2, ccImmune = true,
            note = "Titan stone/arcane construct; immune to humanoid CC",
        },
        ["Arcane Watcher"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 2, ccImmune = true,
            note = "Arcane sentry construct; interrupt beams & focus",
        },
        ["Crystal Elemental"] = {
            mark = 4, creatureType = "Elemental", dangerLevel = 2,
            note = "Un'Goro pylon elemental; Warlock Banish (Triangle) or focus kill",
        },
        ["Pterrordax Screamer"] = {
            mark = 8, creatureType = "Beast", dangerLevel = 3,
            note = "Psychic scream / AoE fear beast; kill or Hibernate/Polymorph immediately",
        },
        ["Primal Devilsaur"] = {
            mark = 8, creatureType = "Beast", dangerLevel = 2, ccImmune = true,
            note = "Massive melee damage & Terrifying Roar; tank with defensive CDs",
        },
        ["Un'Goro Ravager"] = {
            mark = 5, creatureType = "Beast", dangerLevel = 1,
            note = "Pack dinosaur; Polymorph, Hibernate, or Freezing Trap",
        },
    },

    -- ========================================================================
    -- WOW FOREVER RAIDS (Level 60)
    -- 10-Player Raid: Barrow Deeps (8 Bosses)
    -- 20-Player Raid: Hyjal Summit (13 Bosses)
    -- ========================================================================
    ["Barrow Deeps"] = {
        ["Deepscar Matriarch"] = {
            mark = 8, creatureType = "Beast", dangerLevel = 3, ccImmune = true,
            note = "Barrow Deeps Raid Boss 1",
        },
        ["Elder Tangleclaw"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3, ccImmune = true,
            note = "Barrow Deeps Raid Boss 2 (Corrupted Furbolg/Ancient)",
        },
        ["Khalith the Dreadspinner"] = {
            mark = 8, creatureType = "Beast", dangerLevel = 3, ccImmune = true,
            note = "Barrow Deeps Raid Boss 3 (Giant Spider encounter)",
        },
        ["Well of Sorrow"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 3, ccImmune = true,
            note = "Barrow Deeps Raid Boss 4",
        },
        ["Amethrax"] = {
            mark = 8, creatureType = "Dragonkin", dangerLevel = 3, ccImmune = true,
            note = "Barrow Deeps Raid Boss 5",
        },
        ["Del'lynar Songwood"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3, ccImmune = true,
            note = "Barrow Deeps Raid Boss 6",
        },
        ["Ravus"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3, ccImmune = true,
            note = "Barrow Deeps Dual Boss (Ravus and Darlissa) — Primary Kill",
        },
        ["Darlissa"] = {
            mark = 7, creatureType = "Humanoid", dangerLevel = 3, ccImmune = true,
            note = "Barrow Deeps Dual Boss (Ravus and Darlissa) — Secondary Kill / Off-tank",
        },
        ["Sonya Darkhallow"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3, ccImmune = true,
            note = "Barrow Deeps Final Raid Boss",
        },
    },

    ["Hyjal Summit"] = {
        ["Bandalar"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3, ccImmune = true,
            note = "Hyjal Summit 20-Player Raid Boss",
        },
        ["Ancient of Decay"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 3, ccImmune = true,
            note = "Hyjal Summit Raid Boss (Corrupted Ancient)",
        },
        ["Time-Lost Battalion"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3, ccImmune = true,
            note = "Hyjal Summit Raid Boss (Battalion encounter)",
        },
        ["Sylvestris Dusksong"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3, ccImmune = true,
            note = "Hyjal Summit Raid Boss",
        },
        ["Old Gloomlurker"] = {
            mark = 8, creatureType = "Beast", dangerLevel = 3, ccImmune = true,
            note = "Hyjal Summit Raid Boss",
        },
        ["Gharalis the Abyssal"] = {
            mark = 8, creatureType = "Demon", dangerLevel = 3, ccImmune = true,
            note = "Hyjal Summit Raid Boss (Abyssal Demon)",
        },
        ["Kathris the Haunted"] = {
            mark = 8, creatureType = "Undead", dangerLevel = 3, ccImmune = true,
            note = "Hyjal Summit Raid Boss",
        },
        ["Anara Chillwind"] = {
            mark = 8, creatureType = "Elemental", dangerLevel = 3, ccImmune = true,
            note = "Hyjal Summit Raid Boss",
        },
        ["Elder Minderel"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3, ccImmune = true,
            note = "Hyjal Summit Raid Boss",
        },
        ["Tracker Stillwind"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3, ccImmune = true,
            note = "Hyjal Summit Raid Boss",
        },
        ["Council of Thorns"] = {
            mark = 8, creatureType = "Humanoid", dangerLevel = 3, ccImmune = true,
            note = "Hyjal Summit Raid Boss (Council encounter)",
        },
        ["Nythus the Dreambound"] = {
            mark = 8, creatureType = "Dragonkin", dangerLevel = 3, ccImmune = true,
            note = "Hyjal Summit Raid Boss (Emerald Dream Dragon)",
        },
        ["The Wild King"] = {
            mark = 8, creatureType = "Beast", dangerLevel = 3, ccImmune = true,
            note = "Hyjal Summit Final Raid Boss",
        },
    },
}

-- Merge into master mob table
PsychoMarksYou_DefaultMobs = PsychoMarksYou_DefaultMobs or {}
for zone, mobs in pairs(foreverMobs) do
    PsychoMarksYou_DefaultMobs[zone] = mobs
end

-- ============================================================================
-- WOW FOREVER ZONE ALIASES
-- Covers all client/subzone spelling variants so GetRealZoneText() always
-- resolves to the canonical DB key in PsychoMarksYou_DefaultMobs.
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
