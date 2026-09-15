// Copyright OpenHW Group contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#pragma once

#include <stdint.h>

#define DBG_UART_BASE 0x50000000

#define DBG_UART_RBR DBG_UART_BASE + 0
#define DBG_UART_THR DBG_UART_BASE + 0
#define DBG_UART_INTERRUPT_ENABLE DBG_UART_BASE + 4
#define DBG_UART_INTERRUPT_IDENT DBG_UART_BASE + 8
#define DBG_UART_FIFO_CONTROL DBG_UART_BASE + 8
#define DBG_UART_LINE_CONTROL DBG_UART_BASE + 12
#define DBG_UART_MODEM_CONTROL DBG_UART_BASE + 16
#define DBG_UART_LINE_STATUS DBG_UART_BASE + 20
#define DBG_UART_MODEM_STATUS DBG_UART_BASE + 24
#define DBG_UART_DLAB_LSB DBG_UART_BASE + 0
#define DBG_UART_DLAB_MSB DBG_UART_BASE + 4

void dbg_init_uart();

int dbg_read_serial(uint8_t *res);

void dbg_print_uart(const char* str);

void dbg_print_uart_int(uint32_t addr);

void dbg_print_uart_addr(uint64_t addr);

void dbg_print_uart_byte(uint8_t byte);
