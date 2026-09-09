set(NV_CODEC_HEADERS_GENERATED_SRC_PATH ${CMAKE_CURRENT_BINARY_DIR}/FFmpeg/nv-codec-headers)

CPMGetPackage(nv_codec_headers_13_1)
file(COPY "${nv_codec_headers_13_1_SOURCE_DIR}/"
        DESTINATION "${NV_CODEC_HEADERS_GENERATED_SRC_PATH}"
        PATTERN ".git" EXCLUDE)

if(BUILD_FFMPEG_ALL_PATCHES OR BUILD_FFMPEG_NV_CODEC_HEADERS_PATCHES)
    CPMGetPackage(nv_codec_headers_11)
    CPMGetPackage(nv_codec_headers_12)
    CPMGetPackage(nv_codec_headers_13)

    UNIX_PATH(NV_CODEC_HEADERS_11_INCLUDE_DIR_UNIX "${nv_codec_headers_11_SOURCE_DIR}/include")
    UNIX_PATH(NV_CODEC_HEADERS_12_INCLUDE_DIR_UNIX "${nv_codec_headers_12_SOURCE_DIR}/include")
    UNIX_PATH(NV_CODEC_HEADERS_13_INCLUDE_DIR_UNIX "${nv_codec_headers_13_SOURCE_DIR}/include")
    UNIX_PATH(NV_CODEC_HEADERS_13_1_INCLUDE_DIR_UNIX "${nv_codec_headers_13_1_SOURCE_DIR}/include")
    set(FFMPEG_NVENC_SDK_ENV
            "NVENC_SDK_1100_INCLUDE=${NV_CODEC_HEADERS_11_INCLUDE_DIR_UNIX} \
NVENC_SDK_1200_INCLUDE=${NV_CODEC_HEADERS_12_INCLUDE_DIR_UNIX} \
NVENC_SDK_1300_INCLUDE=${NV_CODEC_HEADERS_13_INCLUDE_DIR_UNIX} \
NVENC_SDK_1310_INCLUDE=${NV_CODEC_HEADERS_13_1_INCLUDE_DIR_UNIX}")

    file(GLOB FFMPEG_NV_CODEC_HEADER_PATCH_FILES
            ${CMAKE_CURRENT_SOURCE_DIR}/patches/FFmpeg/FFmpeg/nv-codec-headers/*.patch)

    foreach(patch_file ${FFMPEG_NV_CODEC_HEADER_PATCH_FILES})
        APPLY_GIT_PATCH(${FFMPEG_GENERATED_SRC_PATH} ${patch_file})
    endforeach()
endif()

set(WORKING_DIR "${NV_CODEC_HEADERS_GENERATED_SRC_PATH}")
UNIX_PATH(WORKING_DIR_UNIX ${WORKING_DIR})
UNIX_PATH(DEST_DIR_UNIX ${CMAKE_CURRENT_BINARY_DIR})
add_custom_target(nv-codec-headers ALL
        COMMAND ${SHELL_CMD} "${MAKE_COMPILER_FLAGS} ${MAKE_EXECUTABLE} --jobs=${N_PROC}"
        # this will install the headers to the CMAKE_CURRENT_BINARY_DIR/usr/local
        COMMAND ${SHELL_CMD} "${MAKE_COMPILER_FLAGS} DESTDIR=${DEST_DIR_UNIX} ${MAKE_EXECUTABLE} install"
        WORKING_DIRECTORY ${WORKING_DIR}
        COMMENT "Target: nv-codec-headers"
        COMMAND_EXPAND_LISTS
        USES_TERMINAL
        VERBATIM
        BYPRODUCTS "usr/local/include/ffnvcodec"
)
add_dependencies(${CMAKE_PROJECT_NAME} nv-codec-headers)
install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/usr/local/include/ffnvcodec"
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/include
)
set(PKG_CONFIG_PATH "${CMAKE_CURRENT_BINARY_DIR_UNIX}/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}")
