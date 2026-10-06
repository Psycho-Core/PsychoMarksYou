#!/usr/bin/env python3
"""Run every Psycho Marks You harness. Usage:

    python3 -m venv .venv && .venv/bin/pip install lupa
    .venv/bin/python tests/run_tests.py

These load the real addon Lua modules into a Lua VM with a stubbed WoW API, so
they exercise the shipped code rather than a copy of it. They do not replace
in-client verification of secure actions, nameplates, or key overrides.
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SUITES = ["test_syntax.py", "test_databases.py", "test_behaviour.py", "test_dbtab.py"]

try:
    import lupa  # noqa: F401
except ImportError:
    sys.exit("lupa is required:  pip install lupa")

failed = []
for suite in SUITES:
    path = os.path.join(HERE, suite)
    print("\n" + "#" * 72)
    print("# " + suite)
    print("#" * 72)
    rc = subprocess.call([sys.executable, path])
    if rc != 0:
        failed.append(suite)

print("\n" + "=" * 72)
if failed:
    print("FAILED SUITES: " + ", ".join(failed))
    sys.exit(1)
print("All %d suites passed." % len(SUITES))
