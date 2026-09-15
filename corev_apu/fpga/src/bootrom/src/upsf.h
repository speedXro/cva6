#ifndef UPSF_H_
#define UPSF_H_

#include <stdint.h>

//helpers for printf
uint32_t fmt_uint64_to_buf(uint64_t v, uint8_t base, uint8_t uppercase, char *buf, uint32_t buf_size);
uint32_t print_padded(const char *buf, uint32_t len, uint32_t width, char pad_char);
uint8_t uart_getchar_blocking(void);

void print_char(uint8_t c);
void print_string(const char *s);
uint32_t print_uint32(uint32_t v);
uint32_t print_uint64(uint64_t v);
uint32_t print_int32(int32_t v);
uint32_t print_int64(int64_t v);
uint32_t print_hex_u32(uint32_t v);
uint32_t print_hex_u64(uint64_t v);

//helpers for scanf
void uart_read_word(char *buf, uint32_t max);
uint8_t uart_getchar_blocking(void);
void uart_read_word(char *buf, uint32_t max);
int32_t read_int32_helper(void);
uint32_t read_uint32_helper(void);
uint64_t read_uint64_helper(void);
uint64_t read_hex64_helper(void);

//printf and scanf
int32_t printf(const char *fmt, ...);
int32_t scanf(const char *fmt, ...);
//scamf

#endif