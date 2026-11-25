#!/usr/bin/env sh
# SPDX-License-Identifier: GPL-3.0-only

set -eu

unset MSYS2_ARG_CONV_EXCL
compat_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
language=$1
shift

link=1
for arg in "$@"; do
  case "$arg" in
    -c|-E|-S|-M|-MM) link=0 ;;
    *) ;;
  esac
done

if [ "$link" -eq 1 ]; then
  # FFmpeg compile probes link to the real target runtime and use main as their entry point.
  set -- "$@" -Wl,-entry:main,-subsystem:windows \
    "$NXDK_DIR/lib/libpdclib.lib" "$NXDK_DIR/lib/libxboxrt.lib" "$NXDK_DIR/lib/libwinapi.lib" \
    "$NXDK_DIR/lib/libnxdk_hal.lib" "$NXDK_DIR/lib/xboxkrnl/libxboxkrnl.lib"
  if [ "$language" = c++ ]; then
    set -- "$@" "$NXDK_DIR/lib/libc++.lib"
  fi
fi

if [ "$language" = c++ ]; then
  # Keep Clang's Win32 definitions for the Xbox libc++ headers.
  set -- "-I$NXDK_DIR/lib/libcxx/include" -fno-exceptions "$@"
else
  set -- -U_WIN32 -UWIN32 "$@"
fi

exec clang -target i386-pc-win32 -march=pentium3 -fuse-ld=lld -ffreestanding -nostdlib -fno-builtin \
  -I"$compat_dir/include" -include "$compat_dir/ffmpeg_compat.h" \
  -I"$NXDK_DIR/lib" -I"$NXDK_DIR/lib/xboxrt/libc_extensions" \
  -isystem "$NXDK_DIR/lib/pdclib/include" -I"$NXDK_DIR/lib/pdclib/platform/xbox/include" \
  -I"$NXDK_DIR/lib/winapi" -I"$NXDK_DIR/lib/xboxrt/vcruntime" \
  -Wno-builtin-macro-redefined -DNXDK -D__STDC__=1 -U__STDC_NO_THREADS__ "$@"
