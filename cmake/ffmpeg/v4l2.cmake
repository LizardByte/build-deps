if(BUILD_FFMPEG_ALL_PATCHES OR BUILD_FFMPEG_V4L2_PATCHES)
    file(GLOB FFMPEG_V4L2_PATCH_FILES ${CMAKE_CURRENT_SOURCE_DIR}/patches/FFmpeg/FFmpeg/v4l2/*.patch)
    foreach(patch_file ${FFMPEG_V4L2_PATCH_FILES})
        APPLY_GIT_PATCH(${FFMPEG_GENERATED_SRC_PATH} ${patch_file})
    endforeach()
endif()

set(FFMPEG_V4L2_PRIVATE_HEADERS
        ${FFMPEG_GENERATED_SRC_PATH}/libavcodec/v4l2_buffers.h
        ${FFMPEG_GENERATED_SRC_PATH}/libavcodec/v4l2_context.h
        ${FFMPEG_GENERATED_SRC_PATH}/libavcodec/v4l2_fmt.h
        ${FFMPEG_GENERATED_SRC_PATH}/libavcodec/v4l2_m2m.h)

install(FILES ${FFMPEG_V4L2_PRIVATE_HEADERS}
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/include/libavcodec)
