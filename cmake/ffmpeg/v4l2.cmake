set(FFMPEG_V4L2_PRIVATE_HEADERS
        ${ffmpeg_SOURCE_DIR}/libavcodec/v4l2_buffers.h
        ${ffmpeg_SOURCE_DIR}/libavcodec/v4l2_context.h
        ${ffmpeg_SOURCE_DIR}/libavcodec/v4l2_fmt.h
        ${ffmpeg_SOURCE_DIR}/libavcodec/v4l2_m2m.h)

install(FILES ${FFMPEG_V4L2_PRIVATE_HEADERS}
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/include/libavcodec)
