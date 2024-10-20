file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/third-party/FFmpeg/FFmpeg DESTINATION ${CMAKE_GENERATED_SRC_PATH})

set(FFMPEG_GENERATED_SRC_PATH ${CMAKE_GENERATED_SRC_PATH}/FFmpeg)
set(AVCODEC_GENERATED_SRC_PATH ${CMAKE_GENERATED_SRC_PATH}/FFmpeg/libavcodec)

if(WIN32)
    set(BUILD_FFMPEG_VAAPI OFF)
elseif(APPLE)
    set(BUILD_FFMPEG_AMF OFF)
    set(BUILD_FFMPEG_MF OFF)
    set(BUILD_FFMPEG_NV_CODEC_HEADERS OFF)
    set(BUILD_FFMPEG_VAAPI OFF)
elseif(UNIX)
    # nothing to disable for Linux
endif()

if(BUILD_FFMPEG_AMF)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/amf.cmake)
endif()

if(BUILD_FFMPEG_MF)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/mf.cmake)
endif()

if(BUILD_FFMPEG_NV_CODEC_HEADERS)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/nv_codec_headers.cmake)
endif()

if(BUILD_FFMPEG_SVT_AV1)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/svt_av1.cmake)
endif()

if(BUILD_FFMPEG_VAAPI)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/vaapi.cmake)
endif()

if(BUILD_FFMPEG_X264)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/x264.cmake)
endif()

if(BUILD_FFMPEG_X265)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/x265.cmake)
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/ffmpeg.cmake)
