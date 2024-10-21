cmake_minimum_required(VERSION 3.2)

project(build-deps
        DESCRIPTION "Pre-build dependencies for LizardByte projects.")

option(BUILD_ALL "Build all dependencies" ON)
option(BUILD_ALL_SUNSHINE "Build all Sunshine dependencies" ON)

# FFmpeg
option(BUILD_FFMPEG "Build FFmpeg" ON)
option(BUILD_FFMPEG_ALL_PATCHES "Apply FFmpeg patches" ON)
option(BUILD_FFMPEG_AMF "Build FFmpeg AMF" ON)
option(BUILD_FFMPEG_AMF_PATCHES "Apply FFmpeg AMF patches" ON)
option(BUILD_FFMPEG_CBS "Build FFmpeg CBS" ON)
option(BUILD_FFMPEG_CBS_PATCHES "Apply FFmpeg CBS patches" ON)
option(BUILD_FFMPEG_MF "Build FFmpeg Media Foundation" ON)
option(BUILD_FFMPEG_MF_PATCHES "Apply FFmpeg Media Foundation patches" ON)
option(BUILD_FFMPEG_NV_CODEC_HEADERS "Build FFmpeg NV Codec Headers" ON)
option(BUILD_FFMPEG_NV_CODEC_HEADERS_PATCHES "Apply FFmpeg NV Codec Headers patches" ON)
option(BUILD_FFMPEG_SVT_AV1 "Build FFmpeg SVT-AV1" ON)
option(BUILD_FFMPEG_SVT_AV1_PATCHES "Apply FFmpeg SVT-AV1 patches" ON)
option(BUILD_FFMPEG_VAAPI "Build FFmpeg with VAAPI support" ON)
option(BUILD_FFMPEG_VAAPI_PATCHES "Apply FFmpeg VAAPI patches" ON)
option(BUILD_FFMPEG_X264 "Build FFmpeg x264" ON)
option(BUILD_FFMPEG_X264_PATCHES "Apply FFmpeg x264 patches" ON)
option(BUILD_FFMPEG_X265 "Build FFmpeg x265" ON)
option(BUILD_FFMPEG_X265_PATCHES "Apply FFmpeg x265 patches" ON)

add_custom_target(${CMAKE_PROJECT_NAME})

# set generated source path
set(CMAKE_GENERATED_SRC_PATH ${CMAKE_CURRENT_BINARY_DIR}/generated-src)

# Explicit shell otherwise Windows runs outside the mingw environment
# TODO: is this true when using `${CMAKE_COMMAND} -E`?
if(WIN32)
    set(SHELL_COMMAND sh)
endif()

# common includes
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/apply_git_patch.cmake)

if(BUILD_ALL OR BUILD_ALL_SUNSHINE OR BUILD_FFMPEG)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/_main.cmake)
endif()
