#!/usr/bin/env bash

set -euo pipefail

prefix=$1
build_dir=$2
compiler=$3
test_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

for component in H264_DECODER H263_DECODER H263I_DECODER H263P_DECODER MPEG2VIDEO_DECODER \
  OPUS_DECODER H264_PARSER H263_PARSER MPEGVIDEO_PARSER; do
  grep -Fx "#define CONFIG_$component 1" "$build_dir/config_components.h"
done

archives=()
for library in avcodec swscale swresample avutil ffmpeg-nxdk-compat; do
  archive="$prefix/lib/lib$library.a"
  # A host-format object in any archive makes the package unsuitable for nxdk.
  llvm-readobj --file-headers "$archive" | awk '
    /Machine:/ { found++; if ($2 != "IMAGE_FILE_MACHINE_I386") wrong = 1 }
    END { exit (!found || wrong) }'
  archives+=("$archive")
done

# Link the probe against nxdk and the installed archives. The NASM objects lack SafeSEH metadata.
sh "$compiler" c -Wl,-safeseh:no -I"$prefix/include" \
  "$test_dir/ffmpeg-nxdk.c" "${archives[@]}" -o "$build_dir/ffmpeg-nxdk-probe.exe"
