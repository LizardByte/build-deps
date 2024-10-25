cmake_minimum_required(VERSION 3.25)

project(build-deps
        DESCRIPTION "Pre-build dependencies for LizardByte projects.")

# Main options
option(BUILD_ALL "Build all dependencies" ON)
option(BUILD_ALL_SUNSHINE "Build all Sunshine dependencies" ON)

# FFmpeg options
option(BUILD_FFMPEG "Build FFmpeg" ON)
option(BUILD_FFMPEG_ALL_PATCHES "Apply FFmpeg patches" ON)
option(BUILD_FFMPEG_AMF "Build FFmpeg AMF" ON)
option(BUILD_FFMPEG_AMF_PATCHES "Apply FFmpeg AMF patches" ON)
option(BUILD_FFMPEG_CBS "Build FFmpeg CBS" ON)
option(BUILD_FFMPEG_CBS_PATCHES "Apply FFmpeg CBS patches" ON)
option(BUILD_FFMPEG_MF "Build FFmpeg Media Foundation" ON)
option(BUILD_FFMPEG_MF_PATCHES "Apply FFmpeg Media Foundation patches" ON)
option(BUILD_FFMPEG_NV_CODEC_HEADERS "Build FFmpeg NV Codec Headers" ON)
option(BUILD_FFMPEG_NV_CODEC_HEADERS_PATCHES "Apply FFmpeg NV Codec Headers patches" ON)
option(BUILD_FFMPEG_SVT_AV1 "Build FFmpeg SVT-AV1" ON)
option(BUILD_FFMPEG_SVT_AV1_PATCHES "Apply FFmpeg SVT-AV1 patches" ON)
option(BUILD_FFMPEG_VAAPI "Build FFmpeg with VAAPI support" ON)
option(BUILD_FFMPEG_VAAPI_PATCHES "Apply FFmpeg VAAPI patches" ON)
option(BUILD_FFMPEG_X264 "Build FFmpeg x264" ON)
option(BUILD_FFMPEG_X264_PATCHES "Apply FFmpeg x264 patches" ON)
option(BUILD_FFMPEG_X265 "Build FFmpeg x265" ON)
option(BUILD_FFMPEG_X265_PATCHES "Apply FFmpeg x265 patches" ON)

# The shell command and prefix to use for running extra commands.
if(NOT DEFINED SHELL_CMD)
    if(WIN32)
        set(KNOWN_MSYS2_PATHS "$ENV{RUNNER_TEMP}\\msys64;C:\\msys64")
        foreach(KNOWN_MSYS2_PATH ${KNOWN_MSYS2_PATHS})
            message(STATUS "Checking for MSYS2 at ${KNOWN_MSYS2_PATH}")
            if(EXISTS ${KNOWN_MSYS2_PATH}\\usr\\bin\\bash.exe)
                set(SHELL_CMD "${KNOWN_MSYS2_PATH}\\usr\\bin\\bash.exe" CACHE STRING "Shell to use" FORCE)
                break()
            else()
                message(WARNING "Could not find MSYS2 bash at ${KNOWN_MSYS2_PATH}\\usr\\bin\\bash.exe")
            endif()
        endforeach()
    else()
        set(SHELL_CMD "bash" CACHE STRING "Shell to use" FORCE)
    endif()
endif()

set(MSYSTEM "UCRT64" CACHE STRING "MSYSTEM to use" FORCE)
set(ENV{MSYSTEM} ${MSYSTEM})

if(NOT DEFINED SHELL_CMD_PREFIX)
    if(WIN32)
        set(SHELL_CMD_PREFIX -l -c CACHE STRING "Shell command prefix" FORCE)
    else()
        set(SHELL_CMD_PREFIX -l -c CACHE STRING "Shell command prefix" FORCE)
    endif()
endif()
message(STATUS "Using shell command: ${SHELL_CMD}")
message(STATUS "Using shell command prefix: ${SHELL_CMD_PREFIX}")

find_program(MAKE_EXECUTABLE NAMES make REQUIRED)
message(STATUS "Found make: ${MAKE_EXECUTABLE}")

# Custom target to use to ensure all dependencies are built
add_custom_target(${CMAKE_PROJECT_NAME}
        COMMENT "Completed build-deps"
)

# set architecture
string(TOLOWER ${CMAKE_SYSTEM_PROCESSOR} arch)

# set generated source path
set(CMAKE_GENERATED_SRC_PATH ${CMAKE_CURRENT_BINARY_DIR}/generated-src)

# common includes
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/apply_git_patch.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/unix_path.cmake)

if(BUILD_ALL OR BUILD_ALL_SUNSHINE OR BUILD_FFMPEG)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/_main.cmake)
endif()
