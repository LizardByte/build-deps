CPMGetPackage(libva)

set(LIBVA_GENERATED_SRC_PATH ${libva_SOURCE_DIR})

if(BUILD_FFMPEG_ALL_PATCHES OR BUILD_FFMPEG_LIBVA_PATCHES)
    file(GLOB FFMPEG_LIBVA_PATCH_FILES ${CMAKE_CURRENT_SOURCE_DIR}/patches/FFmpeg/libva/*.patch)

    foreach(patch_file ${FFMPEG_LIBVA_PATCH_FILES})
        APPLY_GIT_PATCH(${LIBVA_GENERATED_SRC_PATH} ${patch_file})
    endforeach()
endif()

# libva uses autotools build system
set(WORKING_DIR "${LIBVA_GENERATED_SRC_PATH}")
UNIX_PATH(WORKING_DIR_UNIX ${WORKING_DIR})

# Runtime paths must refer to the consumer's system, not the build staging prefix.
if(FREEBSD)
    set(LIBVA_DEFAULT_DRIVERS_PATH
            /usr/local/lib/dri  # FreeBSD ports and packages.
    )
    set(LIBVA_DEFAULT_SYSCONFDIR /usr/local/etc)
else()
    set(LIBVA_DEFAULT_DRIVERS_PATH
            /usr/lib/dri  # Arch Linux, Alpine, and distributions using a single lib directory.
            /usr/lib64/dri  # Fedora, RHEL, openSUSE, and other lib64 distributions.
            /usr/lib/va/drivers  # Gentoo profiles using lib.
            /usr/lib64/va/drivers  # Gentoo profiles using lib64.
            /run/opengl-driver/lib/dri  # NixOS system graphics drivers.
            /home/linuxbrew/.linuxbrew/lib/dri  # Homebrew on Linux's default prefix.
            /usr/local/lib/dri  # Locally installed drivers using lib.
            /usr/local/lib64/dri  # Locally installed drivers using lib64.
    )
    set(LIBVA_LIBRARY_ARCHITECTURE "${CMAKE_LIBRARY_ARCHITECTURE}")
    if(NOT LIBVA_LIBRARY_ARCHITECTURE AND CMAKE_C_COMPILER_TARGET)
        set(LIBVA_LIBRARY_ARCHITECTURE "${CMAKE_C_COMPILER_TARGET}")
    endif()
    if(LIBVA_LIBRARY_ARCHITECTURE)
        list(PREPEND LIBVA_DEFAULT_DRIVERS_PATH
                "/usr/lib/${LIBVA_LIBRARY_ARCHITECTURE}/dri"  # Debian, Ubuntu, and Flatpak runtime drivers.
                "/usr/lib/${LIBVA_LIBRARY_ARCHITECTURE}/dri/intel-vaapi-driver"  # Flatpak Intel VA-API extension.
                "/usr/lib/${LIBVA_LIBRARY_ARCHITECTURE}/dri/nvidia-vaapi-driver"  # Flatpak NVIDIA VA-API extension.
                "/usr/lib/${LIBVA_LIBRARY_ARCHITECTURE}/GL/lib/dri"  # Flatpak Mesa GL extension.
        )
    endif()
    list(JOIN LIBVA_DEFAULT_DRIVERS_PATH ":" LIBVA_DEFAULT_DRIVERS_PATH)
    set(LIBVA_DEFAULT_SYSCONFDIR /etc)
endif()
set(LIBVA_DRIVERS_PATH "${LIBVA_DEFAULT_DRIVERS_PATH}" CACHE STRING "Runtime VA-API driver search path")
set(LIBVA_SYSCONFDIR "${LIBVA_DEFAULT_SYSCONFDIR}" CACHE PATH "Runtime libva configuration directory")

# Configure options for libva
list(APPEND LIBVA_EXTRA_CONFIGURE
        --prefix=${CMAKE_CURRENT_BINARY_DIR_UNIX}/libva
        --sysconfdir=${LIBVA_SYSCONFDIR}
        --with-drivers-path=${LIBVA_DRIVERS_PATH}
        --enable-static
        --disable-shared
        --enable-drm
        --enable-x11
        --enable-glx
        --enable-wayland
        --without-legacy
)

# On FreeBSD, disable dependency tracking to avoid gmake/make compatibility issues
if(FREEBSD)
    list(APPEND LIBVA_EXTRA_CONFIGURE --disable-dependency-tracking)
endif()

if(CMAKE_CROSSCOMPILING)
    set(LIBVA_EXTRA_CONFIGURE
            ${LIBVA_EXTRA_CONFIGURE}
            --host=${CMAKE_C_COMPILER_TARGET}
    )
endif()

# Convert list to string
# configure command will only take the first argument if not converted to string
string(REPLACE ";" " " LIBVA_EXTRA_CONFIGURE "${LIBVA_EXTRA_CONFIGURE}")

add_custom_target(libva ALL
        COMMAND ${SHELL_CMD} "${MAKE_COMPILER_FLAGS} ./autogen.sh ${LIBVA_EXTRA_CONFIGURE}"
        COMMAND ${SHELL_CMD} "${MAKE_COMPILER_FLAGS} ${MAKE_EXECUTABLE} --jobs=${N_PROC}"
        COMMAND ${SHELL_CMD} "${MAKE_COMPILER_FLAGS} ${MAKE_EXECUTABLE} install"
        WORKING_DIRECTORY ${WORKING_DIR}
        COMMENT "Target: libva"
        COMMAND_EXPAND_LISTS
        USES_TERMINAL
        VERBATIM
        BYPRODUCTS
            "${CMAKE_CURRENT_BINARY_DIR}/libva/lib/libva.a"
            "${CMAKE_CURRENT_BINARY_DIR}/libva/lib/libva-drm.a"
            "${CMAKE_CURRENT_BINARY_DIR}/libva/lib/libva-x11.a"
            "${CMAKE_CURRENT_BINARY_DIR}/libva/lib/libva-glx.a"
            "${CMAKE_CURRENT_BINARY_DIR}/libva/lib/libva-wayland.a"
)
add_dependencies(${CMAKE_PROJECT_NAME} libva)

# Add to PKG_CONFIG_PATH for FFmpeg to find
set(PKG_CONFIG_PATH "${CMAKE_CURRENT_BINARY_DIR_UNIX}/libva/lib/pkgconfig:${PKG_CONFIG_PATH}")
install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/libva/include/"
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/include)
install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/libva/lib/"
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/lib
        FILES_MATCHING PATTERN "*.a" PATTERN "*.pc")
install(FILES ${libva_SOURCE_DIR}/COPYING
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/share/licenses/libva)
