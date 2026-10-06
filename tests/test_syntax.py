#!/usr/bin/env python3
"""Compile every addon Lua file so a syntax error anywhere fails the suite.

The behavioural suites only load the modules they exercise; this one parses all
of them (Bindings-free, no WoW API needed).
"""
import glob
import os as _os
import sys
from lupa import LuaRuntime

ROOT = _os.path.dirname(_os.path.dirname(_os.path.abspath(__file__))) + _os.sep

L = LuaRuntime()
L.execute(r'''
function compilecheck(s, name)
  local f, err = load(s, "@" .. name)
  if f then return "OK" else return tostring(err) end
end
''')
compilecheck = L.eval("compilecheck")

files = sorted(glob.glob(_os.path.join(ROOT, "PsychoMarksYou", "*.lua")))
if not files:
    sys.exit("no addon Lua files found under %s" % ROOT)

bad = 0
for path in files:
    rel = _os.path.relpath(path, ROOT)
    res = compilecheck(open(path, "rb").read().decode("utf-8", "replace"), rel)
    if res != "OK":
        print("  FAIL  %s: %s" % (rel, res))
        bad += 1
    else:
        print("  PASS  compiles  %s" % rel)

print("\n%d/%d files compile" % (len(files) - bad, len(files)))
sys.exit(1 if bad else 0)
