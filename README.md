# spec-to-gds

An autonomous Claude Code agent that takes a digital-logic spec — a plain-English sentence, or RTL you've already written — all the way to a verified GDSII layout: synthesis, formal equivalence checking, floorplan/place/CTS/route, and GDS merge. Runs unattended, natively, on macOS (arm64), using a from-source build of [OpenROAD](https://github.com/The-OpenROAD-Project/OpenROAD) — no Docker, no emulation.

## No human in the loop

The entire input, both times this has been run, was one sentence typed into a terminal:

```sh
spec-to-gds counter8 "8-bit up-counter, asynchronous active-low reset, synchronous enable"
spec-to-gds counter4sync "4-bit synchronous binary up-counter: clk, synchronous active-high reset (rst), synchronous enable (en) - counter increments on rising clk edge only when en=1 and rst=0, resets to 0 synchronously on the clk edge when rst=1, holds value when en=0. count[3:0] registered output."
```

Everything after that ran unsupervised, in a single [Claude Fable 5](https://www.anthropic.com/) process launched with `--dangerously-skip-permissions`: writing the RTL, writing its own testbench, simulating it, synthesizing it, formally proving the netlist matches the RTL, driving OpenROAD through floorplan/place/CTS/route, merging the routed design into GDS, and re-simulating the *final routed* netlist to prove physical implementation didn't break anything. No human touched a tool in between, and no human fixed anything when a stage went sideways — the agent hit real problems on both runs (a testbench race, a Liberty blackbox issue on the equivalence check, KLayout hanging headless) and diagnosed and resolved each one itself before continuing.

The two runs also aren't the same design copy-pasted twice. `counter8` has an *asynchronous* reset; `counter4sync` has a *synchronous* one. The agent noticed the difference on its own — it synthesized `counter8` to async-reset `DFFR_X1` flops and `counter4sync` to plain `DFF_X1` flops with reset folded into the D-input logic, and it wrote a testbench for `counter4sync` that specifically proves the sync-reset *timing* (asserting reset mid-cycle and checking the counter does **not** clear until the next clock edge) — a distinction nobody told it to test for. That's the bar this repo is trying to hold itself to: not "the tool ran," but "the agent understood the spec."

## How this came to be

This started as an attempt to reproduce [Moonshot AI's Kimi K3 demo](https://www.kimi.com/blog/kimi-k3) — a 48-hour autonomous agent run that took a chip from RTL to GDS using open-source EDA tools. The first approach followed OpenROAD's own documented pattern for this: their `claude.sh` Docker wrapper. It worked, technically — right up until it became clear that OpenROAD's official Docker image is **amd64-only**. On Apple Silicon that meant QEMU-emulating not just the EDA tools inside the container but Claude Code's own binary. A one-line test prompt burned 20+ minutes of continuous CPU before the process had even opened a network connection to make its first API call.

So the project pivoted: build OpenROAD natively for arm64 via Bazel instead of fighting emulation. That surfaced its own chain of real problems — uninitialized git submodules, missing `pandoc`/`groff` host dependencies for a docs target that wasn't even needed, and a subtly nasty one where Bazel's persistent background server had cached the shell `PATH` from *before* a dependency was installed, so newly-installed tools stayed invisible until the server was explicitly restarted. Once the native binary worked, the whole flow — RTL through GDS — got wrapped into a single reusable agent definition (`agent/spec-to-gds.md`) plus a one-line launcher (`bin/spec-to-gds`), so the next design wouldn't require re-deriving any of it.

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

## Examples

Two complete runs, same PDK (Nangate45), same verification bar, different reset semantics:

| Metric | [`counter8`](examples/counter8/) | [`counter4sync`](examples/counter4sync/) |
|---|---|---|
| Spec | 8-bit up-counter, **async** active-low reset, sync enable | 4-bit up-counter, **sync** active-high reset, sync enable |
| Die area | 45.03 × 44.8 µm = 0.002 mm² | 45.03 × 44.8 µm = 0.002 mm² |
| Flop cells used | `DFFR_X1` (async-reset flop) | `DFF_X1` (plain flop, sync reset folded into logic) |
| Standard cells | 33 functional (328 incl. tap/fill) | 18 functional (286 incl. endcap/fill) |
| Timing closure | 1.67 GHz, setup WNS +0.230 ns, hold +0.001 ns → Fmax ≈ 2.7 GHz | 2 GHz, setup WNS +0.238 ns, hold +0.066 ns → Fmax ≈ 3.8 GHz |
| DRC / router DRVs / antenna violations | 0 / 0 / 0 | 0 / 0 / 0 |
| Power | 0.417 mW @ 1.67 GHz | 0.192 mW @ 2 GHz |
| Wall clock | ~17 min (mostly first-time Homebrew installs) | ~4 min (toolchain already warm) |

Verification on both wasn't just "the tool exited zero": RTL testbench passed → Yosys **SAT-proved formal equivalence** between RTL and the synthesized netlist → gate-level simulation of the *final routed* netlist (including CTS/hold-fix buffers) passed the same testbench → GDS geometry independently DRC-checked, 0 violations.

For reference — same PDK as Moonshot's [Kimi K3 chip-design demo](https://www.kimi.com/blog/kimi-k3): their 4 mm² / 100 MHz / 1.46M cells / 0.277 MB SRAM vs. these designs' 0.002 mm² / dozens of cells — roughly 2000× smaller die, as expected for a counter vs. a full chip with embedded memory. Not a like-for-like speed claim.

See [`examples/counter8/rtl2gds-reference.html`](examples/counter8/rtl2gds-reference.html) for the full stage-by-stage walkthrough, complete command reference, output-file guide, and troubleshooting log (git submodule issues, Bazel's stale-PATH server caching, KLayout's Gatekeeper block, etc.) — open it in a browser.

## Repo structure

```
agent/spec-to-gds.md         # subagent definition: toolchain, flow order, known gotchas
bin/spec-to-gds              # launcher: fires an unattended Fable 5 process per spec
examples/
  counter8/                    # async-reset 8-bit counter, complete run RTL through GDS
  counter4sync/                # sync-reset 4-bit counter, complete run RTL through GDS
    <design>.v                   RTL
    <design>_tb.v                 testbench
    synth.ys, equiv_check.ys     Yosys scripts
    <design>_run.tcl             OpenROAD flow driver
    <design>_final.{def,v,odb}  routed outputs
    results/                     per-stage OpenROAD checkpoints, parasitics, DRC report
    <design>.gds                  final layout
    <design>_layout.png           rendered snapshot
    progress.md                    the agent's own running log
```
