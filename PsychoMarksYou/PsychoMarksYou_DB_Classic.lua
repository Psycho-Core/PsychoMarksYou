-- AutoMarkAssist_DB_Classic.lua
-- Mob mark-preference database for Classic (Vanilla) dungeons and raids.
-- This is the first DB module loaded. It defines the legacy Classic table and
-- merges its entries into the runtime lookup without clobbering existing rows.
-- Subsequent expansion modules merge into the runtime table.
--
-- NOTE: Mob names reflect post-Cataclysm revamps where applicable.
-- Classic Era and TBC/WotLK Classic servers may use original pre-Cata names
-- for some mobs.  Unknown mobs are marked via FCFS; adjust entries
-- in-game via the Database tab or by editing this file directly.
--
-- Mark values:
--   8        -> Skull (priority kill target)
--   5        -> Moon  (CC preference, e.g. Polymorph)
--   1-7      -> Any specific mark preference
--   "SKIP"   -> Never mark this mob.
--
-- Context-dependent tactics may be note-only. Such rows have no default mark,
-- creature type, CC flag, or danger level and cannot alter automatic scoring.
-- Adjust via the in-game Database tab or by editing this file directly.

-- Creates the global database tables that subsequent expansion modules merge into.

AutoMarkAssist_MobDB = {

    -- ============================================================
    -- CLASSIC DUNGEONS
    -- ============================================================

    ["Ragefire Chasm"] = {
        ["Searing Blade Cultist"]       = { mark = 5, creatureType = "Humanoid" },
        ["Searing Blade Enforcer"]      = { mark = 5, creatureType = "Humanoid" },
        ["Searing Blade Warlock"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- shadow caster
        ["Corrupted Houndmaster"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- calls beasts
        ["Dark Shaman Acolyte"]         = { mark = 8, creatureType = "Humanoid" },  -- flame shock caster
        ["Molten Elemental"]            = { mark = 5, creatureType = "Elemental" },
        ["Ragefire Shaman"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },
        ["Ragefire Trogg"]              = { mark = 5, creatureType = "Humanoid" },
    },

    ["Wailing Caverns"] = {
        ["Druid of the Fang"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer + lightning
        ["Deviate Viper"]               = { mark = 5, creatureType = "Beast" },
        ["Deviate Adder"]               = { mark = 5, creatureType = "Beast" },
        ["Deviate Raptor"]              = { mark = 5, creatureType = "Beast" },
        ["Deviate Ravager"]             = { mark = 5, creatureType = "Beast" },
        ["Deviate Shambler"]            = { mark = 8, creatureType = "Beast" },
        ["Deviate Stinglash"]           = { mark = 5, creatureType = "Beast" },
        ["Serpentbloom Snake"]          = "SKIP",
        ["Deviate Moccasin"]            = { mark = 5, creatureType = "Beast" },
    },

    ["The Deadmines"] = {
        ["Defias Blood Wizard"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- fire caster
        ["Defias Squallshaper"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- frost caster + heal
        ["Defias Envoker"]              = { mark = 8, creatureType = "Humanoid" },  -- holy fire caster
        ["Defias Pirate"]               = { mark = 5, creatureType = "Humanoid" },
        ["Defias Taskmaster"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- buffs allies
        ["Defias Overseer"]             = { mark = 8, creatureType = "Humanoid" },
        ["Defias Evoker"]               = { mark = 8, creatureType = "Humanoid" },
        ["Defias Cannoneer"]             = { mark = 8, creatureType = "Humanoid" },
        ["Defias Watcher"]              = { mark = 5, creatureType = "Humanoid" },
        ["Defias Strip Miner"]          = { mark = 5, creatureType = "Humanoid" },
        ["Goblin Woodcarver"]           = { mark = 5, creatureType = "Humanoid" },
        ["Goblin Engineer"]             = { mark = 5, creatureType = "Humanoid" },
        ["Goblin Shipbuilder"]          = { mark = 5, creatureType = "Humanoid" },
        ["Defias Miner"]                = { mark = 5, creatureType = "Humanoid" },
    },

    ["Shadowfang Keep"] = {
        ["Tormented Officer"]           = { mark = 8, creatureType = "Undead" },
        ["Wailing Guardsman"]           = { mark = 8, creatureType = "Undead", dangerLevel = 3, note = "Casts a 5-second AoE silence (not a fear); kill or control before it silences the healer and casters." },
        ["Unstable Ravager"]            = { mark = 8, creatureType = "Beast" },
        ["Shadowfang Darksoul"]         = { mark = 8, creatureType = "Humanoid" },
        ["Shadowfang Glutton"]          = { mark = 5, creatureType = "Humanoid" },
        ["Shadowfang Moonwalker"]       = { note = "Uses a temporary anti-magic shield; switch to melee damage or wait out the immunity." },
        ["Shadowfang Ragetooth"]        = { mark = 5, creatureType = "Humanoid" },
        ["Shadowfang Whitescalp"]       = { mark = 5, creatureType = "Humanoid" },
        ["Shadowfang Wolfguard"]        = { mark = 5, creatureType = "Humanoid" },
        ["Dark Creeper"]                = { mark = 5, creatureType = "Humanoid" },  -- stealth
        ["Corpse Eater"]                = { mark = 5, creatureType = "Beast" },
        ["Bleak Worg"]                  = { mark = 5, creatureType = "Beast" },
        ["Slavering Worg"]              = { mark = 5, creatureType = "Beast" },
        ["Lupine Horror"]               = { mark = 8, creatureType = "Beast" },
        ["Lupine Delusion"]             = { mark = 5, creatureType = "Beast" },
        ["Fel Steed"]                   = { note = "Hits hard but can be skipped; avoid an unnecessary pull." },
        ["Vile Bat"]                    = { mark = 5, creatureType = "Beast" },
    },

    ["The Stockade"] = {
        ["Defias Captive"]              = { mark = 7, creatureType = "Humanoid" },
        ["Defias Prisoner"]             = { mark = 5, creatureType = "Humanoid" },
        ["Defias Insurgent"]            = { mark = 8, creatureType = "Humanoid" },
        ["Defias Convict"]              = { mark = 5, creatureType = "Humanoid" },
        ["Defias Inmate"]               = { mark = 5, creatureType = "Humanoid" },
        ["Defias Wizard"]               = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },
        ["Riverpaw Mystic"]             = { mark = 8, creatureType = "Humanoid" },
        ["Riverpaw Overseer"]           = { mark = 8, creatureType = "Humanoid" },
        ["Riverpaw Herbalist"]          = { mark = 5, creatureType = "Humanoid" },
        ["Riverpaw Brute"]              = { mark = 5, creatureType = "Humanoid" },
    },

    ["Blackfathom Deeps"] = {
        ["Twilight Aquamancer"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- frost caster
        ["Twilight Shadowmage"]         = { mark = 8, creatureType = "Humanoid" },
        ["Twilight Loreseeker"]         = { mark = 8, creatureType = "Humanoid" },
        ["Twilight Acolyte"]            = { mark = 5, creatureType = "Humanoid" },
        ["Twilight Thug"]               = { mark = 5, creatureType = "Humanoid" },
        ["Blackfathom Tide Priestess"]  = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
        ["Murkshallow Snapclaw"]        = { mark = 5, creatureType = "Beast" },
        ["Fallenroot Rogue"]            = { mark = 5, creatureType = "Demon" },  -- Satyr are Demon
        ["Fallenroot Shaman"]           = { mark = 8, creatureType = "Demon" },
        ["Fallenroot Satyr"]            = { mark = 5, creatureType = "Demon" },
        ["Barbed Crustacean"]           = { mark = 5, creatureType = "Beast" },
        ["Aku'mai Servant"]             = { mark = 5, creatureType = "Beast" },
        ["Aku'mai Snapjaw"]             = { mark = 5, creatureType = "Beast" },
    },

    ["Gnomeregan"] = {
        ["Arcane Nullifier X-21"]       = { mark = 8, creatureType = "Mechanical", dangerLevel = 2, ccImmune = true },
        ["Leprous Technician"]          = { mark = 8, creatureType = "Humanoid" },
        ["Leprous Machinesmith"]        = { mark = 8, creatureType = "Humanoid" },
        ["Leprous Gnome"]               = { mark = 5, creatureType = "Humanoid" },
        ["Leprous Assistant"]           = { mark = 5, creatureType = "Humanoid" },
        ["Caverndeep Burrower"]         = { mark = 5, creatureType = "Humanoid" },  -- Troggs are Humanoid
        ["Caverndeep Ambusher"]         = { mark = 5, creatureType = "Humanoid" },
        ["Caverndeep Looter"]           = { mark = 5, creatureType = "Humanoid" },
        ["Caverndeep Trapper"]          = { mark = 5, creatureType = "Humanoid" },
        ["Mobile Alert System"]         = { mark = 8, creatureType = "Mechanical", dangerLevel = 3, ccImmune = true },
        ["Dark Iron Agent"]             = { mark = 8, creatureType = "Humanoid" },  -- stealth
        ["Dark Iron Ambassador"]        = { mark = 8, creatureType = "Humanoid" },
        ["Crowd Pummeler 9-60"]         = { mark = 8, creatureType = "Mechanical", ccImmune = true },
        ["Peacekeeper Security Suit"]   = { mark = 8, creatureType = "Mechanical", ccImmune = true },
        ["Alarm-a-bomb 2600"]           = { mark = 8, creatureType = "Mechanical", ccImmune = true },
        ["Security Golem"]              = { mark = 8, creatureType = "Mechanical", ccImmune = true },
        ["Walking Bomb"]                = "SKIP",
    },

    ["Razorfen Kraul"] = {
        ["Razorfen Dustweaver"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- lightning + heal
        ["Razorfen Geomancer"]          = { mark = 8, creatureType = "Humanoid" },
        ["Razorfen Warden"]             = { mark = 5, creatureType = "Humanoid" },
        ["Razorfen Defender"]           = { mark = 5, creatureType = "Humanoid" },
        ["Razorfen Battleguard"]        = { mark = 5, creatureType = "Humanoid" },
        ["Death's Head Seer"]           = { mark = 8, creatureType = "Humanoid" },
        ["Death's Head Cultist"]        = { mark = 8, creatureType = "Humanoid" },
        ["Death's Head Adept"]          = { mark = 8, creatureType = "Humanoid" },
        ["Razorfen Servitor"]           = { mark = 5, creatureType = "Humanoid" },
        ["Razorfen Beastmaster"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- beast caller
        ["Razorfen Handler"]            = { mark = 8, creatureType = "Humanoid" },
        ["Greater Kraul Bat"]           = { mark = 5, creatureType = "Beast" },
        ["Kraul Bat"]                   = "SKIP",
        ["Agile Kraul"]                 = { mark = 5, creatureType = "Beast" },
    },

    ["Razorfen Downs"] = {
        ["Ragglesnout"]                = { mark = 8, creatureType = "Humanoid", dangerLevel = 3, note = "Rare priest-type mob can Dominate Mind and heal; interrupt the heal and control the mind-control cast." },
        ["Death's Head Necromancer"]    = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- raises undead
        ["Death's Head Sage"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },
        ["Death's Head Priest"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
        ["Death's Head Ward Keeper"]    = { mark = 8, creatureType = "Humanoid" },
        ["Withered Quilguard"]          = { mark = 5, creatureType = "Undead" },
        ["Withered Battle Boar"]        = { mark = 5, creatureType = "Undead" },
        ["Withered Reaver"]             = { mark = 5, creatureType = "Undead" },
        ["Withered Spearhide"]          = { mark = 5, creatureType = "Undead" },
        ["Frozen Soul"]                 = { mark = 5, creatureType = "Undead" },
        ["Plaguemaw the Rotting"]       = { mark = 8, creatureType = "Undead" },
        ["Tomb Fiend"]                  = { mark = 5, creatureType = "Undead" },
        ["Tomb Reaver"]                 = { mark = 5, creatureType = "Undead" },
    },

    ["Scarlet Halls"] = {
        ["Scarlet Evoker"]              = { mark = 8, creatureType = "Humanoid" },
        ["Scarlet Treasurer"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
        ["Scarlet Scholar"]             = { mark = 8, creatureType = "Humanoid" },
        ["Scarlet Cannoneer"]           = { mark = 8, creatureType = "Humanoid" },
        ["Master Dog Trainer"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- beast caller
        ["Scarlet Evangelist"]          = { mark = 5, creatureType = "Humanoid" },
        ["Scarlet Myrmidon"]            = { mark = 5, creatureType = "Humanoid" },
        ["Scarlet Defender"]            = { mark = 5, creatureType = "Humanoid" },
        ["Hound"]                       = "SKIP",
    },

    ["Scarlet Monastery"] = {
        ["Scarlet Zealot"]              = { mark = 8, creatureType = "Humanoid" },
        ["Scarlet Chaplain"]            = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
        ["Scarlet Judicator"]           = { mark = 8, creatureType = "Humanoid" },
        ["Scarlet Fanatic"]             = { mark = 5, creatureType = "Humanoid" },
        ["Scarlet Friar"]               = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer
        ["Scarlet Purifier"]            = { mark = 8, creatureType = "Humanoid" },
        ["Scarlet Centurion"]           = { mark = 5, creatureType = "Humanoid" },
        ["Scarlet Torturer"]            = { mark = 8, creatureType = "Humanoid" },
        ["Scarlet Interrogator"]        = { mark = 8, creatureType = "Humanoid" },
        ["Scarlet Wizard"]              = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },
        ["Scarlet Abbot"]               = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
        ["Scarlet Monk"]                = { mark = 5, creatureType = "Humanoid" },
        ["Scarlet Sorcerer"]            = { mark = 8, creatureType = "Humanoid" },
    },

    ["Zul'Farrak"] = {
        ["Sandfury Witch Doctor"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- healer + hex
        ["Sandfury Shadowcaster"]       = { mark = 8, creatureType = "Humanoid" },
        ["Sandfury Firecaller"]         = { mark = 8, creatureType = "Humanoid" },
        ["Sandfury Blood Drinker"]      = { mark = 8, creatureType = "Humanoid" },
        ["Sandfury Zealot"]             = { mark = 5, creatureType = "Humanoid" },
        ["Sandfury Axe Thrower"]        = { mark = 5, creatureType = "Humanoid" },
        ["Sandfury Drudge"]             = { mark = 5, creatureType = "Humanoid" },
        ["Sandfury Guardian"]           = { mark = 5, creatureType = "Humanoid" },
        ["Sandfury Hideskinner"]        = { mark = 5, creatureType = "Humanoid" },
        ["Sandfury Soul Eater"]         = { mark = 8, creatureType = "Humanoid" },
        ["Sandfury Executioner"]        = { mark = 5, creatureType = "Humanoid" },
        ["Sul'lithuz Warder"]           = { mark = 5, creatureType = "Beast" },
        ["Sul'lithuz Broodling"]        = { mark = 5, creatureType = "Beast" },
        ["Troll Totem"]                 = "SKIP",
    },

    ["Maraudon"] = {
        ["Celebras Elementalist"]       = { mark = 8, creatureType = "Elemental" },
        ["Barbed Lasher"]               = { mark = 5, creatureType = "Elemental" },  -- plants
        ["Putrid Shrieker"]             = { mark = 8, creatureType = "Elemental", dangerLevel = 2 },  -- fear
        ["Vile Larva"]                  = "SKIP",
        ["Centaur Pariah"]              = { mark = 8, creatureType = "Humanoid" },
        ["Maraudine Bonepaw"]           = { mark = 5, creatureType = "Humanoid" },
        ["Maraudine Stormer"]           = { mark = 8, creatureType = "Humanoid" },
        ["Maraudine Scout"]             = { mark = 5, creatureType = "Humanoid" },
        ["Maraudine Khan Advisor"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },
        ["Maraudine Wrangler"]          = { mark = 5, creatureType = "Humanoid" },
        ["Meshlok the Harvester"]       = { mark = 8, creatureType = "Elemental" },
        ["Theradrim Guardian"]          = { mark = 8, creatureType = "Elemental" },
        ["Theradrim Shardling"]         = { mark = 5, creatureType = "Elemental" },
        ["Thessala Hydra"]              = { mark = 8, creatureType = "Beast", ccImmune = true },
        ["Noxxion's Spawn"]             = "SKIP",
        ["Poison Sprite"]               = { mark = 5, creatureType = "Elemental" },
        ["Spewed Larva"]                = "SKIP",
    },

    ["Dire Maul"] = {
        ["Gordok Ogre-Mage"]            = { mark = 8, creatureType = "Humanoid" },
        ["Gordok Warlock"]              = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- demon summoner
        ["Gordok Mage-Lord"]            = { mark = 8, creatureType = "Humanoid" },
        ["Gordok Bushwacker"]           = { mark = 5, creatureType = "Humanoid" },
        ["Gordok Brute"]                = { mark = 5, creatureType = "Humanoid" },
        ["Gordok Enforcer"]             = { mark = 5, creatureType = "Humanoid" },
        ["Gordok Reaver"]               = { mark = 5, creatureType = "Humanoid" },
        ["Gordok Mastiff"]              = { mark = 5, creatureType = "Beast" },
        ["Gordok Captain"]              = { mark = 8, creatureType = "Humanoid" },
        ["Gordok Mauler"]               = { mark = 5, creatureType = "Humanoid" },
        ["Wildspawn Imp"]               = { mark = 4, creatureType = "Demon" },  -- banish
        ["Wildspawn Shadowstalker"]     = { mark = 8, creatureType = "Demon" },
        ["Wildspawn Felsworn"]          = { mark = 8, creatureType = "Demon" },
        ["Wildspawn Rogue"]             = { mark = 5, creatureType = "Demon" },
        ["Wildspawn Satyr"]             = { mark = 5, creatureType = "Demon" },
        ["Wildspawn Betrayer"]          = { mark = 5, creatureType = "Demon" },
        ["Warpwood Treant"]             = { mark = 5, creatureType = "Elemental" },
        ["Warpwood Stomper"]            = { mark = 5, creatureType = "Elemental" },
        ["Warpwood Guardian"]           = { mark = 5, creatureType = "Elemental" },
        ["Warpwood Moss Flayer"]        = { mark = 5, creatureType = "Elemental" },
        ["Warpwood Shredder"]           = { mark = 5, creatureType = "Elemental" },
        ["Felvine Shard"]               = "SKIP",
        ["Lethtendris"]                 = { mark = 8, creatureType = "Humanoid" },
        ["Hydrospawn"]                  = { mark = 8, creatureType = "Elemental" },
        ["Mushgog"]                     = { mark = 8, creatureType = "Elemental" },
        ["Isalien"]                     = { mark = 8, creatureType = "Humanoid" },
        ["Zevrim Thornhoof"]            = { mark = 8, creatureType = "Demon" },
    },

    ["Stratholme"] = {
        ["Risen Sorcerer"]              = { mark = 8, creatureType = "Undead" },
        ["Risen Priest"]                = { mark = 8, creatureType = "Undead", dangerLevel = 3 },  -- healer
        ["Risen Lackey"]                = { mark = 5, creatureType = "Undead" },
        ["Risen Bonewarder"]            = { mark = 5, creatureType = "Undead" },
        ["Risen Warlord"]               = { mark = 8, creatureType = "Undead" },
        ["Risen Guard"]                 = { mark = 5, creatureType = "Undead" },
        ["Risen Constable"]             = { mark = 5, creatureType = "Undead" },
        ["Risen Hammersmith"]           = { mark = 5, creatureType = "Undead" },
        ["Risen Deathsworn"]            = { mark = 8, creatureType = "Undead" },
        ["Crimson Sorcerer"]            = { mark = 8, creatureType = "Humanoid" },
        ["Crimson Priest"]              = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
        ["Crimson Gallant"]             = { mark = 5, creatureType = "Humanoid" },
        ["Crimson Inquisitor"]          = { mark = 8, creatureType = "Humanoid" },
        ["Crimson Conjurer"]            = { mark = 8, creatureType = "Humanoid" },
        ["Crimson Initiate"]            = { mark = 5, creatureType = "Humanoid" },
        ["Crimson Defender"]            = { mark = 5, creatureType = "Humanoid" },
        ["Crimson Battle Mage"]         = { mark = 8, creatureType = "Humanoid" },
        ["Crimson Monk"]                = { mark = 5, creatureType = "Humanoid" },
        ["Thuzadin Necromancer"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
        ["Thuzadin Shadowcaster"]       = { mark = 8, creatureType = "Humanoid" },
        ["Thuzadin Acolyte"]            = { mark = 8, creatureType = "Humanoid" },
        ["Eye of Naxxramas"]            = { mark = 8, creatureType = "Undead", dangerLevel = 2 },
        ["Ash'ari Crystal"]             = "SKIP",
        ["Skeletal Sorcerer"]           = { mark = 8, creatureType = "Undead" },
        ["Skeletal Guardian"]           = { mark = 5, creatureType = "Undead" },
        ["Skeletal Berserker"]          = { mark = 5, creatureType = "Undead" },
        ["Mindless Skeleton"]           = "SKIP",
        ["Mindless Zombie"]             = "SKIP",
        ["Plagued Rat"]                 = "SKIP",
        ["Plagued Maggot"]              = "SKIP",
        ["Plagued Gargoyle"]            = { mark = 5, creatureType = "Undead" },
        ["Plagued Ghoul"]               = { mark = 5, creatureType = "Undead" },
        ["Patchwork Horror"]            = { mark = 5, creatureType = "Undead" },
        ["Ghostly Citizen"]             = { mark = 5, creatureType = "Undead" },
        ["Spectral Citizen"]            = { mark = 5, creatureType = "Undead" },
        ["Cannibal Ghoul"]              = { mark = 5, creatureType = "Undead" },
        ["Crypt Crawler"]               = { mark = 5, creatureType = "Beast" },
        ["Crypt Beast"]                 = { mark = 5, creatureType = "Beast" },
        ["Crypt Slayer"]                = { mark = 5, creatureType = "Beast" },
        ["Crypt Fiend"]                 = { mark = 8, creatureType = "Undead" },
        ["Venom Belcher"]               = { mark = 5, creatureType = "Beast" },
    },

    ["Scholomance"] = {
        ["Scholomance Acolyte"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, note = "Caster packs are dangerous; pull one group at a time back toward the entrance to avoid chain pulls." },
        ["Scholomance Necrolyte"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3, note = "High-risk caster; isolate its pack and interrupt dangerous casts." },
        ["Scholomance Neophyte"]        = { mark = 5, creatureType = "Humanoid" },
        ["Scholomance Student"]         = { note = "Viewing-room elite students are commonly skipped unless needed for a quest." },
        ["Scholomance Adept"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, note = "Caster-pack target; use careful single-pack pulls and interrupt casts where possible." },
        ["Scholomance Dark Summoner"]   = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
        ["Scholomance Occultist"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, note = "Caster-pack target; avoid chaining nearby pulls." },
        ["Boneweaver"]                  = { mark = 8, creatureType = "Undead" },
        ["Candlestick Mage"]            = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, note = "Caster; pull carefully with nearby Scholomance packs." },
        ["Reanimated Corpse"]           = "SKIP",
        ["Risen Construct"]             = { mark = 5, creatureType = "Undead" },
        ["Risen Abomination"]           = { mark = 5, creatureType = "Undead" },
        ["Risen Protector"]             = { mark = 5, creatureType = "Undead" },
        ["Risen Guardsman"]             = { mark = 5, creatureType = "Undead" },
        ["Unstable Corpse"]             = { mark = 5, creatureType = "Undead" },
        ["Wailing Death"]               = { mark = 8, creatureType = "Undead", dangerLevel = 2 },
        ["Diseased Ghoul"]              = { mark = 5, creatureType = "Undead" },
        ["Rattlegore"]                  = { mark = 8, creatureType = "Undead", dangerLevel = 2, note = "The nearby trash hits hard and can stun tanks; pull the room slowly and separately." },
    },

    ["The Temple of Atal'Hakkar"] = {
        ["Atal'ai Deathwalker"]         = { mark = 8, creatureType = "Humanoid" },
        ["Atal'ai Priest"]              = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
        ["Atal'ai Witch Doctor"]        = { mark = 8, creatureType = "Humanoid" },
        ["Atal'ai Slave"]               = { mark = 5, creatureType = "Humanoid" },
        ["Atal'ai Warrior"]              = { mark = 5, creatureType = "Humanoid" },
        ["Atal'ai High Priest"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
        ["Gaseous Lurker"]              = { mark = 4, creatureType = "Elemental" },
        ["Suppressor"]                  = { mark = 5, creatureType = "Elemental" },
        ["Murk Spawn"]                  = { mark = 5, creatureType = "Elemental" },
        ["Temple Interior Guardian"]    = { mark = 5, creatureType = "Humanoid" },
        ["Hakkari Bloodkeeper"]         = { mark = 8, creatureType = "Humanoid" },
        ["Hakkari Frostwing"]           = { mark = 5, creatureType = "Dragonkin" },
        ["Hakkari Minion"]              = { mark = 5, creatureType = "Humanoid" },
        ["Hakkari Oracle"]              = { mark = 8, creatureType = "Humanoid" },
        ["Hakkari Shadowcaster"]        = { mark = 8, creatureType = "Humanoid" },
        ["Jade Ooze"]                   = "SKIP",
        ["Jade Sludge"]                 = "SKIP",
        ["Spawn of Hakkar"]             = { mark = 5, creatureType = "Dragonkin" },
    },

    ["Blackrock Depths"] = {
        ["Shadowforge Surveyor"]        = { mark = 8, creatureType = "Humanoid" },
        ["Shadowforge Flame Keeper"]    = { mark = 8, creatureType = "Humanoid" },
        ["Shadowforge Sharpshooter"]    = { mark = 8, creatureType = "Humanoid" },
        ["Shadowforge Senator"]         = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },
        ["Shadowforge Citizen"]         = { mark = 5, creatureType = "Humanoid" },
        ["Shadowforge Warder"]          = { mark = 5, creatureType = "Humanoid" },
        ["Shadowforge Darkweaver"]      = { mark = 8, creatureType = "Humanoid" },
        ["Shadowforge Darkcaster"]      = { mark = 8, creatureType = "Humanoid" },
        ["Shadowforge Peasant"]         = "SKIP",
        ["Shadowforge Chanter"]         = { mark = 8, creatureType = "Humanoid" },
        ["Dark Iron Medic"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
        ["Dark Iron Tastetester"]       = { mark = 5, creatureType = "Humanoid" },
        ["Dark Iron Slaver"]            = { mark = 5, creatureType = "Humanoid" },
        ["Dark Iron Lookout"]           = { mark = 5, creatureType = "Humanoid" },
        ["Dark Iron Raider"]            = { mark = 5, creatureType = "Humanoid" },
        ["Dark Iron Watchman"]          = { mark = 5, creatureType = "Humanoid" },
        ["Dark Iron Steamsmith"]        = { mark = 5, creatureType = "Humanoid" },
        ["Anvilrage Officer"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- rallies
        ["Anvilrage Guardsman"]         = { mark = 5, creatureType = "Humanoid" },
        ["Anvilrage Warden"]            = { mark = 5, creatureType = "Humanoid" },
        ["Anvilrage Soldier"]           = { mark = 5, creatureType = "Humanoid" },
        ["Anvilrage Footman"]           = { mark = 5, creatureType = "Humanoid" },
        ["Anvilrage Marshal"]           = { mark = 8, creatureType = "Humanoid" },
        ["Anvilrage Medic"]             = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
        ["Anvilrage Reservist"]         = { mark = 5, creatureType = "Humanoid" },
        ["Ragereaver Golem"]            = { mark = 8, creatureType = "Elemental" },
        ["Wrath Hammer Construct"]      = { mark = 8, creatureType = "Elemental" },
        ["Molten War Golem"]            = { mark = 8, creatureType = "Elemental" },
        ["Core Rager"]                  = { mark = 8, creatureType = "Elemental" },
        ["Bael'Gar"]                    = { mark = 8, creatureType = "Elemental" },
        ["Fireguard"]                   = { mark = 5, creatureType = "Elemental" },
        ["Twilight's Hammer Torturer"]  = { mark = 8, creatureType = "Humanoid" },
        ["Twilight's Hammer Ambassador"] = { mark = 8, creatureType = "Humanoid" },
        ["Weapon Technician"]           = { mark = 5, creatureType = "Humanoid" },
        ["Ironhand Guardian"]           = { mark = 8, creatureType = "Elemental", ccImmune = true },
    },

    ["Lower Blackrock Spire"] = {
        ["Blackhand Summoner"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
        ["Blackhand Incarcerator"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- stuns
        ["Blackhand Dragon Handler"]    = { mark = 8, creatureType = "Humanoid" },
        ["Blackhand Iron Guard"]        = { mark = 5, creatureType = "Humanoid" },
        ["Blackhand Veteran"]           = { mark = 5, creatureType = "Humanoid" },
        ["Blackhand Assassin"]          = { mark = 8, creatureType = "Humanoid" },
        ["Smolderthorn Shadow Priest"]  = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
        ["Smolderthorn Witch Doctor"]   = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
        ["Smolderthorn Seer"]           = { mark = 8, creatureType = "Humanoid" },
        ["Smolderthorn Headhunter"]     = { mark = 5, creatureType = "Humanoid" },
        ["Smolderthorn Berserker"]      = { mark = 5, creatureType = "Humanoid" },
        ["Smolderthorn Axe Thrower"]    = { mark = 5, creatureType = "Humanoid" },
        ["Smolderthorn Mystic"]         = { mark = 8, creatureType = "Humanoid" },
        ["Scarshield Warlock"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
        ["Scarshield Spellbinder"]      = { mark = 8, creatureType = "Humanoid" },
        ["Scarshield Quartermaster"]    = { mark = 5, creatureType = "Humanoid" },
        ["Scarshield Legionnaire"]      = { mark = 5, creatureType = "Humanoid" },
        ["Spirestone Mystic"]           = { mark = 8, creatureType = "Humanoid" },
        ["Spirestone Ogre Magus"]       = { mark = 8, creatureType = "Humanoid" },
        ["Spirestone Battle Mage"]      = { mark = 5, creatureType = "Humanoid" },
        ["Spirestone Lord Magus"]       = { mark = 8, creatureType = "Humanoid" },
        ["Spirestone Warlord"]          = { mark = 8, creatureType = "Humanoid" },
        ["Spirestone Butcher"]          = { mark = 5, creatureType = "Humanoid" },
        ["Spirestone Enforcer"]         = { mark = 5, creatureType = "Humanoid" },
        ["Rage Talon Dragonspawn"]      = { mark = 5, creatureType = "Dragonkin" },
        ["Rage Talon Flamescale"]       = { mark = 5, creatureType = "Dragonkin" },
        ["Rage Talon Fire Tongue"]      = { mark = 5, creatureType = "Dragonkin" },
        ["Rage Talon Captain"]          = { mark = 8, creatureType = "Dragonkin" },
        ["Firebrand Grunt"]             = { mark = 5, creatureType = "Humanoid" },
        ["Firebrand Legionnaire"]       = { mark = 5, creatureType = "Humanoid" },
        ["War Hound"]                   = { mark = 5, creatureType = "Beast" },
        ["Shadowforge Spirit"]          = { mark = 5, creatureType = "Undead" },
    },

    ["Uldaman"] = {
        ["Shadowforge Geologist"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Flame Spike / Fireball
        ["Shadowforge Darkcaster"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Shadow Bolt / Mana Burn
        ["Shadowforge Relic Hunter"]    = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Heals
        ["Shadowforge Archaeologist"]   = { mark = 5, creatureType = "Humanoid" },
        ["Shadowforge Ruffian"]         = { mark = 3, creatureType = "Humanoid" },
        ["Shadowforge Shovelphlange"]   = { mark = 5, creatureType = "Humanoid" },
        ["Shadowforge Ambusher"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },
        ["Shadowforge Sharpshooter"]    = { mark = 5, creatureType = "Humanoid" },
        ["Stonevault Pillager"]         = { mark = 5, creatureType = "Humanoid" },
        ["Stonevault Brawler"]          = { mark = 5, creatureType = "Humanoid" },
        ["Stonevault Geomancer"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Fireball / Flame Buffet
        ["Stonevault Oracle"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Healing Wave / Lava Spout Totem
        ["Stonevault Flameweaver"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },
        ["Stonevault Ambusher"]         = { mark = 5, creatureType = "Humanoid" },
        ["Stonevault Mauler"]           = { mark = 5, creatureType = "Humanoid" },
        ["Earthen Custodian"]           = { mark = 7, creatureType = "Humanoid", ccImmune = true },
        ["Earthen Guardian"]            = { mark = 5, creatureType = "Humanoid" },
        ["Earthen Sculptor"]            = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },
        ["Earthen Hallshaper"]          = { mark = 5, creatureType = "Humanoid" },
        ["Stone Steward"]               = { mark = 7, creatureType = "Mechanical", ccImmune = true },
        ["Jadespine Basilisk"]          = { mark = 8, creatureType = "Beast", dangerLevel = 2 },     -- Crystalline Slumber
        ["Cleft Scorpid"]               = { mark = 5, creatureType = "Beast" },
        ["Shrieking Bat"]               = { mark = 8, creatureType = "Beast", dangerLevel = 2 },     -- Sonic Burst silence
        ["Venomlash Scorpid"]           = { mark = 5, creatureType = "Beast" },
    },

    ["Upper Blackrock Spire"] = {
        ["Blackhand Summoner"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Summons Dreadweaver / Veteran
        ["Blackhand Dreadweaver"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Veil of Shadow / Shadow Bolt
        ["Blackhand Incarcerator"]      = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- Encage
        ["Blackhand Dragon Handler"]    = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },  -- Mends dragonkin
        ["Blackhand Veteran"]           = { mark = 5, creatureType = "Humanoid" },
        ["Blackhand Iron Guard"]        = { mark = 5, creatureType = "Humanoid" },
        ["Blackhand Assassin"]          = { mark = 3, creatureType = "Humanoid", dangerLevel = 2 },
        ["Blackhand Thug"]              = { mark = 5, creatureType = "Humanoid" },
        ["Rage Talon Fire Tongue"]      = { mark = 8, creatureType = "Dragonkin", dangerLevel = 2 },
        ["Rage Talon Captain"]          = { mark = 7, creatureType = "Dragonkin", dangerLevel = 2 },
        ["Rage Talon Dragon Guard"]     = { mark = 2, creatureType = "Dragonkin" },
        ["Rage Talon Flamescale"]       = { mark = 2, creatureType = "Dragonkin" },
        ["Chromadrake"]                 = { mark = 2, creatureType = "Dragonkin", dangerLevel = 2 },
        ["Rookery Whelp"]               = "SKIP",
        ["Rookery Guardian"]            = { mark = 8, creatureType = "Dragonkin", dangerLevel = 2 },
    },

    -- ============================================================
    -- CLASSIC RAIDS
    -- ============================================================

    ["Molten Core"] = {
        ["Firelord"]                    = { mark = 8, creatureType = "Elemental", dangerLevel = 2, note = "Kill the Lava Spawn adds as they appear; these are not Ragnaros' Sons of Flame." },
        ["Flamewaker"]                  = { mark = 5, creatureType = "Elemental" },
        ["Flamewaker Elite"]            = { note = "Majordomo pack: keep the elites controlled/tanked separately and follow the raid-assigned add order." },
        ["Flamewaker Healer"]           = { mark = 8, creatureType = "Elemental", dangerLevel = 3 },
        ["Flamewaker Priest"]           = { mark = 8, creatureType = "Elemental", dangerLevel = 3 },
        ["Flamewaker Protector"]        = { mark = 5, creatureType = "Elemental" },
        ["Firesworn"]                   = { note = "Explodes on death; spread and handle one at a time. Its relative kill order depends on the raid plan, so no fixed mark is enforced." },
        ["Son of Flame"]                = { mark = 8, creatureType = "Elemental", dangerLevel = 3, note = "Ragnaros phase add; control and burn promptly according to the raid assignment." },
        ["Ancient Core Hound"]          = { mark = 5, creatureType = "Beast" },
        ["Core Hound"]                  = { mark = 5, creatureType = "Beast" },
        ["Lava Elemental"]              = { mark = 4, creatureType = "Elemental", dangerLevel = 2, note = "Elemental trash can be banished or stunned; coordinate control with the tank." },
        ["Lava Surger"]                 = { mark = 4, creatureType = "Elemental", dangerLevel = 2, note = "Knockback hazard; fight away from ledges and use Banish/other control if assigned." },
        ["Lava Annihilator"]            = { note = "Handle as a separate tanked elemental; exact focus order is pack-dependent." },
        ["Lava Reaver"]                 = { mark = 4, creatureType = "Elemental", dangerLevel = 2, note = "May be banished/controlled; follow the tank and raid assignment." },
        ["Primal Flame Elemental"]      = { mark = 5, creatureType = "Elemental" },
        ["Molten Giant"]                = { note = "Stuns and heavy melee make separate tanking important; giants are handled one at a time, not by a universal kill order." },
        ["Molten Destroyer"]            = { note = "Stuns and heavy melee make separate tanking important; giants are handled one at a time, not by a universal kill order." },
        ["Flame Imp"]                   = "SKIP",
        ["Lava Spawn"]                  = { mark = 8, creatureType = "Elemental", dangerLevel = 3, note = "Firelord adds; switch to and kill these promptly as they spawn." },
    },

    ["Onyxia's Lair"] = {
        ["Onyxian Warder"]              = { mark = 8, creatureType = "Dragonkin" },
        ["Onyxian Whelp"]                = "SKIP",
        ["Onyxian Lair Guard"]          = { mark = 8, creatureType = "Dragonkin" },
    },

    ["Blackwing Lair"] = {
        ["Grethok the Controller"]     = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
        ["Blackwing Mage"]              = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, note = "Caster priority on later mixed pulls; kill casters while tanks hold the dangerous dragonkin separately." },
        ["Blackwing Spellbinder"]       = { mark = 8, creatureType = "Humanoid", dangerLevel = 2, note = "Caster priority on later mixed pulls; keep the tanked dragonkin controlled separately." },
        ["Blackwing Taskmaster"]        = { mark = 5, creatureType = "Humanoid" },
        ["Blackwing Warlock"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 3, note = "Focus dangerous caster adds while tanks hold Overseers/Wyrmguards separately." },
        ["Blackwing Guardsman"]         = { mark = 5, creatureType = "Humanoid" },
        ["Blackwing Legionnaire"]       = { mark = 5, creatureType = "Humanoid" },
        ["Blackwing Technician"]        = { mark = "SKIP", creatureType = "Humanoid", note = "Hunter kites these bomb-throwers; the raid ignores them while killing the other adds. Do not focus-mark." },
        ["Death Talon Captain"]         = { mark = 8, creatureType = "Dragonkin" },
        ["Death Talon Flamescale"]      = { mark = 5, creatureType = "Dragonkin" },
        ["Death Talon Hatcher"]         = { mark = 8, creatureType = "Dragonkin", dangerLevel = 3 },
        ["Death Talon Overseer"]        = { note = "Very dangerous; tank separately and space from Wyrmguards while the raid kills casters. The encounter plan, not a fixed mark, controls its order." },
        ["Death Talon Seether"]         = { mark = 5, creatureType = "Dragonkin" },
        ["Death Talon Dragonspawn"]     = { mark = 5, creatureType = "Dragonkin" },
        ["Death Talon Wyrmkin"]         = { mark = 5, creatureType = "Dragonkin" },
        ["Death Talon Wyrmguard"]       = { note = "Very dangerous; tank separately and space from Overseers while the raid kills casters. The encounter plan, not a fixed mark, controls its order." },
        ["Master Elemental Shaper Krixix"] = { mark = 8, creatureType = "Humanoid" },
        ["Enraged Felguard"]            = { mark = 5, creatureType = "Demon" },
        ["Black Whelp"]                 = "SKIP",
        ["Blue Whelp"]                  = "SKIP",
        ["Bronze Whelp"]                = "SKIP",
        ["Corrupted Blue Whelp"]        = "SKIP",
        ["Corrupted Bronze Whelp"]      = "SKIP",
        ["Corrupted Green Whelp"]       = "SKIP",
        ["Corrupted Red Whelp"]         = "SKIP",
        ["Green Whelp"]                 = "SKIP",
        ["Red Whelp"]                   = "SKIP",
    },

    ["Zul'Gurub"] = {
        ["Gurubashi Bat Rider"]         = { mark = 8, creatureType = "Humanoid" },
        ["Gurubashi Blood Drinker"]     = { mark = 8, creatureType = "Humanoid" },
        ["Gurubashi Berserker"]         = { mark = 5, creatureType = "Humanoid" },
        ["Gurubashi Headhunter"]        = { mark = 5, creatureType = "Humanoid" },
        ["Gurubashi Axe Thrower"]       = { mark = 5, creatureType = "Humanoid" },
        ["Gurubashi Champion"]          = { mark = 5, creatureType = "Humanoid" },
        ["Gurubashi Warrior"]           = { mark = 5, creatureType = "Humanoid" },
        ["Hakkari Blood Priest"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
        ["Hakkari Priest"]              = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
        ["Hakkari Shadow Hunter"]       = { mark = 8, creatureType = "Humanoid" },
        ["Hakkari Shadowcaster"]        = { mark = 8, creatureType = "Humanoid" },
        ["Hakkari Witch Doctor"]        = { mark = 8, creatureType = "Humanoid", dangerLevel = 3 },
        ["Mad Servant"]                 = { mark = 8, creatureType = "Humanoid" },
        ["Ohgan"]                       = { mark = 8, creatureType = "Beast" },
        ["Powerful Healing Ward"]       = { mark = 8, creatureType = "Elemental", dangerLevel = 3 },
        ["Son of Hakkar"]               = { mark = 8, creatureType = "Dragonkin" },
        ["Zanza the Restless"]          = { mark = 8, creatureType = "Humanoid" },
        ["Zealot Lor'Khan"]             = { mark = 8, creatureType = "Humanoid" },
        ["Zealot Zath"]                 = { mark = 8, creatureType = "Humanoid" },
        ["Mad Voidwalker"]              = { mark = 4, creatureType = "Demon" },
        ["Razzashi Adder"]              = { mark = 5, creatureType = "Beast" },
        ["Razzashi Cobra"]              = { mark = 5, creatureType = "Beast" },
        ["Razzashi Raptor"]             = { mark = 5, creatureType = "Beast" },
        ["Razzashi Serpent"]            = { mark = 5, creatureType = "Beast" },
        ["Razzashi Venombrood"]         = { mark = 5, creatureType = "Beast" },
        ["Zulian Guardian"]             = { mark = 5, creatureType = "Beast" },
        ["Zulian Panther"]              = { mark = 5, creatureType = "Beast" },
        ["Zulian Stalker"]              = { mark = 5, creatureType = "Beast" },
        ["Zulian Tiger"]                = { mark = 5, creatureType = "Beast" },
        ["Zulian Prowler"]              = { mark = 5, creatureType = "Beast" },
        ["Bloodseeker Bat"]             = { mark = 5, creatureType = "Beast" },
        ["Frog"]                        = "SKIP",
        ["Jungle Toad"]                 = "SKIP",
        ["Parasitic Serpent"]           = "SKIP",
        ["Snake"]                       = "SKIP",
        ["Spider"]                      = "SKIP",
        ["Toad"]                        = "SKIP",
    },

    ["Ruins of Ahn'Qiraj"] = {
        ["Anubisath Guardian"]          = { mark = 8, creatureType = "Humanoid" },
        ["Anubisath Swarmguard"]        = { mark = 8, creatureType = "Humanoid" },
        ["Anubisath Warder"]            = { mark = 8, creatureType = "Humanoid" },
        ["Colonel Zerran"]              = { mark = 8, creatureType = "Humanoid" },
        ["Hive'Zara Hornet"]            = { mark = 5, creatureType = "Beast" },
        ["Hive'Zara Stinger"]           = { mark = 5, creatureType = "Beast" },
        ["Hive'Zara Soldier"]           = { mark = 5, creatureType = "Beast" },
        ["Hive'Zara Wasp"]              = { mark = 5, creatureType = "Beast" },
        ["Mana Fiend"]                  = { mark = 8, creatureType = "Humanoid" },
        ["Major Yeggeth"]               = { mark = 8, creatureType = "Humanoid" },
        ["Major Pakkon"]                = { mark = 8, creatureType = "Humanoid" },
        ["Captain Drenn"]               = { mark = 8, creatureType = "Humanoid" },
        ["Captain Qeez"]                = { mark = 8, creatureType = "Humanoid" },
        ["Captain Tuubid"]              = { mark = 8, creatureType = "Humanoid" },
        ["Captain Xurrem"]              = { mark = 8, creatureType = "Humanoid" },
        ["Obsidian Destroyer"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },  -- mana drain
        ["Spitting Scarab"]             = { mark = 5, creatureType = "Beast" },
        ["Swarmguard Needler"]          = { mark = 5, creatureType = "Beast" },
        ["Beetle"]                      = "SKIP",
        ["Buru Egg"]                    = "SKIP",
        ["Canal Frenzy"]                = "SKIP",
        ["Hive'Zara Larva"]             = "SKIP",
        ["Scorpion"]                    = "SKIP",
        ["Silicate Feeder"]             = "SKIP",
    },

    ["Temple of Ahn'Qiraj"] = {
        ["Anubisath Defender"]          = { note = "Handle Meteor, Plague, and Explode by their mechanics; defenders must be cleared before Twin Emperors, but no universal pack kill order is safe." },
        ["Anubisath Sentinel"]          = { note = "Ability rolls differ: kill the Sentinel with the least dangerous ability first because survivors heal and inherit the dead Sentinel's ability." },
        ["Eye Tentacle"]                = { mark = 8, creatureType = "Aberration", ccImmune = true },
        ["Giant Eye Tentacle"]          = { mark = 8, creatureType = "Aberration", ccImmune = true },
        ["Giant Claw Tentacle"]         = { mark = 8, creatureType = "Aberration", ccImmune = true },
        ["Qiraji Scarab"]               = { mark = 5, creatureType = "Beast" },
        ["Obsidian Eradicator"]         = { note = "Pull/tank separately and interrupt or control its dangerous casts; exact order depends on the pack and raid plan." },
        ["Obsidian Nullifier"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 2 },
        ["Qiraji Brainwasher"]          = { mark = 8, creatureType = "Humanoid", dangerLevel = 3, note = "Mind Control and feared Mind Flay make this the first kill in packs with Vekniss Warriors." },
        ["Qiraji Mindslayer"]           = { mark = 8, creatureType = "Humanoid", dangerLevel = 3, note = "In the pre-C'Thun Mindslayer packs, focus Mindslayers before Champions and Slayers." },
        ["Qiraji Champion"]             = { mark = 7, creatureType = "Humanoid", dangerLevel = 2, note = "Pre-C'Thun pack order: after Mindslayers and before Slayers." },
        ["Qiraji Slayer"]               = { note = "Pre-C'Thun three-target order places Slayers after Mindslayers and Champions; the addon has no third dedicated kill-order icon, so this remains informational." },
        ["Qiraji Swarmguard"]           = { mark = 5, creatureType = "Humanoid" },
        ["Qiraji Lasher"]              = { mark = 8, creatureType = "Humanoid", dangerLevel = 3, note = "Whirlwind/knockback hazard; pull packs back. In Vekniss Wasp packs, usually kill the Lasher first." },
        ["Spawn of Fankriss"]           = { mark = 8, creatureType = "Beast" },
        ["Vekniss Drone"]               = { mark = 5, creatureType = "Beast" },
        ["Vekniss Guardian"]            = { mark = 5, creatureType = "Beast" },
        ["Vekniss Hive Crawler"]        = { mark = 5, creatureType = "Beast" },
        ["Vekniss Soldier"]             = { mark = 5, creatureType = "Beast" },
        ["Vekniss Stinger"]             = { note = "In Vekniss Wasp packs, usually last after the Qiraji Lasher and Wasps; adjust to the actual pack. No third dedicated kill-order icon is assigned." },
        ["Vekniss Warrior"]             = { mark = 7, creatureType = "Beast", dangerLevel = 2, note = "Kill after the Brainwasher in paired packs; each Warrior death spawns a large group of Vekniss Borers." },
        ["Vekniss Borer"]               = { mark = 8, creatureType = "Beast", dangerLevel = 2, note = "Borers spawn in a large group when a Vekniss Warrior dies; switch/AoE them before they overwhelm the raid." },
        ["Vekniss Wasp"]                = { mark = 7, creatureType = "Beast", dangerLevel = 2, note = "In Wasp packs, the usual order is Qiraji Lasher, Wasps, then Stinger." },
        ["Beetle"]                      = "SKIP",
        ["Dark Blue Qiraji Battle Tank"]  = "SKIP",
        ["Gilded Scarab"]               = "SKIP",
        ["Glob of Viscidus"]            = "SKIP",
        ["Light Blue Qiraji Battle Tank"] = "SKIP",
        ["Light Green Qiraji Battle Tank"] = "SKIP",
        ["Orange Qiraji Battle Tank"]   = "SKIP",
        ["Scorpion"]                    = "SKIP",
        ["Twilight Qiraji Battle Tank"] = "SKIP",
    },

    ["Naxxramas"] = {
        ["Bile Retcher"]                = { mark = 8, creatureType = "Undead" },
        ["Soldier of the Frozen Wastes"] = { mark = 8, creatureType = "Undead", dangerLevel = 3, note = "Kel'Thuzad phase-one ranged priority: kill before it reaches anyone and triggers raid-wide Dark Blast." },
        ["Unstoppable Abomination"]     = { note = "Kel'Thuzad phase-one melee add; tank/manage its healing-reduction debuff. Assignment and wave position matter more than a universal kill order." },
        ["Deathknight Captain"]         = { mark = 8, creatureType = "Undead" },
        ["Deathknight Cavalier"]        = { mark = 8, creatureType = "Undead" },
        ["Eye Stalk"]                   = { mark = 8, creatureType = "Aberration", ccImmune = true },
        ["Mad Scientist"]               = { mark = 8, creatureType = "Humanoid" },
        ["Living Poison"]               = "SKIP",
        ["Living Monstrosity"]          = { mark = 8, creatureType = "Undead" },
        ["Naxxramas Acolyte"]           = { mark = 8, creatureType = "Humanoid" },
        ["Naxxramas Cultist"]           = { mark = 8, creatureType = "Humanoid" },
        ["Naxxramas Follower"]          = { mark = 5, creatureType = "Humanoid" },
        ["Necro Knight"]                = { mark = 8, creatureType = "Undead" },
        ["Necro Stalker"]               = { mark = 5, creatureType = "Undead" },
        ["Necropolis Acolyte"]          = { mark = 8, creatureType = "Humanoid" },
        ["Shade of Naxxramas"]          = { mark = 8, creatureType = "Undead" },
        ["Skeletal Smith"]              = { mark = 8, creatureType = "Undead" },
        ["Soul Weaver"]                 = { mark = 7, creatureType = "Undead", dangerLevel = 3, note = "Kel'Thuzad phase-one wave add; ranged players kill it and Soldiers before they reach the raid." },
        ["Spectral Deathknight"]        = { note = "Gothik dead-side wave: use the side-specific kill/CC order; it differs from the living side." },
        ["Spectral Horseman"]           = { note = "Gothik dead-side wave: horsemen are handled after the other assigned adds; follow the side-specific plan." },
        ["Spectral Rider"]              = { note = "Gothik dead-side wave: follow the side-specific kill order; live-side Riders are a higher priority." },
        ["Spectral Trainee"]            = { note = "Gothik dead-side wave: follow the side-specific order; do not apply the living-side priority here." },
        ["Spirit of Naxxramas"]         = { mark = 8, creatureType = "Undead" },
        ["Stoneskin Gargoyle"]          = { mark = 8, creatureType = "Undead" },
        ["Surgical Assistant"]          = { mark = 8, creatureType = "Undead" },
        ["Unholy Staff"]                = { mark = 8, creatureType = "Undead" },
        ["Unrelenting Deathknight"]     = { note = "Gothik living-side Death Knights can be Shackled; wave-side and raid composition determine whether to CC or kill." },
        ["Unrelenting Rider"]           = { note = "Gothik living-side Riders are a high priority; the dead-side order differs, so no global fixed mark is enforced." },
        ["Unrelenting Trainee"]         = { note = "Gothik living-side Trainees are lowest priority; the dead-side order starts differently. Follow the wave/side plan." },
        ["Carrion Spinner"]             = { mark = 5, creatureType = "Beast" },
        ["Dread Creeper"]               = { mark = 5, creatureType = "Beast" },
        ["Frenzied Bat"]                = { mark = 5, creatureType = "Beast" },
        ["Infectious Skitterer"]        = { mark = 5, creatureType = "Beast" },
        ["Plagued Bat"]                 = { mark = 5, creatureType = "Beast" },
        ["Plagued Deathhound"]          = { mark = 5, creatureType = "Beast" },
        ["Venom Stalker"]               = { mark = 5, creatureType = "Beast" },
        ["Bile Sludge"]                 = "SKIP",
        ["Corpse Scarab"]               = "SKIP",
        ["Larva"]                       = "SKIP",
        ["Maggot"]                      = "SKIP",
        ["Plague Slime"]                = "SKIP",
        ["Rat"]                         = "SKIP",
        ["Spider"]                      = "SKIP",
        ["Spore"]                       = "SKIP",
        ["Web Wrap"]                    = "SKIP",
    },
}

-- Merge Classic data into the runtime lookup without replacing any entries
-- supplied by an earlier module. Keep AutoMarkAssist_MobDB as a compatibility alias.
PsychoMarksYou_DefaultMobs = PsychoMarksYou_DefaultMobs or {}
for zone, mobs in pairs(AutoMarkAssist_MobDB) do
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

-- ============================================================
-- ZONE ALIASES
-- Maps alternate / partial zone name strings to canonical DB keys.
-- Subsequent expansion modules merge into this table.
-- ============================================================

PsychoMarksYou_ZoneAliases = {
    ["Ragefire Chasm"]                  = "Ragefire Chasm",
    ["Ragefire"]                        = "Ragefire Chasm",
    ["Wailing Caverns"]                 = "Wailing Caverns",
    ["Deadmines"]                       = "The Deadmines",
    ["The Deadmines"]                   = "The Deadmines",
    ["Shadowfang Keep"]                 = "Shadowfang Keep",
    ["Shadowfang"]                      = "Shadowfang Keep",
    ["The Stockade"]                    = "The Stockade",
    ["Stockade"]                        = "The Stockade",
    ["Stormwind Stockade"]              = "The Stockade",
    ["Blackfathom Deeps"]               = "Blackfathom Deeps",
    ["Blackfathom"]                     = "Blackfathom Deeps",
    ["Gnomeregan"]                      = "Gnomeregan",
    ["Razorfen Kraul"]                  = "Razorfen Kraul",
    ["Razorfen Downs"]                  = "Razorfen Downs",
    ["Scarlet Halls"]                   = "Scarlet Halls",
    ["Scarlet Monastery"]               = "Scarlet Monastery",
    ["Scarlet Monastery: Graveyard"]    = "Scarlet Monastery",
    ["Scarlet Monastery: Library"]      = "Scarlet Monastery",
    ["Scarlet Monastery: Armory"]       = "Scarlet Monastery",
    ["Scarlet Monastery: Cathedral"]    = "Scarlet Monastery",
    ["Scarlet Monastery Graveyard"]     = "Scarlet Monastery",
    ["Scarlet Monastery Library"]       = "Scarlet Monastery",
    ["Scarlet Monastery Armory"]        = "Scarlet Monastery",
    ["Scarlet Monastery Cathedral"]     = "Scarlet Monastery",
    ["Uldaman"]                         = "Uldaman",
    ["Zul'Farrak"]                      = "Zul'Farrak",
    ["Maraudon"]                        = "Maraudon",
    ["Maraudon: Wicked Grotto"]         = "Maraudon",
    ["Maraudon: Foulspore Cavern"]      = "Maraudon",
    ["Maraudon: Earth Song Falls"]      = "Maraudon",
    ["Dire Maul"]                       = "Dire Maul",
    ["Dire Maul East"]                  = "Dire Maul",
    ["Dire Maul West"]                  = "Dire Maul",
    ["Dire Maul North"]                 = "Dire Maul",
    ["Dire Maul: Warpwood Quarter"]     = "Dire Maul",
    ["Dire Maul: Capital Gardens"]      = "Dire Maul",
    ["Dire Maul: Gordok Commons"]       = "Dire Maul",
    ["Stratholme"]                      = "Stratholme",
    ["Stratholme Main Gate"]            = "Stratholme",
    ["Stratholme Service Gate"]         = "Stratholme",
    ["Stratholme: Live"]                = "Stratholme",
    ["Stratholme: Dead"]                = "Stratholme",
    ["Scholomance"]                     = "Scholomance",
    ["Temple of Atal'Hakkar"]           = "The Temple of Atal'Hakkar",
    ["The Temple of Atal'Hakkar"]       = "The Temple of Atal'Hakkar",
    ["Sunken Temple"]                   = "The Temple of Atal'Hakkar",
    ["Blackrock Depths"]                = "Blackrock Depths",
    ["Lower Blackrock Spire"]           = "Lower Blackrock Spire",
    ["Blackrock Spire: Lower"]          = "Lower Blackrock Spire",
    ["LBRS"]                            = "Lower Blackrock Spire",
    ["Upper Blackrock Spire"]           = "Upper Blackrock Spire",
    ["Blackrock Spire: Upper"]          = "Upper Blackrock Spire",
    ["Blackrock Spire"]                 = "Upper Blackrock Spire",
    ["BRS Upper"]                       = "Upper Blackrock Spire",
    ["UBRS"]                            = "Upper Blackrock Spire",
    ["Molten Core"]                     = "Molten Core",
    ["MC"]                              = "Molten Core",
    ["Onyxia's Lair"]                   = "Onyxia's Lair",
    ["Onyxias Lair"]                    = "Onyxia's Lair",
    ["Onyxia"]                          = "Onyxia's Lair",
    ["Ony"]                             = "Onyxia's Lair",
    ["Blackwing Lair"]                  = "Blackwing Lair",
    ["Blackwing"]                       = "Blackwing Lair",
    ["BWL"]                             = "Blackwing Lair",
    ["Zul'Gurub"]                       = "Zul'Gurub",
    ["ZG"]                              = "Zul'Gurub",
    ["Ruins of Ahn'Qiraj"]              = "Ruins of Ahn'Qiraj",
    ["Ruins of AhnQiraj"]               = "Ruins of Ahn'Qiraj",
    ["AQ20"]                            = "Ruins of Ahn'Qiraj",
    ["AQ 20"]                           = "Ruins of Ahn'Qiraj",
    ["Temple of Ahn'Qiraj"]             = "Temple of Ahn'Qiraj",
    ["Temple of AhnQiraj"]              = "Temple of Ahn'Qiraj",
    ["AQ40"]                            = "Temple of Ahn'Qiraj",
    ["AQ 40"]                           = "Temple of Ahn'Qiraj",
    ["Naxxramas"]                       = "Naxxramas",
    ["Naxx"]                            = "Naxxramas",
}

-- ============================================================
-- EXPANSION ORDER
-- Defines the display order for the Database tab zone grouping.
-- Subsequent expansion modules append to this table.
-- ============================================================

PsychoMarksYou_ExpansionOrder = {
    { name = "Classic", dungeons = {
        "Ragefire Chasm", "Wailing Caverns", "The Deadmines", "Shadowfang Keep",
        "The Stockade", "Blackfathom Deeps", "Gnomeregan", "Razorfen Kraul",
        "Razorfen Downs", "Scarlet Halls", "Scarlet Monastery", "Uldaman", "Zul'Farrak",
        "Maraudon", "Dire Maul", "Stratholme", "Scholomance",
        "The Temple of Atal'Hakkar", "Blackrock Depths", "Lower Blackrock Spire",
        "Upper Blackrock Spire",
    }, raids = {
        "Molten Core", "Onyxia's Lair", "Blackwing Lair", "Zul'Gurub",
        "Ruins of Ahn'Qiraj", "Temple of Ahn'Qiraj", "Naxxramas",
    }},
}
