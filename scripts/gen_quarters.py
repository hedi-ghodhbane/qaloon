#!/usr/bin/env python3
"""Generate hizb_quarters.json with exact Qaloun page numbers.

Reads glyphs_qaloun.json to build a (surah, ayah) -> page mapping,
then uses the standard 240 rub al-hizb starting ayahs to produce
the output file.
"""

import json
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
GLYPHS_PATH = os.path.join(PROJECT_ROOT, "assets", "metadata", "glyphs_qaloun.json")
OUTPUT_PATH = os.path.join(PROJECT_ROOT, "assets", "metadata", "hizb_quarters.json")

# Standard Quran rub al-hizb (quarter) starting positions: (surah, ayah)
# 240 entries = 60 hizb x 4 quarters. Universal across all riwayat.
QUARTERS = [
    # Juz 1 - Hizb 1
    (1,1),(2,26),(2,44),(2,60),
    # Hizb 2
    (2,75),(2,92),(2,106),(2,124),
    # Juz 2 - Hizb 3
    (2,142),(2,158),(2,177),(2,189),
    # Hizb 4
    (2,203),(2,219),(2,233),(2,243),
    # Juz 3 - Hizb 5
    (2,253),(2,263),(2,272),(2,283),
    # Hizb 6
    (3,15),(3,33),(3,52),(3,75),
    # Juz 4 - Hizb 7
    (3,93),(3,113),(3,133),(3,153),
    # Hizb 8
    (3,171),(3,186),(4,1),(4,12),
    # Juz 5 - Hizb 9
    (4,24),(4,36),(4,58),(4,74),
    # Hizb 10
    (4,88),(4,100),(4,114),(4,135),
    # Juz 6 - Hizb 11
    (4,148),(4,163),(5,1),(5,12),
    # Hizb 12
    (5,27),(5,41),(5,51),(5,67),
    # Juz 7 - Hizb 13
    (5,82),(5,97),(5,109),(6,13),
    # Hizb 14
    (6,36),(6,59),(6,74),(6,95),
    # Juz 8 - Hizb 15
    (6,111),(6,127),(6,141),(6,152),
    # Hizb 16
    (7,1),(7,31),(7,47),(7,65),
    # Juz 9 - Hizb 17
    (7,88),(7,117),(7,142),(7,156),
    # Hizb 18
    (7,171),(7,189),(8,1),(8,22),
    # Juz 10 - Hizb 19
    (8,41),(8,61),(8,75),(9,3),
    # Hizb 20
    (9,19),(9,34),(9,46),(9,60),
    # Juz 11 - Hizb 21
    (9,75),(9,93),(9,111),(9,122),
    # Hizb 22
    (10,1),(10,26),(10,53),(10,71),
    # Juz 12 - Hizb 23
    (10,90),(11,6),(11,24),(11,41),
    # Hizb 24
    (11,61),(11,84),(11,108),(12,7),
    # Juz 13 - Hizb 25
    (12,30),(12,53),(12,77),(12,101),
    # Hizb 26
    (13,1),(13,19),(13,35),(14,10),
    # Juz 14 - Hizb 27
    (14,28),(15,1),(15,50),(15,85),
    # Hizb 28
    (16,1),(16,30),(16,51),(16,75),
    # Juz 15 - Hizb 29
    (16,90),(16,111),(17,1),(17,23),
    # Hizb 30
    (17,50),(17,70),(17,99),(18,17),
    # Juz 16 - Hizb 31
    (18,32),(18,51),(18,75),(18,99),
    # Hizb 32
    (19,22),(19,59),(19,96),(20,55),
    # Juz 17 - Hizb 33
    (20,83),(20,111),(20,130),(21,29),
    # Hizb 34
    (21,51),(21,83),(22,1),(22,19),
    # Juz 18 - Hizb 35
    (22,38),(22,60),(22,78),(23,18),
    # Hizb 36
    (23,36),(23,75),(23,118),(24,21),
    # Hizb 37
    (24,35),(24,53),(25,1),(25,21),
    # Hizb 38
    (25,53),(26,1),(26,52),(26,111),
    # Juz 20 - Hizb 39
    (26,181),(27,1),(27,27),(27,56),
    # Hizb 40
    (27,82),(28,12),(28,29),(28,51),
    # Juz 21 - Hizb 41
    (28,76),(29,1),(29,26),(29,46),
    # Hizb 42
    (29,64),(30,31),(30,54),(31,22),
    # Juz 22 - Hizb 43
    (32,1),(32,21),(33,18),(33,31),
    # Hizb 44
    (33,51),(33,60),(34,10),(34,24),
    # Juz 23 - Hizb 45
    (34,46),(35,15),(35,41),(36,28),
    # Hizb 46
    (36,60),(37,22),(37,83),(37,145),
    # Juz 24 - Hizb 47
    (38,1),(38,22),(38,52),(39,8),
    # Hizb 48
    (39,32),(39,53),(40,1),(40,21),
    # Juz 25 - Hizb 49
    (40,41),(40,66),(41,9),(41,25),
    # Hizb 50
    (41,47),(42,13),(42,27),(42,51),
    # Juz 26 - Hizb 51
    (43,24),(43,57),(44,1),(44,41),
    # Hizb 52
    (45,12),(46,1),(46,21),(47,10),
    # Juz 27 - Hizb 53
    (47,33),(48,15),(48,29),(49,11),
    # Hizb 54
    (50,27),(51,31),(52,1),(52,24),
    # Juz 28 - Hizb 55
    (53,1),(53,26),(54,1),(54,28),
    # Hizb 56
    (55,1),(55,41),(56,1),(56,75),
    # Juz 29 - Hizb 57
    (57,1),(57,16),(57,25),(58,1),
    # Hizb 58
    (58,14),(59,11),(60,1),(60,7),
    # Juz 30 - Hizb 59
    (61,1),(62,1),(63,1),(65,1),
    # Hizb 60
    (67,1),(69,1),(73,1),(78,1),
]

assert len(QUARTERS) == 240, f"Expected 240, got {len(QUARTERS)}"


def main():
    # Build (surah, ayah) -> first page mapping from glyphs
    with open(GLYPHS_PATH, "r") as f:
        glyphs = json.load(f)

    ayah_page = {}  # (surah, ayah) -> min page
    for g in glyphs:
        key = (g["s"], g["a"])
        page = g["p"]
        if key not in ayah_page or page < ayah_page[key]:
            ayah_page[key] = page

    result = []
    for i, (surah, ayah) in enumerate(QUARTERS):
        juz = (i // 8) + 1
        hizb = (i // 4) + 1
        quarter_in_hizb = (i % 4) + 1

        key = (surah, ayah)
        page = ayah_page.get(key)
        if page is None:
            print(f"WARNING: no glyph for surah {surah} ayah {ayah}")
            page = -1

        result.append({
            "quarterIndex": i,
            "juz": juz,
            "hizb": hizb,
            "quarterInHizb": quarter_in_hizb,
            "surah": surah,
            "ayah": ayah,
            "page": page,
        })

    with open(OUTPUT_PATH, "w") as f:
        json.dump(result, f, indent=2)
        f.write("\n")

    print(f"Wrote {len(result)} quarters to {OUTPUT_PATH}")

    # Print summary for verification
    for r in result[:8]:
        print(f"  Q{r['quarterIndex']:3d}  J{r['juz']:2d} H{r['hizb']:2d}.{r['quarterInHizb']}  "
              f"{r['surah']:3d}:{r['ayah']:<3d}  page {r['page']}")
    print("  ...")
    for r in result[-4:]:
        print(f"  Q{r['quarterIndex']:3d}  J{r['juz']:2d} H{r['hizb']:2d}.{r['quarterInHizb']}  "
              f"{r['surah']:3d}:{r['ayah']:<3d}  page {r['page']}")


if __name__ == "__main__":
    main()
