"""Generate InkWarden Phase 2 sprite (A054) procedurally.

Phase 2 / "Enraged" form of InkWarden.  Compared to A030 (base):
  * larger, brighter amber eye core (bigger glow radius)
  * more coral pulse crack lines radiating from the eye
  * a slight red tint over the deep ink navy body
  * two extra "spike" tentacles extended outward
  * brighter glass cyan edge highlights

Style identical to A030-A032 (procedural pixel art, 64x96, 1px
black outline, ink navy body, muted violet corrosion edges).
"""
from PIL import Image

W, H = 64, 96

# STYLE_GUIDE Hex → RGB
INK_NAVY        = (7, 18, 34)
ABYSS_BLACK     = (4, 5, 9)
GLASS_CYAN      = (105, 199, 206)
PALE_RESONANCE  = (183, 231, 221)
MUTED_VIOLET    = (101, 80, 106)
CORAL_PULSE     = (232, 109, 90)
AMBER_VOICE     = (242, 182, 110)
WARM_PARCHMENT  = (230, 213, 184)
BLACK           = (0, 0, 0)
TRANSPARENT     = (0, 0, 0, 0)


def rgba(*rgb, a=255):
    return (rgb[0], rgb[1], rgb[2], a)


def make_canvas():
    return Image.new("RGBA", (W, H), TRANSPARENT)


def px(img, x, y, color):
    if 0 <= x < W and 0 <= y < H:
        img.putpixel((x, y), color)


def fill_rect(img, x0, y0, x1, y1, color):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            px(img, x, y, color)


def draw_outline_rect(img, x0, y0, x1, y1, color=BLACK):
    for x in range(x0, x1 + 1):
        px(img, x, y0, color)
        px(img, x, y1, color)
    for y in range(y0, y1 + 1):
        px(img, x0, y, color)
        px(img, x1, y, color)


def draw_circle(img, cx, cy, r, color):
    for y in range(cy - r, cy + r + 1):
        for x in range(cx - r, cx + r + 1):
            d2 = (x - cx) ** 2 + (y - cy) ** 2
            if d2 <= r * r:
                px(img, x, y, color)


def draw_ring(img, cx, cy, r_outer, r_inner, color):
    for y in range(cy - r_outer, cy + r_outer + 1):
        for x in range(cx - r_outer, cx + r_outer + 1):
            d2 = (x - cx) ** 2 + (y - cy) ** 2
            if r_inner * r_inner < d2 <= r_outer * r_outer:
                px(img, x, y, color)


# ---------------------------------------------------------------------
# Body silhouette — round blob, like A030 but slightly larger & angrier
# ---------------------------------------------------------------------
def draw_body_blob(img):
    # Build a filled blob via a series of row widths.
    # Rows (y, half-width) — symmetric around x=32
    body_rows = {
        18: 4,   # top
        19: 6,
        20: 8,
        21: 9,
        22: 10,
        23: 11,
        24: 12,
        25: 12,
        26: 13,
        27: 13,
        28: 14,
        29: 14,
        30: 15,
        31: 15,
        32: 16,
        33: 16,
        34: 17,
        35: 17,
        36: 18,
        37: 18,
        38: 19,
        39: 19,
        40: 19,
        41: 20,
        42: 20,
        43: 20,
        44: 20,
        45: 20,
        46: 20,  # widest around eye
        47: 20,
        48: 20,
        49: 19,
        50: 19,
        51: 19,
        52: 18,
        53: 18,
        54: 17,
        55: 17,
        56: 16,
        57: 15,
        58: 14,
        59: 12,
        60: 10,
        61: 8,
        62: 6,
        63: 4,
    }

    # Fill blob with INK_NAVY
    for y, hw in body_rows.items():
        fill_rect(img, 32 - hw, y, 32 + hw, y, rgba(*INK_NAVY))

    # Outline of blob (1px black)
    # Top arc
    for y, hw in body_rows.items():
        if (y - 1) in body_rows and body_rows[y - 1] < hw:
            # left edge
            for ty in range(y - 1, y + 1):
                if 32 - hw - 1 <= 32 - hw <= 32 - hw:
                    px(img, 32 - hw - 1, ty, rgba(*BLACK))
        if (y + 1) not in body_rows or body_rows.get(y + 1, 0) < hw:
            # right edge — but we draw full edge below
            pass

    # Simpler approach: walk each row and set black at leftmost/rightmost
    for y, hw in body_rows.items():
        px(img, 32 - hw, y, rgba(*BLACK))
        px(img, 32 + hw, y, rgba(*BLACK))

    # Top cap
    if 18 in body_rows:
        for x in range(32 - body_rows[18], 32 + body_rows[18] + 1):
            px(img, x, 18, rgba(*BLACK))
    # Bottom cap
    last_y = max(body_rows.keys())
    for x in range(32 - body_rows[last_y], 32 + body_rows[last_y] + 1):
        px(img, x, last_y, rgba(*BLACK))


def draw_eye(img):
    # Eye position: center of body ≈ (32, 41)
    cx, cy = 32, 41

    # Outer glow ring (coral)
    draw_ring(img, cx, cy, 11, 9, rgba(*CORAL_PULSE, a=255))

    # Muted violet glow
    draw_circle(img, cx, cy, 9, rgba(*MUTED_VIOLET, a=210))

    # Bright amber core
    draw_circle(img, cx, cy, 6, rgba(*AMBER_VOICE))
    # Pale highlight
    draw_circle(img, cx, cy, 4, rgba(*WARM_PARCHMENT))
    draw_circle(img, cx, cy, 2, rgba(255, 255, 240))

    # Vertical pupil slit
    fill_rect(img, cx - 1, cy - 3, cx + 1, cy + 3, rgba(*INK_NAVY))


def draw_rage_cracks(img):
    """Cracks radiating from the eye — phase 2 signature."""
    cx, cy = 32, 41

    # Top-left crack
    for i, (dx, dy) in enumerate([(-9, -7), (-10, -8), (-11, -8), (-12, -9)]):
        px(img, cx + dx, cy + dy, rgba(*CORAL_PULSE, a=220 - i * 30))

    # Top-right crack
    for i, (dx, dy) in enumerate([(9, -7), (10, -8), (11, -8), (12, -9)]):
        px(img, cx + dx, cy + dy, rgba(*CORAL_PULSE, a=220 - i * 30))

    # Left crack (horizontal)
    for i, x in enumerate([-13, -14, -15, -16]):
        px(img, cx + x, cy, rgba(*CORAL_PULSE, a=220 - i * 30))

    # Right crack (horizontal)
    for i, x in enumerate([13, 14, 15, 16]):
        px(img, cx + x, cy, rgba(*CORAL_PULSE, a=220 - i * 30))

    # Bottom-left crack
    for i, (dx, dy) in enumerate([(-9, 7), (-10, 8), (-11, 8), (-12, 9)]):
        px(img, cx + dx, cy + dy, rgba(*CORAL_PULSE, a=220 - i * 30))

    # Bottom-right crack
    for i, (dx, dy) in enumerate([(9, 7), (10, 8), (11, 8), (12, 9)]):
        px(img, cx + dx, cy + dy, rgba(*CORAL_PULSE, a=220 - i * 30))

    # Central vertical bright crack (above + below eye)
    for y in range(cy - 16, cy - 11):
        px(img, cx, y, rgba(*CORAL_PULSE, a=160))
    for y in range(cy + 11, cy + 16):
        px(img, cx, y, rgba(*CORAL_PULSE, a=160))

    # Horizontal scar above the eye
    for x in range(cx - 8, cx - 3):
        px(img, x, cy - 8, rgba(*CORAL_PULSE, a=140))
    for x in range(cx + 4, cx + 9):
        px(img, x, cy - 8, rgba(*CORAL_PULSE, a=140))
    # Horizontal scar below the eye
    for x in range(cx - 8, cx - 3):
        px(img, x, cy + 8, rgba(*CORAL_PULSE, a=140))
    for x in range(cx + 4, cx + 9):
        px(img, x, cy + 8, rgba(*CORAL_PULSE, a=140))


def draw_cyan_highlights(img):
    """Brighter glass cyan edge highlights than A030."""
    # Top
    px(img, 32, 19, rgba(*GLASS_CYAN, a=255))
    px(img, 31, 20, rgba(*GLASS_CYAN, a=200))
    px(img, 33, 20, rgba(*GLASS_CYAN, a=200))
    # Bottom of body
    px(img, 32, 62, rgba(*GLASS_CYAN, a=255))
    # Left
    px(img, 12, 41, rgba(*GLASS_CYAN, a=255))
    px(img, 13, 40, rgba(*GLASS_CYAN, a=200))
    px(img, 13, 42, rgba(*GLASS_CYAN, a=200))
    # Right
    px(img, 52, 41, rgba(*GLASS_CYAN, a=255))
    px(img, 51, 40, rgba(*GLASS_CYAN, a=200))
    px(img, 51, 42, rgba(*GLASS_CYAN, a=200))


def draw_side_wisps(img):
    """Two side wisps (left + right) — similar to A030 but slightly longer."""
    # Left wisp
    for y, hw in {30: 2, 31: 3, 32: 3, 33: 3, 34: 2, 35: 2}.items():
        fill_rect(img, 8 - hw, y, 8 + hw, y, rgba(*INK_NAVY))
    px(img, 7, 32, rgba(*CORAL_PULSE, a=220))
    px(img, 6, 33, rgba(*CORAL_PULSE, a=180))
    # outline
    px(img, 5, 33, rgba(*BLACK))
    px(img, 5, 32, rgba(*BLACK))
    px(img, 5, 34, rgba(*BLACK))
    px(img, 4, 33, rgba(*BLACK))

    # Right wisp
    for y, hw in {30: 2, 31: 3, 32: 3, 33: 3, 34: 2, 35: 2}.items():
        fill_rect(img, 56 - hw, y, 56 + hw, y, rgba(*INK_NAVY))
    px(img, 57, 32, rgba(*CORAL_PULSE, a=220))
    px(img, 58, 33, rgba(*CORAL_PULSE, a=180))
    # outline
    px(img, 59, 33, rgba(*BLACK))
    px(img, 59, 32, rgba(*BLACK))
    px(img, 59, 34, rgba(*BLACK))
    px(img, 60, 33, rgba(*BLACK))


def draw_extra_spikes(img):
    """Two extra spikes (bottom-left + bottom-right) — phase 2 signature."""
    # Left spike (extends down-left from body bottom)
    left_spike = [
        (16, 60, 18, 60),
        (14, 61, 20, 61),
        (12, 62, 18, 62),
        (10, 63, 16, 63),
        (8, 64, 14, 64),
        (6, 65, 12, 65),
        (4, 66, 10, 66),
    ]
    for x0, y0, x1, y1 in left_spike:
        fill_rect(img, x0, y0, x1, y1, rgba(*INK_NAVY))
    # outline
    for i, (x0, y0, x1, y1) in enumerate(left_spike):
        for x in range(x0, x1 + 1):
            px(img, x, y0, rgba(*BLACK))
        for y in range(y0, y1 + 1):
            px(img, x0, y, rgba(*BLACK))
    # coral tip
    px(img, 6, 65, rgba(*CORAL_PULSE, a=220))
    px(img, 7, 65, rgba(*CORAL_PULSE, a=180))

    # Right spike (mirror)
    right_spike = [
        (46, 60, 48, 60),
        (44, 61, 50, 61),
        (46, 62, 52, 62),
        (48, 63, 54, 63),
        (50, 64, 56, 64),
        (52, 65, 58, 65),
        (54, 66, 60, 66),
    ]
    for x0, y0, x1, y1 in right_spike:
        fill_rect(img, x0, y0, x1, y1, rgba(*INK_NAVY))
    # outline
    for i, (x0, y0, x1, y1) in enumerate(right_spike):
        for x in range(x0, x1 + 1):
            px(img, x, y0, rgba(*BLACK))
        for y in range(y0, y1 + 1):
            px(img, x1, y, rgba(*BLACK))
    # coral tip
    px(img, 57, 65, rgba(*CORAL_PULSE, a=220))
    px(img, 56, 65, rgba(*CORAL_PULSE, a=180))


def draw_bottom_tentacle(img):
    """Long central bottom tentacle — longer than A030 (extends to row 88)."""
    rows = [
        (64, 4, 4),   # (y, hw_at_top, hw_at_bottom) — we approximate as single hw
        (65, 5, 5),
        (66, 6, 6),
        (67, 6, 6),
        (68, 7, 7),
        (69, 7, 7),
        (70, 6, 6),
        (71, 6, 6),
        (72, 5, 5),
        (73, 5, 5),
        (74, 4, 4),
        (75, 4, 4),
        (76, 3, 3),
        (77, 3, 3),
        (78, 2, 2),
        (79, 2, 2),
        (80, 2, 2),
    ]
    for y, hw, _ in rows:
        fill_rect(img, 32 - hw, y, 32 + hw, y, rgba(*INK_NAVY))
    # outline left/right
    for y, hw, _ in rows:
        px(img, 32 - hw, y, rgba(*BLACK))
        px(img, 32 + hw, y, rgba(*BLACK))
    # coral vein
    for y, _, _ in rows:
        if y % 2 == 0:
            px(img, 32, y, rgba(*CORAL_PULSE, a=200))
        else:
            px(img, 31, y, rgba(*CORAL_PULSE, a=160))
            px(img, 33, y, rgba(*CORAL_PULSE, a=160))
    # tip
    px(img, 32, 81, rgba(*CORAL_PULSE, a=255))
    px(img, 32, 82, rgba(*CORAL_PULSE, a=200))
    # taper last rows
    px(img, 32, 83, rgba(*INK_NAVY))
    px(img, 32, 84, rgba(*INK_NAVY))
    px(img, 32, 85, rgba(*INK_NAVY))
    px(img, 32, 86, rgba(*CORAL_PULSE, a=140))
    px(img, 32, 87, rgba(*CORAL_PULSE, a=80))


def draw_red_tint(img):
    """Subtle red wash over dark body pixels only."""
    # Apply only to INK_NAVY-ish dark body pixels (not outline, not bright accents)
    for y in range(H):
        for x in range(W):
            p = img.getpixel((x, y))
            if p[3] < 30:
                continue
            r, g, b = p[0], p[1], p[2]
            # Skip outline (pure black or near)
            if r < 25 and g < 25 and b < 35:
                continue
            # Skip bright accents
            if r > 200 and g > 150:  # amber / parchment
                continue
            if g > 150 and b > 150:  # cyan
                continue
            if r > 200 and g < 130 and b < 110:  # coral
                continue
            # Skip muted violet (we want violet to stay violet)
            if 60 < r < 130 and 60 < g < 100 and 80 < b < 130:
                continue
            # Dark body — apply subtle red wash (a few %)
            nr = min(255, r + 18)
            ng = max(0, g - 4)
            nb = max(0, b - 4)
            img.putpixel((x, y), (nr, ng, nb, p[3]))


def main():
    img = make_canvas()
    draw_body_blob(img)
    draw_side_wisps(img)
    draw_extra_spikes(img)
    draw_bottom_tentacle(img)
    draw_eye(img)
    draw_rage_cracks(img)
    draw_cyan_highlights(img)
    draw_red_tint(img)

    out = "/workspace/assets/enemies/ink_warden/ink_warden_phase2.png"
    img.save(out)
    print(f"saved {out}  size={img.size}  mode={img.mode}")

    colors = img.getcolors(maxcolors=100000)
    if colors:
        top = sorted(colors, reverse=True)[:18]
        print("top colors:")
        for c, col in top:
            print(f"  {c:6d} {col}")


if __name__ == "__main__":
    main()
