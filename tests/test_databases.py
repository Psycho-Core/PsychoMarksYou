#!/usr/bin/env python3
"""Database-level checks: load the REAL DB modules in TOC order and assert the
counts the README and docs/target-priority-research.md publish.

Loads PsychoMarksYou_DB_Classic.lua and PsychoMarksYou_DB_Forever.lua verbatim
into a Lua VM -- no re-implementation of addon data or merge logic.
"""
import os as _os
import sys
from lupa import LuaRuntime

ROOT = _os.path.dirname(_os.path.dirname(_os.path.abspath(__file__))) + _os.sep


def _p(rel):
    return ROOT + rel.replace("/", _os.sep)


L = LuaRuntime(unpack_returned_tuples=True)

L.execute(r'''
-- Returns a flat summary of a zone->mob table, flagging malformed rows.
function summarise(t)
  if t == nil then return nil end
  local zones, mobs, noteOnly, skipStr, withMark = 0, 0, 0, 0, 0
  local d = {[1]=0, [2]=0, [3]=0}
  local odd = {}
  for z, m in pairs(t) do
    zones = zones + 1
    for name, e in pairs(m) do
      mobs = mobs + 1
      if type(e) == "table" then
        if e.mark ~= nil then withMark = withMark + 1 end
        if e.mark == nil and e.note ~= nil then noteOnly = noteOnly + 1 end
        if e.dangerLevel ~= nil then
          if d[e.dangerLevel] then d[e.dangerLevel] = d[e.dangerLevel] + 1
          else odd[#odd+1] = name .. "/danger=" .. tostring(e.dangerLevel) end
        end
        if e.mark ~= nil and type(e.mark) ~= "number" and e.mark ~= "SKIP" then
          odd[#odd+1] = name .. "/mark=" .. tostring(e.mark)
        end
        if e.mark ~= nil and type(e.mark) == "number" and (e.mark < 1 or e.mark > 8) then
          odd[#odd+1] = name .. "/mark-out-of-range=" .. tostring(e.mark)
        end
        if e.mark == nil and (e.dangerLevel ~= nil or e.creatureType ~= nil or e.ccImmune) then
          odd[#odd+1] = name .. "/note-only-but-has-scoring-fields"
        end
      elseif e == "SKIP" then
        skipStr = skipStr + 1
      else
        odd[#odd+1] = name .. "/type=" .. type(e)
      end
    end
  end
  return zones, mobs, withMark, noteOnly, skipStr, d[1], d[2], d[3], table.concat(odd, " | ")
end
''')

for path in ["PsychoMarksYou/PsychoMarksYou_DB_Classic.lua",
             "PsychoMarksYou/PsychoMarksYou_DB_Forever.lua"]:
    src = open(_p(path), "rb").read().decode("utf-8", "replace")
    try:
        L.execute(src)
    except Exception as exc:
        print("LOAD FAILED:", path)
        print(exc)
        sys.exit(1)
    print("loaded OK:", path)

g = L.globals()
summ = L.eval("summarise")

cz, cm, cmark, cnote, cskip, cd1, cd2, cd3, codd = summ(g.AutoMarkAssist_MobDB)
rz, rm, rmark, rnote, rskip, rd1, rd2, rd3, rodd = summ(g.PsychoMarksYou_DefaultMobs)

print("AutoMarkAssist_MobDB       : zones=%d mobs=%d withMark=%d noteOnly=%d "
      "SKIPstr=%d d1=%d d2=%d d3=%d" % (cz, cm, cmark, cnote, cskip, cd1, cd2, cd3))
print("PsychoMarksYou_DefaultMobs : zones=%d mobs=%d withMark=%d noteOnly=%d "
      "SKIPstr=%d d1=%d d2=%d d3=%d" % (rz, rm, rmark, rnote, rskip, rd1, rd2, rd3))

results = []


def check(name, cond, detail=""):
    results.append(bool(cond))
    print(("  PASS  " if cond else "  FAIL  ") + name + (("  -> " + str(detail)) if detail else ""))


print("\n-- published counts (README / docs) --")
check("Classic table has 600 mob records", cm == 600, cm)
check("Classic table spans 28 zones", cz == 28, cz)
check("no malformed Classic rows", codd == "", codd)
check("no malformed runtime rows", rodd == "", rodd)

print("\n-- the Classic merge actually feeds runtime lookup --")
check("runtime lookup exposes Classic zones",
      L.eval('PsychoMarksYou_DefaultMobs["Scholomance"] ~= nil'))
check("runtime lookup still exposes Forever zones",
      L.eval('PsychoMarksYou_DefaultMobs["The Hall of Thanes"] ~= nil'))
check("runtime zone count = Classic 28 + Forever 7",
      rz == cz + 7, "%d vs %d+7" % (rz, cz))
check("runtime mob count = Classic 600 + Forever 76",
      rm == cm + 76, "%d vs %d+76" % (rm, cm))

print("\n-- the six added Classic rows exist --")
added = [("Razorfen Downs", "Ragglesnout"),
         ("Scholomance", "Rattlegore"),
         ("Naxxramas", "Soldier of the Frozen Wastes"),
         ("Naxxramas", "Unstoppable Abomination"),
         ("Naxxramas", "Spectral Trainee"),
         ("Temple of Ahn'Qiraj", "Qiraji Lasher")]
for zone, mob in added:
    check("%s / %s present" % (zone, mob),
          L.eval('PsychoMarksYou_DefaultMobs["%s"]["%s"] ~= nil' % (zone, mob)))

print("\n-- Forever DB is the curated set --")
forever_zones = L.eval(r'''
function ()
  local n, names = 0, {}
  for z in pairs(PsychoMarksYou_DefaultMobs) do
    if z == "The Hall of Thanes" or z == "Ruins of Lordaeron"
       or z == "Excavation Site: Wetlands" or z == "City of Dalaran"
       or z == "The Drowned City" or z == "Barrow Deeps"
       or z == "Hyjal Summit" then
      n = n + 1
      names[#names+1] = z
    end
  end
  table.sort(names)
  return n, table.concat(names, ", ")
end
''')()
check("exactly seven Forever zones carry rows", forever_zones[0] == 7, forever_zones)
check("Forever adds 76 mob records",
      L.eval(r"""
      function ()
        local n = 0
        for _, z in ipairs({"City of Dalaran", "The Drowned City", "Barrow Deeps",
                            "Hyjal Summit", "The Hall of Thanes",
                            "Ruins of Lordaeron", "Excavation Site: Wetlands"}) do
          for _ in pairs(PsychoMarksYou_DefaultMobs[z]) do n = n + 1 end
        end
        return n
      end
      """)() == 76)
# Four dungeons still have no published mob roster at all ("Bosses: Unknown yet /
# Mob Packs: Unknown yet" in every source), so they get no rows by design.
check("no rows for the four Forever dungeons with no published roster",
      all(L.eval('PsychoMarksYou_DefaultMobs["%s"] == nil' % z) for z in
          ["Krol'dok Stronghold", "Alcaz Prison", "Blackmaw Hold",
           "Shaper's Terrace"]),
      "checked 4 no-data zones")
# The Drowned City and the two raids are demo/roster-only data, so every row in
# them must carry a note saying so.
check("demo-sourced Forever rows all carry a provenance note",
      L.eval(r"""
      function ()
        for _, z in ipairs({"The Drowned City", "Barrow Deeps", "Hyjal Summit"}) do
          for n, e in pairs(PsychoMarksYou_DefaultMobs[z]) do
            if type(e) ~= "table" or e.note == nil then return false end
          end
        end
        return true
      end
      """)())

print("\n-- guide/zone registry still lists all announced content --")
reg = L.eval(r'''
function ()
  local e = PsychoMarksYou_ExpansionOrder[1]
  local d, r = 0, 0
  for _ in pairs(e.dungeons) do d = d + 1 end
  for _ in pairs(e.raids) do r = r + 1 end
  return d, r
end
''')()
check("registry lists 9 dungeons and 2 raids", reg[0] == 9 and reg[1] == 2, reg)

print("\n-- aliases survive the rewrite --")
check("Forever aliases still registered",
      L.eval('PsychoMarksYou_ZoneAliases["Hall of Thanes"] == "The Hall of Thanes"'),
      L.eval('tostring(PsychoMarksYou_ZoneAliases["Hall of Thanes"])'))

print("\n" + "=" * 70)
p = sum(results)
print("RESULT: %d/%d checks passed" % (p, len(results)))
if p != len(results):
    sys.exit(1)
