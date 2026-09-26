#!/bin/bash

source ../cva6_utils/cva6_setvars.sh

export BOARD=kcu116

cd corev_apu/fpga/

rm -rf .Xil/ ariane.cache/ ariane.hw/ reports/
rm *.mif *.backup.log *.jou *.log

cd src/bootrom/

make clean

cd ../../

cd work-fpga/

rm *.v *.sdf *.vdi *.rpt *.rpx *.dcp *.pb *.bit *.dcp *.hwdef *.ltx *.mcs *.mmi *.prm *.tcl *.

cd ../../../

make fpga
