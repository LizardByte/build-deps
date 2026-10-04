set(FFMPEG_PATCH_FILES)

if(BUILD_FFMPEG_CBS AND (BUILD_FFMPEG_ALL_PATCHES OR BUILD_FFMPEG_CBS_PATCHES))
    file(GLOB FFMPEG_CBS_PATCH_FILES ${CMAKE_CURRENT_SOURCE_DIR}/patches/FFmpeg/FFmpeg/cbs/*.patch)
    list(APPEND FFMPEG_PATCH_FILES ${FFMPEG_CBS_PATCH_FILES})
endif()

if(BUILD_FFMPEG_ALL_PATCHES OR BUILD_FFMPEG_LIBAVUTIL_PATCHES)
    file(GLOB FFMPEG_LIBAVUTIL_PATCH_FILES ${CMAKE_CURRENT_SOURCE_DIR}/patches/FFmpeg/FFmpeg/libavutil/*.patch)
    list(APPEND FFMPEG_PATCH_FILES ${FFMPEG_LIBAVUTIL_PATCH_FILES})
endif()

foreach(patch_file ${FFMPEG_PATCH_FILES})
    APPLY_GIT_PATCH(${FFMPEG_GENERATED_SRC_PATH} ${patch_file})
endforeach()

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

list(APPEND FFMPEG_EXTRA_CONFIGURE
        --prefix=${CMAKE_CURRENT_BINARY_DIR_UNIX}/FFmpeg
        --pkg-config=${PKG_CONFIG_EXECUTABLE}
        --extra-cflags='${CMAKE_C_FLAGS}'
        --extra-cxxflags='${CMAKE_CXX_FLAGS}'
        --cc=${CMAKE_C_COMPILER}
        --cxx=${CMAKE_CXX_COMPILER}
        --ar=${CMAKE_AR}
        --ranlib=${CMAKE_RANLIB}
        --pkg-config-flags='--static'
        --extra-cflags='-I${CMAKE_CURRENT_BINARY_DIR_UNIX}/usr/local/include'
        --extra-cflags='-I${CMAKE_CURRENT_BINARY_DIR_UNIX}/x264/include'
        --extra-cflags='-I${CMAKE_CURRENT_BINARY_DIR_UNIX}/libva/include'
        --extra-cflags='-I${CMAKE_CURRENT_BINARY_DIR_UNIX}/vulkan/include'
        --extra-ldflags='-L${CMAKE_CURRENT_BINARY_DIR_UNIX}/usr/local/lib'
        --extra-ldflags='-L${CMAKE_CURRENT_BINARY_DIR_UNIX}/x264/lib'
        --extra-ldflags='-L${CMAKE_CURRENT_BINARY_DIR_UNIX}/libva/lib'
        --extra-ldflags='-L${CMAKE_CURRENT_BINARY_DIR_UNIX}/vulkan/lib'
        --extra-libs='-lpthread -lm'
        --disable-all
        --disable-autodetect
        --disable-iconv
        --enable-static
        --enable-avcodec
        --enable-avutil
        --enable-bsfs  # ensure config.h will have CONFIG_CBS_ flags
        --enable-swscale
)

if(BUILD_FFMPEG_ENCODERS)
    list(APPEND FFMPEG_EXTRA_CONFIGURE --enable-gpl --enable-encoders)
endif()

if(BUILD_FFMPEG_DECODERS)
    list(APPEND FFMPEG_EXTRA_CONFIGURE
            --enable-decoders
            --enable-parsers
            --enable-hwaccels)
    if(BUILD_FFMPEG_DAV1D)
        list(APPEND FFMPEG_EXTRA_CONFIGURE --enable-libdav1d --enable-decoder=libdav1d)
    endif()
endif()
if(BUILD_FFMPEG_OPUS)
    list(APPEND FFMPEG_EXTRA_CONFIGURE --enable-libopus)
endif()

if(BUILD_FFMPEG_TOOLS)
    list(APPEND FFMPEG_EXTRA_CONFIGURE
            --enable-avformat
            --enable-avfilter
            --enable-swresample
            --enable-ffmpeg
            --enable-ffprobe
            --enable-demuxers
            --enable-muxers
            --enable-filters
            --enable-network
            --enable-protocols)
    if(WIN32)
        # The tools are distributed as executables, including their compiler runtimes.
        list(APPEND FFMPEG_EXTRA_CONFIGURE --extra-ldflags='-static')
    endif()
endif()
if(NOT BUILD_FFMPEG_TOOLS)
    list(APPEND FFMPEG_EXTRA_CONFIGURE --disable-network)
endif()

if(BUILD_FFMPEG_AMF)
    list(APPEND FFMPEG_EXTRA_CONFIGURE --enable-amf)
    if(BUILD_FFMPEG_ENCODERS)
        list(APPEND FFMPEG_EXTRA_CONFIGURE --enable-encoder=h264_amf,hevc_amf,av1_amf)
    endif()
endif()
if(BUILD_FFMPEG_MF)
    list(APPEND FFMPEG_EXTRA_CONFIGURE
            --enable-encoder=h264_mf,hevc_mf,av1_mf
            --enable-mediafoundation
    )
endif()
if(BUILD_FFMPEG_NV_CODEC_HEADERS)
    list(APPEND FFMPEG_EXTRA_CONFIGURE
            --enable-cuda
            --enable-ffnvcodec
    )
    if(BUILD_FFMPEG_ENCODERS)
        list(APPEND FFMPEG_EXTRA_CONFIGURE --enable-nvenc --enable-encoder=h264_nvenc,hevc_nvenc,av1_nvenc)
    endif()
    if(BUILD_FFMPEG_DECODERS)
        list(APPEND FFMPEG_EXTRA_CONFIGURE --enable-nvdec --enable-cuvid)
    endif()
    if(UNIX AND NOT APPLE AND NOT FREEBSD AND BUILD_FFMPEG_CUDA_LLVM)
        list(APPEND FFMPEG_EXTRA_CONFIGURE
                --enable-cuda_llvm
        )
    endif()
endif()
if(BUILD_FFMPEG_SVT_AV1)
    list(APPEND FFMPEG_EXTRA_CONFIGURE
            --enable-libsvtav1
            --enable-encoder=libsvtav1
    )
endif()
if(BUILD_FFMPEG_LIBVA)
    list(APPEND FFMPEG_EXTRA_CONFIGURE --enable-vaapi)
    if(BUILD_FFMPEG_ENCODERS)
        list(APPEND FFMPEG_EXTRA_CONFIGURE --enable-encoder=h264_vaapi,hevc_vaapi,av1_vaapi,mpeg2_vaapi)
    endif()
endif()
if(BUILD_FFMPEG_VULKAN)
    list(APPEND FFMPEG_EXTRA_CONFIGURE --enable-vulkan)
    if(BUILD_FFMPEG_ENCODERS)
        list(APPEND FFMPEG_EXTRA_CONFIGURE --enable-encoder=h264_vulkan,hevc_vulkan,av1_vulkan)
    endif()
endif()
if(BUILD_FFMPEG_V4L2)
    list(APPEND FFMPEG_EXTRA_CONFIGURE --enable-v4l2_m2m)
    if(BUILD_FFMPEG_ENCODERS)
        list(APPEND FFMPEG_EXTRA_CONFIGURE --enable-encoder=h264_v4l2m2m,hevc_v4l2m2m,av1_v4l2m2m)
    endif()
endif()
if(BUILD_FFMPEG_X264)
    list(APPEND FFMPEG_EXTRA_CONFIGURE
            --enable-libx264
            --enable-encoder=libx264
    )
endif()
if(BUILD_FFMPEG_X265)
    list(APPEND FFMPEG_EXTRA_CONFIGURE
            --enable-libx265
            --enable-encoder=libx265
    )
endif()

# OS specific options not defined by the above BUILD_FFMPEG_* options
if(WIN32)
    list(APPEND FFMPEG_EXTRA_CONFIGURE
            --enable-d3d11va
    )
    if(BUILD_FFMPEG_DECODERS)
        list(APPEND FFMPEG_EXTRA_CONFIGURE --enable-d3d12va --enable-dxva2)
    endif()
    if(BUILD_FFMPEG_ENCODERS OR BUILD_FFMPEG_DECODERS)
        string(TOLOWER ${MSYSTEM} FFMPEG_MSYSTEM_DIRECTORY)
        find_file(FFMPEG_VPL_STATIC_LIBRARY NAMES libvpl.a
                HINTS "${MSYS2_ROOT}/${FFMPEG_MSYSTEM_DIRECTORY}/lib" REQUIRED)
        install(FILES ${FFMPEG_VPL_STATIC_LIBRARY} DESTINATION ${FFMPEG_INSTALL_PREFIX}/lib)
        install(DIRECTORY "${MSYS2_ROOT}/${FFMPEG_MSYSTEM_DIRECTORY}/share/licenses/libvpl/"
                DESTINATION ${FFMPEG_INSTALL_PREFIX}/share/licenses/vpl)
        # Static oneVPL is implemented in C++; FFmpeg probes it with the C compiler.
        if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
            list(APPEND FFMPEG_EXTRA_CONFIGURE --extra-libs='-lc++')
        else()
            list(APPEND FFMPEG_EXTRA_CONFIGURE --extra-libs='-lstdc++')
        endif()
        list(APPEND FFMPEG_EXTRA_CONFIGURE --enable-libvpl)
        if(BUILD_FFMPEG_ENCODERS)
            list(APPEND FFMPEG_EXTRA_CONFIGURE --enable-encoder=h264_qsv,hevc_qsv,av1_qsv,mpeg2_qsv)
        endif()
    endif()
elseif(APPLE)
    list(APPEND FFMPEG_EXTRA_CONFIGURE
            --enable-videotoolbox
    )
    if(BUILD_FFMPEG_ENCODERS)
        list(APPEND FFMPEG_EXTRA_CONFIGURE --enable-encoder=h264_videotoolbox,hevc_videotoolbox)
    endif()
endif()

if(CMAKE_CROSSCOMPILING)
    list(APPEND FFMPEG_EXTRA_CONFIGURE
            --arch=${arch}
            --enable-cross-compile
            --target-os=${TARGET_OS}
    )
    if(UNIX AND NOT APPLE)
        list(APPEND FFMPEG_EXTRA_CONFIGURE
                --cross-prefix=/usr/bin/${CMAKE_C_COMPILER_TARGET}-
        )
    endif()
endif()

# convert list to string
# configure command will only take the first argument if not converted to string
string(REPLACE ";" " " FFMPEG_EXTRA_CONFIGURE "${FFMPEG_EXTRA_CONFIGURE}")
message(STATUS "FFmpeg configure options: ${FFMPEG_EXTRA_CONFIGURE}")

set(WORKING_DIR "${FFMPEG_GENERATED_SRC_PATH}")
UNIX_PATH(WORKING_DIR_UNIX ${WORKING_DIR})
# Toolchain files can set the compiler as a normal variable rather than a cache entry.
file(GENERATE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-compiler.txt CONTENT "${CMAKE_C_COMPILER}\n")
add_custom_target(ffmpeg ALL
        COMMAND ${SHELL_CMD} "PKG_CONFIG_PATH='${PKG_CONFIG_PATH}' \
./configure \
${FFMPEG_EXTRA_CONFIGURE}"
        COMMAND ${SHELL_CMD} "${FFMPEG_NVENC_SDK_ENV} ${MAKE_EXECUTABLE} --jobs=${N_PROC}"
        COMMAND ${SHELL_CMD} "${FFMPEG_NVENC_SDK_ENV} ${MAKE_EXECUTABLE} install"
        WORKING_DIRECTORY ${WORKING_DIR}
        COMMENT "Target: FFmpeg"
        COMMAND_EXPAND_LISTS
        USES_TERMINAL
        VERBATIM
)
if(BUILD_FFMPEG_AMF)
    add_dependencies(ffmpeg amf)
endif()
if(BUILD_FFMPEG_NV_CODEC_HEADERS)
    add_dependencies(ffmpeg nv-codec-headers)
endif()
if(BUILD_FFMPEG_SVT_AV1)
    add_dependencies(ffmpeg SvtAv1)
endif()
if(BUILD_FFMPEG_LIBVA)
    add_dependencies(ffmpeg libva)
endif()
if(BUILD_FFMPEG_VULKAN)
    add_dependencies(ffmpeg vulkan-loader)
endif()
if(BUILD_FFMPEG_X264)
    add_dependencies(ffmpeg x264)
endif()
if(BUILD_FFMPEG_X265)
    add_dependencies(ffmpeg x265)
endif()
add_dependencies(${CMAKE_PROJECT_NAME} ffmpeg)
if(BUILD_FFMPEG_DECODERS AND BUILD_FFMPEG_DAV1D)
    add_dependencies(ffmpeg dav1d)
endif()
if(BUILD_FFMPEG_OPUS)
    add_dependencies(ffmpeg opus)
endif()
install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/FFmpeg/include/"
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/include)
install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/FFmpeg/lib/"
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/lib)
if(BUILD_FFMPEG_TOOLS)
    install(PROGRAMS
            "${CMAKE_CURRENT_BINARY_DIR}/FFmpeg/bin/ffmpeg${CMAKE_EXECUTABLE_SUFFIX}"
            "${CMAKE_CURRENT_BINARY_DIR}/FFmpeg/bin/ffprobe${CMAKE_EXECUTABLE_SUFFIX}"
            DESTINATION ${FFMPEG_INSTALL_PREFIX}/bin)
endif()
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/relocate-pkgconfig.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/relocate-pkgconfig.cmake @ONLY)
# Run after the pkg-config files from every component have been installed.
install(SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/relocate-pkgconfig.cmake)
install(FILES ${FFMPEG_GENERATED_SRC_PATH}/COPYING.LGPLv2.1
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/share/licenses/ffmpeg)
if(BUILD_FFMPEG_ENCODERS)
    install(FILES ${FFMPEG_GENERATED_SRC_PATH}/COPYING.GPLv2
            DESTINATION ${FFMPEG_INSTALL_PREFIX}/share/licenses/ffmpeg)
endif()

if(NOT BUILD_FFMPEG_CBS)
    return()
endif()


#
# cbs
#
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/libcbs.pc.in
        ${CMAKE_CURRENT_BINARY_DIR}/libcbs.pc @ONLY)

set(AVCODEC_GENERATED_SRC_PATH ${FFMPEG_GENERATED_SRC_PATH}/libavcodec)
set(AVUTIL_GENERATED_SRC_PATH ${FFMPEG_GENERATED_SRC_PATH}/libavutil)

set(EXTRA_FFMPEG_INCLUDE_FILES
        ${FFMPEG_GENERATED_SRC_PATH}/config.h
)
set(EXTRA_AVCODEC_INCLUDE_FILES
        ${AVCODEC_GENERATED_SRC_PATH}/av1.h
        ${AVCODEC_GENERATED_SRC_PATH}/cbs_av1.h
        ${AVCODEC_GENERATED_SRC_PATH}/cbs_bsf.h
        ${AVCODEC_GENERATED_SRC_PATH}/cbs.h
        ${AVCODEC_GENERATED_SRC_PATH}/cbs_h2645.h
        ${AVCODEC_GENERATED_SRC_PATH}/cbs_h264.h
        ${AVCODEC_GENERATED_SRC_PATH}/cbs_h265.h
        ${AVCODEC_GENERATED_SRC_PATH}/cbs_jpeg.h
        ${AVCODEC_GENERATED_SRC_PATH}/cbs_mpeg2.h
        ${AVCODEC_GENERATED_SRC_PATH}/cbs_sei.h
        ${AVCODEC_GENERATED_SRC_PATH}/cbs_vp8.h
        ${AVCODEC_GENERATED_SRC_PATH}/cbs_vp9.h
        ${AVCODEC_GENERATED_SRC_PATH}/codec_desc.h
        ${AVCODEC_GENERATED_SRC_PATH}/codec_id.h
        ${AVCODEC_GENERATED_SRC_PATH}/codec_par.h
        ${AVCODEC_GENERATED_SRC_PATH}/defs.h
        ${AVCODEC_GENERATED_SRC_PATH}/get_bits.h
        ${AVCODEC_GENERATED_SRC_PATH}/h264_levels.h
        ${AVCODEC_GENERATED_SRC_PATH}/h2645_parse.h
        ${AVCODEC_GENERATED_SRC_PATH}/h264.h
        ${AVCODEC_GENERATED_SRC_PATH}/mathops.h
        ${AVCODEC_GENERATED_SRC_PATH}/packet.h
        ${AVCODEC_GENERATED_SRC_PATH}/sei.h
        ${AVCODEC_GENERATED_SRC_PATH}/version_major.h
        ${AVCODEC_GENERATED_SRC_PATH}/vlc.h
)
set(EXTRA_AVCODEC_HEVC_INCLUDE_FILES
        ${AVCODEC_GENERATED_SRC_PATH}/hevc/hevc.h
)
set(EXTRA_AVUTIL_INCLUDE_FILES
        ${AVUTIL_GENERATED_SRC_PATH}/attributes.h
        ${AVUTIL_GENERATED_SRC_PATH}/attributes_internal.h
        ${AVUTIL_GENERATED_SRC_PATH}/intmath.h
)

set(CBS_SOURCE_FILES
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
        ${AVUTIL_GENERATED_SRC_PATH}/intmath.c
)

add_library(cbs STATIC ${CBS_SOURCE_FILES})
target_include_directories(cbs PRIVATE
        ${FFMPEG_GENERATED_SRC_PATH}
)
target_compile_options(cbs PRIVATE -Wall -Wno-incompatible-pointer-types -Wno-format -Wno-format-extra-args)
add_dependencies(cbs ffmpeg)
add_dependencies(${CMAKE_PROJECT_NAME} cbs)

# install cbs target headers
install(FILES ${EXTRA_FFMPEG_INCLUDE_FILES}
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/include)
install(FILES ${EXTRA_AVCODEC_INCLUDE_FILES}
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/include/libavcodec)
install(FILES ${EXTRA_AVCODEC_HEVC_INCLUDE_FILES}
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/include/libavcodec/hevc)
install(FILES ${EXTRA_AVUTIL_INCLUDE_FILES}
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/include/libavutil)
install(TARGETS cbs
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/lib)

# conditional headers based on architecture
if (EXISTS ${AVCODEC_GENERATED_SRC_PATH}/${CBS_ARCH_PATH}/mathops.h)
    install(FILES ${AVCODEC_GENERATED_SRC_PATH}/${CBS_ARCH_PATH}/mathops.h
            DESTINATION ${FFMPEG_INSTALL_PREFIX}/include/libavcodec/${CBS_ARCH_PATH})
endif()
if (EXISTS ${AVUTIL_GENERATED_SRC_PATH}/${CBS_ARCH_PATH}/asm.h)
    install(FILES ${AVUTIL_GENERATED_SRC_PATH}/${CBS_ARCH_PATH}/asm.h
            DESTINATION ${FFMPEG_INSTALL_PREFIX}/include/libavutil/${CBS_ARCH_PATH})
endif()
if (EXISTS ${AVUTIL_GENERATED_SRC_PATH}/${CBS_ARCH_PATH}/intmath.h)
    install(FILES ${AVUTIL_GENERATED_SRC_PATH}/${CBS_ARCH_PATH}/intmath.h
            DESTINATION ${FFMPEG_INSTALL_PREFIX}/include/libavutil/${CBS_ARCH_PATH})
endif()

# install pkg-config file
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/libcbs.pc
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/lib/pkgconfig)
# libcbs is installed after the FFmpeg libraries.
install(SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/relocate-pkgconfig.cmake)
