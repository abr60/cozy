#!/usr/bin/env python3
"""Generate Cozy's light-rain .dur animation for Ly.

No dependencies. Run: python3 generate-rain.py [output.dur] [columns] [rows]

16-color palette indices (Catppuccin Mocha, see /etc/ly/startup.sh):
  0 crust (background), 4 blue, 6 teal, 7 text, 8 dim gray, 12 lavender, 14 sky.

Rain fills the whole TTY with a seamless loop. Each drop's position is a pure
function of the frame index: y(t) = (y0 + laps*t/STEP) mod L, with L dividing
FRAMES. Layers give parallax; a soft quiet zone protects the login box; splashes
are scheduled from the same cycle. Deterministic via SEED.
"""

from __future__ import annotations

import gzip
import json
import math
import random
import sys
from pathlib import Path

# ----------------------------- tunable constants -----------------------------
WIDTH = 240
HEIGHT = 67
FRAMES = 160          # 50 ms/frame -> 8.0 s loop
SEED = 20261121

# Derived in configure() from WIDTH / HEIGHT / FRAMES (no hardcoded L or DROPS):
#   DROPS = max(12, int(WIDTH // 5 * DROP_SCALE))
#   L     = smallest integer >= HEIGHT + 6 with FRAMES % L == 0
#   STEP  = FRAMES // L

DROP_SCALE = 1.0       # density multiplier on the derived DROPS
LAP_JITTER = 1         # small per-lap column jitter (cells)
LAYER_FAR, LAYER_MID, LAYER_NEAR = 0, 1, 2
LAYER_MIX = (0.50, 0.35, 0.15)
LAPS = {LAYER_FAR: 1, LAYER_MID: 2, LAYER_NEAR: 4}  # laps per FRAMES

BOX_W, BOX_H = 44, 13
QUIET_PAD_X, QUIET_PAD_Y = 2, 2
QUIET_FALLOFF = 10
QUIET_MIN_KEEP = 0.05
IMPACT_TOP = False     # True: box splash at QUIET_Y0 (roof / rain shadow)

GUST_BASE = 0.75       # mean visible drop fraction
GUST_AMPLITUDE = 0.25  # threshold 0.50 .. 1.00, centred on the mean
GUST_CYCLES = 2

SPLASH_LIFETIME = 5

# WIND is cosmetic-only: x is fully determined by the per-lap column list xs[],
# so toggling it only changes the head glyph (╲ right / ╱ left); no drift.
WIND = False
WIND_GLYPH = {1: "╲", -1: "╱"}
WIND_SIGN = 1

BG, DIM, TEAL, BLUE, SKY, LAVENDER, TEXT = 0, 8, 6, 4, 14, 12, 7
HEAD_GLYPHS = {
    LAYER_FAR: "·.",
    LAYER_MID: "┆│",
    LAYER_NEAR: "│┃",
}
TAIL_GLYPH = {
    LAYER_FAR: ".",
    LAYER_MID: "┆",
    LAYER_NEAR: "┆",
}
END_GLYPH = "."
# -----------------------------------------------------------------------------

QUIET_X0 = QUIET_X1 = QUIET_Y0 = QUIET_Y1 = 0
DROPS = L = STEP = 0


def configure(width, height):
    global WIDTH, HEIGHT, DROPS, L, STEP, QUIET_X0, QUIET_X1, QUIET_Y0, QUIET_Y1
    WIDTH, HEIGHT = width, height
    DROPS = max(12, int(WIDTH // 5 * DROP_SCALE))
    L = HEIGHT + 6
    while L <= FRAMES and FRAMES % L:
        L += 1
    if L > FRAMES:
        raise ValueError(
            f"HEIGHT {HEIGHT} too large for FRAMES {FRAMES}: "
            f"need L >= {HEIGHT + 6} that divides {FRAMES}"
        )
    STEP = FRAMES // L
    QUIET_X0 = max(0, (WIDTH - BOX_W) // 2 - QUIET_PAD_X)
    QUIET_X1 = min(WIDTH - 1, QUIET_X0 + BOX_W + 2 * QUIET_PAD_X)
    QUIET_Y0 = max(0, (HEIGHT - BOX_H) // 2 - QUIET_PAD_Y)
    QUIET_Y1 = min(HEIGHT - 1, QUIET_Y0 + BOX_H + 2 * QUIET_PAD_Y)


def rows_at(t, layer):
    """Continuous rows travelled by a drop at frame t (pure function of t)."""
    return (LAPS[layer] * t) // STEP


def spawn_frame(drop, lap):
    """Frame the head wraps to row 0 for this lap (ceil; may be negative)."""
    laps = LAPS[drop["layer"]]
    num = STEP * (lap * L - drop["y0"])
    return -((-num) // laps)


def drop_state(drop, t):
    """(x, head, lap): x picks a per-lap stratified column, head wraps mod L."""
    rows = rows_at(t, drop["layer"])
    lap = (drop["y0"] + rows) // L
    x = drop["xs"][lap % drop["laps_per_loop"]]
    head = (drop["y0"] + rows) % L
    return x, head, lap


def gust_at(t):
    return GUST_BASE + GUST_AMPLITUDE * math.sin(2 * math.pi * GUST_CYCLES * t / FRAMES)


def quiet_keep(x, y):
    """Smooth probability that a cell inside/near the box is drawn."""
    dx = max(QUIET_X0 - x, 0, x - QUIET_X1)
    dy = max(QUIET_Y0 - y, 0, y - QUIET_Y1)
    d = math.hypot(dx, dy)
    if d == 0:
        return QUIET_MIN_KEEP
    return QUIET_MIN_KEEP + (1.0 - QUIET_MIN_KEEP) * min(1.0, d / QUIET_FALLOFF)


def drop_visible(drop, t):
    """Gust decided once at this lap's spawn frame: no mid-fall pop in/out."""
    lap = (drop["y0"] + rows_at(t, drop["layer"])) // L
    return drop["h_gust"] <= gust_at(spawn_frame(drop, lap) % FRAMES)


def visible(drop, t, x, y, gust_ok=None):
    """One visibility test shared by drawing and splash scheduling."""
    if gust_ok is None:
        gust_ok = drop_visible(drop, t)
    if not gust_ok:
        return False
    return drop["h_quiet"] < quiet_keep(x, y)


def make_columns(rng, count):
    """Stratified jitter (blue-noise-ish): even spacing, no clumping/stacking."""
    stride = WIDTH / count
    columns, used = [], set()
    for i in range(count):
        for _ in range(8):
            x = int((i + rng.uniform(0.15, 0.85)) * stride) % WIDTH
            if x not in used:
                break
        used.add(x)
        columns.append(x)
    return columns


def make_tags(rng):
    tags = []
    for layer, share in zip((LAYER_FAR, LAYER_MID, LAYER_NEAR), LAYER_MIX):
        tags += [layer] * int(DROPS * share)
    tags += [LAYER_NEAR] * (DROPS - len(tags))
    rng.shuffle(tags)
    return tags


def build_drop(rng, x, layer):
    laps_per_loop = LAPS[layer]
    max_laps = max(LAPS.values())
    # Per-lap columns are the globally stratified base shifted by a fixed
    # stratum per lap, so every lap stays stratified across the full width.
    xs = [
        (x + j * (WIDTH // max_laps) + rng.randint(-LAP_JITTER, LAP_JITTER)) % WIDTH
        for j in range(laps_per_loop)
    ]
    rng.shuffle(xs)

    if layer == LAYER_FAR:
        length = rng.randint(1, 2)
        colors = [DIM] * length
    elif layer == LAYER_MID:
        length = rng.randint(2, 3)
        base = rng.choice([TEAL, BLUE])
        colors = [base] + [DIM] * (length - 1)
    else:
        length = rng.randint(4, 6)
        base = rng.choice([SKY, TEXT])
        colors = [base, base] + [DIM] * (length - 2)
    colors = colors[:length]

    glyphs = [rng.choice(HEAD_GLYPHS[layer])]
    if length >= 2:
        glyphs.append(TAIL_GLYPH[layer])
    glyphs += [END_GLYPH] * (length - len(glyphs))

    return {
        "xs": xs,
        "laps_per_loop": laps_per_loop,
        "y0": rng.randrange(L),
        "layer": layer,
        "length": length,
        "glyphs": glyphs,
        "colors": colors,
        "h_gust": rng.random(),
        "h_quiet": rng.random(),
    }


def box_surface():
    return QUIET_Y0 if IMPACT_TOP else QUIET_Y1


def splash_events(drop):
    """Crossing-based events; includes the t=0 seam crossing."""
    y0, layer = drop["y0"], drop["layer"]
    events = []
    # Seed prev from the last frame so a crossing at the loop seam is not lost.
    prev = y0 + rows_at(FRAMES - 1, layer)

    for t in range(FRAMES):
        # At t=0 use the continuous row at t=FRAMES (same mod L, one lap later).
        r = y0 + (rows_at(FRAMES, layer) if t == 0 else rows_at(t, layer))
        step = r - prev
        if step:
            x, _, _ = drop_state(drop, t)
            surfaces = [(HEIGHT - 1, "floor")]
            if QUIET_X0 <= x <= QUIET_X1:
                surfaces.append((box_surface(), "box"))
            for surface, kind in surfaces:
                if 0 < (surface - prev) % L <= step and visible(drop, t, x, surface - 1):
                    events.append((t, x, surface, kind, layer))
        prev = y0 + rows_at(t, layer)
    return events


def draw_splash(contents, colors, t, event, drop):
    t0, x, y, kind, layer = event
    age = (t - t0) % FRAMES
    if age >= SPLASH_LIFETIME:
        return
    bright = drop["colors"][0]

    def put(px, py, ch, col):
        if 0 <= px < WIDTH and 0 <= py < HEIGHT:
            contents[py][px] = ch
            colors[px][py] = [col, BG]

    if kind == "box":  # smaller, dimmer: only the box edge is hit
        if age == 0:
            put(x, y, ":", DIM)
        elif age == 1:
            put(x - 1, y - 1, "·", DIM)
            put(x + 1, y - 1, "·", DIM)
        elif age == 2:
            put(x - 2, y, "·", DIM)
            put(x + 2, y, "·", DIM)
        return

    if age == 0:
        put(x, y, ":", bright)
        put(x - 1, y - 1, "'", bright)
        put(x + 1, y - 1, "'", bright)
    elif age == 1:
        put(x, y, "·", bright if layer == LAYER_NEAR else DIM)
        put(x - 1, y - 2, "·", DIM)   # side droplets arc up
        put(x + 1, y - 2, "·", DIM)
    elif age == 2:
        put(x - 2, y - 1, "·", DIM)   # and fall back
        put(x + 2, y - 1, "·", DIM)
    elif age == 3:
        put(x - 3, y, "-", DIM)       # ripple starts
        put(x + 3, y, "-", DIM)
    else:
        put(x - 4, y, "_", DIM)       # wide, flat, fading
        put(x + 4, y, "_", DIM)


def main():
    args = sys.argv[1:]
    output = Path(args[0]) if len(args) > 0 else Path(__file__).with_name("rain.dur")
    width = int(args[1]) if len(args) > 1 else WIDTH
    height = int(args[2]) if len(args) > 2 else HEIGHT
    configure(width, height)

    rng = random.Random(SEED)
    drops = [
        build_drop(rng, x, layer)
        for x, layer in zip(make_columns(rng, DROPS), make_tags(rng))
    ]
    events = [(d, ev) for d in drops for ev in splash_events(d)]

    frames = []
    for t in range(FRAMES):
        contents = [[" "] * WIDTH for _ in range(HEIGHT)]
        colors = [[[BG, BG] for _ in range(HEIGHT)] for _ in range(WIDTH)]

        for d in drops:
            gust_ok = drop_visible(d, t)
            if not gust_ok:
                continue
            x, head, _ = drop_state(d, t)
            surface = box_surface() if QUIET_X0 <= x <= QUIET_X1 else HEIGHT - 1
            if head > surface:          # already impacted: clip whole drop
                continue
            for offset in range(d["length"]):
                y = head - offset
                if not 0 <= y <= surface:   # clip head + tail at the surface
                    continue
                if not visible(d, t, x, y, gust_ok):
                    continue
                ch = d["glyphs"][offset]
                if WIND and offset == 0:
                    ch = WIND_GLYPH[WIND_SIGN]
                contents[y][x] = ch
                colors[x][y] = [d["colors"][offset], BG]

        for d, ev in events:
            draw_splash(contents, colors, t, ev, d)

        frames.append(
            {
                "frameNumber": t + 1,
                "delay": 0,
                "contents": ["".join(row) for row in contents],
                "colorMap": colors,
            }
        )

    movie = {
        "formatVersion": 7,
        "colorFormat": "16",
        "preferredFont": "fixed",
        "encoding": "utf-8",
        "name": "Cozy light rain",
        "artist": "Cozy",
        "framerate": 20.0,
        "sizeX": WIDTH,
        "sizeY": HEIGHT,
        "extra": None,
        "frames": frames,
    }
    payload = json.dumps(
        {"DurMovie": movie}, ensure_ascii=False, separators=(",", ":")
    ).encode("utf-8")
    output.write_bytes(gzip.compress(payload, mtime=0))
    print(f"wrote {output} ({FRAMES} frames, {WIDTH}x{HEIGHT})")


if __name__ == "__main__":
    main()
