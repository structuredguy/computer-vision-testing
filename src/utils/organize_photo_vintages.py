# Copied from scratch to workspace src/utils
import sys
import os
sys.path.append(r"C:\Users\tglla\.gemini\antigravity\brain\d68d4dca-0412-4aa9-8a90-ee99810e011c\scratch")
from organize_all_vintages import organize_vintage, generate_map_html, normalize_location

if __name__ == "__main__":
    dry = "--dry-run" in sys.argv
    years_to_run = [2015, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024]
    for yr in years_to_run:
        organize_vintage(yr, dry_run=dry)
