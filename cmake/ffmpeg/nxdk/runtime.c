/* SPDX-License-Identifier: GPL-3.0-only */

/**
 * @file cmake/ffmpeg/nxdk/runtime.c
 * @brief Provide FFmpeg timing functions on stock nxdk.
 */
#include <errno.h>
#include <limits.h>
#include <stdint.h>
#include <synchapi.h>
#include <sys/time.h>
#include <unistd.h>
#include <xboxkrnl/xboxkrnl.h>

int nxdk_ffmpeg_gettimeofday(struct timeval *value, void *timezone) {
  if (value == NULL || timezone != NULL) {
    errno = EINVAL;
    return -1;
  }
  LARGE_INTEGER now;
  KeQuerySystemTime(&now);
  const int64_t ticks = now.QuadPart - INT64_C(116444736000000000);
  int64_t seconds = ticks / INT64_C(10000000);
  int64_t remainder = ticks % INT64_C(10000000);
  if (remainder < 0) {
    --seconds;
    remainder += INT64_C(10000000);
  }
  if (seconds < LONG_MIN || seconds > LONG_MAX) {
    errno = EOVERFLOW;
    return -1;
  }
  value->tv_sec = (long) seconds;
  value->tv_usec = (long) (remainder / 10);
  return 0;
}

int nxdk_ffmpeg_usleep(unsigned int microseconds) {
  Sleep(microseconds / 1000U + (microseconds % 1000U != 0));
  return 0;
}
