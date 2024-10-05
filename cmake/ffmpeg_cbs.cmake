cmake_minimum_required(VERSION 3.2)

project(cbs
        DESCRIPTION "FFmpeg code subset to expose coded bitstream (CBS) internal APIs for Sunshine"
        VERSION 0.1)

set(CMAKE_GENERATED_SRC_PATH ${CMAKE_BINARY_DIR}/generated-src)

# Apply patches
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/apply_git_patch.cmake)
APPLY_GIT_PATCH(${CMAKE_SOURCE_DIR}/ffmpeg_sources/ffmpeg
        ${CMAKE_SOURCE_DIR}/ffmpeg_patches/cbs/01-explicit-intmath.patch)
APPLY_GIT_PATCH(${CMAKE_SOURCE_DIR}/ffmpeg_sources/ffmpeg
        ${CMAKE_SOURCE_DIR}/ffmpeg_patches/cbs/02-include-cbs-config.patch)
APPLY_GIT_PATCH(${CMAKE_SOURCE_DIR}/ffmpeg_sources/ffmpeg
        ${CMAKE_SOURCE_DIR}/ffmpeg_patches/cbs/03-remove-register.patch)
APPLY_GIT_PATCH(${CMAKE_SOURCE_DIR}/ffmpeg_sources/ffmpeg
        ${CMAKE_SOURCE_DIR}/ffmpeg_patches/cbs/04-size-specifier.patch)

file(COPY ${CMAKE_SOURCE_DIR}/ffmpeg_sources/ffmpeg DESTINATION ${CMAKE_GENERATED_SRC_PATH})

set(FFMPEG_GENERATED_SRC_PATH ${CMAKE_GENERATED_SRC_PATH}/ffmpeg)
set(AVCODEC_GENERATED_SRC_PATH ${CMAKE_GENERATED_SRC_PATH}/ffmpeg/libavcodec)
set(CBS_INCLUDE_PATH ${CMAKE_BINARY_DIR}/include/cbs)

message("Running FFmpeg configure to generate platform config")

# Explicit shell otherwise Windows runs outside the mingw environment
if (WIN32)
    set(LEADING_SH_COMMAND sh)
endif ()

string(TOLOWER ${CMAKE_SYSTEM_PROCESSOR} arch)

if (${arch} STREQUAL "aarch64" OR ${arch} STREQUAL "arm64")
    set(CBS_ARCH_PATH arm)
elseif (${arch} STREQUAL "ppc64le")
    set(CBS_ARCH_PATH ppc)
elseif (${arch} STREQUAL "amd64" OR ${arch} STREQUAL "x86_64")
    set(CBS_ARCH_PATH x86)
else ()
    message(FATAL_ERROR "Unsupported system processor:" ${CMAKE_SYSTEM_PROCESSOR})
endif ()

if (CMAKE_CROSSCOMPILING)
    set(FFMPEG_EXTRA_CONFIGURE --arch=${arch} --enable-cross-compile)
endif ()

# The generated config.h needs to have `CONFIG_CBS_` flags enabled (from `--enable-bsfs`)
execute_process(
        COMMAND ${LEADING_SH_COMMAND} ./configure
            --cc=${CMAKE_C_COMPILER}
            --cxx=${CMAKE_CXX_COMPILER}
            --ar=${CMAKE_AR}
            --ranlib=${CMAKE_RANLIB}
            --optflags=${CMAKE_C_FLAGS}
            --disable-all
            --disable-autodetect
            --disable-iconv
            --enable-avcodec
            --enable-avutil
            --enable-bsfs
            --enable-gpl
            --enable-static
            ${FFMPEG_EXTRA_CONFIGURE}
        WORKING_DIRECTORY ${FFMPEG_GENERATED_SRC_PATH}
        COMMAND_ECHO STDOUT
        COMMAND_ERROR_IS_FATAL ANY)

# Headers needed to link for Sunshine
configure_file(${AVCODEC_GENERATED_SRC_PATH}/av1.h ${CBS_INCLUDE_PATH}/av1.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_av1.h ${CBS_INCLUDE_PATH}/cbs_av1.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_bsf.h ${CBS_INCLUDE_PATH}/cbs_bsf.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs.h ${CBS_INCLUDE_PATH}/cbs.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_h2645.h ${CBS_INCLUDE_PATH}/cbs_h2645.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_h264.h ${CBS_INCLUDE_PATH}/cbs_h264.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_h265.h ${CBS_INCLUDE_PATH}/cbs_h265.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_jpeg.h ${CBS_INCLUDE_PATH}/cbs_jpeg.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_mpeg2.h ${CBS_INCLUDE_PATH}/cbs_mpeg2.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_sei.h ${CBS_INCLUDE_PATH}/cbs_sei.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_vp8.h ${CBS_INCLUDE_PATH}/cbs_vp8.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/cbs_vp9.h ${CBS_INCLUDE_PATH}/cbs_vp9.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/codec_desc.h ${CBS_INCLUDE_PATH}/codec_desc.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/codec_id.h ${CBS_INCLUDE_PATH}/codec_id.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/codec_par.h ${CBS_INCLUDE_PATH}/codec_par.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/defs.h ${CBS_INCLUDE_PATH}/defs.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/get_bits.h ${CBS_INCLUDE_PATH}/get_bits.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/h264_levels.h ${CBS_INCLUDE_PATH}/h264_levels.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/h2645_parse.h ${CBS_INCLUDE_PATH}/h2645_parse.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/h264.h ${CBS_INCLUDE_PATH}/h264.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/hevc/hevc.h ${CBS_INCLUDE_PATH}/hevc/hevc.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/mathops.h ${CBS_INCLUDE_PATH}/mathops.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/packet.h ${CBS_INCLUDE_PATH}/packet.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/sei.h ${CBS_INCLUDE_PATH}/sei.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/version_major.h ${CBS_INCLUDE_PATH}/version_major.h COPYONLY)
configure_file(${AVCODEC_GENERATED_SRC_PATH}/vlc.h ${CBS_INCLUDE_PATH}/vlc.h COPYONLY)
configure_file(${FFMPEG_GENERATED_SRC_PATH}/config.h ${CBS_INCLUDE_PATH}/config.h COPYONLY)
configure_file(${FFMPEG_GENERATED_SRC_PATH}/libavutil/attributes.h
        ${CMAKE_BINARY_DIR}/include/libavutil/attributes.h COPYONLY)
configure_file(${FFMPEG_GENERATED_SRC_PATH}/libavutil/attributes_internal.h
        ${CMAKE_BINARY_DIR}/include/libavutil/attributes_internal.h COPYONLY)
configure_file(${FFMPEG_GENERATED_SRC_PATH}/libavutil/intmath.h
        ${CMAKE_BINARY_DIR}/include/libavutil/intmath.h COPYONLY)

set(CBS_SOURCE_FILES
        ${CBS_INCLUDE_PATH}/av1.h
        ${CBS_INCLUDE_PATH}/cbs_av1.h
        ${CBS_INCLUDE_PATH}/cbs_bsf.h
        ${CBS_INCLUDE_PATH}/cbs.h
        ${CBS_INCLUDE_PATH}/cbs_h2645.h
        ${CBS_INCLUDE_PATH}/cbs_h264.h
        ${CBS_INCLUDE_PATH}/cbs_h265.h
        ${CBS_INCLUDE_PATH}/cbs_jpeg.h
        ${CBS_INCLUDE_PATH}/cbs_mpeg2.h
        ${CBS_INCLUDE_PATH}/cbs_sei.h
        ${CBS_INCLUDE_PATH}/cbs_vp8.h
        ${CBS_INCLUDE_PATH}/cbs_vp9.h
        ${CBS_INCLUDE_PATH}/codec_desc.h
        ${CBS_INCLUDE_PATH}/codec_id.h
        ${CBS_INCLUDE_PATH}/codec_par.h
        ${CBS_INCLUDE_PATH}/defs.h
        ${CBS_INCLUDE_PATH}/get_bits.h
        ${CBS_INCLUDE_PATH}/h264_levels.h
        ${CBS_INCLUDE_PATH}/h2645_parse.h
        ${CBS_INCLUDE_PATH}/h264.h
        ${CBS_INCLUDE_PATH}/hevc/hevc.h
        ${CBS_INCLUDE_PATH}/mathops.h
        ${CBS_INCLUDE_PATH}/packet.h
        ${CBS_INCLUDE_PATH}/sei.h
        ${CBS_INCLUDE_PATH}/version_major.h
        ${CBS_INCLUDE_PATH}/vlc.h
        ${CMAKE_BINARY_DIR}/include/libavutil/intmath.h
        ${CBS_INCLUDE_PATH}/config.h

        ${AVCODEC_GENERATED_SRC_PATH}/cbs.c
        ${AVCODEC_GENERATED_SRC_PATH}/cbs_h2645.c
        ${AVCODEC_GENERATED_SRC_PATH}/cbs_av1.c
        ${AVCODEC_GENERATED_SRC_PATH}/cbs_vp8.c
        ${AVCODEC_GENERATED_SRC_PATH}/cbs_vp9.c
        ${AVCODEC_GENERATED_SRC_PATH}/cbs_mpeg2.c
        ${AVCODEC_GENERATED_SRC_PATH}/cbs_jpeg.c
        ${AVCODEC_GENERATED_SRC_PATH}/cbs_sei.c
        ${AVCODEC_GENERATED_SRC_PATH}/h264_levels.c
        ${AVCODEC_GENERATED_SRC_PATH}/h2645_parse.c
        ${AVCODEC_GENERATED_SRC_PATH}/vp8data.c
        ${FFMPEG_GENERATED_SRC_PATH}/libavutil/intmath.c)

# conditional headers based on architecture
if (EXISTS ${AVCODEC_GENERATED_SRC_PATH}/${CBS_ARCH_PATH}/mathops.h)
    configure_file(${AVCODEC_GENERATED_SRC_PATH}/${CBS_ARCH_PATH}/mathops.h
            ${CBS_INCLUDE_PATH}/${CBS_ARCH_PATH}/mathops.h COPYONLY)
    list(APPEND CBS_SOURCE_FILES ${CBS_INCLUDE_PATH}/${CBS_ARCH_PATH}/mathops.h)
endif()
if (EXISTS ${FFMPEG_GENERATED_SRC_PATH}/libavutil/${CBS_ARCH_PATH}/asm.h)
    configure_file(${FFMPEG_GENERATED_SRC_PATH}/libavutil/${CBS_ARCH_PATH}/asm.h
            ${CMAKE_BINARY_DIR}/include/libavutil/${CBS_ARCH_PATH}/asm.h COPYONLY)
    list(APPEND CBS_SOURCE_FILES ${CMAKE_BINARY_DIR}/include/libavutil/${CBS_ARCH_PATH}/asm.h)
endif()
if (EXISTS ${FFMPEG_GENERATED_SRC_PATH}/libavutil/${CBS_ARCH_PATH}/intmath.h)
    configure_file(${FFMPEG_GENERATED_SRC_PATH}/libavutil/${CBS_ARCH_PATH}/intmath.h
            ${CMAKE_BINARY_DIR}/include/libavutil/${CBS_ARCH_PATH}/intmath.h COPYONLY)
    list(APPEND CBS_SOURCE_FILES ${CMAKE_BINARY_DIR}/include/libavutil/${CBS_ARCH_PATH}/intmath.h)
endif()

include_directories(
        ${CMAKE_BINARY_DIR}/include
        ${FFMPEG_GENERATED_SRC_PATH})

add_library(cbs ${CBS_SOURCE_FILES})
target_compile_options(cbs PRIVATE -Wall -Wno-incompatible-pointer-types -Wno-format -Wno-format-extra-args)

install(DIRECTORY ${CMAKE_BINARY_DIR}/include
        DESTINATION ${CMAKE_INSTALL_PREFIX})
install(FILES ${CMAKE_BINARY_DIR}/libcbs.a
        DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/libcbs.pc.in
        ${CMAKE_BINARY_DIR}/libcbs.pc @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/libcbs.pc
        DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig)
