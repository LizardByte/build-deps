if(BUILD_FFMPEG_ALL_PATCHES OR BUILD_FFMPEG_X265_PATCHES)
    file(GLOB FFMPEG_X265_FILES ${CMAKE_CURRENT_SOURCE_DIR}/patches/FFmpeg/x265/*.patch)

    foreach(patch_file ${FFMPEG_SVT_X265_FILES})
        APPLY_GIT_PATCH(${FFMPEG_GENERATED_SRC_PATH} ${patch_file})
    endforeach()
endif()
