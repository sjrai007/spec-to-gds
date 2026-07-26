#!/usr/bin/env python3
"""Run def2stream.merge_gds via the pip klayout module (no GUI needed)."""
import sys
import klayout.db as pya_mod
import def2stream

base = "/Users/you/Documents/WARD/counter8_rtl2gds"
errors = def2stream.merge_gds(
    pya_mod=pya_mod,
    tech_file=f"{base}/FreePDK45.lyt",
    layer_map="",
    in_def=f"{base}/counter8_final.def",
    design_name="counter8",
    in_files=f"{base}/NangateOpenCellLibrary.gds",
    seal_file="",
    out_file=f"{base}/counter8.gds",
)
print(f"merge_gds finished with {errors} error(s)")
sys.exit(1 if errors else 0)
