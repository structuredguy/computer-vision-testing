"""Utility using the GIMP MCP server to generate lightweight, low-resolution
working images for the Santorini presentation.
"""

import json
import os
import socket
from pathlib import Path
from PIL import Image


def gimp_send(cmd: str, params: dict = None, host: str = "localhost", port: int = 9877) -> dict:
    """Send JSON command to GIMP MCP plugin over socket."""
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(15)
    s.connect((host, port))
    payload = json.dumps({"type": cmd, "params": params or {}}).encode("utf-8") + b"\n"
    s.sendall(payload)

    buf = b""
    while True:
        chunk = s.recv(4096)
        if not chunk:
            break
        buf += chunk
        try:
            res = json.loads(buf.decode("utf-8"))
            s.close()
            return res
        except (json.JSONDecodeError, UnicodeDecodeError):
            continue
    s.close()
    return {}


def process_images_with_gimp(
    source_dir: Path,
    output_dir: Path,
    image_names: list[str],
    max_dimension: int = 1000,
) -> None:
    """Scale and export images using GIMP MCP server, then optimize stripped output."""
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Connecting to GIMP MCP server on localhost:9877...")
    status = gimp_send("check_server")
    if not status.get("results", {}).get("running"):
        raise ConnectionError("GIMP MCP server is not running on port 9877.")
    print("GIMP MCP server verified.")

    for name in image_names:
        # Resolve source file
        src_path = source_dir / name
        if not src_path.exists():
            # Try case-insensitive lookup
            matched = [f for f in source_dir.iterdir() if f.name.lower() == name.lower()]
            if matched:
                src_path = matched[0]
            else:
                print(f"Skipping {name}: not found in {source_dir}")
                continue

        out_path = output_dir / name
        is_png = src_path.suffix.lower() == ".png"
        export_fmt = "png" if is_png else "jpeg"

        print(f"\nProcessing {src_path.name} ({src_path.stat().st_size / (1024*1024):.2f} MB)...")

        # 1. Open in GIMP
        open_res = gimp_send("open_image", {"file_path": str(src_path.resolve())})
        if open_res.get("status") != "success":
            print(f"  GIMP open failed: {open_res.get('error')}")
            continue

        # 2. Scale in GIMP preserving aspect ratio
        scale_res = gimp_send(
            "scale_to_fit",
            {
                "image_index": 0,
                "max_width": max_dimension,
                "max_height": max_dimension,
                "interpolation": "cubic",
            },
        )
        scaled_w = scale_res.get("results", {}).get("width")
        scaled_h = scale_res.get("results", {}).get("height")
        print(f"  Scaled in GIMP to: {scaled_w}x{scaled_h}")

        # 3. Export from GIMP
        export_res = gimp_send(
            "export_image",
            {
                "file_path": str(out_path.resolve()),
                "format": export_fmt,
                "quality": 78,
                "flatten": True,
                "image_index": 0,
            },
        )
        if export_res.get("status") != "success":
            print(f"  GIMP export failed: {export_res.get('error')}")
            continue

        # 4. Strip camera metadata (EXIF/ICC) to achieve <100 KB file size
        with Image.open(out_path) as img:
            if is_png:
                img.save(out_path, format="PNG", optimize=True)
            else:
                if img.mode in ("RGBA", "P"):
                    img = img.convert("RGB")
                img.save(out_path, format="JPEG", quality=76, optimize=True)

        final_sz = out_path.stat().st_size
        print(f"  Saved {out_path.name}: {final_sz:,} bytes ({final_sz / 1024:.1f} KB)")


if __name__ == "__main__":
    santorini_dir = Path(r"C:\dev\computer-vision-testing\Santorini")
    out_working_dir = santorini_dir / "img_working"

    target_images = [
        "Santorini-panorama.png",
        "Yposkafa are Cave homes carved into volcanic pumice, from paulshark and Getty Images.jpg",
        "blue-domes.jpg",
        "thermal_response_EN.png",
        "Mykonos-street.JPG",
        "Mykonos-windmills.JPG",
        "Santorini-seismic-engineering.png",
        "Santorini-volcano.JPG",
        "cable-car.jpg",
        "Santorini-modern-challenges.jpg",
        "Santorini-Caldera rim in Fira.JPG",
    ]

    process_images_with_gimp(santorini_dir, out_working_dir, target_images, max_dimension=1000)
