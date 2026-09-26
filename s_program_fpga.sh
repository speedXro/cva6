#!/bin/bash

source ../cva6_utils/cva6_setvars.sh

export BOARD=kcu116

cd corev_apu/fpga/

vivado -mode batch -source scripts/program.tcl

cd ../../