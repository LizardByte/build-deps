# CMake toolchain file for cross compiling to linux powerpc64le

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR ppc64le)

set(CMAKE_C_COMPILER powerpc64le-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER powerpc64le-linux-gnu-g++)

SET(CMAKE_FIND_ROOT_PATH  /usr/powerpc64le-linux-gnu)
