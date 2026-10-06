#!/usr/bin/env python3
import os as _os
ROOT = _os.path.dirname(_os.path.dirname(_os.path.abspath(__file__))) + _os.sep


def _p(rel):
    return ROOT + rel.replace("/", _os.sep)


"""Execute the REAL Database-tab row renderer (PsychoMarksYou_DBTab.lua) with a
stubbed WoW frame API, and assert the new note-only "Note" branch fires.

RefreshMobList is a local closure inside PMY.BuildDatabaseTab, reached through
the tab's OnShow handler -- so the test drives it the way the client does.
"""
import sys
from lupa import LuaRuntime

L = LuaRuntime(unpack_returned_tuples=True)

L.execute(r'''
LOG = { rows = {}, errors = {} }

local noop = function() end

local objmt = {}
objmt.__index = function(self, key)
    if key == "CreateFontString" or key == "CreateTexture" then
        return function(s, ...)
            local child = newframe(key == "CreateTexture" and "Texture" or "FontString")
            local kids = rawget(s, "_kids") or {}
            kids[#kids + 1] = child
            rawset(s, "_kids", kids)
            return child
        end
    elseif key == "SetText" then
        return function(s, txt) rawset(s, "_text", txt) end
    elseif key == "GetText" then
        return function(s) return rawget(s, "_text") or "" end
    elseif key == "SetScript" then
        return function(s, name, fn)
            local sc = rawget(s, "_scripts") or {}
            sc[name] = fn
            rawset(s, "_scripts", sc)
        end
    elseif key == "GetWidth" or key == "GetHeight" or key == "GetEffectiveScale"
        or key == "GetVerticalScrollRange" or key == "GetHorizontalScrollRange"
        or key == "GetVerticalScroll" or key == "GetHorizontalScroll"
        or key == "GetNumRegions" or key == "GetID" then
        return function() return 400 end
    elseif key == "GetChecked" then
        return function() return false end
    elseif key == "GetParent" then
        return function(s) return rawget(s, "_parent") end
    elseif key == "IsShown" or key == "IsVisible" then
        return function() return true end
    elseif key == "GetFontString" then
        return function(s) return rawget(s, "_fontstring") end
    elseif key == "GetNormalTexture" then
        return function() return nil end
    end
    return noop
end

function newframe(kind)
    local o = { _kind = kind }
    setmetatable(o, objmt)
    return o
end

function CreateFrame(kind, name, parent, template)
    local f = newframe(kind)
    rawset(f, "_parent", parent)
    rawset(f, "_name", name)
    if name then _G[name] = f end
    local all = rawget(LOG, "frames") or {}
    all[#all + 1] = f
    rawset(LOG, "frames", all)
    return f
end

-- Record every row the renderer paints, so Python can inspect the results.
function logRow(zone, mobName, sourceText, markText, dangerText)
    local r = LOG.rows
    r[#r + 1] = { zone = zone, name = mobName,
                  source = sourceText, mark = markText, danger = dangerText }
end

function rowcount() return #LOG.rows end
function rowat(i)
    local r = LOG.rows[i]
    return r.zone, r.name, r.source, r.mark, r.danger
end

function print() end
function GameTooltip_Show() end

GameTooltip = newframe("GameTooltip")
GameTooltip.SetOwner = function() end
GameTooltip.AddLine = function() end
GameTooltip.Show = function() end
GameTooltip.Hide = function() end
GameTooltip.NumLines = function() return 0 end
GameTooltip.GetName = function() return "GameTooltip" end

''')

for path in ["PsychoMarksYou/PsychoMarksYou.lua",
             "PsychoMarksYou/PsychoMarksYou_DB_Classic.lua",
             "PsychoMarksYou/PsychoMarksYou_DB_Forever.lua",
             "PsychoMarksYou/PsychoMarksYou_Core.lua",
             "PsychoMarksYou/PsychoMarksYou_MobScanning.lua",
             "PsychoMarksYou/PsychoMarksYou_DBTab.lua"]:
    src = open(_p(path), "rb").read().decode("utf-8", "replace")
    try:
        L.execute(src)
    except Exception as exc:
        print("LOAD FAILED:", path)
        print(exc)
        sys.exit(1)
print("loaded the real DBTab module")

L.execute(r'''
PsychoMarksYou.db = {
    enabled = true, showTooltipHint = true, customMobs = {},
    maxMarksPerPack = 3, announceMode = "OFF",
}
PsychoMarksYou.currentZone = "Molten Core"
PsychoMarksYou.inInstance = true
''')

# Build the tab and fire its OnShow handler -> RefreshZoneList + RefreshMobList.
built = L.eval(r'''
function ()
    local tab = newframe("Frame")
    local ok, err = pcall(PsychoMarksYou.BuildDatabaseTab, tab)
    if not ok then return "BUILD FAILED: " .. tostring(err) end
    local scripts = rawget(tab, "_scripts") or {}
    if not scripts["OnShow"] then return "no OnShow handler registered" end
    local ok2, err2 = pcall(scripts["OnShow"], tab)
    if not ok2 then return "ONSHOW FAILED: " .. tostring(err2) end
    return "ok"
end
''')()
print("BuildDatabaseTab + OnShow:", built)
if built != "ok":
    sys.exit(1)

# Collect the painted rows out of the stubbed frames.
L.eval(r'''
function ()
    LOG.rows = {}
    for _, f in ipairs(LOG.frames) do
        if rawget(f, "_kind") == "Button" and rawget(f, "sourceText") then
            local fs = rawget(f, "sourceText")
            local mb = rawget(f, "markBtn")
            local db = rawget(f, "dangerBtn")
            local nt = rawget(f, "nameText")
            logRow("", (nt and rawget(nt, "_text")) or "",
                   (fs and rawget(fs, "_text")) or "",
                   (mb and rawget(mb, "_text")) or "",
                   (db and rawget(db, "_text")) or "")
        end
    end
    return true
end
''')()

n = L.eval("rowcount()")
print("rows painted by the real renderer:", n)
if n == 0:
    print("FAIL: renderer painted no rows")
    sys.exit(1)

rows = [L.eval("rowat(%d)" % i) for i in range(1, n + 1)]

results = []


def check(name, cond, detail=""):
    results.append(bool(cond))
    print(("  PASS  " if cond else "  FAIL  ") + name + (("  -> " + str(detail)) if detail else ""))


# The renderer paints the selected zone (Molten Core). Show what it produced.
print("\n-- Molten Core rows, Type/Info column --")
for name, source, mark, danger in [(r[1], r[2], r[3], r[4]) for r in rows]:
    if source and "Note" in source:
        print("   note-only  %-26s source=%-8s mark=%r danger=%r" % (name, source, mark, danger))

note_rows = [r for r in rows if r[2] and "Note" in r[2]]
check("at least one row hit the new note-only 'Note' branch",
      len(note_rows) > 0, "%d note rows" % len(note_rows))
check("all note-only rows show '?' as their mark (README claim)",
      all(r[3] == "?" for r in note_rows),
      sorted(set(r[3] for r in note_rows)))
check("every Molten Core note-only name is a real note-only DB row",
      {r[1] for r in note_rows} <= {
          "Flamewaker Elite", "Firesworn", "Lava Annihilator",
          "Molten Giant", "Molten Destroyer"},
      sorted({r[1] for r in note_rows}))

marked = [r for r in rows if r[3] and r[3] != "?" and "SKIP" not in r[3]]
check("marked rows are NOT labelled 'Note'",
      all("Note" not in (r[2] or "") for r in marked),
      "%d marked rows" % len(marked))

lava = [r for r in rows if r[1] == "Lava Spawn"]
check("Lava Spawn now renders as a Skull priority row",
      bool(lava) and "Skull" in (lava[0][3] or ""),
      lava[0][3] if lava else "missing")

tech = [r for r in rows if r[1] == "Blackwing Technician"]
print("\n(Blackwing Technician is in Blackwing Lair; re-rendering that zone)")
L.execute('PsychoMarksYou.currentZone = "Blackwing Lair"')
rebuilt = L.eval(r'''
function ()
    LOG.frames = {}
    LOG.rows = {}
    local tab = newframe("Frame")
    local ok, err = pcall(PsychoMarksYou.BuildDatabaseTab, tab)
    if not ok then return "BUILD FAILED: " .. tostring(err) end
    local scripts = rawget(tab, "_scripts") or {}
    local ok2, err2 = pcall(scripts["OnShow"], tab)
    if not ok2 then return "ONSHOW FAILED: " .. tostring(err2) end
    return "ok"
end
''')()
L.eval(r'''
function ()
    for _, f in ipairs(LOG.frames) do
        if rawget(f, "_kind") == "Button" and rawget(f, "sourceText") then
            local nt = rawget(f, "nameText")
            local mb = rawget(f, "markBtn")
            logRow("", (nt and rawget(nt, "_text")) or "",
                   (rawget(rawget(f, "sourceText"), "_text")) or "",
                   (mb and rawget(mb, "_text")) or "",
                   (rawget(rawget(f, "dangerBtn"), "_text")) or "")
        end
    end
    return true
end
''')()
n2 = L.eval("rowcount()")
rows2 = [L.eval("rowat(%d)" % i) for i in range(1, n2 + 1)]
tech = [r for r in rows2 if r[1] == "Blackwing Technician"]
check("Blackwing Technician renders as SKIP (mark = \"SKIP\" in a table row)",
      bool(tech) and "SKIP" in (tech[0][3] or ""),
      (tech[0][3], tech[0][2]) if tech else "missing")

overseer = [r for r in rows2 if r[1] == "Death Talon Overseer"]
check("Death Talon Overseer is note-only in the UI",
      bool(overseer) and "Note" in (overseer[0][2] or "") and overseer[0][3] == "?",
      (overseer[0][2], overseer[0][3]) if overseer else "missing")

print("\n" + "=" * 70)
p = sum(results)
print("RESULT: %d/%d checks passed" % (p, len(results)))
if p != len(results):
    sys.exit(1)
