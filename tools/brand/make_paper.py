"""Crumpled deep-teal paper for the Dermatriage poster hero.

Procedural, no external source. A crumpled sheet is defined by its creases:
sharp ridges and valleys that run across the paper and taper out at their ends.
This draws several hundred tapered crease segments (a few long folds, many short
wrinkles, biased toward a handful of fold directions the way a hand-crumpled
sheet is), over a gentle large-scale bend and faint facets, then lights the
height field from the upper left and maps it between two teals from the brand
palette. Fixed seed, so the output is reproducible.
Usage: python3 make_paper.py <out.jpg> <preview.jpg>
"""
import sys
import numpy as np
from PIL import Image
from scipy.ndimage import gaussian_filter
from scipy.spatial import cKDTree

out, preview = sys.argv[1], sys.argv[2]
rng = np.random.default_rng(7)
W, H = 1920, 1200
yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
h = np.zeros((H, W), np.float32)

# Gentle bend of the whole sheet
h += 9 * np.sin(xx / 520 + 0.4) * np.cos(yy / 430 + 1.1) + 5 * np.sin((xx + yy) / 300)

# Faint facets so flat areas between creases are not perfectly smooth
seeds = np.c_[rng.uniform(-60, W + 60, 260), rng.uniform(-60, H + 60, 260)]
d, _ = cKDTree(seeds).query(np.stack([xx.ravel(), yy.ravel()], 1), k=1, workers=-1)
h += 0.03 * d.reshape(H, W)

# Creases: a few dominant fold directions plus scatter
dominant = rng.uniform(0, np.pi, 4)


def crease(cx, cy, ang, length, reach, slope):
    """A fold: the sheet bends along the crease line, so the two sides tilt
    differently near it and flatten out further away (lit side and shade side)."""
    ux, uy = np.cos(ang), np.sin(ang)
    half = length / 2
    pad = reach * 7 + 4
    x0 = int(max(0, min(cx - half * abs(ux), cx + half * abs(ux)) - pad))
    x1 = int(min(W, max(cx - half * abs(ux), cx + half * abs(ux)) + pad))
    y0 = int(max(0, min(cy - half * abs(uy), cy + half * abs(uy)) - pad))
    y1 = int(min(H, max(cy - half * abs(uy), cy + half * abs(uy)) + pad))
    if x1 <= x0 or y1 <= y0:
        return
    X = xx[y0:y1, x0:x1] - cx
    Y = yy[y0:y1, x0:x1] - cy
    along = X * ux + Y * uy
    across = -X * uy + Y * ux
    t = np.clip((along + half) / length, 0, 1)
    taper = np.sin(np.pi * t) ** 0.7 * ((along > -half) & (along < half))
    # Sharp crease at the line, sides tilting away, then easing back to flat,
    # so the fold leaves no edge where its computation box ends.
    a = np.abs(across)
    profile = a * np.exp(-a / reach)
    h[y0:y1, x0:x1] += slope * profile * taper


for i in range(260):
    long_fold = i < 18
    ang = (rng.choice(dominant) + rng.normal(0, 0.35)) if rng.random() < 0.6 else rng.uniform(0, np.pi)
    length = rng.uniform(800, 1900) if long_fold else float(np.clip(rng.lognormal(5.6, 0.5), 80, 1000))
    reach = rng.uniform(120, 300) if long_fold else rng.uniform(25, 110)
    slope = (rng.uniform(0.45, 0.85) if long_fold else rng.uniform(0.2, 0.55)) * rng.choice([-1, 1])
    crease(rng.uniform(0, W), rng.uniform(0, H), ang, length, reach, slope)

h = gaussian_filter(h, 0.7)
gy, gx = np.gradient(h)
inv = 1 / np.sqrt(gx ** 2 + gy ** 2 + 1)
L = np.array([-0.45, -0.7, 0.55])
L /= np.linalg.norm(L)
lam = (-gx * L[0] - gy * L[1] + L[2]) * inv
lam = (lam - np.median(lam)) / (lam.std() + 1e-6)
vign = 1 - 0.14 * ((np.linspace(-1, 1, W)[None, :]) ** 2 + (np.linspace(-1, 1, H)[:, None]) ** 2)
t = (np.clip(0.5 + 0.12 * np.tanh(lam * 0.8), 0, 1) * vign)[..., None]
dark = np.array([0x00, 0x36, 0x30], np.float32)
light = np.array([0x16, 0x7E, 0x79], np.float32)
img = dark * (1 - t) + light * t + rng.normal(0, 1.4, (H, W, 3))
im = Image.fromarray(np.clip(img, 0, 255).astype(np.uint8))
im.save(out, quality=80, optimize=True, progressive=True)
im.resize((960, 600)).save(preview, quality=85)
