if(BUILD_FFMPEG_ALL_PATCHES OR BUILD_FFMPEG_X264_PATCHES)
    file(GLOB FFMPEG_X264_FILES ${CMAKE_CURRENT_SOURCE_DIR}/patches/FFmpeg/x264/*.patch)

    foreach(patch_file ${FFMPEG_SVT_X264_FILES})
        APPLY_GIT_PATCH(${FFMPEG_GENERATED_SRC_PATH} ${patch_file})
    endforeach()
endif()
