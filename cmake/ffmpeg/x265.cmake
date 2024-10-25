if(BUILD_FFMPEG_ALL_PATCHES OR BUILD_FFMPEG_X265_PATCHES)
    file(GLOB FFMPEG_X265_FILES ${CMAKE_CURRENT_SOURCE_DIR}/patches/FFmpeg/x265/*.patch)

    foreach(patch_file ${FFMPEG_SVT_X265_FILES})
        APPLY_GIT_PATCH(${FFMPEG_GENERATED_SRC_PATH} ${patch_file})
    endforeach()
endif()

# options for x265
set(ENABLE_CLI OFF CACHE BOOL "Enable CLI")
set(ENABLE_SHARED OFF CACHE BOOL "Enable shared libraries")
set(STATIC_LINK_CRT ON CACHE BOOL "Static link CRT")

# not currently supported for aarch64
if(${arch} STREQUAL "amd64" OR ${arch} STREQUAL "x86_64")
    set(ENABLE_HDR10_PLUS ON CACHE BOOL "Enable HDR10+ support")
endif()

# build x265
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/third-party/FFmpeg/x265_git/source x265 SYSTEM)
add_dependencies(${CMAKE_PROJECT_NAME} x265-static)
set(X265_HEADER_FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/third-party/FFmpeg/x265_git/source/x265.h
        ${CMAKE_CURRENT_BINARY_DIR}/x265/x265_config.h
)
set_target_properties(x265-static PROPERTIES PUBLIC_HEADER "${X265_HEADER_FILES}")
install(TARGETS x265-static
        PUBLIC_HEADER DESTINATION include
)
