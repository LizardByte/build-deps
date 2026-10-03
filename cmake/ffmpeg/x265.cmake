# The nested x265 builds use a single configuration layout: the archives are
# expected at fixed paths inside each build directory, and the combine step
# merges them statically. Multi-config generators (Visual Studio, Xcode) place
# their outputs in per-config subdirectories and are not supported. Fail before
# any side effect (tag fetch, .git rewrite, patches). Do not remove this guard
# without teaching the rules about the per-config paths.
if(CMAKE_CONFIGURATION_TYPES)
    message(FATAL_ERROR "x265 multilib requires a single configuration generator")
endif()

# x265.pc will not be installed if their cmake cannot detect the latest tag
GIT_FETCH_TAGS("third-party/FFmpeg/x265_git")

set(X265_GENERATED_SRC_PATH "${CMAKE_CURRENT_BINARY_DIR}/FFmpeg/x265_git")

# The copied source tree inherits the submodule's .git file, whose relative
# gitdir no longer resolves from the new location. Point it at the real git
# directory so x265 can detect its version tag and install x265.pc (the install
# step is checked by x265-verify-pc.cmake). This runs before the patch loop so
# the patches apply through git apply; the source copy itself is made by
# _main.cmake before this file is included. This couples the build tree to the
# source repository's Git metadata; passing the version explicitly instead is a
# possible follow-up.
execute_process(
        COMMAND git -C "${CMAKE_CURRENT_SOURCE_DIR}/third-party/FFmpeg/x265_git"
            rev-parse --absolute-git-dir
        OUTPUT_VARIABLE X265_GIT_DIR
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
        RESULT_VARIABLE X265_GIT_RESULT
)
if(X265_GIT_RESULT EQUAL 0)
    file(WRITE "${X265_GENERATED_SRC_PATH}/.git" "gitdir: ${X265_GIT_DIR}\n")
endif()

file(GLOB X265_GIT_FILES CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/patches/FFmpeg/x265_git/*.patch")
foreach(patch_file ${X265_GIT_FILES})
    APPLY_GIT_PATCH("${X265_GENERATED_SRC_PATH}" "${patch_file}")
endforeach()
# Note: the x265 patches also raise the policy range declared by its
# cmake_minimum_required, which is what lets CMake 4 and newer configure it

if(BUILD_FFMPEG_ALL_PATCHES OR BUILD_FFMPEG_X265_PATCHES)
    file(GLOB FFMPEG_X265_FILES "${CMAKE_CURRENT_SOURCE_DIR}/patches/FFmpeg/FFmpeg/x265/*.patch")

    foreach(patch_file ${FFMPEG_X265_FILES})
        APPLY_GIT_PATCH("${FFMPEG_GENERATED_SRC_PATH}" "${patch_file}")
    endforeach()
endif()

#
# x265 multilib (8/10/12-bit)
#
# This follows x265's official multilib script (build/linux/multilib.sh): each
# bit depth is built as its own static library and the three archives are then
# combined into a single libx265.a. The 8-bit library holds the public API and
# is compiled with LINKED_10BIT/LINKED_12BIT so that its API dispatcher can
# reach the 10/12-bit encoders, which is what enables Main10 HDR encoding.
#
# The bit depth builds are independent CMake projects, so the toolchain,
# compiler flags and target platform of the main project are forwarded
# explicitly to each of them.
#
# They are plain custom commands instead of ExternalProject so the archives,
# the combine step and the install step can use the same output tracking as the
# other dependencies (see vulkan.cmake), and so the install step can run x265's
# own install rules before replacing the installed library.
#

set(X265_MULTILIB_DIR "${CMAKE_CURRENT_BINARY_DIR}/x265-multilib")
set(X265_8BIT_DIR "${X265_MULTILIB_DIR}/8bit")
set(X265_10BIT_DIR "${X265_MULTILIB_DIR}/10bit")
set(X265_12BIT_DIR "${X265_MULTILIB_DIR}/12bit")
set(X265_COMBINE_DIR "${X265_MULTILIB_DIR}/combine")

if(MSVC)
    set(X265_LIB_NAME "x265-static.lib")
    set(X265_MAIN_NAME "x265-static-main.lib")
    set(X265_MAIN10_NAME "x265-static-main10.lib")
    set(X265_MAIN12_NAME "x265-static-main12.lib")
else()
    set(X265_LIB_NAME "libx265.a")
    set(X265_MAIN_NAME "libx265_main.a")
    set(X265_MAIN10_NAME "libx265_main10.a")
    set(X265_MAIN12_NAME "libx265_main12.a")
endif()

# the MRI script mirrors x265's official multilib script; generate it from the
# archive names so they are only spelled out once
set(_x265_mri_file "${CMAKE_CURRENT_BINARY_DIR}/x265-multilib.ar")
string(CONCAT _x265_mri_content
        "CREATE ${X265_LIB_NAME}.unverified\n"
        "ADDLIB ${X265_MAIN_NAME}\n"
        "ADDLIB ${X265_MAIN10_NAME}\n"
        "ADDLIB ${X265_MAIN12_NAME}\n"
        "SAVE\n"
        "END\n"
)
if(EXISTS "${_x265_mri_file}")
    file(READ "${_x265_mri_file}" _x265_mri_old)
else()
    set(_x265_mri_old "")
endif()
if(NOT "${_x265_mri_old}" STREQUAL "${_x265_mri_content}")
    file(WRITE "${_x265_mri_file}" "${_x265_mri_content}")
endif()

set(X265_COMBINED_LIB "${X265_COMBINE_DIR}/${X265_LIB_NAME}")
set(X265_UNVERIFIED_LIB "${X265_COMBINE_DIR}/${X265_LIB_NAME}.unverified")
set(X265_INSTALL_LIB "${FFMPEG_INSTALL_PREFIX}/lib/${X265_LIB_NAME}")
set(X265_INSTALL_HEADER "${FFMPEG_INSTALL_PREFIX}/include/x265.h")
set(X265_INSTALL_CONFIG "${FFMPEG_INSTALL_PREFIX}/include/x265_config.h")
set(X265_INSTALL_STAMP "${X265_MULTILIB_DIR}/install.stamp")
set(X265_PC_FILE "${FFMPEG_INSTALL_PREFIX}/lib/pkgconfig/x265.pc")
set(X265_INSTALL_OUTPUTS
        "${X265_INSTALL_STAMP}"
        "${X265_INSTALL_LIB}"
        "${X265_INSTALL_HEADER}"
        "${X265_INSTALL_CONFIG}"
        "${X265_PC_FILE}"
)

# HDR10+ is not supported on all architectures
set(X265_ENABLE_HDR10_PLUS OFF)
if("${arch}" STREQUAL "amd64" OR "${arch}" STREQUAL "x86_64")
    set(X265_ENABLE_HDR10_PLUS ON)
endif()

set(X265_CMAKE_ARGS
        -G "${CMAKE_GENERATOR}"
        "-DCMAKE_INSTALL_PREFIX=${FFMPEG_INSTALL_PREFIX}"
        -DCMAKE_BUILD_TYPE=Release
        -DENABLE_CLI=OFF
        -DENABLE_SHARED=OFF
        -DSTATIC_LINK_CRT=ON
)

# forward a variable to the nested builds as a single -D argument; list
# separators are escaped so multi-value variables (e.g. universal macOS
# architectures) do not split into several command line arguments
macro(X265_FORWARD_VARIABLE name)
    if(DEFINED ${name} AND NOT "${${name}}" STREQUAL "")
        string(REPLACE ";" "\\;" _x265_forward_value "${${name}}")
        list(APPEND X265_CMAKE_ARGS "-D${name}=${_x265_forward_value}")
    endif()
endmacro()

# forward the compiler and archiver configuration of the main project
foreach(x265_toolchain_var
        CMAKE_C_COMPILER
        CMAKE_CXX_COMPILER
        CMAKE_C_FLAGS
        CMAKE_CXX_FLAGS
        CMAKE_AR
        CMAKE_RANLIB
        CMAKE_ASM_NASM_COMPILER
)
    X265_FORWARD_VARIABLE(${x265_toolchain_var})
endforeach()

# forward the toolchain file itself so the nested builds inherit the same
# cross compilation environment (sysroot, find root path, compiler selection)
if(DEFINED CMAKE_TOOLCHAIN_FILE AND NOT "${CMAKE_TOOLCHAIN_FILE}" STREQUAL "")
    get_filename_component(x265_toolchain_file "${CMAKE_TOOLCHAIN_FILE}" ABSOLUTE)
    list(APPEND X265_CMAKE_ARGS "-DCMAKE_TOOLCHAIN_FILE=${x265_toolchain_file}")
endif()

# a sysroot configured outside a toolchain file must be forwarded as well
if(DEFINED CMAKE_SYSROOT AND NOT "${CMAKE_SYSROOT}" STREQUAL "")
    list(APPEND X265_CMAKE_ARGS "-DCMAKE_SYSROOT=${CMAKE_SYSROOT}")
endif()

if(APPLE)
    # keep the deployment target and architectures of the main project
    foreach(x265_apple_var
            CMAKE_OSX_ARCHITECTURES
            CMAKE_OSX_DEPLOYMENT_TARGET
            CMAKE_OSX_SYSROOT
    )
        X265_FORWARD_VARIABLE(${x265_apple_var})
    endforeach()
elseif(CMAKE_CROSSCOMPILING)
    X265_FORWARD_VARIABLE(CMAKE_SYSTEM_NAME)
    X265_FORWARD_VARIABLE(CMAKE_SYSTEM_PROCESSOR)
    if(UNIX AND NOT APPLE)
        X265_FORWARD_VARIABLE(CMAKE_C_COMPILER_TARGET)
        X265_FORWARD_VARIABLE(CMAKE_CXX_COMPILER_TARGET)
    endif()
endif()

# x265 reads EXTRA_LIB as a CMake list. A semicolon cannot be forwarded through
# a nested configure command line reliably, so the list is provided through an
# initial cache file instead. The file is rewritten only when its content
# changes and is part of the incremental fingerprint below.
set(_x265_extra_lib "${X265_10BIT_DIR}/${X265_LIB_NAME}")
list(APPEND _x265_extra_lib "${X265_12BIT_DIR}/${X265_LIB_NAME}")
set(_x265_init_file "${CMAKE_CURRENT_BINARY_DIR}/x265-8bit-init.cmake")
set(_x265_init_content "set(EXTRA_LIB \"${_x265_extra_lib}\" CACHE STRING \"\" FORCE)\n")
if(EXISTS "${_x265_init_file}")
    file(READ "${_x265_init_file}" _x265_init_old)
else()
    set(_x265_init_old "")
endif()
if(NOT "${_x265_init_old}" STREQUAL "${_x265_init_content}")
    file(WRITE "${_x265_init_file}" "${_x265_init_content}")
endif()

# The copied sources are refreshed and patched on every configure, so the
# nested builds depend on the original submodule sources and the patches,
# whose timestamps are stable across reconfigures.
file(GLOB_RECURSE X265_BUILD_DEPENDS CONFIGURE_DEPENDS
        "${CMAKE_CURRENT_SOURCE_DIR}/third-party/FFmpeg/x265_git/source/*.asm"
        "${CMAKE_CURRENT_SOURCE_DIR}/third-party/FFmpeg/x265_git/source/*.c"
        "${CMAKE_CURRENT_SOURCE_DIR}/third-party/FFmpeg/x265_git/source/*.cmake"
        "${CMAKE_CURRENT_SOURCE_DIR}/third-party/FFmpeg/x265_git/source/*.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/third-party/FFmpeg/x265_git/source/*.h"
        "${CMAKE_CURRENT_SOURCE_DIR}/third-party/FFmpeg/x265_git/source/*.in"
        "${CMAKE_CURRENT_SOURCE_DIR}/third-party/FFmpeg/x265_git/source/*.S"
        "${CMAKE_CURRENT_SOURCE_DIR}/third-party/FFmpeg/x265_git/source/*.txt"
)
list(APPEND X265_BUILD_DEPENDS ${X265_GIT_FILES})
list(APPEND X265_BUILD_DEPENDS "${_x265_init_file}")
if(DEFINED CMAKE_TOOLCHAIN_FILE AND NOT "${CMAKE_TOOLCHAIN_FILE}" STREQUAL "")
    list(APPEND X265_BUILD_DEPENDS "${CMAKE_TOOLCHAIN_FILE}")
endif()

# x265_add_build_variant(<target> <build_dir> [<extra configure arguments>...])
#
# Configures and builds one bit depth in its own build directory. The archive is
# declared as the output of a custom command, so the nested configure and build
# only run when the sources, the patches or the configure arguments change.
function(x265_add_build_variant target build_dir)
    set(library "${build_dir}/${X265_LIB_NAME}")
    set(arguments_file "${X265_MULTILIB_DIR}/${target}-configure-arguments.txt")
    set(applied_arguments_file "${X265_MULTILIB_DIR}/${target}-configure-arguments.applied")
    set(configure_arguments "${X265_CMAKE_ARGS};${ARGN}")

    # write the arguments file only when its content changes, so an unchanged
    # reconfigure does not force a rebuild
    file(MAKE_DIRECTORY "${X265_MULTILIB_DIR}")
    if(EXISTS "${arguments_file}")
        file(READ "${arguments_file}" old_configure_arguments)
    else()
        set(old_configure_arguments "")
    endif()
    if(NOT "${old_configure_arguments}" STREQUAL "${configure_arguments}")
        file(WRITE "${arguments_file}" "${configure_arguments}")
    endif()

    add_custom_command(
            OUTPUT "${library}"
            COMMAND "${CMAKE_COMMAND}"
                "-DX265_BUILD_DIR=${build_dir}"
                "-DX265_ARGUMENTS_FILE=${arguments_file}"
                "-DX265_APPLIED_FILE=${applied_arguments_file}"
                -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/x265-prepare-variant.cmake"
            COMMAND "${CMAKE_COMMAND}"
                -S "${X265_GENERATED_SRC_PATH}/source"
                -B "${build_dir}"
                ${X265_CMAKE_ARGS}
                ${ARGN}
            COMMAND "${CMAKE_COMMAND}"
                --build "${build_dir}"
                --config Release
                --parallel ${N_PROC}
            COMMAND "${CMAKE_COMMAND}"
                "-DX265_LIBRARY=${library}"
                -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/x265-verify-library.cmake"
            # record the fingerprint only after the build and its verification
            # succeeded, so a failed attempt cleans and retries
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different
                "${arguments_file}" "${applied_arguments_file}"
            WORKING_DIRECTORY "${X265_GENERATED_SRC_PATH}"
            DEPENDS ${X265_BUILD_DEPENDS} "${arguments_file}"
                "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/x265-prepare-variant.cmake"
                "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/x265-verify-library.cmake"
            COMMENT "Target: x265 (${target})"
            VERBATIM
    )

    # this target only carries the dependency on the library built above
    add_custom_target(${target} DEPENDS "${library}" COMMENT "Target: x265 (${target})")
endfunction()

# 12-bit is only a building block for the combined library
x265_add_build_variant(x265-12bit "${X265_12BIT_DIR}"
        -DHIGH_BIT_DEPTH=ON
        -DMAIN12=ON
        -DEXPORT_C_API=OFF
        -DENABLE_HDR10_PLUS=OFF
)

# the 10-bit objects encode Main10, so they need HDR10+ support as well
# (on the architectures that support it)
x265_add_build_variant(x265-10bit "${X265_10BIT_DIR}"
        -DHIGH_BIT_DEPTH=ON
        -DEXPORT_C_API=OFF
        -DENABLE_HDR10_PLUS=${X265_ENABLE_HDR10_PLUS}
)

# the 8-bit build is the public one and links the other two through the API
x265_add_build_variant(x265-8bit "${X265_8BIT_DIR}"
        -C "${CMAKE_CURRENT_BINARY_DIR}/x265-8bit-init.cmake"
        -DLINKED_10BIT=ON
        -DLINKED_12BIT=ON
        -DENABLE_HDR10_PLUS=${X265_ENABLE_HDR10_PLUS}
)

# The nested builds run sequentially, bounding the peak number of parallel
# compilers (each nested build uses --parallel ${N_PROC}). The ordering goes
# through add_dependencies: file-level DEPENDS between variant outputs would
# make the Makefile generator duplicate the producing recipe into the
# dependent target, which can then run it concurrently.
add_dependencies(x265-10bit x265-12bit)
add_dependencies(x265-8bit x265-10bit x265-12bit)

# the combined archive is verified with nm; only MSVC (no nm) may skip it
set(X265_NM_OPTIONAL OFF)
if(MSVC)
    set(X265_NM_OPTIONAL ON)
elseif(NOT CMAKE_NM)
    message(FATAL_ERROR "x265 multilib requires nm to verify the combined archive")
endif()

# combine the three archives into one, mirroring the official multilib script;
# the combined library is only published after the bit depth check passes
if(APPLE)
    # Apple ships libtool in /usr/bin; a GNU libtool found elsewhere (e.g. from
    # Conda) has a different interface and cannot merge archives
    find_program(X265_LIBTOOL NAMES libtool PATHS /usr/bin NO_DEFAULT_PATH REQUIRED)
    set(X265_ARCHIVE_MERGE
            "${X265_LIBTOOL}" -static -o "${X265_LIB_NAME}.unverified"
            "${X265_MAIN_NAME}" "${X265_MAIN10_NAME}" "${X265_MAIN12_NAME}"
    )
elseif(MSVC)
    # lib.exe merges the archives passed on the command line; the ignore flags
    # match x265's official multilib.bat. This branch is not exercised by CI,
    # which builds Windows with MinGW.
    set(X265_ARCHIVE_MERGE
            "${CMAKE_AR}" /nologo /ignore:4006,4221 "/OUT:${X265_LIB_NAME}.unverified"
            "${X265_MAIN_NAME}" "${X265_MAIN10_NAME}" "${X265_MAIN12_NAME}"
    )
else()
    # GNU ar, llvm-ar and the libarchive-based ar of the BSDs read MRI scripts
    # from stdin, which covers Linux, FreeBSD and MinGW/MSYS2
    set(X265_ARCHIVE_MERGE
            "${CMAKE_COMMAND}"
            "-DX265_AR=${CMAKE_AR}"
            "-DX265_MRI_SCRIPT=${_x265_mri_file}"
            -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/x265-multilib-ar.cmake"
    )
endif()

# the combination runs with the staging directory as working directory, so it
# has to exist before the build starts
file(MAKE_DIRECTORY "${X265_COMBINE_DIR}")

add_custom_command(
        OUTPUT "${X265_COMBINED_LIB}"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${X265_COMBINE_DIR}"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "${X265_8BIT_DIR}/${X265_LIB_NAME}" "${X265_COMBINE_DIR}/${X265_MAIN_NAME}"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "${X265_10BIT_DIR}/${X265_LIB_NAME}" "${X265_COMBINE_DIR}/${X265_MAIN10_NAME}"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "${X265_12BIT_DIR}/${X265_LIB_NAME}" "${X265_COMBINE_DIR}/${X265_MAIN12_NAME}"
        COMMAND ${X265_ARCHIVE_MERGE}
        COMMAND "${CMAKE_COMMAND}"
            "-DX265_LIBRARY=${X265_UNVERIFIED_LIB}"
            "-DX265_CHECK_DEPTH=ON"
            "-DX265_NM=${CMAKE_NM}"
            "-DX265_NM_OPTIONAL=${X265_NM_OPTIONAL}"
            -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/x265-verify-library.cmake"
        COMMAND "${CMAKE_COMMAND}" -E copy "${X265_UNVERIFIED_LIB}" "${X265_COMBINED_LIB}"
        COMMAND "${CMAKE_COMMAND}" -E rm -f "${X265_UNVERIFIED_LIB}"
        DEPENDS
            "${X265_8BIT_DIR}/${X265_LIB_NAME}"
            "${X265_10BIT_DIR}/${X265_LIB_NAME}"
            "${X265_12BIT_DIR}/${X265_LIB_NAME}"
            "${_x265_mri_file}"
            "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/x265-multilib-ar.cmake"
            "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/x265-verify-library.cmake"
        WORKING_DIRECTORY "${X265_COMBINE_DIR}"
        COMMENT "Combining x265 8/10/12-bit into multilib ${X265_LIB_NAME}"
        VERBATIM
)

# install x265 through its own install rules to get x265.pc and the headers,
# then replace the 8-bit library with the combined multilib archive. The
# installed files are declared outputs as well, so clearing the install prefix
# reinstalls them; the stamp is written last, so failures are retried and the
# prefix is only touched when the combined library changes.
add_custom_command(
        OUTPUT ${X265_INSTALL_OUTPUTS}
        COMMAND "${CMAKE_COMMAND}" --install "${X265_8BIT_DIR}" --config Release
        COMMAND "${CMAKE_COMMAND}"
            "-DX265_PC_FILE=${X265_PC_FILE}"
            -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/x265-verify-pc.cmake"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "${X265_COMBINED_LIB}" "${X265_INSTALL_LIB}"
        COMMAND "${CMAKE_COMMAND}" -E touch "${X265_INSTALL_STAMP}"
        DEPENDS "${X265_COMBINED_LIB}"
            "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ffmpeg/x265-verify-pc.cmake"
        COMMENT "Installing x265 multilib"
        VERBATIM
)
add_custom_target(x265 DEPENDS ${X265_INSTALL_OUTPUTS} COMMENT "Target: x265")
add_dependencies(x265 x265-8bit x265-10bit x265-12bit)
add_dependencies(${CMAKE_PROJECT_NAME} x265)
