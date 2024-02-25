# CMake toolchain file for cross compiling to linux aarch64

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

SET(CMAKE_FIND_ROOT_PATH  /usr/aarch64-linux-gnu)
