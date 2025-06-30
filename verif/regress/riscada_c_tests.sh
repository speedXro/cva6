#!/bin/bash

# where are the tools
if ! [ -n "$RISCV" ]; then
  echo "Error: RISCV variable undefined"
  return
fi

if ! [ -n "$DV_SIMULATORS" ]; then
  DV_SIMULATORS=vcs-testharness,spike
fi

# install the required tools
if [[ "$DV_SIMULATORS" == *"veri-testharness"* ]]; then
  source ./verif/regress/install-verilator.sh
fi
source ./verif/regress/install-spike.sh

# install the required test suites
#source ./verif/regress/install-riscv-tests.sh

# setup sim env
source ./verif/sim/setup-env.sh

echo "$SPIKE_INSTALL_DIR$"

if ! [ -n "$DV_TARGET" ]; then
  DV_TARGET=cv64a6_imafdc_sv39
fi

if ! [ -n "$UVM_VERBOSITY" ]; then
  export UVM_VERBOSITY=UVM_NONE
fi

export DV_OPTS="$DV_OPTS --issrun_opts=+debug_disable=1+UVM_VERBOSITY=$UVM_VERBOSITY"

cd verif/sim/

errors=0

python3 cva6.py --target ${DV_TARGET} --iss=$DV_SIMULATORS --iss_yaml=cva6.yaml --c_tests ../tests/custom/riscada/riscada_tests.c \
  --gcc_opts="-static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -g ../tests/custom/riscada/ADA_functions.c ../tests/custom/common/syscalls.c ../tests/custom/common/crt.S -I../tests/custom/env -I../tests/custom/common -T ../../config/gen_from_riscv_config/linker/link.ld" $DV_OPTS
[[ $? > 0 ]] && ((errors++))

make -C ../.. clean
make clean_all

[[ $errors > 0 ]] && exit 1 ;
exit 0 ;