if(BUILD_FFMPEG_ALL_PATCHES OR BUILD_FFMPEG_CBS_PATCHES)
    file(GLOB FFMPEG_CBS_PATCH_FILES ${CMAKE_CURRENT_SOURCE_DIR}/patches/FFmpeg/cbs/*.patch)

    foreach(patch_file ${FFMPEG_CBS_PATCH_FILES})
        APPLY_GIT_PATCH(${FFMPEG_GENERATED_SRC_PATH} ${patch_file})
    endforeach()
endif()

set(CBS_INCLUDE_PATH ${CMAKE_CURRENT_BINARY_DIR}/include/cbs)

if(${arch} STREQUAL "aarch64" OR ${arch} STREQUAL "arm64")
    set(CBS_ARCH_PATH arm)
elseif (${arch} STREQUAL "ppc64le")
    set(CBS_ARCH_PATH ppc)
elseif (${arch} STREQUAL "amd64" OR ${arch} STREQUAL "x86_64")
    set(CBS_ARCH_PATH x86)
elseif (${arch} STREQUAL "mips")
    set(CBS_ARCH_PATH mips)
else()
    message(FATAL_ERROR "Unsupported system processor:" ${CMAKE_SYSTEM_PROCESSOR})
endif()

set(FFMPEG_EXTRA_CONFIGURE
        ${FFMPEG_EXTRA_CONFIGURE}
        --disable-all
        --disable-autodetect
        --disable-iconv
        --enable-gpl
        --enable-static
        --enable-avcodec
        --enable-avutil
        --enable-bsfs  # ensure config.h will have CONFIG_CBS_ flags
        --enable-encoder=libsvtav1
        --enable-encoder=libx264,libx265
        --enable-libsvtav1
        --enable-libx264
        --enable-libx265
        --enable-swscale
)

if(WIN32)
    set(FFMPEG_EXTRA_CONFIGURE
            ${FFMPEG_EXTRA_CONFIGURE}
            --enable-amf
            --enable-cuda
            --enable-d3d11va
            --enable-encoder=h264_amf,hevc_amf,av1_amf
            --enable-encoder=h264_mf,hevc_mf
            --enable-encoder=h264_nvenc,hevc_nvenc,av1_nvenc
            --enable-encoder=h264_qsv,hevc_qsv,av1_qsv
            --enable-ffnvcodec
            --enable-libvpl
            --enable-nvenc
            --enable-mediafoundation
    )
elseif(APPLE)
    set(FFMPEG_EXTRA_CONFIGURE
            ${FFMPEG_EXTRA_CONFIGURE}
            --enable-encoder=h264_videotoolbox,hevc_videotoolbox
            --enable-videotoolbox
    )
elseif(UNIX)
    set(FFMPEG_EXTRA_CONFIGURE
            ${FFMPEG_EXTRA_CONFIGURE}
            --enable-amf
            --enable-cuda
            --enable-cuda_llvm
            --enable-encoder=h264_amf,hevc_amf,av1_amf
            --enable-encoder=h264_nvenc,hevc_nvenc,av1_nvenc
            --enable-encoder=h264_vaapi,hevc_vaapi,av1_vaapi
            --enable-encoder=h264_v4l2m2m
            --enable-ffnvcodec
            --enable-nvenc
            --enable-v4l2_m2m
            --enable-vaapi
    )
endif()

if(CMAKE_CROSSCOMPILING)
    set(FFMPEG_EXTRA_CONFIGURE
            ${FFMPEG_EXTRA_CONFIGURE}
            --arch=${arch}
            --enable-cross-compile
    )
endif()

set(WORKING_DIR ${FFMPEG_GENERATED_SRC_PATH})
UNIX_PATH(WORKING_DIR_UNIX ${WORKING_DIR})
add_custom_target(ffmpeg ALL
        COMMAND ${CMAKE_COMMAND} -E env MSYSTEM=${MSYSTEM} ${SHELL_CMD} ${SHELL_CMD_PREFIX} "cd ${WORKING_DIR_UNIX} && \
./configure \
--prefix=${CMAKE_CURRENT_BINARY_DIR_UNIX}/FFmpeg \
--cc=${CMAKE_C_COMPILER} \
--cxx=${CMAKE_CXX_COMPILER} \
--ar=${CMAKE_AR} \
--ranlib=${CMAKE_RANLIB} \
--optflags=${CMAKE_C_FLAGS} \
${FFMPEG_EXTRA_CONFIGURE}"
        # TODO: make command fails, unable to find "cbs/config.h"
#        COMMAND ${CMAKE_COMMAND} -E env MSYSTEM=${MSYSTEM} ${SHELL_CMD} ${SHELL_CMD_PREFIX} "cd ${WORKING_DIR_UNIX} && \
#make"
#        COMMAND ${CMAKE_COMMAND} -E env MSYSTEM=${MSYSTEM} ${SHELL_CMD} ${SHELL_CMD_PREFIX} "cd ${WORKING_DIR_UNIX} && \
#make install"
        WORKING_DIRECTORY ${WORKING_DIR}
        COMMENT "Configuring ffmpeg"
        COMMAND_EXPAND_LISTS
        USES_TERMINAL
)
if(BUILD_FFMPEG_AMF)
    add_dependencies(ffmpeg amf)
endif()
if(BUILD_FFMPEG_NV_CODEC_HEADERS)
    add_dependencies(ffmpeg nv_codec_headers)
endif()
if(BUILD_FFMPEG_SVT_AV1)
    add_dependencies(ffmpeg SvtAv1Enc)
endif()
if(BUILD_FFMPEG_X264)
    add_dependencies(ffmpeg x264)
endif()
if(BUILD_FFMPEG_X265)
    add_dependencies(ffmpeg x265-static)
endif()
add_dependencies(${CMAKE_PROJECT_NAME} ffmpeg)








#set(FFMPEG_CBS_HEADERS
#        ${AVCODEC_GENERATED_SRC_PATH}/av1.h
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs_av1.h
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs_bsf.h
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs.h
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs_h2645.h
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs_h264.h
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs_h265.h
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs_jpeg.h
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs_mpeg2.h
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs_sei.h
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs_vp8.h
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs_vp9.h
#        ${AVCODEC_GENERATED_SRC_PATH}/codec_desc.h
#        ${AVCODEC_GENERATED_SRC_PATH}/codec_id.h
#        ${AVCODEC_GENERATED_SRC_PATH}/codec_par.h
#        ${AVCODEC_GENERATED_SRC_PATH}/defs.h
#        ${AVCODEC_GENERATED_SRC_PATH}/get_bits.h
#        ${AVCODEC_GENERATED_SRC_PATH}/h264_levels.h
#        ${AVCODEC_GENERATED_SRC_PATH}/h2645_parse.h
#        ${AVCODEC_GENERATED_SRC_PATH}/h264.h
#        ${AVCODEC_GENERATED_SRC_PATH}/hevc/hevc.h
#        ${AVCODEC_GENERATED_SRC_PATH}/mathops.h
#        ${AVCODEC_GENERATED_SRC_PATH}/packet.h
#        ${AVCODEC_GENERATED_SRC_PATH}/sei.h
#        ${AVCODEC_GENERATED_SRC_PATH}/version_major.h
#        ${AVCODEC_GENERATED_SRC_PATH}/vlc.h
#        ${FFMPEG_GENERATED_SRC_PATH}/config.h
#        ${FFMPEG_GENERATED_SRC_PATH}/libavutil/attributes.h
#        ${FFMPEG_GENERATED_SRC_PATH}/libavutil/attributes_internal.h
#        ${FFMPEG_GENERATED_SRC_PATH}/libavutil/intmath.h
#)
#
#set(CBS_SOURCE_FILES
#        ${CBS_INCLUDE_PATH}/av1.h
#        ${CBS_INCLUDE_PATH}/cbs_av1.h
#        ${CBS_INCLUDE_PATH}/cbs_bsf.h
#        ${CBS_INCLUDE_PATH}/cbs.h
#        ${CBS_INCLUDE_PATH}/cbs_h2645.h
#        ${CBS_INCLUDE_PATH}/cbs_h264.h
#        ${CBS_INCLUDE_PATH}/cbs_h265.h
#        ${CBS_INCLUDE_PATH}/cbs_jpeg.h
#        ${CBS_INCLUDE_PATH}/cbs_mpeg2.h
#        ${CBS_INCLUDE_PATH}/cbs_sei.h
#        ${CBS_INCLUDE_PATH}/cbs_vp8.h
#        ${CBS_INCLUDE_PATH}/cbs_vp9.h
#        ${CBS_INCLUDE_PATH}/codec_desc.h
#        ${CBS_INCLUDE_PATH}/codec_id.h
#        ${CBS_INCLUDE_PATH}/codec_par.h
#        ${CBS_INCLUDE_PATH}/defs.h
#        ${CBS_INCLUDE_PATH}/get_bits.h
#        ${CBS_INCLUDE_PATH}/h264_levels.h
#        ${CBS_INCLUDE_PATH}/h2645_parse.h
#        ${CBS_INCLUDE_PATH}/h264.h
#        ${CBS_INCLUDE_PATH}/hevc/hevc.h
#        ${CBS_INCLUDE_PATH}/mathops.h
#        ${CBS_INCLUDE_PATH}/packet.h
#        ${CBS_INCLUDE_PATH}/sei.h
#        ${CBS_INCLUDE_PATH}/version_major.h
#        ${CBS_INCLUDE_PATH}/vlc.h
#        ${CMAKE_CURRENT_BINARY_DIR}/include/libavutil/intmath.h
#        ${CBS_INCLUDE_PATH}/config.h
#
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs.c
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs_h2645.c
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs_av1.c
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs_vp8.c
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs_vp9.c
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs_mpeg2.c
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs_jpeg.c
#        ${AVCODEC_GENERATED_SRC_PATH}/cbs_sei.c
#        ${AVCODEC_GENERATED_SRC_PATH}/h264_levels.c
#        ${AVCODEC_GENERATED_SRC_PATH}/h2645_parse.c
#        ${AVCODEC_GENERATED_SRC_PATH}/vp8data.c
#        ${FFMPEG_GENERATED_SRC_PATH}/libavutil/intmath.c)
#
## conditional headers based on architecture
#if (EXISTS ${AVCODEC_GENERATED_SRC_PATH}/${CBS_ARCH_PATH}/mathops.h)
#    configure_file(${AVCODEC_GENERATED_SRC_PATH}/${CBS_ARCH_PATH}/mathops.h
#            ${CBS_INCLUDE_PATH}/${CBS_ARCH_PATH}/mathops.h COPYONLY)
#    list(APPEND CBS_SOURCE_FILES ${CBS_INCLUDE_PATH}/${CBS_ARCH_PATH}/mathops.h)
#endif()
#if (EXISTS ${FFMPEG_GENERATED_SRC_PATH}/libavutil/${CBS_ARCH_PATH}/asm.h)
#    configure_file(${FFMPEG_GENERATED_SRC_PATH}/libavutil/${CBS_ARCH_PATH}/asm.h
#            ${CMAKE_CURRENT_BINARY_DIR}/include/libavutil/${CBS_ARCH_PATH}/asm.h COPYONLY)
#    list(APPEND CBS_SOURCE_FILES ${CMAKE_CURRENT_BINARY_DIR}/include/libavutil/${CBS_ARCH_PATH}/asm.h)
#endif()
#if (EXISTS ${FFMPEG_GENERATED_SRC_PATH}/libavutil/${CBS_ARCH_PATH}/intmath.h)
#    configure_file(${FFMPEG_GENERATED_SRC_PATH}/libavutil/${CBS_ARCH_PATH}/intmath.h
#            ${CMAKE_CURRENT_BINARY_DIR}/include/libavutil/${CBS_ARCH_PATH}/intmath.h COPYONLY)
#    list(APPEND CBS_SOURCE_FILES ${CMAKE_CURRENT_BINARY_DIR}/include/libavutil/${CBS_ARCH_PATH}/intmath.h)
#endif()
#
#include_directories(
#        ${CMAKE_CURRENT_BINARY_DIR}/include
#        ${FFMPEG_GENERATED_SRC_PATH})
#
#add_library(cbs ${CBS_SOURCE_FILES})
#target_compile_options(cbs PRIVATE -Wall -Wno-incompatible-pointer-types -Wno-format -Wno-format-extra-args)
#add_dependencies(cbs cbs_configure)
#add_dependencies(${CMAKE_PROJECT_NAME} cbs)
#
#install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include
#        DESTINATION ${CMAKE_INSTALL_PREFIX})
#install(FILES ${CMAKE_CURRENT_BINARY_DIR}/libcbs.a
#        DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)
#configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/libcbs.pc.in
#        ${CMAKE_CURRENT_BINARY_DIR}/libcbs.pc @ONLY)
#install(FILES ${CMAKE_CURRENT_BINARY_DIR}/libcbs.pc
#        DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig)
