-- ============================================================================
-- Psycho Mark's You - Smart Dungeon & Raid Mob Marker for WoW: Forever Beta
-- Custom WoW Forever Beta edition based on AutoMarkAssist by Swatto
-- Slash Commands: /pmy or /psychomarksyou
-- ============================================================================

PsychoMarksYou = PsychoMarksYou or {}
local PMY = PsychoMarksYou

if not _G.AutoMarkAssist then
    _G.AutoMarkAssist = PMY
end

PMY.ADDON_NAME   = "PsychoMarksYou"
PMY.ADDON_TITLE  = "Psycho Mark's You"
PMY.VERSION      = "1.1.0-ForeverBeta"
PMY.COLOR_PREFIX = "|cFFFF3366[Psycho Mark's You]|r "

-- Keybinding display strings for Blizzard's Keybindings UI (Bindings.xml)
BINDING_HEADER_PSYCHOMARKSYOU                      = "Psycho Mark's You"
BINDING_NAME_CLICK_PMY_MarkMobButton_LeftButton    = "Mark Group / Pack (Auto-Scan)"
BINDING_NAME_CLICK_PMY_ResetMarksButton_LeftButton = "Clear All Marks"

-- ============================================================================
-- CONSTANTS & DEFINITIONS
-- ============================================================================

PMY.RAID_ICONS = {
    [1] = { name = "Star",     chat = "{star}",     color = "|cFFFFFF00", texCoords = {0,    0.25, 0,    0.25} },
    [2] = { name = "Circle",   chat = "{circle}",   color = "|cFFFF7F00", texCoords = {0.25, 0.5,  0,    0.25} },
    [3] = { name = "Diamond",  chat = "{diamond}",  color = "|cFFFF00FF", texCoords = {0.5,  0.75, 0,    0.25} },
    [4] = { name = "Triangle", chat = "{triangle}", color = "|cFF00FF00", texCoords = {0.75, 1.0,  0,    0.25} },
    [5] = { name = "Moon",     chat = "{moon}",     color = "|cFF8888FF", texCoords = {0,    0.25, 0.25, 0.5}  },
    [6] = { name = "Square",   chat = "{square}",   color = "|cFF00FFFF", texCoords = {0.25, 0.5,  0.25, 0.5}  },
    [7] = { name = "Cross",    chat = "{cross}",    color = "|cFFFF0000", texCoords = {0.5,  0.75, 0.25, 0.5}  },
    [8] = { name = "Skull",    chat = "{skull}",    color = "|cFFFFFFFF", texCoords = {0.75, 1.0,  0.25, 0.5}  },
}

PMY.CC_ASSIGNMENTS = {
    MAGE = {
        icon = 5,
        spell = "Polymorph",
        creatureTypes = { Humanoid = true, Beast = true, Critter = true },
        priority = 1,
    },
    ROGUE = {
        icon = 3,
        spell = "Sap",
        creatureTypes = { Humanoid = true },
        priority = 2,
    },
    WARLOCK = {
        icon = 4,
        spell = "Banish",
        creatureTypes = { Demon = true, Elemental = true },
        priority = 3,
    },
    PRIEST = {
        icon = 1,
        spell = "Shackle Undead",
        creatureTypes = { Undead = true },
        priority = 4,
    },
    DRUID = {
        icon = 2,
        spell = "Hibernate",
        creatureTypes = { Beast = true, Dragonkin = true },
        priority = 5,
    },
    HUNTER = {
        icon = 6,
        spell = "Freezing Trap",
        creatureTypes = { Humanoid = true, Beast = true, Demon = true, Dragonkin = true, Giant = true, Undead = true },
        priority = 6,
    },
    PALADIN = {
        icon = 5,
        spell = "Repentance",
        creatureTypes = { Humanoid = true, Demon = true, Dragonkin = true, Giant = true, Undead = true },
        priority = 7,
    },
}

PMY.MARK_ROLES = {
    [8] = "First Kill",
    [7] = "Second Kill",
    [6] = "Trap (Hunter)",
    [5] = "Polymorph (Mage)",
    [4] = "Banish (Warlock)",
    [3] = "Sap (Rogue)",
    [2] = "Hibernate (Druid)",
    [1] = "Shackle (Priest)",
}

PMY.DEFAULTS = {
    enabled           = true,
    markingMode       = "proximity", -- "proximity", "mouseover", "manual"
    markKey           = "ALT",       -- modifier for manual mode: "ALT", "CTRL", "SHIFT", "NONE"
    markMobKey        = nil,         -- optional in-addon keybind for Mark Group / Pack
    resetMarksKey     = nil,         -- optional keybind to clear all active marks
    autoMarkOnTab     = true,        -- auto-mark entire visible pack when pressing TAB out of combat
    autoMarkOnWheel   = true,        -- auto-mark entire visible pack when scrolling mouse wheel out of combat
    showPackHUD       = true,        -- show clickable Pack Ready HUD banner when unmarked pack is detected
    showTooltipHint   = true,        -- show Psycho Mark's You priority & note on mob tooltips
    announceParty     = true,
    announceChatType  = "PARTY",     -- "PARTY", "RAID", "RAID_WARNING", "SAY"
    announcePrefix    = "Psycho Mark's You",
    soloMode          = false,
    onlyTargetPack    = false,
    clearOnCombatEnd  = true,
    reMarkOnDeath     = true,
    customMobs        = {},
    disabledMarks     = {},
    minimapPos        = 220,
    hideMinimapButton = false,
    debugMode         = false,
    scanDelay         = 0.15,
    proximityMarks    = 3,
}

-- ============================================================================
-- STATE VARIABLES
-- ============================================================================

PMY.db                = nil
PMY.currentZone       = ""
PMY.inInstance        = false
PMY.instanceType      = "none"
PMY.markedGUIDs       = {}   -- [key] = iconIndex (key is GUID or "unit:nameplateN")
PMY.iconToGUID        = {}   -- [iconIndex] = key
PMY.guidToName        = {}   -- [key] = mobName
PMY.packMobs          = {}   -- current pack scan results
PMY.partyCC           = {}   -- available CC from current party
PMY.scanPending       = false
PMY.lastAnnounceTime  = 0
PMY.lastScanTime      = 0
PMY.configFrame       = nil
PMY.minimapButton     = nil
PMY.sessionAnnounced  = false
PMY.combatAnnounced   = false
PMY.targetPackActive  = false
PMY.activeNameplates  = {}   -- [unitToken] = true for visible enemy nameplates
PMY.npTicker          = nil  -- C_Timer ticker for proximity scanning
PMY.pullTargetGUID    = nil
PMY.combatMarkedGUIDs = {}
PMY.combatEntryCount  = 0
PMY.engagedGUIDs      = {}
PMY.markTimestamps    = {}   -- [key] = GetTime() when mark was placed
PMY.GRAVEYARD_COOLDOWN = 4.0
PMY.graveyardList     = {}   -- list of { name=string, ctype=string, expire=number }
PMY.combatVerifyTimer = nil
PMY.staleFadeTimers   = {}
PMY.inCombat          = false
PMY.MODIFIER_CHECK = {
    ALT   = IsAltKeyDown,
    CTRL  = IsControlKeyDown,
    SHIFT = IsShiftKeyDown,
    NONE  = function() return true end,
}
