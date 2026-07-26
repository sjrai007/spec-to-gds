# counter4sync RTL-to-GDS progress log

Design: 4-bit synchronous binary up-counter — clk, **synchronous** active-high reset (rst),
synchronous enable (en). Increments on posedge clk when en=1 && rst=0; resets to 0 on the
clk edge when rst=1 (reset has priority over en); holds when en=0. `count[3:0]` registered.
Target: Nangate45 (FreePDK45) via OpenROAD. Date: 2026-07-26. Run: autonomous/unattended.

## Toolchain
- Synthesis: Yosys 0.67 (Homebrew)
- Simulation: Icarus Verilog 13.0 (Homebrew)
- PnR: OpenROAD native build (`OpenROAD/bazel-bin/openroad`), driver modeled on `test/flow.tcl`
- GDS merge/DRC/render: KLayout PyPI module (project `.venv`), ORFS `def2stream.py`
- PDK: Nangate45 kit in `OpenROAD/test/Nangate45/`; std-cell GDS / `def2stream.py` /
  `FreePDK45.lyt` reused from the prior counter8 run (originally fetched from ORFS).

## Stage log

### 1. RTL + pre-synthesis simulation — DONE
- `counter4sync.v`: single always @(posedge clk); rst (sync, priority) then en-gated increment.
- `counter4sync_tb.v` self-checking coverage: reset-from-unknown, **sync-reset timing proof**
  (rst asserted mid-cycle does NOT clear count until the next posedge), rst priority over en,
  0→5 increment, hold under en=0, count to 15, 15→0 wraparound, 1-cycle reset pulse mid-count.
- Result: **ALL TESTS PASSED** (iverilog/vvp, first run).

### 2. Synthesis (Yosys → Nangate45) — DONE
- `synth.ys`: synth -flatten → dfflibmap → abc -D 500 → opt_clean → check -assert (0 problems).
- Netlist `counter4sync_synth.v`: **15 cells, 30.06 µm²** — 4× DFF_X1 (plain DFFs: correct,
  the reset is synchronous so it folds into the D-input logic), 3× NOR2, 2× NOR3, 1 each
  AND3/AND4/AOI211/AOI21/INV/XNOR2.

### 3. Formal equivalence RTL ⇄ netlist — DONE
- `equiv_check.ys` (SAT): **Equivalence successfully proven**, 4/4 $equiv cells proven
  (equiv_simple closed all 4; induction had nothing left). Same liberty-whitebox-unboxing
  and -ignore_miss_func handling as the counter8 run.

### 4. OpenROAD floorplan/place/CTS/route — DONE
- Driver `counter4sync_run.tcl` sources OpenROAD `test/flow.tcl`; run cwd = OpenROAD/test,
  RESULTS_DIR=./results (project). Full log: `openroad_flow.log`. Single pass, exit 0.
- Constraint: `counter4sync.sdc` — clk period **0.5 ns (2 GHz)**, 20%-period I/O delays.
- Floorplan: die **45.03 × 44.8 µm**, core 5.13,5.6 → 39.9,39.2 (same proven PDN geometry
  as counter8: ≥1 metal4 + ≥1 metal7 strap in-core). Utilization 4%.
- Stages: 48 endcaps, PDN, global+detailed place, CTS (**3× BUF_X4**, setup skew −0.000 ns),
  resizer: no setup violations, no hold violations → **0 repair buffers needed**, global route
  (461 µm, max layer congestion 1.79%), antenna check **0 net / 0 pin violations**, detailed
  route (**empty DRC report = 0 violations**, 24 routed nets in DEF), 220 FILLCELLs,
  OpenRCX → SPEF, final STA on extracted parasitics.
- **Post-route timing: setup WNS +0.238 ns, hold WNS +0.066 ns, TNS 0, skew −0.000 ns —
  CLOSED.** Critical path 0.260 ns (DFF→AND4→XNOR2→NOR2→DFF) ⇒ **Fmax ≈ 3.8 GHz**.
- Power @ 2 GHz: **0.192 mW** (68% clock, 29% sequential, 3% comb). 
- Instances: **18 functional** (15 logic + 3 clock buffers) + 48 endcaps + 220 fill = 286.
  Design area 48 µm².
- Outputs: `counter4sync_final.def/.v/.odb`, checkpoints in `results/`.

### 5. GDS merge + DRC — DONE
- KLayout PyPI module in project `.venv` (macOS app hangs headless — known issue), driving
  ORFS `def2stream.py::merge_gds()` via `run_gds_merge.py`. Support files
  (`NangateOpenCellLibrary.gds`, `def2stream.py`, pre-patched `FreePDK45.lyt`) reused from
  the counter8 run.
- Merge: DEF + std-cell GDS → **`counter4sync.gds`** (85 KB), **0 errors**, all LEF cells
  matched GDS cells, no orphan cells. Top-cell bbox verified **45.03 × 44.80 µm**.
- DRC (`run_drc.py`, KLayout Region min-width/min-spacing per Nangate45_tech.lef,
  metal1–metal10; metal8–10 unused): **0 violations**. metal7 shows exactly 1 poly —
  the in-core PDN strap, as intended.

### 6. Post-layout gate-level sim + render — DONE
- `nangate45_sim_models.v` extended with liberty-derived models for the 5 cells new to this
  netlist (AND3_X1, AOI21_X1, AOI211_X1, NOR3_X1, plain DFF_X1).
- Gate-level sim of the **final routed** netlist `counter4sync_final.v` (incl. the 3 CTS
  buffers) against the original RTL testbench: **ALL TESTS PASSED**.
- Layout render: `counter4sync_layout.png` (klayout.lay headless).

## Final metrics
| Metric | Value |
|---|---|
| Die area | 45.03 × 44.80 µm = 2017 µm² (0.002 mm²) |
| Std-cell area / utilization | 48 µm² / 4 % |
| Instances | 18 functional (4 flops, 15 logic cells + 3 CTS BUF_X4) + 48 endcaps + 220 fill = 286 |
| Clock | 0.5 ns target (2 GHz); setup WNS **+0.238 ns** ⇒ **Fmax ≈ 3.8 GHz** |
| Hold WNS / TNS / setup skew | +0.066 ns / 0 / −0.000 ns |
| Route DRVs / antenna / GDS DRC | **0 / 0 / 0** |
| Power @ 2 GHz | 0.192 mW (68 % clock, 29 % sequential, 3 % comb) |
| Routed wirelength | 461 µm (22 signal nets) |

## Verification chain (all green)
1. RTL sim: ALL TESTS PASSED (incl. explicit sync-reset-timing check)
2. RTL ⇄ synthesized netlist: formally proven equivalent (Yosys SAT, 4/4 $equiv)
3. Post-route STA on extracted parasitics: setup/hold/TNS all met
4. Router DRC report empty, antenna 0/0, GDS min-width/spacing DRC 0
5. Routed netlist re-passes the original testbench (gate-level sim)
