// Copyright OpenHW Group contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "dbg_uart.h"

void dbg_write_reg_u8(uintptr_t addr, uint8_t value)
{
    volatile uint8_t *loc_addr = (volatile uint8_t *)addr;
    *loc_addr = value;
}

uint8_t dbg_read_reg_u8(uintptr_t addr)
{
    return *(volatile uint8_t *)addr;
}

int dbg_is_transmit_empty()
{
    return dbg_read_reg_u8(DBG_UART_LINE_STATUS) & 0x20;
}

char dbg_is_transmit_empty_altera()
{
    return ((dbg_read_reg_u8(DBG_UART_THR+7) << 8 ) + dbg_read_reg_u8(DBG_UART_THR+6));
}

int dbg_is_receive_empty()
{
    #ifndef PLAT_AGILEX
        return !(dbg_read_reg_u8(DBG_UART_LINE_STATUS) & 0x1);
    #else
        return (dbg_read_reg_u8(DBG_UART_THR) == 0);
    #endif
}

void dbg_write_serial(char a)
{
    #ifndef PLAT_AGILEX
        while (dbg_is_transmit_empty() == 0) {};
    #else
        while (is_transmit_empty_altera() < 8) {};
    #endif
    dbg_write_reg_u8(DBG_UART_THR, a);
}

int dbg_read_serial(uint8_t *res)
{
    if(dbg_is_receive_empty()) {
        return 0;
    }

    *res = dbg_read_reg_u8(DBG_UART_RBR);
    return 1;
}

void dbg_init_uart(uint32_t freq, uint32_t baud)
{
    uint32_t divisor = freq / (baud << 4);

    dbg_write_reg_u8(DBG_UART_INTERRUPT_ENABLE , 0x00); // Disable all interrupts
    dbg_write_reg_u8(DBG_UART_LINE_CONTROL, 0x80);     // Enable DLAB (set baud rate divisor)
    dbg_write_reg_u8(DBG_UART_DLAB_LSB, divisor);         // divisor (lo byte)
    dbg_write_reg_u8(DBG_UART_DLAB_MSB, (divisor >> 8) & 0xFF);  // divisor (hi byte)
    dbg_write_reg_u8(DBG_UART_LINE_CONTROL, 0x03);     // 8 bits, no parity, one stop bit
    dbg_write_reg_u8(DBG_UART_FIFO_CONTROL, 0xC7);     // Enable FIFO, clear them, with 14-byte threshold
    dbg_write_reg_u8(DBG_UART_MODEM_CONTROL, 0x20);    // Autoflow mode
}

void dbg_print_uart(const char *str)
{
    const char *cur = &str[0];
    while (*cur != '\0')
    {
        dbg_write_serial((uint8_t)*cur);
        ++cur;
    }
}

uint8_t dbg_bin_to_hex_table[16] = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

void dbg_bin_to_hex(uint8_t inp, uint8_t res[2])
{
    res[1] = dbg_bin_to_hex_table[inp & 0xf];
    res[0] = dbg_bin_to_hex_table[(inp >> 4) & 0xf];
    return;
}

void dbg_print_uart_int(uint32_t addr)
{
    int i;
    for (i = 3; i > -1; i--)
    {
        uint8_t cur = (addr >> (i * 8)) & 0xff;
        uint8_t hex[2];
        dbg_bin_to_hex(cur, hex);
        dbg_write_serial(hex[0]);
        dbg_write_serial(hex[1]);
    }
}

void dbg_print_uart_addr(uint64_t addr)
{
    int i;
    for (i = 7; i > -1; i--)
    {
        uint8_t cur = (addr >> (i * 8)) & 0xff;
        uint8_t hex[2];
        dbg_bin_to_hex(cur, hex);
        dbg_write_serial(hex[0]);
        dbg_write_serial(hex[1]);
    }
}

void dbg_print_uart_byte(uint8_t byte)
{
    uint8_t hex[2];
    dbg_bin_to_hex(byte, hex);
    dbg_write_serial(hex[0]);
    dbg_write_serial(hex[1]);
}
