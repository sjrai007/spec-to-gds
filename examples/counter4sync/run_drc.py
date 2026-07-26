#!/usr/bin/env python3
"""Base min-width / min-spacing DRC on the merged GDS (rules from Nangate45_tech.lef,
minimum-width row of each layer's spacing table). Same approach as the counter8 run."""
import klayout.db as db

ly = db.Layout()
ly.read("counter4sync.gds")
top = ly.top_cell()
dbu = ly.dbu

# layer name -> (gds layer, min width um, min spacing um)
rules = {
    "metal1":  (11, 0.07, 0.065),
    "metal2":  (13, 0.07, 0.07),
    "metal3":  (15, 0.07, 0.07),
    "metal4":  (17, 0.14, 0.14),
    "metal5":  (19, 0.14, 0.14),
    "metal6":  (21, 0.14, 0.14),
    "metal7":  (23, 0.40, 0.40),
    "metal8":  (25, 0.40, 0.40),
    "metal9":  (27, 0.80, 0.80),
    "metal10": (29, 0.80, 0.80),
}

total = 0
for name, (gl, w, s) in rules.items():
    li = ly.find_layer(gl, 0)
    if li is None:
        print(f"{name:8s} (gds {gl}/0): not present, skipped")
        continue
    reg = db.Region(top.begin_shapes_rec(li))
    reg.merge()
    wv = reg.width_check(int(round(w / dbu))).count()
    sv = reg.space_check(int(round(s / dbu))).count()
    total += wv + sv
    print(f"{name:8s} (gds {gl}/0): {reg.count()} polys, "
          f"width<{w} viol={wv}, space<{s} viol={sv}")

print(f"TOTAL DRC VIOLATIONS: {total}")
raise SystemExit(1 if total else 0)
