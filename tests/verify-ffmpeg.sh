#!/usr/bin/env bash
set -euo pipefail

package_dir=$(cd "$1" && pwd)
compiler=$2
cross_compile=${3:-false}
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

# Check the installed package from a different prefix, just as consumers use it.
cp -R "$package_dir" "$test_dir/ffmpeg"
export PKG_CONFIG_PATH="$test_dir/ffmpeg/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH"
unset PKG_CONFIG_SYSROOT_DIR

test -f "$test_dir/ffmpeg/lib/libcbs.a"

# shellcheck disable=SC2046
"$compiler" "$(dirname "$0")/ffmpeg-decoders.c" \
    $(pkg-config --static --cflags --libs libcbs libavcodec libavutil libswscale opus) -o "$test_dir/codecs"

if [[ "$cross_compile" == true ]]; then
    # Cross targets can be linked on the runner but require their own OS to execute.
    exit 0
fi
"$test_dir/codecs"

test -x "$test_dir/ffmpeg/bin/ffmpeg"
test -x "$test_dir/ffmpeg/bin/ffprobe"
ffmpeg="$test_dir/ffmpeg/bin/ffmpeg"
ffprobe="$test_dir/ffmpeg/bin/ffprobe"
"$ffmpeg" -version
"$ffprobe" -version
# Exercise Koko's scaling, H.264/AAC encoding, fragmented MP4 pipe output,
# decoding, and JSON metadata probing with a small raw video/audio input.
dd if=/dev/zero of="$test_dir/video.yuv" bs=6144 count=4 2>/dev/null
dd if=/dev/zero of="$test_dir/audio.pcm" bs=19200 count=1 2>/dev/null
"$ffmpeg" -hide_banner -loglevel error \
    -f rawvideo -pixel_format yuv420p -video_size 64x64 -framerate 25 -i "$test_dir/video.yuv" \
    -f s16le -ar 48000 -ac 2 -i "$test_dir/audio.pcm" \
    -c:v libx264 -preset veryfast -vf scale=32:32 -pix_fmt yuv420p \
    -c:a aac -ac 2 -b:a 192k -f mp4 \
    -movflags frag_keyframe+empty_moov+default_base_moof pipe:1 > "$test_dir/output.mp4"
"$ffprobe" -v quiet -print_format json -show_format -show_streams "$test_dir/output.mp4" \
    > "$test_dir/probe.json"
grep -q '"codec_name": "h264"' "$test_dir/probe.json"
grep -q '"codec_name": "aac"' "$test_dir/probe.json"
"$ffmpeg" -hide_banner -loglevel error -i "$test_dir/output.mp4" -f null -
