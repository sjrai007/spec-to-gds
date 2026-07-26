# counter8 RTL-to-GDS progress log

Design: 8-bit up-counter (async active-low reset, sync enable), target Nangate45 (FreePDK45).
Date: 2026-07-26. Total wall-clock for the whole exercise: well under an hour; the OpenROAD
PnR flow itself ran in ~15 seconds.

## Toolchain
- Synthesis: Yosys 0.67 (Homebrew)
- Simulation: Icarus Verilog 13.0 (Homebrew)
- PnR: OpenROAD (native build, `/Users/you/Documents/WARD/OpenROAD/bazel-bin/openroad`)
- GDS merge + DRC + rendering: KLayout via the `klayout` PyPI module (in `.venv/`)
- PDK: **Nangate45** kit shipped with the OpenROAD repo (`test/Nangate45/`): tech+stdcell LEF,
  typ Liberty, tracks/PDN/RC configs. Flow driver modeled on OpenROAD's own reference
  `test/flow.tcl` (the gcd_nangate45 regression flow). Standard-cell GDS
  (`NangateOpenCellLibrary.gds`), `def2stream.py`, and KLayout tech file `FreePDK45.lyt`
  fetched from OpenROAD-flow-scripts (single files via raw GitHub, no full clone).

## Stage log

### 1. RTL + verification — DONE
- `counter8.v`: async-reset DFF bank with enable-gated increment.
- `counter8_tb.v`: self-checking TB — reset hold, enable gating, increment, hold,
  255→0 wraparound, mid-cycle async reset assert/release. Result: **ALL TESTS PASSED**.
- Note: first TB run had a race (reset released exactly on a clock edge); fixed the TB
  (release mid-phase). RTL itself was correct.

### 2. Synthesis (Yosys → Nangate45) — DONE
- `synth.ys`: synth -flatten → dfflibmap → abc -D 600 → opt_clean. Netlist: `counter8_synth.v`.
- **24 cells, 63.6 µm²** cell area: 8× DFFR_X1 (async-reset flop, direct match for the
  RTL's $_DFF_PN0_), 5× XNOR2_X1, 2× XOR2_X1, 2× NAND2_X1, 2× NAND3_X1, 1 each
  NAND4/NOR2/MUX2/INV/AND4.
- Gotcha: `check -assert` initially reported count[7:0] undriven — cosmetic; yosys didn't know
  liberty cell pin directions. Fixed by `read_liberty -lib` before reading the netlist.
- **Formal equivalence RTL ⇄ netlist proven** (`equiv_check.ys`, SAT-based, 8/8 $equiv cells
  proven). Gotchas: needed `-ignore_miss_func` (CLKGATE cells have no function), `async2sync`
  on both sides (async FFs have no direct SAT model), and `setattr ... =*` to unbox the
  liberty whitebox modules so `flatten` inlines them (plain selections exclude boxed modules).

### 3. Floorplan → Place → CTS → Route (OpenROAD) — DONE
- Driver: `counter8_run.tcl` (sources OpenROAD `test/flow.tcl`), run with cwd = OpenROAD/test,
  `RESULTS_DIR=./results`. Full log: `openroad_flow.log`. Single pass, no iterations needed.
- Constraint: `counter8.sdc` — clk period **0.6 ns (1.67 GHz)**, 20 %-period I/O delays.
- Floorplan: die **45.03 × 44.8 µm**, core 5.13,5.6 → 39.9,39.2; sized so ≥1 metal4 (56 µm
  pitch) and ≥1 metal7 (40 µm pitch) PDN strap land in-core. Utilization 7 %.
- Stages: tapcell (48), PDN (m1 followpins + m4/m7 straps), global place, IO place, resize/
  buffer repair, CTS (3× BUF_X4, skew 0.002 ns), hold fix (post-CTS hold −0.062 → +0.001 ns),
  detailed place, global route, antenna check (0 violations), detailed route
  (**0 DRC violations from router**), fill (247 FILLCELLs), OpenRCX extraction → SPEF.
- **Final timing (post-route, extracted parasitics): setup WNS +0.230 ns, hold WNS +0.001 ns,
  TNS 0 — timing closed.** Critical path ≈ 0.37 ns ⇒ Fmax ≈ 2.7 GHz.
- Power @1.67 GHz: 0.417 mW (52 % sequential, 31 % clock, 17 % comb). Wirelength: 997 µm.
- Cells after PnR: **33 functional** (24 logic + 6 BUF_X1 timing repair + 3 BUF_X4 clock tree);
  328 placed instances incl. tap/fill. Design area 87 µm².
- Outputs: `counter8_final.def/.v/.odb`, checkpoints in `results/`.

### 4. GDS merge + checks (KLayout) — DONE
- Blocker: the KLayout **macOS app hangs headless** (even `klayout -zz -v`; not fixed by
  removing quarantine). Workaround: `pip install klayout` in `.venv` and drive ORFS
  `def2stream.py`'s `merge_gds()` via `run_gds_merge.py` with `klayout.db` — no GUI needed.
- `FreePDK45.lyt` edited to point its `<lef-files>` at the OpenROAD test-dir LEFs (ORFS
  normally rewrites this path at build time).
- Merge: DEF + NangateOpenCellLibrary.gds → **`counter8.gds`** (102 KB). 0 errors, all LEF
  cells matched GDS cells, no orphan cells. Top-cell bbox verified 45.03 × 44.8 µm.
- DRC (KLayout Region checks, base min-width/min-spacing rules from Nangate45_tech.lef,
  metal1–metal10): **0 violations**.
- Gate-level sim of `counter8_final.v` (incl. CTS/hold buffers) against the original TB using
  liberty-derived cell models (`nangate45_sim_models.v`): **ALL TESTS PASSED**.
- Layout render: `counter8_layout.png`.

## Final metrics
| Metric | Value |
|---|---|
| Die area | 45.03 × 44.8 µm = 2017 µm² (0.002 mm²) |
| Std-cell area / utilization | 87 µm² / 7 % |
| Instances | 33 functional (8 flops) + 48 tap + 247 fill = 328 |
| Clock | 0.6 ns target; setup WNS +0.230 ns ⇒ Fmax ≈ 2.7 GHz |
| Hold / TNS / skew | +0.001 ns / 0 / 0.002 ns |
| Route DRVs / antenna / GDS DRC | 0 / 0 / 0 |
| Power @ 1.67 GHz | 0.417 mW |
| Wirelength | 997 µm |

## Kimi K3 demo comparison (theirs: 4 mm², 100 MHz, 1.46 M cells, 0.277 MB SRAM)
Same PDK (Nangate45), wildly different scale, as expected:
- Area: 0.002 mm² vs 4 mm² → ~2000× smaller die.
- Cells: 33 vs 1.46 M → ~44 000× fewer.
- SRAM: none vs 0.277 MB.
- Clock: closes at 1.67 GHz with 0.23 ns to spare (Fmax ≈ 2.7 GHz) vs 100 MHz — a tiny
  counter has a ~0.4 ns critical path, so this is not a like-for-like speed claim.
