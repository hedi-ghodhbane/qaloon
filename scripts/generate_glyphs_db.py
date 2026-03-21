#!/usr/bin/env python3
"""
Generates glyphs.db from Qaloun page images using OpenCV template matching.

Detects ayah end markers on each page, determines line positions,
and maps each marker to a surah:ayah using Quran structure metadata.

Prerequisites:
    - Page images at assets/pages/qaloun/
    - pip install opencv-python numpy
"""

import sqlite3
import sys
from pathlib import Path

import cv2
import numpy as np

SCRIPT_DIR = Path(__file__).parent
IMAGES_DIR = SCRIPT_DIR.parent / "assets" / "pages" / "qaloun"
TEMPLATE_PATH = SCRIPT_DIR / "template_qaloun.png"
OUTPUT_DB = SCRIPT_DIR.parent / "assets" / "db" / "glyphs.db"

TOTAL_PAGES = 604
MATCH_THRESHOLD = 0.75
NMS_DISTANCE = 20  # Non-max suppression: merge detections within this distance

# Ayah counts per surah (1-indexed, surah 1 = Al-Fatiha has 7 ayahs)
AYAHS_PER_SURAH = [
    7, 286, 200, 176, 120, 165, 206, 75, 129, 109,
    123, 111, 43, 52, 99, 128, 111, 110, 98, 135,
    112, 78, 118, 64, 77, 227, 93, 88, 69, 60,
    34, 30, 73, 54, 45, 83, 182, 88, 75, 85,
    54, 53, 89, 59, 37, 35, 38, 29, 18, 45,
    60, 49, 62, 55, 78, 96, 29, 22, 24, 13,
    14, 11, 11, 18, 12, 12, 30, 52, 52, 44,
    28, 28, 20, 56, 40, 31, 50, 40, 46, 42,
    29, 19, 36, 25, 22, 17, 19, 26, 30, 20,
    15, 21, 11, 8, 8, 19, 5, 8, 8, 11,
    11, 8, 3, 9, 5, 4, 7, 3, 6, 3,
    5, 4, 5, 6,
]

# Qaloun: first page of each surah (1-indexed).
# Page 1 = Al-Fatiha, Page 2 = Al-Baqarah, etc.
# These are approximate and may need fine-tuning for Qaloun specifically.
SURAH_START_PAGE = [
    1, 2, 50, 77, 106, 128, 151, 177, 187, 208,
    221, 235, 249, 255, 262, 267, 282, 293, 305, 312,
    322, 332, 342, 350, 359, 367, 377, 385, 396, 404,
    411, 415, 418, 428, 434, 440, 446, 453, 462, 467,
    477, 483, 489, 496, 499, 502, 507, 511, 515, 518,
    520, 523, 526, 528, 531, 534, 537, 542, 545, 549,
    551, 553, 554, 556, 558, 560, 562, 564, 566, 568,
    570, 572, 574, 575, 577, 578, 580, 582, 583, 585,
    586, 587, 587, 589, 590, 591, 591, 592, 593, 594,
    595, 595, 596, 596, 597, 597, 598, 598, 599, 599,
    600, 600, 601, 601, 601, 602, 602, 602, 603, 603,
    603, 604, 604, 604,
]


def composite_to_white(image_path: str) -> np.ndarray:
    """Load a transparent PNG and composite onto white background."""
    page = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)
    if page is None:
        return None
    if page.shape[2] == 4:
        alpha = page[:, :, 3] / 255.0
        white = np.ones_like(page[:, :, :3], dtype=np.uint8) * 255
        for c in range(3):
            white[:, :, c] = (page[:, :, c] * alpha + 255 * (1 - alpha)).astype(
                np.uint8
            )
        return white
    return page[:, :, :3]


def detect_markers(page_bgr: np.ndarray, template: np.ndarray) -> list:
    """Detect ayah markers using template matching with NMS."""
    result = cv2.matchTemplate(page_bgr, template, cv2.TM_CCOEFF_NORMED)
    locations = np.where(result >= MATCH_THRESHOLD)

    th, tw = template.shape[:2]
    raw_boxes = []
    for y, x in zip(locations[0], locations[1]):
        raw_boxes.append((x, y, tw, th, result[y, x]))

    # Non-maximum suppression: keep only the best match within NMS_DISTANCE
    raw_boxes.sort(key=lambda b: b[4], reverse=True)
    kept = []
    for box in raw_boxes:
        bx, by = box[0], box[1]
        too_close = False
        for k in kept:
            if abs(bx - k[0]) < NMS_DISTANCE and abs(by - k[1]) < NMS_DISTANCE:
                too_close = True
                break
        if not too_close:
            kept.append(box)

    # Sort by position: top-to-bottom, then right-to-left (RTL reading order)
    kept.sort(key=lambda b: (b[1], -b[0]))
    return [(x, y, w, h) for x, y, w, h, _ in kept]


def detect_lines(page_bgr: np.ndarray, num_lines: int = 15) -> list:
    """Detect text line boundaries by finding horizontal white gaps."""
    gray = cv2.cvtColor(page_bgr, cv2.COLOR_BGR2GRAY)
    h, w = gray.shape

    # Compute row-wise mean intensity
    row_mean = np.mean(gray, axis=1)

    # White rows have high mean (> 240)
    is_white = row_mean > 240

    # Find transitions from white to non-white (line starts)
    # and non-white to white (line ends)
    lines = []
    in_line = False
    line_start = 0

    for y in range(h):
        if not is_white[y] and not in_line:
            line_start = y
            in_line = True
        elif is_white[y] and in_line:
            lines.append((line_start, y))
            in_line = False

    if in_line:
        lines.append((line_start, h - 1))

    return lines


def get_surah_ayah_for_page(page_num: int) -> tuple:
    """Return (surah_number, first_ayah_on_page) for a given page."""
    surah = 1
    for s in range(len(SURAH_START_PAGE) - 1):
        if SURAH_START_PAGE[s] <= page_num < SURAH_START_PAGE[s + 1]:
            surah = s + 1
            break
    else:
        surah = 114

    return surah


def create_database() -> sqlite3.Connection:
    """Create the glyphs SQLite database."""
    OUTPUT_DB.parent.mkdir(parents=True, exist_ok=True)
    if OUTPUT_DB.exists():
        OUTPUT_DB.unlink()

    conn = sqlite3.connect(str(OUTPUT_DB))
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE glyphs (
            glyph_id INTEGER PRIMARY KEY,
            page_number INTEGER NOT NULL,
            line_number INTEGER NOT NULL,
            sura_number INTEGER NOT NULL,
            ayah_number INTEGER NOT NULL,
            position INTEGER NOT NULL,
            min_x INTEGER NOT NULL,
            max_x INTEGER NOT NULL,
            min_y INTEGER NOT NULL,
            max_y INTEGER NOT NULL
        )
    """)
    cur.execute("CREATE INDEX sura_ayah_idx ON glyphs(sura_number, ayah_number)")
    cur.execute("CREATE INDEX page_idx ON glyphs(page_number)")
    conn.commit()
    return conn


def main():
    if not IMAGES_DIR.exists():
        print(f"ERROR: {IMAGES_DIR} not found. Run download_qaloun_pngs.py first.")
        sys.exit(1)

    template = cv2.imread(str(TEMPLATE_PATH))
    if template is None:
        print(f"ERROR: Template not found at {TEMPLATE_PATH}")
        sys.exit(1)

    image_count = len(list(IMAGES_DIR.glob("*.png")))
    print(f"Found {image_count} pages, template: {template.shape[:2]}")
    print(f"Match threshold: {MATCH_THRESHOLD}, NMS distance: {NMS_DISTANCE}")

    conn = create_database()
    cursor = conn.cursor()
    glyph_id = 1

    # Track surah/ayah position across pages
    current_surah = 1
    current_ayah = 1
    total_markers = 0

    for page_num in range(1, TOTAL_PAGES + 1):
        image_path = str(IMAGES_DIR / f"{page_num}.png")
        page_bgr = composite_to_white(image_path)
        if page_bgr is None:
            continue

        # Check if this page starts a new surah
        if current_surah < 114 and page_num >= SURAH_START_PAGE[current_surah]:
            current_surah += 1
            current_ayah = 1

        # Detect markers and lines
        markers = detect_markers(page_bgr, template)
        lines = detect_lines(page_bgr)

        if page_num <= 5 or page_num % 100 == 0:
            print(
                f"  [{page_num:>3}/604] markers={len(markers):>2}, "
                f"lines={len(lines):>2}, surah={current_surah}, ayah={current_ayah}"
            )

        # Map each marker to a line number
        for pos_idx, (mx, my, mw, mh) in enumerate(markers):
            marker_center_y = my + mh // 2

            line_num = 1
            for li, (ly_start, ly_end) in enumerate(lines):
                if ly_start <= marker_center_y <= ly_end:
                    line_num = li + 1
                    break

            cursor.execute(
                "INSERT INTO glyphs VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (
                    glyph_id,
                    page_num,
                    line_num,
                    current_surah,
                    current_ayah,
                    pos_idx + 1,
                    mx,
                    mx + mw,
                    my,
                    my + mh,
                ),
            )
            glyph_id += 1

            # Advance to next ayah
            current_ayah += 1
            if current_ayah > AYAHS_PER_SURAH[current_surah - 1]:
                if current_surah < 114:
                    current_surah += 1
                    current_ayah = 1

        total_markers += len(markers)

    conn.commit()
    conn.close()
    print(f"\nDone! Generated {total_markers} glyph entries in {OUTPUT_DB}")
    print(f"Final position: surah {current_surah}, ayah {current_ayah}")


if __name__ == "__main__":
    main()
