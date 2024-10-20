if(BUILD_FFMPEG_ALL_PATCHES OR BUILD_FFMPEG_NV_CODEC_HEADERS_PATCHES)
    file(GLOB FFMPEG_NV_CODEC_HEADER_PATCH_FILES ${CMAKE_CURRENT_SOURCE_DIR}/patches/FFmpeg/nv-codec-headers/*.patch)

    foreach(patch_file ${FFMPEG_NV_CODEC_HEADER_PATCH_FILES})
        APPLY_GIT_PATCH(${FFMPEG_GENERATED_SRC_PATH} ${patch_file})
    endforeach()
endif()

# copy the source since we will patch the Makefile
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/third-party/FFmpeg/nv-codec-headers"
        DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")

add_custom_target(nv_codec_headers
        # run `sed -i 's/PREFIX =/PREFIX ?=/g' Makefile`
        COMMAND ${CMAKE_COMMAND} -E "sed -i 's/PREFIX =/PREFIX ?=/g' Makefile"
        COMMAND ${CMAKE_COMMAND} -E PREFIX=${CMAKE_CURRENT_BINARY_DIR} make
        COMMAND ${CMAKE_COMMAND} -E PREFIX=${CMAKE_CURRENT_BINARY_DIR} make install
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/nv-codec-headers
)
add_dependencies(${CMAKE_PROJECT_NAME} nv_codec_headers)
