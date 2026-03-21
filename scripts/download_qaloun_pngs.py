#!/usr/bin/env python3
"""
Downloads 604 Qaloun page PNG images from the maknon/Quran GitHub repository.

Usage:
    python3 download_qaloun_pngs.py [--output-dir DIR]

The images are downloaded from:
    https://raw.githubusercontent.com/maknon/Quran/master/pages-qalon/{page}.png
"""

import argparse
import os
import ssl
import sys
import urllib.request
from pathlib import Path

# Workaround for macOS SSL certificate issues.
ssl._create_default_https_context = ssl._create_unverified_context

TOTAL_PAGES = 604
BASE_URL = "https://raw.githubusercontent.com/maknon/Quran/master/pages-qalon"


def download_pages(output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)

    for page in range(1, TOTAL_PAGES + 1):
        filename = f"{page}.png"
        filepath = output_dir / filename

        if filepath.exists() and filepath.stat().st_size > 0:
            print(f"  [{page}/{TOTAL_PAGES}] Skipping {filename} (exists)")
            continue

        url = f"{BASE_URL}/{filename}"
        print(f"  [{page}/{TOTAL_PAGES}] Downloading {filename}...", end=" ")
        try:
            urllib.request.urlretrieve(url, filepath)
            size_kb = filepath.stat().st_size / 1024
            print(f"OK ({size_kb:.0f} KB)")
        except Exception as e:
            print(f"FAILED: {e}")
            # Retry once.
            try:
                urllib.request.urlretrieve(url, filepath)
                print(f"  Retry OK")
            except Exception as e2:
                print(f"  Retry FAILED: {e2}")
                sys.exit(1)


def main() -> None:
    parser = argparse.ArgumentParser(description="Download Qaloun page images")
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("assets/pages/qaloun"),
        help="Directory to save PNG files (default: assets/pages/qaloun)",
    )
    args = parser.parse_args()

    print(f"Downloading {TOTAL_PAGES} Qaloun page images to {args.output_dir}")
    download_pages(args.output_dir)
    print("Done!")


if __name__ == "__main__":
    main()
