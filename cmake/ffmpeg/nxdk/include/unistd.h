/* SPDX-License-Identifier: GPL-3.0-only */

/**
 * @file cmake/ffmpeg/nxdk/include/unistd.h
 * @brief Expose the real sleep helper to FFmpeg without affecting its function probes.
 */
#pragma once
#ifdef __cplusplus
extern "C" {
#endif

  /** @brief Sleep for the given microseconds, rounded up to a whole millisecond. */
  int nxdk_ffmpeg_usleep(unsigned int microseconds);

#ifdef __cplusplus
}
#endif
