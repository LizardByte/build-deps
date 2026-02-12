# Vulkan Headers
set(VULKAN_HEADERS_GENERATED_SRC_PATH ${CMAKE_CURRENT_BINARY_DIR}/FFmpeg/Vulkan-Headers)

add_custom_target(vulkan-headers ALL
        COMMAND ${CMAKE_COMMAND}
            -S ${VULKAN_HEADERS_GENERATED_SRC_PATH}
            -B ${CMAKE_CURRENT_BINARY_DIR}/vulkan-headers-build
            -G "${CMAKE_GENERATOR}"
            -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/vulkan
            -DCMAKE_BUILD_TYPE=Release
        COMMAND ${CMAKE_COMMAND}
            --build ${CMAKE_CURRENT_BINARY_DIR}/vulkan-headers-build
            --target install
        WORKING_DIRECTORY ${VULKAN_HEADERS_GENERATED_SRC_PATH}
        COMMENT "Target: Vulkan-Headers"
        VERBATIM
)
add_dependencies(${CMAKE_PROJECT_NAME} vulkan-headers)

# Vulkan Loader
set(VULKAN_LOADER_GENERATED_SRC_PATH ${CMAKE_CURRENT_BINARY_DIR}/FFmpeg/Vulkan-Loader)

# Configure options for Vulkan-Loader
set(VULKAN_LOADER_CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/vulkan
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
        -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
        -DVULKAN_HEADERS_INSTALL_DIR=${CMAKE_CURRENT_BINARY_DIR}/vulkan
        -DBUILD_STATIC_LOADER=ON
        -DBUILD_SHARED_LIBS=OFF
        -DBUILD_TESTS=OFF
        -DENABLE_WERROR=OFF
)

# Enable Wayland and X11 WSI for Linux and FreeBSD builds
if(UNIX AND NOT APPLE)
    list(APPEND VULKAN_LOADER_CMAKE_ARGS
            -DBUILD_WSI_WAYLAND_SUPPORT=ON
            -DBUILD_WSI_XCB_SUPPORT=ON
            -DBUILD_WSI_XLIB_SUPPORT=ON
    )
endif()

if(CMAKE_CROSSCOMPILING)
    list(APPEND VULKAN_LOADER_CMAKE_ARGS
            -DCMAKE_SYSTEM_NAME=${CMAKE_SYSTEM_NAME}
            -DCMAKE_SYSTEM_PROCESSOR=${CMAKE_SYSTEM_PROCESSOR}
            -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
            -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    )
    if(UNIX AND NOT APPLE)
        list(APPEND VULKAN_LOADER_CMAKE_ARGS
                -DCMAKE_C_COMPILER_TARGET=${CMAKE_C_COMPILER_TARGET}
                -DCMAKE_CXX_COMPILER_TARGET=${CMAKE_CXX_COMPILER_TARGET}
        )
    endif()
endif()

add_custom_target(vulkan-loader ALL
        COMMAND ${CMAKE_COMMAND}
            -S ${VULKAN_LOADER_GENERATED_SRC_PATH}
            -B ${CMAKE_CURRENT_BINARY_DIR}/vulkan-loader-build
            -G "${CMAKE_GENERATOR}"
            ${VULKAN_LOADER_CMAKE_ARGS}
        COMMAND ${CMAKE_COMMAND}
            --build ${CMAKE_CURRENT_BINARY_DIR}/vulkan-loader-build
            --config Release
            --target install
            -- --jobs=${N_PROC}
        WORKING_DIRECTORY ${VULKAN_LOADER_GENERATED_SRC_PATH}
        COMMENT "Target: Vulkan-Loader"
        VERBATIM
        BYPRODUCTS
            "${CMAKE_CURRENT_BINARY_DIR}/vulkan/lib/libvulkan.a"
)
add_dependencies(vulkan-loader vulkan-headers)
add_dependencies(${CMAKE_PROJECT_NAME} vulkan-loader)

# Add to PKG_CONFIG_PATH for FFmpeg to find
set(PKG_CONFIG_PATH "${CMAKE_CURRENT_BINARY_DIR_UNIX}/vulkan/lib/pkgconfig:${PKG_CONFIG_PATH}")
