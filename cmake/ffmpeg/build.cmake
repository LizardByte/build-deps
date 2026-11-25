# Native builds configure in the source tree. The Xbox port keeps generated target files separate.
if(DEFINED FFMPEG_BUILD_DIR)
    file(MAKE_DIRECTORY "${FFMPEG_BUILD_DIR}")
    UNIX_PATH(FFMPEG_SOURCE_DIR_UNIX "${FFMPEG_SOURCE_DIR}")
    set(_ffmpeg_configure "sh ${FFMPEG_SOURCE_DIR_UNIX}/configure")
else()
    set(FFMPEG_BUILD_DIR "${FFMPEG_SOURCE_DIR}")
    set(_ffmpeg_configure "./configure")
endif()

list(PREPEND FFMPEG_EXTRA_CONFIGURE --prefix=${CMAKE_CURRENT_BINARY_DIR_UNIX}/FFmpeg)
string(JOIN " " _ffmpeg_options ${FFMPEG_EXTRA_CONFIGURE})
message(STATUS "FFmpeg configure options: ${_ffmpeg_options}")

add_custom_target(ffmpeg ALL
        COMMAND ${SHELL_CMD} "${FFMPEG_BUILD_ENV} PKG_CONFIG_PATH='${PKG_CONFIG_PATH}' ${_ffmpeg_configure} ${_ffmpeg_options}"
        # FFmpeg's separate make invocation starts its own jobserver.
        COMMAND ${SHELL_CMD}
            "MAKEFLAGS= MFLAGS= ${FFMPEG_BUILD_ENV} ${FFMPEG_NVENC_SDK_ENV} ${MAKE_EXECUTABLE} --jobs=${N_PROC}"
        COMMAND ${SHELL_CMD} "MAKEFLAGS= MFLAGS= ${FFMPEG_BUILD_ENV} ${FFMPEG_NVENC_SDK_ENV} ${MAKE_EXECUTABLE} install"
        WORKING_DIRECTORY "${FFMPEG_BUILD_DIR}"
        COMMENT "Target: FFmpeg"
        COMMAND_EXPAND_LISTS
        USES_TERMINAL
        VERBATIM)
add_dependencies(${CMAKE_PROJECT_NAME} ffmpeg)

install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/FFmpeg/include/"
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/include)
install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/FFmpeg/lib/"
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/lib)
if(BUILD_FFMPEG_TOOLS)
    install(PROGRAMS
            "${CMAKE_CURRENT_BINARY_DIR}/FFmpeg/bin/ffmpeg${CMAKE_EXECUTABLE_SUFFIX}"
            "${CMAKE_CURRENT_BINARY_DIR}/FFmpeg/bin/ffprobe${CMAKE_EXECUTABLE_SUFFIX}"
            DESTINATION ${FFMPEG_INSTALL_PREFIX}/bin)
endif()
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/relocate-pkgconfig.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/relocate-pkgconfig.cmake @ONLY)
# Run after the pkg-config files from every component have been installed.
install(SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/relocate-pkgconfig.cmake)
install(FILES ${FFMPEG_SOURCE_DIR}/COPYING.LGPLv2.1
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/share/licenses/ffmpeg)
