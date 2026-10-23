"""Schematic: track polarity times motor type sets direction (science/microtubule_motors_and_lipid_transport.typ).

Plain geometry, no data. Writes science/figures/direction_rule.png.
Run from anywhere: python direction_rule_fig.py
"""

import pathlib

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch

OUT = pathlib.Path(__file__).resolve().parents[3] / "science" / "figures" / "direction_rule.png"
GREY, KIN, DYN, RET = "0.45", "#1f6fb2", "#b5562b", "#7a4ea3"
plt.rcParams.update({"font.size": 9, "font.family": "Helvetica"})


def microtubule(ax, x0, x1, y, plus_right=True):
    ax.plot([x0, x1], [y, y], color=GREY, lw=2.2, solid_capstyle="butt")
    lo, hi = ("−", "+") if plus_right else ("+", "−")
    ax.text(x0 - 0.12, y, lo, ha="right", va="center", color=GREY)
    ax.text(x1 + 0.12, y, hi, ha="left", va="center", color=GREY)


def cargo(ax, x, y, dx, colour, label, below=False):
    ax.add_patch(plt.Circle((x, y), 0.17, color=colour, zorder=3))
    ax.add_patch(FancyArrowPatch((x + 0.25 * (1 if dx > 0 else -1), y), (x + dx, y),
                                 arrowstyle="-|>", mutation_scale=11, color=colour, lw=1.4))
    ax.text(x, y - 0.3 if below else y + 0.3, label, ha="center",
            va="top" if below else "bottom", color=colour)


def frame(ax, letter, name):
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 3)
    ax.axis("off")
    ax.text(0.0, 2.95, letter, weight="bold", va="top")
    ax.text(0.3, 2.95, name, va="top")


fig, axes = plt.subplots(3, 1, figsize=(6.2, 5.4))
fig.set_layout_engine("constrained")

# a: uniform array, plus ends towards the tip
ax = axes[0]
frame(ax, "a", "uniform array: an axon, or the zone behind a hyphal tip")
for x0, x1, y in [(1.0, 5.5, 1.55), (3.0, 8.5, 1.15), (1.6, 7.0, 0.75)]:
    microtubule(ax, x0, x1, y)
cargo(ax, 4.0, 1.98, 1.4, KIN, "kinesin")
cargo(ax, 6.0, 0.45, -1.4, DYN, "dynein", below=True)
ax.text(0.3, 0.1, "root side", color=GREY)
ax.text(9.7, 0.1, "tip", ha="right", color=GREY)

# b: mixed array, one motor type moves both ways
ax = axes[1]
frame(ax, "b", "mixed array: a dendrite, or the middle of a long hypha")
for x0, x1, y, pr in [(1.0, 5.0, 1.75, True), (5.4, 9.0, 1.35, False),
                      (2.0, 6.5, 0.95, False), (4.0, 8.5, 0.55, True)]:
    microtubule(ax, x0, x1, y, pr)
cargo(ax, 2.6, 2.07, 1.4, KIN, "kinesin")
cargo(ax, 7.6, 1.67, -1.4, KIN, "kinesin")
ax.text(0.3, 0.1, "root side", color=GREY)
ax.text(9.7, 0.1, "tip", ha="right", color=GREY)

# c: the transport paper's picture of one hypha
ax = axes[2]
frame(ax, "c", "two streams in one hypha (working hypothesis)")
ax.add_patch(FancyBboxPatch((0.6, 0.45), 8.6, 1.7, boxstyle="round,pad=0,rounding_size=0.85",
                            fc="none", ec="0.3", lw=1.2))
for y in (1.9, 0.7):
    microtubule(ax, 1.3, 7.6, y)
    for x in (2.2, 4.4, 6.6):
        ax.add_patch(FancyArrowPatch((x - 0.6, y + (0.15 if y > 1 else -0.15)),
                                     (x + 0.6, y + (0.15 if y > 1 else -0.15)),
                                     arrowstyle="-|>", mutation_scale=10, color=KIN, lw=1.4))
for x in (6.6, 4.4, 2.2):
    ax.add_patch(FancyArrowPatch((x + 0.7, 1.3), (x - 0.7, 1.3),
                                 arrowstyle="-|>", mutation_scale=12, color=RET, lw=2.0))
ax.text(4.4, 2.35, "motor-borne stream to the tip, on the tracks", ha="center", color=KIN)
ax.text(4.4, 0.05, "pressure-driven return to the root, in the core", ha="center", color=RET)
ax.text(9.7, 1.3, "tip", ha="right", va="center", color=GREY)

OUT.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(OUT, dpi=150)
print(OUT)
