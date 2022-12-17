cmake_minimum_required(VERSION 3.0)

project(cbs
        DESCRIPTION "FFmpeg code subset to expose coded bitstream (CBS) internal APIs for Sunshine"
        )

set(CMAKE_GENERATED_SRC_PATH ${CMAKE_BINARY_DIR}/generated-src)

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/apply_git_patch.cmake)

# Apply patches
apply_git_patch(${CMAKE_SOURCE_DIR}/ffmpeg_sources/ffmpeg ${CMAKE_SOURCE_DIR}/ffmpeg_patches/cbs/explicit_intmath.patch)
apply_git_patch(${CMAKE_SOURCE_DIR}/ffmpeg_sources/ffmpeg ${CMAKE_SOURCE_DIR}/ffmpeg_patches/cbs/size_specifier.patch)

file(COPY ${CMAKE_SOURCE_DIR}/ffmpeg_sources/ffmpeg DESTINATION ${CMAKE_GENERATED_SRC_PATH})

set(FFMPEG_GENERATED_SRC_PATH ${CMAKE_GENERATED_SRC_PATH}/ffmpeg)
set(AVCODEC_GENERATED_SRC_PATH ${CMAKE_GENERATED_SRC_PATH}/ffmpeg/libavcodec)
set(CBS_GENERATED_SRC_INCLUDE_PATH ${CMAKE_GENERATED_SRC_PATH}/include/cbs)

# Configure FFmpeg to generate necessary config files
# TODO - change this to minimal set of flags and enable gpl 3
if(NOT EXISTS ${FFMPEG_GENERATED_SRC_PATH}/config.h)
    execute_process(COMMAND sh ./configure --disable-all
        WORKING_DIRECTORY ${FFMPEG_GENERATED_SRC_PATH}
        )
endif()

# Headers needed to link for Sunshine
configure_file(${AVCODEC_GENERATED_SRC_PATH}/av1.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/av1.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_av1.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_av1.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_bsf.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_bsf.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_h2645.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_h2645.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_h264.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_h264.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_h265.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_h265.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_jpeg.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_jpeg.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_mpeg2.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_mpeg2.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_sei.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_sei.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_vp9.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/cbs_vp9.h COPYONLY)
configure_file(${FFMPEG_GENERATED_SRC_PATH}/config.h ${CMAKE_GENERATED_SRC_PATH}/include/config.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/defs.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/defs.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/get_bits.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/get_bits.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/h264_levels.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/h264_levels.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/h2645_parse.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/h2645_parse.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/h264.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/h264.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/hevc.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/hevc.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/mathops.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/mathops.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/x86/mathops.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/x86/mathops.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/arm/mathops.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/arm/mathops.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/sei.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/sei.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/vlc.h ${CBS_GENERATED_SRC_INCLUDE_PATH}/vlc.h COPYONLY)

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
    ${CMAKE_GENERATED_SRC_PATH}/include/config.h
    ${CBS_GENERATED_SRC_INCLUDE_PATH}/defs.h
    ${CBS_GENERATED_SRC_INCLUDE_PATH}/get_bits.h
    ${CBS_GENERATED_SRC_INCLUDE_PATH}/h264_levels.h
    ${CBS_GENERATED_SRC_INCLUDE_PATH}/h2645_parse.h
    ${CBS_GENERATED_SRC_INCLUDE_PATH}/h264.h
    ${CBS_GENERATED_SRC_INCLUDE_PATH}/hevc.h
    ${CBS_GENERATED_SRC_INCLUDE_PATH}/mathops.h
    ${CBS_GENERATED_SRC_INCLUDE_PATH}/sei.h
    ${CBS_GENERATED_SRC_INCLUDE_PATH}/vlc.h


    ${AVCODEC_GENERATED_SRC_PATH}/cbs.c
    ${AVCODEC_GENERATED_SRC_PATH}/cbs_h2645.c
    ${AVCODEC_GENERATED_SRC_PATH}/cbs_av1.c
    ${AVCODEC_GENERATED_SRC_PATH}/cbs_vp9.c
    ${AVCODEC_GENERATED_SRC_PATH}/cbs_mpeg2.c
    ${AVCODEC_GENERATED_SRC_PATH}/cbs_jpeg.c
    ${AVCODEC_GENERATED_SRC_PATH}/cbs_sei.c
    ${AVCODEC_GENERATED_SRC_PATH}/h264_levels.c
    ${AVCODEC_GENERATED_SRC_PATH}/h2645_parse.c
    ${FFMPEG_GENERATED_SRC_PATH}/libavutil/intmath.c

    # Additional headers containing symbols needed to compile
    ${CMAKE_GENERATED_SRC_PATH}/include/libavutil/x86/asm.h
    ${CMAKE_GENERATED_SRC_PATH}/include/libavutil/x86/intmath.h
    ${CMAKE_GENERATED_SRC_PATH}/include/libavutil/arm/intmath.h
    ${CMAKE_GENERATED_SRC_PATH}/include/libavutil/intmath.h
)

include_directories(
    ${CBS_GENERATED_SRC_INCLUDE_PATH}
    ${FFMPEG_GENERATED_SRC_PATH}
)

add_library(cbs ${CBS_SOURCE_FILES})
target_compile_options(cbs PRIVATE -Wall -Wno-incompatible-pointer-types -Wno-format -Wno-format-extra-args)
