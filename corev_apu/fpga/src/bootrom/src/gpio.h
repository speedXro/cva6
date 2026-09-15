#pragma once

#include <stdint.h>

#define GPIO_BASE 0x40000000
#define GPIO_DATA GPIO_BASE + 0
#define GPIO_TRI GPIO_BASE + 4
#define GPIO2_DATA GPIO_BASE + 8
#define GPIO2_TRI GPIO_BASE + 12
#define GIER GPIO_BASE + 284
#define IP_IER GPIO_BASE + 296
#define IP_ISR GPIO_BASE + 288

#define DBG_GPIO_BASE  0x50000000
#define DBG_GPIO_DATA  DBG_GPIO_BASE + 0
#define DBG_GPIO_TRI   DBG_GPIO_BASE + 4
#define DBG_GPIO2_DATA DBG_GPIO_BASE + 8
#define DBG_GPIO2_TRI  DBG_GPIO_BASE + 12
#define DBG_GIER       DBG_GPIO_BASE + 284
#define DBG_IP_IER     DBG_GPIO_BASE + 296
#define DBG_IP_ISR     DBG_GPIO_BASE + 288

void init_gpio();
void write_gpio(uintptr_t addr, uint8_t value);
uint8_t read_gpio(uintptr_t addr);

void dbg_init_gpio();
void dbg_write_gpio(uintptr_t addr, uint8_t value);
uint8_t dbg_read_gpio(uintptr_t addr);


