if(BUILD_FFMPEG_ALL_PATCHES OR BUILD_FFMPEG_SVT_AV1_PATCHES)
    file(GLOB FFMPEG_SVT_AV1_PATCH_FILES ${CMAKE_CURRENT_SOURCE_DIR}/patches/FFmpeg/SVT-AV1/*.patch)

    foreach(patch_file ${FFMPEG_SVT_AV1_PATCH_FILES})
        APPLY_GIT_PATCH(${FFMPEG_GENERATED_SRC_PATH} ${patch_file})
    endforeach()
endif()

# options for SVT-AV1
set(BUILD_APPS OFF CACHE BOOL "Build applications")
set(BUILD_DEC OFF CACHE BOOL "Build decoders")
set(ENABLE_AVX512 ON CACHE BOOL "Enable AVX512")
set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared libraries")

# build SVT-AV1
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/third-party/FFmpeg/SVT-AV1 SVT-AV1 SYSTEM)
add_dependencies(${CMAKE_PROJECT_NAME} SvtAv1Enc)
install(TARGETS SvtAv1Enc
        LIBRARY DESTINATION lib
)
