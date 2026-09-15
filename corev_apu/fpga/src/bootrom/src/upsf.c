#include "upsf.h"
#include "uart.h"
#include <stdarg.h>
#include <stddef.h>

/* =========================================================================
 * Internal print helpers
 * ========================================================================= */

void print_char(uint8_t c)
{
    /* Translate bare LF -> CR+LF for standard terminal behaviour */
    if (c == (uint8_t)'\n') {
        write_serial((uint8_t)'\r');
    }
    write_serial(c);
}

/*
 * Render an unsigned 64-bit value into buf[] in the requested base (10 or 16).
 * Returns the number of characters written (NOT NUL-terminated).
 * buf must be at least 20 bytes for decimal, 16 for hex.
 */
uint32_t fmt_uint64_to_buf(uint64_t v, uint8_t base, uint8_t uppercase,
                                   char *buf, uint32_t buf_size)
{
    static const char lower[] = "0123456789abcdef";
    static const char upper[] = "0123456789ABCDEF";
    const char *digits = uppercase ? upper : lower;

    if (v == 0u) {
        buf[0] = '0';
        return 1u;
    }

    /* Build digits in reverse */
    uint32_t len = 0u;
    while (v > 0u && len < buf_size) {
        buf[len++] = digits[v % (uint64_t)base];
        v /= (uint64_t)base;
    }

    /* Reverse in place */
    for (uint32_t lo = 0u, hi = len - 1u; lo < hi; lo++, hi--) {
        char tmp  = buf[lo];
        buf[lo]   = buf[hi];
        buf[hi]   = tmp;
    }

    return len;
}

/*
 * Emit `buf[0..len-1]` to UART, preceded by enough pad_char characters
 * to reach `width` total output characters.
 * Returns the total number of characters written.
 */
uint32_t print_padded(const char *buf, uint32_t len,
                              uint32_t width, char pad_char)
{
    uint32_t written = 0u;

    /* Leading pad */
    while ((written + len) < width) {
        write_serial((uint8_t)pad_char);
        written++;
    }

    /* Value */
    for (uint32_t i = 0u; i < len; i++) {
        write_serial((uint8_t)buf[i]);
        written++;
    }

    return written;
}

/* =========================================================================
 * Internal scanf helpers
 * ========================================================================= */

uint8_t uart_getchar_blocking(void)
{
    uint8_t c;
    while (read_serial(&c) == 0u) {
        /* busy-wait */
    }
    return c;
}

/*
 * Read a whitespace-delimited word from UART with echo.
 * Stops on space / '\n' / '\r'.
 * max includes the NUL terminator.
 */
void uart_read_word(char *buf, uint32_t max)
{
    uint32_t i = 0u;

    for (;;) {
        uint8_t raw = uart_getchar_blocking();
        char    c   = (char)raw;

        if (c == ' ' || c == '\n' || c == '\r') {
            write_serial(raw); /* echo delimiter */
            break;
        }

        write_serial(raw); /* echo character */

        if (i < (max - 1u)) {
            buf[i++] = c;
        }
        /* Buffer full: keep consuming/echoing until delimiter */
    }

    buf[i] = '\0';
}

int32_t read_int32_helper(void)
{
    char tmp[16];
    uart_read_word(tmp, sizeof(tmp));

    int32_t  sign = 1;
    uint32_t i    = 0u;

    if (tmp[0] == '-') {
        sign = -1;
        i    = 1u;
    }

    int32_t v = 0;
    for (; tmp[i] != '\0'; i++) {
        char c = tmp[i];
        if (c < '0' || c > '9') { break; }
        v = v * 10 + (int32_t)(c - '0');
    }

    return sign * v;
}

uint32_t read_uint32_helper(void)
{
    char tmp[16];
    uart_read_word(tmp, sizeof(tmp));

    uint32_t v = 0u;
    for (uint32_t i = 0u; tmp[i] != '\0'; i++) {
        char c = tmp[i];
        if (c < '0' || c > '9') { break; }
        v = v * 10u + (uint32_t)(c - '0');
    }

    return v;
}

uint64_t read_uint64_helper(void)
{
    char tmp[32];
    uart_read_word(tmp, sizeof(tmp));

    uint64_t v = 0u;
    for (uint32_t i = 0u; tmp[i] != '\0'; i++) {
        char c = tmp[i];
        if (c < '0' || c > '9') { break; }
        v = v * 10u + (uint64_t)(c - '0');
    }

    return v;
}

uint32_t read_hex32_helper(void)
{
    char tmp[16];
    uart_read_word(tmp, sizeof(tmp));

    uint32_t v = 0u;
    uint32_t i = 0u;

    /* Skip optional 0x / 0X prefix */
    if (tmp[0] == '0' && (tmp[1] == 'x' || tmp[1] == 'X')) {
        i = 2u;
    }

    for (; tmp[i] != '\0'; i++) {
        char c = tmp[i];
        v <<= 4;
        if      (c >= '0' && c <= '9') { v |= (uint32_t)(c - '0');       }
        else if (c >= 'A' && c <= 'F') { v |= (uint32_t)(c - 'A' + 10u); }
        else if (c >= 'a' && c <= 'f') { v |= (uint32_t)(c - 'a' + 10u); }
        else                           { break;                            }
    }

    return v;
}

uint64_t read_hex64_helper(void)
{
    char tmp[32];
    uart_read_word(tmp, sizeof(tmp));

    uint64_t v = 0u;
    uint32_t i = 0u;

    /* Skip optional 0x / 0X prefix */
    if (tmp[0] == '0' && (tmp[1] == 'x' || tmp[1] == 'X')) {
        i = 2u;
    }

    for (; tmp[i] != '\0'; i++) {
        char c = tmp[i];
        v <<= 4;
        if      (c >= '0' && c <= '9') { v |= (uint64_t)(c - '0');       }
        else if (c >= 'A' && c <= 'F') { v |= (uint64_t)(c - 'A' + 10u); }
        else if (c >= 'a' && c <= 'f') { v |= (uint64_t)(c - 'a' + 10u); }
        else                           { break;                            }
    }

    return v;
}

/* =========================================================================
 * Public API
 * ========================================================================= */

/*
 * printf – supported format syntax:
 *
 *   %[0][width][l]specifier
 *
 *   Flag:
 *     0          zero-pad to <width> (default: space-pad)
 *
 *   Width:
 *     1-64       minimum field width
 *
 *   Length modifier:
 *     l          treat integer as 64-bit (valid for d, u, x, X)
 *
 *   Specifiers:
 *     c          char
 *     s          NUL-terminated string  (width applies; zero-flag treated as space)
 *     d          signed decimal   (int32_t / int64_t with l)
 *     u          unsigned decimal (uint32_t / uint64_t with l)
 *     x          unsigned hex, lowercase (uint32_t / uint64_t with l)
 *     X          unsigned hex, uppercase (uint32_t / uint64_t with l)
 *     p          pointer – always 64-bit zero-padded hex (16 digits)
 *     %          literal '%'
 *
 *   Examples:
 *     %08x    ->  8-digit zero-padded lowercase hex
 *     %016lx  ->  16-digit zero-padded lowercase hex (64-bit)
 *     %5d     ->  space-padded signed decimal, min width 5
 *     %05d    ->  zero-padded signed decimal, min width 5  ("00042")
 *     %-5d is NOT supported (no left-justify flag)
 *
 * Returns the number of characters transmitted to the UART.
 * '\n' is automatically expanded to '\r\n'.
 */
int32_t printf(const char *fmt, ...)
{
    va_list  args;
    va_start(args, fmt);
    int32_t written = 0;

    while (*fmt != '\0') {

        /* ---- plain character ---- */
        if (*fmt != '%') {
            print_char((uint8_t)*fmt++);
            written++;
            continue;
        }

        fmt++; /* skip '%' */

        /* ---- parse '0' flag ---- */
        char pad_char = ' ';
        if (*fmt == '0') {
            pad_char = '0';
            fmt++;
        }

        /* ---- parse width (decimal digits, no leading zero here) ---- */
        uint32_t width = 0u;
        while (*fmt >= '1' && *fmt <= '9') {
            width = width * 10u + (uint32_t)(*fmt - '0');
            fmt++;
        }
        if (width > 64u) { width = 64u; } /* sanity cap */

        /* ---- parse 'l' length modifier ---- */
        uint8_t is_long = 0u;
        if (*fmt == 'l') {
            is_long = 1u;
            fmt++;
        }

        /* ---- dispatch on specifier ---- */
        switch (*fmt) {

        /* -- %c -- */
        case 'c': {
            int32_t c = va_arg(args, int32_t);
            /* Pad with spaces (zero-flag meaningless for single char) */
            if (width > 1u) {
                for (uint32_t p = 1u; p < width; p++) {
                    write_serial((uint8_t)' ');
                    written++;
                }
            }
            print_char((uint8_t)c);
            written++;
        } break;

        /* -- %s -- */
        case 's': {
            const char *s = va_arg(args, const char *);
            if (s == NULL) { s = "(null)"; }

            /* Measure string length for padding */
            uint32_t    slen = 0u;
            const char *p    = s;
            while (*p++) { slen++; }

            /* Space-pad on the left (zero-flag not meaningful for strings) */
            if (slen < width) {
                for (uint32_t p2 = slen; p2 < width; p2++) {
                    write_serial((uint8_t)' ');
                    written++;
                }
            }
            while (*s) {
                print_char((uint8_t)*s++);
                written++;
            }
        } break;

        /* -- %d / %ld -- */
        case 'd': {
            /*
             * Zero-padding with sign: emit '-' first, then zeros, then digits.
             * Space-padding with sign: treat sign as part of value width.
             *
             *   %05d  with -42  ->  "-0042"
             *   %5d   with -42  ->  "  -42"
             */
            char     digits[20];
            uint32_t dlen;
            uint8_t  negative = 0u;

            if (is_long) {
                int64_t v = va_arg(args, int64_t);
                if (v < 0) { negative = 1u; dlen = fmt_uint64_to_buf(~(uint64_t)v + 1u, 10u, 0u, digits, sizeof(digits)); }
                else       {                dlen = fmt_uint64_to_buf((uint64_t)v,        10u, 0u, digits, sizeof(digits)); }
            } else {
                int32_t v = va_arg(args, int32_t);
                if (v < 0) { negative = 1u; dlen = fmt_uint64_to_buf((uint64_t)(~(uint32_t)v + 1u), 10u, 0u, digits, sizeof(digits)); }
                else       {                dlen = fmt_uint64_to_buf((uint64_t)(uint32_t)v,           10u, 0u, digits, sizeof(digits)); }
            }

            uint32_t value_width = dlen + (negative ? 1u : 0u);

            if (pad_char == '0' && negative) {
                /* Sign before zeros: "-00042" */
                write_serial((uint8_t)'-');
                written++;
                uint32_t zeros = (width > value_width) ? (width - value_width) : 0u;
                for (uint32_t z = 0u; z < zeros; z++) {
                    write_serial((uint8_t)'0');
                    written++;
                }
                for (uint32_t d = 0u; d < dlen; d++) {
                    write_serial((uint8_t)digits[d]);
                    written++;
                }
            } else {
                /* Space-pad or positive zero-pad: build full string then pad */
                char full[22];
                uint32_t fi = 0u;
                if (negative) { full[fi++] = '-'; }
                for (uint32_t d = 0u; d < dlen; d++) { full[fi++] = digits[d]; }
                written += (int32_t)print_padded(full, fi, width, pad_char);
            }
        } break;

        /* -- %u / %lu -- */
        case 'u': {
            char     buf[20];
            uint64_t uv;

            if (is_long) { uv = va_arg(args, uint64_t); }
            else         { uv = (uint64_t)va_arg(args, uint32_t); }

            uint32_t len = fmt_uint64_to_buf(uv, 10u, 0u, buf, sizeof(buf));
            written += (int32_t)print_padded(buf, len, width, pad_char);
        } break;

        /* -- %x / %X / %lx / %lX -- */
        case 'x':
        case 'X': {
            char     buf[16];
            uint64_t uv;
            uint8_t  uc = (*fmt == 'X') ? 1u : 0u;

            if (is_long) { uv = va_arg(args, uint64_t); }
            else         { uv = (uint64_t)va_arg(args, uint32_t); }

            uint32_t len = fmt_uint64_to_buf(uv, 16u, uc, buf, sizeof(buf));
            written += (int32_t)print_padded(buf, len, width, pad_char);
        } break;

        /* -- %p -- */
        case 'p': {
            /* Pointers: always 16-digit zero-padded lowercase hex on RV64 */
            char     buf[16];
            uint64_t uv  = (uint64_t)(uintptr_t)va_arg(args, void *);
            uint32_t len = fmt_uint64_to_buf(uv, 16u, 0u, buf, sizeof(buf));
            written += (int32_t)print_padded(buf, len, 16u, '0');
        } break;

        /* -- %% -- */
        case '%':
            print_char((uint8_t)'%');
            written++;
            break;

        default:
            print_char((uint8_t)'?');
            written++;
            break;
        }

        fmt++;
    }

    va_end(args);
    return written;
}

/*
 * scanf – supported specifiers:
 *   %c          char *       (single character, echoed)
 *   %s          char *       (word up to 127 chars + NUL, echoed)
 *   %d          int32_t *    (signed decimal)
 *   %u          uint32_t *   (unsigned decimal)
 *   %lu         uint64_t *   (unsigned decimal, 'l' modifier)
 *   %x / %X     uint32_t *   (hex, optional 0x prefix)
 *   %lx / %lX   uint64_t *   (hex, optional 0x prefix, 'l' modifier)
 *
 * Returns the number of items successfully assigned.
 */
int32_t scanf(const char *fmt, ...)
{
    va_list  args;
    va_start(args, fmt);
    int32_t count = 0;

    while (*fmt != '\0') {
        if (*fmt != '%') {
            fmt++;
            continue;
        }

        fmt++; /* skip '%' */

        /* Parse optional 'l' length modifier */
        uint8_t is_long = 0u;
        if (*fmt == 'l') {
            is_long = 1u;
            fmt++;
        }

        switch (*fmt) {
        case 'c': {
            char *c = va_arg(args, char *);
            *c = (char)uart_getchar_blocking();
            write_serial((uint8_t)*c); /* echo */
            count++;
        } break;

        case 's': {
            char *s = va_arg(args, char *);
            /* 128 bytes max (127 chars + NUL); caller must supply at least that */
            uart_read_word(s, 128u);
            count++;
        } break;

        case 'd': {
            /* 'l' modifier ignored for %d – only 32-bit signed supported */
            int32_t *v = va_arg(args, int32_t *);
            *v = read_int32_helper();
            count++;
        } break;

        case 'u': {
            if (is_long) {
                uint64_t *v = va_arg(args, uint64_t *);
                *v = read_uint64_helper();
            } else {
                uint32_t *v = va_arg(args, uint32_t *);
                *v = read_uint32_helper();
            }
            count++;
        } break;

        case 'x':
        case 'X': {
            if (is_long) {
                uint64_t *v = va_arg(args, uint64_t *);
                *v = read_hex64_helper();
            } else {
                uint32_t *v = va_arg(args, uint32_t *);
                *v = read_hex32_helper();
            }
            count++;
        } break;

        default:
            /* Unsupported specifier – consume and continue */
            break;
        }

        fmt++;
    }

    va_end(args);
    return count;
}