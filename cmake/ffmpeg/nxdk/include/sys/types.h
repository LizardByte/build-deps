/* SPDX-License-Identifier: GPL-3.0-only */

/**
 * @file cmake/ffmpeg/nxdk/include/sys/types.h
 * @brief Types required by the Xbox FFmpeg adapter.
 */
#pragma once
#include <stddef.h>
#include <stdint.h>
typedef int ssize_t;  ///< Signed buffer length on the 32-bit Xbox.
typedef int64_t off_t;  ///< File offset used only by unsupported descriptor APIs.
typedef unsigned int mode_t;  ///< File mode bits for optional dependency queries.

typedef int pid_t;  ///< Identifier for the single Xbox application.
