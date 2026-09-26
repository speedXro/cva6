source ../cva6_utils/cva6_setvars.sh

export BOARD=kcu116

cd corev_apu/fpga/

vivado -mode batch -nolog -nojournal \
       -source scripts/program_flash_kcu116.tcl \
       -tclargs work-fpga/ariane_xilinx.mcs work-fpga/ariane_xilinx.bit

cd ../../
