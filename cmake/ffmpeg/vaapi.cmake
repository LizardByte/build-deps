if(BUILD_FFMPEG_ALL_PATCHES OR BUILD_FFMPEG_VAAPI_PATCHES)
    file(GLOB FFMPEG_VAAPI_FILES ${CMAKE_CURRENT_SOURCE_DIR}/patches/FFmpeg/FFmpeg/VAAPI/*.patch)

    foreach(patch_file ${FFMPEG_VAAPI_FILES})
        APPLY_GIT_PATCH(${FFMPEG_GENERATED_SRC_PATH} ${patch_file})
    endforeach()
endif()
