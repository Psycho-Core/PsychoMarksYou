#!/usr/bin/env python3
"""End-to-end priority tests for the researched kill-order database.

These load the REAL addon modules (PsychoMarksYou.lua, both DBs, Core,
MobScanning) into a Lua VM with a stubbed multi-unit WoW API, then drive the
shipped pipeline:

    PMY.ClassifyMob -> PMY.ScoreMob -> PMY.AllocateMark

and assert that the mobs the research identified as critical (healers,
summoners, fear / mind-control / silence casters) now out-score the filler in
the same pack. That is the whole point of the dangerLevel data: before it
existed, every `mark = 8` row scored identically and the addon could not tell a
healer from a foot soldier.
"""
import os as _os
import sys

ROOT = _os.path.dirname(_os.path.dirname(_os.path.abspath(__file__))) + _os.sep


def _p(rel):
    return ROOT + rel.replace("/", _os.sep)


from lupa import LuaRuntime

L = LuaRuntime(unpack_returned_tuples=True)

# --------------------------------------------------------------------------
# Stubbed WoW API with a table of units, so one "pack" can hold several mobs.
# --------------------------------------------------------------------------
L.execute(r'''
STUB = { zone = "", inInstance = false, pack = {}, tooltipLines = {} }

local function U(unit) return STUB.pack[unit] end

function GetRealZoneText() return STUB.zone end
function GetZoneText()     return STUB.zone end
function IsInInstance()    return STUB.inInstance, "party", 1 end
function GetInstanceInfo() return STUB.zone, "party", 1, nil, 5 end
function GetBuildInfo()    return "1.60.1", "16001", "Jan  1 2026", 16001 end
function GetDifficultyInfo() return "Normal", 1, false, true end

function UnitExists(u)          return U(u) ~= nil end
function UnitName(u)            local m = U(u); return m and m.name or nil end
function UnitGUID(u)            local m = U(u); return m and ("Creature-0-1-" .. m.name) or nil end
function UnitLevel(u)           local m = U(u); return m and (m.level or 60) or nil end
function UnitClassification(u)  local m = U(u); return m and (m.classif or "elite") or nil end
function UnitCreatureType(u)    local m = U(u); return m and (m.ctype or "Humanoid") or nil end
function UnitPowerType(u)       local m = U(u); return m and (m.powerType or 0) or nil end
function UnitPowerMax(u)        local m = U(u); return m and (m.maxMana or 100) or nil end
function UnitHealthMax(u)       local m = U(u); return m and (m.maxHP or 10000) or nil end
function UnitHealth(u)          local m = U(u); return m and (m.maxHP or 10000) or nil end
function UnitAffectingCombat(u) return false end
function UnitCastingInfo(u)     local m = U(u); return m and m.casting or nil end
function UnitChannelInfo(u)     return nil end
function UnitIsPlayer(u)        return false end
function UnitIsDead(u)          return false end
function UnitCanAttack(a, b)    return true end
function GetRaidTargetIndex(u)  return nil end
function IsInRaid()             return false end
function IsInGroup()            return true end
function GetNumGroupMembers()   return 4 end
function UnitIsGroupLeader()    return true end
function UnitIsGroupAssistant() return false end
function GetTime()              return 0 end
function print() end
function DEFAULT_CHAT_FRAME_add(msg) end

GameTooltip = {
  shown = true,
  NumLines = function(self) return #STUB.tooltipLines end,
  GetName  = function(self) return "GameTooltip" end,
  IsShown  = function(self) return true end,
  Show     = function(self) self.shown = true end,
  AddLine  = function(self, text) STUB.tooltipLines[#STUB.tooltipLines + 1] = text end,
}

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

L.execute('PsychoMarksYou.db = { enabled = true, showTooltipHint = true, customMobs = {}, disabledMarks = {} }')
L.execute('PsychoMarksYou.iconToGUID = PsychoMarksYou.iconToGUID or {}')

results = []


def check(name, cond, detail=""):
    results.append(bool(cond))
    print(("  PASS  " if cond else "  FAIL  ") + name + (("  -> " + str(detail)) if detail else ""))


def rank_pack(zone, units):
    """Run the real ClassifyMob+ScoreMob pipeline over a pack; return [(name, score, danger)]."""
    L.execute('STUB.zone = "%s"; STUB.inInstance = true' % zone)
    L.execute("STUB.pack = {}")
    for i, spec in enumerate(units, start=1):
        L.globals().STUB.pack["t%d" % i] = L.eval("(function(t) return t end)")(spec)
    L.execute("PsychoMarksYou.UpdateZone()")
    # Sort with the SHIPPED comparator (PMY.SortByPriority, the one
    # ScanAndMarkPack uses) rather than re-implementing the rule here.
    out = L.eval(r'''
    function ()
      local mobs = {}
      for unit in pairs(STUB.pack) do
        local mob = PsychoMarksYou.ClassifyMob(unit)
        PsychoMarksYou.ScoreMob(mob)
        mobs[#mobs + 1] = mob
      end
      table.sort(mobs, PsychoMarksYou.SortByPriority)
      local rows = {}
      for _, mob in ipairs(mobs) do
        rows[#rows + 1] = ("%s|%s|%s|%s"):format(
          mob.name, tostring(mob.score),
          tostring(PsychoMarksYou.GetEffectiveDanger(mob)),
          tostring(mob.dbPriority))
      end
      return table.concat(rows, "\n")
    end
    ''')()
    parsed = []
    for line in out.strip().split("\n"):
        name, score, danger, prio = line.split("|")
        parsed.append((name, float(score), danger, prio))
    return parsed


def show(rows):
    print("     " + "\n     ".join(
        "%-28s score=%-8.1f danger=%-5s dbMark=%s" % r for r in rows))


# ==========================================================================
print("\n-- Stratholme: the healer must out-score the pack filler --")
rows = rank_pack("Stratholme", [
    {"name": "Crimson Priest", "level": 60},
    {"name": "Crimson Conjurer", "level": 60},
    {"name": "Crimson Defender", "level": 60},
    {"name": "Crimson Gallant", "level": 60},
])
show(rows)
order = [r[0] for r in rows]
# Both critical mobs share danger 3, so they tie on score; what the data
# guarantees is that they sit above the filler, not which of them is first.
check("the two danger-3 mobs take the top two slots",
      set(order[:2]) == {"Crimson Priest", "Crimson Conjurer"}, order)
check("Crimson Priest (healer) outranks the melee filler",
      order.index("Crimson Priest") < order.index("Crimson Gallant"), order)
check("Crimson Conjurer (summoner) outranks the melee filler",
      order.index("Crimson Conjurer") < order.index("Crimson Defender"), order)
check("the danger-3 band scores strictly above the danger-1 band",
      min(r[1] for r in rows if r[2] == "3") > max(r[1] for r in rows if r[2] == "1"),
      sorted(r[1] for r in rows))
check("Crimson Priest carries dangerLevel 3",
      dict((r[0], r[2]) for r in rows)["Crimson Priest"] == "3")
check("Crimson Gallant filler is dangerLevel 1",
      dict((r[0], r[2]) for r in rows)["Crimson Gallant"] == "1")

print("\n-- Blackfathom Deeps: mind-controller and healer first --")
rows = rank_pack("Blackfathom Deeps", [
    {"name": "Twilight Shadowmage", "level": 25},
    {"name": "Twilight Acolyte", "level": 25},
    {"name": "Twilight Thug", "level": 25},
    {"name": "Murkshallow Snapclaw", "level": 25},
])
show(rows)
order = [r[0] for r in rows]
check("the mind-controller and the healer take the top two slots",
      set(order[:2]) == {"Twilight Shadowmage", "Twilight Acolyte"}, order)
check("both outrank the Thug and the Snapclaw",
      order.index("Twilight Thug") > 1 and order.index("Murkshallow Snapclaw") > 1, order)

print("\n-- Lower Blackrock Spire: the portal-summoning Warlock is #1 --")
rows = rank_pack("Lower Blackrock Spire", [
    {"name": "Scarshield Warlock", "level": 58},
    {"name": "Scarshield Spellbinder", "level": 58},
    {"name": "Firebrand Grunt", "level": 58},
    {"name": "Scarshield Legionnaire", "level": 58},
])
show(rows)
order = [r[0] for r in rows]
check("the Warlock and the Spellbinder take the top two slots",
      set(order[:2]) == {"Scarshield Warlock", "Scarshield Spellbinder"}, order)
check("Spellbinder outranks the melee", order.index("Scarshield Spellbinder") < 2, order)

print("\n-- Zul'Gurub: healer > witch doctor > headhunter > axe thrower --")
rows = rank_pack("Zul'Gurub", [
    {"name": "Hakkari Priest", "level": 60},
    {"name": "Hakkari Witch Doctor", "level": 60},
    {"name": "Gurubashi Headhunter", "level": 60},
    {"name": "Gurubashi Axe Thrower", "level": 60},
])
show(rows)
order = [r[0] for r in rows]
check("kill order matches the documented ZG priority",
      order == ["Hakkari Priest", "Hakkari Witch Doctor",
                "Gurubashi Headhunter", "Gurubashi Axe Thrower"], order)

print("\n-- Gnomeregan: the alarm bot and the machine-repairing gnomes lead --")
rows = rank_pack("Gnomeregan", [
    {"name": "Mobile Alert System", "level": 30},
    {"name": "Leprous Machinesmith", "level": 30},
    {"name": "Mechano-Frostwalker", "level": 30},
    {"name": "Caverndeep Burrower", "level": 30},
])
show(rows)
order = [r[0] for r in rows]
check("alarm bot and machinesmith outrank the construct and the trogg",
      order.index("Mobile Alert System") < 2 and order.index("Leprous Machinesmith") < 2, order)
check("ccImmune survived the rewrite on Mobile Alert System",
      L.eval('PsychoMarksYou.GetEntryCCImmune('
             'PsychoMarksYou.GetMobDBEntry("Mobile Alert System")) == true'))

print("\n-- City of Dalaran (Forever): the summoner leads --")
rows = rank_pack("City of Dalaran", [
    {"name": "Kirin Tor Necromancer", "level": 31},
    {"name": "Mana Phantom", "level": 31},
    {"name": "Mana Elemental", "level": 31},
])
show(rows)
order = [r[0] for r in rows]
check("Kirin Tor Necromancer is the top target", order[0] == "Kirin Tor Necromancer", order)
check("Mana Phantom (Mana Burn) is second", order[1] == "Mana Phantom", order)

print("\n-- The Drowned City (Forever): caster trash before the melee --")
rows = rank_pack("The Drowned City", [
    {"name": "Deathless Sorcerer", "level": 38},
    {"name": "Deathless Guardian", "level": 38},
    {"name": "Makrura", "level": 38},
])
show(rows)
order = [r[0] for r in rows]
check("Deathless Sorcerer is the top target", order[0] == "Deathless Sorcerer", order)

print("\n-- The Hall of Thanes: the Summoner still leads Magmatus --")
rows = rank_pack("The Hall of Thanes", [
    {"name": "Dark Iron Summoner", "level": 18},
    {"name": "Magmatus", "level": 18},
    {"name": "Dark Iron Looter", "level": 18},
])
show(rows)
order = [r[0] for r in rows]
check("Dark Iron Summoner is the top target", order[0] == "Dark Iron Summoner", order)

print("\n-- PMY.SortByPriority: the tie-break is deterministic --")
# Two mobs on the same score: the Skull preference must win over Cross, and two
# mobs equal on score AND preference must fall back to name. Without this the
# shipped table.sort (unstable) would pick arbitrarily run to run.
tie = L.eval(r'''
function ()
  local a = { name = "Zz Cross", score = 1300, dbPriority = 7 }
  local b = { name = "Aa Skull", score = 1300, dbPriority = 8 }
  local c = { name = "Mm Also Skull", score = 1300, dbPriority = 8 }
  local t = { a, b, c }
  table.sort(t, PsychoMarksYou.SortByPriority)
  return t[1].name .. "," .. t[2].name .. "," .. t[3].name
end
''')()
check("Skull beats Cross on an equal score", tie.split(",")[0] == "Aa Skull", tie)
check("equal score and equal preference fall back to name",
      tie.split(",")[1] == "Mm Also Skull", tie)
check("higher score still beats a better mark preference",
      L.eval(r'''
      function ()
        local a = { name = "Low", score = 1299, dbPriority = 8 }
        local b = { name = "High", score = 1300, dbPriority = 5 }
        local t = { a, b }
        table.sort(t, PsychoMarksYou.SortByPriority)
        return t[1].name
      end
      ''')() == "High")

print("\n-- note-only rows still encode no static priority --")
rows = rank_pack("Molten Core", [
    {"name": "Molten Giant", "level": 62, "maxHP": 120000},
    {"name": "Lava Spawn", "level": 62},
])
show(rows)
d = dict((r[0], r[3]) for r in rows)
check("Molten Giant has no dbPriority (note-only)", d["Molten Giant"] == "nil", d)
check("Lava Spawn has an explicit Skull preference", d["Lava Spawn"] == "8", d)

print("\n-- AllocateMark still hands the researched rows their intended icon --")
L.execute('STUB.zone = "Stratholme"; STUB.inInstance = true')
L.globals().STUB.pack["t1"] = {"name": "Crimson Priest", "level": 60}
mark = L.eval(r'''
function ()
  PsychoMarksYou.UpdateZone()
  local mob = PsychoMarksYou.ClassifyMob("t1")
  PsychoMarksYou.ScoreMob(mob)
  local m = PsychoMarksYou.AllocateMark(mob)
  return m
end
''')()
check("Crimson Priest is allocated Skull (8)", mark == 8, mark)

print("\n" + "=" * 70)
passed = sum(results)
print("RESULT: %d/%d checks passed" % (passed, len(results)))
sys.exit(0 if passed == len(results) else 1)
