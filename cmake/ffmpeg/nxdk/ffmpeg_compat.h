/* SPDX-License-Identifier: GPL-3.0-only */

/**
 * @file cmake/ffmpeg/nxdk/ffmpeg_compat.h
 * @brief Adapt optional FFmpeg platform helpers for nxdk.
 *
 * This build decodes compressed data in memory. Normal stdio remains available;
 * descriptors, mapped files and temporary files are outside this decoder build.
 */
#pragma once
#include "ffmpeg_memory.h"

#include <errno.h>
#include <malloc.h>
#include <stdio.h>
#include <sys/types.h>

/** @brief Keep the clock adapter's symbol private to the FFmpeg libraries. */
#define gettimeofday nxdk_ffmpeg_gettimeofday
/** @brief Keep the sleep adapter's symbol private to the FFmpeg libraries. */
#define usleep nxdk_ffmpeg_usleep

#if defined(NXDK) && !defined(__cplusplus)
  #include "ffmpeg_math.h"

  // FFmpeg 9.1 calls these functions directly. nxdk's symbols assert at runtime.
  #define exp2 nxdk_ffmpeg_exp2  ///< Use the private double-precision exponential.
  #define exp2f nxdk_ffmpeg_exp2f  ///< Use the private single-precision exponential.
  #define lrint nxdk_ffmpeg_lrint  ///< Round a double to the Xbox long type.
  #define lrintf nxdk_ffmpeg_lrintf  ///< Round a float to the Xbox long type.
  #define llrint nxdk_ffmpeg_llrint  ///< Round a double to a 64-bit integer.
  #define llrintf nxdk_ffmpeg_llrintf  ///< Round a float to a 64-bit integer.
#endif

#ifdef NXDK
  #ifdef __cplusplus
extern "C" {
  #endif

  /**
   * @brief Declare the POSIX Bessel function referenced by FFmpeg's unused jinc kernel.
   *
   * nxdk provides no implementation. The unused static kernel is eliminated, so
   * this declaration permits parsing without adding a linker reference. An actual
   * caller will require a Bessel implementation before the Xbox executable can link.
   *
   * @param x Function argument.
   * @return First-kind Bessel function of order one at x.
   */
  double j1(double x);

  #ifdef __cplusplus
}
  #endif
#endif

/** @brief Supply the compiler memory fence required by FFmpeg's Win32 thread probe. */
#define MemoryBarrier() __atomic_thread_fence(__ATOMIC_SEQ_CST)

/** @brief Route FFmpeg aligned allocation to a complete private implementation. */
#define _aligned_malloc nxdk_ffmpeg_aligned_malloc
/** @brief Preserve aligned buffers when FFmpeg reallocates them. */
#define _aligned_realloc nxdk_ffmpeg_aligned_realloc
/** @brief Match the private aligned allocator when releasing FFmpeg buffers. */
#define _aligned_free nxdk_ffmpeg_aligned_free

/**
 * @brief Reject an optional FFmpeg open request.
 *
 * @param path Requested path.
 * @param flags Requested access flags.
 * @param ... Unused creation mode.
 * @return Always -1 with errno set to ENOSYS.
 */
static inline int nxdk_ffmpeg_open(const char *path, int flags, ...) {
  (void) path;
  (void) flags;
  errno = ENOSYS;
  return -1;
}

/** @brief Keep open adaptation private to FFmpeg. */
#define open nxdk_ffmpeg_open

/**
 * @brief Reject an optional FFmpeg close request.
 *
 * @param descriptor Unsupported file descriptor.
 * @return Always -1 with errno set to ENOSYS.
 */
static inline int nxdk_ffmpeg_close(int descriptor) {
  (void) descriptor;
  errno = ENOSYS;
  return -1;
}

/** @brief Keep close adaptation private to FFmpeg. */
#define close nxdk_ffmpeg_close

/**
 * @brief Reject an optional FFmpeg read request.
 *
 * @param descriptor Unsupported file descriptor.
 * @param buffer Unmodified destination.
 * @param size Requested byte count.
 * @return Always -1 with errno set to ENOSYS.
 */
static inline ssize_t nxdk_ffmpeg_read(int descriptor, void *buffer, size_t size) {
  (void) descriptor;
  (void) buffer;
  (void) size;
  errno = ENOSYS;
  return -1;
}

/** @brief Keep read adaptation private to FFmpeg. */
#define read nxdk_ffmpeg_read

/**
 * @brief Reject an optional FFmpeg fdopen request.
 *
 * @param descriptor Unsupported file descriptor.
 * @param mode Requested stdio mode.
 * @return Always NULL with errno set to ENOSYS.
 */
static inline FILE *nxdk_ffmpeg_fdopen(int descriptor, const char *mode) {
  (void) descriptor;
  (void) mode;
  errno = ENOSYS;
  return NULL;
}

/** @brief Keep fdopen adaptation private to FFmpeg. */
#define fdopen nxdk_ffmpeg_fdopen

/**
 * @brief Reject an optional FFmpeg access request.
 *
 * @param path Requested path.
 * @param mode Requested permissions.
 * @return Always -1 with errno set to ENOSYS.
 */
static inline int nxdk_ffmpeg_access(const char *path, int mode) {
  (void) path;
  (void) mode;
  errno = ENOSYS;
  return -1;
}

/** @brief Keep access adaptation private to FFmpeg. */
#define access nxdk_ffmpeg_access

/**
 * @brief Reject an optional FFmpeg isatty request.
 *
 * @param descriptor Unsupported terminal descriptor.
 * @return Always 0 with errno set to ENOSYS.
 */
static inline int nxdk_ffmpeg_isatty(int descriptor) {
  (void) descriptor;
  errno = ENOSYS;
  return 0;
}

/** @brief Keep isatty adaptation private to FFmpeg. */
#define isatty nxdk_ffmpeg_isatty
