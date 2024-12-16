#!/bin/bash

# Path to Gowin binaries (adjust as needed)
GOWIN_BIN="/data/software/gowin/IDE/bin"

echo "Synthesizing HDL and generating Bitstream.."

# FIX for Ubuntu 24.04 - for some reason i get an error when trying to run any of the IDE tools..
# ERROR: gw_ide: symbol lookup error: /lib/x86_64-linux-gnu/libfontconfig.so.1: undefined symbol: FT_Done_MM_Var
# I had to fix it by exporting libfreetype.so as per below..
export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libfreetype.so

# Current PAth and FPGA project
FPGA_PROJECT_NAME="fpga_project_blinky"
CURRENT_DIR=$(pwd)

# Define the project and Tcl script paths
PROJECT_PATH="$CURRENT_DIR/$FPGA_PROJECT_NAME/$FPGA_PROJECT_NAME.gprj"
TCL_SCRIPT_PATH="$CURRENT_DIR/run_fpga_project.tcl"

# Create the Tcl script dynamically
cat > "$TCL_SCRIPT_PATH" <<EOL
# Open the project
open_project $PROJECT_PATH

# Run all steps (synthesis, place-and-route, bitstream generation)
run all
EOL

# Run the Tcl script using the Gowin shell
"$GOWIN_BIN/gw_sh" "$TCL_SCRIPT_PATH"

# Check the result of the execution
if [ $? -eq 0 ]; then
    echo "Bitstream generation successful!"
    rm $TCL_SCRIPT_PATH
else
    echo "An error occurred during the FPGA project build process."
    rm $TCL_SCRIPT_PATH
    exit -1
fi