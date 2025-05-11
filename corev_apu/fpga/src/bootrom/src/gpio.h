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

void init_gpio();
void write_gpio(uintptr_t addr, uint8_t value);
uint8_t read_gpio(uintptr_t addr);


