#!/usr/bin/env bash

set -euo pipefail

# Resolve directories in the build shell so the same compiler wrappers work in MSYS2.
NXDK_DIR=$(cd "$1" && pwd)
support=$(cd "$2" && pwd)
ffmpeg=$(cd "$3" && pwd)
work=$(cd "$4" && pwd)
prefix=$(realpath "$5")
probe=$(realpath "$6")
jobs=$7
compat="$support/src/_nxdk_compat"
wrappers="$support/scripts"

export NXDK_DIR
export PATH="$NXDK_DIR/bin:$PATH"
unset MAKEFLAGS MFLAGS GNUMAKEFLAGS MAKELEVEL MSYS2_ARG_CONV_EXCL

# Build just the runtime libraries needed by configure probes. Keep object paths relative
# so archiving the nxdk runtime also fits within the Windows command-line limit.
(
  cd "$NXDK_DIR"
  make NXDK_DIR=. NXDK_ONLY=y NXDK_SDL= -j"$jobs" \
    ./lib/libpdclib.lib ./lib/libxboxrt.lib ./lib/libwinapi.lib \
    ./lib/libnxdk_hal.lib ./lib/xboxkrnl/libxboxkrnl.lib './lib/libc++.lib'
)

cd "$work"
sh "$NXDK_DIR/bin/nxdk-cc" -I"$compat/include" -c "$compat/runtime.c" -o runtime.obj
sh "$NXDK_DIR/bin/nxdk-cc" -c "$compat/ffmpeg_memory.c" -o ffmpeg_memory.obj
llvm-ar rcs libffmpeg-nxdk-compat.a runtime.obj ffmpeg_memory.obj

# Keep the SDK and FFmpeg profile compatible with Moonlight's Pentium III build.
# Win32 stack realignment prevents inline x86 asm while NASM can emit i386 COFF.
mkdir -p ffmpeg
cd ffmpeg
sh "$ffmpeg/configure" \
  --prefix="$prefix" --extra-ldflags="$work/libffmpeg-nxdk-compat.a" --extra-cflags=-mstackrealign \
  --enable-cross-compile --arch=x86 --cpu=pentium3 --target-os=none \
  --cc="sh $wrappers/ffmpeg-nxdk-cc.sh" --cxx="sh $wrappers/ffmpeg-nxdk-cxx.sh" \
  --ar=llvm-ar --ranlib=llvm-ranlib --nm=llvm-nm \
  --enable-static --disable-shared --disable-autodetect \
  --enable-asm --disable-inline-asm --enable-x86asm --x86asmexe="$wrappers/ffmpeg-nxdk-nasm.sh" \
  --disable-sse2 --disable-amd3dnow --disable-amd3dnowext --disable-runtime-cpudetect \
  --disable-debug --disable-doc --disable-programs --disable-network --disable-everything \
  --disable-avdevice --disable-avfilter --disable-avformat --disable-iconv --disable-zlib \
  --disable-bzlib --disable-lzma --disable-sdl2 --disable-symver --disable-pthreads \
  --enable-w32threads --disable-os2threads --disable-hwaccels \
  --enable-avcodec --enable-avutil --enable-swscale --enable-swresample \
  --enable-parser=h264 --enable-parser=h263 --enable-parser=mpegvideo \
  --enable-decoder=h264 --enable-decoder=h263 --enable-decoder=h263i --enable-decoder=h263p \
  --enable-decoder=mpeg2video --enable-decoder=opus
make -j"$jobs" install
install -m 644 "$work/libffmpeg-nxdk-compat.a" "$prefix/lib/"
install -Dm644 "$ffmpeg/COPYING.LGPLv2.1" "$prefix/share/licenses/FFmpeg/COPYING.LGPLv2.1"
install -Dm644 "$ffmpeg/COPYING.LGPLv3" "$prefix/share/licenses/FFmpeg/COPYING.LGPLv3"
install -Dm644 "$support/LICENSE" "$prefix/share/licenses/Moonlight-XboxOG/LICENSE"
install -Dm644 "$work/sources.txt" "$prefix/share/ffmpeg-nxdk/sources.txt"

for component in H264_DECODER H263_DECODER H263I_DECODER H263P_DECODER MPEG2VIDEO_DECODER \
  OPUS_DECODER H264_PARSER H263_PARSER MPEGVIDEO_PARSER; do
  grep -Fx "#define CONFIG_$component 1" config_components.h
done

archives=()
for library in avcodec swscale swresample avutil ffmpeg-nxdk-compat; do
  archive="$prefix/lib/lib$library.a"
  # Check each member so mixed host and Xbox objects fail before publication.
  llvm-readobj --file-headers "$archive" | awk '
    /Machine:/ { found++; if ($2 != "IMAGE_FILE_MACHINE_I386") wrong = 1 }
    END { exit (!found || wrong) }'
  archives+=("$archive")
done

# Link against the installed headers and all five archives with the real nxdk runtime.
# The resulting PE executable is an Xbox link probe and is only inspected on the host.
# Match the consumer's linker settings for NASM objects without SafeSEH metadata.
sh "$wrappers/ffmpeg-nxdk-cc.sh" -Wl,-safeseh:no -I"$prefix/include" \
  "$probe" "${archives[@]}" -o "$work/ffmpeg-nxdk-probe.exe"
