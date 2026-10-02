/* ===========================================================================
 * stft_ref.h - bit-exact software reference for the STFT accelerator.
 *
 * Pure C99, integer only, no libm, no dynamic allocation. Reproduces the
 * hardware datapath (windowing, bit-reversed load, radix-2 DIT FFT with
 * per-stage 1/2 round-half-up scaling and saturation) and the three output
 * formats exactly, using the same Q15 coefficient tables as the RTL ROMs
 * (generated into stft_coeffs.h from gen_coeffs.py - one source of truth).
 *
 * Intended use on the final system: run the accelerator and this reference on
 * the SAME 128-sample input, then compare the outputs (see stft_ref_check_*).
 *
 * Note: assumes an arithmetic (sign-propagating) right shift on signed types,
 * which GCC/Clang guarantee on all supported targets (incl. RISC-V/CVA6).
 * ===========================================================================*/
#ifndef STFT_REF_H
#define STFT_REF_H

#include <stdint.h>
#include <stddef.h>
#include "stft_coeffs.h"    /* STFT_N, STFT_LOG2N, STFT_NPIX, tables */

#ifdef __cplusplus
extern "C" {
#endif

/* --- core transform: windowed 128-point FFT, natural-order complex bins ----
 * in       : STFT_N signed 16-bit samples (Q15)
 * wsel     : window select (0 = rect, 1 = hann)
 * out_re/im: STFT_N signed 16-bit bins (1/N-scaled spectrum)                 */
void stft_ref_fft(const int16_t *in, int wsel,
                  int16_t *out_re, int16_t *out_im);

/* --- output-format encoders (match axis_result_streamer.sv) ---------------- */
/* |X|^2 for one bin: sign-extend to 32 bits before squaring (no truncation). */
uint32_t stft_ref_power(int16_t re, int16_t im);
/* 8-bit log pixel from |X|^2 (mirrors logpix() in stft128_pkg.sv).
 * fl: 0 = ~-48 dB, 1 = ~-24 dB, 2 = ~-96 dB, 3 = ~-12 dB.                    */
uint8_t  stft_ref_logpix(uint32_t pwr, int fl);

/* --- convenience wrappers producing a full frame in each out_fmt ----------- */
/* FMT_CPX:    out is STFT_N packed {real<<16 | (imag & 0xffff)} words.       */
void stft_ref_complex(const int16_t *in, int wsel, uint32_t *out /*[STFT_N]*/);
/* FMT_PWR32:  out is STFT_N |X|^2 words.                                     */
void stft_ref_power32(const int16_t *in, int wsel, uint32_t *out /*[STFT_N]*/);
/* FMT_PIX8:   out is STFT_NPIX 8-bit log pixels (bins 0..63).                */
void stft_ref_pixel(const int16_t *in, int wsel, int fl,
                    uint8_t *out /*[STFT_NPIX]*/);

/* --- validation helpers: compare accelerator output vs reference -----------
 * Recompute the reference from `in` and compare to `hw`. Return the number of
 * mismatching elements (0 = accelerator matches the reference exactly).
 * If `first` != NULL, it receives the index of the first mismatch (or -1).   */
int stft_ref_check_complex(const int16_t *in, int wsel,
                           const uint32_t *hw /*[STFT_N]*/, int *first);
int stft_ref_check_power32(const int16_t *in, int wsel,
                           const uint32_t *hw /*[STFT_N]*/, int *first);
int stft_ref_check_pixel  (const int16_t *in, int wsel, int fl,
                           const uint8_t  *hw /*[STFT_NPIX]*/, int *first);

#ifdef __cplusplus
}
#endif
#endif /* STFT_REF_H */
