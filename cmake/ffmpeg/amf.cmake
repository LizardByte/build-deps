if(BUILD_FFMPEG_ALL_PATCHES OR BUILD_FFMPEG_AMF_PATCHES)
    file(GLOB FFMPEG_AMF_PATCH_FILES ${CMAKE_CURRENT_SOURCE_DIR}/patches/FFmpeg/AMF/*.patch)

    foreach(patch_file ${FFMPEG_AMF_PATCH_FILES})
        APPLY_GIT_PATCH(${FFMPEG_GENERATED_SRC_PATH} ${patch_file})
    endforeach()
endif()

add_custom_target(amf ALL
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${CMAKE_CURRENT_SOURCE_DIR}/third-party/FFmpeg/AMF/amf/public/include"
            "${CMAKE_GENERATED_SRC_PATH}/include/AMF"
        COMMENT "Copying AMF headers"
)
