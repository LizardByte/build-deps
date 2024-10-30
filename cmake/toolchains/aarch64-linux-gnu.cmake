# CMake toolchain file for cross compiling to linux aarch64

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(CMAKE_C_COMPILER_TARGET aarch64-linux-gnu)
set(CMAKE_CXX_COMPILER_TARGET ${CMAKE_C_COMPILER_TARGET})
set(CMAKE_C_COMPILER ${CMAKE_C_COMPILER_TARGET}-gcc)
set(CMAKE_CXX_COMPILER ${CMAKE_C_COMPILER_TARGET}-g++)

set(CMAKE_FIND_ROOT_PATH  /usr/${CMAKE_C_COMPILER_TARGET})