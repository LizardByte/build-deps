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
        RESULT_VARIABLE SUCCESS
        ERROR_QUIET)

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
apply_git_patch(${CMAKE_SOURCE_DIR}/ffmpeg_sources/ffmpeg ${CMAKE_SOURCE_DIR}/ffmpeg_patches/cbs/avconfig.patch)
apply_git_patch(${CMAKE_SOURCE_DIR}/ffmpeg_sources/ffmpeg ${CMAKE_SOURCE_DIR}/ffmpeg_patches/cbs/config.patch)
apply_git_patch(${CMAKE_SOURCE_DIR}/ffmpeg_sources/ffmpeg ${CMAKE_SOURCE_DIR}/ffmpeg_patches/cbs/explicit_intmath.patch)
apply_git_patch(${CMAKE_SOURCE_DIR}/ffmpeg_sources/ffmpeg ${CMAKE_SOURCE_DIR}/ffmpeg_patches/cbs/size_specifier.patch)

file(COPY ${CMAKE_SOURCE_DIR}/ffmpeg_sources/ffmpeg DESTINATION ${CMAKE_GENERATED_SRC_PATH})

set(FFMPEG_SRC_PATH ${CMAKE_GENERATED_SRC_PATH}/ffmpeg)
set(AVCODEC_SRC_PATH ${CMAKE_GENERATED_SRC_PATH}/ffmpeg/libavcodec)
set(AVUTIL_SRC_PATH ${CMAKE_GENERATED_SRC_PATH}/ffmpeg/libavutil)

# TODO - reduce below to minimal set of needed headers now that we are using ffmpeg source directly

# Include headers
configure_file(${AVCODEC_SRC_PATH}/av1.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/av1.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/cbs_av1.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_av1.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/cbs_bsf.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_bsf.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/cbs.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/cbs_h2645.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_h2645.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/cbs_h264.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_h264.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/cbs_h265.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_h265.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/cbs_jpeg.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_jpeg.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/cbs_mpeg2.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_mpeg2.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/cbs_sei.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_sei.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/cbs_vp9.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_vp9.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/codec_desc.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/codec_desc.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/codec_id.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/codec_id.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/codec_par.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/codec_par.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/config.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/config.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/defs.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/defs.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/get_bits.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/get_bits.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/h264_levels.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/h264_levels.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/h2645_parse.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/h2645_parse.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/h264.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/h264.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/hevc.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/hevc.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/mathops.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/mathops.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/packet.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/packet.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/sei.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/sei.h COPYONLY)
configure_file(${AVCODEC_SRC_PATH}/vlc.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/vlc.h COPYONLY)


set(CBS_SOURCE_FILES
${CBS_GENERATED_SRC_INCLUDE_PATH}/av1.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_av1.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_bsf.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_h2645.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_h264.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_h265.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_jpeg.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_mpeg2.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_sei.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_vp9.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/codec_desc.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/codec_id.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/codec_par.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/config.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/defs.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/get_bits.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/h264_levels.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/h2645_parse.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/h264.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/hevc.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/mathops.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/packet.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/sei.h
${CBS_GENERATED_SRC_INCLUDE_PATH}/vlc.h

${AVCODEC_SRC_PATH}/cbs.c
${AVCODEC_SRC_PATH}/cbs_h2645.c
${AVCODEC_SRC_PATH}/cbs_av1.c
${AVCODEC_SRC_PATH}/cbs_vp9.c
${AVCODEC_SRC_PATH}/cbs_mpeg2.c
${AVCODEC_SRC_PATH}/cbs_jpeg.c
${AVCODEC_SRC_PATH}/cbs_sei.c
${AVCODEC_SRC_PATH}/h264_levels.c
${AVCODEC_SRC_PATH}/h2645_parse.c

${AVCODEC_SRC_PATH}/avcodec.h
${AVCODEC_SRC_PATH}/bytestream.h
${AVCODEC_SRC_PATH}/cbs_internal.h
${AVCODEC_SRC_PATH}/codec.h
${AVCODEC_SRC_PATH}/h264_ps.h
${AVCODEC_SRC_PATH}/h264_sei.h
${AVCODEC_SRC_PATH}/hevc_sei.h
${AVUTIL_SRC_PATH}/intmath.h
${AVCODEC_SRC_PATH}/put_bits.h
# ${AVCODEC_SRC_PATH}/version_major.h TODO?
)

include_directories(${CBS_GENERATED_SRC_INCLUDE_PATH})
include_directories(${FFMPEG_SRC_PATH})

if(DEFINED FFMPEG_INCLUDE_DIRS)
include_directories(${FFMPEG_INCLUDE_DIRS})
endif()

add_compile_definitions(
    HAVE_THREADS=1
    HAVE_FAST_UNALIGNED

    PIC=1

    CONFIG_CBS_AV1=1
    CONFIG_CBS_H264=1
    CONFIG_CBS_H265=1
    CONFIG_CBS_JPEG=1
    CONFIG_CBS_MPEG2=1
    CONFIG_CBS_VP9=1
    )


add_library(cbs ${CBS_SOURCE_FILES})
target_compile_options(cbs PRIVATE -Wall -Wno-incompatible-pointer-types -Wno-maybe-uninitialized -Wno-format -Wno-format-extra-args)
