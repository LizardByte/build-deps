# Verifies that x265's install step produced the pkg-config file consumed by
# FFmpeg. x265 only generates it when it can detect its version tag, so a
# missing file (or one without a usable version) means the copied source tree
# could not resolve the submodule's git directory, or the checkout has no tags.
#
# Required variables:
#   X265_PC_FILE - pkg-config file the install step must have written

if(NOT DEFINED X265_PC_FILE OR NOT EXISTS "${X265_PC_FILE}")
    message(FATAL_ERROR
            "x265.pc was not installed at ${X265_PC_FILE}. x265 only installs it "
            "when it can detect its version tag, so make sure the source tree is a "
            "git checkout with tags (see GIT_FETCH_TAGS in cmake/ffmpeg/x265.cmake).")
endif()

file(READ "${X265_PC_FILE}" x265_pc_content)
if(NOT x265_pc_content MATCHES "Version:[ \t]*[0-9]")
    message(FATAL_ERROR "the installed x265.pc has no usable version: ${X265_PC_FILE}")
endif()
