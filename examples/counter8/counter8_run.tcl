# counter8 Nangate45 flow driver — run with cwd = OpenROAD/test so the
# helper scripts and Nangate45/ kit resolve via relative paths.
source "helpers.tcl"
source "flow_helpers.tcl"
source "Nangate45/Nangate45.vars"

set design "counter8"
set top_module "counter8"
set synth_verilog "/Users/you/Documents/WARD/counter8_rtl2gds/counter8_synth.v"
set sdc_file "/Users/you/Documents/WARD/counter8_rtl2gds/counter8.sdc"
# Die sized so at least one metal4 (56um pitch) and one metal7 (40um pitch)
# PDN strap lands in the core. Site FreePDK45_38x28_10R_NP_162NW_34O = 0.19 x 1.4 um.
set die_area {0 0 45.03 44.8}
set core_area {5.13 5.6 39.9 39.2}

source "flow.tcl"

# Extra outputs for GDS merge, in the working directory
set out_dir "/Users/you/Documents/WARD/counter8_rtl2gds"
write_def $out_dir/counter8_final.def
write_verilog $out_dir/counter8_final.v
write_db $out_dir/counter8_final.odb
puts "FLOW_COMPLETE"
