#!/usr/bin/env python3
"""
Seeds the Surah metadata into the app's initial SQLite database.
Reads surahs.json and generates SQL INSERT statements that can be
imported into the Drift database during the build pipeline.

Usage:
    python3 seed_metadata.py
"""

import json
import sqlite3
from pathlib import Path

SURAHS_JSON = Path(__file__).parent.parent / "assets" / "metadata" / "surahs.json"
OUTPUT_DB = Path(__file__).parent.parent / "assets" / "db" / "metadata.db"


def main() -> None:
    with open(SURAHS_JSON) as f:
        surahs = json.load(f)

    OUTPUT_DB.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(str(OUTPUT_DB))
    cursor = conn.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS surahs (
            id INTEGER PRIMARY KEY,
            name_arabic TEXT NOT NULL,
            name_transliterated TEXT NOT NULL,
            ayah_count INTEGER NOT NULL
        )
    """)

    for s in surahs:
        cursor.execute(
            "INSERT OR REPLACE INTO surahs (id, name_arabic, name_transliterated, ayah_count) VALUES (?, ?, ?, ?)",
            (s["id"], s["nameArabic"], s["nameTransliterated"], s["ayahCount"]),
        )

    conn.commit()
    conn.close()
    print(f"Seeded {len(surahs)} surahs into {OUTPUT_DB}")


if __name__ == "__main__":
    main()
