# spec-to-gds

An autonomous Claude Code agent that takes a digital-logic spec — RTL you've already written, or just a natural-language description — all the way to a verified GDSII layout: synthesis, formal equivalence checking, floorplan/place/CTS/route, and GDS merge. Runs unattended, natively, on macOS (arm64), using a from-source build of [OpenROAD](https://github.com/The-OpenROAD-Project/OpenROAD) — no Docker, no emulation.

It's driven by Claude Code running [Claude Fable 5](https://www.anthropic.com/), unattended against a fixed toolchain: [Yosys](https://github.com/YosysHQ/yosys) for synthesis, [Icarus Verilog](http://iverilog.icarus.com/) for simulation, the native `openroad` binary for physical design, and [KLayout](https://www.klayout.de/) for the final GDS merge/DRC.

## Why this exists

OpenROAD's official Docker image is amd64-only, which means running it on Apple Silicon means QEMU-emulating not just the EDA tools but Claude Code's own binary — brutally slow (a one-line test prompt took 20+ minutes of continuous CPU before it even opened a network connection). This project instead builds OpenROAD natively via Bazel and runs everything, including the agent itself, unemulated.

## Usage

```sh
bin/spec-to-gds <design_name> <spec description...>

# example:
bin/spec-to-gds shiftreg8 "8-bit shift register, serial-in parallel-out, sync active-high reset, shift-enable input"
```

This launches an unattended Fable 5 process into a fresh `<design_name>_rtl2gds/` directory, following the flow encoded in [`agent/spec-to-gds.md`](agent/spec-to-gds.md) — RTL authoring, pre-synthesis simulation, synthesis, formal equivalence proof, OpenROAD place-and-route, KLayout GDS merge, and post-layout gate-level re-verification.

**Prerequisites**, all specific to the machine this was built on:
- A native OpenROAD binary built via Bazel (`bazelisk build //:openroad`) — see `agent/spec-to-gds.md` for the exact toolchain notes and gotchas hit getting this working on Apple Silicon.
- Homebrew: `yosys`, `icarus-verilog`.
- The `klayout` Python package in a project-local venv — the macOS KLayout **app** hangs when driven headlessly, so the agent uses the pip module instead.
- The Nangate45 PDK, as shipped inside the OpenROAD repo's `test/Nangate45/`.

The paths inside `agent/spec-to-gds.md` and `bin/spec-to-gds` are absolute and specific to the original machine (`/Users/you/Documents/WARD/...`) — adjust them if reusing this elsewhere.

## Example: counter8

[`examples/counter8/`](examples/counter8/) is a complete run: an 8-bit up-counter (async active-low reset, sync enable) taken from a blank Verilog file to a DRC-clean GDS layout in about 17 minutes of wall clock (most of it Homebrew installs — the actual OpenROAD place-and-route took ~15 seconds).

| Metric | Result |
|---|---|
| Die area | 45.03 × 44.8 µm = 0.002 mm² |
| Standard cells | 33 functional (328 incl. tap/fill) |
| Timing closure | 1.67 GHz clock, setup WNS +0.230 ns, hold +0.001 ns, TNS 0 → Fmax ≈ 2.7 GHz |
| DRC / router DRVs / antenna violations | 0 / 0 / 0 |
| Power | 0.417 mW @ 1.67 GHz |

Verification wasn't just "the tool exited zero": RTL testbench passed → Yosys **SAT-proved formal equivalence** between RTL and the synthesized netlist → gate-level simulation of the *final routed* netlist (including CTS/hold-fix buffers) passed the same testbench → GDS geometry independently DRC-checked, 0 violations.

Same PDK (Nangate45) as Moonshot's [Kimi K3 chip-design demo](https://www.kimi.com/blog/kimi-k3), for reference: their 4 mm² / 100 MHz / 1.46M cells / 0.277 MB SRAM vs. this design's 0.002 mm² / 33 cells — ~2000× smaller die, as expected for an 8-bit counter vs. a full chip with embedded memory. Not a like-for-like speed claim.

See [`examples/counter8/rtl2gds-reference.html`](examples/counter8/rtl2gds-reference.html) for the full stage-by-stage walkthrough, complete command reference, output-file guide, and troubleshooting log (git submodule issues, Bazel's stale-PATH server caching, KLayout's Gatekeeper block, etc.) — open it in a browser.

## Repo structure

```
agent/spec-to-gds.md       # subagent definition: toolchain, flow order, known gotchas
bin/spec-to-gds            # launcher: fires an unattended Fable 5 process per spec
examples/counter8/         # a complete example run, RTL through GDS
  counter8.v                 RTL
  counter8_tb.v               testbench
  synth.ys, equiv_check.ys   Yosys scripts
  counter8_run.tcl           OpenROAD flow driver
  counter8_final.{def,v,odb} routed outputs
  results/                   per-stage OpenROAD checkpoints, parasitics, DRC report
  counter8.gds                final layout
  counter8_layout.png         rendered snapshot
  progress.md                  the agent's own running log
  rtl2gds-reference.html      full write-up
```
