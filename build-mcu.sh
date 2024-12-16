#!/bin/bash

MPU_PROJECT_NAME="mcu_project_blinky"

echo ""
echo "Building ARM Cortex M3 Firmware..."

cd $MPU_PROJECT_NAME
make

# Check the result of the execution
if [ $? -eq 0 ]; then
    echo "C++ Project Build success!"
else
    echo "An error occurred during the C++ project build process."
    exit -1
fi