CPMGetPackage(dav1d)

find_program(MESON_EXECUTABLE NAMES meson REQUIRED)
UNIX_PATH(MESON_EXECUTABLE_UNIX ${MESON_EXECUTABLE})
UNIX_PATH(DAV1D_SOURCE_DIR_UNIX ${dav1d_SOURCE_DIR})
set(DAV1D_C_COMPILER_PATH ${CMAKE_C_COMPILER})
set(DAV1D_AR_PATH ${CMAKE_AR})
set(DAV1D_MACHINE_FILE "${CMAKE_CURRENT_BINARY_DIR}/dav1d-machine.ini")
set(DAV1D_CPU_FAMILY ${arch})
if(arch MATCHES "^(amd64|x86_64)$")
    set(DAV1D_CPU_FAMILY x86_64)
elseif(arch MATCHES "^(arm64|aarch64)$")
    set(DAV1D_CPU_FAMILY aarch64)
elseif(arch STREQUAL "ppc64le")
    set(DAV1D_CPU_FAMILY ppc64)
endif()
set(DAV1D_SYSTEM ${TARGET_OS})
if(WIN32)
    set(DAV1D_SYSTEM windows)
endif()
set(DAV1D_C_ARGS "")
separate_arguments(DAV1D_C_FLAGS UNIX_COMMAND "${CMAKE_C_FLAGS}")
foreach(flag IN LISTS DAV1D_C_FLAGS)
    string(APPEND DAV1D_C_ARGS "'${flag}', ")
endforeach()
if(APPLE AND CMAKE_OSX_ARCHITECTURES)
    string(APPEND DAV1D_C_ARGS "'-arch', '${CMAKE_OSX_ARCHITECTURES}', ")
endif()
if(APPLE AND CMAKE_OSX_DEPLOYMENT_TARGET)
    string(APPEND DAV1D_C_ARGS "'-mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}', ")
endif()
if(CMAKE_SYSROOT)
    string(APPEND DAV1D_C_ARGS "'--sysroot=${CMAKE_SYSROOT}', ")
elseif(APPLE AND CMAKE_OSX_SYSROOT)
    string(APPEND DAV1D_C_ARGS "'-isysroot', '${CMAKE_OSX_SYSROOT}', ")
endif()
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/dav1d-machine.ini.in
        ${DAV1D_MACHINE_FILE} @ONLY)
UNIX_PATH(DAV1D_MACHINE_FILE_UNIX ${DAV1D_MACHINE_FILE})

set(DAV1D_MACHINE_OPTION --native-file)
if(CMAKE_CROSSCOMPILING)
    set(DAV1D_MACHINE_OPTION --cross-file)
endif()
add_custom_target(dav1d ALL
        COMMAND ${SHELL_CMD} "'${MESON_EXECUTABLE_UNIX}' setup --reconfigure \
'${CMAKE_CURRENT_BINARY_DIR_UNIX}/dav1d-build' '${DAV1D_SOURCE_DIR_UNIX}' \
${DAV1D_MACHINE_OPTION} '${DAV1D_MACHINE_FILE_UNIX}' \
--prefix='${CMAKE_CURRENT_BINARY_DIR_UNIX}/codec-deps' --libdir=lib \
--buildtype=release --default-library=static -Db_staticpic=true \
-Denable_tools=false -Denable_tests=false -Denable_examples=false"
        COMMAND ${SHELL_CMD} "'${MESON_EXECUTABLE_UNIX}' compile \
-C '${CMAKE_CURRENT_BINARY_DIR_UNIX}/dav1d-build' -j ${N_PROC}"
        COMMAND ${SHELL_CMD} "'${MESON_EXECUTABLE_UNIX}' install -C '${CMAKE_CURRENT_BINARY_DIR_UNIX}/dav1d-build'"
        COMMENT "Target: dav1d"
        USES_TERMINAL
        VERBATIM
)
add_dependencies(${CMAKE_PROJECT_NAME} dav1d)
set(PKG_CONFIG_PATH "${CMAKE_CURRENT_BINARY_DIR_UNIX}/codec-deps/lib/pkgconfig:${PKG_CONFIG_PATH}")
install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/codec-deps/include/dav1d"
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/include)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/codec-deps/lib/libdav1d.a"
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/lib)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/codec-deps/lib/pkgconfig/dav1d.pc"
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/lib/pkgconfig)
install(FILES ${dav1d_SOURCE_DIR}/COPYING
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/share/licenses/dav1d)
