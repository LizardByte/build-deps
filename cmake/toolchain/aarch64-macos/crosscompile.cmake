# CMake toolchain file for cross compiling to linux aarch64

set(CROSS_COMPILE_ARM 1)
set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_SYSTEM_PROCESSOR arm64)
set(CMAKE_OSX_ARCHITECTURES arm64)

set(CMAKE_C_COMPILER clang)
set(CMAKE_C_COMPILER_TARGET arm64-apple-macosx)
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CXX_COMPILER_TARGET arm64-apple-macosx)
