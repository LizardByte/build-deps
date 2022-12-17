cmake_minimum_required(VERSION 3.2)

project(build-deps
        DESCRIPTION "Pre-build dependencies for LizardByte projects"
        )

option(FFMPEG_CBS "Enable CBS library configuration" ON)

if (FFMPEG_CBS)
    include (${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg_cbs.cmake)
endif()
