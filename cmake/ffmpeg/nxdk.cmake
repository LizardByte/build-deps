CPMGetPackage(nxdk)
CPMGetPackage(ffmpeg_nxdk)
set(FFMPEG_SOURCE_DIR "${ffmpeg_nxdk_SOURCE_DIR}")

set(FFMPEG_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-nxdk")
set(BUILD_FFMPEG_TOOLS OFF)
set(_nxdk_adapters "${CMAKE_CURRENT_LIST_DIR}/nxdk")
set(_nxdk_compat "${FFMPEG_BUILD_DIR}/libffmpeg-nxdk-compat.a")
set(_nxdk_sources "${FFMPEG_BUILD_DIR}/sources.txt")
UNIX_PATH(_nxdk_sdk_unix "${nxdk_SOURCE_DIR}")
UNIX_PATH(_nxdk_adapters_unix "${_nxdk_adapters}")
UNIX_PATH(_nxdk_compat_unix "${_nxdk_compat}")
UNIX_PATH(_nxdk_tests_unix "${CMAKE_CURRENT_SOURCE_DIR}/tests")
UNIX_PATH(_nxdk_build_unix "${FFMPEG_BUILD_DIR}")
set(FFMPEG_BUILD_ENV "NXDK_DIR=${_nxdk_sdk_unix} PATH=${_nxdk_sdk_unix}/bin:\"$PATH\"")
configure_file("${CMAKE_CURRENT_LIST_DIR}/nxdk-sources.txt.in" "${_nxdk_sources}" @ONLY)

# Keep SDK archive member paths relative to fit Windows' command-line length limit.
string(CONCAT _nxdk_libraries
        "./lib/libpdclib.lib ./lib/libxboxrt.lib ./lib/libwinapi.lib "
        "./lib/libnxdk_hal.lib ./lib/xboxkrnl/libxboxkrnl.lib './lib/libc++.lib'")
string(CONCAT _nxdk_make
        "cd ${_nxdk_sdk_unix} && MAKEFLAGS= MFLAGS= ${FFMPEG_BUILD_ENV} "
        "${MAKE_EXECUTABLE} NXDK_DIR=. NXDK_ONLY=y NXDK_SDL= --jobs=${N_PROC} ${_nxdk_libraries}")
set(_nxdk_cc "${FFMPEG_BUILD_ENV} sh ${_nxdk_sdk_unix}/bin/nxdk-cc")
set(_nxdk_verify "bash ${_nxdk_tests_unix}/verify-ffmpeg-nxdk.sh")
add_custom_command(OUTPUT "${_nxdk_compat}"
        COMMAND ${SHELL_CMD} "${_nxdk_make}"
        COMMAND ${SHELL_CMD}
            "${_nxdk_cc} -I${_nxdk_adapters_unix}/include -c ${_nxdk_adapters_unix}/runtime.c -o runtime.obj"
        COMMAND ${SHELL_CMD}
            "${_nxdk_cc} -c ${_nxdk_adapters_unix}/ffmpeg_memory.c -o ffmpeg_memory.obj"
        COMMAND ${SHELL_CMD} "llvm-ar rcs libffmpeg-nxdk-compat.a runtime.obj ffmpeg_memory.obj"
        DEPENDS "${_nxdk_sources}"
            "${_nxdk_adapters}/runtime.c" "${_nxdk_adapters}/include/sys/time.h" "${_nxdk_adapters}/include/unistd.h"
            "${_nxdk_adapters}/ffmpeg_memory.c" "${_nxdk_adapters}/ffmpeg_memory.h"
        WORKING_DIRECTORY "${FFMPEG_BUILD_DIR}"
        COMMENT "Build the nxdk runtime libraries and FFmpeg compatibility archive"
        VERBATIM)
add_custom_target(ffmpeg-nxdk-compat
        DEPENDS "${_nxdk_compat}"
        COMMENT "Xbox FFmpeg compatibility archive ready")

# Pentium III supports the NASM MMX/SSE kernels. Stack realignment precludes inline CABAC assembly.
set(FFMPEG_EXTRA_CONFIGURE
        "--extra-ldflags=${_nxdk_compat_unix}"
        --extra-cflags=-mstackrealign
        --enable-cross-compile
        --arch=x86
        --cpu=pentium3
        --target-os=none
        "--cc='sh ${_nxdk_adapters_unix}/cc.sh c'"
        "--cxx='sh ${_nxdk_adapters_unix}/cc.sh c++'"
        --ar=llvm-ar
        --ranlib=llvm-ranlib
        --nm=llvm-nm
        --enable-version3
        --enable-static
        --disable-shared
        --disable-autodetect
        --enable-asm
        --disable-inline-asm
        --enable-x86asm
        "--x86asmexe=${_nxdk_adapters_unix}/nasm.sh"
        --disable-sse2
        --disable-amd3dnow
        --disable-amd3dnowext
        --disable-runtime-cpudetect
        --disable-debug
        --disable-doc
        --disable-programs
        --disable-network
        --disable-everything
        --disable-avdevice
        --disable-avfilter
        --disable-avformat
        --disable-iconv
        --disable-zlib
        --disable-bzlib
        --disable-lzma
        --disable-sdl2
        --disable-symver
        --disable-pthreads
        --enable-w32threads
        --disable-os2threads
        --disable-hwaccels
        --enable-avcodec
        --enable-avutil
        --enable-swscale
        --enable-swresample
        --enable-parser=h264,h263,mpegvideo
        --enable-decoder=h264,h263,h263i,h263p,mpeg2video,opus)
include("${CMAKE_CURRENT_LIST_DIR}/build.cmake")
add_dependencies(ffmpeg ffmpeg-nxdk-compat)

add_custom_command(TARGET ffmpeg POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E copy "${_nxdk_compat}" "${CMAKE_CURRENT_BINARY_DIR}/FFmpeg/lib/"
        COMMAND ${SHELL_CMD}
            "${FFMPEG_BUILD_ENV} ${_nxdk_verify} ${CMAKE_CURRENT_BINARY_DIR_UNIX}/FFmpeg ${_nxdk_build_unix} ${_nxdk_adapters_unix}/cc.sh"
        COMMENT "Verify the Xbox FFmpeg archive and link an nxdk probe"
        VERBATIM)
install(FILES "${FFMPEG_SOURCE_DIR}/COPYING.LGPLv3" DESTINATION "${FFMPEG_INSTALL_PREFIX}/share/licenses/ffmpeg")
install(FILES "${_nxdk_adapters}/COPYING.GPLv3" "${_nxdk_adapters}/NOTICE.md"
        DESTINATION "${FFMPEG_INSTALL_PREFIX}/share/licenses/ffmpeg-nxdk")
install(FILES "${_nxdk_sources}" DESTINATION "${FFMPEG_INSTALL_PREFIX}/share/ffmpeg-nxdk")
