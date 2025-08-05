CPMGetPackage(Boost)

if(BUILD_BOOST_SUNSHINE)
    set(BUILD_BOOST_LIBDISPLAYDEVICE ON)
endif()

list(APPEND BOOST_COMPONENTS_BASE
        asio
        crc
        format
        process
        property_tree
)

if(BUILD_BOOST_LIBDISPLAYDEVICE)
    list(APPEND BOOST_COMPONENTS
            algorithm
            preprocessor
            scope
            uuid
    )
endif()
if(BUILD_BOOST_SUNSHINE)
    list(APPEND BOOST_COMPONENTS
            filesystem
            locale
            log
            program_options
            system
    )
endif()

set(BOOST_ENABLE_CMAKE ON)  # Use experimental superproject to pull library dependencies recursively
set(BOOST_INCLUDE_LIBRARIES ${BOOST_COMPONENTS_BASE} ${BOOST_COMPONENTS})
set(BOOST_INSTALL_INCLUDE_SUBDIR "")  # boost uses a versioned directory by default on Windows
set(BOOST_SKIP_INSTALL_RULES OFF)  # disabled to allow installation of Boost libraries
set(Boost_USE_STATIC_LIBS ON)  # cmake-lint: disable=C0103

message(STATUS "Boost_BINARY_DIR: ${Boost_BINARY_DIR}")
message(STATUS "Boost_SOURCE_DIR: ${Boost_SOURCE_DIR}")

if(WIN32)
    # Windows build is failing to create header file in this directory
    file(MAKE_DIRECTORY ${Boost_BINARY_DIR}/libs/log/src/windows)
endif()

add_subdirectory(${Boost_SOURCE_DIR} ${Boost_BINARY_DIR} SYSTEM)
