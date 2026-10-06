#!/usr/bin/env python3
import os as _os
ROOT = _os.path.dirname(_os.path.dirname(_os.path.abspath(__file__))) + _os.sep


def _p(rel):
    return ROOT + rel.replace("/", _os.sep)


"""Behavioural tests for the changed Psycho Marks You code paths.

These load the REAL addon Lua files (PsychoMarksYou.lua, both DB modules,
PsychoMarksYou_Core.lua, PsychoMarksYou_MobScanning.lua) into a Lua VM with a
stubbed WoW API, then call the real functions under test:
  * PMY.GetMobDBEntry      (zone-authority change)
  * PMY.GetEntryMark/Note  (note-only rows)
  * PMY.ScoreMob/AllocateMark (mark = "SKIP" inside a table)
  * PMY.UpdateTooltipWithMobInfo (new "Tactical note" tooltip line)
  * PMY.GetIconText        (the "?" the README documents)
"""
import sys
from lupa import LuaRuntime

L = LuaRuntime(unpack_returned_tuples=True)
G = L.globals()

# --------------------------------------------------------------------------
# Minimal WoW API stub
# --------------------------------------------------------------------------
L.execute(r'''
-- state the tests drive
STUB = {
  zone = "", inInstance = false, mouseover = nil,
  tooltipLines = {},
}

function GetRealZoneText() return STUB.zone end
function GetZoneText()     return STUB.zone end
function IsInInstance()    return STUB.inInstance, "party", 1 end
function GetInstanceInfo() return "Molten Core", "raid", 1, nil, 5 end
function GetBuildInfo()    return "1.60.1", "16001", "Jan  1 2026", 16001 end

function UnitExists(u)     return STUB.mouseover ~= nil end
function UnitName(u)       return STUB.mouseover end
function UnitIsPlayer(u)   return false end
function UnitCanAttack(a,b) return true end
function UnitCreatureType(u) return "Humanoid" end
function UnitClassification(u) return "elite" end
function UnitLevel(u)      return 60 end
function UnitHealth(u)     return 10000 end
function UnitHealthMax(u)  return 10000 end
function UnitPower(u)      return 0 end
function UnitPowerMax(u)   return 100 end
function UnitAffectingCombat(u) return false end
function UnitCastingInfo(u) return nil end
function UnitIsDead(u)     return false end
function GetRaidTargetIndex(u) return nil end
function UnitGUID(u)       return "Creature-0-1-" .. tostring(STUB.mouseover) end
function IsInRaid()        return false end
function IsInGroup()       return false end
function GetNumGroupMembers() return 0 end
function UnitIsGroupLeader() return true end
function UnitIsGroupAssistant() return false end
function GetTime()         return 0 end
function joinlines()       return table.concat(STUB.tooltipLines, " || ") end
function DEFAULT_CHAT_FRAME_add(msg) end

function print() end

-- GameTooltip stub that records every line added
GameTooltip = {
  shown = true,
  NumLines = function(self) return #STUB.tooltipLines end,
  GetName  = function(self) return "GameTooltip" end,
  IsShown  = function(self) return true end,
  Show     = function(self) self.shown = true end,
  AddLine  = function(self, text, a, b, c, d)
               STUB.tooltipLines[#STUB.tooltipLines + 1] = text
             end,
}
_G["GameTooltipTextLeft1"] = nil

issecretvalue = nil
issecrettable = nil
WOW_PROJECT_ID = 1
WOW_PROJECT_MAINLINE = 1
''')

ORDER = [
    "PsychoMarksYou/PsychoMarksYou.lua",
    "PsychoMarksYou/PsychoMarksYou_DB_Classic.lua",
    "PsychoMarksYou/PsychoMarksYou_DB_Forever.lua",
    "PsychoMarksYou/PsychoMarksYou_Core.lua",
    "PsychoMarksYou/PsychoMarksYou_MobScanning.lua",
]
for path in ORDER:
    src = open(_p(path), "rb").read().decode("utf-8", "replace")
    try:
        L.execute(src)
    except Exception as exc:
        print("LOAD FAILED:", path)
        print(exc)
        sys.exit(1)
print("loaded:", ", ".join(p.split("/")[-1] for p in ORDER))

# PMY.db is normally built by the SavedVariables path; give it the shape
# GetMobDBEntry expects.
L.execute('PsychoMarksYou.db = { enabled = true, showTooltipHint = true, customMobs = {} }')

# --------------------------------------------------------------------------
# tiny test framework
# --------------------------------------------------------------------------
results = []


def check(name, cond, detail=""):
    results.append((bool(cond), name, detail))
    print(("  PASS  " if cond else "  FAIL  ") + name + (("  -> " + str(detail)) if detail else ""))


def lua(expr):
    """Evaluate a Lua expression and return the result."""
    return L.eval(expr)


def set_zone(zone, in_instance):
    L.execute('STUB.zone = %s; STUB.inInstance = %s'
              % ('"%s"' % zone, "true" if in_instance else "false"))
    L.execute("PsychoMarksYou.UpdateZone()")


print("\n-- PMY.GetMobDBEntry: a known instance zone is authoritative --")

set_zone("Molten Core", True)
check("currentZone resolves to Molten Core",
      lua('PsychoMarksYou.currentZone') == "Molten Core",
      lua('PsychoMarksYou.currentZone'))

check("in-instance mob from that zone is found",
      lua('PsychoMarksYou.GetMobDBEntry("Firelord") ~= nil'))

check("note present on Firelord entry",
      lua('PsychoMarksYou.GetEntryNote(PsychoMarksYou.GetMobDBEntry("Firelord")) ~= nil'))

# "Spider" is a SKIP row in the Classic Zul'Gurub / AQ40 / Naxxramas tables.
# Inside Molten Core it must NOT be borrowed from another zone.
check("same-name row is NOT borrowed from another zone (Spider in MC == nil)",
      lua('PsychoMarksYou.GetMobDBEntry("Spider") == nil'),
      repr(lua('tostring(PsychoMarksYou.GetMobDBEntry("Spider"))')))

# A Forever mob must not resolve while standing in a Classic raid.
check("Forever mob not found while in Molten Core",
      lua('PsychoMarksYou.GetMobDBEntry("Dark Iron Summoner") == nil'))

set_zone("The Hall of Thanes", True)
check("Forever zone resolves",
      lua('PsychoMarksYou.currentZone') == "The Hall of Thanes",
      lua('PsychoMarksYou.currentZone'))
check("Forever mob found in its own zone",
      lua('PsychoMarksYou.GetMobDBEntry("Dark Iron Summoner") ~= nil'))
check("Classic mob not found inside a Forever dungeon",
      lua('PsychoMarksYou.GetMobDBEntry("Firelord") == nil'))
check("new Forever note text is the rewritten one",
      lua('PsychoMarksYou.GetEntryNote(PsychoMarksYou.GetMobDBEntry("Dark Iron Summoner"))')
      .startswith("Powerful Fireballs"),
      lua('PsychoMarksYou.GetEntryNote(PsychoMarksYou.GetMobDBEntry("Dark Iron Summoner"))')[:60])

print("\n-- PMY.GetMobDBEntry: unresolvable zone while still in an instance --")
# This is the exact case the `if PMY.inInstance then return nil end` guard exists
# for: no DefaultMobs key matches, so without the guard the global scan below
# would hand back a same-named row from an unrelated expansion/instance.
set_zone("Karazhan Upper Spire", True)
check("unresolvable instance zone keeps the raw name",
      lua('PsychoMarksYou.currentZone') == "Karazhan Upper Spire",
      lua('PsychoMarksYou.currentZone'))
check("that zone has no database rows of its own",
      lua('PsychoMarksYou_DefaultMobs["Karazhan Upper Spire"] == nil'))
check("guard blocks the cross-zone global scan (Firelord == nil)",
      lua('PsychoMarksYou.GetMobDBEntry("Firelord") == nil'),
      repr(lua('tostring(PsychoMarksYou.GetMobDBEntry("Firelord"))')))
check("guard also blocks borrowing a SKIP row (Spider == nil)",
      lua('PsychoMarksYou.GetMobDBEntry("Spider") == nil'),
      repr(lua('tostring(PsychoMarksYou.GetMobDBEntry("Spider"))')))

print("\n-- PMY.GetMobDBEntry: outside instances the global scan still runs --")
set_zone("Elwynn Forest", False)
check("open-world zone leaves currentZone as the raw name",
      lua('PsychoMarksYou.currentZone') == "Elwynn Forest",
      lua('PsychoMarksYou.currentZone'))
check("global scan still finds a Classic row out of instance",
      lua('PsychoMarksYou.GetMobDBEntry("Firelord") ~= nil'))

set_zone("Molten Core", False)
check("outside an instance, unresolvable name still falls through to global scan",
      lua('PsychoMarksYou.GetMobDBEntry("Firelord") ~= nil'))

print("\n-- note-only rows carry no default priority --")
set_zone("Molten Core", True)
check("Molten Giant is note-only (mark == nil)",
      lua('PsychoMarksYou.GetEntryMark(PsychoMarksYou.GetMobDBEntry("Molten Giant")) == nil'))
check("Molten Giant still has its note",
      lua('PsychoMarksYou.GetEntryNote(PsychoMarksYou.GetMobDBEntry("Molten Giant")) ~= nil'))
check("note-only row has no creatureType",
      lua('PsychoMarksYou.GetEntryCreatureType(PsychoMarksYou.GetMobDBEntry("Molten Giant")) == nil'))
check("note-only row has no dangerLevel",
      lua('PsychoMarksYou.GetEntryDangerLevel(PsychoMarksYou.GetMobDBEntry("Molten Giant")) == nil'))

print("\n-- mark = \"SKIP\" inside a table (Blackwing Technician) --")
set_zone("Blackwing Lair", True)
check("Blackwing Lair resolves",
      lua('PsychoMarksYou.currentZone') == "Blackwing Lair",
      lua('PsychoMarksYou.currentZone'))
check('Technician entry exposes mark "SKIP"',
      lua('PsychoMarksYou.GetEntryMark(PsychoMarksYou.GetMobDBEntry("Blackwing Technician")) == "SKIP"'),
      repr(lua('tostring(PsychoMarksYou.GetEntryMark(PsychoMarksYou.GetMobDBEntry("Blackwing Technician")))')))
check("Technician keeps its creatureType for CC checks",
      lua('PsychoMarksYou.GetEntryCreatureType(PsychoMarksYou.GetMobDBEntry("Blackwing Technician")) == "Humanoid"'))

score = L.eval(r'''
function ()
  local PMY = PsychoMarksYou
  local mob = PMY.BuildMobRecord and nil or nil
  local m = {
    guid = "g1", name = "Blackwing Technician", unit = "nameplate1",
    level = 62, classification = "elite", creatureType = "Humanoid",
    isElite = true, isBoss = false, isCasting = false, hasMana = true,
    maxHP = 100000, inCombat = false, existingMark = nil,
    dbPriority = "SKIP", dbCreatureType = "Humanoid", dbCCImmune = false,
    dbDanger = nil, dbNote = "kited", score = 0, assignedMark = nil, assignedRole = nil,
  }
  PMY.ScoreMob(m)
  return m.score
end
''')()
check("ScoreMob gives a SKIP mob score -1", score == -1, score)

alloc = L.eval(r'''
function ()
  local PMY = PsychoMarksYou
  local m = {
    guid = "g2", name = "Blackwing Technician", level = 62, classification = "elite",
    creatureType = "Humanoid", isElite = true, isBoss = false, isCasting = false,
    hasMana = true, maxHP = 100000, dbPriority = "SKIP", dbCreatureType = "Humanoid",
    dbCCImmune = false, dbDanger = nil, score = -1,
  }
  local icon, role = PMY.AllocateMark(m)
  return icon == nil
end
''')()
check("AllocateMark refuses to mark a SKIP mob", alloc)

print("\n-- tooltip: note-only mobs get the new 'Tactical note' line --")


def tooltip_lines_for(mob_name, zone, in_instance=True):
    L.execute('STUB.tooltipLines = {}')
    set_zone(zone, in_instance)
    L.execute('STUB.mouseover = "%s"' % mob_name)
    L.execute("PsychoMarksYou.UpdateTooltipWithMobInfo()")
    return L.eval("joinlines()").split(" || ")


lines = tooltip_lines_for("Molten Giant", "Molten Core")
joined = " || ".join(lines)
check("note-only tooltip shows a 'Psycho Mark's You' header",
      any("Psycho Mark's You" in s for s in lines), joined[:120])
check("note-only tooltip shows the 'Tactical note' label",
      any("Tactical note" in s for s in lines), joined[:160])
check("note-only tooltip still prints the note text",
      any("separate tanking" in s for s in lines), joined[:200])

lines = tooltip_lines_for("Firelord", "Molten Core")
check("marked mob does NOT get the bare 'Tactical note' line",
      not any(s.endswith("Tactical note|r") for s in lines), " || ".join(lines)[:160])
check("marked mob shows its icon + role line",
      any("Skull" in s for s in lines), " || ".join(lines)[:160])

print("\n-- documented UI behaviour --")
check('GetIconText(nil) returns "?" (README claim about note-only rows)',
      lua('PsychoMarksYou.GetIconText(nil)') == "?",
      repr(lua('PsychoMarksYou.GetIconText(nil)')))
check('GetIconText(8) is Skull',
      "Skull" in lua('PsychoMarksYou.GetIconText(8)'))

print("\n-- Classic data is actually reachable at runtime (the merge) --")
check("AutoMarkAssist_MobDB still exported for compatibility",
      lua('AutoMarkAssist_MobDB ~= nil'))
check("runtime table holds Classic zones",
      lua('PsychoMarksYou_DefaultMobs["Scholomance"] ~= nil'))
check("Ragglesnout row added",
      lua('PsychoMarksYou_DefaultMobs["Razorfen Downs"]["Ragglesnout"] ~= nil'))
check("Lava Spawn is now a kill priority, not SKIP",
      lua('type(PsychoMarksYou_DefaultMobs["Molten Core"]["Lava Spawn"]) == "table"')
      and lua('PsychoMarksYou_DefaultMobs["Molten Core"]["Lava Spawn"].mark') == 8)
check("Forever zone survived the Classic merge",
      lua('PsychoMarksYou_DefaultMobs["The Hall of Thanes"]["Durgen Dirgehammer"] ~= nil'))

print("\n" + "=" * 70)
passed = sum(1 for ok, _, _ in results if ok)
print("RESULT: %d/%d checks passed" % (passed, len(results)))
if passed != len(results):
    print("FAILURES:")
    for ok, name, detail in results:
        if not ok:
            print("  -", name, detail)
    sys.exit(1)
