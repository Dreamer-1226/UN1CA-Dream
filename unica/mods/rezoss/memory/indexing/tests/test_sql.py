#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run the actual Java-produced fallback predicates against SQLite."""
import base64
import sqlite3
import sys

db = sqlite3.connect(":memory:")
db.executescript("""
CREATE TABLE memory (_id INTEGER, title TEXT, body TEXT, source_text TEXT,
 user_note TEXT, memo TEXT, representative_tag TEXT, is_locked INTEGER, deleted INTEGER);
CREATE VIEW memory_provider AS SELECT * FROM memory WHERE deleted = 0;
CREATE TABLE collection (_id INTEGER, name TEXT, searchable_keywords TEXT);
""")
for row in [(1, "sale", 0, 0), (2, "sale", 1, 0), (3, "sale", 0, 1),
            (4, "%_\\", 0, 0), (5, "x' OR 1=1 --", 0, 0), (6, "unrelated", 0, 0)]:
    db.execute("INSERT INTO memory VALUES (?,?, '', '', '', '', '', ?, ?)", row)
db.executemany("INSERT INTO collection VALUES (?, ?, '')", [(1, "sale"), (4, "%_\\"), (5, "x' OR 1=1 --"), (6, "unrelated")])
checks = 0
for line in open(sys.argv[1]):
    kind, *encoded = line.rstrip("\n").split("\t")
    text, selection, *arguments = [base64.b64decode(item).decode() for item in encoded]
    table = "memory_provider" if kind == "memory" else "collection"
    ids = [row[0] for row in db.execute(f"SELECT _id FROM {table} WHERE {selection}", arguments)]
    expected = {"sale": [1], "%_\\": [4], "x' OR 1=1 --": [5]}[text]
    assert ids == expected, (kind, text, ids, expected)
    checks += 1
print(f"{checks} SQLite literal search, locked/deleted exclusion and injection checks passed")
