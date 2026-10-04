CPMGetPackage(opus)

set(OPUS_CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/codec-deps
        -DCMAKE_INSTALL_LIBDIR=lib
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
        -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
        -DBUILD_SHARED_LIBS=OFF
        -DOPUS_BUILD_TESTING=OFF
        -DOPUS_BUILD_PROGRAMS=OFF
        -DOPUS_INSTALL_PKG_CONFIG_MODULE=ON
)
if(CMAKE_TOOLCHAIN_FILE)
    list(APPEND OPUS_CMAKE_ARGS -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE})
endif()
if(APPLE)
    list(APPEND OPUS_CMAKE_ARGS
            -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
            -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET})
endif()
add_custom_target(opus ALL
        COMMAND ${CMAKE_COMMAND}
            -S ${opus_SOURCE_DIR}
            -B ${CMAKE_CURRENT_BINARY_DIR}/opus-build
            -G "${CMAKE_GENERATOR}"
            ${OPUS_CMAKE_ARGS}
        COMMAND ${CMAKE_COMMAND} --build ${CMAKE_CURRENT_BINARY_DIR}/opus-build
            --config Release --parallel ${N_PROC}
        COMMAND ${CMAKE_COMMAND} --install ${CMAKE_CURRENT_BINARY_DIR}/opus-build --config Release
        COMMENT "Target: Opus"
        USES_TERMINAL
        VERBATIM
)
add_dependencies(${CMAKE_PROJECT_NAME} opus)
install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/codec-deps/include/opus"
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/include)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/codec-deps/lib/libopus.a"
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/lib)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/codec-deps/lib/pkgconfig/opus.pc"
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/lib/pkgconfig)
install(FILES ${opus_SOURCE_DIR}/COPYING
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/share/licenses/opus)
