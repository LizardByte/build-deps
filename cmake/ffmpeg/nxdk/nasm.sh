#!/usr/bin/env sh
# SPDX-License-Identifier: GPL-3.0-only

set -eu

# FFmpeg's freestanding target defaults to ELF. The Xbox linker consumes i386 COFF.
exec nasm "$@" -f win32
