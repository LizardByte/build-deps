CPMGetPackage(nxdk)
CPMGetPackage(moonlight_nxdk)

# Use the same FFmpeg tag as the native builds with the Xbox-specific patch set.
CPMAddPackage(
        NAME ffmpeg_nxdk
        GIT_REPOSITORY https://github.com/FFmpeg/FFmpeg.git
        GIT_TAG ${FFMPEG_TAG}
        GIT_SHALLOW TRUE
        GIT_CONFIG core.autocrlf=false
        SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/_deps/ffmpeg-nxdk-${FFMPEG_TAG}"
        UPDATE_DISCONNECTED TRUE
        DOWNLOAD_ONLY YES
        PATCHES "${moonlight_nxdk_SOURCE_DIR}/src/_nxdk_compat/ffmpeg/ffmpeg-nxdk.patch"
)

find_program(NXDK_BASH_EXECUTABLE NAMES bash REQUIRED)
set(_nxdk_builder "${CMAKE_CURRENT_SOURCE_DIR}/scripts/build-ffmpeg-nxdk.sh")
set(_nxdk_probe "${CMAKE_CURRENT_SOURCE_DIR}/tests/ffmpeg-nxdk.c")
set(_nxdk_build_dir "${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-nxdk")
set(_nxdk_stage "${CMAKE_CURRENT_BINARY_DIR}/FFmpeg")
set(_nxdk_stamp "${_nxdk_build_dir}/build.stamp")

configure_file("${CMAKE_CURRENT_LIST_DIR}/nxdk-sources.txt.in" "${_nxdk_build_dir}/sources.txt" @ONLY)
add_custom_command(OUTPUT "${_nxdk_stamp}"
        COMMAND "${NXDK_BASH_EXECUTABLE}" "${_nxdk_builder}"
            "${nxdk_SOURCE_DIR}" "${moonlight_nxdk_SOURCE_DIR}" "${ffmpeg_nxdk_SOURCE_DIR}"
            "${_nxdk_build_dir}" "${_nxdk_stage}" "${_nxdk_probe}" "${N_PROC}"
        COMMAND "${CMAKE_COMMAND}" -E touch "${_nxdk_stamp}"
        DEPENDS "${_nxdk_builder}" "${_nxdk_probe}" "${_nxdk_build_dir}/sources.txt"
        COMMENT "Build and verify static FFmpeg for the original Xbox"
        VERBATIM)
add_custom_target(ffmpeg_nxdk ALL
        DEPENDS "${_nxdk_stamp}"
        COMMENT "Xbox FFmpeg package ready")

set(FFMPEG_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}/ffmpeg")
UNIX_PATH(CMAKE_CURRENT_BINARY_DIR_UNIX "${CMAKE_CURRENT_BINARY_DIR}")
UNIX_PATH(FFMPEG_INSTALL_PREFIX_UNIX "${FFMPEG_INSTALL_PREFIX}")
configure_file("${CMAKE_CURRENT_LIST_DIR}/relocate-pkgconfig.cmake.in"
        "${_nxdk_build_dir}/relocate-pkgconfig.cmake" @ONLY)
install(DIRECTORY "${_nxdk_stage}/" DESTINATION "${FFMPEG_INSTALL_PREFIX}")
install(SCRIPT "${_nxdk_build_dir}/relocate-pkgconfig.cmake")
