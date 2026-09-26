#!/bin/bash

source ../cva6_utils/cva6_setvars.sh

export BOARD=kcu116

cd corev_apu/fpga/src/bootrom/

make clean

make bootrom_64.elf 

make clean

cd ../../../../