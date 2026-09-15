`define ROUTER 1

`define STATUS_FATAL_BUFFER 1
`define STATUS_FATAL_FIRST_FREE_BUFFER 2
`define STATUS_FATAL_WRITE_BUFFER_DEMUX 3
`define STATUS_FATAL_INPUT_WIRING 4
`define STATUS_FATAL_FIRST_FULL_BUFFER 5
`define STATUS_FATAL_READ_BUFFER_MUX 6
`define STATUS_FATAL_OUTPUT_WIRING 7
`define STATUS_FATAL_INPUT_BUFFERS 8
`define STATUS_FATAL_OUTPUT_BUFFERS 9
`define STATUS_FATAL_ROUTER 10
`define STATUS_FATAL_RVEXP_CONTROLLER 11
`define STATUS_FATAL_PE 12
`define STATUS_FATAL_PES 13
`define STATUS_FATAL_RVEXP 14
`define STATUS_FATAL_RVEXP_U 15
`define STATUS_FATAL_RVEXP_AXIS4 16


package utils_pkg;

    function automatic int max2 (input int a, input int b);
        return (a > b) ? a : b;
    endfunction

endpackage : utils_pkg
