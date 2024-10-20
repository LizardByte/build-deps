if(BUILD_FFMPEG_ALL_PATCHES OR BUILD_FFMPEG_NV_CODEC_HEADERS_PATCHES)
    file(GLOB FFMPEG_NV_CODEC_HEADER_PATCH_FILES ${CMAKE_CURRENT_SOURCE_DIR}/patches/FFmpeg/nv-codec-headers/*.patch)

    foreach(patch_file ${FFMPEG_NV_CODEC_HEADER_PATCH_FILES})
        APPLY_GIT_PATCH(${FFMPEG_GENERATED_SRC_PATH} ${patch_file})
    endforeach()
endif()

set(WORKING_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third-party/FFmpeg/nv-codec-headers")
UNIX_PATH(WORKING_DIR_UNIX ${WORKING_DIR})
UNIX_PATH(DEST_DIR_UNIX ${CMAKE_CURRENT_BINARY_DIR})
add_custom_target(nv_codec_headers ALL
        COMMAND ${CMAKE_COMMAND} -E env MSYSTEM=${MSYSTEM} ${SHELL_CMD} ${SHELL_CMD_PREFIX} "cd ${WORKING_DIR_UNIX} && \
${MAKE_EXECUTABLE}"
        # this will install the headers to the CMAKE_CURRENT_BINARY_DIR/usr/local
        COMMAND ${CMAKE_COMMAND} -E env MSYSTEM=${MSYSTEM} ${SHELL_CMD} ${SHELL_CMD_PREFIX} "cd ${WORKING_DIR_UNIX} && \
DESTDIR=${DEST_DIR_UNIX} ${MAKE_EXECUTABLE} install"
        WORKING_DIRECTORY ${WORKING_DIR}
        COMMENT "Building nv-codec-headers"
        COMMAND_EXPAND_LISTS
        USES_TERMINAL
)
add_dependencies(${CMAKE_PROJECT_NAME} nv_codec_headers)
install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/usr/local/include/ffnvcodec"
        DESTINATION include
)
