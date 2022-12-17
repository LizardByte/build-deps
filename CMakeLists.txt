cmake_minimum_required(VERSION 3.0)

project(CBS
        DESCRIPTION "FFmpeg code subset to expose coded bitstream (CBS) internal APIs for Sunshine"
        )

set(CMAKE_GENERATED_SRC_PATH ${CMAKE_BINARY_DIR}/generated-src)
set(CBS_GENERATED_SRC_INCLUDE_PATH ${CMAKE_BINARY_DIR}/generated-src/include/cbs)

#
# This macro applies patch to git repository if patch is applicable
# Arguments are path to git repository and path to the git patch
#
macro(apply_git_patch REPO_PATH PATCH_PATH)
    execute_process(COMMAND git apply --check ${PATCH_PATH}
        WORKING_DIRECTORY ${REPO_PATH}
        RESULT_VARIABLE SUCCESS)

    if(${SUCCESS} EQUAL 0)
        message("Applying git patch ${PATCH_PATH} in ${REPO_PATH} repository")
        execute_process(COMMAND git apply ${PATCH_PATH}
            WORKING_DIRECTORY ${REPO_PATH}
            RESULT_VARIABLE SUCCESS)

        if(${SUCCESS} EQUAL 1)
            # We don't stop here because it can happen in case of parallel builds
            message(WARNING "\nError: failed to apply the patch patch: ${PATCH_PATH}\n")
        endif()
    endif()
endmacro()

# Apply patches
apply_git_patch(${CMAKE_SOURCE_DIR}/ffmpeg_sources/ffmpeg ${CMAKE_SOURCE_DIR}/ffmpeg_patches/cbs/explicit_intmath.patch)
apply_git_patch(${CMAKE_SOURCE_DIR}/ffmpeg_sources/ffmpeg ${CMAKE_SOURCE_DIR}/ffmpeg_patches/cbs/size_specifier.patch)

file(COPY ${CMAKE_SOURCE_DIR}/ffmpeg_sources/ffmpeg DESTINATION ${CMAKE_GENERATED_SRC_PATH})

set(FFMPEG_SRC_PATH ${CMAKE_GENERATED_SRC_PATH}/ffmpeg)
set(AVCODEC_SRC_PATH ${CMAKE_GENERATED_SRC_PATH}/ffmpeg/libavcodec)
set(AVUTIL_SRC_PATH ${CMAKE_GENERATED_SRC_PATH}/ffmpeg/libavutil)

# Configure FFmpeg to generate necessary config files
message("Configuring FFmpeg")
execute_process(COMMAND ./configure
    WORKING_DIRECTORY ${FFMPEG_SRC_PATH}
    )

# Minimal set of headers needed for Sunshine
configure_file(${AVCODEC_SRC_PATH}/cbs_av1.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_av1.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/cbs_h264.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_h264.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/cbs_h265.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_h265.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/h264_levels.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/h264_levels.h COPYONLY)

set(CBS_SOURCE_FILES
    ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_av1.h
    ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_h264.h
    ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_h265.h
    ${CBS_GENERATED_SRC_INCLUDE_PATH}/h264_levels.h

    ${AVCODEC_SRC_PATH}/cbs.c
    ${AVCODEC_SRC_PATH}/cbs_h2645.c
    ${AVCODEC_SRC_PATH}/cbs_av1.c
    ${AVCODEC_SRC_PATH}/cbs_vp9.c
    ${AVCODEC_SRC_PATH}/cbs_mpeg2.c
    ${AVCODEC_SRC_PATH}/cbs_jpeg.c
    ${AVCODEC_SRC_PATH}/cbs_sei.c
    ${AVCODEC_SRC_PATH}/h264_levels.c
    ${AVCODEC_SRC_PATH}/h2645_parse.c
)

include_directories(${CBS_GENERATED_SRC_INCLUDE_PATH})
include_directories(${FFMPEG_SRC_PATH})

add_library(cbs ${CBS_SOURCE_FILES})
target_compile_options(cbs PRIVATE -Wall -Wno-incompatible-pointer-types -Wno-format -Wno-format-extra-args)
