#!/bin/bash

echo "Cleaning FPGA & MCU Intermediate files.."
rm -fr ./mcu_project_blinky/out
rm -fr ./fpga_project_blinky/impl
