"""Residual of production graph registration (STHype register_frame_graphs): how far an existing hypha in frame t
lies from the network of a later frame, after registration. Growth is accretive, so every hypha of frame t should
reappear in frame t+k; the nearest distance is registration error + centreline wobble, i.e. what a frame-matching
radius has to tolerate. Points further than FAR from any later edge (pruned / lost hyphae) are counted, not measured.

    python reg_residual.py OUT_CSV PLATE_GRAPH_DIR...      (each dir holds graph_data_registered/)
"""
import json
import sys
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path

import numpy as np
from scipy.spatial import cKDTree

STEP_SRC, STEP_DST, FAR = 20.0, 2.0, 200.0
LAGS = (1, 5, 20)


def lines(f):
    out = []
    for ft in json.load(open(f))["features"]:
        g = ft.get("geometry") or {}
        if g.get("type") == "LineString":
            out.append(np.asarray(g["coordinates"], float)[:, :2])
        elif g.get("type") == "MultiLineString":
            out += [np.asarray(c, float)[:, :2] for c in g["coordinates"]]
    return out


def sample(ls, step):
    pts = []
    for c in ls:
        if len(c) < 2:
            continue
        seg = np.diff(c, axis=0)
        L = np.r_[0, np.cumsum(np.hypot(*seg.T))]
        s = np.arange(0, L[-1] + 1e-9, step)
        pts.append(np.c_[np.interp(s, L, c[:, 0]), np.interp(s, L, c[:, 1])])
    return np.vstack(pts) if pts else np.zeros((0, 2))


def pair(args):
    plate, a, b, lag = args
    src, dst = sample(lines(a), STEP_SRC), sample(lines(b), STEP_DST)
    if not len(src) or not len(dst):
        return None
    d, i = cKDTree(dst).query(src, distance_upper_bound=FAR)
    ok = np.isfinite(d)
    v = dst[i[ok]] - src[ok]
    near = d[ok] < 50
    shift = np.median(v[near], axis=0) if near.sum() > 20 else (np.nan, np.nan)
    q = np.percentile(d[ok], [50, 90, 95, 99, 99.9]) if ok.sum() else [np.nan] * 5
    return dict(plate=plate, src=Path(a).stem, dst=Path(b).stem, lag=lag, n=len(src), lost=float(1 - ok.mean()),
                p50=q[0], p90=q[1], p95=q[2], p99=q[3], p999=q[4], over25=float((d[ok] > 25).mean()),
                over50=float((d[ok] > 50).mean()), shift_x=shift[0], shift_y=shift[1])


def jobs(gdir):
    gdir = Path(gdir)
    R = gdir / "graph_data_registered"
    fr = sorted(R.glob("*.geojson"))
    bad = set(json.load(open(R / "registration_meta.json")).get("bad_frames", [])) if (R / "registration_meta.json").exists() else set()
    keep = [f for k, f in enumerate(fr) if k not in bad]
    if len(keep) < 2:
        print(f"{gdir}: {len(keep)} usable frames, skipped", flush=True)
        return []
    out = []
    for lag in LAGS:
        for k in range(0, len(keep) - lag, max(1, len(keep) // 25)):
            out.append((gdir.name, str(keep[k]), str(keep[k + lag]), lag))
        out.append((gdir.name, str(keep[0]), str(keep[-1]), "ref"))
    return out


def selfcheck():
    c = [np.array([[0, 0], [100, 0]])]
    s = sample(c, 20)
    assert len(s) == 6 and np.allclose(s[-1], [100, 0])
    d, _ = cKDTree(sample([c[0] + [0, 3]], 2)).query(s)
    assert np.allclose(d, 3)
    print("selfcheck ok")


if __name__ == "__main__":
    if sys.argv[1] == "--selfcheck":
        selfcheck()
        sys.exit()
    import pandas as pd
    J = [j for g in sys.argv[2:] for j in jobs(g)]
    print(len(J), "pairs", flush=True)
    with ProcessPoolExecutor(14) as ex:
        R = pd.DataFrame([r for r in ex.map(pair, J) if r])
    R.to_csv(sys.argv[1], index=False)
    pd.set_option("display.width", 200)
    print(R.groupby(["plate", "lag"])[["n", "lost", "p50", "p90", "p95", "p99", "over25", "over50"]].median().round(3).to_string())
    print(R.assign(shift=np.hypot(R.shift_x, R.shift_y)).groupby(["plate", "lag"])["shift"].describe().round(2).to_string())
