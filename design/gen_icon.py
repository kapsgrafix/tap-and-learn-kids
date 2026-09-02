"""Generates the app icon / mascot artwork for Tap & Learn Kids.

Draws "Ollie the Owl", a simple friendly mascot, entirely with vector
shapes (no external art assets needed) and rasterizes it to PNG at all
the Android mipmap densities plus a 512x512 Play Store listing icon.
"""
import math
import os
from PIL import Image, ImageDraw

# Brand palette
BG_TOP = (255, 201, 60)      # sunny yellow
BG_BOTTOM = (255, 138, 61)   # warm orange
BODY = (255, 255, 255)       # white belly
FEATHER = (93, 156, 236)     # sky blue
FEATHER_DARK = (60, 120, 200)
EYE_WHITE = (255, 255, 255)
EYE_BLACK = (59, 59, 59)
BEAK = (255, 179, 71)
CHEEK = (255, 143, 171)

SIZE = 1024


def rounded_gradient_bg(draw, size, radius):
    top = Image.new("RGB", (size, size), BG_TOP)
    bottom = Image.new("RGB", (size, size), BG_BOTTOM)
    mask = Image.new("L", (size, size))
    mdraw = ImageDraw.Draw(mask)
    for y in range(size):
        mdraw.line([(0, y), (size, y)], fill=int(255 * y / size))
    grad = Image.composite(bottom, top, mask)
    corner_mask = Image.new("L", (size, size), 0)
    cdraw = ImageDraw.Draw(corner_mask)
    cdraw.rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    out.paste(grad, (0, 0), corner_mask)
    return out


def draw_owl(canvas: Image.Image):
    d = ImageDraw.Draw(canvas)
    cx, cy = SIZE // 2, SIZE // 2 + 30

    # Body (rounded egg shape) - sky blue
    body_w, body_h = 560, 620
    d.ellipse([cx - body_w / 2, cy - body_h / 2, cx + body_w / 2, cy + body_h / 2], fill=FEATHER)

    # Belly patch - white
    belly_w, belly_h = 360, 430
    d.ellipse([cx - belly_w / 2, cy - belly_h / 2 + 60, cx + belly_w / 2, cy + belly_h / 2 + 60], fill=BODY)

    # Wings
    d.ellipse([cx - body_w / 2 - 40, cy - 40, cx - body_w / 2 + 120, cy + 260], fill=FEATHER_DARK)
    d.ellipse([cx + body_w / 2 - 120, cy - 40, cx + body_w / 2 + 40, cy + 260], fill=FEATHER_DARK)

    # Ear tufts
    d.polygon([(cx - 150, cy - body_h / 2 + 40), (cx - 190, cy - body_h / 2 - 90), (cx - 90, cy - body_h / 2 + 10)], fill=FEATHER)
    d.polygon([(cx + 150, cy - body_h / 2 + 40), (cx + 190, cy - body_h / 2 - 90), (cx + 90, cy - body_h / 2 + 10)], fill=FEATHER)

    # Eyes (big + friendly)
    eye_r = 120
    for ex in (cx - 150, cx + 150):
        ey = cy - 90
        d.ellipse([ex - eye_r, ey - eye_r, ex + eye_r, ey + eye_r], fill=EYE_WHITE, outline=FEATHER_DARK, width=10)
        pupil_r = 55
        d.ellipse([ex - pupil_r, ey - pupil_r + 10, ex + pupil_r, ey + pupil_r + 10], fill=EYE_BLACK)
        d.ellipse([ex - 18 + 20, ey - 18 - 10, ex + 18 + 20, ey + 18 - 10], fill=(255, 255, 255))

    # Cheeks
    d.ellipse([cx - 250, cy + 10, cx - 160, cy + 90], fill=CHEEK)
    d.ellipse([cx + 160, cy + 10, cx + 250, cy + 90], fill=CHEEK)

    # Beak
    d.polygon([(cx - 45, cy + 10), (cx + 45, cy + 10), (cx, cy + 100)], fill=BEAK)

    # Feet
    foot_y = cy + body_h / 2 - 20
    for fx in (cx - 90, cx + 90):
        d.line([(fx, foot_y), (fx - 30, foot_y + 60)], fill=BEAK, width=18)
        d.line([(fx, foot_y), (fx, foot_y + 65)], fill=BEAK, width=18)
        d.line([(fx, foot_y), (fx + 30, foot_y + 60)], fill=BEAK, width=18)


def build_master():
    canvas = rounded_gradient_bg(None, SIZE, radius=220)
    draw_owl(canvas)
    return canvas


def export_all(master: Image.Image, out_root: str):
    # Play Store listing icon
    ps_dir = os.path.join(out_root, "store")
    os.makedirs(ps_dir, exist_ok=True)
    master.resize((512, 512), Image.LANCZOS).save(os.path.join(ps_dir, "play_store_icon_512.png"))
    master.save(os.path.join(ps_dir, "icon_master_1024.png"))

    densities = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    android_res = os.path.join(out_root, "android", "app", "src", "main", "res")
    for folder, px in densities.items():
        target_dir = os.path.join(android_res, folder)
        os.makedirs(target_dir, exist_ok=True)
        master.resize((px, px), Image.LANCZOS).save(os.path.join(target_dir, "ic_launcher.png"))

    # A copy for use inside the Flutter app itself (splash / home screen mascot)
    assets_dir = os.path.join(out_root, "assets", "images")
    os.makedirs(assets_dir, exist_ok=True)
    master.resize((800, 800), Image.LANCZOS).save(os.path.join(assets_dir, "mascot_ollie.png"))


if __name__ == "__main__":
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    m = build_master()
    export_all(m, root)
    print("Icon + mascot artwork generated.")
