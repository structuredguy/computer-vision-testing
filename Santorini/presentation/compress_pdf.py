"""PDF utility to compress embedded images and/or split presentations for download.
"""

import argparse
import io
import os
import sys
from pathlib import Path
from PIL import Image
import pymupdf


def compress_pdf(
    input_path: Path,
    output_path: Path,
    max_dimension: int = 1200,
    jpeg_quality: int = 75,
    target_max_bytes: int = 1_900_000,
) -> None:
    """Compress high-resolution embedded images inside a PDF under target limit (default ~1.9 MB)."""
    print(f"Opening {input_path.name} ({input_path.stat().st_size / (1024*1024):.2f} MB)...")
    
    current_dim = max_dimension
    current_q = jpeg_quality

    for attempt in range(3):
        doc = pymupdf.open(str(input_path))
        processed_xrefs = set()

        for page_idx, page in enumerate(doc):
            for img_info in page.get_images():
                xref = img_info[0]
                if xref in processed_xrefs:
                    continue
                processed_xrefs.add(xref)

                base_image = doc.extract_image(xref)
                image_bytes = base_image.get("image")
                if not image_bytes:
                    continue

                try:
                    img = Image.open(io.BytesIO(image_bytes))
                    orig_w, orig_h = img.size
                    if max(orig_w, orig_h) > current_dim:
                        img.thumbnail((current_dim, current_dim), Image.Resampling.LANCZOS)

                    out_buf = io.BytesIO()
                    if img.mode in ("RGBA", "P"):
                        img = img.convert("RGB")
                    img.save(out_buf, format="JPEG", quality=current_q, optimize=True)
                    new_bytes = out_buf.getvalue()

                    if len(new_bytes) < len(image_bytes):
                        doc.update_stream(xref, new_bytes)
                except Exception as err:
                    print(f"  Warning on page {page_idx+1}, xref {xref}: {err}")

        doc.save(str(output_path), garbage=4, deflate=True)
        final_size = output_path.stat().st_size
        print(f"Attempt {attempt + 1}: {final_size:,} bytes ({final_size / (1024*1024):.2f} MB)")
        if final_size <= target_max_bytes:
            break
        current_dim = int(current_dim * 0.85)
        current_q = max(55, current_q - 10)

    print(f"Compressed PDF saved to {output_path.name}: {output_path.stat().st_size:,} bytes")


def split_pdf(input_path: Path, part1_path: Path, part2_path: Path, split_page: int = 5) -> None:
    """Split a PDF into two parts around split_page."""
    print(f"Splitting {input_path.name} at page {split_page}...")
    doc = pymupdf.open(str(input_path))
    total_pages = len(doc)

    doc1 = pymupdf.open()
    doc1.insert_pdf(doc, from_page=0, to_page=min(split_page - 1, total_pages - 1))
    doc1.save(str(part1_path), garbage=4, deflate=True)

    if split_page < total_pages:
        doc2 = pymupdf.open()
        doc2.insert_pdf(doc, from_page=split_page, to_page=total_pages - 1)
        doc2.save(str(part2_path), garbage=4, deflate=True)

    print(f"  Part 1 (pages 1-{split_page}): {part1_path.stat().st_size:,} bytes ({part1_path.stat().st_size / (1024*1024):.2f} MB)")
    print(f"  Part 2 (pages {split_page+1}-{total_pages}): {part2_path.stat().st_size:,} bytes ({part2_path.stat().st_size / (1024*1024):.2f} MB)")


if __name__ == "__main__":
    base_dir = Path(__file__).resolve().parent
    default_input = base_dir / "main.pdf"

    parser = argparse.ArgumentParser(description="Compress or split presentation PDF.")
    parser.add_argument("--input", type=Path, default=default_input, help="Input PDF path")
    parser.add_argument("--compress", action="store_true", default=True, help="Compress embedded images")
    parser.add_argument("--split", action="store_true", help="Split into two parts")
    args = parser.parse_args()

    if not args.input.exists():
        print(f"Error: {args.input} does not exist.")
        sys.exit(1)

    comp_output = args.input.parent / f"{args.input.stem}_compressed.pdf"
    compress_pdf(args.input, comp_output)

    if args.split:
        p1 = args.input.parent / f"{args.input.stem}_part1.pdf"
        p2 = args.input.parent / f"{args.input.stem}_part2.pdf"
        split_pdf(comp_output, p1, p2)
