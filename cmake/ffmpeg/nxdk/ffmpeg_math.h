/* SPDX-License-Identifier: GPL-3.0-only */

/**
 * @file cmake/ffmpeg/nxdk/ffmpeg_math.h
 * @brief Supply the math functions used by FFmpeg that nxdk leaves unimplemented.
 */
#pragma once

#include <math.h>
#include <stdint.h>

/**
 * @brief Evaluate a base-two exponential using nxdk's implemented natural exponential.
 * @param exponent The exponent to raise two to.
 * @return Two raised to the given exponent.
 */
static inline double nxdk_ffmpeg_exp2(double exponent) {
  const double natural_log_of_two = 0x1.62e42fefa39efp-1;
  return exp(exponent * natural_log_of_two);
}

/**
 * @brief Evaluate a single-precision base-two exponential.
 * @param exponent The exponent to raise two to.
 * @return Two raised to the given exponent, converted to float.
 */
static inline float nxdk_ffmpeg_exp2f(float exponent) {
  return (float) nxdk_ffmpeg_exp2(exponent);
}

#if defined(__i386__) || defined(__x86_64__)
/**
 * @brief Round a double to the Xbox's 32-bit long using the current x87 rounding mode.
 * @param value The value to round.
 * @return The rounded integer, or the x87 integer indefinite value if it is unrepresentable.
 */
static inline long nxdk_ffmpeg_lrint(double value) {
  int32_t result;
  __asm__ volatile("fistpl %0" : "=m"(result) : "t"(value) : "st");
  return result;
}

/**
 * @brief Round a float to the Xbox's 32-bit long using the current x87 rounding mode.
 * @param value The value to round.
 * @return The rounded integer, or the x87 integer indefinite value if it is unrepresentable.
 */
static inline long nxdk_ffmpeg_lrintf(float value) {
  return nxdk_ffmpeg_lrint(value);
}

/**
 * @brief Round a double to a 64-bit integer using the current x87 rounding mode.
 * @param value The value to round.
 * @return The rounded integer, or the x87 integer indefinite value if it is unrepresentable.
 */
static inline long long nxdk_ffmpeg_llrint(double value) {
  int64_t result;
  __asm__ volatile("fistpll %0" : "=m"(result) : "t"(value) : "st");
  return result;
}

/**
 * @brief Round a float to a 64-bit integer using the current x87 rounding mode.
 * @param value The value to round.
 * @return The rounded integer, or the x87 integer indefinite value if it is unrepresentable.
 */
static inline long long nxdk_ffmpeg_llrintf(float value) {
  return nxdk_ffmpeg_llrint(value);
}
#endif
